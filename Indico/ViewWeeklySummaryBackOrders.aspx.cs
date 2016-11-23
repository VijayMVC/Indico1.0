using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Web.UI;
using Indico.Common;
using System.Web.UI.WebControls;
using Dapper;
using Indico.Models;
using Telerik.Web.UI;

namespace Indico
{
    /// <summary>
    /// weekly orders summary view 
    /// </summary>
    /// <author>shanaka rusith</author>
    public partial class ViewWeeklySummaryBackOrders : IndicoPage
    {
        #region Event Handlers

        protected void OnShowButtonClick(object sender, EventArgs e)
        {
            var checkin = txtCheckin.Value;
            var checkout = txtCheckout.Value;
            PopulateGrid(checkin, checkout);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
                return;
            PopulateControllers();
            PopulateGrid();
        }

        protected void OnSummariesGridItemDataBound(object sender, GridItemEventArgs e)
        {
            var dataItem = e.Item.DataItem as WeeklyBackordersSummaryModel;
            if (dataItem == null)
                return;
            var datarow = e.Item as GridDataItem;
            if (datarow == null)
                return;
            var weekLink = (HyperLink) datarow.FindControl("weekLink");
            weekLink.Text = dataItem.WeekNumber;

            weekLink.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");
            weekLink.NavigateUrl = DrillDownPagePath(dataItem, ViewDrillDown.ViewDrillDownType.Shipments);

            var day = dataItem.WeekendDate.DayOfYear;
            if (DateTime.Now.Year == dataItem.WeekendDate.Year && (DateTime.Now.DayOfYear <= day && DateTime.Now.DayOfYear >= day - 6))
                datarow.BackColor = Color.FromArgb(230, 126, 34);

            if (dataItem.PoloCapacity < dataItem.PoloFirms)
            {
                datarow["PoloFirms"].BackColor = Color.HotPink;
                datarow["PoloFirms"].ToolTip = "Capacity exceeded by " + string.Format("{0:N0}", (dataItem.PoloFirms - dataItem.PoloCapacity));
            }

            var firmOrdersLink = (HyperLink) datarow.FindControl("poloFirmsLink");
            firmOrdersLink.Text = string.Format("{0:N0}", dataItem.PoloFirms);
            if (dataItem.PoloFirms > 0)
            {
                firmOrdersLink.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");
                firmOrdersLink.NavigateUrl = DrillDownPagePath(dataItem, ViewDrillDown.ViewDrillDownType.Firm);
            }


            var reservationsLink = (HyperLink) datarow.FindControl("poloReservationsLink");
            reservationsLink.Text = string.Format("{0:N0}", dataItem.PoloReservations);
            if (dataItem.PoloReservations > 0)
            {
                reservationsLink.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");
                reservationsLink.NavigateUrl = DrillDownPagePath(dataItem, ViewDrillDown.ViewDrillDownType.Reservations);
            }

            var holdLink = (HyperLink) datarow.FindControl("poloHoldLink");
            holdLink.Text = string.Format("{0:N0}", dataItem.PoloHolds);
            if (dataItem.PoloHolds > 0)
            {
                holdLink.NavigateUrl = DrillDownPagePath(dataItem, ViewDrillDown.ViewDrillDownType.Hold);
                holdLink.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");
            }

            var totalPoloLink = (HyperLink) datarow.FindControl("totalPoloLink");
            var total = (dataItem.TotalPolo + dataItem.PoloReservations);
            totalPoloLink.Text = string.Format("{0:N0}", total);
            if (total > 0)
            {
                totalPoloLink.NavigateUrl = DrillDownPagePath(dataItem, ViewDrillDown.ViewDrillDownType.AllPieces);
                totalPoloLink.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");
            }

            var totalCapacityLabel = (Label) datarow.FindControl("totalCapacityLabel");
            totalCapacityLabel.Text = string.Format("{0:N0}", dataItem.PoloCapacity);

            var balenceLabel = (Label) datarow.FindControl("balanceLabel");
            var balance = (dataItem.PoloCapacity - (dataItem.TotalPolo + dataItem.PoloReservations));
            balenceLabel.Text = string.Format("{0:N0}", balance);
            if (balance < 0)
                balenceLabel.ForeColor = Color.Red;

            var jacketsLink = (HyperLink) datarow.FindControl("jacketsLink");
            jacketsLink.Text = string.Format("{0:N0}", dataItem.OuterWareFirms);
            if (dataItem.OuterWareFirms > 0)
            {
                jacketsLink.NavigateUrl = DrillDownPagePath(dataItem, ViewDrillDown.ViewDrillDownType.Outerware);
                jacketsLink.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");
            }

            var jacketsCapacityLabel = (Label) datarow.FindControl("jacketsCapacityLabel");
            jacketsCapacityLabel.Text = string.Format("{0:N0}", dataItem.OuterwareCapacity);

            var uptoFiveOrdersLink = (HyperLink) datarow.FindControl("uptoFiveOrdersLink");
            uptoFiveOrdersLink.Text = string.Format("{0:N0}", dataItem.UptoFiveItems);
            if (dataItem.UptoFiveItems > 0)
            {
                uptoFiveOrdersLink.NavigateUrl = DrillDownPagePath(dataItem, ViewDrillDown.ViewDrillDownType.UptoFive);
                uptoFiveOrdersLink.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");
            }

            var uptoFiveOrderscapacityLabel = (Label) datarow.FindControl("uptoFiveOrderscapacityLabel");
            uptoFiveOrderscapacityLabel.Text = string.Format("{0:N0}", dataItem.UptoFiveItemsCapacity);

            var sampleLink = (HyperLink) datarow.FindControl("samplesLink");
            sampleLink.Text = string.Format("{0:N0}", dataItem.Samples);
            if (dataItem.Samples > 0)
            {
                sampleLink.NavigateUrl = DrillDownPagePath(dataItem, ViewDrillDown.ViewDrillDownType.Samples);
                sampleLink.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");
            }

            var samplesCapacityLable = (Label) datarow.FindControl("samplesCapacityLable");
            samplesCapacityLable.Text = string.Format("{0:N0}", dataItem.SampleCapacity);
        }

