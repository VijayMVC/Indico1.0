<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewUsers.aspx.cs" Inherits="Indico.ViewUsers" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddUser" runat="server" class="btn btn-link pull-right" href="~/AddEditUser.aspx">New User</a>
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
                        <a href="AddEditUser.aspx" title="Add an Company.">Add the first User.</a>
                    </h4>
                    <p>
                        You can add as many useres as you like.
                    </p>
                </div>
                <!-- / -->
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <div id="dvSortBy" runat="server" class="form-inline pull-right">
                            <label>
                                Filter by</label>
                            <asp:DropDownList ID="ddlSortByCompany" CssClass="input-medium" runat="server" AutoPostBack="True"
                                OnSelectedIndexChanged="ddlSortByCompany_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                        <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>
                    </div>
                    <!-- / -->
                    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro"
                        EnableEmbeddedSkins="true">
                    </telerik:RadAjaxLoadingPanel>
                    <%-- <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadGridUsers">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridUsers"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridUsers" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadGridUsers_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridUsers_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridUsers_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnGroupsChanging="RadGridUsers_GroupsChanging" OnItemCommand="RadGridUsers_ItemCommand"
                        OnSortCommand="RadGridUsers_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true" GroupsDefaultExpanded="false">
                            <Columns>
                                <telerik:GridTemplateColumn FilterControlWidth="75px" DataField="Name" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" HeaderText="Name">
                                    <ItemTemplate>
                                        <asp:Image ID="imgUser" runat="server" CssClass="avatar32"></asp:Image>
                                        <asp:Literal ID="lblName" runat="server" Text=""></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="Company" SortExpression="Company" HeaderText="Company" CurrentFilterFunction="Contains"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true" DataField="Company">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="UserName" SortExpression="UserName" HeaderText="UserName" CurrentFilterFunction="Contains"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true"
                                    DataField="UserName">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Email" SortExpression="Email" HeaderText="Email" CurrentFilterFunction="Contains"
                                    FilterControlWidth="110px" AutoPostBackOnFilter="true"
                                    DataField="Email">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="RoleName" SortExpression="RoleName" HeaderText="User Role" CurrentFilterFunction="Contains"
                                    FilterControlWidth="110px" AutoPostBackOnFilter="true"
                                    DataField="RoleName">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Status" SortExpression="Status" HeaderText="Status"
                                    FilterControlWidth="120px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    DataField="Status">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit User"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete User"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
                                                <li>
                                                    <asp:LinkButton ID="linkResend" runat="server" CssClass="btn-link iupdate" OnClick="linkResend_Click"
                                                        ToolTip="Resend Mail"><i class="icon-repeat"></i>Resend Mail</asp:LinkButton>

                                                </li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="True">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="true" CaseSensitive="false" />
                    </telerik:RadGrid>
                    <%--<asp:DataGrid ID="dataGridUser" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dataGridUser_ItemDataBound" OnPageIndexChanged="dataGridUser_PageIndexChanged"
                        OnSortCommand="dataGridUser_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="ID" HeaderText="ID" Visible="false" HeaderStyle-CssClass="hide"
                                ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Name" SortExpression="GivenName">
                                <ItemTemplate>
                                    <asp:Image ID="imgUser" runat="server" CssClass="avatar32"></asp:Image>
                                    <asp:Literal ID="lblName" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Company" SortExpression="Company">
                                <ItemTemplate>
                                    <asp:Literal ID="lblCompany" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:BoundColumn DataField="Username" HeaderText="Username" SortExpression="Username"></asp:BoundColumn>
                            <asp:BoundColumn DataField="EmailAddress" HeaderText="Email" SortExpression="EmailAddress"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Status" SortExpression="Status">
                                <ItemTemplate>
                                    <asp:Literal ID="lblStatus" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit User"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                            <li>
                                                <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete User"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
                                            <li>
                                                <asp:LinkButton ID="linkResend" runat="server" CssClass="btn-link iupdate" OnClick="linkResend_Click"
                                                    ToolTip="Resend Mail"><i class="icon-repeat"></i>Resend Mail</asp:LinkButton></li>
                                        </ul>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>--%>
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> did not match
                            any users.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedUserID" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete User</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this User?
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
        var hdnSelectedID = "<%=hdnSelectedUserID.ClientID %>";
        var ddlSortByCompany = "<%=ddlSortByCompany.ClientID %>";        
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show')
            });
                        
            $('#' + ddlSortByCompany).select2();
        });
    </script>
</asp:Content>
