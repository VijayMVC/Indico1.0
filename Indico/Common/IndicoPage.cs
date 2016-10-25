using Dapper;
using Indico.BusinessObjects;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.UI.WebControls;

namespace Indico.Common
{
    /// <summary>
    /// IndicoPage extends System.Web.UI.Page and handles functionality like 
    /// ensuring the user has a valid session and is logged in, error handling and Validation failure
    /// </summary>
    public class IndicoPage : System.Web.UI.Page
    {
        #region Fields

        private IndicoContext indicoContext = null;

        private CompanyBO currentCompany = null;
        private UserBO currentUser = null;
        private CompanyBO distributor = null;
        private RoleBO currentUserRole = null;
        private PageBO currentPage = null;

        private int siteAdministrator = -1;
        private string tempLocation = string.Empty;
        private static ReaderWriterLock rwl;

        #endregion





        #region Properties

        /// <summary>
        /// Get the Indico site client browsing page. 
        /// If not exist then retuns null.
        /// </summary>
        public IndicoPage CurrentPage
        {
            get
            {
                if (this.Page.GetType().IsSubclassOf(System.Type.GetType("Indico.Common.IndicoPage")))
                    return ((IndicoPage)this.Page);

                else return null;
            }
        }

        /// <summary>
        /// Get the IndicoContext of the page. 
        /// If not exist then create a new one and return it.
        /// </summary>
        public IndicoContext ObjContext
        {
            get
            {
                if (indicoContext == null)
                {
                    indicoContext = new IndicoContext();
                }
                return indicoContext;
            }
        }

        /// <summary>
        /// Gets the looged user who accessing the page, or null if no user is valid.
        /// </summary>
        public UserBO LoggedUser
        {
            get
            {
                if (this.currentUser != null)
                {
                    return currentUser;
                }

                if (Session["in_uid"] != null)
                {
                    currentUser = new UserBO(this.ObjContext);
                    currentUser.ID = Convert.ToInt32(Session["in_uid"]);
                    currentUser.GetObject();
                }
                else
                {
                    currentUser = null;
                }
                return currentUser;
            }
        }

        public CompanyBO Distributor
        {
            get
            {
                if (this.distributor != null)
                {
                    return distributor;
                }

                distributor = new CompanyBO();
                //distributor.Name = "BLACKCHROME -" + this.LoggedUser.GivenName.ToUpper() + " " + this.LoggedUser.FamilyName.ToUpper();
                distributor.Owner = this.LoggedUser.ID;
                distributor = distributor.SearchObjects().SingleOrDefault();

                //if (distributor == null)
                //{
                //    distributor = new CompanyBO();
                //    distributor.Name = "BLACKCHROME - " + this.LoggedUser.GivenName.ToUpper() + " " + this.LoggedUser.FamilyName.ToUpper();
                //    distributor = distributor.SearchObjects().SingleOrDefault();
                //}
                return distributor;
            }
        }

        /// <summary>
        /// Gets the logged user role who accessing the page, or null if no user is valid.
        /// </summary>
        public RoleBO LoggedUserRole
        {
            get
            {
                if (this.currentUserRole != null)
                {
                    return currentUserRole;
                }

                if (Session["in_rid"] != null)
                {
                    currentUserRole = new RoleBO(this.ObjContext);
                    currentUserRole.ID = Convert.ToInt32(Session["in_rid"]);
                    currentUserRole.GetObject();
                }
                else if (this.LoggedUser != null && this.LoggedUser.ID > 0)
                {
                    List<RoleBO> lstRole = this.LoggedUser.UserRolesWhereThisIsUser;
                    if (lstRole.Count > 0)
                    {
                        currentUserRole = new RoleBO(this.ObjContext);
                        currentUserRole.ID = lstRole[0].ID;
                        currentUserRole.GetObject();
                    }
                    else
                    {
                        currentUserRole = null;
                    }
                }
                else
                {
                    currentUserRole = null;
                }
                return currentUserRole;
            }
        }

        /// <summary>
        /// Gets the logged user company who accessing the page, or null if no user is valid.
        /// </summary>
        public CompanyBO LoggedCompany
        {
            get
            {
                if (currentCompany != null)
                {
                    return currentCompany;
                }

                if (Session["in_cid"] != null)
                {
                    currentCompany = new CompanyBO(this.ObjContext);
                    currentCompany.ID = Convert.ToInt32(Session["in_cid"]);
                    currentCompany.GetObject();

                    return currentCompany;
                }
                else if (this.LoggedUser != null && this.LoggedUser.ID > 0)
                {
                    currentCompany = new CompanyBO(this.ObjContext);
                    currentCompany.ID = this.LoggedUser.Company;
                    currentCompany.GetObject();
                }
                else
                {
                    currentCompany = null;
                }
                return currentCompany;
            }
        }

        public CompanyType LoggedCompanyType
        {
            get
            {
                return this.GetUserCompanyType();
            }
        }

        public PageBO ActivePage
        {
            get
            {
                if (currentPage != null)
                    return currentPage;

                List<PageBO> lstPages = (from o in (new PageBO()).GetAllObject()
                                         where o.Name.ToLower().EndsWith(this.Name.ToLower())
                                         select o).ToList<PageBO>();
                if (lstPages.Count > 0)
                {
                    currentPage = lstPages[0];
                }
                return currentPage;
            }
        }

        public UserRole LoggedUserRoleName
        {
            get
            {
                return this.GetUserRole(this.LoggedUserRole.ID);
            }
        }

        /// <summary>
        /// The Name (Class name without _aspx extension) of the current page
        /// </summary>
        public string Name
        {
            get
            {
                string pageName = this.GetType().Name;
                string ext = pageName.Split('_').Last();
                pageName = pageName.Substring(0, pageName.LastIndexOf('_')) + "." + ext;
                if (pageName.Contains('_'))
                {
                    pageName = pageName.Split('_').Last();
                }
                return pageName;
            }
        }

        /// <summary>
        /// The Name (Filename without extension) of the current page
        /// </summary>
        public string UrlName
        {
            get
            {
                string str = Request.Url.Segments[Request.Url.Segments.Length - 1];
                return str.Substring(0, str.LastIndexOf("."));
            }
        }

        /// <summary>
        /// The Filename (last segment in th URL) of the current page
        /// </summary>
        public string Filename
        {
            get
            {
                return Request.Url.Segments[Request.Url.Segments.Length - 1];
            }
        }

        /// <summary>
        /// True if the application is in Development mode. If the value of the AppSetting "strEnvironment" is "dev", then this returns true
        /// </summary>
        public bool IsDevelopmentMode
        {
            get
            {
                return (IndicoConfiguration.AppConfiguration.Environment.ToLower() == "dev") ? true : false;
            }
        }

