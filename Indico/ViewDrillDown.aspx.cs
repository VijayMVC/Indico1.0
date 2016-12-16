using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using Indico.Common;
using System.Data.SqlClient;
using System.Configuration;
using Dapper;
using Indico.Models;
using Telerik.Web.UI;
using System.Web.UI;

namespace Indico
{
    public partial class ViewDrillDown : IndicoPage
    {
        #region Enums

        public enum ViewDrillDownType
        {
            Firm = 1,
            Hold = 2,
            AllPieces = 3,
            Outerware = 4,
            UptoFive = 5,
            Samples = 6,
            Reservations= 7,
            Shipments = 8,
            ShipmentDetails = 9
        }

        #endregion

        #region Fields

        private int _weekNumber;
        private int _year;
        private ViewDrillDownType _type;
        private string _shipTo;
        private string _etd;
        #endregion

        #region Methods

        private bool LoadProperties()
        {
            try
            {
                var weekNumber = Request.QueryString["WeekNo"];
                var year = Request.QueryString["Year"];
                if (!string.IsNullOrWhiteSpace(weekNumber))
                    _weekNumber = Int32.Parse(weekNumber);
                else
                    return false;
                if (!string.IsNullOrWhiteSpace(year))
                    _year = Int32.Parse(year);
                else
                    return false;

                var type = Request.QueryString["Type"];
                if (type != null)
                {
                    var str = type.ToUpper();
                    switch (str)
                    {
                        case "FIRM":
                            _type = ViewDrillDownType.Firm;
                            break;
                        case "HOLD":
                            _type = ViewDrillDownType.Hold;
                            break;
                        case "RESERVATIONS":
                            _type = ViewDrillDownType.Reservations;
                            break;
                        case "ALL":
                            _type = ViewDrillDownType.AllPieces;
                            break;
                        case "OUTERWARE":
                            _type = ViewDrillDownType.Outerware;
                            break;
                        case "UPTOFIVE":
                            _type = ViewDrillDownType.UptoFive;
                            break;
                        case "SAMPLE":
                            _type = ViewDrillDownType.Samples;
                            break;
                        case "SHIPMENT":
                            _type = ViewDrillDownType.Shipments;
                            break;
                        case "SHIPMENTDETAIL":
                            _type = ViewDrillDownType.ShipmentDetails;
                            break;
                        default:
                            return false;
                    }

                    if (_type == ViewDrillDownType.ShipmentDetails)
                    {
                        _shipTo = Request.QueryString["ShipTo"];
                        _etd = Request.QueryString["ETD"];
                    }
                }
            }
            catch (Exception)
            {

                return false;
            }
            return true;
        }

