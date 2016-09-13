<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewAccessoryCategories.aspx.cs"
    Inherits="Indico.ViewAccessoryCategories" MasterPageFile="~/Indico.Master" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnNewAccessoryCategory" runat="server" class="btn btn-link iadd pull-right">New Accessory Category</a>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h4>
                        <a href="javascript:AccessoryCategoryAddEdit(this, true, 'New Item Accessory Category');"
                            title="Add an accessory Category.">Add the first Accessory Category.</a>
                    </h4>
                    <p>
                        You can add as many Accessory Categories as you like.
                    </p>
                </div>
                <!-- / -->
                <!-- Data Content -->
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
                            <telerik:AjaxSetting AjaxControlID="RadGridAccessoryCategories">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridAccessoryCategories"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridAccessoryCategories" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="false" OnPageSizeChanged="RadGridAccessoryCategories_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridAccessoryCategories_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridAccessoryCategories_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridAccessoryCategories_ItemCommand"
                        OnSortCommand="RadGridAccessoryCategories_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Name" SortExpression="Name" HeaderText="Name" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="150px" DataField="Name">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Code" SortExpression="Code" HeaderText="Code" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="150px" AutoPostBackOnFilter="true" DataField="Code">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <a id="linkEdit" runat="server" class="btn-link iedit" title="Edit Accessory"><i class="icon-pencil"></i>Edit</a>
                                                </li>
                                                <li>
                                                    <a id="linkDelete" runat="server" class="btn-link idelete" title="Delete Accessory"><i class="icon-trash"></i>Delete</a>
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
                    <%--<asp:DataGrid ID="dgAccessoryCategory" runat="server" CssClass="table" AutoGenerateColumns="false"
                        AllowSorting="true" GridLines="None" AllowPaging="True" PageSize="20" AllowCustomPaging="False"
                        OnItemDataBound="dgAccessoryCategory_ItemDataBound" OnPageIndexChanged="dgAccessoryCategory_PageIndexChanged"
                        OnSortCommand="dgAccessoryCategory_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="Name" HeaderText="Name" SortExpression="Name"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Code" HeaderText="Code" SortExpression="Code"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li><a id="linkEdit" runat="server" class="btn-link iedit" title="Edit Accessory"><i
                                                class="icon-pencil"></i>Edit</a> </li>
                                            <li><a id="linkDelete" runat="server" class="btn-link idelete" title="Delete Accessory">
                                                <i class="icon-trash"></i>Delete</a></li>
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
                            any Accessory Categories.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedAccessoryCategoryID" runat="server" Value="0" />
    <!-- Add / Edit AccessoryCategory -->
    <div id="requestAddEditAccessoryCategory" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static" style="display: none;">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblPopupHeaderText" runat="server" Text=""></asp:Label>
            </h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <!-- Popup Validation -->
            <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <fieldset class="panel" style="margin: 0; padding: 0; background: transparent; border: 0;">
                <div class="control-group">
                    <label class="control-label required">
                        Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtName" runat="server" MaxLength="128"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvName" runat="server" CssClass="error" ControlToValidate="txtName"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Accessory Category name is required">
                                <img src="Content/img/icon_warning.png" title="Accessory Category name is required" alt="Accessory Category name is required" />
                        </asp:RequiredFieldValidator>
                         <asp:CustomValidator ID="cvTxtName" runat="server" OnServerValidate="cvTxtName_ServerValidate" ErrorMessage="Name is already in use"
                            ControlToValidate="txtName" EnableClientScript="false">
                             <img src="Content/img/icon_warning.png"  title="Name is already in use" alt="Name is already in use" />
                        </asp:CustomValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCode" runat="server" MaxLength="128"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvCode" runat="server" CssClass="error" ControlToValidate="txtCode"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Accessory Category Code is required">
                                <img src="Content/img/icon_warning.png" title="Accessory Category Code is required" alt="Accessory Category Code is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
            </fieldset>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_Click"
                data-loading-text="Saving..." type="submit">
                Save Changes</button>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <!-- Delete Item -->
    <div id="requestDeleteAccessoryCategory" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static" style="display: none;">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Accessory Category</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Accessory Category?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDeleteAccessoryCategory" runat="server" class="btn btn-primary" onserverclick="btnDeleteAccessoryCategory_Click"
                data-loading-text="Deleting..." type="submit">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var IsValied = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var hdnSelectedAccessoryCategoryID = "<%=hdnSelectedAccessoryCategoryID.ClientID %>";
        var categoryName = "<%=txtName.ClientID %>";
        var categoryCode = "<%=txtCode.ClientID %>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID %>"
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            if (!IsValied) {
                window.setTimeout(function () {
                    $('#requestAddEditAccessoryCategory').modal('show');
                }, 10);
            }

            $('.iadd').click(function () {
                AccessoryCategoryAddEdit(this, true);
            });

            $('.iedit').click(function () {
                AccessoryCategoryAddEdit(this, false);
            });

            $('.idelete').click(function () {
                $('#' + hdnSelectedAccessoryCategoryID)[0].value = $(this).attr('qid');
                $('#requestDeleteAccessoryCategory').modal('show');
            });

            function AccessoryCategoryAddEdit(o, n) {
                //Hide the validation summary
                $('div.alert-danger, span.error').hide();
                //Set the popup header text
                $('#requestAddEditAccessoryCategory div.modal-header h3 span')[0].innerHTML = (n ? 'New Accessory Category' : 'Edit Accessory Category');
                //Set the popup save button text
                $('#' + btnSaveChanges)[0].innerHTML = (n) ? 'Save Changes' : 'Update';
                //Set item sttribute ID
                $('#' + hdnSelectedAccessoryCategoryID)[0].value = (n ? '0' : $(o).attr('qid'));
                //If this is edit mode the the parent, name and description or not set default   
                if (!n) {
                }
                $('#' + categoryName)[0].value = (n ? '' : $(o).parents('tr').children('td')[0].innerHTML.trim());
                $('#' + categoryCode)[0].value = (n ? '' : $(o).parents('tr').children('td')[1].innerHTML.trim());


                $('#requestAddEditAccessoryCategory').modal('show');
            }
        });
    </script>
    <!-- / -->
</asp:Content>
