<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditIndimanPrice.aspx.cs" Inherits="Indico.AddEditIndimanPrice"
    MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h1>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h1>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="inner">
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    ValidationGroup="priceHeader" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>">
                </asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <fieldset>
                    <h3>
                        Price Details</h3>
                    <p class="required">
                        Indicates required fields
                    </p>
                    <ol>
                        <li>
                            <label class="required">
                                Pattern</label>
                            <asp:TextBox ID="txtPattern" runat="server" Enabled="false"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvPattern" runat="server" ErrorMessage="Pattern is required."
                                ControlToValidate="txtPattern" EnableClientScript="false" ValidationGroup="priceHeader">
                            <img src="Content/img/icon_warning.png"  title="Pattern is required." alt="Pattern is required." />
                            </asp:RequiredFieldValidator>
                            <asp:HyperLink ID="linkSearchPattern" runat="server" CssClass="btn-link isearch"
                                NavigateUrl="javascript:showPopupBox('dvSearchPattern', ($(window).width() * 0.9));"
                                ToolTip="Search Pattern">Pattern</asp:HyperLink>
                            <button id="linkViewPattern" runat="server" class="btn" onclick="showPopupBox('dvViewPattern', 640);"
                                type="button" visible="false">
                                View Pattern
                            </button>
                            <button id="linkSpecification" runat="server" class="btn" onclick="showPopupBox('dvViewSpecification', ($(window).width() * 0.9));"
                                type="button" visible="false">
                                View Spec
                            </button>
                            <asp:HiddenField ID="hdnPattern" runat="server" Value="0" />
                            <!-- Pattern Search -->
                            <div id="dvSearchPattern" class="modal">
                                <!-- Empty Content -->
                                <div id="dvEmptyContentPattern" runat="server" class="alert alert-info">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                                        &times;</button>
                                    <h2>
                                        <a href="/AddEditPattern.aspx?id=0" title="Add a pattern.">Add the first pattern.</a>
                                    </h2>
                                    <p>
                                        You can add many pattern as you like.
                                    </p>
                                </div>
                                <!-- / -->
                                <!-- Data Content -->
                                <div id="dvDataContentPattern" runat="server">
                                    <!-- Search Control -->
                                    <div class="search-control clearfix">
                                        <asp:Panel ID="pnlSearchPattern" runat="server" DefaultButton="btnSearchPattern">
                                            <asp:TextBox ID="txtSearchPattern" runat="server" CssClass="search-control-query"
                                                placeholder="Search"></asp:TextBox>
                                            <asp:Button ID="btnSearchPattern" runat="server" CssClass="search-control-button"
                                                Text="Search" OnClick="btnSearchPattern_Click" />
                                        </asp:Panel>
                                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                                            &times;</button>
                                    </div>
                                    <!-- / -->
                                    <!-- Data Table -->
                                    <asp:DataGrid ID="dgPatterns" runat="server" CssClass="table" AllowCustomPaging="False"
                                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                                        PageSize="10" OnItemDataBound="dgPatterns_ItemDataBound" OnPageIndexChanged="dgPatterns_PageIndexChanged"
                                        OnSortCommand="dgPatterns_SortCommand">
                                        <HeaderStyle CssClass="header" />
                                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                                        <Columns>
                                            <asp:BoundColumn DataField="Number" HeaderText="Number" SortExpression="Number" ItemStyle-Width="10%">
                                            </asp:BoundColumn>
                                            <asp:BoundColumn DataField="OriginRef" HeaderText="Origin Ref" SortExpression="OriginRef"
                                                ItemStyle-Width="10%"></asp:BoundColumn>
                                            <asp:TemplateColumn HeaderText="Item" SortExpression="Item" ItemStyle-Width="20%">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblItemName" runat="server"></asp:Label>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:BoundColumn DataField="NickName" HeaderText="Nick Name" SortExpression="NickName"
                                                ItemStyle-Width="30%"></asp:BoundColumn>
                                            <asp:TemplateColumn HeaderText="Gender" SortExpression="Gender" ItemStyle-Width="8%">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblGender" runat="server"></asp:Label>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Is Active?" SortExpression="IsActive" ItemStyle-Width="8%">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblIsAcitve" runat="server"></asp:Label>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Select" ItemStyle-Width="4%">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="btnSelectPattern" runat="server" CssClass="btn-link iselect"
                                                        OnClick="btnSelectPattern_Click">Select</asp:LinkButton>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                        </Columns>
                                    </asp:DataGrid>
                                    <!-- / -->
                                    <!-- No Search Result -->
                                    <div id="dvNoSearchResultPattern" runat="server" class="message search" visible="false">
                                        <h4>
                                            Your search - <strong>
                                                <asp:Label ID="lblSerchKeyPattern" runat="server"></asp:Label></strong> - did
                                            not match any orders.</h4>
                                    </div>
                                    <!-- / -->
                                </div>
                                <!-- / -->
                            </div>
                            <!-- / -->
                            <!-- View Pattern -->
                            <div id="dvViewPattern" class="modal">
                                <div class="modal-header">
                                    <h2>
                                        Pattern Details</h2>
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                                        &times;</button>
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
                            </div>
                            <!-- / -->
                            <!-- View Garment Specification -->
                            <div id="dvViewSpecification" class="modal">
                                <div class="modal-header">
                                    <h2>
                                        Garment Specification</h2>
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                                        &times;</button>
                                </div>
                                <div class="modal-body">
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
                            </div>
                            <!-- / -->
                        </li>
                        <li>
                            <label class="required">
                                Conversion Factor</label>
                            <asp:TextBox ID="txtConvertionFactor" runat="server" CssClass="idouble"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvConversionFactor" runat="server" ErrorMessage="Conversion Factor is required"
                                ControlToValidate="txtConvertionFactor" EnableClientScript="false" ValidationGroup="priceHeader">
                        <img src="Content/img/icon_warning.png"  title="Conversion Factor is required" alt="Conversion Factor is required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label>
                                Remarks</label>
                            <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="3"></asp:TextBox>
                        </li>
                        <li>
                            <label>
                                Distributor</label>
                            <asp:DropDownList ID="ddlDistributors" runat="server" AutoPostBack="true" Enabled="false"
                                OnSelectedIndexChanged="ddlDistributors_SelectedIndexChanged">
                            </asp:DropDownList>
                        </li>
                    </ol>
                </fieldset>
                <!-- Fabric Seacrch -->
                <div id="dvSearchFabric" class="modal">
                    <!-- Empty Content -->
                    <div id="dvEmptyContentFabric" runat="server" class="alert alert-info">
                        <h2>
                            <a href="/ViewFabricCodes.aspx" title="Add a fabric.">Add the first fabric code.</a>
                        </h2>
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
                            PageSize="10" OnItemDataBound="dgFabrics_ItemDataBound" OnPageIndexChanged="dgFabrics_PageIndexChanged"
                            OnSortCommand="dgFabrics_SortCommand">
                            <HeaderStyle CssClass="header" />
                            <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                            <Columns>
                                <asp:BoundColumn DataField="Code" HeaderText="Code" SortExpression="Code" ItemStyle-Width="10%">
                                </asp:BoundColumn>
                                <asp:BoundColumn DataField="Name" HeaderText="Name" SortExpression="Name" ItemStyle-Width="10%">
                                </asp:BoundColumn>
                                <asp:BoundColumn DataField="Material" HeaderText="Material" SortExpression="Material"
                                    ItemStyle-Width="20%"></asp:BoundColumn>
                                <asp:BoundColumn DataField="NickName" HeaderText="Nick Name" SortExpression="NickName"
                                    ItemStyle-Width="30%"></asp:BoundColumn>
                                <asp:TemplateColumn HeaderText="Select" ItemStyle-Width="4%">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnSelectFabric" runat="server" CssClass="btn-link iselect" OnClick="btnSelectFabric_Click">Select</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                            </Columns>
                        </asp:DataGrid>
                        <!-- / -->
                        <!-- No Search Result -->
                        <div id="dvNoSearchResultFabric" runat="server" class="message search" visible="false">
                            <h4>
                                Your search - <strong>
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
                    <h2>
                        There are no fabrics added to this pattern.
                    </h2>
                    <p>
                        Once you have add a pattern you will able to add many fabric to this pattern as
                        you like.
                    </p>
                </div>
                <!-- / -->
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
                        <asp:BoundColumn DataField="Code" HeaderText="Fabric Code" ItemStyle-Width="10%">
                        </asp:BoundColumn>
                        <asp:BoundColumn DataField="NickName" HeaderText="Nick Name" ItemStyle-Width="18%">
                        </asp:BoundColumn>
                        <asp:TemplateColumn HeaderText="Price" ItemStyle-Width="72%">
                            <ItemTemplate>
                                <ol id="olPriceTable" runat="server" class="ioderlist-table">
                                    <li class="idata-column iempty">
                                        <ul>
                                            <li class="icell-header">&nbsp;<em>&nbsp;</em></li>
                                            <li class="icell-data"><span>CIF Price</span></li>
                                            <li class="icell-data"><span>FOB Price</span></li>
                                            <li class="icell-data"><span>MarkUp</span></li>
                                            <li class="icell-data"><span>CIF Cost</span></li>
                                            <li class="icell-data"><span>FOB Cost</span></li>
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
                                                    <li class="icell-data">
                                                        <asp:Label ID="lblMarkup" runat="server"></asp:Label>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:Label ID="lblCIFCost" runat="server"></asp:Label>
                                                    </li>
                                                    <li class="icell-data">
                                                        <asp:Label ID="lblFOBCost" runat="server"></asp:Label>
                                                    </li>
                                                </ul>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ol>
                                <div class="iaccess-bar iclearfix" style="margin-top: 9px;">
                                    <label class="pull-left" style="font-weight: 600; width: auto;">
                                        <asp:Literal ID="litSetCost" runat="server"></asp:Literal>
                                    </label>
                                    <input id="txtSetCost" runat="server" class="idouble iapply-cost" style="width: 74px"
                                        type="text" />
                                    <button id="btnApply" runat="server" class="btn pull-left iapply" type="button">
                                        Apply
                                    </button>
                                    <button id="btnDelete" runat="server" class="btn pull-right idelete" style="margin-left: 10px;"
                                        type="button">
                                        Delete
                                    </button>
                                    <button id="btnUpdate" runat="server" class="btn pull-right" onserverclick="btnUpdate_Click"
                                        type="button">
                                        Update
                                    </button>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                    </Columns>
                </asp:DataGrid>
                <!-- / -->
                <!-- / -->
                <div class="form-actions">
                    <asp:Button ID="btnSaveChanges" runat="server" CssClass="btn btn-primary" OnClick="btnSaveChanges_Click"
                        ValidationGroup="priceHeader" Text="Save Changes" />
                </div>
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal">
        <div class="modal-header">
            <h2>
                Delete Fabric Code Prices</h2>
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                &times;</button>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this fabic code prices?
        </div>
        <div class="modal-footer">
            <asp:Button ID="btnDelete" runat="server" CssClass="btn" Text="Yes" Url="/AddEditIndimanPrice.aspx"
                OnClick="btnDelete_Click" />
            <input id="btnCancel" class="btn firePopupCancel" type="button" value="No" />
        </div>
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var PopulatePatern = ('<%=ViewState["PopulatePatern"]%>' == "True") ? true : false;
        var PopulateFabric = ('<%=ViewState["PopulateFabric"]%>' == "True") ? true : false;
        var hdnSelectedID = "<%=hdnSelectedID.ClientID%>";
        var btnDelete = "<%=btnDelete.ClientID%>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.iapply').click(function () {
                var cost = parseFloat($(this).prev('input.iapply-cost').val());
                $(this).prev('input.iapply-cost').val('');
                $('#' + $(this).attr('table') + ' input.idouble').val(cost.toFixed(2));
            });
            $('.idelete').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                showPopupBox('requestDelete', '380');
            });
            if (PopulatePatern) {
                window.setTimeout(function () {
                    showPopupBox('dvSearchPattern', ($(window).width() * 0.9));
                }, 10);
            }
            if (PopulateFabric) {
                window.setTimeout(function () {
                    showPopupBox('dvSearchFabric', ($(window).width() * 0.9));
                }, 10);
            }
        });
    </script>
    <!-- / -->
</asp:Content>
