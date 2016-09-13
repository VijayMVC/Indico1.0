using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;
using System.IO;
using System.Transactions;

namespace Indico
{
    public partial class ViewReservations : IndicoPage
    {
        #region Fields

        private DateTime qpWeekEndDate = new DateTime(1100, 1, 1);

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ReservationSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "ID";
                }
                return sort;
            }
            set
            {
                ViewState["ReservationSortExpression"] = value;
            }
        }

        public bool IsNotRefresh
        {
            get
            {
                return (Session["IsPostBack"].ToString() == ViewState["IsPostBack"].ToString());
            }
        }

        protected DateTime WeekEndDate
        {
            get
            {
                //if (qpWeekEndDate != new DateTime(1100, 1, 1))
                //    return qpWeekEndDate;
                if (Request.QueryString["WeekendDate"] != null)
                {
                    qpWeekEndDate = Convert.ToDateTime(Request.QueryString["WeekendDate"].ToString());
                }
                return qpWeekEndDate;
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

        protected void RadGridReservations_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridReservations_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridReservations_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridReservations_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is ReservationDetailsViewBO)
                {
                    ReservationDetailsViewBO objReservation = (ReservationDetailsViewBO)item.DataItem;

                    //ReservationBO objRes = new ReservationBO();
                    //objRes.ID = (int)objReservation.ID;
                    //objRes.GetObject();

                    //int totalOrderQty = (objRes.OrderDetailsWhereThisIsReservation.Count > 0) ? objRes.OrderDetailsWhereThisIsReservation.Sum(o => o.OrderDetailQtysWhereThisIsOrderDetail.Sum(p => p.Qty)) : 0; //(objRes.OrdersWhereThisIsReservation.Count > 0) ? objRes.OrdersWhereThisIsReservation.Sum(o => o.OrderDetailsWhereThisIsOrder.Sum(p => p.OrderDetailQtysWhereThisIsOrderDetail.Sum(q => q.Qty))) : 0;

                    //Literal lblOrderQty = (Literal)item.FindControl("lblOrderQty");
                    //lblOrderQty.Text = totalOrderQty.ToString();

                    Literal lblStatus = (Literal)item.FindControl("lblStatus");
                    lblStatus.Text = "<span class=\"label label-" + objReservation.Status.ToLower().Replace(" ", string.Empty).Trim() + "\">" + objReservation.Status + "</span>";

                    //HyperLink linkCreateOrder = (HyperLink)item.FindControl("linkCreateOrder");
                    //linkCreateOrder.NavigateUrl = "AddEditOrder.aspx?rid=" + objReservation.ID.ToString();
                    //if (totalOrderQty >= objReservation.Qty)
                    //{
                    //    linkCreateOrder.Visible = false;
                    //}

                    //HyperLink linkViewOrders = (HyperLink)item.FindControl("linkViewOrders");
                    //linkViewOrders.NavigateUrl = "ViewOrders.aspx?id=" + objReservation.ID.ToString();
                    //if (objRes.OrdersWhereThisIsReservation.Count == 0)
                    //    linkViewOrders.Visible = false;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.NavigateUrl = "AddEditReservation.aspx?id=" + objReservation.ID.ToString();

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objReservation.ID.ToString());
                }

            }
        }

        protected void RadGridReservations_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridReservations_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dgReservations_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is ReservationBO)
        //    {
        //        ReservationBO objReservation = (ReservationBO)item.DataItem;
        //        int totalOrderQty = (objReservation.OrdersWhereThisIsReservation.Count > 0) ? objReservation.OrdersWhereThisIsReservation.Sum(o => o.OrderDetailsWhereThisIsOrder.Sum(p => p.OrderDetailQtysWhereThisIsOrderDetail.Sum(q => q.Qty))) : 0;

        //        Literal lblResNo = (Literal)item.FindControl("lblResNo");
        //        lblResNo.Text = "RES-" + objReservation.ReservationNo.ToString("0000");

        //        Literal lblDate = (Literal)item.FindControl("lblDate");
        //        lblDate.Text = objReservation.OrderDate.ToString("dd MMM yyyy");

        //        Literal lblPatternNo = (Literal)item.FindControl("lblPatternNo");
        //        lblPatternNo.Text = (objReservation.Pattern != null && objReservation.Pattern > 0) ? objReservation.objPattern.Number : string.Empty; ;

        //        Literal lblReservedQty = (Literal)item.FindControl("lblReservedQty");
        //        lblReservedQty.Text = objReservation.Qty.ToString();

        //        Literal lblOrderQty = (Literal)item.FindControl("lblOrderQty");
        //        lblOrderQty.Text = totalOrderQty.ToString();

        //        Literal lblCoordinator = (Literal)item.FindControl("lblCoordinator");
        //        lblCoordinator.Text = objReservation.objCoordinator.GivenName + " " + objReservation.objCoordinator.FamilyName;

        //        Literal lblClient = (Literal)item.FindControl("lblClient");
        //        lblClient.Text = objReservation.objClient.Name;

        //        Literal lblDistributor = (Literal)item.FindControl("lblDistributor");
        //        lblDistributor.Text = objReservation.objDistributor.Name;

        //        Literal lblOrderShipmentDate = (Literal)item.FindControl("lblOrderShipmentDate");
        //        lblOrderShipmentDate.Text = objReservation.ShipmentDate.ToString("dd MMM yyyy");

        //        Literal lblNotes = (Literal)item.FindControl("lblNotes");
        //        lblNotes.Text = objReservation.Notes;

        //        Literal lblStatus = (Literal)item.FindControl("lblStatus");
        //        lblStatus.Text = "<span class=\"label label-" + objReservation.objStatus.Name.ToLower().Replace(" ", string.Empty).Trim() + "\">" + objReservation.objStatus.Name + "</span>";

        //        HyperLink linkCreateOrder = (HyperLink)item.FindControl("linkCreateOrder");
        //        linkCreateOrder.NavigateUrl = "AddEditOrder.aspx?rid=" + objReservation.ID.ToString();
        //        if (totalOrderQty >= objReservation.Qty)
        //        {
        //            linkCreateOrder.Visible = false;
        //        }
        //        HyperLink linkViewOrders = (HyperLink)item.FindControl("linkViewOrders");
        //        linkViewOrders.NavigateUrl = "ViewOrders.aspx?id=" + objReservation.ID.ToString();
        //        if (objReservation.OrdersWhereThisIsReservation.Count == 0)
        //            linkViewOrders.Visible = false;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.NavigateUrl = "AddEditReservation.aspx?id=" + objReservation.ID.ToString();

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objReservation.ID.ToString());
        //    }
        //}

        //protected void dgReservations_PageIndexChanged(object sender, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgReservations.CurrentPageIndex = e.NewPageIndex;
        //    this.PopulateDataGrid();
        //}

        //protected void dgReservations_SortCommand(object source, DataGridSortCommandEventArgs e)
        //{
        //    string sortDirection = String.Empty;

        //    if (!SortExpression.ToUpper().StartsWith(e.SortExpression) && !SortExpression.ToUpper().Trim().EndsWith("ASC"))
        //        sortDirection = " asc";
        //    else
        //        sortDirection = (SortExpression.ToUpper().EndsWith("DESC")) ? " asc" : " desc";

        //    this.SortExpression = e.SortExpression + sortDirection;
        //    this.PopulateDataGrid();

        //    foreach (DataGridColumn col in this.dgReservations.Columns)
        //    {
        //        if (col.Visible && col.SortExpression == e.SortExpression)
        //        {
        //            col.HeaderStyle.CssClass = "selected " + ((sortDirection.ToUpper() != " DESC") ? "sortDown" : "sortUp");
        //        }
        //        else if (!col.HeaderStyle.CssClass.Contains("hide"))
        //        {
        //            col.HeaderStyle.CssClass = "";
        //        }
        //    }
        //}

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void ddlFilterBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int reservationId = int.Parse(this.hdnSelectedID.Value);

            using (TransactionScope ts = new TransactionScope())
            {
                try
                {
                    ReservationBO objReservation = new ReservationBO(this.ObjContext);
                    objReservation.ID = reservationId;
                    objReservation.GetObject();

                    objReservation.Delete();
                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while deleting reservation", ex);
                }
            }

            this.PopulateControls();
        }

        protected void ddlCoordinator_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void ddlDistributor_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;

            //Populate Order statuses for sorting
            List<ReservationStatusBO> lstReservationStatus = (new ReservationStatusBO()).GetAllObject();
            this.ddlFilterBy.Items.Add(new ListItem("All", "0"));
            foreach (ReservationStatusBO reservationStatus in lstReservationStatus)
            {
                this.ddlFilterBy.Items.Add(new ListItem(reservationStatus.Name, (reservationStatus.ID).ToString()));
            }

            //this.ddlDistributor.Items.Clear();
            //List<int> lstDistributors = (new ReservationBO()).GetAllObject().Where(o => o.objDistributor.IsActive == true).Select(o => o.Distributor).Distinct().ToList();
            //this.ddlDistributor.Items.Add(new ListItem("Select a Distributor", "0"));

            //foreach (int distributor in lstDistributors)
            //{
            //    CompanyBO objCompany = new CompanyBO();
            //    objCompany.ID = distributor;
            //    objCompany.GetObject();

            //    this.ddlDistributor.Items.Add(new ListItem(objCompany.Name, objCompany.ID.ToString()));
            //}

            //this.ddlCoordinator.Items.Clear();
            //List<int> lstCoordinators = (new ReservationBO()).GetAllObject().Where(o => o.objCoordinator.IsActive == true).Select(o => o.Coordinator).Distinct().ToList();
            //this.ddlCoordinator.Items.Add(new ListItem("Select a Coordinator", "0"));

            //foreach (int distributor in lstCoordinators)
            //{
            //    UserBO objUser = new UserBO();
            //    objUser.ID = distributor;
            //    objUser.GetObject();

            //    this.ddlCoordinator.Items.Add(new ListItem(objUser.GivenName + " " + objUser.FamilyName, objUser.ID.ToString()));
            //}

            Session["ReservationDetails"] = null;

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

            List<ReservationDetailsViewBO> lstReservations = new List<ReservationDetailsViewBO>();

            DateTime? selecteddate2 = null;

            if (WeekEndDate != new DateTime(1100, 1, 1))
            {
                selecteddate2 = WeekEndDate;

                int offset = WeekEndDate.DayOfWeek - DayOfWeek.Monday;

                DateTime lastMonday = WeekEndDate.AddDays(-offset);
                DateTime nextSunday = lastMonday.AddDays(6);

                this.litHeaderText.Text = "" + "Reservations for period " + lastMonday.ToShortDateString() + " - " + nextSunday.ToShortDateString() + "";
            }

            //Sort by condition
            /* int sortbyStatus = int.Parse(this.ddlFilterBy.SelectedItem.Value);
             if (sortbyStatus != 0)
                 objReservation.StatusID = sortbyStatus;*/

            string coordinator = string.Empty;
            string distributor = string.Empty;
            string filter = (int.Parse(this.ddlFilterBy.SelectedValue) > 0) ? this.ddlFilterBy.SelectedItem.Text : string.Empty;

            if (this.LoggedUser.IsDirectSalesPerson)
            {
                distributor = this.Distributor.ID.ToString();
            }
            else if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
            {
                coordinator = this.LoggedUser.ID.ToString();
            }

            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstReservations = ReservationBO.GetReservationDetails(WeekEndDate, searchText, filter, distributor, coordinator);
            }
            else
            {
                lstReservations = ReservationBO.GetReservationDetails(selecteddate2, string.Empty, filter, distributor, coordinator);
            }

            if (lstReservations.Count > 0)
            {
                this.RadGridReservations.AllowPaging = (lstReservations.Count > this.RadGridReservations.PageSize);
                this.RadGridReservations.DataSource = lstReservations;
                this.RadGridReservations.DataBind();
                Session["ReservationDetails"] = lstReservations;

                this.dvDataContent.Visible = true;
                this.btnAddOrder.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search") || ((int.Parse(this.ddlFilterBy.SelectedValue) > 0))) //|| (int.Parse(this.ddlDistributor.SelectedValue) > 0) || (int.Parse(this.ddlCoordinator.SelectedValue) > 0)))
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty) + "Filter by " + this.ddlFilterBy.SelectedItem.Text;

                this.btnAddOrder.Visible = true;
                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyContent.Visible = true;
                this.btnAddOrder.Visible = false;
            }
            this.RadGridReservations.Visible = (lstReservations.Count > 0);
        }

        private void ReBindGrid()
        {
            if (Session["ReservationDetails"] != null)
            {
                RadGridReservations.DataSource = (List<ReservationDetailsViewBO>)Session["ReservationDetails"];
                RadGridReservations.DataBind();
            }
        }

        #endregion

    }
}