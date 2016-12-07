using Dapper;
using Indico.BusinessObjects;
using Indico.DAL;
using iTextSharp.text;
using iTextSharp.text.html.simpleparser;
using iTextSharp.text.pdf;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web;
using Excel = Microsoft.Office.Interop.Excel;

namespace Indico.Common
{
    public static class GenerateOdsPdf
    {
        #region Fields

        private static string odsTemplate;
        private static string distributorPOTemplate;
        private static string orderGeneralDetailsTemplate;
        private static string orderGeneralDetailForOfficeTemplate;
        private static string orderOrderDetailsTemplate;
        private static string orderOrderDetailsForOfficeTemplate;
        private static string orderBillingDetailsTemplate;
        private static PdfContentByte contentByte;
        private static BaseFont customFont_PDF;
        private static BaseFont customFontBold_PDF;
        private static string jkGarments;
        private static string jkinvoice;
        private static string jkinvoicesummary;
        private static string orderReport;
        private static string orderReportOrderDetail;
        private static string indimaninvoice;
        private static string batchlabel;
        private static string indimanCostSheet;
        private static string polybaglabels;
        private static string cartonlabels;
        private static string packinglistreport;
        private static string resetlabel;
        private static string shippingdetailslist;
        private static string backorderreport;
        private static string quotedetail;
        private static string clientpackinglistreport;

        #endregion

        #region Properties

        private static string OdsHtml
        {
            get
            {
                if (odsTemplate == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/ODS.html"));
                    odsTemplate = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }

                return odsTemplate;
            }
        }

