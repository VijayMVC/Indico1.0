using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Threading;

using MPEC = Microsoft.Practices.EnterpriseLibrary.Caching;

namespace Indico.BusinessObjects
{
    public class CachedData
    {
        #region Structs

        /// <summary>
        /// Tables
        /// </summary>
        /*
        public struct TableNames
        {
            /// <summary>
            /// Constant for the cached Page entity
            /// </summary>
            /// <remarks>This cached table stored information about web pages in the application and how they relate to each other in the navigational structure</remarks>
            public const string Page = "Page";
            /// <summary>
            /// Constant for the cached PageRole entity
            /// </summary>
            /// <remarks>This cached table stores the relationship between pages in the TableNames.Page table and the roles that are allowed to access them in the TableNames.Role table</remarks>
            public const string PageRole = "PageRole";
            /// <summary>
            /// Constant for the cached Role entity
            /// </summary>
            /// <remarks>This table stores information about the roles that are played by users of the application</remarks>
            public const string Role = "Role";
            /// <summary>
            /// Constant for the cached simple Yes/No table
            /// </summary>
            public const string YesNoTable = "YesNoTable";
            /// <summary>
            /// Constant for the cached UserPageRole entity
            /// </summary>
            /// <remarks>UserPageRole table maintains a table of users' access rights to pages.</remarks>
            public const string UserPageRole = "UserPageRole";
            /// <summary>
            /// Constant for the cached UserCompanyRole entity
            /// </summary>
            /// <remarks>UserCompanyRole table maintains a table of users' roles that they have been assigned to.</remarks>
            public const string UserCompanyRole = "UserCompanyRole";
            /// <summary>
            /// Constant for the cached User entity
            /// </summary>
            /// <remarks>User table maintains a table of users who are attached to current sessions. User objects
            /// are purged when their session is purged.</remarks>
            //public const string User = "User";
            /// <summary>
            /// Constant for the cached AccountSetting entity
            /// </summary>
            /// <remarks>AccountSetting table maintains a table of AccountSetting rows for the owner of this application. </remarks>
            public const string AccountSetting = "AccountSetting";
            /// <summary>
            /// Constant for the cached Category entity
            /// </summary>
            /// <remarks>Category table maintains a table of Category rows belonging to the owner of the application</remarks>
            public const string Category = "Category";
            /// <summary>
            /// Constant for the cached ProductType entity
            /// </summary>
            /// <remarks>ProductType table maintains a table of ProductType rows belonging to the owner of the application</remarks>
            public const string ProductType = "ProductType";
            /// <summary>
            /// Constant for the cached TemplateDef entity
            /// </summary>
            /// <remarks>TemplateDef table maintains a table of TemplateDef rows belonging to the owner of the application. These
            /// are sent to the Flash Client and used in the building of PDFs</remarks>
            //public const string TemplateDef = "TemplateDef";
            /// <summary>
            /// Constant for the cached IsoFormat entity
            /// </summary>
            /// <remarks>IsoFormat table maintains a table of IsoFormat rows in the database. These are the output formats supported</remarks>
            public const string IsoFormat = "IsoFormat";
            /// <summary>
            /// Constant for the cached PrintJobStatus entity
            /// </summary>
            /// <remarks>PrintJobStatus table maintains a table of PrintJobStatus rows belonging to the owner of the application.</remarks>
            public const string PrintJobStatus = "PrintJobStatus";
            /// <summary>
            /// Constant for the cached Country entity
            /// </summary>
            /// <remarks>Country table maintains a table of Country rows </remarks>
            public const string Country = "Country";
            /// <summary>
            /// Constant for the cached Locale entity
            /// </summary>
            /// <remarks>Locale table maintains a table of Locale rows </remarks>
            public const string Locale = "Locale";
            /// <summary>
            /// Constant for the cached CompanyType entity
            /// </summary>
            /// <remarks>CompanyType table maintains a table of CompanyType rows </remarks>
            public const string CompanyType = "CompanyType";
            /// <summary>
            /// a string array containing the names of all the cached tables
            /// </summary>
            public static string[] Names = new string[] { Page, PageRole, Role, YesNoTable, UserCompanyRole, AccountSetting, Category, IsoFormat, PrintJobStatus, Country, Locale, CompanyType };
        }
        */

        #endregion

        #region Fields

        //*SDS  private static bool refreshing = false;
        //*SDS   private static ReaderWriterLock rwl;
        private static DateTime dtLastCached = DateTime.Now;
        private static MPEC.CacheManager cacheManager = null;
        private static CachedDataRefreshAction refreshAction = new CachedDataRefreshAction();

        #endregion

        #region Properties

        public static MPEC.CacheManager CacheManager
        {
            set
            {
                if (cacheManager == null)
                {
                    cacheManager = value;
                }
            }
            get
            {
                return cacheManager;
            }
        }

        private static int CacheItemExpirationTimeInMinutes
        {
            get
            {
                return 600;
            }
        }

