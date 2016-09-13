<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewClients.aspx.cs" Inherits="Indico.ViewClients" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddClient" runat="server" class="btn btn-link pull-right" href="~/AddEditClient.aspx">New Job Name</a>
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
                        <a href="AddEditClient.aspx" title="Add an Company.">Add the first Job Name.</a>
                    </h4>
                    <p>
                        You can add as many clients as you like.
                    </p>
                </div>
                <!-- / -->
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <!-- SORT bY -->
                    <%--<div class="form-inline pull-right">
                        <label>
                            Distributor</label>
                        <asp:DropDownList ID="ddlDistributor" CssClass="input-large" runat="server" AutoPostBack="True"
                            OnSelectedIndexChanged="ddlDistributor_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>--%>
                    <!-- / -->
                    <!-- Search Control -->
                    <div class="search-control clearfix">
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
                    <%--   <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadGridClients">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridClients"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridClients" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadGridClients_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridClients_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridClients_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnGroupsChanging="RadGridClients_GroupsChanging" OnItemCommand="RadGridClients_ItemCommand"
                        OnSortCommand="RadGridClients_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <GroupingSettings CaseSensitive="false" />
                        <MasterTableView AllowFilteringByColumn="true" GroupsDefaultExpanded="false">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Name" SortExpression="Name" HeaderText="Name" CurrentFilterFunction="Contains" AutoPostBackOnFilter="false"
                                    FilterControlWidth="100px" DataField="Name">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Client" SortExpression="Client" HeaderText="Client" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true"
                                    DataField="Distributor">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Country" SortExpression="Country" HeaderText="Country" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true"
                                    DataField="Country">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="City" SortExpression="City" HeaderText="City"
                                    FilterControlWidth="50px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    DataField="City">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Email" SortExpression="Email" HeaderText="Email" CurrentFilterFunction="Contains" FilterControlWidth="110px" AutoPostBackOnFilter="true"
                                    DataField="Email">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Phone" SortExpression="Phone" HeaderText="Phone" CurrentFilterFunction="Contains"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="Phone">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Client"
                                                        Text="Edit" CommandName="Edit"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="lnkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Client"><i class="icon-trash"></i>Delete</asp:HyperLink>

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
                    <%--<asp:DataGrid ID="dataGridClient" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dataGridClient_ItemDataBound" OnPageIndexChanged="dataGridClient_PageIndexChanged"
                        OnSortCommand="dataGridClient_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="Client" HeaderText="ID" Visible="false" HeaderStyle-CssClass="hide"
                                ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Name" SortExpression="Name">
                                <ItemTemplate>
                                    <asp:Literal ID="lblName" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Distributor" SortExpression="Distributor">
                                <ItemTemplate>
                                    <asp:Literal ID="lblCompany" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Country" SortExpression="Country">
                                <ItemTemplate>
                                    <asp:Literal ID="lblCountry" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="City" SortExpression="City">
                                <ItemTemplate>
                                    <asp:Literal ID="lblCity" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Email" SortExpression="Email">
                                <ItemTemplate>
                                    <asp:Literal ID="lblEmail" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Phone No." SortExpression="Phone">
                                <ItemTemplate>
                                    <asp:Literal ID="lblPhone" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Client"
                                                    Text="Edit" CommandName="Edit"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="lnkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Client"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
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
                            any clients.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedClientID" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Client</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Client?
            </p>
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
        var hdnSelectedID = "<%=hdnSelectedClientID.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid')
                $('#requestDelete').modal('show')
            });
        });
    </script>
</asp:Content>
