using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

using Indico.BusinessObjects;
using Indico.Common;
using System.IO;

namespace Indic.Controls
{
    public partial class Navigation : System.Web.UI.UserControl
    {
        #region Fields

        private CompanyBO currentCompany = null;
        private UserBO currentUser = null;

        private int itemTab = 0;
        private int itemMenu = 0;

        #endregion

        #region Properties

        private IndicoPage CurrentPage
        {
            get
            {
                if (this.Page.GetType().IsSubclassOf(System.Type.GetType("Indico.Common.IndicoPage")))
                {
                    return ((IndicoPage)this.Page);
                }
                else
                {
                    return null;
                }
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
                    currentUser = new UserBO();
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
                    currentCompany = new CompanyBO();
                    currentCompany.ID = Convert.ToInt32(Session["in_cid"]);
                    currentCompany.GetObject();

                    return currentCompany;
                }
                else if (this.LoggedUser != null && this.LoggedUser.ID > 0)
                {
                    currentCompany = new CompanyBO();
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

        public string IsSettingActive { get; set; }

        private int MenuItemTab
        {
            get
            {
                if (itemTab > 0)
                    return itemTab;

                List<UserMenuItemRoleViewBO> lstPages = (from o in AvailableUserMenuItems
                                                         where o.PageName != null && o.PageName.ToLower().EndsWith(this.CurrentPage.Name.ToLower())
                                                         select o).ToList<UserMenuItemRoleViewBO>();
                if (lstPages.Count > 0)
                {
                    if (lstPages[0].Parent == 0)
                    {
                        itemTab = (int)lstPages[0].MenuItem;
                        itemMenu = (lstPages.Count > 1) ? (int)lstPages[1].MenuItem : (int)lstPages[0].MenuItem;
                    }
                    else
                    {
                        UserMenuItemRoleViewBO objItemMenu = (from o in AvailableUserMenuItems
                                                              where o.PageName != null && o.MenuItem == lstPages[0].Parent
                                                              select o).ToList<UserMenuItemRoleViewBO>()[0];

                        if (objItemMenu.Parent != 0)
                        {
                            itemTab = (int)objItemMenu.Parent;
                            itemMenu = (int)objItemMenu.MenuItem;
                        }
                        else
                        {
                            itemTab = (int)objItemMenu.MenuItem;
                            itemMenu = (int)lstPages[0].MenuItem;
                        }
                    }
                }
                else
                {
                    itemTab = itemMenu = 0;
                }

                return itemTab;
            }
        }

        private int MenuItemMenu
        {
            get
            {
                if (itemMenu > 0)
                    return itemMenu;

                itemTab = MenuItemTab;
                return itemMenu;
            }
        }

        private List<UserMenuItemRoleViewBO> AvailableUserMenuItems
        {
            get
            {
                if (this.LoggedUser == null || this.LoggedUser.ID == 0)
                {
                    IndicoLogging.log.WarnFormat("Navigation.AvailableUserPageRoles: CurrentUser for session {0} was strangely null or ID was 0 - logging the user out.", Session.SessionID);
                    Response.Redirect("/Logout.aspx");
                }

                if (Session["UserMenuItemRoleView" + this.LoggedUser.ID] == null)
                {
                    UserMenuItemRoleViewBO userMenuItems = new UserMenuItemRoleViewBO();
                    userMenuItems.User = this.LoggedUser.ID;
                    List<UserMenuItemRoleViewBO> lstUMIRV = userMenuItems.SearchObjects();

                    if (this.LoggedUser.IsDirectSalesPerson)
                    {
                        UserMenuItemRoleViewBO disMenu = lstUMIRV.Where(m => m.MenuName == "Distributors").SingleOrDefault();
                        lstUMIRV.Remove(disMenu);
                    }

                    Session["UserMenuItemRoleView" + this.LoggedUser.ID] = lstUMIRV;

                    IndicoLogging.log.WarnFormat("Navigation.AvailableUserPageRoles: Authorisation table for {0} {1} (ID: {2}) refreshed with session id {3} has {4} rows",
                                                 this.LoggedUser.GivenName, this.LoggedUser.FamilyName, this.LoggedUser.ID, Session.SessionID, lstUMIRV.Count);
                }
                return (List<UserMenuItemRoleViewBO>)(Session["UserMenuItemRoleView" + this.LoggedUser.ID]);
            }
        }

        #endregion

        #region Constructors

        #endregion

        #region Events

        /// <summary>
        /// Page load event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void Page_Load(object sender, EventArgs e)
        {
            PopulateControls();
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            if (this.CurrentPage != null)
            {
                this.DeterminePermissions();
            }

            string userRole = (this.LoggedUser.IsDirectSalesPerson)? " (Direct Sales)": " (" + this.LoggedUser.UserRolesWhereThisIsUser[0].Description + ")";

            this.litUsername.Text = this.LoggedUser.GivenName + " " + this.LoggedUser.FamilyName + userRole;
            this.PopulateNavigation();
        }

        private void DeterminePermissions()
        {
            if (!String.IsNullOrEmpty(this.CurrentPage.Name))
            {
                List<PageBO> lstPages = (from o in (new PageBO()).SearchObjects()
                                         where o.Name.ToLower().EndsWith(this.CurrentPage.Name.ToLower())
                                         select o).ToList<PageBO>();
                if (lstPages.Count > 0)
                {
                    List<UserMenuItemRoleViewBO> lstAuthorizedPages = (from o in AvailableUserMenuItems
                                                                       where o.PageName.ToLower().EndsWith(this.CurrentPage.Name.ToLower())
                                                                       orderby o.Position ascending
                                                                       select o).ToList<UserMenuItemRoleViewBO>();
                    if (lstAuthorizedPages.Count == 0)
                    {
                        Response.Redirect("/Unauthorised.html");
                    }
                }
                else
                {
                    Response.Redirect("/Cannotcontinued.html");
                }
            }
            else
            {
                Response.Redirect("/UnexpecteedError.html");
            }
        }

        private void PopulateNavigation()
        {
            List<UserMenuItemRoleViewBO> lstMenuTabs = (from o in AvailableUserMenuItems
                                                        where o.Parent == 0 && o.IsVisible == true
                                                        orderby o.Position ascending
                                                        select o).ToList<UserMenuItemRoleViewBO>();
            this.IsSettingActive = string.Empty;
            foreach (UserMenuItemRoleViewBO menuItem in lstMenuTabs)
            {
                List<UserMenuItemRoleViewBO> lstChildNodes = (from o in AvailableUserMenuItems
                                                              where o.Parent == (int)menuItem.MenuItem && o.IsVisible == true
                                                              select o).ToList();

                if (this.LoggedUser.IsDirectSalesPerson && lstChildNodes.Count > 0 && lstChildNodes.First().MenuName == "Patterns")
                {
                    lstChildNodes.RemoveRange(1, lstChildNodes.Count - 1);
                }

                string strHtml = string.Empty;
                if (menuItem.MenuName.ToUpper() == "SETTINGS")
                {
                    if ((menuItem.Page != null) && (this.MenuItemTab == (int)menuItem.MenuItem))
                    {
                        this.IsSettingActive = " active";
                    }
                }
                else
                {
                    string strStyle = string.Empty;
                    if ((menuItem.Page != null) && (this.MenuItemTab == (int)menuItem.MenuItem))
                    {
                        strStyle = "active";
                    }
                    if (lstChildNodes.Count > 0)
                    {
                        strStyle += " dropdown";
                    }
                    if (strStyle != string.Empty)
                    {
                        strStyle = " class=\"" + strStyle.Trim() + "\"";
                    }

                    string strUrl = String.IsNullOrEmpty(menuItem.PageName) ? "javascript:void(0);" : menuItem.PageName;
                    strHtml = "<li" + strStyle + ">";

                    if (lstChildNodes.Count > 0)
                    {
                        strHtml += "<a data-toggle=\"dropdown\" class=\"dropdown-toggle\" href=\"javascript:void(0);\">" + menuItem.MenuName + "<b class=\"caret\"></b></a><ul class=\"dropdown-menu pull-right\">";

                        foreach (UserMenuItemRoleViewBO childItem in lstChildNodes)
                        {
                            strUrl = String.IsNullOrEmpty(childItem.PageName) ? "javascript:void(0);" : childItem.PageName;
                            strHtml += "<li><a href=\"" + strUrl + "\">" + childItem.MenuName + "</a></li>";
                        }

                        strHtml += "</ul>";
                    }
                    else
                    {
                        strHtml += "<a href=\"" + strUrl + "\">" + menuItem.MenuName + "</a>";
                    }
                    strHtml += "</li>";

                    ulNavigation.Controls.Add(new LiteralControl(strHtml));
                }
            }
        }

        #endregion
    }
}