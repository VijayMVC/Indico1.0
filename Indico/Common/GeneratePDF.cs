using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using iTextSharp.text.html.simpleparser;
using iTextSharp.text.pdf;
using Indico.DAL;
using Indico.Models;
using Microsoft.Reporting.WebForms;
using DB = Indico.Providers.Data.DapperProvider;
using iTextSharp.text;

namespace Indico.Common
{

    #region Enum

    public enum ReportType
    {
        Detail = 0,
        Summary,
        Combined,
        Indiman
    }

    #endregion

    static class GeneratePDF
    {
        #region Fields

        private static string _polybaglabels;
        private static string _cartonlabels;
        private static string _batchlabel;
        private static string _jkinvoice;
        private static string _jkinvoicesummary;
        private static string _indimaninvoice;

        #endregion

        #region Properties

        public static string InstalledFolder { get; set; }

        private static string PolyBagLabels
        {
            get
            {
                if (_polybaglabels == null)
                {
                    var rdr = new StreamReader(InstalledFolder + @"Templates\PolyBagLabel.html");
                    _polybaglabels = rdr.ReadToEnd();
                    rdr.Close();
                }
                return _polybaglabels;
            }
        }

        private static string CartonLabels
        {
            get
            {
                if (_cartonlabels == null)
                {
                    var rdr = new StreamReader(InstalledFolder + @"Templates\CartonLabel.html");
                    _cartonlabels = rdr.ReadToEnd();
                    rdr.Close();
                }
                return _cartonlabels;
            }
        }

        private static string BatchLabel
        {
            get
            {
                if (_batchlabel == null)
                {
                    var rdr = new StreamReader(InstalledFolder + @"Templates\BatchHTML.html");
                    _batchlabel = rdr.ReadToEnd();
                    rdr.Close();
                }
                return _batchlabel;
            }
        }

        private static string JkInvoiceDetail
        {
            get
            {
                if (_jkinvoice == null)
                {
                    var rdr = new StreamReader(Application.ExecutablePath.Substring(0, Application.ExecutablePath.LastIndexOf("bin", StringComparison.Ordinal)) + @"Templates/JKInvoiceDetail.html");
                    _jkinvoice = rdr.ReadToEnd();
                    rdr.Close();
                }
                return _jkinvoice;
            }
        }

        private static string JkInvoiceSummary
        {
            get
            {
                if (_jkinvoicesummary == null)
                {
                    var rdr = new StreamReader(Application.ExecutablePath.Substring(0, Application.ExecutablePath.LastIndexOf("bin", StringComparison.Ordinal)) + @"Templates/JKInvoiceSummary.html");
                    _jkinvoicesummary = rdr.ReadToEnd();
                    rdr.Close();
                }
                return _jkinvoicesummary;
            }
        }

        private static string IndimanInvoice
        {
            get
            {
                if (_indimaninvoice == null)
                {
                    var rdr = new StreamReader(Application.ExecutablePath.Substring(0, Application.ExecutablePath.LastIndexOf("bin", StringComparison.Ordinal)) + @"Templates/IndimanInvoiceDetail.html");
                    _indimaninvoice = rdr.ReadToEnd();
                    rdr.Close();
                }
                return _indimaninvoice;
            }
        }

        #endregion

        #region Methods

