<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewCartons.aspx.cs" Inherits="Indico.ViewCartons" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <asp:ScriptManager runat="server" ID="ScriptMananger1">
    </asp:ScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <span class="label">Carton Empty</span>
                <span class="label label-partialycompleted">Partially Filled</span>
                <span class="label label-complete">Filling Completed</span>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Empty Content -->
                <!-- / -->
                <%--Data Content--%>
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <!-- / -->
                    <!-- Data Table -->
                    <asp:Timer ID="Timer" runat="server" Interval="3000" OnTick="Timer_Tick">
                    </asp:Timer>
                    <asp:UpdatePanel ID="updCartons" runat="server" runat="server">
                        <ContentTemplate>
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
                                                <%-- <asp:Literal ID="litCountry" runat="server"></asp:Literal>
                                                    <br />--%>
                                                <asp:Literal ID="litContectDetails" runat="server"></asp:Literal>
                                            </p>
                                        </div>
                                    </div>
                                    <asp:Repeater ID="rptMode" runat="server" OnItemDataBound="rptMode_ItemDataBound">
                                        <ItemTemplate>
                                            <h3>
                                                <asp:Literal ID="litShipmentMode" runat="server"></asp:Literal>
                                            </h3>
                                            <ul class="thumbnails">
                                                <asp:Repeater ID="rptCarton" runat="server" OnItemDataBound="rptCarton_ItemDataBound">
                                                    <ItemTemplate>
                                                        <li class="span1">
                                                            <div class="thumbnail" id="divThumbnail" runat="server">
                                                                <asp:Image ID="imgCarton" runat="server" CssClass="iinputbox" />
                                                                <div class="caption" style="padding: 0px;">
                                                                    <h2 class="text-center">
                                                                        <asp:Literal ID="litCartonNo" runat="server"></asp:Literal>
                                                                    </h2>
                                                                    <asp:HiddenField ID="hdnCartonNo" runat="server" />
                                                                    <h3 class="text-center" style="line-height: 35px;">
                                                                        <asp:Literal ID="litTotal" runat="server"></asp:Literal>
                                                                    </h3>
                                                                </div>
                                                            </div>
                                                        </li>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </ul>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <hr style="border-color:black;" />
                                </ItemTemplate>
                            </asp:Repeater>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="Timer" EventName="Tick" />
                        </Triggers>
                    </asp:UpdatePanel>
                    <!-- / -->
                    <!-- No Search Result -->
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
        // window.setTimeout(function () { window.location = window.location; }, (1000 * 5));
    </script>
</asp:Content>
