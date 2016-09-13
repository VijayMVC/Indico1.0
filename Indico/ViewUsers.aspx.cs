using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class ViewUsers : IndicoPage
    {
        #region Field

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["UsersSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["UsersSortExpression"] = value;
            }
        }

        public bool IsNotRefresh
        {
            get
            {
                return (Session["IsPostBack"].ToString() == ViewState["IsPostBack"].ToString());
            }
        }

        #endregion

        #region Constructors

        #endregion

        #region Event

        protected void Page_PreRender(object sender, EventArgs e)
        {
            //Page Refresh
            Session["IsPostBack"] = Server.UrlEncode(Guid.NewGuid().ToString());
            ViewState["IsPostBack"] = Session["IsPostBack"];
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                PopulateControls();
            }
        }

        protected void RadGridUsers_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridUsers_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridUsers_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is UsersDetailsViewBO)
                {
                    UsersDetailsViewBO objUserDetails = (UsersDetailsViewBO)item.DataItem;

                    Literal lblName = (Literal)item.FindControl("lblName");
                    lblName.Text = objUserDetails.Name;

                    UserBO objUser = new UserBO();
                    objUser.ID = (int)objUserDetails.User;
                    objUser.GetObject();

                    Image imgUser = (Image)item.FindControl("imgUser");
                    imgUser.ImageUrl = UserBO.GetProfilePicturePath(objUser, UserBO.ImageSize.Medium);

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.NavigateUrl = "/AddEditUser.aspx?id=" + objUser.ID.ToString();
                    linkEdit.Visible = (this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objUserDetails.User.ToString());
                    //linkDelete.Visible = true;

                    if (objUserDetails.StatusID == 2)
                    {
                        linkDelete.Visible = true;
                    }
                    else
                    {
                        linkDelete.Visible = false;
                    }

                    LinkButton linkResend = (LinkButton)item.FindControl("linkResend");
                    linkResend.Visible = false;
                    if (objUserDetails.StatusID == 3)
                    {
                        linkResend.Visible = true;
                        linkResend.Attributes.Add("uid", objUserDetails.User.ToString());
                    }
                }
            }
        }

        protected void RadGridUsers_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridUsers_ItemCommand(object sender, GridCommandEventArgs e)
        {
            //if (e.CommandName == RadGrid.FilterCommandName)
            //{
            this.ReBindGrid();
            //}
        }

        protected void RadGridUsers_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridUser_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is UsersDetailsViewBO)
        //    {
        //        UsersDetailsViewBO objUser = (UsersDetailsViewBO)item.DataItem;

        //        Literal lblName = (Literal)item.FindControl("lblName");
        //        lblName.Text = objUser.GivenName + " " + objUser.FamilyName;

        //        Literal lblStatus = (Literal)item.FindControl("lblStatus");
        //        lblStatus.Text = objUser.objStatus.Name.ToString();

        //        Literal lblCompany = (Literal)item.FindControl("lblCompany");
        //        lblCompany.Text = objUser.objCompany.Name.ToString();

        //        Image imgUser = (Image)item.FindControl("imgUser");
        //        imgUser.ImageUrl = UsersDetailsViewBO.GetProfilePicturePath(objUser, UsersDetailsViewBO.ImageSize.Medium);

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.NavigateUrl = "/AddEditUser.aspx?id=" + objUser.ID.ToString();
        //        linkEdit.Visible = (this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objUser.ID.ToString());
        //        //linkDelete.Visible = true;

        //        if (objUser.Status == 2)
        //        {
        //            linkDelete.Visible = true;
        //        }
        //        else
        //        {
        //            linkDelete.Visible = false;
        //        }
        //        LinkButton linkResend = (LinkButton)item.FindControl("linkResend");
        //        linkResend.Visible = false;
        //        if (objUser.Status == 3)
        //        {
        //            linkResend.Visible = true;
        //            linkResend.Attributes.Add("uid", objUser.ID.ToString());
        //        }

        //    }
        //}

        //protected void dataGridUser_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.RadGridUsers.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dataGridUser_SortCommand(object source, DataGridSortCommandEventArgs e)
        //{
        //    string sortDirection = String.Empty;
        //    if (!SortExpression.ToUpper().StartsWith(e.SortExpression) && !SortExpression.ToUpper().Trim().EndsWith("ASC"))
        //    {
        //        sortDirection = " asc";
        //    }
        //    else
        //    {
        //        sortDirection = (SortExpression.ToUpper().EndsWith("DESC")) ? " asc" : " desc";
        //    }
        //    this.SortExpression = e.SortExpression + sortDirection;

        //    this.PopulateDataGrid();

        //    foreach (DataGridColumn col in this.RadGridUsers.Columns)
        //    {
        //        if (col.Visible && col.SortExpression == e.SortExpression)
        //        {
        //            col.HeaderStyle.CssClass = "selected " + ((sortDirection.ToUpper() != " DESC") ? "sortDown" : "sortUp");
        //        }
        //        else
        //        {
        //            col.HeaderStyle.CssClass = ((col.HeaderStyle.CssClass == "hide") ? "hide" : string.Empty);
        //        }
        //    }
        //}

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            {
                int userId = int.Parse(hdnSelectedUserID.Value.Trim());

                if (userId > 0)
                {

                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            UserBO objUser = new UserBO(this.ObjContext);
                            objUser.ID = userId;
                            objUser.GetObject();

                            var deledeUsers = (from o in (new UserBO()).SearchObjects()
                                               where o.Username.ToLower().StartsWith(objUser.Username.ToLower())
                                               select o).ToList();

                            var deleteUserEmail = (from o in (new UserBO()).SearchObjects()
                                                   where o.EmailAddress.ToLower().StartsWith(objUser.EmailAddress.ToLower())
                                                   select o).ToList();

                            objUser.Status = 4; //Deleted  
                            objUser.IsDeleted = true;
                            objUser.IsActive = false;
                            objUser.Username = objUser.Username + "_" + (deledeUsers.Count + 1).ToString(); //Guid.NewGuid().ToString().Substring(0, 32);
                            objUser.EmailAddress = objUser.EmailAddress + "_" + (deleteUserEmail.Count + 1) + "@" + objUser.EmailAddress.Split('@')[1].ToString();

                            this.ObjContext.SaveChanges();
                            this.PopulateDataGrid();
                            ts.Complete();
                        }
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }

                }
            }
        }

        protected void ddlSortByCompany_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void linkResend_Click(object sender, EventArgs e)
        {
            int user = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["uid"]);
            if (user > 0)
            {
                UserBO objUser = new UserBO();
                objUser.ID = user;
                objUser.GetObject();

                string hostUrl = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/";
                string emailContent = "<p>A new user has been created. " +
                                      "<p>To complete your registration, simply click the link below.<br>" +
                                      "<a href=\"http://" + hostUrl + "Welcome.aspx?guid=" + objUser.Guid + "&id=" + objUser.ID + "\">http://" + hostUrl + "Welcome.aspx?guid=" + objUser.Guid + "&id=" + objUser.ID + "</a></p>";

                IndicoEmail.SendMailNotifications(this.LoggedUser, objUser, "New user has been created", emailContent);
            }
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            // Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;

            // Populate Company
            List<CompanyBO> lstCotype = new List<CompanyBO>();
            if (this.LoggedUserRoleName == GetUserRole(5) || this.LoggedUserRoleName == GetUserRole(1))
            {
                this.dvSortBy.Visible = true;
                lstCotype = (from o in (new CompanyBO()).SearchObjects()
                             where o.Name != "System" && (o.objType.Name == "Factory" ||
                                   o.objType.Name == "Manufacturer" ||
                                   o.objType.Name == "Sales" ||
                                   o.objType.Name == "Distributor")
                             orderby o.Name select o).ToList();
                foreach (CompanyBO company in lstCotype)
                {
                    this.ddlSortByCompany.Items.Add(new ListItem(company.Name, company.ID.ToString()));
                }
                this.ddlSortByCompany.Items.FindByValue("3").Selected = true;
            }
            else
            {
                this.dvSortBy.Visible = false;
            }

            //Populate Company
            if (this.LoggedUserRoleName != GetUserRole(5) && this.LoggedUserRoleName != GetUserRole(1))
            {
                this.dvSortBy.Visible = false;
            }

            this.btnAddUser.Visible = (this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;

            Session["UserDetailsView"] = null;

            //populate Grid
            this.PopulateDataGrid();
        }

        private void PopulateDataGrid()
        {
            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;


            // Search text
            string searchText = this.txtSearch.Text.ToLower().Trim();

            // Populate Items
            List<UsersDetailsViewBO> lstUser = new List<UsersDetailsViewBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                if (this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.SiteAdministrator)
                {
                    lstUser = (from o in (new UsersDetailsViewBO()).SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                               where (o.Role != 1) &&
                                     (o.Name.ToLower().Contains(searchText) ||
                                      o.Email.ToLower().Contains(searchText) ||
                                      o.Company.ToLower().Contains(searchText) ||
                                      o.Status.ToLower().Contains(searchText)
                                      )
                               select o).ToList();
                }
                else
                {
                    lstUser = (from o in (new UsersDetailsViewBO()).SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                               where o.CompanyType == this.LoggedCompany.objType.Name &&
                                     (o.Role != 1) &&
                                     (o.Name.ToLower().Contains(searchText) ||
                                      o.Email.ToLower().Contains(searchText) ||
                                      o.Company.ToLower().Contains(searchText) ||
                                      o.Status.ToLower().Contains(searchText)
                                      )
                               select o).ToList();
                }
            }
            else
            {
                if (this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.SiteAdministrator)
                {
                    lstUser = (from o in (new UsersDetailsViewBO()).SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                               where (o.CompanyType == "Factory" ||
                                     o.CompanyType == "Manufacturer" ||
                                      o.CompanyType == "Sales" ||
                                      o.CompanyType == "Distributor")
                               select o).ToList();
                }
                else if (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator)
                {
                    lstUser = (from o in (new UsersDetailsViewBO()).SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                               where o.Company == this.LoggedCompany.Name &&
                                     o.IsDistributor == true &&
                                   ((o.Role == 10 || o.Role == 11))
                               select o).ToList();
                }
                else
                {
                    lstUser = (from o in (new UsersDetailsViewBO()).SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                               where o.CompanyType == this.LoggedCompany.objType.Name &&
                                   (o.Role != 1)
                               select o).ToList();
                }
            }
            if (this.LoggedUserRoleName == GetUserRole(5) || this.LoggedUserRoleName == GetUserRole(1))
            {
                if ((Session["xCompany"] != null && int.Parse(Session["xCompany"].ToString()) > 0) && (Session["isChangeUser"] != null && Convert.ToBoolean(Session["isChangeUser"].ToString()) == true))
                {
                    this.ddlSortByCompany.Items.FindByValue(this.ddlSortByCompany.SelectedItem.Value).Selected = false;
                    this.ddlSortByCompany.Items.FindByValue(Session["xCompany"].ToString()).Selected = true;
                    lstUser = (from o in lstUser.Where(o => o.Company == this.ddlSortByCompany.SelectedItem.Text) select o).ToList();
                    Session["isChangeUser"] = false;
                }
                else if (int.Parse(this.ddlSortByCompany.SelectedItem.Value) > 0)
                {
                    lstUser = (from o in lstUser.Where(o => o.Company == this.ddlSortByCompany.SelectedItem.Text) select o).ToList();
                    Session["xCompany"] = this.ddlSortByCompany.SelectedValue;
                    Session["isChangeUser"] = false;
                }
            }

            if (lstUser.Count > 0)
            {
                this.RadGridUsers.AllowPaging = (lstUser.Count > this.RadGridUsers.PageSize);
                this.RadGridUsers.DataSource = lstUser;
                this.RadGridUsers.DataBind();
                Session["UserDetailsView"] = lstUser;

                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search"))
            {
                if (this.LoggedUserRoleName == GetUserRole(5) && int.Parse(this.ddlSortByCompany.SelectedItem.Value) > 0)
                {
                    this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                    this.dvDataContent.Visible = true;
                    this.dvNoSearchResult.Visible = true;
                }
                else
                {
                    this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                    this.dvDataContent.Visible = true;
                    this.dvNoSearchResult.Visible = true;
                }
            }
            else
            {
                this.dvEmptyContent.Visible = true;
                this.btnAddUser.Visible = false;
            }

            this.RadGridUsers.Visible = (lstUser.Count > 0);
        }

        private void ReBindGrid()
        {
            if (Session["UserDetailsView"] != null)
            {
                RadGridUsers.DataSource = (List<UsersDetailsViewBO>)Session["UserDetailsView"];
                RadGridUsers.DataBind();
            }
        }

        #endregion
    }
}