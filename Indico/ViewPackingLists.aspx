<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewPackingLists.aspx.cs" Inherits="Indico.ViewPackingLists" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <asp:LinkButton ID="btnPrintLabels" runat="server" class="btn btn-link pull-right" OnClick="btnPrintLabels_Click" Text="Print Labels" />
                <%-- <asp:LinkButton ID="btnStartPacking" runat="server" class="btn btn-link pull-right ipacking"
                    Text="Start Packing" data-toggle="modal" data-target="#requestPacking" />--%>
                <asp:LinkButton ID="btnStartPacking" runat="server" class="btn btn-link pull-right ipacking" Text="Start Packing" PostBackUrl="~/FillCarton.aspx" />
                <asp:LinkButton ID="btnViewCartons" runat="server" class="btn btn-link pull-right ipacking" Text="View Cartons" OnClick="btnViewCartons_Click"></asp:LinkButton>
                <asp:LinkButton ID="btnPrintReport" runat="server" class="btn btn-link pull-right ipacking" Text="Print Packing Report" OnClick="btnPrintReport_Click"><i class="icon-print"></i>Print Packing Report</asp:LinkButton>
                <asp:LinkButton ID="btnPrintReset" runat="server" class="btn btn-link pull-right ipacking" Text="Print Reset BarCode" OnClick="btnPrintReset_Click"><i class="icon-print"></i>Print Reset BarCode</asp:LinkButton>
                <asp:LinkButton ID="btnClientPackingList" runat="server" class="btn btn-link pull-right" Text="Print Packing Report" OnClick="btnClientPackingList_Click"><i class="icon-print"></i>Print Client Packing Report</asp:LinkButton>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">

                <legend>Details</legend>
                <div class="control-group">
                    <label class="control-label">
                        Shipment Mode
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlShipmentMode" runat="server"></asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Shipping Company
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlShippingAddress" runat="server"></asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <div class="controls">
                        <button id="btnSearch" runat="server" class="btn" type="submit" data-loading-text="Searching..." onserverclick="btnSearch_ServerClick">
                            Search</button>
                    </div>
                </div>
                <!-- Data Content -->
                <legend>Packing Details</legend>
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <%-- <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>--%>
                        <%--<asp:Button ID="btnProceed" runat="server" Text="Save changes" />--%>
                    </div>

                    <asp:Repeater ID="rptDistributor" runat="server" OnItemDataBound="rptDistributor_ItemDataBound">
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
                                        <asp:Literal ID="litContactDetails" runat="server"></asp:Literal>
                                    </p>
                                </div>
                            </div>
                            <asp:Repeater ID="rptModes" runat="server" OnItemDataBound="rptModes_ItemDataBound">
                                <ItemTemplate>
                                    <h3>
                                        <asp:Literal ID="litShipmentMode" runat="server"></asp:Literal>
                                    </h3>
                                    <asp:Repeater ID="rptPackingList" runat="server" OnItemDataBound="rptPackingList_ItemDataBound"
                                        OnItemCommand="rptPackingList_ItemCommand">
                                        <ItemTemplate>
                                            <div>
                                                <h4>
                                                    <span class="pull-right">
                                                        <asp:LinkButton ID="btnAutoFill" runat="server" CssClass="btn btn-mini inprogress" CommandName="AutoFill" ToolTip="Auto Fill Carton" Text="">Auto Fill Carton</asp:LinkButton>
                                                        <asp:LinkButton ID="btnPrintLabel" runat="server" CssClass="btn btn-mini" CommandName="PrintLabel" ToolTip="Print Label"><i class="icon-print"></i></asp:LinkButton>
                                                        <asp:LinkButton ID="btnStartPackingCarton" Visible="true" runat="server" CssClass="btn btn-mini inprogress" CommandName="StartPacking" ToolTip="Start Packing" Text="Start Packing"><i class="icon-tags"></i>&nbsp;</asp:LinkButton>
                                                        <asp:LinkButton ID="btnResetCarton" runat="server" CssClass="btn btn-mini" CommandName="ResetCarton" ToolTip="Reset Carton" Text="Reset Carton">Reset Carton</asp:LinkButton>
                                                        <asp:Literal ID="litTotal" runat="server"></asp:Literal>
                                                    </span>
                                                    <asp:Literal ID="litCartonNo" runat="server"></asp:Literal>
                                                    <asp:HiddenField ID="hdnCartonNo" runat="server"></asp:HiddenField>
                                                    <asp:HiddenField ID="hdnPackingListID" runat="server"></asp:HiddenField>
                                                    <asp:HiddenField ID="hdnWeeklyID" runat="server" Value="0" />
                                                    <asp:HiddenField ID="hdnShipTo" runat="server" Value="0" />
                                                    <asp:HiddenField ID="hdnShipmentMode" runat="server" Value="0" />
                                                </h4>
                                                <asp:DataGrid ID="dgPackingList" runat="server" CssClass="table" AllowCustomPaging="False"
                                                    GridLines="None" OnItemDataBound="dgPackingList_ItemDataBound" AutoGenerateColumns="false">
                                                    <HeaderStyle CssClass="header" />
                                                    <Columns>
                                                        <asp:TemplateColumn HeaderText="ID" Visible="false">
                                                            <ItemTemplate>
                                                                <asp:Literal ID="lblID" runat="server"></asp:Literal>
                                                                <asp:Literal ID="lblParentID" runat="server"></asp:Literal>
                                                            </ItemTemplate>
                                                        </asp:TemplateColumn>
                                                        <asp:TemplateColumn HeaderText="PO No" ItemStyle-Width="6%">
                                                            <ItemTemplate>
                                                                <asp:Literal ID="lblPoNo" runat="server"></asp:Literal>
                                                            </ItemTemplate>
                                                        </asp:TemplateColumn>
                                                        <asp:TemplateColumn HeaderText="Client" ItemStyle-Width="12%">
                                                            <ItemTemplate>
                                                                <asp:Literal ID="lblClient" runat="server"></asp:Literal>
                                                            </ItemTemplate>
                                                        </asp:TemplateColumn>
                                                        <asp:TemplateColumn HeaderText="Distributor" ItemStyle-Width="12%">
                                                            <ItemTemplate>
                                                                <asp:Literal ID="lblDistributor" runat="server"></asp:Literal>
                                                            </ItemTemplate>
                                                        </asp:TemplateColumn>
                                                        <asp:TemplateColumn HeaderText="VL No" ItemStyle-Width="8%">
                                                            <ItemTemplate>
                                                                <asp:Literal ID="lblVLName" runat="server"></asp:Literal>
                                                            </ItemTemplate>
                                                        </asp:TemplateColumn>
                                                        <asp:TemplateColumn HeaderText="Description" ItemStyle-Width="18%">
                                                            <ItemTemplate>
                                                                <asp:Literal ID="lblDescription" runat="server"></asp:Literal>
                                                            </ItemTemplate>
                                                        </asp:TemplateColumn>
                                                        <asp:TemplateColumn HeaderText="Size" ItemStyle-Width="40%">
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
                                                                                        <asp:Label ID="lblSize" runat="server" Visible="false"></asp:Label>
                                                                                        <asp:Label ID="lblQty" runat="server" Text="0"></asp:Label>
                                                                                    </li>
                                                                                </ul>
                                                                            </li>
                                                                        </ItemTemplate>
                                                                    </asp:Repeater>
                                                                </ol>
                                                            </ItemTemplate>
                                                        </asp:TemplateColumn>
                                                        <asp:TemplateColumn HeaderText="Total" ItemStyle-Width="4%">
                                                            <ItemTemplate>
                                                                <asp:Literal ID="lblTotal" runat="server"></asp:Literal>
                                                            </ItemTemplate>
                                                        </asp:TemplateColumn>
                                                    </Columns>
                                                </asp:DataGrid>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ItemTemplate>
                            </asp:Repeater>
                        </ItemTemplate>
                    </asp:Repeater>
                    <div>
                        <%--<h4>
                                    <span class="pull-right">
                                        <asp:LinkButton ID="btnAutoFill" runat="server" CssClass="btn btn-mini inprogress" CommandName="AutoFill" ToolTip="Auto Fill Carton" Text="">Auto Fill Carton</asp:LinkButton>
                                        <asp:LinkButton ID="btnPrintLabel" runat="server" CssClass="btn btn-mini" CommandName="PrintLabel" ToolTip="Print Label"><i class="icon-print"></i></asp:LinkButton>
                                        <asp:LinkButton ID="btnStartPackingCarton" Visible="false" runat="server" CssClass="btn btn-mini inprogress" CommandName="StartPacking" ToolTip="Start Packing" Text="Start Packing"><i class="icon-tags"></i>&nbsp;</asp:LinkButton>
                                        <asp:LinkButton ID="btnResetCarton" runat="server" CssClass="btn btn-mini" CommandName="ResetCarton" ToolTip="Reset Carton" Text="Reset Carton">Reset Carton</asp:LinkButton>
                                        <asp:Literal ID="litTotal" runat="server"></asp:Literal>
                                    </span>
                                    <asp:Literal ID="litCartonNo" runat="server"></asp:Literal>
                                    <asp:HiddenField ID="hdnCartonNo" runat="server"></asp:HiddenField>
                                    <asp:HiddenField ID="hdnPackingListID" runat="server"></asp:HiddenField>
                                    <asp:HiddenField ID="hdnWeeklyID" runat="server" Value="0" />
                                </h4>--%>
                    </div>

                    <h3 class="text-center">
                        <asp:Literal ID="litGrandTotal" runat="server"></asp:Literal>
                    </h3>
                </div>
                <!-- / -->
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info" visible="false">
                    <h4>
                        <asp:Literal ID="litErrorMeassaage" runat="server"></asp:Literal></h4>
                </div>
                <!-- / -->
            </div>
        </div>
        <div id="requestPacking" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
            data-backdrop="static">
            <!-- Popup Header -->
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    ×</button>
                <h3>
                    <asp:Label ID="lblPopupHeaderText" runat="server">Scan Barcode</asp:Label></h3>
            </div>
            <!-- / -->
            <!-- Popup Content -->
            <div class="modal-body">
                <!-- Popup Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    ValidationGroup="vgScan" DisplayMode="BulletList" HeaderText="<strong>Scanning not successful.</strong>"></asp:ValidationSummary>
                <!-- / -->
                <fieldset>
                    <div class="control-group">
                        <label class="control-label required">
                            Barcode</label>
                        <div class="controls">
                            <asp:TextBox ID="txtBarcode" runat="server" MaxLength="128" ValidationGroup="vgScan"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvBarcode" runat="server" CssClass="error" ControlToValidate="txtBarcode"
                                ValidationGroup="vgScan" Display="Dynamic" EnableClientScript="True" ErrorMessage="Barcode is required">
                                <img src="Content/img/icon_warning.png" title="Barcode is required" alt="Barcode is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                </fieldset>
            </div>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">
                    Close</button>
                <asp:Button ID="btnScan" runat="server" CssClass="btn btn-primary hide" OnClick="btnScan_Click"
                    data-loading-text="Scanning..." type="submit" Text="Scan" ValidationGroup="vgScan" />
            </div>
        </div>
    </div>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#<%=txtBarcode.ClientID%>').keydown(function (e) {
                if (e.keyCode == 9) {
                    $('#<%=btnScan.ClientID%>').click();
                }
            });
        });
    </script>
</asp:Content>
