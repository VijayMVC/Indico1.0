using System;
using System.IO;
using System.Net;
using Indico.BusinessObjects;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Serialization;
namespace Indico.Common
{
    /// <summary>
    /// helps to find , convert , save images from mail.indico.net.au
    /// </summary>
    public class ImageService:IDisposable
    {
        public DirectoryInfo ImageServiceFilesFolder { get; set; }
        public FileInfo RegisterFile { get; set; }
        public List<VLUrlRecord> Register { get; set; }

        public ImageService()
        {
            ImageServiceFilesFolder= new DirectoryInfo(Path.Combine(Path.Combine(IndicoConfiguration.AppConfiguration.PathToDataFolder, @"ImageServiceFiles"))); ;
            RegisterFile= new FileInfo(Path.Combine(ImageServiceFilesFolder.FullName, "VLUrlRegister.indico"));
            Register = GetRegister();
        }

        public string GetVLImageFromServerIfAvailable(string vlName)
        {
            try
            {
                var newRecord = false;
                vlName = vlName.Trim();
                var imageServiceDirectory = ImageServiceFilesFolder;
                if (!imageServiceDirectory.Exists)
                    imageServiceDirectory.Create();
                var register = GetRegister();
                var record = Register.FirstOrDefault(r => r.VlName == vlName);
                if (record == null)
                {
                    record = new VLUrlRecord { VlName = vlName };
                    if (newRecord)
                        Register.Add(record);
                }
                   
                if (string.IsNullOrWhiteSpace(record.FtpPath))
                {
                    var ftppath = CheckImageForVLAvailable(vlName);
                    if (ftppath == null)
                        return null;
                    record.FtpPath = ftppath;
                }

                ConvertToImage(ref record);
                if (string.IsNullOrEmpty(record.ImagePath))
                    return null;
                ClearRegister(ref register);
                return record.ImagePath;
            }
            catch (Exception e)
            {
                return null;
            }
        }

