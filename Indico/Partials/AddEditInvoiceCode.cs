

using System;
using System.Collections.Generic;
using Indico.Models;
using System.Data;
using System.Globalization;
using System.Linq;
using Dapper;
using Telerik.Web.UI;
using System.Web.UI.WebControls;
using Indico.Common.Extensions;

// ReSharper disable once CheckNamespace
namespace Indico
{
    public partial class AddEditInvoice
    {
        #region Fields

        private int _currentInvoiceId;

        #endregion

        #region Properties

        /// <summary>
        /// ID Of the editing invoice . if 0 this is a new on (not editing)
        /// </summary>
        private int CurrentInvoiceId
        {
            get
            {
                if(_currentInvoiceId > -1)
                    return _currentInvoiceId;

                _currentInvoiceId = 0;
                if (Request.QueryString["id"] != null)
                {
                    _currentInvoiceId = Convert.ToInt32(Request.QueryString["id"]);
                }
                return _currentInvoiceId;
            }    
        }

        /// <summary>
        /// Is this a new Invoice or editing existing one
        /// </summary>
        private bool IsNew { get { return CurrentInvoiceId < 1; } }

        private List<NewShipmentOrderDetailSizeQtyViewModel> InvoiceItems { get { return  Session["InvoiceItems"] as List<NewShipmentOrderDetailSizeQtyViewModel>;   } set { Session["InvoiceItems"] = value; } }

        #endregion

        #region UI Events

        protected void OnWeekSelectionChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
        {
            var selectedWeekId = Convert.ToInt32(WeekComboBox.SelectedValue);
            if (selectedWeekId < 1)
                return;
            using (var connection = GetIndicoConnnection())
            {
                var shipmentKeys = GetShipmentKeys(connection, selectedWeekId);
                BindData(RadComboShipmentKey, shipmentKeys);
                EnableControl(RadComboShipmentKey);
            }
        }

        protected void OnShipmentKeyComboBoxSelectionChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
        {
            using (var connection = GetIndicoConnnection())
            {
                var selectedItem = RadComboShipmentKey.SelectedItem;
                if(selectedItem == null)
                    return;

                var shipTo = GetControl<Literal>(selectedItem, "litShipTo").Text;


                EnableOrDisableInvoiceInformationControls(true);
                LoadBillToAndShipTo(connection, shipTo);
                LoadBanks(connection);
                LoadShipmentModes(connection);
                LoadStatus(connection);
                LoadPorts(connection);

                LoadItems(connection, shipTo, GetControl<Literal>(selectedItem, "litDestinationPort").Text, 
                    GetControl<Literal>(selectedItem, "litETD").Text, 
                    GetControl<Literal>(selectedItem, "litPriceTerm").Text);
            }
        }

        protected void OnItemGridDataBind(object sender, GridItemEventArgs e)
        {
            var item = e.Item as GridDataItem;
            if (item != null)
            {
                var dataItem = item;

                if ((dataItem.ItemIndex > -1 && dataItem.DataItem is NewShipmentOrderDetailSizeQtyViewModel))
                {
                    var modelObject =  (NewShipmentOrderDetailSizeQtyViewModel)dataItem.DataItem;
                }

            }
        }

        protected void OnItemGridPageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            RebindItemGrid();
        }

