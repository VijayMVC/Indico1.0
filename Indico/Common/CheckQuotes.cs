using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Hosting;
using System.Transactions;

using Indico.BusinessObjects;
using IL = Indico.BusinessObjects.IndicoLogging;
using System.Collections.Generic;
using System.Drawing;


namespace Indico.Common
{
    public class CheckQuotes : IndicoPage
    {
        #region Enum

        public enum CheckQuoteState
        {
            Stopped,
            Started,
            Error
        }

        #endregion

        #region Fields

        // Field declaration and intialization
        private static ReaderWriterLock rwl = new ReaderWriterLock();
        private static Thread MaintenanceWorkThread;
        public static CheckQuoteState State = CheckQuoteState.Stopped;
        static string emailTemplate = string.Empty;
        private static string quotedetail;

        #endregion

        #region Properties

        protected static string QuoteEmailTemplate
        {
            get
            {
                if (string.IsNullOrEmpty(emailTemplate))
                {
                    StreamReader rdr = new StreamReader(HostingEnvironment.MapPath("~/Templates/Quote.html"));
                    emailTemplate = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return emailTemplate;
            }
        }

        private static string QuoteDetail
        {
            get
            {
                //if (quotedetail == null)
                //{
                StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/Quote.html"));
                quotedetail = rdr.ReadToEnd();
                rdr.Close();
                rdr = null;
                // }
                return quotedetail;
            }
        }

        #endregion

        #region Constructors

        /// <summary>
        /// Default constructor
        /// </summary>
        public CheckQuotes()
        {

        }

        #endregion

        #region Methods

        public static void Start()
        {
            rwl.AcquireWriterLock(Timeout.Infinite);
            try
            {
                if (MaintenanceWorkThread == null || !MaintenanceWorkThread.IsAlive)
                {
                    IL.log.Info("CheckQuotes.Start() - Starting...");
                    MaintenanceWorkThread = IndicoConfiguration.GetContextAwareThread(new ThreadStart((new CheckQuotes()).DoCheckQuotesStatus));
                    MaintenanceWorkThread.SetApartmentState(ApartmentState.STA);
                    MaintenanceWorkThread.Start();
                    State = CheckQuoteState.Started;
                    IL.log.Info("CheckQuotes.Start() - Started.");
                }
            }
            catch (Exception ex)
            {
                IL.log.ErrorFormat("CheckQuotes.Start() - Error occurred, Message: {0}\nStacktrace: {1}", ex.Message, ex.StackTrace);

                State = CheckQuoteState.Error;
            }
            finally
            {
                rwl.ReleaseWriterLock();
            }
        }

        /// <summary>
        /// This method will do the deletion work and sleep until the next interval starts.
        /// </summary>
        public void DoCheckQuotesStatus()
        {
            try
            {
                while (true)
                {
                    try
                    {
                        IL.log.Debug("DoCheckQuotesStatus() - cycle begins...");

                        // Start checking the statuses of In Progress Quotes
                        QuoteBO objQuote = new QuoteBO();
                        objQuote.Status = 1;
                        List<QuoteBO> lstQuotes = objQuote.SearchObjects();
                        foreach (QuoteBO Quote in lstQuotes)
                        {
                            /// Start processing the Quote...
                            /// 

                            if (Quote.QuoteExpiryDate.ToShortDateString() == DateTime.Now.ToShortDateString())
                            {
                                this.ChangeOrderStatus(Quote.ID);
                            }
                            if (Quote.QuoteExpiryDate.ToShortDateString() == DateTime.Now.AddDays(2).ToShortDateString())
                            {
                            }
                        }

                        IL.log.Debug("DoCheckQuotesStatus() - cycle ends.");
                    }
                    catch (Exception ex)
                    {
                        IL.log.ErrorFormat("DoCheckQuotesStatus() - Error occurred, Message: {0}\nStacktrace: {1}", ex.Message, ex.StackTrace);
                    }

                    // Sleep until the next inetrval starts.
                    Thread.Sleep(24 * 60 * 60 * 1000);
                    //Thread.Sleep(1000 * 60 * 1); // 1min
                }
            }
            catch (System.Threading.ThreadAbortException)
            {
                IL.log.InfoFormat("DoCheckQuotesStatus Task: Caught Thread Abort.");
            }
        }

        // TODDO NNM
        //private void SendMail(QuoteBO objQuote, string mailSubject)
        //{
        //    try
        //    {
        //        string mailcc = string.Empty;
        //        List<QuoteChangeEmailListBO> lstQuoteChangeEmailListCC = (new QuoteChangeEmailListBO()).SearchObjects().Where(o => o.IsCC == true).ToList();

        //        foreach (QuoteChangeEmailListBO ccList in lstQuoteChangeEmailListCC)
        //        {
        //            UserBO objUser = new UserBO();
        //            objUser.ID = (int)ccList.User;
        //            objUser.GetObject();
        //            mailcc += objUser.EmailAddress + ",";
        //        }

        //        string emailContent = string.Empty;
        //        string emailTemp = QuoteEmailTemplate;
        //        string emailLogoPath = string.Empty;

        //        if (!string.IsNullOrEmpty(objQuote.JobName))
        //        {
        //            emailContent += " <tr>" +
        //                              "<td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Job Name" + "</td>" +
        //                              "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + objQuote.JobName + "</td>" +
        //                              "</tr>";
        //        }

        //        if (objQuote.Pattern != null && objQuote.Pattern > 0)
        //        {
        //            emailContent += " <tr>" +
        //                              "<td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Item" + "</td>" +
        //                              "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + objQuote.objPattern.Number + "-" + objQuote.objPattern.NickName + "</td>" +
        //                              "</tr>";
        //        }

        //        if (objQuote.IndimanPrice != null && objQuote.IndimanPrice > 0)
        //        {
        //            string currency = (objQuote.Currency != null && objQuote.Currency > 0) ? objQuote.objCurrency.Code : string.Empty;
        //            string priceterm = (objQuote.PriceTerm != null && objQuote.PriceTerm > 0) ? objQuote.objPriceTerm.Name : string.Empty;
        //            emailContent += " <tr>" +
        //                             "<td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Price" + "</td>" +
        //                             "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + currency + " " + Convert.ToDecimal(objQuote.IndimanPrice).ToString("0.00") + " " + priceterm + "</td>" +
        //                             "</tr>";
        //        }

        //        if (objQuote.Qty != null && objQuote.Qty != 0)
        //        {
        //            emailContent += " <tr>" +
        //                             "<td width=\"200\" style=\"border-left:1px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Indicated Quantity" + "</td>" +
        //                             "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + objQuote.Qty.ToString() + "</td>" +
        //                             "</tr>";
        //        }

        //        if (objQuote.DeliveryDate != null)
        //        {
        //            emailContent += " <tr>" +
        //                             "<td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Approx. despatch date" + "</td>" +
        //                             "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + Convert.ToDateTime(objQuote.DeliveryDate).ToString("dd MMMM yyyy") + "</td>" +
        //                             "</tr>";
        //        }

        //        if (objQuote.QuoteExpiryDate != null)
        //        {
        //            emailContent += " <tr>" +
        //                            " <td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Expires On" + "</td>" +
        //                            " <td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + Convert.ToDateTime(objQuote.QuoteExpiryDate).ToString("dd MMMM yyyy") + "</td>" +
        //                            " </tr>";
        //        }

        //        if (!string.IsNullOrEmpty(objQuote.Notes))
        //        {
        //            emailContent += " <tr>" +
        //                             "<td width=\"200\" style=\"border-left:1px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Notes" + "</td>" +
        //                             "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + objQuote.Notes + "</td>" +
        //                             "</tr>";
        //        }

        //        if (objQuote.Distributor != null && objQuote.Distributor > 0)
        //        {
        //            emailContent += " <tr>" +
        //                             "<td width=\"200\" style=\"border-left:1px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Distributor" + "</td>" +
        //                             "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + objQuote.objDistributor.Name + "</td>" +
        //                             "</tr>";
        //        }


        //        emailTemp = emailTemp.Replace("<$tabledata$>", emailContent);
        //        emailTemp = emailTemp.Replace("<$contactname$>", (!string.IsNullOrEmpty(objQuote.ContactName)) ? objQuote.ContactName : string.Empty);
        //        string designation = (!string.IsNullOrEmpty(LoggedUser.Designation)) ? (" | " + LoggedUser.Designation) : string.Empty;
        //        emailTemp = emailTemp.Replace("<$name$>", LoggedUser.GivenName + " " + LoggedUser.FamilyName + "" + designation);                
        //        emailTemp = emailTemp.Replace(" <$email$>", objQuote.objCreator.EmailAddress);
        //        emailTemp = emailTemp.Replace(" <$phone$>", objQuote.objCreator.OfficeTelephoneNumber);
        //        emailTemp = emailTemp.Replace("<$Mobile$>", (objQuote.objCreator.MobileTelephoneNumber != null && !string.IsNullOrEmpty(objQuote.objCreator.MobileTelephoneNumber)) ? objQuote.objCreator.MobileTelephoneNumber : string.Empty);
        //        emailTemp = emailTemp.Replace("<$fax$>", LoggedUser.objCompany.Fax);

        //        EmailLogoBO objEmailLogo = new EmailLogoBO().SearchObjects().SingleOrDefault();

        //        if (objEmailLogo != null)
        //        {
        //            emailLogoPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmailLogos/" + objEmailLogo.EmailLogoPath;

        //            if (!File.Exists(Server.MapPath(emailLogoPath)))
        //            {
        //                emailLogoPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmailLogos/logo_login.png";
        //            }
        //        }
        //        else
        //        {
        //            emailLogoPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmailLogos/logo_login.png";
        //        }

        //        System.Drawing.Image Image = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + emailLogoPath);
        //        SizeF emailLogo = Image.PhysicalDimension;
        //        Image.Dispose();

        //        List<float> lstVLImageDimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(emailLogo.Width)), Convert.ToInt32(Math.Abs(emailLogo.Height)), 100);
        //        if (File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + emailLogoPath))
        //        {
        //            emailLogoPath = "http://" + IndicoConfiguration.AppConfiguration.SiteHostAddress + "/" + emailLogoPath;
        //            emailTemp = emailTemp.Replace("<$logoimage$>", "<img src=\"" + emailLogoPath + "\" height=\"" + lstVLImageDimensions[0].ToString() + "\" width=\"" + lstVLImageDimensions[1].ToString() + "\"/>");
        //        }

        //        if (!string.IsNullOrEmpty(mailcc))
        //        {
        //            IndicoEmail.SendMail(objQuote.objCreator.GivenName + " " + objQuote.objCreator.FamilyName, objQuote.objCreator.EmailAddress, objQuote.ContactName, objQuote.ClientEmail, mailcc, "Quote: QT- " + objQuote.ID + mailSubject, null, "", false, emailTemp);
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        IL.log.Error("Error occured while send email from CheckQuotes", ex);
        //    }
        //}

        private void SendMail(QuoteBO objQuote, string mailSubject)
        {

            try
            {
                string mailcc = string.Empty;
                List<QuoteChangeEmailListBO> lstQuoteChangeEmailListCC = (new QuoteChangeEmailListBO()).SearchObjects().Where(o => o.IsCC == true).ToList();

                foreach (QuoteChangeEmailListBO ccList in lstQuoteChangeEmailListCC)
                {
                    UserBO objUser = new UserBO();
                    objUser.ID = (int)ccList.User;
                    objUser.GetObject();
                    mailcc += objUser.EmailAddress + ",";
                }

                //string emailContent = CheckQuotes.CreateQuoteDetailBody(objQuote);
                //string emailTemp = QuoteEmailTemplate;
                //string emailTemp = CheckQuotes.CreateQuoteDetailBody(objQuote);

                string emailTemp = GenerateOdsPdf.CreateQuoteDetail(objQuote);
                string emailLogoPath = string.Empty;

                string[] attachment = { GenerateOdsPdf.CreateQuoteDetailAttachments(objQuote.ID) };

                if (!string.IsNullOrEmpty(mailcc))
                {
                    IndicoEmail.SendMail(objQuote.objCreator.GivenName + " " + objQuote.objCreator.FamilyName, objQuote.objCreator.EmailAddress, objQuote.ContactName, objQuote.ClientEmail, mailcc, "quote: qt- " + objQuote.ID + mailSubject, null, "", false, emailTemp);
                }
            }
            catch (Exception ex)
            {
                IL.log.Error("Error occured while send email from CheckQuotes", ex);
            }
        }

        private void ChangeOrderStatus(int QuoteID)
        {
            try
            {
                if (QuoteID > 0)
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        QuoteBO objQuote = new QuoteBO(this.ObjContext);
                        objQuote.ID = QuoteID;
                        objQuote.GetObject();

                        objQuote.Status = 4;

                        ObjContext.SaveChanges();
                        ts.Complete();

                    }
                }
            }
            catch (Exception ex)
            {
                IL.log.Error("Error occured while updating quote table in CheckQuote", ex);
            }
        }

