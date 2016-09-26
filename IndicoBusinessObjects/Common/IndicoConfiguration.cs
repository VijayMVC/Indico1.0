using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Threading;
using System.Web;

namespace Indico.BusinessObjects
{
    public class IndicoConfiguration
    {
        #region Fields

        private static IndicoConfiguration instance;

        // Lock synchronization object
        private static object syncLock = new object();

        private static string environment = string.Empty;
        private static string developmentUser = string.Empty;
        private static string isDebugMode = string.Empty;
        private static string isMaintenanceMode = string.Empty;

        private static bool? isSendEmails = null;
        private static string mailServer = string.Empty;
        private static bool? useGmailServer = null;
        private static string gmailServer = string.Empty;
        private static string gmailUserName = string.Empty;
        private static string gmailPassword = string.Empty;

        private static string systemEmailFromAddress = string.Empty;
        private static string systemEmailFromName = string.Empty;
        private static string helpDeskEmailAddress = string.Empty;

        private static bool? isErrorLogging = null;
        private static bool? isShowErrorPage = null;
        private static string errorURL = string.Empty;
        private static string maintenanceURL = string.Empty;
        private static string unauthorisedURL = string.Empty;
        private static string unexpectedErrorMessage = string.Empty;

        private static string assemblyFolderName = string.Empty;
        private static string dataFolderName = string.Empty;
        private static string imageFolderName = string.Empty;
        private static string pathToProjectFolder = string.Empty;
        private static string pathToAssembyFolder = string.Empty;
        private static string pathToDataFolder = string.Empty;
        private static string pathToImageFolder = string.Empty;

        private static string defaultLocale = string.Empty;
        private static int directoryCodeMaxValue = 0;
        private static string releaseDateTime = string.Empty;
        private static string siteHostAddress = string.Empty;

        private static string dNSServername = string.Empty;
        private static string dNSUsername = string.Empty;
        private static string dNSPassword = string.Empty;
        private static string domainName = string.Empty;
        private static string iISSiteName = string.Empty;

        private static string indimanAdministratoremail = string.Empty;
        private static string indicoAdministratoremail = string.Empty;
        private static string factoryAdminstratoremail = string.Empty;

        private static string priceccmail = string.Empty;

        private static string httppostguid = string.Empty;
        private static string httpposturl = string.Empty;

        private static string _myobCompanyFile = string.Empty;
        private static string _myobDeveloperKey = string.Empty;
        private static string _myobDeveloperSecretKey = string.Empty;

        //MYOB Accounts for Item
        private static int _myobItemCostOfSaleAccounNumber;
        private static int _myobItemIncomeAccountNumber;
        private static int _myobItemAssetAccountNumber;
        
        //Myob Authorization
        private static string _myobOAuthUrl = string.Empty;
        private static string _myobClientId = string.Empty;
        private static string _myobClientSecret = string.Empty;
        private static string _myobScope = string.Empty;
        private static string _myobUsername = string.Empty;
        private static string _myobPassword = string.Empty;

        // Images FTP server (used in ImageService)
        private static string _imagesFtpUrl = string.Empty;
        private static string _imagesFtpUserName = string.Empty;
        private static string _imagesFtpPassword = string.Empty;

        private static ReaderWriterLock rwl = new ReaderWriterLock();

        #endregion

        #region Properties

        public static IndicoConfiguration AppConfiguration
        {
            get
            {
                // 'Double checked locking' pattern which (once
                // the instance exists) avoids locking each
                // time the method is invoked
                if (instance == null)
                {
                    lock (syncLock)
                    {
                        if (instance == null)
                        {
                            instance = new IndicoConfiguration();
                        }
                    }
                }

                return instance;
            }
        }

