<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewSummaryDetails.aspx.cs" Inherits="Indico.ViewSummaryDetails" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Empty Content -->
                <!-- / -->
                <%--Data Content--%>
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <!-- / -->
                    <!-- Data Table -->
                    <telerik:RadGrid ID="RadGridWeeklySummary" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="false" OnPageSizeChanged="RadGridWeeklySummary_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridWeeklySummary_PageIndexChanged" ShowFooter="true" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridWeeklySummary_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridWeeklySummary_ItemCommand"
                        OnSortCommand="RadGridWeeklySummary_SortCommand" EnableHeaderContextAggregatesMenu="true">
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <MasterTableView AllowFilteringByColumn="true" GroupsDefaultExpanded="false">
                            <Columns>
                                <telerik:GridTemplateColumn FilterControlWidth="75px" AutoPostBackOnFilter="false" HeaderText="ETD">
                                    <ItemTemplate>
                                        <asp:Literal ID="litWeekEnDate" runat="server" Text=""></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="ShipmentMode" SortExpression="ShipmentMode" HeaderText="Shipment Mode" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true" DataField="ShipmentMode">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="CompanyName" SortExpression="CompanyName" HeaderText="Company Name" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true"
                                    DataField="CompanyName">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn FilterControlWidth="50px" SortExpression="Qty" AutoPostBackOnFilter="false" HeaderText="Total" DataField="Qty" Groupable="false">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkTotal" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Literal ID="litQty" runat="server"></asp:Literal>
                                    </FooterTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="PaymentMethod" SortExpression="PaymentMethod" HeaderText="Payment Method" Groupable="false" CurrentFilterFunction="Contains"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="PaymentMethod">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Country" SortExpression="Country" HeaderText="Country" CurrentFilterFunction="Contains" Groupable="false" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="Country">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn FilterControlWidth="50px" AllowFiltering="true" AutoPostBackOnFilter="false" DataField="InvoiceStatus" HeaderText="Invoice Status" Groupable="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="litStatus" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridDateTimeColumn DataField="ShipmentDate" HeaderText="Shipment Date" FilterControlWidth="100px" Groupable="false"
                                    SortExpression="ShipmentDate" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridTemplateColumn FilterControlWidth="50px" AllowFiltering="false" AutoPostBackOnFilter="false" HeaderText="View Invoice" Groupable="false">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkInvoice" runat="server">View Invoice</asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn FilterControlWidth="50px" AllowFiltering="false" AutoPostBackOnFilter="false" HeaderText="Invoice Number" Groupable="false">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtInvoiceNo" runat="server" CssClass="itxt input-medium"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn FilterControlWidth="50px" AllowFiltering="false" AutoPostBackOnFilter="false" HeaderText="Create" Groupable="false">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnCreateInvoice" Style="display: none;" Text="Create" runat="server" OnClick="btnCreateInvoice_Click" ToolTip="Create Invoice" CssClass="icreate"></asp:LinkButton>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <GroupingSettings CaseSensitive="false" />
                    </telerik:RadGrid>
                    <%-- <asp:DataGrid ID="dgWeeklySummary" runat="server" CssClass="table" AllowCustomPaging="False" PageSize="20"
                        AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        OnItemDataBound="dgWeeklySummary_ItemDataBound">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:TemplateColumn HeaderText="ETD" ItemStyle-Width="20%">
                                <ItemTemplate>
                                    <asp:Literal ID="litWeekEnDate" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Mode" ItemStyle-Width="20%">
                                <ItemTemplate>
                                    <asp:Literal ID="litShipmentMode" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Send To" ItemStyle-Width="20%">
                                <ItemTemplate>
                                    <asp:Literal ID="litShipTo" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Total" ItemStyle-Width="20%">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkTotal" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Invoice No" ItemStyle-Width="5%">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtInvoiceNo" runat="server" CssClass="itxt input-medium"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Create" ItemStyle-Width="5%">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnCreateInvoice" Style="display: none;" Text="Create" runat="server" OnClick="btnCreateInvoice_Click" ToolTip="Create Invoice" CssClass="icreate"></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>--%>
                    <%-- <h4 class="text-right">Total: 
                        <asp:Literal ID="litGrandTotal" runat="server"></asp:Literal>
                    </h4>--%>
                    <!-- / -->
                    <!-- No Search Result -->
                </div>
                <!-- / -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h4>No orders have been added for this Week.
                    </h4>
                </div>
            </div>
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedAgeGroupID" runat="server" Value="0" />
    <script type="text/javascript">
        
    </script>
    <script type="text/javascript">
        $(document).ready(function () {

            $('.itxt').keyup(function () {

                if ($(this).length > 0) {
                    $(this).closest('tr').find('.icreate').attr('style', 'display:block');
                }
                else {
                    $(this).closest('tr').find('.icreate').attr('style', 'display:none');
                }

            });

        });
    </script>
</asp:Content>