        public static string CreateIndimanInvoiceHtml(InvoiceModel invoice)
        {
            var indimaninvoicehtmlstring = new StringBuilder(IndimanInvoice);
            var recordcount = 0;
            var finalrecord = string.Empty;
            var masterqty = 0;
            decimal masteramount = 0;

            var invNo = invoice.IndimanInvoiceNo ?? "0";
            var date = (invoice.IndimanInvoiceDate != null) ? Convert.ToDateTime(invoice.IndimanInvoiceDate.Value).ToString("dd MMMM yyyy") : DateTime.Now.ToString("dd MMMM yyyy");

          //  IndicoPackingEntities context = new IndicoPackingEntities();

            var address = DB.DistributorClientAddress(invoice.ShipTo.GetValueOrDefault());

            // var billTo = DB.DistributorClientAddress(invoice.BillTo.GetValueOrDefault());
            var addressCountry = DB.Country(address.Country);
            var invoiceShipmentMode = DB.ShipmentMode(invoice.ShipmentMode);
            indimaninvoicehtmlstring
                .Replace("<$invoiceno$>", invNo)
                .Replace("<$invoicedate$>", date)
                .Replace("<$shipcompanyname$>", address.CompanyName)
                .Replace("<$shipcompanyaddress$>", address.Address + "  " + address.State)
                .Replace("<$shipcompanypostalcode$>", address.PostCode + "  " + addressCountry.ShortName)
                .Replace("<$shipcompanycontact$>", address.ContactName + "  " + address.ContactPhone)
                .Replace("<$shipmentmode$>", invoiceShipmentMode.Name)
                .Replace("<$awbno$>", invoice.AWBNo);

            var invoicedetail = "<table cellpadding=\"1\" cellspacing=\"0\" style=\"font-size: 6px\" border=\"0.5\" width=\"100%\"><tr>" +
                                   "<th style=\"line-height:7px;\" width=\"10%\" align=\"center\"><b>Order</b></th>" +
                                   "<th style=\"line-height:7px;\" width=\"5%\" align=\"center\"><b>Total</b></th>" +
                                   "<th style=\"line-height:7px;\" width=\"18%\" align=\"center\"><b>Description</b></th>" +
                                   "<th style=\"line-height:7px;\" width=\"32%\" align=\"center\"><b>Particulars</b></th>" +
                                   "<th style=\"line-height:7px;\" width=\"6%\" align=\"center\"><b>Type</b></th>" +
                                   "<th style=\"line-height:7px;\" width=\"6%\" align=\"center\"><b>Price</b></th>" +
                                   "<th style=\"line-height:7px;\" width=\"6%\" align=\"center\"><b>Other/Ch</b></th>" +
                                   "<th style=\"line-height:7px;\" width=\"6%\" align=\"center\"><b>Total Price</b></th>" +
                                   "<th style=\"line-height:7px;\" width=\"6%\" align=\"center\"><b>Amount</b></th>" +
                                   "<th style=\"line-height:7px;\" width=\"5%\" align=\"center\"><b>Notes</b></th></tr>";


            var invoiceItems = DB.InvoiceOrderDetailItemsForInvoice(invoice.ID).GroupBy(i => i.Distributor).ToList();
            double rowCount = 0;
            var pageCount = 0;
            const int firstPageCount = 28;
            const int otherPagesCount = 35;

            foreach (var distributor in invoiceItems)
            {
                var totoalqty = 0;
                invoicedetail += "<tr style=\"height:-2px;\"><td style=\"line-height:10px;\" colspan=\"10\"><h6 style=\"padding-left:5px\"><b>" + distributor.Key + "</b></h6></td></tr>";
                rowCount++;

                var lstOrderDetailsGroup = distributor.ToList();

                foreach (var item in lstOrderDetailsGroup)
                {
                    var orderdetailqty = string.Empty;
                    orderdetailqty += item.SizeQuantities;
                    var total = (decimal)(item.Amount);
                    masteramount = masteramount + total;
                    totoalqty = totoalqty + item.Qty.GetValueOrDefault();
                    var patternNo = item.Pattern.Substring(0, item.Pattern.LastIndexOf('-')).Trim();
                    var fabricName = item.Fabric.Substring(item.Fabric.IndexOf('-') + 1).Trim();
                    var nickName = item.Pattern.Substring(item.Pattern.IndexOf('-') + 1).Trim();

                    if (((item.VisualLayout + " " + item.Client).Count() > 27) || ((patternNo + " " + fabricName).Count() > 46)) //32
                    {
                        rowCount = rowCount + 0.5;
                    }
                    if (((orderdetailqty.Trim().Substring(0, orderdetailqty.Length - 2)).Count() > 27) || (nickName.Count() > 46))
                    {
                        rowCount = rowCount + 0.5;
                    }

                    invoicedetail += "<tr><td style=\"line-height:10px;\" border=\"0\" width=\"10%\">" + item.PurchaseOrder + "</td>" +
                                        "<td style=\"line-height:10px;\" border=\"0\" width=\"5%\">" + item.Qty + "</td>" +
                                        "<td style=\"line-height:10px;\" border=\"0\"  width=\"18%\">" + item.VisualLayout + " " + item.Client + "<br/>" + orderdetailqty.Trim().Substring(0, orderdetailqty.Length - 2) + "</td>" +
                                        "<td style=\"line-height:10px;\" border=\"0\" width=\"32%\">" + patternNo + " " + fabricName + "<br/>" + nickName + "</td>" +
                                        "<td style=\"line-height:10px;\" border=\"0\"  width=\"6%\">" + item.OrderType + "</td>" +
                                        "<td style=\"line-height:10px;\" border=\"0\"  width=\"6%\">" + item.IndimanPrice + "</td>" +
                                        "<td style=\"line-height:10px;\" border=\"0\" width=\"6%\">" + item.OtherCharges + "</td>" +
                                        "<td style=\"line-height:10px;\" border=\"0\" width=\"6%\">" + item.Amount + "</td>" +
                                        "<td style=\"line-height:10px;\" border=\"0\" width=\"6%\">" + total.ToString("0.00") + "</td>" +
                                        "<td style=\"line-height:10px;\" border=\"0\"  width=\"5%\">" + item.IndimanNotes + " </td></tr>";

                    rowCount++;


                    if ((pageCount == 0 && rowCount >= firstPageCount) || (pageCount != 0 && rowCount >= otherPagesCount))
                    {
                        invoicedetail += "<tr style=\"height:5px;\"><td border=\"0\" style=\"line-height:60px;color: #FFFFFF;\" colspan=\"10\"><h6>INDICO</h6></td></tr>";
                        rowCount = 0;
                        pageCount++;
                    }
                }

                recordcount = recordcount + 1;
                masterqty = masterqty + totoalqty;
            }

            invoicedetail += "</table>";

            if (invoiceItems.Count == recordcount)
            {
                finalrecord += "<table border=\"0.5\"><tr><td style=\"line-height:10px;\" border=\"0\">Total:</td><td style=\"line-height:10px;\" border=\"0\">" + masterqty + "</td><td style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" +
                               "<td style=\"line-height:10px;\" border=\"0\">&nbsp;</td><td style=\"line-height:10px;\" border=\"0\">&nbsp;</td><td style=\"line-height:10px;\" border=\"0\">&nbsp;</td><td style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" +
                               "<td style=\"line-height:10px;\" border=\"0\"></td></tr></table>";
            }

            indimaninvoicehtmlstring
                .Replace("<$pricedetails$>", invoicedetail)
                .Replace("<$finalrecord$>", finalrecord);

            var gst = ((masteramount * 10) / 100);
            var totalgst = gst + masteramount;

            indimaninvoicehtmlstring
                .Replace("<$subtotal$>", masteramount.ToString("0.00"))
                .Replace("<$gst$>", gst.ToString("0.00"))
                .Replace("<$totgst$>", totalgst.ToString("0.00"));

            return indimaninvoicehtmlstring.ToString();
        }

