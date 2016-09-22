<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewClientOrders.aspx.cs" Inherits="Indico.ViewClientOrders" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h1>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h1>
            <asp:Button ID="btnAddOrder" runat="server" CssClass="btn btn-primary pull-right" Text="New Order"
                PostBackUrl="~/AddEditClientOrder.aspx" />
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="inner">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h2>
                        <a href="AddEditClientOrder.aspx" title="Add an item.">Add the first order.</a>
                    </h2>
                    <p>
                        You can add as many orders as you like.
                    </p>
                </div>
                <!-- / -->
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>
                        <dl class="sortBy">
                            <dt>
                                <label>
                                    Filter by Status</label></dt>
                            <dd>
                                <asp:DropDownList ID="ddlSortBy" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlSortBy_SelectedIndexChanged">
                                </asp:DropDownList>
                            </dd>
                        </dl>
                    </div>
                    <!-- / -->
                    <!-- Data Table -->

                    <asp:DataGrid ID="dgOrders" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dgOrders_ItemDataBound" OnPageIndexChanged="dgOrders_PageIndexChanged"
                        OnSortCommand="dgOrders_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="CompanyName" HeaderText="Distributor" SortExpression="CompanyName"
                                ItemStyle-Width="18%"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Order Date" SortExpression="Date" ItemStyle-Width="8%">
                                <ItemTemplate>
                                    <asp:Label ID="lblOrderDate" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:BoundColumn DataField="OrderNumber" HeaderText="Distributor Ref" SortExpression="OrderNumber"
                                ItemStyle-Width="8%"></asp:BoundColumn>
                            <asp:BoundColumn DataField="ClientName" HeaderText="Client / Job Name" SortExpression="ClientName"
                                ItemStyle-Width="12%"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Delivery Date" SortExpression="DesiredDeliveryDate"
                                ItemStyle-Width="8%">
                                <ItemTemplate>
                                    <asp:Label ID="lblDesiredDate" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:BoundColumn DataField="OrderType" HeaderText="Type" SortExpression="OrderType"
                                ItemStyle-Width="8%"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="VL Number - Pattern Number - Fabric" ItemStyle-Width="20%">
                                <ItemTemplate>
                                    <asp:Label ID="lblVlNumber" runat="server" Text=""></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Visual Layout Image" ItemStyle-Width="4%">
                                <ItemTemplate>
                                    <a id="ancVLImage" runat="server"></a>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Order Status" ItemStyle-Width="10%">
                                <ItemTemplate>
                                    <asp:Label ID="lblOrderStatus" runat="server" Text=""></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Qty" ItemStyle-Width="4%">
                                <ItemTemplate>
                                    <a id="linkOrderQty" runat="server" class="btn-link iorder" title="Order Quantity" onserverclick="linkOrderQty_Click">Order Quantity</a>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Action" ItemStyle-Width="4%">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkEditView" runat="server" CssClass="btn-link"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>

                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                            any orders.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <!-- Add Order Popup -->
    <div id="requestOrderQties" class="modal">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h2>
                <asp:Label ID="lblPopupHeaderText" runat="server"></asp:Label></h2>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <fieldset>
                <ol class="ioderlist-table">
                    <asp:Repeater ID="rptSizeQty" runat="server" OnItemDataBound="rptSizeQty_ItemDataBound">
                        <ItemTemplate>
                            <li class="idata-column">
                                <ul>
                                    <li class="icell-header">
                                        <h4>
                                            <asp:Literal ID="litHeading" runat="server"></asp:Literal></h4>
                                    </li>
                                    <li class="icell-data">
                                        <asp:Label ID="lblQty" runat="server"></asp:Label>
                                    </li>
                                </ul>
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>
                </ol>
            </fieldset>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <!-- Delete Item -->
    <div id="requestDelete" class="modal">
        <div class="modal-header">
            <h2>Delete Order</h2>
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Order?
        </div>
        <div class="modal-footer">
            <asp:Button ID="btnDelete" runat="server" CssClass="btn" Text="Yes" Url="/ViewItems.aspx"
                OnClick="btnDelete_Click" />
            <input id="btnCancel" class="btn firePopupCancel" type="button" value="No" />
        </div>
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var isPopulate = ('<%=ViewState["IsPopulate"]%>' == 'True') ? true : false;
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            if (isPopulate) {
                window.setTimeout(function () {
                    $('#requestOrderQties div.modal-header h2 span')[0].innerHTML = 'Order Quantities';
                    showPopupBox('requestOrderQties', '900', '-100');
                }, 10);
            }
        });
    </script>
    <!-- / -->
</asp:Content>
