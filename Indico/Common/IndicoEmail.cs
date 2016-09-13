using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.Web;
using System.IO;

using Indico.BusinessObjects;

namespace Indico.Common
{
    public class IndicoEmail
    {
        #region Fields

        static string emailTemplate;
        static string emailTemplateHelpCentre;

        #endregion

        #region Properties

        protected static string EmailTemplate
        {
            get
            {
                if (emailTemplate == null)
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/EmailTemplate.html"));
                    // StreamReader rdr = new StreamReader(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\Indico\\Templates\\EmailTemplate.html");
                    emailTemplate = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return emailTemplate;
            }
        }

        #endregion

        #region Methods

        public static void SendChangePasswordEmailNitifications(UserBO objReceiver, string title, string emailContent)
        {
            //CompanyBO objCompany = new CompanyBO();
            //objCompany.ID = objSender.Company;
            //objCompany.GetObject();

            string fromName = "Indiman Administrator"; //objSender.GivenName + " " + objSender.FamilyName;
            string fromEmail = "no-reply@gw.indiman.net"; // objSender.EmailAddress;
            string toName = objReceiver.GivenName + " " + objReceiver.FamilyName;
            string hostUrl = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/";

            string mailBody = EmailTemplate;
            mailBody = mailBody.Replace("<$headerBGColor$>", "#222");
            mailBody = mailBody.Replace("<$accountname$>", "Indico");
            mailBody = mailBody.Replace("<$accountheader$>", "Indico");            
            mailBody = mailBody.Replace("<$accountURL$>", "<a href=\"http://" + hostUrl + "\">" + hostUrl + "</a>");
            mailBody = mailBody.Replace("<$title$>", title);
            mailBody = mailBody.Replace("<$imageURL$>", "http://" + hostUrl);
            mailBody = mailBody.Replace("<$firstname$>", objReceiver.GivenName);
            mailBody = mailBody.Replace("<$content$>", emailContent);
            mailBody = mailBody.Replace("<$headerlink$>", "#09F");
            mailBody = mailBody.Replace("<$normallink$>", "#06F");
            mailBody = mailBody.Replace("<$h1link$>", "#03F");

            SendMail(fromName, fromEmail, toName, objReceiver.EmailAddress, "", title, null, "", false, mailBody);
        }

        public static void SendMailNotifications(UserBO objSender, UserBO objReceiver, string title, string emailContent)
        {
            CompanyBO objCompany = new CompanyBO();
            objCompany.ID = objSender.Company;
            objCompany.GetObject();

            string fromName = objSender.GivenName + " " + objSender.FamilyName;
            string fromEmail = objSender.EmailAddress;
            string toName = objReceiver.GivenName + " " + objReceiver.FamilyName;
            string hostUrl = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/";

            string mailBody = EmailTemplate;
            mailBody = mailBody.Replace("<$headerBGColor$>", "#222");
            mailBody = mailBody.Replace("<$accountname$>", objCompany.Name);
            mailBody = mailBody.Replace("<$accountheader$>", objCompany.Name);            
            mailBody = mailBody.Replace("<$accountURL$>", "<a href=\"http://" + hostUrl + "\">" + hostUrl + "</a>");
            mailBody = mailBody.Replace("<$title$>", title);
            mailBody = mailBody.Replace("<$imageURL$>", "http://" + hostUrl);
            mailBody = mailBody.Replace("<$firstname$>", objReceiver.GivenName);
            mailBody = mailBody.Replace("<$content$>", emailContent);
            mailBody = mailBody.Replace("<$headerlink$>", "#09F");
            mailBody = mailBody.Replace("<$normallink$>", "#06F");
            mailBody = mailBody.Replace("<$h1link$>", "#03F");

            SendMail(fromName, fromEmail, toName, objReceiver.EmailAddress, "", title, null, "", false, mailBody);
        }

        public static void SendMailFromSystem(string toName, string toEmail, string mailCC, string subjectText, string bodyText, bool isHtml)
        {
            string emailSenderAddress = IndicoConfiguration.AppConfiguration.EmailSystemFromAddress;
            string emailSenderName = IndicoConfiguration.AppConfiguration.EmailSystemFromName;
            if (isHtml)
            {
                SendMail(emailSenderName, emailSenderAddress, toName, toEmail, mailCC, subjectText, null, "", false, bodyText);
            }
            else
            {
                SendMail(emailSenderName, emailSenderAddress, toName, toEmail, mailCC, subjectText, bodyText, "", false, null);
            }
        }

        public static void SendMail(string fromName, string fromEmail, string toName, string toEmail, string CC, string subjectText, string bodyText, string Filename, bool deleteAttachment, string bodyHtml)
        {
            string[] attachmentPaths = new string[] { };
            SendMail(fromName, fromEmail, toName, toEmail, CC, subjectText, bodyText, attachmentPaths, deleteAttachment, bodyHtml);
        }

