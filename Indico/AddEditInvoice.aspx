<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddEditInvoice.aspx.cs"
    Inherits="Indico.AddEditInvoice" MasterPageFile="~/Indico.Master" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <link href="Content/img/Telerik/ComboBox.Metro.css" rel="stylesheet" />
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <asp:LinkButton ID="btnFactoryDetail" runat="server" CssClass="btn btn-link pull-right" OnClick="btnFactoryDetail_Click" Visible="false"><i class="icon-print"></i>Print Invoice Detail</asp:LinkButton>
                <asp:LinkButton ID="btnInvoiceSummary" runat="server" CssClass="btn btn-link pull-right" OnClick="btnInvoiceSummary_Click" Visible="false"><i class="icon-print"></i>Print Invoice Summary</asp:LinkButton>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    ValidationGroup="validateInvoice" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->
                <legend>Invoice Details</legend>
                <div class="control-group">
                    <label class="control-label">
                        Week
                    </label>
                    <div class="controls">
                        <telerik:RadComboBox ID="WeekComboBox" runat="server" HighlightTemplatedItems="true"
                            Skin="Metro" CssClass="RadComboBox_Metro" DropDownWidth="300" OnItemDataBound="OnWeekDataBound"
                            DataTextField="Text" EmptyMessage="Select a WeekEnd Date" OnSelectedIndexChanged="OnWeekSelectionChanged"
                            AutoPostBack="true" EnableLoadOnDemand="true" Filter="StartsWith" DataValueField="ID">
                            <HeaderTemplate>
                                <table style="width: 300px" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td style="width: 100px;">Week No
                                        </td>
                                        <td style="width: 200px;">ETD
                                        </td>
                                    </tr>
                                </table>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <table style="width: 300px" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td style="width: 100px;">
                                            <asp:Literal ID="litWeekNo" runat="server"></asp:Literal>
                                        </td>
                                        <td style="width: 200px;">
                                            <asp:Literal ID="litETD" runat="server"></asp:Literal>
                                        </td>
                                    </tr>
                                </table>
                            </ItemTemplate>
                        </telerik:RadComboBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Shipment Dates
                    </label>
                    <div class="controls">
                        <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                            <asp:TextBox ID="txtShipmentDate" runat="server"></asp:TextBox>
                            <span class="add-on"><i class="icon-calendar"></i></span>

                        </div>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Shipment Key
                    </label>
                    <asp:Panel ID="ShipmentKeyDropDownPannel" runat="server">
                        <div class="controls">
                            <telerik:RadComboBox ID="RadComboShipmentKey" runat="server" HighlightTemplatedItems="true"
                                AutoPostBack="true" Enabled="true"
                                DropDownWidth="650" OnItemDataBound="RadComboShipmentKey_ItemDataBound" DataTextField="CompanyName"
                                OnSelectedIndexChanged="OnShipmentKeyComboBoxSelectionChanged" EmptyMessage="Select Week Details"
                                EnableLoadOnDemand="true" Filter="StartsWith">
                                <HeaderTemplate>
                                    <table>
                                        <tr>
                                            <th style="width: 200px;">Ship To </th>
                                            <th style="width: 150px;">Port </th>
                                            <th style="width: 200px;">Etd </th>
                                            <th style="width: 150px;">Price Term </th>
                                            <th style="width: 75px;">Qty </th>
                                        </tr>
                                    </table>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <table>
                                        <tr>
                                            <td style="width: 250px;">
                                                <asp:Literal ID="litShipTo" runat="server"></asp:Literal>
                                            </td>
                                            <td style="width: 150px;">
                                                <asp:Literal ID="litDestinationPort" runat="server"></asp:Literal>
                                            </td>
                                            <td style="width: 200px;">
                                                <asp:Literal ID="litETD" runat="server"></asp:Literal>
                                            </td>
                                            <td style="width: 150px;">
                                                <asp:Literal ID="litPriceTerm" runat="server"></asp:Literal>
                                            </td>
                                            <td style="width: 75px;">
                                                <asp:Literal ID="litQty" runat="server"></asp:Literal>
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </telerik:RadComboBox>
                            <asp:Label ID="lblShipmentKeyAddress" runat="server" Visible="true"></asp:Label>
                        </div>
                    </asp:Panel>
                    <asp:Panel ID="ShipmentKeyPannel" runat="server" Visible="false">
                        <div class="controls">
                            <table class="table table-bordered" style="width: auto">
                                <tr>
                                    <th style="width: 200px;">Ship To </th>
                                    <th style="width: 150px;">Port </th>
                                    <th style="width: 200px;">ETD </th>
                                    <th style="width: 150px;">Price Term </th>
                                    <th style="width: 75px;">Qty </th>
                                </tr>
                                <tr>
                                    <td style="width: 250px;">
                                        <asp:Literal ID="litShipToTable" runat="server"></asp:Literal>
                                    </td>
                                    <td style="width: 150px;">
                                        <asp:Literal ID="litDestinationPortTable" runat="server"></asp:Literal>
                                    </td>
                                    <td style="width: 200px;">
                                        <asp:Literal ID="litETDTable" runat="server"></asp:Literal>
                                    </td>
                                    <td style="width: 150px;">
                                        <asp:Literal ID="litPriceTermTable" runat="server"></asp:Literal>
                                    </td>
                                    <td style="width: 75px;">
                                        <asp:Literal ID="litQtyTable" runat="server"></asp:Literal>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </asp:Panel>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Invoice Number
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtInvoiceNo" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvInvoiceNo" runat="server" ErrorMessage="Invoice Number is required"
                            ValidationGroup="validateInvoice" ControlToValidate="txtInvoiceNo" EnableClientScript="false">
                        <img src="Content/img/icon_warning.png"  title="Invoice Number  is required" alt="Invoice Number  is required" />
                        </asp:RequiredFieldValidator>
                        <asp:CustomValidator ID="cfvInvoiceNo" runat="server" ControlToValidate="txtInvoiceNo"
                            ErrorMessage="This invoice number already exists" EnableClientScript="false"
                            OnServerValidate="cfvInvoiceNumber_Validate" ValidationGroup="validateInvoice">
                        <img src="Content/img/icon_warning.png" title="This invoice number already exists"
                            alt="This invoice number already exists" /></asp:CustomValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Invoice Date
                    </label>
                    <div class="controls">
                        <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                            <asp:TextBox ID="txtInvoiceDate" runat="server"></asp:TextBox>
                            <span class="add-on"><i class="icon-calendar"></i></span>

                        </div>
                        <asp:RequiredFieldValidator ID="rfvInvoiceDate" runat="server" ErrorMessage="Invoice Date is required" ValidationGroup="validateInvoice" ControlToValidate="txtInvoiceDate" EnableClientScript="false">
                        <img src="Content/img/icon_warning.png"  title="Invoice Date is required" alt="Invoice Date is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <asp:Panel ID="IndimanInvoiceNoPanel" runat="server">
                    <div class="control-group">
                        <label class="control-label required">
                            Indiman Invoice Number
                        </label>
                        <div class="controls">
                            <asp:TextBox ID="txtIndimanInvoiceNo" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Invoice Number is required"
                                ValidationGroup="validateInvoice" ControlToValidate="txtIndimanInvoiceNo" EnableClientScript="false">
                        <img src="Content/img/icon_warning.png"  title="Invoice Number  is required" alt="Invoice Number  is required" />
                            </asp:RequiredFieldValidator>
                            <asp:CustomValidator ID="CustomValidator1" runat="server" ControlToValidate="txtIndimanInvoiceNo"
                                ErrorMessage="This invoice number already exists" EnableClientScript="false"
                                OnServerValidate="cfvInvoiceNumber_Validate" ValidationGroup="validateInvoice">
                        <img src="Content/img/icon_warning.png" title="This invoice number already exists"
                            alt="This invoice number already exists" /></asp:CustomValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Indiman Invoice Date
                        </label>
                        <div class="controls">
                            <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                <asp:TextBox ID="txtIndimanInvoiceDate" runat="server"></asp:TextBox>
                                <span class="add-on"><i class="icon-calendar"></i></span>

                            </div>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ErrorMessage="Invoice Date is required" ValidationGroup="validateInvoice" ControlToValidate="txtIndimanInvoiceDate" EnableClientScript="false">
                        <img src="Content/img/icon_warning.png"  title="Invoice Date is required" alt="Invoice Date is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                </asp:Panel>
                <div class="control-group">
                    <div class="controls checkbox">
                        <asp:CheckBox ID="chkChangeOrderDate" runat="server" Text="" />Is Change Shipment Date
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Awb No
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtAwbNo" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Ship To
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ShipToDropDownList" runat="server" DataTextField="Text" DataValueField="Value"></asp:DropDownList>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">
                        Bill To
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="BillToDropDownList" runat="server" DataValueField="Value" DataTextField="Text" CssClass="form-control"></asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Bank
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="BankDropDownList" runat="server" DataValueField="Value" DataTextField="Text"></asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvBank" runat="server" ErrorMessage="Bank is required" InitialValue="0"
                            ValidationGroup="validateInvoice" ControlToValidate="BankDropDownList" EnableClientScript="false">
                        <img src="Content/img/icon_warning.png"  title="Bank is required" alt="Bank is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Mode
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ShipmentModeDropDownList" runat="server" DataValueField="Value" DataTextField="Text"></asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Port
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="PortDropDownList" runat="server" DataValueField="Value" DataTextField="Text"></asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Status
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="StatusDropDownList" runat="server" DataValueField="Value" DataTextField="Text"></asp:DropDownList>
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Status is required" InitialValue="0" ValidationGroup="validateInvoice" ControlToValidate="StatusDropDownList" EnableClientScript="false">
                        <img src="Content/img/icon_warning.png"  title="Status is required" alt="Status is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <asp:Panel ID="ItemsPanel" runat="server" Visible="false">
                    <h4>Items
                    <telerik:RadButton runat="server" CssClass="pull-right" ID="CostSheetButton" OnClick="OnApplyCostSheetPriceButtonCLick" Text="Apply Cost Sheet Price"></telerik:RadButton>
                    </h4>
                    <div id="dvNewContent" runat="server">
                        <telerik:RadGrid ID="ItemGrid" runat="server" AllowPaging="True" AllowFilteringByColumn="true"
                            ShowFooter="true" AutoGenerateColumns="false" OnItemDataBound="OnItemGridDataBind"
                            Skin="Metro" CssClass="RadGrid_Rounded" AllowSorting="true" EnableEmbeddedSkins="true"
                            OnItemCommand="OnItemGridItemCommand" PageSize="50" OnPageIndexChanged="OnIemtGridPageIndexChanged" OnPageSizeChanged="OnItemGridPageSizeChanged">
                            <GroupingSettings CaseSensitive="false" />
                            <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                            <MasterTableView AllowFilteringByColumn="true" TableLayout="Auto">
                                <Columns>
                                    <telerik:GridBoundColumn UniqueName="PurchaseOrderNumber" SortExpression="PurchaseOrderNumber" HeaderText="Purchase Order" FilterControlWidth="40px" DataField="PurchaseOrder"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="OrderType" SortExpression="OrderType" HeaderText="Order Type" CurrentFilterFunction="Contains" FilterControlWidth="75px" AutoPostBackOnFilter="true" DataField="OrderType">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="VisualLayout" SortExpression="VisualLayout"
                                        FilterControlWidth="75px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                        HeaderText="Visual Layout" DataField="VisualLayout" Aggregate="Count" FooterText="Total Visual Layouts: ">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="Distributor" SortExpression="Distributor" HeaderText="Distributor"
                                        FilterControlWidth="75px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                        DataField="Distributor">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="Client" SortExpression="Client" HeaderText="Client"
                                        FilterControlWidth="120px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                        DataField="Client">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="Pattern" SortExpression="Pattern" HeaderText="Pattern"
                                        FilterControlWidth="110px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                        DataField="Pattern">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="Fabric" SortExpression="Fabric" HeaderText="Fabric"
                                        FilterControlWidth="75px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                        DataField="Fabric">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="Gender" SortExpression="Gender" HeaderText="Gender"
                                        FilterControlWidth="75px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                        DataField="Gender">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="AgeGroup" SortExpression="AgeGroup" HeaderText="AgeGroup" FilterControlWidth="75px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                        DataField="AgeGroup">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="Qty" SortExpression="Qty" HeaderText="Qty" FilterControlWidth="75px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                        DataField="Qty" ItemStyle-HorizontalAlign="Right" Aggregate="Sum" FooterAggregateFormatString="Grand Units: {0:F2}">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="FactoryCostsheetPrice" SortExpression="FactoryCostsheetPrice" HeaderText="Cost Sheet Price" FilterControlWidth="75px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true" DataField="FactoryCostsheetPrice" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:C}"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="IndimanCostsheetPrice" SortExpression="IndimanCostsheetPrice" HeaderText="Cost Sheet Price" FilterControlWidth="75px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true" DataField="IndimanCostsheetPrice" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:C}"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="FactoryPriceForIndiman" SortExpression="FactoryPriceForIndiman" HeaderText="FactoryPrice" FilterControlWidth="75px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" DataField="FactoryPrice" Visible="false" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:C}"></telerik:GridBoundColumn>
                                    <telerik:GridTemplateColumn AllowFiltering="false" FilterControlWidth="200px" UniqueName="OtherCharges">
                                        <HeaderTemplate>
                                            <asp:Label runat="server" Text="Other Charges"></asp:Label>
                                            <br />
                                            <telerik:RadNumericTextBox runat="server" ID="OtherChargesApplyTextBox" CssClass="otherChargesTextBox" Width="50px">
                                            </telerik:RadNumericTextBox>
                                            <telerik:RadButton runat="server" ID="ApplyOtherChargesButton" Text="Apply"></telerik:RadButton>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <telerik:RadNumericTextBox runat="server" ID="OtherChargesTextBox" OnTextChanged="OnOtherChargesTextChanged" Type="Currency" Width="50px" DataFormatString="{0:C}"></telerik:RadNumericTextBox>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn AllowFiltering="false" FilterControlWidth="200px" UniqueName="FactoryPrice">
                                        <HeaderTemplate>
                                            <asp:Label runat="server" Text="Factory Price"></asp:Label>
                                            <br />
                                            <telerik:RadNumericTextBox runat="server" ID="FactoryPriceApplyTextBox" Width="50px">
                                            </telerik:RadNumericTextBox>
                                            <telerik:RadButton runat="server" ID="ApplyFactoryPriceButton" Text="Apply"></telerik:RadButton>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <telerik:RadNumericTextBox runat="server" ID="FactoryPriceTextBox" CssClass="factoryprice" OnTextChanged="OnFactoryPriceTextChanged" Type="Currency" Width="50px"></telerik:RadNumericTextBox>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>

                                    <telerik:GridTemplateColumn AllowFiltering="false" FilterControlWidth="200px" UniqueName="IndimanPrice">
                                        <HeaderTemplate>
                                            <asp:Label runat="server" Text="Indiman Price"></asp:Label>
                                            <br />
                                            <telerik:RadNumericTextBox runat="server" ID="IndimanPriceApplyTextBox" Width="50px">
                                            </telerik:RadNumericTextBox>
                                            <telerik:RadButton runat="server" ID="ApplyIndimanPriceButton" Text="Apply"></telerik:RadButton>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <telerik:RadNumericTextBox runat="server" ID="IndimanPriceTextBox" OnTextChanged="OnIndimanPriceTextChanged" Type="Currency" Width="50px"></telerik:RadNumericTextBox>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridBoundColumn UniqueName="TotalPrice" SortExpression="TotalPrice" HeaderText="Total Price" FilterControlWidth="75px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true" DataField="Total" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:C}"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="Amount" SortExpression="Amount" HeaderText="Amount" FilterControlWidth="75px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true" DataField="Amount" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:C}" Aggregate="Sum" FooterAggregateFormatString="Grand Total: {0:F2}"></telerik:GridBoundColumn>
                                    <%--<telerik:GridBoundColumn UniqueName="Notes" SortExpression="Notes" HeaderText="Notes" FilterControlWidth="75px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true" DataField="Notes"></telerik:GridBoundColumn>--%>
                                    <telerik:GridTemplateColumn AllowFiltering="false" FilterControlWidth="200px" UniqueName="IndimanNotes">
                                        <HeaderTemplate>
                                            <asp:Label runat="server" Text="Notes"></asp:Label>
                                            <br />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <telerik:RadTextBox runat="server" ID="IndimanNotesTextBox" OnTextChanged="OnIndimanNotesTextChanged" Width="100px"></telerik:RadTextBox>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn AllowFiltering="false" FilterControlWidth="200px" UniqueName="FactoryNotes">
                                        <HeaderTemplate>
                                            <asp:Label runat="server" Text="Notes"></asp:Label>
                                            <br />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <telerik:RadTextBox runat="server" ID="FactoryNotesTextBox" OnTextChanged="OnFactoryNotesTextChanged" Width="100px"></telerik:RadTextBox>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn AllowFiltering="false" FilterControlWidth="200px" UniqueName="Remove">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete this item"><i class="icon-trash"></i>Delete</asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                </Columns>
                            </MasterTableView>
                        </telerik:RadGrid>
                        <!-- / -->
                    </div>
                    <div class="form-actions">
                        <button id="btnCreateInvoice" runat="server" class="btn btn-primary" validationgroup="validateInvoice"
                            data-loading-text="Saving..." type="submit" onserverclick="OnSaveButtonClick">
                            Save Changes</button>
                    </div>
                </asp:Panel>
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <div id="requestRemove" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Remove Invoice Item</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to remove this invoice item?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" onserverclick="btnDelete_Click"
                type="submit" data-loading-text="Deleting...">
                Yes</button>
        </div>
    </div>
    <!-- Shiping Address Details-->
    <div id="dvSipmentAddress" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Shipping Address Details</h3>
        </div>
        <div class="modal-body">
            <!-- Validation-->
            <asp:ValidationSummary ID="validateShiipingAddress" runat="server" CssClass="alert alert-danger"
                ValidationGroup="validShiipingAddress" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <fieldset>
                <div class="control-group">
                    <label class="control-label required">
                        Company Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCOmpanyName" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvCompanyName" runat="server" CssClass="error" ValidationGroup="validShiipingAddress"
                            ControlToValidate="txtCOmpanyName" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Company Name is required">
                                <img src="Content/img/icon_warning.png" title="Company Name is required" alt="Company Name is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Address</label>
                    <div class="controls">
                        <asp:TextBox ID="txtShipToAddress" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvAddress" runat="server" CssClass="error" ValidationGroup="validShiipingAddress"
                            ControlToValidate="txtShipToAddress" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Address is required">
                                <img src="Content/img/icon_warning.png" title="Address is required" alt="Address is required" />
                        </asp:RequiredFieldValidator>
                        <p class="text-info">
                            Street Address required. PO Box not acceptable
                        </p>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Suburb</label>
                    <div class="controls">
                        <asp:TextBox ID="txtSuburbCity" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvSuburb" runat="server" CssClass="error" ValidationGroup="validShiipingAddress"
                            ControlToValidate="txtSuburbCity" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Suburb is required">
                                <img src="Content/img/icon_warning.png" title="Suburb is required" alt="Suburb is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        State</label>
                    <div class="controls">
                        <asp:TextBox ID="txtShipToState" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvShipToState" runat="server" CssClass="error" ValidationGroup="validShiipingAddress"
                            ControlToValidate="txtShipToState" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="State is required">
                                <img src="Content/img/icon_warning.png" title="State is required" alt="State is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Post Code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtShipToPostCode" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvPostCode" runat="server" CssClass="error" ValidationGroup="validShiipingAddress"
                            ControlToValidate="txtShipToPostCode" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Post Code is required">
                                <img src="Content/img/icon_warning.png" title="Post Code is required" alt="Post Code is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Country</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlShipToCountry" runat="server">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvCountry" runat="server" CssClass="error" ValidationGroup="validShiipingAddress"
                            InitialValue="0" ControlToValidate="ddlShipToCountry" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Country is required">
                                <img src="Content/img/icon_warning.png" title="Country is required" alt="Country is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Phone Number</label>
                    <div class="controls">
                        <asp:TextBox ID="txtShipToPhone" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvPhone" runat="server" CssClass="error" ValidationGroup="validShiipingAddress"
                            ControlToValidate="txtShipToPhone" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Phone is required">
                                <img src="Content/img/icon_warning.png" title="Phone is required" alt="Phone is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Contact Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtShipToContactName" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvContactName" runat="server" CssClass="error" ValidationGroup="validShiipingAddress"
                            ControlToValidate="txtShipToContactName" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Contact Name is required">
                                <img src="Content/img/icon_warning.png" title="Contact Name is required" alt="Contact Name is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Port</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlShipToPort" runat="server"></asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvPort" runat="server" CssClass="error" ValidationGroup="validShiipingAddress" InitialValue="0"
                            ControlToValidate="ddlShipToPort" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Port is required">
                                <img src="Content/img/icon_warning.png" title="Port is required" alt="Port is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Distributor</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlDistributor" runat="server"></asp:DropDownList>
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" CssClass="error" ValidationGroup="validShiipingAddress" InitialValue="0"
                            ControlToValidate="ddlDistributor" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Distributor is required">
                                <img src="Content/img/icon_warning.png" title="Distributor is required" alt="Distributor is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
            </fieldset>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveShippingAddress" runat="server" class="btn btn-primary" type="submit"
                validationgroup="validShiipingAddress" data-loading-text="Saving..." onserverclick="btnSaveShippingAddress_ServerClick">
                Save</button>
        </div>
    </div>
    <!--/-->
    <asp:HiddenField ID="hdnSelectedID" runat="server" />
    <asp:HiddenField ID="hdnIndexID" runat="server" />
    <asp:HiddenField ID="HiddenField1" runat="server" />

