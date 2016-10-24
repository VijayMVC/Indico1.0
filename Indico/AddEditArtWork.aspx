<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditArtWork.aspx.cs" Inherits="Indico.AddEditArtWork" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"
                    ValidationGroup="valGrpVL"></asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <legend>Details</legend>
                <div class="control-group">
                    <label id="lblProductNumber" runat="server" class="control-label required">
                        Reference Number
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtReferenceNumber" runat="server">
                        </asp:TextBox>
                        <%-- <asp:RequiredFieldValidator ID="rfvProductNumber" runat="server" ErrorMessage="Product number is required"
                            ControlToValidate="txtReferenceNumber" EnableClientScript="false" ValidationGroup="valGrpVL"
                            InitialValue="0">
                            <img src="Content/img/icon_warning.png"  title="Product number is required" alt="Product Number is required" />
                        </asp:RequiredFieldValidator>--%>
                        <%--<asp:CustomValidator ID="cvProductNumber" runat="server" ErrorMessage="This Product number already being used."
                            EnableClientScript="false" ValidationGroup="valGrpVL" ControlToValidate="txtProductNumber"
                            OnServerValidate="cvProductNumber_OnServerValidate">
                                <img src="Content/img/icon_warning.png"  title="This Product number already being used." alt="This Product number already being used." />
                        </asp:CustomValidator>--%>
                    </div>
                </div>
                <div id="dvHideColums" runat="server">
                    <asp:UpdatePanel ID="updatePnlDistributor" runat="server">
                        <ContentTemplate>
                            <div class="control-group">
                                <label class="control-label required">
                                    Distributor</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlDistributor" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlDistributor_SelectedIndexChange">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Client/Job Name</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlClient" Enabled="false" runat="server">
                                    </asp:DropDownList>
                                    <asp:LinkButton ID="lbAddNewClient" runat="server" OnClick="lbAddNewClient_Click"
                                        data-original-title="Add New Client" CssClass="btn-link iadd" ToolTip="Add New Client"
                                        Style="visibility: hidden"><i class="icon-plus"></i></asp:LinkButton>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Primary Coordinator</label>
                                <div class="controls">
                                    <b>
                                        <asp:Label ID="lblPrimaryCoordinator" runat="server"></asp:Label></b>
                                </div>
                            </div>
                            <%--  <div class="control-group">
                                <label class="control-label">
                                    Secondary Coordinator</label>
                                <div class="controls">
                                    <b>
                                        <asp:Label ID="lblSecondaryCoordinator" runat="server"></asp:Label></b>
                                </div>
                            </div>--%>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Resolution Profile</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlResolutionProfile" runat="server">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Fabric</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlFabric" runat="server" CssClass="">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Pattern</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlPattern" runat="server" OnSelectedIndexChanged="ddlPattern_OnSelectedIndexChanged"
                            AutoPostBack="true">
                        </asp:DropDownList>
                        <span class="text-error">
                            <asp:Literal ID="litPatternError" runat="server" Visible="false"></asp:Literal>
                        </span>
                        <asp:LinkButton ID="linkViewPattern" runat="server" CssClass="btn-link ipattern"
                            ToolTip="View Pattern" OnClick="linkViewPattern_Click" Visible="false">Pattern</asp:LinkButton>
                        <asp:LinkButton ID="linkSpecification" runat="server" CssClass="btn-link ispec" ToolTip="View Garment Specification"
                            OnClick="linkSpecification_Click" Visible="false">Sepecification</asp:LinkButton>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">Pocket</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlPocketType" runat="server"></asp:DropDownList>
                    </div>
                </div>
                <!-- View Pattern -->
                <%--   <div id="dvViewPattern" class="modal">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <div class="modal-header">
                        <h2>Pattern Details</h2>
                    </div>
                    <div class="modal-body">
                        <fieldset class="info">
                            <ol>
                                <li>
                                    <label>
                                        Pattern Number</label>
                                    <asp:TextBox ID="txtPatternNo" runat="server" Enabled="false"></asp:TextBox>
                                </li>
                                <li>
                                    <label>
                                        Item Name</label>
                                    <asp:TextBox ID="txtItemName" runat="server" Enabled="false"></asp:TextBox>
                                </li>
                                <li>
                                    <label>
                                        Size Set</label>
                                    <asp:TextBox ID="txtSizeSet" runat="server" Enabled="false"></asp:TextBox>
                                </li>
                                <li>
                                    <label>
                                        Age Group</label>
                                    <asp:TextBox ID="txtAgeGroup" runat="server" Enabled="false"></asp:TextBox>
                                </li>
                                <li>
                                    <label>
                                        Printer Trpe</label>
                                    <asp:TextBox ID="txtPrinterType" runat="server" Enabled="false"></asp:TextBox>
                                </li>
                                <li>
                                    <label>
                                        Keywords</label>
                                    <asp:TextBox ID="txtKeyword" runat="server" Enabled="false"></asp:TextBox>
                                </li>
                                <li>
                                    <label>
                                        Original Ref</label>
                                    <asp:TextBox ID="txtOriginalRef" runat="server" Enabled="false"></asp:TextBox>
                                </li>
                                <li>
                                    <label>
                                        Sub Item Name</label>
                                    <asp:TextBox ID="txtSubItem" runat="server" Enabled="false"></asp:TextBox>
                                </li>
                                <li>
                                    <label>
                                        Gender</label>
                                    <asp:TextBox ID="txtGender" runat="server" Enabled="false"></asp:TextBox>
                                </li>
                                <li>
                                    <label>
                                        Nick Name</label>
                                    <asp:TextBox ID="txtNickName" runat="server" Enabled="false"></asp:TextBox>
                                </li>
                                <li>
                                    <label>
                                        Corr Pattern</label>
                                    <asp:TextBox ID="txtCorrPattern" runat="server" Enabled="false"></asp:TextBox>
                                </li>
                                <li>
                                    <label>
                                        Consumption</label>
                                    <asp:TextBox ID="txtConsumption" runat="server" Enabled="false"></asp:TextBox>
                                </li>
                            </ol>
                        </fieldset>
                    </div>
                </div>--%>
                <!-- / -->
                <!-- View Garment Specification -->
                <%-- <div id="dvViewSpecification" class="modal garmentSpec">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                            &times;</button>
                        <h3>Garment Specification</h3>
                    </div>
                    <div class="modal-body">
                        <ol class="ioderlist-table">
                            <li class="idata-row">
                                <ul>
                                    <li class="icell-header small">Key</li>
                                    <li class="icell-header exlarge">Loacation</li>
                                    <asp:Repeater ID="rptSpecSizeQtyHeader" runat="server" OnItemDataBound="rptSpecSizeQtyHeader_ItemDataBound">
                                        <ItemTemplate>
                                            <li class="icell-header">
                                                <asp:Literal ID="litCellHeader" runat="server"></asp:Literal>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ul>
                            </li>
                            <asp:Repeater ID="rptSpecML" runat="server" OnItemDataBound="rptSpecML_ItemDataBound">
                                <ItemTemplate>
                                    <li class="idata-row">
                                        <ul>
                                            <li class="icell-header small">
                                                <asp:Literal ID="litCellHeaderKey" runat="server"></asp:Literal>
                                            </li>
                                            <li class="icell-header exlarge">
                                                <asp:Literal ID="litCellHeaderML" runat="server"></asp:Literal>
                                            </li>
                                            <asp:Repeater ID="rptSpecSizeQty" runat="server" OnItemDataBound="rptSpecSizeQty_ItemDataBound">
                                                <ItemTemplate>
                                                    <li class="icell-data">
                                                        <asp:Label ID="lblCellData" runat="server"></asp:Label>
                                                    </li>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </ul>
                                    </li>
                                </ItemTemplate>
                            </asp:Repeater>
                        </ol>
                    </div>
                </div>--%>
                <!-- / -->
                <!-- Data Content -->
                <asp:UpdatePanel ID="UpdatePatternAccessory" runat="server">
                    <ContentTemplate>
                        <div id="dvNewDataContent" runat="server" visible="false">
                            <legend>Accessories </legend>
                            <div id="dvAccessoryEmptyContent" runat="server" class="alert alert-info">
                                <h4>No Accessories Found
                                </h4>
                            </div>
                            <!-- Data grid -->
                            <asp:DataGrid ID="dgPatternAccessory" runat="server" CssClass="table" AutoGenerateColumns="false"
                                AllowSorting="true" GridLines="None" AllowPaging="false" AllowCustomPaging="False"
                                OnItemDataBound="dgPatternAccessory_ItemDataBound">
                                <HeaderStyle CssClass="header" />
                                <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                                <Columns>
                                    <asp:TemplateColumn HeaderText="Pattern Number" Visible="false">
                                        <ItemTemplate>
                                            <asp:Label ID="lblPatternNumber" runat="server"></asp:Label>
                                            <asp:Label ID="lblPatternID" runat="server" Visible="false"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Accessory Name">
                                        <ItemTemplate>
                                            <asp:Label ID="lblAccessoryName" runat="server"></asp:Label>
                                            <asp:Label ID="lblAccessoryID" runat="server" Visible="false"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Accessory Category">
                                        <ItemTemplate>
                                            <asp:Label ID="lblAccessoryCategory" runat="server"></asp:Label>
                                            <asp:Label ID="lblAccessoryCategoryID" runat="server" Visible="false"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Code">
                                        <ItemTemplate>
                                            <asp:Label ID="lblCategoryCode" runat="server"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Accessory Color" Visible="false">
                                        <ItemTemplate>
                                            <asp:DropDownList ID="ddlAccessoryColor" runat="server" onchange="colorchange(this)">
                                            </asp:DropDownList>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn Visible="false">
                                        <ItemTemplate>
                                            <div class="color-picker-frame">
                                                <div id="dvAccessoryColor" runat="server" class="icolor">
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                </Columns>
                            </asp:DataGrid>
                            <!-- / -->
                            <!-- No Search Result -->
                            <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                                <h4>Your search - <strong>
                                    <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                                    any documents.</h4>
                            </div>
                            <!-- / -->
                        </div>
                        <script type="text/javascript">
                            function colorchange(sender) {
                                $(sender).closest('tr').find('.icolor').attr('style', 'background-color:' + $('option:selected', sender).attr('color'));
                            }
                        </script>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="ddlPattern"  EventName="SelectedIndexChanged" />
                    </Triggers>
                </asp:UpdatePanel>
                <div class="form-actions">
                    <button id="btnSaveChanges" runat="server" class="btn btn-primary" type="submit"
                        data-loading-text="Saving..." onserverclick="btnSaveChanges_Click" validationgroup="valGrpVL">
                        Save Changes</button>
                    <button id="btnCancel" runat="server" class="btn btn-primary"
                        onserverclick="btnCancel_ServerClick" type="button">
                        Cancel</button>
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <!-- Delete VL Image -->
    <%--<div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Product Image</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Image?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDeleteVLImage" runat="server" class="btn btn-primary" type="submit"
                onserverclick="btnDeleteVLImage_Click">
                Yes</button>
        </div>
    </div>--%>
    <!-- / -->
    <!-- Page Script -->
    <script type="text/javascript">
        var PopulatePatern = ('<%=ViewState["PopulatePatern"]%>' == "True") ? true : false;
        var PopulateFabric = ('<%=ViewState["PopulateFabric"]%>' == "True") ? true : false;
        var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
        var txtProductNumber = "<%=txtReferenceNumber.ClientID %>";
        var dvHideColums = "<%=dvHideColums.ClientID %>"
        var ddlPattern = "<%=ddlPattern.ClientID %>"
        var ddlFabric = "<%=ddlFabric.ClientID %>"
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            if (PopulatePatern) {
                window.setTimeout(function () {
                    showPopupBox('dvViewPattern');
                }, 10);
            }

            if (PopulateFabric) {
                window.setTimeout(function () {
                    showPopupBox('dvViewSpecification', ($(window).width() * 0.7));
                }, 10);
            }

            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });

            $('#' + ddlPattern).select2();
            $('#' + ddlFabric).select2();

            $('.igridview input[type=checkbox]').click(function () {
                var id = this.id;
                if (!this.checked) {
                    this.checked = true;
                }
                else {
                    $('.igridview input[type=checkbox]').each(function () {
                        if (this.id != id) {
                            this.checked = false;
                        }
                    });
                }
            });



            /*$('.ivlImage').click(function () {
            $('.ivlImage input[type=checkbox]').each(function () {
            $(this).prop("checked", false);
            });
            $(this).attr('checked', true);
            });*/
        });

        function checkChanged(e) {
            $('.ivlImage input[type=checkbox]').each(function () {
                $(this).prop("checked", false);
            });
            $(e).children('input[type=checkbox]').prop('checked', true)
        }

    </script>
    <!-- / -->
</asp:Content>
