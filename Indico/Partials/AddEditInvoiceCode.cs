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
using DB = Indico.Providers.Data.DapperProvider;

// ReSharper disable once CheckNamespace
namespace Indico
{
    public partial class AddEditInvoice
    {
        public enum InvoiceType
        {
            Factory = 1 ,
            Indiman = 2
        }

        #region Fields

        private string _invoiceTypeParameter;
        private int _currentInvoiceId;
        private InvoiceModel _currentInvoice;

        #endregion

        #region Properties

        private int CurrentInvoiceId
        {
            get
            {
                _currentInvoiceId = 0;
                if (Request.QueryString["id"] != null)
                {
                    _currentInvoiceId = Convert.ToInt32(Request.QueryString["id"]);
                }
                return _currentInvoiceId;
            }
        }

        private InvoiceModel CurrentInvoice
        {
            get
            {
                if (CurrentInvoiceId < 1)
                    return null;
                return _currentInvoice ?? (_currentInvoice = DB.Invoice(CurrentInvoiceId));
            }
        }

        private string InvoiceTypeParameter
        {
            get { return _invoiceTypeParameter ?? (_invoiceTypeParameter = Request.QueryString["type"]); }

        }
        private bool IsNew { get { return CurrentInvoiceId < 1; } }

        private bool InnertextChanged { get { return ((bool?)Session["InnertextChanged"] ?? false); } set { Session["InnertextChanged"] = value; } }

        private List<InvoiceOrderDetailItemModel> InvoiceItems { get { return Session["InvoiceItems"] as List<InvoiceOrderDetailItemModel>; } set { Session["InvoiceItems"] = value; } }

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

        public InvoiceType CurrentInvoiceType { get { return (InvoiceType) Session["CurrentInvoiceType"]; } private set { Session["CurrentInvoiceType"] = value; } }


        #endregion

        #region UI Events

        protected void OnWeekSelectionChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
        {
            var selectedWeekId = Convert.ToInt32(WeekComboBox.SelectedValue);
            if (selectedWeekId < 1)
                return;
            var shipmentKeys = GetShipmentKeys(selectedWeekId);
            BindData(RadComboShipmentKey, shipmentKeys);
            EnableControl(RadComboShipmentKey);
        }

        protected void OnShipmentKeyComboBoxSelectionChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
        {
            var index = RadComboShipmentKey.SelectedIndex;
            if (index < 0)
                return;

            var selectedModel = ShipmentKeys[index];
            if (selectedModel == null)
                return;
            var selectedItem = RadComboShipmentKey.SelectedItem;
            if (selectedItem == null)
                return;

            EnableOrDisableInvoiceInformationControls(true);
            LoadBillToAndShipTo();
            LoadBanks();
            LoadShipmentModes();
            LoadStatus();
            LoadPorts();

            var weeklyCapacityId = int.Parse(WeekComboBox.SelectedItem.Value);
            var obj = new WeeklyProductionCapacityBO {ID = weeklyCapacityId};
            obj.GetObject();

            int invoiceId;

            var objInv = new InvoiceBO {WeeklyProductionCapacity = weeklyCapacityId, ShipTo = selectedModel.ShipToID, ShipmentDate = selectedModel.ShipmentDate};
            // TODO: Add database fields for below two
            //objInv.Port = selectedModel.PortID;
            //objInv.PriceTerm = selectedModel.PriceTermID;
            var lstInvoices = objInv.SearchObjects();

            if (lstInvoices.Count == 0)
            {
                invoiceId = DB.CreateInvoice(weeklyCapacityId, selectedModel.ShipToID, selectedModel.PortID, obj.WeekendDate.Year + obj.WeekendDate.Month.ToString().PadLeft(2, '0') + obj.WeekendDate.Day.ToString().PadLeft(2, '0'),
                    selectedModel.ShipmentDate.GetSQLDateString(), selectedModel.PriceTermID, selectedModel.ShipmentModeID, LoggedUser.ID);
            }
            else
                invoiceId = lstInvoices[0].ID;

            LoadInvoiceItems(invoiceId);
        }

