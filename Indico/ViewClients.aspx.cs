using System;
using System.Collections.Generic;
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
    public partial class ViewClients : IndicoPage
    {
        #region Fields

        private int pageindex = 0;
        private int dgPageSize = 20;

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ClientSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "0";
                }
                return sort;
            }
            set
            {
                ViewState["ClientSortExpression"] = value;
            }
        }

        private bool OrderBy
        {
            get
            {
                return (Session["ClientsOrderBy"] != null) ? (bool)Session["ClientsOrderBy"] : false;
            }
            set
            {
                Session["ClientsOrderBy"] = value;
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

        protected int ClientPageCount
        {
            get
            {
                int c = 0;
                try
                {
                    if (Session["ClientPageCount"] != null)
                        c = Convert.ToInt32(Session["ClientPageCount"]);
                }
                catch (Exception)
                {
                    Session["ClientPageCount"] = c;
                }
                Session["ClientPageCount"] = c;
                return c;
            }
            set
            {
                Session["ClientPageCount"] = value;
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

        /// <summary>
        /// Page load event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>

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

        protected void RadGridClients_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridClients_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridClients_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if ((item.ItemIndex > -1 && item.DataItem is ReturnClientsDetailsViewBO))
                {
                    ReturnClientsDetailsViewBO objClientDetails = (ReturnClientsDetailsViewBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.NavigateUrl = "/AddEditClient.aspx?id=" + objClientDetails.Client.ToString();

                    HyperLink lnkDelete = (HyperLink)item.FindControl("lnkDelete");
                    lnkDelete.Attributes.Add("qid", objClientDetails.Client.ToString());

                    lnkDelete.Visible = !(objClientDetails.VisualLayouts == true); // (objClientDetails.VisualLayouts == true || objClientDetails.Order == true) ? false : true;
                }
            }
        }

        protected void RadGridClients_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridClients_ItemCommand(object sender, GridCommandEventArgs e)
        {
            //if (e.CommandName == RadGrid.FilterCommandName)
            //{
            this.ReBindGrid();
            //}
        }

        protected void RadGridClients_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void RadGridClients_ItemCommand(object sender, GridCommandEventArgs e)
        //{

        //}

        //protected void RadGridClients_SortCommand(object sender, GridSortCommandEventArgs e)
        //{

        //}

        //protected void dataGridClient_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is ReturnClientsDetailsViewBO)
        //    {
        //        ReturnClientsDetailsViewBO objClientDetails = (ReturnClientsDetailsViewBO)item.DataItem;


        //        Literal lblName = (Literal)item.FindControl("lblName");
        //        lblName.Text = objClientDetails.Name;

        //        Literal lblCompany = (Literal)item.FindControl("lblCompany");
        //        lblCompany.Text = objClientDetails.Distributor;

        //        Literal lblCountry = (Literal)item.FindControl("lblCountry");
        //        lblCountry.Text = objClientDetails.Country;

        //        Literal lblCity = (Literal)item.FindControl("lblCity");
        //        lblCity.Text = objClientDetails.City;

        //        Literal lblEmail = (Literal)item.FindControl("lblEmail");
        //        lblEmail.Text = objClientDetails.Email;

        //        Literal lblPhone = (Literal)item.FindControl("lblPhone");
        //        lblPhone.Text = objClientDetails.Phone;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.NavigateUrl = "/AddEditClient.aspx?id=" + objClientDetails.Client.ToString();

        //        HyperLink lnkDelete = (HyperLink)item.FindControl("lnkDelete");
        //        lnkDelete.Attributes.Add("qid", objClientDetails.Client.ToString());

        //        lnkDelete.Visible = (objClientDetails.VisualLayouts == true || objClientDetails.Order == true || objClientDetails.Reservation == true) ? false : true;


        //    }
        //}

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            {
                int client = int.Parse(hdnSelectedClientID.Value.Trim());

                if (client > 0)
                {
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            JobNameBO objJobName = new JobNameBO(this.ObjContext);
                            objJobName.ID = client;
                            objJobName.GetObject();

                            objJobName.Delete();

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

        //protected void dataGridClient_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridClient.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dataGridClient_SortCommand(object source, DataGridSortCommandEventArgs e)
        //{
        //    switch (e.SortExpression)
        //    {
        //        case "Name":
        //            SortExpression = "0";
        //            break;
        //        case "Distributor":
        //            SortExpression = "1";
        //            break;
        //        case "Country":
        //            SortExpression = "2";
        //            break;
        //        case "City":
        //            SortExpression = "3";
        //            break;
        //        case "Email":
        //            SortExpression = "4";
        //            break;
        //        case "Phone":
        //            SortExpression = "5";
        //            break;
        //    }

        //    this.OrderBy = !this.OrderBy;

        //    this.PopulateDataGrid();

        //    foreach (DataGridColumn col in this.dataGridClient.Columns)
        //    {
        //        if (col.Visible && col.SortExpression == e.SortExpression)
        //        {
        //            col.HeaderStyle.CssClass = "selected " + ((OrderBy == true) ? "sortDown" : "sortUp");
        //        }
        //        else
        //        {
        //            col.HeaderStyle.CssClass = ((col.HeaderStyle.CssClass == "hide") ? "hide" : string.Empty);
        //        }
        //    }
        //}

        /*protected void ddlDistributor_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateDataGrid();
        }*/

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
                this.ProcessNumbering(clickedPageNumber, ClientPageCount);
            else
            {
                if (clickedPageNumber > 10)
                {
                    if (clickedPageNumber % 10 == 0)
                        this.ProcessNumbering(clickedPageNumber - 9, ClientPageCount);
                    else
                        this.ProcessNumbering(((clickedPageNumber / 10) * 10) + 1, ClientPageCount);
                }
                else
                {
                    this.ProcessNumbering((clickedPageNumber / 10 == 0) ? 1 : clickedPageNumber / 10, ClientPageCount);
                }
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;
            ViewState["IsPageValied"] = true;
            Session["ClientPageCount"] = 0;
            Session["LoadedPageNumber"] = 1;
            Session["totalCount"] = 1;
            Session["ClientsOrderBy"] = false;
            Session["ClientDetailsView"] = null;

            // Populate Distributors
            //this.ddlDistributor.Items.Clear();
            //this.ddlDistributor.Items.Add(new ListItem("All", "0"));
            //List<int> lstClient = (new ClientBO()).SearchObjects().Where(o => o.objDistributor.IsActive == true && o.objDistributor.IsDelete == false).OrderBy(o => o.objDistributor.Name).Select(o => (int)o.Distributor).Distinct().ToList();

            //foreach (int id in lstClient)
            //{
            //    CompanyBO objCompany = new CompanyBO();
            //    objCompany.ID = id;
            //    objCompany.GetObject();

            //    this.ddlDistributor.Items.Add(new ListItem(objCompany.Name, objCompany.ID.ToString()));

            //}
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
            string distributor = string.Empty;
            // Populate Distributors

            int totalCount = 0;

            if (this.LoggedUser.IsDirectSalesPerson)
            {
                distributor = "DIS" + this.Distributor.ID.ToString();
            }
            else if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
            {
                distributor = "COD" + this.LoggedUser.ID.ToString();
            }

            List<ReturnClientsDetailsViewBO> lstClientDetailsView = new List<ReturnClientsDetailsViewBO>();
            lstClientDetailsView = JobNameBO.GetJobNameDetails(((searchText != string.Empty) && (searchText != "search")) ? searchText : string.Empty,
                dgPageSize, pageIndex, int.Parse(SortExpression), OrderBy, out totalCount, distributor).ToList();

            if (lstClientDetailsView.Count > 0)
            {
                this.RadGridClients.AllowPaging = (lstClientDetailsView.Count > this.RadGridClients.PageSize);
                this.RadGridClients.DataSource = lstClientDetailsView;
                this.RadGridClients.DataBind();
                Session["ClientDetailsView"] = lstClientDetailsView;

                /*TotalCount = (totalCount == 0) ? TotalCount : totalCount;

                Session["ClientPageCount"] = (TotalCount % dgPageSize == 0) ? (TotalCount / dgPageSize) : ((TotalCount / dgPageSize) + 1);

                this.dvPagingFooter.Visible = (TotalCount > dgPageSize);
                this.lbFooterPrevious.Visible = (pageIndex != 1 && pageIndex != 90);
                this.ProcessNumbering(1, Convert.ToInt32(Session["ClientPageCount"]));*/

                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search"))
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;

                this.dvPagingFooter.Visible = false;
            }
            else
            {
                this.dvEmptyContent.Visible = true;
                this.btnAddClient.Visible = false;

                this.dvPagingFooter.Visible = false;
            }


            this.RadGridClients.Visible = (lstClientDetailsView.Count > 0);
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
            if (Session["ClientDetailsView"] != null)
            {
                RadGridClients.DataSource = (List<ReturnClientsDetailsViewBO>)Session["ClientDetailsView"];
                RadGridClients.DataBind();
            }
        }

        #endregion
    }
}