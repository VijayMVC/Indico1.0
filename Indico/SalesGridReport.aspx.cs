using System;
using System.Collections.Generic;
using System.IO;
using System.Drawing;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using Dapper;
using Indico.Common;
using Indico.BusinessObjects;
using System.Text.RegularExpressions;
using Microsoft.Reporting.WebForms;
using System.Threading;
using System.Reflection;
using Telerik.Web.UI;
//using Indico.Model;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Data;

namespace Indico
{
    public partial class SalesGridReport : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        public bool IsNotRefreshed
        {
            get
            {
                return (Session["IsPostBack"].ToString() == ViewState["IsPostBack"].ToString());
            }
        }

        public string HeaderText { get; set; }

        protected bool GetQueryIDs
        {
            get
            {
                if (Request.QueryString["Start"] != null)
                {
                    try
                    {
                        Start = DateTime.Parse(Request.QueryString["Start"].ToString());
                    }
                    catch
                    {
                        return false;
                    }
                }
                else
                    return false;

                if (Request.QueryString["End"] != null)
                {
                    try
                    {
                        End = DateTime.Parse(Request.QueryString["End"].ToString());
                    }
                    catch
                    {
                        return false;
                    }
                }
                else
                    return false;

                if (End < Start)
                    return false;

                if (Request.QueryString["Name"] != null)
                {
                    DistributorName = Request.QueryString["Name"].ToString();
                }
                else
                    return false;

                if (Request.QueryString["Type"] != null)
                {
                    string type = Request.QueryString["Type"].ToString();
                    if (type == "1" || type == "2")
                        DistributorType = type;
                    else
                        DistributorType = "1";
                }
                else
                    return false;

                return true;
            }
        }


        public DateTime Start { get; set; }

        public DateTime End { get; set; }

        public string DistributorName { get; set; }

        public string DistributorType { get; set; }

        #endregion

        #region Constructors

        #endregion