        private string CheckImageForVLAvailable(string vlName)
        {
            vlName = vlName.Trim();
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

        private void ConvertToImage(ref VLUrlRecord record)
        {
            if (!string.IsNullOrEmpty(record.ImagePath) && new FileInfo(record.ImagePath).Exists)
                return;
            FileInfo cdrFile;
            var cdrFolder = new DirectoryInfo(Path.Combine(IndicoConfiguration.AppConfiguration.PathToDataFolder, "ImageServiceFiles", "CDRFiles"));
            if (!cdrFolder.Exists)
                Directory.CreateDirectory(cdrFolder.FullName);
            var imageFilesFolder = new DirectoryInfo(Path.Combine(IndicoConfiguration.AppConfiguration.PathToDataFolder, "ImageServiceFiles", "ImageFiles"));
            if (!imageFilesFolder.Exists)
                Directory.CreateDirectory(imageFilesFolder.FullName);

            if (!string.IsNullOrEmpty(record.ImagePath) && new FileInfo(record.CDRPath).Exists)
            {
                cdrFile = new FileInfo(record.CDRPath);
            }
            else
            {
                var fileData = DownloadFile(record.FtpPath);
                cdrFile = new FileInfo(Path.Combine(cdrFolder.FullName, Guid.NewGuid() + "_.cdr"));
                if (!cdrFile.Exists)
                    cdrFile.Create().Dispose();
                File.WriteAllBytes(cdrFile.FullName, fileData);
                record.CDRPath = cdrFile.FullName;
            }
            var imageFile = new FileInfo(Path.Combine(imageFilesFolder.FullName, Guid.NewGuid() + "_.png"));
            try
            {
                //TODO Convert using the Tool
                //var cdr = new CorelDRAW.Application();
                //cdr.OpenDocument(cdrFile.FullName, 1);
                //cdr.ActiveDocument.PageSizes.Add("A4", 297, 210);
                //cdr.ActiveDocument.ExportBitmap(
                //    imageFile.FullName,
                //    VGCore.cdrFilter.cdrPNG,
                //    VGCore.cdrExportRange.cdrCurrentPage,
                //    VGCore.cdrImageType.cdrRGBColorImage,
                //    0, 0, 72, 72,
                //    VGCore.cdrAntiAliasingType.cdrSupersampling,
                //    false,
                //    true).Finish();
                //cdr.ActiveDocument.Close();
                //cdr.Quit();
            }
            catch (Exception e)
            {
                //throw e;
            }
            finally
            {
                if (!imageFile.Exists)
                {
                    if (cdrFile.Exists)
                        cdrFile.Delete();
                }
            }
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

        public static Byte[] ToByteArray(Stream stream)
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
            var date = DateTime.Now;
            var cdrFolder = new DirectoryInfo(Path.Combine(IndicoConfiguration.AppConfiguration.PathToDataFolder, "ImageServiceFiles", "CDRFiles"));
            if (!cdrFolder.Exists)
            {
                var files = cdrFolder.GetFiles("*", SearchOption.AllDirectories);
                foreach (var file in files.Where(file => file.CreationTime.AddDays(7) > date || files.Length < 1))
                {
                    file.Delete();
                }
            }
            var imageFilesFolder = new DirectoryInfo(Path.Combine(IndicoConfiguration.AppConfiguration.PathToDataFolder, "ImageServiceFiles", "ImageFiles"));
            if (!imageFilesFolder.Exists)
                return;
            var imageFiles = imageFilesFolder.GetFiles("*", SearchOption.AllDirectories);
            foreach (var file in imageFiles.Where(file => file.CreationTime.AddDays(7) > date || file.Length < 1))
            {
                file.Delete();
            }
        }

        private void ClearRegister(ref List<VLUrlRecord> list)
        {
            var date = DateTime.Now;
            foreach (var it in list)
            {
                var item = it;
                if(item==null)
                    continue;
                if (!string.IsNullOrWhiteSpace(item.CDRPath))
                {
                    var cdr = new FileInfo(item.CDRPath);
                    if (cdr.Exists && (cdr.CreationTime.AddDays(7) > date || cdr.Length < 1))
                        cdr.Delete();
                    else if(!cdr.Exists)
                        it.ImagePath = null;
                }
                else
                    it.CDRPath = null;
                if (!string.IsNullOrWhiteSpace(item.ImagePath))
                {
                    var image = new FileInfo(item.ImagePath);
                    if (image.Exists && (image.CreationTime.AddDays(7) > date || image.Length < 1))
                        image.Delete();
                    else if(!image.Exists)
                        it.ImagePath = null;
                }
                else
                    it.ImagePath = null;
            }
        }

        private List<VLUrlRecord> GetRegister()
        {
            var register = RegisterFile;
            if (!register.Exists)
            {
                register.Create().Close();
                return new List<VLUrlRecord>();
            }
            
            var reader =new StreamReader(register.FullName);
            using (reader)
            {
                var line = "";
                var result = new List<VLUrlRecord>();
                while ((line=reader.ReadLine())!=null)
                {
                    if (string.IsNullOrWhiteSpace(line))
                        continue;
                    var splitted = line.Split(new string[] { "|||" }, 4, StringSplitOptions.None);
                    if (splitted.Length > 3)
                    {
                        result.Add(new VLUrlRecord { VlName = splitted[0], CDRPath = splitted[1], ImagePath = splitted[2], FtpPath = splitted[3] });
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
            if (Register.Count > 0)
            {
                var writer = new StreamWriter(register.FullName) { AutoFlush = true};
                var builder = new StringBuilder();
                using (writer)
                {
                    foreach (var record in Register)
                    {
                        if (record == null || string.IsNullOrWhiteSpace(record.VlName))
                            continue;
                        builder.Append(record.VlName);
                        if (!string.IsNullOrWhiteSpace(record.CDRPath))
                        {
                            builder.Append("|||")
                                .Append(record.CDRPath);
                        }
                        if (!string.IsNullOrWhiteSpace(record.ImagePath))
                        {
                            builder.Append("|||")
                                .Append(record.ImagePath);
                        }
                        if (!string.IsNullOrWhiteSpace(record.FtpPath))
                        {
                            builder.Append("|||")
                                .Append(record.FtpPath);
                        }
                        builder.Append(Environment.NewLine);
                    }

                    writer.Write(builder.ToString());
                }
            }
           
        }

        public class VLUrlRecord
        {
            public string VlName { get; set; }
            public string FtpPath { get; set; }
            public string ImagePath { get; set; }
            public string CDRPath { get; set; }
        }
    }
}