        /*
        public static List<PageBO> PageList
        {
            get
            {
                string key = TableNames.Page + "_" + BusinessObject.OwnerCompanyID.ToString();

                if (CachedData.CacheManager[key] == null)
                {
                    PageBO objPage = new PageBO();
                    objPage.Company = BusinessObject.OwnerCompanyID;
                    Add(key, objPage.SearchObjects());
                }

                return (List<PageBO>)CachedData.CacheManager[key];
            }
            set
            {
                string key = TableNames.Page + "_" + BusinessObject.OwnerCompanyID.ToString();
                if (CachedData.CacheManager[key] != null)
                {
                    Remove(key);
                }

                Add(key, value);
            }
        }
        */

        #endregion

        #region Constructors

        static CachedData()
        {
            if (cacheManager == null)
            {
                cacheManager = MPEC.CacheFactory.GetCacheManager() as MPEC.CacheManager;
            }
        }

        #endregion

        #region Methods

        public static void Add(string key, object value1)
        {
            CachedData.CacheManager.Add(key, value1, MPEC.CacheItemPriority.High, null,
                new MPEC.Expirations.SlidingTime(TimeSpan.FromMinutes(CacheItemExpirationTimeInMinutes)));
        }

        public static void Add(string key, object value1, FileInfo fileDependency)
        {
            MPEC.Expirations.FileDependency fd = new MPEC.Expirations.FileDependency(fileDependency.FullName);

            CachedData.CacheManager.Add(key, value1, MPEC.CacheItemPriority.High, refreshAction,
                new MPEC.Expirations.SlidingTime(TimeSpan.FromMinutes(CacheItemExpirationTimeInMinutes)), fd);
        }

        public static void Remove(string key)
        {
            CachedData.CacheManager.Remove(key);
        }

        public static object GetData(string key)
        {
            return CachedData.CacheManager.GetData(key);
        }