        /*
        public static string CreateQuoteDetailBody(QuoteBO objQuote)
        {
            string _html = QuoteDetail;

            try
            {

                List<float> lstheaderpage = new List<float>();


                string imagePath = "http://" + IndicoConfiguration.AppConfiguration.SiteHostAddress + @"\IndicoData\Logo\Blackchrome-Quote-header.png";

                string headerpath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/Logo/Blackchrome-Quote-header.png";


                System.Drawing.Image HImage = System.Drawing.Image.FromFile(headerpath);
                SizeF HeaderImage = HImage.PhysicalDimension;
                HImage.Dispose();

                lstheaderpage = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(HeaderImage.Width)), Convert.ToInt32(Math.Abs(HeaderImage.Height)), 800, 115);

                _html = _html.Replace("<$headerimage$>", "<img src=\"" + imagePath + "\" alt=\"Smiley face\" height=\"" + 150 + "\" width=\"" + 1000 + "\" >");

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

                        imagepath = objIndicoPage.GetVLImagePath((int)item.VisualLayout);

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

                    lstVLImages = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(VlImage.Width)), Convert.ToInt32(Math.Abs(VlImage.Height)), 500, 500);

                    string image = "<img src=\"" + "http://" + IndicoConfiguration.AppConfiguration.SiteHostAddress + "/" + imagepath + "\" alt=\"Smiley face\" height=\"" + lstVLImages[0].ToString() + "\" width=\"" + lstVLImages[1].ToString() + "\" >";

                    string sizes = string.Empty;

                    List<SizeBO> lstSizes = item.objPattern.objSizeSet.SizesWhereThisIsSizeSet.Where(o => o.IsDefault == true).ToList();
                    if (lstSizes.Any())
                    {
                        sizes = (lstSizes.Count > 1) ? lstSizes.First().SizeName + " - " + lstSizes.Last().SizeName : "";
                    }

                    //foreach (SizeBO size in lstSizes)
                    //{
                    //    sizes += size.SizeName + " , ";
                    //}

                    string uom = (item.Unit != null && item.Unit > 0) ? item.objUnit.Name : string.Empty;

                    decimal total = ((Convert.ToDecimal(item.IndimanPrice.ToString()) + Convert.ToDecimal(item.GST.ToString())) * item.Qty);

                    tabledescription += "<tr>" +
                                             "<td border=\"0\" width=\"60%\">" +
                                             "<table style=\"font-size: 6px;\" border=\"0\">" +
                                             "<tr>" +
                                             "<td width=\"40%\"> " + image +
                                             "</td>" +
                                             "<td width=\"60%\">" +
                                             "<table>" +
                                             "<tr>" +
                                             "<td> " + item.objPattern.objItem.Name + "</td>" +
                                             "</tr>" +
                                             "<tr>" +
                                             "<td>expiry date : " + objQuote.QuoteExpiryDate.ToString("dd MMMM yyyy") + "</td>" +
                                             "</tr>" +
                                             "<tr>" +
                                             "<td>price include full colour sublimation</td>" +
                                             "</tr>" +
                                             "<tr>" +
                                             "<td>pattern description: " + item.objPattern.NickName + "</td>" +
                                             "</tr>" +
                                             "<tr>" +
                                             "<td>colours: </td>" +
                                             "</tr>" +
                                             "<tr>" +
                                             "<td>sizes:" + sizes.Remove(sizes.LastIndexOf(",")) + "</td>" +
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


                //_html = _html.Replace("<$name$>", LoggedUser.GivenName + " " + LoggedUser.FamilyName + "" + designation);

                _html = _html.Replace("<$emailaddress$>", objQuote.objCreator.EmailAddress);
                _html = _html.Replace("<$officephone$>", objQuote.objCreator.OfficeTelephoneNumber);
                _html = _html.Replace("<$mobilenumber$>", (objQuote.objCreator.MobileTelephoneNumber != null && !string.IsNullOrEmpty(objQuote.objCreator.MobileTelephoneNumber)) ? objQuote.objCreator.MobileTelephoneNumber : string.Empty);
                _html = _html.Replace("<$faxnumber$>", objQuote.objCreator.objCompany.Fax);

                string emailLogoPath = string.Empty;
                EmailLogoBO objemaillogo = new EmailLogoBO().SearchObjects().SingleOrDefault();

                if (objemaillogo != null)
                {
                    emailLogoPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/emaillogos/" + objemaillogo.EmailLogoPath;

                    if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + emailLogoPath))
                    {
                        emailLogoPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/emaillogos/logo_login.png";
                    }
                }
                else
                {
                    emailLogoPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/emaillogos/logo_login.png";
                }

                System.Drawing.Image eimage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + emailLogoPath);
                SizeF emaillogo = eimage.PhysicalDimension;
                eimage.Dispose();

                List<float> lstvlimagedimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(emaillogo.Width)), Convert.ToInt32(Math.Abs(emaillogo.Height)), 100);

                if (File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + emailLogoPath))
                {
                    emailLogoPath = "http://" + IndicoConfiguration.AppConfiguration.SiteHostAddress + "/" + emailLogoPath;
                    _html = _html.Replace("<$emailogo$>", "<img src=\"" + emailLogoPath + "\" height=\"" + lstvlimagedimensions[0].ToString() + "\" width=\"" + lstvlimagedimensions[1].ToString() + "\"/>");
                }

            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while creating Quote Detail HTML", ex);
            }

            return _html;
        }
        */

        #endregion
    }
}