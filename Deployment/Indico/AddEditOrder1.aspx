<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditOrder1.aspx.cs" Inherits="Indico.AddEditOrder1" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <asp:LinkButton ID="lbDownloadDistributorPO" CssClass="btn btn-link  pull-right" runat="server" OnClick="lbDownloadDistributorPO_Click" ToolTip="Distributor PO"><i class="icon-print"></i>Distributor PO</asp:LinkButton>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div id="dvPageContent" runat="server" class="row-fluid">
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    ValidationGroup="valGrpOrderHeader" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- Page Data -->
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#<%=collapse1.ClientID%>">Details for Indico Warehouse Processing</a>
                    </div>
                    <div id="collapse1" runat="server" class="accordion-body collapse in">
                        <div class="accordion-inner">
                            <div class="control-group">
                                <label class="control-label required">
                                    Date</label>
                                <div class="controls">
                                    <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                        <asp:TextBox CssClass="input-medium" ID="txtDate" runat="server"></asp:TextBox>
                                        <span class="add-on"><i class="icon-calendar"></i></span>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvDate" runat="server" ErrorMessage="Date is required."
                                        ControlToValidate="txtDate" EnableClientScript="false" Display="Dynamic" ValidationGroup="valGrpOrderHeader">
                                            <img src="Content/img/icon_warning.png"  title="Date is required." alt="Date is required." />
                                    </asp:RequiredFieldValidator>
                                    <asp:CustomValidator ID="cvDate" runat="server" ErrorMessage="Invalid Date" EnableClientScript="false"
                                        ValidationGroup="valGrpOrderHeader" ControlToValidate="txtDate" ValidateEmptyText="true"
                                        OnServerValidate="cvDate_OnServerValidate">
                                             <img src="Content/img/icon_warning.png"  title="Invalid Date" alt="Invalid Date" />
                                    </asp:CustomValidator>
                                    <span style="text-align: right">
                                        <asp:Label ID="lblDistributor" runat="server" Text="test" Visible="false"></asp:Label></span>
                                </div>
                            </div>
                            <div id="liDistributorPoNo" runat="server" class="control-group">
                                <label class="control-label">
                                    Distributor PO No.</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtPoNo" CssClass="input-medium" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <asp:UpdateProgress ID="upDistributor" runat="server" AssociatedUpdatePanelID="updatePnlDistributor">
                                <ProgressTemplate>
                                    <div style="position: fixed; text-align: center; height: 100%; width: 100%; top: 0; right: 0; left: 0; z-index: 9999999; background-color: #000000; opacity: 0.7;">
                                        <span style="border-width: 0px; position: fixed; padding: 50px; background-color: #FFFFFF; font-size: 24px; left: 40%; top: 40%;">Loading...</span>
                                    </div>
                                </ProgressTemplate>
                            </asp:UpdateProgress>
                            <asp:UpdatePanel ID="updatePnlDistributor" runat="server">
                                <ContentTemplate>
                                    <div id="liDistributor" runat="server" class="control-group">
                                        <label class="control-label required">
                                            Distributor</label>
                                        <div class="controls">
                                            <asp:DropDownList CssClass="input-xlarge" ID="ddlDistributor" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlDistributor_SelectedIndexChanged">
                                            </asp:DropDownList>
                                            <asp:RequiredFieldValidator ID="rfvDistributor" runat="server" ErrorMessage="Distributor is required."
                                                ControlToValidate="ddlDistributor" InitialValue="0" EnableClientScript="false"
                                                Display="Dynamic" ValidationGroup="valGrpOrderHeader">
                                            <img src="Content/img/icon_warning.png"  title="Distributor is required." alt="Distributor is required." />
                                            </asp:RequiredFieldValidator>
                                            <asp:Label ID="lblDistributorAddress" runat="server" Visible="false"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="control-group">
                                        <label class="control-label required">
                                            MYOB Card File</label>
                                        <div class="controls">
                                            <asp:DropDownList ID="ddlMYOBCardFile" CssClass="input-xlarge" runat="server">
                                            </asp:DropDownList>
                                            <a id="ancNewMYOB" visible="false" runat="server" class="btn btn-link imyobcardfile" onclick="javascript:AddNewMYOBCardFile();" title="Add New MYOB Card file"><i class="icon-plus"></i></a>
                                            <a id="ancEditMYOB" visible="false" runat="server" class="btn btn-link ieditmyobcardfile" title="Edit MYOB Card file details" onclick="javascript:EditMYOBCardFile(this);"><i class=" icon-pencil"></i></a>
                                            <asp:RequiredFieldValidator ID="rfvMYOBCardFile" runat="server" ErrorMessage="MYOB Card File is required."
                                                ControlToValidate="ddlMYOBCardFile" InitialValue="0" EnableClientScript="false"
                                                Display="Dynamic" ValidationGroup="valGrpOrderHeader">
                                            <img src="Content/img/icon_warning.png"  title="MYOB Card File is required." alt="MYOB Card File is required." />
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <div id="liClient" runat="server" class="control-group">
                                        <label class="control-label required">
                                            Client</label>
                                        <div class="controls">
                                            <asp:DropDownList ID="ddlClient" CssClass="input-xlarge" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlClient_SelectedIndexChanged" Enabled="true">
                                            </asp:DropDownList>
                                            <a id="aAddClient" runat="server" visible="false" class="btn btn-link iClient" onclick="javascript:AddNewClient(true);" title="Add New Client"><i class="icon-plus"></i></a>
                                            <asp:Label ID="litClient" runat="server"></asp:Label>
                                            <asp:LinkButton ID="btnEditClient" runat="server" Visible="false" class="btn btn-link" title="Edit Client" OnClick="btnEditClient_Click"><i class="icon-pencil"></i></asp:LinkButton>
                                            <asp:Label ID="lblFOCPenaltyClient" Text=" This is a FOC Penalty Client" runat="server" style="color:white;"></asp:Label>
                                            <asp:RequiredFieldValidator ID="rfvClient" runat="server" ErrorMessage="Client is required."
                                                ControlToValidate="ddlClient" InitialValue="0" EnableClientScript="false"
                                                Display="Dynamic" ValidationGroup="valGrpOrderHeader">
                                            <img src="Content/img/icon_warning.png"  title="Client is required." alt="Client is required." />
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <div class="control-group">
                                        <label class="control-label required">
                                            Job Name</label>
                                        <div class="controls">
                                            <asp:DropDownList ID="ddlJobName" CssClass="input-xlarge" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlJobName_SelectedIndexChanged" Enabled="true">
                                            </asp:DropDownList>
                                            <a id="ancNewJobName" runat="server" visible="false" class="btn btn-link" onclick="javascript:AddNewJobName();" title="Add New Job Name"><i class="icon-plus"></i></a>
                                            <asp:Literal ID="litJobName" runat="server"></asp:Literal>
                                            <asp:LinkButton ID="btnEditJobName" runat="server" Visible="false" class="btn btn-link" OnClick="btnEditJobName_Click" ToolTip="Edit JobName"><i class="icon-pencil"></i></asp:LinkButton>
                                            <asp:RequiredFieldValidator ID="rfvJobName" runat="server" ErrorMessage="Job Name is required."
                                                ControlToValidate="ddlJobName" InitialValue="0" EnableClientScript="false"
                                                Display="Dynamic" ValidationGroup="valGrpOrderHeader">
                                            <img src="Content/img/icon_warning.png"  title="Job Name is required." alt="Job Name is required." />
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <div class="control-group">
                                        <label class="control-label required">
                                            Billing Address</label>
                                        <div class="controls">
                                            <asp:DropDownList ID="ddlBillingAddress" CssClass="input-xlarge" runat="server" Enabled="false"
                                                AutoPostBack="true" OnSelectedIndexChanged="ddlBillingAddress_SelectedIndexChanged">
                                            </asp:DropDownList>
                                            <a id="aAddShippingAddress" runat="server" visible="false" class="btn btn-link ishippingAddress" onclick="javascript:AddNewShipmentAddress('Billing');" title="Add New Address Details"><i class="icon-plus"></i></a>
                                            <asp:RequiredFieldValidator ID="rflBillingAddress" runat="server" ErrorMessage="Billing Address is required."
                                                ControlToValidate="ddlBillingAddress" InitialValue="0" EnableClientScript="false"
                                                Display="Dynamic" ValidationGroup="valGrpOrderHeader">
                                            <img src="Content/img/icon_warning.png"  title="Billing Address is required." alt="Billing Address is required." />
                                            </asp:RequiredFieldValidator>
                                            <asp:Label ID="lblBillingAddress" runat="server"></asp:Label>
                                            <asp:LinkButton ID="btnEditBilling" runat="server" Visible="false" class="btn btn-link" OnClick="btnEditBilling_Click" ToolTip="Edit Billing Address"><i class="icon-pencil"></i></asp:LinkButton>
                                        </div>
                                    </div>
                                    <div class="control-group">
                                        <label class="control-label required">
                                            Despatch Address</label>
                                        <div class="controls">
                                            <asp:DropDownList ID="ddlDespatchAddress" CssClass="input-xlarge" runat="server" Enabled="false"
                                                AutoPostBack="true" OnSelectedIndexChanged="ddlDespatchAddress_SelectedIndexChanged">
                                            </asp:DropDownList>
                                            <a id="ancDespatchAddress" runat="server" visible="false" class="btn btn-link ishippingAddress" onclick="javascript:AddNewShipmentAddress('Despatch');" title="Add New Address Details"><i class="icon-plus"></i></a>
                                            <asp:RequiredFieldValidator ID="rfvDespatchAddress" runat="server" ErrorMessage="Despatch Address is required."
                                                ControlToValidate="ddlDespatchAddress" InitialValue="0" EnableClientScript="false"
                                                Display="Dynamic" ValidationGroup="valGrpOrderHeader">
                                            <img src="Content/img/icon_warning.png"  title="Despatch Address is required." alt="Billing Address is required." />
                                            </asp:RequiredFieldValidator>
                                            <asp:Label ID="lblDespatchAddress" runat="server"></asp:Label>
                                            <asp:LinkButton ID="btnEditDespatch" runat="server" Visible="false" class="btn btn-link" OnClick="btnEditDespatch_Click" ToolTip="Edit Despatch Address"><i class="icon-pencil"></i></asp:LinkButton>
                                        </div>
                                    </div>
                                    <%--<div class="control-group">
                                        <label class="control-label">
                                            Label</label>
                                        <div class="controls">
                                            <asp:DropDownList ID="ddlLabel" CssClass="input-xlarge" runat="server" Enabled="false">
                                            </asp:DropDownList>
                                        </div>
                                    </div>--%>
                                </ContentTemplate>
                                <Triggers>
                                    <asp:PostBackTrigger ControlID="btnEditBilling" />
                                    <asp:PostBackTrigger ControlID="btnEditDespatch" />
                                    <asp:PostBackTrigger ControlID="btnEditClient" />
                                    <asp:PostBackTrigger ControlID="btnEditJobName" />
                                </Triggers>
                            </asp:UpdatePanel>
                            <div id="liOrderStatus" runat="server" class="control-group" visible="false">
                                <label class="control-label">
                                    Order Status</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlStatus" CssClass="input-medium" runat="server">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <%--  <legend><h5>Details for Indico Warehouse Processing</h5></legend>--%>
                            <div id="liOrderNumber" runat="server" class="control-group">
                                <label class="control-label">
                                    Production PO No.</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtRefference" CssClass="input-medium" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div id="liAccessNo" runat="server" class="control-group">
                                <label class="control-label">
                                    MS Access PO No.</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtOldPoNo" CssClass="input-medium" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group" id="dvDesireDate" runat="server">
                                <label class="control-label required" id="lblDateName" runat="server">
                                    Date Required in Customers Hand</label>
                                <div class="controls" id="dvDesiredDate" runat="server">
                                    <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                        <asp:TextBox ID="txtDesiredDate" CssClass="input-medium" runat="server"></asp:TextBox>
                                        <span class="add-on"><i class="icon-calendar"></i></span>
                                    </div>
                                    <asp:CustomValidator ID="cvDesiredDate" runat="server" ErrorMessage="Invalid Desired Date"
                                        EnableClientScript="false" ValidationGroup="valGrpOrderHeader" ControlToValidate="txtDesiredDate"
                                        ValidateEmptyText="true" OnServerValidate="cvDesiredDate_OnServerValidate">
                                             <img src="Content/img/icon_warning.png"  title="Invalid Desired Date" alt="Invalid Desired Date" />
                                    </asp:CustomValidator>
                                    <p class="text-info">
                                        <asp:Literal ID="litDateRequiredDescription" runat="server"></asp:Literal>
                                    </p>
                                </div>
                            </div>
                            <div class="control-group" id="Div1" runat="server">
                                <label class="control-label">
                                    Is this delivery date Flexible?</label>
                                <div class="controls">
                                    <label class="radio inline">
                                        <asp:RadioButton ID="rbDateYes" runat="server" Checked="true" GroupName="daterequired" />
                                        Yes
                                    </label>
                                    <label class="radio inline">
                                        <asp:RadioButton ID="rbDateNo" runat="server" GroupName="daterequired" />
                                        No
                                    </label>
                                    <p class="text-info">
                                        (You should only select NO, if the delivery is required for an event where the date is fixed and cannot change.)
                                    </p>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Delivery Option</label>
                                <div class="controls">
                                    <label class="radio inline">
                                        Road Freight<asp:RadioButton ID="rdoRoadFreight" Checked="true" runat="server" GroupName="grpRA" />
                                    </label>
                                    <label class="radio inline">
                                        Airbag<asp:RadioButton ID="rdoAirbag" runat="server" GroupName="grpRA" />
                                    </label>
                                    <label class="radio inline">
                                        Pick up<asp:RadioButton ID="rdoPickup" runat="server" GroupName="grpRA" />
                                    </label>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Special Instructions</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtNotes" TextMode="MultiLine" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div id="dvOfficeUse" runat="server" class="control-group">
                                <label class="control-label required">
                                    Shipment Date</label>
                                <div class="controls">
                                    <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                        <asp:TextBox ID="txtShipmentDate" CssClass="input-medium" runat="server"></asp:TextBox>
                                        <span class="add-on"><i class="icon-calendar"></i></span>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvShipmentDate" runat="server" ErrorMessage="Date is required."
                                        ControlToValidate="txtShipmentDate" EnableClientScript="false" Display="Dynamic" ValidationGroup="valGrpOrderHeader">
                                            <img src="Content/img/icon_warning.png"  title="Date is required." alt="Date is required." />
                                    </asp:RequiredFieldValidator>
                                    <asp:CustomValidator ID="cvShipmentDate" runat="server" ErrorMessage="Invalid Date" EnableClientScript="false"
                                        ValidationGroup="valGrpOrderHeader" ControlToValidate="txtShipmentDate" ValidateEmptyText="true"
                                        OnServerValidate="cvDate_OnServerValidate">
                                             <img src="Content/img/icon_warning.png"  title="Invalid Date" alt="Invalid Date" />
                                    </asp:CustomValidator>
                                </div>
                            </div>
                            <div id="liPaymentMethod" runat="server" class="control-group">
                                <label class="control-label required">
                                    Shipment Term</label>
                                <div class="controls">
                                    <asp:DropDownList CssClass="input-medium" ID="ddlPaymentMethod" runat="server">
                                    </asp:DropDownList>
                                    <a visible="false" id="ancNewPaymentMethod" runat="server" class="btn btn-link iadd" title="Add New Payment Method">
                                        <i class="icon-plus"></i></a>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Shipment Mode</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlShipmentMode" runat="server">
                                    </asp:DropDownList>
                                    <a visible="false" id="ancShipmentMode" data-placement="bottom" runat="server" class="btn btn-link iadd ishipment" title="Add New Shipment Mode"><i class="icon-plus"></i></a>
                                </div>
                            </div>
                            <div class="control-group">
                                <div class="controls radio">
                                    <asp:RadioButton ID="rbWeeklyShipment" runat="server" GroupName="shiptoMethod" onchange="SetDespatchDiv();" Checked="true" />
                                    In Weekly shipment to Adelaide warehouse
                                </div>
                            </div>
                            <div class="controls radio">
                                <asp:RadioButton ID="rbCourier" runat="server" GroupName="shiptoMethod" onchange="SetDespatchDiv();" />
                                By Special International Courier service
                                            <p class="text-info">(International courier charges apply. Please obtain estimate from coordinator)</p>
                                <div class="control-group" id="dvOdDespatchAddress" style="display: none;">
                                    <label class="control-label required">
                                        Despatch Address</label>
                                    <div class="controls">
                                        <asp:DropDownList ID="ddlCourierAddress" CssClass="input-xlarge" runat="server" AutoPostBack="true"
                                            OnSelectedIndexChanged="ddlCourierAddress_SelectedIndexChanged">
                                        </asp:DropDownList>
                                        <a id="ancCourierAddress" runat="server" visible="false" class="btn btn-link ishippingAddress" onclick="javascript:AddNewShipmentAddress('Courier');" title="Add New Address Details"><i class="icon-plus"></i></a>
                                        <asp:Label ID="lblCourierAddress" runat="server"></asp:Label>
                                        <asp:LinkButton ID="btnEditCourier" runat="server" Visible="false" class="btn btn-link" OnClick="btnEditCourier_Click" ToolTip="Edit Courier Address"><i class="icon-pencil"></i></asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <%--<div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#<%=collapse3.ClientID%>">Details for Indico Warehouse Processing</a>
                    </div>
                    <div id="collapse3" runat="server" class="accordion-body collapse">
                        <div class="accordion-inner">
                            
                        </div>
                    </div>
                </div>--%>
                <%-- <div class="accordion-group" style="display: none;">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#<%=collapse2.ClientID%>">Delivery Information for Factory</a>
                    </div>
                    <div id="collapse2" runat="server" class="accordion-body collapse">
                        <div class="accordion-inner">
                            <div id="dvOfficeUse" runat="server">
                               <div class="control-group">
                                    <label class="control-label">
                                        Shipment Date</label>
                                    <div class="controls">
                                        <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                            <asp:TextBox ID="txtShipmentDate" CssClass="input-medium" runat="server"></asp:TextBox>
                                            <span class="add-on"><i class="icon-calendar"></i></span>
                                        </div>
                                    </div>
                                </div>
                            <div id="liPaymentMethod" runat="server" class="control-group">
                                    <label class="control-label">
                                        Shipment Term</label>
                                    <div class="controls">
                                        <asp:DropDownList CssClass="input-medium" ID="ddlPaymentMethod" runat="server">
                                        </asp:DropDownList>
                                        <a id="ancNewPaymentMethod" runat="server" class="btn btn-link iadd" title="Add New Payment Method">
                                            <i class="icon-plus"></i></a>
                                    </div>
                                </div>
                        </div>
                        <div class="control-group" id="divShipmentMode" runat="server">
                                <label class="control-label">
                                    Shipment Mode</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlShipmentMode" runat="server">
                                    </asp:DropDownList>
                                    <a id="ancShipmentMode" data-placement="bottom" runat="server" class="btn btn-link iadd ishipment" title="Add New Shipment Mode"><i class="icon-plus"></i></a>
                                </div>
                            </div>
                            <div class="control-group">
                                <div class="controls radio" id="dvWeeklyShipment" runat="server">
                                    <asp:RadioButton ID="rbWeeklyShipment" runat="server" GroupName="shiptoMethod" Checked="true" />
                                    In Weekly shipment to Adelaide warehouse
                                </div>
                            </div>
                            <div>
                                <div class="controls radio">
                                    <asp:RadioButton ID="rbCourier" runat="server" GroupName="shiptoMethod" />
                                    By Special International Courier service
                                     <p class="text-info">(International courier charges apply. Please obtain estimate from coordinator)</p>
                                </div>
                            </div>
                    </div>
                </div>
            </div>--%>
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" id="linkorderdetail" data-toggle="collapse" href="#<%=collapse4.ClientID%>">Order
                            Details</a>
                    </div>
                    <div id="collapse4" runat="server" class="accordion-body collapse">
                        <div class="accordion-inner">
                            <h4>Added Order Details</h4>
                            <!-- Data Table -->
                            <asp:DataGrid ID="dgOrderItems" runat="server" CssClass="table" AllowCustomPaging="False"
                                AllowPaging="False" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                                OnItemDataBound="dgOrderItems_ItemDataBound">
                                <HeaderStyle CssClass="header" />
                                <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                                <Columns>
                                    <asp:TemplateColumn HeaderText="Order Type">
                                        <ItemTemplate>
                                            <asp:Literal ID="lblOrderType" runat="server" Text=""></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="VL Number / Pattern Number / Fabric">
                                        <ItemTemplate>
                                            <asp:Literal ID="lblVLNumber" runat="server" Text=""></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="VL Image">
                                        <ItemTemplate>
                                            <a id="ancVLImage" runat="server"><i id="ivlimageView" runat="server" class="icon-eye-open"></i></a>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Pocket">
                                        <ItemTemplate>
                                            <asp:Literal ID="litPocket" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <%--<asp:TemplateColumn HeaderText="Price">
                                    <ItemTemplate>
                                        <asp:Literal ID="litPrice" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>--%>
                                    <asp:TemplateColumn HeaderText="Dis. Edited Price">
                                        <ItemTemplate>
                                            <%-- <div class="input-append">
                                                <asp:TextBox ID="txtPercentage" runat="server" CssClass="input-mini"></asp:TextBox>
                                                <span class="add-on">%</span>
                                            </div>--%>
                                            <div class="input-append">
                                                <%-- <span class="add-on">$</span>--%>
                                                <asp:TextBox ID="txtEditedPrice" runat="server" CssClass="input-mini"></asp:TextBox>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <%-- <asp:TemplateColumn HeaderText="Dis. Edited Price Comments">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtPriceRemarks" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateColumn>--%>
                                    <asp:TemplateColumn HeaderText="Quantities" ItemStyle-Width="25%">
                                        <ItemTemplate>
                                            <ol class="ioderlist-table">
                                                <asp:Repeater ID="rptSizeQtyView" runat="server" OnItemDataBound="rptSizeQtyView_ItemDataBound">
                                                    <ItemTemplate>
                                                        <li class="idata-column">
                                                            <ul>
                                                                <li class="icell-header">
                                                                    <asp:Literal ID="litHeading" runat="server"></asp:Literal>
                                                                </li>
                                                                <li class="icell-data">
                                                                    <asp:Label ID="lblQty" runat="server" Text=""></asp:Label>
                                                                </li>
                                                            </ul>
                                                        </li>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </ol>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Order Detail Notes" Visible="false">
                                        <ItemTemplate>
                                            <asp:Literal ID="lblOdNotes" runat="server" Text=""></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Visual Layout Notes" Visible="false">
                                        <ItemTemplate>
                                            <asp:Literal ID="lblVlNotes" runat="server" Text=""></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <%-- <asp:TemplateColumn HeaderText="Label">
                                    <ItemTemplate>
                                        <a id="ancLabelImagePreview" runat="server"><i id="ilabelimageView" runat="server"
                                            class="icon-eye-open"></i></a><a id="ancDownloadLabel" class="btn btn-link idownload"
                                                title="Download" runat="server" onserverclick="ancDownloadLabel_Click"><i class="icon-download-alt"></i></a>
                                    </ItemTemplate>
                                </asp:TemplateColumn>--%>
                                    <asp:TemplateColumn HeaderText="Name & Number File">
                                        <ItemTemplate>
                                            <a id="ancNameNumberFile" runat="server" title="Name & Number File" href="javascript:void(0);">
                                                <i id="iNameNumberFile" runat="server" class="icon-eye-ok"></i></a><a id="ancDownloadNameAndNumberFile"
                                                    class="btn btn-link idownload" title="Download" runat="server" onserverclick="ancDownloadNameAndNumberFile_Click">
                                                    <i class="icon-download-alt"></i></a>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Qty">
                                        <ItemTemplate>
                                            <asp:Literal ID="lblQty" runat="server" Text=""></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Surcharge">
                                        <ItemTemplate>
                                            <asp:Literal ID="lblSurcharge" runat="server" Text=""></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText=" Total Value">
                                        <ItemTemplate>
                                            <p>$<asp:Label ID="lblTotal" runat="server" Text=""></asp:Label></p>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Status">
                                        <ItemTemplate>
                                            <asp:Literal ID="litDetailStatus" runat="server" Text=""></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="">
                                        <ItemTemplate>
                                            <div class="btn-group">
                                                <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                    <i class="icon-cog"></i><span class="caret"></span></a>
                                                <ul class="dropdown-menu pull-right" style="position: relative">
                                                    <li>
                                                        <a id="linkEdit" runat="server" class="btn-link iedit" title="Edit Item" onserverclick="linkEdit_Click"><i class="icon-pencil"></i>Edit</a>
                                                    </li>
                                                    <li>
                                                        <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Order Detail"><i class="icon-trash"></i>Delete</asp:HyperLink>
                                                    </li>
                                                    <li>
                                                        <asp:LinkButton ID="libtnSaveRemarks" runat="server" CssClass="btn-link" OnClick="libtnSaveRemarks_Click" ToolTip="Save Price Remarks"><i class="icon-edit"></i>Save Remarks</asp:LinkButton>
                                                    </li>
                                                    <li>
                                                        <asp:HyperLink ID="linkCancelDetail" runat="server" CssClass="btn-link icancelled" ToolTip="Cancel Order Detail"><i class="icon-trash"></i>Cancel Order Detail</asp:HyperLink>
                                                    </li>
                                                </ul>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                </Columns>
                            </asp:DataGrid>
                            <!-- / -->
                            <!-- No Orders -->
                            <div id="dvNoOrders" runat="server" class="alert alert-info">
                                <h4>No orders have been added.</h4>
                                <p>
                                    Once you add an order, you'll see the details below.
                                </p>
                            </div>
                            <!-- / -->
                            <h4>New Order Detail</h4>
                            <div class="span12">
                                <div class="span8">
                                    <div class="control-group">
                                        <div class="controls">
                                            <label class="checkbox inline">
                                                <asp:CheckBox ID="chkPhotoApprovalRequired" runat="server" />
                                                Is Photo Approval Required
                                            </label>
                                        </div>
                                    </div>
                                    <div class="control-group">
                                        <div class="controls">
                                            <label class="checkbox inline">
                                                <asp:CheckBox ID="chkBrandingKit" CssClass="input-medium" runat="server"></asp:CheckBox>
                                                Use Branding Kit
                                            </label>
                                            <label class="checkbox inline">
                                                <asp:CheckBox ID="chkLockerPatch" CssClass="input-medium" runat="server"></asp:CheckBox>
                                                Use Locker Patch
                                            </label>

                                        </div>
                                    </div>
                                    <div class="control-group">
                                        <label class="control-label required">
                                            Order Type</label>
                                        <div class="controls">
                                            <asp:DropDownList ID="ddlOrderType" CssClass="input-xlarge" runat="server" Url="/AddEditClientOrder.aspx">
                                            </asp:DropDownList>
                                            <asp:RequiredFieldValidator ID="rfvOrderType" runat="server" ErrorMessage="Order Type is required."
                                                ControlToValidate="ddlOrderType" InitialValue="0" ValidationGroup="valGrpOrderHeader"
                                                EnableClientScript="false" Display="Dynamic">
                                            <img src="Content/img/icon_warning.png"  title="Order Type is required." alt="Order Type is required." />
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <asp:UpdateProgress ID="upVLNumber" runat="server" AssociatedUpdatePanelID="UpdateVlNumber">
                                        <ProgressTemplate>
                                            <div style="position: fixed; text-align: center; height: 100%; width: 100%; top: 0; right: 0; left: 0; z-index: 9999999; background-color: #000000; opacity: 0.7;">
                                                <span style="border-width: 0px; position: fixed; padding: 50px; background-color: #FFFFFF; font-size: 24px; left: 40%; top: 40%;">Loading...</span>
                                            </div>
                                        </ProgressTemplate>
                                    </asp:UpdateProgress>
                                    <asp:UpdatePanel ID="UpdateVlNumber" runat="server" style="display: inline-block;">
                                        <ContentTemplate>
                                            <div class="control-group">
                                                <label class="control-label required">
                                                    Label</label>
                                                <div class="controls">
                                                    <asp:DropDownList ID="ddlLabel" runat="server" CssClass="input-xlarge"></asp:DropDownList>
                                                    <asp:RequiredFieldValidator ID="rfvLabel" runat="server" ErrorMessage="Label is required."
                                                        ControlToValidate="ddlLabel" InitialValue="0" ValidationGroup="valGrpOrderHeader"
                                                        EnableClientScript="false" Display="Dynamic">
                                            <img src="Content/img/icon_warning.png"  title="Label is required." alt="Label is required." />
                                                    </asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div id="dvFromVL" runat="server">
                                                <div class="control-group">
                                                    <div class="controls radio">
                                                        <asp:RadioButton ID="rbVisualLayout" runat="server" GroupName="orderDetailFrom" AutoPostBack="true" OnCheckedChanged="rbVisualLayout_CheckedChanged" onchange="SetOrderDetailDiv();" Checked="true" />
                                                        From Visual Layout
                                                    </div>
                                                </div>
                                                <div class="control-group">
                                                    <div class="controls radio">
                                                        <asp:RadioButton ID="rbPatternFabric" runat="server" GroupName="orderDetailFrom" AutoPostBack="true" OnCheckedChanged="rbVisualLayout_CheckedChanged" onchange="SetOrderDetailDiv();" />
                                                        From Pattern - Fabric
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="control-group ifromVisualLayout">
                                                <label class="control-label required">
                                                    Visual Layout
                                                </label>
                                                <div class="controls">
                                                    <asp:DropDownList ID="ddlVlNumber" CssClass="input-xlarge" runat="server" AutoPostBack="true"
                                                        OnSelectedIndexChanged="ddlVlNumber_SelectedIndexChange" Url="/AddEditOrder.aspx">
                                                    </asp:DropDownList>
                                                    <%-- <asp:DropDownList ID="ddlArtWork" CssClass="input-xlarge" runat="server" AutoPostBack="true"
                                                    Enabled="false" OnSelectedIndexChanged="ddlArtWork_SelectedIndexChanged" Url="/AddEditOrder.aspx">
                                                </asp:DropDownList>--%>
                                                    <asp:LinkButton ID="ancAddNewVL" runat="server" CssClass="btn btn-link" OnClick="ancAddNewVL_Click" OnClientClick="ClickVL(this)"
                                                        ToolTip="Add New Visual Layout" Visible="false"><i class="icon-plus"></i></asp:LinkButton>
                                                    <%--<div class="search-control" id="dvSearchVl" runat="server" style="display: inline-block; margin-bottom: 0;">
                                                        <asp:TextBox ID="txtVLSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                                                        <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search" />
                                                    </div>--%>
                                                    <%--<div class="search-control" style="display: inline-block; margin-bottom: 0;">
                                                    <asp:DropDownList ID="ddlSizes" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSizes_SelectedIndexChanged"></asp:DropDownList>
                                                </div>--%>
                                                    <span class="text-error">
                                                        <asp:Literal ID="litMeassage" runat="server"></asp:Literal>
                                                    </span>
                                                    <%--<asp:RequiredFieldValidator ID="rfvVlNumber" runat="server" ErrorMessage="Visual Layout Number is required"
                                                        ControlToValidate="ddlVlNumber" InitialValue="0" ValidationGroup="valGrpOrderHeader"
                                                        EnableClientScript="false" Display="Dynamic">
                                            <img src="Content/img/icon_warning.png"  title="Visual Layout Number is required" alt="Visual Layout Number is required" />
                                                    </asp:RequiredFieldValidator>--%>
                                                </div>
                                            </div>
                                            <div class="control-group ifromPattern" style="display: none">
                                                <label class="control-label required">
                                                    Pattern
                                                </label>
                                                <div class="controls">
                                                    <asp:DropDownList ID="ddlPattern" CssClass="input-xlarge" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPattern_SelectedIndexChanged"></asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="control-group ifromPattern" style="display: none">
                                                <label class="control-label required">
                                                    Fabric
                                                </label>
                                                <div class="controls">
                                                    <asp:DropDownList ID="ddlFabric" CssClass="input-xlarge" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFabric_SelectedIndexChanged"></asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="control-group">
                                                <div class="controls">
                                                    <div class="search-control" style="display: inline-block; margin-bottom: 0;">
                                                        <asp:DropDownList ID="ddlSizes" CssClass="input-medium" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSizes_SelectedIndexChanged"></asp:DropDownList>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="control-group">
                                                <ol id="olSizeQuantities" class="ioderlist-table" style="display: block; margin-left: 380px; margin-top: 0; width: 620px;">
                                                    <asp:Repeater ID="rptSizeQty" runat="server" OnItemDataBound="rptSizeQty_ItemDataBound">
                                                        <ItemTemplate>
                                                            <li class="idata-column">
                                                                <ul>
                                                                    <li class="icell-header">
                                                                        <asp:Literal ID="litHeading" runat="server"></asp:Literal>
                                                                    </li>
                                                                    <li class="icell-data">
                                                                        <asp:TextBox ID="txtQty" runat="server" CssClass="iintiger" Width="40" onkeyup="javascript:calculateTotalQty();"></asp:TextBox>
                                                                        <asp:HiddenField ID="hdnQtyID" runat="server" Value="0" />
                                                                    </li>
                                                                </ul>
                                                            </li>
                                                        </ItemTemplate>
                                                    </asp:Repeater>
                                                </ol>
                                            </div>
                                            <div class="control-group">
                                                <label class="control-label">
                                                </label>
                                                <div class="row-fluid">
                                                    <ul class="thumbnails">
                                                        <li class="span4">
                                                            <div class="thumbnail">
                                                                <asp:Image ID="imgvlImage" runat="server" />
                                                                <div class="caption">
                                                                    <h3 class="text-center">Visual Layout Image
                                                                    </h3>
                                                                </div>
                                                            </div>
                                                        </li>
                                                        <li class="span6">
                                                            <div class="control-group">
                                                                <label class="control-label">
                                                                    Total Quantity</label>
                                                                <div class="controls">
                                                                    <asp:TextBox ID="txtTotalQty" runat="server" Style="text-align: right" Enabled="false" Text="" CssClass="input-medium"></asp:TextBox>
                                                                    <p class="extra-helper icenter" runat="server" visible="false">
                                                                        <asp:Label ID="lblreservationQty" runat="server" Text=""></asp:Label>
                                                                    </p>
                                                                </div>
                                                            </div>
                                                            <div class="control-group">
                                                                <label class="control-label">
                                                                    Unit</label>
                                                                <div class="controls">
                                                                    <asp:TextBox ID="txtUnit" runat="server" Enabled="false" Text="" CssClass="input-medium"></asp:TextBox>
                                                                </div>
                                                            </div>
                                                            <div class="control-group" id="dvIndimanPrice" runat="server">
                                                                <label class="control-label">Indiman Price $</label>
                                                                <div class="controls">
                                                                    <asp:TextBox ID="txtPrice" runat="server" data-attr="base" Enabled="false" Style="text-align: right" CssClass="input-medium"></asp:TextBox>
                                                                </div>
                                                            </div>
                                                            <div class="control-group">
                                                                <label class="control-label">Promo Code</label>
                                                                <div class="controls">
                                                                    <asp:TextBox ID="txtPromoCode" runat="server" Text="" CssClass="input-medium"></asp:TextBox>
                                                                </div>
                                                            </div>
                                                            <div id="dvPatternLit" runat="server" class="control-group" visible="false">
                                                                <label class="control-label">Pattern</label>
                                                                <div class="controls">
                                                                    <asp:Literal ID="litPattern" runat="server"></asp:Literal>
                                                                </div>
                                                            </div>
                                                            <div id="dvFabricLit" runat="server" class="control-group" visible="false">
                                                                <label class="control-label">Fabric</label>
                                                                <div class="controls">
                                                                    <asp:Literal ID="litFabric" runat="server"></asp:Literal>
                                                                </div>
                                                            </div>
                                                            <div id="dvPocketLit" runat="server" class="control-group" visible="false">
                                                                <label class="control-label">Pocket</label>
                                                                <div class="controls">
                                                                    <asp:Literal ID="litPocket" runat="server"></asp:Literal>
                                                                </div>
                                                            </div>
                                                        </li>
                                                    </ul>
                                                </div>
                                            </div>
                                            <div class="control-group">
                                                 <table style="width:auto" id="tblSurcharge" class="table">
                                                  <tr>
                                                    <td></td>
                                                    <td>Normal Distributor Price $</td>
                                                    <td>Normal Margin %</td>
                                                    <td><asp:Label id="tdSurcharge1" runat="server">Surcharge %</asp:Label></td>
                                                    <td><asp:Label id="tdSurchargePrice1" runat="server">Price With Surcharge $</asp:Label></td>
                                                    <td><asp:Label id="tdSurchargeMargin1" runat="server">Margin With Surcharge %</asp:Label></td>
                                                    <td>Total Value $</td>
                                                  </tr>
                                                  <tr>
                                                    <td>         </td>
                                                    <td><asp:TextBox ID="txtDistributorPrice" runat="server" data-attr="new" Style="text-align: right" CssClass="input-medium" Width="100px"></asp:TextBox></td>
                                                    <td><span id="dvPercentage" runat="server">
                                                            <asp:TextBox ID="txtPercentage" runat="server" data-attr="ptg" Style="text-align: right" CssClass="input-medium" Width="75px"></asp:TextBox>  
                                                        </span>
                                                    </td>
                                                    <td><asp:TextBox ID="txtSurcharge" runat="server" data-attr="new" Style="text-align: right" CssClass="input-medium" Width="75px"></asp:TextBox></td>
                                                    <td><asp:TextBox ID="txtPriceWithSurcharge" runat="server" data-attr="new" Style="text-align: right" CssClass="input-medium" Width="100px" Enabled="false"></asp:TextBox></td>
                                                    <td><asp:TextBox ID="txtMarginWithSurcharge" runat="server" data-attr="new" Style="text-align: right" CssClass="input-medium" Width="100px" Enabled="false"></asp:TextBox></td>
                                                    <td><asp:TextBox ID="txtTotalValueSurcharge" runat="server" data-attr="new" Style="text-align: right" CssClass="input-medium" Width="100px" Enabled="false"></asp:TextBox></td>
                                                  </tr>
                                                </table> 
                                            </div>
                                            <div class="control-group">
                                                <label class="control-label">Price Comments</label>
                                                <div class="controls">
                                                    <asp:TextBox ID="txtPriceComments" runat="server" TextMode="MultiLine" CssClass="input-medium"></asp:TextBox>
                                                </div>
                                            </div>
                                            <%-- <div id="dvOfficeUse" runat="server" class="control-group">
                                                <label class="control-label required">
                                                    Shipment Date</label>
                                                <div class="controls">
                                                    <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                                        <asp:TextBox ID="txtShipmentDate" CssClass="input-medium" runat="server"></asp:TextBox>
                                                        <span class="add-on"><i class="icon-calendar"></i></span>
                                                    </div>
                                                    <%-- <asp:RequiredFieldValidator ID="rfvShipmentDate" runat="server" ErrorMessage="Date is required."
                                                    ControlToValidate="txtShipmentDate" EnableClientScript="false" Display="Dynamic" ValidationGroup="valGrpOrderHeader">
                                            <img src="Content/img/icon_warning.png"  title="Date is required." alt="Date is required." />
                                                </asp:RequiredFieldValidator>-- %>
                                                    <asp:CustomValidator ID="cvShipmentDate" runat="server" ErrorMessage="Invalid Date" EnableClientScript="false"
                                                        ValidationGroup="valGrpOrderHeader" ControlToValidate="txtShipmentDate" ValidateEmptyText="true"
                                                        OnServerValidate="cvDate_OnServerValidate">
                                             <img src="Content/img/icon_warning.png"  title="Invalid Date" alt="Invalid Date" />
                                                    </asp:CustomValidator>
                                                </div>
                                            </div>
                                            <div id="liPaymentMethod" runat="server" class="control-group">
                                                <label class="control-label">
                                                    Shipment Term</label>
                                                <div class="controls">
                                                    <asp:DropDownList CssClass="input-medium" ID="ddlPaymentMethod" runat="server">
                                                    </asp:DropDownList>
                                                    <a visible="false" id="ancNewPaymentMethod" runat="server" class="btn btn-link iadd" title="Add New Payment Method">
                                                        <i class="icon-plus"></i></a>
                                                </div>
                                            </div>
                                            <div class="control-group">
                                                <label class="control-label">
                                                    Shipment Mode</label>
                                                <div class="controls">
                                                    <asp:DropDownList ID="ddlShipmentMode" runat="server">
                                                    </asp:DropDownList>
                                                    <a visible="false" id="ancShipmentMode" data-placement="bottom" runat="server" class="btn btn-link iadd ishipment" title="Add New Shipment Mode"><i class="icon-plus"></i></a>
                                                </div>
                                            </div>
                                            <div class="control-group">
                                                <div class="controls radio">
                                                    <asp:RadioButton ID="rbWeeklyShipment" runat="server" GroupName="shiptoMethod" onchange="SetDespatchDiv();" Checked="true" />
                                                    In Weekly shipment to Adelaide warehouse
                                                </div>
                                            </div>
                                            <div class="controls radio">
                                                <asp:RadioButton ID="rbCourier" runat="server" GroupName="shiptoMethod" onchange="SetDespatchDiv();" />
                                                By Special International Courier service
                                            <p class="text-info">(International courier charges apply. Please obtain estimate from coordinator)</p>
                                                <div class="control-group" id="dvOdDespatchAddress" style="display: none;">
                                                    <label class="control-label required">
                                                        Despatch Address</label>
                                                    <div class="controls">
                                                        <asp:DropDownList ID="ddlCourierAddress" CssClass="input-xlarge" runat="server">
                                                        </asp:DropDownList>
                                                        <asp:Label ID="lblOdDespatchAddress" runat="server"></asp:Label>
                                                    </div>
                                                </div>
                                            </div>--%>
                                            <div class="control-group">
                                                <label class="control-label">
                                                    Order Detail Notes</label>
                                                <div class="controls">
                                                    <asp:TextBox ID="txtOdNotes" runat="server" TextMode="MultiLine" CssClass="input-medium" ViewStateMode="Enabled"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="control-group">
                                                <label class="control-label">
                                                    Factory Instructions</label>
                                                <div class="controls">
                                                    <asp:TextBox ID="txtFactoryDescription" runat="server" TextMode="MultiLine" CssClass="input-medium" ViewStateMode="Enabled"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="control-group" runat="server" visible="false">
                                                <label class="control-label">
                                                    Repeat/New</label>
                                                <div class="controls">
                                                    <asp:TextBox ID="txtIsNew" runat="server" Enabled="false" CssClass="input-medium"></asp:TextBox>
                                                </div>
                                            </div>
                                            <script type="text/javascript">
                                                function calculateTotalQty() {
                                                    var qty = 0;
                                                    $('#olSizeQuantities input[type=text]').each(function () {
                                                        qty += Number($(this)[0].value);
                                                    }); 
                                                    $('#' + lblTotalQty).val(qty);
                                                    $('#' + hdnTotalQuantity).val(qty);

                                                    $('#' + lblTotalQty).val(qty);
                                                    $('#' + hdnTotalQuantity).val(qty);

                                                    var tdSurcharge1 = '<%=tdSurcharge1.ClientID%>';
                                                    var tdSurchargePrice1 = '<%=tdSurchargePrice1.ClientID%>';
                                                    var tdSurchargeMargin1 = '<%=tdSurchargeMargin1.ClientID%>';
                                                    var txtSurcharge = '<%=txtSurcharge.ClientID%>';
                                                    var txtPriceWithSurcharge = '<%=txtPriceWithSurcharge.ClientID%>';
                                                    var txtMarginWithSurcharge = '<%=txtMarginWithSurcharge.ClientID%>';

                                                    /*if (qty > 5) {
                                                        // $('#tblSurcharge td:nth-child(4), td:nth-child(5), td:nth-child(6)').hide();
                                                        $('#' + tdSurcharge1).hide();
                                                        $('#' + tdSurchargePrice1).hide();
                                                        $('#' + tdSurchargeMargin1).hide();
                                                        $('#' + txtSurcharge).hide();
                                                        $('#' + txtPriceWithSurcharge).hide();
                                                        $('#' + txtMarginWithSurcharge).hide();
                                                    }
                                                    else {
                                                        // $('#tblSurcharge td:nth-child(4), td:nth-child(5), td:nth-child(6)').show();
                                                        $('#' + tdSurcharge1).show();
                                                        $('#' + tdSurchargePrice1).show();
                                                        $('#' + tdSurchargeMargin1).show();
                                                        $('#' + txtSurcharge).show();
                                                        $('#' + txtPriceWithSurcharge).show();
                                                        $('#' + txtMarginWithSurcharge).show();
                                                    }*/

                                                    var price_new_id = '<%=txtDistributorPrice.ClientID%>';
                                                    var price_with_surchage_id = '<%=txtPriceWithSurcharge.ClientID%>';
                                                    var totalValue = '<%=txtTotalValueSurcharge.ClientID%>';

                                                    $('#' + totalValue).val((qty * $('#' + price_new_id).val() * (1 + $('#' + txtSurcharge).val() / 100)).toFixed(2));

                                                    // var price = $('#'+txtPrice).val();
                                                    // $('#' + txtPrice).val(price * qty); 
                                                }

                                                function ClickVL(e) {
                                                    $(e).click();
                                                }
                                            </script>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                    <script>
                                        var tot_id = '<%=txtTotalValue.ClientID%>';
                                        var deliveryCA_id = '<%=txtDeliveryCharges.ClientID%>';
                                        var artworkCA_id = '<%=txtArtworkCharges.ClientID%>';
                                        var otherCA_id = '<%=txtOtherCharges.ClientID%>';
                                        var excludeGST_id = '<%=txtTotalValueExcludeGST.ClientID%>';
                                        var includeGST_id = '<%=txtGrandTotal.ClientID%>';
                                        var GST_id = '<%=txtGST.ClientID%>';
                                        var chkGST_id = '<%=chkIsGstExclude.ClientID%>';

                                        $(document).ready(function () {
                                            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
                                            function EndRequest(sender, args) {
                                                if (args.get_error() == undefined) {
                                                    BindTotal();
                                                }
                                            }

                                            BindTotal();

                                            function BindTotal() {
                                                $('#' + deliveryCA_id).bind('keyup', function () {
                                                    DisplyTotal();
                                                });

                                                $('#' + artworkCA_id).bind('keyup', function () {
                                                    DisplyTotal();
                                                });

                                                $('#' + otherCA_id).bind('keyup', function () {
                                                    DisplyTotal();
                                                });

                                                $('#' + chkGST_id).click(function () {
                                                    DisplyTotal();
                                                });

                                                DisplyTotal();
                                            }

                                            function DisplyTotal() {
                                                var deliveryCA = parseFloat($('#' + deliveryCA_id).val());
                                                var artworkCA = parseFloat($('#' + artworkCA_id).val());
                                                var otherCA = parseFloat($('#' + otherCA_id).val());
                                                var tot = parseFloat($('#' + tot_id).val());
                                                var grandTotal = (tot + deliveryCA + artworkCA + otherCA).toFixed(2);
                                                $('#' + excludeGST_id).val(grandTotal);

                                                if ($('#' + chkGST_id).is(':checked')) {
                                                    $('#' + GST_id).val('0.00');
                                                    $('#' + includeGST_id).val(grandTotal);
                                                }
                                                else {
                                                    $('#' + GST_id).val((grandTotal * 0.1).toFixed(2));
                                                    $('#' + includeGST_id).val((grandTotal * 1.1).toFixed(2));
                                                }
                                            }
                                        });
                                    </script>
                                    <script>
                                        var price_id = '<%=txtPrice.ClientID%>';
                                        var ptg_id = '<%=txtPercentage.ClientID%>';
                                        var price_new_id = '<%=txtDistributorPrice.ClientID%>';
                                        var surchage_id = '<%=txtSurcharge.ClientID%>';
                                        var price_with_surchage_id = '<%=txtPriceWithSurcharge.ClientID%>';
                                        var margin_with_surchage_id = '<%=txtMarginWithSurcharge.ClientID%>';
                                        var qty = '<%=txtTotalQty.ClientID%>';
                                        var totalValue = '<%=txtTotalValueSurcharge.ClientID%>';

                                        $(document).ready(function () {
                                            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
                                            function EndRequest(sender, args) {
                                                if (args.get_error() == undefined) {
                                                    BindEvents();
                                                }
                                            }

                                            function BindEvents() {
                                                $('#' + ptg_id).bind('keyup', function () {
                                                    var price = parseFloat($('#' + price_id).val());

                                                    if ($(this).val() != '0' && $(this).val() != '') {
                                                        $('#' + price_new_id).val((price / (1 - (parseFloat($(this).val() / 100)))).toFixed(2));
                                                    }
                                                    else {
                                                        $('#' + price_new_id).val('0');
                                                    }

                                                    // Get indiman price
                                                    var price = parseFloat($('#' + price_id).val());

                                                    // Get the distributor value
                                                    var distributorValue = parseFloat($('#' + price_new_id).val());

                                                    // Get the surcharge value
                                                    var surchargeValue = parseFloat($('#' + surchage_id).val());

                                                    // Update the price with surchage and margin surchage if surchage has value menas more than 0 or not empty
                                                    if ($('#' + surchargeValue).val() != '0' && $('#' + surchargeValue).val() != '') {
                                                        $('#' + price_with_surchage_id).val((distributorValue * (1 + (surchargeValue / 100))).toFixed(2));
                                                        $('#' + margin_with_surchage_id).val((100 * (1 - (price / parseFloat($('#' + price_with_surchage_id).val())))).toFixed(2));
                                                        $('#' + totalValue).val(($('#' + qty).val() * $('#' + price_new_id).val() * (1 + surchargeValue / 100)).toFixed(2));
                                                    }
                                                });

                                                $('#' + price_new_id).bind('keyup', function () {
                                                    var price = parseFloat($('#' + price_id).val());

                                                    if ($(this).val() != '0' && $(this).val() != '') {
                                                        $('#' + ptg_id).val((100 * (1 - (price / parseFloat($(this).val())))).toFixed(2));
                                                    }
                                                    else {
                                                        $('#' + ptg_id).val('0');
                                                    }

                                                    // Get indiman price
                                                    var price = parseFloat($('#' + price_id).val());

                                                    // Get the distributor value
                                                    var distributorValue = parseFloat($('#' + price_new_id).val());

                                                    // Get the surcharge value
                                                    var surchargeValue = parseFloat($('#' + surchage_id).val());

                                                    // Update the price with surchage and margin surchage if surchage has value menas more than 0 or not empty
                                                    if ($('#' + surchargeValue).val() != '0' && $('#' + surchargeValue).val() != '') {
                                                        $('#' + price_with_surchage_id).val((distributorValue * (1 + (surchargeValue / 100))).toFixed(2));
                                                        $('#' + margin_with_surchage_id).val((100 * (1 - (price / parseFloat($('#' + price_with_surchage_id).val())))).toFixed(2));
                                                        $('#' + totalValue).val(($('#' + qty).val() * $('#' + price_new_id).val() * (1 + surchargeValue / 100)).toFixed(2));
                                                    }
                                                });

                                                $('#' + surchage_id).bind('keyup', function () {
                                                    // Get indiman price
                                                    var price = parseFloat($('#' + price_id).val());

                                                    // Get the distributor value
                                                    var distributorValue = parseFloat($('#' + price_new_id).val());

                                                    // Get the surcharge value
                                                    var surchargeValue = parseFloat($('#' + surchage_id).val());

                                                    if (surchargeValue >= 0.0 && $(this).val() != '') {
                                                        $('#' + price_with_surchage_id).val((distributorValue * (1 + (surchargeValue / 100))).toFixed(2));
                                                        $('#' + margin_with_surchage_id).val((100 * (1 - (price / parseFloat($('#' + price_with_surchage_id).val())))).toFixed(2));
                                                        $('#' + totalValue).val(($('#' + qty).val() * $('#' + price_new_id).val() * (1 + surchargeValue / 100)).toFixed(2));
                                                    }
                                                });
                                            }

                                            BindEvents();
                                        });
                                    </script>
                                    <div class="control-group">
                                        <label class="control-label">
                                            Deduct Reservations
                                        </label>
                                        <div class="controls">
                                            <telerik:RadComboBox ID="RadComboReservations" runat="server" HighlightTemplatedItems="true"
                                                Skin="Metro" CssClass="RadComboBox_Metro" AutoPostBack="true" DropDownWidth="650" OnSelectedIndexChanged="RadComboReservations_SelectedIndexChanged"
                                                OnItemDataBound="RadComboReservations_ItemDataBound" DataTextField="ReservationNo"
                                                EmptyMessage="Select Reservation" EnableLoadOnDemand="true" Filter="StartsWith">
                                                <HeaderTemplate>
                                                    <table style="width: 100%" cellspacing="0" cellpadding="0">
                                                        <tr>
                                                            <td style="width: 15%;">Reservation
                                                            </td>
                                                            <td style="width: 15%;">Order Week
                                                            </td>
                                                            <td style="width: 20%;">ETD
                                                            </td>
                                                            <td style="width: 20%;">Distibutor
                                                            </td>
                                                            <td style="width: 20%;">Client
                                                            </td>
                                                            <td style="width: 10%;">Status
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <table style="width: 100%" cellspacing="0" cellpadding="0">
                                                        <tr>
                                                            <td style="width: 15%;">
                                                                <asp:Literal ID="litReservation" runat="server"></asp:Literal>
                                                            </td>
                                                            <td style="width: 15%;">
                                                                <asp:Literal ID="litOrderWeek" runat="server"></asp:Literal>
                                                            </td>
                                                            <td style="width: 20%;">
                                                                <asp:Literal ID="litETD" runat="server"></asp:Literal>
                                                            </td>
                                                            <td style="width: 20%;">
                                                                <asp:Literal ID="litDistributor" runat="server"></asp:Literal>
                                                            </td>
                                                            <td style="width: 20%;">
                                                                <asp:Literal ID="litClient" runat="server"></asp:Literal>
                                                            </td>
                                                            <td style="width: 10%;">
                                                                <asp:Literal ID="litStatus" runat="server"></asp:Literal>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ItemTemplate>
                                            </telerik:RadComboBox>
                                            <asp:Label ID="litReservationDetail" runat="server" Visible="false"></asp:Label>
                                        </div>
                                    </div>
                                    <asp:UpdatePanel ID="updateVlImage" runat="server">
                                        <ContentTemplate>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                    <!-- name and nunber file -->
                                    <div class="control-group">
                                        <label class="control-label">
                                            Are name and numbers required</label>
                                        <div class="controls">
                                            <div class="">
                                                <label class="radio inline">
                                                    <asp:RadioButton ID="rbNaNuYes" runat="server" GroupName="NaNurequired" />
                                                    Yes
                                                </label>
                                                <label class="radio inline">
                                                    <asp:RadioButton ID="rbNaNuNo" runat="server" Checked="true" GroupName="NaNurequired" />
                                                    No
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="control-group">
                                        <label class="control-label">
                                        </label>
                                        <div class="controls" id="dvFilePreview" runat="server">
                                            <table id="uploadtable_1" class="file_upload_files" multirow="false" setdefault="false" ishide="true">
                                                <%-- <asp:Repeater ID="rptUploadFile" runat="server">
                                                    <ItemTemplate>--%>
                                                <tr id="tableRowfileUpload">
                                                    <td class="file_preview">
                                                        <asp:Image ID="uploadImage" Height="" Width="" runat="server" ImageUrl="" class="img-circle" />
                                                    </td>
                                                    <td class="file_name">
                                                        <asp:Literal ID="litfileName" runat="server"></asp:Literal>
                                                    </td>
                                                    <td id="filesize" class="file_size" runat="server">
                                                        <asp:Literal ID="litfileSize" runat="server"></asp:Literal>
                                                    </td>
                                                    <td class="file_delete">
                                                        <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn btn-link ideletefile" ToolTip="Delete File"><i class="icon-trash"></i></asp:HyperLink>
                                                        <asp:HiddenField ID="hdnDeleteFile" runat="server" />
                                                    </td>
                                                </tr>
                                                <%-- </ItemTemplate>
                                                </asp:Repeater>--%>
                                            </table>
                                            <input id="hdnUploadFiles" runat="server" name="hdnUploadFiles" type="hidden" value="" />
                                        </div>
                                    </div>
                                    <div class="control-group" id="lifileUploder" runat="server">
                                        <label class="control-label">
                                            Upload Names & Numbers File</label>
                                        <div class="controls">
                                            <div id="dropzone_1" class="fileupload preview single hide-dropzone setdefault">
                                                <input id="file_1" name="file_1" type="file" />
                                                <button id="btnup_1" type="submit">
                                                    Upload</button>
                                                <div id="divup_1">
                                                    Drag file here or click to upload
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div id="dvNotification" runat="server">
                                        <label class="control-label ">
                                        </label>
                                        <p class="extra-helper">
                                            <span class="label label-info">Hint:</span> You can drag & drop files from your
                                            desktop on this webpage with Google Chrome, Mozilla Firefox and Apple Safari.                                                                                   
                                        </p>
                                    </div>
                                    <div>
                                        <label class="control-label ">
                                        </label>
                                        <p class="extra-helper">
                                            <b>You can upload excel or word files only. </b>
                                        </p>
                                    </div>
                                    <!-- / -->
                                    <div class="iclearfix icenter">
                                        <button id="btnCancelOrder" runat="server" class="btn" causesvalidation="false" onserverclick="btnCancelOrder_ServerClick">Cancel</button>
                                        <button id="btnAddOrder" runat="server" class="btn btn-success" validationgroup="valGrpOrderHeader"
                                            data-loading-text="Adding..." type="submit" onserverclick="btnAddOrder_Click">
                                            Add Order Detail</button>
                                    </div>
                                </div>
                                <div class="span4">
                                </div>
                            </div>

                        </div>
                    </div>
                </div>
                <div id="dvBillingDetails" runat="server" class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#<%=collapse5.ClientID%>">Other Charges</a>
                    </div>
                    <div id="collapse5" runat="server" class="accordion-body collapse">
                        <div class="accordion-inner">
                            <div class="control-group">
                                <label class="control-label">
                                    Total Value</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtTotalValue" runat="server" Text="0" CssClass="input-medium" Style="text-align: right" Enabled="false"></asp:TextBox>
                                    <label class="checkbox inline" id="lblTotalQty" runat="server"></label>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Delivery Charges Amount</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtDeliveryCharges" runat="server" Text="0" CssClass="input-medium" Style="text-align: right"></asp:TextBox>
                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator2" ControlToValidate="txtDeliveryCharges" ValidationGroup="valGrpOrderHeader" EnableClientScript="false"
                                        runat="server" ErrorMessage="Decimal values only." Display="Dynamic" ValidationExpression="^[0-9]*(\.[0-9]{1,2})?$">
                                        <img src="Content/img/icon_warning.png"  title="Decimal values only." alt="Decimal values only."" />
                                    </asp:RegularExpressionValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Artwork Charges Amount</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtArtworkCharges" runat="server" Text="0" CssClass="input-medium" Style="text-align: right"></asp:TextBox>
                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator3" ControlToValidate="txtArtworkCharges" ValidationGroup="valGrpOrderHeader" EnableClientScript="false"
                                        runat="server" ErrorMessage="Decimal values only." Display="Dynamic" ValidationExpression="^[0-9]*(\.[0-9]{1,2})?$">
                                         <img src="Content/img/icon_warning.png"  title="Decimal values only." alt="Decimal values only."" />
                                    </asp:RegularExpressionValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Other Charges Amount</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtOtherCharges" runat="server" Text="0" CssClass="input-medium" Style="text-align: right"></asp:TextBox>
                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator4" ControlToValidate="txtOtherCharges" ValidationGroup="valGrpOrderHeader" EnableClientScript="false"
                                        runat="server" ErrorMessage="Decimal values only." Display="Dynamic" ValidationExpression="^[0-9]*(\.[0-9]{1,2})?$">
                                         <img src="Content/img/icon_warning.png"  title="Decimal values only." alt="Decimal values only."" />
                                    </asp:RegularExpressionValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Other Charges Description</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtOtherChargesDescription" runat="server" TextMode="MultiLine" Text="" CssClass="ismall"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Total Excluding GST</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtTotalValueExcludeGST" runat="server" Text="0" CssClass="input-medium" Style="text-align: right" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    GST (10%)</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtGST" runat="server" Text="0" CssClass="input-medium" Style="text-align: right" Enabled="false"></asp:TextBox>
                                    <label class="checkbox inline">
                                        <asp:CheckBox ID="chkIsGstExclude" runat="server" />
                                        Exclude GST
                                    </label>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Total Including GST</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtGrandTotal" runat="server" Text="0" CssClass="input-medium" Style="text-align: right" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <div class="controls">
                                    <label class="checkbox inline">
                                        <asp:CheckBox ID="chkTAndC" runat="server" />
                                        Signed Acceptance to Terms and Conditions received ;
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="form-actions">
                    <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_Click"
                        data-loading-text="Saving..." type="submit" validationgroup="valGrpOrderHeader">
                        Save Changes</button>
                    <button id="btnPrint" runat="server" class="btn btn-primary" type="submit" validationgroup="valGrpOrderHeader" onserverclick="btnPrint_ServerClick">
                        Save and Print                                       
                    </button>
                    <button id="btnSubmit" visible="false" runat="server" class="btn btn-primary" type="submit" validationgroup="valGrpOrderHeader" onserverclick="btnSubmit_ServerClick">
                        Save and Submit                                       
                    </button>
                    <button id="btnClose" runat="server" class="btn btn-default" type="submit" causesvalidation="false" onserverclick="btnClose_ServerClick">
                        Cancel                                       
                    </button>

                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
        <!-- / -->
        <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnEditType" runat="server" Value="Edit" />
        <asp:HiddenField ID="hdncancelledorderdetail" runat="server" Value="0" />
        <asp:HiddenField ID="hdnSelectedClientId" runat="server" Value="0" />
        <asp:HiddenField ID="hdnSelectedDistributorId" runat="server" Value="0" />
        <asp:HiddenField ID="hdnSelectedDisClientAddress" runat="server" Value="0" />
        <asp:HiddenField ID="hdnTotalQuantity" runat="server" Value="0" />
        <!-- Delete Item -->
        <div id="requestDeleteOrder" class="modal fade" role="dialog" aria-hidden="true"
            keyboard="false" data-backdrop="static">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    ×</button>
                <h3>Delete Order Detail</h3>
            </div>
            <div class="modal-body">
                <p>
                    Are you sure you wish to delete this order detail?
                </p>
            </div>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">
                    Close</button>
                <button id="btnDeleteOrderItem" runat="server" class="btn btn-primary" type="submit"
                    data-loading-text="Deleting..." onserverclick="btnDeleteOrderItem_Click">
                    Yes</button>
            </div>
        </div>
        <!-- / -->
        <!-- Cancel Order Detail -->
        <div id="dvCancelledOrder" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
            data-backdrop="static">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    ×</button>
                <h3>Cancel Order Detail</h3>
            </div>
            <div class="modal-body">
                <p>
                    Are you sure to cancel this order detail?
                </p>
            </div>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">
                    No</button>
                <button id="btnCancelled" runat="server" class="btn btn-primary" onserverclick="btnCancelled_ServerClick"
                    data-loading-text="Saving..." type="submit">
                    Yes</button>
            </div>
        </div>
        <!-- / -->
        <!-- Delete Existing Order Items -->
        <div id="requestDeleteOrders" class="modal fade" role="dialog" aria-hidden="true"
            keyboard="false" data-backdrop="static">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    ×</button>
                <h3>Delete Order Items</h3>
            </div>
            <div class="modal-body">
                <p>
                    There are some order items associated with this client,Are you sure you wish to
                delete this order items?
                </p>
            </div>
            <div class="modal-footer">
                <button id="btnDeleteOrderItemsCancel" runat="server" class="btn btn-default" type="submit"
                    onserverclick="btnDeleteOrderItemsCancel_Click">
                    No</button>
                <button id="btnDeleteOrderItems" runat="server" class="btn btn-primary" type="submit"
                    data-loading-text="Deleting..." onserverclick="btnDeleteOrderItems_Click">
                    Yes</button>
            </div>
        </div>
        <!-- / -->
        <!-- Shiping Address Details-->
        <div id="dvShipmentAddress" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
            data-backdrop="static">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    ×</button>
                <h3>Address Details</h3>
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
                            Address Type</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlAdderssType" runat="server"></asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvAddressType" runat="server" CssClass="error" ValidationGroup="validShiipingAddress"
                                InitialValue="-1" ControlToValidate="ddlAdderssType" Display="Dynamic" EnableClientScript="false"
                                ErrorMessage="Address Type is required">
                                <img src="Content/img/icon_warning.png" title="Address Type is required" alt="Address Type is required" />
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
                            Email</label>
                        <div class="controls">
                            <asp:TextBox ID="txtShipToEmail" runat="server"></asp:TextBox>
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
                        <label class="control-label">
                            Port</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlShipToPort" runat="server"></asp:DropDownList>
                        </div>
                    </div>
                </fieldset>
            </div>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">
                    Close</button>
                <button id="btnSaveShippingAddress" runat="server" class="btn btn-primary" type="submit"
                    validationgroup="validShiipingAddress" data-loading-text="Saving..." onserverclick="btnSaveShippingAddress_Click">
                    Save</button>
                <asp:HiddenField ID="hdnAddressID" runat="server" />
                <asp:HiddenField ID="hdnAddressType" runat="server" />
            </div>
        </div>
        <!--/-->
        <!-- Client-->
        <div id="dvClient" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
            data-backdrop="static">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    ×</button>
                <h3>Client Details</h3>
            </div>
            <div class="modal-body">
                <!-- Validation-->
                <asp:ValidationSummary ID="vsClient" runat="server" CssClass="alert alert-danger"
                    ValidationGroup="validClient" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->
                <fieldset>
                    <div class="control-group" runat="server" id="dvClientDistributor" visible="false">
                        <label class="control-label required">
                            Distributor</label>
                        <div class="controls">
                            <asp:Label ID="lblClientDistributor" runat="server"></asp:Label>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Name</label>
                        <div class="controls">
                            <asp:TextBox ID="txtClientName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvClientName" runat="server" CssClass="error" ValidationGroup="validClient"
                                ControlToValidate="txtClientName" Display="Dynamic" EnableClientScript="false"
                                ErrorMessage="Client Name is required">
                                <img src="Content/img/icon_warning.png" title="Client Name is required" alt="Client Name is required" />
                            </asp:RequiredFieldValidator>
                            <asp:CustomValidator ID="cvTxtClientName" runat="server" OnServerValidate="cvTxtClientName_ServerValidate" ErrorMessage="Name is already in use" ValidationGroup="validClient"
                                ControlToValidate="txtClientName" EnableClientScript="false">
                             <img src="Content/img/icon_warning.png"  title="Name is already in use" alt="Name is already in use" />
                            </asp:CustomValidator>
                        </div>
                    </div>
                </fieldset>
            </div>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">
                    Close</button>
                <button id="btnSaveClient" runat="server" class="btn btn-primary" type="submit"
                    validationgroup="validClient" data-loading-text="Saving..." onserverclick="btnSaveClient_ServerClick">
                    Save</button>
                <asp:HiddenField ID="hdnClientID" runat="server" />
            </div>
        </div>
        <!--/-->
        <!-- Job Name-->
        <div id="addjobName" class="modal fade" role="dialog" aria-hidden="true" keyboard="false">
            <asp:UpdatePanel runat="server" ID="UpdateJobName" UpdateMode="Always">
                <ContentTemplate>
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                            ×</button>
                        <h3 id="titleJobName">New Job Name</h3>
                    </div>
                    <div class="modal-body">
                        <!-- Validation-->
                        <asp:ValidationSummary ID="vsNewJobName" runat="server" CssClass="alert alert-danger"
                            ValidationGroup="newJobName" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                        <!-- / -->
                        <fieldset>
                            <%-- <div class="control-group">
                                <label class="control-label required">
                                    Client</label>
                                <div class="controls">
                                    <asp:DropDownList CssClass="input-xlarge" ID="ddlJobNameClient" runat="server" Enabled="false">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvJobNameClient" runat="server" ErrorMessage="Client is required" Display="Dynamic" ValidationGroup="newJobName"
                                        ControlToValidate="ddlJobNameClient" InitialValue="0" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Client is required" alt="Client is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>--%>
                            <div class="control-group">
                                <label class="control-label required">
                                    Job Name</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtNewJobName" runat="server"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvNewJobName" runat="server" CssClass="error" ValidationGroup="newJobName"
                                        ControlToValidate="txtNewJobName" Display="Dynamic" EnableClientScript="false"
                                        ErrorMessage="Job Name is required">
                                <img src="Content/img/icon_warning.png" title="Job Name is required" alt="Job Name is required" />
                                    </asp:RequiredFieldValidator>
                                    <asp:CustomValidator ID="cfvJobName" runat="server" OnServerValidate="cfvJobName_ServerValidate" ErrorMessage="Name is already in use" ValidationGroup="newJobName"
                                        ControlToValidate="txtNewJobName" EnableClientScript="false">
                             <img src="Content/img/icon_warning.png"  title="Name is already in use" alt="Name is already in use" />
                                    </asp:CustomValidator>
                                </div>
                            </div>
                        </fieldset>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">
                    Close</button>
                <button id="btnSaveJobName" runat="server" class="btn btn-primary" type="submit"
                    validationgroup="newJobName" data-loading-text="Saving..." onserverclick="btnSaveJobName_ServerClick">
                    Save</button>
                <asp:HiddenField ID="hdnEditJobNameID" runat="server" Value="0" />
            </div>
        </div>
        <!-- Shiping Address Details-->
        <div id="requestDeleteFile" class="modal fade" role="dialog" aria-hidden="true"
            keyboard="false" data-backdrop="static">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    ×</button>
                <h3>Delete Name and Numbers File</h3>
            </div>
            <div class="modal-body">
                <p>
                    Are you sure you wish to delete this name and numbers file?
                </p>
            </div>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">
                    No</button>
                <button id="btnDeleteFile" runat="server" class="btn btn-primary" text="" onserverclick="btnDeleteFile_ServerClick"
                    type="submit">
                    Yes</button>
            </div>
        </div>
        <!--/-->
        <!-- Date Confirmation-->
        <div id="dvDateConfirmation" class="modal fade" role="dialog" aria-hidden="true"
            keyboard="true" data-backdrop="static">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    ×</button>
                <h3>Confirm Shipment Date</h3>
            </div>
            <div class="modal-body">
                <p>
                    Shipment lead time is not adequate.
                </p>
            </div>
            <div class="modal-footer">
                <%-- <button class="btn" data-dismiss="modal" aria-hidden="true">
                    No</button>--%>
                <button data-dismiss="modal" class="btn btn-primary" aria-hidden="true">Continue</button>
            </div>
        </div>
        <!--/-->
        <!-- Page Scripts -->
        <script type="text/javascript">
            var PopulateDeleteOrdersMsg = ('<%=ViewState["PopulateDeleteOrdersMsg"]%>' == 'True') ? true : false;
            var PopulateShippingAddress = ('<%=ViewState["PopulateShippingAddress"]%>' == 'True') ? true : false;
            var PopulateClient = ('<%=ViewState["PopulateClient"]%>' == 'True') ? true : false;
            var PopulateJobName = ('<%=ViewState["PopulateJobName"]%>' == 'True') ? true : false;
            var PopulateScrolling = ('<%=ViewState["PopulateScrolling"]%>' == 'True') ? true : false;

            //  Ship to Details
            var rbWeeklyShipment = "<%=rbWeeklyShipment.ClientID %>";
            var rbCourier = "<%=rbCourier.ClientID %>";
            var hdncancelledorderdetail = "<%=hdncancelledorderdetail.ClientID %>";
            var txtDate = "<%=txtDate.ClientID %>";
            var txtDesiredDate = '<%=txtDesiredDate.ClientID%>';
            var ddlClient = "<%=ddlClient.ClientID %>";
            var ddlJobName = "<%=ddlJobName.ClientID %>";
            var ddlBillingAddress = "<%=ddlBillingAddress.ClientID %>";
            var ddlDespatchAddress = "<%=ddlDespatchAddress.ClientID %>";
            var ddlCourierAddress = "<%=ddlCourierAddress.ClientID %>";
            var ddlDistributor = "<%=ddlDistributor.ClientID %>";
            var ddlMYOBCardFile = "<%=ddlMYOBCardFile.ClientID %>";
            var ddlVlNumber = "<%=ddlVlNumber.ClientID %>";
            var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
            var hdnUploadFiles = "<%=hdnUploadFiles.ClientID %>";
            var lblTotalQty = "<%=txtTotalQty.ClientID %>";
            var ancNewPaymentMethod = "<%=ancNewPaymentMethod.ClientID %>";
            var ddlDistributor = "<%=ddlDistributor.ClientID %>";
            var txtOdNotes = "<%=txtOdNotes.ClientID %>";
            var ddlShipmentMode = "<%=ddlShipmentMode.ClientID %>";
            var hdnEditType = "<%=hdnEditType.ClientID %>";
            var ddlAdderssType = "<%=ddlAdderssType.ClientID %>";
            var hdnTotalQuantity = "<%=hdnTotalQuantity.ClientID %>";
            var billingDetails = "<%=dvBillingDetails.ClientID %>";
            var hdnAddressID = "<%=hdnAddressID.ClientID %>";
            var hdnClientID = "<%=hdnClientID.ClientID %>";
            var hdnEditJobNameID = "<%=hdnEditJobNameID.ClientID %>";
            var rbVisualLayout = "<%=rbVisualLayout.ClientID %>";
            var rbPatternFabric = "<%=rbPatternFabric.ClientID %>";
            var ddlPattern = "<%=ddlPattern.ClientID %>";
            var ddlFabric = "<%=ddlFabric.ClientID %>";
            var txtNewJobName = "<%=txtNewJobName.ClientID %>";
            var txtShipmentDate = "<%=txtShipmentDate.ClientID%>";
        </script>
        <script type="text/javascript">
            $(document).ready(function () {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
                function EndRequest(sender, args) {
                    if (args.get_error() == undefined) {
                        BindPopupEvents();
                    }
                }

                BindPopupEvents();

                $('.icancelled').click(function () {
                    $('#' + hdncancelledorderdetail).val($(this).attr('qid'));
                    $('#dvCancelledOrder').modal('show');
                });

                if (PopulateScrolling) {
                    event.preventDefault();

                    var target = $('#linkorderdetail')[0].hash;
                    $target = $(target);

                    $('html,body').animate({ scrollTop: $target.offset().top }, 400);
                }

                $('.idelete').click(function () {
                    $('#' + hdnSelectedID).val($(this).attr('qid'));
                    $('#requestDeleteOrder').modal('show');
                });

                $('#' + ancNewPaymentMethod).click(function () {
                    resetFieldsDefault('requestAddPaymentMethod');
                    $('div.alert-danger, span.error').hide();
                    $('#requestAddPaymentMethod').modal('show');
                    $('#dvShipmentMethod').modal('hide');
                });

                $('#' + txtShipmentDate).change(function () {
                    var clientDate = parseDate($('#' + txtDesiredDate).val());
                    var shipmentDate = parseDate($('#' + txtShipmentDate).val());

                    var dateDif = (clientDate - shipmentDate) / 1000 / 60 / 60 / 24;

                    if (dateDif < 6) {
                        $('#dvDateConfirmation').modal('show');
                    }
                });

                function parseDate(s) {
                    var months = {
                        january: 0, february: 1, march: 2, april: 3, may: 4, june: 5,
                        july: 6, august: 7, september: 8, october: 9, november: 10, december: 11
                    };
                    var p = s.split(' ');
                    return new Date(p[2], months[p[1].toLowerCase()], p[0]);
                }

                $('.iaddress').click(function () {
                    resetFieldsDefault('ViewDistributorAddressDetails');
                    $('div.alert-danger, span.error').hide();
                    $('#ViewDistributorAddressDetails').modal('show');
                    $('#' + hdnDistributorType).val('distributor');
                });

                $('.iintiger').keyup(function () {
                    calculateTotalQty();
                });

                $('.ideletefile').click(function () {
                    $('#requestDeleteFile').modal('show');
                });

                function calculateTotalQty() {
                    var qty = 0;
                    $('#olSizeQuantities input[type=text]').each(function () {
                        qty += Number($(this)[0].value);
                    });
                    $('#' + lblTotalQty).val(qty); $('#' + hdnTotalQuantity).val(qty);
                }

                if (PopulateClient) {
                    $('#dvClient').modal('show');
                }

                if (PopulateJobName) {
                    $('#addjobName').modal('show');
                }

                if (PopulateShippingAddress) {
                    $('#dvShipmentAddress').modal('show');
                }

                if (PopulateDeleteOrdersMsg) {
                    window.setTimeout(function () {
                        $('#requestDeleteOrders').modal('show');
                    }, 10);
                }

                function BindPopupEvents() {
                    SetDespatchDiv();
                    SetOrderDetailDiv();

                    calculateTotalQty();

                    $('.datepicker').datepicker({ format: 'dd MM yyyy' });

                    $('#' + ddlClient).select2();
                    $('#' + ddlJobName).select2();
                    $('#' + ddlBillingAddress).select2();
                    $('#' + ddlDespatchAddress).select2();
                    $('#' + ddlCourierAddress).select2();
                    $('#' + ddlDistributor).select2();
                    $('#' + ddlMYOBCardFile).select2();
                    $('#' + ddlPattern).select2();
                    $('#' + ddlFabric).select2();
                }
            });
        </script>
        <script type="text/javascript">
            function SetDespatchDiv() {
                if ($('#' + rbCourier).is(':checked')) {
                    $('#dvOdDespatchAddress').show();
                }
                else {
                    $('#dvOdDespatchAddress').hide();
                }
            }

            function SetOrderDetailDiv() {
                if ($('#' + rbVisualLayout).is(':checked')) {
                    $('.ifromVisualLayout').show();
                    $('.ifromPattern').hide();
                }
                else {
                    $('.ifromPattern').show();
                    $('.ifromVisualLayout').hide();
                }
            }

            function ShowPopUpEdit() {
                $('#' + hdnDistributorType).val('distributor');
                $('.editAddress').click();
            }

            function ShipmentAddress(e) {
                if ($(e).val() > 0) {
                    $('.iedidshipping').show();
                }
                else {
                    $('.iedidshipping').hide();
                }
            }

            function SaveAddress() {
                $('#' + btnSaveDistributorAddress).click();
            }

            function AddNewShipmentAddress(addressType) {
                resetFieldsDefault('dvShipmentAddress');
                $('#' + hdnAddressID).val('0');
                $('div.alert-danger, span.error').hide();
                $('#dvShipmentAddress').modal('show');
                //if (addressType isBilling) {
                //    $('#' + hdnEditType).val('Billing');
                //}
                //else {
                //    $('#' + hdnEditType).val('Despatch');
                //}

                $('#' + hdnEditType).val(addressType);
            }

            function AddNewClient() {
                resetFieldsDefault('dvClient');
                $('#' + hdnClientID).val('0');
                $('div.alert-danger, span.error').hide();
                $('#dvClient').modal('show');
            }

            function AddNewJobName() {
                $('div.alert-danger, span.error').hide();
                $('#addjobName').modal('show');
                $('#titleJobName').text('New Job Name');
                $('#' + txtNewJobName).val('');
                $('#' + hdnEditJobNameID).val('0');
                $('#' + hdnSelectedID).val('New');
            }

            $('.accordion-toggle').click(function () {

                //if ($('#' + billingDetails).click())
                //{
                $('.collapse').collapse('hide')
                //$('.collapse').collapse({toggle: false})
                // $('.accordion-toggle').addClass('collapsed');
                // $(this).addClass('collapse');
                //}
            });
        </script>
        <!-- / -->
</asp:Content>
