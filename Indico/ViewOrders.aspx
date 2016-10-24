<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewOrders.aspx.cs" Inherits="Indico.ViewOrders" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.scheduledate').datepicker({ format: 'M dd, yyyy' });
            $('.rptDate').datepicker({ format: 'M dd, yyyy' });
            var nowTemp = new Date();
            var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);
            $('.input-daterange').datepicker({ format: 'M dd, yyyy' });
        });
    </script>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddOrder" runat="server" class="btn btn-link pull-right" href="~/AddEditOrder.aspx">New Order</a>
                <a id="btnWeekOrders" runat="server" class="btn btn-link pull-right" visible="false" onserverclick="btnWeekOrders_OnClick" type="submit">Weekly Orders</a>
                <a id="btnWeeklyCapacity" runat="server" class="btn btn-link pull-right" onserverclick="btnWeeklyCapacity_Click">Weekly Summary</a>
                <asp:LinkButton ID="btnGenerateLabels" Visible="false" runat="server" CssClass="btn btn-link pull-right" OnClick="btnGenerateLabels_Click" Text="Generate Labels" />
                <asp:LinkButton ID="btnSubmitOrders" runat="server" Visible="false" CssClass="btn btn-link pull-right" OnClick="btnSubmitOrders_Click" Text="Submit Orders" />
                <asp:LinkButton ID="btnChangeDetailStatus" Visible="false" runat="server" CssClass="btn btn-link pull-right" OnClick="btnChangeStatus_Click" Text="Change Detail Status" />
                <asp:LinkButton ID="btnExportToExcel" runat="server" CssClass="btn btn-link pull-right" OnClick="btnExportToExcel_Click"><i class="icon-print"></i>Grid Export To Excel</asp:LinkButton>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h4>
                        <a href="AddEditOrder.aspx" title="Add an Orders.">Add the first order.</a>
                    </h4>
                    <p>
                        You can add as many orders as you like.
                    </p>
                </div>
                <div id="dvEmptyOrders" runat="server" class="alert alert-info">
                    <h4>
                        <asp:Literal ID="litEmptyOrders" runat="server"></asp:Literal></h4>
                </div>
                <div id="dvEmptyContentFadmin" runat="server" class="alert alert-info">
                    <h4>No orders have been added.
                    </h4>
                </div>
                <!-- / -->
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <div class="form-inline pull-right">
                            <div class="input-daterange pull-right" id="datepicker" runat="server">
                                <label>
                                    &nbsp;Order Date From</label>
                                <input type="text" class="input-small" name="start" id="txtCheckin" runat="server" />
                                <span class="add-on">to</span>
                                <input type="text" class="input-small" name="end" id="txtCheckout" runat="server" />
                                <button runat="server" class="btn btn-info" id="btnSearchingDate" onserverclick="btnSearchingDate_Click"
                                    data-loading-text="Searching..." type="submit">
                                    Search
                                </button>
                            </div>
                            <label>
                                Status</label>
                            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="input-medium" AutoPostBack="True"
                                OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                            </asp:DropDownList>
                            <label>
                                Clients</label>
                            <asp:DropDownList ID="ddlClients" runat="server" CssClass="input-large" AutoPostBack="True"
                                OnSelectedIndexChanged="ddlClients_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                        <div id="dvAdminFilters" runat="server" class="form-inline pull-right">
                            <label id="lblDistributor" runat="server">
                                Distributor</label>
                            <asp:DropDownList ID="ddlDistributor" runat="server" CssClass="input-large" AutoPostBack="True"
                                OnSelectedIndexChanged="ddlDistributor_SelectedIndexChanged">
                            </asp:DropDownList>
                            <label id="lblCoordinator" runat="server">
                                Coordinator</label>
                            <asp:DropDownList ID="ddlCoordinator" runat="server" CssClass="input-medium" AutoPostBack="True"
                                OnSelectedIndexChanged="ddlCoordinator_SelectedIndexChanged">
                            </asp:DropDownList>
                            <label runat="server" visible="false" id="lblShipmentAddress">
                                Shipment Address</label>
                            <asp:DropDownList ID="ddlShipmentAddress" runat="server" CssClass="input-medium" AutoPostBack="True" Visible="false"
                                OnSelectedIndexChanged="ddlShipmentAddress_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                        <label class="pull-right" id="labelTotal" runat="server" visible="false" style="margin-right: 20px;">
                            <strong>Total:
                                <asp:Label ID="lblTotal" runat="server"></asp:Label>
                            </strong>
                        </label>
                        <div id="dlFactoryDetails" runat="server" class="pull-right" style="margin-right: 20px;"
                            visible="false">
                            <div class="btn-group">
                                <a href="javascript:void(0);" data-toggle="dropdown" class="btn dropdown-toggle">Printing
                                    <span class="caret"></span></a>
                                <ul class="dropdown-menu pull-right">
                                    <li>
                                        <asp:LinkButton ID="btnPrint" runat="server" class="btn-link" type="submit" OnClick="btnPrint_Click">
                                        <i class="icon-eye-open"></i>View
                                        </asp:LinkButton>
                                    </li>
                                    <li>
                                        <asp:LinkButton ID="btnEditPrint" runat="server" class="btn-link" type="submit" OnClick="btnEditPrint_OnClick"
                                            Visible="false">
                                        <i class="icon-pencil"></i>Edit
                                        </asp:LinkButton>
                                    </li>
                                </ul>
                            </div>
                            <div class="btn-group">
                                <a href="javascript:void(0);" data-toggle="dropdown" class="btn dropdown-toggle">Pressing
                                    <span class="caret"></span></a>
                                <ul class="dropdown-menu pull-right">
                                    <li>
                                        <asp:LinkButton ID="btnHeatPress" runat="server" class="btn-link" type="submit" OnClick="btnHeatPress_Click">
                                        <i class="icon-eye-open"></i>View
                                        </asp:LinkButton>
                                    </li>
                                    <li>
                                        <asp:LinkButton ID="btnEditHeatPressed" runat="server" class="btn-link" type="submit"
                                            OnClick="btnEditHeatPressed_OnClick" Visible="false">
                                        <i class="icon-pencil"></i>Edit
                                        </asp:LinkButton>
                                    </li>
                                </ul>
                            </div>
                            <div class="btn-group">
                                <a href="javascript:void(0);" data-toggle="dropdown" class="btn dropdown-toggle">Sewing
                                    <span class="caret"></span></a>
                                <ul class="dropdown-menu pull-right">
                                    <li>
                                        <asp:LinkButton ID="btnSewing" runat="server" class="btn-link" type="submit" OnClick="btnSewing_Click">
                                        <i class="icon-eye-open"></i>View
                                        </asp:LinkButton>
                                    </li>
                                    <li>
                                        <asp:LinkButton ID="btnEditSewing" runat="server" class="btn-link" type="submit"
                                            OnClick="btnEditSewing_OnClick" Visible="false">
                                        <i class="icon-pencil"></i>Edit
                                        </asp:LinkButton>
                                    </li>
                                </ul>
                            </div>
                            <div class="btn-group">
                                <a href="javascript:void(0);" data-toggle="dropdown" class="btn dropdown-toggle">Packing
                                    <span class="caret"></span></a>
                                <ul class="dropdown-menu pull-right">
                                    <li>
                                        <asp:LinkButton ID="btnPacking" runat="server" class="btn-link" type="submit" OnClick="btnPacking_Click">
                                        <i class="icon-eye-open"></i>View
                                        </asp:LinkButton>
                                    </li>
                                    <li>
                                        <asp:LinkButton ID="btnEditPacked" runat="server" class="btn-link" type="submit"
                                            OnClick="btnEditPacked_OnClick" Visible="false">
                                        <i class="icon-pencil"></i>Edit
                                        </asp:LinkButton>
                                    </li>
                                </ul>
                            </div>
                            <div class="btn-group">
                                <a href="javascript:void(0);" data-toggle="dropdown" class="btn dropdown-toggle">Shipping
                                    <span class="caret"></span></a>
                                <ul class="dropdown-menu pull-right">
                                    <li>
                                        <asp:LinkButton ID="btnShipped" runat="server" CssClass="btn-link" OnClick="btnShipped_Click">
                                            <i class="icon-eye-open"></i>View
                                        </asp:LinkButton>
                                    </li>
                                    <li>
                                        <asp:LinkButton ID="btnEditShipped" runat="server" CssClass="btn-link" OnClick="btnEditShipped_OnClick"
                                            Visible="false">
                                            <i class="icon-pencil"></i>Edit
                                        </asp:LinkButton>
                                    </li>
                                </ul>
                            </div>
                        </div>
                        <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>
                    </div>
                    <!-- / -->
                    <!-- Data Table -->
                    <div class="table-responsive">
                        <telerik:RadGrid ID="RadGridOrders" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadGridOrders_PageSizeChanged"
                            PageSize="20" OnPageIndexChanged="RadGridOrders_PageIndexChanged" ShowFooter="false" OnCustomAggregate="RadGridOrders_CustomAggregate" OnGroupsChanging="RadGridOrders_GroupsChanging"
                            AutoGenerateColumns="false" OnItemDataBound="RadGridOrders_ItemDataBound" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                            Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true" EnableLinqExpressions="false"
                            OnItemCommand="RadGridOrders_ItemCommand" FooterStyle-Height="150px" FooterStyle-VerticalAlign="Top"
                            OnSortCommand="RadGridOrders_SortCommand">
                            <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                            <GroupingSettings CaseSensitive="false" />
                            <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                            <MasterTableView AllowFilteringByColumn="true" ShowFooter="true" ShowGroupFooter="true">
                                <Columns>
                                    <telerik:GridTemplateColumn AllowFiltering="false" Groupable="false" UniqueName="check">
                                        <HeaderTemplate>
                                            <asp:CheckBox ID="checkAll" runat="server" onclick="checkAllRows(this);" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:CheckBox ID="chkGenerateLabel" runat="server" />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <%--<telerik:GridNumericColumn UniqueName="Order" SortExpression="Order" HeaderText="No." DataFormatString="{0} " CurrentFilterFunction="EqualTo" Aggregate="Count" FooterText="Total Orders: "
                                    FilterControlWidth="30px" AutoPostBackOnFilter="true"
                                    DataField="Order">
                                </telerik:GridNumericColumn>--%>
                                    <telerik:GridTemplateColumn HeaderText="No." SortExpression="Order" FilterControlWidth="50px" DataField="Order" Groupable="false">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="lnkPONumber" runat="server"></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <%--           <telerik:GridTemplateColumn HeaderText="No." DataField="Order" FilterControlWidth="50px">
                                    <ItemTemplate>
                                        <asp:Literal ID="litOrderNo" runat="server"></asp:Literal>
                                        <asp:Literal ID="lblOrderNumber" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>--%>
                                    <telerik:GridTemplateColumn Aggregate="Count" FooterAggregateFormatString="{0}" HeaderText="VL/CS Name" FilterControlWidth="50px" DataField="VisualLayout" Groupable="false">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="linkVL" runat="server"></asp:HyperLink>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <%-- <telerik:GridNumericColumn UniqueName="Quantity" SortExpression="Quantity" HeaderText="Qty" DataFormatString="{0} " CurrentFilterFunction="EqualTo" FooterText="Total Qty: " Aggregate="Sum"
                                    FilterControlWidth="30px" AutoPostBackOnFilter="true"
                                    DataField="Quantity"> 
                                </telerik:GridNumericColumn>--%>
                                    <telerik:GridTemplateColumn Aggregate="Sum" FooterAggregateFormatString="{0:###,##0}" DataField="Quantity" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderText="Qty" FilterControlWidth="50px" UniqueName="OrderDetailQty">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkQuantity" runat="server" ToolTip="this is quantity wise"></asp:LinkButton>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <%--<telerik:GridNumericColumn Aggregate="Sum" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderText="Qty" FilterControlWidth="50px" UniqueName="OrderDetailQty" DataField="Quantity">--%>
                                    <telerik:GridTemplateColumn Aggregate="Sum" FooterAggregateFormatString="${0:###,##0.00}" DataField="EditedPrice" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderText="Value" AllowFiltering="false" Groupable="false" UniqueName="OrderDetailValue">
                                        <ItemTemplate>
                                            <asp:Literal ID="litOrderDetailValue" runat="server" Text=""></asp:Literal>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridBoundColumn Aggregate="Custom" FooterAggregateFormatString="{0}" UniqueName="Pattern" SortExpression="Pattern" HeaderText="Pattern" AllowSorting="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="110px" DataField="Pattern">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="OrderType" SortExpression="OrderType" HeaderText="Order Type" AllowSorting="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="75px" AutoPostBackOnFilter="true" DataField="OrderType">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridTemplateColumn SortExpression="ShipmentDate" UniqueName="SheduledDate" HeaderText="ETD" DataType="System.DateTime" AllowFiltering="true" Groupable="false" DataField="ShipmentDate" FilterControlWidth="50px">
                                        <ItemTemplate>
                                            <asp:TextBox ID="txtScheduleDate" runat="server" CssClass="input-small scheduledate"></asp:TextBox>
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

                                                        tableView.filter("SheduledDate", date, "EqualTo");
                                                    }
                                                    function FormatSelectedDate(picker) {
                                                        var date = picker.get_selectedDate();
                                                        var dateInput = picker.get_dateInput();
                                                        var formattedDate = dateInput.get_dateFormatInfo().FormatDate(date, dateInput.get_displayDateFormat());

                                                        return formattedDate;
                                                    }
                                                    function KeyPressed(sender, args) {
                                                        //alert('key');
                                                        tableView.filter("SheduledDate", "", "NoFilter");
                                                    }
                                                </script>
                                            </telerik:RadScriptBlock>
                                        </FilterTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn HeaderText="QA" AllowFiltering="false" Groupable="false" Display="false" UniqueName="PrintMeasurements">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnPrintMeasurements" runat="server" OnClick="btnPrintMeasurements_Click" ODID="" data-toggle="tooltip" data-original-title="QA Sheet"><i class="icon-excel"></i></asp:LinkButton>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn HeaderText="ODS" AllowFiltering="false" Groupable="false" Display="false" UniqueName="PrintODS">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnPrintODS" runat="server" OnClick="btnPrintODS_Click" ODSID="" ToolTip="Order Detail Sheet"><i class="icon-printpdf"></i></asp:LinkButton>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn HeaderText="N&N" AllowFiltering="false" Groupable="false" Display="true" UniqueName="N&N">
                                        <ItemTemplate>
                                            <%-- <a id="ancNameNumberFile" runat="server" title="Name & Number File" href="javascript:void(0);">
                                                <i id="iNameNumberFile" runat="server" class="icon-eye-ok"></i></a>--%>
                                            <a id="ancDownloadNameAndNumberFile"
                                                class="btn btn-link idownload" title="Download" runat="server" onserverclick="ancDownloadNameAndNumberFile_Click">
                                                <i class="icon-download-alt"></i></a>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn HeaderText="Detail Status" AllowFiltering="true" Groupable="false" FilterControlWidth="30px" UniqueName="DetailStatus">
                                        <FilterTemplate>
                                            <telerik:RadComboBox ID="radComboOrderDetailStatus" DataTextField="Name" DataValueField="ID" AppendDataBoundItems="true" Width="100px" runat="server" Skin="Metro" CssClass="RadComboBox_Metro" OnSelectedIndexChanged="radComboOrderDetailStatus_SelectedIndexChanged" AutoPostBack="true">
                                                <Items>
                                                    <telerik:RadComboBoxItem Text="All" Value="0" />
                                                </Items>
                                            </telerik:RadComboBox>
                                        </FilterTemplate>
                                        <ItemTemplate>
                                            <asp:DropDownList ID="ddlOrderDetailStatus" OnSelectedIndexChanged="ddlOrderDetailStatus_SelectedIndexChanged" Visible="false" AutoPostBack="true" runat="server" Width="100px" CssClass="input-medium">
                                            </asp:DropDownList>
                                            <asp:Literal ID="litOrderDetailStatus" runat="server" Visible="false"></asp:Literal>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn HeaderText="Image" AllowFiltering="false" Groupable="false">
                                        <ItemTemplate>
                                            <a id="ancMainImage" runat="server" target="_blank"><i id="ivlmainimageView" runat="server"
                                                class="icon-eye-open"></i></a>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridBoundColumn UniqueName="PurONo" SortExpression="PurONo" HeaderText="Pur. O. No." AllowSorting="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="50px" DataField="PurONo">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="Coordinator" SortExpression="Coordinator" HeaderText="Coordinator" AllowSorting="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="100px" DataField="Coordinator">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="Distributor" SortExpression="Distributor" HeaderText="Distributor" AllowSorting="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="100px" DataField="Distributor">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="Client" SortExpression="Client" HeaderText="Client" AllowSorting="false" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="100px" DataField="Client">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="JobName" SortExpression="JobName" HeaderText="JobName" AllowSorting="false" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="100px" DataField="JobName">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridTemplateColumn UniqueName="TCAccepted" Groupable="true" Display="true" HeaderText="T&C Accepted" DataType="System.Boolean" AllowFiltering="false" SortExpression="IsAcceptedTermsAndConditions">
                                        <ItemTemplate>
                                            <asp:CheckBox ID="chkIsAcceptedTC" runat="server" Width="10px" />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridBoundColumn UniqueName="PaymentMethod" SortExpression="PaymentMethod" HeaderText="Payment Method" AllowSorting="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="50px" DataField="PaymentMethod">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="ShipmentMethod" SortExpression="ShipmentMethod" HeaderText="Shipment Mode" AllowSorting="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="50px" DataField="ShipmentMethod">
                                    </telerik:GridBoundColumn>
                                    <%--<telerik:GridCheckBoxColumn UniqueName="WeeklyShipment" HeaderText="Is Weekly Shipment" DataField="WeeklyShipment" AllowFiltering="false" ItemStyle-CssClass="rfdCheckboxChecked" ItemStyle-HorizontalAlign="Center"
                                        AllowSorting="true">
                                    </telerik:GridCheckBoxColumn>--%>
                                    <%-- <telerik:GridCheckBoxColumn UniqueName="CourierDelivery" HeaderText="IsCourierDelivery" DataField="CourierDelivery" AllowFiltering="false" ItemStyle-CssClass="rfdCheckboxChecked" ItemStyle-HorizontalAlign="Center"
                                        AllowSorting="true">
                                    </telerik:GridCheckBoxColumn>
                                   <telerik:GridCheckBoxColumn UniqueName="AdelaideWareHouse" HeaderText="IsAdelaideWareHouse" DataField="AdelaideWareHouse" AllowFiltering="false" ItemStyle-CssClass="rfdCheckboxChecked" ItemStyle-HorizontalAlign="Center"
                                        AllowSorting="true">
                                    </telerik:GridCheckBoxColumn>
                                    <telerik:GridCheckBoxColumn UniqueName="FollowingAddress" HeaderText="IsFollowingAddress" DataField="FollowingAddress" AllowFiltering="false" ItemStyle-CssClass="rfdCheckboxChecked" ItemStyle-HorizontalAlign="Center"
                                        AllowSorting="true">
                                    </telerik:GridCheckBoxColumn>--%>
                                    <%--<telerik:GridBoundColumn UniqueName="ShippingAddress" SortExpression="ShippingAddress" HeaderText="Shipping Address" AllowSorting="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="100px" DataField="ShippingAddress">
                                    </telerik:GridBoundColumn>--%>
                                    <telerik:GridTemplateColumn UniqueName="ShippingAddress" SortExpression="ShippingAddress" HeaderText="Shipping Address" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="100px" DataField="ShippingAddress">
                                        <ItemTemplate>
                                            <asp:Label runat="server" ID="lblShippingAddress"></asp:Label>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridBoundColumn UniqueName="DestinationPort" SortExpression="DestinationPort" HeaderText="Destination Port" AllowSorting="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="100px" DataField="DestinationPort">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="Creator" SortExpression="Creator" HeaderText="Creator" AllowSorting="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="75px" DataField="Creator">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridDateTimeColumn UniqueName="CreatedDate" DataField="CreatedDate" HeaderText="Created Date" FilterControlWidth="110px" Groupable="false" SortExpression="CreatedDate" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                        DataFormatString="{0:dd MMMM yyyy}">
                                    </telerik:GridDateTimeColumn>
                                    <telerik:GridBoundColumn UniqueName="Modifier" SortExpression="Modifier" HeaderText="Modifier" AllowSorting="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains"
                                        FilterControlWidth="75px" DataField="Modifier">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridDateTimeColumn UniqueName="ModifiedDate" DataField="ModifiedDate" HeaderText="Modified Date" FilterControlWidth="75px" Groupable="false" SortExpression="ModifiedDate" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                        DataFormatString="{0:dd MMMM yyyy}">
                                    </telerik:GridDateTimeColumn>
                                    <telerik:GridTemplateColumn HeaderText="Resolution Profile" AllowFiltering="false" Groupable="false" UniqueName="ResolutionProfile">
                                        <ItemTemplate>
                                            <asp:DropDownList ID="ddlResolutionProfile" runat="server" Width="165px"></asp:DropDownList>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <%--  <telerik:GridTemplateColumn HeaderText="View" AllowFiltering="false" Groupable="false" Visible="false">
                                    <ItemTemplate>
                                        <a id="ancViewOrder" runat="server" class="btn btn-link ispec" title="View Order"
                                            onserverclick="ancViewOrder_Click"><i class="icon-th-list"></i></a>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>--%>
                                    <telerik:GridTemplateColumn HeaderText="Status" AllowFiltering="true" Groupable="false" FilterControlWidth="50px" DataField="OrderStatus" UniqueName="OrderStatus">
                                        <FilterTemplate>
                                            <telerik:RadComboBox ID="radComboOrderStatus" DataTextField="Name" DataValueField="ID" AppendDataBoundItems="true" runat="server" Skin="Metro" CssClass="RadComboBox_Metro" OnSelectedIndexChanged="radComboOrderStatus_SelectedIndexChanged" AutoPostBack="true">
                                                <Items>
                                                    <telerik:RadComboBoxItem Text="All" Value="0" />
                                                </Items>
                                            </telerik:RadComboBox>
                                        </FilterTemplate>
                                        <ItemTemplate>
                                            <asp:Literal ID="lblStatus" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                        <ItemTemplate>
                                            <div class="btn-group pull-right">
                                                <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                    <i class="icon-cog"></i><span class="caret"></span></a>
                                                <ul class="dropdown-menu pull-right">
                                                    <li>
                                                        <asp:LinkButton ID="lbDownloadDistributorPO" runat="server" OnClick="lbDownloadDistributorPO_Click" ToolTip="Print Order Overview"><i class="icon-print"></i> Print Order</asp:LinkButton>
                                                    </li>
                                                    <li>
                                                        <asp:LinkButton ID="lbDownloadDistributorPOForOffice" runat="server" OnClick="lbDownloadDistributorPOForOffice_Click" ToolTip="Print Order Overview For Office Use"><i class="icon-print"></i> Print Office Overview</asp:LinkButton>
                                                    </li>

                                                    <li>
                                                        <asp:LinkButton ID="linkButttonEditFactoryStatus" runat="server" OnClick="linkButttonEditFactoryStatus_Click" ToolTip="Edit Factory Order Detail Status" Visible="false"><i class="icon-pencil"></i> Edit Factory Order Detail Status</asp:LinkButton>
                                                    </li>
                                                    <li>
                                                        <asp:HyperLink ID="linkEditView" runat="server" ToolTip="Edit Order" Visible="false"><i class="icon-pencil"></i> Edit Order</asp:HyperLink>
                                                    </li>
                                                    <li>
                                                        <asp:LinkButton ID="lbSubmitOdsPrint" runat="server" OnClick="lbSubmitOdsPrint_Click" Visible="false" ToolTip="Submit ODS Print"><i class="icon-check"></i> Submit ODS Print</asp:LinkButton>
                                                    </li>
                                                    <li>
                                                        <asp:HyperLink ID="lbSubmitOrder" runat="server" CssClass="iSubmitOrder" Visible="false" ToolTip="Submit Order"><i class="icon-check"></i> Submit</asp:HyperLink>
                                                    </li>
                                                    <li>
                                                        <asp:HyperLink ID="linkHold" runat="server" CssClass="ilinkhold" Visible="false" ToolTip="Hold Order"><i class="icon-check"></i> Hold</asp:HyperLink>
                                                    </li>
                                                    <li>
                                                        <asp:LinkButton ID="btnSaveOrder" runat="server" OnClick="btnSaveOrder_Click" Visible="false" ToolTip="Save Order" CssClass="isheduledate"><i class="icon-edit"></i> Save Order</asp:LinkButton>
                                                    </li>
                                                    <li>
                                                        <asp:HyperLink ID="linkDelete" runat="server" CssClass="idelete" ToolTip="Delete Entire Order" Visible="false"><i class="icon-trash"></i> Delete Entire Order</asp:HyperLink>
                                                    </li>
                                                    <li>
                                                        <asp:LinkButton ID="btnGenerateBC" runat="server" OnClick="btnGenerateBC_Click" ToolTip="Generate Labels" Visible="false"><i class="icon-barcode"></i> Generate Labels</asp:LinkButton>
                                                    </li>
                                                    <li>
                                                        <asp:LinkButton ID="btnGenerateBatchLabel" runat="server" OnClick="btnGenerateBatchLabel_Click" ToolTip="Print Batch Labels" Visible="false"><i class="icon-download-alt"></i> Print Batch Labels</asp:LinkButton>
                                                    </li>
                                                    <li>
                                                        <asp:LinkButton ID="btnCHangeResolution" runat="server" OnClick="btnCHangeResolution_Click" ToolTip="Change Resolution Profile" Visible="false"><i class="icon-edit"></i> Change Resolution Profile</asp:LinkButton>
                                                    </li>
                                                    <li>
                                                        <asp:LinkButton ID="btnChangeStatus" runat="server" OnClick="btnChangeStatus_Click" ToolTip="Change Detail Status" Visible="false"><i class="icon-edit"></i> Change Detail Status</asp:LinkButton>
                                                    </li>
                                                    <li>
                                                        <asp:HyperLink ID="linkCancelledOrderDetail" runat="server" CssClass="ilinkcancelled" ToolTip="Cancel Order Detail" Visible="false"><i class="icon-check"></i> Cancel Order Detail</asp:HyperLink>
                                                    </li>
                                                    <li>
                                                        <asp:HyperLink ID="lbCreateNewFrom" runat="server"  ToolTip="Create new from this" Visible="false"><i class="icon-plus"></i> Create new from this</asp:HyperLink>
                                                    </li>
                                                </ul>
                                            </div>
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                </Columns>
                            </MasterTableView>
                            <ClientSettings AllowDragToGroup="True" AllowGroupExpandCollapse="true" AllowExpandCollapse="true">
                            </ClientSettings>
                            <GroupingSettings ShowUnGroupButton="true" />
                        </telerik:RadGrid>
                    </div>
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search -
                            <asp:Label ID="lblSearchKey" runat="server"></asp:Label>
                            - did not match any orders.</h4>
                    </div>
                    <%--<div id="dvNoSearchCriteria" runat="server" class="message search" visible="false">
                        <h4>
                            <asp:Label ID="lblNoSearchText" runat="server"></asp:Label></h4>
                        - 
                    </div>--%>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <!-- View Order Details -->
    <%-- <div id="requestOrderDetails" class="modal modal-medium hide fade" role="dialog"
        aria-hidden="true" keyboard="false" data-backdrop="static">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblPopupHeaderText" runat="server"></asp:Label></h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <fieldset class="info icolumns">
                <div class="control-group">
                    <label class="control-label">
                        Date</label>
                    <div class="controls">
                        <asp:TextBox ID="txtDate" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Your Reference</label>
                    <div class="controls">
                        <asp:TextBox ID="txtRefference" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <legend>Delivery Information </legend>
                <div class="control-group">
                    <label class="control-label">
                        Distributor</label>
                    <div class="controls">
                        <asp:TextBox ID="txtDistributor" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <%--<div class="control-group">
                    <label class="control-label">
                        Address</label>
                    <div class="controls">
                        <asp:TextBox ID="txtAddress" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        City</label>
                    <div class="controls">
                        <asp:TextBox ID="lblCity" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Post Code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtPostCode" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Country</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCountry" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>--% >
                <div class="control-group">
                    <label class="control-label">
                        Client / Job Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtClientOrJobName" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        PO NO.</label>
                    <div class="controls">
                        <asp:TextBox ID="txtPoNo" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Old PO NO.</label>
                    <div class="controls">
                        <asp:TextBox ID="txtOldPoNo" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Ship To</label>
                    <div class="controls">
                        <asp:TextBox ID="txtShipTo" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Destination</label>
                    <div class="controls">
                        <asp:TextBox ID="txtDespatchTo" runat="server" Text="" TextMode="MultiLine" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Shipement Mode</label>
                    <div class="controls">
                        <asp:TextBox ID="txtShipmentMode" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Payment Method</label>
                    <div class="controls">
                        <asp:TextBox ID="txtPaymentMethod" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Status</label>
                    <div class="controls">
                        <asp:TextBox ID="txtStatus" runat="server" Text="" Enabled="false"></asp:TextBox>
                    </div>
                </div>
            </fieldset>
            <fieldset>
                <legend>Products Ordered</legend>
                <!-- Data Table -->
                <asp:DataGrid ID="dgOrderItems" runat="server" CssClass="table" AllowCustomPaging="False"
                    AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                    OnItemDataBound="dgOrderItems_ItemDataBound">
                    <HeaderStyle CssClass="header" />
                    <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                    <Columns>
                        <asp:TemplateColumn HeaderText="Order Type">
                            <ItemTemplate>
                                <asp:Literal ID="lblOrderType" runat="server" Text=""></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="VL / Pattern / Fabric">
                            <ItemTemplate>
                                <asp:Literal ID="lblVLNumber" runat="server" Text=""></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="VL Image">
                            <ItemTemplate>
                                <a id="ancVLImage" runat="server"><i id="ivlimageView" runat="server" class="icon-eye-open"></i></a>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Quantities">
                            <ItemTemplate>
                                <ol class="ioderlist-table">
                                    <asp:Repeater ID="rptSizeQtyView" runat="server" OnItemDataBound="rptSizeQtyView_ItemDataBound">
                                        <ItemTemplate>
                                            <li class="idata-column">
                                                <ul>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litHeading" runat="server"></asp:Literal>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:Label ID="lblQty" runat="server" Text=""></asp:Label>
                                                    </li>
                                                </ul>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ol>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Total">
                            <ItemTemplate>
                                <asp:Literal ID="lblTotoal" runat="server"></asp:Literal></li>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Notes">
                            <ItemTemplate>
                                <asp:Literal ID="lblVlNotes" runat="server" Text=""></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Label">
                            <ItemTemplate>
                                <a id="ancLabelImagePreview" runat="server"><i id="ilabelimageView" runat="server"
                                    class="icon-eye-open"></i></a>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="File">
                            <ItemTemplate>
                                <a id="ancNameNumberFile" runat="server" title="Name & Number File" href="javascript:void(0);">
                                    <i id="iNameNumberFile" runat="server" class="icon-eye-ok"></i></a>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                    </Columns>
                </asp:DataGrid>
                <!-- / -->
                <!-- No Orders -->
                <div id="dvNoOrders" runat="server" class="alert alert-info">
                    <h4>No orders have been added.</h4>
                    <p>
                        Once you add an order, you'll see the details below.
                    </p>
                </div>
                <!-- / -->
            </fieldset>
        </div>
        <!-- / -->
    </div>--%>
    <!-- / -->
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Order</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure to delete this order?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" text="" onserverclick="btnDelete_Click"
                data-loading-text="Deleting..." type="submit">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Submit Order -->
    <div id="dvSubmitOrder" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Submit Order</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure to submit this order?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnSubmitOrder" runat="server" class="btn btn-primary" onserverclick="btnSubmitOrder_Click"
                data-loading-text="Submitting..." type="submit">
                Yes</button>
        </div>
    </div>
    <div id="dvHoldOrder" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Hold Order</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure to hold this order?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnHold" runat="server" class="btn btn-primary" onserverclick="btnHold_Click"
                data-loading-text="Saving..." type="submit">
                Yes</button>
        </div>
    </div>
    <div id="dvCancelledOrder" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Cancel Order Detail</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure to cancel this order detail?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnCancelled" runat="server" class="btn btn-primary" onserverclick="btnCancelled_ServerClick"
                data-loading-text="Saving..." type="submit">
                Yes</button>
        </div>
    </div>
    <asp:HiddenField ID="hdnIndimanOrderID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnOrderStatus" runat="server" Value="0" />
    <asp:HiddenField ID="hdnSheduleDate" runat="server" Value="0" />
    <asp:HiddenField ID="hdnCancelledOrderDetail" runat="server" Value="0" />
    <asp:HiddenField ID="hdnOrderDetailID" runat="server" Value="0" />
    <!-- / -->
    <!-- Factory Order Detail status -->
    <asp:HiddenField ID="hdnOrderID" runat="server" Value="0" />
    <div id="requestFactoryOrderDetailStatus" class="modal modal-medium hide fade" role="dialog"
        aria-hidden="true" keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Factory Order Details</h3>
        </div>
        <div class="modal-body">
            <asp:DataGrid ID="dgFactoryOrderDetailStatus" runat="server" CssClass="table ifont-small"
                AllowCustomPaging="False" AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false"
                GridLines="None" PageSize="10" OnItemDataBound="dgFactoryOrderDetailStatus_ItemDataBound">
                <HeaderStyle CssClass="header" />
                <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                <Columns>
                    <asp:TemplateColumn HeaderText="Order Detail" ItemStyle-Width="8%">
                        <ItemTemplate>
                            <asp:Label ID="lblOrderDetail" runat="server" Text=""></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="ODS Printed" ItemStyle-Width="4%">
                        <ItemTemplate>
                            <asp:CheckBox ID="chkOdsPrinted" runat="server" Enabled="false" Checked="false" />
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="" ItemStyle-Width="84%">
                        <ItemTemplate>
                            <div class="iwizard-row">
                                <label class="checkbox">
                                    Printed<asp:CheckBox ID="chkPrinting" runat="server" Enabled="false" Checked="false" />
                                </label>
                                <ol class="ioderlist-table">
                                    <li class="idata-column">
                                        <ul>
                                            <li class="icell-header">
                                                <asp:Literal ID="litPrintSizeHeading" runat="server">Size</asp:Literal>
                                            </li>
                                            <li class="icell-header">
                                                <asp:Literal ID="litPrintDateHeading" runat="server">Date</asp:Literal>
                                            </li>
                                            <li class="icell-header">
                                                <asp:Literal ID="litPrintQuantity" runat="server">Amount</asp:Literal>
                                            </li>
                                            <li class="icell-header ">
                                                <asp:Literal ID="litPrintTotalCount" runat="server">Total Qty</asp:Literal>
                                            </li>
                                        </ul>
                                    </li>
                                    <asp:Repeater ID="rptPrinted" runat="server" OnItemDataBound="rptPrinted_ItemDataBound">
                                        <ItemTemplate>
                                            <li class="idata-column">
                                                <ul>
                                                    <li class="icell-data">
                                                        <asp:Label ID="lblPrintSize" runat="server" Text=""></asp:Label>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:TextBox ID="txtPrintStartedDate" CssClass="rptDate" runat="server"></asp:TextBox>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:TextBox ID="txtPrintQty" runat="server" CssClass="iqty"></asp:TextBox>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:Label ID="lblPrintTotalQty" runat="server"></asp:Label>
                                                    </li>
                                                </ul>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ol>
                            </div>
                            <div class="iwizard-row">
                                <label class="checkbox">
                                    Heat Pressed
                                    <asp:CheckBox ID="chkHeatPress" runat="server" Enabled="false" Checked="false" />
                                </label>
                                <ol class="ioderlist-table">
                                    <li class="idata-column">
                                        <ul>
                                            <li class="icell-header">
                                                <asp:Literal ID="litPressedSizeHeading" runat="server">Size</asp:Literal>
                                            </li>
                                            <li class="icell-header">
                                                <asp:Literal ID="litPressedHeading" runat="server">Date</asp:Literal>
                                            </li>
                                            <li class="icell-header">
                                                <asp:Literal ID="litPressedQuantity" runat="server">Amount</asp:Literal>
                                            </li>
                                            <li class="icell-header tqty">
                                                <asp:Literal ID="liPressTotalQty" runat="server">Total Qty</asp:Literal>
                                            </li>
                                        </ul>
                                    </li>
                                    <asp:Repeater ID="rptPressed" runat="server" OnItemDataBound="rptPressed_ItemDataBound">
                                        <ItemTemplate>
                                            <li class="idata-column">
                                                <ul>
                                                    <li class="icell-data">
                                                        <asp:Label ID="lblPressedSize" runat="server" Text=""></asp:Label>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:TextBox ID="txtPressedStartedDate" CssClass="rptDate" runat="server"></asp:TextBox>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:TextBox ID="txtPressedQty" runat="server" CssClass="iqty"></asp:TextBox>
                                                    </li>
                                                    <li class="icell-data tqty">
                                                        <asp:Label ID="lblPressedTotalQty" runat="server"></asp:Label>
                                                    </li>
                                                </ul>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ol>
                            </div>
                            <div class="iwizard-row">
                                <label class="checkbox">
                                    Sewing
                                    <asp:CheckBox ID="chkSewing" runat="server" Enabled="false" Checked="false" />
                                </label>
                                <ol class="ioderlist-table">
                                    <li class="idata-column">
                                        <ul>
                                            <li class="icell-header">
                                                <asp:Literal ID="litSewingSizeHeading" runat="server">Size</asp:Literal>
                                            </li>
                                            <li class="icell-header">
                                                <asp:Literal ID="litSewingHeading" runat="server">Date</asp:Literal>
                                            </li>
                                            <li class="icell-header">
                                                <asp:Literal ID="litSewingQuantity" runat="server">Amount</asp:Literal>
                                            </li>
                                            <li class="icell-header">
                                                <asp:Literal ID="litSewingTotalQty" runat="server">Total Qty</asp:Literal>
                                            </li>
                                        </ul>
                                    </li>
                                    <asp:Repeater ID="rptSewing" runat="server" OnItemDataBound="rptSewing_ItemDataBound">
                                        <ItemTemplate>
                                            <li class="idata-column">
                                                <ul>
                                                    <li class="icell-data">
                                                        <asp:Label ID="lblSewingSize" runat="server" Text=""></asp:Label>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:TextBox ID="txtSewingStartedDate" CssClass="rptDate" runat="server"></asp:TextBox>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:TextBox ID="txtSewingQty" runat="server" CssClass="iqty"></asp:TextBox>
                                                    </li>
                                                    <li class="icell-data tqty">
                                                        <asp:Label ID="lblSewingTotalQty" runat="server"></asp:Label>
                                                    </li>
                                                </ul>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ol>
                            </div>
                            <div class="iwizard-row">
                                <label class="checkbox">
                                    Packed
                                    <asp:CheckBox ID="chkFactoryPacking" runat="server" Enabled="false" Checked="false" />
                                </label>
                                <ol class="ioderlist-table">
                                    <li class="idata-column">
                                        <ul>
                                            <li class="icell-header">
                                                <asp:Literal ID="litPackedSizeHeading" runat="server">Size</asp:Literal>
                                            </li>
                                            <li class="icell-header">
                                                <asp:Literal ID="litPackedHeading" runat="server">Date</asp:Literal>
                                            </li>
                                            <li class="icell-header">
                                                <asp:Literal ID="litPackedQuantity" runat="server">Amount</asp:Literal>
                                            </li>
                                            <li class="icell-header">
                                                <asp:Literal ID="litPackingTotalQty" runat="server">Total Qty</asp:Literal>
                                            </li>
                                        </ul>
                                    </li>
                                    <asp:Repeater ID="rptPacked" runat="server" OnItemDataBound="rptPacked_ItemDataBound">
                                        <ItemTemplate>
                                            <li class="idata-column">
                                                <ul>
                                                    <li class="icell-data">
                                                        <asp:Label ID="lblPackedSize" runat="server" Text=""></asp:Label>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:TextBox ID="txtPackedStartedDate" CssClass="rptDate" runat="server"></asp:TextBox>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:TextBox ID="txtPackedQty" runat="server" CssClass="iqty"></asp:TextBox>
                                                    </li>
                                                    <li class="icell-data tqty">
                                                        <asp:Label ID="lblPackingTotal" runat="server"></asp:Label>
                                                    </li>
                                                </ul>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ol>
                            </div>
                            <div class="iwizard-row">
                                <label class="checkbox">
                                    Shipped
                                    <asp:CheckBox ID="chkFactoryShipped" runat="server" Enabled="false" Checked="false" />
                                </label>
                                <ol class="ioderlist-table">
                                    <li class="idata-column">
                                        <ul>
                                            <li class="icell-header">
                                                <asp:Literal ID="litShippedSizeHeading" runat="server">Size</asp:Literal>
                                            </li>
                                            <li class="icell-header">
                                                <asp:Literal ID="litShippedHeading" runat="server">Date</asp:Literal>
                                            </li>
                                            <li class="icell-header">
                                                <asp:Literal ID="litShippedQuantity" runat="server">Amount</asp:Literal>
                                            </li>
                                            <li class="icell-header">
                                                <asp:Literal ID="litShippedTotalQty" runat="server">Total Qty</asp:Literal>
                                            </li>
                                        </ul>
                                    </li>
                                    <asp:Repeater ID="rptShipped" runat="server" OnItemDataBound="rptShipped_ItemDataBound">
                                        <ItemTemplate>
                                            <li class="idata-column">
                                                <ul>
                                                    <li class="icell-data">
                                                        <asp:Label ID="lblShippedSize" runat="server" Text=""></asp:Label>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:TextBox ID="txtShippedStartedDate" CssClass="rptDate" runat="server"></asp:TextBox>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:TextBox ID="txtShippedQty" runat="server" CssClass="iqty"></asp:TextBox>
                                                    </li>
                                                    <li class="icell-data tqty">
                                                        <asp:Label ID="lblShippedTotal" runat="server"></asp:Label>
                                                    </li>
                                                </ul>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ol>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Completed" ItemStyle-Width="4%">
                        <ItemTemplate>
                            <asp:Label ID="lblCompleted" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                </Columns>
            </asp:DataGrid>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnFactoryHold" runat="server" class="btn btn-warning" onserverclick="btnFactoryHold_OnClick"
                data-loading-text="Saving..." type="submit">
                Factory Hold</button>
            <button runat="server" class="btn btn-primary" id="btnSubmit" onserverclick="btnSubmit_Click"
                data-loading-text="Saving..." type="submit">
                Submit</button>
        </div>
    </div>
    <!-- / -->
    <!-- Weekly Orders -->
    <div id="dvWeeklyOrders" class="modal modal-medium hide fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Weekly Order Details
            </h3>
        </div>
        <div class="modal-body">
            <asp:Repeater ID="rptWeeklyOrders" runat="server" OnItemDataBound="rptWeeklyOrders_ItemDataBound">
                <ItemTemplate>
                    <h3 id="h3WeeklyOrders" runat="server" visible="false"></h3>
                    <label id="lbldistributorClient" runat="server" class="pull-right">
                    </label>
                    <asp:DataGrid ID="dgWeeklyOrderDetails" runat="server" CssClass="table table-striped ifont-small"
                        AllowCustomPaging="False" AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false"
                        GridLines="None" PageSize="10" OnItemDataBound="dgWeeklyOrderDetails_ItemDataBound">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:TemplateColumn HeaderText="Order Detail" ItemStyle-Width="8%">
                                <ItemTemplate>
                                    <asp:Label ID="lblWeeklyOrderDetail" runat="server" Text=""></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="ODS Printed" ItemStyle-Width="4%">
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkWeeklyOdsPrinted" runat="server" Enabled="false" Checked="false" />
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="" ItemStyle-Width="84%">
                                <ItemTemplate>
                                    <div class="iwizard-row">
                                        <label class="checkbox">
                                            Printed<asp:CheckBox ID="chkWeeklyPrinting" runat="server" Enabled="false" Checked="false" />
                                        </label>
                                        <ol class="ioderlist-table">
                                            <li class="idata-column">
                                                <ul>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyPrintSizeHeading" runat="server">Size</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyPrintDateHeading" runat="server">Date</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyPrintQuantity" runat="server">Amount</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyPrintTotal" runat="server">Total Qty</asp:Literal>
                                                    </li>
                                                </ul>
                                            </li>
                                            <asp:Repeater ID="rptWeeklyPrinted" runat="server" OnItemDataBound="rptWeeklyPrinted_ItemDataBound">
                                                <ItemTemplate>
                                                    <li class="idata-column">
                                                        <ul>
                                                            <li class="icell-data">
                                                                <asp:Label ID="lblWeeklyPrintSize" runat="server" Text=""></asp:Label>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:TextBox ID="txtWeeklyPrintStartedDate" CssClass="rptDate" runat="server"></asp:TextBox>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:TextBox ID="txtWeeklyPrintQty" runat="server" CssClass="iqty"></asp:TextBox>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:Label ID="lblWeeklyPrintTotal" runat="server"></asp:Label>
                                                            </li>
                                                        </ul>
                                                    </li>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </ol>
                                    </div>
                                    <div class="iwizard-row">
                                        <label class="checkbox">
                                            Pressed<asp:CheckBox ID="chkWeeklyHeatPress" runat="server" Enabled="false" Checked="false" />
                                        </label>
                                        <ol class="ioderlist-table">
                                            <li class="idata-column">
                                                <ul>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyPressedSizeHeading" runat="server">Size</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyPressedHeading" runat="server">Date</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyPressedQuantity" runat="server">Amount</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyPressTotal" runat="server">Total Qty</asp:Literal>
                                                    </li>
                                                </ul>
                                            </li>
                                            <asp:Repeater ID="rptWeeklyPressed" runat="server" OnItemDataBound="rptWeeklyPressed_ItemDataBound">
                                                <ItemTemplate>
                                                    <li class="idata-column">
                                                        <ul>
                                                            <li class="icell-data">
                                                                <asp:Label ID="lblWeeklyPressedSize" runat="server" Text=""></asp:Label>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:TextBox ID="txtWeeklyPressedStartedDate" CssClass="rptDate" runat="server"></asp:TextBox>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:TextBox ID="txtWeeklyPressedQty" runat="server" CssClass="iqty"></asp:TextBox>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:Label ID="lblWeeklyPressTotal" runat="server"></asp:Label>
                                                            </li>
                                                        </ul>
                                                    </li>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </ol>
                                    </div>
                                    <div class="iwizard-row">
                                        <label class="checkbox">
                                            Sewing<asp:CheckBox ID="chkWeeklySewing" runat="server" Enabled="false" Checked="false" />
                                        </label>
                                        <ol class="ioderlist-table">
                                            <li class="idata-column">
                                                <ul>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklySewingSizeHeading" runat="server">Size</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklySewingHeading" runat="server">Date</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklySewingQuantity" runat="server">Amount</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklySewingTotal" runat="server">Total Qty</asp:Literal>
                                                    </li>
                                                </ul>
                                            </li>
                                            <asp:Repeater ID="rptWeeklySewing" runat="server" OnItemDataBound="rptWeeklySewing_ItemDataBound">
                                                <ItemTemplate>
                                                    <li class="idata-column">
                                                        <ul>
                                                            <li class="icell-data">
                                                                <asp:Label ID="lblWeeklySewingSize" runat="server" Text=""></asp:Label>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:TextBox ID="txtWeeklySewingStartedDate" CssClass="rptDate" runat="server"></asp:TextBox>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:TextBox ID="txtWeeklySewingQty" runat="server" CssClass="iqty"></asp:TextBox>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:Label ID="lblWeeklySewingTotal" runat="server"></asp:Label>
                                                            </li>
                                                        </ul>
                                                    </li>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </ol>
                                    </div>
                                    <div class="iwizard-row">
                                        <label class="checkbox">
                                            Packed<asp:CheckBox ID="chkWeeklyFactoryPacking" runat="server" Enabled="false" Checked="false" />
                                        </label>
                                        <ol class="ioderlist-table">
                                            <li class="idata-column">
                                                <ul>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyPackedSizeHeading" runat="server">Size</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyPackedHeading" runat="server">Date</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyPackedQuantity" runat="server">Amount</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyPackedTotal" runat="server">Total Qty</asp:Literal>
                                                    </li>
                                                </ul>
                                            </li>
                                            <asp:Repeater ID="rptWeeklyPacked" runat="server" OnItemDataBound="rptWeeklyPacked_ItemDataBound">
                                                <ItemTemplate>
                                                    <li class="idata-column">
                                                        <ul>
                                                            <li class="icell-data">
                                                                <asp:Label ID="lblWeeklyPackedSize" runat="server" Text=""></asp:Label>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:TextBox ID="txtWeeklyPackedStartedDate" CssClass="rptDate" runat="server"></asp:TextBox>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:TextBox ID="txtWeeklyPackedQty" runat="server" CssClass="iqty"></asp:TextBox>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:Label ID="lblWeeklyPackedTotal" runat="server"></asp:Label>
                                                            </li>
                                                        </ul>
                                                    </li>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </ol>
                                    </div>
                                    <div class="iwizard-row">
                                        <label class="checkbox">
                                            Shipped
                                            <asp:CheckBox ID="chkWeeklyFactoryShipped" runat="server" Enabled="false" Checked="false" />
                                        </label>
                                        <ol class="ioderlist-table">
                                            <li class="idata-column">
                                                <ul>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyShippedSizeHeading" runat="server">Size</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyShippedHeading" runat="server">Date</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyShippedQuantity" runat="server">Amount</asp:Literal>
                                                    </li>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litWeeklyShippedTotal" runat="server">Total Qty</asp:Literal>
                                                    </li>
                                                </ul>
                                            </li>
                                            <asp:Repeater ID="rptWeeklyShipped" runat="server" OnItemDataBound="rptWeeklyShipped_ItemDataBound">
                                                <ItemTemplate>
                                                    <li class="idata-column">
                                                        <ul>
                                                            <li class="icell-data">
                                                                <asp:Label ID="lblWeeklyShippedSize" runat="server" Text=""></asp:Label>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:TextBox ID="txtWeeklyShippedStartedDate" CssClass="rptDate" runat="server"></asp:TextBox>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:TextBox ID="txtWeeklyShippedQty" runat="server" CssClass="iqty"></asp:TextBox>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:Label ID="lblWeeklyShippedTotal" runat="server"></asp:Label>
                                                            </li>
                                                        </ul>
                                                    </li>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </ol>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Completed" ItemStyle-Width="4%">
                                <ItemTemplate>
                                    <asp:Label ID="lblWeeklyCompleted" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>
                </ItemTemplate>
            </asp:Repeater>
            <!-- No Orders -->
            <div id="dvWeeklyFactoryEmptyContent" runat="server" class="alert alert-info">
                <h4>No orders have been added for this week.</h4>
            </div>
            <!-- / -->
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button runat="server" class="btn btn-primary" id="btnSubmitWeeklyOrders" onserverclick="btnWeeklyOrdersSubmit_Click"
                data-loading-text="Saving..." type="submit">
                Submit</button>
        </div>
    </div>
    <!-- / -->
    <!-- Department Details -->
    <div id="dvDepartmentDetails" class="modal modal-medium hide fade" role="dialog"
        aria-hidden="true" keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblDepartmentName" runat="server"></asp:Label></h3>
        </div>
        <div class="modal-body">
            <legend>ENTER THE DAYS PRODUCTION ACTIVITY </legend>
            <fieldset>
                <div class="control-group">
                    <div class="controls">
                        <asp:Label ID="lblDepartmentDate" runat="server"></asp:Label>
                    </div>
                </div>
            </fieldset>
            <fieldset>
                <!-- Data Table -->
                <asp:DataGrid ID="dgDepatrmentOrderDetail" runat="server" CssClass="table" AllowCustomPaging="False"
                    AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                    OnItemDataBound="dgDepatrmentOrderDetail_ItemDataBound">
                    <HeaderStyle CssClass="header" />
                    <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                    <Columns>
                        <asp:TemplateColumn HeaderText="Order">
                            <ItemTemplate>
                                <asp:Label ID="lblDepartmentOrderNumber" runat="server" Text=""></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="VL / Pattern / Fabric">
                            <ItemTemplate>
                                <asp:Label ID="lblDepartmentVLNumber" runat="server" Text=""></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Size">
                            <ItemTemplate>
                                <asp:Label ID="lblDeptSize" runat="server" Text=""></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="">
                            <ItemTemplate>
                                <asp:Label ID="lblDeptQty" runat="server"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Order Qty">
                            <ItemTemplate>
                                <asp:Label ID="lblTotalQty" runat="server"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Balance">
                            <ItemTemplate>
                                <asp:Label ID="lblDeptBalance" runat="server"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                    </Columns>
                </asp:DataGrid>
                <!-- / -->
                <!-- No Orders -->
                <div id="dvDeptEmptyContent" runat="server" class="alert alert-info">
                    <h4>No orders have been added.</h4>
                </div>
                <!-- / -->
            </fieldset>
        </div>
    </div>
    <!-- / -->
    <!--Edit Department Details -->
    <div id="dvEditDepartmentDetails" class="modal modal-medium hide fade" role="dialog"
        aria-hidden="true" keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblEditDepartmentHeaderText" runat="server"></asp:Label></h3>
        </div>
        <div class="modal-body">
            <fieldset>
                <!-- Data Table -->
                <asp:DataGrid ID="dgEditDepartmentDetails" runat="server" CssClass="table ifont-small"
                    AllowCustomPaging="False" AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false"
                    GridLines="None" PageSize="10" OnItemDataBound="dgEditDepartmentDetails_ItemDataBound">
                    <HeaderStyle CssClass="header" />
                    <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                    <Columns>
                        <asp:TemplateColumn HeaderText="Order Detail">
                            <ItemTemplate>
                                <asp:Label ID="lblDeptEditOrderDetail" runat="server" Text=""></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="">
                            <ItemTemplate>
                                <div class="iwizard-row">
                                    <ol class="ioderlist-table">
                                        <li class="idata-column">
                                            <ul>
                                                <li class="icell-header">
                                                    <asp:Literal ID="litEditDeptSizeHeading" runat="server">Size</asp:Literal>
                                                </li>
                                                <li class="icell-header">
                                                    <asp:Literal ID="litEditDeptDateHeading" runat="server">Date</asp:Literal>
                                                </li>
                                                <li class="icell-header">
                                                    <asp:Literal ID="litEditDeptQuantity" runat="server">Amount</asp:Literal>
                                                </li>
                                                <li class="icell-header">
                                                    <asp:Literal ID="litEditDeptTotal" runat="server">Total Qty</asp:Literal>
                                                </li>
                                            </ul>
                                        </li>
                                        <asp:Repeater ID="rptEditDepartmentDetails" runat="server" OnItemDataBound="rptEditDepartmentDetails_ItemDataBound">
                                            <ItemTemplate>
                                                <li class="idata-column">
                                                    <ul>
                                                        <li class="icell-data">
                                                            <asp:Label ID="lblEditDeptSize" runat="server" Text=""></asp:Label>
                                                        </li>
                                                        <li class="icell-data">
                                                            <asp:TextBox ID="txtEditDeptStartedDate" CssClass="rptDate" runat="server"></asp:TextBox>
                                                        </li>
                                                        <li class="icell-data">
                                                            <asp:TextBox ID="txtEditDeptQty" runat="server" CssClass="iqty"></asp:TextBox>
                                                        </li>
                                                        <li class="icell-data">
                                                            <asp:Label ID="lblEditDeptTotal" runat="server"></asp:Label>
                                                        </li>
                                                    </ul>
                                                </li>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </ol>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                    </Columns>
                </asp:DataGrid>
                <!-- / -->
                <!-- No Orders -->
                <div id="dvEditDepartmentEmptyContent" runat="server" class="alert alert-info">
                    <h4>No orders have been added.</h4>
                </div>
                <!-- / -->
            </fieldset>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button runat="server" class="btn btn-primary" id="btnEditDeptSubmit" onserverclick="btnEditDeptSubmit_Click"
                data-loading-text="Saving..." type="submit">
                Submit
            </button>
        </div>
    </div>
    <!-- / -->
    <div id="dvWeeklyCapacities" class="modal modal-medium hide fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblWeeklyCapacitiesHeader" runat="server" Text="Weekly Summary"></asp:Label></h3>
        </div>
        <div class="modal-body">
            <div class="search-control clearfix">
                <div class="form-inline pull-right">
                    <label>
                        Filter by From</label>
                    <asp:DropDownList ID="ddlMonth" runat="server" AutoPostBack="True" CssClass="input-small"
                        OnSelectedIndexChanged="ddlMonth_SelectedIndexChanged">
                    </asp:DropDownList>
                    <asp:DropDownList ID="ddlYear" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlYear_SelectedIndexChanged"
                        CssClass="input-small">
                    </asp:DropDownList>
                </div>
            </div>
            <asp:DataGrid ID="dgWeeklySummary" runat="server" CssClass="table" AutoGenerateColumns="false"
                AllowSorting="true" GridLines="None" AllowPaging="True" PageSize="20" AllowCustomPaging="False"
                OnItemDataBound="dgWeeklySummary_ItemDataBound" OnPageIndexChanged="dgWeeklySummary_PageIndexChanged">
                <HeaderStyle CssClass="header" />
                <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                <Columns>
                    <asp:TemplateColumn HeaderText="Week #/ Year">
                        <ItemTemplate>
                            <asp:Label ID="lblWeekYear" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Weekend Date">
                        <ItemTemplate>
                            <asp:Label ID="lblWeekEnd" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Firm">
                        <ItemTemplate>
                            <asp:Label ID="lblkFirm" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Reservation">
                        <ItemTemplate>
                            <asp:Label ID="lblReservations" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Total">
                        <ItemTemplate>
                            <asp:Label ID="lblTotal" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="On Hold">
                        <ItemTemplate>
                            <asp:Label ID="lblHold" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Capacities">
                        <ItemTemplate>
                            <asp:Label ID="lblCapacities" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Balance">
                        <ItemTemplate>
                            <asp:Label ID="lblBalance" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="<=5 Items">
                        <ItemTemplate>
                            <asp:Label ID="lbllessfiveitems" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Jackets">
                        <ItemTemplate>
                            <asp:Label ID="lblJackets" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Samples">
                        <ItemTemplate>
                            <asp:Label ID="lblSamples" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Holidays">
                        <ItemTemplate>
                            <asp:Label ID="lblHoliday" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                </Columns>
            </asp:DataGrid>
            <div id="dvEmptyWeeklyCapacities" runat="server" class="alert alert-info">
                <h4>Weekly Capacities.
                </h4>
                <p>
                    There are no data for Weekly capacities
                </p>
            </div>
        </div>
    </div>

    <!-- Page Scripts -->
    <script type="text/javascript">
        var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
        var PopulateWeeklyCapacities = ('<%=ViewState["PopulateWeeklyCapacities"]%>' == 'True') ? true : false;
        var PopulateOrderDetails = ('<%=ViewState["PopulateOrderDetails"]%>' == 'True') ? true : false;
        var PopulateOrderDetailsStatus = ('<%=ViewState["PopulateOrderDetailsStatus"]%>' == 'True') ? true : false;
        var PopulateWeeklyOrderDetails = ('<%=ViewState["PopulateWeeklyOrderDetails"]%>' == 'True') ? true : false;
        var PopulateDepartmentDetails = ('<%=ViewState["PopulateDepartmentDetails"]%>' == 'True') ? true : false;
        var PopulateEditDepartmentDetails = ('<%=ViewState["PopulateEditDepartmentDetails"]%>' == 'True') ? true : false;
        var PopulateIndimanSubmit = ('<%=ViewState["PopulateIndimanSubmit"]%>' == 'True') ? true : false;
        var hdnIndimanOrderID = "<%=hdnIndimanOrderID.ClientID %>";
        var hdnOrderStatus = "<%=hdnOrderStatus.ClientID %>";
        var btnSubmit = "<%=btnSubmit.ClientID %>";
        var btnEditDeptSubmit = "<%=btnEditDeptSubmit.ClientID %>";
        var btnSubmitWeeklyOrders = "<%=btnSubmitWeeklyOrders.ClientID %>";
        var hdnSheduleDate = "<%=hdnSheduleDate.ClientID %>";
        var hdnCancelledOrderDetail = "<%=hdnCancelledOrderDetail.ClientID %>";
        var gridToCheckAll = '<%= RadGridOrders.ClientID %>';
        var ddlClients = '<%= ddlClients.ClientID %>';
        var ddlStatus = '<%= ddlStatus.ClientID %>';
        var ddlDistributor = '<%= ddlDistributor.ClientID %>';
        var ddlCoordinator = '<%= ddlCoordinator.ClientID %>';          
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });

            $('.isheduledate').click(function () {
                $('#' + hdnSheduleDate).val($('.scheduledate').val());
            });

            $('#' + ddlClients).select2();
            $('#' + ddlStatus).select2();
            $('#' + ddlDistributor).select2();
            $('#' + ddlCoordinator).select2();

            if (PopulateOrderDetails) {
                window.setTimeout(function () {
                    populateOrder();
                }, 10);
            }

            function populateOrder() {
                /*  $('div.error, span.error').hide();*/
                $('#requestOrderDetails div.modal-header h3 span')[0].innerHTML = 'Order Details';
                $('#requestOrderDetails').modal('show');
            }

            if (PopulateOrderDetailsStatus) {
                $('#requestFactoryOrderDetailStatus').modal('show');
            }

            if (PopulateWeeklyOrderDetails) {
                $('#dvWeeklyOrders').modal('show');
            }

            if (PopulateDepartmentDetails) {
                $('#dvDepartmentDetails').modal('show');
            }

            if (PopulateEditDepartmentDetails) {
                $('#dvEditDepartmentDetails').modal('show');
            }

            if (PopulateWeeklyCapacities) {
                $('#dvWeeklyCapacities').modal('show');
            }

            $('.iqty').keyup(function () {
                var textBoxValue = $(this).val();
                var amount = $(this).parent('li.icell-data').next('li.icell-data').children().attr('amount');
                var total = (parseInt(textBoxValue) + parseInt(amount));
                var tqty = $(this).parent('li.icell-data').next('li.icell-data').children().attr('tqty');
                if (total > tqty) {
                    $(this).css('border-color', '#ff0000');
                    $('#' + btnSubmit).hide();
                    $('#' + btnEditDeptSubmit).hide();
                    $('#' + btnSubmitWeeklyOrders).hide();
                }
                else {
                    $(this).css('border-color', '#fffafa')
                    $('#' + btnSubmit).show();
                    $('#' + btnEditDeptSubmit).show();
                    $('#' + btnSubmitWeeklyOrders).show();
                }
            });

            $('.iSubmitOrder').click(function () {
                $('#' + hdnIndimanOrderID).val($(this).attr('order'));
                $('#' + hdnOrderStatus).val($(this).attr('status'));
                $('#dvSubmitOrder').modal('show');
            });

            $('.ilinkcancelled').click(function () {
                $('#' + hdnCancelledOrderDetail).val($(this).attr('oddid'));
                $('#dvCancelledOrder').modal('show');
            });

            $('.ilinkhold').click(function () {
                $('#' + hdnIndimanOrderID).val($(this).attr('order'));
                $('#' + hdnOrderStatus).val($(this).attr('status'));
                $('#dvHoldOrder').modal('show');
            });
        });
        function checkAllRows(sender) {
            var checked = sender.checked;
            var container = document.getElementById(gridToCheckAll);
            //var checkboxes = container.getElementsByTagName('input');
            var checkboxes = container.getElementsByClassName('iCheck');
            for (var i = 0, l = checkboxes.length; i < l; i++) {
                if (checkboxes[i] != sender && !checkboxes[i].disabled && checkboxes[i].firstChild != null)
                    checkboxes[i].firstChild.checked = checked;
            }
        }
    </script>
    <!-- / -->
</asp:Content>
