<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewEmbroideries.aspx.cs" Inherits="Indico.ViewEmbroideries" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddEmbroidery" href="AddEditEmbroidery.aspx" runat="server" class="btn btn-link iadd pull-right">New Embroidery</a>
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
                        <a href="AddEditEmbroidery.aspx" title="Add an Embroidery.">Add the first Embroidery.</a>
                    </h4>
                    <p>
                        You can add as many Embroideries as you like.
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
                    <%-- <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadGridEmbroideries">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridEmbroideries"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridEmbroideries" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadGridEmbroideries_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridEmbroideries_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridEmbroideries_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnGroupsChanging="RadGridEmbroideries_GroupsChanging" OnItemCommand="RadGridEmbroideries_ItemCommand"
                        OnSortCommand="RadGridEmbroideries_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <GroupingSettings CaseSensitive="false" />
                        <MasterTableView AllowFilteringByColumn="true" TableLayout="Auto" GroupsDefaultExpanded="false">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Embroidery" SortExpression="Embroidery" HeaderText="Embroidery No." CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    FilterControlWidth="50px" DataField="Embroidery">
                                </telerik:GridBoundColumn>
                                <telerik:GridDateTimeColumn DataField="EmbStrikeOffDate" HeaderText="Strike Off Reqstd" FilterControlWidth="110px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true"
                                    SortExpression="EmbStrikeOffDate" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridDateTimeColumn DataField="PhotoRequiredBy" HeaderText="Strike Off Rqd" FilterControlWidth="110px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true"
                                    SortExpression="PhotoRequiredBy" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridBoundColumn UniqueName="JobName" SortExpression="JobName" HeaderText="Job Name" CurrentFilterFunction="Contains"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true" DataField="JobName">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Distributor" SortExpression="Distributor" HeaderText="Distributor" CurrentFilterFunction="Contains"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true"
                                    DataField="Distributor">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Coordinator" SortExpression="Coordinator" HeaderText="Coordinator" CurrentFilterFunction="Contains"
                                    FilterControlWidth="110px" AutoPostBackOnFilter="true"
                                    DataField="Coordinator">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Client" SortExpression="Client" HeaderText="Client"
                                    FilterControlWidth="120px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    DataField="Client">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Assign" SortExpression="Assign" HeaderText="Assign To" CurrentFilterFunction="Contains"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true"
                                    DataField="Assign">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Creator" SortExpression="Creator" HeaderText="Creator" CurrentFilterFunction="Contains"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true"
                                    DataField="Creator">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Modifier" SortExpression="Modifier" HeaderText="Modifier" CurrentFilterFunction="Contains"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true"
                                    DataField="Modifier">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Embroidery"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Embroidery"><i class="icon-trash"></i>Delete</asp:HyperLink>

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
                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                            any Embroidery.</h4>
                    </div>
                </div>
                <!-- / -->
            </div>
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Embroidery</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Embroidery?
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
        var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {

            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });
        });
    </script>
</asp:Content>
