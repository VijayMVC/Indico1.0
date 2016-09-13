<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="SalesGridReport.aspx.cs" Inherits="Indico.SalesGridReport" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="aspContent" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <script type="text/javascript">
        $(document).ready(function () {
            var nowTemp = new Date();
            var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);
            $('.input-daterange').datepicker({ format: 'M dd, yyyy' });
        });
    </script>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <div>
                    <div>
                        <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                            ValidationGroup="validateDate" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the report below</strong>"></asp:ValidationSummary>
                    </div>
                    <div class="search-control clearfix">
                        <div id="dvAdminFilters" runat="server" class="form-inline pull-left well well-sm">
                            <div class="pull-left" >
                                <label>Distributor Name</label>
                                <asp:TextBox ID="txtName" runat="server" CssClass="input-large"></asp:TextBox>
                                <asp:RadioButton ID="rdoDirectSales" GroupName="DistributorType" runat="server" Checked="true" Style="padding-left: 40px" />
                                <label>Direct Sales</label>
                                <asp:RadioButton ID="rdoWholesale" GroupName="DistributorType" runat="server" Style="padding-left: 20px" />
                                <label>Wholesale</label>
                                <%--<div style="display: none">
                                <label>Distributor</label>
                                <asp:DropDownList ID="ddlDistributor" runat="server" CssClass="input-xlarge"></asp:DropDownList>
                            </div>--%>
                            </div>
                            <div class="input-daterange pull-left" style="padding-left: 40px" id="datepicker" runat="server">
                                Order Date &nbsp <span class="add-on">From</span>
                                <input type="text" class="input-small" name="start" id="txtCheckin" runat="server" />
                                <asp:RequiredFieldValidator ID="rfvTxtCheckin" runat="server" ErrorMessage="Start date is required"
                                    ValidationGroup="validateDate" ControlToValidate="txtCheckin" EnableClientScript="true">
                               <img src="Content/img/icon_warning.png"  title="Start date is required" alt="Start date is required" />
                                </asp:RequiredFieldValidator>
                                <span class="add-on">to</span>
                                <input type="text" class="input-small" name="end" id="txtCheckout" runat="server" />
                                <asp:RequiredFieldValidator ID="rfvTxtCheckout" runat="server" ErrorMessage="End date is required"
                                    ValidationGroup="validateDate" ControlToValidate="txtCheckout" EnableClientScript="true">
                               <img src="Content/img/icon_warning.png"  title="End date is required" alt="End date is required" />
                                </asp:RequiredFieldValidator>
                                <asp:CustomValidator ID="cvDateRange" runat="server" ControlToValidate="txtCheckout" EnableClientScript="true"
                                    ErrorMessage="Start date should be less than end date" ValidationGroup="validateDate" OnServerValidate="cvDateRange_ServerValidate">
                                    <img src="Content/img/icon_warning.png"  title="Start date should be less than end date" alt="Start date should be less than end date" />
                                </asp:CustomValidator>
                            </div>
                            <div class="pull-left">
                                <asp:Button ID="btnViewReport" CssClass="btn btn-info" runat="server" Text="View Report" ValidationGroup="validateDate" OnClick="btnViewReport_OnClick" />
                            </div>
                        </div>
                    </div>
                </div>
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <p>
                        There are no records to be shown.
                    </p>
                </div>
                <div id="dvDataContent" runat="server">
                    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server">
                    </telerik:RadAjaxLoadingPanel>
                    <div class="demo-container no-bg">
                        <telerik:RadGrid ID="RadGridSalesReport" ShowGroupPanel="false" AutoGenerateColumns="false" AllowFilteringByColumn="true" AllowSorting="true"
                            ShowFooter="True" runat="server" GridLines="None" AllowPaging="true" EnableLinqExpressions="false" PageSize="50" OnItemDataBound="RadGridSalesReport_ItemDataBound"
                            OnPageSizeChanged="RadGridSalesReport_PageSizeChanged" OnPageIndexChanged="RadGridSalesReport_PageIndexChanged" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                            Skin="Metro" CssClass="RadGrid" EnableEmbeddedSkins="true" OnItemCommand="RadGridSalesReport_ItemCommand" OnItemCreated="RadGridSalesReport_OnItemCreated" OnSortCommand="RadGridSalesReport_SortCommand"
                            OnCustomAggregate="RadGridOrders_CustomAggregate">
                            <PagerStyle Mode="NextPrevAndNumeric"></PagerStyle>
                            <MasterTableView ShowGroupFooter="true" AllowMultiColumnSorting="false">
                                <Columns>
                                    <telerik:GridBoundColumn FooterStyle-HorizontalAlign="Right" Aggregate="Custom" FooterText=""  FooterAggregateFormatString="{0:C2}" DataField="Name" HeaderText="Distributor" UniqueName="Name" SortExpression="Name"  CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridTemplateColumn FooterStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" Aggregate="Sum" DataField="Quantity" HeaderText="Units" UniqueName="Quantity" SortExpression="Quantity" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                       FooterAggregateFormatString="{0:N0}" FooterStyle-Font-Bold="true"  FilterControlWidth="50px">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="lnkQuantity" Font-Underline="True" runat="server" ></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridBoundColumn FooterStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right"  Aggregate="Sum" DataField="QuantityPercentage" UniqueName="QuantityPercentage" HeaderText="% of Units"  SortExpression="QuantityPercentage" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                        DataFormatString="{0:P2}" FooterAggregateFormatString="{0:P1}"  FilterControlWidth="50px" Display="False">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn FooterStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" Aggregate="Sum" DataField="Value" UniqueName="Value" HeaderText="Sales Value" SortExpression="Value" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                        FooterText="" FooterAggregateFormatString="{0:C2}" DataFormatString="{0:C2}"  FooterStyle-Font-Bold="true"  FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn FooterStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" Display="False" Aggregate="Sum" DataField="PurchasePrice" UniqueName="PurchasePrice" HeaderText="Purchase Value" SortExpression="PurchasePrice" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                        FooterText="" FooterAggregateFormatString="{0:C2}" DataFormatString="{0:C2}"  FooterStyle-Font-Bold="true"  FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn FooterStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" Aggregate="Sum" DataField="ValuePercentage" UniqueName="ValuePercentage" HeaderText="% of Value" SortExpression="ValuePercentage" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                       DataFormatString="{0:P2}" FooterAggregateFormatString="{0:P1}"  FilterControlWidth="50px"  Display="False">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn FooterStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" Aggregate="Custom" DataField="AvgPrice" UniqueName="AvgPrice" HeaderText="Avg Price" SortExpression="AvgPrice" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                        FooterText="" DataFormatString="{0:C2}"  FooterStyle-Font-Bold="true"  FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn FooterStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" Aggregate="Sum" DataField="GrossProfit" UniqueName="GrossProfit" HeaderText="Gross Profit" SortExpression="GrossProfit" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                       DataFormatString="{0:C2}" FooterAggregateFormatString="{0:C2}"  FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>
                                    <%--<telerik:GridBoundColumn Aggregate="None" DataField="GrossMargin" UniqueName="GrossMargin" HeaderText="Gross Margin %" SortExpression="GrossMargin" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                       DataFormatString="{0:N2}" FooterAggregateFormatString="{0:C2}"  FilterControlWidth="50px">
                                    </telerik:GridBoundColumn>--%>
                                    <telerik:GridTemplateColumn FooterStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataField="GrossMargin" UniqueName="GrossMargin" HeaderText="Gross Margin %" SortExpression="GrossMargin" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                        FilterControlWidth="50px">
                                        <ItemTemplate>
                                            <asp:Literal ID="litGrossMargin" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                </Columns>
                                <GroupByExpressions>
                                    <telerik:GridGroupByExpression>
                                        <GroupByFields>
                                            <telerik:GridGroupByField FieldName="MonthAndYear" SortOrder="None"></telerik:GridGroupByField>
                                        </GroupByFields>
                                        <SelectFields>
                                            <telerik:GridGroupByField FieldName="MonthAndYear" FieldAlias="MonthAndYear" SortOrder="None"></telerik:GridGroupByField>
                                        </SelectFields>
                                    </telerik:GridGroupByExpression>
                                </GroupByExpressions>                                
                            </MasterTableView>
                            <GroupingSettings ShowUnGroupButton="false" CaseSensitive="false" RetainGroupFootersVisibility="true"></GroupingSettings>
                        </telerik:RadGrid>
                    </div>
                </div>
                <!-- <div>
                  
                </div> -->

            </div>
            <!-- / -->
        </div>
    </div>
    <!-- / -->
</asp:Content>