        /// <summary>
        /// True if the application is in debug mode. This reflects the value of the AppSetting "blnIsDebugMode"
        /// </summary>
        public bool IsDebugMode
        {
            get
            {
                return IndicoConfiguration.AppConfiguration.IsDebugMode;
            }
        }

        /// <summary>
        /// True if the application is in Maintenance mode. This reflects the value of the AppSetting "blnIsMaintenanceMode"
        /// </summary>
        public bool IsMaintenanceMode
        {
            get
            {
                return IndicoConfiguration.AppConfiguration.IsMaintenanceMode;
            }
        }

        /// <summary>
        /// The location of the Maintenance URL. This reflects the value of the AppSetting "strMaintenanceURL"
        /// </summary>
        public string MaintenanceURL
        {
            get
            {
                return IndicoConfiguration.AppConfiguration.MaintenanceURL;
            }
        }

        /// <summary>
        /// The location of the Unauthorised URL. This reflects the value of the AppSetting "strUnauthorisedURL"
        /// </summary>
        public string UnauthorisedURL
        {
            get
            {
                return IndicoConfiguration.AppConfiguration.UnauthorisedURL;
            }
        }

        /// <summary>
        /// The location of the Error URL. This reflects the value of the AppSetting "strErrorURL"
        /// </summary>
        public string ErrorURL
        {
            get
            {
                return IndicoConfiguration.AppConfiguration.ErrorURL;
            }
        }

        public bool IsSiteAdministrator
        {
            get
            {
                if (siteAdministrator > 0)
                {
                    return Convert.ToBoolean(siteAdministrator);
                }

                bool isAdministrator = ((this.LoggedUser.Username == "Administrator") && (this.LoggedUserRole != null) && (this.LoggedUserRole.ID == 1));
                siteAdministrator = Convert.ToInt32(isAdministrator);

                return isAdministrator;
            }
        }

        public string UserTempFolder
        {
            get
            {
                if (tempLocation != string.Empty)
                {
                    return tempLocation;
                }

                tempLocation = (this.LoggedCompany.ID.ToString() + this.LoggedUser.ID.ToString());
                return tempLocation;
            }
        }

        public FileInfo[] ClientUploadFiles
        {
            get
            {
                string folderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + this.UserTempFolder;
                DirectoryInfo folderInfo = new DirectoryInfo(folderPath);
                return folderInfo.GetFiles();
            }
        }

        public bool IsNotRefresh
        {
            get
            {
                return (Session["IsPostBack"].ToString() == ViewState["IsPostBack"].ToString());
            }
        }

        public static ReaderWriterLock RWLock
        {
            get
            {
                if (rwl == null)
                {
                    rwl = new ReaderWriterLock();
                }
                return rwl;
            }
        }

        /// <summary>
        /// SqlConnection to the databse using the connection string -> ConnectionStrings["DefaultConnection"]
        /// </summary>
        protected SqlConnection DatabaseConnection
        {
            get
            {
                return new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
            }
        } 

        #endregion

        #region Constructors

        /// <summary>
        /// Create a new instance of IndicoPage
        /// </summary>
        public IndicoPage()
        {
            this.Init += new EventHandler(IndicoPage_Init);
            this.Error += new EventHandler(IndicoPage_Error);
            this.Unload += new EventHandler(IndicoPage_Unload);
        }

        #endregion

        #region Event Handlers

        /*protected override void OnPreRender(EventArgs e)
        {
            //Page Refresh
            Session["IsPostBack"] = Server.UrlEncode(Guid.NewGuid().ToString());
            ViewState["IsPostBack"] = Session["IsPostBack"];
        }*/

        private void IndicoPage_Init(object sender, EventArgs e)
        {
            // Set Date Time format
            System.Threading.Thread.CurrentThread.CurrentCulture = new System.Globalization.CultureInfo("en-AU");

            // Deny anonymous browsers - when Request.UserAgent is null or 0 length
            // it makes the code in Login.aspx.cs fail with an exception that then gets logged
            // 100 times a day currently. 
            if (Request.UserAgent == null || Request.UserAgent.Length == 0)
            {
                IndicoLogging.log.DebugFormat("IndicoPage.IndicoPage_Init() Anonymous User Agent at {0} has been denied access", Request.UserHostAddress);
                Response.Write(String.Format("Anonymous User Agent at {0} has been denied access", Request.UserHostAddress));
                Response.Flush();
                Response.End();
            }

            if ((Server.GetLastError() == null) && (this.Name.ToLower() != "login.aspx") && (this.Name.ToLower() != "logout.aspx") && (this.Name.ToLower() != "default.aspx") && (this.Name.ToLower() != "welcome.aspx") && (this.Name.ToLower() != "lostpassword.aspx"))
            {
                if ((this.LoggedUser != null) && (this.Name.ToLower() != "error.aspx"))
                {
                    //Remember the user based cookies this must be exists
                    Session["Unique"] = "expand" + this.ActivePage.ID.ToString() + this.LoggedUser.ID.ToString();
                }
                // have we lost our user/session or not logged in at all?
                else
                {
                    if (this.Name.ToLower() != "default")
                    {
                        this.Response.Redirect("/Login.aspx?do=" + Server.UrlEncode(Request.Url.AbsoluteUri));
                    }
                    else
                    {
                        this.Response.Redirect("/Login.aspx");
                    }
                }

                if (this.IsDevelopmentMode && Request.Params.Get("refresh") != null)
                {
                    IndicoLogging.log.InfoFormat("IndicoPage.IndicoPage_Init() {1} {2} (ID:{3}) requested a cache refresh for host {0}",
                                                 Request.Url.Host, this.LoggedUser.GivenName, this.LoggedUser.FamilyName, this.LoggedUser.ID);
                }
            }
        }

        private void IndicoPage_Error(object sender, EventArgs e)
        {
            // In some cases, the transaction might still be alive holding a process lock on SQL
            if (this.ObjContext != null)
            {
                this.ObjContext.Dispose();
            }
        }

        private void IndicoPage_Unload(object sender, EventArgs e)
        {
            if (this.ObjContext != null)
            {
                this.ObjContext.Dispose();
            }

            /*if (this.LoggedAccount != null && this.LoggedUser != null)
            {
                Thread t = new Thread(new ThreadStart(this.DeleteTempFiles));
                t.Start();                
            }*/
        }

        #endregion

        #region Methods

