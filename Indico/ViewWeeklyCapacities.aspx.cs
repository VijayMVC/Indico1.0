using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;
using System.Globalization;
using System.IO;
using System.Drawing;

namespace Indico
{
    public partial class ViewWeeklyCapacities : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ItemsAttributeSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "WeekendDate";
                }
                return sort;
            }
            set
            {
                ViewState["ItemsAttributeSortExpression"] = value;
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

        protected void RadGridWeeklySummary_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridWeeklySummary_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridWeeklySummary_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;
                if (item.ItemIndex > -1 && item.DataItem is WeeklyProductionCapacityBO)
                {
                    WeeklyProductionCapacityBO objProductionCapacity = (WeeklyProductionCapacityBO)item.DataItem;

                    HyperLink linkWeekYear = (HyperLink)item.FindControl("linkWeekYear");
                    linkWeekYear.Text = objProductionCapacity.WeekNo + "/" + objProductionCapacity.WeekendDate.Year;

                    if ((this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator || this.LoggedUserRoleName == UserRole.FactoryAdministrator))
                    {
                        linkWeekYear.NavigateUrl = "ViewSummaryDetails.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy");
                    }

                    if (DateTime.Now < objProductionCapacity.WeekendDate && DateTime.Now > objProductionCapacity.WeekendDate.AddDays(-7))
                    {
                        item.BackColor = Color.Orange;                       
                    }

                    TextBox txtCapacity = (TextBox)item.FindControl("txtCapacity");
                    txtCapacity.Text = objProductionCapacity.Capacity.ToString("#,##0");

                    List<ReturnProductionCapacitiesViewBO> lstPCVPolos = OrderBO.Productioncapacities((DateTime?)objProductionCapacity.WeekendDate, 1);

                    // Jackets data
                    List<ReturnProductionCapacitiesViewBO> lstPCVJackets = OrderBO.Productioncapacities((DateTime?)objProductionCapacity.WeekendDate, 2);

                    HyperLink linkJacketFirm = (HyperLink)item.FindControl("linkJacketFirm");
                    linkJacketFirm.Text = lstPCVJackets[0].Firms.ToString();
                    linkJacketFirm.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Firm";

                    HyperLink linkJacketReservations = (HyperLink)item.FindControl("linkJacketReservations");
                    linkJacketReservations.Text = lstPCVJackets[0].ResevationOrders.ToString() + " " + "(" + lstPCVPolos[0].Resevations.ToString() + ")";
                    linkJacketReservations.NavigateUrl = "ViewReservations.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy");

                    HyperLink linkJacketTotal = (HyperLink)item.FindControl("linkJacketTotal");
                    linkJacketTotal.Text = (lstPCVJackets[0].Firms + lstPCVPolos[0].ResevationOrders).ToString();
                    linkJacketTotal.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Total";

                    HyperLink linkJacketHold = (HyperLink)item.FindControl("linkJacketHold");
                    linkJacketHold.Text = lstPCVJackets[0].Holds.ToString();
                    linkJacketHold.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Hold";

                    TextBox txtJacketCapacity = (TextBox)item.FindControl("txtJacketCapacity");
                    txtJacketCapacity.Text = objProductionCapacity.Capacity.ToString("#,##0");

                    Label lblJacketBalance = (Label)item.FindControl("lblJacketBalance");
                    lblJacketBalance.Text = (objProductionCapacity.Capacity - (lstPCVJackets[0].Firms + lstPCVJackets[0].ResevationOrders)).ToString();
                    lblJacketBalance.ForeColor = ((Convert.ToDecimal(lblJacketBalance.Text) >= 0)) ? Color.Black : Color.Red;

                    HyperLink linkJacketlessfiveitems = (HyperLink)item.FindControl("linkJacketlessfiveitems");
                    linkJacketlessfiveitems.Text = lstPCVJackets[0].Less5Items.ToString();
                    linkJacketlessfiveitems.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Lessfiveitems";

                    HyperLink linkJacketSamples = (HyperLink)item.FindControl("linkJacketSamples");
                    linkJacketSamples.Text = lstPCVJackets[0].Samples.ToString();
                    linkJacketSamples.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Samples";

                    // end Jacket data

                    HyperLink linkTotalFirm = (HyperLink)item.FindControl("linkTotalFirm");
                    HyperLink linkTotalCapacity = (HyperLink)item.FindControl("linkTotalCapacity");

                    linkTotalFirm.Text = (lstPCVPolos[0].Firms + lstPCVJackets[0].Firms).ToString();
                    linkTotalFirm.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Firm";

                    linkTotalCapacity.Text = objProductionCapacity.Capacity.ToString("#,##0");
                    linkTotalCapacity.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Total";

                    HyperLink linkFirm = (HyperLink)item.FindControl("linkFirm");
                    linkFirm.Text = lstPCVPolos[0].Firms.ToString();
                    linkFirm.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Firm";

                    HyperLink linkWeekDetails = (HyperLink)item.FindControl("linkWeekDetails");
                    linkWeekDetails.NavigateUrl = "ViewWeekDetails.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy");
                    linkWeekDetails.Visible = ((lstPCVPolos[0].Firms.Value > 0) && (this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator || this.LoggedUserRoleName == UserRole.FactoryAdministrator)) ? true : false;

                    HyperLink linkReservations = (HyperLink)item.FindControl("linkReservations");
                    linkReservations.Text = lstPCVPolos[0].ResevationOrders.ToString() + " " + "(" + lstPCVPolos[0].Resevations.ToString() + ")";
                    linkReservations.NavigateUrl = "ViewReservations.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy");

                    HyperLink linkTotal = (HyperLink)item.FindControl("linkTotal");
                    linkTotal.Text = (lstPCVPolos[0].Firms + lstPCVPolos[0].ResevationOrders).ToString();
                    linkTotal.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Total";

                    HyperLink linkHold = (HyperLink)item.FindControl("linkHold");
                    linkHold.Text = lstPCVPolos[0].Holds.ToString();
                    linkHold.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Hold";

                    //HyperLink linkBalance = (HyperLink)item.FindControl("linkBalance");
                    //linkBalance.Text = (objProductionCapacity.Capacity - (lstPCV[0].Firms + lstPCV[0].Resevations)).ToString();
                    //linkBalance.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Balance";

                    Label lblBalance = (Label)item.FindControl("lblBalance");
                    lblBalance.Text = (objProductionCapacity.Capacity - (lstPCVPolos[0].Firms + lstPCVPolos[0].ResevationOrders)).ToString();
                    lblBalance.ForeColor = ((Convert.ToDecimal(lblBalance.Text) >= 0)) ? Color.Black : Color.Red;

                    //HyperLink linkJackets = (HyperLink)item.FindControl("linkJackets");
                    //linkJackets.Text = lstPCV[0].Jackets.ToString();
                    //linkJackets.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Jackets";

                    HyperLink linkSamples = (HyperLink)item.FindControl("linkSamples");
                    linkSamples.Text = lstPCVPolos[0].Samples.ToString();
                    linkSamples.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Samples";

                    TextBox txtHolidays = (TextBox)item.FindControl("txtHolidays");
                    txtHolidays.Text = objProductionCapacity.NoOfHolidays.ToString();

                    HyperLink linklessfiveitems = (HyperLink)item.FindControl("linklessfiveitems");
                    linklessfiveitems.Text = lstPCVPolos[0].Less5Items.ToString();
                    linklessfiveitems.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Lessfiveitems";

                    LinkButton linkEditCapacity = (LinkButton)item.FindControl("linkEditCapacity");
                    linkEditCapacity.Attributes.Add("pcid", objProductionCapacity.ID.ToString());

                    LinkButton linkPackingList = (LinkButton)item.FindControl("linkPackingList");
                    linkPackingList.Text = "<i class=\"icon-retweet\"></i>" + ((objProductionCapacity.PackingListsWhereThisIsWeeklyProductionCapacity.Count > 0) ? "Modify" : "Create") + " Packing Plan";
                    linkPackingList.CommandName = "Create";

                    HyperLink linkSummary = (HyperLink)item.FindControl("linkSummary");
                    linkSummary.NavigateUrl = "ViewSummaryDetails.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy");
                    linkSummary.Visible = ((lstPCVPolos[0].Firms.Value > 0) && (this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator)) ? true : false;

                    HtmlGenericControl liViewPacking = (HtmlGenericControl)item.FindControl("liViewPacking");
                    if (objProductionCapacity.PackingListsWhereThisIsWeeklyProductionCapacity.Count > 0)
                    {
                        LinkButton lnkViewPackingList = (LinkButton)item.FindControl("lnkViewPackingList");
                        lnkViewPackingList.CommandName = "View";
                    }
                    else
                    {
                        liViewPacking.Attributes.Add("style", "display:none");
                    }

                    HiddenField hdnWeekendDate = (HiddenField)item.FindControl("hdnWeekendDate");
                    hdnWeekendDate.Value = objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy");

                    HyperLink linkInvoice = (HyperLink)item.FindControl("linkInvoice");
                    linkInvoice.NavigateUrl = "/AddEditInvoice.aspx?widdate=" + objProductionCapacity.WeekendDate.ToString() + "&wid=" + objProductionCapacity.ID.ToString();
                    //linkInvoice.Visible = (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator) ? true : false;

                    HyperLink linkViewInvoice = (HyperLink)item.FindControl("linkViewInvoice");
                    linkViewInvoice.NavigateUrl = "/ViewInvoices.aspx?wid=" + objProductionCapacity.ID.ToString();// TODOD??

                    LinkButton btnCreateBatchLabel = (LinkButton)item.FindControl("btnCreateBatchLabel");
                    btnCreateBatchLabel.Attributes.Add("wdate", objProductionCapacity.WeekendDate.ToString());
                    btnCreateBatchLabel.Visible = (lstPCVPolos[0].Firms > 0) ? true : false;

                    LinkButton btnCreateShippingDetail = (LinkButton)item.FindControl("btnCreateShippingDetail");
                    btnCreateShippingDetail.Attributes.Add("wdate", objProductionCapacity.WeekendDate.ToString());
                    btnCreateShippingDetail.Visible = (lstPCVPolos[0].Firms > 0) ? true : false;

                    TextBox txtSalesTarget = (TextBox)item.FindControl("txtSalesTarget");
                    txtSalesTarget.Text = (!string.IsNullOrEmpty(objProductionCapacity.SalesTarget.ToString())) ? Convert.ToDecimal(objProductionCapacity.SalesTarget.ToString()).ToString("0.00") : "0.00";

                    Literal litEstimatedValue = (Literal)item.FindControl("litEstimatedValue");
                    litEstimatedValue.Text = (Convert.ToDecimal(lstPCVPolos[0].Firms.ToString()) * Convert.ToDecimal(this.txtEstimatedValue.Text)).ToString("0.00");

                    Label lblBalanceValue = (Label)item.FindControl("lblBalanceValue");
                    lblBalanceValue.Text = (Convert.ToDecimal(litEstimatedValue.Text) - Convert.ToDecimal(txtSalesTarget.Text)).ToString("0.00");
                    lblBalanceValue.ForeColor = ((Convert.ToDecimal(lblBalanceValue.Text) >= 0)) ? Color.Black : Color.Red;

                    /*  DateTime d = objProductionCapacity.WeekendDate;

                      int offset = d.DayOfWeek - DayOfWeek.Monday;

                      DateTime lastMonday = d.AddDays(-offset);
                      DateTime nextSunday = lastMonday.AddDays(6);*/

                    int total = (int)(lstPCVPolos[0].Firms + lstPCVPolos[0].Resevations);
                    int balance = (int)(objProductionCapacity.Capacity - (lstPCVPolos[0].Firms + lstPCVPolos[0].Resevations));

                    if (total > objProductionCapacity.Capacity)
                    {
                        e.Item.Cells[1].BackColor = System.Drawing.ColorTranslator.FromHtml("#ff4040");
                    }
                    else if (balance <= 500 && balance > 0)
                    {
                        e.Item.Cells[1].BackColor = System.Drawing.ColorTranslator.FromHtml("#ff9200");
                    }

                    int i = 0;
                    foreach (TableCell cell in item.Cells)
                    {
                        if (i > 3 && i < 12)
                        {
                            cell.BackColor = Color.PowderBlue;
                        }
                        else if (i > 11 && i < 20)
                        {
                            cell.BackColor = Color.Moccasin;
                        }
                        else if (i > 19 && i < 22)
                        {
                            cell.BackColor = Color.MediumSeaGreen;
                        }

                        i++;
                    }
                }
            }
        }

        protected void RadGridWeeklySummary_ItemCommand(object sender, GridCommandEventArgs e)
        {
            HiddenField hdnWeekendDate = (HiddenField)e.Item.FindControl("hdnWeekendDate");

            if (hdnWeekendDate != null && !string.IsNullOrEmpty(hdnWeekendDate.Value))
            {
                string weekendDate = hdnWeekendDate.Value;

                if (e.CommandName == "Create")
                {
                    Response.Redirect("PackingList.aspx?WeekendDate=" + weekendDate);
                }
                else if (e.CommandName == "View")
                {
                    Response.Redirect("ViewPackingLists.aspx?WeekendDate=" + weekendDate);
                }
            }

            this.ReBindGrid();

        }

        protected void RadGridWeeklySummary_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dgWeeklySummary_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is WeeklyProductionCapacityBO)
        //    {
        //        WeeklyProductionCapacityBO objProductionCapacity = (WeeklyProductionCapacityBO)item.DataItem;

        //        HyperLink linkWeekYear = (HyperLink)item.FindControl("linkWeekYear");
        //        linkWeekYear.Text = objProductionCapacity.WeekNo + "/" + objProductionCapacity.WeekendDate.Year;

        //        if ((this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator))
        //        {
        //            linkWeekYear.NavigateUrl = "ViewSummaryDetails.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy");
        //        }

        //        Literal lblWeekEnd = (Literal)item.FindControl("lblWeekEnd");
        //        lblWeekEnd.Text = objProductionCapacity.WeekendDate.ToString("dd MMM yyyy");

        //        TextBox txtCapacity = (TextBox)item.FindControl("txtCapacity");
        //        txtCapacity.Text = objProductionCapacity.Capacity.ToString("#,##0");

        //        List<ReturnProductionCapacitiesViewBO> lstPCV = OrderBO.Productioncapacities((DateTime?)objProductionCapacity.WeekendDate);

        //        HyperLink linkFirm = (HyperLink)item.FindControl("linkFirm");
        //        linkFirm.Text = lstPCV[0].Firms.ToString();
        //        linkFirm.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Firm";

        //        HyperLink linkWeekDetails = (HyperLink)item.FindControl("linkWeekDetails");
        //        linkWeekDetails.NavigateUrl = "ViewWeekDetails.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy");
        //        linkWeekDetails.Visible = ((lstPCV[0].Firms.Value > 0) && (this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator)) ? true : false;

        //        HyperLink linkReservations = (HyperLink)item.FindControl("linkReservations");
        //        linkReservations.Text = lstPCV[0].ResevationOrders.ToString() + " " + "(" + lstPCV[0].Resevations.ToString() + ")";
        //        linkReservations.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Reservations";

        //        HyperLink linkTotal = (HyperLink)item.FindControl("linkTotal");
        //        linkTotal.Text = (lstPCV[0].Firms + lstPCV[0].ResevationOrders).ToString();
        //        linkTotal.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Total";

        //        HyperLink linkHold = (HyperLink)item.FindControl("linkHold");
        //        linkHold.Text = lstPCV[0].Holds.ToString();
        //        //linkHold.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Hold";

        //        HyperLink linkBalance = (HyperLink)item.FindControl("linkBalance");
        //        linkBalance.Text = (objProductionCapacity.Capacity - (lstPCV[0].Firms + lstPCV[0].Resevations)).ToString();
        //        //linkBalance.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Balance";

        //        HyperLink linkJackets = (HyperLink)item.FindControl("linkJackets");
        //        linkJackets.Text = lstPCV[0].Jackets.ToString();
        //        linkJackets.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Jackets";

        //        HyperLink linkSamples = (HyperLink)item.FindControl("linkSamples");
        //        linkSamples.Text = lstPCV[0].Samples.ToString();
        //        linkSamples.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Samples";

        //        TextBox txtHolidays = (TextBox)item.FindControl("txtHolidays");
        //        txtHolidays.Text = objProductionCapacity.NoOfHolidays.ToString();

        //        HyperLink linklessfiveitems = (HyperLink)item.FindControl("linklessfiveitems");
        //        linklessfiveitems.Text = lstPCV[0].Less5Items.ToString();
        //        linklessfiveitems.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Lessfiveitems";

        //        LinkButton linkEditCapacity = (LinkButton)item.FindControl("linkEditCapacity");
        //        linkEditCapacity.Attributes.Add("pcid", objProductionCapacity.ID.ToString());

        //        LinkButton linkPackingList = (LinkButton)item.FindControl("linkPackingList");
        //        linkPackingList.Text = "<i class=\"icon-retweet\"></i>" + ((objProductionCapacity.PackingListsWhereThisIsWeeklyProductionCapacity.Count > 0) ? "Modify" : "Create") + " Packing Plan";
        //        linkPackingList.CommandName = "Create";

        //        HyperLink linkSummary = (HyperLink)item.FindControl("linkSummary");
        //        linkSummary.NavigateUrl = "ViewSummaryDetails.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy");
        //        linkSummary.Visible = ((lstPCV[0].Firms.Value > 0) && (this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator)) ? true : false;

        //        HtmlGenericControl liViewPacking = (HtmlGenericControl)item.FindControl("liViewPacking");
        //        if (objProductionCapacity.PackingListsWhereThisIsWeeklyProductionCapacity.Count > 0)
        //        {
        //            LinkButton lnkViewPackingList = (LinkButton)item.FindControl("lnkViewPackingList");
        //            lnkViewPackingList.CommandName = "View";
        //        }
        //        else
        //        {
        //            liViewPacking.Attributes.Add("style", "display:none");
        //        }

        //        HiddenField hdnWeekendDate = (HiddenField)item.FindControl("hdnWeekendDate");
        //        hdnWeekendDate.Value = objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy");

        //        HyperLink linkInvoice = (HyperLink)item.FindControl("linkInvoice");
        //        linkInvoice.NavigateUrl = "/AddEditInvoice.aspx?wid=" + objProductionCapacity.ID.ToString();
        //        //linkInvoice.Visible = (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator) ? true : false;

        //        HyperLink linkViewInvoice = (HyperLink)item.FindControl("linkViewInvoice");
        //        linkViewInvoice.NavigateUrl = "/ViewInvoices.aspx?wid=" + objProductionCapacity.ID.ToString();

        //        LinkButton btnCreateBatchLabel = (LinkButton)item.FindControl("btnCreateBatchLabel");
        //        btnCreateBatchLabel.Attributes.Add("wdate", objProductionCapacity.WeekendDate.ToString());



        //        int total = (int)(lstPCV[0].Firms + lstPCV[0].Resevations);
        //        int balance = (int)(objProductionCapacity.Capacity - (lstPCV[0].Firms + lstPCV[0].Resevations));

        //        if (total > objProductionCapacity.Capacity)
        //        {
        //            e.Item.Cells[1].BackColor = System.Drawing.ColorTranslator.FromHtml("#ff4040");
        //        }
        //        else if (balance <= 500 && balance > 0)
        //        {
        //            e.Item.Cells[1].BackColor = System.Drawing.ColorTranslator.FromHtml("#ff9200");
        //        }

        //        //e.Item.Cells[1].HorizontalAlign = HorizontalAlign.Center;
        //    }
        //}

        //protected void dgWeeklySummary_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgWeeklySummary.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dgWeeklySummary_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dgWeeklySummary.Columns)
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

        protected void dgPackingList_ItemCommand(object source, DataGridCommandEventArgs e)
        {
            HiddenField hdnWeekendDate = (HiddenField)e.Item.FindControl("hdnWeekendDate");
            if (hdnWeekendDate != null && !string.IsNullOrEmpty(hdnWeekendDate.Value))
            {
                string weekendDate = hdnWeekendDate.Value;

                if (e.CommandName == "Create")
                {
                    Response.Redirect("PackingList.aspx?WeekendDate=" + weekendDate);
                }
                else if (e.CommandName == "View")
                {
                    Response.Redirect("ViewPackingLists.aspx?WeekendDate=" + weekendDate);
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            int itemId = int.Parse(this.hdnSelectedWeeklySummaryID.Value.ToString().Trim());

            if (Page.IsValid)
            {
                this.ProcessForm(itemId, false);
                Response.Redirect("/ViewWeeklyCapacities.aspx");
            }

            // Popup Header Text
            this.lblPopupHeaderText.Text = ((itemId > 0) ? "Edit " : "New ") + "Weekly Capacities";

            ViewState["IsPageValied"] = (Page.IsValid);
            this.dvPageValidation.Visible = !(Page.IsValid);
        }

        protected void linkEditCapacity_Click(object sender, EventArgs e)
        {
            try
            {
                foreach (GridDataItem item in RadGridWeeklySummary.Items)
                {
                    TextBox txtCapacity = (TextBox)item.FindControl("txtCapacity");
                    TextBox txtHolidays = (TextBox)item.FindControl("txtHolidays");
                    TextBox txtSalesTarget = (TextBox)item.FindControl("txtSalesTarget");

                    LinkButton linkEditCapacity = (LinkButton)item.FindControl("linkEditCapacity");
                    int pcid = int.Parse(linkEditCapacity.Attributes["pcid"].ToString());

                    if (pcid > 0 && txtCapacity != null && txtHolidays != null)
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            WeeklyProductionCapacityBO objWeeklyProductionCapacity = new WeeklyProductionCapacityBO(this.ObjContext);
                            objWeeklyProductionCapacity.ID = pcid;
                            objWeeklyProductionCapacity.GetObject();

                            string capacity = txtCapacity.Text.Replace(",", "");

                            objWeeklyProductionCapacity.Capacity = int.Parse(capacity);
                            objWeeklyProductionCapacity.NoOfHolidays = int.Parse(txtHolidays.Text);
                            objWeeklyProductionCapacity.SalesTarget = decimal.Parse(txtSalesTarget.Text);

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while editing weekly capcity and weekly holidays in ViewWeeklyCpacities.aspx", ex);
            }
            this.PopulateDataGrid();
        }

        protected void ddlYear_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void ddlMonth_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnCreateBatchLabel_Click(object sender, EventArgs e)
        {
            DateTime weekenddate = Convert.ToDateTime(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["wdate"].ToString());
            if (weekenddate != null)
            {
                try
                {
                    string pdfpath = Common.GenerateOdsPdf.CreateBathLabel(weekenddate);
                    this.DownloadPDFFile(pdfpath);
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while creating Batch Label in side ViewWeeklyCapacities.aspx", ex);
                }
            }
        }

        protected void btnCreateShippingDetail_Click(object sender, EventArgs e)
        {
            DateTime weekenddate = Convert.ToDateTime(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["wdate"].ToString());
            if (weekenddate != null)
            {
                try
                {
                    string pdfpath = Common.GenerateOdsPdf.GenerateShippingDetailsPDF(weekenddate);

                    if (File.Exists(pdfpath))
                    {
                        this.DownloadPDFFile(pdfpath);
                    }

                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while creating Shipping Detail in side ViewWeeklyCapacities.aspx", ex);
                }
            }
        }

        protected void btnCalulate_ServerClick(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            //Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;

            // Popup Header Text
            this.lblPopupHeaderText.Text = "New Weekly Capacities";

            //Set validity of the control fields
            ViewState["IsPageValied"] = true;

            this.ddlYear.Items.Clear();
            //this.ddlYear.Items.Add(new ListItem("All", "0"));
            List<int> lstYears = (new WeeklyProductionCapacityBO()).SearchObjects().Select(o => o.WeekendDate.Year).Distinct().ToList();
            foreach (int year in lstYears)
            {
                this.ddlYear.Items.Add(new ListItem(year.ToString()));
            }

            var exists = lstYears.Contains(DateTime.Now.Year);

            if (exists)
            {
                this.ddlYear.Items.FindByValue(DateTime.Now.Year.ToString()).Selected = true;
            }
            else
            {
                this.ddlYear.Items.FindByValue("0").Selected = true;
            }

            this.ddlMonth.Items.Clear();
            //this.ddlMonth.Items.Add(new ListItem("All", "0"));
            List<int> lstMonths = (new WeeklyProductionCapacityBO()).SearchObjects().Select(o => o.WeekendDate.Month).Distinct().ToList();
            foreach (int month in lstMonths)
            {
                string monthname = CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(month);
                this.ddlMonth.Items.Add(new ListItem(monthname, month.ToString()));
            }

            this.ddlMonth.Items.FindByValue(DateTime.Now.Month.ToString()).Selected = true;

            Session["WeeklySummaryDetails"] = null;

            //Popultate the data grid
            this.PopulateDataGrid();

        }

        private void ProcessForm(int queryId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    WeeklyProductionCapacityBO objProductionCapacity = new WeeklyProductionCapacityBO(this.ObjContext);
                    if (queryId > 0)
                    {
                        objProductionCapacity.ID = queryId;
                        objProductionCapacity.GetObject();
                    }

                    if (isDelete)
                    {
                        objProductionCapacity.Delete();
                    }
                    else
                    {
                        //objProductionCapacity.Name = this.txtAttributeName.Text;
                        //objProductionCapacity.Description = this.txtDescription.Text;

                        if (queryId == 0)
                        {
                            objProductionCapacity.Add();
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                //IndicoLogging.log("Error occured while Adding the Item", ex);
            }
        }

        private void PopulateDataGrid()
        {
            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;
            // get the first monday of the week
            var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
            var monday = DateTime.Today.AddDays(-daysTillMonday);

            // get the first monday  of specific month
            DateTime dt = DateTime.Now;
            if (this.ddlMonth.SelectedIndex > -1 && this.ddlYear.SelectedIndex > -1)
            {
                dt = new DateTime(int.Parse(this.ddlYear.SelectedValue), int.Parse(this.ddlMonth.SelectedValue), 1);
                dt = dt.AddDays(1);
            }

            // Search text
            string searchText = this.txtSearch.Text.ToLower().Trim();

            // Populate Item Attribute
            WeeklyProductionCapacityBO objProductionCapacity = new WeeklyProductionCapacityBO();

            // Sort by condition
            List<WeeklyProductionCapacityBO> lstProductionCapacity = new List<WeeklyProductionCapacityBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstProductionCapacity = (from o in objProductionCapacity.SearchObjects().AsQueryable().Where(o => o.WeekendDate >= monday && o.WeekendDate.ToString().Contains(searchText))
                                        .OrderBy(SortExpression).ToList<WeeklyProductionCapacityBO>()
                                         select o).ToList();
            }
            else
            {
                if (this.ddlYear.SelectedIndex > -1)
                {
                    if (int.Parse(this.ddlMonth.SelectedValue) == DateTime.Now.Month)
                    {
                        lstProductionCapacity = objProductionCapacity.SearchObjects().AsQueryable().Where(o => o.WeekendDate >= monday && o.WeekendDate.Year >= int.Parse(this.ddlYear.SelectedItem.Text)).OrderBy(SortExpression).ToList<WeeklyProductionCapacityBO>();
                    }
                }
                else if (this.ddlYear.SelectedIndex == -1)
                {
                    lstProductionCapacity = objProductionCapacity.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<WeeklyProductionCapacityBO>();
                }
                else
                {
                    lstProductionCapacity = objProductionCapacity.SearchObjects().AsQueryable().Where(o => o.WeekendDate.Date >= monday).OrderBy(SortExpression).ToList<WeeklyProductionCapacityBO>();
                }
            }

            if (this.ddlMonth.SelectedIndex > -1)
            {
                if (int.Parse(this.ddlMonth.SelectedValue) != DateTime.Now.Month)
                {
                    lstProductionCapacity = objProductionCapacity.SearchObjects().AsQueryable().Where(o => o.WeekendDate >= dt).OrderBy(o => o.WeekendDate).ToList<WeeklyProductionCapacityBO>();
                }
            }
            else if (this.ddlMonth.SelectedIndex == -1)
            {
                lstProductionCapacity = lstProductionCapacity.ToList<WeeklyProductionCapacityBO>();
            }

            if (lstProductionCapacity.Count > 0)
            {
                this.RadGridWeeklySummary.AllowPaging = (lstProductionCapacity.Count > this.RadGridWeeklySummary.PageSize);
                this.RadGridWeeklySummary.DataSource = lstProductionCapacity;
                this.RadGridWeeklySummary.DataBind();
                Session["WeeklySummaryDetails"] = lstProductionCapacity;

                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search") || (this.ddlYear.SelectedIndex > -1) || (this.ddlMonth.SelectedIndex > -1))
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyContent.Visible = true;
            }

            this.RadGridWeeklySummary.Visible = (lstProductionCapacity.Count > 0);
        }

        private void ReBindGrid()
        {
            if (Session["WeeklySummaryDetails"] != null)
            {
                RadGridWeeklySummary.DataSource = (List<WeeklyProductionCapacityBO>)Session["WeeklySummaryDetails"];
                RadGridWeeklySummary.DataBind();
            }
        }

        #endregion
    }
}