        private void PopulateOrderGrid()
        {
            using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                var type = 1;
                switch (_type)
                {
                      case  ViewDrillDownType.Firm:
                        type = 1;
                        break;
                        case ViewDrillDownType.Hold:
                        type = 2;
                        break;
                    case ViewDrillDownType.AllPieces:
                        type = 3;
                        break;
                    case ViewDrillDownType.Outerware:
                        type = 4;
                        break;
                    case ViewDrillDownType.UptoFive:
                        type = 5;
                        break;
                    case ViewDrillDownType.Samples:
                        type = 6;
                        break;
                    case ViewDrillDownType.Reservations:
                        type = 7;
                        break;
                    case ViewDrillDownType.Shipments:
                        type = 8;
                        break;
                    case ViewDrillDownType.ShipmentDetails:
                        type = 9;
                        break;

                }
                var data = _type == ViewDrillDownType.ShipmentDetails ? 
                    connection.Query<DrillDownModel>(string.Format("EXEC [dbo].[SPC_{0}] '{1}', '{2}'", "GetShipmentDetails", _shipTo, _etd)).OrderBy(i => i.Order).ToList() 
                    : connection.Query<DrillDownModel>(string.Format("EXEC [dbo].[SPC_{0}] {1}, {2}, {3}", "GetPoloOrdersForGivenWeek", _year, _weekNumber, type)).ToList();
                
                
                if (_type != ViewDrillDownType.Shipments)
                {
                    var orders = data.GroupBy(i => i.Order);
                    foreach (var o in orders)
                    {
                        var i = 1;
                        var vls = o.OrderBy(t => t.ProductID).ToList();
                        foreach (var vl in vls)
                        {
                            //vl.PurchaseOrderNumber = vl.PurchaseOrderNumber + "-" + i;
                            string index = (i < 10) ? ("0" + i) : i.ToString();
                            vl.PurchaseOrderNumber = vl.PurchaseOrderNumber + "-" + index;                            
                            i++;
                        }
                    }
                    data = data.OrderBy(d => d.Order).ThenBy(d => d.ProductID).ToList();
                }
                if (data.Count < 1)
                {
                    dvEmptyContent.Visible = true;
                    return;
                }
                switch (_type)
                {
                    case ViewDrillDownType.Reservations:
                        OrderGrid.Columns[2].Display = false;
                        OrderGrid.Columns[4].Display = false;
                        OrderGrid.Columns[15].Display = false;
                        OrderGrid.Columns[16].Display = false;
                        OrderGrid.Columns[17].Visible = false;
                        OrderGrid.Columns[19].Display = false;
                        OrderGrid.Columns[20].Display = false;
                        OrderGrid.Columns[21].Display = false;
                        break;
                    case ViewDrillDownType.Shipments:
                        OrderGrid.Columns[0].Visible = false;
                        OrderGrid.Columns[1].Visible = false;
                        OrderGrid.Columns[2].Visible = false;
                        OrderGrid.Columns[3].Visible = false;
                        OrderGrid.Columns[4].Visible = false;
                        OrderGrid.Columns[5].Visible = false;
                        OrderGrid.Columns[6].Visible = true;
                        OrderGrid.Columns[7].Visible = false;
                        OrderGrid.Columns[8].Visible = false;
                        OrderGrid.Columns[9].Visible = false;
                        OrderGrid.Columns[10].Visible = false;
                        OrderGrid.Columns[11].Visible = false;
                        OrderGrid.Columns[12].Visible = false;
                        OrderGrid.Columns[13].Visible = false;
                        OrderGrid.Columns[14].Visible = false;
                        OrderGrid.Columns[15].Visible = true;
                        OrderGrid.Columns[16].Visible = false;
                        OrderGrid.Columns[17].Visible = false;
                        OrderGrid.Columns[18].Visible = false;
                        OrderGrid.Columns[19].Visible = true;
                        OrderGrid.Columns[20].Visible = true;
                        OrderGrid.Columns[21].Visible = true;
                        OrderGrid.Columns[22].Visible = false;
                        OrderGrid.Columns[23].Visible = false;
                        OrderGrid.Columns[24].Visible = false;
                        OrderGrid.Columns[25].Visible = false;
                        OrderGrid.Columns[26].Visible = true;
                        OrderGrid.Columns[27].Visible = false;
                        OrderGrid.Columns[28].Visible = false;
                        OrderGrid.Columns[29].Visible = false;
                        break;
                    default:
                        if(_type != ViewDrillDownType.AllPieces)
                        {
                            OrderGrid.Columns[14].Display = false;
                            OrderGrid.Columns[13].Display = false;
                            OrderGrid.Columns[12].Display = false;
                        }
                        break;
                }
                
                Session["DrilldownView"] = data;
                OrderGrid.DataSource = data;
                OrderGrid.DataBind();
                dvDataContent.Visible = true;
            }
        }

        private void PopulateControls()
        {
            litHeaderText.Text = string.Format("{2} For The Week {0}/{1}.", _year,_weekNumber,TypeToNormalString(_type));
        }

        public static string TypeToString(ViewDrillDownType type)
        {
            switch (type)
            {
                case ViewDrillDownType.Firm:
                    return "FIRM";
                case ViewDrillDownType.Hold:
                    return "HOLD";
                case ViewDrillDownType.Reservations:
                    return "RESERVATIONS";
                case ViewDrillDownType.AllPieces:
                    return "ALL";
                case ViewDrillDownType.Outerware:
                    return "OUTERWARE";
                case ViewDrillDownType.UptoFive:
                    return "UPTOFIVE";
                case ViewDrillDownType.Samples:
                    return "SAMPLE";
                case ViewDrillDownType.Shipments:
                    return "SHIPMENT";
                case ViewDrillDownType.ShipmentDetails:
                    return "SHIPMENTDETAIL";
                default:
                    return "";
            }
        }

