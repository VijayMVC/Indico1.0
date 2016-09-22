<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    EnableEventValidation="false" CodeBehind="EditIndimanPrice.aspx.cs" Inherits="Indico.EditIndimanPrice"
    MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnEmailAddresses" runat="server" class="btn btn-link pull-right" onserverclick="btnEmailAddresses_OnClick">E-Mail List</a>
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
                <div class="search-control clearfix">
                    <div class="pull-right">
                        <asp:DropDownList ID="ddlPriceTerm" runat="server">
                        </asp:DropDownList>
                        <asp:DropDownList ID="ddlExcelDistributor" runat="server">
                        </asp:DropDownList>
                        <button id="btndownloadExcel" runat="server" class="btn" type="submit" onserverclick="btndownloadExcel_Click">
                            Price Excel</button>
                    </div>
                </div>
                <fieldset>
                    <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                        <legend>Price Details</legend>
                        <div id="liDistributors" runat="server" class="control-group">
                            <label class="control-label">
                                Distributor</label>
                            <asp:DropDownList ID="ddlDistributors" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlDistributors_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                        <div class="control-group" style="display: none;">
                            <label class="control-label">
                                Search Any
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtSearchAny" runat="server"></asp:TextBox>
                            </div>
                        </div>
                        <div id="dvHide" runat="server">
                            <div class="control-group">
                                <label class="control-label">
                                    Pattern Number</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtPattern" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Pattern Nick Name
                                </label>
                                <div class="controls">
                                    <asp:TextBox ID="txtPatternNickName" runat="server">
                                    </asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Fabric Name:
                                </label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlFabricName" runat="server" CssClass="input-xlarge">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-actions">
                                <%-- <button id="btnSearch" runat="server" class="btn" onserverclick="btnSearch_Click"
                                    data-loading-text="Searching..." type="submit">
                                    Search</button>--%>
                                <asp:Button runat="server" ID="btnSearch" CssClass="btn" OnClick="btnSearch_Click" Text="Search" />
                            </div>
                        </div>
                    </asp:Panel>
                </fieldset>
                <!-- Fabric Seacrch -->
                <div id="dvSearchFabric" class="modal">
                    <!-- Empty Content -->
                    <div id="dvEmptyContentFabric" runat="server" class="alert alert-info">
                        <h4>
                            <a href="/ViewFabricCodes.aspx" title="Add a fabric.">Add the first fabric code.</a>
                        </h4>
                        <p>
                            You can add many fabric codes as you like.
                        </p>
                    </div>
                    <!-- / -->
                    <!-- Data Content -->
                    <div id="dvDataContentFabric" runat="server">
                        <!-- Search Control -->
                        <div class="search-control clearfix">
                            <asp:Panel ID="pnlSearchFabric" runat="server" DefaultButton="btnSearchFabric">
                                <asp:TextBox ID="txtSearchFabric" runat="server" CssClass="search-control-query"
                                    placeholder="Search"></asp:TextBox>
                                <asp:Button ID="btnSearchFabric" runat="server" CssClass="search-control-button"
                                    Text="Search" OnClick="btnSearchFabric_Click" />
                            </asp:Panel>
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                                &times;</button>
                        </div>
                        <!-- / -->
                        <!-- Data Table -->
                        <asp:DataGrid ID="dgFabrics" runat="server" CssClass="table" AllowCustomPaging="False"
                            AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                            PageSize="20" OnItemDataBound="dgFabrics_ItemDataBound" OnPageIndexChanged="dgFabrics_PageIndexChanged"
                            OnSortCommand="dgFabrics_SortCommand">
                            <HeaderStyle CssClass="header" />
                            <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                            <Columns>
                                <asp:BoundColumn DataField="Code" HeaderText="Code" SortExpression="Code"></asp:BoundColumn>
                                <asp:BoundColumn DataField="Name" HeaderText="Name" SortExpression="Name"></asp:BoundColumn>
                                <asp:BoundColumn DataField="Material" HeaderText="Material" SortExpression="Material"></asp:BoundColumn>
                                <asp:BoundColumn DataField="NickName" HeaderText="Nick Name" SortExpression="NickName"></asp:BoundColumn>
                                <asp:TemplateColumn HeaderText="Select">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnSelectFabric" runat="server" CssClass="btn-link iselect" OnClick="btnSelectFabric_Click">Select</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                            </Columns>
                        </asp:DataGrid>
                        <!-- / -->
                        <!-- No Search Result -->
                        <div id="dvNoSearchResultFabric" runat="server" class="message search" visible="false">
                            <h4>Your search - <strong>
                                <asp:Label ID="lblSerchKeyFabric" runat="server"></asp:Label></strong> - did
                                not match any orders.</h4>
                        </div>
                        <!-- / -->
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
                <div class="iaccess-bar iclearfix">
                    <button id="btnAddFabric" runat="server" class="btn btn-success pull-right" onclick="showPopupBox('dvSearchFabric', ($(window).width() * 0.9));"
                        type="button" visible="false">
                        Add Fabric Code
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
                    AutoGenerateColumns="false" GridLines="None" PageSize="25" OnItemDataBound="dgSelectedFabrics_ItemDataBound"
                    OnPageIndexChanged="dgSelectFabrics_PageIndexChange">
                    <HeaderStyle CssClass="header" />
                    <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                    <Columns>
                        <asp:TemplateColumn HeaderText="ID" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide">
                            <ItemTemplate>
                                <asp:Literal ID="litPrice" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Enable Price List" Visible="false">
                            <ItemTemplate>
                                <asp:CheckBox ID="chkEnablePriceList" runat="server" />
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Pattern Number">
                            <ItemTemplate>
                                <asp:Literal ID="lblPatternNumber" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Fabric Code">
                            <ItemTemplate>
                                <asp:Literal ID="lblFabricCode" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Nick Name">
                            <ItemTemplate>
                                <asp:Literal ID="lblNickName" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Price">
                            <ItemTemplate>
                                <ol id="olPriceTable" runat="server" class="ioderlist-table">
                                    <li class="idata-column iempty">
                                        <ul>
                                            <li class="icell-header">&nbsp;<em>&nbsp;</em></li>
                                            <li class="icell-data"><span>CIF Price</span></li>
                                            <li class="icell-data"><span>FOB Price</span></li>
                                            <%--<li class="icell-data"><span>MarkUp</span></li>
                                                <li class="icell-data"><span>CIF Cost</span></li>
                                                <li class="icell-data"><span>FOB Cost</span></li>--%>
                                        </ul>
                                    </li>
                                    <asp:Repeater ID="rptPriceLevelCost" runat="server" OnItemDataBound="rptPriceLevelCost_ItemDataBound">
                                        <ItemTemplate>
                                            <li class="idata-column">
                                                <ul>
                                                    <li class="icell-header">
                                                        <asp:Literal ID="litCellHeader" runat="server"></asp:Literal>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:HiddenField ID="hdnCellID" runat="server" Value="0"></asp:HiddenField>
                                                        <asp:TextBox ID="txtCIFPrice" runat="server" CssClass="idouble"></asp:TextBox>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:Label ID="lblFOBPrice" runat="server"></asp:Label>
                                                    </li>
                                                    <%--<li class="icell-data">
                                                            <asp:Label ID="lblMarkup" runat="server"></asp:Label>
                                                        </li>
                                                        <li class="icell-data">
                                                            <asp:Label ID="lblCIFCost" runat="server"></asp:Label>
                                                        </li>
                                                        <li class="icell-data">
                                                            <asp:Label ID="lblFOBCost" runat="server"></asp:Label>
                                                        </li>--%>
                                                </ul>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ol>
                                <div class="iaccess-controls" runat="server" id="dvSetCost">
                                    <label>
                                        <asp:Literal ID="litSetCost" runat="server"></asp:Literal></label>
                                    <input id="txtSetCost" runat="server" class="input-mini idouble iapply-cost" type="text" />
                                    <button id="btnApply" runat="server" class="btn iapply" type="button">
                                        Apply</button>
                                    <label>
                                        <asp:Literal ID="litConvesionFactor" runat="server"></asp:Literal></label>
                                    <asp:TextBox ID="txtConversionFactor" runat="server" CssClass="input-mini"></asp:TextBox>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Modified Date">
                            <ItemTemplate>
                                <asp:Literal ID="lblStatus" runat="server"></asp:Literal>
                                <asp:Literal ID="litModifiedDate" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="">
                            <ItemTemplate>
                                <div class="btn-group pull-right">
                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                        <i class="icon-cog"></i><span class="caret"></span></a>
                                    <ul class="dropdown-menu pull-right">
                                        <li>
                                            <asp:HyperLink ID="linkAddEditNote" runat="server" CssClass="btn-link iadd" CommandName="Add Price" ToolTip="Add Note"><i class="icon-plus"></i>Add Note</asp:HyperLink>
                                        </li>
                                        <li>
                                            <asp:LinkButton ID="btnViewNote" runat="server" OnClick="btnViewNote_Click" CssClass="btn-link inote" ToolTip="View Note" CommandName="View Note" Visible="false"><i class="icon-list-alt"></i>View  Note</asp:LinkButton></li>
                                        <li>
                                            <asp:LinkButton ID="btnUpdate" runat="server" CssClass="btn-link isave" CommandName="UpdatePrice" OnClick="btnUpdate_Click" ToolTip="Update Price"><i class="icon-edit"></i>Update</asp:LinkButton></li>
                                        <li>
                                            <asp:HyperLink ID="btnDelete" runat="server" CssClass="btn-link idelete" CommandName="Delete Price" ToolTip="Delete Price"><i class="icon-trash"></i>Delete</asp:HyperLink>
                                        </li>
                                        <li>
                                            <asp:LinkButton ID="btnSubmitIndico" runat="server" CssClass="btn-link isave" CommandName="SubmitIndico" OnClick="btnSubmitIndico_Click" ToolTip="">
                                                <i class="icon-edit"></i>
                                                <asp:Literal ID="litPriceStatus" runat="server"></asp:Literal>
                                            </asp:LinkButton></li>
                                        </li>
                                    </ul>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                    </Columns>
                </asp:DataGrid>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedPattern" runat="server" Value="0" />
    <asp:HiddenField ID="hdnPattern" runat="server" Value="0" />
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnPriceID" runat="server" />
    <asp:HiddenField ID="hdnPatternNumber" runat="server" Value="0" />
    <asp:HiddenField ID="hdnIndimanPriceRemarks" runat="server" Value="0" />
    <asp:HiddenField ID="hdnEmailAddressesTo" runat="server" Value="" />
    <asp:HiddenField ID="hdnEmailAddressesCC" runat="server" Value="" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Fabric Code Prices</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this fabic code prices?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" type="submit" onserverclick="btnDelete_Click">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- AddEdit Note -->
    <div id="dvAddEditNote" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
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
                No</button>
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
                    PageSize="10" OnItemDataBound="dgViewNote_ItemDataBound">
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
                        <asp:TemplateColumn HeaderText="">
                            <ItemTemplate>
                                <div class="btn-group pull-right">
                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                        <i class="icon-cog"></i><span class="caret"></span></a>
                                    <ul class="dropdown-menu pull-right">
                                        <li>
                                            <asp:HyperLink ID="btnDelete" runat="server" CssClass="iprice btn-link idelete" ToolTip="Delete Price Remarks"><i class="icon-trash"></i>Delete</asp:HyperLink>
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
    <!-- / -->
    <!-- Delete Price Remarks -->
    <div id="requestDeletePriceRemarks" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Indiman Price Remarks</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this indiman price remarks?
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDeleteIndimanPriceRemarks" runat="server" class="btn btn-primary"
                type="submit" onserverclick="btnDeleteIndimanPriceRemarks_Click" data-loading-text="Deleting...">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- AddEdit Emails -->
    <div id="dvEmailAddresses" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Email Addresses
            </h3>
        </div>
        <div class="modal-body">
            <h5>To List</h5>
            <div class="stack-wrapper">
                <asp:ListBox ID="lstBoxToNewUsers" runat="server" CssClass="pull-right"></asp:ListBox>
                <div class="pull-right">
                    <button id="Tonext" class="btn" type="button">
                        ></button>
                    <button id="Toback" class="btn" type="button">
                        <</button>
                    <button id="toNextAll" class="btn" type="button">
                        >></button>
                    <button id="toBackAll" class="btn" type="button">
                        <<</button>
                </div>
                <asp:ListBox ID="lstBoxToExistUsers" runat="server"></asp:ListBox>
            </div>
            <h5>CC List</h5>
            <div class="stack-wrapper">
                <asp:ListBox ID="lstBoxCccNewUsers" runat="server" CssClass="pull-right"></asp:ListBox>
                <div class="pull-right">
                    <button id="ccnext" class="btn" type="button">
                        ></button>
                    <button id="ccback" class="btn" type="button">
                        <</button>
                    <button id="ccNextAll" class="btn" type="button">
                        >></button>
                    <button id="ccBackAll" class="btn" type="button">
                        <<</button>
                </div>
                <asp:ListBox ID="lstBoxCcExistUsers" runat="server"></asp:ListBox>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveEmailAddresses" runat="server" class="btn btn-primary isend" onserverclick="btnSaveEmailAddresses_OnClick"
                data-loading-text="Saving...">
                Save Changes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Progressbar -->
    <div id="dvProgress" class="modal transparent tiny" keyboard="false" data-backdrop="static">
        <div class="modal-body">
            <div class="progress progress-striped active">
                <div class="bar" style="width: 0%;">
                </div>
            </div>
            <h5 class="progress-title">Generating Price List ...</h5>
        </div>
        <button id="btnCancelDownload" class="iexceldownload" data-dismiss="modal" aria-hidden="true"
            style="display: none;">
            No</button>
    </div>
    <!-- / -->
    <asp:Button ID="btnBostBack" runat="server" Style="visibility: hidden;" OnClick="btnDownload_Click" />
    <!-- Page Scripts -->
    <script type="text/javascript">
        var PopulatePatern = ('<%=ViewState["PopulatePatern"]%>' == "True") ? true : false;
        var populateProgress = ('<%=ViewState["populateProgress"]%>' == "True") ? true : false;
        var PopulateFabric = ('<%=ViewState["PopulateFabric"]%>' == "True") ? true : false;
        var PopulateViewNote = ('<%=ViewState["PopulateViewNote"]%>' == "True") ? true : false;
        var PopulateAddEditNote = ('<%=ViewState["PopulateAddEditNote"]%>' == "True") ? true : false;
        var PopulateEmailAddress = ('<%=ViewState["PopulateEmailAddress"]%>' == "True") ? true : false;
        var lstBoxToExistUsers = "<%=lstBoxToExistUsers.ClientID%>";
        var lstBoxToNewUsers = "<%=lstBoxToNewUsers.ClientID%>";
        var lstBoxCcExistUsers = "<%=lstBoxCcExistUsers.ClientID%>";
        var lstBoxCccNewUsers = "<%=lstBoxCccNewUsers.ClientID%>";
        var hdnEmailAddressesTo = "<%=hdnEmailAddressesTo.ClientID%>";
        var hdnEmailAddressesCC = "<%=hdnEmailAddressesCC.ClientID%>";
        var hdnSelectedID = "<%=hdnSelectedID.ClientID%>";
        var btnDelete = "<%=btnDelete.ClientID%>";
        var hdnPattern = "<%=hdnPattern.ClientID%>";
        var hdnPriceID = "<%=hdnPriceID.ClientID%>";
        var hdnPatternNumber = "<%=hdnPatternNumber.ClientID%>";
        var hdnIndimanPriceRemarks = "<%=hdnIndimanPriceRemarks.ClientID%>";
        var txtSearchAny = "<%=txtSearchAny.ClientID%>";
        var btnSearch = "<%=btnSearch.ClientID%>";
        var btnBostBack = "<%=btnBostBack.ClientID%>";
        var btndownloadExcel = "<%=btndownloadExcel.ClientID%>";
        var ddlFabricName = "<%=ddlFabricName.ClientID%>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#' + ddlFabricName).select2();

            $('.iapply').click(function () {
                var cost = parseFloat($(this).prev('input.iapply-cost').val());
                $(this).prev('input.iapply-cost').val('');
                $('#' + $(this).attr('table') + ' input.idouble').val(cost.toFixed(2));
            });
            $('.idelete').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                $('#' + hdnPattern).val($(this).attr('pid'));
                $('#requestDelete').modal('show');
            });
            $('.iprice').click(function () {
                $('#' + hdnIndimanPriceRemarks).val($(this).attr('imrid'));
                $('#dvViewNote').modal('hide');
                $('#requestDeletePriceRemarks').modal('show');
            });
            $('.iadd').click(function () {
                resetFieldsDefault('dvAddEditNote');
                $('div.ivalidator, span.error').hide();
                $('#' + hdnPriceID).val($(this).attr('PriceID'));
                window.setTimeout(function () {
                    $('#dvAddEditNote').modal('show');
                }, 10);
            });
            if (PopulatePatern) {
                window.setTimeout(function () {
                    $('#dvSearchPattern').modal('show');
                }, 10);
            }
            if (PopulateFabric) {
                window.setTimeout(function () {
                    $('#dvSearchFabric').modal('show');
                }, 10);
            }
            if (PopulateViewNote) {
                window.setTimeout(function () {
                    $('#dvViewNote').modal('show');
                }, 10);
            }
            if (PopulateAddEditNote) {
                window.setTimeout(function () {
                    $('#dvAddEditNote').modal('show');
                }, 10);
            }
            $('.isave').click(function () {
                $('#' + hdnSelectedID).val($(this).attr("fname"));
                $('#' + hdnPatternNumber).val($(this).attr("pnumber") + "," + $(this).attr("pnickname"));
            });

            /* $('.imail').click(function () {
            resetFieldsDefault('dvEmailAddresses');
            showPopupBox('dvEmailAddresses', ($(window).width() * 0.6));
            });*/

            if (PopulateEmailAddress) {
                resetFieldsDefault('dvEmailAddresses');
                $('#dvEmailAddresses').modal('show');
            }


            $('.isend').click(function () {
                var selectedVal = '';
                var selectedValCC = '';
                $('#' + hdnEmailAddressesTo).val('');
                $('#' + hdnEmailAddressesCC).val('');

                $('#' + lstBoxToNewUsers).find('option').each(function () {
                    selectedVal += $(this).val() + ','
                    $('#' + hdnEmailAddressesTo).val(selectedVal);
                });
                $('#' + lstBoxCccNewUsers).find('option').each(function () {
                    selectedValCC += $(this).val() + ','
                    $('#' + hdnEmailAddressesCC).val(selectedValCC);
                });
            });


            $('#Tonext').click(function () {
                /*if ($('#' + lstBoxToExistUsers).find('option:selected').val() != undefined) {
                selectedVal += $('#' + lstBoxToExistUsers).find('option:selected').val() + ',';
                }               
                $('#' + hdnEmailAddressesTo).val(selectedVal);*/
                $('#' + lstBoxToExistUsers).find('option:selected').appendTo($('#' + lstBoxToNewUsers));
            });
            $('#Toback').click(function () {
                /* selectedVal = selectedVal.split(',');
                selectedVal.splice(selectedVal.valueOf($('#' + lstBoxToNewUsers).find('option:selected').index()), 1)
                $('#' + hdnEmailAddressesTo).val(selectedVal.join(','));*/
                $('#' + lstBoxToNewUsers).find('option:selected').appendTo($('#' + lstBoxToExistUsers));
            });
            $('#toNextAll').click(function () {
                //  selectedVal = '';
                /*  $('#' + lstBoxToExistUsers).find('option').each(function () {
                selectedVal += $(this).val() + ','
                $('#' + hdnEmailAddressesTo).val(selectedVal);
                });*/
                $('#' + lstBoxToExistUsers).find('option').appendTo($('#' + lstBoxToNewUsers));
            });
            $('#toBackAll').click(function () {
                $('#' + hdnEmailAddressesTo).val('');
                $('#' + lstBoxToNewUsers).find('option').appendTo($('#' + lstBoxToExistUsers));
            });

            $('#ccnext').click(function () {
                /*  if ($('#' + lstBoxCcExistUsers).find('option:selected').val() != undefined) {
                selectedValCC += $('#' + lstBoxCcExistUsers).find('option:selected').val() + ',';
                }
                $('#' + hdnEmailAddressesCC).val(selectedValCC);*/
                $('#' + lstBoxCcExistUsers).find('option:selected').appendTo($('#' + lstBoxCccNewUsers));
            });
            $('#ccback').click(function () {
                /* selectedValCC = selectedValCC.split(',');
                selectedValCC.splice(selectedValCC.valueOf($('#' + lstBoxCccNewUsers).find('option:selected').index()), 1)
                $('#' + hdnEmailAddressesCC).val(selectedValCC.join(','));*/
                $('#' + lstBoxCccNewUsers).find('option:selected').appendTo($('#' + lstBoxCcExistUsers));
            });
            $('#ccNextAll').click(function () {
                /* selectedValCC = '';
                $('#' + lstBoxCcExistUsers).find('option').each(function () {
                selectedValCC += $(this).val() + ','
                $('#' + hdnEmailAddressesCC).val(selectedValCC);
                });*/
                $('#' + lstBoxCcExistUsers).find('option').appendTo($('#' + lstBoxCccNewUsers));
            });
            $('#ccBackAll').click(function () {
                $('#' + hdnEmailAddressesCC).val('');
                $('#' + lstBoxCccNewUsers).find('option').appendTo($('#' + lstBoxCcExistUsers));
            });

            $('#' + txtSearchAny).keypress(function (e) {
                if (e.which == 13) {
                    $('#' + btnSearch).click();
                    //$('#dvProgress').modal('hide');
                    $('#' + btndownloadExcel).prop('disabled', true);
                }
            });

            $(window).keyup(function (e) {
                if (e.keyCode == 13) {
                    $('#' + btnSearch).click();
                    // $('#dvProgress').modal('hide');
                    $('#' + btndownloadExcel).prop('disabled', true);
                }
            });

            if (populateProgress) {
                $('#dvProgress').modal('show');
                isPostBack();
            }
        });

        var postbackTimer;

        function isPostBack() {
            postbackTimer = setInterval('postBack()', 1000);
        }

        function postBack() {
            $.ajax({
                type: 'POST',
                url: '/EditIndimanPrice.aspx/Progress',
                contentType: "application/json; charset=utf-8",
                data: '{UserID: 0}',
                dataType: 'json',
                error: function (xhr, ajaxOptions, thrownError) {
                    // alert('Status : ' + xhr.status + '\n Message : ' + xhr.statusText + '\n ex : ' + thrownError);
                },
                success: function (msg) {
                    if (Number(msg.d) == 100) {
                        window.setTimeout(function () {
                            Download();
                        }, 2000);
                        clearInterval(postbackTimer);
                    }
                    else if (Number(msg.d) > 0) {
                        $('#dvProgress .progress .bar')[0].style.width = Number(msg.d) + '%';
                    }
                }
            });
        }

        function Download() {
            $('#' + btnBostBack).click();
            $('.iexceldownload').click();
        }
    </script>
    <!-- / -->
</asp:Content>
