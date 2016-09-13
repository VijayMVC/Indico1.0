<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewProductionPlanningDetails.aspx.cs" Inherits="Indico.ViewProductionPlanningDetails" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <%-- <div class="header-actions">
                <a id="btnAddGender" runat="server" class="btn btn-link iadd pull-right">New Gender</a>
            </div>--%>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Data Content -->
                <!-- Search Control -->
                <div class="search-control clearfix">
                    <div class="form-inline pull-right">
                        <asp:Button ID="btnSaveAll" runat="server" Text="Save All" OnClick="btnSaveAll_Click" CssClass="btn-info" Visible="false" />
                    </div>
                    <%-- <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>--%>
                    <asp:DropDownList ID="ddlWeek" runat="server" CssClass="input-large" OnSelectedIndexChanged="ddlWeek_SelectedIndexChanged" AutoPostBack="true"></asp:DropDownList>
                </div>
                <div id="dvDataContent" runat="server" visible="false">
                    <!-- / -->
                    <!-- Data Table -->
                    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro"
                        EnableEmbeddedSkins="true">
                    </telerik:RadAjaxLoadingPanel>
                    <%-- <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="rgProdPlans">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="rgProdPlans"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="rgProdPlans" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="false" OnPageSizeChanged="rgProdPlans_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="rgProdPlans_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="rgProdPlans_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="rgProdPlans_ItemCommand"
                        OnSortCommand="rgProdPlans_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true" ShowGroupFooter="true" ShowFooter="true">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Week" SortExpression="Week" HeaderText="Week" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="50px" DataField="Week">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Pattern" SortExpression="Pattern" HeaderText="Pattern" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="50px" DataField="Pattern">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="OrderType" SortExpression="OrderType" HeaderText="OrderType" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="50px" DataField="OrderType">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="PurchaseOrder" SortExpression="PurchaseOrder" HeaderText="PurchaseOrder" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="50px" DataField="PurchaseOrder">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn Aggregate="Count" FooterAggregateFormatString="{0}" UniqueName="Product" SortExpression="Product" HeaderText="Product" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="50px" DataField="Product">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn UniqueName="ProductionLine" FilterControlWidth="50px" HeaderText="Production Line" DataField="ProductionLine">
                                    <ItemTemplate>
                                        <asp:DropDownList ID="ddlProductionLine" runat="server" CssClass="input-medium"></asp:DropDownList>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn UniqueName="SewingDate" FilterControlWidth="50px" HeaderText="Sewing Date" DataField="SewingDate" DataType="System.DateTime">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtSewingDate" runat="server" CssClass="input-small sewingdate"></asp:TextBox>
                                    </ItemTemplate>
                                    <FilterTemplate>
                                        <telerik:RadDatePicker RenderMode="Lightweight" ID="ShippedDatePicker" runat="server" Width="100px" MinDate="01-01-2010"
                                            ClientEvents-OnDateSelected="DateSelected" DateInput-ClientEvents-OnKeyPress="KeyPressed" />
                                        <telerik:RadScriptBlock ID="RadScriptBlock2" runat="server">
                                            <script type="text/javascript">
                                                function DateSelected(sender, args) {
                                                    var tableView = $find("<%# ((GridItem)Container).OwnerTableView.ClientID %>");

                                                    var date = FormatSelectedDate(sender);

                                                    //alert(date);

                                                    tableView.filter("SewingDate", date, "EqualTo");
                                                }
                                                function FormatSelectedDate(picker) {
                                                    var date = picker.get_selectedDate();
                                                    var dateInput = picker.get_dateInput();
                                                    var formattedDate = dateInput.get_dateFormatInfo().FormatDate(date, dateInput.get_displayDateFormat());

                                                    return formattedDate;
                                                }
                                                function KeyPressed(sender, args) {
                                                    //alert('key');
                                                    tableView.filter("SewingDate", "", "NoFilter");
                                                }
                                            </script>
                                        </telerik:RadScriptBlock>
                                    </FilterTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn Aggregate="Sum" FooterAggregateFormatString="{0}" UniqueName="Quantity" SortExpression="Quantity" HeaderText="Quantity" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="50px" DataField="Quantity">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn UniqueName="FOCPenalty" SortExpression="FOCPenalty" HeaderText="Priority" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="50px" DataField="FOCPenalty">
                                    <ItemTemplate>
                                        <asp:Literal ID="litPriority" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn Aggregate="Sum" FooterAggregateFormatString="{0}" UniqueName="SMV" SortExpression="SMV" HeaderText="SMV" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="50px" DataField="SMV">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn Aggregate="Sum" FooterAggregateFormatString="{0}" UniqueName="TotalSMV" SortExpression="TotalSMV" HeaderText="TotalSMV" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="50px" DataField="TotalSMV">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Client" SortExpression="Client" HeaderText="Client" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="150px" DataField="Client">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Mode" SortExpression="Mode" HeaderText="Mode" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="50px" DataField="Mode">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="ShipTo" SortExpression="ShipTo" HeaderText="ShipTo" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="50px" DataField="ShipTo">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Port" SortExpression="Port" HeaderText="Port" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="50px" DataField="Port">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Country" SortExpression="Country" HeaderText="Country" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="50px" DataField="Country">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:LinkButton ID="btnSave" runat="server" CssClass="btn-link" ToolTip="Edit Gender" Text="Save" CommandName="Save"><i class="icon-pencil"></i>Save</asp:LinkButton>
                                                </li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="false">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="false" />
                    </telerik:RadGrid>
                    <!-- / -->
                </div>
                <div id="dvEmptyContent" runat="server" class="alert alert-info" visible="true">
                    <p>
                        There are no records to be shown.
                    </p>
                </div>
                <!-- / -->
            </div>
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <script type="text/javascript">
        var ddlWeek = '<%= ddlWeek.ClientID %>';

        $(document).ready(function () {
            $('#' + ddlWeek).select2();

            $('.sewingdate').datepicker({ format: 'M dd, yyyy' });
            var nowTemp = new Date();
            var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);
            $('.input-daterange').datepicker({ format: 'M dd, yyyy' });
        });
    </script>
</asp:Content>
