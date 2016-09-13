using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Text.RegularExpressions;

using Indico.BusinessObjects;
using Indico.Common;

namespace jfuExample
{
    /// <summary>
    /// File Upload httphandler to receive files and save them to the server.
    /// </summary>
    public class FileUpload : IHttpHandler
    {
        public bool IsReusable
        {
            get
            {
                return false;
            }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";

            HttpRuntimeSection runTime = (HttpRuntimeSection)WebConfigurationManager.GetSection("system.web/httpRuntime");
            int maxRequestLength = (runTime.MaxRequestLength - 100) * 1024;

            if (context.Request.ContentLength > maxRequestLength)
            {
                return;
            }

            if (context.Request.Files.Count == 0)
            {
                IndicoLogging.log.Error("Upload failed. No files received. " + DateTime.Now.ToString("dd MMM yyyy hh:mm:ss tt"));
                context.Response.Write("No files received.");
            }
            else
            {
                HttpFileCollection filecollection = context.Request.Files;
                for (int i = 0; i < filecollection.Count; i++)
                {
                    HttpPostedFile uploadedfile = filecollection[i];

                    string fileKey = string.Empty;
                    if (context.Request.Params.Get("filekey") != null)
                    {
                        fileKey = context.Request.Params.Get("filekey").Trim();
                    }
                    else
                    {
                        fileKey = (new Random()).Next(100, 999).ToString();
                    }

                    string fileName = Path.GetFileName(uploadedfile.FileName.Trim());
                    double fileSize = Math.Round(double.Parse(uploadedfile.ContentLength.ToString()) / 1024 * 1000) / 1000;
                    string fileType = uploadedfile.ContentType;

                    string subFolder = context.Request.Params.Get("ctl00$subfolder");
                    string folderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + subFolder;
                    string fileUrl = Path.GetFileNameWithoutExtension(fileName.Replace(' ', '-')) + "_" + fileKey + Path.GetExtension(fileName);
                    string filePath = folderPath + "\\" + fileUrl;

                    try
                    {
                        if (!Directory.Exists(folderPath))
                        {
                            Directory.CreateDirectory(folderPath);
                        }

                        uploadedfile.SaveAs(filePath);

                        string height = "0";
                        string width = "0";

                        if (IndicoPage.IsImageFile(Path.GetExtension(filePath)))
                        {
                            System.Drawing.Image activityOrigImage = System.Drawing.Image.FromFile(filePath);
                            SizeF origImageSize = activityOrigImage.PhysicalDimension;
                            List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 250, 140);

                            height = lstImgDimensions[0].ToString();
                            width = lstImgDimensions[1].ToString();
                        }
                        context.Response.Write("{\"name\":\"" + fileName + "\",\"type\":\"" + fileType + "\",\"filesize\":\"" + fileSize.ToString() + "\" ,\"size\":\"" + fileSize.ToString() + " Kb\",\"key\":\"" + fileKey + "\",\"url\":\"" + fileUrl + "\",\"height\":\"" + height + "\",\"width\":\"" + width + "\"}");

                        IndicoLogging.log.Info("Upload Success. " + DateTime.Now.ToString("dd MMM yyyy hh:mm:ss tt") + Environment.NewLine + fileName + " ," + fileUrl + ", " + fileType + ", " + fileSize);
                    }
                    catch (HttpException hx)
                    {
                        IndicoLogging.log.Error("Upload failed. ", hx);
                    }
                }
            }
        }
    }
}