        private static string DistributorPOTemplate
        {
            get
            {
                if (distributorPOTemplate == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/DistributorPO.html"));
                    distributorPOTemplate = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return distributorPOTemplate;
            }
        }

        private static string OrderGeneralDetailsTemplate
        {
            get
            {
                if (orderGeneralDetailsTemplate == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/OrderReport-GeneralDetails.html"));
                    orderGeneralDetailsTemplate = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return orderGeneralDetailsTemplate;
            }
        }

        private static string OrderGeneralDetailsForOfficeTemplate
        {
            get
            {
                if (orderGeneralDetailForOfficeTemplate != null)
                    return orderGeneralDetailForOfficeTemplate;
                using (var rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/OrderReport-GeneralDetails-ForOffice.html")))
                {
                    orderGeneralDetailForOfficeTemplate = rdr.ReadToEnd();
                    rdr.Close();
                }
                return orderGeneralDetailForOfficeTemplate;
            }
        }

        private static string OrderOrderDetailsTemplate
        {
            get
            {
                if (orderOrderDetailsTemplate == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/OrderReport-OrderDetails.html"));
                    orderOrderDetailsTemplate = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return orderOrderDetailsTemplate;
            }
        }

        private static string OrderOrderDetailsForOfficeTemplate
        {
            get
            {
                if (orderOrderDetailsForOfficeTemplate == null)
                {
                    var rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/OrderReport-OrderDetails-ForOffice.html"));
                    orderOrderDetailsForOfficeTemplate = rdr.ReadToEnd();
                    rdr.Close();
                }
                return orderOrderDetailsForOfficeTemplate;
            }
        }

        private static string OrderBillingDetailsTemplate
        {
            get
            {
                if (orderBillingDetailsTemplate == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/OrderReport-BillingDetails.html"));
                    orderBillingDetailsTemplate = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return orderBillingDetailsTemplate;
            }
        }

        private static string JKGarments
        {
            get
            {
                if (jkGarments == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/JKCostSheet.html"));
                    jkGarments = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return jkGarments;
            }
        }

        private static string JKInvoiceDetail
        {
            get
            {
                if (jkinvoice == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/JKInvoiceDetail.html"));
                    jkinvoice = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return jkinvoice;
            }
        }

        private static string JKInvoiceSummary
        {
            get
            {
                if (jkinvoicesummary == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/JKInvoiceSummary.html"));
                    jkinvoicesummary = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return jkinvoicesummary;
            }
        }

        private static string OrderReport
        {
            get
            {
                if (orderReport == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/OrderReport.html"));
                    orderReport = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return orderReport;
            }
        }

        private static string OrderReportOrderDetail
        {
            get
            {
                if (orderReportOrderDetail == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/OrderReportOrderDetail.html"));
                    orderReportOrderDetail = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return orderReportOrderDetail;
            }
        }

        private static string IndimanInvoice
        {
            get
            {
                // if (indimaninvoice == null)
                // {
                StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/IndimanInvoiceDetail.html"));
                indimaninvoice = rdr.ReadToEnd();
                rdr.Close();
                rdr = null;
                // }
                return indimaninvoice;
            }
        }

        private static string BatchLabel
        {
            get
            {
                if (batchlabel == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/BatchHTML.html"));
                    batchlabel = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return batchlabel;
            }
        }

        private static string IndimanCostSheet
        {
            get
            {
                //if (indimanCostSheet == null)
                // {
                StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/IndimanCostSheet.html"));
                indimanCostSheet = rdr.ReadToEnd();
                rdr.Close();
                rdr = null;
                // }
                return indimanCostSheet;
            }
        }

        private static string PolyBagLabels
        {
            get
            {
                if (polybaglabels == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/PolyBagLabel.html"));
                    polybaglabels = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return polybaglabels;
            }
        }

        private static string CartonLabels
        {
            get
            {
                if (cartonlabels == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/CartonLabel.html"));
                    cartonlabels = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return cartonlabels;
            }
        }

        private static string PackingListReport
        {
            get
            {
                if (packinglistreport == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/PackingList.html"));
                    packinglistreport = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return packinglistreport;
            }
        }

        private static string ResetBarcode
        {
            get
            {
                if (resetlabel == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/ResetLabel.html"));
                    resetlabel = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return resetlabel;
            }
        }

        private static string ShippingDetailsList
        {
            get
            {
                if (shippingdetailslist == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/ShipmentDetailsList.html"));
                    shippingdetailslist = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return shippingdetailslist;
            }
        }

        private static string BackOrder
        {
            get
            {
                if (backorderreport == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/BackOrder.html"));
                    backorderreport = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return backorderreport;
            }
        }

        private static string QuoteDetail
        {
            get
            {
                //if (quotedetail == null)
                //{
                StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/QuoteDetail.html"));
                quotedetail = rdr.ReadToEnd();
                rdr.Close();
                rdr = null;
                // }
                return quotedetail;
            }
        }

        private static BaseFont PDFFont
        {
            get
            {
                if (customFont_PDF == null)
                {
                    customFont_PDF = BaseFont.CreateFont((@"C:\Projects\Indico\IndicoData\fonts\DaxOT-WideRegular.otf"), BaseFont.CP1252, BaseFont.EMBEDDED);
                }
                return customFont_PDF;
            }
        }

        private static BaseFont PDFFontBold
        {
            get
            {
                if (customFontBold_PDF == null)
                {
                    customFontBold_PDF = BaseFont.CreateFont((@"C:\Projects\Indico\IndicoData\fonts\DaxOT-WideBold.otf"), BaseFont.CP1252, BaseFont.EMBEDDED);
                }
                return customFontBold_PDF;
            }
        }

        private static string ClientPackingListReport
        {
            get
            {
                if (clientpackinglistreport == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/ClientPackingList.html"));
                    clientpackinglistreport = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return clientpackinglistreport;
            }
        }

        #endregion

        #region Methods

        public static string CreateODSHtml(OrderDetailBO orderDetail)
        {
            //IndicoPage objIndicoPage = new IndicoPage();
            string odsPrinting = OdsHtml;
            //OrderBO order = orderDetail.objOrder;

            odsPrinting = odsPrinting.Replace("<$type$>", orderDetail.objOrderType.Name);
            odsPrinting = odsPrinting.Replace("<$scheduleddate$>", String.Format("{0:dddd, d MMM yyyy}", orderDetail.ShipmentDate)); //Wednesday, 10 April 2013

            odsPrinting = odsPrinting.Replace("<$product$>", ((orderDetail.objVisualLayout.NameSuffix != null) ? (orderDetail.objVisualLayout.NamePrefix + orderDetail.objVisualLayout.NameSuffix) : orderDetail.objVisualLayout.NamePrefix));
            odsPrinting = odsPrinting.Replace("<$Pattern$>", orderDetail.objPattern.Number + " - " + orderDetail.objPattern.NickName);
            odsPrinting = odsPrinting.Replace("<$fabric$>", orderDetail.objFabricCode.Code + " - " + orderDetail.objFabricCode.NickName);
            odsPrinting = odsPrinting.Replace("<$client$>", orderDetail.objOrder.objClient.Name);
            odsPrinting = odsPrinting.Replace("<$distributor$>", orderDetail.objOrder.objDistributor.Name);
            odsPrinting = odsPrinting.Replace("<$coordinator$>", orderDetail.objOrder.objDistributor.objCoordinator.GivenName + " " + orderDetail.objOrder.objDistributor.objCoordinator.FamilyName);
            odsPrinting = odsPrinting.Replace("<$printtype$>", orderDetail.objPattern.objPrinterType.Name);
            odsPrinting = odsPrinting.Replace("<$profile$>", (orderDetail.objVisualLayout.ResolutionProfile != null && orderDetail.objVisualLayout.ResolutionProfile > 0) ? orderDetail.objVisualLayout.objResolutionProfile.Name : string.Empty);
            odsPrinting = odsPrinting.Replace("<$printer$>", string.Empty);
            odsPrinting = odsPrinting.Replace("<$photo$>", string.Empty);

            odsPrinting = odsPrinting.Replace("<$companyname$>", (orderDetail.DespatchTo.HasValue && orderDetail.DespatchTo.Value > 0) ? orderDetail.objDespatchTo.CompanyName : string.Empty);
            odsPrinting = odsPrinting.Replace("<$address$>", orderDetail.objDespatchTo.Address + " " + orderDetail.objDespatchTo.State);
            odsPrinting = odsPrinting.Replace("<$postalcode$>", orderDetail.objDespatchTo.PostCode + " " + orderDetail.objDespatchTo.objCountry.ShortName);
            odsPrinting = odsPrinting.Replace("<$contact$>", orderDetail.objDespatchTo.ContactName + " " + orderDetail.objDespatchTo.ContactPhone);
            odsPrinting = odsPrinting.Replace("<$port$>", (orderDetail.objDespatchTo.Port != null && orderDetail.objDespatchTo.Port > 0) ? orderDetail.objDespatchTo.objPort.Name : string.Empty);

            odsPrinting = odsPrinting.Replace("<$mode$>", (orderDetail.ShipmentMode != null && orderDetail.ShipmentMode > 0) ? orderDetail.objShipmentMode.Name : string.Empty);
            odsPrinting = odsPrinting.Replace("<$terms$>", (orderDetail.PaymentMethod != null && orderDetail.PaymentMethod > 0) ? orderDetail.objPaymentMethod.Name : string.Empty);

            odsPrinting = odsPrinting.Replace("<$labelname$>", (orderDetail.Label != null && orderDetail.Label > 0) ? orderDetail.objLabel.Name : string.Empty);

            string tabledata = string.Empty;
            //string tabledata2 = string.Empty;
            string tabledata3 = string.Empty;
            string sizespecification = string.Empty;
            int total = 0;

            List<OrderDetailQtyBO> lstODQtys = orderDetail.OrderDetailQtysWhereThisIsOrderDetail;

            foreach (OrderDetailQtyBO item in lstODQtys)
            {
                if (item.Qty > 0)
                {
                    total = total + item.Qty;
                }
            }

            /* tabledata += " <tr><td align=\"center\" style=\"font-size: 8px; line-height:5px;\">Total</td>";
             tabledata += "<td align=\"center\" style=\"font-size: 8px; line-height:5px;\">" + total + "</td> </tr>";

             odsPrinting = odsPrinting.Replace("<$tabledetails$>", tabledata);*/

            string vl = (orderDetail.VisualLayout > 0) ? (orderDetail.objVisualLayout.NameSuffix != null || orderDetail.objVisualLayout.NameSuffix > 0) ? orderDetail.objVisualLayout.NamePrefix + " " + orderDetail.objVisualLayout.NameSuffix.ToString() : orderDetail.objVisualLayout.NamePrefix : string.Empty;

            odsPrinting = odsPrinting.Replace("<$orderdetailmessageline1$>", "<tr><td valign=\"top\" style=\"font-size: 8px\"><p>" + orderDetail.VisualLayoutNotes + "</p></td></tr>");
            odsPrinting = odsPrinting.Replace("<$systemdate$>", String.Format("{0:dddd, d MMM yyyy}", DateTime.Now));

            // size specification            
            sizespecification = "<table border=\"0.5\" cellpadding=\"3\" cellspacing=\"0\" width=\"100%\" style=\"font-size:6px;\">";
            //sizespecification += "<tr><td align=\"center\" width=\"8%\">" + total.ToString() + "</td>";

            PatternBO objPattern = new PatternBO();
            objPattern.ID = orderDetail.Pattern;
            objPattern.GetObject();

            MeasurementLocationBO objMesurementLocation = new MeasurementLocationBO();
            objMesurementLocation.Item = objPattern.Item;
            List<MeasurementLocationBO> lstMeasurementLocation = objMesurementLocation.SearchObjects();

            SizeBO objSize = new SizeBO();
            objSize.SizeSet = objPattern.SizeSet;
            List<int> lstPatternSize = objSize.SearchObjects().Select(o => o.ID).ToList();

            SizeChartBO objPatternSizeChart = new SizeChartBO();
            objPatternSizeChart.Pattern = objPattern.ID;
            List<int> lstSCSize = objPatternSizeChart.SearchObjects().Select(o => o.Size).Distinct().ToList();

            List<int> lstExceptSize = lstPatternSize.Except(lstSCSize).ToList();

            List<SizeChartBO> lstSizeCharts = new List<SizeChartBO>();
            if (lstExceptSize.Count > 0)
            {
                foreach (MeasurementLocationBO mLocation in lstMeasurementLocation)
                {
                    foreach (int size in lstExceptSize)
                    {
                        SizeChartBO objSizeChart = new SizeChartBO();
                        objSizeChart.MeasurementLocation = mLocation.ID;
                        objSizeChart.Size = size;
                        objSizeChart.Val = 0;

                        lstSizeCharts.Add(objSizeChart);
                    }
                }
            }

            if (lstSizeCharts.Count > 0)
            {
                lstSizeCharts.AddRange(objPattern.SizeChartsWhereThisIsPattern);
            }
            else
            {
                lstSizeCharts = objPattern.SizeChartsWhereThisIsPattern;
            }


            if (lstSizeCharts.Count > 0)
            {
                List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = lstSizeCharts.OrderBy(o => o.objMeasurementLocation.Key).GroupBy(o => o.MeasurementLocation).ToList();

                //foreach (OrderDetailQtyBO item in orderDetail.OrderDetailQtysWhereThisIsOrderDetail)
                //{
                //    List<int> lstCount = lstSizeCharts.Where(o => o.Size == item.Size).Select(o => o.Size).ToList();

                //    if (lstCount.Count > 0)
                //    {
                //        sizespecification += "<td align=\"center\" width=\"5%\">" + item.Qty.ToString() + "</td>";
                //    }
                //}

                //sizespecification += "</tr>";

                sizespecification += "<tr><td width=\"8%\" style=\"font-size: 8px;\">Location</td>";

                foreach (SizeChartBO sizeChart in lstSizeChartGroup[0].OrderBy(o => o.objSize.SeqNo).ToList())
                {
                    string qty = (lstODQtys.Where(m => m.Size == sizeChart.Size).Any()) ? (" (" + lstODQtys.Where(m => m.Size == sizeChart.Size).First().Qty + ")") : string.Empty;

                    sizespecification += "<td align=\"center\" width=\"5%\">" + sizeChart.objSize.SizeName + qty + "</td>";
                }

                sizespecification += "</tr>";

                var listTR = lstSizeChartGroup.Select(m => m.First()).ToList();

                foreach (var sizeChart in listTR)
                {
                    List<SizeChartBO> lstSizeChart = lstSizeCharts.Where(m => m.MeasurementLocation == sizeChart.MeasurementLocation).OrderBy(o => o.objSize.SeqNo).ToList();

                    sizespecification += "<tr>";
                    sizespecification += "<td width=\"8%\">" + sizeChart.objMeasurementLocation.Name + "</td>";


                    foreach (var values in lstSizeChart.ToList())
                    {
                        List<OrderDetailQtyBO> lstQty = orderDetail.OrderDetailQtysWhereThisIsOrderDetail.Where(o => o.Size == values.Size).ToList();

                        if (lstQty.Count > 0)
                        {
                            if (lstQty[0].Qty > 0)
                            {
                                sizespecification += "<td  width=\"5%\">" +
                                                     "<table border=\"0\" cellpadding=\"1\" cellspacing=\"0\" width=\"100%\">" +
                                                     "<tr>" +
                                                     "<td style=\"\" width=\"4%\">" + values.Val.ToString() + "</td>" +
                                                     "<td width=\"4%\" border=\"0.5\">&nbsp;</td>" +
                                                     "</tr>" +
                                                     "</table>" +
                                                     "</td>";
                            }
                            else
                            {
                                sizespecification += "<td style=\"color:#ffffff\" width=\"5%\">" + values.Val.ToString() + "</td>";
                            }

                        }
                        else
                        {
                            sizespecification += "<td style=\"color:#ffffff\" width=\"5%\">" + values.Val.ToString() + "</td>";
                        }
                    }
                    sizespecification += "</tr>";
                }
            }
            sizespecification += "</table>";

            odsPrinting = odsPrinting.Replace("<$specification$>", sizespecification);
            //<! --- / ----- >

            string imagepath = string.Empty;
            string vlimages = string.Empty;
            List<float> lstLabelImageDimensions = new List<float>();
            List<float> lstVLImages = new List<float>();

            if (orderDetail.Label != null && orderDetail.Label > 0)
            {
                string filePath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/Labels/" + orderDetail.objLabel.LabelImagePath;

                if (!File.Exists(filePath))
                {
                    filePath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }

                imagepath = filePath;
                System.Drawing.Image Image = System.Drawing.Image.FromFile(imagepath);
                SizeF labelImage = Image.PhysicalDimension;
                Image.Dispose();

                lstLabelImageDimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(labelImage.Width)), Convert.ToInt32(Math.Abs(labelImage.Height)), 150);
            }

            odsPrinting = odsPrinting.Replace("<$image$>", !(string.IsNullOrEmpty(imagepath)) ? "<img src=\"" + imagepath + "\" alt=\"Smiley face\" height=\"" + lstLabelImageDimensions[0].ToString() + "\" width=\"" + lstLabelImageDimensions[1].ToString() + "\" >" : string.Empty);

            ImageBO objImage = new ImageBO();
            objImage.VisualLayout = orderDetail.VisualLayout ?? 0;

            List<ImageBO> lstvlImages = objImage.SearchObjects();

            if (lstvlImages.Count > 0)
            {
                vlimages += "<table width=\"100%\" border=\"0\" cellpadding=\"0\">";
                int i = 0;

                foreach (ImageBO image in lstvlImages)
                {
                    imagepath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/VisualLayout/" + "/" + orderDetail.VisualLayout + "/" + image.Filename + image.Extension;

                    if (!File.Exists(imagepath))
                    {
                        imagepath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    }

                    System.Drawing.Image Image = System.Drawing.Image.FromFile(imagepath);
                    SizeF VlImage = Image.PhysicalDimension;
                    Image.Dispose();

                    lstVLImages = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(VlImage.Width)), Convert.ToInt32(Math.Abs(VlImage.Height)), 500, 500);

                    if (i == 0)
                    {
                        vlimages += "<tr><td  width=\"100%\" align=\"right\"><img src=\"" + imagepath + "\" alt=\"Smiley face\" height=\"" + lstVLImages[0].ToString() + "\" width=\"" + lstVLImages[1].ToString() + "\" ></td></tr>";

                    }
                    else
                    {
                        vlimages += "<tr><td width=\"100%\" style=\"line-height:40px;\" align=\"right\"><img src=\"" + imagepath + "\" alt=\"Smiley face\" height=\"" + lstVLImages[0].ToString() + "\" width=\"" + lstVLImages[1].ToString() + "\" ></td></tr>";
                    }
                    i++;

                }
                vlimages += "</table>";
            }
            odsPrinting = odsPrinting.Replace("<$Vlimage$>", !(string.IsNullOrEmpty(imagepath)) ? vlimages : string.Empty);

            /* string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\ODS_" + orderDetail.ID.ToString() + ".html";
             System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
             file.WriteLine(odsPrinting);
             file.Close();*/

            return odsPrinting;
        }

        public static string GenerateODSPDF(OrderDetailBO objOrderDetail)
        {
            string downloadingpath = IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "ODS_" + objOrderDetail.objOrder.ID.ToString() + "_" + Guid.NewGuid() + ".pdf";
            string createpdfPath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + downloadingpath;


            File.Delete(createpdfPath);

            try
            {
                Document document = new Document();
                PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(createpdfPath, FileMode.Create));
                document.AddKeywords("paper airplanes");

                float marginBottom = 12;
                float lineHeight = 14;
                float pageMargin = 20;
                float pageHeight = iTextSharp.text.PageSize.A4.Height;
                float pageWidth = iTextSharp.text.PageSize.A4.Width;

                document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                document.SetMargins(0, 0, 0, 0);

                // Open the document for writing content
                document.Open();
                // Get the top layer and write some text
                contentByte = writer.DirectContent;

                contentByte.BeginText();
                string content = string.Empty;

                //Header
                contentByte.SetFontAndSize(PDFFont, 14);
                content = "ORDER DETAIL SHEET";
                contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, (pageMargin * 11), (pageHeight - pageMargin - lineHeight), 0);

                // Title
                contentByte.SetFontAndSize(PDFFontBold, 14);
                string order = (string.IsNullOrEmpty(objOrderDetail.objOrder.OldPONo)) ? "PO " + objOrderDetail.objOrder.ID.ToString() : objOrderDetail.objOrder.OldPONo.ToString();
                content = order;
                contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

                contentByte.EndText();
                // Top Line
                contentByte.SetLineWidth(0.5f);
                contentByte.SetColorStroke(BaseColor.BLACK);
                contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                contentByte.Stroke();

                string htmlText = GenerateOdsPdf.CreateODSHtml(objOrderDetail);
                HTMLWorker htmlWorker = new HTMLWorker(document);
                htmlWorker.Parse(new StringReader(htmlText));

                document.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return downloadingpath;
        }

        public static string GenerateMeasurementExcel(OrderDetailBO orderDetail)
        {
            // get a write lock on scCacheKeys
            IndicoPage.RWLock.AcquireWriterLock(Timeout.Infinite);

            string filePath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "Measurement_" + orderDetail.objOrder.ID.ToString() + "_" + Guid.NewGuid() + ".xlsx";
            CreateExcelDocument excell_app = new CreateExcelDocument(false);

            try
            {
                OrderBO order = orderDetail.objOrder;
                order.GetObject();
                int col_1 = 2;
                int rownumber = 0;
                int row = 1;
                string columnName = string.Empty;
                int startrow = 0;
                int removerange = 0;
                char character;

                //*SDS List<SizeChartBO> lstSizeCharts1 = orderDetail.objPattern.SizeChartsWhereThisIsPattern;
                //*SDS List<IGrouping<int, SizeChartBO>> lstSizeChartGroup1 = lstSizeCharts1.OrderBy(o => o.objMeasurementLocation.Key).GroupBy(o => o.Size).ToList();

                OrderDetailQtyBO objODQty = new OrderDetailQtyBO();
                objODQty.OrderDetail = orderDetail.ID;
                List<OrderDetailQtyBO> lstODQTY = objODQty.SearchObjects();

                foreach (OrderDetailQtyBO odq in lstODQTY)
                {
                    if (odq.Qty > 0)
                    {
                        rownumber++;
                        if (rownumber == 1)
                        {
                            int unicode = 65;
                            //first row
                            excell_app.AddHeaderData(1, 1, "PO NUMBER: " + order.ID.ToString(), "A1", "A1", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                            string vlNumber = (orderDetail.objVisualLayout.NameSuffix == null && orderDetail.objVisualLayout.NameSuffix == 0) ? orderDetail.objVisualLayout.NamePrefix : orderDetail.objVisualLayout.NamePrefix + " " + orderDetail.objVisualLayout.NameSuffix;
                            excell_app.AddHeaderData(1, 5, vlNumber, "B1", "E1", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                            excell_app.AddHeaderData(1, 12, "SIZE / QTY: " + odq.objSize.SizeName + "/" + odq.Qty.ToString(), "F1", "L1", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                            excell_app.AddHeaderData(1, 17, "PAT: " + orderDetail.objPattern.Number, "M1", "Q1", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                            //second row
                            excell_app.AddHeaderData(2, 1, "Measurement Location", "A2", "A2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");

                            List<MeasurementLocationBO> lstMeasurementLocation = (from o in (new MeasurementLocationBO()).SearchObjects().Where(o => o.Item == odq.objOrderDetail.objPattern.Item).OrderBy(o => o.Key) select o).ToList();
                            row++;
                            foreach (MeasurementLocationBO ml in lstMeasurementLocation)
                            {
                                character = (char)++unicode;
                                columnName = character.ToString();

                                excell_app.AddHeaderDataWithOrientation(2, col_1, ml.Name, columnName + row, columnName + row, true, true, "Calibri", 11, Excel.XlVAlign.xlVAlignCenter, "General", 90, System.Drawing.Color.Black);

                                col_1++;
                            }

                            col_1 = 14;
                            excell_app.AddHeaderDataWithOrientation(2, col_1, "BUTTONCOLOUR", "N" + row, "N" + row, true, true, "Calibri", 11, Excel.XlVAlign.xlVAlignCenter, "General", 90, System.Drawing.Color.Black);
                            col_1++;
                            excell_app.AddHeaderDataWithOrientation(2, col_1, "ZIP COLOUR", "O" + row, "O" + row, true, true, "Calibri", 11, Excel.XlVAlign.xlVAlignCenter, "General", 90, System.Drawing.Color.Black);
                            col_1++;
                            excell_app.AddHeaderDataWithOrientation(2, col_1, "NAMES AND NUMBERS", "P" + row, "P" + row, true, true, "Calibri", 11, Excel.XlVAlign.xlVAlignCenter, "General", 90, System.Drawing.Color.Black);
                            col_1++;
                            excell_app.AddHeaderDataWithOrientation(2, col_1, "CORRECT CARE & SIZE LABEL", "Q" + row, "Q" + row, true, true, "Calibri", 11, Excel.XlVAlign.xlVAlignCenter, "General", 90, System.Drawing.Color.Black);
                            //third row
                            excell_app.AddHeaderData(3, 1, "Specification", "A3", "A3", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");


                            unicode = 65;
                            col_1 = 2;



                            //*SDS  List<SizeChartBO> lstSizeCharts = ((IGrouping<int, SizeChartBO>)lstSizeChartGroup1[removerange]).ToList();
                            GetMeasureLocForPatternSizeViewBO objMeasureLocs = new GetMeasureLocForPatternSizeViewBO();
                            objMeasureLocs.Pattern = orderDetail.objPattern.ID;
                            objMeasureLocs.Size = odq.objSize.ID;
                            List<GetMeasureLocForPatternSizeViewBO> sizes = objMeasureLocs.SearchObjects().OrderBy(o => o.Key).ToList();

                            //*SDS foreach (SizeChartBO scharts in lstSizeCharts)
                            foreach (GetMeasureLocForPatternSizeViewBO schart in sizes)
                            {
                                row++;
                                excell_app.AddHeaderData(3, col_1, schart.Val.ToString(), columnName + row, columnName + row, true, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                                col_1++;
                            }

                            removerange++;


                            row = 4;
                            for (int i = 1; i < odq.Qty + 1; i++)
                            {
                                col_1 = 2;
                                excell_app.AddData(row, 1, i.ToString(), "A" + col_1, "A" + col_1, null, Excel.XlHAlign.xlHAlignCenter);

                                if (i == odq.Qty + 1)
                                {
                                    excell_app.AddData(row, 1, "", "A" + col_1, "A" + col_1, null, Excel.XlHAlign.xlHAlignCenter);
                                    col_1 = 2;
                                }
                                row++;
                            }

                            row--;
                            excell_app.BorderAround("A1", "Q" + row);
                        }
                        else
                        {
                            int unicode = 65;
                            row = row + 2;
                            startrow = row;
                            //excell_app.ResizeCell(startrow, 1, 20);
                            excell_app.AddHeaderData(row, 1, "PO NUMBER: " + order.ID.ToString(), "A" + row, "A" + row, true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                            string vlNumber = (orderDetail.objVisualLayout.NameSuffix == null && orderDetail.objVisualLayout.NameSuffix == 0) ? orderDetail.objVisualLayout.NamePrefix : orderDetail.objVisualLayout.NamePrefix + " " + orderDetail.objVisualLayout.NameSuffix;
                            excell_app.AddHeaderData(row, 5, vlNumber, "B" + row, "E" + row, true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                            excell_app.AddHeaderData(row, 12, "SIZE / QTY: " + odq.objSize.SizeName.ToString() + "/" + odq.Qty.ToString(), "F" + row, "L" + row, true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                            excell_app.AddHeaderData(row, 17, "PATTERN " + orderDetail.objPattern.Number, "M" + row, "Q" + row, true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");

                            row++;
                            excell_app.AddHeaderData(row, 1, "Measurement Location", "A" + row, "A" + row, true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");

                            List<MeasurementLocationBO> lstMeasurementLocation = (from o in (new MeasurementLocationBO()).SearchObjects().Where(o => o.Item == odq.objOrderDetail.objPattern.Item).OrderBy(o => o.Key) select o).ToList();
                            foreach (MeasurementLocationBO ml in lstMeasurementLocation)
                            {
                                character = (char)++unicode;
                                columnName = character.ToString();

                                excell_app.AddHeaderDataWithOrientation(row, col_1, ml.Name, columnName + row, columnName + row, true, true, "Calibri", 11, Excel.XlVAlign.xlVAlignCenter, "General", 90, System.Drawing.Color.Black);

                                col_1++;
                            }

                            col_1 = 14;
                            excell_app.AddHeaderDataWithOrientation(row, col_1, "BUTTONCOLOUR", "N" + row, "N" + row, false, true, "Calibri", 11, Excel.XlVAlign.xlVAlignCenter, "General", 90, System.Drawing.Color.Black);
                            col_1++;
                            excell_app.AddHeaderDataWithOrientation(row, col_1, "ZIP COLOUR", "O" + row, "O" + row, false, true, "Calibri", 11, Excel.XlVAlign.xlVAlignCenter, "General", 90, System.Drawing.Color.Black);
                            col_1++;
                            excell_app.AddHeaderDataWithOrientation(row, col_1, "NAMES AND NUMBERS", "P" + row, "P" + row, false, true, "Calibri", 11, Excel.XlVAlign.xlVAlignCenter, "General", 90, System.Drawing.Color.Black);
                            col_1++;
                            excell_app.AddHeaderDataWithOrientation(row, col_1, "CORRECT CARE & SIZE LABEL", "Q" + row, "Q" + row, false, true, "Calibri", 11, Excel.XlVAlign.xlVAlignCenter, "General", 90, System.Drawing.Color.Black);


                            row++;
                            excell_app.AddHeaderData(row, 1, "Specification", "A" + row, "A" + row, true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");


                            unicode = 65;
                            col_1 = 2;


                            GetMeasureLocForPatternSizeViewBO objMeasureLocs = new GetMeasureLocForPatternSizeViewBO();
                            objMeasureLocs.Pattern = orderDetail.objPattern.ID;
                            objMeasureLocs.Size = odq.objSize.ID;
                            List<GetMeasureLocForPatternSizeViewBO> sizes = objMeasureLocs.SearchObjects().OrderBy(o => o.Key).ToList();

                            //*SDS foreach (SizeChartBO scharts in lstSizeCharts)
                            foreach (GetMeasureLocForPatternSizeViewBO schart in sizes)
                            {
                                character = (char)++unicode;
                                columnName = character.ToString();
                                excell_app.AddHeaderData(row, col_1, schart.Val.ToString(), columnName + row, columnName + row, true, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                                col_1++;
                            }
                            removerange++;




                            for (int i = 1; i <= odq.Qty + 1; i++)
                            {
                                col_1 = 2;
                                row++;
                                excell_app.AddData(row, 1, i.ToString(), "A" + col_1, "A" + col_1, null, Excel.XlHAlign.xlHAlignCenter);

                                if (i == odq.Qty + 1)
                                {
                                    excell_app.AddData(row, 1, "", "A" + col_1, "A" + col_1, null, Excel.XlHAlign.xlHAlignCenter);
                                    col_1 = 2;
                                }
                            }
                            row--;
                            excell_app.BorderAround("A" + startrow, "Q" + row);
                        }
                    }
                }


                //excell_app.CloseDocument(filePath);
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Generation Excel.", ex);
            }
            finally
            {
                // Save & Close the Excel Document
                excell_app.CloseDocument(filePath);

                // release the lock
                IndicoPage.RWLock.ReleaseWriterLock();
            }
            return filePath;
        }

        public static string CreateJKCostSheetHTML(CostSheetBO objCostSheet)
        {
            string jkgarmentshtmlstring = JKGarments;
            string pricedetails = string.Empty;
            decimal totalfabric = 0;
            decimal totalaccessory = 0;
            string factoryremarks = string.Empty;
            string costsheetimages = string.Empty;
            string filepath = string.Empty;
            List<float> lstCostSheetImages = new List<float>();

            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$costsheetid$>", objCostSheet.ID.ToString());
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$patternnumber$>", objCostSheet.objPattern.Number + " - " + objCostSheet.objPattern.Remarks);
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$mainfabric$>", objCostSheet.objFabric.Name);
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$modifieddate$>", objCostSheet.ModifiedDate.HasValue ? Convert.ToDateTime(objCostSheet.ModifiedDate.ToString()).ToString("dd MMMM yyyy") : string.Empty);
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$modifier$>", ((objCostSheet.Modifier ?? 0) > 0) ? objCostSheet.objModifier.GivenName + " " + objCostSheet.objModifier.FamilyName : string.Empty);

            pricedetails = "<tr>" +
                           "<td>" +
                           "<table border=\"0.5\" style=\"text-align:center;\">" +
                           "<tr>" +
                           "<td bgcolor=\"#87CEFA\" width=\"20\" style=\"text-align:center; \">Fab Code</td>" +
                           "<td bgcolor=\"#87CEFA\" width=\"30\" style=\"text-align:center; \">Fab Description</td>" +
                           "<td bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Supplier </td>" +
                           "<td bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Cons</td>" +
                           "<td bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Unit</td>" +
                           "<td bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Rate</td>" +
                           "<td bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Cost</td>" +
                           "</tr>";

            foreach (PatternSupportFabricBO fabric in (new PatternSupportFabricBO()).SearchObjects().Where(o => o.CostSheet == objCostSheet.ID).ToList())
            {
                string supplier = (fabric.objFabric.Supplier != null && fabric.objFabric.Supplier > 0) ? fabric.objFabric.objSupplier.Name : "&nbsp;";
                string unit = (fabric.objFabric.Unit != null && fabric.objFabric.Unit > 0) ? fabric.objFabric.objUnit.Name : "&nbsp;";
                decimal rate = (fabric.objFabric.FabricPrice != null) ? Convert.ToDecimal(fabric.objFabric.FabricPrice.ToString()) : 0;
                decimal price = Convert.ToDecimal(fabric.FabConstant.ToString()) * rate;
                totalfabric = totalfabric + price;
                string nickname = (!string.IsNullOrEmpty(fabric.objFabric.NickName)) ? fabric.objFabric.NickName : "&nbsp;";

                pricedetails += "<tr><td width=\"20\" style=\"text-align:center; \">" + fabric.objFabric.Code + "</td>";
                pricedetails += "<td width=\"30\" style=\"text-align:center; \">" + nickname + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \">" + supplier + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \">" + fabric.FabConstant.ToString("0.00") + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \">" + unit + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \"> $ " + rate.ToString("0.00") + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \"> $ " + price.ToString("0.00") + "</td></tr>";
            }

            pricedetails += "<tr>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td style=\"text-align:center;\"><b>Total</b></td>" +
                            "<td style=\"text-align:center; \"><b> $ " + totalfabric.ToString("0.00") + "</b></td>" +
                            "</tr>" +
                            "</table>";
            //jkgramentshtmlstring = jkgramentshtmlstring.Replace("<$pricedetails$>", pricedetails);

            pricedetails += "<table>" +
                            "<tr>" +
                            "<td  style=\"line-height: 50px;>&nbsp;</td><td height=\"100\">&nbsp;</td>" +
                            "<td height=\"100\">&nbsp;</td>" +
                            "<td height=\"100\">&nbsp;</td>" +
                            "<td height=\"100\">&nbsp;</td>" +
                            "<td height=\"100\">&nbsp;</td>" +
                            "<td style=\"color: #F0FFFF;\">HOOOOOOO</td>" +
                            "</tr>" +
                            "</table>";
            pricedetails += "<tr>" +
                            "<td style=\"line-height: 50;\">&nbsp;</td>" +
                            "</tr>";
            pricedetails += "<tr>" +
                            "<td>" +
                            "<table  border=\"0.5\">" +
                            "<tr>" +
                            "<th bgcolor=\"#87CEFA\" width=\"20\" style=\"text-align:center; \">Acc Code</th>" +
                            "<th bgcolor=\"#87CEFA\" width=\"30\" style=\"text-align:center; \">Acc Description</th>" +
                            "<th bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Supplier </th>" +
                            "<th bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Cons</th>" +
                            "<th bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Unit</th>" +
                            "<th bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Rate</th>" +
                            "<th bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Cost</th>" +
                            "</tr>";

            foreach (PatternSupportAccessoryBO accessory in (new PatternSupportAccessoryBO()).SearchObjects().Where(o => o.CostSheet == objCostSheet.ID).ToList())
            {
                string supplier = (accessory.objAccessory.Supplier != null && accessory.objAccessory.Supplier > 0) ? accessory.objAccessory.objSupplier.Name : string.Empty;
                string unit = (accessory.objAccessory.Unit != null && accessory.objAccessory.Unit > 0) ? accessory.objAccessory.objUnit.Name : string.Empty;
                decimal rate = (accessory.objAccessory.Cost != null) ? Convert.ToDecimal(accessory.objAccessory.Cost.ToString()) : 0;
                decimal price = Convert.ToDecimal(accessory.AccConstant.ToString()) * rate;
                totalaccessory = totalaccessory + price;

                pricedetails += "<tr><td width=\"20\" style=\"text-align:center; \">" + accessory.objAccessory.Name + "</td>";
                pricedetails += "<td width=\"30\" style=\"text-align:center; \">" + accessory.objAccessory.Description + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \">" + supplier + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \">" + accessory.AccConstant.ToString("0.00") + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \">" + unit + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \"> $ " + rate.ToString("0.00") + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \"> $ " + price.ToString("0.00") + "</td></tr>";
            }

            // pricedetails += "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td style=\"border: #F3E solid 1px;\">" + totalaccessory.ToString("0.00") + "</td></tr>";
            pricedetails += "<tr>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td  border=\"0\">&nbsp;</td>" +
                            "<td  border=\"0\">&nbsp;</td>" +
                            "<td  border=\"0\">&nbsp;</td>" +
                            "<td style=\"text-align:center;\"><b>Total</b></td>" +
                            "<td width=\"10\" style=\"text-align:center; \"><b> $ " + totalaccessory.ToString("0.00") + "</b></td>" +
                            "</tr>" +
                            "</table>" +
                            "</td>" +
                            "</tr>";
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$pricedetails$>", pricedetails);

            CostSheet objCostValues = new AddEditFactoryCostSheet().CalculateCostSheet(objCostSheet);

            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$totalfabriccost$>", Convert.ToDecimal(totalfabric).ToString("0.00"));
            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$totalaccessorycost$>", Convert.ToDecimal(totalaccessory).ToString("0.00"));
            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$totalhpcost$>", Convert.ToDecimal(objCostSheet.HPCost).ToString("0.00"));
            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$totallabelcost$>", Convert.ToDecimal(objCostSheet.LabelCost).ToString("0.00"));
            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$othercost$>", Convert.ToDecimal(objCostSheet.Other).ToString("0.00"));
            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$wastage$>", Convert.ToDecimal(objCostSheet.Wastage).ToString("0.00"));
            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$finance$>", Convert.ToDecimal(objCostSheet.Finance).ToString("0.00"));

            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$totalfabriccost$>", Convert.ToDecimal(objCostValues.totalFabricCost).ToString("0.00"));
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$totalaccessorycost$>", Convert.ToDecimal(objCostValues.totalAccCost).ToString("0.00"));
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$totalhpcost$>", Convert.ToDecimal(objCostValues.heatpress).ToString("0.00"));
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$totallabelcost$>", Convert.ToDecimal(objCostValues.labelCost).ToString("0.00"));
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$othercost$>", Convert.ToDecimal(objCostValues.packing).ToString("0.00"));
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$wastage$>", Convert.ToDecimal(objCostValues.wastage).ToString("0.00"));
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$finance$>", Convert.ToDecimal(objCostValues.finance).ToString("0.00"));

            //decimal totalAccCost = objCostSheet.TotalAccessoriesCost ?? 0;
            //decimal heatpress = objCostSheet.HPCost;
            //decimal labelCost = objCostSheet.LabelCost;
            //decimal packing = objCostSheet.Other ?? 0;
            //decimal wastage = objCostSheet.Wastage;
            //decimal subWastage = (totalAccCost + heatpress + labelCost + packing) * Convert.ToDecimal(0.03);

            //decimal finance = objCostSheet.Finance;
            //decimal subFinance = (totalfabric + totalAccCost + heatpress + labelCost + packing) * Convert.ToDecimal(0.04);

            //decimal smv = objCostSheet.objPattern.SMV ?? 0;
            //decimal smvRate = objCostSheet.SMVRate ?? 0;
            //decimal calculatedCM = smv * smvRate;

            //decimal FOBCost = calculatedCM + totalfabric + totalAccCost + heatpress + labelCost + packing + subWastage + subFinance;
            //FOBCost = decimal.Truncate(FOBCost * 100) / 100;

            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$subwastage$>", subWastage.ToString("0.00")); // wastage
            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$subfinance$>", subFinance.ToString("0.00")); // finance
            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$smv$>", Convert.ToDecimal(objCostSheet.objPattern.SMV).ToString("0.00"));
            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$smvrate$>", Convert.ToDecimal(objCostSheet.SMVRate).ToString("0.00"));
            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$cm$>", calculatedCM.ToString("0.00")); // CM
            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$fobcost$>", FOBCost.ToString("0.00")); // fob cost
            //jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$fobcostroundup$>", Convert.ToDecimal((objCostSheet.QuotedFOBCost != null && objCostSheet.QuotedFOBCost != decimal.Parse("0")) ? objCostSheet.QuotedFOBCost.ToString() : (objCostSheet.JKFOBCost != null) ? objCostSheet.JKFOBCost.ToString() : "0").ToString("0.00"));

            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$subwastage$>", objCostValues.subWastage.ToString("0.00")); // wastage
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$subfinance$>", objCostValues.subFinance.ToString("0.00")); // finance
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$smv$>", Convert.ToDecimal(objCostValues.smv).ToString("0.00"));
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$smvrate$>", Convert.ToDecimal(objCostValues.smvRate).ToString("0.00"));
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$cm$>", objCostValues.calculatedCM.ToString("0.00")); // CM
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$fobcost$>", objCostValues.FOBCost.ToString("0.00")); // fob cost
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$fobcostroundup$>", objCostValues.JKQuotedFOB.ToString("0.00")); //Convert.ToDecimal((objCostSheet.QuotedFOBCost != null && objCostSheet.QuotedFOBCost != decimal.Parse("0")) ? objCostSheet.QuotedFOBCost.ToString() : (objCostSheet.JKFOBCost != null) ? objCostSheet.JKFOBCost.ToString() : "0").ToString("0.00"));

            // factory remarks
            List<CostSheetRemarksBO> lstRemarks = (new CostSheetRemarksBO()).GetAllObject().Where(o => o.CostSheet == objCostSheet.ID).ToList();
            if (lstRemarks.Count > 0)
            {
                factoryremarks += "<tr><td><table border=\"0\" width=\"100%\">";

                foreach (CostSheetRemarksBO remarks in lstRemarks)
                {
                    factoryremarks += "<tr><td width=\"30%\">" + remarks.objModifier.GivenName + " " + remarks.objModifier.FamilyName + "</td><td  width=\"30%\">" + remarks.ModifiedDate.ToString("dd MMMM yyyy") + "</td><td width=\"40%\">" + remarks.Remarks + "</td></tr>";
                }
                factoryremarks += "</table></td></tr>";
            }
            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$remarks$>", factoryremarks);

            // cost sheet images 

            List<PatternTemplateImageBO> lstCostSheetimages = (new PatternTemplateImageBO()).GetAllObject().Where(o => o.Pattern == objCostSheet.Pattern && o.IsHero == true).ToList();
            if (lstCostSheetimages.Count > 0)
            {
                //costsheetimages += "<tr><td style=\"text-align:left;\"><table style=\"text-align:left;\"><tr>";
                foreach (PatternTemplateImageBO image in lstCostSheetimages)
                {
                    filepath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + "/" + objCostSheet.Pattern + "/" + image.Filename + image.Extension;

                    if (!File.Exists(filepath))
                    {
                        filepath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    }

                    System.Drawing.Image Image = System.Drawing.Image.FromFile(filepath);
                    SizeF CostSheetImage = Image.PhysicalDimension;
                    Image.Dispose();

                    lstCostSheetImages = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(CostSheetImage.Width)), Convert.ToInt32(Math.Abs(CostSheetImage.Height)), 700, 700);
                    costsheetimages += "<tr><td  style=\"text-align:left;\"><img src=\"" + filepath + "\" alt=\"Smiley face\" height=\"" + lstCostSheetImages[0].ToString() + "\" width=\"" + lstCostSheetImages[1].ToString() + "\" ></td></tr>";
                }

                //costsheetimages += "</tr></table></td></tr>";
            }

            jkgarmentshtmlstring = jkgarmentshtmlstring.Replace("<$images$>", costsheetimages);

            /*string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\pattern_" + objCostSheet.ID.ToString() + ".html";
            System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
            file.WriteLine(jkgramentshtmlstring);
            file.Close();*/

            return jkgarmentshtmlstring;
        }

        public static string GenerateJKCostSheetPDF(int costsheet)
        {
            string jkcostsheetpath = string.Empty;
            if (costsheet > 0)
            {
                CostSheetBO objCostSheet = new CostSheetBO();
                objCostSheet.ID = costsheet;
                objCostSheet.GetObject();

                Document document = new Document();

                try
                {
                    jkcostsheetpath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "JKCostSheet_" + objCostSheet.ID.ToString() + "_" + objCostSheet.Pattern.ToString() + "_" + objCostSheet.Fabric.ToString() + "_" + ".pdf";

                    if (File.Exists(jkcostsheetpath))
                    {
                        File.Delete(jkcostsheetpath);
                    }

                    PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(jkcostsheetpath, FileMode.Create));
                    document.AddKeywords("paper airplanes");

                    float marginBottom = 12;
                    float lineHeight = 14;
                    float pageMargin = 20;
                    float pageHeight = iTextSharp.text.PageSize.A4.Height;
                    float pageWidth = iTextSharp.text.PageSize.A4.Width;

                    document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                    document.SetMargins(0, 0, 0, 0);

                    // Open the document for writing content
                    document.Open();
                    // Get the top layer and write some text
                    contentByte = writer.DirectContent;

                    contentByte.BeginText();
                    string content = string.Empty;

                    //Header
                    contentByte.SetFontAndSize(PDFFont, 10);
                    content = "JK GARMENTS - SUBLIMATION GARMENTS - COST SHEET";
                    contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

                    contentByte.EndText();
                    // Top Line
                    contentByte.SetLineWidth(0.5f);
                    contentByte.SetColorStroke(BaseColor.BLACK);
                    contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.Stroke();

                    string htmlText = GenerateOdsPdf.CreateJKCostSheetHTML(objCostSheet);
                    HTMLWorker htmlWorker = new HTMLWorker(document);
                    htmlWorker.Parse(new StringReader(htmlText));
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while Generate Pdf JKCostSheet in GenerateOdsPdf Class", ex);
                }

                document.Dispose();
                document.Close();
            }
            return jkcostsheetpath;
        }

        private static string CreateJKInvoiceDetailHTML(InvoiceBO objInvoice)
        {
            string jkinvoicedetailhtmlstring = JKInvoiceDetail;
            string invoicedetail = string.Empty;
            int recordcount = 0;
            string finalrecord = string.Empty;
            int masterqty = 0;
            decimal masteramount = 0;
            decimal total = 0;
            int rowIndex = 1;

            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$invoiceno$>", objInvoice.InvoiceNo);
            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$shipmentdate$>", objInvoice.InvoiceDate.ToString("dd MMMM yyyy"));
            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$shipcompanyname$>", objInvoice.objShipTo.CompanyName);
            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$shipcompanyaddress$>", objInvoice.objShipTo.Address + "  " + objInvoice.objShipTo.State);
            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$shipcompanypostalcode$>", objInvoice.objShipTo.PostCode + "  " + objInvoice.objShipTo.objCountry.ShortName);
            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$shipcompanycontact$>", objInvoice.objShipTo.ContactName + "  " + objInvoice.objShipTo.ContactPhone);
            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$shipmentmode$>", objInvoice.objShipmentMode.Name);
            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$awbno$>", objInvoice.AWBNo);
            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$port$>", (objInvoice.objBillTo.Port != null && objInvoice.objBillTo.Port > 0) ? objInvoice.objBillTo.objPort.Name : string.Empty);

            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$billtocompanyname$>", objInvoice.objBillTo.CompanyName);
            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$billtocompanyname$>", objInvoice.objBillTo.Address);
            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$billtocompanystate$>", objInvoice.objBillTo.Suburb + "  " + objInvoice.objBillTo.State + "  " + objInvoice.objBillTo.PostCode);
            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$billtocompanycountry$>", objInvoice.objBillTo.objCountry.ShortName);

            List<ReturnWeeklyAddressDetailsBO> lstWeeklyAddressDetils = new List<ReturnWeeklyAddressDetailsBO>();

            lstWeeklyAddressDetils = OrderDetailBO.GetOrderDetailsAddressDetails(objInvoice.objWeeklyProductionCapacity.WeekendDate, objInvoice.objShipTo.CompanyName, objInvoice.ShipmentMode);

            List<IGrouping<string, ReturnWeeklyAddressDetailsBO>> lstAddressOrderDetails = lstWeeklyAddressDetils.GroupBy(o => o.Distributor).ToList();

            invoicedetail = "<table cellpadding=\"1\" cellspacing=\"0\" style=\"font-size: 8px\" border=\"0.5\" width=\"100%\"><tr>" +
                            "<th border=\"0\" width=\"13%\"><b>Type</b></th>" +
                            "<th border=\"0\" width=\"5%\"><b>Qty</b></th>" +
                            "<th border=\"0\" width=\"8%\"><b>VL</b></th>" +
                            "<th border=\"0\" width=\"25%\"><b>Sizes</b></th>" +
                            "<th border=\"0\"  width=\"35%\"><b>Description</b></th>" +
                            "<th border=\"0\" width=\"6%\"><b>USD</b></th>" +
                            "<th border=\"0\" width=\"8%\"><b>AMOUNT</b></th></tr>";

            foreach (IGrouping<string, ReturnWeeklyAddressDetailsBO> distributor in lstAddressOrderDetails)
            {
                int totoalqty = 0;
                decimal totalamount = 0;
                invoicedetail += "<tr style=\"height:-2px;\"><td style=\"line-height:10px;\" colspan=\"7\"><h6 style=\"padding-left:5px\"><b>" + distributor.Key + "</b></h6></td></tr>";
                rowIndex++;

                List<ReturnWeeklyAddressDetailsBO> lstOrderDetailsGroup = distributor.ToList();//((IGrouping<string, ReturnWeeklyAddressDetailsBO>)distributor).ToList();

                foreach (ReturnWeeklyAddressDetailsBO item in lstOrderDetailsGroup)
                {
                    List<InvoiceOrderBO> lstInvoiceOrder = objInvoice.InvoiceOrdersWhereThisIsInvoice.Where(o => o.OrderDetail == item.OrderDetail).ToList();

                    if (lstInvoiceOrder.Count > 0)
                    {
                        string orderdetailqty = string.Empty;

                        OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                        objOrderDetailqty.OrderDetail = (int)item.OrderDetail;

                        foreach (OrderDetailQtyBO objOdq in objOrderDetailqty.SearchObjects())
                        {
                            if (objOdq.Qty > 0)
                            {
                                orderdetailqty += objOdq.objSize.SizeName + "/" + objOdq.Qty + ",";
                            }
                        }

                        decimal factoryprice = (lstInvoiceOrder.Count > 0 && lstInvoiceOrder[0].FactoryPrice != null) ? (decimal)lstInvoiceOrder[0].FactoryPrice : 0;

                        total = (decimal)(item.Quantity * factoryprice);
                        totalamount = totalamount + total;
                        masteramount = masteramount + total;
                        totoalqty = totoalqty + (int)item.Quantity;

                        invoicedetail += "<tr>" +
                                         "<td style=\"line-height:10px;\" width=\"13%\">" + item.OrderType + "<br>" + item.PurONo + "</td>" +
                                         "<td style=\"line-height:10px;\" width=\"5%\">" + item.Quantity + "</td>" +
                                         "<td style=\"line-height:10px;\" width=\"8%\">" + item.VisualLayout + " </td>" +
                                         "<td style=\"line-height:10px;\" width=\"25%\">" + item.Client + "<br>" + orderdetailqty.TrimEnd(',') + "</td>" +
                                         //"<td style=\"line-height:10px;\" width=\"35%\">" + item.Pattern + "<br>" + item.Fabric + " </td>" +
                                         "<td style=\"line-height:10px;\" width=\"35%\">" + item.Pattern + "<br>" + item.FabricCode + " " + item.FabricMaterial + "</td>" +
                                         "<td style=\"line-height:10px;\" width=\"6%\" >" + factoryprice.ToString("0.00") + "</td>" +
                                         "<td style=\"line-height:10px;\" width=\"8%\">" + total.ToString("0.00") + "</td></tr>";

                        rowIndex++;

                        if (rowIndex >= 30)
                        {
                            invoicedetail += "<tr style=\"height:5px;\"><td border=\"0\" style=\"line-height:50px;color: #FFFFFF;\" colspan=\"7\"><h6>INDICO</h6></td></tr>";
                            rowIndex = 0;
                        }
                    }
                }
                invoicedetail += "<tr style=\"height:2px;\"><td  style=\"line-height:-2px;color: #F0FFFF;\" colspan=\"9\"></td>";
                invoicedetail += "<tr>" +
                                 "<td  style=\"line-height:8px;\" border=\"0\" width=\"13%\">&nbsp;</td>" +
                                 "<td  style=\"line-height:8px;\" border=\"0\" width=\"5%\"><b>" + totoalqty + "</b></td>" +
                                 "<td  style=\"line-height:8px;\" border=\"0\" width=\"8%\">&nbsp;</td>" +
                                 "<td  style=\"line-height:8px;\" border=\"0\" width=\"25%\">&nbsp;</td>" +
                                 "<td style=\"line-height:8px;\" border=\"0\" width=\"35%\">&nbsp;</td>" +
                                 "<td style=\"line-height:8px;\" border=\"0\" width=\"6%\">&nbsp;</td>" +
                                 "<td  style=\"line-height:8px;\" border=\"0\" width=\"8%\">" + totalamount.ToString("0.00") + "</td>" +
                                 "</tr>";

                recordcount = recordcount + 1;
                masterqty = masterqty + totoalqty;

                if (lstAddressOrderDetails.Count != recordcount)
                {
                    invoicedetail += "<tr style=\"height:5px;\"><td border=\"0\" style=\"line-height:2px;color: #FFFFFF;\" colspan=\"7\"><h6>INDICO</h6></td>";
                    rowIndex++;

                    if (rowIndex >= 30)
                    {
                        invoicedetail += "<tr style=\"height:5px;\"><td border=\"0\" style=\"line-height:50px;color: #FFFFFF;\" colspan=\"7\"><h6>INDICO</h6></td></tr>";
                        rowIndex = 0;
                    }
                }
            }

            invoicedetail += "</table>";

            if (lstAddressOrderDetails.Count == recordcount)
            {
                finalrecord = "<table border=\"0.5\">" +
                              "<tr>" +
                              "<td width=\"13%\" style=\"line-height:0px;\">&nbsp;</td>" +
                              "<td width=\"5%\" style=\"line-height:0px;\">&nbsp;</td>" +
                              "<td width=\"8%\" style=\"line-height:0px;\">&nbsp;</td>" +
                              "<td width=\"25%\" style=\"line-height:0px;\">&nbsp;</td>" +
                              "<td width=\"35%\" style=\"line-height:0px;\">&nbsp;</td>" +
                              "<td width=\"6%\" style=\"line-height:0px;\">&nbsp;</td>" +
                              "<td width=\"8%\" style=\"line-height:0px;\">&nbsp;</td>" +
                              "</tr>";
                finalrecord += "<tr>" +
                               "<td width=\"13%\" style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" +
                               "<td width=\"5%\" style=\"line-height:10px;\" border=\"0\">" + masterqty + "</td>" +
                               "<td width=\"8%\" style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" +
                                "<td width=\"25%\" style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" +
                               "<td width=\"35%\" style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" +
                               "<td width=\"6%\" style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" +
                               "<td width=\"8%\" style=\"line-height:10px;\" border=\"0\">" + masteramount.ToString("0.00") + "</td>" +
                               "</tr>" +
                               "</table>";
            }

            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$pricedetails$>", invoicedetail);
            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$finalrecord$>", finalrecord);

            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$bankname$>", objInvoice.objBank.Name);

            string country = (objInvoice.objBank.Country != null || objInvoice.objBank.Country > 0) ? objInvoice.objBank.objCountry.ShortName : string.Empty;

            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$bankaddress$>", objInvoice.objBank.Address + "  " + objInvoice.objBank.City + "  " + objInvoice.objBank.State + "  " + objInvoice.objBank.Postcode + "  " + country);

            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$accountnumber$>", objInvoice.objBank.AccountNo);

            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$swiftcode$>", objInvoice.objBank.SwiftCode);

            //string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\invoice_" + objInvoice.ID.ToString() + ".html";
            //System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
            //file.WriteLine(jkinvoicedetailhtmlstring);
            //file.Close();

            return jkinvoicedetailhtmlstring;
        }

        public static string GenerateJKInvoiceDetail(int invoice)
        {
            string jkinvoicedetailpath = string.Empty;

            InvoiceBO objInvoice = new InvoiceBO();
            objInvoice.ID = invoice;
            objInvoice.GetObject();

            try
            {
                jkinvoicedetailpath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "JKInvoiceDetail_" + objInvoice.ID.ToString() + "_" + ".pdf";

                if (File.Exists(jkinvoicedetailpath))
                {
                    File.Delete(jkinvoicedetailpath);
                }

                Document document = new Document();
                PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(jkinvoicedetailpath, FileMode.Create));
                document.AddKeywords("paper airplanes");

                //float marginBottom = 12;
                //float lineHeight = 14;
                //float pageMargin = 20;
                float pageHeight = iTextSharp.text.PageSize.A4.Height;
                float pageWidth = iTextSharp.text.PageSize.A4.Width;

                document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                document.SetMargins(0, 0, 0, 0);

                // Open the document for writing content
                writer.PageEvent = new PDFFooter("COMMERCIAL INVOICE", false);

                document.Open();

                // Get the top layer and write some text
                //contentByte = writer.DirectContent;

                //contentByte.BeginText();
                //string content = string.Empty;
                //string pageNo = string.Empty;
                ////string page = "Page " + writer.getpa();


                ////Header
                //contentByte.SetFontAndSize(PDFFontBold, 10);
                //content = "COMMERCIAL INVOICE";
                //contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

                //// set Page Number
                //contentByte.SetFontAndSize(PDFFont, 8);
                //pageNo = "Page " + writer.PageNumber.ToString();
                //contentByte.ShowTextAligned(PdfContentByte.ALIGN_RIGHT, pageNo, (pageWidth - 30), (pageHeight - pageMargin - lineHeight), 0);

                //contentByte.EndText();

                //// Top Line
                //contentByte.SetLineWidth(0.5f);
                //contentByte.SetColorStroke(BaseColor.BLACK);
                //contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                //contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                //contentByte.Stroke();

                string htmlText = GenerateOdsPdf.CreateJKInvoiceDetailHTML(objInvoice);
                HTMLWorker htmlWorker = new HTMLWorker(document);
                htmlWorker.Parse(new StringReader(htmlText));

                document.Close();
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Generate Pdf JKInvoiceOrderDetail in GenerateOdsPdf Class", ex);
            }

            return jkinvoicedetailpath;
        }

        private static string CreateJKInvoiceSummaryHTML(InvoiceBO objInvoice)
        {
            string jkinvoicesummaryhtmlstring = JKInvoiceSummary;
            string invoicesummary = string.Empty;
            int masterqty = 0;
            decimal masteramount = 0;
            int rowIndex = 1;

            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$invoicenumber$>", objInvoice.InvoiceNo);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$shipmentdate$>", objInvoice.InvoiceDate.ToString("dd MMMM yyyy"));
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$mode$>", objInvoice.objShipmentMode.Name);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$awbno$>", objInvoice.AWBNo);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$companyname$>", objInvoice.objShipTo.CompanyName);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$companyaddress$>", objInvoice.objShipTo.Address + "  " + objInvoice.objShipTo.State);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$companypostalcodecountry$>", objInvoice.objShipTo.PostCode + "  " + objInvoice.objShipTo.objCountry.ShortName);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$companycontact$>", objInvoice.objShipTo.ContactName + "  " + objInvoice.objShipTo.ContactPhone);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$port$>", (objInvoice.objBillTo.Port != null && objInvoice.objBillTo.Port > 0) ? objInvoice.objBillTo.objPort.Name : string.Empty);

            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$billtocompanyname$>", objInvoice.objBillTo.CompanyName);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$billtocompanyname$>", objInvoice.objBillTo.Address);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$billtocompanystate$>", objInvoice.objBillTo.Suburb + "  " + objInvoice.objBillTo.State + "  " + objInvoice.objBillTo.PostCode);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$billtocompanycountry$>", objInvoice.objBillTo.objCountry.ShortName);

            List<ReturnWeeklyAddressDetailsBO> lstWeeklyAddressDetils = new List<ReturnWeeklyAddressDetailsBO>();

            lstWeeklyAddressDetils = OrderDetailBO.GetOrderDetailsAddressDetails(objInvoice.objWeeklyProductionCapacity.WeekendDate, objInvoice.objShipTo.CompanyName, objInvoice.ShipmentMode);

            List<IGrouping<string, ReturnWeeklyAddressDetailsBO>> lstAddressOrderDetails = lstWeeklyAddressDetils.GroupBy(o => (o.HSCode != null) ? o.HSCode : string.Empty).ToList();

            invoicesummary = "<table width=\"100%\" style=\"font-size:6px;\" cellpadding=\"1\" cellspacing=\"0\"><tr>" +
                             "<th width=\"35%\">Filaments</th>" +
                             "<th width=\"20%\">Item Name</th>" +
                             "<th width=\"10%\">Gender</th>" +
                             "<th width=\"15%\">Item Sub Cat</th>" +
                             "<th width=\"10%\">Qty</th>" +
                             "<th width=\"10%\">Amount</th></tr>" +
                             "<tr><td style=\"line-height:0px;\" colspan=\"6\" border=\"0.5\"></td></tr>";

            foreach (IGrouping<string, ReturnWeeklyAddressDetailsBO> hscode in lstAddressOrderDetails)
            {
                string hscodetext = (!string.IsNullOrEmpty(hscode.Key)) ? hscode.Key : string.Empty;
                int qty = 0;
                decimal amount = 0;
                decimal total = 0;
                rowIndex++;

                invoicesummary += "<tr><td colspan=\"6\"><b>" + hscodetext + "</b></td></tr>";

                List<ReturnWeeklyAddressDetailsBO> lstOrderDetailsGroup = hscode.ToList();

                foreach (ReturnWeeklyAddressDetailsBO item in lstOrderDetailsGroup)
                {
                    PatternBO objPattern = new PatternBO();
                    objPattern.ID = (int)item.PatternID;
                    objPattern.GetObject();

                    List<InvoiceOrderBO> lstInvoiceOrder = objInvoice.InvoiceOrdersWhereThisIsInvoice.Where(o => o.OrderDetail == item.OrderDetail).ToList();

                    if (lstInvoiceOrder.Count > 0)
                    {
                        qty = qty + (int)item.Quantity;
                        total = (decimal)(item.Quantity * lstInvoiceOrder[0].FactoryPrice);
                        amount = amount + total;

                        string subitem = (objPattern.SubItem != null && objPattern.SubItem > 0) ? objPattern.objSubItem.Name : string.Empty;

                        invoicesummary += "<tr><td style=\"line-height:12px;\" width=\"35%\">" + item.Pattern + "<br>" + item.FabricCode + " " + item.FabricMaterial + "</td>" +
                                          //"<tr><td style=\"line-height:12px;\" width=\"35%\">" + item.Fabric + "</td>" +                                            
                                          "<td style=\"line-height:12px;\" width=\"20%\">" + objPattern.objItem.Name + "</td>" +
                                          "<td style=\"line-height:12px;\" width=\"10%\">" + objPattern.objGender.Name + "</td>" +
                                          "<td style=\"line-height:12px;\" width=\"15%\">" + subitem + "</td>" +
                                          "<td style=\"line-height:12px;\" width=\"10%\">" + item.Quantity.Value + "</td>" +
                                          "<td style=\"line-height:12px;\" width=\"10%\">" + total.ToString("0.00") + "</td></tr>";

                        rowIndex++;

                        if (rowIndex >= 35)
                        {
                            invoicesummary += "<tr style=\"height:5px;\"><td border=\"0\" style=\"line-height:50px;color: #FFFFFF;\" colspan=\"6\"><h6>INDICO</h6></td></tr>";
                            rowIndex = 0;
                        }
                    }
                }

                masterqty = masterqty + qty;
                masteramount = masteramount + amount;
                invoicesummary += "<tr><td style=\"line-height:12px;\" width=\"35%\"></td>" +
                                  "<td width=\"20%\"></td>" +
                                  "<td style=\"line-height:12px;\" width=\"10%\"></td>" +
                                  "<td style=\"line-height:12px;\" width=\"15%\"></td>" +
                                  "<td style=\"line-height:12px;\" width=\"10%\"><b>" + qty.ToString() + "</b></td>" +
                                  "<td style=\"line-height:12px;\" width=\"10%\"><b>" + amount.ToString("0.00") + "</b></td></tr>";

                invoicesummary += "<tr><td width=\"35%\"></td>" +
                                  "<td width=\"20%\"></td>" +
                                  "<td width=\"10%\"></td>" +
                                  "<td width=\"15%\"></td>" +
                                  "<td width=\"10%\" style=\"line-height:0px;\" border=\"0.5\"></td>" +
                                  "<td width=\"10%\" style=\"line-height:0px;\" border=\"0.5\"></td></tr>";

                if (rowIndex >= 35)
                {
                    invoicesummary += "<tr style=\"height:5px;\"><td border=\"0\" style=\"line-height:50px;color: #FFFFFF;\" colspan=\"6\"><h6>INDICO</h6></td></tr>";
                    rowIndex = 0;
                }
            }

            invoicesummary += "<tr><td style=\"line-height:12px;\" width=\"35%\"></td>" +
                              "<td style=\"line-height:12px;\" width=\"20%\"></td>" +
                              "<td style=\"line-height:12px;\" width=\"10%\"></td>" +
                              "<td style=\"line-height:12px;\" width=\"15%\"></td>" +
                              "<td style=\"line-height:12px;\" width=\"10%\"><b>" + masterqty.ToString() + "</b></td>" +
                              "<td style=\"line-height:12px;\" width=\"10%\"><b>" + masteramount.ToString("0.00") + "</b></td></tr>";
            invoicesummary += "<tr><td width=\"35%\"></td>" +
                              "<td width=\"20%\"></td>" +
                              "<td width=\"10%\"></td>" +
                              "<td width=\"15%\"></td>" +
                              "<td width=\"10%\" style=\"line-height:0px;\" border=\"0.5\"></td><td width=\"10%\" style=\"line-height:0px;\" border=\"0.5\"></td></tr>";
            invoicesummary += "</table>";

            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$invoicesummary$>", invoicesummary);

            //string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\invoice_" + objInvoice.ID.ToString() + ".html";
            //System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
            //file.WriteLine(jkinvoicesummaryhtmlstring);
            //file.Close();

            return jkinvoicesummaryhtmlstring;
        }

        private static string CreateOrderReportHTML(OrderBO objOrder, decimal deliveryCharge, decimal artWorkCharge, decimal additionalCharge, decimal gstAmount)
        {
            string orderReporthtmlstring = OrderReport;
            string orderReportOrderDetailhtmlstring = string.Empty;
            string orderDetailhtmlString = string.Empty;
            string orderDetailQtyHeaderHtmlString = string.Empty;
            string orderDetailQtyValuesHtmlString = string.Empty;
            decimal vlPrice = 0;
            int qty = 0;
            decimal qtyPrice = 0;
            decimal totalValue = 0;
            decimal orderTotal = 0;

            try
            {
                orderReporthtmlstring = orderReporthtmlstring.Replace("<$OrderDate$>", objOrder.Date.ToString("dd MMMM yyyy"));
                orderReporthtmlstring = orderReporthtmlstring.Replace("<$PONumber$>", objOrder.PurchaseOrderNo);
                //orderReporthtmlstring = orderReporthtmlstring.Replace("<$OrderType$>", objOrder.OldPONo);
                //orderReporthtmlstring = orderReporthtmlstring.Replace("<$MYOBCardFile$>", objOrder.OldPONo);

                if ((objOrder.DespatchToAddress ?? 0) > 0)
                {
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$CompanyName$>", objOrder.objDespatchToAddress.CompanyName);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$Address$>", objOrder.objDespatchToAddress.Address);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$Suburb$>", objOrder.objDespatchToAddress.Suburb);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$State$>", objOrder.objDespatchToAddress.State);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$PostCode$>", objOrder.objDespatchToAddress.PostCode);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$ContactName$>", objOrder.objDespatchToAddress.ContactName);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$ContactPhone$>", objOrder.objDespatchToAddress.ContactPhone);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$ContactEmail$>", string.Empty);
                }
                else
                {
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$CompanyName$>", objOrder.objDistributor.NickName);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$Address$>", objOrder.objDistributor.Address1 + ", " + objOrder.objDistributor.Address2);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$Suburb$>", objOrder.objDistributor.City);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$State$>", objOrder.objDistributor.State);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$PostCode$>", objOrder.objDistributor.Postcode);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$ContactName$>", objOrder.objDistributor.objOwner.GivenName + " " + objOrder.objDistributor.objOwner.FamilyName);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$ContactPhone$>", objOrder.objDistributor.Phone1);
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$ContactEmail$>", objOrder.objDistributor.objOwner.EmailAddress);
                }

                orderReporthtmlstring = orderReporthtmlstring.Replace("<$DateRequired$>", objOrder.EstimatedCompletionDate.ToString("dd MMMM yyyy"));

                if (objOrder.ShipmentDate.HasValue)
                    orderReporthtmlstring = orderReporthtmlstring.Replace("<$ShipmentDate$>", objOrder.ShipmentDate.Value.ToString("dd MMMM yyyy"));
                orderReporthtmlstring = orderReporthtmlstring.Replace("<$DateIsNegotiable$>", objOrder.IsDateNegotiable ? "Yes" : "No");
                orderReporthtmlstring = orderReporthtmlstring.Replace("<$DeliveryOption$>", objOrder.OldPONo);
                orderReporthtmlstring = orderReporthtmlstring.Replace("<$SpecialInstructions$>", objOrder.Notes);

                OrderDetailBO objODetail = new OrderDetailBO();
                objODetail.Order = objOrder.ID;
                List<OrderDetailBO> lstOrderDetail = objODetail.SearchObjects();

                foreach (OrderDetailBO objOD in lstOrderDetail)
                {
                    OrderDetailQtyBO objODQty = new OrderDetailQtyBO();
                    objODQty.OrderDetail = objOD.ID;
                    List<OrderDetailQtyBO> lstOrderDetailQty = objODQty.SearchObjects();

                    orderReportOrderDetailhtmlstring = OrderReportOrderDetail;
                    qty = lstOrderDetailQty.Sum(m => m.Qty);
                    vlPrice = objOD.EditedPrice ?? 0; // IndicoPage.CalculatePricePerVL(objOD.VisualLayout, qty);
                    qtyPrice = vlPrice * qty;

                    orderReportOrderDetailhtmlstring = orderReportOrderDetailhtmlstring.Replace("<$VLNumber$>", objOD.objVisualLayout.NamePrefix);
                    orderReportOrderDetailhtmlstring = orderReportOrderDetailhtmlstring.Replace("<$Pocket$>", ((objOD.objVisualLayout.PocketType ?? 0) > 0) ? objOD.objVisualLayout.objPocketType.Name : string.Empty);
                    orderReportOrderDetailhtmlstring = orderReportOrderDetailhtmlstring.Replace("<$Garment$>", objOD.objPattern.Number + "-" + objOD.objPattern.Description);
                    orderReportOrderDetailhtmlstring = orderReportOrderDetailhtmlstring.Replace("<$Fabric$>", objOD.objFabricCode.NickName);

                    foreach (OrderDetailQtyBO objODQtyBO in lstOrderDetailQty)
                    {
                        orderDetailQtyHeaderHtmlString += "<td>" + objODQtyBO.objSize.SizeName + "</td>";
                        orderDetailQtyValuesHtmlString += "<td>" + objODQtyBO.Qty + "</td>";
                    }

                    orderDetailQtyHeaderHtmlString += "<td> " + "Total" + "</td>";
                    orderDetailQtyHeaderHtmlString += "<td> " + "Price" + "</td>";
                    orderDetailQtyHeaderHtmlString += "<td> " + "Amount" + "</td>";

                    orderDetailQtyValuesHtmlString += "<td> " + lstOrderDetailQty.Sum(mbox => mbox.Qty) + "</td>";
                    orderDetailQtyValuesHtmlString += "<td> $" + vlPrice.ToString() + "</td>";
                    orderDetailQtyValuesHtmlString += "<td> $" + qtyPrice.ToString() + "</td>";

                    orderReportOrderDetailhtmlstring = orderReportOrderDetailhtmlstring.Replace("<$OrderDetailQTYHeader$>", orderDetailQtyHeaderHtmlString);
                    orderReportOrderDetailhtmlstring = orderReportOrderDetailhtmlstring.Replace("<$OrderDetailQTYValues$>", orderDetailQtyValuesHtmlString);
                    orderDetailhtmlString += orderReportOrderDetailhtmlstring;

                    orderDetailQtyHeaderHtmlString = orderDetailQtyValuesHtmlString = string.Empty;

                    totalValue += qtyPrice;
                }

                orderTotal = totalValue + deliveryCharge + artWorkCharge + additionalCharge;

                orderReporthtmlstring = orderReporthtmlstring.Replace("<$OrderDetail$>", orderDetailhtmlString);
                orderReporthtmlstring = orderReporthtmlstring.Replace("<$OrderValue$>", "$" + totalValue.ToString("0.00"));
                orderReporthtmlstring = orderReporthtmlstring.Replace("<$DeliveryCharge$>", "$" + deliveryCharge.ToString("0.00"));
                orderReporthtmlstring = orderReporthtmlstring.Replace("<$ArtworkCharge$>", "$" + artWorkCharge.ToString("0.00"));
                orderReporthtmlstring = orderReporthtmlstring.Replace("<$AdditionalCharge$>", "$" + additionalCharge.ToString("0.00"));
                orderReporthtmlstring = orderReporthtmlstring.Replace("<$Total$>", "$" + orderTotal.ToString("0.00"));
                orderReporthtmlstring = orderReporthtmlstring.Replace("<$GST$>", gstAmount.ToString("0.00") + "%");
                orderReporthtmlstring = orderReporthtmlstring.Replace("<$TotalWithGST$>", "$" + (orderTotal + (orderTotal * gstAmount / 100)).ToString("0.00"));
            }
            catch (Exception ex)
            {
                throw;
            }

            return orderReporthtmlstring;
        }

        public static string GenerateJKInvoiceSummary(int invoice)
        {
            InvoiceBO objInvoice = new InvoiceBO();
            objInvoice.ID = invoice;
            objInvoice.GetObject();

            string jkinvoicesummarypath = string.Empty;

            try
            {
                jkinvoicesummarypath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "JKInvoiceSummary_" + objInvoice.ID.ToString() + "_" + ".pdf";

                if (File.Exists(jkinvoicesummarypath))
                {
                    File.Delete(jkinvoicesummarypath);
                }

                Document document = new Document();
                PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(jkinvoicesummarypath, FileMode.Create));
                document.AddKeywords("paper airplanes");



                //float marginBottom = 12;
                //float lineHeight = 14;
                //float pageMargin = 20;
                float pageHeight = iTextSharp.text.PageSize.A4.Height;
                float pageWidth = iTextSharp.text.PageSize.A4.Width;

                document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                document.SetMargins(0, 0, 0, 0);

                writer.PageEvent = new PDFFooter("INVOICE SUMMARY", false);

                document.Open();

                //// Open the document for writing content
                //document.Open();
                //// Get the top layer and write some text
                //contentByte = writer.DirectContent;

                //contentByte.BeginText();
                //string content = string.Empty;
                //string pageNo = string.Empty;
                ////string page = "Page " + writer.getpa();


                ////Header
                //contentByte.SetFontAndSize(PDFFontBold, 10);
                //content = "INVOICE SUMMARY";
                //contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

                //// set Page Number
                //contentByte.SetFontAndSize(PDFFont, 8);
                //pageNo = "Page " + writer.PageNumber.ToString();
                //contentByte.ShowTextAligned(PdfContentByte.ALIGN_RIGHT, pageNo, (pageWidth - 30), (pageHeight - pageMargin - lineHeight), 0);

                //contentByte.EndText();

                //// Top Line
                //contentByte.SetLineWidth(0.5f);
                //contentByte.SetColorStroke(BaseColor.BLACK);
                //contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                //contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                //contentByte.Stroke();

                string htmlText = GenerateOdsPdf.CreateJKInvoiceSummaryHTML(objInvoice);
                HTMLWorker htmlWorker = new HTMLWorker(document);
                htmlWorker.Parse(new StringReader(htmlText));

                document.Close();
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Generate Pdf jkinvoicesummarypath in GenerateOdsPdf Class", ex);
            }

            return jkinvoicesummarypath;
        }

        public static string GenerateOrderReport(int order, decimal deliveryCharge, decimal artWorkCharge, decimal additionalCharge, decimal gstAmount)
        {
            OrderBO objOrder = new OrderBO();
            objOrder.ID = order;
            objOrder.GetObject();

            string tempLocation = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\";
            string orderReportpath = tempLocation + "OrderReport_" + objOrder.ID.ToString() + ".pdf"; ;
            string orderReportTempPath = tempLocation + "OrderReport_" + objOrder.ID.ToString() + "_Temp.pdf"; ;
            string tAndC = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\IndicoTermsAndConditions.pdf";
            Document document = new Document();

            try
            {
                if (File.Exists(orderReportpath))
                {
                    File.Delete(orderReportpath);
                }

                if (File.Exists(orderReportTempPath))
                {
                    File.Delete(orderReportTempPath);
                }

                PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(orderReportTempPath, FileMode.Create));
                float pageHeight = iTextSharp.text.PageSize.A4.Height;
                float pageWidth = iTextSharp.text.PageSize.A4.Width;

                document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                document.SetMargins(10, 10, 10, 10);
                // writer.PageEvent = new PDFFooter("ORDEROVERVIEW FORM", false);

                document.Open();

                string htmlText = GenerateOdsPdf.CreateOrderReportHTML(objOrder, deliveryCharge, artWorkCharge, additionalCharge, gstAmount);
                HTMLWorker htmlWorker = new HTMLWorker(document);
                htmlWorker.Parse(new StringReader(htmlText));
                document.Close();

                CombineMultiplePDFs(new string[] { orderReportTempPath, tAndC }, orderReportpath);
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Generate Pdf orderReportpath in GenerateOdsPdf Class", ex);
            }
            finally
            {
                document.Close();
                if (File.Exists(orderReportTempPath))
                {
                    File.Delete(orderReportTempPath);
                }
            }

            return orderReportpath;
        }

        private static void AppendToDocument(string sourcePdfPath, string outputPdfPath, List<int> neededPages)
        {
            var sourceDocumentStream = new FileStream(sourcePdfPath, FileMode.Open); //@"C:\Projects\Indico\IndicoData\Temp\test.pdf"
            var destinationDocumentStream = new FileStream(outputPdfPath, FileMode.Append);
            var pdfConcat = new PdfConcatenate(destinationDocumentStream);

            var pdfReader = new PdfReader(sourceDocumentStream);
            pdfReader.SelectPages(neededPages);
            pdfConcat.AddPages(pdfReader);

            pdfReader.Close();
            pdfConcat.Close();
        }

        public static void CombineMultiplePDFs(string[] fileNames, string outFile)
        {
            // step 1: creation of a document-object
            Document document = new Document();

            // step 2: we create a writer that listens to the document
            PdfCopy writer = new PdfCopy(document, new FileStream(outFile, FileMode.Create));
            if (writer == null)
            {
                return;
            }

            // step 3: we open the document
            document.Open();

            foreach (string fileName in fileNames)
            {
                // we create a reader for a certain document
                PdfReader reader = new PdfReader(fileName);
                reader.ConsolidateNamedDestinations();

                // step 4: we add content
                for (int i = 1; i <= reader.NumberOfPages; i++)
                {
                    PdfImportedPage page = writer.GetImportedPage(reader, i);
                    writer.AddPage(page);
                }

                PRAcroForm form = reader.AcroForm;
                if (form != null)
                {
                    writer.CopyAcroForm(reader);
                }

                reader.Close();
            }

            // step 5: we close the document and writer
            writer.Close();
            document.Close();
        }

        private static void CombineAndSavePdf(string savePath, List<string> lstPdfFiles)
        {
            using (Stream outputPdfStream = new FileStream(savePath, FileMode.Create, FileAccess.Write, FileShare.None))
            {

                Document document = new Document();
                PdfSmartCopy copy = new PdfSmartCopy(document, outputPdfStream);
                document.Open();
                PdfReader reader;
                int totalPageCnt;
                PdfStamper stamper;
                string[] fieldNames;
                foreach (string file in lstPdfFiles)
                {
                    reader = new PdfReader(file);
                    totalPageCnt = reader.NumberOfPages;
                    for (int pageCnt = 0; pageCnt < totalPageCnt;)
                    {
                        //have to create a new reader for each page or PdfStamper will throw error
                        reader = new PdfReader(file);
                        stamper = new PdfStamper(reader, outputPdfStream);
                        fieldNames = new string[stamper.AcroFields.Fields.Keys.Count];
                        stamper.AcroFields.Fields.Keys.CopyTo(fieldNames, 0);
                        foreach (string name in fieldNames)
                        {
                            stamper.AcroFields.RenameField(name, name + "_file" + pageCnt.ToString());
                        }
                        copy.AddPage(copy.GetImportedPage(reader, ++pageCnt));
                    }
                    copy.FreeReader(reader);
                }
                document.Close();
            }
        }

        public static string CombinedInvoice(int invoice)
        {
            InvoiceBO objInvoice = new InvoiceBO();
            objInvoice.ID = invoice;
            objInvoice.GetObject();

            string jkinvoicesummarypath = string.Empty;

            jkinvoicesummarypath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "JKCombineInvoice_" + objInvoice.ID.ToString() + "_" + ".pdf";

            try
            {

                if (File.Exists(jkinvoicesummarypath))
                {
                    File.Delete(jkinvoicesummarypath);
                }
                List<string> lstfilespath = new List<string>();

                // generated indico detail pdf path
                string invoicedetailpath = GenerateJKInvoiceDetail(invoice);

                lstfilespath.Add(invoicedetailpath);

                // generated indico summary pdf path
                string invoicesummarypath = GenerateJKInvoiceSummary(invoice);

                lstfilespath.Add(invoicesummarypath);

                CombineAndSavePdf(jkinvoicesummarypath, lstfilespath);
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while creating combined invoice from GenerateOdsPdf", ex);
            }
            return jkinvoicesummarypath;
        }

        public static string CreateIndimanInvoiceHTML(InvoiceBO objInvoice)
        {
            string indimaninvoicehtmlstring = IndimanInvoice;
            string invoicedetail = string.Empty;
            int recordcount = 0;
            string finalrecord = string.Empty;
            int masterqty = 0;
            decimal masteramount = 0;
            decimal total = 0;

            string invNo = (objInvoice.IndimanInvoiceNo != null) ? objInvoice.IndimanInvoiceNo : "0";
            string date = (objInvoice.IndimanInvoiceDate != null) ? Convert.ToDateTime(objInvoice.IndimanInvoiceDate.Value).ToString("dd MMMM yyyy") : DateTime.Now.ToString("dd MMMM yyyy");

            indimaninvoicehtmlstring = indimaninvoicehtmlstring.Replace("<$invoiceno$>", invNo);
            indimaninvoicehtmlstring = indimaninvoicehtmlstring.Replace("<$invoicedate$>", date);
            indimaninvoicehtmlstring = indimaninvoicehtmlstring.Replace("<$shipcompanyname$>", objInvoice.objShipTo.CompanyName);
            indimaninvoicehtmlstring = indimaninvoicehtmlstring.Replace("<$shipcompanyaddress$>", objInvoice.objShipTo.Address + "  " + objInvoice.objShipTo.State);
            indimaninvoicehtmlstring = indimaninvoicehtmlstring.Replace("<$shipcompanypostalcode$>", objInvoice.objShipTo.PostCode + "  " + objInvoice.objShipTo.objCountry.ShortName);
            indimaninvoicehtmlstring = indimaninvoicehtmlstring.Replace("<$shipcompanycontact$>", objInvoice.objShipTo.ContactName + "  " + objInvoice.objShipTo.ContactPhone);
            indimaninvoicehtmlstring = indimaninvoicehtmlstring.Replace("<$shipmentmode$>", objInvoice.objShipmentMode.Name);
            indimaninvoicehtmlstring = indimaninvoicehtmlstring.Replace("<$awbno$>", objInvoice.AWBNo);

            List<ReturnWeeklyAddressDetailsBO> lstWeeklyAddressDetils = new List<ReturnWeeklyAddressDetailsBO>();

            lstWeeklyAddressDetils = OrderDetailBO.GetOrderDetailsAddressDetails(objInvoice.objWeeklyProductionCapacity.WeekendDate, objInvoice.objShipTo.CompanyName, objInvoice.ShipmentMode);

            List<IGrouping<string, ReturnWeeklyAddressDetailsBO>> lstAddressOrderDetails = lstWeeklyAddressDetils.GroupBy(o => o.Distributor).ToList();

            invoicedetail = "<table cellpadding=\"1\" cellspacing=\"0\" style=\"font-size: 6px\" border=\"0.5\" width=\"100%\"><tr>" +
                            "<th style=\"line-height:7px;\" width=\"5%\"><b>Order</b></th>" +
                            "<th style=\"line-height:7px;\" width=\"5%\"><b>Total</b></th>" +
                            "<th style=\"line-height:7px;\" width=\"23%\"><b>Size</b></th>" +
                            "<th style=\"line-height:7px;\" width=\"27%\"><b>Pattern</b></th>" +
                            "<th style=\"line-height:7px;\" width=\"18%\"><b>Fabric</b></th>" +
                            "<th style=\"line-height:7px;\" width=\"5%\"><b>VL</b></th>" +
                            "<th style=\"line-height:7px;\" width=\"6%\"><b>Type</b></th>" +
                            "<th style=\"line-height:7px;\" width=\"5%\"><b>Price</b></th>" +
                            "<th style=\"line-height:7px;\" width=\"6%\"><b>AMOUNT</b></th></tr>";
            int rowIndex = 1;
            foreach (IGrouping<string, ReturnWeeklyAddressDetailsBO> distributor in lstAddressOrderDetails)
            {
                int totoalqty = 0;
                invoicedetail += "<tr style=\"height:-2px;\"><td style=\"line-height:10px;\" colspan=\"9\"><h6 style=\"padding-left:5px\"><b>" + distributor.Key + "</b></h6></td></tr>";
                rowIndex++;

                List<ReturnWeeklyAddressDetailsBO> lstOrderDetailsGroup = distributor.ToList();//((IGrouping<string, ReturnWeeklyAddressDetailsBO>)distributor).ToList();

                foreach (ReturnWeeklyAddressDetailsBO item in lstOrderDetailsGroup)
                {
                    List<InvoiceOrderBO> lstInvoiceOrder = objInvoice.InvoiceOrdersWhereThisIsInvoice.Where(o => o.OrderDetail == item.OrderDetail).ToList();

                    if (lstInvoiceOrder.Count > 0)
                    {
                        string orderdetailqty = string.Empty;

                        OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                        objOrderDetailqty.OrderDetail = (int)item.OrderDetail;

                        foreach (OrderDetailQtyBO objOdq in objOrderDetailqty.SearchObjects())
                        {
                            if (objOdq.Qty > 0)
                            {
                                orderdetailqty += objOdq.objSize.SizeName + "/" + objOdq.Qty + ",";
                            }

                        }

                        decimal indimanprice = (lstInvoiceOrder[0].IndimanPrice != null && lstInvoiceOrder[0].IndimanPrice > 0) ? (decimal)lstInvoiceOrder[0].IndimanPrice : 0;

                        total = (decimal)(item.Quantity * indimanprice);
                        masteramount = masteramount + total;
                        totoalqty = totoalqty + (int)item.Quantity;

                        invoicedetail += "<tr><td style=\"line-height:10px;\" border=\"0\" width=\"5%\">" + item.Order + "</td>" +
                                         "<td style=\"line-height:10px;\" border=\"0\" width=\"5%\">" + item.Quantity + "</td>" +
                                         "<td style=\"line-height:10px;\" border=\"0\"  width=\"23%\">" + orderdetailqty.TrimEnd(',') + "</td>" +
                                         "<td style=\"line-height:10px;\" border=\"0\" width=\"27%\">" + item.Pattern + " </td>" +
                                         //"<td style=\"line-height:10px;\" border=\"0\"  width=\"18%\">" + item.Fabric + " </td>" +
                                         "<td style=\"line-height:10px;\" border=\"0\"  width=\"18%\">" + item.FabricCode + " " + item.FabricName + " </td>" +
                                         "<td style=\"line-height:10px;\" border=\"0\"  width=\"5%\">" + item.VisualLayout + " </td>" +
                                         "<td style=\"line-height:10px;\" border=\"0\" width=\"6%\">" + item.OrderType + "</td>" +
                                         "<td style=\"line-height:10px;\" border=\"0\" width=\"5%\">" + lstInvoiceOrder[0].IndimanPrice + "</td>" +
                                         "<td style=\"line-height:10px;\" border=\"0\" width=\"6%\">" + total.ToString("0.00") + "</td></tr>";

                        rowIndex++;

                        if (rowIndex >= 30)
                        {
                            invoicedetail += "<tr style=\"height:5px;\"><td border=\"0\" style=\"line-height:50px;color: #FFFFFF;\" colspan=\"9\"><h6>INDICO</h6></td></tr>";
                            rowIndex = 0;
                        }
                    }
                }

                recordcount = recordcount + 1;
                masterqty = masterqty + totoalqty;

                if (lstAddressOrderDetails.Count != recordcount)
                {
                    invoicedetail += "<tr style=\"height:5px;\"><td border=\"0\" style=\"line-height:2px;color: #FFFFFF;\" colspan=\"9\"><h6>INDICO</h6></td></tr>";
                    rowIndex++;
                }


                if (rowIndex >= 30)
                {
                    invoicedetail += "<tr style=\"height:5px;\"><td border=\"0\" style=\"line-height:50px;color: #FFFFFF;\" colspan=\"9\"><h6>INDICO</h6></td></tr>";
                    rowIndex = 0;
                }
            }

            invoicedetail += "</table>";

            if (lstAddressOrderDetails.Count == recordcount)
            {

                finalrecord += "<table border=\"0.5\"><tr><td style=\"line-height:10px;\" border=\"0\">Total:</td><td style=\"line-height:10px;\" border=\"0\">" + masterqty + "</td><td style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" +
                               "<td style=\"line-height:10px;\" border=\"0\">&nbsp;</td><td style=\"line-height:10px;\" border=\"0\">&nbsp;</td><td style=\"line-height:10px;\" border=\"0\">&nbsp;</td><td style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" +
                               "<td style=\"line-height:10px;\" border=\"0\"></td></tr></table>";
            }

            indimaninvoicehtmlstring = indimaninvoicehtmlstring.Replace("<$pricedetails$>", invoicedetail);
            indimaninvoicehtmlstring = indimaninvoicehtmlstring.Replace("<$finalrecord$>", finalrecord);

            decimal gst = ((masteramount * 10) / 100);
            decimal totalgst = gst + masteramount;

            indimaninvoicehtmlstring = indimaninvoicehtmlstring.Replace("<$subtotal$>", masteramount.ToString("0.00"));
            indimaninvoicehtmlstring = indimaninvoicehtmlstring.Replace("<$gst$>", gst.ToString("0.00"));
            indimaninvoicehtmlstring = indimaninvoicehtmlstring.Replace("<$totgst$>", totalgst.ToString("0.00"));

            /*string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\invoice_" + objInvoice.ID.ToString() + ".html";
            System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
            file.WriteLine(indimaninvoicehtmlstring);
            file.Close();*/

            return indimaninvoicehtmlstring;
        }

        public static string GenerateIndimanInvoice(int invoice)
        {
            InvoiceBO objInvoice = new InvoiceBO();
            objInvoice.ID = invoice;
            objInvoice.GetObject();

            string temppath = string.Empty;

            Document document = new Document();

            try
            {
                temppath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "Indiman_Invoice_" + objInvoice.ID.ToString() + "_" + ".pdf";

                if (File.Exists(temppath))
                {
                    File.Delete(temppath);
                }

                PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(temppath, FileMode.Create));
                document.AddKeywords("paper airplanes");

                //float marginBottom = 12;
                //float lineHeight = 14;
                //float pageMargin = 20;
                float pageHeight = iTextSharp.text.PageSize.A4.Height;
                float pageWidth = iTextSharp.text.PageSize.A4.Width;

                document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                document.SetMargins(0, 0, 0, 0);

                writer.PageEvent = new PDFFooter("Indico Manufacturing Pty Ltd", true);

                // Open the document for writing content
                document.Open();
                // Get the top layer and write some text
                //contentByte = writer.DirectContent;

                //contentByte.BeginText();
                //string content = string.Empty;
                //string content_1 = string.Empty;
                //////string page = "Page " + writer.GetPageReference();

                //////Header
                //contentByte.SetFontAndSize(PDFFont, 12);
                //content = "Indico Manufacturing Pty Ltd";
                //contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

                //contentByte.SetFontAndSize(PDFFont, 6);
                //content_1 = "Suit 43,125 Highbury Road, Burwood, VIC 3125";
                //contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content_1, pageMargin, (pageHeight - pageMargin - 22), 0);

                //contentByte.EndText();
                //// Top Line
                //contentByte.SetLineWidth(0.5f);
                //contentByte.SetColorStroke(BaseColor.BLACK);
                //contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                //contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                //contentByte.Stroke();

                string htmlText = GenerateOdsPdf.CreateIndimanInvoiceHTML(objInvoice);
                HTMLWorker htmlWorker = new HTMLWorker(document);
                htmlWorker.Parse(new StringReader(htmlText));

                writer.Close();
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Generate Pdf indimaninvoicepath in GenerateOdsPdf Class", ex);
            }
            finally
            {
                document.Close();
            }

            return temppath;
        }

        private static string CreateBatchLabelHTML(ReturnWeeklyAddressDetailsBO objReturnWeeklyAddressDetails, DateTime weekenddate)
        {
            string batchlabel = BatchLabel;

            OrderBO objOrder = new OrderBO();
            objOrder.ID = (int)objReturnWeeklyAddressDetails.Order;
            objOrder.GetObject();

            string order = (!string.IsNullOrEmpty(objOrder.OldPONo)) ? objOrder.OldPONo.ToString() : "PO-" + objReturnWeeklyAddressDetails.Order.ToString();

            batchlabel = batchlabel.Replace("<$Order$>", order);
            batchlabel = batchlabel.Replace("<$VisualLayout$>", objReturnWeeklyAddressDetails.VisualLayout);
            batchlabel = batchlabel.Replace("<$Pattern$>", objReturnWeeklyAddressDetails.Pattern.Split('-')[0].ToString());
            batchlabel = batchlabel.Replace("<$qty$>", objReturnWeeklyAddressDetails.Quantity.ToString());
            batchlabel = batchlabel.Replace("<$weekenddate$>", weekenddate.ToString("d"));

            return batchlabel;
        }

        private static string CreateBatchLabelHTML(OrderDetailBO objOrderDetail, DateTime weekenddate)
        {
            string batchlabel = BatchLabel;
            int qty = objOrderDetail.OrderDetailQtysWhereThisIsOrderDetail.Sum(o => o.Qty);

            string order = (!string.IsNullOrEmpty(objOrderDetail.objOrder.OldPONo)) ? objOrderDetail.objOrder.OldPONo.ToString() : "PO-" + objOrderDetail.Order.ToString();

            batchlabel = batchlabel.Replace("<$Order$>", order);
            batchlabel = batchlabel.Replace("<$VisualLayout$>", objOrderDetail.objVisualLayout.NamePrefix.ToString());
            batchlabel = batchlabel.Replace("<$Pattern$>", objOrderDetail.objPattern.Number);
            batchlabel = batchlabel.Replace("<$qty$>", qty.ToString());
            batchlabel = batchlabel.Replace("<$weekenddate$>", weekenddate.ToString("d"));

            return batchlabel;
        }

        public static string CreateBathLabel(DateTime weekenddate)
        {
            string directorypath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + Guid.NewGuid();
            List<string> lstfilepaths = new List<string>();
            string tempfilepath = string.Empty;

            string batchlabelfile = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "Batch_Label_" + weekenddate.ToString("dd MMMM yyyy") + "_" + ".pdf";

            try
            {
                if (Directory.Exists(directorypath))
                {
                    Directory.Delete(directorypath, true);
                }
                else
                {
                    Directory.CreateDirectory(directorypath);
                }

                if (File.Exists(batchlabelfile))
                {
                    File.Delete(batchlabelfile);
                }

                List<ReturnWeeklyAddressDetailsBO> lstWeeklyAddressDetils = new List<ReturnWeeklyAddressDetailsBO>();

                lstWeeklyAddressDetils = OrderDetailBO.GetOrderDetailsAddressDetails(weekenddate, string.Empty, 0);

                foreach (ReturnWeeklyAddressDetailsBO objwad in lstWeeklyAddressDetils)
                {
                    for (int i = 0; i < objwad.Quantity; i++)
                    {
                        tempfilepath = directorypath + "\\" + Guid.NewGuid() + ".pdf";

                        Document document = new Document();
                        PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(tempfilepath, FileMode.Create));
                        document.AddKeywords("paper airplanes");

                        //float marginBottom = 12;
                        //float lineHeight = 14;
                        //float pageMargin = 20;
                        float pageHeight = (float)108.0;
                        float pageWidth = (float)50.0;

                        document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                        document.SetMargins(0, 0, 0, 0);

                        // Open the document for writing content
                        document.Open();

                        string htmlText = GenerateOdsPdf.CreateBatchLabelHTML(objwad, weekenddate);
                        HTMLWorker htmlWorker = new HTMLWorker(document);
                        htmlWorker.Parse(new StringReader(htmlText));

                        document.Close();

                        lstfilepaths.Add(tempfilepath);
                    }
                }

                if (lstfilepaths.Count > 0)
                {
                    CombineAndSavePdf(batchlabelfile, lstfilepaths);
                }

                if (Directory.Exists(directorypath))
                {
                    Thread t = new Thread(new ThreadStart(() => DeleteDirectory(directorypath)));
                    t.Start();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while creating Batch Label in GenerateOdsPdf CreateBathLabelmethod", ex);
            }

            return batchlabelfile;
        }

        public static string CreateBathLabel(int order)
        {
            string directorypath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + Guid.NewGuid();
            List<string> lstfilepaths = new List<string>();
            string tempfilepath = string.Empty;

            string batchlabelfile = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "Batch_Label_" + DateTime.Now.ToString("dd MMMM yyyy") + "_" + ".pdf";

            try
            {
                if (Directory.Exists(directorypath))
                {
                    Directory.Delete(directorypath, true);
                }
                else
                {
                    Directory.CreateDirectory(directorypath);
                }

                if (File.Exists(batchlabelfile))
                {
                    File.Delete(batchlabelfile);
                }

                OrderDetailBO objOrderDetail = new OrderDetailBO();
                objOrderDetail.Order = order;

                List<OrderDetailBO> lstOrderDetails = objOrderDetail.SearchObjects();

                foreach (OrderDetailBO objOD in lstOrderDetails)
                {
                    OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                    objOrderDetailQty.OrderDetail = objOD.ID;

                    List<OrderDetailQtyBO> lstOrderDetailsqty = objOrderDetailQty.SearchObjects();

                    List<WeeklyProductionCapacityBO> lstWeeklyProductionCapacity = (new WeeklyProductionCapacityBO()).SearchObjects().Where(o => o.WeekendDate > objOD.SheduledDate && o.WeekendDate <= objOD.SheduledDate.AddDays(7)).ToList();



                    tempfilepath = directorypath + "\\" + Guid.NewGuid() + ".pdf";

                    Document document = new Document();
                    PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(tempfilepath, FileMode.Create));
                    document.AddKeywords("paper airplanes");

                    //float marginBottom = 12;
                    //float lineHeight = 14;
                    //float pageMargin = 20;
                    float pageHeight = (float)108.0;
                    float pageWidth = (float)50.0;

                    document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                    document.SetMargins(0, 0, 0, 0);

                    // Open the document for writing content
                    document.Open();

                    string htmlText = GenerateOdsPdf.CreateBatchLabelHTML(objOD, Convert.ToDateTime(lstWeeklyProductionCapacity[0].WeekendDate));
                    HTMLWorker htmlWorker = new HTMLWorker(document);
                    htmlWorker.Parse(new StringReader(htmlText));

                    document.Close();

                    lstfilepaths.Add(tempfilepath);

                }

                if (lstfilepaths.Count > 0)
                {
                    CombineAndSavePdf(batchlabelfile, lstfilepaths);
                }

                if (Directory.Exists(directorypath))
                {
                    Thread t = new Thread(new ThreadStart(() => DeleteDirectory(directorypath)));
                    t.Start();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while creating Batch Label in GenerateOdsPdf CreateBathLabelmethod", ex);
            }

            return batchlabelfile;
        }

        public static string CreateIndimanCostSheet(CostSheetBO objCostSheet)
        {
            string IndimanCostSheethtmlstring = IndimanCostSheet;
            string pricedetails = string.Empty;
            decimal totalfabric = 0;
            decimal totalaccessory = 0;
            string factoryremarks = string.Empty;
            string costsheetimages = string.Empty;
            string filepath = string.Empty;
            List<float> lstCostSheetImages = new List<float>();
            string indimanremarks = string.Empty;

            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$costsheetid$>", objCostSheet.ID.ToString());
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$patternnumber$>", objCostSheet.objPattern.Number + " - " + objCostSheet.objPattern.Remarks);
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$mainfabric$>", objCostSheet.objFabric.Name);
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$modifieddate$>", (objCostSheet.IndimanModifiedDate != null) ? Convert.ToDateTime(objCostSheet.IndimanModifiedDate.ToString()).ToString("dd MMMM yyyy") : string.Empty);
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$modifier$>", (objCostSheet.IndimanModifier != null && objCostSheet.IndimanModifier > 0) ? objCostSheet.objIndimanModifier.GivenName + " " + objCostSheet.objIndimanModifier.FamilyName : string.Empty);

            pricedetails = "<tr>" +
                           "<td>" +
                           "<table border=\"0.5\" style=\"text-align:center; font-size: 6px;\">" +
                           "<tr>" +
                           "<td bgcolor=\"#87CEFA\"  width=\"20\" style=\"text-align:center; \">Fab Code</td>" +
                           "<td bgcolor=\"#87CEFA\"  width=\"30\" style=\"text-align:center; \">Fab Description</td>" +
                           "<td bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Supplier </td>" +
                           "<td bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Cons</td>" +
                           "<td bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Unit</td>" +
                           "<td bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Rate</td>" +
                           "<td bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Cost</td>" +
                           "</tr>";



            foreach (PatternSupportFabricBO fabric in (new PatternSupportFabricBO()).SearchObjects().Where(o => o.CostSheet == objCostSheet.ID).ToList())
            {
                string supplier = (fabric.objFabric.Supplier != null && fabric.objFabric.Supplier > 0) ? fabric.objFabric.objSupplier.Name : "&nbsp;";
                string unit = (fabric.objFabric.Unit != null && fabric.objFabric.Unit > 0) ? fabric.objFabric.objUnit.Name : "&nbsp;";
                decimal rate = (fabric.objFabric.FabricPrice != null) ? Convert.ToDecimal(fabric.objFabric.FabricPrice.ToString()) : 0;
                decimal price = Convert.ToDecimal(fabric.FabConstant.ToString()) * rate;
                totalfabric = totalfabric + price;
                string nickname = (!string.IsNullOrEmpty(fabric.objFabric.NickName)) ? fabric.objFabric.NickName : "&nbsp;";

                pricedetails += "<tr><td width=\"20\" style=\"text-align:center; \">" + fabric.objFabric.Code + "</td>";
                pricedetails += "<td width=\"30\" style=\"text-align:center; \">" + nickname + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \">" + supplier + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \">" + fabric.FabConstant.ToString("0.00") + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \">" + unit + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \"> $ " + rate.ToString("0.00") + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \"> $ " + price.ToString("0.00") + "</td></tr>";
            }

            pricedetails += "<tr>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td style=\"text-align:center;\"><b>Total</b></td>" +
                            "<td style=\"text-align:center; \"><b> $ " + totalfabric.ToString("0.00") + "</b></td>" +
                            "</tr>" +
                            "</table>";
            //jkgramentshtmlstring = jkgramentshtmlstring.Replace("<$pricedetails$>", pricedetails);

            pricedetails += "<table>" +
                            "<tr>" +
                            "<td  style=\"line-height: 50px;>&nbsp;</td>" +
                            "<td height=\"100\">&nbsp;</td>" +
                            "<td height=\"100\">&nbsp;</td>" +
                            "<td height=\"100\">&nbsp;</td>" +
                            "<td height=\"100\">&nbsp;</td>" +
                            "<td height=\"100\">&nbsp;</td>" +
                            "<td style=\"color: #F0FFFF;\">HOOOOOOO</td>" +
                            "</tr>" +
                            "</table>";
            pricedetails += "<tr>" +
                            "<td style=\"line-height: 50;\">&nbsp;</td>" +
                            "</tr>";
            pricedetails += "<tr>" +
                            "<td>" +
                            "<table  border=\"0.5\" style=\"text-align:center; font-size: 6px;\">" +
                            "<tr>" +
                            "<th bgcolor=\"#87CEFA\" width=\"20\" style=\"text-align:center; \">Acc Code</th>" +
                            "<th bgcolor=\"#87CEFA\" width=\"30\" style=\"text-align:center; \">Acc Description</th>" +
                            "<th bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Supplier </th>" +
                            "<th bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Cons</th>" +
                            "<th bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Unit</th>" +
                            "<th bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Rate</th>" +
                            "<th bgcolor=\"#87CEFA\" width=\"10\" style=\"text-align:center; \">Cost</th>" +
                            "</tr>";

            foreach (PatternSupportAccessoryBO accessory in (new PatternSupportAccessoryBO()).SearchObjects().Where(o => o.CostSheet == objCostSheet.ID).ToList())
            {
                string supplier = (accessory.objAccessory.Supplier != null && accessory.objAccessory.Supplier > 0) ? accessory.objAccessory.objSupplier.Name : string.Empty;
                string unit = (accessory.objAccessory.Unit != null && accessory.objAccessory.Unit > 0) ? accessory.objAccessory.objUnit.Name : string.Empty;
                decimal rate = (accessory.objAccessory.Cost != null) ? Convert.ToDecimal(accessory.objAccessory.Cost.ToString()) : 0;
                decimal price = Convert.ToDecimal(accessory.AccConstant.ToString()) * rate;
                totalaccessory = totalaccessory + price;


                pricedetails += "<tr><td width=\"20\" style=\"text-align:center; font-size: 6px;\">" + accessory.objAccessory.Name + "</td>";
                pricedetails += "<td width=\"30\" style=\"text-align:center; \">" + accessory.objAccessory.Description + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \">" + supplier + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \">" + accessory.AccConstant.ToString("0.00") + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \">" + unit + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \"> $ " + rate.ToString("0.00") + "</td>";
                pricedetails += "<td width=\"10\" style=\"text-align:center; \"> $ " + price.ToString("0.00") + "</td></tr>";
            }

            // pricedetails += "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td style=\"border: #F3E solid 1px;\">" + totalaccessory.ToString("0.00") + "</td></tr>";
            pricedetails += "<tr>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td border=\"0\">&nbsp;</td>" +
                            "<td style=\"text-align:center;\"><b>Total</b></td>" +
                            "<td width=\"10\" style=\"text-align:center; \"><b> $ " + totalaccessory.ToString("0.00") + "</b></td>" +
                            "</tr>" +
                            "</table>" +
                            "</td>" +
                            "</tr>";
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$pricedetails$>", pricedetails);

            CostSheet objCostValues = new AddEditFactoryCostSheet().CalculateCostSheet(objCostSheet);

            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$totalfabriccost$>", Convert.ToDecimal(objCostValues.totalFabricCost).ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$totalaccessorycost$>", Convert.ToDecimal(objCostValues.totalAccCost).ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$totalhpcost$>", Convert.ToDecimal(objCostValues.heatpress).ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$totallabelcost$>", Convert.ToDecimal(objCostValues.labelCost).ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$othercost$>", Convert.ToDecimal(objCostValues.packing).ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$wastage$>", Convert.ToDecimal(objCostValues.wastage).ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$finance$>", Convert.ToDecimal(objCostValues.finance).ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$subwastage$>", Convert.ToDecimal(objCostValues.subWastage).ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$subfinance$>", Convert.ToDecimal(objCostValues.subFinance).ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$smv$>", objCostValues.smv.ToString("0.00"));//(objCostSheet.objPattern.SMV != null) ? Convert.ToDecimal(objCostSheet.objPattern.SMV.ToString()).ToString("0.00") : string.Empty);
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$smvrate$>", objCostValues.smvRate.ToString("0.00"));//(objCostSheet.SMVRate != null) ? Convert.ToDecimal(objCostSheet.SMVRate.ToString()).ToString("0.00") : string.Empty);
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cm$>", objCostValues.calculatedCM.ToString("0.00"));//(objCostSheet.CM != null) ? Convert.ToDecimal(objCostSheet.CM.ToString()).ToString("0.00") : string.Empty);
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$fobcost$>", Convert.ToDecimal(objCostValues.FOBCost).ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$quotedJKFOB$>", objCostValues.JKQuotedFOB.ToString("0.00")); //Convert.ToDecimal((objCostSheet.QuotedFOBCost != null && objCostSheet.QuotedFOBCost != decimal.Parse("0")) ? objCostSheet.QuotedFOBCost.ToString() : (objCostSheet.JKFOBCost != null) ? objCostSheet.JKFOBCost.ToString() : "0").ToString("0.00"));

            // indiman cost
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$subconsumption$>", Convert.ToDecimal(objCostSheet.SubCons).ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$dutyrate$>", Convert.ToDecimal(objCostValues.dutyRate).ToString("0.00"));

            //cost1
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$costfactor1name$>", (!string.IsNullOrEmpty(objCostSheet.CF1)) ? objCostSheet.CF1 : "Cost Factor 1");
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cost11$>", objCostValues.cons1.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cost12$>", objCostValues.rate1.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cost13$>", objCostValues.cost1.ToString("0.00"));

            //cost2
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$costfactor2name$>", (!string.IsNullOrEmpty(objCostSheet.CF1)) ? objCostSheet.CF2 : "Cost Factor 2");
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cost21$>", objCostValues.cons2.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cost22$>", objCostValues.rate2.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cost23$>", objCostValues.cost2.ToString("0.00"));

            //cost3
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$costfactor3name$>", (!string.IsNullOrEmpty(objCostSheet.CF1)) ? objCostSheet.CF3 : "Cost Factor 3");
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cost31$>", objCostValues.cons3.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cost32$>", objCostValues.rate3.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cost33$>", objCostValues.cost3.ToString("0.00"));

            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$ink$>", objCostValues.ink.ToString("0.000"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$inkrate$>", objCostValues.inkRate.ToString("0.000"));

            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$papaer$>", objCostValues.paper.ToString("0.000"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$paperrate$>", objCostValues.paperRate.ToString("0.000"));

            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$exchrate$>", objCostValues.exchangeRate.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$fobaud$>", objCostValues.fobAUD.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$duty$>", objCostValues.duty.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cost1$>", objCostValues.cost1.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cost2$>", objCostValues.cost2.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cost3$>", objCostValues.cost3.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$inkcost$>", objCostValues.inkCost.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$papercost$>", objCostValues.paperCost.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$airfreight$>", objCostValues.airFreight.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$impcharges$>", objCostValues.impCharges.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$mgtoh$>", objCostValues.mgtOH.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$indicooh$>", objCostValues.indicoOH.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$depr$>", objCostValues.depr.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$landed$>", objCostValues.landed.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$cif$>", objCostValues.indimanCIF.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$margin$>", objCostValues.calMgn.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$mp$>", objCostValues.calMp.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$quotedcif$>", objCostValues.quotedCIF.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$quotedmargin$>", objCostValues.actMgn.ToString("0.00"));
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$quotedmp$>", objCostValues.quotedMp.ToString("0.00"));

            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$fobfactor$>", (objCostSheet.FobFactor != null) ? Convert.ToDecimal(objCostSheet.FobFactor).ToString("0.00") : string.Empty);
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$quotedIndimanFOB$>", objCostValues.IndimanQuotedFOB.ToString("0.00")); //(objCostSheet.IndimanFOB != null) ? Convert.ToDecimal(objCostSheet.IndimanFOB).ToString("0.00") : string.Empty);
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$marginrate$>", objCostValues.marginRate.ToString("0.00"));

            // factory remarks
            CostSheetRemarksBO objRemark = new CostSheetRemarksBO();
            objRemark.CostSheet = objCostSheet.ID;
            List<CostSheetRemarksBO> lstRemarks = objRemark.SearchObjects();

            if (lstRemarks.Count > 0)
            {
                factoryremarks += "<table border=\"0\" width=\"100%\">";

                foreach (CostSheetRemarksBO fremarks in lstRemarks)
                {
                    factoryremarks += "<tr>";
                    factoryremarks += "<td width=\"30%\">" + fremarks.objModifier.GivenName + " " + fremarks.objModifier.FamilyName + "</td>";
                    factoryremarks += "<td width=\"20%\">" + fremarks.ModifiedDate.ToString("dd MMMM yyyy") + "</td>";
                    factoryremarks += "<td width=\"50%\">" + fremarks.Remarks + "</td>";
                    factoryremarks += "</tr>";
                }
                factoryremarks += "</table>";
            }
            else
            {
                factoryremarks += "<table border=\"0\" width=\"100%\">";
                factoryremarks += "<tr>";
                factoryremarks += "<td>&nbsp;</td>";
                factoryremarks += "</tr>";
                factoryremarks += "</table>";
            }
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$factoryremarks$>", factoryremarks);

            //indiman remarks
            IndimanCostSheetRemarksBO objIndimanCostSheetRemarks = new IndimanCostSheetRemarksBO();
            objIndimanCostSheetRemarks.CostSheet = objCostSheet.ID;

            List<IndimanCostSheetRemarksBO> lstIndimanCostSheetRemarks = objIndimanCostSheetRemarks.SearchObjects();

            if (lstIndimanCostSheetRemarks.Count > 0)
            {
                indimanremarks += "<table border=\"0\" width=\"100%\">";

                foreach (IndimanCostSheetRemarksBO inremarks in lstIndimanCostSheetRemarks)
                {
                    indimanremarks += "<tr>";
                    indimanremarks += "<td width=\"30%\">" + inremarks.objModifier.GivenName + " " + inremarks.objModifier.FamilyName + "</td>";
                    indimanremarks += "<td width=\"20%\">" + inremarks.ModifiedDate.ToString("dd MMMM yyyy") + "</td>";
                    indimanremarks += "<td width=\"50%\">" + inremarks.Remarks + "</td>";
                    indimanremarks += "</tr>";
                }
                indimanremarks += "</table>";
            }
            else
            {
                indimanremarks += "<table border=\"0\" width=\"100%\">";
                indimanremarks += "<tr>";
                indimanremarks += "<td>&nbsp;</td>";
                indimanremarks += "</tr>";
                indimanremarks += "</table>";
            }
            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$indimanremarks$>", indimanremarks);

            // cost sheet images 

            PatternTemplateImageBO objImage = new PatternTemplateImageBO();
            objImage.Pattern = objCostSheet.Pattern;
            objImage.IsHero = true;

            List<PatternTemplateImageBO> lstCostSheetimages = objImage.SearchObjects();
            if (lstCostSheetimages.Count > 0)
            {
                //costsheetimages += "<tr><td style=\"text-align:left;\"><table style=\"text-align:left;\"><tr>";

                foreach (PatternTemplateImageBO image in lstCostSheetimages)
                {
                    filepath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + "/" + objCostSheet.Pattern + "/" + image.Filename + image.Extension;

                    if (!File.Exists(filepath))
                    {
                        filepath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    }

                    System.Drawing.Image Image = System.Drawing.Image.FromFile(filepath);
                    SizeF CostSheetImage = Image.PhysicalDimension;
                    Image.Dispose();

                    lstCostSheetImages = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(CostSheetImage.Width)), Convert.ToInt32(Math.Abs(CostSheetImage.Height)), 300, 300);
                    costsheetimages += "<table><tr><td  style=\"text-align:left;\"><img src=\"" + filepath + "\" alt=\"Smiley face\" height=\"" + lstCostSheetImages[0].ToString() + "\" width=\"" + lstCostSheetImages[1].ToString() + "\" ></td></tr></table>";
                }

                //costsheetimages += "</tr></table></td></tr>";
            }

