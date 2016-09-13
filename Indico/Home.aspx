<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="Home.aspx.cs" Inherits="Indico.Home" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="inner">
                <!-- Client Order Details -->
                <div id="dvClientOrderDetails" runat="server" visible="true" class="hero-unit">
                    <h1>
                        <asp:Literal ID="litCompanyName" runat="server"></asp:Literal></h1>
                    <p>
                        <%--<asp:Literal ID="litOrderCount" runat="server"></asp:Literal>--%> Page under construction.</p>
                    <a id="ancOrderCount" class="btn btn-primary btn-large" href="ViewOrders.aspx" runat="server">View Orders</a>
                    <asp:Button ID="btnViewClientOrder" runat="server" Text="View" CssClass="btn btn-primary"
                        Visible="false" />
                    <input id="btnHideClientOrder" type="button" name="Hide" value="Hide" class="btn btn-primary"
                        style="display: none" />
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var dvClientOrderDetails = "<%=dvClientOrderDetails.ClientID %>";
    </script>
    <script type="text/javascript">
        $(function () {
            // run the currently selected effect
            function runEffect() {
                // get effect type from 
                var selectedEffect = 'blind';

                // most effect types need no options passed by default
                var options = {};
                // some effects have required parameters
                if (selectedEffect === "scale") {
                    options = { percent: 0 };
                } else if (selectedEffect === "size") {
                    options = { to: { width: 200, height: 60} };
                }

                // run the effect
                $('#' + dvClientOrderDetails).toggle(selectedEffect, options, 500);
            };

            // set effect from select menu value
            $("#btnHideClientOrder").click(function () {
                runEffect();
                return false;
            });
        });	
    </script>
    <!-- / -->
</asp:Content>
