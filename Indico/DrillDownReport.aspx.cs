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
using System.Data.SqlClient;
using System.Configuration;
using System.Globalization;
using System.Diagnostics;
using System.Data;

namespace Indico
{
    public partial class DrillDownReport : IndicoPage
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

        public short Year { get; set; }

        public short Month { get; set; }

        protected bool GetQueryIDs
        {
            get
            {
                if (Request.QueryString["ID"] != null)
                {
                    try
                    {
                        this.Distributor = Convert.ToInt32(Request.QueryString["ID"].ToString());
                    }
                    catch(Exception)
                    {
                        return false;
                    }
                }
                else
                    return false;

                if (Request.QueryString["Start"] != null)
                {
                    try
                    {
                        this.Start = DateTime.Parse(Request.QueryString["Start"].ToString());
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
                        this.End = DateTime.Parse(Request.QueryString["End"].ToString());
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
                    this.DistributorName = Request.QueryString["Name"].ToString();
                }
                else
                    return false;

                if (Request.QueryString["Type"] != null)
                {
                    this.DistributorType = Request.QueryString["Type"].ToString();
                }
                else
                    return false;

                if (Request.QueryString["Current"] != null)
                {
                    this.Current = Request.QueryString["Current"].ToString();
                    if (this.Current.Length != 6)
                        return false;

                    if (!Regex.IsMatch(this.Current, @"^\d+$"))
                        return false;

                    this.Year = short.Parse(this.Current.Substring(0, 4));
                    this.Month = short.Parse(this.Current.Substring(4, 2));

                    if (Month < 1 || Month > 12)
                        return false;
                }
                else
                    return false;

                if (Request.QueryString["DistributorName"] != null)
                {
                    CurrentDistributorName = Request.QueryString["DistributorName"];
                }
                else
                    return false;

                if (End < Start)
                    return false;

                return true;
            }
        }

        public new int Distributor { get; set; }

        public string CurrentDistributorName { get; set; }
        
        public DateTime Start { get; set; }

        public DateTime End { get; set; }

        public string Current { get; set; }

        public short Date { get; set; }

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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                PopulateControls();
            }
        }

        protected void RadGridDrillDownReport_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridDrillDownReport_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridDrillDownReport_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridGroupHeaderItem)
            {
                GridGroupHeaderItem item = e.Item as GridGroupHeaderItem;
                (item.DataCell).Text = (item.DataCell).Text.Replace("MonthAndYear: ", string.Empty);
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
                GridFooterItem footeritem = e.Item as GridFooterItem;
                //footeritem.Cells[5].Text = string.Empty;

                try
                {
                    var totalGrossProfit = decimal.Parse(e.Item.Cells[9].Text.Replace("$", string.Empty).Replace(",", string.Empty));
                    var totalSalesPrice = decimal.Parse(e.Item.Cells[5].Text.Replace("$", string.Empty).Replace(",", string.Empty));
                    e.Item.Cells[10].Text = ((totalGrossProfit / totalSalesPrice) * 100).ToString("0.00") + "%";
                }
                catch (Exception)
                {
                    //ignored
                }


                footeritem.Style.Add("color", "green");
                footeritem.Style.Add("font-weight", "bold");
            }
            else if (e.Item is GridGroupFooterItem)
            {

                var totalGrossProfit = decimal.Parse(e.Item.Cells[10].Text.Replace("$", string.Empty).Replace(",", string.Empty));
                var totalSalesPrice = decimal.Parse(e.Item.Cells[6].Text.Replace("$", string.Empty).Replace(",", string.Empty));
                e.Item.Cells[11].Text = ((totalGrossProfit / totalSalesPrice) * 100).ToString("0.00") + "%";




                GridGroupFooterItem groupFooter = e.Item as GridGroupFooterItem;
                
                groupFooter.Cells[2].BackColor = Color.Red;
                groupFooter.Style.Add("color", "blue");
                groupFooter.Style.Add("font-weight", "bold");
            }
            else if (e.Item is GridDataItem)
            {
                
                var item = (GridDataItem)e.Item;
                if (!(item.ItemIndex > -1 && item.DataItem is ReturnDetailReportByDistributorBO)) return;
                var obj = (ReturnDetailReportByDistributorBO)item.DataItem;

                var lnkQuantity = (HyperLink)item.FindControl("lnkQuantity");
                lnkQuantity.NavigateUrl = "DrillDownReportByClient.aspx?Start=" + this.Start.ToShortDateString() + "&End=" + this.End.ToShortDateString() + "&Distributor=" + this.Distributor.ToString() + "&Client=" + obj.ID.ToString() + "&Current=" + this.Current + "&Name=" + this.DistributorName + "&Type=" + this.DistributorType + "&ClientName=" + obj.Client + "&DistributorName="+CurrentDistributorName;
                lnkQuantity.Text = Convert.ToString(obj.Quantity);
            }
         }

        protected void RadGridDrillDownReport_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridDrillDownReport_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridDrillDownReport_CustomAggregate(object sender, GridCustomAggregateEventArgs e)
        {
            switch (e.Column.UniqueName)
            {
                case "AvgPrice":
                    try
                    {
                        GridItem[] arrGroupFooter = RadGridDrillDownReport.MasterTableView.GetItems(GridItemType.GroupFooter);
                        GridItem[] arrGridFooter = RadGridDrillDownReport.MasterTableView.GetItems(GridItemType.Footer);

                        if (arrGridFooter.Any())
                        {
                            GridFooterItem footeritem = arrGridFooter.Last() as GridFooterItem;
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
                        IndicoLogging.log.Error("Error occured while calculating average prices", ex);
                    }

                    break;
                case "Client": 
                    {
                        if (e.Item is GridGroupFooterItem)
                        {
                            GridItem[] arrGroupHeader = RadGridDrillDownReport.MasterTableView.GetItems(GridItemType.GroupHeader);
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

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("/SalesGridReport.aspx?Name=" + this.DistributorName + "&Type=" + this.DistributorType + "&Start=" + this.Start.ToShortDateString() + "&End=" + this.End.ToShortDateString());
        }

        protected void RadGridDrillDownReport_OnItemCreated(object sender, GridItemEventArgs e)
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

        #endregion

        #region Methods

        private void PopulateControls()
        {
           
            PopulateDataGrid();
            if (CurrentDistributorName == null) CurrentDistributorName = "";
             this.litHeaderText.Text = "DRILL DOWN REPORT BY CLIENT FOR ( "+CurrentDistributorName.ToUpper()+" )";
        }

        private void PopulateDataGrid()
        {
            if (this.GetQueryIDs)
            {
                //Back button
                lbBack.NavigateUrl = "/SalesGridReport.aspx?Name=" + this.DistributorName + "&Type=" + this.DistributorType + "&Start=" + this.Start.ToShortDateString() + "&End=" + this.End.ToShortDateString();

                //IndicoEntities1 context = new IndicoEntities1();
               // List<ReturnDetailReportByDistributor> lstDetailReport = context.GetDetailReportByDistributor(/*t.Item1, t.Item2*/ this.Start, this.End, this.Distributor).ToList<ReturnDetailReportByDistributor>();

                using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
                {
                    connection.Open();

                    var t = CalculateStartDateAndEndDate(this.Start, this.End, this.Year, this.Month);
                    var lstDetailReport = connection.Query<ReturnDetailReportByDistributorBO>(string.Format(@"EXEC [Indico].[dbo].[SPC_GetDetailReportByDistributor] '{0}','{1}',{2}",
                                                                                      t.Item1.ToString("yyyyMMdd"), t.Item2.ToString("yyyyMMdd"), this.Distributor)).ToList();

                    //var lstDetailReport = connection.Query<ReturnDetailReportByDistributorBO>(string.Format(@"EXEC [Indico].[dbo].[SPC_GetDetailReportByDistributor] '{0}','{1}',{2}",
                    //                                                                 this.Start.ToString("yyyy-MM-dd hh:mm:ss", CultureInfo.InvariantCulture), this.End.ToString("yyyy-MM-dd hh:mm:ss", CultureInfo.InvariantCulture), this.Distributor)).ToList();
                    connection.Close();
                    this.RadGridDrillDownReport.AllowPaging = (lstDetailReport.Count > this.RadGridDrillDownReport.PageSize);
                    this.RadGridDrillDownReport.AllowSorting = false;
                    this.RadGridDrillDownReport.MasterTableView.AllowNaturalSort = false;
                    this.RadGridDrillDownReport.DataSource = lstDetailReport;
                    this.RadGridDrillDownReport.DataBind();
                    Session["GridDetailsReport"] = lstDetailReport;
                }
            }
            else
            {
                // Redirect to error page
                Response.Redirect("/Error.aspx?");
            }
        }

        private void ProcessForm()
        {

        }

        private void ReBindGrid()
        {
            if (Session["GridDetailsReport"] != null)
            {
                RadGridDrillDownReport.DataSource = (List<ReturnDetailReportByDistributorBO>)Session["GridDetailsReport"];
                RadGridDrillDownReport.DataBind();
            }
        }

        private Tuple<DateTime, DateTime> CalculateStartDateAndEndDate(DateTime start, DateTime end, short year, short month)
        {
            if (start.Month < month)
                start = DateTime.Parse("01/" + month.ToString() + "/" + year.ToString());

            if (end.Month > month)
                end = DateTime.Parse(this.CalculateLastDate(month, year).ToString() + "/" + month.ToString() + "/" + year.ToString());

            return new Tuple<DateTime, DateTime>(start, end);
        }

        private short CalculateLastDate(short month, short year)
        {
            if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)
                return 31;
            else if (month == 4 || month == 6 || month == 9 || month == 11)
                return 30;
            else if (year % 4 == 0)
                return 29;
            else
                return 28;
        }

        #endregion
    }
}