<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true" EnableEventValidation="false"
    CodeBehind="AddEditOrder.aspx.cs" Inherits="Indico.AddEditOrder" MaintainScrollPositionOnPostback="true" %>

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
                <div id="dvOrderDetails" runat="server" class="accordion-group">
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
                            <div id="liDistributor" runat="server" class="control-group">
                                <label class="control-label required">
                                    Distributor</label>
                                <div class="controls">
                                    <asp:DropDownList CssClass="input-xxlarge" ID="ddlDistributor" runat="server" EnableViewState="true">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvDistributor" runat="server" ErrorMessage="Distributor is required."
                                        ControlToValidate="ddlDistributor" InitialValue="0" EnableClientScript="false"
                                        Display="Dynamic" ValidationGroup="valGrpOrderHeader">
                                            <img src="Content/img/icon_warning.png"  title="Distributor is required." alt="Distributor is required." />
                                    </asp:RequiredFieldValidator>
                                    <asp:Label ID="lblDistributorAddress" runat="server" Visible="false"></asp:Label>
                                </div>
                            </div>
                            <div id="liClient" runat="server" class="control-group">
                                <label class="control-label required">
                                    Client</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlClient" CssClass="input-xxlarge" runat="server" EnableViewState="true">
                                    </asp:DropDownList>
                                    <a id="aAddClient" runat="server" class="btn btn-link iClient" onclick="javascript:AddNewClient();" title="Add New Client"><i class="icon-plus"></i></a>
                                    <span id="dvClientDetails" runat="server" enableviewstate="true"></span>
                                    <asp:LinkButton ID="btnEditClient" runat="server" class="btn btn-link" title="Edit Client" OnClick="btnEditClient_Click"><i class="icon-pencil"></i></asp:LinkButton>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Job Name</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlJobName" CssClass="input-xxlarge" runat="server" EnableViewState="true">
                                    </asp:DropDownList>
                                    <a id="ancNewJobName" runat="server" class="btn btn-link" onclick="javascript:AddNewJobName();" title="Add New Job Name"><i class="icon-plus"></i></a>
                                    <asp:Label ID="lblJobName" runat="server" EnableViewState="true"></asp:Label>
                                    <asp:LinkButton ID="btnEditJobName" runat="server" class="btn btn-link" OnClick="btnEditJobName_Click" ToolTip="Edit JobName"><i class="icon-pencil"></i></asp:LinkButton>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Billing Address</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlBillingAddress" CssClass="input-xxlarge" runat="server" EnableViewState="true">
                                    </asp:DropDownList>
                                    <a id="aAddShippingAddress" runat="server" class="btn btn-link ishippingAddress" onclick="javascript:AddNewShipmentAddress('Billing');" title="Add New Address Details"><i class="icon-plus"></i></a>
                                    <asp:Label ID="lblBillingAddress" runat="server" EnableViewState="true"></asp:Label>
                                    <asp:LinkButton ID="btnEditBilling" runat="server" class="btn btn-link" OnClick="btnEditBilling_Click" ToolTip="Edit Billing Address"><i class="icon-pencil"></i></asp:LinkButton>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Despatch Address</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlDespatchAddress" CssClass="input-xxlarge" runat="server" EnableViewState="true">
                                    </asp:DropDownList>
                                    <a id="ancDespatchAddress" runat="server" class="btn btn-link ishippingAddress" onclick="javascript:AddNewShipmentAddress('Despatch');" title="Add New Address Details"><i class="icon-plus"></i></a>
                                    <asp:Label ID="lblDespatchAddress" runat="server" EnableViewState="true"></asp:Label>
                                    <asp:LinkButton ID="btnEditDespatch" runat="server" class="btn btn-link" OnClick="btnEditDespatch_Click" ToolTip="Edit Despatch Address"><i class="icon-pencil"></i></asp:LinkButton>
                                </div>
                            </div>
                            <div id="liOrderStatus" runat="server" class="control-group" visible="false">
                                <label class="control-label">
                                    Order Status</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlStatus" CssClass="input-medium" runat="server">
                                    </asp:DropDownList>
                                </div>
                            </div>
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
                                        <asp:DropDownList ID="ddlCourierAddress" CssClass="input-xlarge" runat="server">
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
                <div id="dvODDetail" runat="server" class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" id="linkorderdetail" data-toggle="collapse" href="#<%=collapse2.ClientID%>">Order
                            Details</a>
                    </div>
                    <div id="collapse2" runat="server" class="accordion-body collapse">
                        <div class="accordion-inner">
                            <div style="padding-bottom: 40px">
                                <span style="float: left">
                                    <asp:LinkButton class="btn btn-info" runat="server" ID="btnNewOrderDetail" OnClick="btnNewOrderDetail_Click" Text="New Order Detail" />
                                </span>
                            </div>
                            <%--<span  style="padding-right:10px"> <a id="ancNewOrderDetail" >Add New Order Detail</a></span>                      --%>
                            <!-- Data Table -->
                            <asp:DataGrid ID="dgOrderItems" runat="server" CssClass="table" AllowCustomPaging="False"
                                AllowPaging="False" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                                OnItemDataBound="dgOrderItems_ItemDataBound">
                                <HeaderStyle CssClass="header" />
                                <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                                <Columns>                                    
                                    <asp:TemplateColumn HeaderText="Number">
                                        <ItemTemplate>
                                            <asp:Literal ID="lblIndex" runat="server" Text=""></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
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

                                    <asp:TemplateColumn HeaderText="Name & Number File">
                                        <ItemTemplate>
                                            <a id="ancNameNumberFile" runat="server" title="Name & Number File" href="javascript:void(0);">
                                                <i id="iNameNumberFile" runat="server" class="icon-eye-ok"></i></a><a id="ancDownloadNameAndNumberFile"
                                                    class="btn btn-link idownload" title="Download" runat="server" onserverclick="ancDownloadNameAndNumberFile_Click">
                                                    <i class="icon-download-alt"></i></a>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Dis. Edited Price">
                                        <ItemTemplate>
                                            <div class="input-append">
                                                <asp:TextBox ID="txtEditedPrice" runat="server" CssClass="input-mini"></asp:TextBox>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Surcharge">
                                        <ItemTemplate>
                                            <asp:Literal ID="lblSurcharge" runat="server" Text=""></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Qty">
                                        <ItemTemplate>
                                            <asp:Literal ID="lblQty" runat="server" Text=""></asp:Literal>
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
                        </div>
                    </div>
                </div>
                <div id="dvBillingDetails" runat="server" class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#<%=collapse3.ClientID%>">Other Charges</a>
                    </div>
                    <div id="collapse3" runat="server" class="accordion-body collapse">
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
                                        <img src="Content/img/icon_warning.png"  title="Decimal values only." alt="Decimal values only." />
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
                                         <img src="Content/img/icon_warning.png"  title="Decimal values only." alt="Decimal values only." />
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
                                         <img src="Content/img/icon_warning.png"  title="Decimal values only." alt="Decimal values only." />
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
        <asp:HiddenField ID="hdnSelectedIndex" runat="server" Value="0" />
        <asp:HiddenField ID="hdnEditType" runat="server" Value="Edit" />
        <asp:HiddenField ID="hdncancelledorderdetail" runat="server" Value="0" />
        <asp:HiddenField ID="hdnSelectedClientId" runat="server" Value="0" />
        <asp:HiddenField ID="hdnSelectedDistributorId" runat="server" Value="0" />
        <asp:HiddenField ID="hdnSelectedDisClientAddress" runat="server" Value="0" />
        <asp:HiddenField ID="hdnTotalQuantity" runat="server" Value="0" />

        <asp:HiddenField ID="hdnEditClientID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnEditJobNameID" runat="server" Value="0" />

        <asp:HiddenField ID="hdnDistributorID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnClientID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnJobNameID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnBillingAddressID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnDespatchAddressID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnCourierAddressID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnLabelID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnVisualLayoutID" runat="server" Value="0" />

        <!-- Job Name-->
        <div id="dvAddEditOrderDetail" class="modal fade"  role="dialog" aria-hidden="true" keyboard="false">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    ×</button>
                <h3 id="odTitle" runat="server">New Order Detail</h3>
            </div>
            <asp:HiddenField ID="hfScrollPosition" Value="0" runat="server" />

            <div class="row" style="margin-left: 50px;">
                <div class="col-sm-2"></div>
                <div class="col-sm-9">
                    <div class="modal-body" id="dvScroll" onscroll="setScrollPosition(this.scrollTop);">
                    
                      
                        <%--<div ID="sizeWarning" runat="server" class="signin-error" Visible="True">
                            <div class=" alert alert-warning" role="alert">
                                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                                <strong>
                                     You are selecting a size which is our normal size range and is essentially a bespoke garment.
                                    <br/>
                                    Please provide the specific key measurements;namely the chest width and centre back measurements.
                                    <br/>
                                    This will involve creating an appropriate template and accommodating the artwork in the new template.Artwork must be done again.
                                    <br/>
                                    The order is likely to be delayed.
                                    <br/>
                                    Please contact Melbourne coordinator to enquire is the new size can be accommodated for this pattern
                                </strong>
                                <br />
                            </div>
                        </div>--%>

                        <!-- Validation-->
                        <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="alert alert-danger"
                            ValidationGroup="vgOrderDetail" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                        <!-- / -->
                        <fieldset>
                            <!-- name and nunber file -->
                            <div class="control-group">
                                <label class="control-label">
                                    Are name and numbers required</label>
                                <div class="controls">
                                    <div class="">
                                        <label class="radio inline">
                                            <asp:RadioButton ID="rbNaNuYes" runat="server" GroupName="NaNurequired" OnCheckedChanged="rbNaNuYes_CheckedChanged" AutoPostBack="true" />
                                            Yes
                                        </label>
                                        <label class="radio inline">
                                            <asp:RadioButton ID="rbNaNuNo" runat="server" Checked="true" GroupName="NaNurequired" OnCheckedChanged="rbNaNuYes_CheckedChanged" AutoPostBack="true" />
                                            No
                                        </label>
                                    </div>
                                </div>
                            </div>
                            <div class="control-group" id="dvNaNPreview" runat="server">
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

                                <label class="control-label ">
                                </label>
                                <p class="extra-helper">
                                    <b>You can upload excel or word files only. </b>
                                </p>
                            </div>
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
                                        ControlToValidate="ddlOrderType" InitialValue="0" ValidationGroup="vgOrderDetail"
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
                                                ControlToValidate="ddlLabel" InitialValue="0" ValidationGroup="vgOrderDetail"
                                                EnableClientScript="false" Display="Dynamic">
                                            <img src="Content/img/icon_warning.png"  title="Label is required." alt="Label is required." />
                                            </asp:RequiredFieldValidator>
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
                                            <span class="text-error">
                                                <asp:Literal ID="litMeassage" runat="server"></asp:Literal>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="control-group">
                                        <div class="controls">
                                            <div class="search-control" style="display: inline-block; margin-bottom: 0;">
                                                <asp:DropDownList ID="ddlSizes" CssClass="input-medium" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSizes_SelectedIndexChanged"></asp:DropDownList>
                                            </div>
                                           
                                        </div>

                                          <div class="alert alert-danger" runat="server" ID="sizeWarningAlert" Visible="False" style="margin-top: 10px;">
                                        <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
                                          You are selecting a size which is our normal size range and is essentially a bespoke garment.
                                                <br/>
                                                Please provide the specific key measurements;namely the chest width and centre back measurements.
                                                <br/>
                                                This will involve creating an appropriate template and accommodating the artwork in the new template.Artwork must be done again.
                                                <br/>
                                                The order is likely to be delayed.
                                                <br/>
                                                Please contact Melbourne coordinator to enquire is the new size can be accommodated for this pattern
                                      </div>
                                    </div>
                                    <div class="control-group">
                                        <ol id="olSizeQuantities" class="ioderlist-table" style="display: block; margin-left: 100px; margin-top: 0; width: 620px;">
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
                                                        <asp:Image ID="imgvlImage" Width="350px" Height="350px" runat="server" />
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
                                                            <p id="P1" class="extra-helper icenter" runat="server" visible="false">
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
                                        <table style="width: auto" id="tblIndimanPrice" class="table">
                                            <tr>
                                                <td>Indiman Cost Sheet Price $</td>
                                                <td>Surcharge/Discount +/-</td>
                                                <td>Indiman Final Price $</td>
                                                <td>Purchase Value $</td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:TextBox ID="txtIndimanCostSheetPrice" runat="server" data-attr="base" Enabled="false" Style="text-align: right" CssClass="input-medium"></asp:TextBox></td>
                                                <td>
                                                    <asp:TextBox ID="txtIndimanSurcharge" runat="server" data-attr="base" Style="text-align: right" CssClass="input-medium"></asp:TextBox></td>
                                                <td>
                                                    <asp:TextBox ID="txtIndimanFinalPrice" runat="server" data-attr="base" Enabled="false" Style="text-align: right" CssClass="input-medium"></asp:TextBox></td>
                                                <td>
                                                    <asp:TextBox ID="txtIndimanPurchaseValue" runat="server" data-attr="base" Enabled="false" Style="text-align: right" CssClass="input-medium"></asp:TextBox></td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div class="control-group">
                                        <table style="width: auto" id="tblDistributorPrice" class="table">
                                            <tr>
                                                <td>Distributor Price $</td>
                                                <td>Surcharge/Discount %</td>
                                                <td>Distributor Final Price $</td>
                                                <td>Sales Value $</td>
                                                <td>Gross Profit $</td>
                                                <td>Gross Margin %</td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:TextBox ID="txtDistributorPrice" runat="server" data-attr="new" Style="text-align: right" CssClass="input-medium" Width="100px"></asp:TextBox></td>
                                                <td>
                                                    <asp:TextBox ID="txtDistributorSurcharge" runat="server" data-attr="new" Style="text-align: right" CssClass="input-medium" Width="75px"></asp:TextBox></td>
                                                <td>
                                                    <asp:TextBox ID="txtDistributorFinalPrice" runat="server" data-attr="new" Style="text-align: right" CssClass="input-medium" Width="100px" Enabled="false"></asp:TextBox></td>
                                                <td>
                                                    <asp:TextBox ID="txtSalesValue" runat="server" data-attr="new" Style="text-align: right" CssClass="input-medium" Width="100px" Enabled="false"></asp:TextBox></td>
                                                <td>
                                                    <asp:TextBox ID="txtGrossProfit" runat="server" data-attr="new" Style="text-align: right" CssClass="input-medium" Width="100px" Enabled="false"></asp:TextBox></td>
                                                <td>
                                                    <asp:TextBox ID="txtGrossMargin" runat="server" data-attr="new" Style="text-align: right" CssClass="input-medium" Width="100px" Enabled="false"></asp:TextBox></td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div class="control-group">
                                        <label class="control-label">Price Comments</label>
                                        <div class="controls">
                                            <asp:TextBox ID="txtPriceComments" runat="server" TextMode="MultiLine" CssClass="input-medium"></asp:TextBox>
                                        </div>
                                    </div>
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
                                </ContentTemplate>
                            </asp:UpdatePanel>
                            <script type="text/javascript">

                                var txtTotalQty = '<%=txtTotalQty.ClientID%>';
                                var hdnTotalQuantity = "<%=hdnTotalQuantity.ClientID %>";

                                var txtIndimanCostSheetPrice = '<%=txtIndimanCostSheetPrice.ClientID%>';
                                var txtIndimanSurcharge = '<%=txtIndimanSurcharge.ClientID%>';
                                var txtIndimanFinalPrice = '<%=txtIndimanFinalPrice.ClientID%>';
                                var txtIndimanPurchaseValue = '<%=txtIndimanPurchaseValue.ClientID%>';

                                var txtDistributorPrice = '<%=txtDistributorPrice.ClientID%>';
                                var txtDistributorSurcharge = '<%=txtDistributorSurcharge.ClientID%>';
                                var txtDistributorFinalPrice = '<%=txtDistributorFinalPrice.ClientID%>';
                                var txtSalesValue = '<%=txtSalesValue.ClientID%>';
                                var txtGrossProfit = '<%=txtGrossProfit.ClientID%>';
                                var txtGrossMargin = '<%=txtGrossMargin.ClientID%>';

                                var txtDeliveryCharges = '<%=txtDeliveryCharges.ClientID%>';
                                var txtArtworkCharges = '<%=txtArtworkCharges.ClientID%>';
                                var txtOtherCharges = '<%=txtOtherCharges.ClientID%>';
                                var txtTotalValue = '<%=txtTotalValue.ClientID%>';
                                var txtTotalValueExcludeGST = '<%=txtTotalValueExcludeGST.ClientID%>';
                                var txtGrandTotal = '<%=txtGrandTotal.ClientID%>';
                                var txtGST = '<%=txtGST.ClientID%>';
                                var chkIsGstExclude = '<%=chkIsGstExclude.ClientID%>';

                                $(document).ready(function () {
                                    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
                                    function EndRequest(sender, args) {
                                        if (args.get_error() == undefined) {
                                            BindPriceCalculations();
                                        }
                                    }

                                    BindPriceCalculations();

                                    function BindPriceCalculations() {
                                        $('#' + txtIndimanSurcharge).bind('keyup', function () {
                                            CalculateIndimanFinalPrice();
                                            CalculatePurchaseValue();
                                            CalculateDistributorPrice();
                                            CalculateDistributorFinalPrice();
                                            CalculateSalesValue();
                                            CalculateGrossProfit();
                                            CalculateGrossMargin();
                                            DisplyTotal();
                                        });

                                        $('#' + txtDistributorPrice).bind('keyup', function () {
                                            $('#' + txtDistributorPrice).css("color", "black");
                                            CalculateDistributorFinalPrice();
                                            CalculateSalesValue();
                                            CalculateGrossProfit();
                                            CalculateGrossMargin();
                                            DisplyTotal();
                                        });

                                        $('#' + txtDistributorSurcharge).bind('keyup', function () {
                                            CalculateDistributorFinalPrice();
                                            CalculateSalesValue();
                                            CalculateGrossProfit();
                                            CalculateGrossMargin();
                                            DisplyTotal();
                                        });

                                        $('#' + txtDeliveryCharges).bind('keyup', function () {
                                            DisplyTotal();
                                        });

                                        $('#' + txtArtworkCharges).bind('keyup', function () {
                                            DisplyTotal();
                                        });

                                        $('#' + txtOtherCharges).bind('keyup', function () {
                                            DisplyTotal();
                                        });

                                        $('#' + chkIsGstExclude).click(function () {
                                            DisplyTotal();
                                        });
                                    }
                                });

                                function CalculateIndimanFinalPrice() {
                                    $('#' + txtIndimanFinalPrice).val("$" + (parseFloat($('#' + txtIndimanCostSheetPrice).val().replace("$", "")) + parseFloat($('#' + txtIndimanSurcharge).val())).toFixed(2));
                                }

                                function CalculateDistributorPrice() {
                                    $('#' + txtDistributorPrice).val((parseFloat($('#' + txtIndimanFinalPrice).val().replace("$", "")) / (1 - 0.42)).toFixed(2));
                                    $('#' + txtDistributorPrice).css("color", "gray");
                                }

                                function CalculatePurchaseValue() {
                                    $('#' + txtIndimanPurchaseValue).val((parseFloat($('#' + txtIndimanFinalPrice).val().replace("$", "")) * $('#' + txtTotalQty).val()).toFixed(2));
                                }

                                function CalculateDistributorFinalPrice() {
                                    $('#' + txtDistributorFinalPrice).val('$' + (parseFloat($('#' + txtDistributorPrice).val()) + (parseFloat($('#' + txtDistributorPrice).val()) * parseFloat($('#' + txtDistributorSurcharge).val()) / 100)).toFixed(2));
                                }

                                function CalculateSalesValue() {
                                    $('#' + txtSalesValue).val('$' + (parseFloat($('#' + txtDistributorFinalPrice).val().replace("$", "")) * $('#' + txtTotalQty).val()).toFixed(2));
                                }

                                function CalculateGrossProfit() {
                                    $('#' + txtGrossProfit).val('$' + (parseFloat($('#' + txtSalesValue).val().replace("$", "")) - parseFloat($('#' + txtIndimanPurchaseValue).val().replace("$", ""))).toFixed(2));
                                }

                                function CalculateGrossMargin() {
                                    $('#' + txtGrossMargin).val(((1 - ($('#' + txtIndimanPurchaseValue).val().replace("$", "") / $('#' + txtSalesValue).val().replace("$", ""))) * 100).toFixed(2) + '%');
                                }

                                function DisplyTotal() {
                                    var deliveryCA = parseFloat($('#' + txtDeliveryCharges).val());
                                    var artworkCA = parseFloat($('#' + txtArtworkCharges).val());
                                    var otherCA = parseFloat($('#' + txtOtherCharges).val());
                                    var total = parseFloat($('#' + txtTotalValue).val());
                                    var grandTotal = (total + deliveryCA + artworkCA + otherCA).toFixed(2);

                                    $('#' + txtTotalValueExcludeGST).val(grandTotal);

                                    if ($('#' + chkIsGstExclude).is(':checked')) {
                                        $('#' + txtGST).val('0.00');
                                        $('#' + txtGrandTotal).val(grandTotal);
                                    }
                                    else {
                                        $('#' + txtGST).val((grandTotal * 0.1).toFixed(2));
                                        $('#' + txtGrandTotal).val((grandTotal * 1.1).toFixed(2));
                                    }
                                }

                                function calculateTotalQty() {
                                    var qty = 0;
                                    $('#olSizeQuantities input[type=text]').each(function () {
                                        qty += Number($(this)[0].value);
                                    });
                                    $('#' + lblTotalQty).val(qty);
                                    $('#' + hdnTotalQuantity).val(qty);

                                    CalculatePurchaseValue();
                                    CalculateSalesValue();
                                    CalculateGrossProfit();
                                    CalculateGrossMargin();
                                }

                                //$(function () {
                                //    $('#' + txtDistributorPrice).each(function () {
                                //        $.data(this, 'default', this.value);
                                //    }).css("color", "gray")
                                //    .focus(function () {
                                //        if (!$.data(this, 'edited')) {
                                //            //this.value = "";
                                //            $(this).css("color", "black");
                                //        }
                                //    }).change(function () {
                                //        $.data(this, 'edited', this.value != "");
                                //    }).blur(function () {
                                //        if (!$.data(this, 'edited')) {
                                //            //this.value = $.data(this, 'default');
                                //            $(this).css("color", "gray");
                                //        }
                                //    });
                                //});
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
                            <!-- / -->
                        </fieldset>


                    </div>
                </div>
                <div class="col-sm-1"></div>
            </div>
            <%--   </contenttemplate>
            </asp:UpdatePanel>--%>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">
                    Close</button>
                <button id="btnAddOrder" runat="server" class="btn btn-success" validationgroup="vgOrderDetail"
                    data-loading-text="Adding..." type="submit" onserverclick="btnAddOrder_Click">
                    Add Order Detail</button>
                <asp:HiddenField ID="HiddenField1" runat="server" Value="0" />
            </div>
        </div>
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
                    ValidationGroup="validShipingAddress" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->
                <fieldset>
                    <div class="control-group">
                        <label class="control-label required">
                            Company Name</label>
                        <div class="controls">
                            <asp:TextBox ID="txtCompanyName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvCompanyName" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
                                ControlToValidate="txtCompanyName" Display="Dynamic" EnableClientScript="false"
                                ErrorMessage="Company Name is required">
                                <img src="Content/img/icon_warning.png" title="Company Name is required" alt="Company Name is required" />
                            </asp:RequiredFieldValidator>
                            <asp:CustomValidator ID="cfvCompanyName" runat="server" OnServerValidate="cfvCompanyName_ServerValidate" ErrorMessage="Company Name is already in use"
                                ValidationGroup="validShipingAddress" ControlToValidate="txtCompanyName" EnableClientScript="false">
                             <img src="Content/img/icon_warning.png"  title="Company Name is already in use" alt="Company Name is already in use" />
                            </asp:CustomValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Address Type</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlAdderssType" runat="server"></asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvAddressType" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
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
                            <asp:TextBox ID="txtShipToAddress" runat="server" CssClass="tbaReplace"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvAddress" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
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
                            <asp:TextBox ID="txtSuburbCity" runat="server" CssClass="tbaReplace"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvSuburb" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
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
                            <asp:TextBox ID="txtShipToState" runat="server" CssClass="tbaReplace"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvShipToState" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
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
                            <asp:TextBox ID="txtShipToPostCode" runat="server" CssClass="tbaReplace"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvPostCode" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
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
                            <asp:RequiredFieldValidator ID="rfvCountry" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
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
                            <asp:TextBox ID="txtShipToPhone" runat="server" CssClass="tbaReplace"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvPhone" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
                                ControlToValidate="txtShipToPhone" Display="Dynamic" EnableClientScript="false"
                                ErrorMessage="Phone is required">
                                <img src="Content/img/icon_warning.png" title="Phone is required" alt="Phone is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Email</label>
                        <div class="controls">
                            <asp:TextBox ID="txtShipToEmail" runat="server" CssClass="tbaReplace"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Contact Name</label>
                        <div class="controls">
                            <asp:TextBox ID="txtShipToContactName" runat="server" CssClass="tbaReplace"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvContactName" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
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
                            <asp:RequiredFieldValidator ID="rfvShipToPort" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
                                InitialValue="0" ControlToValidate="ddlShipToPort" Display="Dynamic" EnableClientScript="false"
                                ErrorMessage="Port is required">
                                <img src="Content/img/icon_warning.png" title="Port is required" alt="Port is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                </fieldset>
            </div>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">
                    Close</button>
                <button id="btnSaveShippingAddress" runat="server" class="btn btn-primary" type="submit"
                    validationgroup="validShipingAddress" data-loading-text="Saving..." onserverclick="btnSaveShippingAddress_Click">
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
                <h3 id="titleClient">Client</h3>
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
                        <h3 id="titleJobName">Job Name</h3>
                    </div>
                    <div class="modal-body">
                        <!-- Validation-->
                        <asp:ValidationSummary ID="vsNewJobName" runat="server" CssClass="alert alert-danger"
                            ValidationGroup="newJobName" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                        <!-- / -->
                        <fieldset>
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
            var PopulateOrderDetail = ('<%=ViewState["PopulateOrderDetail"]%>' == 'True') ? true : false;
            var PopulateDropDown = ('<%=ViewState["PopulateDropDown"]%>' == 'True') ? true : false;

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
            var ddlVlNumber = "<%=ddlVlNumber.ClientID %>";
            var ddlLabel = "<%=ddlLabel.ClientID %>";
            var ddlAdderssType = "<%=ddlAdderssType.ClientID %>";

            var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
            var hdnSelectedIndex = "<%=hdnSelectedIndex.ClientID %>";
            var hdnUploadFiles = "<%=hdnUploadFiles.ClientID %>";
            var lblTotalQty = "<%=txtTotalQty.ClientID %>";
            var ancNewPaymentMethod = "<%=ancNewPaymentMethod.ClientID %>";
            var ddlDistributor = "<%=ddlDistributor.ClientID %>";
            var txtOdNotes = "<%=txtOdNotes.ClientID %>";
            var ddlShipmentMode = "<%=ddlShipmentMode.ClientID %>";
            var hdnEditType = "<%=hdnEditType.ClientID %>";
                        
            var billingDetails = "<%=dvBillingDetails.ClientID %>";
            var hdnAddressID = "<%=hdnAddressID.ClientID %>";
            var txtNewJobName = "<%=txtNewJobName.ClientID %>";
            var txtShipmentDate = "<%=txtShipmentDate.ClientID%>";

            var dvClientDetails = "<%=dvClientDetails.ClientID%>";
            var lblJobName = "<%=lblJobName.ClientID %>";
            var lblBillingAddress = "<%=lblBillingAddress.ClientID%>";
            var lblDespatchAddress = "<%=lblDespatchAddress.ClientID%>";
            var lblCourierAddress = "<%=lblCourierAddress.ClientID%>";

            var hdnDistributorID = "<%=hdnDistributorID.ClientID %>";
            var hdnClientID = "<%=hdnClientID.ClientID %>";
            var hdnJobNameID = "<%=hdnJobNameID.ClientID %>";
            var hdnBillingAddressID = "<%=hdnBillingAddressID.ClientID %>";
            var hdnDespatchAddressID = "<%=hdnDespatchAddressID.ClientID %>";
            var hdnCourierAddressID = "<%=hdnCourierAddressID.ClientID %>";
            var hdnLabelID = "<%=hdnLabelID.ClientID %>";
            var hdnVisualLayoutID = "<%=hdnVisualLayoutID.ClientID %>";
            var hdnEditClientID = "<%=hdnEditClientID.ClientID %>";
            var hdnEditJobNameID = "<%=hdnEditJobNameID.ClientID %>";

            var aAddClient = "<%=aAddClient.ClientID %>";
            var ancNewJobName = "<%=ancNewJobName.ClientID %>";
            var aAddShippingAddress = "<%=aAddShippingAddress.ClientID %>";
            var ancDespatchAddress = "<%=ancDespatchAddress.ClientID %>";
            var btnEditClient = "<%=btnEditClient.ClientID %>";
            var btnEditJobName = "<%=btnEditJobName.ClientID %>";
            var btnEditBilling = "<%=btnEditBilling.ClientID %>";
            var btnEditDespatch = "<%=btnEditDespatch.ClientID %>";

            var txtCompanyName = "<%=txtCompanyName.ClientID %>";
            var ddlAdderssType = "<%=ddlAdderssType.ClientID %>";
            var ddlShipToCountry = "<%=ddlShipToCountry.ClientID %>";
            var ddlShipToPort = "<%=ddlShipToPort.ClientID %>";


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
                    $('#' + hdnSelectedIndex).val($(this).attr('index'));
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

                $('.ideletefile').click(function () {
                    $('#requestDeleteFile').modal('show');
                });

                if (PopulateClient) {
                    $('#dvClient').modal('show');
                }

                if (PopulateJobName) {
                    $('#addjobName').modal('show');
                }

                if (PopulateShippingAddress) {
                    $('#dvShipmentAddress').modal('show');
                }

                if (PopulateOrderDetail) {
                    $('#dvAddEditOrderDetail').modal('show').css({
                        'margin-top': function () { //vertical centering
                            return -(15);
                        },
                        'margin-bottom': function () {
                            return -(15);
                        },
                        //'margin-left': function () { //Horizontal centering
                        //    return -($(this).width() / 2);
                        //}
                        'margin-left': function () { //Horizontal centering
                            return -($(this).width() / 1.5)
                        },
                        'margin-right': function () { //Horizontal centering
                            return -($(this).width() / 1.5)
                        }                       
                    });

                    //rescale();
                }

                //function rescale() {
                //    var size = { width: $(window).width(), height: $(window).height() }
                //    /*CALCULATE SIZE*/
                //    var offset = 20;
                //    var offsetBody = 150;
                //    $('#dvAddEditOrderDetail').css('height', size.height - offset);
                //    $('.modal-body').css('height', size.height - (offset + offsetBody));
                //    $('#dvAddEditOrderDetail').css('top', 0);
                //}

                function BindPopupEvents() {
                    SetDespatchDiv();
                   
                    $('.datepicker').datepicker({ format: 'dd MM yyyy' });

                    $('#' + ddlClient).select2();
                    $('#' + ddlJobName).select2();
                    $('#' + ddlBillingAddress).select2();
                    $('#' + ddlDespatchAddress).select2();
                    $('#' + ddlCourierAddress).select2();
                    $('#' + ddlDistributor).select2();
                    $('#' + ddlVlNumber).select2();
                    $('#' + ddlLabel).select2();

                    $("input[type='text']").on("click", function () {
                        $(this).select();
                    });

                    if (!PopulateDropDown) {
                        PopulateClients($("#" + hdnDistributorID).val());
                        PopulateAddress($("#" + hdnDistributorID).val());
                    }

                    PopulateJobNames($("#" + hdnClientID).val());
                    PopulateAddressDetails($("#" + hdnBillingAddressID).val(), 1);
                    PopulateAddressDetails($("#" + hdnDespatchAddressID).val(), 2);
                    PopulateAddressDetails($("#" + hdnCourierAddressID).val(), 3);
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

            function AddNewShipmentAddress(addressType) {
                resetFieldsDefault('dvShipmentAddress');

                $(".tbaReplace").val("TBA");
                $('#' + txtCompanyName).val($("#" + ddlDistributor + " option:selected").text());
                $("#" + ddlAdderssType).val("0");
                $("#" + ddlShipToCountry).val("14");
                $("#" + ddlShipToPort).val("3");

                $('#' + hdnAddressID).val('0');
                $('div.alert-danger, span.error').hide();
                $('#dvShipmentAddress').modal('show');
                $('#' + hdnEditType).val(addressType);
            }

            function AddNewClient() {
                resetFieldsDefault('dvClient');
                $('#' + hdnEditClientID).val('0');
                $('div.alert-danger, span.error').hide();
                $('#dvClient').modal('show');
            }

            function AddNewJobName() {
                $('#' + txtNewJobName).val('');
                $('#' + hdnEditJobNameID).val('0');
                $('#addjobName').modal('show');
            }

            $('.accordion-toggle').click(function () {
                $('.collapse').collapse('hide')
            });

            function pageLoad() {
                maintainScrollPosition();
            }

            function setScrollPosition(scrollValue) {
                $('#<%=hfScrollPosition.ClientID%>').val(scrollValue);
            }

            function maintainScrollPosition() {
                $("#dvScroll").scrollTop($('#<%=hfScrollPosition.ClientID%>').val());
                        }
        </script>
        <script type="text/javascript">
            $(document).ready(function () {
                if (PopulateDropDown) {
                    var selctedID = $("#" + ddlDistributor).val();
                    $("#" + hdnDistributorID).val(selctedID);
                    PopulateClients(selctedID);
                    PopulateAddress(selctedID);
                }
            });

            $("#" + ddlDistributor).change(function () {
                $("#" + hdnDistributorID).val($(this).val());
                PopulateClients($(this).val());
                PopulateAddress($(this).val());
            });

            $("#" + ddlClient).change(function () {
                $("#" + hdnClientID).val($(this).val());
                PopulateJobNames($(this).val());
            });

            $("#" + ddlJobName).change(function () {
                $("#" + hdnJobNameID).val($(this).val());
                if ($(this).val() != "0") {
                    $("#" + lblJobName).text($(this).find('option:selected').text());
                    $("#" + btnEditJobName).show();
                }
                else {
                    $("#" + lblJobName).text("");
                    $("#" + btnEditJobName).hide();
                }
            });

            $("#" + ddlBillingAddress).change(function () {
                $("#" + hdnBillingAddressID).val($(this).val());
                $("#" + hdnDespatchAddressID).val($(this).val());

                $("#" + ddlDespatchAddress).val($(this).val());
                $("#" + ddlDespatchAddress).select2();

                PopulateAddressDetails($(this).val(), 1);
                PopulateAddressDetails($(this).val(), 2);
            });

            $("#" + ddlDespatchAddress).change(function () {
                $("#" + hdnDespatchAddressID).val($(this).val());
                PopulateAddressDetails($(this).val(), 2);
            });

            $("#" + ddlCourierAddress).change(function () {
                $("#" + hdnCourierAddressID).val($(this).val());
                $("#" + hdnDespatchAddressID).val($(this).val());

                $("#" + ddlDespatchAddress).val($(this).val());
                $("#" + ddlDespatchAddress).select2();

                PopulateAddressDetails($(this).val(), 2);
                PopulateAddressDetails($(this).val(), 3);
            });

        </script>
        <script type="text/javascript">
            function PopulateClients(id) {
                $.ajax({
                    type: "POST",
                    url: "AddEditOrder.aspx/GetClients",
                    data: JSON.stringify({ 'id': id }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (Result) {
                        Result = Result.d;
                        $("#" + ddlClient).empty().append('<option selected="selected" value="0">Select Client</option>');
                        $.each(Result, function (key, value) {
                            $("#" + ddlClient).append($("<option></option>").val
                            (value.Value).html(value.Text));
                        });

                        $("#" + ddlClient).val($("#" + hdnClientID).val());
                        $("#" + ddlClient).select2();

                        if (id > 0) {
                            $("#" + aAddClient).show();
                            $("#" + aAddShippingAddress).show();
                            $("#" + ancDespatchAddress).show();
                        }
                        else {
                            $("#" + aAddClient).hide();
                            $("#" + ancNewJobName).hide();
                            $("#" + aAddShippingAddress).hide();
                            $("#" + ancDespatchAddress).hide();
                            $("#" + btnEditClient).hide();
                            $("#" + btnEditJobName).hide();
                            $("#" + btnEditBilling).hide();
                            $("#" + btnEditDespatch).hide();
                            PopulateClientDetails(0);
                        }

                        $("#" + ddlJobName).empty().append('<option selected="selected" value="0">Select Job Name</option>');
                        $("#" + ddlJobName).select2();
                    },
                    error: function (xhr, textStatus, errorThrown) {
                        var err = eval("(" + xhr.responseText + ")");
                        alert(err.Message);
                    }
                });
            }

            function PopulateJobNames(id) {
                PopulateClientDetails(id);

                $.ajax({
                    type: "POST",
                    url: "AddEditOrder.aspx/GetJobNames",
                    data: JSON.stringify({ 'id': id }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (Result) {
                        Result = Result.d;
                        $("#" + ddlJobName).empty().append('<option selected="selected" value="0">Select Job Name</option>');
                        $.each(Result, function (key, value) {
                            $("#" + ddlJobName).append($("<option></option>").val
                            (value.Value).html(value.Text));
                        });

                        $("#" + ddlJobName).val($("#" + hdnJobNameID).val());
                        $("#" + ddlJobName).select2();

                        if (id == "0") {
                            $("#" + ancNewJobName).hide();
                        }
                        else {
                            $("#" + ancNewJobName).show();
                        }

                        if ($("#" + hdnJobNameID).val() == "0") {
                            $("#" + btnEditJobName).hide();
                            $("#" + lblJobName).text("");
                        }
                        else {
                            $("#" + btnEditJobName).show();
                            $("#" + lblJobName).text($("#" + ddlJobName).find('option:selected').text());
                        }
                    },
                    error: function (xhr, textStatus, errorThrown) {
                        var err = eval("(" + xhr.responseText + ")");
                        alert(err.Message);
                    }
                });
            }

            function PopulateAddress(id) {
                $.ajax({
                    type: "POST",
                    url: "AddEditOrder.aspx/GetBillingAddress",
                    data: JSON.stringify({ 'id': id }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (Result) {
                        Result = Result.d;
                        $("#" + ddlBillingAddress).empty().append('<option selected="selected" value="0">Select Billing Address</option>');
                        $.each(Result, function (key, value) {
                            $("#" + ddlBillingAddress).append($("<option></option>").val
                            (value.Value).html(value.Text));
                        });
                        $("#" + ddlBillingAddress).val($("#" + hdnBillingAddressID).val());
                        $("#" + ddlBillingAddress).select2();

                        $("#" + ddlDespatchAddress).empty().append('<option selected="selected" value="0">Select Despatch Address</option>');
                        $.each(Result, function (key, value) {
                            $("#" + ddlDespatchAddress).append($("<option></option>").val
                            (value.Value).html(value.Text));
                        });
                        $("#" + ddlDespatchAddress).val($("#" + hdnDespatchAddressID).val());
                        $("#" + ddlDespatchAddress).select2();

                        $("#" + ddlCourierAddress).empty().append('<option selected="selected" value="0">Select Despatch Address</option>');
                        $.each(Result, function (key, value) {
                            $("#" + ddlCourierAddress).append($("<option></option>").val
                            (value.Value).html(value.Text));
                        });
                        $("#" + ddlCourierAddress).val($("#" + hdnCourierAddressID).val());
                        $("#" + ddlCourierAddress).select2();
                    },
                    error: function (xhr, textStatus, errorThrown) {
                        var err = eval("(" + xhr.responseText + ")");
                        alert(err.Message);
                    }
                });
            }

            function PopulateAddressDetails(id, addType) {
                if (id > 0) {
                    $.ajax({
                        type: "POST",
                        url: "AddEditOrder.aspx/GetAddressDetails",
                        data: JSON.stringify({ 'id': id }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (Result) {
                            Result = Result.d;
                            switch (addType) {
                                case 1:
                                    $("#" + lblBillingAddress).text(Result);
                                    $("#" + btnEditBilling).show();
                                    break;
                                case 2:
                                    $("#" + lblDespatchAddress).text(Result);
                                    $("#" + btnEditDespatch).show();
                                    break;
                                case 3:
                                    $("#" + lblCourierAddress).text(Result);
                                    break;
                                default:
                                    break;
                            }
                        },
                        error: function (xhr, textStatus, errorThrown) {
                            var err = eval("(" + xhr.responseText + ")");
                            alert(err.Message);
                        }
                    });
                }
                else {
                    switch (addType) {
                        case 1:
                            $("#" + lblBillingAddress).text("");
                            $("#" + btnEditBilling).hide();
                            break;
                        case 2:
                            $("#" + lblDespatchAddress).text("");
                            $("#" + btnEditDespatch).hide();
                            break;
                        case 3:
                            $("#" + lblCourierAddress).text("");
                            break;
                        default:
                            break;
                    }
                }
            }

            function PopulateClientDetails(id) {
                if (id > 0) {
                    $.ajax({
                        type: "POST",
                        url: "AddEditOrder.aspx/GetClientDetails",
                        data: JSON.stringify({ 'id': id }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (Result) {
                            Result = Result.d;
                            $("#" + dvClientDetails).html(Result);
                            $("#" + btnEditClient).show();
                        },
                        error: function (xhr, textStatus, errorThrown) {
                            var err = eval("(" + xhr.responseText + ")");
                            alert(err.Message);
                        }
                    });
                }
                else {
                    $("#" + btnEditClient).hide();
                    $("#" + dvClientDetails).html("");
                }
            }
        </script>
        <!-- / -->
</asp:Content>