<%--    <!-- Date Confirmation-->
    <div id="dvDateConfirmation" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="true" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Invoice Item</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Invoice item?
            </p>
        </div>
        <div class="modal-footer">
            <button data-dismiss="modal" class="btn btn-primary" aria-hidden="true">Confirm</button>
            <asp:Button ID="btnDelete" runat="server" OnClick="btnDelete_Click" Text="Button"/>
        </div>
    </div>
    <!--/-->--%>

    <!-- Page Scripts -->
    <script type="text/javascript">
        var txtInvoiceDate = "<%=txtInvoiceDate.ClientID %>";
        var RadInvoice = "<%=ItemGrid.ClientID %>";
        var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
        var hdnIndexID = "<%=hdnIndexID.ClientID %>";

        var PopulatePrintedOrders = ('<%=ViewState["PopulatePrintedOrders"]%>' == "True") ? true : false;
      
    </script>
    <script type="text/javascript">
        $(document).ready(function () {

            //$(document).ready(function () {
            $('.datepicker').datepicker({
                format: 'dd MM yyyy'
            });
            //});

            $('.iapply').click(function () {
                $('.irate').each(function () {
                    $(this).val($('.imainrate').val());
                });
            });


            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('uid');
                $('#requestRemove').modal('show');
            });


            $('.factoryprice').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('uid');
                alert("Hello! I am an alert box!!");;
            });

            //$('.iremove').click(function () {
            //    $('#' + hdnSelectedID).val($(this).attr('qid'));
            //    $('#' + hdnIndexID).val($(this).attr('indexid'));
            //    $('#' + hdnOrderDetail).val($(this).attr('odid'))
            //    $('#requestRemove').modal('show');

            //});

            $('.irate').keyup(function () {

                var rate = parseFloat($(this).val());
                var qty = parseFloat($(this).parents('tr').children('td').find('span')[0].innerHTML);
                $(this).parents('tr').children('td').find('span')[1].innerHTML = (rate * qty).toFixed(2);

                calculate();

            });

            $('.ishippingAddress').click(function () {
                resetFieldsDefault('requestAddPaymentMethod');
                $('div.alert-danger, span.error').hide();
                $('#dvSipmentAddress').modal('show');
            });

            // populate dvSipmentAddress modal
            if (PopulateShippingAddress) {
                $('#dvSipmentAddress').modal('show');
            }

            function calculate() {
                var footerrate = 0;
                var footeramount = 0;

                $('.irate').each(function () {
                    footerrate = parseFloat(footerrate + parseFloat($(this).val()));
                });

                $('.iamount').each(function () {
                    footeramount = parseFloat(footeramount + parseFloat($(this)[0].innerHTML));
                });

                //$('.ifooterrate')[0].innerHTML = parseFloat(footerrate).toFixed(2);
                $('.ifooteramount')[0].innerHTML = parseFloat(footeramount).toFixed(2);
            }
        });
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            /*  $("input[type=text][id*=txtPricePerUnit]").attr("disabled", true);
            $("input[type=checkbox][id*=chbSelect]").click(function () {
            if (this.checked) {
            $(this).closest("tr").find("input[type=text][id*=txtPricePerUnit]").attr("disabled", false);
            }
            else {
            $(this).closest("tr").find("input[type=text][id*=txtPricePerUnit]").attr("disabled", true);
            }
            });*/
        });
    </script>
    <!-- / -->
</asp:Content>
