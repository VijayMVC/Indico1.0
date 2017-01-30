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
                        <telerik:RadComboBox ID="RadComboWeek" runat="server" HighlightTemplatedItems="true"
                            Skin="Metro" CssClass="RadComboBox_Metro" DropDownWidth="300" OnItemDataBound="RadComboWeek_ItemDataBound"
                            DataTextField="weeknoyear" EmptyMessage="Select a WeekEnd Date" OnSelectedIndexChanged="RadComboWeek_SelectedIndexChanged"
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
                        <span class="text-error" id="spanShipmentError" runat="server">All Invoices have been
                            created for all shipments for this Week</span>
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
                    <div class="controls">
                        <telerik:RadComboBox ID="RadComboShipmentKey" runat="server" HighlightTemplatedItems="true"
                            Skin="Metro" CssClass="RadComboBox_Metro" AutoPostBack="true" Enabled="true"
                            DropDownWidth="650" OnItemDataBound="RadComboShipmentKey_ItemDataBound" DataTextField="CompanyName"
                            OnSelectedIndexChanged="RadComboShipmentKey_SelectedIndexChanged" EmptyMessage="Select Week Details"
                            EnableLoadOnDemand="true" Filter="StartsWith">
                            <HeaderTemplate>
                                <table style="width: 500px" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td style="width: 200px;">Ship To
                                        </td>
                                        <td style="width: 75px;">Port
                                        </td>
                                        <td style="width: 150px;">ETD
                                        </td>
                                        <td style="width: 50px;">Price Term
                                        </td>
                                        
                                    </tr>
                                </table>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <table style="width: 500px" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td style="width: 200px;">
                                            <asp:Literal ID="litShipTo" runat="server"></asp:Literal>
                                        </td>
                                        <td style="width: 75px;">
                                            <asp:Literal ID="litWeek" runat="server"></asp:Literal>
                                        </td>
                                        <td style="width: 150px;">
                                            <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        </td>
                                        <td style="width: 50px;">
                                            <asp:Literal ID="litMode" runat="server"></asp:Literal>
                                        </td>
                                        <td style="width: 25px;">
                                            <asp:Literal ID="litQty" runat="server"></asp:Literal>
                                        </td>
                                    </tr>
                                </table>
                            </ItemTemplate>
                        </telerik:RadComboBox>
                        <asp:Label ID="lblShipmentKeyAddress" runat="server" Visible="true"></asp:Label>
                    </div>
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
                        
                  <asp:DropDownList ID="ddlShipTo" runat="server"></asp:DropDownList>

                    </div>
                </div>
                <div class="control-group">
                    <div class="controls checkbox">
                        <asp:CheckBox ID="chkIsBillTo" runat="server" Text="" />Is Bill To
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Bill To
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlBillTo" runat="server" DataValueField="Id" DataTextField="Address"></asp:DropDownList>
                        <a id="aShippingAddressCourier" runat="server" class="btn btn-link ishippingAddress" title="Add New Bill To Address Details"><i class="icon-plus"></i></a>
                        <asp:CustomValidator ID="cvBillTo" runat="server" ControlToValidate="ddlBillTo" ErrorMessage="Bill To Is Required" EnableClientScript="false"
                            OnServerValidate="cvBillTo_ServerValidate" ValidationGroup="validateInvoice">
                        <img src="Content/img/icon_warning.png" title="Bill To Is Required" alt="Bill To Is Required" />
                        </asp:CustomValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Bank
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlBank" runat="server" DataValueField="ID" DataTextField="Name"></asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvBank" runat="server" ErrorMessage="Bank is required" InitialValue="0"
                            ValidationGroup="validateInvoice" ControlToValidate="ddlBank" EnableClientScript="false">
                        <img src="Content/img/icon_warning.png"  title="Bank is required" alt="Bank is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Mode
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlMode" runat="server" DataTextField="Name" DataValueField="ID" ></asp:DropDownList>
                    </div>
                </div>
                 <div class="control-group">
                    <label class="control-label">
                        Port
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlport" runat="server" DataTextField="Name" DataValueField="ID" ></asp:DropDownList>
                    </div>
                </div>



                <div class="control-group">
                    <label class="control-label">
                        Status
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlStatus" runat="server" DataTextField="Name" DataValueField="ID"></asp:DropDownList>
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Status is required" InitialValue="0" ValidationGroup="validateInvoice" ControlToValidate="ddlStatus" EnableClientScript="false">
                        <img src="Content/img/icon_warning.png"  title="Status is required" alt="Status is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <%-- </fieldset>--%>
                <!-- Search Printed Orders -->
                <!-- / -->
                <%--<fieldset>--%>
                <%--  select orders--%>
                <!-- Not Existing Orders-->
                <legend>Not Existing Orders</legend>
                <asp:DataGrid ID="dgNotExistingInvoiceOrders" runat="server" CssClass="table" AllowCustomPaging="False" PageSize="20"
                    AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                    OnItemDataBound="dgNotExistingInvoiceOrders_ItemDataBound">
                    <HeaderStyle CssClass="header" />
                    <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                    <Columns>
                        <asp:BoundColumn HeaderText="Order No." DataField="Order"></asp:BoundColumn>
                        <asp:BoundColumn HeaderText="Order Type" DataField="OrderType"></asp:BoundColumn>
                        <asp:BoundColumn HeaderText="Visual Layout" DataField="VisualLayout"></asp:BoundColumn>
                        <asp:BoundColumn HeaderText="Distributor" DataField="Distributor"></asp:BoundColumn>
                        <asp:BoundColumn HeaderText="Client" DataField="Client"></asp:BoundColumn>
                        <asp:BoundColumn HeaderText="Pattern" DataField="Pattern"></asp:BoundColumn>
                        <asp:BoundColumn HeaderText="Fabric" DataField="Fabric"></asp:BoundColumn>
                        <asp:BoundColumn HeaderText="Gender" DataField="Gender"></asp:BoundColumn>
                        <asp:BoundColumn HeaderText="AgeGroup" DataField="AgeGroup"></asp:BoundColumn>
                        <asp:TemplateColumn HeaderText="Qty">
                            <ItemTemplate>
                                <asp:Literal ID="litQty" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Add">
                            <ItemTemplate>
                                <asp:LinkButton ID="lbAdd" OnClick="lbAdd_Click" runat="server"><i class="icon-plus"></i>Add</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                    </Columns>
                </asp:DataGrid>
                <!-- Empty Content -->
                <div id="dvEmptyNotExistingOrders" runat="server" class="alert alert-info">
                    <h4>
                        <asp:Literal ID="litMeassage" runat="server"></asp:Literal></h4>
                </div>
                <!-- / -->
                <!--/-->
                <legend>Orders</legend>
                <div id="dvNewContent" runat="server">
                    <!-- Data grid -->
                    <%--<telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro"
                        EnableEmbeddedSkins="true">
                    </telerik:RadAjaxLoadingPanel>
                    <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadInvoice">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadInvoice"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <div id="dvFactoryRate" runat="server" class="control-group pull-right">
                        <label class="control-label">
                            Factory Rate
                        </label>
                        <div class="controls">
                            <asp:TextBox ID="txtFactoryCost" CssClass="input-small" runat="server"></asp:TextBox>
                            <button id="btnChangeCost" type="submit" onserverclick="btnChangeCost_ServerClick" runat="server" class="btn btn-success">Change </button>
                        </div>

                    </div>
                    <telerik:RadGrid ID="RadInvoice" runat="server" AllowPaging="false" AllowFilteringByColumn="true"
                        ShowFooter="true" AutoGenerateColumns="false" OnItemDataBound="RadInvoice_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid_Rounded" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadInvoice_ItemCommand" OnSortCommand="RadInvoice_SortCommand">
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true" TableLayout="Auto">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Order" SortExpression="Order" HeaderText="Order No." FilterControlWidth="40px" DataField="Order"></telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="OrderType" SortExpression="OrderType" HeaderText="Order Type" CurrentFilterFunction="Contains" FilterControlWidth="75px" AutoPostBackOnFilter="true" DataField="OrderType">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="VisualLayout" SortExpression="VisualLayout"
                                    FilterControlWidth="75px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    HeaderText="Visual Layout" DataField="VisualLayout" Aggregate="Count" FooterText="Total: ">
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
                                <telerik:GridTemplateColumn HeaderText="Qty" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:Label ID="lblQty" runat="server" CssClass="iqty"></asp:Label>
                                        <asp:HiddenField ID="hdnOrderDetail" runat="server" />
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="Label1" runat="server"></asp:Label>
                                    </FooterTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Factory Rate" AllowFiltering="false" ItemStyle-Width="70px">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtRate" runat="server" CssClass="irate" Width="50px"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Amount" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:Label ID="lblAmount" runat="server" CssClass="iamount"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTotalAmount" runat="server" CssClass="ifooteramount"></asp:Label>
                                    </FooterTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Cost Sheet" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lbCostSheet" OnClick="lbCostSheet_Click" runat="server" CssClass="btn-link" ToolTip=""></asp:LinkButton>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false" ItemStyle-Width="70px">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link iremove" ToolTip="Delete Invoice"><i class="icon-remove"></i>Remove</asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                    </telerik:RadGrid>
                    <!-- / -->
                </div>
                <!-- Empty Content -->
                <div id="dvEmptyContentInvoiceOrders" runat="server" class="alert alert-info">
                    <h4>There are no select orders added to this invoice.
                    </h4>
                    <p>
                        You can add many orders to this invoice as you like.
                    </p>
                </div>
                <!-- / -->
                <div class="form-actions">
                    <button id="btnCreateInvoice" runat="server" class="btn btn-primary" validationgroup="validateInvoice"
                        data-loading-text="Saving..." type="submit" onserverclick="btnCreateInvoice_Click">
                        Save Changes</button>
                </div>
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
            <h3>Remove Order Detail</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to remove this order detail?
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
    <!-- Page Scripts -->
    <script type="text/javascript">
        var txtInvoiceDate = "<%=txtInvoiceDate.ClientID %>";
        var RadInvoice = "<%=RadInvoice.ClientID %>";
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

            $('.iremove').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                $('#' + hdnIndexID).val($(this).attr('indexid'));
                $('#' + hdnOrderDetail).val($(this).attr('odid'))
                $('#requestRemove').modal('show');

            });

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