        /// <summary>
        /// Terminates a user's session
        /// </summary>
        public static void EndSession(ref UserBO LoggedUser)
        {
            if (HttpContext.Current.Session["in_uid"] != null)
            {
                UserLoginBO objLogin = new UserLoginBO();
                objLogin.ID = Convert.ToInt32(HttpContext.Current.Session["in_uid"]);
                objLogin.GetObject();

                objLogin.DateLogout = DateTime.Now;
            }

            LoggedUser = null;
            HttpContext.Current.Session["in_sid"] = null;
            HttpContext.Current.Session["in_cid"] = null;
            HttpContext.Current.Session["in_uid"] = null;
            HttpContext.Current.Session.Abandon();
        }

        /// <summary>
        /// Delete temporary files
        /// </summary>
        private void DeleteTempFiles()
        {
            string tmpFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + this.UserTempFolder;

            if (Directory.Exists(tmpFolderPath))
            {
                foreach (string file in Directory.GetFiles(tmpFolderPath))
                {
                    if (File.Exists(file))
                    {
                        try
                        {
                            File.Delete(file);
                        }
                        catch (Exception ex)
                        {
                            IndicoLogging.log.WarnFormat("IndicoPage (" + this.GetType().FullName + ") could not delete temporary file " + file +
                                                         " for User ID " + this.LoggedUser.ID + " because \"" + ex.Message + "\"");
                        }
                    }
                }
            }

            /* old 
            if (this.temporaryFiles != null)
            {
                foreach (string f in this.temporaryFiles)
                {
                    FileInfo fi = new FileInfo(f);
                    int c = 1;
                    while (fi.Exists && c != 1000)
                    {
                        try
                        {
                            fi.Delete();
                            Thread.Sleep(50);
                            fi = new FileInfo(f);
                            c++;
                        }
                        catch (Exception ex)
                        {
                            Thread.Sleep(50);
                            fi = new FileInfo(f);
                            c++;
                            if (c == 1000)
                            {
                                IndicoLogging.log.WarnFormat("IndicoPage ({0}) could not delete temporary file {1} for User ID {3} because \"{2}\"",
                                    this.GetType().FullName,
                                    f,
                                    ex.Message,
                                    this.LoggedUser.ID);
                            }
                        }
                    }
                }

                this.temporaryFiles = null;
            }
            */
        }

        public static void EmptyDirectory(DirectoryInfo directory)
        {
            foreach (FileInfo file in directory.GetFiles()) file.Delete();
            foreach (DirectoryInfo subDirectory in directory.GetDirectories()) subDirectory.Delete(true);
        }

        /// <summary>
        /// Get the Directory Path
        /// </summary>
        public static string GetDirectoryPath(int dirLocation, string seperator)
        {
            string dirPath = string.Empty;

            if (dirLocation > 0)
            {
                string strLocation = Convert.ToString(dirLocation);
                char[] chrLocation = strLocation.ToCharArray();

                for (int i = 0; i < chrLocation.Length; i++)
                {
                    dirPath += chrLocation[i].ToString();
                    dirPath += seperator;
                }
            }
            return dirPath;
        }

        public void DownloadFileWithResponse(string filePath, HttpResponse response)
        {
            FileInfo fileInfo = new FileInfo(filePath);

            response.ClearContent();
            response.ContentType = MimeType(fileInfo.Name);
            response.AddHeader("Content-Disposition", string.Format("attachment; filename = {0}", fileInfo.Name));
            response.AddHeader("Content-Length", (fileInfo.Length).ToString("F0"));
            response.TransmitFile(filePath);
            response.End();
        }

        private string MimeType(string fileName)
        {
            string ext = Path.GetExtension(fileName).ToLower();
            string mime = "application/octetstream";

            if (string.IsNullOrEmpty(ext))
            {
                return mime;
            }
            else
            {
                Microsoft.Win32.RegistryKey regKey = Microsoft.Win32.Registry.ClassesRoot.OpenSubKey(ext);

                if (regKey != null && regKey.GetValue("Content Type") != null)
                {
                    mime = regKey.GetValue("Content Type").ToString();
                }
                return mime;
            }
        }

        public static bool IsImageFile(string Extension)
        {
            Extension = Extension.ToLower();

            if (Extension == ".jpg" || Extension == ".jpeg"
                || Extension == ".tif" || Extension == ".tiff"
                || Extension == ".png" || Extension == ".gif" || Extension == ".bmp")
            {
                return true;
            }

            return false;
        }

        public static void ClearTemp()
        {
            string tempPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Temp";

            List<string> lstTmpFiles = Directory.GetFiles(tempPath).ToList();
            foreach (string file in lstTmpFiles)
            {
                try
                {
                    File.Delete(file);
                }
                catch { }
            }
        }

        public void DownloadFile(string filePath)
        {
            FileInfo fileInfo = new FileInfo(filePath);

            Response.ClearContent();
            Response.ContentType = MimeType(fileInfo.Name);
            Response.AddHeader("Content-Disposition", string.Format("attachment; filename = {0}", fileInfo.Name));
            Response.AddHeader("Content-Length", (fileInfo.Length).ToString("F0"));
            Response.TransmitFile(filePath);
            Response.End();
        }

        public void DownloadPDFFile(string filePath)
        {
            var fileInfo = new FileInfo(filePath);
            var outputName = System.Text.RegularExpressions.Regex.Replace(fileInfo.Name, @"\W+", "_");
            outputName = System.Text.RegularExpressions.Regex.Replace(outputName, "_pdf", ".pdf");
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Content-Type", "application/pdf");
            Response.AddHeader("Content-Disposition", string.Format("attachment; filename = {0}", outputName));
            Response.AddHeader("Content-Length", (fileInfo.Length).ToString("F0"));
            Response.TransmitFile(filePath);
            Response.Flush();
            Response.Close();
            Response.BufferOutput = true;
        }

        public void DownloadFile(string filePath, HttpResponse response)
        {
            FileInfo fileInfo = new FileInfo(filePath);

            response.ClearContent();
            response.ContentType = MimeType(fileInfo.Name);
            response.AddHeader("Content-Disposition", string.Format("attachment; filename = {0}", fileInfo.Name));
            response.AddHeader("Content-Length", (fileInfo.Length).ToString("F0"));
            response.TransmitFile(filePath);
            response.End();
        }

        public void DownloadExcelFile(string filePath)
        {
            FileInfo fileInfo = new FileInfo(filePath);
            string outputName = System.Text.RegularExpressions.Regex.Replace(fileInfo.Name, @"\W+", "_");
            outputName = System.Text.RegularExpressions.Regex.Replace(outputName, "_xlsx", ".xlsx");
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Content-Type", "application/vnd.ms-excel");
            Response.AddHeader("Content-Disposition", string.Format("attachment; filename = {0}", outputName));
            Response.AddHeader("Content-Length", (fileInfo.Length).ToString("F0"));
            Response.TransmitFile(filePath);
            Response.Flush();
            Response.Close();
            Response.BufferOutput = true;
        }

