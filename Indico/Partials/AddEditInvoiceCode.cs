

using System;
using System.Collections.Generic;
using Indico.Models;
using System.Data;
using System.Linq;
using Dapper;
using Telerik.Web.UI;
using System.Web.UI.WebControls;
using Indico.Common.Extensions;
using Indico.BusinessObjects;
using System.Text;

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

                //if (_currentInvoiceId > -1)
                //    return _currentInvoiceId;

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

        private bool InnertextChanged { get { return ((bool?)Session["InnertextChanged"] ?? false); } set { Session["InnertextChanged"] = value; } }

        // private List<NewShipmentOrderDetailSizeQtyViewModel> OriginalInvoiceItems { get { return Session["OriginalInvoiceItems"] as List<NewShipmentOrderDetailSizeQtyViewModel>; } set { Session["OriginalInvoiceItems"] = value; } }
        private List<NewShipmentOrderDetailSizeQtyViewModel> InvoiceItems { get { return Session["InvoiceItems"] as List<NewShipmentOrderDetailSizeQtyViewModel>; } set { Session["InvoiceItems"] = value; } }

        private List<ShipmentkeyModel> ShipmentKeys
        {
            get
            {
                return Session["ShipmentKeys"] as List<ShipmentkeyModel>;
            }
            set
            {
                Session["ShipmentKeys"] = value;
            }
        }
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
            var index = RadComboShipmentKey.SelectedIndex;
            if (index < 0)
                return;

            var selectedModel = ShipmentKeys[index];
            if (selectedModel == null)
                return;
            using (var connection = GetIndicoConnnection())
            {
                var selectedItem = RadComboShipmentKey.SelectedItem;
                if (selectedItem == null)
                    return;

                EnableOrDisableInvoiceInformationControls(true);
                LoadBillToAndShipTo(connection);
                LoadBanks(connection);
                LoadShipmentModes(connection);
                LoadStatus(connection);
                LoadPorts(connection);

                int weeklyCapacityId = int.Parse(this.WeekComboBox.SelectedItem.Value);
                WeeklyProductionCapacityBO obj = new WeeklyProductionCapacityBO();
                obj.ID = weeklyCapacityId;
                obj.GetObject();

                int invoiceId = 0;

                //InvoiceBO objInv = new InvoiceBO();
                //OrderDetailBO objOrderD = new OrderDetailBO();

                //objInv.WeeklyProductionCapacity = weeklyCapacityId;
                //objInv.ShipTo = selectedModel.ShipToID;
                //objInv.ShipmentDate = selectedModel.ShipmentDate;
                // TODO: Add database fields for below two
                //objInv.Port = objOrderD.order selectedModel.PortID;
                //objInv.PriceTerm = selectedModel.PriceTermID;
                //List<InvoiceBO> lstInvoices = objInv.SearchObjects();

                //if (lstInvoices.Count > 0)
                //{
                    invoiceId = this.CreateInvoice(connection, weeklyCapacityId, selectedModel.ShipToID, selectedModel.PortID, obj.WeekendDate.Year.ToString() + obj.WeekendDate.Month.ToString().PadLeft(2, '0') + obj.WeekendDate.Day.ToString().PadLeft(2, '0'),
                        selectedModel.ShipmentDate.GetSQLDateString(), selectedModel.PriceTermID, selectedModel.ShipmentModeID);
                //}
                //else
                //    invoiceId = lstInvoices[0].ID;

                this.LoadInvoice(connection, invoiceId);
            }
        }

        protected void OnItemGridDataBind(object sender, GridItemEventArgs e)
        {
            var item = e.Item as GridDataItem;
            if (item != null)
            {
                var dataItem = item;
                string itemId; 

                if ((dataItem.ItemIndex > -1 && dataItem.DataItem is NewShipmentOrderDetailSizeQtyViewModel))
                {
                    var modelObject = (NewShipmentOrderDetailSizeQtyViewModel)dataItem.DataItem;
                    if (modelObject.IsRemoved)
                    {
                        item.Visible = false;
                        return;
                    }

                    var factoryPriceTextBox = GetControl<RadNumericTextBox>(e.Item, "FactoryPriceTextBox");
                    var otherChargesTextBox = GetControl<RadNumericTextBox>(e.Item, "OtherChargesTextBox");
                    var notesTextAreaTextBox = GetControl<RadTextBox>(e.Item, "NotesTextArea");
                    itemId = modelObject.InvoiceOrderDetailItemID.ToString();
                    factoryPriceTextBox.Attributes["uid"] = itemId;
                    otherChargesTextBox.Attributes["uid"] = itemId;
                    notesTextAreaTextBox.Attributes["uid"] = itemId;
                    factoryPriceTextBox.Text = modelObject.FactoryPrice.ToString();
                    otherChargesTextBox.Text = modelObject.OtherCharges.ToString();
                    notesTextAreaTextBox.Text = modelObject.FactoryNotes.ToString();
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

        protected void OnItemGridItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandSource is RadButton)
            {
                var button = e.CommandSource as RadButton;
                if (button.ID == "ApplyOtherChargesButton")
                {
                    var textBox = GetControl<RadNumericTextBox>(button.Parent, "OtherChargesApplyTextBox");
                    decimal value;
                    if (textBox.Text != null)
                    {
                        if (decimal.TryParse(textBox.Text, out value))
                        {
                            var gridItems = ItemGrid.Items;
                            var en = gridItems.GetEnumerator();
                            var invoiceItems = InvoiceItems;
                            while (en.MoveNext())
                            {
                                var gridItem = en.Current as GridDataItem;
                                var tb = GetControl<RadNumericTextBox>(gridItem, "OtherChargesTextBox");
                                var id = int.Parse(tb.Attributes["uid"]);

                                var toUpdate = invoiceItems.FirstOrDefault(i => i.InvoiceOrderDetailItemID == id);
                                if (toUpdate != null)
                                    toUpdate.OtherCharges = value;

                            }

                            InvoiceItems = invoiceItems;
                        }
                    }
                }
                else if (button.ID == "ApplyFactoryPriceButton")
                {
                    var textBox = GetControl<RadNumericTextBox>(button.Parent, "FactoryPriceApplyTextBox");
                    decimal value;
                    if (textBox.Text != null)
                    {
                        if (decimal.TryParse(textBox.Text, out value))
                        {
                            var gridItems = ItemGrid.Items;
                            var en = gridItems.GetEnumerator();
                            var invoiceItems = InvoiceItems;
                            while (en.MoveNext())
                            {
                                var gridItem = en.Current as GridDataItem;
                                var tb = GetControl<RadNumericTextBox>(gridItem, "FactoryPriceTextBox");
                                var id = int.Parse(tb.Attributes["uid"]);

                                var toUpdate = invoiceItems.FirstOrDefault(i => i.InvoiceOrderDetailItemID == id);
                                if (toUpdate != null)
                                    toUpdate.FactoryPrice = value;

                            }
                            InvoiceItems = invoiceItems;
                        }
                    }
                }
                else if (e.Item is GridDataItem)
                {
                    var dataItem = e.Item as GridDataItem;
                    var index = dataItem.DataSetIndex;
                    var items = InvoiceItems;
                    var invoiceItem = items[index];

                    string id = invoiceItem.InvoiceOrderDetailItemID.ToString();

                    invoiceItem.IsRemoved = true;
                    InvoiceItems = items;
                    dataItem.Visible = false;
                    return;
                }
            }
            RebindItemGrid();
        }

        protected void OnApplyCostSheetPriceButtonCLick(object sender, EventArgs e)
        {
            if (InnertextChanged)
            {
                InnertextChanged = false;
                return;
            }
            var gridItems = ItemGrid.Items;
            var en = gridItems.GetEnumerator();
            var invoiceItems = InvoiceItems;
            while (en.MoveNext())
            {
                var gridItem = en.Current as GridDataItem;
                var tb = GetControl<RadNumericTextBox>(gridItem, "FactoryPriceTextBox");
                var id = int.Parse(tb.Attributes["uid"]);

                var toUpdate = invoiceItems.FirstOrDefault(i => i.InvoiceOrderDetailItemID == id);
                if (toUpdate != null)
                {
                    toUpdate.FactoryPrice = toUpdate.OtherCharges = toUpdate.CostSheetPrice.GetValueOrDefault();
                }
            }
            InvoiceItems = invoiceItems;
            RebindItemGrid();
        }

        protected void OnSaveButtonClick(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                using (var connection = GetIndicoConnnection())
                {
                    CreateNewInvoice(connection);
                }
                Response.Redirect("/ViewInvoices.aspx");
            }
        }

        protected void btnCreateInvoice_Click(object sender, EventArgs e)
        {
            if (InvoiceItems == null)
            {
                CustomValidator cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "validateInvoice";
                cv.ErrorMessage = "No Shipment key have been selected";
                Page.Validators.Add(cv);
            }

            if (Page.IsValid)
            {
                using (var connection = GetIndicoConnnection())
                {
                    CreateNewInvoice(connection);
                }

                Response.Redirect("/ViewInvoices.aspx");
            }
        }

        protected void OnOtherChargesTextChanged(object sender, EventArgs e)
        {
            var textBox = sender as RadNumericTextBox;
            var uid = int.Parse(textBox.Attributes["uid"]);

            var items = InvoiceItems;
            var item = items.FirstOrDefault(i => i.InvoiceOrderDetailItemID == uid);

            if (item != null)
            {
                item.OtherCharges = (decimal)textBox.Value.GetValueOrDefault();
                InvoiceItems = items;
            }

            InnertextChanged = true;
        }

        protected void OnFactoryPriceTextChanged(object sender, EventArgs e)
        {
            var textBox = sender as RadNumericTextBox;
            var uid = int.Parse(textBox.Attributes["uid"]);

            var items = InvoiceItems;
            var item = items.FirstOrDefault(i => i.InvoiceOrderDetailItemID == uid);

            if (item != null)
            {
                item.FactoryPrice = (decimal)textBox.Value.GetValueOrDefault();
                InvoiceItems = items;
            }
            InnertextChanged = true;
        }

        protected void OnNotesChanged(object sender, EventArgs e)
        {
            var textBox = sender as RadTextBox;
            var uid = int.Parse(textBox.Attributes["uid"]);

            var items = InvoiceItems;
            var item = items.FirstOrDefault(i => i.InvoiceOrderDetailItemID == uid);

            if (item != null)
            {
                item.FactoryNotes = textBox.Text;
                InvoiceItems = items;
            }
            InnertextChanged = true;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializeUserInterface();
            }
        }

        #endregion

        #region Private functions 

        private void InitializeUserInterface()
        {
            using (var databaseConnection = GetIndicoConnnection())
            {
                if (IsNew)
                    InitializeUserInterfaceForNewInvoice(databaseConnection);
                else
                    InitializeUserInterfaceForExistingInvoice(databaseConnection);
            }
        }

        private void InitializeUserInterfaceForNewInvoice(IDbConnection databaseConnection)
        {
            DisableControl(RadComboShipmentKey);
            EnableOrDisableInvoiceInformationControls(false);
            BindData(WeekComboBox, GetWeeks(databaseConnection));
        }

        private void InitializeUserInterfaceForExistingInvoice(IDbConnection connection)
        {
            var invoice = GetInvoice(connection, CurrentInvoiceId);
            WeekComboBox.Enabled = false;
            //BindData(WeekComboBox, GetWeeks(connection));
            //WeekComboBox.
            txtShipmentDate.Text = invoice.ShipmentDate.ToString("dd MMMM yyyy");
            DisableControl(RadComboShipmentKey);
            txtInvoiceNo.Text = invoice.InvoiceNo;
            txtInvoiceDate.Text = invoice.InvoiceDate.ToString("dd MMMM yyyy");
            txtAwbNo.Text = invoice.AWBNo;

            LoadBillToAndShipTo(connection);
            LoadBanks(connection);
            LoadShipmentModes(connection);
            LoadStatus(connection);
            LoadPorts(connection);
            LoadItems(connection, invoice.ID);

            ShipToDropDownList.Items.FindByValue(invoice.ShipTo.ToString()).Selected = true;
            BillToDropDownList.Items.FindByValue(invoice.BillTo.ToString()).Selected = true;
            BankDropDownList.Items.FindByValue(invoice.Bank.ToString()).Selected = true;
            ShipmentModeDropDownList.Items.FindByValue(invoice.ShipmentMode.ToString()).Selected = true;
            //PortDropDownList.Items.FindByValue(invoice..ToString()).Selected = true;
            StatusDropDownList.Items.FindByValue(invoice.Status.ToString()).Selected = true;
        }

        private void EnableOrDisableInvoiceInformationControls(bool status)
        {
            var controls = new WebControl[] { txtInvoiceDate, txtInvoiceNo, txtAwbNo, txtAwbNo, ShipToDropDownList, BillToDropDownList, BankDropDownList, ShipmentModeDropDownList, PortDropDownList, StatusDropDownList, txtShipmentDate, chkChangeOrderDate };
            if (status)
                EnableControl(controls);
            else DisableControl(controls);
        }

        private IEnumerable<ShipmentkeyModel> GetShipmentKeys(IDbConnection connection, int weekId)
        {
            var result = connection.Query<ShipmentkeyModel>(string.Format("EXEC [dbo].[SPC_GetShipmentKeys] {0}", weekId));
            ShipmentKeys = result.ToList();
            return result;
        }

        public static IEnumerable<WeekNoWeekendDateModel> GetWeeks(IDbConnection connection)
        {
            const string query =
                @"SELECT * FROM [dbo].WeeklyProductionCapacity WHERE WeekendDate <= DATEADD(MONTH ,1 , GETDATE()) AND DATEPART(yyyy, WeekendDate) >= {0} ORDER BY DATEPART(yyyy, WeekendDate) , WeekNo ";
            return connection.Query<WeekNoWeekendDateModel>(string.Format(query, DateTime.Now.Year));
        }

        private static IEnumerable<TextValueModel> GetAddresses(IDbConnection connection)
        {
            return connection.Query<TextValueModel>(
                string.Format(@"SELECT dca.CompanyName + ' ' +  dca.[Address] + ' ' + dca.PostCode + ' ' +  dca.Suburb + ' ' + dca.[State] + dca.Country AS Text, dca.ID AS Value
	                FROM [dbo].[DistributorClientAddressDetailsView] dca"));
        }

        private void LoadBillToAndShipTo(IDbConnection connection)
        {
            var addresses = GetAddresses(connection).ToList();
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


        private int CreateInvoice(IDbConnection connection, int weeklyProductionCapacity, int shipTo, int destinationPort, string weekEndDate, string etd, int priceTerm, int shipmentMode)
        {
            var query =
                 string.Format(@"
                      EXEC [dbo].[SPC_CreateInvoice]
                      @WeeklyProductionCapacity = {0}, @DistributorClientAddress = {1}, @Port = '{2}', @WeekEndDate = '{3}', @ShipmentDate = '{4}', @PaymentMethod = {5}, @ShipmentMode = {6}, @Creator = {7}",
                        weeklyProductionCapacity, shipTo, destinationPort, weekEndDate, etd, priceTerm, shipmentMode, LoggedUser.ID);

            int invoiceId = int.Parse(connection.Query<int>(query).ToList()[0].ToString());

            return invoiceId;
        }

        private void LoadInvoice(IDbConnection connection, int invoiceId)
        {
            var query =
                 string.Format(@"
                      EXEC [dbo].[SPC_GetInvoiceOrderDetailItemsForEdit]
                      @InvoiceId = {0}",
                        invoiceId);

            var invoiceItems = connection.Query<NewShipmentOrderDetailSizeQtyViewModel>(query).ToList();
            invoiceItems.ForEach(i => i.IsChanged = false);
            InvoiceItems = invoiceItems;
            BindData(ItemGrid, invoiceItems);
        }

        private void LoadItems(IDbConnection connection, int invoiceid)
        {
            var query =
                 string.Format(@"
                      EXEC [dbo].[SPC_GetInvoiceOrderDetailItemsForEdit]
                      @InvoiceId = {0}",invoiceid);

            var items = connection.Query<NewShipmentOrderDetailSizeQtyViewModel>(query).ToList();
            items.ForEach(i => i.IsChanged = false);
            InvoiceItems = items;
            BindData(ItemGrid, items);
        }

        private void RemoveItemInGrid(IDbConnection connection, string id)
        {
            var query = string.Format(@" UPDATE [dbo].[InvoiceOrderDetailItem] SET [IsRemoved] = 1 WHERE [ID] = " + id + "");
            connection.Execute(query);
        }

        private void RebindItemGrid()
        {
            BindData(ItemGrid, InvoiceItems);
        }

        private void CreateNewInvoice(IDbConnection connection)
        {
            var invoice = InvoiceItems.First().Invoice;
            const string updateScript =
                @"
                    UPDATE [dbo].[Invoice]
                       SET [InvoiceNo] = '{1}'
                          ,[AWBNo] = '{2}'
                          ,[Modifier] = {3}
                          ,[ModifiedDate] = '{4}'
                          ,[Status] = {5}
                          ,[BillTo] = {6}
                          ,[IsBillTo] = {7}
                          ,[Bank] = {8}
                          ,[InvoiceDate] = '{9}'
                     WHERE ID = {0}";

            connection.Execute(string.Format(updateScript, invoice,
                txtInvoiceNo.Text, txtAwbNo.Text, LoggedUserRole.ID, DateTime.Now.GetSQLDateString(),
                Convert.ToInt32(StatusDropDownList.SelectedItem.Value), Convert.ToInt32(BillToDropDownList.SelectedItem.Value), 1, Convert.ToInt32(BankDropDownList.SelectedItem.Value), txtInvoiceDate.Text));

            var invoiceItems = InvoiceItems;


            var itemsToUpdate = invoiceItems.Where(i => i.IsChanged).ToList();


            if (itemsToUpdate.Count > 0)
            {
                var updateBuilder = new StringBuilder();
                foreach (var item in itemsToUpdate)
                {

                    var baseScript =
                        string.Format(@"
                        UPDATE [dbo].[InvoiceOrderDetailItem]
                            SET [OtherCharges] = {0},
                            [FactoryPrice] = {1}
                            WHERE ID = {2}", item.OtherCharges, item.FactoryPrice, item.InvoiceOrderDetailItemID);
                    updateBuilder.AppendLine(baseScript);
                }

                connection.Execute(updateBuilder.ToString());
            }
        }

        private InvoiceModel GetInvoice(IDbConnection connection, int id)
        {
            return connection.Query<InvoiceModel>("SELECT * FROM [dbo].[Invoice] WHERE ID = " + id).FirstOrDefault();
        }

        #endregion
    }
}