            IndimanCostSheethtmlstring = IndimanCostSheethtmlstring.Replace("<$images$>", costsheetimages);

            //string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\CostSheet_" + objCostSheet.ID.ToString() + ".html";
            //System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
            //file.WriteLine(IndimanCostSheethtmlstring);
            //file.Close();


            return IndimanCostSheethtmlstring;
        }

        public static string GenerateIndimanCostSheet(int costsheet)
        {
            string Indimancostsheetpath = string.Empty;
            if (costsheet > 0)
            {
                CostSheetBO objCostSheet = new CostSheetBO();
                objCostSheet.ID = costsheet;
                objCostSheet.GetObject();

                try
                {
                    Indimancostsheetpath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "IndimanCostSheet_" + objCostSheet.ID.ToString() + "_" + objCostSheet.Pattern.ToString() + "_" + objCostSheet.Fabric.ToString() + "_" + ".pdf";

                    if (File.Exists(Indimancostsheetpath))
                    {
                        File.Delete(Indimancostsheetpath);
                    }

                    Document document = new Document();
                    PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(Indimancostsheetpath, FileMode.Create));
                    document.AddKeywords("paper airplanes");

                    float marginBottom = 12;
                    float lineHeight = 14;
                    float pageMargin = 20;
                    float pageHeight = iTextSharp.text.PageSize.A4.Height;
                    float pageWidth = iTextSharp.text.PageSize.A4.Width;

                    document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                    document.SetMargins(0, 0, 0, 0);

                    // Open the document for writing content
                    document.Open();
                    // Get the top layer and write some text
                    contentByte = writer.DirectContent;

                    contentByte.BeginText();
                    string content = string.Empty;

                    //Header
                    contentByte.SetFontAndSize(PDFFont, 10);
                    content = "JK AND INDICO COST SHEET";
                    contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

                    contentByte.EndText();
                    // Top Line
                    contentByte.SetLineWidth(0.5f);
                    contentByte.SetColorStroke(BaseColor.BLACK);
                    contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.Stroke();

                    string htmlText = GenerateOdsPdf.CreateIndimanCostSheet(objCostSheet);
                    HTMLWorker htmlWorker = new HTMLWorker(document);
                    htmlWorker.Parse(new StringReader(htmlText));

                    document.Close();
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while Generate Pdf IndimanCostSheet in GenerateOdsPdf Class", ex);
                }
            }

