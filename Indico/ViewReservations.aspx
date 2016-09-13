<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewReservations.aspx.cs" Inherits="Indico.ViewReservations" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddOrder" runat="server" class="btn btn-link pull-right" href="~/AddEditReservation.aspx">New Reservation</a>
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
                        <a href="AddEditReservation.aspx" title="Add a Reservation.">Add the first reservation.</a>
                    </h4>
                    <p>
                        You can add as many reservations as you like.
                    </p>
                </div>
                <!-- / -->
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <div class="form-inline pull-right">
                            <label>
                                Filter by Status</label>
                            <asp:DropDownList ID="ddlFilterBy" runat="server" CssClass="input-medium" AutoPostBack="True"
                                OnSelectedIndexChanged="ddlFilterBy_SelectedIndexChanged">
                            </asp:DropDownList>
                           <%-- <label>
                                Filter by Distributor</label>
                            <asp:DropDownList ID="ddlDistributor" runat="server" CssClass="input-medium" AutoPostBack="True"
                                OnSelectedIndexChanged="ddlDistributor_SelectedIndexChanged">
                            </asp:DropDownList>
                            <label>
                                Filter by Coordinator</label>
                            <asp:DropDownList ID="ddlCoordinator" runat="server" CssClass="input-medium" AutoPostBack="True"
                                OnSelectedIndexChanged="ddlCoordinator_SelectedIndexChanged">
                            </asp:DropDownList>--%>
                        </div>
                        <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>
                    </div>
                    <!-- / -->
                    <!-- Data Table -->
                    <telerik:RadGrid ID="RadGridReservations" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadGridReservations_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridReservations_PageIndexChanged" ShowFooter="false" OnGroupsChanging="RadGridReservations_GroupsChanging" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridReservations_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridReservations_ItemCommand"
                        OnSortCommand="RadGridReservations_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="ReservationNo" SortExpression="ReservationNo" HeaderText="Res No." AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    FilterControlWidth="75px" DataField="ReservationNo">
                                </telerik:GridBoundColumn>
                                <telerik:GridDateTimeColumn DataField="OrderDate" HeaderText="Date" FilterControlWidth="110px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true"
                                    SortExpression="OrderDate" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridBoundColumn UniqueName="Pattern" SortExpression="Pattern" HeaderText="Pattern" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Pattern">
                                </telerik:GridBoundColumn>
                                <telerik:GridNumericColumn UniqueName="Qty" SortExpression="Qty" HeaderText="Reserved Qty" DataFormatString="{0} " ItemStyle-Width="5%" CurrentFilterFunction="Contains"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="Qty">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="UsedQty" SortExpression="UsedQty" HeaderText="Used" DataFormatString="{0} " ItemStyle-Width="5%" CurrentFilterFunction="Contains"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="UsedQty">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="Balance" SortExpression="Balance" HeaderText="Balance" DataFormatString="{0} " ItemStyle-Width="5%" CurrentFilterFunction="Contains"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="Balance">
                                </telerik:GridNumericColumn>
                                <telerik:GridBoundColumn UniqueName="Coordinator" SortExpression="Coordinator" HeaderText="Coordinator" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Coordinator">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Client" SortExpression="Client" HeaderText="Client" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Client">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Distributor" SortExpression="Distributor" HeaderText="Distributor" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Distributor">
                                </telerik:GridBoundColumn>
                                <telerik:GridDateTimeColumn DataField="ShipmentDate" HeaderText="Shipment Date" FilterControlWidth="110px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true"
                                    SortExpression="ShipmentDate" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridBoundColumn UniqueName="Notes" SortExpression="Notes" HeaderText="Notes" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Notes">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="Status" AllowFiltering="false" Groupable="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblStatus" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <%--<telerik:GridTemplateColumn HeaderText="Create Order" AllowFiltering="false" Groupable="false" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="6%">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkCreateOrder" runat="server" CssClass="btn-link iadd" ToolTip="Create Order using this Reservation"><i class="icon-plus"></i></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="View Orders" AllowFiltering="false" Groupable="false" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="6%">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkViewOrders" runat="server" CssClass="btn-link iview" ToolTip="View Orders"><i class="icon-th-list"></i></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>--%>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Reservation"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Reservation"><i class="icon-trash"></i>Delete</asp:HyperLink>
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

                    <%--<asp:DataGrid ID="dgReservations" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dgReservations_ItemDataBound" OnPageIndexChanged="dgReservations_PageIndexChanged"
                        OnSortCommand="dgReservations_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:TemplateColumn HeaderText="Res No" SortExpression="">
                                <ItemTemplate>
                                    <asp:Literal ID="lblResNo" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Date" SortExpression="OrderDate">
                                <ItemTemplate>
                                    <asp:Literal ID="lblDate" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Pattern No" SortExpression="Pattern">
                                <ItemTemplate>
                                    <asp:Literal ID="lblPatternNo" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Reserved Qty" SortExpression="Qty">
                                <ItemTemplate>
                                    <asp:Literal ID="lblReservedQty" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Total Order Qty" SortExpression="">
                                <ItemTemplate>
                                    <asp:Literal ID="lblOrderQty" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Coordinator" SortExpression="">
                                <ItemTemplate>
                                    <asp:Literal ID="lblCoordinator" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Client" SortExpression="Client">
                                <ItemTemplate>
                                    <asp:Literal ID="lblClient" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Distributor" SortExpression="Distributor">
                                <ItemTemplate>
                                    <asp:Literal ID="lblDistributor" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Shipment Date" SortExpression="ShipmentDate">
                                <ItemTemplate>
                                    <asp:Literal ID="lblOrderShipmentDate" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Notes" SortExpression="">
                                <ItemTemplate>
                                    <asp:Literal ID="lblNotes" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Status" SortExpression="Status">
                                <ItemTemplate>
                                    <asp:Literal ID="lblStatus" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Create Order">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkCreateOrder" runat="server" CssClass="btn-link iadd" ToolTip="Create Order Using This Reservation"><i class="icon-plus"></i></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="View Orders">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkViewOrders" runat="server" CssClass="btn-link iview" ToolTip="View Orders"><i class="icon-th-list"></i></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Reservation"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Reservation"><i class="icon-trash"></i>Delete</asp:HyperLink>
                                            </li>
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
                            any orders.</h4>
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
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Reservation</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this reservation?
            </p>
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
    <script type="text/javascript">
        var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
        var txtSearch = "<%=txtSearch.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });
        });
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            if ($.browser.msie) {
                $('#' + txtSearch).val('Search');
                $('#' + txtSearch).focus(function () {
                    this.select();
                });
            }
        });
    </script>
</asp:Content>