        private string TypeToNormalString(ViewDrillDownType type)
        {
            switch (type)
            {
                case ViewDrillDownType.Firm:
                    return "Firm Orders";
                case ViewDrillDownType.Hold:
                    return "Hold Items";
                case ViewDrillDownType.Reservations:
                    return "Reservations";
                case ViewDrillDownType.AllPieces:
                    return "Orders";
                case ViewDrillDownType.Outerware:
                    return "Outer wares";
                case ViewDrillDownType.UptoFive:
                    return "Up to five Orders";
                case ViewDrillDownType.Samples:
                    return "Sample Orders";
                case ViewDrillDownType.Shipments:
                    return "Shipments";
                case ViewDrillDownType.ShipmentDetails:
                    return "Shipment Details";
                default:
                    return "";
            }
        }
        
        private void ReBindGrid()
        {
            if (Session["DrilldownView"] == null) return;
            OrderGrid.DataSource = (List<DrillDownModel>)Session["DrilldownView"];
            OrderGrid.DataBind();
        }

        #endregion

        #region Events

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!LoadProperties())
                throw new Exception("Given Query Parameter Values Are Wrong For ViewDrillDown");
            PopulateOrderGrid();
            PopulateControls();
        }
        
        protected void OnOrderGridItemDataBound(object sender, GridItemEventArgs e)
        {
            var dataItem = e.Item.DataItem as DrillDownModel;
            if (dataItem == null)
                return;
            var item = e.Item as GridDataItem;
            if (item == null)
                return;
            var datarow = item;

            var poNumberLink = (HyperLink)datarow.FindControl("PONumberLink");
            poNumberLink.Text = dataItem.PurchaseOrderNumber;
            poNumberLink.NavigateUrl = string.Format("AddEditOrder.aspx?id={0}", dataItem.Order);
            poNumberLink.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");

            var productlink = (HyperLink)datarow.FindControl("ProductLink");
            productlink.Text = dataItem.Product;
            productlink.NavigateUrl = string.Format("AddEditVisualLayout.aspx?id={0}", dataItem.ProductID);
            productlink.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");

            var patternLink = (HyperLink)datarow.FindControl("patternLink");
            patternLink.Text = dataItem.Pattern;
            patternLink.NavigateUrl = string.Format("AddEditPattern.aspx?id={0}", dataItem.PatternID);
            patternLink.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");

            var fabricLink = (HyperLink)datarow.FindControl("fabricLink");
            fabricLink.Text = dataItem.Fabric;
            fabricLink.NavigateUrl = string.Format("AddEditFabricCode.aspx?id={0}", dataItem.FabricID);
            fabricLink.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");

            var qtyLink = (HyperLink)datarow.FindControl("QtyLink");
            qtyLink.Text = string.Format("{0:N0}", dataItem.Qty);


            if (_type == ViewDrillDownType.Shipments)
            {
                var url = string.Format("/ViewDrillDown.aspx?WeekNo={0}&Year={1}&Type={2}&ShipTo={3}&ETD={4}", _weekNumber, _year, TypeToString(ViewDrillDownType.ShipmentDetails),dataItem.ShipTo,dataItem.ETD.ToString("yyyyMMdd"));
                datarow.Attributes.Add("ondblclick", string.Format( "OpenInNewTab('{0}');",url));
                qtyLink.NavigateUrl = string.Format(url);
                qtyLink.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");
            }
        }
        
        protected void OnExportToExcelButtonClick(object sender, EventArgs e)
        {
            const string alternateText = "ExcelML";
            OrderGrid.ExportSettings.Excel.Format = (GridExcelExportFormat)Enum.Parse(typeof(GridExcelExportFormat), alternateText);
            OrderGrid.ExportSettings.IgnorePaging = true;
            OrderGrid.ExportSettings.ExportOnlyData = true;
            OrderGrid.ExportSettings.OpenInNewWindow = true;
            OrderGrid.ExportSettings.FileName = string.Format("{0}-{1}-{2}", TypeToNormalString(_type), _year + "/" + _weekNumber, string.Format("{0}_{1}_{2}_{3}", DateTime.Now.Year, DateTime.Now.Month, DateTime.Now.Hour, DateTime.Now.Minute));
            OrderGrid.MasterTableView.ExportToExcel();
        }

        protected void OrderGrid_OnPageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            ReBindGrid();
        }

        protected void OrderGrid_OnPageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            ReBindGrid();
        }

        protected void OrderGrid_OnSortCommand(object sender, GridSortCommandEventArgs e)
        {
            ReBindGrid();
        }

        protected void OnItemClick(object sender, RadMenuEventArgs e)
        {
            ReBindGrid();
        }

        protected void OrderGrid_OnGroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            ReBindGrid();
        }
        
        #endregion
    }
}