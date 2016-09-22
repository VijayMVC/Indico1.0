<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewHSCode.aspx.cs" Inherits="Indico.ViewHSCode" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddHSCode" runat="server" class="btn btn-link iadd pull-right">New HS Code</a>
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
                        <a href="javascript:HSCodeAddEdit(this, true, 'New HS Code');" title="Add an HS Code.">Add the first HS Code.</a>
                    </h4>
                    <p>
                        You can add as many HS Codes as you like.
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
                    <%--<telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadGridHSCode">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridHSCode"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridHSCode" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="false" OnPageSizeChanged="RadGridHSCode_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridHSCode_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridHSCode_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridHSCode_ItemCommand"
                        OnSortCommand="RadGridHSCode_SortCommand">
                        <GroupingSettings CaseSensitive="false" />
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                       <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true" TableLayout="Auto">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="ItemSubCategoryID" AllowSorting="false" AllowFiltering="false" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false" HeaderText="ItemCategoryID"
                                    DataField="ItemSubCategoryID">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="GenderID" SortExpression="GenderID" AllowSorting="false" AllowFiltering="false" Groupable="false" HeaderText="GenderID"
                                    AutoPostBackOnFilter="true" DataField="GenderID">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Code" SortExpression="Code" HeaderText="Code" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="150px" AutoPostBackOnFilter="true" DataField="Code">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="ItemSubCategory" SortExpression="ItemSubCategory" HeaderText="ItemSubCategory" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="150px" AutoPostBackOnFilter="true" DataField="ItemSubCategory">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Gender" SortExpression="Gender" HeaderText="Gender" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="150px" AutoPostBackOnFilter="true" DataField="Gender">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit HS Code"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete HS Code"><i class="icon-trash"></i>Delete</asp:HyperLink>

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
                    <%--     <asp:DataGrid ID="dgHSCode" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dgHSCode_ItemDataBound" OnPageIndexChanged="dgHSCode_PageIndexChanged"
                        OnSortCommand="dgHSCode_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="ItemSubCategory" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide">
                            </asp:BoundColumn>
                            <asp:BoundColumn DataField="Gender" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide">
                            </asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Code">
                                <ItemTemplate>
                                    <asp:Literal ID="litCode" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="ItemSubGroup">
                                <ItemTemplate>
                                    <asp:Literal ID="litItemSUbGroup" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Gender">
                                <ItemTemplate>
                                    <asp:Literal ID="litGender" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit HS Code"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                            <li>
                                                <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete HS Code"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
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
                            any HS Code.</h4>
                    </div>
                </div>
                <!-- / -->
            </div>
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnHSCode" runat="server" Value="0" />
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
                        Item Sub Group</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlItemSubGroup" runat="server">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvItemSubGroup" runat="server" CssClass="error"
                            ControlToValidate="ddlItemSubGroup" Display="Dynamic" EnableClientScript="False"
                            InitialValue="0" ErrorMessage="Item Sub Group is required">
                                <img src="Content/img/icon_warning.png" title="Item Sub Group is required" alt="Item Sub Group is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Gender</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlGender" runat="server">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvGender" runat="server" CssClass="error" ControlToValidate="ddlGender"
                            Display="Dynamic" EnableClientScript="False" InitialValue="0" ErrorMessage="Gender is required">
                                <img src="Content/img/icon_warning.png" title="Gender is required" alt="Gender is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCode" runat="server" MaxLength="128"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvHSCode" runat="server" CssClass="error" ControlToValidate="txtCode"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Code is required">
                                <img src="Content/img/icon_warning.png" title="Code is required" alt="Code is required" />
                        </asp:RequiredFieldValidator>
                        <asp:CustomValidator ID="cvHSCode" runat="server" CssClass="error" ControlToValidate="txtCode"
                            OnServerValidate="cvHSCode_OnServerValidate" Display="Dynamic" EnableClientScript="False"
                            ErrorMessage="This Sub Item and Gender is already used">
                              <img src="Content/img/icon_warning.png" title="This Sub Item and Gender is already used" alt="This Sub Item and Gender is already used" />
                        </asp:CustomValidator>
                    </div>
                </div>
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
            <h3>Delete HS Code</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this hs code?
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
        var txtCode = "<%=txtCode.ClientID%>";
        var ddlItemSubGroup = "<%=ddlItemSubGroup.ClientID%>";
        var ddlGender = "<%=ddlGender.ClientID%>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID%>";
        var hdnSelectedID = "<%=hdnHSCode.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.iadd').click(function () {
                resetFieldsDefault('requestAddEdit');
                HSCodeAddEdit(this, true);
            });

            $('.iedit').click(function () {
                fillText(this);
                HSCodeAddEdit(this, false);
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
        });

        function HSCodeAddEdit(o, n) {
            $('div.alert-danger, span.error').hide();
            $('#requestAddEdit div.modal-header h3 span')[0].innerHTML = (n ? 'Add HS Code' : 'Edit HS Code');
            $('#' + btnSaveChanges)[0].innerHTML = (n) ? 'Save Changes' : 'Update';
            $('#' + hdnSelectedID).val(n ? '0' : $(o).attr('qid'));
            $('#requestAddEdit').modal('show');
        }

        function fillText(o) {
            $('#' + txtCode)[0].value = $(o).parents('tr').children('td')[2].innerHTML.trim();
            $('#' + ddlItemSubGroup).val($(o).parents('tr').children('td')[0].innerHTML)
            $('#' + ddlGender).val($(o).parents('tr').children('td')[1].innerHTML)
        }


    </script>
</asp:Content>
