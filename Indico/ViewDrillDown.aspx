<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewDrillDown.aspx.cs" Inherits="Indico.ViewDrillDown" MasterPageFile="~/Indico.Master"%>
<asp:Content ID="Content" ContentPlaceHolderID="iContentPlaceHolder" runat="server" >
    <asp:ScriptManager ID="PatternScriprtManaget" runat="server">
    </asp:ScriptManager>
    <div class="Page">
        <div class="page-header">
            <div class="header-actions">
                <asp:LinkButton ID="ExportToExcellButton" runat="server" CssClass="btn btn-link pull-right" OnClick="OnExportToExcelButtonClick"><i class="icon-excel"></i> Export To Excel</asp:LinkButton>
            </div>
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
                   <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
                   </telerik:RadAjaxLoadingPanel>
                   <telerik:RadGrid ID="OrderGrid"  AllowPaging="True" GroupingEnabled="True" AutoGenerateColumns="False" AllowFilteringByColumn="True" AllowSorting="True" ShowGroupPanel="True"
                            ShowFooter="True" runat="server"   EnableLinqExpressions="True" PageSize="25" OnItemDataBound="OnOrderGridItemDataBound" OnPageSizeChanged="OrderGrid_OnPageSizeChanged" OnPageIndexChanged="OrderGrid_OnPageIndexChanged"
                            EnableHeaderContextMenu="True" EnableHeaderContextFilterMenu="True" CssClass="RadGrid" OnSortCommand="OrderGrid_OnSortCommand" OnGroupsChanging="OrderGrid_OnGroupsChanging" G
                            Skin="Metro" EnableEmbeddedSkins="true" >
                             <GroupingSettings CaseSensitive="false" />
                             <HeaderContextMenu OnItemClick="OnItemClick"></HeaderContextMenu>
                            <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                            <MasterTableView ShowGroupFooter="true" AllowMultiColumnSorting="true">
                                 <Columns>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="Week" FilterControlWidth="50px" AllowFiltering="True"  HeaderText="Week" UniqueName="Week" SortExpression="Week" GroupByExpression="Week"  CurrentFilterFunction="Contains" Groupable="True"></telerik:GridBoundColumn>
                                    <telerik:GridTemplateColumn AutoPostBackOnFilter="true" DataField="PurchaseOrderNumber" CurrentFilterFunction="Contains" FilterControlWidth="50px" AllowFiltering="True" HeaderText="P.O No" UniqueName="PurchaseOrderNumber" SortExpression="PurchaseOrderNumber" Groupable="True">
                                        <ItemTemplate>
                                           <asp:HyperLink target="_blank" ID="PONumberLink" runat="server"></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn AutoPostBackOnFilter="true" DataField="Product"   FilterControlWidth="50px" AllowFiltering="True" HeaderText="Product" UniqueName="Product" SortExpression="Product" Groupable="True">
                                         <ItemTemplate>
                                           <asp:HyperLink target="_blank" ID="ProductLink" runat="server"></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn AutoPostBackOnFilter="true" DataField="Pattern" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Pattern" UniqueName="Pattern" SortExpression="Pattern" Groupable="True">
                                         <ItemTemplate>
                                           <asp:HyperLink target="_blank" ID="patternLink" runat="server"></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn AutoPostBackOnFilter="true" DataField="Fabric" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Fabric" UniqueName="Fabric" SortExpression="Fabric" Groupable="True">
                                         <ItemTemplate>
                                           <asp:HyperLink target="_blank" ID="fabricLink" runat="server"></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridDateTimeColumn AutoPostBackOnFilter="true" DataField="OrderDate" FilterControlWidth="100px" AllowFiltering="True" PickerType="DatePicker" EnableTimeIndependentFiltering="true" DataFormatString="{0:dddd, dd MMMM  yyyy}" HeaderText="Order Date" UniqueName="OrderDate" SortExpression="OrderDate" Groupable="True"></telerik:GridDateTimeColumn>
                                    <telerik:GridDateTimeColumn AutoPostBackOnFilter="true" DataField="ETD" FilterControlWidth="100px" AllowFiltering="True" PickerType="DatePicker" EnableTimeIndependentFiltering="true" DataFormatString="{0:dddd, dd MMMM  yyyy}" HeaderText="ETD" UniqueName="ETD" SortExpression="ETD" Groupable="True"></telerik:GridDateTimeColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="Coodinator" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Coodinator" UniqueName="Coodinator" SortExpression="Coodinator" Groupable="True"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="OrderType" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Order Type" UniqueName="OrderType" SortExpression="OrderType" Groupable="True"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="Distributor" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Distributor" UniqueName="Distributor" SortExpression="Distributor" Groupable="True"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="Client" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Client" UniqueName="Client" SortExpression="Client" Groupable="True"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="JobName" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Job Name" UniqueName="JobName" SortExpression="JobName" Groupable="True"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="OrgQty" FilterControlWidth="50px" DataFormatString="{0:n}" ItemStyle-HorizontalAlign="Right" AllowFiltering="True" HeaderText="Org Qty" UniqueName="OrgQty" SortExpression="OrgQty" Groupable="True"  Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right"  FooterAggregateFormatString="{0:N0}"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="UsedQty" FilterControlWidth="50px" DataFormatString="{0:n}" ItemStyle-HorizontalAlign="Right" AllowFiltering="True" HeaderText="Used Qty" UniqueName="UsedQty" SortExpression="UsedQty" Groupable="True"  Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right"  FooterAggregateFormatString="{0:N0}"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="BalQty" FilterControlWidth="50px" DataFormatString="{0:n}" ItemStyle-HorizontalAlign="Right" AllowFiltering="True" HeaderText="Bal Qty" UniqueName="BalQty" SortExpression="BalQty" Groupable="True"  Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right"  FooterAggregateFormatString="{0:N0}"></telerik:GridBoundColumn>
                                    <telerik:GridTemplateColumn AutoPostBackOnFilter="true" DataField="Qty" FilterControlWidth="50px" ItemStyle-HorizontalAlign="Right" AllowFiltering="True" HeaderText="Quantity" UniqueName="Qty" SortExpression="Qty" Groupable="True"  Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right"  FooterAggregateFormatString="{0:N0}">
                                        <ItemTemplate>
                                            <asp:HyperLink target="_blank" runat="server" ID="QtyLink"></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="ProductionLine" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Production Line" UniqueName="ProductionLine" SortExpression="ProductionLine" Groupable="True"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="ItemSubCat" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Item Sub Cat" UniqueName="SubItemName" SortExpression="SubItemName" Groupable="True"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="PrintType" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Print Type" UniqueName="PrintType" SortExpression="PrintType" Groupable="True"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="ShipTo" FilterControlWidth="50px" AllowFiltering="True" HeaderText="ShipTo" UniqueName="ShipTo" SortExpression="ShipTo" Groupable="True"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="Port" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Port" UniqueName="Port" SortExpression="Port" Groupable="True"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="Mode" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Mode" UniqueName="Mode" SortExpression="Mode" Groupable="True"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="Status" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Status" UniqueName="Status" SortExpression="Status" Groupable="True"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="SMV" DataFormatString="{0:n}" FilterControlWidth="50px" AllowFiltering="true"  HeaderText="SMV" UniqueName="SMV" SortExpression="SMV" Groupable="True" ItemStyle-HorizontalAlign="Right" Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right"  FooterAggregateFormatString="{0:N0}"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="TotalSMV" DataFormatString="{0:n}" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Total SMV" UniqueName="TotalSMV" SortExpression="TotalSMV" ItemStyle-HorizontalAlign="Right" Groupable="True" Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right"  FooterAggregateFormatString="{0:N0}" ></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="ShipQty" DataFormatString="{0:n}" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Ship Qty" UniqueName="ShipQty" SortExpression="ShipQty" ItemStyle-HorizontalAlign="Right" Groupable="True" Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right" Display="False"  FooterAggregateFormatString="{0:N0}" ></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="Terms" FilterControlWidth="50px" Display="False" AllowFiltering="True" HeaderText="Terms" UniqueName="Terms" SortExpression="Terms" Groupable="True"></telerik:GridBoundColumn>
                                     <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="IsBrandingKit" FilterControlWidth="50px"  Display="False" AllowFiltering="True" HeaderText="Is Branding Kit" UniqueName="IsBrandingKit" SortExpression="IsBrandingKit" GroupByExpression="IsBrandingKit" Groupable="True"></telerik:GridBoundColumn>
                                     <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="PhotoApproval" FilterControlWidth="50px"  Display="False" AllowFiltering="True" HeaderText="Photo Approval" UniqueName="PhotoApproval" SortExpression="PhotoApproval" GroupByExpression="PhotoApproval" Groupable="True"></telerik:GridBoundColumn>
                                     <telerik:GridBoundColumn AutoPostBackOnFilter="true" DataField="DetailStatus" FilterControlWidth="50px"  Display="True" AllowFiltering="True" HeaderText="Detail Status" UniqueName="DetailStatus" SortExpression="DetailStatus" GroupByExpression="DetailStatus" Groupable="True"></telerik:GridBoundColumn>
                                 </Columns> 
                            </MasterTableView>
                   </telerik:RadGrid> <!--End Of WeeklyPiecesSummaryRedGrid-->
                 </div> <!--End Of Data Context -->
           </div> <!-- End Of Row-->
        </div><!--End Of Page Content-->
        <script type="text/javascript">
            function OpenInNewTab(url) {
                var win = window.open(url, "_blank");
                win.focus();
            }
        </script>
    </div> <!--End Of The Page-->
    
</asp:Content>