<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="DrillDownReport.aspx.cs" Inherits="Indico.DrillDownReport" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="aspContent" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <%--<button id="btnBack1" runat="server" class="btn btn-info pull-right" onserverclick="btnBack_Click">Back</button>                --%>
                <asp:HyperLink ID="lbBack" runat="server" Text="Back" class="btn btn-info pull-right" ForeColor="White"></asp:HyperLink>
            </div>  
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal> 
            </h3>      
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server">
                    </telerik:RadAjaxLoadingPanel>
                  <div class="demo-container no-bg">
                        <telerik:RadGrid ID="RadGridDrillDownReport" ShowGroupPanel="false" AutoGenerateColumns="false" AllowFilteringByColumn="true" AllowSorting="true"
                            ShowFooter="True" runat="server" GridLines="None" AllowPaging="true" EnableLinqExpressions="false" PageSize="50" OnItemDataBound="RadGridDrillDownReport_ItemDataBound"
                            OnPageSizeChanged="RadGridDrillDownReport_PageSizeChanged" OnPageIndexChanged="RadGridDrillDownReport_PageIndexChanged" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                            Skin="Metro" CssClass="RadGrid" EnableEmbeddedSkins="true" OnItemCommand="RadGridDrillDownReport_ItemCommand" OnItemCreated="RadGridDrillDownReport_OnItemCreated" OnSortCommand="RadGridDrillDownReport_SortCommand"
                            OnCustomAggregate="RadGridDrillDownReport_CustomAggregate">
                            <PagerStyle Mode="NextPrevAndNumeric"></PagerStyle>
                            <MasterTableView ShowGroupFooter="true" AllowMultiColumnSorting="false">
                                <Columns>
                                    <telerik:GridBoundColumn Aggregate="Custom" FooterText=""  FooterAggregateFormatString="{0:C2}"  DataField="Client" HeaderText="Client" UniqueName="Client" SortExpression="Client"  CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridTemplateColumn HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Aggregate="Sum" DataField="Quantity" HeaderText="Units" UniqueName="Quantity" SortExpression="Quantity" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                       FooterAggregateFormatString="{0:N0}" FooterStyle-Font-Bold="true" FilterControlWidth="50px">
                                        <ItemTemplate>
                                            <asp:HyperLink  ID="lnkQuantity" Font-Underline="True" runat="server"></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridBoundColumn HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Aggregate="Sum" DataField="QuantityPercentage" UniqueName="QuantityPercentage" HeaderText="% of Units"  SortExpression="QuantityPercentage" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                        DataFormatString="{0:P}" FooterAggregateFormatString="{0:P1}"  FilterControlWidth="50px" Display="False">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Aggregate="Sum" DataField="Value" UniqueName="Value" HeaderText="Sales Value" SortExpression="Value" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                        FooterText="" FooterAggregateFormatString="{0:C2}" DataFormatString="{0:C2}"  FooterStyle-Font-Bold="true"  FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                     <telerik:GridBoundColumn Display="False" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Aggregate="Sum" DataField="PurchasePrice" UniqueName="PurchasePrice" HeaderText="Purchase Value" SortExpression="PurchasePrice" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                        FooterText="" FooterAggregateFormatString="{0:C2}" DataFormatString="{0:C2}"  FooterStyle-Font-Bold="true"  FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Aggregate="Sum" DataField="ValuePercentage" UniqueName="ValuePercentage" HeaderText="% of Value" SortExpression="ValuePercentage" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                       DataFormatString="{0:P}" FooterAggregateFormatString="{0:P1}"  FilterControlWidth="50px" Display="False">
                                    </telerik:GridBoundColumn>
                                     <telerik:GridBoundColumn HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Aggregate="Avg" DataField="AvgPrice" UniqueName="AvgPrice" HeaderText="Avg Price" SortExpression="AvgPrice" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                        FooterText="" DataFormatString="{0:C2}" FooterStyle-Font-Bold="true"  FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Aggregate="Sum" DataField="GrossProfit" UniqueName="GrossProfit" HeaderText="Gross Profit" SortExpression="GrossProfit" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                       DataFormatString="{0:C2}" FooterAggregateFormatString="{0:C2}" FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataField="GrossMargin" UniqueName="GrossMargin" HeaderText="Gross Margin %" SortExpression="GrossMargin" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                       DataFormatString="{0:P}" FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                </Columns>
                            <%--    <GroupByExpressions>
                                    <telerik:GridGroupByExpression>
                                        <GroupByFields>
                                            <telerik:GridGroupByField FieldName="MonthAndYear"  SortOrder="None"></telerik:GridGroupByField>
                                        </GroupByFields>
                                        <SelectFields>
                                            <telerik:GridGroupByField FieldName="MonthAndYear" FieldAlias="MonthAndYear" SortOrder="None"></telerik:GridGroupByField>
                                        </SelectFields>
                                    </telerik:GridGroupByExpression>
                                </GroupByExpressions>      --%>                          
                            </MasterTableView>
                            <GroupingSettings ShowUnGroupButton="false" CaseSensitive="false" RetainGroupFootersVisibility="true"></GroupingSettings>
                        </telerik:RadGrid>
                    </div>
               

            </div>
            <!-- / -->
        </div>
    </div>
    <!-- / -->
</asp:Content>

