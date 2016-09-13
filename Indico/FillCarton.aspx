<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="FillCarton.aspx.cs" Inherits="Indico.FillCarton" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <%--<asp:LinkButton ID="btnResetPacking" runat="server" class="btn btn-link pull-right ipacking"
                    Text="Reset Carton" OnClick="btnResetPacking_Click" />--%>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <div id="dvError" runat="server" visible="false" style="font-size: 300%">
                    <div class="barcode-scannig">
                        <label class="text-info">
                            <asp:Label ID="lblError" Font-Size="40px" ForeColor="Red" runat="server"></asp:Label>
                        </label>
                        <br />
                    </div>
                </div>
                <div id="dvScanCarton" runat="server">
                    <div class="barcode-scannig">
                        <label id="h3Carton" runat="server" class="text-info" style="font-size: 400%;">
                            <asp:Literal ID="litCarton" runat="server"></asp:Literal>
                            <br />
                            <br />
                            <br />
                            <br />
                            <asp:Literal ID="litAddress" runat="server" Text="Test"></asp:Literal>
                        </label>
                        <div class="barcode-input">
                            <asp:TextBox ID="txtCarton" runat="server" Style="z-index: -1;" MaxLength="128" ValidationGroup="vgScanCarton" Text=""
                                CssClass="icarton"></asp:TextBox>
                            <asp:TextBox ID="TextBox2" runat="server" Style="z-index: -1;" MaxLength="128" Text="" CssClass="ipolybag"></asp:TextBox>
                            <div class="input-mask">
                            </div>
                            <asp:Button ID="btnScanCarton" runat="server" CssClass="btn hide" OnClick="btnScanCarton_Click"
                                data-loading-text="Scanning..." type="submit" Text="Scan" ValidationGroup="vgScanCarton" />
                        </div>
                    </div>
                </div>
                <div id="dvScanPolyBag" runat="server">
                    <div class="barcode-scannig">
                        <asp:Image ID="imgPolyBag" runat="server" ImageUrl="~/Content/img/shopping_bag.png" />
                        <label id="h3PolyBags" runat="server" class="text-info" style="font-size: 400%;">
                            <asp:Literal ID="litPolyBags" runat="server"></asp:Literal>
                        </label>
                        <div class="barcode-input">
                            <asp:TextBox ID="txtPolybag" runat="server" MaxLength="128" ValidationGroup="vgScanPolyBag" Text=""
                                CssClass="ipolybag" TabIndex="0"></asp:TextBox>
                            <asp:TextBox ID="TextBox1" runat="server" MaxLength="128" Text="" Style="z-index: -1;" CssClass="ipolybag"></asp:TextBox>
                            <div class="input-mask">
                            </div>
                            <asp:Button ID="btnScanPolyBag" runat="server" CssClass="btn" OnClick="btnScanPolyBag_Click"
                                data-loading-text="Scanning..." type="submit" Text="Scan" />
                        </div>
                    </div>
                </div>
                <!-- / -->
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <!-- /-->
                    <ul class="thumbnails ">
                        <asp:Repeater ID="rptCarton" runat="server" OnItemDataBound="rptCarton_ItemDataBound"
                            OnItemCommand="rptCarton_ItemCommand">
                            <ItemTemplate>
                                <li class="span2">
                                    <div class="thumbnail">
                                        <asp:Image ID="imgCarton" runat="server" ImageUrl="~/Content/img/carton.png" Height="212"
                                            Width="250" CssClass="iinputbox" />
                                        <div class="caption ">
                                            <h3 class="text-center">
                                                <asp:Literal ID="litCartonNo" runat="server"></asp:Literal>
                                                <asp:HiddenField ID="hdnCartonNo" runat="server" />
                                            </h3>
                                            <div class="btn-group">
                                                <a class="btn" href="#"><i class="icon-cog"></i></a><a class="btn dropdown-toggle"
                                                    data-toggle="dropdown" href="#"><span class="caret"></span></a>
                                                <ul class="dropdown-menu">
                                                    <li>
                                                        <asp:LinkButton ID="linkAdd" CommandName="AddItem" runat="server" CssClass="btn-link"
                                                            ToolTip="Add"><i class="icon-plus "></i> Add</asp:LinkButton></li>
                                                    <%--<li>
                                                        <asp:HyperLink ID="linkReset" runat="server" CssClass="btn-link ireset" ToolTip="Reset Carton"><i class="icon-repeat"></i> Reset Carton</asp:HyperLink>
                                                    </li>--%>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ul>
                </div>
                <div id="dvSuccess" runat="server" visible="false" style="font-size: 300%">
                    <div class="barcode-scannig">
                        <asp:Image ID="imgSuccess" runat="server" ImageUrl="~/Content/img/arrow_box.png" Height="200"
                            Width="200" CssClass="iinputbox" />
                        <label class="text-info">
                            <asp:Label ID="lblSuccess" Font-Size="40px" ForeColor="#33cc33" runat="server"></asp:Label>
                        </label>
                    </div>
                </div>
                <!-- / -->
            </div>
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnCarton" Value="0" runat="server" />
    <asp:HiddenField ID="hdnWeekID" Value="0" runat="server" />
    <div id="requestReset" class="modal fade" role="dialog" aria-hidden="true">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Reset Carton
            </h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to reset this carton?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnReset" runat="server" class="btn btn-primary" type="submit" onserverclick="btnReset_Click"
                data-loading-text="Resetting...">
                Yes</button>
        </div>
    </div>
    <script type="text/javascript">
        var IsCarton = ('<%=ViewState["IsCarton"]%>' == 'True') ? true : false;
        var hdnCarton = "<%=hdnCarton.ClientID %>";
        var hdnWeekID = "<%=hdnWeekID.ClientID %>";    
    </script>
    <script type="text/javascript">
        $(document).click(function () {
            $('.barcode-scannig #<%=InputClientID%>').focus();
        });

        $(document).ready(function () {
            $('.barcode-scannig #<%=InputClientID%>').focus();

            $('#<%=txtCarton.ClientID%>').keydown(function (e) {
                if (e.keyCode == 9) {
                    ChangeImage();
                    setTimeout($('#<%=btnScanCarton.ClientID%>').click(), 50000);
                    $('#<%=txtCarton.ClientID%>').val('');
                }
            });

            $('#<%=txtPolybag.ClientID%>').keydown(function (e) {
                if (e.keyCode == 9) {
                    $('#<%=btnScanPolyBag.ClientID%>').click();
                    $('#<%=txtPolybag.ClientID%>').val('');
                }
            });

            $('.ireset').click(function () {
                $('#' + hdnCarton).val($(this).attr('cid'));
                $('#' + hdnWeekID).val($(this).attr('wid'));
                $('#requestReset').modal('show');
            });

            // only for testing
            //$('#<%=btnScanCarton.ClientID%>').click(function () {
            //
            //    ChangeImage();
            // });

            if (IsCarton) {
                $('#<%=txtCarton.ClientID%>').focus();
            }

        });

        function ChangeImage() {
            $('.iinputbox').each(function () {
                var carton = $('#iContentPlaceHolder_txtCarton').val().split('-')[0];
                var imgcarton = $(this).attr('cid');
                if (carton == imgcarton) {
                    $(this).attr('src', 'Content/img/arrow_box.png').delay(50000).fadeIn(400);
                }
            });
        }
    </script>
</asp:Content>
