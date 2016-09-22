<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewWeekDetails.aspx.cs" Inherits="Indico.ViewWeekDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <%--Data Content--%>
                <div id="dvDataContent" runat="server">
                    <!-- Data Table -->

                    <asp:Repeater ID="rptShipmentOrders" runat="server" OnItemDataBound="rptShipmentOrders_OnItemBound">
                        <ItemTemplate>
                            <div class="clearfix">
                                <div class="alert alert-block alert-info pull-right span4">
                                    <!--<button data-dismiss="alert" class="close" type="button">×</button>-->
                                    <h4 class="alert-heading">
                                        <asp:Literal ID="litDate" runat="server"></asp:Literal>
                                    </h4>
                                    <p>
                                        <asp:Literal ID="litComapny" runat="server"></asp:Literal>
                                        <br />
                                        <asp:Literal ID="litAddress" runat="server"></asp:Literal>
                                        <br />
                                        <asp:Literal ID="litSuberb" runat="server"></asp:Literal>
                                        <br />
                                        <asp:Literal ID="litPostCode" runat="server"></asp:Literal>
                                        <br />
                                        <!--<asp:Literal ID="litCountry" runat="server"></asp:Literal>
                                        <br />-->
                                        <asp:Literal ID="litContectDetails" runat="server"></asp:Literal>
                                    </p>
                                </div>
                            </div>
                            <asp:Repeater ID="rptMode" runat="server" OnItemDataBound="rptMode_ItemDataBound">
                                <ItemTemplate>
                                    <h3>
                                        <asp:Literal ID="litShipmentMode" runat="server"></asp:Literal>
                                    </h3>
                                    <asp:DataGrid ID="dgOrders" runat="server" CssClass="table" AllowCustomPaging="False"
                                        AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                                        OnItemDataBound="dgOrders_ItemDataBound">
                                        <HeaderStyle CssClass="header" />
                                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                                        <Columns>
                                            <asp:TemplateColumn HeaderText="Despatch From" ItemStyle-Width="8%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="litScheduleDate" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="P.O. No." ItemStyle-Width="5%">
                                                <ItemTemplate>
                                                    <asp:HyperLink ID="linkOrderNO" runat="server"></asp:HyperLink>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Order" ItemStyle-Width="5%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="litOrderType" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Client" ItemStyle-Width="12%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="litClient" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Product" ItemStyle-Width="7%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="litVisualLayout" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Pattern" ItemStyle-Width="25%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="litPattern" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Distributor" ItemStyle-Width="15%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="litDistributor" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Qty" ItemStyle-Width="5%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="litQty" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Coordinator" ItemStyle-Width="10%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="litCoordinator" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                        </Columns>
                                    </asp:DataGrid>
                                </ItemTemplate>
                            </asp:Repeater>
                            <legend class="text-right">
                                <asp:Literal ID="litGrandTotal" runat="server"></asp:Literal>
                            </legend>
                        </ItemTemplate>
                    </asp:Repeater>
                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                            any documents.</h4>
                    </div>
                </div>
                <!-- / -->
            </div>
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedAgeGroupID" runat="server" Value="0" />
    <!-- Add / Edit Item -->
    <!-- Delete Item -->
    <!-- / -->
    <script type="text/javascript">
      
    </script>
    <script type="text/javascript">
        $(document).ready(function () {

        });
    </script>
</asp:Content>
