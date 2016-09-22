<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewDistributors.aspx.cs" Inherits="Indico.ViewDistributors" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddDistributor" runat="server" class="btn btn-link pull-right" href="~/AddEditDistributor.aspx">New Distributor</a>
                <%--<asp:Button ID="btnReplaceCoordinators" runat="server" CssClass="btn btn-primary ireplace pull-right"
                Text="Replace Coordinator" />--%>
                <%-- <input type="button" id="btnReplaceCoordinators" class="btn btn-primary ireplace pull-right"
                    value="Replace Coordinator" />--%>
                <a id="btnReplaceCoordinators" runat="server" href="#replaceCoordinator" role="button"
                    class="btn btn-link pull-right" data-toggle="modal">Replace Coordinator</a>
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
                        <a href="AddEditDistributor.aspx" title="Add an Company.">Add the first Distributor.</a>
                    </h4>
                    <p>
                        You can add as many distributors as you like.
                    </p>
                </div>
                <!-- / -->
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <!-- SORT bY -->
                        <div class="form-inline pull-right">
                            <label>
                                Primary</label>
                            <asp:DropDownList ID="ddlPrimaryCoordinator" CssClass="input-medium" runat="server"
                                AutoPostBack="True" OnSelectedIndexChanged="ddlPrimaryCoordinator_SelectedIndexChanged">
                            </asp:DropDownList>
                            <label>
                                Secondary</label>
                            <asp:DropDownList ID="ddlSecondaryCoordinator" CssClass="input-medium" runat="server"
                                AutoPostBack="True" OnSelectedIndexChanged="ddlSecondaryCoordinator_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                        <!-- / -->
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
                            <telerik:AjaxSetting AjaxControlID="RadGridDistributors">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridDistributors"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridDistributors" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadGridDistributors_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridDistributors_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridDistributors_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnGroupsChanging="RadGridDistributors_GroupsChanging" OnItemCommand="RadGridDistributors_ItemCommand"
                        OnSortCommand="RadGridDistributors_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true" GroupsDefaultExpanded="false">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Name" SortExpression="Name" HeaderText="Name" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" DataField="Name">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="NickName" SortExpression="NickName" HeaderText="Nick Name" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="NickName">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="PrimaryCoordinator" SortExpression="PrimaryCoordinator" HeaderText="Primary Coordinator" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true"
                                    DataField="PrimaryCoordinator">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn Visible="false" UniqueName="SecondaryCoordinator" SortExpression="SecondaryCoordinator" HeaderText="Secondary Coordinator"
                                    FilterControlWidth="100px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    DataField="SecondaryCoordinator">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Distributor"
                                                        Text="Edit" CommandName="Edit"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                                <li>
                                                    <asp:HyperLink ID="lnkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Distributor"><i class="icon-trash"></i>Delete</asp:HyperLink>

                                                </li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="True">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="true" />
                    </telerik:RadGrid>
                    <%--<asp:DataGrid ID="dataGridDistributor" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dataGridDistributor_ItemDataBound" OnPageIndexChanged="dataGridDistributor_PageIndexChanged"
                        OnSortCommand="dataGridDistributor_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="Distributor" HeaderText="ID" Visible="false" HeaderStyle-CssClass="hide"
                                ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Name" SortExpression="Name">
                                <ItemTemplate>
                                    <asp:Literal ID="lblName" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Nick Name" SortExpression="NickName">
                                <ItemTemplate>
                                    <asp:Literal ID="lblNickName" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Primary Coordinator" SortExpression="PrimaryCoordinator">
                                <ItemTemplate>
                                    <asp:Literal ID="lblCoordinator" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Secondary Coordinator" SortExpression="SecondaryCoordinator">
                                <ItemTemplate>
                                    <asp:Literal ID="lblSecondaryCoordinator" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Distributor"
                                                    Text="Edit" CommandName="Edit"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                            <li>
                                                <asp:HyperLink ID="lnkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Distributor"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
                                        </ul>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>--%>
                    <div id="dvPagingFooter" visible="false" class="paginator" runat="server">
                        <div class="paginatorRight">
                            <!--<span class="displaying-num">Displaying 1-10 of <span id="spFooterTotal" runat="server">
                            </span></span>-->
                            <asp:LinkButton ID="lbFooterPrevious" runat="server" class="paginatorPreviousButton"
                                OnClick="lbHeaderPrevious_Click"></asp:LinkButton>
                            <asp:LinkButton ID="lbFooterPreviousDots" runat="server" class="" OnClick="lbHeaderPreviousDots_Click">...</asp:LinkButton>
                            <asp:LinkButton ID="lbFooter1" CssClass="paginatorLink current" runat="server" OnClick="lbHeader1_Click">1</asp:LinkButton>
                            <asp:LinkButton ID="lbFooter2" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">2</asp:LinkButton>
                            <asp:LinkButton ID="lbFooter3" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">3</asp:LinkButton>
                            <asp:LinkButton ID="lbFooter4" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">4</asp:LinkButton>
                            <asp:LinkButton ID="lbFooter5" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">5</asp:LinkButton>
                            <asp:LinkButton ID="lbFooter6" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">6</asp:LinkButton>
                            <asp:LinkButton ID="lbFooter7" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">7</asp:LinkButton>
                            <asp:LinkButton ID="lbFooter8" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">8</asp:LinkButton>
                            <asp:LinkButton ID="lbFooter9" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">9</asp:LinkButton>
                            <asp:LinkButton ID="lbFooter10" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">10</asp:LinkButton>
                            <asp:LinkButton ID="lbFooterNextDots" runat="server" class="dots" OnClick="lbHeaderNextDots_Click">...</asp:LinkButton>
                            <asp:LinkButton ID="lbFooterNext" runat="server" class="paginatorNextButton" OnClick="lbHeaderNext_Click"></asp:LinkButton>
                        </div>
                    </div>
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> did not match
                            any distributors.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedCompanyID" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Distributor</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Distributor?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" onserverclick="btnDelete_Click"
                data-loading-text="Deleting..." type="submit">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Replace Coordinator Item -->
    <div id="replaceCoordinator" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Replace Coordinator</h3>
        </div>
        <div class="modal-body">
            <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <fieldset>
                <div class="control-group">
                    <label class="checkbox inline">
                        <asp:RadioButton ID="rbBoth" runat="server" GroupName="coordinator" Checked="true" />
                        Primary and Secondary
                    </label>
                    <label class="checkbox inline">
                        <asp:RadioButton ID="rbPrimary" runat="server" GroupName="coordinator" />
                        Primary Coordinator
                    </label>
                    <label class="checkbox inline">
                        <asp:RadioButton ID="rbSecondary" runat="server" GroupName="coordinator" />
                        Secondary Coordinator
                    </label>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Current Coordinator
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlCurrentCoordinator" runat="server">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Replace with Coordinator
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlReplaceCoordinator" runat="server">
                        </asp:DropDownList>
                    </div>
                </div>
            </fieldset>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnReplaceCoordinator" runat="server" class="btn btn-primary" onserverclick="btnReplaceCoordinator_Click" data-loading-text="Replacing..."
                type="submit">
                Replace</button>
        </div>
    </div>
    <!-- / -->
    <script type="text/javascript">
        var hdnSelectedID = "<%=hdnSelectedCompanyID.ClientID %>";
        var ReplaceCoordinator = ('<%=ViewState["ReplaceCoordinator"]%>' == 'True') ? true : false;
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show')
            });
        });

    </script>
</asp:Content>
