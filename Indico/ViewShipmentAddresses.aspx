<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewShipmentAddresses.aspx.cs" Inherits="Indico.ViewShipmentAddresses" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddAddress" runat="server" class="btn btn-link iadd pull-right">New Address</a>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h2>
                        <a class="btn-link iadd" title="Add an Shipment Address.">Add the first Address.</a>
                    </h2>
                    <p>
                        You can add as many Addresses as you like.
                    </p>
                </div>
                <!-- / -->
                <%--Data Content--%>
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>
                    </div>
                    <!-- / -->
                    <!-- Data Table -->
                    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro"
                        EnableEmbeddedSkins="true">
                    </telerik:RadAjaxLoadingPanel>
                    <telerik:RadGrid ID="RadGridShipmentAddress" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="false" OnPageSizeChanged="RadGridShipmentAddress_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridShipmentAddress_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridShipmentAddress_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridShipmentAddress_ItemCommand"
                        OnSortCommand="RadGridShipmentAddress_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="CompanyName" SortExpression="CompanyName" HeaderText="Company Name" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="CompanyName">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="ContactName" SortExpression="ContactName" HeaderText="Contact Name" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="ContactName">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="ContactEmail" SortExpression="EmailAddress" HeaderText="Email" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="EmailAddress">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="ContactPhone" SortExpression="ContactPhone" HeaderText="Contact Phone" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="ContactPhone">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Address" SortExpression="Address" HeaderText="Address" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="100px" DataField="Address">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Suburb" SortExpression="Suburb" HeaderText="Suburb" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Suburb">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="PostCode" SortExpression="PostCode" HeaderText="Post Code" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="PostCode">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="CountryID" SortExpression="CountryID" HeaderText="CountryID" AllowSorting="false" FilterControlWidth="10px" AutoPostBackOnFilter="true" DataField="Country">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn UniqueName="Country" SortExpression="Country" HeaderText="Country" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Country">
                                    <ItemTemplate>
                                        <asp:Literal ID="litCountry" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="State" SortExpression="State" HeaderText="State" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="State">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="PortID" SortExpression="PortID" HeaderText="PortID" AllowSorting="false" FilterControlWidth="10px" AutoPostBackOnFilter="true" DataField="Port">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn UniqueName="Port" SortExpression="Port" HeaderText="Port" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Port">
                                    <ItemTemplate>
                                        <asp:Literal ID="litPort" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="ClientID" SortExpression="ClientID" HeaderText="ClientID" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Client">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn UniqueName="Client" SortExpression="Client" HeaderText="Client" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Client">
                                    <ItemTemplate>
                                        <asp:Literal ID="litClient" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="DistributorID" SortExpression="DistributorID" HeaderText="DistributorID" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Distributor">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn UniqueName="Distributor" SortExpression="Distributor" HeaderText="Distributor" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Distributor">
                                    <ItemTemplate>
                                        <asp:Literal ID="litDistributor" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="AddressTypeID" SortExpression="AddressType" HeaderText="AddressType" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="AddressType">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn UniqueName="AddressType" SortExpression="AddressType" HeaderText="AddressType" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="AddressType">
                                    <ItemTemplate>
                                        <asp:Literal ID="litAddressType" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Shipment Address"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Shipment Address"><i class="icon-trash"></i>Delete</asp:HyperLink>
                                                </li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="false">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="false" />
                    </telerik:RadGrid>
                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                            any address.</h4>
                    </div>
                </div>
                <!-- / -->
            </div>
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedShipmentAddressID" runat="server" Value="0" />
    <!-- Add / Edit Item -->
    <!-- Shiping Address Details-->
    <div id="dvSipmentAddress" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblPopupHeaderText" runat="server"></asp:Label></h3>
        </div>
        <div class="modal-body">
            <!-- Validation-->
            <asp:ValidationSummary ID="validateShiipingAddress" runat="server" CssClass="alert alert-danger"
                ValidationGroup="validShipingAddress" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <fieldset>
                <%--<div class="control-group">
                    <div class="controls radio btn-group">
                        <label>Client<asp:RadioButton ID="rbClient" runat="server" GroupName="CDType" onchange="SetClientorDistDiv();" Checked="true" /></label>
                        <label>Distributor<asp:RadioButton ID="rbDistributor" runat="server" GroupName="CDType" onchange="SetClientorDistDiv();" /></label>
                    </div>
                    <asp:CustomValidator ID="cvDistributor" runat="server" ErrorMessage=""
                            EnableClientScript="false" ValidationGroup="validShipingAddress" 
                            OnServerValidate="cvDistributor_ServerValidate">
                                <img src="Content/img/icon_warning.png" />
                        </asp:CustomValidator>
                </div>--%>
                <%--<div class="control-group" id="dvClient">
                    <label class="control-label required">
                        Client</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlClient" runat="server"></asp:DropDownList>
                       <%-- <asp:RequiredFieldValidator ID="rfvClient" runat="server" CssClass="error" ValidationGroup="validShipingAddress" InitialValue="0"
                            ControlToValidate="ddlClient" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Client is required">
                                <img src="Content/img/icon_warning.png" title="Client is required" alt="Client is required"/>
                        </asp:RequiredFieldValidator>- -%>
                    </div>
                </div>
                <div class="control-group" id="dvDistributor" style="display: none;">
                    <label class="control-label required">
                        Distributor</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlDistributor" runat="server"></asp:DropDownList>
                      <%--  <asp:RequiredFieldValidator ID="rfvDistributor" runat="server" CssClass="error" ValidationGroup="validShipingAddress" InitialValue="0"
                            ControlToValidate="ddlDistributor" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Distributor is required">
                                <img src="Content/img/icon_warning.png" title="Distributor is required" alt="Distributor is required" />
                        </asp:RequiredFieldValidator>- -%>
                    </div>                   
                </div>--%>
                <div class="control-group">
                    <label class="control-label required">
                        Distributor</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlDistributor" runat="server" CssClass="input-xlarge"></asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvDistributor" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
                            InitialValue="0" ControlToValidate="ddlDistributor" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Distributor is required">
                                <img src="Content/img/icon_warning.png" title="Distributor is required" alt="Distributor is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Company Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCOmpanyName" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvCompanyName" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
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
                        <asp:TextBox ID="txtShipToAddress" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvAddress" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
                            ControlToValidate="txtShipToAddress" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Address is required">
                                <img src="Content/img/icon_warning.png" title="Address is required" alt="Address is required" />
                        </asp:RequiredFieldValidator>
                         <asp:CustomValidator ID="cvTxtName" runat="server" OnServerValidate="cvTxtName_ServerValidate" ErrorMessage="Name is already in use" ValidationGroup="validShipingAddress"
                            ControlToValidate="txtShipToAddress" EnableClientScript="false">
                             <img src="Content/img/icon_warning.png"  title="Name is already in use" alt="Name is already in use" />
                        </asp:CustomValidator>
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
                        <asp:TextBox ID="txtShipToState" runat="server"></asp:TextBox>
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
                        <asp:TextBox ID="txtShipToPostCode" runat="server"></asp:TextBox>
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
                        <asp:TextBox ID="txtShipToPhone" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvPhone" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
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
                        <asp:RequiredFieldValidator ID="rfvContactName" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
                            ControlToValidate="txtShipToContactName" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Contact Name is required">
                                <img src="Content/img/icon_warning.png" title="Contact Name is required" alt="Contact Name is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Email</label>
                    <div class="controls">
                        <asp:TextBox ID="txtShipToEmail" runat="server"></asp:TextBox>
                        <%--<asp:RequiredFieldValidator ID="rfvShipToEmail" runat="server" CssClass="error" ValidationGroup="validShipingAddress"
                            ControlToValidate="txtShipToEmail" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Email is required">
                                <img src="Content/img/icon_warning.png" title="Email is required" alt="Email is required" />
                        </asp:RequiredFieldValidator>--%>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Port</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlShipToPort" runat="server"></asp:DropDownList>
                        <%-- <asp:RequiredFieldValidator ID="rfvPort" runat="server" CssClass="error" ValidationGroup="validShipingAddress" InitialValue="0"
                            ControlToValidate="ddlShipToPort" Display="Dynamic" EnableClientScript="false"
                            ErrorMessage="Port is required">
                                <img src="Content/img/icon_warning.png" title="Port is required" alt="Port is required" />
                        </asp:RequiredFieldValidator>--%>
                    </div>
                </div>
            </fieldset>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveShippingAddress" runat="server" class="btn btn-primary" type="submit"
                validationgroup="validShipingAddress" data-loading-text="Saving..." onserverclick="btnSaveShippingAddress_ServerClick">
                Save</button>
        </div>
    </div>
    <!--/-->
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Address</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Address?
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" onserverclick="btnDelete_Click"
                data-loading-text="Deleting..." type="submit">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var companyname = "<%=txtCOmpanyName.ClientID%>";
        var shiptoAddress = "<%=txtShipToAddress.ClientID%>";
        var suberb = "<%=txtSuburbCity.ClientID%>";
        var state = "<%=txtShipToState.ClientID%>";
        var postcode = "<%=txtShipToPostCode.ClientID%>";
        var country = "<%=ddlShipToCountry.ClientID%>";
        var phone = "<%=txtShipToPhone.ClientID%>";
        var contactname = "<%=txtShipToContactName.ClientID%>";
        var email = "<%=txtShipToEmail.ClientID%>";
        var port = "<%=ddlShipToPort.ClientID%>";
        var btnSaveChanges = "<%=txtShipToContactName.ClientID%>";
        var hdnSelectedID = "<%=hdnSelectedShipmentAddressID.ClientID %>";
        //var ddlClient = "< %=ddlClient.ClientID %>";
        var ddlDistributor = "<%=ddlDistributor.ClientID %>";
        var ddlAdderssType = "<%=ddlAdderssType.ClientID %>";
        //var rbClient = "< %=rbClient.ClientID %>";
        //var rbDistributor = "< %=rbDistributor.ClientID %>";
        var isDirectSales = "<%=this.LoggedUser.IsDirectSalesPerson%>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.iadd').click(function () {
                resetFieldsDefault('dvSipmentAddress');

                //if (isDirectSales == "True") {                  
                //    $('#' + ddlDistributor).val("< %=this.Distributor.ID%>");
                //}
               
                ShipmentAddressAddEdit(this, true);
            });

            // $('#' + ddlDistributor).select2();

            $('.iedit').click(function () {
                fillText(this);
                ShipmentAddressAddEdit(this, false);
            });

            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });

            if (!IsPageValid) {
                window.setTimeout(function () {
                    $('#dvSipmentAddress').modal('show');
                }, 10);
            }

            function ShipmentAddressAddEdit(o, n) {
                $('div.alert-danger, span.error').hide();
                $('#dvSipmentAddress div.modal-header h3 span')[0].innerHTML = (n ? 'Add Address' : 'Edit Address');
                $('#' + btnSaveChanges)[0].innerHTML = (n) ? 'Save Changes' : 'Update';
                $('#' + hdnSelectedID).val(n ? '0' : $(o).attr('qid'));
                $('#dvSipmentAddress').modal('show');
            }

            function fillText(o) {
                $('#' + companyname)[0].value = $(o).parents('tr').children('td')[0].innerHTML;
                $('#' + contactname)[0].value = (($(o).parents('tr').children('td')[1].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[1].innerHTML);
                $('#' + email)[0].value = (($(o).parents('tr').children('td')[2].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[2].innerHTML);
                $('#' + phone)[0].value = (($(o).parents('tr').children('td')[3].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[3].innerHTML);
                $('#' + shiptoAddress)[0].value = (($(o).parents('tr').children('td')[4].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[4].innerHTML);
                $('#' + suberb)[0].value = (($(o).parents('tr').children('td')[5].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[5].innerHTML);
                $('#' + postcode)[0].value = (($(o).parents('tr').children('td')[6].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[6].innerHTML);
                $('#' + country)[0].value = (($(o).parents('tr').children('td')[7].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[7].innerHTML);
                $('#' + state)[0].value = (($(o).parents('tr').children('td')[9].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[9].innerHTML);
                $('#' + port)[0].value = (($(o).parents('tr').children('td')[10].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[10].innerHTML);
                //$('#' + ddlClient)[0].value = (($(o).parents('tr').children('td')[12].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[12].innerHTML);//13
                $('#' + ddlDistributor)[0].value = (($(o).parents('tr').children('td')[14].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[14].innerHTML);

                //if ($(o).parents('tr').children('td')[14].innerHTML != '&nbsp;')
                //    $('#' + ddlDistributor).val($(o).parents('tr').children('td')[14].innerHTML);

                $('#' + ddlAdderssType)[0].value = (($(o).parents('tr').children('td')[16].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[16].innerHTML);//14               
                //if ($('#' + ddlDistributor)[0].value > 0) {
                //    $('#' + rbDistributor).attr({ "checked": true }).prop({ "checked": true });
                //    $('#' + rbClient).removeAttr("checked");
                //    $('#dvDistributor').show();
                //    $('#dvClient').hide();
                //}
                //else {
                //    $('#' + rbClient).attr({ "checked": true }).prop({ "checked": true });
                //    $('#' + rbDistributor).removeAttr("checked");
                //    $('#dvClient').show();
                //    $('#dvDistributor').hide();
                //}
            }
        });

        //function SetClientorDistDiv() {
        //    if ($('#' + rbClient).is(':checked')) {
        //        $('#dvClient').show();
        //        $('#dvDistributor').hide();
        //    }
        //    else if ($('#' + rbDistributor).is(':checked')) {
        //        $('#dvDistributor').show();
        //        $('#dvClient').hide();
        //    }
        //}

    </script>
</asp:Content>