        private static string CreateJkInvoiceDetailHtml(InvoiceModel invoice)
        {
            var jkinvoicedetailhtmlstring = new StringBuilder(JkInvoiceDetail);
            var recordcount = 0;
            var finalrecord = string.Empty;
            var masterqty = 0;
            decimal masteramount = 0;
            var rowIndex = 1;
            var rowIndexCount = 20;


            var address = DB.DistributorClientAddress(invoice.ShipTo.GetValueOrDefault());

            var billTo = DB.DistributorClientAddress(invoice.BillTo.GetValueOrDefault());
            var billtoCountry = DB.Country(billTo.Country);
            var invoiceShipmentMode = DB.ShipmentMode(invoice.ShipmentMode);
            var billtoPort = DB.DestinationPort(billTo.Port.GetValueOrDefault());

            jkinvoicedetailhtmlstring
                .Replace("<$invoiceno$>", invoice.InvoiceNo)
                .Replace("<$shipmentdate$>", invoice.InvoiceDate.ToString("dd MMMM yyyy"))
                .Replace("<$shipcompanyname$>", address.CompanyName)
                .Replace("<$shipcompanyaddress$>", address.Address + "  " + address.State)
                .Replace("<$shipcompanypostalcode$>", address.PostCode + "  " + billtoCountry.ShortName)
                .Replace("<$shipcompanycontact$>", address.ContactName + "  " + address.ContactPhone)
                .Replace("<$shipmentmode$>", invoiceShipmentMode.Name)
                .Replace("<$awbno$>", invoice.AWBNo)
                .Replace("<$port$>", (billTo.Port != null && billTo.Port > 0) ? billtoPort.Name : string.Empty)
                .Replace("<$billtocompanyname$>", billTo.CompanyName)
                .Replace("<$billtocompanyname$>", billTo.Address)
                .Replace("<$billtocompanystate$>", billTo.Suburb + "  " + billTo.State + "  " + billTo.PostCode)
                .Replace("<$billtocompanycountry$>", billtoCountry.ShortName);


            var invoicedetail = "<table cellpadding=\"1\" cellspacing=\"0\" style=\"font-size: 7px\" width=\"100%\"><tr>" +
                                   "<th border=\"0\" width=\"9%\"><b>Type</b></th>" + //13
                                   "<th border=\"0\" width=\"10%\"><b>Qty</b></th>" + //5
                                   "<th border=\"0\" width=\"20%\"><b>Sizes</b></th>" + //25
                                   "<th border=\"0\"  width=\"34%\"><b>Description</b></th>" + //35
                                   "<th border=\"0\" width=\"6%\"><b>Price</b></th>" +
                                   "<th border=\"0\" width=\"7%\"><b>Other/Ch</b></th>" +
                                   "<th border=\"0\" width=\"6%\"><b>Total</b></th>" +
                                   "<th border=\"0\" width=\"8%\"><b>AMOUNT</b></th></tr>";

            var invoiceItems = DB.InvoiceOrderDetailItemsForInvoice(invoice.ID).GroupBy(i => i.Distributor).ToList();

            foreach (var distributor in invoiceItems)
            {
                var totoalqty = 0;
                decimal totalamount = 0;
                invoicedetail += "<tr style=\"height:-2px;\" border=\"0.5\"><td style=\"line-height:10px;\" colspan=\"8\"><h6 style=\"padding-left:5px\"><b>" + distributor.Key /*address.CompanyName*/ + "</b></h6></td></tr>";
                rowIndex++;

                var lstOrderDetailsGroup = distributor.ToList();

                foreach (var item in lstOrderDetailsGroup)
                {
                    var orderdetailqty = string.Empty;
                    orderdetailqty += item.SizeQuantities;
                    var total = (decimal)(item.Amount);
                    totalamount = totalamount + total;
                    masteramount = masteramount + total;
                    totoalqty = totoalqty + item.Qty.GetValueOrDefault();

                    invoicedetail += "<tr style=\"height:-2px;\">" +
                                     "<td style=\"line-height:10px;\" width=\"9%\">" + item.OrderType + "<br>" + item.PurchaseOrder + "</td>" + //13
                                     "<td style=\"line-height:10px;\" width=\"10%\">" + item.Qty + "  " + item.ItemName + "</td>" + //5
                                     "<td style=\"line-height:10px;\" width=\"20%\">" + item.VisualLayout + " " + item.Client + "<br>" + orderdetailqty.Trim().Substring(0, orderdetailqty.Length - 2) + "</td>" + //item.client(ic) //25
                                     "<td style=\"line-height:10px;\" width=\"34%\">" + item.Fabric + " " + item.Material + "</td>" +
                                     "<td style=\"line-height:10px;\" width=\"6%\">" + item.FactoryPrice.GetValueOrDefault().ToString("0.00") + "</td>" + //35
                                     "<td style=\"line-height:10px;\" width=\"7%\" >" + item.OtherCharges.GetValueOrDefault().ToString("0.00") + "</td>" +
                                     "<td style=\"line-height:10px;\" width=\"6%\" >" + ((decimal)item.Amount).ToString("0.00") + "</td>" +
                                     "<td style=\"line-height:10px;\" width=\"6%\" >" + total.ToString("0.00") + "</td></tr>" +
                                     "<tr><td style=\"line-height:0px;\" colspan=\"8\" border=\"0.5\"></td></tr>";

                    rowIndex++;

                    if (rowIndex >= rowIndexCount) //16
                    {
                        invoicedetail += "<tr style=\"height:5px;\"><td border=\"0\" style=\"line-height:50px;color: #FFFFFF;\" colspan=\"8\"><h6>INDICO</h6></td></tr>";
                        rowIndex = 0;
                        rowIndexCount = 27;
                    }
                }
                //}
                invoicedetail += "<tr style=\"height:2px;\"><td  style=\"line-height:-2px;color: #F0FFFF;\" colspan=\"8\"></td>"; //9colspan
                invoicedetail += "<tr>" +
                                 "<td  style=\"line-height:8px;\" border=\"0\" width=\"9%\">&nbsp;</td>" + //13
                                 "<td  style=\"line-height:8px;\" border=\"0\" width=\"10%\"><b>" + totoalqty + "</b></td>" + //5
                                 "<td  style=\"line-height:8px;\" border=\"0\" width=\"20%\">&nbsp;</td>" + //25
                                 "<td style=\"line-height:8px;\" border=\"0\" width=\"34%\">&nbsp;</td>" + //35
                                 "<td style=\"line-height:8px;\" border=\"0\" width=\"6%\">&nbsp;</td>" +
                                 "<td style=\"line-height:8px;\" border=\"0\" width=\"7%\">&nbsp;</td>" + //IC
                                 "<td style=\"line-height:8px;\" border=\"0\" width=\"6%\">&nbsp;</td>" + //IC
                                 "<td  style=\"line-height:8px;\" border=\"0\" width=\"8%\">" + totalamount.ToString("0.00") + "</td>" +
                                 "</tr>";

                recordcount = recordcount + 1;
                masterqty = masterqty + totoalqty;

                if (invoiceItems.Count != recordcount)
                {
                    invoicedetail += "<tr style=\"height:5px;\"><td border=\"0\" style=\"line-height:2px;color: #FFFFFF;\" colspan=\"8\"><h6>INDICO</h6></td>"; //7 colspan
                    rowIndex++;

                    if (rowIndex >= rowIndexCount)
                    {
                        invoicedetail += "<tr style=\"height:5px;\"><td border=\"0\" style=\"line-height:50px;color: #FFFFFF;\" colspan=\"8\"><h6>INDICO</h6></td></tr>"; //7 colspan
                        rowIndex = 0;
                        rowIndexCount = 27;
                    }
                }
            }

            invoicedetail += "</table>";

            if (invoiceItems.Count == recordcount)
            {
                finalrecord = "<table border=\"0.5\">" +
                              "<tr>" +
                              "<td width=\"9%\" style=\"line-height:0px;\">&nbsp;</td>" + //13
                              "<td width=\"10%\" style=\"line-height:0px;\">&nbsp;</td>" + //5
                              "<td width=\"20%\" style=\"line-height:0px;\">&nbsp;</td>" + //25
                              "<td width=\"34%\" style=\"line-height:0px;\">&nbsp;</td>" + //35
                              "<td width=\"6%\" style=\"line-height:0px;\">&nbsp;</td>" +
                              "<td width=\"7%\" style=\"line-height:0px;\">&nbsp;</td>" +//IC
                              "<td width=\"6%\" style=\"line-height:0px;\">&nbsp;</td>" +//IC
                              "<td width=\"8%\" style=\"line-height:0px;\">&nbsp;</td>" +
                              "</tr>";
                finalrecord += "<tr>" +
                               "<td width=\"9%\" style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" + //13
                               "<td width=\"10%\" style=\"line-height:10px;\" border=\"0\">" + masterqty + "</td>" +//5
                                "<td width=\"20%\" style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" + //25
                               "<td width=\"34%\" style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" + //35
                               "<td width=\"6%\" style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" +
                               "<td width=\"7%\" style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" + //IC
                               "<td width=\"6%\" style=\"line-height:10px;\" border=\"0\">&nbsp;</td>" +  //IC
                               "<td width=\"8%\" style=\"line-height:10px;\" border=\"0\">" + masteramount.ToString("0.00") + "</td>" +
                               "</tr>" +
                               "</table>";
            }

            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$pricedetails$>", invoicedetail);
            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$finalrecord$>", finalrecord);

            var invoiceBank = DB.Bank(invoice.Bank.GetValueOrDefault());
            var bankCountry = DB.Country(invoiceBank.Country.GetValueOrDefault());

            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$bankname$>", invoiceBank.Name);

            string country = (invoiceBank.Country != null || invoiceBank.Country > 0) ? bankCountry.ShortName : string.Empty;

            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$bankaddress$>",invoiceBank.Address + "  " + invoiceBank.City + "  " + invoiceBank.State + "  " + invoiceBank.Postcode + "  " + country);

            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$accountnumber$>", invoiceBank.AccountNo);

            jkinvoicedetailhtmlstring = jkinvoicedetailhtmlstring.Replace("<$swiftcode$>", invoiceBank.SwiftCode);

            return jkinvoicedetailhtmlstring.ToString();
        }

