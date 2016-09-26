using System;
using System.IO;
using System.Net;
using Indico.BusinessObjects;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace Indico.Common
{
    /// <summary>
    /// helps to find , convert , save images from mail.indico.net.au
    /// </summary>
    public class ImageService:IDisposable
    {
        public DirectoryInfo ImageServiceFilesFolder { get; set; }
        public FileInfo RegisterFile { get; set; }
        public List<VlUrlRecord> Register { get; set; }

        public ImageService()
        {
            ImageServiceFilesFolder= new DirectoryInfo(Path.Combine(Path.Combine(IndicoConfiguration.AppConfiguration.PathToDataFolder, @"ImageServiceFiles")));
            if(!ImageServiceFilesFolder.Exists)
                ImageServiceFilesFolder.Create();
            RegisterFile= new FileInfo(Path.Combine(ImageServiceFilesFolder.FullName, "VLUrlRegister.indico"));
            Register = GetRegister();
        }

        public string GetVlImageFromServerIfAvailable(string vlName)
        {
            try
            {
                vlName = vlName.Trim();
                var imageServiceDirectory = ImageServiceFilesFolder;
                if (!imageServiceDirectory.Exists)
                    imageServiceDirectory.Create();
                var record = Register.FirstOrDefault(r => r.VlName == vlName);
                if (record == null)
                {
                    record = new VlUrlRecord { VlName = vlName };
                    Register.Add(record);
                }
                   
                if (string.IsNullOrWhiteSpace(record.FtpPath))
                {
                    var ftppath = CheckImageForVlAvailable(ref record);
                    if (ftppath == null)
                        return null;
                    record.FtpPath = ftppath;
                }
                if (string.IsNullOrWhiteSpace(record.CdrPath))
                {
                    var cdrFolder = new DirectoryInfo(Path.Combine(IndicoConfiguration.AppConfiguration.PathToDataFolder, "ImageServiceFiles", "CDRFiles"));
                    if (!cdrFolder.Exists)
                        Directory.CreateDirectory(cdrFolder.FullName);

                    var fileData = DownloadFile(record.FtpPath);
                    var cdrFile = new FileInfo(Path.Combine(cdrFolder.FullName, record.ImageFileName + ".cdr"));
                    File.WriteAllBytes(cdrFile.FullName, fileData);
                    record.CdrPath = cdrFile.FullName;
                }

                if (string.IsNullOrWhiteSpace(record.ImagePath))
                {
                    try { ConvertToImage(ref record); }
                    catch (Exception) {/*ignored*/ }
                }

                if (string.IsNullOrEmpty(record.ImagePath))
                    return null;
                CleanFiles();
                return "/IndicoData/ImageServiceFiles/ImageFiles/"+new FileInfo(record.ImagePath).Name;
            }
            catch (Exception)
            {
                return null;
            }
        }

        private string CheckImageForVlAvailable(ref VlUrlRecord record)
        {
            var vlName = record.VlName.Trim();
            if (!Regex.IsMatch(vlName, @"^[Vv][Ll]\d{1,}$"))
                return null;
            var folders = GetFilesInAFolder(IndicoConfiguration.AppConfiguration.ImagesFtpUrl);
            if (folders==null)
                return null;
            folders = folders.Where(f => f.StartsWith("VL")).ToList();
            if (folders.Count < 1)
                return null;
            var vlNumberMatch = Regex.Match(vlName, @"\d{1,}");
            var vlNumber = Convert.ToInt32(vlNumberMatch.Value);
            var containFolder = "";
            foreach (var folder in folders)
            {
                var splitted = folder.Split('-');
                if(splitted.Length<1)
                    continue;
                var startStr = splitted[0].Trim();
                var endStr = splitted[1].Trim();
                var startMatch = Regex.Match(startStr, @"\d{1,}");
                var endMatch = Regex.Match(endStr, @"\d{1,}");
                var start = Convert.ToInt32(startMatch.Value);
                var end = Convert.ToInt32(endMatch.Value);
                if (vlNumber >= start && vlNumber <= end)
                {
                    containFolder = folder;
                }
            }
            if (containFolder == "")
                return null;
            var files = GetFilesInAFolder(IndicoConfiguration.AppConfiguration.ImagesFtpUrl+containFolder);
            if(files==null )
                return null;
            var targetFile = "";
            foreach (var f in files)
            {
                var fileName = f.TrimEnd('/').Split('/').Last();
                if (!fileName.Trim().StartsWith(vlName))
                    continue;
                record.ImageFileName = fileName.Replace("|||","");
                targetFile = f;
                break;
            }
            return targetFile == "" ? null : "ftp://mail.indico.net.au/"+targetFile;
        }

        private List<string> GetFilesInAFolder(string folder)
        {
            var ftpRequest = (FtpWebRequest)WebRequest.Create(folder);
            ftpRequest.Credentials = new NetworkCredential(IndicoConfiguration.AppConfiguration.ImagesFtpUserName, IndicoConfiguration.AppConfiguration.ImagesFtpPassword);
            ftpRequest.Method = WebRequestMethods.Ftp.ListDirectory;
            ftpRequest.KeepAlive = true;
            var ftpResponse = (FtpWebResponse)ftpRequest.GetResponse();
            var responceStream = ftpResponse.GetResponseStream();
            if (responceStream == null)
                return null;
            var sr = new StreamReader(responceStream);
            var files = new List<string>();
            while (sr.EndOfStream == false)
            {
                var str = sr.ReadLine();
                if (str == null)
                    continue;
                files.Add(str);
            }
            ftpResponse.Close();
            responceStream.Close();
            sr.Close();
            return files;
        }

        private void ConvertToImage(ref VlUrlRecord record)
        {
            if (!string.IsNullOrEmpty(record.ImagePath) && string.IsNullOrWhiteSpace(record.CdrPath))
                return;

            var imageFilesFolder = new DirectoryInfo(Path.Combine(IndicoConfiguration.AppConfiguration.PathToDataFolder, "ImageServiceFiles", "ImageFiles"));
            if (!imageFilesFolder.Exists)
                Directory.CreateDirectory(imageFilesFolder.FullName);

            var imageFile = new FileInfo(Path.Combine(imageFilesFolder.FullName, record.ImageFileName + ".png"));

            var pathtoConverter = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Applications\\CDRConverter.exe";
            var converter = new Process
            {
                StartInfo =
                {
                    FileName = pathtoConverter,
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    Arguments = string.Format("\"{0}\" \"{1}\"",record.CdrPath,imageFile.FullName),
                    RedirectStandardError = true
                }
            };
            converter.Start();

            converter.WaitForExit();
            
            if (imageFile.Exists)
                record.ImagePath = imageFile.FullName;
        }

        private byte[] DownloadFile(string path)
        {
            var ftpRequest = (FtpWebRequest)WebRequest.Create(path);
            ftpRequest.Credentials = new NetworkCredential(IndicoConfiguration.AppConfiguration.ImagesFtpUserName, IndicoConfiguration.AppConfiguration.ImagesFtpPassword);
            ftpRequest.Method = WebRequestMethods.Ftp.DownloadFile;
            var ftpResponse = (FtpWebResponse)ftpRequest.GetResponse();
            var responceStream = ftpResponse.GetResponseStream();
            if (responceStream == null)
                return null;
            var data = ToByteArray(responceStream);
            ftpResponse.Close();
            return data;
        }

        public static byte[] ToByteArray(Stream stream)
        {
            MemoryStream ms = new MemoryStream();
            byte[] chunk = new byte[4096];
            int bytesRead;
            while ((bytesRead = stream.Read(chunk, 0, chunk.Length)) > 0)
            {
                ms.Write(chunk, 0, bytesRead);
            }

            return ms.ToArray();
        }

        private void CleanFiles()
        {
            var cdrFolder = new DirectoryInfo(Path.Combine(ImageServiceFilesFolder.FullName, "CDRFiles"));
            var imageFolder = new DirectoryInfo(Path.Combine(ImageServiceFilesFolder.FullName, "ImageFiles"));
            if (cdrFolder.Exists)
            {
                var cdrFiles = cdrFolder.GetFiles("*", SearchOption.AllDirectories);
                foreach (var 
                    file1 in 
                    cdrFiles.Where(file => file.Exists)
                    .Where(file1 => Register.Count(r => r.CdrPath == file1.FullName) < 1))
                {
                    file1.Delete();
                }
            }
            if (!imageFolder.Exists)
                return;
            var imageFiles = imageFolder.GetFiles("*", SearchOption.AllDirectories);
            foreach (var
                file1 in
                imageFiles.Where(file => file.Exists)
                    .Where(file1 => Register.Count(r => r.ImagePath == file1.FullName) < 1))
            {
                file1.Delete();
            }
        }

        private List<VlUrlRecord> GetRegister()
        {
            var register = RegisterFile;
            if (!register.Exists)
            {
                register.Create().Close();
                return new List<VlUrlRecord>();
            }
            
            var reader =new StreamReader(register.FullName);
            using (reader)
            {
                string line;
                var result = new List<VlUrlRecord>();
                while ((line=reader.ReadLine())!=null)
                {
                    if (string.IsNullOrWhiteSpace(line))
                        continue;
                    var splitted = line.Split(new[] { "|||" }, 5, StringSplitOptions.None);
                    if (splitted.Length > 4)
                    {
                        result.Add(new VlUrlRecord { VlName = splitted[0], CdrPath = splitted[1], ImagePath = splitted[2], FtpPath = splitted[3],ImageFileName=splitted[4] });
                    }
                }
                return result;
            }
        }


        public void Dispose()
        {
            var register = RegisterFile;
            if (!register.Exists)
                register.Create().Close();
            if (Register.Count <= 0)
                return;
            var writer = new StreamWriter(register.FullName);
            var builder = new StringBuilder();
            using (writer)
            {
                foreach (var record in Register.Where(record => record != null && !string.IsNullOrWhiteSpace(record.VlName)))
                {
                    builder.Append(record.VlName);
                    builder.Append("|||")
                        .Append(string.IsNullOrWhiteSpace(record.CdrPath) ? "" : record.CdrPath)
                        .Append("|||")
                        .Append(string.IsNullOrWhiteSpace(record.ImagePath) ? "" : record.ImagePath)
                        .Append("|||")
                        .Append(string.IsNullOrWhiteSpace(record.FtpPath) ? "" : record.FtpPath)
                        .Append("|||")
                        .Append(string.IsNullOrWhiteSpace(record.ImageFileName) ? "" : record.ImageFileName);
                    builder.Append(Environment.NewLine);
                }

                writer.Write(builder.ToString());
            }
        }

        public class VlUrlRecord
        {
            public string VlName { get; set; }
            public string FtpPath { get; set; }
            public string ImagePath { get; set; }
            public string CdrPath { get; set; }
            public string ImageFileName { get; set; }
        }
    }
}