            return Indimancostsheetpath;
        }

        public static string GenerateIndimanBulkCostSheet()
        {
            string Indimancostsheetpath = string.Empty;
            List<string> lstFilePaths = new List<string>();

            Indimancostsheetpath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "IndimanCostSheet_Bulk.pdf";

            string DirectoryPath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + Guid.NewGuid();

            if (!Directory.Exists(DirectoryPath))
            {
                Directory.CreateDirectory(DirectoryPath);
            }

            if (File.Exists(Indimancostsheetpath))
            {
                File.Delete(Indimancostsheetpath);
            }

            foreach (CostSheetBO objCostSheet in (new CostSheetBO()).SearchObjects().Where(o => o.JKFOBCost != 0 && o.IndimanCIF != 0))
            {

                try
                {
                    string tempIndimancostsheetpath = DirectoryPath + "\\" + "IndimanCostSheet_" + objCostSheet.ID.ToString() + "_" + objCostSheet.Pattern.ToString() + "_" + objCostSheet.Fabric.ToString() + "_" + ".pdf";

                    lstFilePaths.Add(tempIndimancostsheetpath);

                    Document document = new Document();
                    PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(tempIndimancostsheetpath, FileMode.Create));
                    document.AddKeywords("paper airplanes");

                    float marginBottom = 12;
                    float lineHeight = 14;
                    float pageMargin = 20;
                    float pageHeight = iTextSharp.text.PageSize.A4.Height;
                    float pageWidth = iTextSharp.text.PageSize.A4.Width;

                    document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                    document.SetMargins(0, 0, 0, 0);

                    // Open the document for writing content
                    document.Open();
                    // Get the top layer and write some text
                    contentByte = writer.DirectContent;

                    contentByte.BeginText();
                    string content = string.Empty;

                    //Header
                    contentByte.SetFontAndSize(PDFFont, 10);
                    content = "JK AND INDICO COST SHEET";
                    contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

                    contentByte.EndText();
                    // Top Line
                    contentByte.SetLineWidth(0.5f);
                    contentByte.SetColorStroke(BaseColor.BLACK);
                    contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.Stroke();

                    string htmlText = GenerateOdsPdf.CreateIndimanCostSheet(objCostSheet);
                    HTMLWorker htmlWorker = new HTMLWorker(document);
                    htmlWorker.Parse(new StringReader(htmlText));

                    document.Close();
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while Generate Pdf IndimanCostSheet in GenerateOdsPdf Class", ex);
                }
            }

            if (lstFilePaths.Count > 0)
            {
                CombineAndSavePdf(Indimancostsheetpath, lstFilePaths);
            }

            if (Directory.Exists(DirectoryPath))
            {
                Thread t = new Thread(new ThreadStart(() => DeleteDirectory(DirectoryPath)));
                t.Start();
            }

            return Indimancostsheetpath;
        }

        /*private static bool FindAndKillProcess(string name)
        {
            //here we're going to get a list of all running processes on
            //the computer
            foreach (Process clsProcess in Process.GetProcesses())
            {
                //now we're going to see if any of the running processes
                //match the currently running processes by using the StartsWith Method,
                //this prevents us from incluing the .EXE for the process we're looking for.
                //. Be sure to not
                //add the .exe to the name you provide, i.e: NOTEPAD,
                //not NOTEPAD.EXE or false is always returned even if
                //notepad is running
                if (clsProcess.ProcessName.StartsWith(name))
                {
                    //since we found the proccess we now need to use the
                    //Kill Method to kill the process. Remember, if you have
                    //the process running more than once, say IE open 4
                    //times the loop thr way it is now will close all 4,
                    //if you want it to just close the first one it finds
                    //then add a return; after the Kill
                    clsProcess.Kill();
                    //process killed, return true
                    return true;
                }
            }
            //process not found, return false
            return false;
        }*/

        private static void DeleteDirectory(string directorypath)
        {
            // get a write lock on scCacheKeys
            IndicoPage.RWLock.AcquireWriterLock(Timeout.Infinite);

            bool isDelete = true;

            while (isDelete)
            {
                try
                {
                    Directory.Delete(directorypath, true);
                    isDelete = false;
                }
                catch (Exception)
                {
                    isDelete = true;

                }
                finally
                {

                    if (!isDelete)
                    {
                        // release the lock
                        IndicoPage.RWLock.ReleaseWriterLock();
                    }

                }
            }

        }

        private static string CreatePolyBagBarcodelHTML(string imagePath)
        {
            string bolybagbarcode = PolyBagLabels;

            bolybagbarcode = bolybagbarcode.Replace("<$image$>", "<img src=\"" + imagePath + "\" alt=\"Smiley face\" height=\"" + 95 + "\" width=\"" + 265 + "\" >");

            return bolybagbarcode;
        }

        public static string PrintPolyBagBarcode(string imagelocation)
        {
            string directorypath = imagelocation + Guid.NewGuid();//IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + Guid.NewGuid();
            List<string> lstfilepaths = new List<string>();
            string tempfilepath = string.Empty;

            string polybagbarcodes = imagelocation + "PolyBag_Barcodes_" + DateTime.Now.ToString("dd MMMM yyyy") + "_" + ".pdf";

            try
            {
                if (Directory.Exists(directorypath))
                {
                    Directory.Delete(directorypath, true);
                }
                else
                {
                    Directory.CreateDirectory(directorypath);
                }

                if (File.Exists(polybagbarcodes))
                {
                    File.Delete(polybagbarcodes);
                }

                List<string> lstFileNames = Directory.GetFiles(imagelocation).Select(f => new FileInfo(f)).OrderBy(f => f.CreationTime).Select(m => m.FullName).ToList();

                foreach (string imagePath in lstFileNames)
                {


                    tempfilepath = directorypath + "\\" + Guid.NewGuid() + ".pdf";

                    Document document = new Document();
                    PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(tempfilepath, FileMode.Create));
                    document.AddKeywords("paper airplanes");

                    //float marginBottom = 12;
                    //float lineHeight = 14;
                    //float pageMargin = 20;
                    float pageHeight = (float)100.0;
                    float pageWidth = (float)295.0;

                    document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                    document.SetMargins(0, 0, 0, 0);

                    // Open the document for writing content
                    document.Open();

                    string htmlText = GenerateOdsPdf.CreatePolyBagBarcodelHTML(imagePath);
                    HTMLWorker htmlWorker = new HTMLWorker(document);
                    htmlWorker.Parse(new StringReader(htmlText));

                    document.Close();

                    lstfilepaths.Add(tempfilepath);

                }

                if (lstfilepaths.Count > 0)
                {
                    CombineAndSavePdf(polybagbarcodes, lstfilepaths);
                }

                if (Directory.Exists(directorypath))
                {
                    Thread t = new Thread(new ThreadStart(() => DeleteDirectory(directorypath)));
                    t.Start();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while creating Poly Bag Barcode Label in GenerateOdsPdf PrintPolyBagBarcode", ex);
            }

            return polybagbarcodes;
        }

        private static string CreateCartonBarcodelHTML(string imagePath)
        {
            string cartonbarcode = CartonLabels;

            cartonbarcode = cartonbarcode.Replace("<$image$>", "<img src=\"" + imagePath + "\" alt=\"Smiley face\" height=\"" + 255 + "\" width=\"" + 285 + "\" >");

            return cartonbarcode;
        }

        public static string PrintCartonBarcode(string imagelocation)
        {
            string directorypath = imagelocation + Guid.NewGuid();//IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + Guid.NewGuid();
            List<string> lstfilepaths = new List<string>();
            string tempfilepath = string.Empty;

            string polybagbarcodes = imagelocation + "Carton_Barcodes_" + DateTime.Now.ToString("dd MMMM yyyy") + "_" + ".pdf";

            try
            {
                if (Directory.Exists(directorypath))
                {
                    Directory.Delete(directorypath, true);
                }
                else
                {
                    Directory.CreateDirectory(directorypath);
                }

                if (File.Exists(polybagbarcodes))
                {
                    File.Delete(polybagbarcodes);
                }

                List<string> lstFileNames = Directory.GetFiles(imagelocation).Select(f => new FileInfo(f)).OrderBy(f => f.CreationTime).Select(m => m.FullName).ToList();

                foreach (string imagePath in lstFileNames)
                {
                    tempfilepath = directorypath + "\\" + Guid.NewGuid() + ".pdf";

                    Document document = new Document();
                    PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(tempfilepath, FileMode.Create));
                    document.AddKeywords("paper airplanes");

                    //float marginBottom = 12;
                    //float lineHeight = 14;
                    //float pageMargin = 20;
                    float pageHeight = (float)255.0;
                    float pageWidth = (float)385.0;

                    document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                    document.SetMargins(0, 0, 0, 0);

                    // Open the document for writing content
                    document.Open();

                    string htmlText = GenerateOdsPdf.CreateCartonBarcodelHTML(imagePath);
                    HTMLWorker htmlWorker = new HTMLWorker(document);
                    htmlWorker.Parse(new StringReader(htmlText));

                    document.Close();

                    lstfilepaths.Add(tempfilepath);

                }

                if (lstfilepaths.Count > 0)
                {
                    CombineAndSavePdf(polybagbarcodes, lstfilepaths);
                }

                if (Directory.Exists(directorypath))
                {
                    Thread t = new Thread(new ThreadStart(() => DeleteDirectory(directorypath)));
                    t.Start();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while creating Carton Barcode Label in GenerateOdsPdf PrintCartonBarcode", ex);
            }

            return polybagbarcodes;
        }

        private static string CreatePackingReprortHTML(DateTime WeekendDate, int shipmentmode, int shipmentaddress)
        {
            string packingreport = PackingListReport;
            int totalctn = 0;
            int totalqty = 0;

            List<PackingList> PackingLists = new List<PackingList>();
            List<PackingListViewBO> lstPackingLists = new List<PackingListViewBO>();
            lstPackingLists = PackingListBO.GetPackingList(WeekendDate, shipmentmode, shipmentaddress);

            if (lstPackingLists.Count > 0)
            {
                IEnumerable<IGrouping<int?, PackingListViewBO>> lst = lstPackingLists.GroupBy(m => m.ShipTo).ToList();

                string data = string.Empty;

                IGrouping<int?, PackingListViewBO> igPackingList = lst.FirstOrDefault();
                PackingListViewBO obj = igPackingList.First();

                foreach (IGrouping<int?, PackingListViewBO> pl in lst)
                {
                    DistributorClientAddressBO objDistributorClientAdress = new DistributorClientAddressBO();
                    objDistributorClientAdress.ID = (int)pl.Key;
                    objDistributorClientAdress.GetObject();

                    int invoice = (new InvoiceOrderBO()).SearchObjects().Where(o => o.OrderDetail == obj.OrderDetail).Select(o => o.Invoice).SingleOrDefault();

                    InvoiceBO objInvoice = new InvoiceBO();
                    objInvoice.ID = invoice;
                    objInvoice.GetObject();


                    data += "<table bgcolor=\"#d9edf7\" cellpadding=\"8\"style=\"font-size:9px;background-color: #d9edf7; border-color: #bce8f1; color: #3a87ad\" cellspacing=\"0\" border=\"0\" width=\"40%\" align=\"right\">"
                            + "<tr>"
                            + "<td style=\"line-height:1px;\" width=\"100%\">" + objDistributorClientAdress.CompanyName + "</td>"
                            + "</tr>"
                            + "<tr>"
                            + "<td style=\"line-height:1px;\" width=\"100%\">" + objDistributorClientAdress.Address + "</td>"
                            + "</tr>"
                            + "<tr>"
                            + "<td style=\"line-height:1px;\" width=\"100%\">" + objDistributorClientAdress.Suburb + "</td>"
                            + "</tr>"
                            + "<tr>"
                            + "<td style=\"line-height:1px;\" width=\"100%\">" + objDistributorClientAdress.State + " " + objDistributorClientAdress.PostCode + " , " + objDistributorClientAdress.objCountry.ShortName + "</td>"
                            + "</tr>"
                            + "<tr>"
                            + "<td style=\"line-height:1px;\" width=\"100%\"><b>" + objInvoice.InvoiceNo + "</b></td>"
                            + "</tr>"
                            + "</table>";

                    IEnumerable<IGrouping<string, PackingListViewBO>> lstModesGroup = pl.GroupBy(o => (string)o.ShipmentMode).ToList();

                    foreach (IGrouping<string, PackingListViewBO> modes in lstModesGroup)
                    {
                        data += "<table cellpadding=\"5\"style=\"font-size:8px;\" cellspacing=\"0\" border=\"0\" width=\"100%\" align=\"right\">"
                         + "<tr>"
                         + "<td style=\"line-height:1px;\" width=\"100%\"><b>" + modes.Key + "</b></td>"
                         + "</tr>"
                         + "</table>";


                        IEnumerable<IGrouping<int, PackingListViewBO>> lstCarton = pl.GroupBy(o => (int)o.CartonNo).ToList();

                        totalctn = lstCarton.Count();

                        //IGrouping<int, PackingListViewBO> igPackingList = lstCarton.FirstOrDefault();
                        //PackingListViewBO obj = igPackingList.First();


                        foreach (IGrouping<int, PackingListViewBO> carton in lstCarton)
                        {
                            int total = 0;

                            data += "<table cellpadding=\"5\"style=\"font-size:8px;\" cellspacing=\"0\" border=\"0\" width=\"100%\" align=\"center\">"
                                         + "<tr>"
                                         + "<td width=\"5%\"></td>"
                                         + "<td width=\"12%\"><h4><b>Carton : " + carton.Key + "</b></h4></td>"
                                         + "<td width=\"12%\"></td>"
                                         + "<td width=\"10%\"></td>"
                                         + "<td width=\"20%\"><h5></h5></td>"
                                         + "<td width=\"36%\"></td>"
                                         + "<td width=\"5%\"></td>"
                                         + "</tr>"
                                         + " <tr>"
                                         + "<th style=\"line-height:8px;\" width=\"5%\"><b>PO No.</b></th>"
                                         + "<th style=\"line-height:8px;\" width=\"12%\"><b>Client</b></th>"
                                         + "<th style=\"line-height:8px;\" width=\"12%\"><b>Distributor</b></th>"
                                         + "<th style=\"line-height:8px;\" width=\"10%\"><b>VL No</b></th>"
                                         + "<th style=\"line-height:8px;\" width=\"20%\"><b>Description</b></th>"
                                         + "<th style=\"line-height:8px;\" width=\"36%\"><b>Size</b></th>"
                                         + "<th style=\"line-height:8px;\" width=\"5%\"><b>Total</b></th>"
                                         + "</tr>";

                            foreach (PackingListViewBO packinglist in carton)
                            {
                                data += "<tr>"
                                       + "<td style=\"line-height:8px;\" width=\"5%\">" + packinglist.OrderNumber.ToString() + "</td>"
                                       + "<td style=\"line-height:8px;\" width=\"12%\">" + packinglist.Client + "</td>"
                                       + "<td style=\"line-height:6px;\" width=\"12%\">" + packinglist.Distributor + "</td>"
                                       + "<td style=\"line-height:8px;\" width=\"10%\">" + packinglist.VLName + "</td>"
                                       + "<td style=\"line-height:8px;\" width=\"20%\">" + packinglist.Pattern + "</td>"
                                       + "<td style=\"line-height:8px;\" width=\"36%\">";

                                PackingListSizeQtyBO objPackSizeQty = new PackingListSizeQtyBO();
                                objPackSizeQty.PackingList = packinglist.PackingList.Value;

                                List<PackingListSizeQtyBO> lstPackListQtys = objPackSizeQty.SearchObjects().Where(m => m.Qty > 0).ToList();

                                data += "<table cellpadding=\"3\" border=\"0.5\" width=\"100%\" align=\"center\">"
                                                + "<tr>";

                                foreach (PackingListSizeQtyBO plsq in lstPackListQtys)
                                {

                                    data += "<td style=\"line-height:4px;\" align=\"center\" width=\"5%\" bgcolor=\"#6495ED\" >" + plsq.objSize.SizeName + "</td>";


                                }

                                data += "</tr>"
                                        + "<tr>";

                                foreach (PackingListSizeQtyBO plsq in lstPackListQtys)
                                {
                                    int count = (new PackingListCartonItemBO()).SearchObjects().Where(o => o.PackingList == plsq.PackingList && o.Size == plsq.Size).Count();

                                    string color = string.Empty;

                                    if (count == 0)
                                    {
                                        color = "#FFFFFF";
                                    }
                                    else if (count == plsq.Qty)
                                    {
                                        color = "#33CC66";
                                    }
                                    else if (count > 0)
                                    {
                                        color = "#FFFFCC";
                                    }
                                    data += "<td style=\"line-height:4px;\" align=\"center\" width=\"2%\" bgcolor=\"" + color + "\">" + count + " / " + plsq.Qty + "</td>";

                                }

                                data += "</tr>"
                                          + "</table>"
                                          + "</td>"
                                          + "<td width=\"5%\">" + packinglist.PackingTotal.Value + "</td>"
                                          + "</tr>";

                                total += packinglist.PackingTotal.Value;


                            }

                            totalqty += total;

                            data += "<tr>"
                                  + "<td colspan=\"7\"></td>"
                                  + "</tr>"
                                  + " <tr>"
                                  + "<th style=\"line-height:8px;\" width=\"5%\"</th>"
                                  + "<th style=\"line-height:8px;\" width=\"12%\"></th>"
                                  + "<th style=\"line-height:8px;\" width=\"12%\"></th>"
                                  + "<th style=\"line-height:8px;\" width=\"10%\"></th>"
                                  + "<th style=\"line-height:8px;\" width=\"20%\"></th>"
                                  + "<th style=\"line-height:8px;\" width=\"36%\"></th>"
                                  + "<th style=\"line-height:8px;\" width=\"5%\">" + total.ToString() + "</th>"
                                  + "</tr>";
                            data += "</table>";

                        }

                    }
                }

                packingreport = packingreport.Replace("<$tabledata$>", data);
                packingreport = packingreport.Replace("<$totalctn$>", totalctn.ToString());
                packingreport = packingreport.Replace("<$totalpcs$>", totalqty.ToString());
            }

            return packingreport;
        }

        public static string GeneratePackingReportPDF(DateTime WeekEndDate, int shipmentmode, int shipmentaddress)
        {
            string packinglistreportpath = string.Empty;



            if (WeekEndDate != null && WeekEndDate != new DateTime(1100, 1, 1))
            {

                try
                {
                    packinglistreportpath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "Packing_Report_" + WeekEndDate.ToString("dd MMMM yyyy") + ".pdf";

                    if (File.Exists(packinglistreportpath))
                    {
                        File.Delete(packinglistreportpath);
                    }

                    Document document = new Document();
                    PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(packinglistreportpath, FileMode.Create));
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

                    //Header
                    contentByte.SetFontAndSize(PDFFont, 10);
                    content = "Packing List Report - " + WeekEndDate.ToString("dd MMMM yyyy");
                    contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

                    contentByte.EndText();
                    // Top Line
                    contentByte.SetLineWidth(0.5f);
                    contentByte.SetColorStroke(BaseColor.BLACK);
                    contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.Stroke();

                    string htmlText = GenerateOdsPdf.CreatePackingReprortHTML(WeekEndDate, shipmentmode, shipmentaddress);
                    HTMLWorker htmlWorker = new HTMLWorker(document);
                    htmlWorker.Parse(new StringReader(htmlText));

                    document.Close();
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while Generate Pdf PackingListReport in GenerateOdsPdf Class", ex);
                }
            }
            return packinglistreportpath;
        }

        private static string CreateResetBarcodelHTML(string imagePath)
        {
            string resetbarcode = ResetBarcode;

            resetbarcode = resetbarcode.Replace("<$image$>", "<img src=\"" + imagePath + "\" alt=\"Smiley face\" height=\"" + 255 + "\" width=\"" + 285 + "\" >");

            return resetbarcode;
        }

        public static string PrintResetBarcode(string imagelocation, string imagePath)
        {
            //string directorypath = imagelocation + Guid.NewGuid();//IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + Guid.NewGuid();

            string tempfilepath = string.Empty;

            string resetbarcodes = imagelocation + "Reset_Barcodes_" + DateTime.Now.ToString("dd MMMM yyyy") + "_" + ".pdf";

            try
            {
                /*if (Directory.Exists(directorypath))
                {
                    Directory.Delete(directorypath, true);
                }
                else
                {
                    Directory.CreateDirectory(directorypath);
                }*/

                if (File.Exists(resetbarcodes))
                {
                    File.Delete(resetbarcodes);
                }


                Document document = new Document();
                PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(resetbarcodes, FileMode.Create));
                document.AddKeywords("paper airplanes");

                //float marginBottom = 12;
                //float lineHeight = 14;
                //float pageMargin = 20;
                float pageHeight = (float)255.0;
                float pageWidth = (float)385.0;

                document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                document.SetMargins(0, 0, 0, 0);

                // Open the document for writing content
                document.Open();

                string htmlText = GenerateOdsPdf.CreateCartonBarcodelHTML(imagePath);
                HTMLWorker htmlWorker = new HTMLWorker(document);
                htmlWorker.Parse(new StringReader(htmlText));

                document.Close();

            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while creating Reset Barcode Label in GenerateOdsPdf PrintReset Barcode", ex);
            }

            return resetbarcodes;
        }

        private static string CreateShippingDetailsHTML(DateTime WeekendDate)
        {
            string shippinglist = ShippingDetailsList;

            List<ReturnShiipingDetailsViewBO> lstShippingList = new List<ReturnShiipingDetailsViewBO>();
            lstShippingList = OrderBO.GetShippingDetails(WeekendDate);

            if (lstShippingList.Count > 0)
            {
                IEnumerable<IGrouping<string, ReturnShiipingDetailsViewBO>> lst = lstShippingList.GroupBy(m => m.SubItem).ToList();


                string data = string.Empty;

                foreach (IGrouping<string, ReturnShiipingDetailsViewBO> sd in lst)
                {
                    int total = 0;
                    data += "<table cellpadding=\"5\"style=\"font-size:8px;\" cellspacing=\"0\" border=\"0.5\" width=\"100%\" align=\"center\">"
                                 + "<tr>"
                                 + "<td style=\"line-height:8px;\" colspan=\"6\"> <h5>" + sd.Key + "</h5></td>"
                                 + "</tr>"
                                 + " <tr>"
                                 + "<th style=\"line-height:8px;\" width=\"10%\"><b>Shipment Date</b></th>"
                                 + "<th style=\"line-height:8px;\" width=\"30%\"><b>Pattern</b></th>"
                                 + "<th style=\"line-height:8px;\" width=\"8%\"><b>Quantity</b></th>"
                                 + "<th style=\"line-height:8px;\" width=\"10%\"><b>Type</b></th>"
                                 + "<th style=\"line-height:8px;\" width=\"23%\"><b>Fabric</b></th>"
                                 + "<th style=\"line-height:8px;\" width=\"10%\"><b>Order No</b></th>"
                                 + "<th style=\"line-height:8px;\" width=\"10%\"><b>Visual Layout</b></th>"
                                 + "</tr>";

                    foreach (ReturnShiipingDetailsViewBO shippingDetails in sd)
                    {
                        string order = (!string.IsNullOrEmpty(shippingDetails.PurONo)) ? shippingDetails.PurONo : shippingDetails.Order.ToString();
                        data += "<tr>"
                               + "<td style=\"line-height:8px;\" width=\"10%\">" + Convert.ToDateTime(shippingDetails.ShipmentDate.ToString()).ToString("dd MMMM yyyy") + "</td>"
                               + "<td style=\"line-height:8px;\" width=\"30%\">" + shippingDetails.Pattern + "</td>"
                               + "<td style=\"line-height:8px;\" width=\"8%\">" + shippingDetails.Quantity.ToString() + "</td>"
                               + "<td style=\"line-height:8px;\" width=\"10%\">" + shippingDetails.OrderType + "</td>"
                               + "<td style=\"line-height:8px;\" width=\"23%\">" + shippingDetails.Fabric + "</td>"
                               + "<td style=\"line-height:8px;\" width=\"10%\">" + order + "</td>"
                               + "<td style=\"line-height:8px;\" width=\"10%\">" + shippingDetails.VisualLayout + "</td>"
                               + "</tr>";

                        total = total + (int)shippingDetails.Quantity;
                    }

                    data += "<tr>"
                              + "<td border=\"0\" style=\"line-height:8px;\" width=\"10%\"></td>"
                              + "<td border=\"0\" style=\"line-height:8px;\" width=\"30%\"></td>"
                              + "<td border=\"0.5\" style=\"line-height:8px;\" width=\"8%\"><b>" + total.ToString() + "</b></td>"
                              + "<td border=\"0\" style=\"line-height:8px;\" width=\"10%\"></td>"
                              + "<td border=\"0\" style=\"line-height:8px;\" width=\"23%\"></td>"
                              + "<td border=\"0\" style=\"line-height:8px;\" width=\"10%\"></td>"
                              + "<td border=\"0\" style=\"line-height:8px;\" width=\"10%\"></td>"
                              + "</tr>";
                    data += "<tr>"
                              + "<td border=\"0\" style=\"line-height:8px;\" width=\"10%\"></td>"
                              + "<td border=\"0\" style=\"line-height:8px; color:#ffffff;\" width=\"30%\">hgfytfytfyfgtt</td>"
                              + "<td border=\"0\" style=\"line-height:8px;\" width=\"8%\"></td>"
                              + "<td border=\"0\" style=\"line-height:8px;\" width=\"10%\"></td>"
                              + "<td border=\"0\" style=\"line-height:8px;\" width=\"23%\"></td>"
                              + "<td border=\"0\" style=\"line-height:8px;\" width=\"10%\"></td>"
                              + "<td border=\"0\" style=\"line-height:8px;\" width=\"10%\"></td>"
                              + "</tr>";
                    data += "</table>";
                }

                shippinglist = shippinglist.Replace("<$tabledata$>", data);
            }

            return shippinglist;
        }

        public static string GenerateShippingDetailsPDF(DateTime WeekEndDate)
        {
            string shippingdetailstpath = string.Empty;



            if (WeekEndDate != null && WeekEndDate != new DateTime(1100, 1, 1))
            {

                try
                {
                    shippingdetailstpath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "Packing_Report_" + WeekEndDate.ToString("dd MMMM yyyy") + ".pdf";

                    if (File.Exists(shippingdetailstpath))
                    {
                        File.Delete(shippingdetailstpath);
                    }

                    Document document = new Document();
                    PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(shippingdetailstpath, FileMode.Create));
                    document.AddKeywords("paper airplanes");

                    float marginBottom = 12;
                    float lineHeight = 14;
                    float pageMargin = 20;
                    float pageHeight = iTextSharp.text.PageSize.A4.Height;
                    float pageWidth = iTextSharp.text.PageSize.A4.Width;

                    document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                    document.SetMargins(0, 0, 0, 0);

                    // Open the document for writing content
                    document.Open();
                    // Get the top layer and write some text
                    contentByte = writer.DirectContent;

                    contentByte.BeginText();
                    string content = string.Empty;

                    //Header
                    contentByte.SetFontAndSize(PDFFont, 10);
                    content = "Orders List for - " + WeekEndDate.ToString("dd MMMM yyyy");
                    contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

                    contentByte.EndText();
                    // Top Line
                    contentByte.SetLineWidth(0.5f);
                    contentByte.SetColorStroke(BaseColor.BLACK);
                    contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.Stroke();

                    string htmlText = GenerateOdsPdf.CreateShippingDetailsHTML(WeekEndDate);
                    HTMLWorker htmlWorker = new HTMLWorker(document);
                    htmlWorker.Parse(new StringReader(htmlText));

                    document.Close();
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while Generate Pdf Shipping Details in GenerateOdsPdf Class", ex);
                }
            }
            return shippingdetailstpath;
        }

        //private static void CreateBackOrderReport(DateTime _weekenddate, int _distributor, string _filepath)
        //{
        //    try
        //    {
        //        CreateOpenXMLExcel openxml_Excel = new CreateOpenXMLExcel("Back Order Excel");

        //        #region Page Setup

        //        openxml_Excel.SetPageSetup(XLPageOrientation.Portrait, XLPaperSize.A4Paper);

        //        #endregion

        //        #region Set Margins

        //        openxml_Excel.SetMargings(0.25, 0.75, 0, 0, 0.3, 0, false, false);

        //        #endregion

        //        #region Change Column Width

        //        openxml_Excel.ChangeColumnWidth(1, 10);//A
        //        openxml_Excel.ChangeColumnWidth(2, 10);//B
        //        openxml_Excel.ChangeColumnWidth(3, 10);//C
        //        openxml_Excel.ChangeColumnWidth(4, 10);//D
        //        openxml_Excel.ChangeColumnWidth(5, 10);//E
        //        openxml_Excel.ChangeColumnWidth(6, 10);//F
        //        openxml_Excel.ChangeColumnWidth(7, 10);//G
        //        openxml_Excel.ChangeColumnWidth(8, 10);//H
        //        openxml_Excel.ChangeColumnWidth(9, 10);//I
        //        //openxml_Excel.ChangeColumnWidth(10, 10);//J
        //        //openxml_Excel.ChangeColumnWidth(11, 10);//K
        //        //openxml_Excel.ChangeColumnWidth(12, 10);//L
        //        //openxml_Excel.ChangeColumnWidth(13, 10);//M
        //        //openxml_Excel.ChangeColumnWidth(14, 10);//N


        //        #endregion

        //        #region Header Data
        //        int totalCount = 0;

        //        CompanyBO objCompany = new CompanyBO();
        //        objCompany.ID = _distributor;
        //        objCompany.GetObject();

        //        List<OrderDetailsViewBO> lstOrderDetails = lstOrderDetails = OrderBO.GetWeeklyFirmOrders(_weekenddate, string.Empty, string.Empty, 0, true, 1, 0, out totalCount, string.Empty, objCompany.Name, string.Empty);

        //        OrderBO objOrder = new OrderBO();
        //        objOrder.ID = (int)lstOrderDetails[0].Order;
        //        objOrder.GetObject();

        //        openxml_Excel.AddCellValue("A1", "BACK ORDERS REPORT FOR  " + objOrder.objDistributor.Name, "Calibri", true, XLAlignmentHorizontalValues.Left, 18, XLCellValues.Text);

        //        int i = 3;

        //        for (int c = 1; c < 10; c++)
        //        {
        //            openxml_Excel.DrawToptBorder(i, c, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        }

        //        openxml_Excel.AddHeaderData("A" + i.ToString(), "DEPARTS FACTORY ON " + _weekenddate.ToLongDateString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "A" + i.ToString() + ":" + "E" + i.ToString(), XLCellValues.Text, XLColor.Khaki);
        //        openxml_Excel.AddHeaderData("F" + i.ToString(), objOrder.objShipmentMode.Name, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "F" + i.ToString() + ":" + "I" + i.ToString(), XLCellValues.Text, XLColor.Khaki);

        //        openxml_Excel.DrawLeftBorder(i, 1, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 5, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 9, XLBorderStyleValues.Thin, XLColor.DarkGray);

        //        for (int c = 1; c < 10; c++)
        //        {
        //            openxml_Excel.DrawBottomBorder(i, c, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        }

        //        int p = i++;

        //        openxml_Excel.AddCellValue("A" + i.ToString(), "Please allow another 1 week for shipment, customs clearance, local", "Calibri", false, XLAlignmentHorizontalValues.Left, 10, XLCellValues.Text, XLColor.White);

        //        i++;

        //        openxml_Excel.DrawLeftBorder(i, 1, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 5, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 9, XLBorderStyleValues.Thin, XLColor.DarkGray);

        //        openxml_Excel.AddCellValue("A" + i.ToString(), "delivery. Shipment dates are indicative dates. Subject to change without", "Calibri", false, XLAlignmentHorizontalValues.Left, 10, XLCellValues.Text, XLColor.White);

        //        i++;

        //        openxml_Excel.DrawLeftBorder(i, 1, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 5, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 9, XLBorderStyleValues.Thin, XLColor.DarkGray);

        //        openxml_Excel.AddCellValue("A" + i.ToString(), "notce.", "Calibri", false, XLAlignmentHorizontalValues.Left, 10, XLCellValues.Text, XLColor.White);

        //        //i++;

        //        //openxml_Excel.AddHeaderDataWrapText("A" + i.ToString(), "Subject to change without notce.", "Calibri", false, XLAlignmentHorizontalValues.Left, 10, "A" + i.ToString() + ":" + "D" + i.ToString(), XLCellValues.Text, XLColor.White, XLAlignmentVerticalValues.Center);
        //        i = p;
        //        i++;

        //        openxml_Excel.DrawLeftBorder(i, 1, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 5, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 9, XLBorderStyleValues.Thin, XLColor.DarkGray);

        //        openxml_Excel.AddCellValue("F" + i.ToString(), objOrder.objDespatchToAddress.CompanyName, "Calibri", false, XLAlignmentHorizontalValues.Left, 10, XLCellValues.Text);

        //        i++;

        //        openxml_Excel.DrawLeftBorder(i, 1, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 5, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 9, XLBorderStyleValues.Thin, XLColor.DarkGray);

        //        openxml_Excel.AddCellValue("F" + i.ToString(), objOrder.objDespatchToAddress.Address, "Calibri", false, XLAlignmentHorizontalValues.Left, 10, XLCellValues.Text);

        //        i++;

        //        openxml_Excel.DrawLeftBorder(i, 1, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 5, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 9, XLBorderStyleValues.Thin, XLColor.DarkGray);

        //        openxml_Excel.AddCellValue("F" + i.ToString(), objOrder.objDespatchToAddress.Suburb + " , " + objOrder.objDespatchToAddress.State, "Calibri", false, XLAlignmentHorizontalValues.Left, 10, XLCellValues.Text);

        //        i++;

        //        openxml_Excel.DrawLeftBorder(i, 1, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 5, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 9, XLBorderStyleValues.Thin, XLColor.DarkGray);

        //        openxml_Excel.AddCellValue("F" + i.ToString(), objOrder.objDespatchToAddress.objCountry.ShortName, "Calibri", false, XLAlignmentHorizontalValues.Left, 10, XLCellValues.Text);

        //        i++;

        //        openxml_Excel.DrawLeftBorder(i, 1, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 5, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 9, XLBorderStyleValues.Thin, XLColor.DarkGray);

        //        openxml_Excel.AddCellValue("F" + i.ToString(), objOrder.objDespatchToAddress.ContactName + " " + objOrder.objDespatchToAddress.ContactPhone, "Calibri", false, XLAlignmentHorizontalValues.Left, 10, XLCellValues.Text);

        //        i++;
        //        openxml_Excel.DrawLeftBorder(i, 1, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 5, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        openxml_Excel.DrawRightBorder(i, 9, XLBorderStyleValues.Thin, XLColor.DarkGray);

        //        for (int c = 1; c < 10; c++)
        //        {
        //            openxml_Excel.DrawBottomBorder(i, c, XLBorderStyleValues.Thin, XLColor.DarkGray);
        //        }

        //        #endregion

        //        #region Data
        //        #endregion

        //        #region Footer

        //        openxml_Excel.FooterLeft(DateTime.Now.ToLongDateString(), XLHFOccurrence.AllPages);

        //        openxml_Excel.FooterCenter("Page ", XLHFOccurrence.AllPages);
        //        openxml_Excel.FooterCenter(XLHFPredefinedText.PageNumber, XLHFOccurrence.AllPages);
        //        openxml_Excel.FooterCenter(" of ", XLHFOccurrence.AllPages);
        //        openxml_Excel.FooterCenter(XLHFPredefinedText.NumberOfPages, XLHFOccurrence.AllPages);

        //        #endregion

        //        #region Convert To PDF

        //        string tmpfilepath = _filepath.Replace(".pdf", ".xlsx");

        //        openxml_Excel.CloseDocument(tmpfilepath);

        //        CreateExcelDocument excel = new CreateExcelDocument(tmpfilepath);

        //        excel.ConvertToPDF(tmpfilepath.Replace(".xlsx", ".html"));

        //        excel.CloseDocument();

        //        #endregion



        //    }
        //    catch (Exception ex)
        //    {
        //        IndicoLogging.log.Error("Error occured while Generating Back Order Pdf", ex);
        //    }

        //}

        //public static string GenerateBackOrder(DateTime _weekenddate, int _distributor)
        //{
        //    //List<OrderDetailsViewBO> lstOrderDetails = new List<OrderDetailsViewBO>();

        //    string filepath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "Back_Order_" + _weekenddate.ToString("dd MMMM yyyy") + ".pdf";

        //    CreateBackOrderReport(_weekenddate, _distributor, filepath);

        //    return filepath;
        //}

        private static string CreateBackOrder(DateTime _weekenddate, int _distributor)
        {
            string _html = BackOrder;

            try
            {
                List<BackOrderDetail> lstBackOrderDetail = new List<BackOrderDetail>();

                List<OrderDetailBO> lstOrderDetails = (new OrderDetailBO()).SearchObjects().Where(o => o.SheduledDate >= _weekenddate && o.objOrder.Distributor == _distributor).ToList();


                foreach (OrderDetailBO od in lstOrderDetails)
                {
                    BackOrderDetail objBackOrderdetail = new BackOrderDetail();

                    objBackOrderdetail.ShipmentMode = od.objOrder.objShipmentMode.Name;
                    objBackOrderdetail.CompanyName = od.objOrder.objDespatchToAddress.CompanyName;
                    objBackOrderdetail.Address = od.objOrder.objDespatchToAddress.Address;
                    objBackOrderdetail.State = od.objOrder.objDespatchToAddress.Suburb + " , " + od.objOrder.objDespatchToAddress.State;
                    objBackOrderdetail.Country = od.objOrder.objDespatchToAddress.objCountry.ShortName;
                    objBackOrderdetail.ContactName = od.objOrder.objDespatchToAddress.ContactName + " / " + od.objOrder.objDespatchToAddress.ContactPhone;
                    objBackOrderdetail.DistributorPONo = od.objOrder.PurchaseOrderNo.ToString();
                    objBackOrderdetail.OrderNo = "PO " + od.objOrder.ID.ToString();
                    objBackOrderdetail.VisualLayout = od.objVisualLayout.NamePrefix;
                    objBackOrderdetail.PatternNickName = od.objPattern.NickName;
                    objBackOrderdetail.PatternNumber = od.objPattern.Number;
                    objBackOrderdetail.Item = (od.objPattern.SubItem != null && od.objPattern.SubItem > 0) ? od.objPattern.objSubItem.Name : string.Empty;
                    objBackOrderdetail.Qty = (new OrderDetailQtyBO()).GetAllObject().Where(o => o.OrderDetail == od.ID).Sum(o => o.Qty);
                    objBackOrderdetail.Status = "WIP";
                    objBackOrderdetail.Client = od.objOrder.objClient.Name;

                    var daysTillfriday = (int)DayOfWeek.Friday - (int)od.SheduledDate.DayOfWeek;
                    var ETD = od.SheduledDate.AddDays(daysTillfriday);

                    objBackOrderdetail.WeekendDate = ETD;

                    lstBackOrderDetail.Add(objBackOrderdetail);
                }

                IEnumerable<IGrouping<DateTime, BackOrderDetail>> lst = lstBackOrderDetail.OrderBy(o => o.WeekendDate).GroupBy(m => m.WeekendDate).ToList();

                string headerdata = string.Empty;
                string data = string.Empty;
                int totalqty = 0;

                foreach (IGrouping<DateTime, BackOrderDetail> bdlist in lst)
                {
                    IEnumerable<IGrouping<string, BackOrderDetail>> lstAddress = bdlist.GroupBy(m => m.CompanyName).ToList();

                    foreach (IGrouping<string, BackOrderDetail> Address in lstAddress)
                    {
                        //IEnumerable<IGrouping<string, BackOrderDetail>> lstModes = Address.GroupBy(m => m.ShipmentMode).ToList();
                        IEnumerable<IGrouping<string, BackOrderDetail>> lstModes = Address.GroupBy(m => (string)m.ShipmentMode).ToList();

                        foreach (IGrouping<string, BackOrderDetail> Mode in lstModes)
                        {
                            var result = (BackOrderDetail)Mode.ToList()[0];

                            data += "<tr valign=\"middle\" style=\"line-height: 9px;\">" +
                                         "<td>" +
                                         "<table cellpadding=\"3\" cellspacing=\"0\">" +
                                         "<tr align=\"left\" valign=\"middle\">" +
                                         "<td valign=\"top\">" +
                                         "<table border=\"0.5\">" +
                                         "<tr>" +
                                         "<td width=\"60%\" bgcolor=\"#F0E68C\">DEPARTS FACTORY ON " + bdlist.Key.ToLongDateString() + "</td>" +
                                         "<td width=\"40%\" bgcolor=\"#F0E68C\">" + Mode.Key + "</td>" +
                                         "</tr>" +
                                         "<tr>" +
                                         "<td width=\"60%\">Please allow another 1 week for shipment, customs clearance, local delivery. Shipment dates are indicative dates. Subject to change without notice.</td>" +
                                         "<td width=\"40%\">" +
                                         "<table border=\"0\" width=\"100%\">" +
                                         "<tr>" +
                                         "<td style=\"line-height: 5px;\"><b>" + result.CompanyName + "</b></td>" +
                                         "</tr>" +
                                         "<tr>" +
                                         "<td style=\"line-height: 5px;\">" + result.Address + "</td>" +
                                         "</tr>" +
                                         "<tr>" +
                                         "<td style=\"line-height: 5px;\">" + result.State + "</td>" +
                                         "</tr>" +
                                         "<tr>" +
                                         "<td style=\"line-height: 5px;\">" + result.Country + "</td>" +
                                         "</tr>" +
                                         "<tr>" +
                                         "<td style=\"line-height: 5px;\">" + result.ContactName + "</td>" +
                                         "</tr>" +
                                         "</table>" +
                                         "</td>" +
                                         "</tr>" +
                                         "</table>" +
                                         "</td>" +
                                         "</tr>" +
                                         "</table>" +
                                         "</td>" +
                                         "</tr>";

                            /*              _html = _html.Replace("<$WeekEndDate$>", bdlist.Key.ToLongDateString());

                                          _html = _html.Replace("<$ShipmentMode$>", lstOrderDetails[0].objOrder.objShipmentMode.Name);

                                          _html = _html.Replace("<$CompanyName$>", lstOrderDetails[0].objOrder.objDespatchToAddress.CompanyName);

                                          _html = _html.Replace("<$CompanyAddress$>", lstOrderDetails[0].objOrder.objDespatchToAddress.Address);

                                          _html = _html.Replace("<$CompanyState$>", lstOrderDetails[0].objOrder.objDespatchToAddress.Suburb + " , " + lstOrderDetails[0].objOrder.objDespatchToAddress.State);

                                          _html = _html.Replace("<$CompanyCountry$>", lstOrderDetails[0].objOrder.objDespatchToAddress.objCountry.ShortName);

                                          _html = _html.Replace("<$CompanyContact$>", lstOrderDetails[0].objOrder.objDespatchToAddress.ContactName + "  " + lstOrderDetails[0].objOrder.objDespatchToAddress.ContactPhone);
                          */
                            //  data += headerdata;

                            data += "<tr>" +
                                   "<td>" +
                                   "<table cellpadding=\"3\" cellspacing=\"0\">" +
                                   "<tr>" +
                                   "<td>";

                            data += "<table cellpading=\"3\" border=\"0.5\" style=\"font-size:6px;\">";

                            int total = 0;

                            foreach (BackOrderDetail bd in Mode)
                            {
                                data += "<tr>" +
                                        "<td style=\"line-height: 8px;\" width=\"10%\">" + bd.OrderNo + "</td>" +
                                        "<td style=\"line-height: 8px;\" width=\"10%\">" + bd.DistributorPONo + "</td>" +
                                        "<td style=\"line-height: 8px;\" width=\"10%\">" + bd.PatternNumber + "</td>" +
                                        "<td style=\"line-height: 8px;\" width=\"30%\">" + bd.Client + "</td>" +
                                        "<td style=\"line-height: 8px;\" width=\"10%\">" + bd.VisualLayout + "</td>" +
                                        "<td style=\"line-height: 8px;\" width=\"15%\">" + bd.Item + "</td>" +
                                        "<td style=\"line-height: 8px;\" align=\"right\" width=\"5%\">" + bd.Qty.ToString() + "</td>" +
                                        "<td style=\"line-height: 8px;\" width=\"10%\">" + bd.Status + "</td>" +
                                        "</tr>";

                                total = total + bd.Qty;
                            }

                            data += "<tr>" +
                                        "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                                        "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                                        "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                                        "<td border=\"0\" style=\"line-height: 8px;\" width=\"30%\"></td>" +
                                        "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                                        "<td style=\"line-height: 8px;\" width=\"15%\">TOTAL - ORDER</td>" +
                                        "<td style=\"line-height: 8px;\" align=\"right\" width=\"5%\">" + total.ToString() + "</td>" +
                                        "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                                    "</tr>";

                            data += "<tr>" +
                                       "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                                       "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                                       "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                                       "<td align=\"right\" border=\"0\" style=\"line-height: 8px;\" width=\"30%\">TOATL FOR " + bdlist.Key.ToLongDateString() + "</td>" +
                                       "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                                       "<td border=\"0\" style=\"line-height: 8px;\" width=\"15%\"></td>" +
                                       "<td style=\"line-height: 8px;\" align=\"right\" width=\"5%\">" + total.ToString() + "</td>" +
                                       "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                                     "</tr>";

                            data += "</table>";

                            data += "</td>" +
                                    "</tr>" +
                                    "</table>" +
                                    "</td>" +
                                    "</tr>";

                            data += "<tr>" +
                                   "<td style=\"line-height: 20px;\">&nbsp;" +
                                   "</td>" +
                                   "</tr>";

                            totalqty = totalqty + total;
                        }
                    }
                }

                data += "<tr>" +
                        "<td style=\"line-height: 100px;\">&nbsp;" +
                        "</td>" +
                        "</tr>" +
                        "<tr><td><table cellpadding=\"3\" cellspacing=\"0\"><tr><td><table cellspacing=\"0\" cellpading=\"2\" border=\"0.5\" style=\"font-size:6px;\"><tr>" +
                            "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                            "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                            "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                            "<td align=\"right\" border=\"0\" style=\"line-height: 8px;\" width=\"30%\">Grand Total</td>" +
                            "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                            "<td border=\"0\" style=\"line-height: 8px;\" width=\"15%\"></td>" +
                            "<td style=\"line-height: 8px;\" align=\"right\" width=\"5%\">" + totalqty.ToString() + "</td>" +
                            "<td border=\"0\" style=\"line-height: 8px;\" width=\"10%\"></td>" +
                        "</tr></table></td></tr></td></tr></table>";


                _html = _html.Replace("<$tabledata$>", data);
            }
            catch (Exception)
            {

                throw;
            }

            return _html;
        }

        public static string GenerateBackOrder(DateTime _WeekendDate, int _distributor)
        {
            CompanyBO objCompany = new CompanyBO();
            objCompany.ID = _distributor;
            objCompany.GetObject();

            string downloadingpath = IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "Back_Order_" + objCompany.Name + ".pdf";
            string createpdfPath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + downloadingpath;


            File.Delete(createpdfPath);

            try
            {
                Document document = new Document();
                PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(createpdfPath, FileMode.Create));
                document.AddKeywords("paper airplanes");

                float marginBottom = 12;
                float lineHeight = 14;
                float pageMargin = 20;
                float pageHeight = iTextSharp.text.PageSize.A4.Height;
                float pageWidth = iTextSharp.text.PageSize.A4.Width;

                document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                document.SetMargins(0, 0, 0, 0);

                // Open the document for writing content
                document.Open();
                // Get the top layer and write some text
                contentByte = writer.DirectContent;

                contentByte.BeginText();
                string content = string.Empty;

                //Header
                contentByte.SetFontAndSize(PDFFont, 10);
                content = "BACK ORDERS REPORT FOR " + objCompany.Name;
                contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

                contentByte.EndText();
                // Top Line
                contentByte.SetLineWidth(0.5f);
                contentByte.SetColorStroke(BaseColor.BLACK);
                contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                contentByte.Stroke();

                string htmlText = GenerateOdsPdf.CreateBackOrder(_WeekendDate, _distributor);
                HTMLWorker htmlWorker = new HTMLWorker(document);
                htmlWorker.Parse(new StringReader(htmlText));

                document.Close();
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while generating Back Order report", ex);
            }

            return createpdfPath;
        }

        public static string CreateQuoteDetail(QuoteBO objQuote)
        {
            string _html = QuoteDetail;

            try
            {
                string imagePath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/Logo/Blackchrome-Quote-header.png"; //@"C:\Projects\Indico\IndicoData\Logo\Blackchrome-Quote-header.png";

                _html = _html.Replace("<$headerimage$>", "<img src=\"" + imagePath + "\" alt=\"Smiley face\" height=\"" + 842 + "\" width=\"" + 595 + "\" >");

                _html = _html.Replace("<$contactname$>", objQuote.ContactName);

                _html = _html.Replace("<$number$>", objQuote.ID.ToString());

                _html = _html.Replace("<$quotedate$>", objQuote.DateQuoted.ToString("dd MMMM yyyy"));

                _html = _html.Replace("<$contactmail$>", objQuote.ClientEmail);

                List<QuoteDetailBO> lstQuoteDetails = objQuote.QuoteDetailsWhereThisIsQuote.ToList();

                string imagepath = string.Empty;
                string tabledescription = string.Empty;
                decimal designfee = 0;

                foreach (QuoteDetailBO item in lstQuoteDetails)
                {
                    if (item.VisualLayout != null && item.VisualLayout > 0)
                    {
                        IndicoPage objIndicoPage = new IndicoPage();

                        imagepath = IndicoPage.GetVLImagePath((int)item.VisualLayout);

                        if (string.IsNullOrEmpty(imagepath))
                        {
                            imagepath = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                        }
                    }
                    else
                    {
                        imagepath = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    }

                    List<float> lstVLImages = new List<float>();
                    System.Drawing.Image Image = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + imagepath);
                    SizeF VlImage = Image.PhysicalDimension;
                    Image.Dispose();

                    lstVLImages = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(VlImage.Width)), Convert.ToInt32(Math.Abs(VlImage.Height)), 800, 800);

                    string image = "<img src=\"" + IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + imagepath + "\" alt=\"Smiley face\" height=\"" + lstVLImages[0].ToString() + "\" width=\"" + lstVLImages[1].ToString() + "\" >";

                    string sizes = string.Empty;

                    List<SizeBO> lstSizes = item.objPattern.objSizeSet.SizesWhereThisIsSizeSet.Where(o => o.IsDefault == true).ToList();
                    if (lstSizes.Any())
                    {
                        sizes = (lstSizes.Count > 1) ? lstSizes.First().SizeName + " - " + lstSizes.Last().SizeName : lstSizes.First().SizeName;
                    }

                    //foreach (SizeBO size in lstSizes)
                    //{
                    //    sizes += size.SizeName + " , ";
                    //}

                    string uom = (item.Unit != null && item.Unit > 0) ? item.objUnit.Name : string.Empty;

                    //decimal total = ((Convert.ToDecimal(item.IndimanPrice.ToString()) + Convert.ToDecimal(item.GST.ToString())) * item.Qty);
                    decimal total = (item.IndimanPrice ?? 0 + ((item.IndimanPrice ?? 0 / 100) * item.GST ?? 0)) * item.Qty;

                    tabledescription += "<tr>" +
                                             "<td border=\"0\" width=\"60%\">" +
                                             "<table style=\"font-size: 6px;\" border=\"0\">" +
                                             "<tr>" +
                                             "<td width=\"40%\"> " + image +
                                             "</td>" +
                                             "<td width=\"60%\">" +
                                             "<table>" +
                                             "<tr>" +
                                             "<td> " + item.objPattern.objItem.Name.ToUpper() + "</td>" +
                                             "</tr>" +
                                             "<tr>" +
                                             "<td>EXPIRY DATE: " + objQuote.QuoteExpiryDate.ToString("dd MMMM yyyy").ToUpper() + "</td>" +
                                             "</tr>" +
                                             "<tr>" +
                                             "<td>PRICE INCLUDING FULL COLOUR SUBLIMATION: </td>" +
                                             "</tr>" +
                                             "<tr>" +
                                             "<td>PATTERN DESCRIPTION: " + item.objPattern.NickName.ToUpper() + "</td>" +
                                             "</tr>" +
                                             "<tr>" +
                                             "<td>COLOURS: </td>" +
                                             "</tr>" +
                                             "<tr>" +
                                             "<td>SIZES: " + sizes + "</td>" +
                                             "</tr>" +
                                             "</table>" +
                                             "</td>" +
                                             "</tr>" +
                                             "</table>" +
                                             "</td>" +
                                             "<td valign=\"top\" border=\"0\" width=\"8%\"> " + item.Qty.ToString() + "</td>" +
                                             "<td valign=\"top\" border=\"0\" width=\"8%\"> " + uom + "</td>" +
                                             "<td valign=\"top\" border=\"0\" width=\"8%\">$ " + Convert.ToDecimal(item.IndimanPrice.ToString()).ToString("0.00") + "</td>" +
                                             "<td valign=\"top\" border=\"0\" width=\"8%\">$ " + Convert.ToDecimal(item.GST.ToString()).ToString("0.00") + "</td>" +
                                             "<td valign=\"top\" border=\"0\" width=\"8%\">$ " + total.ToString("0.00") + "</td>" +
                                             "</tr>" +
                                             "<tr>" +
                                             "<td colspan=\"6\" border=\"0\" style=\"line-height: 40px; color: #FFFFFF;\"><h1>INDICO</h1>" +
                                             "</td>" +
                                             "</tr>";
                    designfee += (decimal)item.DesignFee;
                    // break;
                }


                tabledescription += "<tr>" +
                                            "<td border=\"0\" style=\"text-align: center;\" width=\"60%\"><h6>Design Fee</h6></td>" +
                                            "<td border=\"0\" width=\"8%\">" + designfee + "</td>" +
                                            "<td border=\"0\" width=\"8%\"></td>" +
                                            "<td border=\"0\" width=\"8%\"></td>" +
                                            "<td border=\"0\" width=\"8%\"></td>" +
                                            "<td border=\"0\" width=\"8%\"></td>" +
                                    "</tr>" +
                                    "<tr>" +
                                             "<td colspan=\"6\" border=\"0\" style=\"line-height: 15px; color: #FFFFFF;\"><h3>INDICO</h3>" +
                                             "</td>" +
                                    "</tr>";

                _html = _html.Replace("<$details$>", tabledescription);
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while creating Quote Detail HTML", ex);
            }

            return _html;
        }

        public static string CreateQuoteDetailAttachments(int _quote)
        {
            QuoteBO objQuote = new QuoteBO();
            objQuote.ID = _quote;
            objQuote.GetObject();

            string downloadingpath = IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "Quote_" + objQuote.ID.ToString() + "_" + DateTime.Now.Millisecond + ".pdf";
            string createpdfPath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + downloadingpath;

            if (File.Exists(createpdfPath))
                File.Delete(createpdfPath);

            try
            {
                Document document = new Document();
                PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(createpdfPath, FileMode.Create));
                document.AddKeywords("paper airplanes");

                float marginBottom = 12;
                float lineHeight = 14;
                float pageMargin = 20;
                float pageHeight = iTextSharp.text.PageSize.A4.Height;
                float pageWidth = iTextSharp.text.PageSize.A4.Width;

                document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                document.SetMargins(0, 0, 0, 0);

                // Open the document for writing content
                document.Open();
                // Get the top layer and write some text
                contentByte = writer.DirectContent;

                //contentByte.BeginText();
                string content = string.Empty;

                //Header
                /*contentByte.SetFontAndSize(PDFFont, 10);
                content = "BACK ORDERS REPORT FOR " 
                contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

                contentByte.EndText();
                // Top Line
                contentByte.SetLineWidth(0.5f);
                contentByte.SetColorStroke(BaseColor.BLACK);
                contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                contentByte.Stroke();*/

                string htmlText = GenerateOdsPdf.CreateQuoteDetail(objQuote);
                HTMLWorker htmlWorker = new HTMLWorker(document);
                htmlWorker.Parse(new StringReader(htmlText));

                htmlWorker.Close();
                htmlWorker.Dispose();
                writer.Close();
                writer.Dispose();
                document.Close();
                document.Dispose();
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while generating Quote Detail report", ex);
            }

            return createpdfPath;
        }

        private static string CreateClientPackingReprortHTML(DateTime WeekendDate, int shipmentmode, int shipmentaddress)
        {
            string packingreport = PackingListReport;

            List<PackingList> PackingLists = new List<PackingList>();
            List<PackingListViewBO> lstPackingLists = new List<PackingListViewBO>();
            lstPackingLists = PackingListBO.GetPackingList(WeekendDate, shipmentmode, shipmentaddress);

            if (lstPackingLists.Count > 0)
            {
                IEnumerable<IGrouping<int?, PackingListViewBO>> lst = lstPackingLists.GroupBy(m => m.ShipTo).ToList();

                string data = string.Empty;

                foreach (IGrouping<int?, PackingListViewBO> pl in lst)
                {
                    DistributorClientAddressBO objDistributorClientAdress = new DistributorClientAddressBO();
                    objDistributorClientAdress.ID = (int)pl.Key;
                    objDistributorClientAdress.GetObject();

                    data += "<table bgcolor=\"#d9edf7\" cellpadding=\"5\"style=\"font-size:6px;background-color: #d9edf7; border-color: #bce8f1; color: #3a87ad\" cellspacing=\"0\" border=\"0\" width=\"30%\" align=\"right\">"
                            + "<tr>"
                            + "<td style=\"line-height:1px;\" width=\"100%\">" + objDistributorClientAdress.CompanyName + "</td>"
                            + "</tr>"
                            + "<tr>"
                            + "<td style=\"line-height:1px;\" width=\"100%\">" + objDistributorClientAdress.Address + "</td>"
                            + "</tr>"
                            + "<tr>"
                            + "<td style=\"line-height:1px;\" width=\"100%\">" + objDistributorClientAdress.Suburb + "</td>"
                            + "</tr>"
                            + "<tr>"
                            + "<td style=\"line-height:1px;\" width=\"100%\">" + objDistributorClientAdress.State + " " + objDistributorClientAdress.PostCode + " , " + objDistributorClientAdress.objCountry.ShortName + "</td>"
                            + "</tr>"
                            + "</table>";

                    IEnumerable<IGrouping<string, PackingListViewBO>> lstModesGroup = pl.GroupBy(o => (string)o.ShipmentMode).ToList();

                    foreach (IGrouping<string, PackingListViewBO> modes in lstModesGroup)
                    {
                        data += "<table cellpadding=\"5\"style=\"font-size:8px;\" cellspacing=\"0\" border=\"0\" width=\"100%\" align=\"right\">"
                         + "<tr>"
                         + "<td style=\"line-height:1px;\" width=\"100%\"><b>" + modes.Key + "</b></td>"
                         + "</tr>"
                         + "</table>";


                        IEnumerable<IGrouping<int, PackingListViewBO>> lstCarton = pl.GroupBy(o => (int)o.CartonNo).ToList();

                        foreach (IGrouping<int, PackingListViewBO> carton in lstCarton)
                        {

                            data += "<table cellpadding=\"5\"style=\"font-size:8px;\" cellspacing=\"0\" border=\"0\" width=\"100%\" align=\"center\">"
                                         + "<tr>"
                                         + "<td colspan=\"7\"> <h5>Carton : " + carton.Key + "</h5></td>"
                                         + "</tr>"
                                         + " <tr>"
                                         + "<th style=\"line-height:8px;\" width=\"5%\"><b>PO No.</b></th>"
                                         + "<th style=\"line-height:8px;\" width=\"12%\"><b>Client</b></th>"
                                         + "<th style=\"line-height:8px;\" width=\"12%\"><b>Distributor</b></th>"
                                         + "<th style=\"line-height:8px;\" width=\"10%\"><b>VL No</b></th>"
                                         + "<th style=\"line-height:8px;\" width=\"20%\"><b>Description</b></th>"
                                         + "<th style=\"line-height:8px;\" width=\"36%\"><b>Size</b></th>"
                                         + "<th style=\"line-height:8px;\" width=\"5%\"><b>Total</b></th>"
                                         + "</tr>";

                            foreach (PackingListViewBO packinglist in carton)
                            {
                                data += "<tr>"
                                       + "<td style=\"line-height:8px;\" width=\"5%\">" + packinglist.OrderNumber.ToString() + "</td>"
                                       + "<td style=\"line-height:8px;\" width=\"12%\">" + packinglist.Client + "</td>"
                                       + "<td style=\"line-height:6px;\" width=\"12%\">" + packinglist.Distributor + "</td>"
                                       + "<td style=\"line-height:8px;\" width=\"10%\">" + packinglist.VLName + "</td>"
                                       + "<td style=\"line-height:8px;\" width=\"20%\">" + packinglist.Pattern + "</td>"
                                       + "<td style=\"line-height:8px;\" width=\"36%\">";

                                PackingListSizeQtyBO objPackSizeQty = new PackingListSizeQtyBO();
                                objPackSizeQty.PackingList = packinglist.PackingList.Value;

                                List<PackingListSizeQtyBO> lstPackListQtys = objPackSizeQty.SearchObjects().Where(m => m.Qty > 0).ToList();

                                //data += "<table cellpadding=\"3\" border=\"0\" width=\"100%\" align=\"center\">"
                                //              + "<tr>";

                                //foreach (PackingListSizeQtyBO plsq in lstPackListQtys)
                                //{

                                //    data += "<td style=\"line-height:4px;\" align=\"center\" width=\"5%\" bgcolor=\"#6495ED\" >" + plsq.objSize.SizeName + "</td>";


                                //}

                                //data += "</tr>"
                                //        + "<tr>";

                                string sizedetails = string.Empty;

                                foreach (PackingListSizeQtyBO plsq in lstPackListQtys)
                                {
                                    // int count = (new PackingListCartonItemBO()).SearchObjects().Where(o => o.PackingList == plsq.PackingList && o.Size == plsq.Size).Count();

                                    //string color = string.Empty;

                                    //if (count == 0)
                                    //{
                                    //    color = "#FFFFFF";
                                    //}
                                    //else if (count == plsq.Qty)
                                    //{
                                    //    color = "#33CC66";
                                    //}
                                    //else if (count > 0)
                                    //{
                                    //    color = "#FFFFCC";
                                    //}
                                    //data += "<td>" + count + " / " + plsq.Qty + "</td> , ";

                                    sizedetails += plsq.Qty + " / " + plsq.objSize.SizeName + " , ";

                                }

                                //data += "</tr>"
                                //          + "</table>"
                                data += sizedetails.Remove(sizedetails.LastIndexOf(",")) + "</td>"
                                    + "<td width=\"5%\">" + packinglist.PackingTotal.Value + "</td>"
                                    + "</tr>";

                            }
                            data += "</table>";
                        }
                    }
                }

                packingreport = packingreport.Replace("<$tabledata$>", data);
            }

            return packingreport;
        }

        public static string GenerateClientPackingListReport(DateTime WeekEndDate, int shipmentmode, int shipmentaddress)
        {
            string packinglistreportpath = string.Empty;

            if (WeekEndDate != null && WeekEndDate != new DateTime(1100, 1, 1))
            {

                try
                {
                    packinglistreportpath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + "Client_Packing_Report_" + WeekEndDate.ToString("dd MMMM yyyy") + ".pdf";

                    if (File.Exists(packinglistreportpath))
                    {
                        File.Delete(packinglistreportpath);
                    }

                    Document document = new Document();
                    PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(packinglistreportpath, FileMode.Create));
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

                    //Header
                    contentByte.SetFontAndSize(PDFFont, 10);
                    content = "Packing List Report - " + WeekEndDate.ToString("dd MMMM yyyy");
                    contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

                    contentByte.EndText();
                    // Top Line
                    contentByte.SetLineWidth(0.5f);
                    contentByte.SetColorStroke(BaseColor.BLACK);
                    contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
                    contentByte.Stroke();

                    string htmlText = GenerateOdsPdf.CreateClientPackingReprortHTML(WeekEndDate, shipmentmode, shipmentaddress);
                    HTMLWorker htmlWorker = new HTMLWorker(document);
                    htmlWorker.Parse(new StringReader(htmlText));

                    document.Close();
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while Generate Pdf PackingListReport in GenerateOdsPdf Class", ex);
                }
            }
            return packinglistreportpath;
        }

        #region Print Order Report

        public static string GeneratePdfOrderReport(int OrderID)
        {
            OrderBO objOrder = new OrderBO();
            objOrder.ID = OrderID;
            objOrder.GetObject();

            string tempLocation = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\";
            string orderReportTempPath = tempLocation + "OrderReport_Temp" + objOrder.ID.ToString() + ".pdf";
            string orderReportPath = tempLocation + "OrderReport_" + objOrder.ID.ToString() + ".pdf";
            string generalDetailsTempPath = tempLocation + "General_Temp_" + objOrder.ID.ToString() + "_" + Guid.NewGuid() + ".pdf";
            string generalDetailsPath = tempLocation + "General_" + objOrder.ID.ToString() + "_" + Guid.NewGuid() + ".pdf";
            string billingDetailsPath = tempLocation + "Billing_" + objOrder.ID.ToString() + "_" + Guid.NewGuid() + ".pdf";
            string tAndCPath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\IndicoTermsAndConditions.pdf";
            List<string> tempOrderDetailPaths = new List<string>();

            Document document = new Document();
            PdfWriter writer;
            PdfReader reader;
            HTMLWorker htmlWorker;

            float pageHeight = iTextSharp.text.PageSize.A4.Height;
            float pageWidth = iTextSharp.text.PageSize.A4.Width;
            string htmlText = string.Empty;

            if (File.Exists(orderReportPath))
            {
                File.Delete(orderReportPath);
            }

            try
            {
                //General details
                writer = PdfWriter.GetInstance(document, new FileStream(generalDetailsTempPath, FileMode.Create));
                document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                document.SetMargins(0, 0, 0, 0);
                document.Open();
                contentByte = writer.DirectContent;
                htmlText = GenerateOdsPdf.CreateHtmlOrderGeneralDetails(objOrder);
                htmlWorker = new HTMLWorker(document);
                htmlWorker.Parse(new StringReader(htmlText));
                document.Close();

                //Adding custom header

                reader = new PdfReader(generalDetailsTempPath);
                iTextSharp.text.Rectangle size = reader.GetPageSizeWithRotation(1);
                document = new Document(size);
                FileStream fs = new FileStream(generalDetailsPath, FileMode.Create, FileAccess.Write);
                writer = PdfWriter.GetInstance(document, fs);
                document.Open();
                BaseFont bFont = BaseFont.CreateFont(IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\fonts\" + "DaxOT-WideBold.otf", BaseFont.CP1250, BaseFont.EMBEDDED);
                PdfContentByte cb = writer.DirectContent;
                cb.SetFontAndSize(bFont, 14);
                cb.BeginText();
                string text = "Order Overview Form";
                cb.ShowTextAligned(1, text, 120, 765, 0);
                cb.EndText();
                PdfImportedPage page = writer.GetImportedPage(reader, 1);
                cb.AddTemplate(page, 0, 0);

                document.Close();
                fs.Close();
                writer.Close();
                reader.Close();

                // Merging

                List<OrderDetailBO> lstDetails = objOrder.OrderDetailsWhereThisIsOrder;
                int resultCount = lstDetails.Count;

                if (resultCount > 1)
                {
                    bool isAppend = ((resultCount % 2 == 0 && resultCount % 4 == 2) || ((resultCount + 1) % 4 == 0));

                    //Dynamially creating pages..
                    List<string> htmlPages = GenerateOdsPdf.CreateOrderDetailExtensionHTMLList(objOrder);
                    int listCount = 1;

                    foreach (string html in htmlPages)
                    {
                        string tempPath = tempLocation + "Order_" + objOrder.ID.ToString() + "_" + Guid.NewGuid() + ".pdf";
                        tempOrderDetailPaths.Add(tempPath);

                        document = new Document();
                        writer = PdfWriter.GetInstance(document, new FileStream(tempPath, FileMode.Create));
                        document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                        document.SetMargins(0, 0, 0, 0);
                        document.Open();
                        contentByte = writer.DirectContent;
                        htmlText = html;

                        if (isAppend && listCount == htmlPages.Count)
                        {
                            htmlText += GenerateOdsPdf.CreateHtmlOrderBillingDetails(objOrder);
                        }

                        htmlWorker = new HTMLWorker(document);
                        htmlWorker.Parse(new StringReader(htmlText));
                        document.Close();
                        ++listCount;
                    }

                    List<string> lstAppendFiles = new List<string>();
                    lstAppendFiles.Add(generalDetailsPath);
                    foreach (string path in tempOrderDetailPaths)
                    {
                        lstAppendFiles.Add(path);
                    }

                    if (!isAppend)
                    {
                        //Billing details
                        document = new Document();
                        writer = PdfWriter.GetInstance(document, new FileStream(billingDetailsPath, FileMode.Create));
                        document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                        document.SetMargins(0, 0, 0, 0);
                        document.Open();
                        contentByte = writer.DirectContent;
                        htmlText = GenerateOdsPdf.CreateHtmlOrderBillingDetails(objOrder);
                        htmlWorker = new HTMLWorker(document);
                        htmlWorker.Parse(new StringReader(htmlText));
                        document.Close();

                        lstAppendFiles.Add(billingDetailsPath);
                    }
                    lstAppendFiles.Add(tAndCPath);

                    GenerateOdsPdf.CombineMultiplePDFs(lstAppendFiles.ToArray(), orderReportTempPath);
                }
                else
                {
                    //Billing details
                    document = new Document();
                    writer = PdfWriter.GetInstance(document, new FileStream(billingDetailsPath, FileMode.Create));
                    document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                    document.SetMargins(0, 0, 0, 0);
                    document.Open();
                    contentByte = writer.DirectContent;
                    htmlText = GenerateOdsPdf.CreateHtmlOrderBillingDetails(objOrder);
                    htmlWorker = new HTMLWorker(document);
                    htmlWorker.Parse(new StringReader(htmlText));
                    document.Close();
                    GenerateOdsPdf.CombineMultiplePDFs(new string[] { generalDetailsPath, billingDetailsPath, tAndCPath }, orderReportTempPath);
                }

                //Deleting temporary files
                if (File.Exists(generalDetailsTempPath))
                {
                    File.Delete(generalDetailsTempPath);
                }

                if (File.Exists(generalDetailsPath))
                {
                    File.Delete(generalDetailsPath);
                }

                foreach (string path in tempOrderDetailPaths)
                {
                    if (File.Exists(path))
                    {
                        File.Delete(path);
                    }
                }

                if (File.Exists(billingDetailsPath))
                {
                    File.Delete(billingDetailsPath);
                }

                //Page numbering                
                byte[] bytes = File.ReadAllBytes(orderReportTempPath);
                iTextSharp.text.Font blackFont = FontFactory.GetFont("Arial", 12, iTextSharp.text.Font.NORMAL, BaseColor.BLACK);
                using (MemoryStream stream = new MemoryStream())
                {
                    reader = new PdfReader(bytes);
                    using (PdfStamper stamper = new PdfStamper(reader, stream))
                    {
                        int pages = reader.NumberOfPages;
                        for (int i = 1; i <= pages; i++)
                        {
                            ColumnText.ShowTextAligned(stamper.GetUnderContent(i), Element.ALIGN_CENTER, new Phrase(/*"PO-" + OrderID + " " +*/ i.ToString() + "/" + pages, blackFont), 300f, 15f, 0);
                        }
                    }
                    bytes = stream.ToArray();
                    reader.Close();
                }
                File.WriteAllBytes(orderReportPath, bytes);

                if (File.Exists(orderReportTempPath))
                {
                    File.Delete(orderReportTempPath);
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Generate Pdf DistributorPO in GenerateOdsPdf Class", ex);
            }
            finally
            {
                document.Close();
            }

            return orderReportPath;
        }

        public static string GeneratePdfOrderReportForOffice(int orderId)
        {
            var objOrder = new OrderBO { ID = orderId };
            if (!objOrder.GetObject())
                return "";

            var tempLocation = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\";
            var orderReportTempPath = tempLocation + "OrderReport_office_Temp" + objOrder.ID + ".pdf";
            var orderReportPath = tempLocation + "OrderReport_office_" + objOrder.ID + ".pdf";
            var generalDetailsTempPath = tempLocation + "General_office_Temp_" + objOrder.ID + "_" + Guid.NewGuid() + ".pdf";
            var generalDetailsPath = tempLocation + "General_office" + objOrder.ID + "_" + Guid.NewGuid() + ".pdf";
            var billingDetailsPath = tempLocation + "Billing_office" + objOrder.ID + "_" + Guid.NewGuid() + ".pdf";
            var tAndCPath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "\\IndicoTermsAndConditions.pdf";
            var tempOrderDetailPaths = new List<string>();
            var document = new Document();

            var pageHeight = PageSize.A4.Height;
            var pageWidth = PageSize.A4.Width;

            if (File.Exists(orderReportPath))
                File.Delete(orderReportPath);

            //try
            //{
            //General details
            var writer = PdfWriter.GetInstance(document, new FileStream(generalDetailsTempPath, FileMode.Create));
            document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
            document.SetMargins(0, 0, 0, 0);
            document.Open();
            contentByte = writer.DirectContent;
            var htmlText = CreateHtmlOrderGeneralDetails(objOrder, true);
            var htmlWorker = new HTMLWorker(document);
            htmlWorker.Parse(new StringReader(htmlText));
            document.Close();

            //Adding custom header

            var reader = new PdfReader(generalDetailsTempPath);
            iTextSharp.text.Rectangle size = reader.GetPageSizeWithRotation(1);
            document = new Document(size);
            FileStream fs = new FileStream(generalDetailsPath, FileMode.Create, FileAccess.Write);
            writer = PdfWriter.GetInstance(document, fs);
            document.Open();
            BaseFont bFont = BaseFont.CreateFont(IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\fonts\" + "DaxOT-WideBold.otf", BaseFont.CP1250, BaseFont.EMBEDDED);
            PdfContentByte cb = writer.DirectContent;
            cb.SetFontAndSize(bFont, 14);
            cb.BeginText();
            string text = "Order Overview Form for Office purpose only";
            cb.ShowTextAligned(1, text, 120, 765, 0);
            cb.EndText();
            PdfImportedPage page = writer.GetImportedPage(reader, 1);
            cb.AddTemplate(page, 0, 0);

            document.Close();
            fs.Close();
            writer.Close();
            reader.Close();

            // Merging

            List<OrderDetailBO> lstDetails = objOrder.OrderDetailsWhereThisIsOrder;
            int resultCount = lstDetails.Count;

            if (resultCount > 1)
            {
                bool isAppend = ((resultCount % 2 == 0 && resultCount % 4 == 2) || ((resultCount + 1) % 4 == 0));

                //Dynamially creating pages..
                List<string> htmlPages = GenerateOdsPdf.CreateOrderDetailExtensionHTMLList(objOrder);
                int listCount = 1;

                foreach (string html in htmlPages)
                {
                    string tempPath = tempLocation + "Order_" + objOrder.ID + "_" + Guid.NewGuid() + ".pdf";
                    tempOrderDetailPaths.Add(tempPath);

                    document = new Document();
                    writer = PdfWriter.GetInstance(document, new FileStream(tempPath, FileMode.Create));
                    document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                    document.SetMargins(0, 0, 0, 0);
                    document.Open();
                    contentByte = writer.DirectContent;
                    htmlText = html;

                    if (isAppend && listCount == htmlPages.Count)
                    {
                        htmlText += GenerateOdsPdf.CreateHtmlOrderBillingDetails(objOrder);
                    }

                    htmlWorker = new HTMLWorker(document);
                    htmlWorker.Parse(new StringReader(htmlText));
                    document.Close();
                    ++listCount;
                }

                List<string> lstAppendFiles = new List<string>();
                lstAppendFiles.Add(generalDetailsPath);
                foreach (string path in tempOrderDetailPaths)
                {
                    lstAppendFiles.Add(path);
                }

                if (!isAppend)
                {
                    //Billing details
                    document = new Document();
                    writer = PdfWriter.GetInstance(document, new FileStream(billingDetailsPath, FileMode.Create));
                    document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                    document.SetMargins(0, 0, 0, 0);
                    document.Open();
                    contentByte = writer.DirectContent;
                    htmlText = GenerateOdsPdf.CreateHtmlOrderBillingDetails(objOrder);
                    htmlWorker = new HTMLWorker(document);
                    htmlWorker.Parse(new StringReader(htmlText));
                    document.Close();

                    lstAppendFiles.Add(billingDetailsPath);
                }
                lstAppendFiles.Add(tAndCPath);

                GenerateOdsPdf.CombineMultiplePDFs(lstAppendFiles.ToArray(), orderReportTempPath);
            }
            else
            {
                //Billing details
                document = new Document();
                writer = PdfWriter.GetInstance(document, new FileStream(billingDetailsPath, FileMode.Create));
                document.SetPageSize(new iTextSharp.text.Rectangle(pageWidth, pageHeight));
                document.SetMargins(0, 0, 0, 0);
                document.Open();
                contentByte = writer.DirectContent;
                htmlText = GenerateOdsPdf.CreateHtmlOrderBillingDetails(objOrder);
                htmlWorker = new HTMLWorker(document);
                htmlWorker.Parse(new StringReader(htmlText));
                document.Close();
                GenerateOdsPdf.CombineMultiplePDFs(new string[] { generalDetailsPath, billingDetailsPath, tAndCPath }, orderReportTempPath);
            }

            //Deleting temporary files
            if (File.Exists(generalDetailsTempPath))
            {
                File.Delete(generalDetailsTempPath);
            }

            if (File.Exists(generalDetailsPath))
            {
                File.Delete(generalDetailsPath);
            }

            foreach (string path in tempOrderDetailPaths)
            {
                if (File.Exists(path))
                {
                    File.Delete(path);
                }
            }

            if (File.Exists(billingDetailsPath))
            {
                File.Delete(billingDetailsPath);
            }

            //Page numbering                
            byte[] bytes = File.ReadAllBytes(orderReportTempPath);
            iTextSharp.text.Font blackFont = FontFactory.GetFont("Arial", 12, iTextSharp.text.Font.NORMAL, BaseColor.BLACK);
            using (MemoryStream stream = new MemoryStream())
            {
                reader = new PdfReader(bytes);
                using (PdfStamper stamper = new PdfStamper(reader, stream))
                {
                    int pages = reader.NumberOfPages;
                    for (int i = 1; i <= pages; i++)
                    {
                        ColumnText.ShowTextAligned(stamper.GetUnderContent(i), Element.ALIGN_CENTER, new Phrase(/*"PO-" + OrderID + " " +*/ i.ToString() + "/" + pages, blackFont), 300f, 15f, 0);
                    }
                }
                bytes = stream.ToArray();
                reader.Close();
            }
            File.WriteAllBytes(orderReportPath, bytes);

            if (File.Exists(orderReportTempPath))
            {
                File.Delete(orderReportTempPath);
            }
            //}
            //catch (Exception ex)
            //{
            //    IndicoLogging.log.Error("Error occured while Generate Pdf DistributorPO in GenerateOdsPdf Class", ex);
            //}
            //finally
            //{
            //    document.Close();
            //}

            return orderReportPath;
        }

        public static PdfPTable GetHeaderTable(int x, int y)
        {
            PdfPTable table = new PdfPTable(2);
            table.TotalWidth = 527;
            table.LockedWidth = true;
            table.DefaultCell.FixedHeight = 20;
            // table.DefaultCell.Border = Rectangle.BOTTOM_BORDER;
            table.AddCell("FOOBAR FILMFESTIVAL");
            table.DefaultCell.HorizontalAlignment = Element.ALIGN_RIGHT;
            table.AddCell(string.Format("Page {0} of {1}", x, y));
            return table;
        }

        private static string CreateHtmlOrderGeneralDetails(OrderBO objOrder, bool forOffice = false)
        {
            var builder = new StringBuilder(forOffice ? OrderGeneralDetailsForOfficeTemplate : OrderGeneralDetailsTemplate);
            var imagePath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/Logo/blackchrome2015.png";
            var emptyString = string.Empty;
            var lstDetails = objOrder.OrderDetailsWhereThisIsOrder.ToList();

            builder.Replace("<$headerimage$>", "<img src=\"" + imagePath + "\" alt=\"Smiley face\" height=\"" + 176 + "\" width=\"" + 595 + "\" >")
                .Replace("<$orderdate$>", objOrder.Date.ToLongDateString().ToUpper())
                .Replace("<$myobcardfile$>", lstDetails.First().objVisualLayout.objClient.objClient.objDistributor.Name)
                .Replace("<$distributororderno$>", (objOrder.PurchaseOrderNo != null) ? objOrder.PurchaseOrderNo.ToUpper() : string.Empty)
                .Replace("<$orderdate$>", objOrder.Date.ToLongDateString())
                .Replace("<$Client$>", lstDetails.First().objVisualLayout.objClient.objClient.Name.ToUpper())
                .Replace("<$jobname$>", lstDetails.First().objVisualLayout.objClient.Name.ToUpper());

            //Billing Info
            if (objOrder.BillingAddress.HasValue && objOrder.BillingAddress > 0)
            {
                builder.Replace("<$billingcompanyname$>", objOrder.objBillingAddress.CompanyName.ToUpper())
                    .Replace("<$shiptoaddresstype$>", ((objOrder.objBillingAddress.AddressType ?? 1) == 1) ? "RESIDENTIAL" : "BUSINESS")
                    .Replace("<$billingaddress$>", objOrder.objBillingAddress.Address.ToUpper())
                    .Replace("<$billingsuberb$>", objOrder.objBillingAddress.Suburb.ToUpper())
                    .Replace("<$billingpostcode$>", objOrder.objBillingAddress.PostCode.ToUpper())
                    .Replace("<$billingstate$>", objOrder.objBillingAddress.State.ToUpper())
                    .Replace("<$billingcountry$>", objOrder.objBillingAddress.objCountry.ShortName.ToUpper())
                    .Replace("<$billingcontactName$>", objOrder.objBillingAddress.ContactName.ToUpper())
                    .Replace("<$billingphone$>", objOrder.objBillingAddress.ContactPhone.ToUpper())
                    .Replace("<$billingemail$>", objOrder.objBillingAddress.EmailAddress)
                    .Replace("<$client$>", (objOrder.Client > 0) ? objOrder.objClient.Name.ToUpper() : string.Empty);
            }
            else
            {
                builder.Replace("<$billingcompanyname$>", emptyString)
                    .Replace("<$shiptoaddresstype$>", emptyString)
                    .Replace("<$billingaddress$>", emptyString)
                    .Replace("<$billingsuberb$>", emptyString)
                    .Replace("<$billingpostcode$>", emptyString)
                    .Replace("<$billingstate$>", emptyString)
                    .Replace("<$billingcountry$>", emptyString)
                    .Replace("<$billingcontactName$>", emptyString)
                    .Replace("<$billingphone$>", emptyString)
                    .Replace("<$billingemail$>", emptyString)
                    .Replace("<$client$>", (objOrder.Client > 0) ? objOrder.objClient.Name.ToUpper() : string.Empty);
            }
            //<$despatchmode$>

            //Dispatch Info
            if (objOrder.DespatchToAddress.HasValue && objOrder.DespatchToAddress > 0)
            {
                builder.Replace("<$shiptocompanyname$>", objOrder.objDespatchToAddress.CompanyName.ToUpper())
                    .Replace("<$shiptoaddresstype$>", ((objOrder.objDespatchToAddress.AddressType ?? 1) == 1) ? "RESIDENTIAL" : "BUSINESS")
                    .Replace("<$shiptoaddress$>", objOrder.objDespatchToAddress.Address.ToUpper())
                    .Replace("<$shiptosuburb$>", objOrder.objDespatchToAddress.Suburb.ToUpper())
                    .Replace("<$shiptopostcode$>", objOrder.objDespatchToAddress.PostCode.ToUpper())
                    .Replace("<$shiptostate$>", objOrder.objDespatchToAddress.State.ToUpper())
                    .Replace("<$shiptocountry$>", objOrder.objDespatchToAddress.objCountry.ShortName.ToUpper())
                    .Replace("<$shiptocontact$>", objOrder.objDespatchToAddress.ContactName.ToUpper())
                    .Replace("<$shiptophone$>", objOrder.objDespatchToAddress.ContactPhone.ToUpper())
                    .Replace("<$shiptoemail$>", objOrder.objDespatchToAddress.EmailAddress);
            }
            else
            {
                builder.Replace("<$shiptocompanyname$>", emptyString)
                    .Replace("<$shiptoaddresstype$>", emptyString)
                    .Replace("<$shiptoaddress$>", emptyString)
                    .Replace("<$shiptosuburb$>", emptyString)
                    .Replace("<$shiptopostcode$>", emptyString)
                    .Replace("<$shiptostate$>", emptyString)
                    .Replace("<$shiptocountry$>", emptyString)
                    .Replace("<$shiptocontact$>", emptyString)
                    .Replace("<$shiptophone$>", emptyString)
                    .Replace("<$shiptoemail$>", emptyString);
            }

            builder.Replace("<$factorymasterpo$>", objOrder.ID.ToString())
            .Replace("<$daterequire$>", (objOrder.EstimatedCompletionDate != new DateTime(1100, 1, 1) ?
                Convert.ToDateTime(objOrder.EstimatedCompletionDate.ToString()).ToLongDateString().ToUpper() : string.Empty))
            .Replace("<$datenegotiable$>", objOrder.IsDateNegotiable ? "YES" : "NO")
                .Replace("<$despatchmode$>", (objOrder.DeliveryOption.HasValue && objOrder.DeliveryOption > 0) ? objOrder.objDeliveryOption.Name.ToUpper() : string.Empty)
                .Replace("<$shipmentterm$>", (objOrder.PaymentMethod.HasValue && objOrder.PaymentMethod > 0) ? objOrder.objPaymentMethod.Name.ToUpper() : string.Empty)
                .Replace("<$ordernotes$>", (string.IsNullOrEmpty(objOrder.Notes)) ? string.Empty : objOrder.Notes.ToUpper());

            if (forOffice)
            {
                var ods = objOrder.OrderDetailsWhereThisIsOrder;
                if (ods != null && ods.Count > 0)
                    builder.Replace("<$despatchfromfactory$>", ods.First().ShipmentDate.ToLongDateString().ToUpper());
                var ord = ods.FirstOrDefault(od => od.ShipmentMode.HasValue && od.ShipmentMode != 0);
                if (ord != null)
                {
                    if (ord.objShipmentMode != null)
                        builder.Replace("<$factorydespatchmode$>", ord.objShipmentMode.Name.ToUpper());
                }
            }
            var orderDetailsHtml = new StringBuilder();
            for (var i = 0; i < 1; i++)
            {
                if (i < lstDetails.Count)
                    orderDetailsHtml.Append(CreateOrderDetailHTML(lstDetails[i], i + 1, forOffice));
            }
            builder.Replace("<$orderdetail$>", orderDetailsHtml.ToString());
            return builder.ToString();


            //string generalDetailsHtml = OrderGeneralDetailsTemplate;
            //string imagePath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/Logo/blackchrome2015.png"; //@"C:\Projects\Indico\IndicoData\Logo\blackcrome_Order.png";
            //string orderDetailsHtml = string.Empty;
            //string emptyString = string.Empty;
            //List<OrderDetailBO> lstDetails = objOrder.OrderDetailsWhereThisIsOrder.ToList();

            //generalDetailsHtml = generalDetailsHtml.Replace("<$headerimage$>", "<img src=\"" + imagePath + "\" alt=\"Smiley face\" height=\"" + 176 + "\" width=\"" + 595 + "\" >");

            //generalDetailsHtml = generalDetailsHtml.Replace("<$orderdate$>", objOrder.Date.ToLongDateString().ToUpper());
            ////generalDetailsHtml = generalDetailsHtml.Replace("<$myobcardfile$>", (objOrder.MYOBCardFile.HasValue && objOrder.MYOBCardFile > 0) ? objOrder.objMYOBCardFile.Name.ToUpper() : string.Empty);
            //generalDetailsHtml = generalDetailsHtml.Replace("<$myobcardfile$>", lstDetails.First().objVisualLayout.objClient.objClient.objDistributor.Name);
            //generalDetailsHtml = generalDetailsHtml.Replace("<$distributororderno$>", (objOrder.PurchaseOrderNo != null) ? objOrder.PurchaseOrderNo.ToString().ToUpper() : string.Empty);
            //generalDetailsHtml = generalDetailsHtml.Replace("<$orderdate$>", objOrder.Date.ToLongDateString());
            ////generalDetailsHtml = generalDetailsHtml.Replace("<$Client$>", objOrder.objClient.objClient.Name.ToUpper());
            ////generalDetailsHtml = generalDetailsHtml.Replace("<$jobname$>", objOrder.objClient.Name.ToUpper());
            //generalDetailsHtml = generalDetailsHtml.Replace("<$Client$>", lstDetails.First().objVisualLayout.objClient.objClient.Name.ToUpper());
            //generalDetailsHtml = generalDetailsHtml.Replace("<$jobname$>", lstDetails.First().objVisualLayout.objClient.Name.ToUpper());

            ////Billing Info
            //if (objOrder.BillingAddress.HasValue && objOrder.BillingAddress > 0)
            //{
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingcompanyname$>", objOrder.objBillingAddress.CompanyName.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptoaddresstype$>", ((objOrder.objBillingAddress.AddressType ?? 1) == 1) ? "RESIDENTIAL" : "BUSINESS");
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingaddress$>", objOrder.objBillingAddress.Address.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingsuberb$>", objOrder.objBillingAddress.Suburb.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingpostcode$>", objOrder.objBillingAddress.PostCode.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingstate$>", objOrder.objBillingAddress.State.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingcountry$>", objOrder.objBillingAddress.objCountry.ShortName.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingcontactName$>", objOrder.objBillingAddress.ContactName.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingphone$>", objOrder.objBillingAddress.ContactPhone.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingemail$>", objOrder.objBillingAddress.EmailAddress);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$client$>", (objOrder.Client > 0) ? objOrder.objClient.Name.ToUpper() : string.Empty);
            //}
            //else
            //{
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingcompanyname$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptoaddresstype$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingaddress$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingsuberb$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingpostcode$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingstate$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingcountry$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingcontactName$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingphone$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$billingemail$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$client$>", (objOrder.Client > 0) ? objOrder.objClient.Name.ToUpper() : string.Empty);
            //}

            ////Despatch Info
            //if (objOrder.DespatchToAddress.HasValue && objOrder.DespatchToAddress > 0)
            //{
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptocompanyname$>", objOrder.objDespatchToAddress.CompanyName.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptoaddresstype$>", ((objOrder.objDespatchToAddress.AddressType ?? 1) == 1) ? "RESIDENTIAL" : "BUSINESS");
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptoaddress$>", objOrder.objDespatchToAddress.Address.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptosuburb$>", objOrder.objDespatchToAddress.Suburb.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptopostcode$>", objOrder.objDespatchToAddress.PostCode.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptostate$>", objOrder.objDespatchToAddress.State.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptocountry$>", objOrder.objDespatchToAddress.objCountry.ShortName.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptocontact$>", objOrder.objDespatchToAddress.ContactName.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptophone$>", objOrder.objDespatchToAddress.ContactPhone.ToUpper());
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptoemail$>", objOrder.objDespatchToAddress.EmailAddress);

            //    //generalDetailsHtml = generalDetailsHtml.Replace("< $shipmentport$>",
            //    //    ((objOrder.objDespatchToAddress.Port.HasValue && objOrder.objDespatchToAddress.Port.Value > 0) ? objOrder.objDespatchToAddress.objPort.Name.ToUpper() : string.Empty));
            //}
            //else
            //{
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptocompanyname$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptoaddresstype$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptoaddress$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptosuburb$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptopostcode$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptostate$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptocountry$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptocontact$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptophone$>", emptyString);
            //    generalDetailsHtml = generalDetailsHtml.Replace("<$shiptoemail$>", emptyString);
            //}

            //generalDetailsHtml = generalDetailsHtml.Replace("<$factorymasterpo$>", objOrder.ID.ToString()); //(!string.IsNullOrEmpty(objOrder.OldPONo.ToString())) ? objOrder.OldPONo.ToString().ToUpper() : objOrder.ID.ToString());
            //generalDetailsHtml = generalDetailsHtml.Replace("<$daterequire$>", (objOrder.EstimatedCompletionDate != new DateTime(1100, 1, 1) ?
            //    Convert.ToDateTime(objOrder.EstimatedCompletionDate.ToString()).ToLongDateString().ToUpper() : string.Empty));

            ////  generalDetailsHtml = generalDetailsHtml.Replace("<$label$>", (objOrder.Label.HasValue && objOrder.Label > 0) ? objOrder.objLabel.Name.ToUpper() : string.Empty);
            //generalDetailsHtml = generalDetailsHtml.Replace("<$datenegotiable$>", objOrder.IsDateNegotiable ? "YES" : "NO");
            ////generalDetailsHtml = generalDetailsHtml.Replace("<$shipmentmode$>", objOrder.objShipmentMode.Name.ToUpper());
            ////generalDetailsHtml = generalDetailsHtml.Replace("<$shipmentdate$>", (objOrder.ShipmentDate != null && objOrder.ShipmentDate != new DateTime(1100, 1, 1) ?
            ////Convert.ToDateTime(objOrder.ShipmentDate.ToString()).ToLongDateString().ToUpper() : string.Empty));

            //generalDetailsHtml = generalDetailsHtml.Replace("<$despatchmode$>", (objOrder.DeliveryOption.HasValue && objOrder.DeliveryOption > 0) ? objOrder.objDeliveryOption.Name.ToUpper() : string.Empty);

            //generalDetailsHtml = generalDetailsHtml.Replace("<$shipmentterm$>", (objOrder.PaymentMethod.HasValue && objOrder.PaymentMethod > 0) ? objOrder.objPaymentMethod.Name.ToUpper() : string.Empty);
            //generalDetailsHtml = generalDetailsHtml.Replace("<$ordernotes$>", (string.IsNullOrEmpty(objOrder.Notes)) ? string.Empty : objOrder.Notes.ToUpper());

            //for (int i = 0; i < 1; i++)
            //{
            //    if (i < lstDetails.Count)
            //    {
            //        orderDetailsHtml += GenerateOdsPdf.CreateOrderDetailHTML(lstDetails[i], i + 1);
            //    }
            //}

            //generalDetailsHtml = generalDetailsHtml.Replace("<$orderdetail$>", orderDetailsHtml);

            //return generalDetailsHtml;
        }


        private static string CreateHtmlOrderBillingDetails(OrderBO objOrder)
        {
            string billingDetailsHtml = OrderBillingDetailsTemplate;
            decimal grandvalue = 0;
            int sumOfQuantities = 0;

            List<OrderDetailsView> lstOrderDetails = new List<OrderDetailsView>();
            // lstOrderDetails = OrderBO.GetOrderDetails(objOrder.ID, (objOrder.PaymentMethod != null && objOrder.PaymentMethod > 0) ? (objOrder.PaymentMethod == 1) ? 1 : 2 : 1);

            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Open();

                lstOrderDetails = connection.Query<OrderDetailsView>(" EXEC	[dbo].[SPC_GetOrderDetailIndicoPrice] " +
                                                                        "@P_Order = '" + objOrder.ID + "'").ToList();

                connection.Close();
            }

            foreach (OrderDetailsView orderdetail in lstOrderDetails)
            {
                decimal totalvalue = 0;
                totalvalue = Convert.ToDecimal((Convert.ToDecimal(orderdetail.DistributorEditedPrice * (1 + orderdetail.DistributorSurcharge / 100)) * orderdetail.Quantity));
                grandvalue = grandvalue + totalvalue;
                sumOfQuantities += (int)orderdetail.Quantity;
            }

            decimal deliveryCharge, artWorkCharge, additionalCharge, totalCost, gstAmount, grandTotal;
            deliveryCharge = objOrder.DeliveryCharges ?? 0;
            artWorkCharge = objOrder.ArtWorkCharges ?? 0;
            additionalCharge = objOrder.OtherCharges ?? 0;
            totalCost = grandvalue + deliveryCharge + artWorkCharge + additionalCharge;
            gstAmount = objOrder.IsGSTExcluded ? 0 : ((totalCost / 100) * 10);
            grandTotal = totalCost + gstAmount;

            billingDetailsHtml = billingDetailsHtml.Replace("<$factorymasterpo$>", objOrder.ID.ToString()); //(!string.IsNullOrEmpty(objOrder.OldPONo.ToString())) ? objOrder.OldPONo.ToString().ToUpper() : objOrder.ID.ToString());          
            billingDetailsHtml = billingDetailsHtml.Replace("<$totalorderquantity$>", sumOfQuantities.ToString());
            billingDetailsHtml = billingDetailsHtml.Replace("<$totalvalue$>", "$" + grandvalue.ToString("0,0.00"));
            billingDetailsHtml = billingDetailsHtml.Replace("<$deliverycharges$>", "$" + deliveryCharge.ToString("0,0.00"));
            billingDetailsHtml = billingDetailsHtml.Replace("<$artworkcharges$>", "$" + artWorkCharge.ToString("0,0.00"));
            billingDetailsHtml = billingDetailsHtml.Replace("<$othercharges$>", "$" + additionalCharge.ToString("0,0.00"));
            billingDetailsHtml = billingDetailsHtml.Replace("<$description$>", (string.IsNullOrEmpty(objOrder.OtherChargesDescription) ? string.Empty : objOrder.OtherChargesDescription.ToUpper()));
            billingDetailsHtml = billingDetailsHtml.Replace("<$totalcost$>", "$" + totalCost.ToString("0,0.00"));
            billingDetailsHtml = billingDetailsHtml.Replace("<$gst$>", "$" + gstAmount.ToString("0,0.00"));
            billingDetailsHtml = billingDetailsHtml.Replace("<$totalindludinggst$>", "$" + grandTotal.ToString("0,0.00"));
            billingDetailsHtml = billingDetailsHtml.Replace("<$createdBy$>", ((objOrder.objCreator.IsDirectSalesPerson) ? "BLACKCHROME -" : string.Empty) + objOrder.objCreator.GivenName.ToUpper() + " " + objOrder.objCreator.FamilyName.ToUpper());

            return billingDetailsHtml;
        }

        private static string CreateOrderDetailHTML(OrderDetailBO objOrderDetail, int subPO, bool forOffice = false)
        {

            //TODO make more clear
            string orderDetailHtml = (forOffice ? OrderOrderDetailsForOfficeTemplate : OrderOrderDetailsTemplate);
            string order = "PO - " + objOrderDetail.Order.ToString();
            string qtyHeader = string.Empty;
            string qtyValues = string.Empty;
            string productNumber = string.Empty;
            string pockets = string.Empty;
            string vlImagePath = string.Empty;
            int Qty = 0;
            decimal totalvalue = 0;
            decimal surchargePrice = 0;
            string bgColor = "bgcolor=#EEE8AA";
            decimal price = (objOrderDetail.EditedPrice.HasValue) ? Convert.ToDecimal(objOrderDetail.EditedPrice) : 0;
            string patternDesc = string.Empty;

            if (objOrderDetail.VisualLayout.HasValue && objOrderDetail.VisualLayout > 0)
            {
                productNumber = objOrderDetail.objVisualLayout.NamePrefix;
                pockets = (((objOrderDetail.objVisualLayout.PocketType ?? 0) > 0) ? objOrderDetail.objVisualLayout.objPocketType.Name : string.Empty);
                vlImagePath = IndicoPage.GetVLImagePath(objOrderDetail.VisualLayout);

                patternDesc = objOrderDetail.objVisualLayout.objPattern.Number.ToUpper() + "-" + objOrderDetail.objVisualLayout.objPattern.NickName.ToUpper() + "-" + objOrderDetail.objVisualLayout.objFabricCode.Name.ToUpper();
            }
            //else if (objOrderDetail.ArtWork.HasValue && objOrderDetail.ArtWork > 0)
            //{
            //    productNumber = objOrderDetail.objArtWork.ReferenceNo;
            //    pockets = (((objOrderDetail.objArtWork.PocketType ?? 0) > 0) ? objOrderDetail.objArtWork.objPocketType.Name : string.Empty);
            //}
            else
            {
                patternDesc = objOrderDetail.objPattern.Number.ToUpper() + " - " + objOrderDetail.objPattern.NickName.ToUpper() + " - " + objOrderDetail.objFabricCode.Name.ToUpper();
            }

            orderDetailHtml = orderDetailHtml.Replace("<$factorysubpo$>", order.ToUpper() + "-" + subPO);
            orderDetailHtml = orderDetailHtml.Replace("<$ordertype$>", objOrderDetail.objOrderType.Name.ToUpper());
            orderDetailHtml = orderDetailHtml.Replace("<$productnumber$>", productNumber.ToUpper());
            orderDetailHtml = orderDetailHtml.Replace("<$brandingkit$>", objOrderDetail.IsBrandingKit ? "YES" : "NO");
            orderDetailHtml = orderDetailHtml.Replace("<$lockerpatch$>", objOrderDetail.IsLockerPatch ? "YES" : "NO");
            //orderDetailHtml = orderDetailHtml.Replace("<$embroidery$>", string.Empty);
            orderDetailHtml = orderDetailHtml.Replace("<$label$>", (objOrderDetail.Label.HasValue && objOrderDetail.Label > 0) ? objOrderDetail.objLabel.Name : string.Empty);
            orderDetailHtml = orderDetailHtml.Replace("<$pockets$>", pockets.ToUpper());
            orderDetailHtml = orderDetailHtml.Replace("<$namesandnumbers$>", ((objOrderDetail.IsRequiredNamesNumbers ?? false) ? "YES" : "NO"));
            orderDetailHtml = orderDetailHtml.Replace("<$notes$>", (string.IsNullOrEmpty(objOrderDetail.VisualLayoutNotes) ? string.Empty : objOrderDetail.VisualLayoutNotes).ToUpper());
            if (forOffice)
                orderDetailHtml = orderDetailHtml.Replace("<$pricecomments$>", objOrderDetail.EditedPriceRemarks ?? "");

            orderDetailHtml = orderDetailHtml.Replace("<$patterndesc$>", patternDesc);

            vlImagePath = string.IsNullOrEmpty(vlImagePath) ? (IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png") : vlImagePath;
            vlImagePath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + vlImagePath;
            orderDetailHtml = orderDetailHtml.Replace("<$vlimage$>", "<img src=\"" + vlImagePath + "\" alt=\"Smiley face\" height=\"" + 110 + "\" width=\"" + IndicoPage.GetResizedImageDimensionForHeight(vlImagePath, 110) + "\"  >");

            OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
            objOrderDetailQty.OrderDetail = objOrderDetail.ID;
            List<OrderDetailQtyBO> lstQtys = objOrderDetailQty.SearchObjects();

            foreach (OrderDetailQtyBO orderQty in lstQtys)
            {
                Qty = Qty + orderQty.Qty;
                qtyHeader += "<td width=\"15\" style=\"text-align:center; \">" + orderQty.objSize.SizeName.ToUpper() + "</td>";
                qtyValues += "<td " + ((orderQty.Qty > 0) ? bgColor : string.Empty) + " width=\"15\" style=\"text-align:center; \">" + orderQty.Qty.ToString() + "</td>";
            }

            totalvalue = (price * (1 + (objOrderDetail.DistributorSurcharge ?? 0) / (decimal)100)) * Qty;
            surchargePrice = price * (1 + (objOrderDetail.DistributorSurcharge ?? 0) / (decimal)100);

            qtyHeader += "<td width=\"15\" style=\"text-align:center; \">Total</td>" +
                                "<td width=\"20\" style=\"text-align:center; \">Price</td>" +
                                "<td width=\"20\" style=\"text-align:center; \">Surcharge/Discount %</td>" +
                                "<td width=\"20\" style=\"text-align:center; \">Final Price</td>" +
                                " <td width=\"20\" style=\"text-align:center; \">Total Value</td>" +
                               "</tr>";

            qtyValues += "<td width=\"15\" style=\"text-align:center; \">" + Qty.ToString() + "</td>" +
                               "<td width=\"20\" style=\"text-align:center; \">" + price.ToString("0,0.00") + "</td>" +
                               "<td width=\"20\" style=\"text-align:center; \" " + (((objOrderDetail.DistributorSurcharge ?? 0) < 0) ? "color=\"#FF0000\"" : string.Empty) + ">" + (objOrderDetail.DistributorSurcharge ?? 0).ToString() + "%</td>" +
                               "<td width=\"20\" style=\"text-align:center; \">" + "$" + surchargePrice.ToString("0.00") + "</td>" +
                               "<td width=\"20\" style=\"text-align:center; \">" + "$" + totalvalue.ToString("0,0.00") + "</td>";

            orderDetailHtml = orderDetailHtml.Replace("<$qtyheader$>", qtyHeader);
            orderDetailHtml = orderDetailHtml.Replace("<$qtyvalues$>", qtyValues);

            return orderDetailHtml;
        }

        /*private static string CreateOrderDetailExtensionHTML(OrderBO objOrder)
        {
            string orderDetailExtensionHtml = string.Empty;
            int i = 0;

            orderDetailExtensionHtml += "<table cellpadding=\"17\" style=\"font-size: 8px\"><tr valign=\"middle\"><td><table cellpadding=\"0\">";

            List<OrderDetailBO> lstDetails = objOrder.OrderDetailsWhereThisIsOrder.ToList();

            foreach (OrderDetailBO objDetail in lstDetails)
            {
                if (i > 0)
                {
                    orderDetailExtensionHtml += GenerateOdsPdf.CreateOrderDetailHTML(objDetail, i + 1);
                }
                i++;
            }

            orderDetailExtensionHtml += "</table></table>";

            return orderDetailExtensionHtml;
        }
        */

        private static List<string> CreateOrderDetailExtensionHTMLList(OrderBO objOrder)
        {
            List<string> htmlPages = new List<string>();
            string start = "<table cellpadding=\"17\" style=\"font-size: 8px\"><tr valign=\"middle\"><td><table cellpadding=\"0\">";
            string end = "</table></table>";
            string content = string.Empty;
            int addedCount = 0;
            int i = 0;
            List<OrderDetailBO> lstDetails = objOrder.OrderDetailsWhereThisIsOrder.ToList();

            foreach (OrderDetailBO objDetail in lstDetails)
            {
                if (i > 0)
                {
                    content += GenerateOdsPdf.CreateOrderDetailHTML(objDetail, i + 1);
                    addedCount++;

                    if (addedCount == 4 || i == (lstDetails.Count - 1))
                    {
                        htmlPages.Add(start + content + end);
                        content = string.Empty;
                        addedCount = 0;
                    }
                }
                i++;
            }

            return htmlPages;
        }

        #endregion

        #endregion
    }

    #region Internal Class

    internal class BackOrderDetail
    {
        public string ShipmentMode { get; set; }

        public string CompanyName { get; set; }

        public string Address { get; set; }

        public string State { get; set; }

        public string Country { get; set; }

        public string ContactName { get; set; }

        public string DistributorPONo { get; set; }

        public string OrderNo { get; set; }

        public string VisualLayout { get; set; }

        public string PatternNickName { get; set; }

        public string PatternNumber { get; set; }

        public string Item { get; set; }

        public int Qty { get; set; }

        public string Status { get; set; }

        public DateTime WeekendDate { get; set; }

        public string Client { get; set; }
    }

    #endregion
}