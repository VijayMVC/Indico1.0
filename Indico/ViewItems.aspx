<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewItems.aspx.cs" Inherits="Indico.ViewItems" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddItem" runat="server" class="btn btn-link iadd pull-right" type="submit"
                    onserverclick="btnAddItem_Click">New Item</a>
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
                        <a href="javascript:itemAddEdit(this, true, 'New Item');" title="Add an item.">Add the
                            first item.</a>
                    </h4>
                    <p>
                        You can add as many items as you like.
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
                        <ajaxsettings>
                            <telerik:AjaxSetting AjaxControlID="RadGridItems">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridItems"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </ajaxsettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridItems" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="false" OnPageSizeChanged="RadGridItems_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridItems_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridItems_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridItems_ItemCommand"
                        OnSortCommand="RadGridItems_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="ID" SortExpression="ID" HeaderText="ID" AllowSorting="false" AllowFiltering="false" Groupable="false"
                                    AutoPostBackOnFilter="true" DataField="ID">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Name" SortExpression="Name" HeaderText="Name" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="150px" DataField="Name">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Description" SortExpression="Description" HeaderText="Description" AllowSorting="true" Groupable="false"
                                    AutoPostBackOnFilter="true" DataField="Description">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn UniqueName="ItemType" SortExpression="ItemType" HeaderText="Type" Groupable="false"
                                    AutoPostBackOnFilter="true">
                                    <ItemTemplate>
                                        <asp:Literal ID="litType" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="Parent" SortExpression="Parent" HeaderText="Parent" AllowSorting="false" AllowFiltering="false" Groupable="false"
                                    AutoPostBackOnFilter="true" DataField="Parent">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="Image" AllowFiltering="false">
                                    <ItemTemplate>
                                        <a id="ancTemplateItemImage" runat="server" target="_blank"><i id="iitemImage" runat="server" class="icon-eye-open"></i></a>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:LinkButton ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Item" OnClick="linkEdit_Click"><i class="icon-pencil"></i>Edit</asp:LinkButton>
                                                </li>
                                                <li>
                                                    <asp:LinkButton ID="linkEditSubItem" runat="server" CssClass="btn-link ieditsub" ToolTip="Add/Edit Sub Item" OnClick="linkEditSubItem_Click"><i class="icon-pencil"></i>Edit Sub Item</asp:LinkButton>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Item"><i class="icon-trash"></i>Delete</asp:HyperLink>
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
                    <%--       <asp:DataGrid ID="dataGridItems" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dataGridItems_ItemDataBound" OnPageIndexChanged="dataGridItems_PageIndexChanged"
                        OnSortCommand="dataGridItems_SortCommand" OnItemCommand="dataGridItems_ItemCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="ID" HeaderText="ID" Visible="false"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Name" HeaderText="Name" SortExpression="Name"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Description" HeaderText="Description" HeaderStyle-CssClass="hide"
                                ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Parent" HeaderText="Parent" HeaderStyle-CssClass="hide"
                                ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Image">
                                <ItemTemplate>
                                    <a id="ancTemplateItemImage" runat="server" target="_blank"><i id="iitemImage" runat="server"
                                        class="icon-eye-open"></i></a>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:LinkButton ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Item"
                                                    CommandName="Edit"><i class="icon-pencil"></i>Edit</asp:LinkButton></li>
                                            <li>
                                                <asp:LinkButton ID="linkEditSubItem" runat="server" CssClass="btn-link iedit" ToolTip="Add/Edit Sub Item"
                                                    CommandName="Edit Sub"><i class="icon-pencil"></i>Edit Sub Item</asp:LinkButton></li>
                                            <li>
                                                <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Item"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
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
                            any documents.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnIsNewItem" runat="server" Value="0" />
    <asp:HiddenField ID="hdnSelectedItemID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnSubItemName" runat="server" Value="" />
    <asp:HiddenField ID="hdnSubItemDescription" runat="server" Value="" />
    <!-- Add / Edit Sub Item -->
    <div id="requestAddEditSubItem" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblPopupSubItemHeaderText" runat="server"></asp:Label></h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <fieldset>
                <div class="control-group">
                    <label class="control-label">
                        Parent</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlParentAttribute" runat="server" AutoPostBack="true" CssClass="firePopupChange"
                            Enabled="false" OnSelectedIndexChanged="ddlParentAttribute_SelectedIndexChanged">
                        </asp:DropDownList>
                        <asp:LinkButton ID="linkAddNew" runat="server" Visible="false" CssClass="btn-link iadd"
                            ToolTip="Add New Item" OnClick="linkAddNew_Click"><i class="icon-plus"></i></asp:LinkButton>
                        <asp:RequiredFieldValidator ID="rfvParent" runat="server" CssClass="error" ControlToValidate="ddlParentAttribute"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Parent is required"
                            InitialValue="0">
                                <img src="Content/img/icon_warning.png" title="Parent is required" alt="Parent is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
            </fieldset>
            <fieldset id="liAddEditSubItem" runat="server">
                <asp:DataGrid ID="dgAddEditSubItem" runat="server" CssClass="table" AllowCustomPaging="False"
                    AllowPaging="false" AutoGenerateColumns="false" GridLines="None" OnItemDataBound="dgAddEditSubItem_ItemDataBound"
                    OnItemCommand="dgAddEditSubItem_ItemCommand">
                    <HeaderStyle CssClass="header" />
                    <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                    <Columns>
                        <asp:TemplateColumn Visible="false" HeaderText="ID">
                            <ItemTemplate>
                                <asp:Literal ID="lblID" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Item Name" SortExpression="Name" ItemStyle-Width="46%">
                            <ItemTemplate>
                                <asp:Literal ID="lblItemName" runat="server"></asp:Literal>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtItemName" runat="server" CssClass="ismall changeItemName"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvItemName" runat="server" ErrorMessage="Item Name is required"
                                    ControlToValidate="txtItemName" EnableClientScript="false" Display="Dynamic">
                                                <img src="Content/img/icon_warning.png"  title="Item Name is required" alt="Item Name is required" />
                                </asp:RequiredFieldValidator>
                            </EditItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Description">
                            <ItemTemplate>
                                <asp:Literal ID="lblItemDescription" runat="server"></asp:Literal>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtItemDescription" runat="server" CssClass="ismall changeItemDesc"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn>
                            <ItemTemplate>
                                <div class="btn-group pull-right">
                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                        <i class="icon-cog"></i><span class="caret"></span></a>
                                    <ul class="dropdown-menu pull-right">
                                        <li>
                                            <asp:LinkButton ID="linkEdit" runat="server" CssClass="btn-link iedit" CausesValidation="false"
                                                CommandName="Edit" ToolTip="Edit Item"><i class="icon-pencil"></i>Edit</asp:LinkButton></li>
                                        <li>
                                            <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" CausesValidation="false"
                                                CommandName="Delete" ToolTip="Delete Item"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
                                    </ul>
                                </div>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <div class="btn-group pull-right">
                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                        <i class="icon-cog"></i><span class="caret"></span></a>
                                    <ul class="dropdown-menu pull-right">
                                        <li>
                                            <asp:LinkButton ID="linkSave" runat="server" CssClass="btn-link isave" CausesValidation="false"
                                                CommandName="Save" ToolTip="Save Item"><i class="icon-edit"></i>Save Item</asp:LinkButton></li>
                                    </ul>
                                </div>
                            </EditItemTemplate>
                        </asp:TemplateColumn>
                    </Columns>
                </asp:DataGrid>
            </fieldset>
        </div>
        <div class="modal-footer">
        </div>
    </div>
    <!-- / -->
    <div id="requestAddEditItem" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblPopupItemHeaderText" runat="server"></asp:Label></h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <!-- Popup Validation -->
            <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                ValidationGroup="validateItem" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <fieldset>
                <div class="control-group">
                    <label class="control-label required">
                        Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtItemName" runat="server" MaxLength="128"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvItemName" runat="server" CssClass="error" ControlToValidate="txtItemName"
                            ValidationGroup="validateItem" Display="Dynamic" EnableClientScript="False" ErrorMessage="Item name is required">
                                <img src="Content/img/icon_warning.png" title="Item name is required" alt="Item name is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Type</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlItemType" runat="server"></asp:DropDownList>
                         <asp:RequiredFieldValidator ID="rfvItemType" runat="server" CssClass="error" ControlToValidate="ddlItemType"
                            ValidationGroup="validateItem" Display="Dynamic" EnableClientScript="False" ErrorMessage="Item type is required">
                                <img src="Content/img/icon_warning.png" title="Item type is required" alt="Item type is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Description</label>
                    <div class="controls">
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="topic_d" MaxLength="255"
                            TextMode="MultiLine" Rows="2"></asp:TextBox>
                    </div>
                </div>
            </fieldset>
            <legend>Item Image</legend>
            <div id="liitemImage" runat="server" class="">
                <div class="control-group">
                    <div id="liuploadTable" runat="server">
                        <asp:Image ID="ItemImage" runat="server" />
                        <table id="uploadtable_1" class="file_upload_files" multirow="false" setdefault="true">
                            <tr id="profilePictureRow" runat="server">
                            </tr>
                        </table>
                        <input id="hdnItemImage" runat="server" name="hdnProfilePicture" type="hidden" value="" />
                    </div>
                </div>
                <div id="liUploder" runat="server">
                    <div class="controls">
                        <div id="dropzone_1" class="fileupload preview single setdefault hide-dropzone">
                            <input id="file_1" name="file_1" type="file" />
                            <button id="btnup_1" type="submit">
                                Upload</button>
                            <div id="divup_1">
                                Drag photo here or click to upload
                            </div>
                        </div>
                    </div>
                    <div>
                        <label class="control-label ">
                        </label>
                        <p class="extra-helper">
                            <span class="label label-info">Hint:</span> You can drag & drop files from your
                            desktop on this webpage with Google Chrome, Mozilla Firefox and Apple Safari.
                        </p>
                    </div>
                </div>
            </div>
            <div class="text-center">
                <div id="dvItemImageGuide" runat="server">
                    <ul class="thumbnails">
                        <li class="span3">
                            <div class="thumbnail">
                                <asp:Image ID="imgItemImage" runat="server" />
                                <div class="caption">
                                    <asp:HyperLink ID="linkDeleteItemImage" runat="server" CssClass="btn-link" ToolTip="Delete Item Image"><i class="icon-trash"></i></asp:HyperLink>
                                </div>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        <!-- / -->
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_Click"
                validationgroup="validateItem" data-loading-text="Saving..." type="submit">
                Save Changes</button>
        </div>
    </div>
    <asp:HiddenField ID="hdnEditMode" runat="server" />
    <asp:HiddenField ID="hdnItemSub" runat="server" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Item</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Item?
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" type="submit" onserverclick="btnDelete_Click"
                data-loading-text="Deleting...">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Delete Template Image -->
    <div id="requestDeleteItemImage" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Template Image</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Item Image?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnDeleteItemImg" runat="server" class="btn btn-primary" onserverclick="btnDeleteItemImg_Click"
                type="submit">
                Yes</button>
            <button id="btnEditImage" runat="server" onserverclick="btnEditImage_Click" style="display: none"
                type="submit">
                Edit</button>
        </div>
    </div>
    <!-- / -->
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var IsPopulateSubItemModel = ('<%=ViewState["IsPopulateSubItemModel"]%>' == 'True') ? true : false;
        var IsPopulateItemModel = ('<%=ViewState["IsPopulateItemModel"]%>' == 'True') ? true : false;

        var itemName = "<%=txtItemName.ClientID%>";
        var itemDescription = "<%=txtDescription.ClientID%>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID%>";
        var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
        var imgItemImage = "<%=imgItemImage.ClientID%>";
        var hdnEditMode = "<%=hdnEditMode.ClientID%>";
        var btnEditImage = "<%=btnEditImage.ClientID%>";
        var linkDeleteItemImage = "<%=linkDeleteItemImage.ClientID%>";
        var dvItemImageGuide = "<%=dvItemImageGuide.ClientID%>";
        var liitemImage = "<%=liitemImage.ClientID%>";
        var liuploadTable = "<%=liuploadTable.ClientID%>";
        var liUploder = "<%=liUploder.ClientID%>";
        var hdnItemSub = "<%=hdnItemSub.ClientID%>";

        var hdnIsNewItem = "<%=hdnIsNewItem.ClientID %>";
        var hdnSelectedItemID = "<%=hdnSelectedItemID.ClientID %>";
        var hdnSubItemName = "<%=hdnSubItemName.ClientID%>";
        var hdnSubItemDescription = "<%=hdnSubItemDescription.ClientID%>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            /*$('.iadd').click(function () {
            resetFieldsDefault('requestAddEditSubItem');
            itemAddEdit(this, true);
            $('#' + imgItemImage).removeAttr('src');
            });

            $('.iedit').click(function () {
            fillText(this);
            itemAddEdit(this, false);
            $('#' + btnEditImage).click();
            });*/

            $('.iedit').click(function () {
                $('#' + hdnSelectedItemID)[0].value = $(this).attr('qid');
            });

            $('.ieditsub').click(function () {
                $('#' + hdnItemSub).val($(this).attr('qid'));;
            });

            $('.idelete').click(function () {
                $('#' + hdnSelectedItemID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });

            $('.changeItemDesc').keyup(function () {
                $('#' + hdnSubItemDescription).val($(this).val());
            });

            $('.changeItemName').keyup(function () {
                $('#' + hdnSubItemName).val($(this).val());
            });

            if (IsPopulateSubItemModel) {
                subItemAddEdit(this);
            }

            if (IsPopulateItemModel) {
                var isNew = true;
                if ($('#' + hdnIsNewItem).val() == "0") {
                    isNew = false;
                }
                itemAddEdit(this, isNew);
            }

            $('#' + linkDeleteItemImage).click(function () {
                $('#' + hdnEditMode)[0].value = $(this).attr('imageID');
                $('#requestDeleteItemImage').modal('show');
            });

            if (!IsPageValid) {
                $('#requestAddEditSubItem').modal('hide');
                $('#requestAddEditItem').modal('show');
            }

            function subItemAddEdit(o) {
                $('div.alert-danger, span.error').hide();
                $('#requestAddEditSubItem div.modal-header h3 span')[0].innerHTML = 'Edit Item';
                /*$('#' + btnSaveChanges).val(n ? 'Save Changes' : 'Update');
                $('#' + hdnSelectedID).val(n ? '0' : $(o).attr('qid'));
                $('#' + dvItemImageGuide).hide();
                $('#' + liitemImage).show();
                $('#' + liuploadTable).show();
                $('#' + liUploder).show();
                if (!n) {
                $('#' + ddlParentAttribute).val($(o).parents('tr').children('td')[2].innerHTML);
                }*/
                $('#requestAddEditSubItem').modal('show');
                $('#requestAddEditItem').modal('hide');
            }

            function itemAddEdit(o, n) {
                $('div.alert-danger, span.error').hide();
                $('#requestAddEditItem div.modal-header h3 span')[0].innerHTML = (n ? 'New Item' : 'Edit Item');
                $('#' + btnSaveChanges)[0].innerHTML = (n) ? 'Save Changes' : 'Update';
                $('#requestAddEditItem').modal('show');
                $('#requestAddEditSubItem').modal('hide');
            }

            /*function fillText(o) {
            $('#' + itemName)[0].value = $(o).parents('tr').children('td')[0].innerHTML.trim();
            // $('#' + itemDescription)[0].value = $(o).parents('tr').children('td')[1].innerHTML.trim();
            if ($(o).parents('tr').children('td')[1].innerHTML.trim() == '&nbsp;') {
            $('#' + itemDescription)[0].value = '';

            }
            else {
            $('#' + itemDescription)[0].value = $(o).parents('tr').children('td')[1].innerHTML.trim();
            }
            var NoImage = $(o).parents('tr').find('.iview').attr('href')

            if (NoImage != null) {
            $('#' + liitemImage).hide();
            }
            else {
            $('#' + liitemImage).show();
            }
            }*/
        });
    </script>
</asp:Content>