        #region Events

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

        }

        /// <summary>
        /// Page load event
        /// </summary>
        /// <param name="sender">Sender</param>
        /// <param name="e">Even arg</param>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                PopulateControls();
            }
        }

        protected void RadGridSalesReport_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridSalesReport_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridSalesReport_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridGroupHeaderItem)
            {
                GridGroupHeaderItem item = e.Item as GridGroupHeaderItem;
                (item.DataCell).Text = (item.DataCell).Text.Replace("MonthAndYear: ", string.Empty);
                this.HeaderText = (item.DataCell).Text;
                string monthPart = (item.DataCell).Text.Substring(4);
                if (monthPart == "01")
                    (item.DataCell).Text = (item.DataCell).Text.Substring(0, 4) + " - " + "January";
                else if (monthPart == "02")
                    (item.DataCell).Text = (item.DataCell).Text.Substring(0, 4) + " - " + "February";
                else if (monthPart == "03")
                    (item.DataCell).Text = (item.DataCell).Text.Substring(0, 4) + " - " + "March";
                else if (monthPart == "04")
                    (item.DataCell).Text = (item.DataCell).Text.Substring(0, 4) + " - " + "April";
                else if (monthPart == "05")
                    (item.DataCell).Text = (item.DataCell).Text.Substring(0, 4) + " - " + "May";
                else if (monthPart == "06")
                    (item.DataCell).Text = (item.DataCell).Text.Substring(0, 4) + " - " + "June";
                else if (monthPart == "07")
                    (item.DataCell).Text = (item.DataCell).Text.Substring(0, 4) + " - " + "July";
                else if (monthPart == "08")
                    (item.DataCell).Text = (item.DataCell).Text.Substring(0, 4) + " - " + "August";
                else if (monthPart == "09")
                    (item.DataCell).Text = (item.DataCell).Text.Substring(0, 4) + " - " + "September";
                else if (monthPart == "10")
                    (item.DataCell).Text = (item.DataCell).Text.Substring(0, 4) + " - " + "October";
                else if (monthPart == "11")
                    (item.DataCell).Text = (item.DataCell).Text.Substring(0, 4) + " - " + "November";
                else if (monthPart == "12")
                    (item.DataCell).Text = (item.DataCell).Text.Substring(0, 4) + " - " + "December";
            }
            else if (e.Item is GridFooterItem)
            {
                var footeritem = (GridFooterItem)e.Item;
                try
                {
                    var totalGrossProfit = decimal.Parse(e.Item.Cells[10].Text.Replace("$", string.Empty).Replace(",", string.Empty));
                    var totalSalesPrice = decimal.Parse(e.Item.Cells[6].Text.Replace("$", string.Empty).Replace(",", string.Empty));
                    e.Item.Cells[11].Text = ((totalGrossProfit / totalSalesPrice) * 100).ToString("0.00") + "%";
                }
                catch(Exception)
                {
                    //ignored
                }


                //footeritem.Cells[5].Text = string.Empty;
                //footeritem.Cells[7].Text = string.Empty;
                //footeritem.Style.Add("text-align", "right");
                footeritem.Style.Add("color", "green");
                footeritem.Style.Add("font-weight", "bold");
            }
            else if (e.Item is GridDataItem)
            {
                var item = (GridDataItem)e.Item;

                if (!(item.ItemIndex > -1 && item.DataItem is ReturnOrderQuantitiesAndAmountBO)) return;

                var obj = (ReturnOrderQuantitiesAndAmountBO)item.DataItem;
                var lnkQuentity = (HyperLink)item.FindControl("lnkQuantity");
                lnkQuentity.Text = Convert.ToString(obj.Quantity);
                lnkQuentity.NavigateUrl = "DrillDownReport.aspx?id=" + obj.ID +
                                          "&DistributorName="+obj.Name+
                                          "&Start=" + DateTime.Parse(this.txtCheckin.Value).ToShortDateString() +
                                          "&End=" + DateTime.Parse(this.txtCheckout.Value).ToShortDateString() +
                                          "&Current=" + HeaderText +
                                          "&Name=" + txtName.Text +
                                          "&Type=" + ((rdoDirectSales.Checked) ? "1" : "2");
                var litGrossMargin = (Literal)item.FindControl("litGrossMargin");
                litGrossMargin.Text = obj.GrossMargin.ToString("0.00") + "%";


                //HyperLink lnkDistributor = (HyperLink)item.FindControl("lnkDistributor");

                //                lnkDistributor.NavigateUrl = "DrillDownReport.aspx?id=" + obj.ID.ToString() + "&Start=" + DateTime.Parse(this.txtCheckin.Value).ToShortDateString() + "&End=" + DateTime.Parse(this.txtCheckout.Value).ToShortDateString() + "&Current=" + this.HeaderText + "&Name=" + this.txtName.Text + "&Type=" + ((this.rdoDirectSales.Checked)? "1" : "2");
                //lnkDistributor.Text = obj.Name;
                // Literal litGrossMargin = (Literal)item.FindControl("litGrossMargin");
                //litGrossMargin.Text = obj.GrossMargin.ToString("0.00") + "%";

            }

            else if (e.Item is GridGroupFooterItem)
            {
                GridGroupFooterItem groupFooter = e.Item as GridGroupFooterItem;
                decimal totalGrossProfit = decimal.Parse(e.Item.Cells[10].Text.Replace("$", string.Empty).Replace(",", string.Empty));
                decimal totalSalesPrice = decimal.Parse(e.Item.Cells[6].Text.Replace("$", string.Empty).Replace(",", string.Empty));
                e.Item.Cells[11].Text = ((totalGrossProfit/totalSalesPrice)*100).ToString("0.00") + "%";

                groupFooter.Style.Add("color", "blue");
                groupFooter.Style.Add("font-weight", "bold");
            }
        }

        protected void RadGridSalesReport_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridSalesReport_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridOrders_CustomAggregate(object sender, GridCustomAggregateEventArgs e)
        {
            switch (e.Column.UniqueName)
            {
                case "AvgPrice":
                    try
                    {
                        GridItem[] arrGroupFooter = RadGridSalesReport.MasterTableView.GetItems(GridItemType.GroupFooter);
                        GridItem[] arrFooter = RadGridSalesReport.MasterTableView.GetItems(GridItemType.Footer);

                        if (arrFooter.Any())
                        {
                            GridFooterItem footeritem = arrFooter.Last() as GridFooterItem;
                            int qty = int.Parse(footeritem.Cells[4].Text.Replace(",", ""));
                            decimal value = decimal.Parse(footeritem.Cells[6].Text.Replace("$", "").Replace(",", ""));

                            e.Result = "$" + String.Format("{0:n}", value / qty);
                            return;
                        }

                        if (arrGroupFooter.Any())
                        {
                            GridGroupFooterItem footeritem = arrGroupFooter.Last() as GridGroupFooterItem;
                            int qty = int.Parse(footeritem.Cells[4].Text.Replace(",", ""));
                            decimal value = decimal.Parse(footeritem.Cells[6].Text.Replace("$", "").Replace(",", ""));

                            e.Result = "$" + String.Format("{0:n}", value / qty);
                        }
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occurred while calculating average prices", ex);
                    }

                    break;
                case "Name":
                    {
                        if (e.Item is GridGroupFooterItem)
                        {
                            GridItem[] arrGroupHeader = RadGridSalesReport.MasterTableView.GetItems(GridItemType.GroupHeader);
                            if (arrGroupHeader.Any())
                            {
                                var headerItem = arrGroupHeader.Last() as GridGroupHeaderItem;
                                e.Result = "Total For " + headerItem.DataCell.Text;
                            }
                        }
                        else if (e.Item is GridFooterItem)
                        {
                            e.Result = "Grand Total ";
                        }
                    }
                    break;
                default:
                    break;
            }
        }

        protected void cvDateRange_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                DateTime? selecteddate1 = null;
                DateTime? selecteddate2 = null;

                if (!string.IsNullOrEmpty(this.txtCheckin.Value) && !string.IsNullOrEmpty(this.txtCheckout.Value))
                {
                    selecteddate1 = Convert.ToDateTime(this.txtCheckin.Value);
                    selecteddate2 = Convert.ToDateTime(this.txtCheckout.Value);
                }

                this.cvDateRange.IsValid = selecteddate1 < selecteddate2;
            }
            catch (Exception ex)
            {
                this.cvDateRange.IsValid = false;
            }
        }

        protected void btnViewReport_OnClick(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                PopulateDataGrid();
            }

            this.validationSummary.Visible = !Page.IsValid;
        }

        #endregion

        #region Methods

        /// <summary>
        /// This method calls when page loads
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;
            RadGridSalesReport.Visible = false;

            this.txtCheckout.Value = DateTime.Now.ToString("MMM dd, yyyy");
            this.txtCheckin.Value = DateTime.Now.ToString("MMM 1, yyyy");

            if (GetQueryIDs)
            {
                this.txtName.Text = this.DistributorName;
                this.rdoDirectSales.Checked = (this.DistributorType == "1") ? true : false;
                this.rdoWholesale.Checked = (this.DistributorType == "2") ? true : false;
                this.txtCheckin.Value = this.Start.ToShortDateString();
                this.txtCheckout.Value = this.End.ToShortDateString();
                //this.btnViewReport_OnClick(null, new EventArgs());
                PopulateDataGrid();
            }
        }

        //no error handling
        private void PopulateDataGrid()
        {
            RadGridSalesReport.Visible = true;

            DateTime? selecteddate1 = null;
            DateTime? selecteddate2 = null;
            if (!string.IsNullOrEmpty(this.txtCheckin.Value) && !string.IsNullOrEmpty(this.txtCheckout.Value))
            {
                selecteddate1 = Convert.ToDateTime(this.txtCheckin.Value);
                selecteddate2 = Convert.ToDateTime(this.txtCheckout.Value);
            }

            //Hide Controls

            this.dvDataContent.Visible = true;

            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Open();

                var lstOrderQtyAmt = connection.Query<ReturnOrderQuantitiesAndAmountBO>(string.Format(@"EXEC [Indico].[dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange] '{0}','{1}','{2}',{3}",
                                                                                      selecteddate1.Value.ToString("yyyyMMdd"), selecteddate2.Value.ToString("yyyyMMdd"), this.txtName.Text, this.rdoDirectSales.Checked ? 1 : 2)).ToList();
                connection.Close();
                //lstOrderQtyAmt = OrderBO.GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange(selecteddate1, selecteddate2, this.txtName.Text, this.rdoDirectSales.Checked ? 1 : 2);
                //IndicoEntities1 context = new IndicoEntities1();
                //List<ReturnOrderQuantitiesAndAmount> lstOrderQtyAmt = context.GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange(selecteddate1, selecteddate2, this.txtName.Text, this.rdoDirectSales.Checked ? 1 : 2).ToList<ReturnOrderQuantitiesAndAmount>();
                this.RadGridSalesReport.AllowPaging = (lstOrderQtyAmt.Count > this.RadGridSalesReport.PageSize);
                this.dvEmptyContent.Visible = (lstOrderQtyAmt.Count > 0) ? false : true;
                this.RadGridSalesReport.AllowSorting = false;
                this.RadGridSalesReport.MasterTableView.AllowNaturalSort = false;
                this.RadGridSalesReport.DataSource = lstOrderQtyAmt;
                this.RadGridSalesReport.DataBind();
                Session["GridReportDetails"] = lstOrderQtyAmt;
                this.RadGridSalesReport.Visible = (lstOrderQtyAmt.Count > 0);
            }
        }

        private void ProcessForm()
        {

        }

        private void ReBindGrid()
        {
            if (Session["GridReportDetails"] != null)
            {
                RadGridSalesReport.DataSource = (List<ReturnOrderQuantitiesAndAmountBO>)Session["GridReportDetails"];
                RadGridSalesReport.DataBind();
            }
        }

        #endregion

        protected void RadGridSalesReport_OnItemCreated(object sender, GridItemEventArgs e)
        {
            var filteringItem = e.Item as GridFilteringItem;
            if (filteringItem == null) return;
            filteringItem["Quantity"].HorizontalAlign = HorizontalAlign.Right;
            filteringItem["QuantityPercentage"].HorizontalAlign = HorizontalAlign.Right;
            filteringItem["Value"].HorizontalAlign = HorizontalAlign.Right;
            filteringItem["PurchasePrice"].HorizontalAlign = HorizontalAlign.Right;
            filteringItem["ValuePercentage"].HorizontalAlign = HorizontalAlign.Right;
            filteringItem["AvgPrice"].HorizontalAlign = HorizontalAlign.Right;
            filteringItem["GrossProfit"].HorizontalAlign = HorizontalAlign.Right;
            filteringItem["GrossMargin"].HorizontalAlign = HorizontalAlign.Right;
        }
    }
}