        /*
        public static void RefreshList(string tableName, int companyId)
        {
            if (tableName != string.Empty && companyId != 0)
            {
                string key = tableName + "_" + companyId.ToString();

                switch (tableName)
                {
                    case TableNames.Page:
                        PageBO objPage = new PageBO();
                        objPage.Company = companyId;
                        List<PageBO> lstP = objPage.SearchObjects();
                        Add(key, lstP);
                        break;
                    case TableNames.UserCompanyRole:
                        UserCompanyRoleBO objUserCompanyRole = new UserCompanyRoleBO();
                        objUserCompanyRole.Company = companyId;
                        List<UserCompanyRoleBO> lstUCR = objUserCompanyRole.SearchObjects();
                        Add(key, lstUCR);
                        break;
                    case TableNames.Category:
                        CategoryBO objCategory = new CategoryBO();
                        objCategory.Company = companyId;
                        List<CategoryBO> lstCat = objCategory.SearchObjects();
                        Add(key, lstCat);
                        break;
                    case TableNames.PrintJobStatus:
                        PrintJobStatusBO objPrintJobStatus = new PrintJobStatusBO();
                        objPrintJobStatus.Company = companyId;
                        List<PrintJobStatusBO> lstPJS = objPrintJobStatus.SearchObjects();
                        Add(key, lstPJS);
                        break;
                    case TableNames.Country:
                        CountryBO objCountry = new CountryBO();
                        List<CountryBO> lstCoun = objCountry.SearchObjects();
                        Add(key, lstCoun);
                        break;
                    case TableNames.Role:
                        RoleBO objRole = new RoleBO();
                        List<RoleBO> lstR = objRole.SearchObjects();
                        Add(key, lstR);
                        break;
                    case TableNames.IsoFormat:
                        IsoFormatBO objIsoFormat = new IsoFormatBO();
                        List<IsoFormatBO> lstISF = objIsoFormat.SearchObjects();
                        Add(key, lstISF);
                        break;
                    case TableNames.Locale:
                        LocaleBO objLocale = new LocaleBO();
                        List<LocaleBO> lstL = objLocale.SearchObjects();
                        Add(key, lstL);
                        break;
                    case TableNames.CompanyType:
                        CompanyTypeBO objCompany = new CompanyTypeBO();
                        List<CompanyTypeBO> lstCT = objCompany.SearchObjects();
                        Add(key, lstCT);
                        break;
                    default:
                        break;
                }
            }
        }

        public static void Refresh(int companyId)
        {
            string key = string.Empty;

            key = TableNames.Page + "_" + companyId.ToString();
            PageBO objPage = new PageBO();
            objPage.Company = companyId;
            List<PageBO> lstP = objPage.SearchObjects();
            Add(key, lstP);

            key = TableNames.UserCompanyRole + "_" + companyId.ToString();
            UserCompanyRoleBO objUserCompanyRole = new UserCompanyRoleBO();
            objUserCompanyRole.Company = companyId;
            List<UserCompanyRoleBO> lstUCR = objUserCompanyRole.SearchObjects();
            Add(key, lstUCR);

            key = TableNames.Category + "_" + companyId.ToString();
            CategoryBO objCategory = new CategoryBO();
            objCategory.Company = companyId;
            List<CategoryBO> lstCat = objCategory.SearchObjects();
            Add(key, lstCat);

            key = TableNames.PrintJobStatus + "_" + companyId.ToString();
            PrintJobStatusBO objPrintJobStatus = new PrintJobStatusBO();
            objPrintJobStatus.Company = companyId;
            List<PrintJobStatusBO> lstPJS = objPrintJobStatus.SearchObjects();
            Add(key, lstPJS);

            key = TableNames.Country + "_" + companyId.ToString();
            CountryBO objCountry = new CountryBO();
            List<CountryBO> lstCoun = objCountry.SearchObjects();
            Add(key, lstCoun);

            key = TableNames.Role + "_" + companyId.ToString();
            RoleBO objRole = new RoleBO();
            List<RoleBO> lstR = objRole.SearchObjects();
            Add(key, lstR);

            key = TableNames.IsoFormat + "_" + companyId.ToString();
            IsoFormatBO objIsoFormat = new IsoFormatBO();
            List<IsoFormatBO> lstISF = objIsoFormat.SearchObjects();
            Add(key, lstISF);

            key = TableNames.Locale + "_" + companyId.ToString();
            LocaleBO objLocale = new LocaleBO();
            List<LocaleBO> lstL = objLocale.SearchObjects();
            Add(key, lstL);

            key = TableNames.CompanyType + "_" + companyId.ToString();
            CompanyTypeBO objCompany = new CompanyTypeBO();
            List<CompanyTypeBO> lstCT = objCompany.SearchObjects();
            Add(key, lstCT);
        }        

        public static void Refresh()
        {
            string key = string.Empty;

            key = TableNames.Page + "_" + BusinessObject.OwnerCompanyID.ToString();
            PageBO objPage = new PageBO();
            objPage.Company = BusinessObject.OwnerCompanyID;
            List<PageBO> lstP = objPage.SearchObjects();
            Add(key, lstP);

            key = TableNames.UserCompanyRole + "_" + BusinessObject.OwnerCompanyID.ToString();
            UserCompanyRoleBO objUserCompanyRole = new UserCompanyRoleBO();
            objUserCompanyRole.Company = BusinessObject.OwnerCompanyID;
            List<UserCompanyRoleBO> lstUCR = objUserCompanyRole.SearchObjects();
            Add(key, lstUCR);

            key = TableNames.Category + "_" + BusinessObject.OwnerCompanyID.ToString();
            CategoryBO objCategory = new CategoryBO();
            objCategory.Company = BusinessObject.OwnerCompanyID;
            List<CategoryBO> lstCat = objCategory.SearchObjects();
            Add(key, lstCat);

            key = TableNames.PrintJobStatus + "_" + BusinessObject.OwnerCompanyID.ToString();
            PrintJobStatusBO objPrintJobStatus = new PrintJobStatusBO();
            objPrintJobStatus.Company = BusinessObject.OwnerCompanyID;
            List<PrintJobStatusBO> lstPJS = objPrintJobStatus.SearchObjects();
            Add(key, lstPJS);

            key = TableNames.Country + "_" + BusinessObject.OwnerCompanyID.ToString();
            CountryBO objCountry = new CountryBO();
            List<CountryBO> lstCoun = objCountry.SearchObjects();
            Add(key, lstCoun);

            key = TableNames.Role + "_" + BusinessObject.OwnerCompanyID.ToString();
            RoleBO objRole = new RoleBO();
            List<RoleBO> lstR = objRole.SearchObjects();
            Add(key, lstR);

            key = TableNames.IsoFormat + "_" + BusinessObject.OwnerCompanyID.ToString();
            IsoFormatBO objIsoFormat = new IsoFormatBO();
            List<IsoFormatBO> lstISF = objIsoFormat.SearchObjects();
            Add(key, lstISF);

            key = TableNames.Locale + "_" + BusinessObject.OwnerCompanyID.ToString();
            LocaleBO objLocale = new LocaleBO();
            List<LocaleBO> lstL = objLocale.SearchObjects();
            Add(key, lstL);

            key = TableNames.CompanyType + "_" + BusinessObject.OwnerCompanyID.ToString();
            CompanyTypeBO objCompany = new CompanyTypeBO();
            List<CompanyTypeBO> lstCT = objCompany.SearchObjects();
            Add(key, lstCT);
        }
        */

        #endregion
    }

    #region CachedDataRefreshAction : MPEC.ICacheItemRefreshAction

    public class CachedDataRefreshAction : MPEC.ICacheItemRefreshAction
    {
        void MPEC.ICacheItemRefreshAction.Refresh(string removedKey, object expiredValue, MPEC.CacheItemRemovedReason removalReason)
        {
            Console.WriteLine("CachedData - Key {0} expired from cache, reason: {1}", removedKey, removalReason.ToString());
        }
    }

    #endregion
}
