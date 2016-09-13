using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Linq.Dynamic;
using Indico.BusinessObjects;
using Indico.Common;
using Telerik.Web.UI;
using System.Web.UI.WebControls;
using Dapper;
using Indico.Models;

namespace Indico
{
    // ReSharper disable once InconsistentNaming
    public partial class ViewWeeklySMVCapacities : IndicoPage
    {

        #region Properties

        private string SortExpression
        {
            get
            {
                var sort = (string)ViewState["ItemsAttributeSortExpression"];
                if (string.IsNullOrEmpty(sort))
                    sort = "WeekendDate";
                return sort;
            }
            // set { ViewState["ItemsAttributeSortExpression"] = value; }
        }

        public new bool IsNotRefresh
        {
            get { return (Session["IsPostBack"].ToString() == ViewState["IsPostBack"].ToString()); }
        }

        #endregion


        protected void Page_PreRender(object sender, EventArgs e)
        {
            Session["IsPostBack"] = Server.UrlEncode(Guid.NewGuid().ToString());
            ViewState["IsPostBack"] = Session["IsPostBack"];
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            PopulateControls();
            PopulateDataGrid();
        }

        protected void ddlMonth_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateDataGrid();
        }

        protected void ddlYear_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateDataGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            PopulateDataGrid();
        }

        protected void OnWeeklySmvSummaryRedGridItemCommand(object sender, GridCommandEventArgs e)
        {
            var hdnWeekendDate = (HiddenField)e.Item.FindControl("hdnWeekendDate");

            if (hdnWeekendDate != null && !string.IsNullOrEmpty(hdnWeekendDate.Value))
            {
                var weekendDate = hdnWeekendDate.Value;

                switch (e.CommandName)
                {
                    case "Create":
                        Response.Redirect("PackingList.aspx?WeekendDate=" + weekendDate);
                        break;
                    case "View":
                        Response.Redirect("ViewPackingLists.aspx?WeekendDate=" + weekendDate);
                        break;
                }
            }
            ReBindGrid();
        }

        protected void OnWeeklySmvSummaryRedGridItemDataBound(object sender, GridItemEventArgs e)
        {
            var gridFooterItem = e.Item as GridFooterItem;
            if (gridFooterItem != null)
            {
                gridFooterItem.Style.Add("color", "green");
                gridFooterItem.Style.Add("font-weight", "bold");
            }

            if (!(e.Item is GridDataItem)) return;
            var item = (GridDataItem)e.Item;
            if (item.ItemIndex <= -1 || !(item.DataItem is WeeklySmvSummariesModel)) return;
            var obj = (WeeklySmvSummariesModel)item.DataItem;

            var linkWeekYear = (HyperLink)item.FindControl("linkWeekYear");
            linkWeekYear.Text = obj.WeekNumber + "/" + obj.WeekEndDate.Year;

            if ((LoggedUserRoleName == UserRole.IndimanAdministrator || LoggedUserRoleName == UserRole.IndimanCoordinator || LoggedUserRoleName == UserRole.FactoryAdministrator))
            {
                linkWeekYear.NavigateUrl = "ViewSummaryDetails.aspx?WeekendDate=" + obj.WeekEndDate.ToString("dd/MM/yyyy");
            }

            if (DateTime.Now < obj.WeekEndDate && DateTime.Now > obj.WeekEndDate.AddDays(-7))
            {
                item.BackColor = Color.Orange;
            }


            item.Cells[7].Text = Convert.ToString(6 - obj.NumberOfHoliDays);

            var weekEndDateStr = obj.WeekEndDate.ToString("dd/MM/yyyy");

            var linkpolofirm = (HyperLink)item.FindControl("PoloFirmLink");
            linkpolofirm.Text = obj.PoloFirms.ToString();
            linkpolofirm.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + weekEndDateStr + "&Type=Firm";

            var linkpoloreservations = (HyperLink)item.FindControl("PoloReservationsLink");
            linkpoloreservations.Text = obj.PoloReservations.ToString();
            linkpoloreservations.NavigateUrl = "ViewReservations.aspx?WeekendDate=" + weekEndDateStr;

            var linkPoloTotal = (HyperLink)item.FindControl("PoloTotalLink");
            linkPoloTotal.Text = Convert.ToString(obj.PoloTotal);
            linkPoloTotal.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + weekEndDateStr + "&Type=Total";

            var linkpolohold = (HyperLink)item.FindControl("PoloHoldLink");
            linkpolohold.Text = Convert.ToString(obj.PoloHolds);
            linkpolohold.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + weekEndDateStr + "&Type=Hold";

            var poloCapacityTextBox = (TextBox)item.FindControl("PoloCapacityTextBox");
            poloCapacityTextBox.Text = obj.PoloCapacity.ToString("#,##0");

            var poloBalanceLabel = (Label)item.FindControl("PoloBalanceLabel");
            poloBalanceLabel.Text = (obj.PoloCapacity - (obj.PoloReservations + obj.PoloFirms)).ToString(CultureInfo.InvariantCulture);
            poloBalanceLabel.ForeColor = ((Convert.ToDecimal(poloBalanceLabel.Text) >= 0)) ? Color.Black : Color.Red;


            //var lnkpolouptofive = (HyperLink)item.FindControl("PoloLessFiveItemsLink");
            //lnkpolouptofive.Text = obj.PoloUptoFiveItems.ToString();
            //lnkpolouptofive.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + weekEndDateStr + "&Type=Lessfiveitems";

            //item.Cells[15].Text = obj.PoloFivePcsCapacity.ToString(CultureInfo.InvariantCulture);


            //var lnkpolosamples = (HyperLink)item.FindControl("PoloSampleItemsLink");
            //lnkpolosamples.Text = obj.PoloSamples.ToString();
            //lnkpolosamples.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + weekEndDateStr + "&Type=Samples";

            //item.Cells[17].Text = obj.PoloSampleCapacity.ToString(CultureInfo.InvariantCulture);

            var linkouterwarefirm = (HyperLink)item.FindControl("OuterwareFirmLink");
            linkouterwarefirm.Text = obj.OuterWareFirms.ToString();
            linkouterwarefirm.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + weekEndDateStr + "&Type=Firm";

            var linkouterwarereservations = (HyperLink)item.FindControl("OuterwareReservationsLink");
            linkouterwarereservations.Text = obj.OuterwareReservations.ToString();
            linkouterwarereservations.NavigateUrl = "ViewReservations.aspx?WeekendDate=" + weekEndDateStr;

            var linkOuterwareTotal = (HyperLink)item.FindControl("OuterwareTotalLink");
            linkOuterwareTotal.Text = Convert.ToString(obj.OuterwareTotal);
            linkOuterwareTotal.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + weekEndDateStr + "&Type=Total";

            var linkouterwarehold = (HyperLink)item.FindControl("OuterwareHoldLink");
            linkouterwarehold.Text = Convert.ToString(obj.OuterwareHolds);
            linkouterwarehold.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + weekEndDateStr + "&Type=Hold";

            var outerwareCapacityTextBox = (TextBox)item.FindControl("OuterwareCapacityTextBox");
            outerwareCapacityTextBox.Text = obj.OuterwareCapacity.ToString("#,##0");

            var outerwareBalanceLabel = (Label)item.FindControl("OuterwareBalanceLabel");
            outerwareBalanceLabel.Text = (obj.OuterwareCapacity - (obj.OuterwareReservations + obj.OuterWareFirms)).ToString(CultureInfo.InvariantCulture);
            outerwareBalanceLabel.ForeColor = ((Convert.ToDecimal(outerwareBalanceLabel.Text) >= 0)) ? Color.Black : Color.Red;

            //var lnkouterwareuptofive = (HyperLink)item.FindControl("OuterwareLessFiveItemsLink");
            //lnkouterwareuptofive.Text = obj.OuterwareUptoFiveItems.ToString();
            //lnkouterwareuptofive.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + weekEndDateStr + "&Type=Lessfiveitems";

            //item.Cells[25].Text = obj.OuterwareFivePcsCapacity.ToString(CultureInfo.InvariantCulture);


            //var lnkouterwaresamples = (HyperLink)item.FindControl("OuterwareSampleItemsLink");
            //lnkouterwaresamples.Text = obj.OuterwareSamples.ToString();
            //lnkouterwaresamples.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + weekEndDateStr + "&Type=Samples";

            //item.Cells[27].Text = Convert.ToString(obj.OuterwareSampleCapacity, CultureInfo.InvariantCulture);



            var linktotalfirm = (HyperLink)item.FindControl("TotalFirmLink");
            linktotalfirm.Text = obj.TotalFirm.ToString();
            linktotalfirm.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + weekEndDateStr + "&Type=Firm";

            var linktotalcapacity = (HyperLink)item.FindControl("TotalCapacityLink");
            linktotalcapacity.Text = obj.TotalCapacity.ToString(CultureInfo.InvariantCulture);
            linktotalcapacity.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + weekEndDateStr + "&Type=Total";

            var txtHolidays = (TextBox)item.FindControl("HolidaysTextBox");
            txtHolidays.Text = (obj.NumberOfHoliDays).ToString();
        }

        protected void OnWeeklySmvSummaryRedGridPageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            ReBindGrid();
        }

        protected void OnWeeklySmvSummaryRedGridPageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            ReBindGrid();
        }

        protected void OnWeeklySmvSummaryRedGridSortCommand(object sender, GridSortCommandEventArgs e)
        {
            ReBindGrid();
        }

        protected void OnlnkEditCapacityClick(object sender, EventArgs e)
        {

        }

        protected void OnbtnCreateBatchLabelClick(object sender, EventArgs e)
        {

        }

        protected void OnbtnCreateShipmentDetailClick(object sender, EventArgs e)
        {

        }


        private void PopulateControls()
        {
            litHeaderText.Text = ActivePage.Heading;
            ViewState["IsPageValied"] = true;

            ddlYear.Items.Clear();
            var years =
                (new WeeklyProductionCapacityBO()).SearchObjects().Select(o => o.WeekendDate.Year).Distinct().ToList();

            foreach (var year in years)
                ddlYear.Items.Add(new ListItem(year.ToString()));

            if (years.Contains(DateTime.Now.Year))
                ddlYear.Items.FindByValue(DateTime.Now.Year.ToString()).Selected = true;
            else
                ddlYear.Items.FindByValue("0").Selected = true;

            ddlMonth.Items.Clear();
            var months =
                (new WeeklyProductionCapacityBO()).SearchObjects().Select(o => o.WeekendDate.Month).Distinct().ToList();
            foreach (var month in months)
            {
                var monthname = CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(month);
                ddlMonth.Items.Add(new ListItem(monthname, month.ToString()));
            }
            ddlMonth.Items.FindByValue(DateTime.Now.Month.ToString()).Selected = true;
            Session["WeeklySMVSummary"] = null;
        }

        private void PopulateDataGrid()
        {
            dvEmptyContent.Visible = false;
            dvDataContent.Visible = false;
            dvNoSearchResult.Visible = false;

            var startYear = ddlYear.SelectedItem.Value;
            if (string.IsNullOrWhiteSpace(startYear))
                startYear = Convert.ToString(DateTime.Now.Year);

            var startMonth = ddlMonth.SelectedItem.Value;
            if (string.IsNullOrWhiteSpace(startMonth))
                startMonth = Convert.ToString(DateTime.Now.Month);


            using (
                var connection =
                    new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Open();
                var spResult =
                    connection.Query<WeeklySmvSummariesModel>(
                        string.Format("EXEC [dbo].[SPC_GetWeeklySummariesForSMV] {0}, {1}", startMonth,
                            startYear)).ToList();
                if (spResult.Count < 1)
                {
                    dvEmptyContent.Visible = true;
                    connection.Close();
                    return;
                }
                WeeklySMVSummaryRedGrid.AllowPaging = (spResult.Count >
                                                       WeeklySMVSummaryRedGrid.PageSize);
                WeeklySMVSummaryRedGrid.DataSource = spResult;
                WeeklySMVSummaryRedGrid.DataBind();
                Session["WeeklySMVSummary"] = spResult;
                dvDataContent.Visible = true;
            }

            //var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
            //var monday = DateTime.Today.AddDays(-daysTillMonday);

            //if (ddlMonth.SelectedIndex <= -1 || ddlYear.SelectedIndex <= -1) return;
            //var dt = new DateTime(int.Parse(ddlYear.SelectedValue), int.Parse(ddlMonth.SelectedValue), 1);
            //dt = dt.AddDays(1);
            //var searchText = txtSearch.Text.ToLower().Trim();
            //var objProductionCapacity = new WeeklyProductionCapacityBO();


            //var lstProductionCapacity = new List<WeeklyProductionCapacityBO>();
            //if ((searchText != string.Empty) && (searchText != "search"))
            //{
            //    lstProductionCapacity =
            //        (from o in
            //             objProductionCapacity.SearchObjects()
            //                 .AsQueryable()
            //                 .Where(
            //                     o =>
            //                         o.WeekendDate >= monday &&
            //                         o.WeekendDate.ToString(CultureInfo.InvariantCulture).Contains(searchText))
            //                 .OrderBy(SortExpression).ToList()
            //         select o).ToList();
            //}
            //else
            //{
            //    if (ddlYear.SelectedIndex > -1)
            //    {
            //        if (int.Parse(ddlMonth.SelectedValue) == DateTime.Now.Month)
            //        {
            //            lstProductionCapacity =
            //                objProductionCapacity.SearchObjects()
            //                    .AsQueryable()
            //                    .Where(
            //                        o =>
            //                            o.WeekendDate >= monday &&
            //                            o.WeekendDate.Year >= int.Parse(ddlYear.SelectedItem.Text))
            //                    .OrderBy(SortExpression)
            //                    .ToList();
            //        }
            //    }
            //    else if (ddlYear.SelectedIndex == -1)
            //    {
            //        lstProductionCapacity =
            //            objProductionCapacity.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            //    }
            //    else
            //    {
            //        lstProductionCapacity =
            //            objProductionCapacity.SearchObjects()
            //                .AsQueryable()
            //                .Where(o => o.WeekendDate.Date >= monday)
            //                .OrderBy(SortExpression)
            //                .ToList();
            //    }
            //}

            //if (ddlMonth.SelectedIndex > -1)
            //{
            //    if (int.Parse(ddlMonth.SelectedValue) != DateTime.Now.Month)
            //    {
            //        lstProductionCapacity =
            //            objProductionCapacity.SearchObjects()
            //                .AsQueryable()
            //                .Where(o => o.WeekendDate >= dt)
            //                .OrderBy(o => o.WeekendDate)
            //                .ToList();
            //    }
            //}
            //else if (ddlMonth.SelectedIndex == -1)
            //{
            //    lstProductionCapacity = lstProductionCapacity.ToList();
            //}

            //if (lstProductionCapacity.Count > 0)
            //{
            //    WeeklySMVSummaryRedGrid.AllowPaging = (lstProductionCapacity.Count >
            //                                              WeeklySMVSummaryRedGrid.PageSize);
            //    WeeklySMVSummaryRedGrid.DataSource = lstProductionCapacity;
            //    WeeklySMVSummaryRedGrid.DataBind();
            //    Session["WeeklySMVSummary"] = lstProductionCapacity;

            //    dvDataContent.Visible = true;
            //}
            //else if ((searchText != string.Empty && searchText != "search") || (ddlYear.SelectedIndex > -1) ||
            //         (ddlMonth.SelectedIndex > -1))
            //{
            //    lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

            //    dvDataContent.Visible = true;
            //    dvNoSearchResult.Visible = true;
            //}
            //else
            //{
            //    dvEmptyContent.Visible = true;
            //}

            //WeeklySMVSummaryRedGrid.Visible = (lstProductionCapacity.Count > 0);
        }

        private void ReBindGrid()
        {
            if (Session["WeeklySMVSummary"] == null)
                return;
            WeeklySMVSummaryRedGrid.DataSource = (List<WeeklySmvSummariesModel>)Session["WeeklySMVSummary"];
            WeeklySMVSummaryRedGrid.DataBind();
        }
    }
}