        #endregion

        #region Private Methods

        private string DrillDownPagePath(WeeklyBackordersSummaryModel model, ViewDrillDown.ViewDrillDownType type)
        {
            return string.Format("/ViewDrillDown.aspx?WeekNo={0}&Year={1}&Type={2}", model.WeekNo, model.WeekendDate.Year, ViewDrillDown.TypeToString(type));
        }

        private void PopulateControllers()
        {
            litHeaderText.Text = "Weekly Summaries (Backorder)";
        }

        private void PopulateGrid(string startDate = null, string endDate = null)
        {
            List<WeeklyBackordersSummaryModel> data;
            using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                if (!string.IsNullOrWhiteSpace(endDate) && !string.IsNullOrWhiteSpace(startDate))
                    data = connection.Query<WeeklyBackordersSummaryModel>(string.Format("EXEC [dbo].[SPC_GetBackOrdersWeeklySummary" +
                                                                                        "] '{0}', '{1}'", startDate, endDate)).ToList();
                else if (!string.IsNullOrWhiteSpace(startDate))
                    data = connection.Query<WeeklyBackordersSummaryModel>(string.Format("EXEC [dbo].[SPC_GetBackOrdersWeeklySummary] '{0}'", startDate)).ToList();
                else
                    data = connection.Query<WeeklyBackordersSummaryModel>(string.Format("EXEC [dbo].[SPC_GetBackOrdersWeeklySummary]")).ToList();
            }

            if (data.Count < 1)
            {
                dvEmptyContent.Visible = true;
                dvDataContent.Visible = false;
            }
            else
            {
                dvDataContent.Visible = true;
                SummariesGrid.DataSource = data;
                SummariesGrid.DataBind();
                Session["WeeklySummaryBackOrders"] = data;
            }
        }

        #endregion

        private void RebindGrid()
        {
            if (Session["WeeklySummaryBackOrders"] == null)
                return;
            SummariesGrid.DataSource = (List<WeeklyBackordersSummaryModel>)Session["PatternDetailsView"];
            SummariesGrid.DataBind();
        }

        protected void SummariesGrid_OnPageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            RebindGrid();
        }
    }
}