        public UserRole GetUserRole(int roleId)
        {
            switch (roleId)
            {
                case 1: return UserRole.SiteAdministrator;
                case 2: return UserRole.FactoryAdministrator;
                case 3: return UserRole.FactoryCoordinator;
                case 4: return UserRole.FactoryPatternDeveloper;
                case 5: return UserRole.IndimanAdministrator;
                case 6: return UserRole.IndimanCoordinator;
                case 7: return UserRole.IndicoAdministrator;
                case 8: return UserRole.IndicoCoordinator;
                case 9: return UserRole.IndicoPatternDeveloper;
                case 10: return UserRole.DistributorAdministrator;
                case 11: return UserRole.DistributorCoordinator;
                default: return UserRole.NotAssigned;
            }
        }

        public CompanyType GetUserCompanyType()
        {
            switch (this.LoggedCompany.Type)
            {
                case 1: return CompanyType.Factory;
                case 2: return CompanyType.Manufacturer;
                case 3: return CompanyType.Sales;
                case 4: return CompanyType.Distributor;
                case 5: return CompanyType.Client;
                default: return CompanyType.NotAssigned;
            }
        }

        public OrderStatus GetOrderStatus(int statusid)
        {
            OrderStatusBO objOrderStatus = new OrderStatusBO();
            objOrderStatus.ID = statusid;
            objOrderStatus.GetObject();

            return GetOrderStatusByBO(objOrderStatus);
        }

        public static OrderStatus GetOrderStatusByBO(OrderStatusBO objOrderStatus)
        {
            return GetOrderStatusByName(objOrderStatus.Name);
        }

        private static OrderStatus GetOrderStatusByName(string name)
        {
            switch (name)
            {
                case "NEW": return OrderStatus.New;
                case "In Progress": return OrderStatus.InProgress;
                case "Partialy Completed": return OrderStatus.PartialyCompleted;
                case "Completed": return OrderStatus.Completed;
                case "Submitted by Distributor": return OrderStatus.DistributorSubmitted;
                case "Indico Hold": return OrderStatus.IndicoHold;
                case "Indico Submitted": return OrderStatus.IndicoSubmitted;
                case "Indiman Hold": return OrderStatus.IndimanHold;
                case "Indiman Submitted": return OrderStatus.IndimanSubmitted;
                case "Factory Hold": return OrderStatus.FactoryHold;
                case "Cancelled": return OrderStatus.Cancelled;
                case "Submitted by Coordinator": return OrderStatus.CoordinatorSubmitted;
                default: return OrderStatus.New;
            }
        }

        public OrderStatusBO GetOrderStatus(OrderStatus status)
        {
            string name = string.Empty;

            switch (status)
            {
                case OrderStatus.New:
                    name = "New";
                    break;
                case OrderStatus.InProgress:
                    name = "In Progress";
                    break;
                case OrderStatus.PartialyCompleted:
                    name = "Partialy Completed";
                    break;
                case OrderStatus.Completed:
                    name = "Completed";
                    break;
                case OrderStatus.DistributorSubmitted:
                    name = "Submitted by Distributor";
                    break;
                case OrderStatus.IndicoHold:
                    name = "Indico Hold";
                    break;
                case OrderStatus.IndicoSubmitted:
                    name = "Indiman Submitted";
                    break;
                case OrderStatus.IndimanHold:
                    name = "Indiman Hold";
                    break;
                case OrderStatus.IndimanSubmitted:
                    name = "Indiman Submitted";
                    break;
                case OrderStatus.FactoryHold:
                    name = "Factory Hold";
                    break;
                case OrderStatus.Cancelled:
                    name = "Cancelled";
                    break;
                case OrderStatus.CoordinatorSubmitted:
                    name = "Submitted by Coordinator";
                    break;
                default:
                    break;
            }


            return (new OrderStatusBO()).GetAllObject().Single(o => o.Name == name);
        }

        //--------Get Image Paths ----------------------//

        public string GetLabelImagePath(int orderDetailId)
        {
            string LabelImagePath = string.Empty;

            OrderDetailBO objOrderDetail = new OrderDetailBO();
            objOrderDetail.ID = orderDetailId;
            objOrderDetail.GetObject();

            if (objOrderDetail.Label > 0)
            {
                LabelImagePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/Labels/" + objOrderDetail.objLabel.LabelImagePath;
            }

            return LabelImagePath;
        }

