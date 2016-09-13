<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewItemAttributes.aspx.cs" Inherits="Indico.ItemAttributes" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnNewAttribute" runat="server" class="btn btn-link iadd pull-right">New Item
                    Attribute</a>
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
                    <h2>
                        <a href="javascript:ItemAttributesAddEdit(this, true, 'New Item Attributes');" title="Add an item Attribute.">Add the first item Attribute.</a>
                    </h2>
                    <p>
                        You can add as many item Attributes as you like.
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
                    <%-- <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadGridItemAttribute">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridItemAttribute"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridItemAttribute" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadGridItemAttribute_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridItemAttribute_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridItemAttribute_ItemDataBound" OnGroupsChanging="RadGridItemAttribute_GroupsChanging"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridItemAttribute_ItemCommand"
                        OnSortCommand="RadGridItemAttribute_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Name" SortExpression="Name" HeaderText="Name" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    FilterControlWidth="150px" DataField="Name">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Description" SortExpression="Description" HeaderText="Description" AllowSorting="true" AllowFiltering="true" CurrentFilterFunction="Contains"
                                    AutoPostBackOnFilter="true" DataField="Description">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="ItemID" SortExpression="ItemID" HeaderText="ItemID" AllowSorting="false" AllowFiltering="false"
                                    AutoPostBackOnFilter="true" DataField="ItemID">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Item" SortExpression="Item" HeaderText="Item" AllowSorting="true"
                                    FilterControlWidth="150px" DataField="Item">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <a id="linkEdit" runat="server" class="btn-link iedit" title="Edit Attribute"><i class="icon-pencil"></i>Edit</a>
                                                </li>
                                                <li>
                                                    <asp:LinkButton ID="lbtnEditSUbAttributes" runat="server" ToolTip="Edit Item Attribute" OnClick="lbtnEditSUbAttributes_Click"><i class="icon-pencil"></i>Edit Sub Attributes</asp:LinkButton>
                                                </li>
                                                <li>
                                                    <a id="linkDelete" runat="server" class="btn-link idelete" title="Delete Attribute"><i class="icon-trash"></i>Delete </a>
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
                    <%--  <asp:DataGrid ID="dgItemAttributes" runat="server" CssClass="table" AutoGenerateColumns="false"
                        AllowSorting="true" GridLines="None" AllowPaging="True" PageSize="20" AllowCustomPaging="False"
                        OnItemDataBound="dgItemAttributes_ItemDataBound" OnPageIndexChanged="dataGridItemAttributes_PageIndexChanged"
                        OnSortCommand="dgItemAttributes_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="Name" HeaderText="Item Attributes Name" SortExpression="Name"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Description" HeaderText="Description" HeaderStyle-CssClass="hide"
                                ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Item" HeaderText="Item" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Parent" HeaderText="Parent" HeaderStyle-CssClass="hide"
                                ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Item" SortExpression="Item">
                                <ItemTemplate>
                                    <asp:Literal ID="litItem" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li><a id="linkEdit" runat="server" class="btn-link iedit" title="Edit Attribute"><i
                                                class="icon-pencil"></i>Edit</a></li>
                                            <li>
                                                <asp:LinkButton ID="lbtnEditSUbAttributes" runat="server" ToolTip="Edit Item Attribute"
                                                    OnClick="lbtnEditSUbAttributes_Click"><i class="icon-pencil"></i>Edit Sub Attributes</asp:LinkButton></li>
                                            <li><a id="linkDelete" runat="server" class="btn-link idelete" title="Delete Attribute">
                                                <i class="icon-trash"></i>Delete </a></li>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>--%>
                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                            any Item Attributes.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedAttributeID" runat="server" Value="0" />
    <!-- Add / Edit ItemAttribute -->
    <div id="requestAddEditAttribute" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static" style="display: none;">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblPopupHeaderText" runat="server" Text="New Topic"></asp:Label>
            </h3>
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
                        Item</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlItem" runat="server">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvItem" runat="server" CssClass="error" ControlToValidate="ddlItem"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Item is required"
                            InitialValue="0">
                                <img src="Content/img/icon_warning.png" title="Item is required" alt="Item is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Attribute Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtAttributeName" runat="server" MaxLength="128"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvItemAttribute" runat="server" CssClass="error"
                            ControlToValidate="txtAttributeName" Display="Dynamic" EnableClientScript="False"
                            ErrorMessage="Attribute name is required">
                                <img src="Content/img/icon_warning.png" title="Attribute name is required" alt="Attribute name is required" />
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
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_Click"
                data-loading-text="Saving...">
                Save Changes</button>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnAttributeName" runat="server" Value="0" />
    <asp:HiddenField ID="hdnAttributeDescription" runat="server" Value="0" />
    <asp:HiddenField ID="hdnParent" runat="server" Value="0" />
    <asp:HiddenField ID="hdnItem" runat="server" Value="0" />
    <!-- Add / Edit Sub Item -->
    <div id="dvSubItemAttributes" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static" style="display: none;">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Edit Sub Attributes
            </h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <fieldset>
                <div class="control-group">
                    <label class="control-label">
                        Parent</label>
                    <div class="controls">
                        <asp:TextBox ID="txtParent" runat="server" Enabled="false"></asp:TextBox>
                        <asp:LinkButton ID="linkAddNew" runat="server" CssClass="btn-link" ToolTip="Add New Item Attribute" data-placement="bottom"
                            OnClick="linkAddNew_Click"><i class="icon-plus"></i></asp:LinkButton>
                    </div>
                </div>
            </fieldset>
            <fieldset>
                <asp:DataGrid ID="dgAddEditSubItemAttributes" runat="server" CssClass="table" AllowCustomPaging="False"
                    AllowPaging="false" AutoGenerateColumns="false" GridLines="None" OnItemDataBound="dgAddEditSubItemAttributes_ItemDataBound"
                    OnItemCommand="dgAddEditSubItemAttributes_ItemCommand">
                    <HeaderStyle CssClass="header" />
                    <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                    <Columns>
                        <asp:TemplateColumn Visible="false" HeaderText="ID">
                            <ItemTemplate>
                                <asp:Literal ID="litID" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Attribute Name">
                            <ItemTemplate>
                                <asp:Literal ID="litAttribute" runat="server"></asp:Literal>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtAttribute" runat="server" CssClass="ismall changeItemName"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvAttribute" runat="server" ErrorMessage="Attribute Name is required"
                                    ControlToValidate="txtAttribute" EnableClientScript="false" Display="Dynamic">
                                                <img src="Content/img/icon_warning.png"  title="Attribute Name is required" alt="Attribute Name is required" />
                                </asp:RequiredFieldValidator>
                            </EditItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Description">
                            <ItemTemplate>
                                <asp:Literal ID="litDescription" runat="server"></asp:Literal>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtDescription" runat="server" CssClass="ismall changeItemDesc"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn>
                            <ItemTemplate>
                                <div class="btn-group pull-right">
                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                        <i class="icon-cog"></i><span class="caret"></span></a>
                                    <ul class="dropdown-menu pull-right">
                                        <li>
                                            <asp:LinkButton ID="linkEdit" runat="server" CssClass="btn-link" CausesValidation="false"
                                                CommandName="Edit" ToolTip="Edit Sub Attribute"><i class="icon-pencil"></i>Edit</asp:LinkButton></li>
                                        <li>
                                            <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" CausesValidation="false"
                                                CommandName="Delete" ToolTip="Delete Sub Attribute"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
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
                                                CommandName="Save" ToolTip="Save Sub Attribute"><i class="icon-edit"></i>Save Item</asp:LinkButton></li>
                                    </ul>
                                </div>
                            </EditItemTemplate>
                        </asp:TemplateColumn>
                    </Columns>
                </asp:DataGrid>
            </fieldset>
        </div>
        <!-- / -->
        <div class="modal-footer">
        </div>
    </div>
    <!-- / -->
    <!-- Delete Item -->
    <div id="requestDeleteAttribute" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static" style="display: none;">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Attribute</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Attribute?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDeleteAttribute" runat="server" class="btn btn-primary" onserverclick="btnDeleteAttribute_Click"
                data-loading-text="Deleting..." type="submit">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var IsPageValied = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var IsSubAttribute = ('<%=ViewState["IsSubAttribute"]%>' == 'True') ? true : false;        
        var hdnSelectedAttributeID = "<%=hdnSelectedAttributeID.ClientID %>";
        var attributeName = "<%=txtAttributeName.ClientID%>";
        var ddlItem = "<%=ddlItem.ClientID %>";
        var txtAttributeName = "<%=txtAttributeName.ClientID %>";
        var txtDescription = "<%=txtDescription.ClientID %>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID %>";
        var hdnAttributeName = "<%=hdnAttributeName.ClientID %>";
        var hdnAttributeDescription = "<%=hdnAttributeDescription.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            if (!IsPageValied) {
                window.setTimeout(function () {
                    $('#requestAddEditAttribute').modal('show');
                }, 10);
            }

            $('.iadd').click(function () {
                resetFieldsDefault('requestAddEditAttribute');
                ItemAttributesAddEdit(this, true);
            });

            $('.iedit').click(function () {
                ItemAttributesAddEdit(this, false);
            });

            $('.idelete').click(function () {
                $('#' + hdnSelectedAttributeID)[0].value = $(this).attr('qid');
                $('#requestDeleteAttribute').modal('show');
                $('#requestAddEditAttribute').modal('hide');
                $('#dvSubItemAttributes').modal('hide');
            });

            if (IsSubAttribute) {
                $('#dvSubItemAttributes').modal('show');
            }

            $('.changeItemName').keyup(function () {

                $('#' + hdnAttributeName).val($(this).val());

            });

            $('.changeItemDesc').keyup(function () {

                $('#' + hdnAttributeDescription).val($(this).val());

            });

            function ItemAttributesAddEdit(o, n) {
                //Hide the validation summary
                $('div.alert-danger, span.error').hide();
                //Set the popup header text
                $('#requestAddEditAttribute div.modal-header h3 span')[0].innerHTML = (n ? 'New Item Attribute' : 'Edit Item Attribute');
                //Set the popup save button text
                $('#' + btnSaveChanges)[0].innerHTML = (n) ? 'Save Changes' : 'Update';
                //Set item sttribute ID
                $('#' + hdnSelectedAttributeID)[0].value = (n ? '0' : $(o).attr('qid'));
                //If this is edit mode the the parent, name and description or not set default            
                $('#' + txtAttributeName)[0].value = (n ? '' : $(o).parents('tr').children('td')[0].innerHTML);
                $('#' + txtDescription)[0].value = (n ? '' : (($(o).parents('tr').children('td')[1].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[1].innerHTML));

                if (!n) {
                    $('#' + ddlItem).val($(o).parents('tr').children('td')[2].innerHTML);
                    // $('#' + ddlParentAttribute).val($(o).parents('tr').children('td')[3].innerHTML);
                }
                $('#requestAddEditAttribute').modal('show');
            }
        });
    </script>
    <!-- / -->
</asp:Content>
