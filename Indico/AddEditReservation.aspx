<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditReservation.aspx.cs" Inherits="Indico.AddEditReservation" %>

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
            <div id="dvPageContent" runat="server" class="inner">
                
                <legend>Reservation Details</legend>
                 <div class="alert alert-danger" id="dvAlert" style="display:none;"></div>
                <div class="control-group" id="divReservationNo" runat="server" visible="false">
                    <label class="control-label required">
                        Reservation No</label>
                    <div class="controls">
                        <asp:TextBox ID="txtReservationNo" runat="server" Enabled="false"></asp:TextBox>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label required">
                        Reservation Date</label>
                    <div class="controls">
                        <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                            <asp:TextBox ID="txtDate" runat="server" CssClass="datePick"></asp:TextBox>
                            <span class="add-on"><i class="icon-calendar"></i></span>
                        </div>
                        
                    </div>
                </div>


                <%-- <div class="control-group">
                    <label class="control-label">
                        New/Repeat
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlNewRepeat" runat="server">
                            <asp:ListItem Text="New" Value="0" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Repeat" Value="1"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>--%>
                <div class="control-group">
                    <label class="control-label required">
                        Pattern</label>
                    <%--<asp:HiddenField ID="hdnPatternId" runat="server" Value="0" />--%>
                    <div class="controls">
                        <asp:DropDownList ID="ddlPattern" runat="server" CssClass="input-xlarge" DataTextField="NickName" DataValueField="ID"></asp:DropDownList>
                        
                            
                        
                        <%-- <asp:TextBox ID="txtPattern" runat="server" Enabled="false"></asp:TextBox>
                        <asp:HyperLink ID="linkSearchPattern" runat="server" CssClass="btn-link isearch"
                            data-target="#dvSearchPattern" data-toggle="modal" ToolTip="Search Pattern"><i class="icon-search"></i></asp:HyperLink>
                        <asp:HyperLink ID="linkViewPattern" runat="server" CssClass="btn-link ipattern" data-target="#dvViewPattern"
                            data-toggle="modal" ToolTip="View Pattern" Visible="false"><i class="icon-list"></i></asp:HyperLink>
                        <asp:HyperLink ID="linkSpecification" runat="server" CssClass="btn-link ispec" data-target="#dvViewSpecification"
                            data-toggle="modal" ToolTip="View Garment Specification" Visible="false"><i class="icon-th-list"></i></asp:HyperLink>--%>
                    </div>
                </div>
                <!-- Pattern Search -->
                <!-- / -->
                <!-- View Pattern -->
                <!-- / -->
                <!-- View Garment Specification -->
                <!-- / -->
                <div class="control-group">
                    <label class="control-label required">
                        Coordinator</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlCoordinator" runat="server" DataValueField="ID" DataTextField="Username"></asp:DropDownList>
                        
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Distributor</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlDistributor" runat="server" DataValueField="ID" DataTextField="Name">
                        </asp:DropDownList>
                        
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Client</label>
                    <div class="controls">
                        <asp:TextBox ID="txtClient" runat="server"></asp:TextBox>
                    </div>
                </div>
                
                <div class="control-group">
                    <label class="control-label required">
                        ETD</label>
                    <div class="controls">
                        <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                            <asp:TextBox ID="txtShippingDate" runat="server" CssClass="datePick"></asp:TextBox>
                            <span class="add-on"><i class="icon-calendar"></i></span>
                        </div>
                       
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Quantity</label>
                    <div class="controls">
                        <asp:TextBox ID="txtQty" runat="server" CssClass="iintiger"></asp:TextBox>
                        
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">
                        Quantity-Polo and Others</label>
                    <div class="controls">
                        <asp:TextBox ID="txtQtyPolo" runat="server" CssClass="iintiger" Text="0"></asp:TextBox>
                        
                    </div>
                </div>

                 <div class="control-group">
                    <label class="control-label">
                        Quantity-Outerwear</label>
                    <div class="controls">
                        <asp:TextBox ID="txtQtyOutwear" runat="server" CssClass="iintiger" Text="0"></asp:TextBox>
                        
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">
                        Notes</label>
                    <div class="controls">
                        <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine"></asp:TextBox>
                    </div>
                </div>
                <div class="form-actions">
                    <button id="btnSaveChanges"  class="btn btn-primary"
                        type="button">
                       Save Changes</button>
                    <button id="saveButtonServer" runat="server" class="btn btn-primary" style="display:none;" type="submit" onserverclick="btnSaveChanges_Click"></button>
                </div>
            </div>
        </div>
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnCoordinator" runat="server" />
    <!-- Page Script -->
    <script type="text/javascript">
        var PopulatePatern = ('<%=ViewState["PopulatePatern"]%>' == "True") ? true : false;
        var ddlPattern = "<%=ddlPattern.ClientID %>"
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.datepicker').datepicker({ format: 'dd MM yyyy' });
            var reservationno = "#<%=txtReservationNo.ClientID%>";
            var resdate = "#<%=txtDate.ClientID%>";
            var pattern = "#<%=ddlPattern.ClientID%>";
            var coordinator = "#<%=ddlCoordinator.ClientID%>";
            var distributor = "#<%=ddlDistributor.ClientID%>";
            var client = "#<%=txtClient.ClientID%>";
            var shippingdate = "#<%=txtShippingDate.ClientID%>";
            var qty = "#<%=txtQty.ClientID%>";
            function validateControl(dd, name) {
                console.log($(dd).val());
                return !$(dd).val() ? " " + name + " is required. </br>" : "";
            }

           function isFormValid() {
                var error = "";
                error += validateControl(resdate, "Reservation Date");
                error += validateControl(client, "Client");
                error += validateControl(shippingdate, "ETD");
                error += validateControl(qty, "Quantity");
                if($(pattern)[0].selectedIndex==0)
                {
                    error += "Pattern is required<br/>";
                }
                if ($(coordinator)[0].selectedIndex == 0) {
                    error += "Coordinator is required<br/>";
                }

                if ($(distributor)[0].selectedIndex == 0) {
                    error += "Distributor is required<br/>";
                }
           
                if(error){
                    $("#dvAlert").html(error);
                    $("#dvAlert").show();
                    return false;
                }
                return true;

            }


            function onSaveButonClick() {

                if (isFormValid()) {
                    $("#<%=saveButtonServer.ClientID%>").click();
                }

            }

            $(function () {
                $("#btnSaveChanges").on("click", onSaveButonClick);
            });
  
        })(window.jQuery, document);
    </script>
    <!-- / -->
</asp:Content>
