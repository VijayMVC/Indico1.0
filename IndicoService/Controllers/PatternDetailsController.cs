using Indico.BusinessObjects;
using Indico.Common;
using IndicoService.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Web.Http;

namespace IndicoService.Controllers
{
    public class PatternDetailsController : ApiController
    {
        // GET api/PatternDetails
        public PatternDetailModel Get(string number)
        {
            PatternDetailModel objModel = new PatternDetailModel();

            try
            {
                PatternBO objPattern = new PatternBO();
                objPattern.IsActiveWS = true;
                objPattern.IsActive = true;
                objPattern.Number = number;
                objPattern = objPattern.SearchObjects().SingleOrDefault();

                if (objPattern != null && objPattern.Creator > 0)
                {
                    objModel.Pattern = objPattern.ID;
                    objModel.Number = objPattern.Number;
                    objModel.Remarks = objPattern.Remarks;
                    objModel.Gender = objPattern.objGender.Name;
                    objModel.Description = objPattern.Description;

                    if ((objPattern.PatternCompressionImage ?? 0) > 0)
                    {
                        objModel.GarmentSpecChartImagePath = PopulatePatternCompressionImage(objPattern);
                    }
                    else
                    {
                        List<MeasurementLocation> lstMLocations = new List<MeasurementLocation>();

                        SizeChartBO objSChart = new SizeChartBO();
                        objSChart.Pattern = objPattern.ID;
                        List<SizeChartBO> lstSizeCharts = objSChart.SearchObjects().Where(o => o.objMeasurementLocation.IsSend == true && o.Val > 0).ToList();

                        List<MeasurementLocationBO> lstLocations = lstSizeCharts.Select(m => m.objMeasurementLocation).Distinct().ToList();

                        IEnumerable<IGrouping<string, MeasurementLocationBO>> lst = lstLocations.GroupBy(m => m.Name);

                        foreach (IGrouping<string, MeasurementLocationBO> objML in lst)
                        {
                            MeasurementLocation location = new MeasurementLocation();
                            location.Name = objML.Key;

                            List<SizeChartBO> lstMSizes = lstSizeCharts.Where(m => m.MeasurementLocation == objML.ElementAtOrDefault(0).ID).ToList();

                            foreach (SizeChartBO objSize in lstMSizes)
                            {
                                location.ListSizes.Add(new Size { name = objSize.objSize.SizeName, Value = objSize.Val.ToString() });
                            }

                            lstMLocations.Add(location);
                        }

                        objModel.ListMeasurementLocations = lstMLocations;
                    }

                    //Populate Images
                    PatternTemplateImageBO objOtherImage = new PatternTemplateImageBO();
                    objOtherImage.Pattern = objPattern.ID;
                    List<PatternTemplateImageBO> lstOtherImages = objOtherImage.SearchObjects();

                    List<PatternTemplateImageBO> lstOtherImages1 = lstOtherImages.Where(o => o.ImageOrder == 1).ToList();
                    List<PatternTemplateImageBO> lstOtherImages2 = lstOtherImages.Where(o => o.ImageOrder == 2).ToList();
                    List<PatternTemplateImageBO> lstOtherImages3 = lstOtherImages.Where(o => o.ImageOrder == 3).ToList();

                    objModel.GarmentImagePath1 = TemplateImagePath(lstOtherImages1);
                    objModel.GarmentImagePath2 = TemplateImagePath(lstOtherImages2);
                    objModel.GarmentImagePath3 = TemplateImagePath(lstOtherImages3);
                    objModel.GarmentSpecImagePath = TemplateImagePath(lstOtherImages.Where(o => o.IsHero).ToList(), true);
                }
            }
            catch (Exception ex)
            {
                objModel.Ex = ex;
            }

            return objModel;
        }

