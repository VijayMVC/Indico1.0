<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewAccessories.aspx.cs" Inherits="Indico.ViewAccessories" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddPatternAccessory" runat="server" class="btn btn-link iadd pull-right">New
                    Pattern Accessory</a>
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
                    <h4>
                        <a href="javascript:PatternAccessoryAddEdit(this, true, 'New PatternAccessory');"
                            title="Add an Pattern Accessory.">Add the first Accessory.</a>
                    </h4>
                    <p>
                        You can add as many Accessories as you like.
                    </p>
                </div>
                <!-- / -->
                <!--Data Content-->
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
                    <%-- <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadGridAccessory">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridAccessory"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridAccessory" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadGridAccessory_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridAccessory_PageIndexChanged" ShowFooter="false" OnGroupsChanging="RadGridAccessory_GroupsChanging"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridAccessory_ItemDataBound" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridAccessory_ItemCommand"
                        OnSortCommand="RadGridAccessory_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true" GroupsDefaultExpanded="false">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Name" SortExpression="Name" HeaderText="Name" AllowSorting="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" DataField="Name">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Code" SortExpression="Code" HeaderText="Code" AllowSorting="true" AllowFiltering="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true" DataField="Code">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="AccessoryCategoryID" SortExpression="AccessoryCategoryID" HeaderText="AccessoryCategoryID" AllowSorting="true"
                                    AutoPostBackOnFilter="true" DataField="AccessoryCategoryID">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="AccessoryCategory" SortExpression="AccessoryCategory" HeaderText="AccessoryCategory" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="AccessoryCategory">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Description" SortExpression="Description" HeaderText="Description" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Description">
                                </telerik:GridBoundColumn>
                                <telerik:GridNumericColumn UniqueName="Cost" SortExpression="Cost" HeaderText="Cost" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="Cost">
                                </telerik:GridNumericColumn>
                                <telerik:GridBoundColumn UniqueName="SuppCode" SortExpression="SuppCode" HeaderText="Supp. Code" AllowSorting="true" AllowFiltering="true"
                                    AutoPostBackOnFilter="true" DataField="SuppCode">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="UnitID" SortExpression="UnitID" HeaderText="UnitID" AllowSorting="false" AllowFiltering="false"
                                    AutoPostBackOnFilter="true" DataField="UnitID">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Unit" SortExpression="Unit" HeaderText="Unit" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true" DataField="Unit">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="SupplierID" SortExpression="SupplierID" HeaderText="SupplierID" AllowSorting="false" AllowFiltering="false"
                                    AutoPostBackOnFilter="true" DataField="SupplierID">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Supplier" SortExpression="Supplier" HeaderText="Supplier" AllowSorting="true" AllowFiltering="true" FilterControlWidth="100px" CurrentFilterFunction="Contains"
                                    AutoPostBackOnFilter="true" DataField="Supplier">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" class="btn-link iedit" runat="server" ToolTip="Edit Accessory"> <i class="icon-pencil"></i>Edit</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" class="btn-link idelete" ToolTip="Delete Accessory"> <i class="icon-trash"></i>Delete</asp:HyperLink>
                                                </li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="true">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="true" />
                    </telerik:RadGrid>
                    <%--<asp:DataGrid ID="dataGridPatternAccessory" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dataGridPatternAccessory_ItemDataBound" OnPageIndexChanged="dataGridPatternAccessory_PageIndexChanged"
                        OnSortCommand="dataGridPatternAccessory_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="Name" HeaderText="Name" SortExpression="Name"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Code" HeaderText="Code" SortExpression="Code"></asp:BoundColumn>
                            <asp:BoundColumn DataField="AccessoryCategory" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Accessory Category">
                                <ItemTemplate>
                                    <asp:Literal ID="litAccessoryCategory" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:BoundColumn DataField="Description" HeaderText="Description" SortExpression="Description"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Cost" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:BoundColumn DataField="SuppCode" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Unit" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Unit">
                                <ItemTemplate>
                                    <asp:Literal ID="litUnit" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:BoundColumn DataField="Supplier" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Supplier">
                                <ItemTemplate>
                                    <asp:Literal ID="litSupplier" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="" ItemStyle-Width="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:HyperLink ID="linkEdit" class="btn-link iedit" runat="server" ToolTip="Edit Pattern Accessory Category"> <i
                                                    class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                            <li>
                                                <asp:HyperLink ID="linkDelete" runat="server" class="btn-link idelete" ToolTip="Delete Pattern Accessory Category"> <i
                                                    class="icon-trash"></i>Delete</asp:HyperLink></li>
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
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> did not match
                            any Accessories.</h4>
                    </div>
                </div>
                <!-- / -->
            </div>
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- /
    -->
    <asp:HiddenField ID="hdnSelectedPatternAccessoryID" runat="server" Value="0" />
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
                        <asp:TextBox ID="txtPatternAccessory" runat="server" MaxLength="128"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvPatternAccessory" runat="server" CssClass="error"
                            ControlToValidate="txtPatternAccessory" Display="Dynamic" EnableClientScript="False"
                            ErrorMessage="Name is required">
                                <img src="Content/img/icon_warning.png" title="Name is required" alt="Name is required" />
                        </asp:RequiredFieldValidator>
                         <asp:CustomValidator ID="cvTxtName" runat="server" OnServerValidate="cvTxtName_ServerValidate" ErrorMessage="Name is already in use"
                            ControlToValidate="txtPatternAccessory" EnableClientScript="false">
                             <img src="Content/img/icon_warning.png"  title="Name is already in use" alt="Name is already in use" />
                        </asp:CustomValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCode" runat="server" CssClass="topic_d" MaxLength="255" TextMode="MultiLine"
                            Rows="2"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvCode" runat="server" CssClass="error" ControlToValidate="txtCode"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Code is required">
                                <img src="Content/img/icon_warning.png" title="Code is required" alt="Code is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Accessory Category</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlAccessoryaCategory" runat="server">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvAccessoryCategory" runat="server" CssClass="error"
                            ControlToValidate="ddlAccessoryaCategory" InitialValue="0" Display="Dynamic"
                            EnableClientScript="False" ErrorMessage="Accessory Category is required">
                                <img src="Content/img/icon_warning.png" title="Accessory Category is required" alt="Accessory Category is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Description</label>
                    <div class="controls">
                        <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Cost</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCost" runat="server" TextMode="MultiLine"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Supp. Code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtSuppCode" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Unit</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlUnit" runat="server">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Supplier</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlSupplier" runat="server">
                        </asp:DropDownList>
                    </div>
                </div>
            </fieldset>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_Click"
                data-loading-text="Saving...">
                Save Changes</button>
        </div>
    </div>
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Accessory</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Accessory?>
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" onserverclick="btnDelete_Click"
                data-loading-text="Deleting...">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var patternaccessoryname = "<%=txtPatternAccessory.ClientID%>";
        var patternaccessorycode = "<%=txtCode.ClientID%>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID%>";
        var ddlAccessoryaCategory = "<%=ddlAccessoryaCategory.ClientID%>";
        var txtDescription = "<%=txtDescription.ClientID%>";
        var hdnSelectedID = "<%=hdnSelectedPatternAccessoryID.ClientID %>";
        var txtCost = "<%=txtCost.ClientID %>";
        var txtSuppCode = "<%=txtSuppCode.ClientID %>";
        var ddlUnit = "<%=ddlUnit.ClientID %>";
        var ddlSupplier = "<%=ddlSupplier.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.iadd').click(function () {
                resetFieldsDefault('requestAddEdit');
                PatternAccessoryAddEdit(this, true);
            });

            $('.iedit').click(function () {
                fillText(this);
                PatternAccessoryAddEdit(this, false);
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

            function PatternAccessoryAddEdit(o, n) {
                $('div.alert-danger, span.error').hide();
                $('#requestAddEdit div.modal-header h3 span')[0].innerHTML = (n ? 'Add Accessory' : 'Edit Accessory');
                $('#' + btnSaveChanges)[0].innerHTML = (n) ? 'Save Changes' : 'Update';
                $('#' + hdnSelectedID).val(n ? '0' : $(o).attr('qid'));
                $('#requestAddEdit').modal('show');
            }

            function fillText(o) {
                $('#' + patternaccessoryname)[0].value = $(o).parents('tr').children('td')[0].innerHTML;
                $('#' + patternaccessorycode)[0].value = $(o).parents('tr').children('td')[1].innerHTML;
                $('#' + ddlAccessoryaCategory)[0].value = $(o).parents('tr').children('td')[2].innerHTML;
                $('#' + txtDescription)[0].value = (($(o).parents('tr').children('td')[4].innerHTML != '&nbsp;') ? $(o).parents('tr').children('td')[4].innerHTML : '');
                $('#' + txtCost)[0].value = (($(o).parents('tr').children('td')[5].innerHTML != '&nbsp;') ? $(o).parents('tr').children('td')[5].innerHTML : '');
                $('#' + txtSuppCode)[0].value = (($(o).parents('tr').children('td')[6].innerHTML != '&nbsp;') ? $(o).parents('tr').children('td')[6].innerHTML : '');
                $('#' + ddlUnit)[0].value = $(o).parents('tr').children('td')[7].innerHTML;
                $('#' + ddlSupplier)[0].value = $(o).parents('tr').children('td')[9].innerHTML;
            }
        });
    </script>
</asp:Content>
