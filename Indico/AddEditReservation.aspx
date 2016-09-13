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
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    ValidationGroup="vgReservationFields" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->
                <!-- / -->
                <!-- Page Data -->
                <legend>Reservation Details</legend>
                <div class="control-group" id="divReservationNo" runat="server" visible="false">
                    <label class="control-label required">
                        Reservation No</label>
                    <div class="controls">
                        <asp:TextBox ID="txtReservationNo" runat="server" Enabled="false"></asp:TextBox>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label required">
                        Date</label>
                    <div class="controls">
                        <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                            <asp:TextBox ID="txtDate" runat="server" CssClass="datePick"></asp:TextBox>
                            <span class="add-on"><i class="icon-calendar"></i></span>
                        </div>
                        <asp:RequiredFieldValidator ID="rfvDate" runat="server" ErrorMessage="Date is required."
                            ControlToValidate="txtDate" EnableClientScript="false" Display="Dynamic" ValidationGroup="vgReservationFields">
                            <img src="Content/img/icon_warning.png"  title="Date is required." alt="Date is required." />
                        </asp:RequiredFieldValidator>
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
                    <label class="control-label">
                        Pattern</label>
                    <%--<asp:HiddenField ID="hdnPatternId" runat="server" Value="0" />--%>
                    <div class="controls">
                        <asp:DropDownList ID="ddlPattern" runat="server" CssClass="input-xlarge"></asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvPattern" runat="server" ErrorMessage="Pattern is required."
                            ControlToValidate="ddlPattern" InitialValue="0" EnableClientScript="false"
                            Display="Dynamic" ValidationGroup="vgReservationFields">
                            <img src="Content/img/icon_warning.png"  title="Pattern is required." alt="Pattern is required." />
                        </asp:RequiredFieldValidator>
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
                        <asp:DropDownList ID="ddlCoordinator" runat="server"></asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvCoordinator" runat="server" ErrorMessage="Coordinator is required."
                            ControlToValidate="ddlCoordinator" InitialValue="0" EnableClientScript="false"
                            Display="Dynamic" ValidationGroup="vgReservationFields">
                            <img src="Content/img/icon_warning.png"  title="Coordinator is required." alt="Coordinator is required." />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Distributor</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlDistributor" runat="server">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvDistributor" runat="server" ErrorMessage="Distributor is required."
                            ControlToValidate="ddlDistributor" InitialValue="0" EnableClientScript="false"
                            Display="Dynamic" ValidationGroup="vgReservationFields">
                            <img src="Content/img/icon_warning.png"  title="Distributor is required." alt="Distributor is required." />
                        </asp:RequiredFieldValidator>
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
                    <label class="control-label">
                        Shipt To</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlShipToAddress" runat="server"></asp:DropDownList>
                        <asp:Label ID="lblShipToAddress" runat="server" Visible="false"></asp:Label>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Shipement Mode</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlShipmentMode" runat="server">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Shipping Date</label>
                    <div class="controls">
                        <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                            <asp:TextBox ID="txtShippingDate" runat="server" CssClass="datePick"></asp:TextBox>
                            <span class="add-on"><i class="icon-calendar"></i></span>
                        </div>
                        <asp:RequiredFieldValidator ID="rfvShippingDate" runat="server" ErrorMessage="Shipping date is required."
                            ControlToValidate="txtShippingDate" EnableClientScript="false" Display="Dynamic"
                            ValidationGroup="vgReservationFields">
                            <img src="Content/img/icon_warning.png"  title="Shipping date is required." alt="Shipping date is required." />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Quantity</label>
                    <div class="controls">
                        <asp:TextBox ID="txtQty" runat="server" CssClass="iintiger"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvQuantity" runat="server" ErrorMessage="Quantity is required."
                            ControlToValidate="txtQty" EnableClientScript="false" Display="Dynamic" ValidationGroup="vgReservationFields">
                            <img src="Content/img/icon_warning.png"  title="Quantity is required." alt="Quantity is required." />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div id="liStatus" runat="server" visible="false" class="control-group">
                    <label class="control-label">
                        Status</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlStatus" runat="server">
                        </asp:DropDownList>
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
                    <button id="btnSaveChanges" runat="server" class="btn btn-primary" text="" type="submit"
                        data-loading-text="Saving..." onserverclick="btnSaveChanges_Click" validationgroup="vgReservationFields">
                        Save Changes</button>
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
            if (PopulatePatern) {
                window.setTimeout(function () {
                    $('#dvSearchPattern').modal('show');
                }, 10);
            }

            $('#' + ddlPattern).select2();

            $('.datepicker').datepicker({ format: 'dd MM yyyy' });
        });
    </script>
    <!-- / -->
</asp:Content>
