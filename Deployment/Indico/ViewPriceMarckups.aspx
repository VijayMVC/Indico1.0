<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewPriceMarckups.aspx.cs" Inherits="Indico.ViewPriceMarckups" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddPriceMarckup" runat="server" class="btn btn-link iadd pull-right" qid="0">
                    Add Price Markup</a> <a id="btnClonePriceMarkup" runat="server" class="btn btn-link iclone pull-right">
                        Clone Price Markup</a>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h4>
                        <a class="iadd" href="javascript:void(0);" qid="0" title="Add an item.">Add the first
                            price level.</a>
                    </h4>
                    <p>
                        You can add many price levels as you like.</p>
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
                    </div>
                    <!-- / -->
                    <!-- Data Table -->
                    <div class="accordion-group">
                        <div class="accordion-heading">
                            <a class="accordion-toggle" data-toggle="collapse" href="#collapse1">Distributor Price
                                Markups</a>
                        </div>
                        <div id="collapse1" class="accordion-body collapse in">
                            <div class="accordion-inner">
                                <asp:DataGrid ID="dgPriceMarckups" runat="server" CssClass="table" AllowCustomPaging="False"
                                    AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                                    PageSize="20" OnItemDataBound="dgPriceMarckups_ItemDataBound" OnPageIndexChanged="dgPriceMarckups_PageIndexChanged"
                                    OnSortCommand="dgPriceMarckups_SortCommand">
                                    <HeaderStyle CssClass="header" />
                                    
                                    
                                    <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                                    <Columns>
                                        <asp:TemplateColumn HeaderText="Distributor" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide">
                                            <ItemTemplate>
                                                <asp:Literal ID="litDistributor" runat="server"></asp:Literal>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                        <asp:TemplateColumn HeaderText="Distributor">
                                            <ItemTemplate>
                                                <asp:Literal ID="lblDistributor" runat="server"></asp:Literal>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                        <asp:TemplateColumn HeaderText="Price Level">
                                            <ItemTemplate>
                                                <ol class="ioderlist-table">
                                                    <asp:Repeater ID="rptDistributorPriceLevels" runat="server" OnItemDataBound="rptPriceLevels_ItemDataBound">
                                                        <ItemTemplate>
                                                            <li class="idata-column">
                                                                <ul>
                                                                    <li class="icell-header">
                                                                        <asp:Literal ID="litCellHeader" runat="server"></asp:Literal>
                                                                    </li>
                                                                    <li class="icell-data">
                                                                        <asp:HiddenField ID="hdnCellID" runat="server" Value="0"></asp:HiddenField>
                                                                        <asp:Label ID="lblCellData" runat="server"></asp:Label>
                                                                    </li>
                                                                </ul>
                                                            </li>
                                                        </ItemTemplate>
                                                    </asp:Repeater>
                                                </ol>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                        <asp:TemplateColumn HeaderText="">
                                            <ItemTemplate>
                                                <div class="btn-group pull-right">
                                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                        <i class="icon-cog"></i><span class="caret"></span></a>
                                                    <ul class="dropdown-menu pull-right">
                                                        <li>
                                                            <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                                        </li>
                                                        <li>
                                                            <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete"><i class="icon-trash"></i>Delete</asp:HyperLink>
                                                        </li>
                                                    </ul>
                                                </div>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                    </Columns>
                                </asp:DataGrid>
                                <!-- / -->
                                <!-- No Search Result -->
                                <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                                    <h4>
                                        Your search - <strong>
                                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                                        any distributor price markups.</h4>
                                </div>
                                <div id="dvEmptyDistributor" runat="server" class="alert alert-info" visible="false">
                                    <h4>
                                        No Distributor Price Markups Found
                                    </h4>
                                    <p>
                                        You can add many distributor price markups as you like.</p>
                                </div>
                                <!-- / -->
                            </div>
                        </div>
                    </div>
                    <div class="accordion-group">
                        <div class="accordion-heading">
                            <a class="accordion-toggle" data-toggle="collapse" href="#collapse2">Label Price Markups</a>
                        </div>
                        <div id="collapse2" class="accordion-body collapse">
                            <div class="accordion-inner">
                                <asp:DataGrid ID="dgLabelPriceMarckups" runat="server" CssClass="table" AllowCustomPaging="False"
                                    AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                                    PageSize="20" OnItemDataBound="dgLabelPriceMarckups_ItemDataBound" OnPageIndexChanged="dgLabelPriceMarckups_PageIndexChanged"
                                    OnSortCommand="dgPriceMarckupsLabel_SortCommand">
                                    <HeaderStyle CssClass="header" />
                                    
                                    
                                    <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                                    <Columns>
                                        <asp:TemplateColumn HeaderText="Distributor" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide">
                                            <ItemTemplate>
                                                <asp:Literal ID="litLabel" runat="server"></asp:Literal>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                        <asp:TemplateColumn HeaderText="Label">
                                            <ItemTemplate>
                                                <asp:Literal ID="lblLabel" runat="server"></asp:Literal>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                        <asp:TemplateColumn HeaderText="Price Level">
                                            <ItemTemplate>
                                                <ol class="ioderlist-table">
                                                    <asp:Repeater ID="rptLabelPriceLevels" runat="server" OnItemDataBound="rptLabelPriceLevels_ItemDataBound">
                                                        <ItemTemplate>
                                                            <li class="idata-column">
                                                                <ul>
                                                                    <li class="icell-header">
                                                                        <asp:Literal ID="litLabelCellHeader" runat="server"></asp:Literal>
                                                                    </li>
                                                                    <li class="icell-data">
                                                                        <asp:HiddenField ID="hdnCellID" runat="server" Value="0"></asp:HiddenField>
                                                                        <asp:Label ID="lblLabelCellData" runat="server"></asp:Label>
                                                                    </li>
                                                                </ul>
                                                            </li>
                                                        </ItemTemplate>
                                                    </asp:Repeater>
                                                </ol>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                        <asp:TemplateColumn HeaderText="">
                                            <ItemTemplate>
                                                <div class="btn-group pull-right">
                                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                        <i class="icon-cog"></i><span class="caret"></span></a>
                                                    <ul class="dropdown-menu pull-right">
                                                        <li>
                                                            <asp:HyperLink ID="linkLabelEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Price Markups"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                                        </li>
                                                        <li>
                                                            <asp:HyperLink ID="linkLabelDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Price Markups"><i class="icon-trash" ></i>Delete</asp:HyperLink>
                                                        </li>
                                                    </ul>
                                                </div>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                    </Columns>
                                </asp:DataGrid>
                                <!-- / -->
                                <!-- No Search Result -->
                                <div id="dvNoSearchResultLabel" runat="server" class="message search" visible="false">
                                    <h4>
                                        Your search - <strong>
                                            <asp:Label ID="lblLabelSerchKey" runat="server"></asp:Label></strong> - did
                                        not match any labes.</h4>
                                </div>
                                <div id="dvEmptyLabel" runat="server" class="alert alert-info" visible="false">
                                    <h4>
                                        No Label Price Markups Found
                                    </h4>
                                    <p>
                                        You can add many label price markups as you like.</p>
                                </div>
                                <!-- / -->
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- / -->
        </div>
    </div>
    <!-- / -->
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnType" runat="server" Value="0" />
    <!-- Add Order Popup -->
    <div id="requestAddEdit" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblPopupHeaderText" runat="server"></asp:Label></h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <!-- Popup Validation -->
            <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                ValidationGroup="vgPriceMarckup" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>">
            </asp:ValidationSummary>
            <!-- / -->
            <fieldset>
                <div class="control-group">
                    <label class="control-label required">
                        Distributor
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlDistributors" runat="server">
                        </asp:DropDownList>
                        <asp:Label ID="lblDisitributor" runat="server" />
                    </div>
                </div>
                <div class="control-group">
                    <ol id="olPriceLevels" class="ioderlist-table">
                        <asp:Repeater ID="rptPriceLevels" runat="server" OnItemDataBound="rptPriceLevels_ItemDataBound">
                            <ItemTemplate>
                                <li class="idata-column">
                                    <ul>
                                        <li class="icell-header">
                                            <asp:Literal ID="litCellHeader" runat="server"></asp:Literal>
                                        </li>
                                        <li class="icell-data">
                                            <asp:HiddenField ID="hdnCellID" runat="server" Value="0"></asp:HiddenField>
                                            <asp:TextBox ID="txtCellData" runat="server" CssClass="input-mini"></asp:TextBox>
                                        </li>
                                    </ul>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ol>
                </div>
            </fieldset>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close
            </button>
            <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_Click"
                data-loading-text="Saving..." type="submit" validationgroup="vgPriceMarckup">
                Save Changes</button>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                Delete Price Marckup</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Price Marckup?</p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" type="submit" onserverclick="btnDelete_Click"
                data-loading-text="Deleting...">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdndistributor" runat="server" Value="0" />
    <!-- Empty Distributor -->
    <div id="checkDistributor" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                No New Distributors</h3>
        </div>
        <div class="modal-body">
            <p>
                All distributors are currently added to the list</p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
        </div>
    </div>
    <!-- / -->
    <!-- Clone Price Markup-->
    <div id="requestClonePriceMarkup" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                Clone Price Marckup</h3>
        </div>
        <div class="modal-body">
            <asp:ValidationSummary ID="ClonevalidationSummary" runat="server" CssClass="alert alert-danger"
                DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>">
            </asp:ValidationSummary>
            <div class="control-group">
                <label class="control-label">
                    Existing Price Markup
                </label>
                <div class="controls">
                    <asp:DropDownList ID="ddlExistDistributors" runat="server">
                    </asp:DropDownList>
                </div>
            </div>
            <div class="control-group">
                <div class="controls">
                    <label class="checkbox inline">
                        <asp:RadioButton ID="rbDistributor" runat="server" GroupName="clone" Checked="true" />
                        Distributor
                    </label>
                    <label class="checkbox inline">
                        <asp:RadioButton ID="rbLabel" runat="server" GroupName="clone" />
                        Label
                    </label>
                </div>
            </div>
            <div class="idistributor" style="display: block">
                <label class="control-label">
                    New Price Markup
                </label>
                <div class="controls">
                    <asp:DropDownList ID="ddlNewDistributors" runat="server">
                    </asp:DropDownList>
                </div>
            </div>
            <div class="ilabel" style="display: none">
                <label class="control-label">
                    New Price Markup Label
                </label>
                <div class="controls">
                    <asp:TextBox ID="txtMarkupLabel" runat="server"></asp:TextBox>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveClonePriceMarkup" runat="server" class="btn btn-primary" type="submit"
                onserverclick="btnSaveClonePriceMarkup_Click" istype="distributor" data-loading-text="Creating...">
                Create Markup</button>
            <button id="btnSaveClonePriceMarkupLabel" runat="server" class="btn btn-primary"
                data-loading-text="Creating..." type="submit" onserverclick="btnSaveClonePriceMarkupLabel_Click"
                style="display: none;">
                Create Markup</button>
        </div>
    </div>
    <!-- / -->
    <!-- Page
    Scripts -->
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var ClonePriceMarkup = ('<%=ViewState["ClonePriceMarkup"]%>' == 'True') ? true : false;
        var hdnSelectedID = "<%=hdnSelectedID.ClientID%>";
        var hdndistributor = "<%=hdndistributor.ClientID%>";
        var lblDisitributor = "<%=lblDisitributor.ClientID%>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID%>";
        var dgPriceMarckups = "<%=dgPriceMarckups.ClientID%>";
        var btnDelete = "<%=btnDelete.ClientID%>";
        var ddlDistributors = "<%=ddlDistributors.ClientID%>";
        var rbDistributor = "<%=rbDistributor.ClientID%>";
        var rbLabel = "<%=rbLabel.ClientID%>";
        var btnSaveClonePriceMarkup = "<%=btnSaveClonePriceMarkup.ClientID%>";
        var btnSaveClonePriceMarkupLabel = "<%=btnSaveClonePriceMarkupLabel.ClientID%>"; var hdnType = "<%=hdnType.ClientID%>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.iadd').click(function () {
                var items = $('#' + ddlDistributors).children().length;
                if (items < 1) {
                    $('#checkDistributor').modal('show');
                }
                else {
                    resetFieldsDefault('requestAddEdit');
                    itemAddEdit(this, true);

                }
            });

            $('.iedit').click(function () {
                $('#' + hdnType)[0].value = $(this).attr('isType');
                fillFieldsData(this); itemAddEdit(this, false);
            });

            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                $('#' + hdnType)[0].value = $(this).attr('isType');
                $('#requestDelete').modal('show');
            });

            if (!IsPageValid) {
                window.setTimeout(function () {
                    $('#requestAddEdit').modal('show');
                }, 10);
            }

            $('.iclone').click(function () {
                $('div.ivalidator').hide();
                resetFieldsDefault('replaceCoordinator');
                $('#requestClonePriceMarkup').modal('show');
            });

            if (ClonePriceMarkup) {
                window.setTimeout(function () {
                    $('#requestClonePriceMarkup').modal('show');
                }, 10);
            }
            function itemAddEdit(o, n) {
                $('div.alert-danger, span.error').hide();
                $('#requestAddEdit div.modal-header h3 span')[0].innerHTML = (n ? 'Add Price Marckup' : 'Edit Price Marckup');
                if (n) {
                    $('#' + lblDisitributor).hide();
                    $('#' + ddlDistributors).show();
                    $('#' + hdndistributor).val(false);
                    resetFieldsDefault('requestAddEdit');
                }
                else {
                    $('#' + hdnSelectedID).val(n ? '0' : $(o).attr('qid'));
                    $('#' + lblDisitributor).show();
                    $('#' + ddlDistributors).hide();
                    $('#' + hdndistributor).val(true);
                    $('#' + lblDisitributor).text($(o).parents('tr').children('td')[1].innerHTML.trim());
                }
                $('#' + btnSaveChanges)[0].innerHTML = (n) ? 'Save Changes' : 'Update';
                $('#requestAddEdit').modal('show');
            }



            function fillFieldsData(o) {
                $('tr.irow_' + $(o).attr('qid') + ' ol li.icell-data').each(function () {
                    var dpm = $(this).children('input[type=hidden]')[0].value; var mup = $(this).children('span')[0].innerHTML.trim();
                    var plv = $(this).children('span').attr('qid');
                    $('#olPriceLevels li input[type=text].level' + plv).prev('input[type=hidden]')[0].value = dpm;
                    $('#olPriceLevels li input[type=text].level' + plv).val(mup);
                });
            }
            $('#' + rbDistributor).click(function () {
                $('.idistributor').show();
                $('.ilabel').hide();
                $('#' + btnSaveClonePriceMarkup).show(); $('#' + btnSaveClonePriceMarkupLabel).hide();
            });

            $('#' + rbLabel).click(function () {
                $('.ilabel').show();
                $('.idistributor').hide();
                $('#' + btnSaveClonePriceMarkupLabel).show(); $('#' + btnSaveClonePriceMarkup).hide();
            });
        });
    </script>
    <!-- / -->
</asp:Content>
