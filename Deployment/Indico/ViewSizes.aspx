<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewSizes.aspx.cs" Inherits="Indico.ViewSizes" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="Page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddSizes" runat="server" class="btn btn-link iadd pull-right" onserverclick="btnAddSizes_Click"
                    type="submit">New Sizes</a>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h4>
                        <a href="javascript:SizesAddEdit(this, true, 'New Sizes');" title="Add a Size.">Add
                            the first Sizes.</a>
                    </h4>
                    <p>
                        You can add as many Sizes as you like.
                    </p>
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
                    <%--<telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server"   Skin="Metro"
                        EnableEmbeddedSkins="true">
                    </telerik:RadAjaxLoadingPanel>--%>
                    <%--   <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadGridSize">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridSize"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridSize" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="false" OnPageSizeChanged="RadGridSize_PageSizeChanged" AllowAutomaticUpdates="false" AllowAutomaticInserts="false"
                        PageSize="20" OnPageIndexChanged="RadGridSize_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridSize_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridSize_ItemCommand"
                        OnSortCommand="RadGridSize_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true">
                            <Columns>
                                <telerik:GridTemplateColumn DataField="Name" SortExpression="Name" HeaderText="Name" FilterControlWidth="150px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="litName" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn DataField="Description" SortExpression="Description" HeaderText="Description" FilterControlWidth="150px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="litDescription" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdnSizeSet" runat="server" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:LinkButton ID="linkEdit" runat="server" CssClass="btn-link ieditss" OnClick="linkEdit_Click"
                                                        ToolTip="Edit Size Set"><i class="icon-pencil"></i>Edit</asp:LinkButton>
                                                </li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="false">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="false" />
                    </telerik:RadGrid>
                    <%-- <asp:DataGrid ID="dataGridSizeSets" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dataGridSizeSets_ItemDataBound" OnPageIndexChanged="dataGridSizeSets_PageIndexChanged"
                        OnSortCommand="dataGridSizeSets_SortCommand" OnItemCommand="dataGridSizeSets_ItemCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="ID" HeaderText="ID" SortExpression="ID" HeaderStyle-CssClass="hide"
                                ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Name" HeaderText="Name" SortExpression="Name"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Description" HeaderText="Description" SortExpression="Description"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:LinkButton ID="linkEdit" runat="server" CssClass="btn-link iedit" CommandName="Edit"
                                                    ToolTip="Edit Size Set"><i class="icon-pencil"></i>Edit</asp:LinkButton>
                                            </li>
                                        </ul>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>--%>
                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> did not match
                            any sizes.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnIsNewSizeSet" runat="server" Value="0" />
    <asp:HiddenField ID="hdnSelectedSizeID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnSeqNo" runat="server" Value="" />
    <asp:HiddenField ID="hdnSizeName" runat="server" Value="" />
    <asp:HiddenField ID="hdnSizeSetID" runat="server" Value="" />
    <asp:HiddenField ID="hdnIsDefault" runat="server" Value="0" />
    <!-- Add / Edit Item -->
    <div id="requestAddEdit" class="modal fade" role="dialog" aria-hidden="true" keyboard="false" data-backdrop="static">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
            <h3>
                <asp:Label ID="lblPopupHeaderText" runat="server"></asp:Label>
            </h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <!-- Popup Validation -->
            <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <div>
                <div class="control-group">
                    <label class="control-label required">
                        Size Set</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlSizeSet" runat="server" AutoPostBack="true" CssClass="firePopupChange"
                            OnSelectedIndexChanged="ddlSizeSet_SelectedIndexChanged">
                        </asp:DropDownList>
                        <asp:LinkButton ID="linkAddNew" runat="server" Visible="false" CssClass="btn-link iadd firePopupChange"
                            ToolTip="Add New Size" OnClick="linkAddNew_Click"><i class="icon-plus"></i></asp:LinkButton>
                        <asp:RequiredFieldValidator ID="rfvSizeSet" runat="server" CssClass="error" ControlToValidate="ddlSizeSet"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Size Set is required"
                            InitialValue="0">
                                <img src="Content/img/icon_warning.png" title="Size Set is required" alt="Size Set is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
            </div>
            <div id="dvAddEditSizes" runat="server">
                <asp:DataGrid ID="dgAddEditSizes" runat="server" CssClass="table" AllowCustomPaging="False"
                    AllowPaging="false" AutoGenerateColumns="false" GridLines="None" OnItemDataBound="dgAddEditSizes_ItemDataBound"
                    OnItemCommand="dgAddEditSizes_ItemCommand">
                    <HeaderStyle CssClass="header" />
                    <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                    <Columns>
                        <asp:TemplateColumn Visible="false" HeaderText="ID">
                            <ItemTemplate>
                                <asp:Literal ID="lblID" runat="server" Text="0"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Is Default">
                            <ItemTemplate>
                                <%--<asp:CheckBox ID="chkIsDefault" runat="server" CssClass="changeisdefault" />--%>
                                <asp:CheckBox ID="chkIsDefault" runat="server" CssClass="changeisdefault" />
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Size Name" SortExpression="SizeName">
                            <ItemTemplate>
                                <%--<asp:Literal ID="lblSizeName" runat="server"></asp:Literal>--%>
                                <asp:TextBox ID="txtSizeName" runat="server" CssClass="ismall changeSizeName"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvSizeName" runat="server" ErrorMessage="Size Name is required" ControlToValidate="txtSizeName" EnableClientScript="false" Display="Dynamic">
                                    <img src="Content/img/icon_warning.png"  title="Size Name is required" alt="Size Name is required" />
                                </asp:RequiredFieldValidator>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Seq No" SortExpression="SeqNo">
                            <ItemTemplate>
                                <%--<asp:Literal ID="lblSeqNo" runat="server"></asp:Literal>--%>
                                <asp:TextBox ID="txtSeqNo" runat="server" CssClass=" changeSeqNo"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvSeqNo" runat="server" ErrorMessage="Sequence Number is required" ControlToValidate="txtSeqNo" EnableClientScript="false" Display="Dynamic">
                                    <img src="Content/img/icon_warning.png"  title="Sequence Number is required" alt="Sequence Number is required" />
                                </asp:RequiredFieldValidator>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn>
                            <ItemTemplate>
                                <%--<div class="btn-group pull-right">
                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                        <i class="icon-cog"></i><span class="caret"></span>
                                    </a>
                                    <ul class="dropdown-menu pull-right">
                                        <li>
                                            <asp:LinkButton ID="linkEdit" runat="server" CssClass="btn-link iedit" CausesValidation="false" CommandName="Edit" ToolTip="Edit Size"><i class="icon-pencil"></i>Edit</asp:LinkButton>
                                        </li>
                                        <li>--%>
                                <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" CausesValidation="false" CommandName="Delete" ToolTip="Delete Size"><i class="icon-trash"></i></asp:HyperLink>
                                <%--</li>
                                    </ul>
                                </div>--%>
                            </ItemTemplate>
                            <%--<EditItemTemplate>
                                <div class="btn-group pull-right">
                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                        <i class="icon-cog"></i><span class="caret"></span>
                                    </a>
                                    <ul class="dropdown-menu pull-right">
                                        <li>
                                            <asp:LinkButton ID="linkSave" runat="server" CssClass="btn-link isave" CausesValidation="false" CommandName="Save" ToolTip="Save Size"><i class="icon-edit"></i>Save Size</asp:LinkButton>
                                        </li>
                                    </ul>
                                </div>
                            </EditItemTemplate>--%>
                        </asp:TemplateColumn>
                    </Columns>
                </asp:DataGrid>
            </div>
            <!-- / -->
        </div>
        <div class="modal-footer noborder">
            <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
            <asp:Button ID="btnSaveChanges" runat="server" CssClass="btn btn-primary" OnClick="btnSaveChanges_Click" Text="Save Changes" Url="/ViewSizes.aspx" />
        </div>
    </div>
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Size</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Size?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" type="submit" onserverclick="btnDelete_Click">
                Yes
            </button>
        </div>
    </div>
    <!-- / -->
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var IsPopulateModel = ('<%=ViewState["IsPopulateModel"]%>' == 'True') ? true : false;
        var ddlSizeSet = "<%=ddlSizeSet.ClientID%>";
        var dvAddEditSizes = "<%=dvAddEditSizes.ClientID %>";
        var hdnSizeSetID = "<%=hdnSizeSetID.ClientID %>";

        var hdnIsNewSizeSet = "<%=hdnIsNewSizeSet.ClientID %>";
        var hdnSelectedSizeID = "<%=hdnSelectedSizeID.ClientID %>";
        var hdnSeqNo = "<%=hdnSeqNo.ClientID%>";
        var hdnSizeName = "<%=hdnSizeName.ClientID%>";
        var hdnIsDefault = "<%=hdnIsDefault.ClientID%>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            /*$('.iadd').click(function () {
            $('#' + dvEmptyContentAccessory).show();
            $('#' + dvAddEditSizes).hide();
            resetFieldsDefault('requestAddEdit');
            SizesAddEdit(this, true);
            });

            $('.idelete').click(function () {
            if (!($(this).hasClass('idelete-row'))) {
            $('#' + hdnSelectedSizeID)[0].value = $(this).attr('qid');
            showPopupBox('requestDelete');
            }
            });*/

            $('.iedit').click(function () {
                $('#' + hdnSelectedSizeID)[0].value = $(this).attr('qid');
            });

            $('.ieditss').click(function () {
                $('#' + hdnSizeSetID).val($(this).attr('qid'));

            });

            $('.idelete').click(function () {
                $('#' + hdnSelectedSizeID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });

            $('.changeSeqNo').keyup(function () {
                $('#' + hdnSeqNo).val($(this).val());
            });

            $('.changeSizeName').keyup(function () {
                $('#' + hdnSizeName).val($(this).val());
            });

            $('.changeisdefault').click(function (e) {
                if (e.target.checked) {
                    $('#' + hdnIsDefault).val(1);
                }
                else {
                    $('#' + hdnIsDefault).val(0);
                }

            });

            if (IsPopulateModel) {
                var isNew = true;
                if ($('#' + hdnIsNewSizeSet).val() == "0") {
                    isNew = false;
                }
                SizesAddEdit(this, isNew);
            }

            if (!IsPageValid) {
                window.setTimeout(function () {
                    $('#requestAddEdit').modal('show');

                }, 10);
            }

            function SizesAddEdit(o, n) {
                $('div.alert-danger, span.error').hide();
                $('#requestAddEdit div.modal-header h3 span')[0].innerHTML = (n ? 'Add Size' : 'Edit Size');
                /*$('#' + btnSaveChanges).val(n ? 'Save Changes' : 'Update');
                $('#' + hdnSelectedSizeID).val(n ? '0' : $(o).attr('qid'));
                if (!n) {
                $('#' + ddlSizeSet).val($(o).parents('tr').children('td')[1].innerHTML);
                }*/
                $('#requestAddEdit').modal('show');
            }

            /*function fillText(o) {
            $('#' + txtSizeName)[0].value = $(o).parents('tr').children('td')[2].childNodes[1].innerHTML.trim();
            $('#' + txtSeqNo)[0].value = $(o).parents('tr').children('td')[3].childNodes[1].innerHTML.trim();
            }*/
        });
    </script>
</asp:Content>
