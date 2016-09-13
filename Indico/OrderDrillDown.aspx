<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OrderDrillDown.aspx.cs" Inherits="Indico.OrderDrillDown" MasterPageFile="~/Indico.Master"%>
<asp:Content ID="Content" ContentPlaceHolderID="iContentPlaceHolder" runat="server" >
    <asp:ScriptManager ID="PatternScriprtManaget" runat="server">
    </asp:ScriptManager>
    <div class="Page">
        <div class="page-header">
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div> <!--End Of The Page-Header-->
         <div class="page-content">
            <div class="row-fluid">
                 <div id="dvEmptyContent" Visible="False" runat="server" class="alert alert-info">
                    <h4>
                        <a title="Weekly Pieces Capacities.">Order Drill Down</a>
                    </h4>
                    <p>
                        There are no data to show
                    </p>
                </div> <!-- Empty COntent-->
                <div id="dvDataContent" runat="server" Visible="False">
                   <telerik:RadGrid ID="OrderGrid" ShowGroupPanel="false" AutoGenerateColumns="false" AllowFilteringByColumn="true" AllowSorting="true"
                            ShowFooter="True" runat="server" GridLines="None" AllowPaging="true" EnableLinqExpressions="false" PageSize="50" OnItemDataBound="OnOrderGridItemDataBound"
                            EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                            Skin="Metro" EnableEmbeddedSkins="true" >
                            <PagerStyle Mode="NextPrevAndNumeric"></PagerStyle>
                            <MasterTableView ShowGroupFooter="true" AllowMultiColumnSorting="false">
                                <Columns>
                                    <telerik:GridBoundColumn DataField="Week" AllowFiltering="False" HeaderText="Week" UniqueName="Week" SortExpression="Week" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="PurchaseOrderNumber" AllowFiltering="False" HeaderText="P.O No" UniqueName="PurchaseOrderNumber" SortExpression="PurchaseOrderNumber" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="VlName" AllowFiltering="False" HeaderText="Product" UniqueName="Product" SortExpression="Product" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Pattern" AllowFiltering="False" HeaderText="Pattern" UniqueName="Pattern" SortExpression="Pattern" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Fabric" AllowFiltering="False" HeaderText="Fabric" UniqueName="Fabric" SortExpression="Fabric" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridDateTimeColumn DataField="OrderDate" AllowFiltering="False" PickerType="DatePicker" EnableTimeIndependentFiltering="true" DataFormatString="{0:dddd, dd MMMM  yyyy}" HeaderText="Order Date" UniqueName="OrderDate" SortExpression="OrderDate" Groupable="false"></telerik:GridDateTimeColumn>
                                    <telerik:GridDateTimeColumn DataField="ETD" AllowFiltering="False" PickerType="DatePicker" EnableTimeIndependentFiltering="true" DataFormatString="{0:dddd, dd MMMM  yyyy}" HeaderText="ETD" UniqueName="ETD" SortExpression="ETD" Groupable="false"></telerik:GridDateTimeColumn>
                                    <telerik:GridBoundColumn DataField="Coodinator" AllowFiltering="False" HeaderText="Coodinator" UniqueName="Coodinator" SortExpression="Coodinator" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="OrderType" AllowFiltering="False" HeaderText="Order Type" UniqueName="OrderType" SortExpression="OrderType" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Distributor" AllowFiltering="False" HeaderText="Distributor" UniqueName="Distributor" SortExpression="Distributor" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Client" AllowFiltering="False" HeaderText="Client" UniqueName="Client" SortExpression="Client" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Quantity" ItemStyle-HorizontalAlign="Right" AllowFiltering="False" HeaderText="Quantity" UniqueName="Quantity" SortExpression="Quantity" Groupable="false"  Aggregate="Sum" FooterStyle-ForeColor="Green"  FooterAggregateFormatString="{0:N0}"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="ProductionLine" AllowFiltering="False" HeaderText="ProductionLine" UniqueName="ProductionLine" SortExpression="ProductionLine" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="SubItemName" AllowFiltering="False" HeaderText="SubItemName" UniqueName="SubItemName" SortExpression="SubItemName" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="PrintType" AllowFiltering="False" HeaderText="PrintType" UniqueName="PrintType" SortExpression="PrintType" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="ShipTo" AllowFiltering="False" HeaderText="ShipTo" UniqueName="ShipTo" SortExpression="ShipTo" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Port" AllowFiltering="False" HeaderText="Port" UniqueName="Port" SortExpression="Port" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Mode" AllowFiltering="False" HeaderText="Mode" UniqueName="Mode" SortExpression="Mode" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Status" AllowFiltering="False" HeaderText="Status" UniqueName="Status" SortExpression="Status" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="SMV" AllowFiltering="False" HeaderText="SMV" UniqueName="SMV" SortExpression="SMV" Groupable="false"  Aggregate="Sum" FooterStyle-ForeColor="Green"  FooterAggregateFormatString="{0:N0}"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Total SMV" AllowFiltering="False" HeaderText="TotalSMV" UniqueName="TotalSMV" SortExpression="TotalSMV" Groupable="false" Aggregate="Sum" FooterStyle-ForeColor="Green"  FooterAggregateFormatString="{0:N0}" ></telerik:GridBoundColumn>
                                </Columns>
                            </MasterTableView>
                   </telerik:RadGrid> <!--End Of WeeklyPiecesSummaryRedGrid-->
                 </div> <!--End Of Data Context -->
           </div> <!-- End Of Row-->
        </div><!--End Of Page Content-->
    </div> <!--End Of The Page-->
    
</asp:Content>