        [HttpGet]
        public string Get(int id, int unit = 0) // convertType = 0 : cm / 1 : inch
        {
            try
            {
                PatternBO objPattern = new PatternBO();
                objPattern.ID = id;
                objPattern.GetObject();

                WebServicePattern objWebServicePattern = new WebServicePattern(true);
                string filePath = objWebServicePattern.GeneratePDF(objPattern, false, unit.ToString(), GetCompressionImagePhysicalPath(objPattern));

                filePath = filePath.Replace(IndicoConfiguration.AppConfiguration.PathToProjectFolder, IndicoConfiguration.AppConfiguration.SiteHostAddress.Replace("/", ""));
                filePath = filePath.Replace(@"\", "/");

                return filePath;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        //[HttpGet]
        //public HttpResponseMessage Get(int id, int convertType = 0) // convertType = 0 : cm / 1 : inch
        //{
        //    try
        //    {
        //        PatternBO objPattern = new PatternBO();
        //        objPattern.ID = id;
        //        objPattern.GetObject();

        //        WebServicePattern objWebServicePattern = new WebServicePattern(true);
        //        string filePath = objWebServicePattern.GeneratePDF(objPattern, false, convertType.ToString(), GetCompressionImagePhysicalPath(objPattern));

        //        var stream = new MemoryStream();

        //        using (FileStream file = new FileStream(filePath, FileMode.Open, FileAccess.Read))
        //        {
        //            byte[] bytes = new byte[file.Length];
        //            file.Read(bytes, 0, (int)file.Length);
        //            stream.Write(bytes, 0, (int)file.Length);
        //        }

        //        var result = new HttpResponseMessage(HttpStatusCode.OK)
        //        {
        //            Content = new ByteArrayContent(stream.GetBuffer())
        //        };
        //        result.Content.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("attachment")
        //        {
        //            FileName = objPattern.Number + ".pdf"
        //        };
        //        result.Content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");

        //        return result;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw;
        //    }
        //}

        private string TemplateImagePath(List<PatternTemplateImageBO> lstOtherImages, bool isHero = false)
        {
            string imageFilePath = string.Empty;

            if (lstOtherImages.Any() && lstOtherImages.First().ID > 0)
            {
                PatternTemplateImageBO objPTI = isHero ? lstOtherImages.Last() : lstOtherImages.First();
                imageFilePath = File.Exists(IndicoConfiguration.AppConfiguration.PathToDataFolder + "/PatternTemplates/" + objPTI.Pattern + "/" + objPTI.Filename + objPTI.Extension) ?
                                 IndicoConfiguration.AppConfiguration.SiteHostAddress + IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + objPTI.Pattern + "/" + objPTI.Filename + objPTI.Extension :
                                string.Empty; //IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
            }
            else
            {
                imageFilePath = string.Empty; // IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
            }
            return imageFilePath.ToLower();
        }

        private string PopulatePatternCompressionImage(PatternBO objPattern)
        {
            string dataFolderPath = "/" + IndicoConfiguration.AppConfiguration.DataFolderName;
            string ImagePath = dataFolderPath + "/noimage-png-350px-350px.png";

            if ((objPattern.PatternCompressionImage ?? 0) > 0)
            {
                string fileName = objPattern.objPatternCompressionImage.Filename;
                string extension = objPattern.objPatternCompressionImage.Extension;

                //string physicalFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\PatternCompressionImages\\" + objPattern.ID + "\\";
                string CompressionImagePhysicalPath = GetCompressionImagePhysicalPath(objPattern); // physicalFolderPath + fileName + extension;

                if (File.Exists(CompressionImagePhysicalPath))
                {
                    ImagePath = dataFolderPath + "/PatternCompressionImages/" + objPattern.ID + "/" + fileName + extension;
                }
            }

            return ImagePath;
        }

        private string GetCompressionImagePhysicalPath(PatternBO objPattern)
        {
            string filePath = string.Empty;

            if ((objPattern.PatternCompressionImage ?? 0) > 0)
            {
                string fileName = objPattern.objPatternCompressionImage.Filename;
                string extension = objPattern.objPatternCompressionImage.Extension;
                string physicalFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\PatternCompressionImages\\" + objPattern.ID + "\\";
                filePath = (physicalFolderPath + fileName + extension);
            }

            return filePath;
        }
    }
}