        protected void OnIemtGridPageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            RebindItemGrid();
        }

        #endregion

        #region Private functions 

        private void InitializeUserInterface()
        {
            using (var databaseConnection = GetIndicoConnnection())
            {
                if (IsNew)
                    InitializeUserInterfaceForNewInvoice(databaseConnection);
            }
            
            using (var databaseConnection = GetIndicoConnnection())
            {

            }
        }

        private void InitializeUserInterfaceForNewInvoice(IDbConnection databaseConnection)
        {
            DisableControl(RadComboShipmentKey);
            EnableOrDisableInvoiceInformationControls(false);
            BindData(WeekComboBox,GetWeeks(databaseConnection));
        }

        private void EnableOrDisableInvoiceInformationControls(bool status)
        {
            var controls = new WebControl[] {txtInvoiceDate,txtInvoiceNo, txtAwbNo, txtAwbNo, ShipToDropDownList, BillToDropDownList, BankDropDownList, ShipmentModeDropDownList, PortDropDownList, StatusDropDownList, txtShipmentDate, chkChangeOrderDate};
            if(status)
                EnableControl(controls);
            else DisableControl(controls);
        }

        private static IEnumerable<ShipmentkeyModel> GetShipmentKeys(IDbConnection connection, int weekId)
        {
            return connection.Query<ShipmentkeyModel>(string.Format("EXEC [dbo].[SPC_GetShipmentKeys] {0}", weekId));
        }

        public static IEnumerable<WeekNoWeekendDateModel> GetWeeks(IDbConnection connection)
        {
            const string query =
                @"SELECT * FROM [dbo].WeeklyProductionCapacity WHERE WeekendDate <= DATEADD(MONTH ,1 , GETDATE()) AND DATEPART(yyyy, WeekendDate) >= {0} ORDER BY DATEPART(yyyy, WeekendDate) , WeekNo ";
            return connection.Query<WeekNoWeekendDateModel>(string.Format(query, DateTime.Now.Year));
        }

        private static IEnumerable<TextValueModel> GetAddressesForDistributor(IDbConnection connection, string distributorName)
        {
            return connection.Query<TextValueModel>(
                string.Format(@"SELECT dca.CompanyName + ' ' +  dca.[Address] + ' ' + dca.PostCode + ' ' +  dca.Suburb + ' ' + dca.[State] + dca.Country AS Text, dca.ID AS Value
	                FROM [dbo].[DistributorClientAddressDetailsView] dca
                WHERE dca.CompanyName = '{0}'", distributorName));
        } 

        private void LoadBillToAndShipTo(IDbConnection connection, string distributorName)
        {
            var addresses = GetAddressesForDistributor(connection, distributorName).ToList();
            BindData(ShipToDropDownList, addresses);
            BindData(BillToDropDownList, addresses);
        }

        private void LoadBanks(IDbConnection connection)
        {
            const string query = "SELECT [Name] AS [Text], ID AS [Value] FROM [dbo].[Bank] ORDER BY [Name]";
            var banks = connection.Query<TextValueModel>(query);
            BindData(BankDropDownList, banks);
        }

        private void LoadShipmentModes(IDbConnection connection)
        {
            const string query = "SELECT [Name] AS [Text], ID AS [Value] FROM [dbo].[ShipmentMode] ORDER BY [Name]";
            var shipmentModes = connection.Query<TextValueModel>(query);
            BindData(ShipmentModeDropDownList, shipmentModes);
        }

        private void LoadStatus(IDbConnection connection)
        {
            const string query = "SELECT [Name] AS [Text], ID AS [Value] FROM [dbo].[InvoiceStatus] ORDER BY [Name]";
            var status = connection.Query<TextValueModel>(query);
            BindData(StatusDropDownList, status);
        }

        private void LoadPorts(IDbConnection connection)
        {
            const string query = "SELECT [Name] AS [Text], ID AS [Value] FROM [dbo].[DestinationPort] ORDER BY [Name]";
            var ports = connection.Query<TextValueModel>(query);
            BindData(PortDropDownList, ports);
        }

        private void LoadItems(IDbConnection connection, string shipTo, string destinationPort, string etd, string priceTerm )
        {
            var query =
                 string.Format(@"
                      EXEC [dbo].[SPC_GetInvoiceOrderDetailItems]
                      @Distributor = '{0}', @Port = '{1}', @ShipmentDate = '{2}', @PaymentMethod = '{3}'", shipTo, destinationPort, DateTime.ParseExact(etd, "dd MMMM yyyy", null).GetSQLDateString(), priceTerm);

            var items = connection.Query<NewShipmentOrderDetailSizeQtyViewModel>(query).ToList();
            InvoiceItems = items;
            BindData(ItemGrid, items);
        }

        private void RebindItemGrid()
        {
            BindData(ItemGrid, InvoiceItems);
        }

        #endregion
    }
}