        public static string GetVLImagePath(int? visualLayoutId)
        {
            string VLImagePath = string.Empty;

            if (visualLayoutId.HasValue && visualLayoutId > 0)
            {
                VisualLayoutBO objVLNumber = new VisualLayoutBO();
                objVLNumber.ID = visualLayoutId.Value;
                objVLNumber.GetObject();

                ImageBO objImage = objVLNumber.ImagesWhereThisIsVisualLayout.SingleOrDefault(o => o.IsHero == true);

                if (objImage != null)
                {
                    VLImagePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/VisualLayout/" + objVLNumber.ID.ToString() + "/" + objImage.Filename + objImage.Extension;

                    if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + VLImagePath))
                    {
                        VLImagePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    }
                }
            }
            return VLImagePath;
        }

        public static string GetVLImagePath(int visualLayout, string fileName, string extension)
        {
            string VLImagePath = string.Empty;

            VLImagePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/VisualLayout/" + visualLayout + "/" + fileName + extension;

            if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + VLImagePath))
            {
                VLImagePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
            }

            return VLImagePath;
        }

        public string GetNameNumberFileIconPath(int orderDetailId)
        {
            OrderDetailBO objOrderDetail = new OrderDetailBO();
            objOrderDetail.ID = orderDetailId;
            objOrderDetail.GetObject();

            string NameAndNumberFilePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/NameAndNumbersFiles/" + objOrderDetail.Order.ToString() + "/" + objOrderDetail.ID.ToString() + "/" + objOrderDetail.NameAndNumbersFilePath;
            string Extension = Path.GetExtension(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + NameAndNumberFilePath).Replace(".", string.Empty);
            string NameAndNumberFileIconPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/FileTypes/" + Extension + ".gif";

            if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + NameAndNumberFileIconPath))
                NameAndNumberFileIconPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/FileTypes/unknown.gif";
            if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + NameAndNumberFilePath))
                NameAndNumberFileIconPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/NameAndNumbersFiles/no_files_found.jpg";

            return NameAndNumberFileIconPath;
        }

        public string GetNameNumberFilePath(int orderDetailId)
        {
            OrderDetailBO objOrderDetail = new OrderDetailBO();
            objOrderDetail.ID = orderDetailId;
            objOrderDetail.GetObject(false);

            string NameAndNumberFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "/NameAndNumbersFiles/" + objOrderDetail.Order.ToString() + "/" + objOrderDetail.ID.ToString() + "/" + objOrderDetail.NameAndNumbersFilePath;
            return NameAndNumberFilePath;

            //return string.Empty;
        }

        public int GetWeekOfYear(DateTime time)
        {
            // Seriously cheat.  If its Monday, Tuesday or Wednesday, then it'll 
            // be the same week# as whatever Thursday, Friday or Saturday are,
            // and we always get those right
            DayOfWeek day = CultureInfo.InvariantCulture.Calendar.GetDayOfWeek(time);
            if (day >= DayOfWeek.Monday && day <= DayOfWeek.Wednesday)
            {
                time = time.AddDays(3);
            }

            // Return the week of our adjusted day
            return CultureInfo.InvariantCulture.Calendar.GetWeekOfYear(time, CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday);
        }

        //-------------------------------------------------//

        public void PopulateFileUploder(Repeater rpt, System.Web.UI.HtmlControls.HtmlInputHidden hdnFileNames)
        {
            try
            {
                (new IndicoFileUpload()).PopulateUploader(rpt, hdnFileNames.Value);
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error Occured while PopulateFileUploder Method", ex);
            }
        }

        public static decimal GetCostSheetPricePerVL(int pattern, int fabricCode)
        {
            decimal calculatedPrice = 0;

            try
            {
                CostSheetBO objPrice = new CostSheetBO();
                objPrice.Pattern = pattern;
                objPrice.Fabric = fabricCode;

                calculatedPrice = objPrice.SearchObjects().Select(o => o.QuotedCIF ?? 0).First();
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error Occured while GetCostSheetPricePerVL Method", ex);
            }

            return calculatedPrice;
        }

        public static decimal CalculateIndimanPricePerVL(int pattern, int fabricCode, int Qty)
        {
            decimal calculatedPrice = 0;
            int priceLevelID = 0;

            if (Qty < 6)
            {
                priceLevelID = 1;
            }
            else if (Qty < 10)
            {
                priceLevelID = 2;
            }
            else if (Qty < 20)
            {
                priceLevelID = 3;
            }
            else if (Qty < 50)
            {
                priceLevelID = 4;
            }
            else if (Qty < 100)
            {
                priceLevelID = 5;
            }
            else if (Qty < 250)
            {
                priceLevelID = 6;
            }
            else if (Qty < 500)
            {
                priceLevelID = 7;
            }
            else
            {
                priceLevelID = 8;
            }

            //if (vl > 0)
            //{
            //    VisualLayoutBO objVisualLayout = new VisualLayoutBO();
            //    objVisualLayout.ID = vl;
            //    objVisualLayout.GetObject();

            //    pattern = objVisualLayout.Pattern;
            //    fabricCode = objVisualLayout.FabricCode ?? 0;
            //}
            //else if (aw > 0)
            //{
            //    ArtWorkBO objArtWork = new ArtWorkBO();
            //    objArtWork.ID = aw;
            //    objArtWork.GetObject();

            //    pattern = objArtWork.Pattern;
            //    fabricCode = objArtWork.FabricCode;
            //}


            PriceBO objPrice = new PriceBO();
            objPrice.Pattern = pattern;
            objPrice.FabricCode = fabricCode;

            int price = objPrice.SearchObjects().Select(o => o.ID).SingleOrDefault();

            if (price > 0)
            {
                PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO();
                objPriceLevelCost.Price = price;
                objPriceLevelCost.PriceLevel = priceLevelID;
                objPriceLevelCost = objPriceLevelCost.SearchObjects()[0];

                calculatedPrice = objPriceLevelCost.IndimanCost;
            }
            //DistributorPriceLevelCostBO objDPLC = new DistributorPriceLevelCostBO();
            //objDPLC.PriceTerm = 1;
            //objDPLC.PriceLevelCost = objPriceLevelCost.ID;

            //List<DistributorPriceLevelCostBO> lstLevelCosts = objDPLC.SearchObjects().Where(m => m.Distributor == null || m.Distributor == 0).ToList();

            //if (lstLevelCosts.Any())
            //{
            //    calculatedPrice = lstLevelCosts[0].IndicoCost;
            //}

            return calculatedPrice;
        }

        public static DateTime GetNextWeekday(DayOfWeek day)
        {
            DateTime result = DateTime.Now.AddDays(1);
            while (result.DayOfWeek != day)
                result = result.AddDays(1);
            return result;
        }

        public static string GetSetting(string key)
        {
            string value = string.Empty;

            try
            {
                SettingsBO objSetting = new SettingsBO();
                objSetting.Key = key;

                objSetting = objSetting.SearchObjects().SingleOrDefault();
                value = objSetting.Value;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error Occured while GetSetting Method", ex);
            }
            return value;
        }

        public static float GetResizedImageDimensionForHeight(string imagePath, float newHeight)
        {
            System.Drawing.Image img = System.Drawing.Image.FromFile(imagePath);
            float originalWidth = img.Width;
            float originalHeight = img.Height;

            float newWidth;
            if (originalHeight > newHeight)
            {
                newWidth = (float)Math.Round(((newHeight / originalHeight) * originalWidth), 0);
            }
            else
            {
                newWidth = originalWidth;
            }

            return newWidth;
        }

        public void SendOrderSubmissionEmail(int OrderID, string receiverEmail, string receiverName, bool Submit, CustomSettings? ccSetting)
        {
            try
            {
                var objOrder = new OrderBO { ID = OrderID };
                objOrder.GetObject();

                var creatorName = objOrder.objCreator.GivenName + " " + objOrder.objCreator.FamilyName;
                var coordinatorName = (objOrder.objDistributor.Coordinator.HasValue && objOrder.objDistributor.Coordinator > 0) ?
                    objOrder.objDistributor.objCoordinator.GivenName + " " + objOrder.objDistributor.objCoordinator.FamilyName : string.Empty;
                var mailCc = string.Empty;

                var objSetting = new SettingsBO();

                switch (ccSetting)
                {
                    case CustomSettings.DSOCC:
                        objSetting.Key = CustomSettings.DSOCC.ToString();
                        objSetting = objSetting.SearchObjects().SingleOrDefault();
                        if (objSetting != null) mailCc = objSetting.Value;
                        break;
                    case CustomSettings.CSOCC:
                        objSetting.Key = CustomSettings.CSOCC.ToString();
                        objSetting = objSetting.SearchObjects().SingleOrDefault();
                        if (objSetting != null) mailCc = objSetting.Value;
                        break;
                }


                var emailContenntBuilder = new StringBuilder(string.Format("Order has been submitted for your inspection on {0} <br><br>", DateTime.Now.ToLongDateString()));
                var title = string.Format("OPS Order Number {0} for {1}", objOrder.ID, objOrder.objClient.Name + ((objOrder.ShipmentDate.HasValue) ? " ETD " + objOrder.ShipmentDate.Value.ToShortDateString() : string.Empty));
                emailContenntBuilder.Append("<table>")
                    .AppendFormat("<tr><td width=\"200\">By : </td><td>{0}</td></tr>", creatorName)
                    .AppendFormat("<tr><td width=\"200\">Distributor : </td><td>{0}</td></tr>", objOrder.objDistributor.Name)
                    .AppendFormat("<tr><td width=\"200\">Client : </td><td>{0}</td></tr>", objOrder.objClient.objClient.Name)
                    .AppendFormat("<tr><td width=\"200\">Job Name : </td><td>{0}</td></tr>", objOrder.objClient.Name)
                    .AppendFormat("<tr><td width=\"200\">Coordinator : </td><td>{0}</td></tr>", coordinatorName);

                if (!objOrder.IsDateNegotiable)
                    emailContenntBuilder.Append("<tr><td width=\"200\">Non-Negotiable : </td><td style=\"color:red;\">YES</td></tr>");

                var objOd = new OrderDetailBO { Order = objOrder.ID };
                var lstOd = objOd.SearchObjects();


                var objOdFirst = lstOd.First();

                if (objOdFirst.IsWeeklyShipment ?? false)
                    emailContenntBuilder.Append("<tr><td width=\"200\">Ship To : </td><td>Adelaide Warehouse</td></tr>");

                else if (objOdFirst.IsCourierDelivery ?? false)
                {
                    emailContenntBuilder.AppendFormat("<tr><td width=\"200\">Name : </td><td>{0}</td></tr>", objOdFirst.objDespatchTo.ContactName)
                        .AppendFormat("<tr><td width=\"200\">Contact : </td><td>{0}</td></tr>", objOdFirst.objDespatchTo.ContactPhone)
                        .AppendFormat("<tr><td width=\"200\">Ship To : </td><td>{0} {1} {2} {3} {4} {5}</td></tr>", objOdFirst.objDespatchTo.CompanyName, objOdFirst.objDespatchTo.Address, objOdFirst.objDespatchTo.Suburb, objOdFirst.objDespatchTo.State, objOdFirst.objDespatchTo.PostCode, objOdFirst.objDespatchTo.objCountry.ShortName);
                }

                emailContenntBuilder.Append((string.IsNullOrEmpty(objOrder.Notes)) ? string.Empty : string.Format("<tr><td width=\"160\">Special Instructions : </td><td>{0}</td></tr>", objOrder.Notes))
                    .Append("</table><br>");

                var poSuffix = 0;

                foreach (var objOrdeDetail in lstOd)
                {
                    var filepath = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/" + GetVLImagePath(objOrdeDetail.objVisualLayout.ID);
                    var nnFilePath = GetNameNumberFilePath(objOrdeDetail.ID);
                    var rowspan = (objOrdeDetail.PhotoApprovalReq ?? false) ? 13 : 12;
                    var pattern = ((objOrdeDetail.VisualLayout ?? 0) > 0) ? (objOrdeDetail.objVisualLayout.objPattern.Number + "-" + objOrdeDetail.objVisualLayout.objPattern.NickName) : (objOrdeDetail.objPattern.Number + "-" + objOrdeDetail.objPattern.NickName);
                    var fabric = ((objOrdeDetail.VisualLayout ?? 0) > 0) ? (objOrdeDetail.objVisualLayout.objFabricCode.Code + "-" + objOrdeDetail.objVisualLayout.objFabricCode.Name) : (objOrdeDetail.objFabricCode.Code + "-" + objOrdeDetail.objFabricCode.Name);

                    var bySize = objOrdeDetail.objVisualLayout.BySizeArtWork ? "YES" : "NO";

                    emailContenntBuilder.Append("<table border=\"1\" width=\"800\" height=\"250\">")
                        .AppendFormat("<tr><td width=\"200\">PO Number : </td><td width=\"300\">{0} - {1}</td>", objOrder.ID, (++poSuffix))
                        .AppendFormat("<td rowspan=\"{0}\"><img height=\"200\" src=\"{1}\"></td></tr>", rowspan, filepath)
                        .AppendFormat("<tr><td width=\"200\">Order Type: </td><td width=\"300\">{0}</td></tr>", objOrdeDetail.objOrderType.Name)
                        .AppendFormat("<tr><td width=\"200\">Product: </td><td width=\"300\">{0}</td></tr>", objOrdeDetail.objVisualLayout.NamePrefix)
                        .AppendFormat("<tr><td width=\"200\">By Size: </td><td width=\"300\">{0}</td></tr>", bySize)
                        .AppendFormat("<tr><td width=\"200\">Fabric: </td><td width=\"300\">{0}</td></tr>", fabric)
                        .AppendFormat("<tr><td width=\"200\">Pattern: </td><td width=\"300\">{0}</td></tr>", pattern)
                        .AppendFormat("<tr><td width=\"200\">ETD: </td><td width=\"300\">{0}</td></tr>", objOrdeDetail.ShipmentDate.ToShortDateString())
                        .AppendFormat("<tr><td width=\"200\">Label: </td><td width=\"300\">{0}</td></tr>", objOrdeDetail.objLabel.Name)
                        .AppendFormat("<tr><td width=\"200\">Branding Kit: </td><td width=\"300\">{0}</td></tr>", (objOrdeDetail.IsBrandingKit ? "YES" : "NO"))
                        .AppendFormat("<tr><td width=\"200\">Names & Numbers: </td><td width=\"300\">{0}</td></tr>", (File.Exists(nnFilePath) ? "YES" : "NO"))
                        .Append("<tr><td width=\"200\">Size/Quantity: </td><td width=\"300\">");


                    var objQty = new OrderDetailQtyBO {OrderDetail = objOrdeDetail.ID};
                    var lstOdQty = objQty.SearchObjects();

                    var sizeQty = lstOdQty.Where(objOdQty => objOdQty.Qty > 0).Aggregate(string.Empty, (current, objOdQty) => current + (objOdQty.objSize.SizeName + "/" + objOdQty.Qty.ToString() + ","));

                    emailContenntBuilder.Append(sizeQty.Remove(sizeQty.Length - 1, 1))
                        .Append("</td></tr>")
                        .AppendFormat("<tr><td width=\"200\">Total : </td><td width=\"300\">{0} pcs</td></tr>", lstOdQty.Sum(m => m.Qty));


                    if (objOrdeDetail.PhotoApprovalReq ?? false)
                        emailContenntBuilder.Append("<tr><td width=\"200\">Photo Request : </td><td style=\"color:red;\" width=\"300\">YES</td></tr>");

                    emailContenntBuilder.Append("<tr><td width=\"200\">Pocket Request : </td><td width=\"300\">")
                        .Append(((objOrdeDetail.objVisualLayout.PocketType.HasValue && objOrdeDetail.objVisualLayout.PocketType.Value > 0) ? objOrdeDetail.objVisualLayout.objPocketType.Name : string.Empty) + "</td></tr>")
                        .Append((string.IsNullOrEmpty(objOrdeDetail.VisualLayoutNotes)) ? string.Empty : string.Format("<tr><td width=\"200\">Notes : </td><td colspan=\"2\"><span style=\"color:red;\">{0}</span></td></tr>", objOrdeDetail.VisualLayoutNotes))
                        .Append((string.IsNullOrWhiteSpace(objOrdeDetail.EditedPriceRemarks)) ? "" : string.Format("<tr><td width=\"200\">Price comments: </td><td colspan=\"2\">{0}</td></tr>", objOrdeDetail.EditedPriceRemarks))
                        .Append((string.IsNullOrWhiteSpace(objOrdeDetail.FactoryInstructions)) ? "" : string.Format("<tr><td width=\"200\">Factory Instructions: </td><td colspan=\"2\">{0}</td></tr>", objOrdeDetail.FactoryInstructions))
                        .Append("</table><br>");

                }

                emailContenntBuilder.Append("<br><br>")
                    .AppendFormat("Please click below link to review it.<br>{0}", "http://" + IndicoConfiguration.AppConfiguration.SiteHostAddress + "/AddEditOrder.aspx?id=" + OrderID);

                IndicoEmail.SendMailOrderSubmission(receiverName, receiverEmail, mailCc, title, emailContenntBuilder.ToString());








                ////if (Submit)
                ////{
                ////    title = "Order has been submitted for you in OPS";

                //emailContent +=  //"<p>Dear " + receiverName + ",<br><br>" +
                //                "Order has been submitted for your inspection on " + DateTime.Now.ToLongDateString() + "<br><br>";
                ////+                                "By: " + creatorName + " <br>" +
                ////"Distributor: " + objOrder.objDistributor.Name + " <br>" +
                ////"Coordinator: " + coordinatorName + " <br>" +
                ////"Client/ Job Name: " + objOrder.objClient.Name + " <br><br>";
                ////}
                ////else
                ////{
                //var title = "OPS Order Number " + objOrder.ID + " for " + objOrder.objClient.Name + ((objOrder.ShipmentDate.HasValue) ? " ETD " + objOrder.ShipmentDate.Value.ToShortDateString() : string.Empty);
                ////"Order has been added or edited " + objOrder.ID.ToString();

                ////emailContent += "<p>Dear Administrator,<br><br>" +
                ////                "Orders have been added or edited on " + DateTime.Now.ToLongDateString() + " for the following Products: <br><br>" +
                ////                "Distributor: " + objOrder.objDistributor.Name + " <br>" +
                ////                "Coordinator: " + coordinatorName + " <br>" +
                ////                "Client: " + objOrder.objClient.Name + "<br><br>";
                //emailContent += "<table>";

                //emailContent += "<tr><td width=\"200\">By : </td><td>" + creatorName + "</td></tr>" +
                //                "<tr><td width=\"200\">Distributor : </td><td>" + objOrder.objDistributor.Name + "</td></tr>" +
                //                "<tr><td width=\"200\">Client : </td><td>" + objOrder.objClient.objClient.Name + "</td></tr>" +
                //                "<tr><td width=\"200\">Job Name : </td><td>" + objOrder.objClient.Name + "</td></tr>" +
                //                "<tr><td width=\"200\">Coordinator : </td><td>" + coordinatorName + "</td></tr>"
                //               ;

                //if (!objOrder.IsDateNegotiable)
                //{
                //    emailContent += "<tr><td width=\"200\">Non-Negotiable : </td><td style=\"color:red;\">YES</td></tr>";
                //}

                //OrderDetailBO objOD = new OrderDetailBO();
                //objOD.Order = objOrder.ID;
                //List<OrderDetailBO> lstOD = objOD.SearchObjects();

                //OrderDetailBO objODFirst = lstOD.First();

                //if (objODFirst.IsWeeklyShipment ?? false)
                //{
                //    emailContent += "<tr><td width=\"200\">Ship To : </td><td>Adelaide Warehouse</td></tr>";
                //}
                //else if (objODFirst.IsCourierDelivery ?? false)
                //{
                //    emailContent += "<tr><td width=\"200\">Name : </td><td>" + objODFirst.objDespatchTo.ContactName + "</td></tr>" +
                //                "<tr><td width=\"200\">Contact : </td><td>" + objODFirst.objDespatchTo.ContactPhone + "</td></tr>" +
                //               "<tr><td width=\"200\">Ship To : </td><td>" + objODFirst.objDespatchTo.CompanyName + " " + objODFirst.objDespatchTo.Address + " " + objODFirst.objDespatchTo.Suburb + " " + objODFirst.objDespatchTo.State + " " + objODFirst.objDespatchTo.PostCode + " " + objODFirst.objDespatchTo.objCountry.ShortName + "</td></tr>";
                //}

                //emailContent += (string.IsNullOrEmpty(objOrder.Notes)) ? string.Empty : ("<tr><td width=\"160\">Special Instructions : </td><td>" + objOrder.Notes + "</td></tr>");

                //emailContent += "</table><br>";

                //int poSuffix = 0;

                //foreach (OrderDetailBO objOrdeDetail in lstOD) // objOrder.OrderDetailsWhereThisIsOrder)
                //{
                //    string filepath = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/" + IndicoPage.GetVLImagePath(objOrdeDetail.objVisualLayout.ID);
                //    //string filepath = "http://gw.indiman.net/" + IndicoPage.GetVLImagePath(objOrdeDetail.objVisualLayout.ID);                    
                //    string NNFilePath = GetNameNumberFilePath(objOrdeDetail.ID);
                //    int rowspan = (objOrdeDetail.PhotoApprovalReq ?? false) ? 13 : 12;
                //    string pattern = ((objOrdeDetail.VisualLayout ?? 0) > 0) ? (objOrdeDetail.objVisualLayout.objPattern.Number + "-" + objOrdeDetail.objVisualLayout.objPattern.NickName) : (objOrdeDetail.objPattern.Number + "-" + objOrdeDetail.objPattern.NickName);
                //    string fabric = ((objOrdeDetail.VisualLayout ?? 0) > 0) ? (objOrdeDetail.objVisualLayout.objFabricCode.Code + "-" + objOrdeDetail.objVisualLayout.objFabricCode.Name) : (objOrdeDetail.objFabricCode.Code + "-" + objOrdeDetail.objFabricCode.Name);

                //    string bySize = ((bool)objOrdeDetail.objVisualLayout.BySizeArtWork) ? "YES" : "NO";

                //    emailContent += "<table border=\"1\" width=\"800\" height=\"250\">" +
                //                    "<tr><td width=\"200\">PO Number : </td><td width=\"300\">" + objOrder.ID + " -" + (++poSuffix).ToString() + "</td>" +
                //                                    "<td rowspan=\"" + rowspan + "\"><img height=\"200\" src=\"" + filepath + "\"></td></tr>" +
                //                    "<tr><td width=\"200\">Order Type: </td><td width=\"300\">" + objOrdeDetail.objOrderType.Name + "</td></tr>" +
                //                    "<tr><td width=\"200\">Product: </td><td width=\"300\">" + objOrdeDetail.objVisualLayout.NamePrefix + "</td></tr>" +
                //                   "<tr><td width=\"200\">By Size: </td><td width=\"300\">" + bySize + "</td></tr>" +
                //                    "<tr><td width=\"200\">Fabric: </td><td width=\"300\">" + fabric + "</td></tr>" +
                //                    "<tr><td width=\"200\">Pattern: </td><td width=\"300\">" + pattern + "</td></tr>" +
                //                    "<tr><td width=\"200\">ETD: </td><td width=\"300\">" + objOrdeDetail.ShipmentDate.ToShortDateString() + "</td></tr>" +
                //                    "<tr><td width=\"200\">Label: </td><td width=\"300\">" + objOrdeDetail.objLabel.Name + "</td></tr>" +
                //                    "<tr><td width=\"200\">Branding Kit: </td><td width=\"300\">" + (objOrdeDetail.IsBrandingKit ? "YES" : "NO") + "</td></tr>" +
                //                    "<tr><td width=\"200\">Names & Numbers: </td><td width=\"300\">" + (File.Exists(NNFilePath) ? "YES" : "NO") + "</td></tr>" +
                //                    "<tr><td width=\"200\">Size/Quantity: </td><td width=\"300\">";

                //    OrderDetailQtyBO objQty = new OrderDetailQtyBO();
                //    objQty.OrderDetail = objOrdeDetail.ID;
                //    List<OrderDetailQtyBO> lstODQty = objQty.SearchObjects();

                //    string sizeQty = string.Empty;

                //    foreach (OrderDetailQtyBO objODQty in lstODQty)
                //    {
                //        if (objODQty.Qty > 0)
                //        {
                //            sizeQty += objODQty.objSize.SizeName + "/" + objODQty.Qty.ToString() + ",";
                //        }
                //    }

                //    emailContent += sizeQty.Remove(sizeQty.Length - 1, 1);
                //    emailContent += "</td></tr>";

                //    emailContent += "<tr><td width=\"200\">Total : </td><td width=\"300\">" + lstODQty.Sum(m => m.Qty).ToString() + " pcs</td></tr>";

                //    if (objOrdeDetail.PhotoApprovalReq ?? false)
                //    {
                //        emailContent += "<tr><td width=\"200\">Photo Request : </td><td style=\"color:red;\" width=\"300\">YES</td></tr>";
                //    }

                //    emailContent += "<tr><td width=\"200\">Pocket Request : </td><td width=\"300\">" +
                //        ((objOrdeDetail.objVisualLayout.PocketType.HasValue && objOrdeDetail.objVisualLayout.PocketType.Value > 0) ? objOrdeDetail.objVisualLayout.objPocketType.Name : string.Empty) + "</td></tr>";
                //    emailContent += (string.IsNullOrEmpty(objOrdeDetail.VisualLayoutNotes)) ? string.Empty : ("<tr><td width=\"200\">Notes : </td><td colspan=\"2\"><span style=\"color:red;\">" + objOrdeDetail.VisualLayoutNotes + "</span></td></tr>");

                //    emailContent += "</table><br>";
                //}
                ////}

                //emailContent += "<br><br>";
                //emailContent += "Please click below link to review it.<br>" +
                //                "http://" + IndicoConfiguration.AppConfiguration.SiteHostAddress + "/AddEditOrder.aspx?id=" + OrderID;
                ////+ "Regards, <br>" + "OPS Team</p><br><br>";

                //// IndicoEmail.SendMailFromSystem(receiverName, receiverEmail, mailCC, title, emailContent, true);
                //IndicoEmail.SendMailOrderSubmission(receiverName, receiverEmail, mailCc, title, emailContent);
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occurred while send client order email", ex);
            }
        }

        public static int ValidateField2(int id, string table, string field1, string value1, string field2, string value2)
        {
            int isValid = 0;

            System.Data.SqlClient.SqlConnection connection = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
            connection.Open();
            string query = string.Format(@"EXEC [Indico].[dbo].[SPC_ValidateField2] '{0}','{1}','{2}','{3}','{4}','{5}'",
                                                                                  id.ToString(), table, field1, value1, field2, value2);
            var result = connection.Query<int>(query);
            connection.Close();

            isValid = result.First();

            return isValid;
        }

        #endregion

        #region Enums

        public enum UserRole
        {
            /// <summary>
            ///Administrator of the indico application 
            /// </summary>
            SiteAdministrator,
            FactoryAdministrator,
            FactoryCoordinator,
            FactoryPatternDeveloper,
            IndimanAdministrator,
            IndimanCoordinator,
            /// <summary>
            /// SAdmin
            /// </summary>
            IndicoAdministrator,
            IndicoCoordinator,
            IndicoPatternDeveloper,
            DistributorAdministrator,
            DistributorCoordinator,
            /// <summary>
            /// No Role Assigned
            /// </summary>
            NotAssigned
        };

        public enum CompanyType
        {
            /// <summary>
            /// Indico Factory
            /// </summary>
            Factory,
            /// <summary>
            /// Indico Manufacturer
            /// </summary>
            Manufacturer,
            /// <summary>
            /// Indico Sales
            /// </summary>
            Sales,
            /// <summary>
            /// Indico Distributor
            /// </summary>
            Distributor,
            /// <summary>
            /// Indico Client
            /// </summary>
            Client,
            NotAssigned
        };

        public enum OrderStatus
        {
            New,
            InProgress,
            PartialyCompleted,
            Completed,
            DistributorSubmitted,
            IndicoHold,
            IndicoSubmitted,
            IndimanHold,
            IndimanSubmitted,
            FactoryHold,
            Cancelled,
            CoordinatorSubmitted
        };

        public enum CustomSettings
        {
            OPP,
            DSOCC,
            CSOTO,
            CSOCC,
            ISOTO
        };

        public enum AddressType
        {
            Business = 1,
            Residential = 2
        }

        public enum FabricType
        {
            Main = 0,
            Secondary = 1,
            Lining = 2
        }

        #endregion
    }
}