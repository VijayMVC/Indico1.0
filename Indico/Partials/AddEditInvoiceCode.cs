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
            Factory = 1,
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

        public InvoiceType CurrentInvoiceType { get { return (InvoiceType)Session["CurrentInvoiceType"]; } private set { Session["CurrentInvoiceType"] = value; } }


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
            this.LoadBillToAndShipTo();
            this.LoadBanks();
            this.LoadShipmentModes();
            this.LoadStatus();
            this.LoadPorts();

            var weeklyCapacityId = int.Parse(WeekComboBox.SelectedItem.Value);
            var obj = new WeeklyProductionCapacityBO { ID = weeklyCapacityId };
            obj.GetObject();

            int invoiceId;
            var invoices = DB.Invoice(weeklyCapacityId, selectedModel.ShipToID, selectedModel.ShipmentDate.GetSQLDateString());
            if (invoices.Count == 0)
            {
                invoiceId = DB.CreateInvoice(weeklyCapacityId, selectedModel.ShipToID, selectedModel.PortID, obj.WeekendDate.Year + obj.WeekendDate.Month.ToString().PadLeft(2, '0') + obj.WeekendDate.Day.ToString().PadLeft(2, '0'),
                    selectedModel.ShipmentDate.GetSQLDateString(), selectedModel.PriceTermID, selectedModel.ShipmentModeID, LoggedUser.ID);
            }
            else
                invoiceId = invoices[0].ID;
            if (invoiceId != 0)
            {
                btnCreateInvoice.Visible = true;
                dvNewContent.Visible = true;
                CostSheetButton.Visible = true;
                ItemsPanel.Visible = true;
                this.LoadInvoiceItems(invoiceId);
            }
        }

        protected void OnItemGridDataBind(object sender, GridItemEventArgs e)
        {
            var item = e.Item as GridDataItem;
            //var items = e.Item as Gridcom
            if (item != null)
            {
                var dataItem = item;

                if ((dataItem.ItemIndex > -1 && dataItem.DataItem is InvoiceOrderDetailItemModel))
                {
                    var modelObject = (InvoiceOrderDetailItemModel)dataItem.DataItem;

                    var factoryPriceTextBox = GetControl<RadNumericTextBox>(e.Item, "FactoryPriceTextBox");
                    var otherChargesTextBox = GetControl<RadNumericTextBox>(e.Item, "OtherChargesTextBox");
                    var indimanPriceApplyTextBox = GetControl<RadNumericTextBox>(e.Item, "IndimanPriceTextBox");
                    var linkDelete = GetControl<HyperLink>(e.Item, "linkDelete");
                    var factoryNotesTextBox = GetControl<RadTextBox>(e.Item, "FactoryNotesTextBox");
                    var indimanNotesTextBox = GetControl<RadTextBox>(e.Item, "IndimanNotesTextBox");
                    indimanNotesTextBox.Attributes["uid"] = factoryNotesTextBox.Attributes["uid"] = linkDelete.Attributes["uid"] = indimanPriceApplyTextBox.Attributes["uid"] = factoryPriceTextBox.Attributes["uid"] = otherChargesTextBox.Attributes["uid"] = modelObject.InvoiceOrderDetailItemID.ToString();
                    factoryPriceTextBox.Text = modelObject.FactoryPrice.ToString();
                    otherChargesTextBox.Text = modelObject.OtherCharges.ToString();
                    indimanPriceApplyTextBox.Text = modelObject.IndimanPrice.ToString();
                    factoryNotesTextBox.Text = modelObject.FactoryNotes;
                    indimanNotesTextBox.Text = modelObject.IndimanNotes;
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
                                        {
                                            toUpdate.OtherCharges = value;
                                            if (CurrentInvoiceType == InvoiceType.Factory)
                                            {
                                                toUpdate.Amount = AmountCalculation(toUpdate.FactoryPrice.GetValueOrDefault(), value, toUpdate.Qty.GetValueOrDefault());
                                                //toUpdate.Total = (double)(toUpdate.FactoryPrice + value);
                                                toUpdate.Total = TotalCalculation(toUpdate.FactoryPrice.Value + value);
                                            }
                                            else
                                            {
                                                //toUpdate.Amount = (double)(toUpdate.Qty.GetValueOrDefault() * (toUpdate.IndimanPrice + value));
                                                toUpdate.Amount = AmountCalculation(toUpdate.IndimanPrice.GetValueOrDefault(), value, toUpdate.Qty.GetValueOrDefault());
                                                toUpdate.Total = TotalCalculation(toUpdate.IndimanPrice.GetValueOrDefault() + value);
                                                //toUpdate.Total = (double)(toUpdate.FactoryPrice + value);
                                            }
                                        }

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
                                        {
                                            toUpdate.FactoryPrice = value;
                                            //toUpdate.Amount = (double)(toUpdate.Qty.GetValueOrDefault() * (value + toUpdate.OtherCharges));
                                            //toUpdate.Total = (double)(value + toUpdate.OtherCharges);
                                            toUpdate.Amount = AmountCalculation(value, toUpdate.OtherCharges.GetValueOrDefault(), toUpdate.Qty.GetValueOrDefault());
                                            toUpdate.Total = TotalCalculation(value , toUpdate.OtherCharges.GetValueOrDefault());
                                        }
                                    }
                                    InvoiceItems = invoiceItems;
                                }
                            }
                        }
                        break;
                    case "ApplyIndimanPriceButton":
                        {
                            var textBox = GetControl<RadNumericTextBox>(button.Parent, "IndimanPriceApplyTextBox");
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
                                        var tb = GetControl<RadNumericTextBox>(gridItem, "IndimanPriceTextBox");
                                        var id = int.Parse(tb.Attributes["uid"]);

                                        var toUpdate = invoiceItems.FirstOrDefault(i => i.InvoiceOrderDetailItemID == id);
                                        if (toUpdate != null)
                                        {
                                            toUpdate.IndimanPrice = value;
                                            //toUpdate.Amount = (double)(toUpdate.Qty.GetValueOrDefault() * (value + toUpdate.OtherCharges));
                                            //toUpdate.Total = (double)(value + toUpdate.OtherCharges);
                                            toUpdate.Amount = AmountCalculation(value, toUpdate.OtherCharges.GetValueOrDefault(), toUpdate.Qty.GetValueOrDefault());
                                            toUpdate.Total = TotalCalculation(value, toUpdate.OtherCharges.GetValueOrDefault());
                                        }

                                    }
                                    InvoiceItems = invoiceItems;
                                }
                            }
                        }
                        break;
                    default:
                        //var item = e.Item as GridDataItem;
                        //if (item != null)
                        //{
                        //var dataItem = item;
                        //var index = dataItem.DataSetIndex;
                        //var items = InvoiceItems;
                        //var invoiceItem = items[index];

                        //var id = invoiceItem.InvoiceOrderDetailItemID.ToString();

                        //using (var connection = GetIndicoConnnection())
                        //{
                        //    RemoveItemInGrid(connection, id);
                        //}
                        //invoiceItem.IsRemoved = true;
                        //InvoiceItems = items;
                        //dataItem.Visible = false;
                        //return;
                        //}
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
                if (CurrentInvoiceType == InvoiceType.Factory)
                    Response.Redirect("/ViewInvoices.aspx");
                else if (CurrentInvoiceType == InvoiceType.Indiman)
                    Response.Redirect("/ViewIndimanInvoices.aspx");
            }
        }

        protected void OnFactoryNotesTextChanged(object sender, EventArgs e)
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
            RebindItemGrid();
        }


        protected void OnIndimanNotesTextChanged(object sender, EventArgs e)
        {
            var textBox = sender as RadTextBox;
            var uid = int.Parse(textBox.Attributes["uid"]);

            var items = InvoiceItems;
            var item = items.FirstOrDefault(i => i.InvoiceOrderDetailItemID == uid);

            if (item != null)
            {
                item.IndimanNotes = textBox.Text;
                InvoiceItems = items;
            }
            InnertextChanged = true;
            RebindItemGrid();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int id = int.Parse(this.hdnSelectedID.Value);
            var items = InvoiceItems;
            foreach (InvoiceOrderDetailItemModel od in items)
            {
                if (od.InvoiceOrderDetailItemID == id)
                {
                    items.Remove(od);
                    break;
                }
            }
            using (var connection = GetIndicoConnnection())
            {
                RemoveItemInGrid(connection, id.ToString());
            }
            InvoiceItems = items;
            RebindItemGrid();
            return;
        }

        protected void OnOtherChargesTextChanged(object sender, EventArgs e)
        {
            var textBox = sender as RadNumericTextBox;
            var uid = int.Parse(textBox.Attributes["uid"]);

            var items = InvoiceItems;
            var item = items.FirstOrDefault(i => i.InvoiceOrderDetailItemID == uid);

            if (item != null)
            {
                decimal oldOtherCharges = item.OtherCharges.Value;
                item.OtherCharges = (decimal)textBox.Value.GetValueOrDefault();
                item.Amount = AmountCalculation(item.FactoryPrice.GetValueOrDefault(), item.OtherCharges.GetValueOrDefault(), item.Qty.GetValueOrDefault());
                item.Total = TotalCalculation(item.FactoryPrice.GetValueOrDefault(), item.OtherCharges.GetValueOrDefault());
                InvoiceItems = items;
            }

            InnertextChanged = true;
            RebindItemGrid();
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
                if (item.FactoryPrice != 0)
                {
                    //item.Amount = (double)(Convert.ToDecimal(item.Qty.Value) * (item.FactoryPrice + item.OtherCharges));
                    //item.Total = (double)(item.FactoryPrice + item.OtherCharges);
                    item.Amount = AmountCalculation(item.FactoryPrice.GetValueOrDefault() , item.OtherCharges.GetValueOrDefault(), item.Qty.GetValueOrDefault());
                    item.Total = TotalCalculation(item.FactoryPrice.GetValueOrDefault(), item.OtherCharges.GetValueOrDefault());
                }
                else
                { 
                    //item.Amount = Convert.ToDouble(item.OtherCharges);
                    //item.Total = (double)item.OtherCharges;
                    item.Amount = AmountCalculation(0, item.OtherCharges.GetValueOrDefault(), item.Qty.GetValueOrDefault());
                    item.Total = TotalCalculation(0, item.OtherCharges.GetValueOrDefault());
                }
                InvoiceItems = items;
            }
            InnertextChanged = true;
            RebindItemGrid();
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


                var currentInvoice = CurrentInvoice;
                if (CurrentInvoice == null)
                {
                    CurrentInvoiceType = InvoiceType.Factory;
                }
                else
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
                /* else
                 {
                     CurrentInvoiceType = string.IsNullOrWhiteSpace(CurrentInvoice.IndimanInvoiceNo) ? InvoiceType.Indiman
                         : InvoiceType.Factory;
                 }*/

                switch (CurrentInvoiceType)
                {
                    case InvoiceType.Factory:
                        ItemGrid.Columns.FindByUniqueName("IndimanCostsheetPrice").Visible = false;
                        ItemGrid.Columns.FindByUniqueName("IndimanPrice").Visible = false;
                        ItemGrid.Columns.FindByUniqueName("IndimanNotes").Visible = false;
                        IndimanInvoiceNoPanel.Visible = false;
                        break;
                    case InvoiceType.Indiman:
                        ItemGrid.Columns.FindByUniqueName("FactoryCostsheetPrice").Visible = false;
                        ItemGrid.Columns.FindByUniqueName("FactoryPrice").Visible = false;
                        ItemGrid.Columns.FindByUniqueName("FactoryPriceForIndiman").Visible = true;
                        ItemGrid.Columns.FindByUniqueName("FactoryNotes").Visible = false;
                        break;
                    default:
                        break;
                }
                this.InitializeUserInterface();
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
            this.EnableOrDisableInvoiceInformationControls(false);
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
            ShipmentKeyDropDownPannel.Visible = false;
            ShipmentKeyDropDownPannel.Visible = false;
            ShipmentKeyPannel.Visible = true;

            if (CurrentInvoiceType == InvoiceType.Indiman)
            {
                txtIndimanInvoiceNo.Text = invoice.IndimanInvoiceNo;
                txtInvoiceNo.Enabled = false;
                txtIndimanInvoiceDate.Text = DateTime.Now.ToString("dd MMMM yyyy");
                txtInvoiceDate.Enabled = false;
            }

            this.LoadBillToAndShipTo();
            this.LoadBanks();
            this.LoadShipmentModes();
            this.GetShipmentkey(invoice.ShipTo.Value, invoice.ShipmentMode, invoice.Port, invoice.ShipmentDate, invoice.PriceTerm, invoice.WeeklyProductionCapacity);
            this.GetWeek(invoice.WeeklyProductionCapacity, DateTime.Now.Year);
            this.LoadStatus();
            this.LoadPorts();
            //*SDS this.LoadItems(invoice.ID);

            btnCreateInvoice.Visible = true;
            dvNewContent.Visible = true;
            CostSheetButton.Visible = true;
            ItemsPanel.Visible = true;
            this.LoadInvoiceItems(invoice.ID);


            //RadComboShipmentKey.Items.FindItemByValue(DB.ShipmentKeys).Selected = true;
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
            {
                EnableControl(controls);
                txtInvoiceDate.Text = DateTime.Now.ToString("dd MMMM yyyy");
            }
            else DisableControl(controls);
        }

        private IEnumerable<ShipmentkeyModel> GetShipmentKeys(int weekId)
        {
            var shipmentkeyModels = DB.ShipmentKeys(weekId);
            ShipmentKeys = shipmentkeyModels.ToList();
            return shipmentkeyModels;
        }

        private void GetShipmentkey(int ShipTo, int ShipmentModeID, int Port, DateTime ShipmentDate, int PriceTerm, int WeeklyProductionCapacity)
        {
            List<ShipmentkeyModel> shipmentkeyModels = DB.ShipmentKeys(WeeklyProductionCapacity);
            var shipmentkey = shipmentkeyModels.Where(o => o.ShipTo == ShipTo && o.ShipmentModeID == ShipmentModeID && o.PortID == Port && o.ShipmentDate == ShipmentDate && o.PriceTermID == PriceTerm).FirstOrDefault();
            litShipToTable.Text = shipmentkey.CompanyName;
            litDestinationPortTable.Text = shipmentkey.DestinationPort;
            litETDTable.Text = shipmentkey.ShipmentDate.ToString("dd MMMM yyyy");
            litPriceTermTable.Text = shipmentkey.PriceTerm;
            litQtyTable.Text = shipmentkey.Qty.ToString();
        }

        private void GetWeek(int id, int year)
        {
            WeeklyProductionCapacityBO objWeeklyProduntionCapacity = new WeeklyProductionCapacityBO();
            objWeeklyProduntionCapacity.ID = id;
            objWeeklyProduntionCapacity.GetObject();

            WeekComboBox.Text = year + "/" + objWeeklyProduntionCapacity.WeekNo.ToString();
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
            List<InvoiceOrderDetailItemModel> invoiceItems = new List<InvoiceOrderDetailItemModel>();
            if (CurrentInvoiceType == InvoiceType.Factory)
            {
                invoiceItems = DB.InvoiceOrderDetailItemsForInvoice(invoiceId);
            }
            else if (CurrentInvoiceType == InvoiceType.Indiman)
            {
                invoiceItems = DB.InvoiceOrderDetailItemsForInvoice(invoiceId, true);
            }
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
                    DB.UpdateInvoice(invoice, LoggedUser.ID, null, txtAwbNo.Text, Convert.ToInt32(StatusDropDownList.SelectedItem.Value), Convert.ToInt32(BillToDropDownList.SelectedItem.Value), Convert.ToInt32(BankDropDownList.SelectedItem.Value), Convert.ToDateTime(txtInvoiceDate.Text).GetSQLDateString(), txtIndimanInvoiceNo.Text, txtIndimanInvoiceDate.Text);
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
            DB.UpdateChangedInvoiceOrderDetailItemPrices(InvoiceItems);
        }

        public double AmountCalculation(decimal factoryPrice = 0, decimal otherCharges = 0, int qty = 0)
        {
            return Convert.ToDouble(qty * (factoryPrice + otherCharges));
        }

        public double TotalCalculation(decimal factoryPrice = 0, decimal otherCharges = 0)
        {
            return Convert.ToDouble(factoryPrice + otherCharges);
        }

        #endregion
    }
}