        private static string CreateJKInvoiceSummaryHTML(InvoiceModel objInvoice)
        {
            var jkinvoicesummaryhtmlstring = JkInvoiceSummary;
            var masterqty = 0;
            decimal masteramount = 0;
            var rowIndex = 1;

            // IndicoPackingEntities context = new IndicoPackingEntities();
            var address = DB.DistributorClientAddress(objInvoice.ShipTo.GetValueOrDefault());

            var billTo = DB.DistributorClientAddress(objInvoice.BillTo.GetValueOrDefault());
            var billtoCountry = DB.Country(billTo.Country);
            var invoiceShipmentMode = DB.ShipmentMode(objInvoice.ShipmentMode);
            var billtoPort = DB.DestinationPort(billTo.Port.GetValueOrDefault());
            var addressCountry = DB.Country(address.Country);


            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$invoicenumber$>", objInvoice.InvoiceNo);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$shipmentdate$>", objInvoice.InvoiceDate.ToString("dd MMMM yyyy"));
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$mode$>", invoiceShipmentMode.Name);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$awbno$>", objInvoice.AWBNo);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$companyname$>", address.CompanyName);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$companyaddress$>", address.Address + "  " + address.State);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$companypostalcodecountry$>", address.PostCode + "  " + addressCountry.ShortName);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$companycontact$>", address.ContactName + "  " + address.ContactPhone);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$port$>", (billTo.Port != null && billTo.Port > 0) ? billtoPort.Name : string.Empty);

            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$billtocompanyname$>", billTo.CompanyName);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$billtocompanyname$>", billTo.Address);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$billtocompanystate$>", billTo.Suburb + "  " + billTo.State + "  " + billTo.PostCode);
            jkinvoicesummaryhtmlstring = jkinvoicesummaryhtmlstring.Replace("<$billtocompanycountry$>", billtoCountry.ShortName);

            var invoicesummary = "<table width=\"100%\" style=\"font-size:6px;\" cellpadding=\"1\" cellspacing=\"0\"><tr>" +
                                    "<th width=\"35%\">Filaments</th>" +
                                    "<th width=\"20%\">Item Name</th>" +
                                    "<th width=\"10%\">Gender</th>" +
                                    "<th width=\"15%\">Item Sub Cat</th>" +
                                    "<th width=\"10%\">Qty</th>" +
                                    "<th width=\"10%\">Amount</th></tr>" +
                                    "<tr><td style=\"line-height:0px;\" colspan=\"6\" border=\"0.5\"></td></tr>";

            var invoiceItems = DB.InvoiceOrderDetailItemsForInvoice(objInvoice.ID).GroupBy(i => i.HSCode).ToList();

            foreach (var hscode in invoiceItems)
            {
                var hscodetext = (!string.IsNullOrEmpty(hscode.Key)) ? hscode.Key : string.Empty;
                var qty = 0;
                decimal amount = 0;
                decimal total = 0;
                rowIndex++;

                invoicesummary += "<tr><td colspan=\"6\"><b>" + hscodetext + "</b></td></tr>";

                var lstOrderDetailsGroup = hscode.ToList();

                foreach (var item in lstOrderDetailsGroup)
                {
                    qty = qty + item.Qty.GetValueOrDefault();
                    total = (decimal)item.Amount;
                    amount = amount + total;

                    invoicesummary += "<tr><td style=\"line-height:12px;\" width=\"35%\">" + item.Material + "</td>" +
                                        "<td style=\"line-height:12px;\" width=\"20%\">" + item.ItemName + "</td>" +
                                        "<td style=\"line-height:12px;\" width=\"10%\">" + item.Gender + "</td>" +
                                        "<td style=\"line-height:12px;\" width=\"15%\">" + item.ItemSubGroup + "</td>" +
                                        "<td style=\"line-height:12px;\" width=\"10%\">" + item.Qty + "</td>" +
                                        "<td style=\"line-height:12px;\" width=\"10%\">" + ((decimal)item.Amount).ToString("0.00") + "</td></tr>";

                    rowIndex++;

                    if (rowIndex >= 37)
                    {
                        invoicesummary += "<tr style=\"height:5px;\"><td border=\"0\" style=\"line-height:50px;color: #FFFFFF;\" colspan=\"6\"><h6>INDICO</h6></td></tr>";
                        rowIndex = 0;
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

                if (rowIndex >= 37)
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
     

        public static string CombinedInvoice(int invoice, string dataFolder)
        {
            var objInvoice = DB.Invoice(invoice);
            var jkinvoicesummarypath = string.Empty;
            jkinvoicesummarypath = dataFolder + @"Data\Invoices\" + "JKCombineInvoice_" + objInvoice.ID.ToString() + "_" + ".pdf";
            try
            {

                if (File.Exists(jkinvoicesummarypath))
                {
                    File.Delete(jkinvoicesummarypath);
                }

                var lstfilespath = new List<string>();

                var invoicedetailpath = GenerateJKInvoiceDetail(invoice, dataFolder);
                lstfilespath.Add(invoicedetailpath);
                var invoicesummarypath = GenerateJKInvoiceSummary(invoice, dataFolder);
                lstfilespath.Add(invoicesummarypath);
                CombineAndSavePdf(jkinvoicesummarypath, lstfilespath);
            }
            catch (Exception)
            {
                //IndicoLogging.log.Error("Error occured while creating combined invoice from GenerateOdsPdf", ex);
            }
            return jkinvoicesummarypath;
        }

        public static string GenerateJKInvoiceSummary(int invoice, string dataFolder)
        {
            //IndicoPackingEntities context = new IndicoPackingEntities();

            var objInvoice = DB.Invoice(invoice);

            string jkinvoicesummarypath = string.Empty;

            try
            {
                jkinvoicesummarypath = dataFolder + @"Data\Invoices\" + "JKInvoiceSummary_" + objInvoice.ID.ToString() + "_" + ".pdf";//dataFolder + @"Data\Invoices\" + "JKInvoiceSummary_" + objInvoice.ID.ToString() + "_" + ".pdf";

                if (File.Exists(jkinvoicesummarypath))
                {
                    try
                    {
                        File.Delete(jkinvoicesummarypath);
                    }
                    catch
                    { }
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

                string htmlText = GeneratePDF.CreateJKInvoiceSummaryHTML(objInvoice);
                HTMLWorker htmlWorker = new HTMLWorker(document);
                htmlWorker.Parse(new StringReader(htmlText));

                document.Close();
            }
            catch (Exception ex)
            {
                //IndicoLogging.log.Error("Error occured while Generate Pdf jkinvoicesummarypath in GenerateOdsPdf Class", ex);
            }

            return jkinvoicesummarypath;
        }

        public static string GenerateJKInvoiceDetail(int invoice, string dataFolder)
        {
            string jkinvoicedetailpath = string.Empty;

            //IndicoPackingEntities context = new IndicoPackingEntities();

            var objInvoice = DB.Invoice(invoice);

            try
            {
                jkinvoicedetailpath = dataFolder + @"Data\Invoices\" + "JKInvoiceDetail_" + objInvoice.ID.ToString() + "_" + ".pdf";

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

                string htmlText = CreateJkInvoiceDetailHtml(objInvoice);
                HTMLWorker htmlWorker = new HTMLWorker(document);
                htmlWorker.Parse(new StringReader(htmlText));

                document.Close();
            }
            catch (Exception ex)
            {
                //IndicoLogging.log.Error("Error occured while Generate Pdf JKInvoiceOrderDetail in GenerateOdsPdf Class", ex);
            }

            return jkinvoicedetailpath;
        }

        public static string GenerateIndimanInvoice(int invoice, string dataFolder)
        {
            //InvoiceBO objInvoice = new InvoiceBO();
            //objInvoice.ID = invoice;
            //objInvoice.GetObject();

            var temppath = string.Empty;


            var objInvoice = DB.Invoice(invoice);

            var document = new Document();

            try
            {
                temppath = dataFolder + @"Data\Invoices\" + "IndimanInvoiceDetail_" + objInvoice.ID + "_" + ".pdf";

                if (File.Exists(temppath))
                {
                    File.Delete(temppath);
                }

                var writer = PdfWriter.GetInstance(document, new FileStream(temppath, FileMode.Create));
                document.AddKeywords("paper airplanes");

                //float marginBottom = 12;
                //float lineHeight = 14;
                //float pageMargin = 20;
                var pageHeight = PageSize.A4.Height;
                var pageWidth = PageSize.A4.Width;

                document.SetPageSize(new Rectangle(pageWidth, pageHeight));
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

                var htmlText = CreateIndimanInvoiceHtml(objInvoice);
                var htmlWorker = new HTMLWorker(document);
                htmlWorker.Parse(new StringReader(htmlText));

                writer.Close();
            }
            catch (Exception)
            {
                //IndicoLogging.log.Error("Error occured while Generate Pdf indimaninvoicepath in GenerateOdsPdf Class", ex);
            }
            finally
            {
                document.Close();
            }

            return temppath;
        }

        //public static void GenerateInvoices(int invoiceId, string dataFolder, string rdlFileName, string invoiceName, ReportType type)
        //{
        //    using (var rpt = new ReportViewer())
        //    {
        //        var isFileOpen = false;

        //        rpt.ProcessingMode = ProcessingMode.Local;

        //        rpt.LocalReport.ReportPath = dataFolder + @"Data\Reports\" + rdlFileName;

        //        //var context = new IndicoPackingEntities();

        //        rpt.LocalReport.DataSources.Clear();
        //        rpt.LocalReport.DataSources.Add(new ReportDataSource("InvoiceHeader", context.InvoiceHeaderDetailsViews.Where(i => i.ID == invoiceId)));

        //        switch (type)
        //        {
        //            case ReportType.Detail:
        //                rpt.LocalReport.DataSources.Add(new ReportDataSource("OrderByDistributor", context.GetWeeklyAddressDetailsByDistributors.Where(i => i.ID == invoiceId)));
        //                break;
        //            case ReportType.Summary:
        //                rpt.LocalReport.DataSources.Add(new ReportDataSource("ByHSCode", context.GetWeeklyAddressDetailsByHSCodes.Where(i => i.ID == invoiceId)));
        //                break;
        //            case ReportType.Combined:
        //                rpt.LocalReport.DataSources.Add(new ReportDataSource("OrderByDistributor", context.GetWeeklyAddressDetailsByDistributors.Where(i => i.ID == invoiceId)));
        //                rpt.LocalReport.DataSources.Add(new ReportDataSource("ByHSCode", context.GetWeeklyAddressDetailsByHSCodes.Where(i => i.ID == invoiceId)));
        //                break;
        //            case ReportType.Indiman:
        //                rpt.LocalReport.DataSources.Add(new ReportDataSource("OrderByDistributorForIndiman", context.GetWeeklyAddressDetailsByDistributorForIndimen.Where(i => i.ID == invoiceId)));
        //                break;
        //            default:
        //                break;
        //        }

        //        string mimeType, encoding, extension, deviceInfo;
        //        string[] streamids;
        //        Warning[] warnings;
        //        const string format = "PDF";

        //        deviceInfo = "<DeviceInfo>" +
        //        "<SimplePageHeaders>True</SimplePageHeaders>" +
        //        "</DeviceInfo>";

        //        var bytes = rpt.LocalReport.Render(format, deviceInfo, out mimeType, out encoding, out extension, out streamids, out warnings);

        //        var temppath = dataFolder + @"Data\Invoices\" + invoiceName + ".pdf";

        //        FileStream stream = null;

        //        if (File.Exists(temppath))
        //        {
        //            try
        //            {
        //                stream = File.Open(temppath, FileMode.Open, FileAccess.ReadWrite, FileShare.None);
        //            }
        //            catch (IOException)
        //            {
        //                MessageBox.Show(string.Format("{0} is opened in PDF viewer. Please close it before opening another one.", invoiceName + ".pdf"), "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
        //                isFileOpen = true;
        //            }
        //            finally
        //            {
        //                if (stream != null)
        //                    stream.Close();
        //            }
        //        }

        //        if (File.Exists(temppath) && !isFileOpen)
        //        {
        //            File.Delete(temppath);
        //        }

        //        if (!isFileOpen)
        //        {
        //            using (var fs = new FileStream(temppath, FileMode.Create))
        //            {
        //                fs.Write(bytes, 0, bytes.Length);
        //            }
        //        }

        //        while (File.Exists(temppath))
        //        {
        //            Thread.Sleep(1000);
        //            Process.Start(temppath);
        //            break;
        //        }
        //    }

        //}

        #endregion
    }
}