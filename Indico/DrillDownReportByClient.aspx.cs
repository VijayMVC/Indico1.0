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

namespace Indico
{
    public partial class DrillDownReportByClient : IndicoPage
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

        protected bool GetQueryIDs
        {
            get
            {
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

                if (Request.QueryString["Distributor"] != null)
                {
                    try
                    {
                        this.Distributor = Convert.ToInt32(Request.QueryString["Distributor"].ToString());
                    }
                    catch(Exception)
                    {
                        return false;
                    }
 
                }
                else
                    return false;

                if (Request.QueryString["Client"] != null)
                {
                    try
                    {
                        this.Client = Convert.ToInt32(Request.QueryString["Client"].ToString());
                    }
                    catch(Exception)
                    {
                        return false;
                    }

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

                if (Request.QueryString["ClientName"] != null)
                    ClientName = Request.QueryString["ClientName"];
                else return false;

                if (Request.QueryString["DistributorName"] != null)
                    CurrentDistributorName = Request.QueryString["DistributorName"];
                else
                    return false;

                return true;
            }
        }

        public new int Distributor { get; set; }

        public int Client { get; set; }

        public string ClientName { get; set; }

        public DateTime Start { get; set; }

        public DateTime End { get; set; }

        public string Current { get; set; }

        public short Year { get; set; }

        public short Month { get; set; }

        public string DistributorName { get; set; }

        public string CurrentDistributorName { get; set; }

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

        protected void RadGridDrillDownReportByClient_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridDrillDownReportByClient_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridDrillDownReportByClient_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (!(e.Item is GridFooterItem)) return;
            try
            {
                var totalGrossProfit = decimal.Parse(e.Item.Cells[8].Text.Replace("$", string.Empty).Replace(",", string.Empty));
                var totalSalesPrice = decimal.Parse(e.Item.Cells[6].Text.Replace("$", string.Empty).Replace(",", string.Empty));
                e.Item.Cells[9].Text = ((totalGrossProfit / totalSalesPrice) * 100).ToString("0.00") + "%";
            }
            catch (Exception)
            {
                //ignored
            }

            var footeritem = (GridFooterItem)e.Item;
            footeritem.Style.Add("color", "green");
            footeritem.Style.Add("font-weight", "bold");
        }

        protected void RadGridDrillDownReportByClient_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridDrillDownReportByClient_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        #endregion

        #region Methods

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

        private void PopulateControls()
        {
            
          //this.litHeaderText.Text = this.ActivePage.Heading;
            PopulateDataGrid();
            if (ClientName == null) ClientName = "";
            litHeaderText.Text = string.Format("DRILL DOWN REPORT BY PRODUCT FOR ( {0} )",ClientName.ToUpper());
        }

        private void PopulateDataGrid()
        {
            if (this.GetQueryIDs)
            {
                //Back button
                lbBack.NavigateUrl = "/DrillDownReport.aspx?id=" + this.Distributor +"&DistributorName="+CurrentDistributorName+ "&Start=" + this.Start.ToShortDateString() + "&End=" + this.End.ToShortDateString() + "&Current=" + this.Current + "&Name=" + this.DistributorName + "&Type=" + this.DistributorType;
                // Show the detail VL information
                var t = CalculateStartDateAndEndDate(this.Start, this.End, this.Year, this.Month);
                //IndicoEntities1 context = new IndicoEntities1();
                using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
                {
                    connection.Open();
                    var lstDetailReportByClient = connection.Query<ReturnDetailReportByClientBO>(string.Format(@"EXEC [Indico].[dbo].[SPC_GetDetailReportByClient] '{0}','{1}','{2}',{3}",
                                                                                      t.Item1.ToString("yyyyMMdd"), t.Item2.ToString("yyyyMMdd"), this.Distributor, this.Client)).ToList();
                    connection.Close();

                    RadGridDrillDownReportByClient.AllowPaging = (lstDetailReportByClient.Count > RadGridDrillDownReportByClient.PageSize);
                    RadGridDrillDownReportByClient.AllowSorting = false;
                    RadGridDrillDownReportByClient.MasterTableView.AllowNaturalSort = false;
                    
                    RadGridDrillDownReportByClient.DataSource = lstDetailReportByClient;
                    RadGridDrillDownReportByClient.DataBind();
                    Session["GridDetailsReportByClient"] = lstDetailReportByClient;
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
            if (Session["GridDetailsReportByClient"] != null)
            {
                this.RadGridDrillDownReportByClient.DataSource = (List<ReturnDetailReportByClientBO>)Session["GridDetailsReportByClient"];
                this.RadGridDrillDownReportByClient.DataBind();
            }
        }

        #endregion

        protected void RadGridDrillDownReportByClient_OnItemCreated(object sender, GridItemEventArgs e)
        {
            var filteringItem = e.Item as GridFilteringItem;
            if (filteringItem == null) return;
            filteringItem["Quantity"].HorizontalAlign = HorizontalAlign.Right;
            filteringItem["Price"].HorizontalAlign = HorizontalAlign.Right;
            filteringItem["Value"].HorizontalAlign = HorizontalAlign.Right;
            filteringItem["PurchasePrice"].HorizontalAlign = HorizontalAlign.Right;
            filteringItem["GrossProfit"].HorizontalAlign = HorizontalAlign.Right;
            filteringItem["GrossMargin"].HorizontalAlign = HorizontalAlign.Right;
        }
    }
}