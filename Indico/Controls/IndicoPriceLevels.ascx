<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="IndicoPriceLevels.ascx.cs" Inherits="Indico.Controls.IndicoPriceLevels" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<div class="row-fluid">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Empty Content -->
    <div style="text-align: right">
        <asp:Literal ID="litModified" runat="server"></asp:Literal>
        <asp:Button ID="btnBulkSave" runat="server" OnClick="btnBulkSave_Click" Text="Save All" CssClass="btn btn-default" />
    </div>
    <div id="dvEmptyContent" runat="server" class="alert alert-info">
        <%--<h2>
                        <a href="javascript:SettingAddEdit(this, true, 'New Setting');" title="Add an Setting.">Add the first Setting.</a>
                    </h2>--%>
        <p>
            No cost sheets found.
        </p>
    </div>
    <!-- / -->
    <%--Data Content--%>
    <div id="dvDataContent" runat="server">
        <!-- Search Control -->
        <div class="search-control clearfix">
            <%-- <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch" Visible="">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>--%>
        </div>
        <!-- / -->
        <!-- Data Table -->
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro"
            EnableEmbeddedSkins="true">
        </telerik:RadAjaxLoadingPanel>
        <telerik:RadGrid ID="RadGridCostSheets" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="false" OnPageSizeChanged="RadGridCostSheets_PageSizeChanged"
            PageSize="20" OnPageIndexChanged="RadGridCostSheets_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
            AutoGenerateColumns="false" OnItemDataBound="RadGridCostSheets_ItemDataBound" OnItemCreated="RadGridCostSheets_ItemCreated"
            Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true" EnableLinqExpressions="false"
            OnItemCommand="RadGridCostSheets_ItemCommand"
            OnSortCommand="RadGridCostSheets_SortCommand">
            <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
            <GroupingSettings CaseSensitive="false" />
            <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
            <MasterTableView AllowFilteringByColumn="true">
                <Columns>
                    <telerik:GridTemplateColumn UniqueName="CostSheet" HeaderText="Cost Sheet" SortExpression="CostSheetId" FilterControlWidth="50px" AllowFiltering="true" DataField="CostSheetId" CurrentFilterFunction="EqualTo" Groupable="false">
                        <ItemTemplate>
                            <asp:HyperLink ID="hlCostSheet" runat="server"></asp:HyperLink>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridBoundColumn UniqueName="PatternCode" SortExpression="PatternCode" HeaderText="Pattern Code" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="50px" DataField="PatternCode">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn UniqueName="PatternNickName" SortExpression="PatternNickName" HeaderText="Pattern Desc" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="200px" DataField="PatternNickName">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn UniqueName="FabricCode" SortExpression="FabricCode" HeaderText="Fabric Code" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="50px" DataField="FabricCode">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn UniqueName="FabricName" SortExpression="FabricName" HeaderText="Fabric" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="100px" DataField="FabricName">
                    </telerik:GridBoundColumn>
                    <telerik:GridTemplateColumn UniqueName="FabricPrice" ItemStyle-HorizontalAlign="Right" SortExpression="FabricPrice" HeaderText="Fabric Cost" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="50px" DataField="FabricPrice">
                        <ItemTemplate>
                            <asp:Literal ID="litFabricCost" runat="server"></asp:Literal>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridBoundColumn UniqueName="CoreCategory" SortExpression="CoreCategory" HeaderText="Core Category" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="100px" DataField="CoreCategory">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn UniqueName="ItemCategory" SortExpression="ItemCategory" HeaderText="Item Category" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="100px" DataField="ItemCategory">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn UniqueName="LastModifier" SortExpression="LastModifier" HeaderText="Last Modifier" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="100px" DataField="LastModifier">
                    </telerik:GridBoundColumn>
                    <telerik:GridTemplateColumn UniqueName="ModifiedDate" SortExpression="ModifiedDate" HeaderText="Modified Date" DataType="System.DateTime" Groupable="false"
                        FilterControlWidth="100px" DataField="ModifiedDate">
                        <ItemTemplate>
                            <asp:Literal ID="litModifiedDate" runat="server"></asp:Literal>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridBoundColumn UniqueName="Remarks" SortExpression="Remarks" HeaderText="Remarks" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="100px" DataField="Remarks">
                    </telerik:GridBoundColumn>
                    <telerik:GridTemplateColumn UniqueName="FOBCost" ItemStyle-HorizontalAlign="Right" SortExpression="FOBCost" HeaderText="FOB Cost" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="50px" DataField="FOBCost">
                        <ItemTemplate>
                            <asp:Literal ID="litFOBCost" runat="server"></asp:Literal>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn UniqueName="QuotedFOBPrice" ItemStyle-HorizontalAlign="Right" SortExpression="QuotedFOBPrice" HeaderText="JK Price" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="50px" DataField="QuotedFOBPrice">
                        <ItemTemplate>
                            <asp:Literal ID="litQuotedFOBPrice" runat="server"></asp:Literal>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn UniqueName="IndimanPrice" ItemStyle-HorizontalAlign="Right" SortExpression="IndimanPrice" HeaderText="Indiman Price" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="50px" DataField="IndimanPrice">
                        <ItemTemplate>
                            <asp:Literal ID="litIndimanPrice" runat="server"></asp:Literal>
                            <asp:TextBox ID="txtIndimanPrice" runat="server" Width="50px" Height="15px" Style="text-align: right"></asp:TextBox>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn UniqueName="ActMgn" ItemStyle-HorizontalAlign="Right" SortExpression="ActMgn" HeaderText="Margin Value" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="50px" DataField="ActMgn">
                        <ItemTemplate>
                            <asp:Literal ID="litActMgn" runat="server"></asp:Literal>
                            <asp:HiddenField ID="hdnCSID" runat="server" Value="0" />
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn UniqueName="QuotedMp" ItemStyle-HorizontalAlign="Right" SortExpression="QuotedMp" HeaderText="Margin %" CurrentFilterFunction="Contains" Groupable="false"
                        FilterControlWidth="50px" DataField="QuotedMp">
                        <ItemTemplate>
                            <asp:Literal ID="litQuotedMp" runat="server"></asp:Literal>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                </Columns>
            </MasterTableView>
            <ClientSettings AllowDragToGroup="false">
            </ClientSettings>
            <GroupingSettings ShowUnGroupButton="false" />
        </telerik:RadGrid>
        <!-- / -->
        <!-- No Search Result -->
        <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
            <h4>Your search - <strong>
                <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                            any documents.</h4>
        </div>
        <script type="text/javascript">
            var levelCount = '<%=ViewState["LevelCount"]%>';

            $(document).ready(function () {
                $('.iWhatPrice').keyup(function () {
                    WhatIfPrice(this);
                });

                $('.iWhatPercentage').keyup(function () {
                    WhatIfPercentage(this);
                });

                function WhatIfPrice(o) {
                    var cifPrice = $(o).parents('tr').children('td')[9].innerHTML.replace('$', '');
                    //alert(cifPrice);

                    var whatPrice = $(o).val();
                    var percentageColumn = 11 + parseInt(levelCount);

                    if (isNaN(whatPrice) || (whatPrice == '')) {
                        $(o).parents('tr').children('td')[percentageColumn].children[0].value = '';
                    }
                    else {
                        var whatPercentage = 100 - (100 * cifPrice / whatPrice);
                        whatPercentage = whatPercentage.toFixed(2);
                        $(o).parents('tr').children('td')[percentageColumn].children[0].value = whatPercentage + '%';
                    }
                }

                function WhatIfPercentage(o) {
                    var cifPrice = $(o).parents('tr').children('td')[9].innerHTML.replace('$', '');
                    //alert(cifPrice);

                    var whatPercentage = $(o).val();
                    var priceColumn = 10 + parseInt(levelCount);

                    if (isNaN(whatPercentage) || (whatPercentage == '')) {
                        $(o).parents('tr').children('td')[priceColumn].children[0].value = '';
                    }
                    else {
                        var whatPrice = (100 * cifPrice) / (100 - whatPercentage);
                        whatPrice = whatPrice.toFixed(2);
                        $(o).parents('tr').children('td')[priceColumn].children[0].value = '$' + whatPrice;
                    }
                }
            });
        </script>
    </div>
    <!-- / -->
</div>