        public string Environment
        {
            get
            {
                if (String.IsNullOrEmpty(environment))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["Environment"].ToString().Trim()))
                    {
                        environment = ConfigurationManager.AppSettings["Environment"].ToString();
                    }
                    else
                    {
                        environment = "dev";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "Environment");
                    }
                }
                return environment;
            }
        }


        public int DevelopmentUser
        {
            get
            {
                if (String.IsNullOrEmpty(developmentUser))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["DevelopmentUser"].ToString().Trim()))
                    {
                        developmentUser = ConfigurationManager.AppSettings["DevelopmentUser"].ToString();
                    }
                    else
                    {
                        developmentUser = "0";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "Environment");
                    }
                }
                try { return int.Parse(developmentUser); }
                catch { return 0; }
            }
        }

        public bool IsDebugMode
        {
            get
            {
                if (String.IsNullOrEmpty(isDebugMode))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["IsDebugMode"].ToString().Trim()))
                    {
                        isDebugMode = ConfigurationManager.AppSettings["IsDebugMode"].ToString();
                    }
                    else
                    {
                        isDebugMode = "false";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "IsDebugMode");
                    }
                }

                bool mode = false;
                try
                {
                    mode = Convert.ToBoolean(isDebugMode);
                }
                catch
                {
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Error occured while converting the config value for {0}", "IsDebugMode");
                }
                return mode;
            }
        }

        public bool IsMaintenanceMode
        {
            get
            {
                if (String.IsNullOrEmpty(isMaintenanceMode))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["IsMaintenanceMode"].ToString().Trim()))
                    {
                        isMaintenanceMode = ConfigurationManager.AppSettings["IsMaintenanceMode"].ToString();
                    }
                    else
                    {
                        isMaintenanceMode = "false";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "IsMaintenanceMode");
                    }
                }

                bool mode = false;
                try
                {
                    mode = Convert.ToBoolean(isMaintenanceMode);
                }
                catch
                {
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Error occured while converting the config value for {0}", "IsMaintenanceMode");
                }
                return mode;
            }
        }

        public bool IsSendEmails
        {
            get
            {
                if (isSendEmails == null)
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["IsSendEmails"].ToString().Trim()))
                    {
                        try
                        {
                            isSendEmails = Convert.ToBoolean(ConfigurationManager.AppSettings["IsSendEmails"]);
                        }
                        catch
                        {
                            isSendEmails = false;
                            IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Error occured while converting the config value for {0}", "IsSendEmails");
                        }
                    }
                    else
                    {
                        isSendEmails = false;
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "IsSendEmails");
                    }
                }

                return (bool)isSendEmails;
            }
        }

        public string MailServer
        {
            get
            {
                if (String.IsNullOrEmpty(mailServer))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["MailServer"].ToString().Trim()))
                    {
                        mailServer = ConfigurationManager.AppSettings["MailServer"].ToString();
                    }
                    else
                    {
                        mailServer = "localhost";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "MailServer");
                    }
                }

                return mailServer;
            }
        }

        public bool UseGmailServer
        {
            get
            {
                if (useGmailServer == null)
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["UseGmailServer"].ToString().Trim()))
                    {
                        try
                        {
                            useGmailServer = Convert.ToBoolean(ConfigurationManager.AppSettings["UseGmailServer"]);
                        }
                        catch
                        {
                            useGmailServer = false;
                            IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Error occured while converting the config value for {0}", "UseGmailServer");
                        }
                    }
                    else
                    {
                        useGmailServer = false;
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "UseGmailServer");
                    }
                }

                return (bool)useGmailServer;
            }
        }

        public string GmailServer
        {
            get
            {
                if (String.IsNullOrEmpty(gmailServer))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["GmailServer"].ToString().Trim()))
                    {
                        gmailServer = ConfigurationManager.AppSettings["GmailServer"].ToString();
                    }
                    else
                    {
                        gmailServer = "smtp.gmail.com";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "GmailServer");
                    }
                }

                return gmailServer;
            }
        }

        public string GmailUserName
        {
            get
            {
                if (String.IsNullOrEmpty(gmailUserName))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["GmailUserName"].ToString().Trim()))
                    {
                        gmailUserName = ConfigurationManager.AppSettings["GmailUserName"].ToString();
                    }
                    else
                    {
                        gmailUserName = "admin.Indico@gmail.com";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "GmailUserName");
                    }
                }

                return gmailUserName;
            }
        }

        public string GmailPassword
        {
            get
            {
                if (String.IsNullOrEmpty(gmailPassword))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["GmailPassword"].ToString().Trim()))
                    {
                        gmailPassword = ConfigurationManager.AppSettings["GmailPassword"].ToString();
                    }
                    else
                    {
                        gmailPassword = "mailadmin";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "GmailPassword");
                    }
                }

                return gmailPassword;
            }
        }

        public string EmailSystemFromAddress
        {
            get
            {
                if (String.IsNullOrEmpty(systemEmailFromAddress))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["SystemEmailFromAddress"].ToString().Trim()))
                    {
                        systemEmailFromAddress = ConfigurationManager.AppSettings["SystemEmailFromAddress"].ToString();
                    }
                    else
                    {
                        systemEmailFromAddress = "Webadmin@Indico.com";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "SystemEmailFromAddress");
                    }
                }

                return systemEmailFromAddress;
            }
        }

        public string EmailSystemFromName
        {
            get
            {
                if (String.IsNullOrEmpty(systemEmailFromName))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["SystemEmailFromName"].ToString().Trim()))
                    {
                        systemEmailFromName = ConfigurationManager.AppSettings["SystemEmailFromName"].ToString();
                    }
                    else
                    {
                        systemEmailFromName = "Indico Admin";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "SystemEmailFromName");
                    }
                }

                return systemEmailFromName;
            }
        }

        public string HelpDeskEmailAddress
        {
            get
            {
                if (String.IsNullOrEmpty(helpDeskEmailAddress))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["HelpDeskEmailAddress"].ToString().Trim()))
                    {
                        helpDeskEmailAddress = ConfigurationManager.AppSettings["HelpDeskEmailAddress"].ToString();
                    }
                    else
                    {
                        helpDeskEmailAddress = "help@Indico.com";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "HelpDeskEmailAddress");
                    }
                }

                return helpDeskEmailAddress;
            }
        }

        public bool IsErrorLogging
        {
            get
            {
                if (isErrorLogging == null)
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["IsErrorLogging"].ToString().Trim()))
                    {
                        try
                        {
                            isErrorLogging = Convert.ToBoolean(ConfigurationManager.AppSettings["IsErrorLogging"]);
                        }
                        catch
                        {
                            isErrorLogging = false;
                            IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Error occured while converting the config value for {0}", "IsErrorLogging");
                        }
                    }
                    else
                    {
                        isErrorLogging = false;
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "IsErrorLogging");
                    }
                }
                return (bool)isErrorLogging;
            }
        }

        public bool IsShowErrorPage
        {
            get
            {
                if (isShowErrorPage == null)
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["IsShowErrorPage"].ToString().Trim()))
                    {
                        try
                        {
                            isShowErrorPage = Convert.ToBoolean(ConfigurationManager.AppSettings["IsShowErrorPage"]);
                        }
                        catch
                        {
                            isShowErrorPage = false;
                            IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Error occured while converting the config value for {0}", "IsShowErrorPage");
                        }
                    }
                    else
                    {
                        isShowErrorPage = false;
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "IsShowErrorPage");
                    }
                }
                return (bool)isShowErrorPage;
            }
        }

        public string ErrorURL
        {
            get
            {
                if (String.IsNullOrEmpty(errorURL))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["ErrorURL"].ToString().Trim()))
                    {
                        errorURL = ConfigurationManager.AppSettings["ErrorURL"].ToString();
                    }
                    else
                    {
                        errorURL = "/Error.aspx";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "ErrorURL");
                    }
                }
                return errorURL;
            }
        }

        public string MaintenanceURL
        {
            get
            {
                if (String.IsNullOrEmpty(maintenanceURL))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["MaintenanceURL"].ToString().Trim()))
                    {
                        maintenanceURL = ConfigurationManager.AppSettings["MaintenanceURL"].ToString();
                    }
                    else
                    {
                        maintenanceURL = "Maintanance.html";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "MaintenanceURL");
                    }
                }

                return maintenanceURL;
            }
        }

        public string UnauthorisedURL
        {
            get
            {
                if (String.IsNullOrEmpty(unauthorisedURL))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["UnauthorisedURL"].ToString().Trim()))
                    {
                        unauthorisedURL = ConfigurationManager.AppSettings["UnauthorisedURL"].ToString();
                    }
                    else
                    {
                        unauthorisedURL = "/Unauthorised.html";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "UnauthorisedURL");
                    }
                }

                return unauthorisedURL;
            }
        }

        public string DataFolderName
        {
            get
            {
                if (String.IsNullOrEmpty(dataFolderName))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["DataFolderName"].ToString().Trim()))
                    {
                        dataFolderName = ConfigurationManager.AppSettings["DataFolderName"].ToString().Trim();
                    }
                    else
                    {
                        dataFolderName = "IndicoData";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "DataFolderName");
                    }
                }
                return dataFolderName;
            }
        }

        public string ImageFolderName
        {
            get
            {
                if (String.IsNullOrEmpty(imageFolderName))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["ImageFolderName"].ToString().Trim()))
                    {
                        imageFolderName = ConfigurationManager.AppSettings["ImageFolderName"].ToString();
                    }
                    else
                    {
                        imageFolderName = "noimage";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "ImageFolderName");
                    }
                }
                return imageFolderName;
            }
        }

        public string PathToProjectFolder
        {
            get
            {
                if (String.IsNullOrEmpty(pathToProjectFolder))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["PathToProjectFolder"].ToString().Trim()))
                    {
                        pathToProjectFolder = ConfigurationManager.AppSettings["PathToProjectFolder"].ToString().Trim();
                    }
                    else
                    {
                        pathToProjectFolder = "C:\\Indico\\IndicoData";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "PathToProjectFolder");
                    }
                }
                return pathToProjectFolder;
            }
        }

        public string PathToAssemblies
        {
            get
            {
                if (String.IsNullOrEmpty(pathToAssembyFolder))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["AssembyFolderName"].ToString().Trim()))
                    {
                        pathToAssembyFolder = PathToProjectFolder + "\\" + ConfigurationManager.AppSettings["AssembyFolderName"].ToString().Trim();
                    }
                    else
                    {
                        pathToAssembyFolder = "C:\\Indico\\Assemblies";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "AssembyFolderName");
                    }
                }
                return pathToAssembyFolder;
            }
        }

        public string PathToDataFolder
        {
            get
            {
                if (String.IsNullOrEmpty(pathToDataFolder))
                {
                    pathToDataFolder = (PathToProjectFolder + "\\" + DataFolderName);
                }
                return pathToDataFolder;
            }
        }

        public string PathToImageFolder
        {
            get
            {
                if (String.IsNullOrEmpty(pathToImageFolder))
                {
                    pathToImageFolder = (PathToDataFolder + "\\" + ImageFolderName);
                }
                return pathToImageFolder;
            }
        }

        public string DefaultLocale
        {
            get
            {
                if (String.IsNullOrEmpty(defaultLocale))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["DefaultLocale"].ToString().Trim()))
                    {
                        defaultLocale = ConfigurationManager.AppSettings["DefaultLocale"].ToString();
                    }
                    else
                    {
                        defaultLocale = "en-AU";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "DefaultLocale");
                    }
                }

                return defaultLocale;
            }
        }

        public int DirectoryLocation
        {
            get
            {
                if (directoryCodeMaxValue == 0)
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["DirectoryCodeMaxValue"].ToString().Trim()))
                    {
                        try
                        {
                            directoryCodeMaxValue = int.Parse(ConfigurationManager.AppSettings["DirectoryCodeMaxValue"].ToString().Trim());
                        }
                        catch
                        {
                            directoryCodeMaxValue = 100;
                            IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "DirectoryCodeMaxValue");
                        }
                    }
                    else
                    {
                        directoryCodeMaxValue = 100;
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "DirectoryCodeMaxValue");
                    }
                }

                return directoryCodeMaxValue;
            }
        }

        public string ReleasedDateTime
        {
            get
            {
                if (String.IsNullOrEmpty(releaseDateTime))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["ReleaseDateTime"].ToString().Trim()))
                    {
                        releaseDateTime = ConfigurationManager.AppSettings["ReleaseDateTime"].ToString();
                        try
                        {
                            releaseDateTime = DateTime.Parse(releaseDateTime).ToString("ddd, d MMM yyyy hh:mm tt");
                        }
                        catch
                        {
                            releaseDateTime = "Tue, 01st Mar 2011 01:28 PM";
                        }
                    }
                    else
                    {
                        releaseDateTime = "Tue, 01st Mar 2011 01:28 PM";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "ReleaseDateTime");
                    }
                }

                return releaseDateTime;
            }
        }

        public string SiteHostAddress
        {
            get
            {
                if (String.IsNullOrEmpty(siteHostAddress))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["SiteHostAddress"].ToString().Trim()))
                    {
                        siteHostAddress = ConfigurationManager.AppSettings["SiteHostAddress"].ToString();
                    }
                    else
                    {
                        siteHostAddress = "local-indico.com";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "SiteHostAddress");
                    }
                }

                return siteHostAddress;
            }
        }

        public string DNSServername
        {
            get
            {
                if (String.IsNullOrEmpty(dNSServername))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["DNSServername"].ToString().Trim()))
                    {
                        dNSServername = ConfigurationManager.AppSettings["DNSServername"].ToString();
                    }
                    else
                    {
                        dNSServername = "Server";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "DNSServername");
                    }
                }

                return dNSServername;
            }
        }

        public string DNSUsername
        {
            get
            {
                if (String.IsNullOrEmpty(dNSUsername))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["DNSUsername"].ToString().Trim()))
                    {
                        dNSUsername = ConfigurationManager.AppSettings["DNSUsername"].ToString();
                    }
                    else
                    {
                        dNSUsername = "Username";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "DNSUsername");
                    }
                }

                return dNSUsername;
            }
        }

        public string DNSPassword
        {
            get
            {
                if (String.IsNullOrEmpty(dNSPassword))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["DNSPassword"].ToString().Trim()))
                    {
                        dNSPassword = ConfigurationManager.AppSettings["DNSPassword"].ToString();
                    }
                    else
                    {
                        dNSPassword = "Password";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "DNSPassword");
                    }
                }

                return dNSPassword;
            }
        }

        public string DomainName
        {
            get
            {
                if (String.IsNullOrEmpty(domainName))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["DomainName"].ToString().Trim()))
                    {
                        domainName = ConfigurationManager.AppSettings["DomainName"].ToString();
                    }
                    else
                    {
                        domainName = "crosstivity.com";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "DomainName");
                    }
                }

                return domainName;
            }
        }

        public string IISSiteName
        {
            get
            {
                if (String.IsNullOrEmpty(iISSiteName))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["IISSiteName"].ToString().Trim()))
                    {
                        iISSiteName = ConfigurationManager.AppSettings["IISSiteName"].ToString();
                    }
                    else
                    {
                        iISSiteName = "Indico";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "IISSiteName");
                    }
                }

                return iISSiteName;
            }
        }

        public string IndimanAdministratorEmail
        {
            get
            {
                if (String.IsNullOrEmpty(indimanAdministratoremail))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["IndimanAdminEmail"].ToString().Trim()))
                    {
                        indimanAdministratoremail = ConfigurationManager.AppSettings["IndimanAdminEmail"].ToString();
                    }
                    else
                    {
                        indimanAdministratoremail = "prakash@indico.net.au";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "IndimanAdministratorEmail");
                    }
                }

                return indimanAdministratoremail;
            }
        }

        public string IndicoAdministratorEmail
        {
            get
            {
                if (String.IsNullOrEmpty(indicoAdministratoremail))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["IndicoAdminEmail"].ToString().Trim()))
                    {
                        indicoAdministratoremail = ConfigurationManager.AppSettings["IndicoAdminEmail"].ToString();
                    }
                    else
                    {
                        indicoAdministratoremail = "mark@indico.net.au";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "IndicoAdministratorEmail");
                    }
                }

                return indicoAdministratoremail;
            }
        }

        public string FactoryAdministratorEmail
        {
            get
            {
                if (String.IsNullOrEmpty(factoryAdminstratoremail))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["FactoryAdminEmail"].ToString().Trim()))
                    {
                        factoryAdminstratoremail = ConfigurationManager.AppSettings["FactoryAdminEmail"].ToString();
                    }
                    else
                    {
                        factoryAdminstratoremail = "prakash@indico.net.au";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "FactoryAdministratorEmail");
                    }
                }

                return factoryAdminstratoremail;
            }
        }

        public string PriceCCMail
        {
            get
            {
                if (String.IsNullOrEmpty(priceccmail))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["ccPriceMail"].ToString().Trim()))
                    {
                        priceccmail = ConfigurationManager.AppSettings["ccPriceMail"].ToString();
                    }
                    else
                    {
                        priceccmail = "mark@indico.net.au";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "PriceCCMail");
                    }
                }

                return priceccmail;
            }
        }

        public string HttpPostGuid
        {
            get
            {
                if (String.IsNullOrEmpty(httppostguid))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["HttpPostGuid"].ToString().Trim()))
                    {
                        httppostguid = ConfigurationManager.AppSettings["HttpPostGuid"].ToString();
                    }
                    else
                    {
                        httppostguid = "0b186383-e0c9-45f6-80c5-7dab57389a0b";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "HttpPostGuid");
                    }
                }

                return httppostguid;
            }
        }

        public string HttpPostURL
        {
            get
            {
                if (String.IsNullOrEmpty(httpposturl))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["HttpPostURL"].ToString().Trim()))
                    {
                        httpposturl = ConfigurationManager.AppSettings["HttpPostURL"].ToString();
                    }
                    else
                    {
                        httpposturl = "http://www.wearebuildingstuff.net.au/SSL/SA/Blackchrome/Sportswear/export_gspec.php";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "HttpPostURL");
                    }
                }

                return httpposturl;
            }
        }

        public string MyObCompanyFile
        {
            get
            {
                if (String.IsNullOrEmpty(_myobCompanyFile))
                {
                    if (!String.IsNullOrEmpty(ConfigurationManager.AppSettings["MyObCompanyFile"].ToString().Trim()))
                    {
                        _myobCompanyFile = ConfigurationManager.AppSettings["MyObCompanyFile"].ToString();
                    }
                    else
                    {
                        _myobCompanyFile = "Indico Manufacturing Pty Ltd";
                        IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "MyObCompanyFile");
                    }
                }

                return _myobCompanyFile;
            }
        }

        public string MyoBDeveloperKey
        {
            get
            {
                if (!string.IsNullOrEmpty(_myobDeveloperKey)) 
                    return _myobDeveloperKey;
                if (!string.IsNullOrEmpty(ConfigurationManager.AppSettings["MyoBDeveloperKey"].Trim()))
                {
                    _myobDeveloperKey = ConfigurationManager.AppSettings["MyoBDeveloperKey"];
                }
                else
                {
                    _myobDeveloperKey = "AccountRight";//"a5zjfk9qn279fb5ke96m2j7c";
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "MyoBDeveloperKey");
                }
                return _myobDeveloperKey;
            }
        }

        public string MyoBDeveloperSecretKey
        {
            get
            {
                if (!string.IsNullOrEmpty(_myobDeveloperSecretKey))
                    return _myobDeveloperSecretKey;
                if (!string.IsNullOrEmpty(ConfigurationManager.AppSettings["MyoBDeveloperSecretKey"].Trim()))
                {
                    _myobDeveloperSecretKey = ConfigurationManager.AppSettings["MyoBDeveloperSecretKey"];
                }
                else
                {
                    _myobDeveloperSecretKey = "KtBYHjZHlPi2NOXH6Gl0";//"dh3WMkh5TpGMwQeuktEPDnST";
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", "MyoBDeveloperSecretKey");
                }
                return _myobDeveloperSecretKey;
            }
        }

        public int MyobItemCostOfSaleAccounNumber
        {
            get
            {
                const string propertyName = "MyobItemCostOfSaleAccounNumber";
                if (_myobItemCostOfSaleAccounNumber != 0)

                    return _myobItemCostOfSaleAccounNumber;
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings[propertyName]))
                {
                    _myobItemCostOfSaleAccounNumber = Convert.ToInt32(ConfigurationManager.AppSettings[propertyName]);
                }
                else
                {
                    _myobItemCostOfSaleAccounNumber = 5025;
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", propertyName);
                }
                return _myobItemCostOfSaleAccounNumber;
            }
        }

        public int MyobItemIncomeAccountNumber
        {
            get
            {

                if (_myobItemIncomeAccountNumber != 0)
                    return _myobItemIncomeAccountNumber;

                const string propertyName = "MyobItemIncomeAccountNumber";
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings[propertyName]))
                {
                    _myobItemIncomeAccountNumber = Convert.ToInt32(ConfigurationManager.AppSettings[propertyName]);
                }
                else
                {
                    _myobItemIncomeAccountNumber = 1070;
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", propertyName);
                }
                return _myobItemIncomeAccountNumber;
            }
        }

        public int MyobItemAssetAccountNumber
        {
            get
            {
                if (_myobItemAssetAccountNumber != 0)
                    return _myobItemAssetAccountNumber;
                const string propertyName = "MyobItemAssetAccountNumber";
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings[propertyName]))
                {
                    _myobItemAssetAccountNumber = Convert.ToInt32(ConfigurationManager.AppSettings[propertyName]);
                }
                else
                {
                    _myobItemAssetAccountNumber = 5030;
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", propertyName);
                }
                return _myobItemAssetAccountNumber;
            }
        }

        public string MyobOAuthUrl
        {
            get
            {
                if (!string.IsNullOrWhiteSpace(_myobOAuthUrl))
                    return _myobOAuthUrl;
                const string propertyName = "MyobOAuthUrl";
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings[propertyName]))
                {
                    _myobOAuthUrl = ConfigurationManager.AppSettings[propertyName];
                }
                else
                {
                    _myobOAuthUrl = "https://secure.myob.com/oauth2/v1/authorize";
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", propertyName);
                }
                return _myobOAuthUrl;
            }
        }

        public string MyobClientId
        {
            get
            {
                if (!string.IsNullOrWhiteSpace(_myobClientId))
                    return _myobClientId;
                const string propertyName = "MyobClientId";
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings[propertyName]))
                {
                    _myobClientId = ConfigurationManager.AppSettings[propertyName];
                }
                else
                {
                    _myobClientId = "AccountRight";
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", propertyName);
                }
                return _myobClientId;
            }
        }

        public string MyobClientSecret
        {
            get
            {
                if (!string.IsNullOrWhiteSpace(_myobClientSecret))
                    return _myobClientSecret;
                const string propertyName = "MyobClientSecret";
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings[propertyName]))
                {
                    _myobClientSecret = ConfigurationManager.AppSettings[propertyName];
                }
                else
                {
                    _myobClientSecret = "KtBYHjZHlPi2NOXH6Gl0";
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", propertyName);
                }
                return _myobClientSecret;
            }
        }

        public string MyobScope
        {
            get
            {
                if (!string.IsNullOrWhiteSpace(_myobScope))
                    return _myobScope;
                const string propertyName = "MyobScope";
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings[propertyName]))
                {
                    _myobScope = ConfigurationManager.AppSettings[propertyName];
                }
                else
                {
                    _myobScope = "CompanyFile mydot.assets.read mydot.applications.write";
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", propertyName);
                }
                return _myobScope;
            }
        }

        public string MyobUsername
        {
            get
            {
                if (!string.IsNullOrWhiteSpace(_myobUsername))
                    return _myobUsername;
                const string propertyName = "MyobUsername";
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings[propertyName]))
                {
                    _myobUsername = ConfigurationManager.AppSettings[propertyName];
                }
                else
                {
                    _myobUsername = "prakashs@blackchrome.com.au";
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", propertyName);
                }
                return _myobUsername;
            }
        }

        public string MyobPassword
        {
            get
            {
                if (!string.IsNullOrWhiteSpace(_myobPassword))
                    return _myobPassword;
                const string propertyName = "MyobPassword";
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings[propertyName]))
                {
                    _myobPassword = ConfigurationManager.AppSettings[propertyName];
                }
                else
                {
                    _myobPassword = "Prk95h12#";
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", propertyName);
                }
                return _myobPassword;
            }
        }

        public string ImagesFtpUrl
        {
            get
            {
                if (!string.IsNullOrWhiteSpace(_imagesFtpUrl))
                    return _imagesFtpUrl;
                const string propertyName = "ImagesFtpUrl";
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings[propertyName]))
                {
                    _imagesFtpUrl = ConfigurationManager.AppSettings[propertyName];
                }
                else
                {
                    _imagesFtpUrl = "ftp://mail.indico.net.au/";
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", propertyName);
                }
                return _imagesFtpUrl;
            }
        }
        public string ImagesFtpUserName
        {
            get
            {
                if (!string.IsNullOrWhiteSpace(_imagesFtpUserName))
                    return _imagesFtpUserName;
                const string propertyName = "ImagesFtpUserName";
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings[propertyName]))
                {
                    _imagesFtpUserName = ConfigurationManager.AppSettings[propertyName];
                }
                else
                {
                    _imagesFtpUserName = "siwanka";
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", propertyName);
                }
                return _imagesFtpUserName;
            }
        }

        public string ImagesFtpPassword
        {
            get
            {
                if (!string.IsNullOrWhiteSpace(_imagesFtpPassword))
                    return _imagesFtpPassword;
                const string propertyName = "ImagesFtpPassword";
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings[propertyName]))
                {
                    _imagesFtpPassword = ConfigurationManager.AppSettings[propertyName];
                }
                else
                {
                    _imagesFtpPassword = "Siwanka99";
                    IndicoLogging.log.ErrorFormat("IndicoConfiguration class: Unable to retrieve the config value for {0}", propertyName);
                }
                return _imagesFtpPassword;
            }


        }


        public static Thread GetContextAwareThread(ThreadStart s)
        {
            Thread t = new Thread(s);

            // Ensure the new Thread gets the same ownership settings as the CurrentThread
            rwl.AcquireWriterLock(Timeout.Infinite);
            try
            {
                //m_htOwnerCompanyID[t] = OwnerCompanyID;
                //m_htAccountID[t] = AccountID;
            }
            finally
            {
                rwl.ReleaseWriterLock();
            }

            return t;
        }

        #endregion

        
    }
}
