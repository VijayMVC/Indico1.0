using Indico.BusinessObjects;
using iTextSharp.text;
using iTextSharp.text.html.simpleparser;
using iTextSharp.text.pdf;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Xml;
//using Indico.BusinessObjects;

namespace Indico.Common
{
    public class WebServicePattern
    {
        #region Fields

        private PdfContentByte contentByte;
        private BaseFont customFont_PDF;

        static string garmentSpecTemplate;
        HttpForm objPost = null;

        #endregion

        #region Properties

        public BaseFont PDFFont
        {
            get
            {
                if (customFont_PDF == null)
                {
                    customFont_PDF = BaseFont.CreateFont((IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\fonts\DaxOT-WideRegular.otf"), BaseFont.CP1252, BaseFont.EMBEDDED);
                }
                return customFont_PDF;
            }
        }

        public string DeletePatternNumber { get; set; }

        public string img1 { get; set; }

        public string img2 { get; set; }

        public string img3 { get; set; }

        public string img4 { get; set; }

        public string pdf { get; set; }

        public string meas_xml { get; set; }

        public string garment_des { get; set; }

        public string pat_no { get; set; }

        public string s_desc { get; set; }

        public string l_desc { get; set; }

        public string gen_cat { get; set; }

        public string age_group { get; set; }

        public string main_cat_id { get; set; }

        public string sub_cat_id { get; set; }

        public string rating { get; set; }

        public string times { get; set; }

        public string date_entered { get; set; }

        public string GUID { get; set; }

        public static string GarmentSpecHtml
        {
            get
            {
                if (garmentSpecTemplate == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/GarmentSpecHtml.html")); // new StreamReader(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\Indico\\Templates\\GarmentSpecHtml.html");
                    garmentSpecTemplate = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }

                return garmentSpecTemplate;
            }
        }

        #endregion

        #region Constructors

        //public WebServicePattern()
        //{
        //    objPost = new HttpForm(IndicoConfiguration.AppConfiguration.HttpPostURL);
        //}

        public WebServicePattern(bool webApi = false)
        {
            if (!webApi)
            {
                objPost = new HttpForm(IndicoConfiguration.AppConfiguration.HttpPostURL);
            }
        }

        #endregion

        #region Methods

        public string CreateHtml(PatternBO objPattern, string convertType, bool isAllSizes)
        {
            return this.CreateHtml(objPattern, convertType, false, isAllSizes);
        }

        public string CreateHtml(PatternBO objPattern, string convertType, bool tbodyOnly, bool isAllSizes)
        {
            string tbody = "<tr>" +
                           "    <td></td>" +
                           "    <$measurementposition$>" +
                           "</tr>" +
                           "<$records$>";

            string garmentspec = GarmentSpecHtml;
            garmentspec = garmentspec.Replace("<$type$>", (convertType == "0") ? "1.0 cm" : "0.5 inch");

            //List<SizeChartBO> lstSizeCharts = objPattern.SizeChartsWhereThisIsPattern.Where(o => o.objMeasurementLocation.IsSend == true).ToList();
            SizeChartBO objSChart = new SizeChartBO();
            objSChart.Pattern = objPattern.ID;
            List<SizeChartBO> lstSizeCharts = objSChart.SearchObjects().Where(o => o.Val > 0).ToList();

            if (!isAllSizes)
            {
                lstSizeCharts = objSChart.SearchObjects().Where(o => o.objMeasurementLocation.IsSend == true).ToList();
            }

            if (lstSizeCharts.Count > 0)
            {
                string tabledata = string.Empty;
                string records = string.Empty;
                string style = string.Empty;
                List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = lstSizeCharts.OrderBy(o => o.objMeasurementLocation.Key).GroupBy(o => o.MeasurementLocation).ToList();

                foreach (SizeChartBO sizeChart in lstSizeChartGroup[0].ToList())
                {
                    //SizeChartBO objSC = new SizeChartBO();
                    //objSC.Size = sizeChart.Size;

                    //if (objSC.SearchObjects().Where(o => o.Val == 0).Count() != objSC.SearchObjects().Count())
                    //{
                    //    tabledata += "<td align=\"center\" bgcolor=\"#CCCCCC\" style=\"background-color: #CCCCCC; width: 35px; font-weight: bold;\">" + sizeChart.objSize.SizeName + "</td>";
                    //}

                    //if (sizeChart.Val > 0)
                    //{
                    if (tbodyOnly)
                        tabledata += "<td>" + sizeChart.objSize.SizeName + "</td>";
                    else
                        tabledata += "<td align=\"center\" bgcolor=\"#CCCCCC\" style=\"background-color: #CCCCCC; width: 35px; font-weight: bold;\">" + sizeChart.objSize.SizeName + "</td>";
                    //}
                }

                tbody = tbody.Replace("<$measurementposition$>", tabledata);
                garmentspec = garmentspec.Replace("<$measurementposition$>", tabledata);
                bool alternativeRow = false;

                var listTR = lstSizeChartGroup.Select(m => m.First()).ToList();
                foreach (var sizeChart in listTR)
                {
                    //List<SizeChartBO> lstSizeChart = objPattern.SizeChartsWhereThisIsPattern.Where(m => m.MeasurementLocation == sizeChart.MeasurementLocation && m.objMeasurementLocation.IsSend == true).ToList();
                    //int count = lstSizeChart.Where(o => o.Val == 0).Count();

                    //if (lstSizeChart.Count != count)
                    //{
                    //    style = (alternativeRow) ? "#CCCCCC" : "#F5F5F5";
                    //    records += "<tr>";
                    //    records += "<td align=\"left\" bgcolor=" + style + " width=\"250\">" + sizeChart.objMeasurementLocation.Key + ". " + sizeChart.objMeasurementLocation.Name + "</td>";
                    //}

                    //if (sizeChart.Val > 0)
                    //{
                    if (tbodyOnly)
                        records += "<td>" + sizeChart.objMeasurementLocation.Key + ". " + sizeChart.objMeasurementLocation.Name + "</td>";
                    else
                    {
                        style = (alternativeRow) ? "#CCCCCC" : "#F5F5F5";
                        records += "<tr>";
                        records += "<td align=\"left\" bgcolor=" + style + " width=\"250\">" + sizeChart.objMeasurementLocation.Key + ". " + sizeChart.objMeasurementLocation.Name + "</td>";
                    }
                    //}

                    //foreach (var values in lstSizeChart.ToList())
                    //{
                    //    SizeChartBO objSizeChart = new SizeChartBO();
                    //    objSizeChart.Size = values.Size;

                    //    if ((lstSizeChart.Count != count) && (objSizeChart.SearchObjects().Where(o => o.Val == 0).Count() != objSizeChart.SearchObjects().Count()))
                    //    {
                    //        records += (convertType == "0") ? "<td align=\"center\" bgcolor=" + style + " style=\"width: 250px;\">" + Math.Round(Convert.ToDecimal(values.Val.ToString()), 0) + "</td>" :
                    //           "<td align=\"center\" bgcolor=" + style + " style=\"width: 250px;\">" +
                    //           Math.Round((values.Val * (decimal)0.39), 0) + "</td>";
                    //    }
                    //}
                    List<SizeChartBO> lstSizeChart = lstSizeCharts.Where(m => m.MeasurementLocation == sizeChart.MeasurementLocation).ToList();
                    foreach (var values in lstSizeChart.ToList())
                    {
                        //SizeChartBO objSizeChart = new SizeChartBO();
                        //objSizeChart.Size = values.Size;

                        //if ((lstSizeChart.Count != count) && (objSizeChart.SearchObjects().Where(o => o.Val == 0).Count() != objSizeChart.SearchObjects().Count()))
                        //{
                        //    records += (convertType == "0") ? "<td align=\"center\" bgcolor=" + style + " style=\"width: 250px;\">" + Math.Round(Convert.ToDecimal(values.Val.ToString()), 0) + "</td>" :
                        //       "<td align=\"center\" bgcolor=" + style + " style=\"width: 250px;\">" +
                        //       Math.Round((values.Val * (decimal)0.39), 0) + "</td>";
                        //}
                        //if (values.Val > 0)
                        //{
                        if (tbodyOnly)
                            records += "<td><label class=\"cm\">" + Math.Round(Convert.ToDecimal(values.Val.ToString()), 1).ToString() + "</label><label class=\"inches\">" + Math.Round((values.Val * (decimal)0.39), 1).ToString("0.0") + "</label></td>";
                        else
                        {
                            records += (convertType == "0") ? "<td align=\"center\" bgcolor=" + style + " style=\"width: 250px;\">" + Math.Round(Convert.ToDecimal(values.Val.ToString()), 1) + "</td>" :
                              "<td align=\"center\" bgcolor=" + style + " style=\"width: 250px;\">" +
                              Math.Round((values.Val * (decimal)0.39), 1) + "</td>";
                        }
                        //}
                    }

                    records += "</tr>";
                    alternativeRow = !alternativeRow;
                }
                tbody = tbody.Replace("<$records$>", records);
                garmentspec = garmentspec.Replace("<$records$>", records);
            }

            if (tbodyOnly)
                return tbody;
            else
                return garmentspec;
        }

        public void ConstructHttpPost(bool IsDelete)
        {
            try
            {

                if (IsDelete)
                {
                    objPost.SetValue("del_patno", this.DeletePatternNumber);
                    objPost.SetValue("guid", GUID);
                }
                else
                {
                    objPost.SetValue("guid", GUID);
                    objPost.AttachFile("img1", img1);
                    objPost.AttachFile("img2", img2);
                    objPost.AttachFile("img3", img3);
                    objPost.AttachFile("img4", img4);
                    objPost.AttachFile("pdf", pdf);
                    objPost.SetValue("meas_xml", meas_xml);
                    objPost.SetValue("garment_des", garment_des);
                    objPost.SetValue("pat_no", pat_no);
                    objPost.SetValue("s_desc", s_desc);
                    objPost.SetValue("l_desc", l_desc);
                    objPost.SetValue("gen_cat", gen_cat);
                    objPost.SetValue("age_group", age_group);
                    objPost.SetValue("main_cat_id", main_cat_id);
                    objPost.SetValue("sub_cat_id", sub_cat_id);
                    //objPost.SetValue("rating", rating);
                    //objPost.SetValue("times", times);
                    objPost.SetValue("date_entered", date_entered);
                }


            }
            catch (Exception ex)
            {

                IndicoLogging.log.Error("Error occured while executing the HttpPost", ex);
            }
        }

        public void Post(bool IsDelete)
        {
            string result = string.Empty;
            this.ConstructHttpPost(IsDelete);
            System.Net.HttpWebResponse s = objPost.Submit();

            using (Stream responseStream = s.GetResponseStream())
            {
                using (StreamReader readStream = new StreamReader(responseStream, Encoding.UTF8))
                {
                    result = readStream.ReadToEnd();
                }
            }
        }

        public string WriteGramentSpecXML(PatternBO ObjPattern)
        {

            List<SizeChartBO> lstSizeCharts = ObjPattern.SizeChartsWhereThisIsPattern.Where(o => o.objMeasurementLocation.IsSend == true).ToList();
            StringWriter sw = new StringWriter();
            string s = string.Empty;
            if (lstSizeCharts.Count > 0)
            {
                List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = lstSizeCharts.OrderBy(o => o.objMeasurementLocation.Key).GroupBy(o => o.MeasurementLocation).ToList();

                using (XmlTextWriter writer = new XmlTextWriter(sw))
                {
                    writer.WriteStartDocument();
                    writer.WriteStartElement("xml");
                    writer.WriteStartElement("mdtl");


                    writer.WriteStartElement("szs");


                    foreach (SizeChartBO sizeChart in lstSizeChartGroup[0].ToList())
                    {
                        //bool isPrint = false;

                        /* foreach (var sizeChar in lstSizeChartGroup.Select(m => m.First()).ToList())
                         {
                             List<SizeChartBO> lstSizeChart = ObjPattern.SizeChartsWhereThisIsPattern.Where(m => m.MeasurementLocation == sizeChar.MeasurementLocation && m.Size == sizeChart.Size && m.objMeasurementLocation.IsSend == true).ToList();

                             int valcount = 0;

                             foreach (var item in lstSizeChart)
                             {
                                 if (item.Val == 0)
                                 {
                                     valcount++;
                                 }
                             }

                             if (lstSizeChart.Count != valcount)
                             {
                                 isPrint = true;
                             }
                         }*/

                        SizeChartBO objSC = new SizeChartBO();
                        objSC.Size = sizeChart.Size;


                        if (objSC.SearchObjects().Where(o => o.Val == 0).Count() != objSC.SearchObjects().Count())
                        {
                            writer.WriteElementString("sz", sizeChart.objSize.SizeName);
                        }

                    }

                    writer.WriteEndElement();

                    writer.WriteStartElement("mnts");
                    foreach (var sizeChart in lstSizeChartGroup.Select(m => m.First()).ToList())
                    {
                        List<SizeChartBO> lstSizeChart = ObjPattern.SizeChartsWhereThisIsPattern.Where(m => m.MeasurementLocation == sizeChart.MeasurementLocation && m.objMeasurementLocation.IsSend == true).ToList();


                        int count = lstSizeChart.Where(o => o.Val == 0).Count();

                        //foreach (var item in lstSizeChart)
                        //{
                        //    if (item.Val == 0)
                        //    {
                        //        count++;
                        //    }
                        //}


                        if (lstSizeChart.Count != count)
                        {
                            writer.WriteStartElement("mnt");
                            writer.WriteElementString("mpnt", sizeChart.objMeasurementLocation.Key + ". " + sizeChart.objMeasurementLocation.Name);
                            writer.WriteStartElement("unts");
                        }


                        foreach (var values in lstSizeChart.ToList())
                        {
                            //int valueCount = 0;

                            //foreach (var item in lstSizeChart)
                            //{
                            //    if (values.Val == 0)
                            //    {
                            //        valueCount++;
                            //    }
                            //}

                            SizeChartBO objSizeChart = new SizeChartBO();
                            objSizeChart.Size = values.Size;


                            if ((lstSizeChart.Count != count) && (objSizeChart.SearchObjects().Where(o => o.Val == 0).Count() != objSizeChart.SearchObjects().Count()))
                            {
                                writer.WriteElementString("unt", Math.Round(Convert.ToDecimal(values.Val), 0).ToString());
                            }
                        }
                        if (lstSizeChart.Count != count)
                        {
                            writer.WriteEndElement();
                            writer.WriteEndElement();
                        }
                    }

                    writer.WriteEndElement();
                    writer.WriteEndElement();
                    writer.WriteEndElement();

                    writer.Flush();

                    s = sw.ToString().Replace("<?xml version=\"1.0\" encoding=\"utf-16\"?>", string.Empty);
                    /* string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\pattern_" + ObjPattern.Number + ".txt";
                     System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
                     file.WriteLine(s);
                     file.Close();*/
                }

            }
            return s;
        }

        public string CreateImages(PatternBO objPattern, string image)
        {
            var objImageProcess = new ImageProcess();
            string imageSource = string.Empty;
            string newImageSource = string.Empty;
            string folderPath = string.Empty;
            float tempHeight = 0;
            float tempWidth = 0;

            #region CreateFolderPath

            folderPath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/" + objPattern.Number.ToString();

            if (!Directory.Exists(folderPath))
            {
                Directory.CreateDirectory(folderPath);
            }

            #endregion

            if (image == "img4")
            {
                List<PatternTemplateImageBO> lstPatternTemplateImage = objPattern.PatternTemplateImagesWhereThisIsPattern.Where(o => o.IsHero == true).ToList();
                newImageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/" + objPattern.Number.ToString() + "/" + objPattern.Number + ".jpg";

                if (lstPatternTemplateImage.Count > 0)
                {
                    foreach (PatternTemplateImageBO ptImageHero in lstPatternTemplateImage)
                    {
                        imageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + ptImageHero.Pattern.ToString() + "/" + ptImageHero.Filename + ptImageHero.Extension;

                        if (!File.Exists(imageSource))
                        {
                            imageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/gspec-missing.jpg";
                        }
                    }
                }
                else
                {
                    imageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/gspec-missing.jpg";
                }
                if (File.Exists(newImageSource))
                {
                    File.Delete(newImageSource);
                }
                if (!File.Exists(newImageSource))
                {
                    #region resizeImageDimentions

                    System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(imageSource);
                    SizeF origImageSize = VLOrigImage.PhysicalDimension;
                    VLOrigImage.Dispose();

                    tempWidth = 852;
                    tempHeight = (float)Math.Round(((tempWidth / origImageSize.Width) * origImageSize.Height), 0);

                    #endregion

                    objImageProcess.ResizeWebServiceImages(int.Parse(tempWidth.ToString()), int.Parse(tempHeight.ToString()), imageSource, newImageSource);
                }
            }
            if (image == "img2")
            {
                List<PatternTemplateImageBO> lstPatternTemplateImage = objPattern.PatternTemplateImagesWhereThisIsPattern.Where(o => o.IsHero == false && o.ImageOrder == 2).ToList();
                newImageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/" + objPattern.Number.ToString() + "/" + objPattern.Number + "-2" + ".jpg";

                if (lstPatternTemplateImage.Count > 0)
                {
                    imageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + lstPatternTemplateImage[0].Pattern.ToString() + "/" + lstPatternTemplateImage[0].Filename + lstPatternTemplateImage[0].Extension;

                    if (!File.Exists(imageSource))
                    {
                        imageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/gspec-missing.jpg";
                    }
                }
                else
                {
                    imageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/gspec-missing.jpg";
                }

                if (File.Exists(newImageSource))
                {
                    File.Delete(newImageSource);
                }
                if (!File.Exists(newImageSource))
                {
                    #region ResizeImageDimentions

                    System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(imageSource);
                    SizeF origImageSize = VLOrigImage.PhysicalDimension;
                    VLOrigImage.Dispose();

                    tempWidth = 480;
                    tempHeight = (float)Math.Round(((480 / origImageSize.Width) * origImageSize.Height), 0);

                    #endregion

                    objImageProcess.ResizeWebServiceImages(int.Parse(tempWidth.ToString()), int.Parse(tempHeight.ToString()), imageSource, newImageSource);
                }
            }

            if (image == "img3")
            {
                List<PatternTemplateImageBO> lstPatternTemplateImage = objPattern.PatternTemplateImagesWhereThisIsPattern.Where(o => o.IsHero == false && o.ImageOrder == 3).ToList();
                newImageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/" + objPattern.Number.ToString() + "/" + objPattern.Number + "-3" + ".jpg";

                if (lstPatternTemplateImage.Count > 0)
                {
                    imageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + lstPatternTemplateImage[0].Pattern.ToString() + "/" + lstPatternTemplateImage[0].Filename + lstPatternTemplateImage[0].Extension;

                    if (!File.Exists(imageSource))
                    {
                        imageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/gspec-missing.jpg";
                    }
                }
                else
                {
                    imageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/gspec-missing.jpg";
                }

                if (File.Exists(newImageSource))
                {
                    File.Delete(newImageSource);
                }

                if (!File.Exists(newImageSource))
                {
                    #region resizeImageDimentions

                    System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(imageSource);
                    SizeF origImageSize = VLOrigImage.PhysicalDimension;
                    VLOrigImage.Dispose();

                    tempWidth = 480;
                    tempHeight = (float)Math.Round(((480 / origImageSize.Width) * origImageSize.Height), 0);

                    #endregion

                    objImageProcess.ResizeWebServiceImages(int.Parse(tempWidth.ToString()), int.Parse(tempHeight.ToString()), imageSource, newImageSource);
                }
            }

            if (image == "img1")
            {
                List<PatternTemplateImageBO> lstPatternTemplateImage = objPattern.PatternTemplateImagesWhereThisIsPattern.Where(o => o.IsHero == false && o.ImageOrder == 1).ToList();
                newImageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/" + objPattern.Number.ToString() + "/" + objPattern.Number + "-1" + ".jpg";

                if (lstPatternTemplateImage.Count > 0)
                {
                    imageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + lstPatternTemplateImage[0].Pattern.ToString() + "/" + lstPatternTemplateImage[0].Filename + lstPatternTemplateImage[0].Extension;

                    if (!File.Exists(imageSource))
                    {
                        imageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/gspec-missing.jpg";
                    }
                }
                else
                {
                    imageSource = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/gspec-missing.jpg";
                }

                if (File.Exists(newImageSource))
                {
                    File.Delete(newImageSource);
                }

                if (!File.Exists(newImageSource))
                {
                    #region ResizeImageDimentions

                    System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(imageSource);
                    SizeF origImageSize = VLOrigImage.PhysicalDimension;
                    VLOrigImage.Dispose();

                    tempWidth = 480;
                    tempHeight = (float)Math.Round(((480 / origImageSize.Width) * origImageSize.Height), 0);

                    #endregion

                    objImageProcess.ResizeWebServiceImages(int.Parse(tempWidth.ToString()), int.Parse(tempHeight.ToString()), imageSource, newImageSource);
                }
            }
            return newImageSource;
        }

        public string GeneratePDF(PatternBO objPattern, bool isWebService, string convertType, string compressionImagePath = "", bool isAllSizes = false)
        {
            string createpdfPath = string.Empty;
            string imagepath = string.Empty;

            try
            {
                if (isWebService)
                {
                    imagepath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/" + objPattern.Number.ToString() + "/" + objPattern.Number + ".jpg";
                }
                else
                {
                    List<PatternTemplateImageBO> listPTIs = objPattern.PatternTemplateImagesWhereThisIsPattern.Where(o => o.IsHero).ToList();

                    if (listPTIs.Any())
                    {
                        PatternTemplateImageBO objPatternTemplateImage = listPTIs.Last();
                        imagepath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + objPattern.ID.ToString() + "/" + objPatternTemplateImage.Filename + objPatternTemplateImage.Extension;
                    }
                }

                imagepath = (File.Exists(imagepath)) ? imagepath : IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/gspec-missing.jpg";

                createpdfPath = (isWebService) ? IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServicePDF/" + objPattern.Number.ToString() + ".pdf" : IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "GS_" + objPattern.Number.ToString() + ".pdf"; ;

                //Document document = new Document();
                using (var document = new Document())
                using (var writer = PdfWriter.GetInstance(document, new FileStream(createpdfPath, FileMode.Create)))
                {
                    document.AddKeywords("paper airplanes");

                    float marginBottom = 12;
                    float lineHeight = 14;
                    float pageMargin = 20;
                    float pageHeight = iTextSharp.text.PageSize.A4.Width;
                    float pageWidth = iTextSharp.text.PageSize.A4.Height;

                    document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                    document.SetMargins(0, 0, 0, 0);

                    // Open the document for writing content
                    document.Open();
                    // Get the top layer and write some text
                    contentByte = writer.DirectContent;

                    contentByte.BeginText();
                    string content = string.Empty;

                    // Header
                    contentByte.SetFontAndSize(this.PDFFont, 24);
                    content = "GARMENT SPECIFICATION";
                    contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

                    // Title
                    contentByte.SetFontAndSize(this.PDFFont, 9);
                    content = "Pattern " + objPattern.Number + " - " + objPattern.NickName;
                    contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom), 0);

                    content = objPattern.ModifiedDate.ToLongDateString();
                    contentByte.ShowTextAligned(PdfContentByte.ALIGN_RIGHT, content, (pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom), 0);

                    // Footer
                    contentByte.SetFontAndSize(this.PDFFont, 8);
                    content = "© Copyright " + DateTime.Now.Year.ToString() + ", All rights reserved.";
                    contentByte.ShowTextAligned(PdfContentByte.ALIGN_RIGHT, content, (pageWidth - pageMargin), pageMargin, 0);

                    contentByte.EndText();

                    // Top Line
                    contentByte.SetLineWidth(0.5f);
                    contentByte.SetColorStroke(BaseColor.BLACK);
                    contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.Stroke();

                    // Bottom Line
                    contentByte.SetLineWidth(0.5f);
                    contentByte.SetColorStroke(BaseColor.BLACK);
                    contentByte.MoveTo(pageMargin, pageMargin + marginBottom);
                    contentByte.LineTo((pageWidth - pageMargin), pageMargin + marginBottom);
                    contentByte.Stroke();

                    if (string.IsNullOrWhiteSpace(compressionImagePath) && objPattern.PatternCompressionImage != 0 && objPattern.objPatternCompressionImage != null)
                    {
                        var fileName = objPattern.objPatternCompressionImage.Filename;
                        var extension = objPattern.objPatternCompressionImage.Extension;

                        var physicalFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\PatternCompressionImages\\" + objPattern.ID + "\\";

                        if (File.Exists(physicalFolderPath + fileName + extension))
                        {
                            var dataFolderPath = Path.Combine(IndicoConfiguration.AppConfiguration.PathToProjectFolder, IndicoConfiguration.AppConfiguration.DataFolderName);
                            compressionImagePath = Path.Combine(dataFolderPath, "PatternCompressionImages", objPattern.ID.ToString(), fileName + extension);
                        }
                    }
                    if ((objPattern.PatternCompressionImage ?? 0) > 0 && !string.IsNullOrWhiteSpace(compressionImagePath))
                    {
                        var specImage = iTextSharp.text.Image.GetInstance(compressionImagePath);
                        specImage.ScaleToFit(pageWidth - (pageMargin * 2), 230f);
                        specImage.SetAbsolutePosition(((pageWidth - specImage.ScaledWidth) / 2), (pageHeight - (pageMargin * 2) - lineHeight - marginBottom - specImage.ScaledHeight));
                        document.Add(specImage);
                    }
                    else
                    {
                        // Draw Hero Image
                        var heroImage = iTextSharp.text.Image.GetInstance(imagepath);
                        heroImage.ScaleToFit(pageWidth - (pageMargin * 2), 270f);
                        heroImage.SetAbsolutePosition(((pageWidth - heroImage.ScaledWidth) / 2), (pageHeight - (pageMargin * 2) - lineHeight - marginBottom - heroImage.ScaledHeight));
                        document.Add(heroImage);

                        var htmlText = CreateHtml(objPattern, convertType, isAllSizes);
                        var htmlWorker = new HTMLWorker(document);
                        htmlWorker.Parse(new StringReader(htmlText));
                    }

                    document.Close();
                    writer.Close();
                }
                // PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(createpdfPath, FileMode.Create));
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return createpdfPath;
        }

        public void DeleteDirectoriesGivenPattern(PatternBO objPattern)
        {
            string deleteImageDirectory = string.Empty;
            string deletePDFDirectory = string.Empty;

            deleteImageDirectory = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServiceImages/" + objPattern.Number;
            deletePDFDirectory = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/WebServicePattern/WebServicePDF/" + objPattern.Number + ".pdf";
            try
            {
                if (Directory.Exists(deleteImageDirectory))
                {
                    Directory.Delete(deleteImageDirectory, true);
                }

                if (File.Exists(deletePDFDirectory))
                {
                    File.Delete(deletePDFDirectory);
                }

            }
            catch (Exception)
            {

                throw;
            }

        }

        #endregion
    }
}