        public static void SendMail(string fromName, string fromEmail, string toName, string toEmailCSV, string mailCCCSV, string subjectText, string bodyText, string[] attachmentPaths, bool deleteAttachment, string bodyHtml)
        {
            if (IndicoConfiguration.AppConfiguration.IsSendEmails)
            {
                string innerException = String.Empty;
                string exceptionMessage = String.Empty;
                string stackTrace = String.Empty;
                MailMessage mailMessage = new MailMessage();

                mailMessage.From = new MailAddress(fromEmail, fromName.Replace(",", " "));

                foreach (string mail in toEmailCSV.Split(','))
                {
                    if (!string.IsNullOrEmpty(mail))
                    {
                        mailMessage.To.Add(new MailAddress(mail, toName.Replace(",", " ")));
                    }
                }

                if (mailCCCSV != null && mailCCCSV != String.Empty)
                {
                    foreach (string mailcc in mailCCCSV.Split(','))
                    {
                        if (!string.IsNullOrEmpty(mailcc))
                        {
                            mailMessage.CC.Add(mailcc);
                        }
                    }

                }

                mailMessage.Subject = subjectText;
                mailMessage.Body = bodyText;

                if (bodyHtml != null && bodyHtml != String.Empty)
                {
                    mailMessage.Body = bodyHtml;
                    mailMessage.IsBodyHtml = true;
                }

                string fileName = null;
                if (attachmentPaths != null && attachmentPaths.Length > 0)
                {
                    for (int ia = 0; ia < attachmentPaths.Length; ia++)
                    {
                        fileName = attachmentPaths[ia];
                        if (fileName != null && File.Exists(fileName))
                        {
                            //mailMessage.AddAttachment(strFilename);
                            Attachment att = new Attachment(fileName);
                            mailMessage.Attachments.Add(att);
                        }
                    }
                }

                SmtpClient smtpClient = new SmtpClient();

                if (IndicoConfiguration.AppConfiguration.UseGmailServer)
                {
                    smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;
                    smtpClient.Host = IndicoConfiguration.AppConfiguration.GmailServer;
                    smtpClient.Port = 587;
                    smtpClient.EnableSsl = true;
                    smtpClient.UseDefaultCredentials = false;
                    smtpClient.Credentials = new System.Net.NetworkCredential(IndicoConfiguration.AppConfiguration.GmailUserName, IndicoConfiguration.AppConfiguration.GmailPassword);
                }
                else
                {
                    smtpClient = new SmtpClient(IndicoConfiguration.AppConfiguration.MailServer, 25);
                    smtpClient.DeliveryMethod = SmtpDeliveryMethod.PickupDirectoryFromIis;
                }

                try
                {
                    smtpClient.Send(mailMessage);
                }
                catch (System.Exception objException)
                {
                    IndicoLogging.log.Error("Error occured while sending the email...", objException);

                    exceptionMessage = objException.Message;
                    stackTrace = objException.StackTrace;

                    while (objException.InnerException != null)
                    {
                        innerException = innerException + objException.InnerException.ToString();
                        objException = objException.InnerException;
                    }

                    //if (!IndicoConfiguration.CurrentAccountSetting.IgnoreNotificationSendingError)
                    //{
                    //    throw new System.Exception("A problem occurred while trying to send the following notification [" + strFilename + "] to [" + strToEmail + "]:\r\n\r\n" + strExceptionMessage + strStackTrace + strInnerException);
                    //}
                }
            }
        }

        public static void SendMailNotificationsToExternalUsers(UserBO objSender, string receiverEmail, string receiverName, string title, string emailContent)
        {
            string fromName = objSender.GivenName + " " + objSender.FamilyName;
            string fromEmail = objSender.EmailAddress;
            string hostUrl = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/";

            string mailBody = EmailTemplate;
            mailBody = mailBody.Replace("<$headerBGColor$>", "#222");
            mailBody = mailBody.Replace("<$accountname$>", objSender.objCompany.Name);
            mailBody = mailBody.Replace("<$accountheader$>", objSender.objCompany.Name);            
            mailBody = mailBody.Replace("<$accountURL$>", "<a href=\"http://" + hostUrl + "\">" + hostUrl + "</a>");
            mailBody = mailBody.Replace("<$title$>", title);
            mailBody = mailBody.Replace("<$imageURL$>", "http://" + hostUrl);
            mailBody = mailBody.Replace("<$firstname$>", receiverName);
            mailBody = mailBody.Replace("<$content$>", emailContent);
            mailBody = mailBody.Replace("<$headerlink$>", "#09F");
            mailBody = mailBody.Replace("<$normallink$>", "#06F");
            mailBody = mailBody.Replace("<$h1link$>", "#03F");

            SendMail(fromName, fromEmail, receiverName, receiverEmail, "", title, null, "", false, mailBody);
        }

        public static void SendMailOrderSubmission(string receiverName, string receiverEmail, string mailCC, string title, string emailContent)
        {
            string hostUrl = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/";

            string mailBody = EmailTemplate;
            mailBody = mailBody.Replace("<$headerBGColor$>", "#F25223");
            mailBody = mailBody.Replace("<$accountname$>", "Indico");
            mailBody = mailBody.Replace("<$accountheader$>", title);
            mailBody = mailBody.Replace("<$accountURL$>", "<a href=\"http://" + hostUrl + "\">" + hostUrl + "</a>");
            mailBody = mailBody.Replace("<$title$>", string.Empty);
            mailBody = mailBody.Replace("<$imageURL$>", "http://" + hostUrl);
            mailBody = mailBody.Replace("<$firstname$>", receiverName);
            mailBody = mailBody.Replace("<$content$>", emailContent);
            mailBody = mailBody.Replace("<$headerlink$>", "#FFFFFF");
            mailBody = mailBody.Replace("<$normallink$>", "#06F");
            mailBody = mailBody.Replace("<$h1link$>", "#03F");

            SendMail("System Admin", "no-reply@gw.indiman.net", receiverName, receiverEmail, mailCC, title, null, "", false, mailBody);
        }

        #endregion
    }
}
