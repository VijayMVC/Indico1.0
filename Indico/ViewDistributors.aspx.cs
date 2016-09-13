using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;
using Dapper;
using Indico.BusinessObjects;
using Indico.Common;
using System.Data.SqlClient;
using System.Configuration;

namespace Indico
{
    public partial class ViewDistributors : IndicoPage
    {
        #region Fields

        int pageindex = 0;
        private int dgPageSize = 20;

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["DistributorSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "0";
                }
                return sort;
            }
            set
            {
                ViewState["DistributorSortExpression"] = value;
            }
        }

        private bool OrderBy
        {
            get
            {
                return (Session["DistributorOrderBy"] != null) ? (bool)Session["DistributorOrderBy"] : false;
            }
            set
            {
                Session["DistributorOrderBy"] = value;
            }
        }

        private int pageIndex
        {
            get
            {
                if (pageindex == 0)
                {
                    pageindex = 1;
                }
                return pageindex;
            }

            set
            {
                pageindex = value;
            }
        }

        private int TotalCount
        {
            get
            {
                int totalCount = (Session["totalCount"] != null) ? int.Parse(Session["totalCount"].ToString()) : 1;
                return totalCount;
            }
            set
            {
                Session["totalCount"] = value;
            }
        }

        protected int LoadedPageNumber
        {
            get
            {
                int c = 1;
                try
                {
                    if (Session["LoadedPageNumber"] != null)
                    {
                        c = Convert.ToInt32(Session["LoadedPageNumber"]);
                    }
                }
                catch (Exception)
                {
                    Session["LoadedPageNumber"] = c;
                }
                Session["LoadedPageNumber"] = c;
                return c;

            }
            set
            {
                Session["LoadedPageNumber"] = value;
            }
        }

        protected int DistributorPageCount
        {
            get
            {
                int c = 0;
                try
                {
                    if (Session["DistributorCount"] != null)
                        c = Convert.ToInt32(Session["DistributorCount"]);
                }
                catch (Exception)
                {
                    Session["DistributorCount"] = c;
                }
                Session["DistributorCount"] = c;
                return c;
            }
            set
            {
                Session["DistributorCount"] = value;
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

        #region Events

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

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        //protected void RadGridDistributors_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is DistributorsDetailsView)
        //    {
        //        DistributorsDetailsView objDistributorDetails = (DistributorsDetailsView)item.DataItem;


        //        //HyperLink lnkEdit = (HyperLink)item.FindControl("lnkEdit");
        //        Literal lblName = (Literal)item.FindControl("lblName");
        //        lblName.Text = objDistributorDetails.Name;

        //        Literal lblNickName = (Literal)item.FindControl("lblNickName");
        //        lblNickName.Text = objDistributorDetails.NickName;

        //        Literal lblCoordinator = (Literal)item.FindControl("lblCoordinator");
        //        lblCoordinator.Text = objDistributorDetails.PrimaryCoordinator;


        //        Literal lblSecondaryCoordinator = (Literal)item.FindControl("lblSecondaryCoordinator");
        //        lblSecondaryCoordinator.Text = objDistributorDetails.SecondaryCoordinator;

        //        HyperLink lnkDelete = (HyperLink)item.FindControl("lnkDelete");
        //        lnkDelete.Attributes.Add("qid", objDistributorDetails.Distributor.ToString());

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.NavigateUrl = "/AddEditDistributor.aspx?id=" + objDistributorDetails.Distributor.ToString();



        //        if (objDistributorDetails.Clients == true || objDistributorDetails.DistributorLabels == true ||
        //            objDistributorDetails.DistributorPriceLevelCosts == true || objDistributorDetails.DistributorPriceMarkups == true || objDistributorDetails.DespatchTo == true ||
        //            objDistributorDetails.Order.Value == true || objDistributorDetails.ShipTo == true)
        //        {
        //            lnkDelete.Visible = false;
        //        }


        //    }
        //}

        protected void RadGridDistributors_PageSizeChanged(object sender, Telerik.Web.UI.GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridDistributors_PageIndexChanged(object sender, Telerik.Web.UI.GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridDistributors_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item;

                if (item.ItemIndex > -1 && item.DataItem is DistributorsDetailsView)
                {
                    DistributorsDetailsView objDistributorDetails = (DistributorsDetailsView)item.DataItem;

                    HyperLink lnkDelete = (HyperLink)item.FindControl("lnkDelete");
                    lnkDelete.Attributes.Add("qid", objDistributorDetails.Distributor.ToString());

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.NavigateUrl = "/AddEditDistributor.aspx?id=" + objDistributorDetails.Distributor.ToString();

                    //if (objDistributorDetails.Clients == true || objDistributorDetails.DistributorLabels == true ||
                    //    objDistributorDetails.DistributorPriceLevelCosts == true || objDistributorDetails.DistributorPriceMarkups == true || objDistributorDetails.DespatchTo == true ||
                    //    objDistributorDetails.Order.Value == true || objDistributorDetails.ShipTo == true)
                    //{
                    //    lnkDelete.Visible = false;
                    //}

                    lnkDelete.Visible = objDistributorDetails.CanDelete;
                }
            }
        }

        protected void RadGridDistributors_GroupsChanging(object sender, Telerik.Web.UI.GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridDistributors_ItemCommand(object sender, Telerik.Web.UI.GridCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridDistributors_SortCommand(object sender, Telerik.Web.UI.GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, EventArgs e)
        {
            this.ReBindGrid();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            {
                int companyId = int.Parse(hdnSelectedCompanyID.Value.Trim());

                if (companyId > 0)
                {
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            CompanyBO objCompany = new CompanyBO(this.ObjContext);
                            objCompany.ID = companyId;
                            objCompany.GetObject();

                            objCompany.IsActive = false;
                            objCompany.IsDelete = true;

                            this.ObjContext.SaveChanges();
                            ts.Complete();

                        }

                        this.PopulateDataGrid();
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }
        }

        protected void RadGridDistributors_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.RadGridDistributors.CurrentPageIndex = e.NewPageIndex;
            pageindex = e.NewPageIndex;
            this.PopulateDataGrid();
        }

        protected void RadGridDistributors_SortCommand(object source, DataGridSortCommandEventArgs e)
        {
            switch (e.SortExpression)
            {
                case "Name":
                    SortExpression = "0";
                    break;
                case "NickName":
                    SortExpression = "1";
                    break;
                case "PrimaryCoordinator":
                    SortExpression = "2";
                    break;
                case "SecondaryCoordinator":
                    SortExpression = "3";
                    break;
            }

            this.OrderBy = !this.OrderBy;

            this.PopulateDataGrid();

            foreach (DataGridColumn col in this.RadGridDistributors.Columns)
            {
                if (col.Visible && col.SortExpression == e.SortExpression)
                {
                    col.HeaderStyle.CssClass = "selected " + ((OrderBy == true) ? "sortDown" : "sortUp");
                }
                else
                {
                    col.HeaderStyle.CssClass = ((col.HeaderStyle.CssClass == "hide") ? "hide" : string.Empty);
                }
            }
        }

        protected void ddlPrimaryCoordinator_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void ddlSecondaryCoordinator_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnReplaceCoordinator_Click(object sender, EventArgs e)
        {
            bool isRedirect = false;

            if (this.IsNotRefresh)
            {
                if (this.ddlCurrentCoordinator.SelectedValue != "0" && this.ddlReplaceCoordinator.SelectedValue != "0")
                {
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            if (this.rbPrimary.Checked == true)
                            {
                                if (this.ddlCurrentCoordinator.SelectedValue != this.ddlReplaceCoordinator.SelectedValue)
                                {
                                    List<CompanyBO> lstpCoordinator = (from o in (new CompanyBO()).SearchObjects().Where(o => o.IsDistributor == true && o.Coordinator == int.Parse(this.ddlCurrentCoordinator.SelectedValue) && o.IsActive == true && o.IsDelete == false).OrderBy(o => o.objCoordinator.GivenName) select o).ToList();
                                    if (lstpCoordinator.Count > 0)
                                    {
                                        foreach (CompanyBO coordinator in lstpCoordinator)
                                        {
                                            CompanyBO objCompany = new CompanyBO(this.ObjContext);
                                            objCompany.ID = coordinator.ID;
                                            objCompany.GetObject();

                                            objCompany.Coordinator = int.Parse(this.ddlReplaceCoordinator.SelectedValue);
                                            this.ObjContext.SaveChanges();
                                        }
                                        isRedirect = true;
                                        ViewState["ReplaceCoordinator"] = false;
                                    }
                                }
                                else
                                {
                                    CustomValidator customValidator = new CustomValidator();
                                    customValidator.ErrorMessage = "This coordinator already exists";
                                    customValidator.IsValid = false;
                                    customValidator.EnableClientScript = false;

                                    isRedirect = false;
                                    this.validationSummary.Controls.Add(customValidator);
                                    ViewState["ReplaceCoordinator"] = true;
                                }
                            }
                            else if (this.rbSecondary.Checked == true)
                            {
                                if (this.ddlCurrentCoordinator.SelectedValue != this.ddlReplaceCoordinator.SelectedValue)
                                {
                                    List<CompanyBO> lstRepCoordinator = (from o in (new CompanyBO()).SearchObjects().Where(o => o.IsDistributor == true && o.SecondaryCoordinator == int.Parse(this.ddlCurrentCoordinator.SelectedValue)).OrderBy(o => o.objSecondaryCoordinator.GivenName) select o).ToList();
                                    if (lstRepCoordinator.Count > 0)
                                    {
                                        foreach (CompanyBO scoordinator in lstRepCoordinator)
                                        {
                                            CompanyBO objCompany = new CompanyBO(this.ObjContext);
                                            objCompany.ID = scoordinator.ID;
                                            objCompany.GetObject();

                                            objCompany.SecondaryCoordinator = int.Parse(this.ddlReplaceCoordinator.SelectedValue);
                                            this.ObjContext.SaveChanges();
                                        }
                                    }
                                    isRedirect = true;
                                    ViewState["ReplaceCoordinator"] = false;
                                }
                                else
                                {
                                    CustomValidator customValidator = new CustomValidator();
                                    customValidator.ErrorMessage = "This coordinator already exists";
                                    customValidator.IsValid = false;
                                    customValidator.EnableClientScript = false;

                                    isRedirect = false;
                                    this.validationSummary.Controls.Add(customValidator);
                                    ViewState["ReplaceCoordinator"] = true;
                                }
                            }
                            else if (this.rbBoth.Checked == true)
                            {
                                if (this.ddlCurrentCoordinator.SelectedValue != this.ddlReplaceCoordinator.SelectedValue)
                                {
                                    List<CompanyBO> lstpCoordinator = (from o in (new CompanyBO()).SearchObjects().Where(o => o.IsDistributor == true && o.Coordinator == int.Parse(this.ddlCurrentCoordinator.SelectedValue)).OrderBy(o => o.objCoordinator.GivenName) select o).ToList();
                                    if (lstpCoordinator.Count > 0)
                                    {
                                        foreach (CompanyBO coordinator in lstpCoordinator)
                                        {
                                            CompanyBO objCompany = new CompanyBO(this.ObjContext);
                                            objCompany.ID = coordinator.ID;
                                            objCompany.GetObject();

                                            objCompany.Coordinator = int.Parse(this.ddlReplaceCoordinator.SelectedValue);
                                            this.ObjContext.SaveChanges();
                                        }
                                        isRedirect = true;
                                        ViewState["ReplaceCoordinator"] = false;
                                    }

                                    List<CompanyBO> lstRepCoordinator = (from o in (new CompanyBO()).SearchObjects().Where(o => o.IsDistributor == true && o.SecondaryCoordinator == int.Parse(this.ddlCurrentCoordinator.SelectedValue)).OrderBy(o => o.objSecondaryCoordinator.GivenName) select o).ToList();
                                    if (lstRepCoordinator.Count > 0)
                                    {
                                        foreach (CompanyBO scoordinator in lstRepCoordinator)
                                        {
                                            CompanyBO objCompany = new CompanyBO(this.ObjContext);
                                            objCompany.ID = scoordinator.ID;
                                            objCompany.GetObject();

                                            objCompany.SecondaryCoordinator = int.Parse(this.ddlReplaceCoordinator.SelectedValue);
                                            this.ObjContext.SaveChanges();
                                        }
                                        isRedirect = true;
                                        ViewState["ReplaceCoordinator"] = false;
                                    }
                                }
                                else
                                {
                                    CustomValidator customValidator = new CustomValidator();
                                    customValidator.ErrorMessage = "This coordinator already exists";
                                    customValidator.IsValid = false;
                                    customValidator.EnableClientScript = false;

                                    isRedirect = false;
                                    this.validationSummary.Controls.Add(customValidator);
                                    ViewState["ReplaceCoordinator"] = true;
                                }
                            }
                            ts.Complete();
                        }
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while updating coordinators in ViewDistribotors", ex);
                    }
                }
            }
            if (isRedirect)
            {
                Response.Redirect("/ViewDistributors.aspx");
            }
        }

        protected void lbHeaderPrevious_Click(object sender, EventArgs e)
        {
            LinkButton lk = new LinkButton();
            lk.ID = "lbHeader" + (--this.LoadedPageNumber).ToString();
            lk.Text = (--this.LoadedPageNumber).ToString();
            this.lbHeader1_Click(lk, e);
        }

        protected void lbHeaderNext_Click(object sender, EventArgs e)
        {
            LinkButton lk = new LinkButton();
            lk.ID = "lbHeader" + (++this.LoadedPageNumber).ToString();
            lk.Text = (++this.LoadedPageNumber).ToString();
            this.lbHeader1_Click(lk, e);
        }

        protected void lbHeaderNextDots_Click(object sender, EventArgs e)
        {
            LinkButton lk = new LinkButton();
            //lk.ID = "lbHeader" + ((ActivitiesTotal % 10 == 0) ? (ActivitiesTotal / 10) : (ActivitiesTotal / 10) + 1).ToString();
            //lk.Text = ((ActivitiesTotal % 10 == 0) ? (ActivitiesTotal / 10) : (ActivitiesTotal / 10) + 1).ToString();

            int nextSet = (LoadedPageNumber % 10 == 0) ? (LoadedPageNumber + 1) : ((this.LoadedPageNumber / 10) * 10) + 11;
            lk.ID = "lbHeader" + nextSet.ToString();
            lk.Text = nextSet.ToString();
            this.lbHeader1_Click(lk, e);

            //((ActivitiesTotal % 10 == 0) ? (ActivitiesTotal / 10) : (ActivitiesTotal / 10) + 1)
        }

        protected void lbHeaderPreviousDots_Click(object sender, EventArgs e)
        {
            LinkButton lk = new LinkButton();
            //lk.ID = "lbHeader" + (1).ToString();
            //lk.Text = (1).ToString();
            int previousSet = (LoadedPageNumber % 10 == 0) ? (LoadedPageNumber - 19) : (((this.LoadedPageNumber / 10) * 10) - 9);
            lk.ID = "lbHeader" + previousSet.ToString();
            lk.Text = previousSet.ToString();
            this.lbHeader1_Click(lk, e);
        }

        protected void lbHeader1_Click(object sender, EventArgs e)
        {
            //rfvDistributor.Enabled = false;
            //rfvLabelName.Enabled = false;
            //cvLabel.Enabled = false;

            string clickedPageText = ((LinkButton)sender).Text;
            int clickedPageNumber = Convert.ToInt32(clickedPageText);
            Session["LoadedPageNumber"] = clickedPageNumber;
            int currentPage = 1;

            this.ClearCss();

            if (clickedPageNumber > 10)
                currentPage = (clickedPageNumber % 10) == 0 ? 10 : clickedPageNumber % 10;
            else
                currentPage = clickedPageNumber;

            this.HighLightPageNumber(currentPage);

            this.lbFooterNext.Visible = true;
            this.lbFooterPrevious.Visible = true;

            if (clickedPageNumber == ((TotalCount % dgPageSize == 0) ? TotalCount / dgPageSize : Math.Floor((double)(TotalCount / dgPageSize)) + 1))
                this.lbFooterNext.Visible = false;
            if (clickedPageNumber == 1)
                this.lbFooterPrevious.Visible = false;

            //int startIndex = clickedPageNumber * 10 - 10;
            this.pageIndex = clickedPageNumber;
            this.PopulateDataGrid();

            if (clickedPageNumber % 10 == 1)
                this.ProcessNumbering(clickedPageNumber, DistributorPageCount);
            else
            {
                if (clickedPageNumber > 10)
                {
                    if (clickedPageNumber % 10 == 0)
                        this.ProcessNumbering(clickedPageNumber - 9, DistributorPageCount);
                    else
                        this.ProcessNumbering(((clickedPageNumber / 10) * 10) + 1, DistributorPageCount);
                }
                else
                {
                    this.ProcessNumbering((clickedPageNumber / 10 == 0) ? 1 : clickedPageNumber / 10, DistributorPageCount);
                }
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary> 
        /// 

        private void PopulateControls()
        {
            // Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;
            ViewState["ReplaceCoordinator"] = false;
            Session["totalCount"] = 1;
            Session["LoadedPageNumber"] = 1;
            Session["DistributorCount"] = 0;
            Session["DistributorOrderBy"] = false;
            Session["DistributorsDetailsView"] = null;
            this.dvDataContent.Visible = false;

            // populate primary coordinator
            ReturnDistributorPrimaryCoordinatorBO objDistributorPrimaryCoordinator = new ReturnDistributorPrimaryCoordinatorBO();
            CompanyExtensions.BindList(this.ddlPrimaryCoordinator, (from o in objDistributorPrimaryCoordinator.SearchObjects().OrderBy(o => o.Name) select o).ToList(), "ID", "Name");

            //populate secondary coordinator
            ReturnDistributorSecondaryCoordinatorBO objDistributorSecondaryCoordinator = new ReturnDistributorSecondaryCoordinatorBO();
            CompanyExtensions.BindList(this.ddlSecondaryCoordinator, (from o in objDistributorSecondaryCoordinator.SearchObjects().OrderBy(o => o.Name) select o).ToList(), "ID", "Name");

            if (this.LoggedUserRoleName == GetUserRole(5))
            {
                this.btnReplaceCoordinators.Visible = true;
                // populate current coordinator                
                this.ddlCurrentCoordinator.Items.Add(new ListItem("Select current coordinator", "0"));
                this.ddlReplaceCoordinator.Items.Add(new ListItem("Select replace coordinator", "0"));

                List<UserBO> lstcurcoordinator = (from co in new UserBO().GetAllObject().AsQueryable().OrderBy("GivenName").ToList()
                                                  where co.objCompany.Type == 3
                                                  select co).ToList();
                foreach (UserBO prcoordinator in lstcurcoordinator)
                {
                    this.ddlCurrentCoordinator.Items.Add(new ListItem(prcoordinator.GivenName + " " + prcoordinator.FamilyName, prcoordinator.ID.ToString()));
                    this.ddlReplaceCoordinator.Items.Add(new ListItem(prcoordinator.GivenName + " " + prcoordinator.FamilyName, prcoordinator.ID.ToString()));
                }
            }
            this.PopulateDataGrid();
        }

        private void PopulateDataGrid()
        {
            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;
            string pcoordinator = string.Empty;
            string scoordinator = string.Empty;
            string searchText = string.Empty;

            // Populate Distributors
            List<DistributorsDetailsView> lstDistributorDetailsView = new List<DistributorsDetailsView>();
            int totalCount = 0;

            if ((this.txtSearch.Text != string.Empty) && (this.txtSearch.Text != "search"))
            {
                // Search text
                searchText = this.txtSearch.Text.ToLower().Trim();
            }

            // search primary coodinator
            if (this.ddlPrimaryCoordinator.SelectedIndex != 0)
            {
                pcoordinator = this.ddlPrimaryCoordinator.SelectedItem.Text;
            }

            //search secondary coodinator
            if (this.ddlSecondaryCoordinator.SelectedIndex != 0)
            {
                scoordinator = this.ddlSecondaryCoordinator.SelectedItem.Text;
            }

            if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
            {
                pcoordinator = this.LoggedUser.ID.ToString();
            }

            //lstDistributorDetailsView = CompanyBO.GetDistributorDetails(searchText, dgPageSize, pageIndex, int.Parse(SortExpression), OrderBy, out totalCount, pcoordinator, scoordinator).ToList();

            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Open();

                lstDistributorDetailsView = connection.Query<DistributorsDetailsView>(string.Format(@"EXEC [Indico].[dbo].[SPC_ViewDistributorsDetails] '{0}','{1}','{2}'", searchText, pcoordinator, scoordinator)).ToList();
                connection.Close();
            }

            if (lstDistributorDetailsView.Count > 0)
            {
                this.RadGridDistributors.AllowPaging = (lstDistributorDetailsView.Count > this.RadGridDistributors.PageSize);
                this.RadGridDistributors.DataSource = lstDistributorDetailsView;
                this.RadGridDistributors.DataBind();
                Session["DistributorsDetailsView"] = lstDistributorDetailsView;
                /*TotalCount = (totalCount == 0) ? TotalCount : totalCount;

                Session["DistributorCount"] = (TotalCount % dgPageSize == 0) ? (TotalCount / dgPageSize) : ((TotalCount / dgPageSize) + 1);

                this.dvPagingFooter.Visible = (TotalCount > dgPageSize);
                this.lbFooterPrevious.Visible = (pageIndex != 1 && pageIndex != 90);
                this.ProcessNumbering(1, Convert.ToInt32(Session["DistributorCount"]));*/

                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search") || this.ddlPrimaryCoordinator.SelectedIndex != 0 || this.ddlSecondaryCoordinator.SelectedIndex != 0)
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;

                this.dvPagingFooter.Visible = false;
                this.lbFooterPrevious.Visible = false;
            }
            else
            {
                this.dvDataContent.Visible = false;
                this.dvEmptyContent.Visible = true;
                this.btnAddDistributor.Visible = false;

                this.dvPagingFooter.Visible = false;
                this.lbFooterPrevious.Visible = false;
            }

            this.RadGridDistributors.Visible = (lstDistributorDetailsView.Count > 0);
        }

        private void ProcessNumbering(int start, int count)
        {
            this.lbFooterPreviousDots.Visible = true;
            this.lbFooterNextDots.Visible = true;

            int i = start;
            // 1
            if (i <= count)
            {
                this.lbFooter1.Visible = true;
                this.lbFooter1.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter1.Visible = false;
            }
            // 2
            if (++i <= count)
            {
                this.lbFooter2.Visible = true;
                this.lbFooter2.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter2.Visible = false;
            }
            // 3
            if (++i <= count)
            {
                this.lbFooter3.Visible = true;
                this.lbFooter3.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter3.Visible = false;
            }
            // 4
            if (++i <= count)
            {
                this.lbFooter4.Visible = true;
                this.lbFooter4.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter4.Visible = false;
            }
            // 5
            if (++i <= count)
            {
                this.lbFooter5.Visible = true;
                this.lbFooter5.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter5.Visible = false;
            }
            // 6
            if (++i <= count)
            {
                this.lbFooter6.Visible = true;
                this.lbFooter6.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter6.Visible = false;
            }
            // 7
            if (++i <= count)
            {
                this.lbFooter7.Visible = true;
                this.lbFooter7.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter7.Visible = false;
            }
            // 8
            if (++i <= count)
            {
                this.lbFooter8.Visible = true;
                this.lbFooter8.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter8.Visible = false;
            }
            // 9
            if (++i <= count)
            {
                this.lbFooter9.Visible = true;
                this.lbFooter9.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter9.Visible = false;
            }
            // 10
            if (++i <= count)
            {
                this.lbFooter10.Visible = true;
                this.lbFooter10.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter10.Visible = false;
            }

            int loadedPageTemp = (LoadedPageNumber % 10 == 0) ? ((LoadedPageNumber - 1) / 10) : (LoadedPageNumber / 10);

            if (TotalCount <= 10 * dgPageSize)
            {
                this.lbFooterPreviousDots.Visible = false;
                this.lbFooterNextDots.Visible = false;
            }

            else if (TotalCount - ((loadedPageTemp) * 10 * dgPageSize) <= 10 * dgPageSize)
            {
                this.lbFooterNextDots.Visible = false;
            }
            else
            {
                this.lbFooterPreviousDots.Visible = (this.lbFooter1.Text == "1") ? false : true;
            }
        }

        private void HighLightPageNumber(int clickedPageNumber)
        {
            LinkButton clickedLink = (LinkButton)this.FindControlRecursive(this, "lbFooter" + clickedPageNumber);
            clickedLink.CssClass = "paginatorLink current";
        }

        private void ClearCss()
        {
            for (int i = 1; i <= 10; i++)
            {
                LinkButton lbFooter = (LinkButton)this.FindControlRecursive(this, "lbFooter" + i.ToString());
                lbFooter.CssClass = "paginatorLink";
            }
        }

        private Control FindControlRecursive(Control root, string id)
        {
            if (root.ID == id)
            {
                return root;
            }

            foreach (Control c in root.Controls)
            {
                Control t = FindControlRecursive(c, id);
                if (t != null)
                {
                    return t;
                }
            }

            return null;
        }

        private void ReBindGrid()
        {
            if (Session["DistributorsDetailsView"] != null)
            {
                RadGridDistributors.DataSource = (List<DistributorsDetailsView>)Session["DistributorsDetailsView"];
                RadGridDistributors.DataBind();
            }
        }

        #endregion

        #region inner class

        private class DistributorsDetailsView
        {
            public int Distributor { get; set; }
            public string Type { get; set; }
            public bool IsDistributor { get; set; }
            public string Name { get; set; }
            public string Number { get; set; }
            public string Address1 { get; set; }
            public string Address2 { get; set; }
            public string City { get; set; }
            public string State { get; set; }
            public string PostCode { get; set; }
            public string Country { get; set; }
            public string Phone1 { get; set; }
            public string Phone2 { get; set; }
            public string Fax { get; set; }
            public string NickName { get; set; }
            public string PrimaryCoordinator { get; set; }
            public string Owner { get; set; }
            public string Creator { get; set; }
            public DateTime? CreatedDate { get; set; }
            public string Modifier { get; set; }
            public DateTime? ModifiedDate { get; set; }
            public string SecondaryCoordinator { get; set; }
            public bool IsActive { get; set; }
            public bool IsDelete { get; set; }
            public bool CanDelete { get; set; }

            //public int CostSheet { get; set; }

            //public decimal QuotedFOBCost { get; set; }
            //public decimal QuotedCIF { get; set; }
            //public decimal QuotedMP { get; set; }
            //public decimal ExchangeRate { get; set; }
            //public int PatternID { get; set; }
            //public string Pattern { get; set; }
            //public string Fabric { get; set; }
            //public string Category { get; set; }
            //public decimal SMV { get; set; }
            //public decimal SMVRate { get; set; }
            //public decimal CalculateCM { get; set; }
            //public decimal TotalFabricCost { get; set; }
            //public decimal TotalAccessoriesCost { get; set; }
            //public decimal HPCost { get; set; }
            //public decimal LabelCost { get; set; }
            //public decimal CM { get; set; }
            //public decimal JKFOBCost { get; set; }
            //public decimal Roundup { get; set; }
            //public decimal DutyRate { get; set; }
            //public decimal SubCons { get; set; }
            //public decimal MarginRate { get; set; }
            //public decimal Duty { get; set; }
            //public decimal FOBAUD { get; set; }
            //public decimal AirFregiht { get; set; }
            //public decimal ImpCharges { get; set; }
            //public decimal Landed { get; set; }
            //public decimal MGTOH { get; set; }
            //public decimal IndicoOH { get; set; }
            //public decimal InkCost { get; set; }
            //public decimal PaperCost { get; set; }
            //public bool ShowToIndico { get; set; }
            //public DateTime? ModifiedDate { get; set; }
            //public DateTime? IndimanModifiedDate { get; set; }
        }

        #endregion
    }
}