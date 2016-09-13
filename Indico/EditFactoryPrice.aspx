<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="EditFactoryPrice.aspx.cs" Inherits="Indico.EditFactoryPrice" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btndownloadExcel" runat="server" class="btn btn-link pull-right" type="submit"
                    onserverclick="btndownloadExcel_Click">Price Excel</a>
                <asp:DropDownList ID="ddlPriceTerm" runat="server" CssClass="pull-right" Visible="false">
                </asp:DropDownList>
                <asp:DropDownList ID="ddlExcelDistributor" runat="server" CssClass="pull-right" Visible="false">
                </asp:DropDownList>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    ValidationGroup="priceHeader" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <fieldset>
                    <legend>Price Details</legend>
                    <div class="control-group">
                        <label class="control-label">
                            Search Any
                        </label>
                        <div class="controls">
                            <asp:TextBox ID="txtSearchAny" runat="server"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Pattern Number</label>
                        <div class="controls">
                            <asp:TextBox ID="txtPattern" runat="server"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Pattern Nick Name</label>
                        <div class="controls">
                            <asp:TextBox ID="txtPatternNickName" runat="server"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Fabric Code</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlFabricCode" runat="server">
                            </asp:DropDownList>
                        </div>
                    </div>
                </fieldset>
                <div class="form-actions">
                    <button id="btnSearch" runat="server" class="btn" onserverclick="btnSearch_Click"
                        data-loading-text="Searching..." type="submit">
                        Search
                    </button>
                </div>
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info" visible="false">
                    <h4 id="h2EmptyContent" runat="server">There are no Fabrics associated with this Pattern.
                    </h4>
                    <p id="pEmptyContent" runat="server">
                        Once Pattern is added then you will be able to add Fabrics.
                    </p>
                </div>
                <!-- / -->
                <!-- Selected Fabrics -->
                <asp:DataGrid ID="dgSelectedFabrics" runat="server" CssClass="table" AllowCustomPaging="False"
                    AutoGenerateColumns="false" GridLines="None" PageSize="20" OnItemDataBound="dgSelectedFabrics_ItemDataBound"
                    OnPageIndexChanged="dgSelectFabrics_PageIndexChanged">
                    <HeaderStyle CssClass="header" />
                    <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                    <Columns>
                        <asp:TemplateColumn HeaderText="ID" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide">
                            <ItemTemplate>
                                <asp:Literal ID="litPrice" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Pattern Number">
                            <ItemTemplate>
                                <asp:Literal ID="lblPatternNumber" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Nick Name">
                            <ItemTemplate>
                                <asp:Literal ID="lblNickName" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Fabric Code">
                            <ItemTemplate>
                                <asp:Literal ID="lblFabricName" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Cost">
                            <ItemTemplate>
                                <ol id="olPriceTable" runat="server" class="ioderlist-table">
                                    <asp:Repeater ID="rptPriceLevelCost" runat="server" OnItemDataBound="rptPriceLevelCost_ItemDataBound">
                                        <ItemTemplate>
                                            <li class="idata-column">
                                                <ul>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litCellHeader" runat="server"></asp:Literal>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:HiddenField ID="hdnCellID" runat="server" Value="0"></asp:HiddenField>
                                                        <asp:Label ID="lblCellData" runat="server" CssClass="idouble" EnableViewState="true"></asp:Label>
                                                    </li>
                                                </ul>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ol>
                                <div class="iaccess-controls">
                                    <label>Set cost for all levels</label>
                                    <input id="txtSetCostForAllLevels" type="text" class="input-mini idouble iapply-cost"
                                        style="width: 74px" />
                                    <button id="btnApply" runat="server" class="btn iapply" type="submit" onserverclick="btnUpdate_Click"
                                        data-loading-text="Applying...">
                                        Apply
                                    </button>
                                    <%--<button id="btnDelete" runat="server" class="btn pull-right idelete" style="margin-left: 10px;"
                                        type="button">
                                        Delete
                                    </button>--%>
                                    <%--<asp:LinkButton ID="btnUpdate" runat="server" class="btn-link isave" ToolTip="Update Price"
                                            OnClick="btnUpdate_Click">Update</asp:LinkButton>--%>
                                    <%--   <button id="btnUpdate" runat="server" class="btn pull-right" onserverclick="btnUpdate_Click"
                                            type="button">
                                            Update
                                        </button>--%>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="">
                            <ItemTemplate>
                                <div class="btn-group pull-right">
                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                        <i class="icon-cog"></i><span class="caret"></span></a>
                                    <ul class="dropdown-menu pull-right">
                                        <li>
                                            <asp:HyperLink ID="linkAddEditNote" runat="server" CssClass="btn-link iadd" ToolTip="Add Note"><i class="icon-plus"></i>Add Note</asp:HyperLink>
                                        </li>
                                        <li>
                                            <asp:LinkButton ID="btnViewNote" runat="server" OnClick="btnViewNote_Click" CssClass="btn-link inote"
                                                Visible="false"><i class="icon-list-alt"></i>View  Note</asp:LinkButton>
                                        </li>
                                        <li>
                                            <asp:LinkButton ID="btnUpdate" runat="server" class="btn-link isave" ToolTip="Update Price"
                                                Visible="false" OnClick="btnUpdate_Click"><i class="icon-edit"></i>Upadte</asp:LinkButton>
                                        </li>
                                    </ul>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                    </Columns>
                </asp:DataGrid>
                <!-- / -->
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnPattern" runat="server" Value="0" />
    <asp:HiddenField ID="hdnFabric" runat="server" Value="0" />
    <asp:HiddenField ID="PriceID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnFactoryPriceRemarks" runat="server" Value="0" />
    <asp:HiddenField ID="hdnFactoryPrice" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Factory Prices</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this factory prices?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" onserverclick="btnDelete_Click"
                data-loading-text="Deleting..." type="submit">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- AddEdit Note -->
    <div id="dvAddEditNote" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblNoteTitle" runat="server" Text="Add Note"></asp:Label>
            </h3>
        </div>
        <div class="modal-body">
            <asp:ValidationSummary ID="vsAddNote" runat="server" CssClass="alert alert-danger"
                ValidationGroup="checkNote" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <fieldset>
                <div class="control-group">
                    <label class="control-label required">
                        Note</label>
                    <div class="controls">
                        <asp:TextBox ID="txtNote" runat="server" TextMode="MultiLine" />
                        <asp:RequiredFieldValidator ID="rfvNote" runat="server" CssClass="error" ControlToValidate="txtNote"
                            ValidationGroup="checkNote" Display="Dynamic" EnableClientScript="False" ErrorMessage="Note is required">
                                <img src="Content/img/icon_warning.png" title="Note is required" alt="Note is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
            </fieldset>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveNote" runat="server" class="btn btn-primary" type="submit" validationgroup="checkNote"
                data-loading-text="Saving..." onserverclick="btnSaveNote_Click">
                Save Changes</button>
        </div>
    </div>
    <!-- / -->
    <!-- View Note -->
    <div id="dvViewNote" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblViewNoteTitle" runat="server" Text="View Notes"></asp:Label>
            </h3>
        </div>
        <div class="modal-body">
            <div id="dvNoteEmptyContent" runat="server" class="alert alert-info">
                <h4>No price remarks
                </h4>
            </div>
            <fieldset>
                <asp:DataGrid ID="dgViewNote" runat="server" CssClass="table" AllowCustomPaging="False"
                    AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                    PageSize="1000" OnItemDataBound="dgViewNote_ItemDataBound">
                    <HeaderStyle CssClass="header" />


                    <Columns>
                        <asp:TemplateColumn HeaderText="Creator">
                            <ItemTemplate>
                                <asp:Literal ID="lblCreator" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Created Date">
                            <ItemTemplate>
                                <asp:Literal ID="lblCreatedDate" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Remarks">
                            <ItemTemplate>
                                <asp:Literal ID="lblRemarks" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Remarks">
                            <ItemTemplate>
                                <div class="btn-group pull-right">
                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                        <i class="icon-cog"></i><span class="caret"></span></a>
                                    <ul class="dropdown-menu pull-right">
                                        <li>
                                            <asp:HyperLink ID="linkDelete" runat="server" CssClass="iprice btn-link idelete"
                                                ToolTip="Delete Price Remarks"><i class="icon-trash"></i>Delete</asp:HyperLink>
                                        </li>
                                    </ul>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                    </Columns>
                </asp:DataGrid>
            </fieldset>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
        </div>
    </div>
    <!-- Delete Price Remarks -->
    <div id="requestDeletePriceRemarks" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Factory Price Remarks</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this factory price remarks?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnDeleteFactoryPriceRemarks" runat="server" class="btn btn-primary"
                data-loading-text="Deleting..." type="submit" onserverclick="btnDeleteFactoryPriceRemarks_Click">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <div id="dvProgress" class="modal transparent tiny hide fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="progress progress-striped active">
            <div class="bar" style="width: 0%;">
            </div>
        </div>
        <h5 class="progress-title">Generating Price List ...</h5>
        <button id="btnCancelDownload" class="btn iexceldownload" data-dismiss="modal" aria-hidden="true"
            type="button" value="Cancel" style="display: none;">
            No</button>
    </div>
    <!-- / -->
    <asp:Button ID="btnBostBack" runat="server" CssClass="hide hideOverly" OnClick="btnDownload_Click" />
    <!-- Page Scripts -->
    <script type="text/javascript">
        var populateAddEditNote = ('<%=ViewState["populateAddEditNote"]%>' == "True") ? true : false;
        var populateProgress = ('<%=ViewState["populateProgress"]%>' == "True") ? true : false;
        var PopulateViewNote = ('<%=ViewState["PopulateViewNote"]%>' == "True") ? true : false;
        var hdnSelectedID = "<%=hdnSelectedID.ClientID%>";
        var hdnPattern = "<%=hdnPattern.ClientID%>";
        var hdnFabric = "<%=hdnFabric.ClientID%>";
        var btnDelete = "<%=btnDelete.ClientID%>";
        var PriceID = "<%=PriceID.ClientID%>";
        var hdnFactoryPriceRemarks = "<%=hdnFactoryPriceRemarks.ClientID%>";
        var btnBostBack = "<%=btnBostBack.ClientID%>";
        var txtSearchAny = "<%=txtSearchAny.ClientID%>";
        var btnSearch = "<%=btnSearch.ClientID%>";
        var txtPattern = "<%=txtPattern.ClientID%>";
        var txtPatternNickName = "<%=txtPatternNickName.ClientID%>";
        var hdnFactoryPrice = "<%=hdnFactoryPrice.ClientID%>";        
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.iapply').click(function () {
                var cost = parseFloat($(this).prev('input.iapply-cost').val());
                /* $(this).prev('input.iapply-cost').val('');
                $('#' + $(this).attr('table') + ' span.idouble').each(function () {
                this.innerHTML = cost.toFixed(2);
                });*/

                $('#' + hdnFactoryPrice).val(isNaN(cost) ? '0' : cost.toFixed(2));
                $('#' + hdnPattern).val($(this).attr('pnumber') + "," + $(this).attr('nickname'));
                $('#' + hdnFabric).val($(this).attr('fname'));
            });
            $('.idelete').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                $('#requestDelete').modal('show');
            });
            $('.isave').click(function () {
                $('#' + hdnPattern).val($(this).attr('pnumber') + "," + $(this).attr('nickname'));
                $('#' + hdnFabric).val($(this).attr('fname'));
            });
            $('.iadd').click(function () {
                resetFieldsDefault('dvAddEditNote');
                $('div.alert-danger, span.error').hide();
                $('#' + PriceID).val($(this).attr('PriceID'));
                window.setTimeout(function () {
                    $('#dvAddEditNote').modal('show');
                }, 10);
            });

            $('.iprice').click(function () {
                $('#' + hdnFactoryPriceRemarks).val($(this).attr('pr'));
                $('#dvViewNote').modal('hide');
                $('#requestDeletePriceRemarks').modal('show');
            });

            if (PopulateViewNote) {
                window.setTimeout(function () {
                    $('#dvViewNote').modal('show');
                }, 10);
            }

            if (populateAddEditNote) {
                window.setTimeout(function () {
                    $('#dvAddEditNote').modal('show');
                }, 10);
            }

            if (populateProgress) {
                $('#dvProgress').modal('show');
                isPostBack();
            }

            $('#' + txtSearchAny).keypress(function (e) {
                if (e.which == 13) {
                    $('#' + btnSearch).click();
                }
            });

            $('#' + txtPattern).keypress(function (e) {
                if (e.which == 13) {
                    $('#' + btnSearch).click();
                }
            });

            $('#' + txtPatternNickName).keypress(function (e) {
                if (e.which == 13) {
                    $('#' + btnSearch).click();
                }
            });

        });

        var postbackTimer;
        function isPostBack() {
            postbackTimer = setInterval('postBack()', 1000);
        }

        function postBack() {
            $.ajax({
                type: 'POST',
                url: '/EditFactoryPrice.aspx/Progress',
                contentType: "application/json; charset=utf-8",
                data: '{UserID: 0}',
                dataType: 'json',
                error: function (xhr, ajaxOptions, thrownError) {
                    // alert('Status : ' + xhr.status + '\n Message : ' + xhr.statusText + '\n ex : ' + thrownError);
                },
                success: function (msg) {
                    if (Number(msg.d) == 100) {
                        window.setTimeout(function () {
                            click();
                        }, 1000);
                        clearInterval(postbackTimer);
                    }
                    else if (Number(msg.d) > 0) {
                        $('#dvProgress .progress .bar')[0].style.width = Number(msg.d) + '%';
                    }
                }
            });

            function click() {
                $('#' + btnBostBack).click();
                $('.iexceldownload').click();
            }
        }
    </script>
    <!-- / -->
</asp:Content>
