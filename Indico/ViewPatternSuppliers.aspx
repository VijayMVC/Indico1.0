<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewPatternSuppliers.aspx.cs" Inherits="Indico.ViewPatternSuppliers" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddSupplier" runat="server" class="btn btn-link iadd pull-right">New Pattern Supplier</a>
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
                        <a href="javascript:SupplierAddEdit(this, true, 'New Supplier');" title="Add a Supplier.">Add the first Supplier.</a>
                    </h2>
                    <p>
                        You can add as many Suppliers as you like.
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
                    <%--  <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadGridSuppliers">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridSuppliers"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridSuppliers" runat="server" AllowPaging="true" AllowFilteringByColumn="true"
                        ShowGroupPanel="false" OnPageSizeChanged="RadGridSuppliers_PageSizeChanged" PageSize="20" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        OnPageIndexChanged="RadGridSuppliers_PageIndexChanged" ShowFooter="false" AutoGenerateColumns="false"
                        OnItemDataBound="RadGridSuppliers_ItemDataBound" Skin="Metro" CssClass="RadGrid"
                        AllowSorting="true" EnableEmbeddedSkins="true" OnItemCommand="RadGridSuppliers_ItemCommand"
                        OnSortCommand="RadGridSuppliers_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Name" SortExpression="Name" HeaderText="Name" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    AllowSorting="true" FilterControlWidth="100px" DataField="Name">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Address1" SortExpression="Address1" HeaderText="Address1" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    AllowSorting="true" FilterControlWidth="50px" DataField="Address1">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Address2" SortExpression="Address2" HeaderText="Address2" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    AllowSorting="true" FilterControlWidth="50px" DataField="Address2">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="City" SortExpression="City" HeaderText="City" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    AllowSorting="true" FilterControlWidth="50px" DataField="City">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="State" SortExpression="State" HeaderText="State" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    AllowSorting="true" FilterControlWidth="50px" DataField="State">
                                </telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn UniqueName="Postcode" SortExpression="Postcode" HeaderText="Postcode" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    AllowSorting="true" FilterControlWidth="50px" DataField="Postcode">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Country" SortExpression="Country" HeaderText="Country" CurrentFilterFunction="Contains" Groupable="false"
                                    AllowSorting="true" FilterControlWidth="50px" AutoPostBackOnFilter="true" DataField="Country" Visible="false">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="Country" FilterControlWidth="50px">                                    
                                    <ItemTemplate>
                                        <asp:Literal ID="litCountry" runat="server">
                                        </asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="EmailAddress" SortExpression="EmailAddress" HeaderText="Email Address" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    AllowSorting="true" FilterControlWidth="100px" DataField="EmailAddress">
                                </telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn UniqueName="TelephoneNumber" SortExpression="TelephoneNumber" HeaderText="Telephone Number" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    AllowSorting="true" FilterControlWidth="50px" DataField="TelephoneNumber">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Creator" SortExpression="Creator" HeaderText="Creator" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    AllowSorting="true" FilterControlWidth="50px" DataField="Creator" Visible="false">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn AllowFiltering="false" UniqueName="CountryID" HeaderText="CountryID">
                                    <ItemTemplate>
                                        <asp:Label ID="lblCountry" runat="server" CssClass="country" ></asp:Label>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Supplier"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Supplier"><i class="icon-trash"></i>Delete</asp:HyperLink>
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
                    <%--<asp:DataGrid ID="dgSuppliers" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dgSuppliers_ItemDataBound" OnPageIndexChanged="dgSuppliers_PageIndexChanged"
                        OnSortCommand="dgSuppliers_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="Name" HeaderText="Name" SortExpression="Name"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Country" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Country">
                                <ItemTemplate>
                                    <asp:Literal ID="litCountry" runat="server">
                                    </asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Supplier"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                            <li>
                                                <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Supplier"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
                                        </ul>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>--%>
                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                            any Suppliers.</h4>
                    </div>
                </div>
                <!-- / -->
            </div>
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedSupplierID" runat="server" Value="0" />
    <!-- Add / Edit Item -->
    <div id="requestAddEdit" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblPopupHeaderText" runat="server"></asp:Label></h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <!-- Popup Validation -->
            <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <fieldset>
                <div class="control-group">
                    <label class="control-label required">
                        Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtSupplierName" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvSupplierName" runat="server" CssClass="error"
                            ControlToValidate="txtSupplierName" Display="Dynamic" EnableClientScript="False"
                            ErrorMessage="Name is required">
                                <img src="Content/img/icon_warning.png" title="Name is required" alt="Name is required" />
                        </asp:RequiredFieldValidator>
                         <asp:CustomValidator ID="cvTxtName" runat="server" OnServerValidate="cvTxtName_ServerValidate" ErrorMessage="Name is already in use"
                            ControlToValidate="txtSupplierName" EnableClientScript="false">
                             <img src="Content/img/icon_warning.png"  title="Name is already in use" alt="Name is already in use" />
                        </asp:CustomValidator>
                    </div>
                </div>
                 <div class="control-group">
                    <label class="control-label">
                        Address1</label>
                    <div class="controls">
                        <asp:TextBox ID="txtAddress1" runat="server"></asp:TextBox>
                        </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Address2</label>
                    <div class="controls">
                        <asp:TextBox ID="txtAddress2" runat="server"></asp:TextBox>
                        </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        City</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCity" runat="server"></asp:TextBox>
                        </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        State</label>
                    <div class="controls">
                        <asp:TextBox ID="txtState" runat="server"></asp:TextBox>
                        </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Post code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtPostcode" runat="server"></asp:TextBox>
                        </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Country</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlCountry" runat="server">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvCountry" runat="server" CssClass="error" ControlToValidate="ddlCountry"
                            Display="Dynamic" EnableClientScript="False" InitialValue="0" ErrorMessage="Country is required">
                                <img src="Content/img/icon_warning.png" title="Country is required" alt="Country is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Email address</label>
                    <div class="controls">
                        <asp:TextBox ID="txtEmailAddress" runat="server"></asp:TextBox>
                        </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Telephone number</label>
                    <div class="controls">
                        <asp:TextBox ID="txtTelephoneNumber" runat="server"></asp:TextBox>
                        </div>
                </div>
               <!-- <div>
                <div class="control-group">
                    <label class="control-label required">
                        Creator</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlCreator" runat="server">
                        </asp:DropDownList>
                       </div>
                </div>
                 <div class="control-group">
                    <label class="control-label required">
                        Created date</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCreatedDate" runat="server" TextMode="Date"></asp:TextBox>
                        </div>
                </div>
                 <div class="control-group">
                    <label class="control-label required">
                        Modifier</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlModifier" runat="server">
                        </asp:DropDownList>
                       </div>
                </div>
                 <div class="control-group">
                    <label class="control-label required">
                        Modified date</label>
                    <div class="controls">
                        <asp:TextBox ID="txtModifiedDate" runat="server" TextMode="Date"></asp:TextBox>
                        </div>
                </div>
                    </div> !-->
            </fieldset>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_Click"
                data-loading-text="Saving..." type="submit" text="">
                Save Changes</button>
        </div>
    </div>
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Supplier</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Supplier?
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
        var supplierName = "<%=txtSupplierName.ClientID%>";
        var suppliercountry = "<%=ddlCountry.ClientID%>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID%>";
        var hdnSelectedID = "<%=hdnSelectedSupplierID.ClientID %>";
        var address1 = "<%=txtAddress1.ClientID%>";
        var address2 = "<%=txtAddress2.ClientID%>";
        var city = "<%=txtCity.ClientID%>";
        var state = "<%=txtState.ClientID%>";
        var postcode = "<%=txtPostcode.ClientID%>";
        var email = "<%=txtEmailAddress.ClientID%>";
        var telno = "<%=txtTelephoneNumber.ClientID%>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () { 
            $('.iadd').click(function () {
                resetFieldsDefault('requestAddEdit');
                SupplierAddEdit(this, true);
            });

            $('.iedit').click(function () {
                fillText(this);
                SupplierAddEdit(this, false);
            });

            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });

            if (!IsPageValid) {
                window.setTimeout(function () {
                    $('#requestAddEdit').modal('show');
                }, 10);
            }

            function SupplierAddEdit(o, n) {
                $('div.alert-danger, span.error').hide();
                $('#requestAddEdit div.modal-header h3 span')[0].t = (n ? 'Add Supplier' : 'Edit Supplier');
                $('#' + btnSaveChanges)[0].innerHTML = (n) ? 'Save Changes' : 'Update';
                $('#' + hdnSelectedID).val(n ? '0' : $(o).attr('qid'));
                $('#requestAddEdit').modal('show');
            }

            function fillText(o) {
                $('#' + supplierName)[0].value = $(o).parents('tr').children('td')[0].innerHTML;
                $('#' + address1)[0].value = ($(o).parents('tr').children('td')[1].innerHTML === '&nbsp;') ? '' : $(o).parents('tr').children('td')[1].innerHTML;
                $('#' + address2)[0].value = ($(o).parents('tr').children('td')[2].innerHTML === '&nbsp;') ? '' : $(o).parents('tr').children('td')[2].innerHTML;
                $('#' + city)[0].value = ($(o).parents('tr').children('td')[3].innerHTML === '&nbsp;') ? '' : $(o).parents('tr').children('td')[3].innerHTML;
                $('#' + state)[0].value = ($(o).parents('tr').children('td')[4].innerHTML === '&nbsp;') ? '' : $(o).parents('tr').children('td')[4].innerHTML;
                $('#' + postcode)[0].value = ($(o).parents('tr').children('td')[5].innerHTML === '&nbsp;') ? '' : $(o).parents('tr').children('td')[5].innerHTML;
                $('#' + email)[0].value = ($(o).parents('tr').children('td')[7].innerHTML === '&nbsp;') ? '' : $(o).parents('tr').children('td')[7].innerHTML;
                $('#' + telno)[0].value = ($(o).parents('tr').children('td')[8].innerHTML === '&nbsp;') ? '' : $(o).parents('tr').children('td')[8].innerHTML;
                $('#' + suppliercountry).val($(o).attr('cty'));
            }
        });
    </script>
</asp:Content>
