<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="DrillDownReportByClient.aspx.cs" Inherits="Indico.DrillDownReportByClient" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="aspContent" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
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
                        <telerik:RadGrid ID="RadGridDrillDownReportByClient" ShowGroupPanel="false" AutoGenerateColumns="false" AllowFilteringByColumn="true" AllowSorting="true"
                            ShowFooter="True" runat="server" GridLines="None" AllowPaging="true" EnableLinqExpressions="false" PageSize="50" OnItemDataBound="RadGridDrillDownReportByClient_ItemDataBound"
                            OnPageSizeChanged="RadGridDrillDownReportByClient_PageSizeChanged" OnPageIndexChanged="RadGridDrillDownReportByClient_PageIndexChanged" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                            Skin="Metro" CssClass="RadGrid" EnableEmbeddedSkins="true" OnItemCommand="RadGridDrillDownReportByClient_ItemCommand" OnItemCreated="RadGridDrillDownReportByClient_OnItemCreated" OnSortCommand="RadGridDrillDownReportByClient_SortCommand"
                            >
                            <PagerStyle Mode="NextPrevAndNumeric"></PagerStyle>
                            <MasterTableView ShowGroupFooter="true" AllowMultiColumnSorting="false">
                                <Columns>
                                    <telerik:GridBoundColumn Aggregate="None" DataField="VLName" UniqueName="VLName" SortExpression="VLName" HeaderText="VL Name" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn Aggregate="None" DataField="SubItemName" UniqueName="SubItemName" HeaderText="Sub Item Name" SortExpression="SubItemName" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn Aggregate="Sum" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataField="Quantity" HeaderText="Quantity" UniqueName="Quantity" SortExpression="Quantity" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                       FooterAggregateFormatString="{0:N0}" FooterStyle-Font-Bold="true" DataFormatString="{0:N0}" FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn  DataField="Price"  HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderText="Price" UniqueName="Price" SortExpression="Price" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                       FooterAggregateFormatString="{0:C2}" FooterStyle-Font-Bold="true" DataFormatString="{0:C2}" FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn Aggregate="Sum"  HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataField="Value" UniqueName="Value" HeaderText="Sales Value" SortExpression="Value" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                        FooterText="" FooterAggregateFormatString="{0:C2}" DataFormatString="{0:C2}"  FooterStyle-Font-Bold="true"  FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn Display="False" Aggregate="Sum" DataField="PurchasePrice"  HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" UniqueName="PurchasePrice" HeaderText="Purchase Value" SortExpression="PurchasePrice" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                        FooterText="" FooterAggregateFormatString="{0:C2}" DataFormatString="{0:C2}"  FooterStyle-Font-Bold="true"  FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn FooterStyle-HorizontalAlign="Right"  HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Aggregate="Sum" DataField="GrossProfit" UniqueName="GrossProfit" HeaderText="Gross Profit" SortExpression="GrossProfit" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                       DataFormatString="{0:C2}" FooterAggregateFormatString="{0:C2}" FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn FooterStyle-HorizontalAlign="Right"  HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataField="GrossMargin" UniqueName="GrossMargin" HeaderText="Gross Margin %" SortExpression="GrossMargin" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                      FooterText="GM" DataFormatString="{0:P1}" FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                </Columns>
                                <%--<GroupByExpressions>
                                    <telerik:GridGroupByExpression>
                                        <GroupByFields>
                                            <telerik:GridGroupByField FieldName="MonthAndYear" SortOrder="None"></telerik:GridGroupByField>
                                        </GroupByFields>
                                        <SelectFields>
                                            <telerik:GridGroupByField FieldName="MonthAndYear" FieldAlias="MonthAndYear" SortOrder="None"></telerik:GridGroupByField>
                                        </SelectFields>
                                    </telerik:GridGroupByExpression>
                                </GroupByExpressions>  --%>                              
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

