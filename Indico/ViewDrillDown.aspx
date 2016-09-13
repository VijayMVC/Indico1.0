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
                   <telerik:RadGrid ID="OrderGrid"  AllowPaging="true" AutoGenerateColumns="false" AllowFilteringByColumn="true" AllowSorting="true" ShowGroupPanel="True"
                            ShowFooter="True" runat="server"  EnableLinqExpressions="False" PageSize="25" OnItemDataBound="OnOrderGridItemDataBound"
                            EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true" CssClass="RadGrid"
                            Skin="Metro" EnableEmbeddedSkins="true" >
                             <GroupingSettings CaseSensitive="false" />
                            <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                            <MasterTableView ShowGroupFooter="true" AllowMultiColumnSorting="false">
                                 <Columns>
                                    <telerik:GridBoundColumn DataField="Week" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Week" UniqueName="Week" SortExpression="Week" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridTemplateColumn DataField="PurchaseOrderNumber" FilterControlWidth="50px" AllowFiltering="True" HeaderText="P.O No" UniqueName="PurchaseOrderNumber" SortExpression="PurchaseOrderNumber" Groupable="false">
                                        <ItemTemplate>
                                           <asp:HyperLink target="_blank" ID="PONumberLink" runat="server"></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn DataField="Product"   FilterControlWidth="50px" AllowFiltering="True" HeaderText="Product" UniqueName="Product" SortExpression="Product" Groupable="false">
                                         <ItemTemplate>
                                           <asp:HyperLink target="_blank" ID="ProductLink" runat="server"></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn DataField="Pattern" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Pattern" UniqueName="Pattern" SortExpression="Pattern" Groupable="false">
                                         <ItemTemplate>
                                           <asp:HyperLink target="_blank" ID="patternLink" runat="server"></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn DataField="Fabric" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Fabric" UniqueName="Fabric" SortExpression="Fabric" Groupable="false">
                                         <ItemTemplate>
                                           <asp:HyperLink target="_blank" ID="fabricLink" runat="server"></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridDateTimeColumn DataField="OrderDate" FilterControlWidth="100px" AllowFiltering="True" PickerType="DatePicker" EnableTimeIndependentFiltering="true" DataFormatString="{0:dddd, dd MMMM  yyyy}" HeaderText="Order Date" UniqueName="OrderDate" SortExpression="OrderDate" Groupable="false"></telerik:GridDateTimeColumn>
                                    <telerik:GridDateTimeColumn DataField="ETD" FilterControlWidth="100px" AllowFiltering="True" PickerType="DatePicker" EnableTimeIndependentFiltering="true" DataFormatString="{0:dddd, dd MMMM  yyyy}" HeaderText="ETD" UniqueName="ETD" SortExpression="ETD" Groupable="false"></telerik:GridDateTimeColumn>
                                    <telerik:GridBoundColumn DataField="Coodinator" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Coodinator" UniqueName="Coodinator" SortExpression="Coodinator" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="OrderType" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Order Type" UniqueName="OrderType" SortExpression="OrderType" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Distributor" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Distributor" UniqueName="Distributor" SortExpression="Distributor" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Client" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Client" UniqueName="Client" SortExpression="Client" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="JobName" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Job Name" UniqueName="JobName" SortExpression="JobName" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="OrgQty" FilterControlWidth="50px" DataFormatString="{0:n}" ItemStyle-HorizontalAlign="Right" AllowFiltering="True" HeaderText="Org Qty" UniqueName="OrgQty" SortExpression="OrgQty" Groupable="false"  Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right"  FooterAggregateFormatString="{0:N0}"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="UsedQty" FilterControlWidth="50px" DataFormatString="{0:n}" ItemStyle-HorizontalAlign="Right" AllowFiltering="True" HeaderText="Used Qty" UniqueName="UsedQty" SortExpression="UsedQty" Groupable="false"  Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right"  FooterAggregateFormatString="{0:N0}"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="BalQty" FilterControlWidth="50px" DataFormatString="{0:n}" ItemStyle-HorizontalAlign="Right" AllowFiltering="True" HeaderText="Bal Qty" UniqueName="BalQty" SortExpression="BalQty" Groupable="false"  Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right"  FooterAggregateFormatString="{0:N0}"></telerik:GridBoundColumn>
                                    <telerik:GridTemplateColumn DataField="Qty" FilterControlWidth="50px" ItemStyle-HorizontalAlign="Right" AllowFiltering="True" HeaderText="Quantity" UniqueName="Qty" SortExpression="Qty" Groupable="false"  Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right"  FooterAggregateFormatString="{0:N0}">
                                        <ItemTemplate>
                                            <asp:HyperLink target="_blank" runat="server" ID="QtyLink"></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridBoundColumn DataField="ProductionLine" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Production Line" UniqueName="ProductionLine" SortExpression="ProductionLine" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="ItemSubCat" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Item Sub Cat" UniqueName="SubItemName" SortExpression="SubItemName" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="PrintType" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Print Type" UniqueName="PrintType" SortExpression="PrintType" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="ShipTo" FilterControlWidth="50px" AllowFiltering="True" HeaderText="ShipTo" UniqueName="ShipTo" SortExpression="ShipTo" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Port" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Port" UniqueName="Port" SortExpression="Port" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Mode" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Mode" UniqueName="Mode" SortExpression="Mode" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Status" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Status" UniqueName="Status" SortExpression="Status" Groupable="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="SMV" DataFormatString="{0:n}" FilterControlWidth="50px" AllowFiltering="true"  HeaderText="SMV" UniqueName="SMV" SortExpression="SMV" Groupable="false" ItemStyle-HorizontalAlign="Right" Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right"  FooterAggregateFormatString="{0:N0}"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="TotalSMV" DataFormatString="{0:n}" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Total SMV" UniqueName="TotalSMV" SortExpression="TotalSMV" ItemStyle-HorizontalAlign="Right" Groupable="false" Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right"  FooterAggregateFormatString="{0:N0}" ></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="ShipQty" DataFormatString="{0:n}" FilterControlWidth="50px" AllowFiltering="True" HeaderText="Ship Qty" UniqueName="ShipQty" SortExpression="ShipQty" ItemStyle-HorizontalAlign="Right" Groupable="false" Aggregate="Sum" FooterStyle-ForeColor="Green" FooterStyle-HorizontalAlign="Right" Visible="False"  FooterAggregateFormatString="{0:N0}" ></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Terms" FilterControlWidth="50px" Visible="False" AllowFiltering="True" HeaderText="Terms" UniqueName="Terms" SortExpression="Terms" Groupable="false"></telerik:GridBoundColumn>
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