        protected void OnItemGridDataBind(object sender, GridItemEventArgs e)
        {
            var item = e.Item as GridDataItem;
            if (item != null)
            {
                var dataItem = item;

                if ((dataItem.ItemIndex > -1 && dataItem.DataItem is InvoiceOrderDetailItemModel))
                {
                    var modelObject = (InvoiceOrderDetailItemModel)dataItem.DataItem;
                    if (modelObject.IsRemoved)
                    {
                        item.Visible = false;
                        return;
                    }

                    var factoryPriceTextBox = GetControl<RadNumericTextBox>(e.Item, "FactoryPriceTextBox");
                    var otherChargesTextBox = GetControl<RadNumericTextBox>(e.Item, "OtherChargesTextBox");
                    // var notes = GetControl<RadTextBox>(e.Item, "NotesTextArea");
                    factoryPriceTextBox.Attributes["uid"] = otherChargesTextBox.Attributes["uid"] = modelObject.InvoiceOrderDetailItemID.ToString();
                    factoryPriceTextBox.Text = modelObject.FactoryPrice.ToString();
                    otherChargesTextBox.Text = modelObject.OtherCharges.ToString();
                    //notes.Text = modelObject.Notes;
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
            var radButton = e.CommandSource as RadButton;
            if (radButton != null)
            {
                var button = radButton;
                switch (button.ID)
                {
                    case "ApplyOtherChargesButton":
                    {
                        var textBox = GetControl<RadNumericTextBox>(button.Parent, "OtherChargesApplyTextBox");
                        if (textBox.Text != null)
                        {
                            decimal value;
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
                        break;
                    case "ApplyFactoryPriceButton":
                    {
                        var textBox = GetControl<RadNumericTextBox>(button.Parent, "FactoryPriceApplyTextBox");
                        if (textBox.Text != null)
                        {
                            decimal value;
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
                        break;
                    default:
                        var item = e.Item as GridDataItem;
                        if (item != null)
                        {
                            var dataItem = item;
                            var index = dataItem.DataSetIndex;
                            var items = InvoiceItems;
                            var invoiceItem = items[index];

                            var id = invoiceItem.InvoiceOrderDetailItemID.ToString();

                            using (var connection = GetIndicoConnnection())
                            {
                                RemoveItemInGrid(connection, id);
                            }
                            invoiceItem.IsRemoved = true;
                            InvoiceItems = items;
                            dataItem.Visible = false;
                            return;
                        }
                        break;
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
                    switch (CurrentInvoiceType)
                    {
                        case InvoiceType.Factory:
                            toUpdate.FactoryPrice = toUpdate.FactoryCostsheetPrice.GetValueOrDefault();
                            break;
                        case InvoiceType.Indiman:
                            toUpdate.IndimanPrice = toUpdate.IndimanCostsheetPrice.GetValueOrDefault();
                            break;
                    }
                }
            }
            InvoiceItems = invoiceItems;
            RebindItemGrid();
        }

        protected void OnSaveButtonClick(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                Save();
                Response.Redirect("/ViewInvoices.aspx");
            }
        }

        //protected void btnCreateInvoice_Click(object sender, EventArgs e)
        //{
        //    if (InvoiceItems == null)
        //    {
        //        CustomValidator cv = new CustomValidator();
        //        cv.IsValid = false;
        //        cv.ValidationGroup = "validateInvoice";
        //        cv.ErrorMessage = "No Shipment key have been selected";
        //        Page.Validators.Add(cv);
        //    }

        //    if (Page.IsValid)
        //    {
        //        using (var connection = GetIndicoConnnection())
        //        {
        //            CreateNewInvoice(connection);
        //        }

        //        Response.Redirect("/ViewInvoices.aspx");
        //    }
        //}

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

        protected void OnIndimanPriceTextChanged(object sender, EventArgs e)
        {
            var textBox = sender as RadNumericTextBox;
            if (textBox == null)
                return;

            var uid = int.Parse(textBox.Attributes["uid"]);

            var items = InvoiceItems;
            var item = items.FirstOrDefault(i => i.InvoiceOrderDetailItemID == uid);

            if (item != null)
            {
                item.IndimanPrice = (decimal)textBox.Value.GetValueOrDefault();
                InvoiceItems = items;
            }
            InnertextChanged = true;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializeUserInterface();

                var currentInvoice = CurrentInvoice;
                if (currentInvoice == null)
                {
                    switch (InvoiceTypeParameter)
                    {
                        case "i":
                            CurrentInvoiceType = InvoiceType.Indiman;
                            break;
                        case "f":
                            CurrentInvoiceType = InvoiceType.Factory;
                            break;
                        default:
                            throw new Exception("Invoice type not provided");
                    }
                }
                else
                {
                    CurrentInvoiceType = string.IsNullOrWhiteSpace(CurrentInvoice.IndimanInvoiceNo) ? InvoiceType.Indiman
                        : InvoiceType.Factory;
                }

                switch (CurrentInvoiceType)
                {
                    case InvoiceType.Factory:
                        ItemGrid.Columns.FindByUniqueName("IndimanCostsheetPrice").Visible = false;
                        ItemGrid.Columns.FindByUniqueName("IndimanPrice").Visible = false;
                        break;
                    case InvoiceType.Indiman:
                        ItemGrid.Columns.FindByUniqueName("FactoryCostsheetPrice").Visible = false;
                        ItemGrid.Columns.FindByUniqueName("FactoryPrice").Visible = false;
                        break;
                }
            }
        }

        #endregion

        #region Private functions 

        private void InitializeUserInterface()
        {
            if (IsNew)
                InitializeUserInterfaceForNewInvoice();
            else
                InitializeUserInterfaceForExistingInvoice();
        }

        private void InitializeUserInterfaceForNewInvoice()
        {
            DisableControl(RadComboShipmentKey);
            EnableOrDisableInvoiceInformationControls(false);
            BindData(WeekComboBox, DB.GetWeekNames(DateTime.Now.Year));
        }

        private void InitializeUserInterfaceForExistingInvoice()
        {
            var invoice = DB.Invoice(CurrentInvoiceId);
            WeekComboBox.Enabled = false;
            txtShipmentDate.Text = invoice.ShipmentDate.ToString("dd MMMM yyyy");
            DisableControl(RadComboShipmentKey);
            txtInvoiceNo.Text = invoice.InvoiceNo;
            txtInvoiceDate.Text = invoice.InvoiceDate.ToString("dd MMMM yyyy");
            txtAwbNo.Text = invoice.AWBNo;

            LoadBillToAndShipTo();
            LoadBanks();
            LoadShipmentModes();
            LoadStatus();
            LoadPorts();
            LoadItems(invoice.ID);

            ShipToDropDownList.Items.FindByValue(invoice.ShipTo.ToString()).Selected = true;
            BillToDropDownList.Items.FindByValue(invoice.BillTo.ToString()).Selected = true;
            BankDropDownList.Items.FindByValue(invoice.Bank.ToString()).Selected = true;
            ShipmentModeDropDownList.Items.FindByValue(invoice.ShipmentMode.ToString()).Selected = true;
            StatusDropDownList.Items.FindByValue(invoice.Status.ToString()).Selected = true;
        }

        private void EnableOrDisableInvoiceInformationControls(bool status)
        {
            var controls = new WebControl[] { txtInvoiceDate, txtInvoiceNo, txtAwbNo, txtAwbNo, ShipToDropDownList, BillToDropDownList, BankDropDownList, ShipmentModeDropDownList, PortDropDownList, StatusDropDownList, txtShipmentDate, chkChangeOrderDate };
            if (status)
                EnableControl(controls);
            else DisableControl(controls);
        }

        private IEnumerable<ShipmentkeyModel> GetShipmentKeys(int weekId)
        {
            var shipmentkeyModels = DB.ShipmentKeys(weekId);
            ShipmentKeys = shipmentkeyModels.ToList();
            return shipmentkeyModels;
        }
        
        private void LoadBillToAndShipTo()
        {
            var addresses = DB.AllDistributorClientAddressNames().ToList();
            BindData(ShipToDropDownList, addresses);
            BindData(BillToDropDownList, addresses);
        }

        private void LoadBanks()
        {
            var banks = DB.AllBankNames();
            BindData(BankDropDownList, banks);
        }

        private void LoadShipmentModes()
        {
            var shipmentModes = DB.AllShipmentModeNames();
            BindData(ShipmentModeDropDownList, shipmentModes);
        }

        private void LoadStatus()
        {
            var statuses = DB.AllInvoiceStatusNames();
            BindData(StatusDropDownList, statuses);
        }

        private void LoadPorts()
        {
            var ports = DB.AllDestinationPortNames();
            BindData(PortDropDownList, ports);
        }

        private void LoadInvoiceItems(int invoiceId)
        {
            var invoiceItems = DB.InvoiceOrderDetailItemsForInvoice(invoiceId);
            InvoiceItems = invoiceItems;
            RebindItemGrid();
        }

        private void LoadItems(int invoiceid)
        {
            var items = DB.InvoiceOrderDetailItemsForInvoice(invoiceid);
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

        private void Save()
        {
            var invoice = InvoiceItems.First().InvoiceID;

            switch (CurrentInvoiceType)
            {
                case InvoiceType.Factory:
                    DB.UpdateInvoice(invoice, LoggedUser.ID, txtInvoiceNo.Text, txtAwbNo.Text, Convert.ToInt32(StatusDropDownList.SelectedItem.Value), Convert.ToInt32(BillToDropDownList.SelectedItem.Value), Convert.ToInt32(BankDropDownList.SelectedItem.Value), Convert.ToDateTime(txtInvoiceDate.Text).GetSQLDateString());
                    break;
                case InvoiceType.Indiman:
                    DB.UpdateInvoice(invoice, LoggedUser.ID, null, txtAwbNo.Text, Convert.ToInt32(StatusDropDownList.SelectedItem.Value), Convert.ToInt32(BillToDropDownList.SelectedItem.Value),
                        Convert.ToInt32(BankDropDownList.SelectedItem.Value), Convert.ToDateTime(txtInvoiceDate.Text).GetSQLDateString(), txtInvoiceNo.Text);
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
            DB.UpdateChangedInvoiceOrderDetailItemPrices(InvoiceItems);
        }

        #endregion
    }
}