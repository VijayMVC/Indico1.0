<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="EditIndicoPrice.aspx.cs" Inherits="Indico.EditIndicoPrice" MaintainScrollPositionOnPostback="true"
    EnableViewState="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <asp:ScriptManager ID="myScriptManager" runat="server">
    </asp:ScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <asp:HyperLink ID="linkExcel" runat="server" CssClass="btn btn-link pull-right" Text="Import Excel" />
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
                    ValidationGroup="vgSearchPattern" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <fieldset>
                    <legend>Price Details</legend>
                    <!-- Distributor -->
                    <div class="control-group">
                        <label class="control-label">
                            Distributor</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlDistributors" runat="server" AutoPostBack="false">
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Search Any</label>
                        <div class="controls">
                            <asp:TextBox ID="txtSearchAny" runat="server" CssClass="isearchany" Enabled="true"></asp:TextBox>
                            <button id="btnSearchByCategory" runat="server" class="btn" onserverclick="btnSearchByCategory_Click"
                                data-loading-text="Searching..." type="submit" validationgroup="vgSearchPattern">
                                Search
                            </button>
                            <span style="display: inline-block; width: 30px;">&nbsp;</span>
                            <button id="btnResetSearchAny" runat="server" class="btn btn-primary" onserverclick="btnReset_Click"
                                data-loading-text="Reseting..." type="submit">
                                Reset
                            </button>
                        </div>
                    </div>
                    <!-- / -->
                    <!-- Pattern -->
                    <div class="control-group">
                        <div class="controls radio inline">
                            <asp:RadioButton ID="rbCifPrice" runat="server" GroupName="price" OnCheckedChanged="checkPrice_Check"
                                AutoPostBack="true" Checked="true" />
                            CIF Price
                        </div>
                        <div class="controls radio inline">
                            <asp:RadioButton ID="rbFobPrice" runat="server" GroupName="price" OnCheckedChanged="checkPrice_Check"
                                AutoPostBack="true" Text />
                            FOB Price
                        </div>
                    </div>
                    <div id="dvHide" runat="server">
                        <div>
                            <label>
                                Search Pattern Number
                            </label>
                            <asp:TextBox ID="txtSerchPatternNumber" runat="server" Text="" />
                            <asp:Button ID="btnSearchPatternNumber" CssClass="btn" runat="server" Text="Search"
                                OnClick="btnSearchByPatternNumber_Click" />
                            <asp:Button ID="btnReset" runat="server" CssClass="btn btn-primary pull-right" OnClick="btnReset_Click"
                                Text="Reset" />
                        </div>
                        <div>
                            <label>
                                Pattern Number</label>
                            <asp:TextBox ID="txtPattern" runat="server" Enabled="true"></asp:TextBox>
                            <asp:HiddenField ID="hdnSelectPattern" runat="server" Value="0" />
                            <asp:CustomValidator ID="cvPattern" runat="server" Display="Dynamic" EnableClientScript="false"
                                ErrorMessage="Invalid Pattern" ValidationGroup="vgSearchPattern">
                            <img src="Content/img/icon_warning.png"  title="Company  is required" alt="Company  is required" />
                            </asp:CustomValidator>
                        </div>
                        <div>
                            <label>
                                Pattern Nick Name</label>
                            <asp:TextBox ID="txtPatternNickName" runat="server"></asp:TextBox>
                        </div>
                        <!-- Remarks -->
                        <div>
                            <label>
                                Fabric Name</label>
                            <asp:DropDownList ID="ddlFabricName" runat="server" AutoPostBack="false">
                            </asp:DropDownList>
                        </div>
                    </div>
                    <!-- / -->
                </fieldset>
                <fieldset>
                    <legend>Sports Categories </legend>
                    <asp:CheckBoxList ID="lstOtherCategories" runat="server" CssClass="checkbox-columns vertical"
                        RepeatDirection="Vertical">
                    </asp:CheckBoxList>
                </fieldset>
                <div id="dvFormActions" runat="server" class="form-actions" visible="false">
                    <%--<asp:Button ID="btnUpdatePrice" runat="server" Text="Update" CssClass="btn" OnClick="btnUpdatePrice_Click" />--%>
                    <asp:Button ID="btnChangeCifFob" runat="server" Text="Show FOB Pricing" CssClass="btn"
                        OnClick="btnChangeCifFob_Click" Style="display: none" />
                </div>
                <div id="dvSelectedCategories" runat="server" visible="false">
                    <!-- Empty Content -->
                    <div id="dvEmptyContent" runat="server" class="alert alert-info" visible="false">
                        <h4>
                            <asp:Label ID="lblEmptyMessage" runat="server" Text="There are no prices to be shown"></asp:Label>
                        </h4>
                        <p>
                            <asp:Label ID="lblEmptyDescription" runat="server" Text="To narrow down the search please select sports category."></asp:Label>
                        </p>
                    </div>
                    <!-- / -->
                    <asp:Repeater ID="rptSportCategory" runat="server" OnItemDataBound="rptSportCategory_ItemDataBound">
                        <ItemTemplate>
                            <h3 id="h3SportCatogoryName" runat="server" visible="false"></h3>
                            <asp:DataGrid ID="dgSelectedFabrics" runat="server" CssClass="table" AllowCustomPaging="False"
                                AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                                PageSize="1000" OnItemDataBound="dgSelectedFabrics_ItemDataBound">
                                <HeaderStyle CssClass="header" />
                                <Columns>
                                    <asp:TemplateColumn>
                                        <ItemTemplate>
                                            <asp:CheckBox ID="checkEnablePriceList" runat="server" CssClass="iactiveplist" />
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Other Categories">
                                        <ItemTemplate>
                                            <asp:Literal ID="litOtherCategories" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Number">
                                        <ItemTemplate>
                                            <asp:Literal ID="litPatternNo" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Sub Category">
                                        <ItemTemplate>
                                            <asp:Literal ID="litItemSubCategory" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Description">
                                        <ItemTemplate>
                                            <asp:Literal ID="litDescription" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Fabric">
                                        <ItemTemplate>
                                            <asp:Literal ID="litfabric" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Levels">
                                        <ItemTemplate>
                                            <ol id="olPriceTable" runat="server" class="ioderlist-table">
                                                <asp:Repeater ID="rptPriceLevelCost" runat="server" OnItemDataBound="rptPriceLevelCost_ItemDataBound">
                                                    <ItemTemplate>
                                                        <li class="idata-column">
                                                            <ul id="ulPrice">
                                                                <li class="icell-header">
                                                                    <asp:Literal ID="litCellHeader" runat="server"></asp:Literal>
                                                                </li>
                                                                <li class="icell-data icell-split iprice-indico-cif">
                                                                    <asp:HiddenField ID="hdnCellID" runat="server" Value="0"></asp:HiddenField>
                                                                    <asp:TextBox ID="txtEditedIndicoCIFPrice" runat="server" CssClass="idouble"></asp:TextBox>
                                                                    <asp:Label ID="lblEditedIndicoCIFMarkup" runat="server" CssClass="indico-markup-cif-fob"></asp:Label>
                                                                </li>
                                                                <li class="icell-data icell-split iprice-indiman-cif">
                                                                    <asp:Label ID="lblCalculatedIndimanCIFPrice" runat="server" class="indiman-price-cif-fob"></asp:Label>
                                                                    <asp:Label ID="lblCalculatedIndimanCIFMarkup" runat="server" CssClass="indiman-markup-cif-fob"></asp:Label>
                                                                </li>
                                                                <%--<li class="icell-data icell-split iprice-indico-fob">
                                                                    <asp:Label ID="lblIndicoFOBPrice" runat="server"></asp:Label>
                                                                    <asp:Label ID="lblIndicoFOBMarkup" runat="server"></asp:Label>
                                                                </li>
                                                                <li class="icell-data icell-split iprice-indiman-fob">
                                                                    <asp:Label ID="lblIndimanFOBPrice" runat="server"></asp:Label>
                                                                    <asp:Label ID="lblIndimanFOBMarkup" runat="server"></asp:Label>
                                                                </li>--%>
                                                                <li class="icell-data indiman-price">
                                                                    <asp:Label ID="lblIndimanPrice" runat="server"></asp:Label>
                                                                </li>
                                                            </ul>
                                                        </li>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </ol>
                                            <%--<div class="iaccess-bar iclearfix" style="margin-top: 9px;">
                                                <label class="pull-left" style="font-weight: 600; width: auto;">
                                                    <asp:Literal ID="litSetCost" runat="server"></asp:Literal>
                                                </label>
                                                <input id="txtSetCost" runat="server" class="idouble iapply-cost" style="width: 74px"
                                                    type="text" />
                                                <button id="btnApply" runat="server" class="btn pull-left iapply" type="button">
                                                    Apply
                                                </button>
                                                <button class="btn pull-left itoggle" style="margin-left: 10px;" type="button">
                                                    FOB
                                                </button>
                                                <button id="btnDelete" runat="server" class="btn pull-right idelete" style="margin-left: 10px;"
                                                    type="button">
                                                    Delete</button>
                                                <asp:HiddenField ID="hdnPattern" runat="server" Value="0" />
                                            </div>--%>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Mod. Date">
                                        <ItemTemplate>
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
                                                        <asp:HyperLink ID="linkAddEditNote" runat="server" CssClass="btn-link iadd" ToolTip="Add Note"><i class="icon-plus"></i>Add Note</asp:HyperLink>
                                                    </li>
                                                    <li>
                                                        <asp:LinkButton ID="btnViewNote" runat="server" OnClick="btnViewNote_Click" CssClass="btn-link inote"
                                                            ToolTip="View Note" Visible="false"><i class="icon-list-alt"></i>View  Note</asp:LinkButton>
                                                    </li>
                                                    <li>
                                                        <asp:LinkButton ID="btnUpdate" runat="server" CssClass="btn-link isave ioverly" CommandName="UpdatePrice"
                                                            ToolTip="Update" OnClick="btnUpdate_Click"><i class="icon-edit"></i>Update</asp:LinkButton>
                                                    </li>
                                                </ul>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                </Columns>
                            </asp:DataGrid>
                        </ItemTemplate>
                    </asp:Repeater>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnTerm" runat="server" Value="1"></asp:HiddenField>
    <asp:HiddenField ID="hdnConvertionFactor" runat="server" Value="1"></asp:HiddenField>
    <asp:HiddenField ID="hdnUserID" runat="server" Value="0" />
    <asp:HiddenField ID="PriceID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnIndicoPriceRemarks" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
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
            <button id="btnDelete" runat="server" class="btn btn-primary" type="submit" onserverclick="btnDelete_Click"
                data-loading-text="Deleting...">
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
                </div>
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
            <button id="btnSaveNote" runat="server" class="btn btn-primary" validationgroup="checkNote"
                data-loading-text="Saving..." type="submit" onserverclick="btnSaveNote_Click">
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
            <h3>Delete Indico Price Remarks</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Indico price remarks?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDeleteIndicoPriceRemarks" runat="server" class="btn btn-primary" data-loading-text="Deleting..."
                onserverclick="btnDeleteIndicoPriceRemarks_Click">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Import Excel -->
    <div id="dvImportExcel" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Import Excel</h3>
        </div>
        <div class="modal-body">
            <div>
                <div class="control-group pull-right">
                    <label class="control-label">
                    </label>
                    <div class="controls">
                        <table id="uploadtable_1" class="file_upload_files" multirow="false" setdefault="false">
                            <asp:Repeater ID="rptUploadFile" runat="server">
                                <ItemTemplate>
                                    <tr id="tableRowfileUpload">
                                        <td class="file_preview">
                                            <asp:Image ID="uploadImage" Height="" Width="" runat="server" ImageUrl="" />
                                        </td>
                                        <td class="file_name">
                                            <asp:Literal ID="litfileName" runat="server"></asp:Literal>
                                        </td>
                                        <td id="filesize" class="file_size" runat="server">
                                            <asp:Literal ID="litfileSize" runat="server"></asp:Literal>
                                        </td>
                                        <td class="file_delete">
                                            <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn btn-link idelete" ToolTip="Delete Excel">Delete</asp:HyperLink>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </table>
                        <input id="hdnUploadFiles" runat="server" name="hdnUploadFiles" type="hidden" value="" />
                    </div>
                </div>
                <div class="pull-right">
                    <div class="control-group" id="lifileUploder" runat="server">
                        <label class="control-label">
                            Upload Excel File</label>
                        <div class="controls">
                            <div id="dropzone_1" class="fileupload preview single hide-dropzone">
                                <input id="file_1" name="file_1" type="file" />
                                <button id="btnup_1" type="submit">
                                    Upload</button>
                                <div id="divup_1">
                                    Drag file here or click to upload
                                </div>
                            </div>
                        </div>
                    </div>
                    <div>
                        <p class="extra-helper text-center">
                            <span class="label label-info">Hint:</span> You can drag & drop files from your
                                            desktop on this webpage with Google Chrome, Mozilla Firefox and Apple Safari.
                                            <!--[if IE]>
                            <strong>Microsoft Explorer has currently no support for Drag & Drop or multiple file selection.</strong>
                            <![endif]-->
                        </p>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnImportExcel" runat="server" class="btn btn-primary" onserverclick="btnImportExcel_Click"
                data-loading-text="Importing..." type="submit">
                Import Excel</button>
        </div>
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var populateAddEditNote = ('<%=ViewState["populateAddEditNote"]%>' == "True") ? true : false;
        var PopulateViewNote = ('<%=ViewState["PopulateViewNote"]%>' == "True") ? true : false;
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var populateImportExcel = ('<%=ViewState["populateImportExcel"]%>' == "True") ? true : false;
        var hdnSelectedID = "<%=hdnSelectedID.ClientID%>";
        var hdnConvertionFactor = "<%=hdnConvertionFactor.ClientID %>";
        var hdnSelectPattern = "<%=hdnSelectPattern.ClientID %>";
        var hdnUserID = "<%=hdnUserID.ClientID %>";
        var hdnTerm = "<%=hdnTerm.ClientID %>";
        var PriceID = "<%=PriceID.ClientID %>";
        var txtPattern = "<%=txtPattern.ClientID %>";
        var txtSearchAny = "<%=txtSearchAny.ClientID %>";
        var hdnIndicoPriceRemarks = "<%=hdnIndicoPriceRemarks.ClientID%>";
        var linkExcel = "<%=linkExcel.ClientID%>";  
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#' + txtPattern).keyup(function () {
                $('#' + hdnConvertionFactor).val('');
                $('#' + hdnSelectPattern).val('0');
            });

            $('li.indiman-price').css('backgroundColor', '#FFE87C');
            $('input[type=text].idouble.idiff').parent('li').css('backgroundColor', '#FFFF00');

            $('li.iprice-indico-cif input[type=text]').keyup(function () {
                calculte(this);
                colorChange(this);
            });

            function calculte(input) {
                if ($(input).val()) {
                    if ($('#' + hdnTerm).val() == "1") {
                        //var ulPrice = $(input).parents('ul').attr('id');
                        var newCIFPrice = parseFloat($(input).val());
                        //var cf = parseFloat($(input).attr('cf'));
                        //var newFOBPrice = parseFloat(newCIFPrice - cf);
                        //var cost = parseFloat($('#ulPrice li.icell-data:last span').text());
                        var cost = parseFloat($(input).attr('IndimanCost'));
                        // var newMarkup = Math.round(parseFloat(100 - ((cost * 100) / newCIFPrice)));
                        var newMarkup = parseFloat((1 - (cost / newCIFPrice)) * 100);

                        $(input).next('span').text(newMarkup.toFixed(2) + '%');
                        //$('#ulPrice li.iprice-indico-cif span.indico-markup-cif-fob').text(newMarkup.toFixed(2) + '%');
                        //$('#ulPrice li.iprice-indico-fob span:first').text(newFOBPrice.toFixed(2) + '%');
                        //$('#ulPrice li.iprice-indico-fob span:last').text(newMarkup.toFixed(2) + '%');
                    }
                    else {
                        var newCIFPrice = parseFloat($(input).val());
                        var cf = parseFloat($(input).attr('cf'));
                        var cost = parseFloat($(input).attr('IndimanCost'));
                        /* var newMarkup = Math.round(parseFloat(100 - (((cost - cf) * 100) / newCIFPrice)));*/
                        var newMarkup = parseFloat((1 - ((cost - cf) / newCIFPrice)) * 100);
                        $(input).next('span').text(newMarkup.toFixed(2) + '%');
                    }

                }
            }

            function colorChange(input) {
                var oldValue = $(input).parents('ul').find('li.iprice-indiman-cif').find('span.indiman-price-cif-fob')[0].innerHTML.split('$')[1];
                var newValue = $(input).val();
                $(input).parent('li').css('backgroundColor', ((parseFloat(oldValue) != parseFloat(newValue)) ? '#FFFF00' : '#FFFFFF'));
            }

            /*  if (PopulatePaternSearch) {
            window.setTimeout(function () {
            showPopupBox('dvSearchPattern', ($(window).width() * 0.9));
            }, 10);
            }*/

            /*  if (PopulatePatern) {
            window.setTimeout(function () {
            showPopupBox('dvViewPattern', 640);
            }, 10);
            }*/

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
            $('.iadd').click(function () {
                resetFieldsDefault('dvAddEditNote');
                $('div.alert-danger, span.error').hide();
                $('#' + PriceID).val($(this).attr('PriceID'));
                window.setTimeout(function () {
                    $('#dvAddEditNote').modal('show');
                }, 10);
            });

            $('.iprice').click(function () {
                $('#' + hdnIndicoPriceRemarks).val($(this).attr('pr'));
                $('#requestDeletePriceRemarks').modal('show');
            });

            $('#' + txtSearchAny).keyup(function () {
                $('.vertical').each(function () {
                    $('input[type=checkbox]').removeAttr('checked');
                });
            });

            $('#' + linkExcel).click(function () {
                $('#dvImportExcel').modal('show');
            });

            if (!populateImportExcel) {
                $('#dvImportExcel').modal('hide');
            }

        });

    </script>
    <!-- / -->
</asp:Content>
