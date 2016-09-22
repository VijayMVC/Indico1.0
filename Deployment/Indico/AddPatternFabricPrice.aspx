<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddPatternFabricPrice.aspx.cs" Inherits="Indico.AddPatternFabricPrice"
    MaintainScrollPositionOnPostback="true" EnableEventValidation="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnIndimanPrice" runat="server" class="btn btn-link iadd pull-right" onserverclick="btnIndimanPrice_Click">Indiman Prices</a>
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
                <legend>Price Details</legend>
                <asp:Panel runat="server" DefaultButton="btnSearch">
                    <div class="control-group">
                        <label class="control-label required">
                            Pattern</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlPattern" runat="server">
                            </asp:DropDownList>
                            <asp:Button ID="btnSearch" runat="server" OnClick="btnSearch_Click" CssClass="btn"
                                data-loading-text="Searching..." Text="Search" />
                            <a id="linkViewPattern" runat="server" class="btn" data-target="#dvViewPattern" href="#dvViewSpecification"
                                data-toggle="modal" type="button" visible="false">View Pattern </a><span style="display: inline-block; width: 30px;">&nbsp;</span> <a id="linkSpecification" runat="server" data-target="#dvViewSpecification"
                                    class="btn" href="#dvViewSpecification" data-toggle="modal" visible="false">View
                                        Spec </a>
                        </div>
                    </div>
                    <asp:HiddenField ID="hdnPattern" runat="server" Value="0" />
                </asp:Panel>
                <!-- / -->
                <!-- View Pattern -->
                <div id="dvViewPattern" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
                    data-backdrop="static">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                            ×</button>
                        <h3>Pattern Details</h3>
                    </div>
                    <div class="modal-body">
                        <fieldset class="info">
                            <div class="control-group">
                                <label class="control-label">
                                    Pattern Number</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtPatternNo" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Item Name</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtItemName" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Size Set</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtSizeSet" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Age Group</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtAgeGroup" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Printer Trpe</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtPrinterType" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Keywords</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtKeyword" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Original Ref</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtOriginalRef" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Sub Item Name</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtSubItem" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Gender</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtGender" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Nick Name</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtNickName" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Corr Pattern</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtCorrPattern" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Consumption</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtConsumption" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                        </fieldset>
                    </div>
                </div>
                <!-- / -->
                <!-- View Garment Specification -->
                <div id="dvViewSpecification" class="modal modal-medium hide fade" role="dialog"
                    aria-hidden="true" keyboard="false" data-backdrop="static">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                            ×</button>
                        <h3>Garment Specification</h3>
                    </div>
                    <div class="modal-body">
                        <fieldset>
                            <div class="control-group">
                                <label class="control-label required">
                                </label>
                                <ol class="ioderlist-table">
                                    <li class="idata-row">
                                        <ul>
                                            <li class="icell-header small">Key</li>
                                            <li class="icell-header large">Loacation</li>
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
                                                    <li class="icell-header large">
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
                        </fieldset>
                    </div>
                </div>
                <!-- / -->
                <!-- Fabric Seacrch -->
                <!-- / -->
                <div id="divAddFabric" runat="server" class="" visible="false">
                    <div class="control-group">
                        <label class="control-label">
                            Fabric</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlFabric" runat="server">
                            </asp:DropDownList>
                            <button id="btnAddFabric" runat="server" class="btn btn-success pull-right" onserverclick="btnAddFabric_Click"
                                type="button">
                                Add Fabric Code
                            </button>
                        </div>
                    </div>
                </div>
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info" visible="false">
                    <h4>There are no fabrics associated with this Pattern.
                    </h4>
                    <p>
                        Once Pattern is added then you will be able to add Fabrics.
                    </p>
                </div>
                <!-- / -->
                <div id="dvNoResult" runat="server" class="alert alert-info" visible="false">
                    <h4>Please enter value to search.
                    </h4>
                </div>
                <!-- Selected Fabrics -->
                <asp:DataGrid ID="dgSelectedFabrics" runat="server" CssClass="table" AllowCustomPaging="False"
                    AutoGenerateColumns="false" GridLines="None" PageSize="10" OnItemDataBound="dgSelectedFabrics_ItemDataBound">
                    <HeaderStyle CssClass="header" />
                    <Columns>
                        <asp:TemplateColumn HeaderText="ID" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide">
                            <ItemTemplate>
                                <asp:Literal ID="litPrice" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:BoundColumn DataField="Code" HeaderText="Fabric Code"></asp:BoundColumn>
                        <asp:BoundColumn DataField="NickName" HeaderText="Nick Name"></asp:BoundColumn>
                        <asp:TemplateColumn HeaderText="Creator">
                            <ItemTemplate>
                                <asp:Literal ID="lblCreator" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Create Date">
                            <ItemTemplate>
                                <asp:Literal ID="lblCreateDate" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Modifier">
                            <ItemTemplate>
                                <asp:Literal ID="litModifier" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Modified Date">
                            <ItemTemplate>
                                <asp:Literal ID="litMofiedDate" runat="server"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Note" Visible="false">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnAddNote" CssClass="btn-link iadd" runat="server" OnClick="btnAddNote_Click">Add Edit Note</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn>
                            <ItemTemplate>
                                <div class="btn-group pull-right">
                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                        <i class="icon-cog"></i><span class="caret"></span></a>
                                    <ul class="dropdown-menu pull-right">
                                        <li>
                                            <asp:HyperLink ID="linkEdit" runat="server" CssClass="ifabricedit" ToolTip="Edit Fabric"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                        </li>
                                        <li>
                                            <asp:HyperLink ID="linkDelete" runat="server" CssClass="idelete" ToolTip="Delete Fabric"><i class="icon-trash"></i>Delete</asp:HyperLink>
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
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Price</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this price?
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
    <!-- Edit Fabric -->
    <div id="requestEditFabric" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Edit Fabric</h3>
        </div>
        <div class="modal-body">
            <fieldset>
                <div class="control-group">
                    <label class="control-label">
                        Fabric</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlEditFabric" runat="server">
                        </asp:DropDownList>
                    </div>
                </div>
            </fieldset>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveFabric" runat="server" class="btn btn-primary" onserverclick="btnSaveFabric_Click"
                data-loading-text="Saving..." type="submit" text="">
                Save Changes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Add Edit Note-->
    <div id="requestAddEditNote" class="modal">
        <div class="modal-header">
            <h2>
                <asp:Label ID="lblNoteHeading" runat="server"></asp:Label>
            </h2>
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                &times;</button>
        </div>
        <div class="modal-body">
            <fieldset>
                <ol>
                    <li>
                        <label>
                            Note</label>
                        <asp:TextBox ID="txtAddNote" runat="server" TextMode="MultiLine"></asp:TextBox>
                    </li>
                </ol>
            </fieldset>
        </div>
        <div class="modal-footer">
            <asp:Button ID="btnSave" runat="server" CssClass="btn" OnClick="btnSave_Click" Text="Save"
                Url="/AddPatternFabricPrice.aspx" />
            <input id="btnCancelSaveNote" class="btn firePopupCancel" type="button" value="Cancel" />
        </div>
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        //var PopulatePatern = ('<%=ViewState["PopulatePatern"]%>' == "True") ? true : false;
        //var PopulateFabric = ('<%=ViewState["PopulateFabric"]%>' == "True") ? true : false;
        var populateaddNewNote = ('<%=ViewState["populateaddNewNote"]%>' == "True") ? true : false;
        var hdnSelectedID = "<%=hdnSelectedID.ClientID%>";
        var btnDelete = "<%=btnDelete.ClientID%>";
        var btnSearch = "<%=btnSearch.ClientID%>";
        var ddlPattern = "<%=ddlPattern.ClientID%>";
        var ddlFabric = "<%=ddlFabric.ClientID%>";
        var ddlEditFabric = "<%=ddlEditFabric.ClientID%>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.iapply').click(function () {
                var cost = parseFloat($(this).prev('input.iapply-cost').val());
                $(this).prev('input.iapply-cost').val('');
                $('#' + $(this).attr('table') + ' input.idouble').val(cost.toFixed(2));
            });
            $('.ifabricedit').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('pid'));
                $('#' + ddlEditFabric).val($(this).attr('fid'));
                $('#requestEditFabric').modal('show');
            });

            $('.idelete').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                $('#requestDelete').modal('show');
                //showPopupBox('requestDelete');
            });
            if (populateaddNewNote) {
                window.setTimeout(function () {
                    // showPopupBox('requestAddEditNote')
                }, 10);
            }
            $('#' + ddlPattern).select2();
            $('#' + ddlFabric).select2();
        });
    </script>
    <!-- / -->
</asp:Content>
