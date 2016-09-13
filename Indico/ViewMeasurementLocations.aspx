<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewMeasurementLocations.aspx.cs" Inherits="Indico.ViewMeasurementLocations" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <%--<input id="btnAddMeasurementLocation" runat="server" class="btn btn-primary iadd pull-right"
                type="button" value="New Measurement Location" />--%>
            <div class="header-actions">
                <a id="btnAddMeasurementLocation" runat="server" class="btn btn-link iadd pull-right"
                    onserverclick="btnAddMeasurementLocation_Click" type="submit">New Measurement Location</a>
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
                        <a href="javascript:MeasurementLocationsAddEdit(this, true, 'New Measurement Location');"
                            title="Add a Measurement Location.">Add the first measurement location.</a>
                    </h4>
                    <p>
                        You can add as many measurement locations as you like.
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
                    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro"
                        EnableEmbeddedSkins="true">
                    </telerik:RadAjaxLoadingPanel>
                    <%--   <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <ajaxsettings>
                            <telerik:AjaxSetting AjaxControlID="RadGridMeasurements">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridMeasurements"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </ajaxsettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridMeasurements" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadGridMeasurements_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridMeasurements_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridMeasurements_ItemDataBound" OnGroupsChanging="RadGridMeasurements_GroupsChanging"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridMeasurements_ItemCommand"
                        OnSortCommand="RadGridMeasurements_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Name" SortExpression="Name" HeaderText="Name" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="150px" DataField="Name">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:LinkButton ID="linkEdit" runat="server" CssClass="btn-link iedit" OnClick="linkEdit_Click" ToolTip="Edit Measurement Location"><i class="icon-pencil"></i>Edit</asp:LinkButton>
                                                </li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="true">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="true" />
                    </telerik:RadGrid>
                    <%--<asp:DataGrid ID="dgMeasurementLocation" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dgMeasurementLocation_ItemDataBound" OnPageIndexChanged="dgMeasurementLocation_PageIndexChanged"
                        OnSortCommand="dgMeasurementLocation_SortCommand" OnItemCommand="dgMeasurementLocation_ItemCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="ID" HeaderText="ID" ItemStyle-Width="30%" SortExpression="ID"
                                HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:BoundColumn DataField="ID" HeaderText="Item" HeaderStyle-CssClass="hide" ItemStyle-CssClass="hide">
                            </asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Item" SortExpression="Name">
                                <ItemTemplate>
                                    <asp:Literal ID="lblItem" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:LinkButton ID="linkEdit" runat="server" CssClass="btn-link iedit" CommandName="Edit"
                                                    ToolTip="Edit Measurement Location"><i class="icon-pencil"></i>Edit</asp:LinkButton>
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
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                            any documents.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedMeasurementLocationListID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnKey" runat="server" Value="" />
    <asp:HiddenField ID="hdnName" runat="server" Value="" />
    <asp:HiddenField ID="hdnIsSend" runat="server" Value="0" />
    <!-- Add / Edit Item -->
    <div id="requestAddEdit" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
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
            <input id="hdnIsNewML" type="hidden" runat="server" value="0" />
            <!-- Popup Validation -->
            <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <fieldset>
                <div class="control-group">
                    <label class="control-label required">
                        Item</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlItem" runat="server" CssClass="firePopupChange" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlItem_SelectedIndexChange">
                        </asp:DropDownList>
                        <asp:LinkButton ID="linkAddNew" runat="server" Visible="false" CssClass="btn-link iadd firePopupChange"
                            ToolTip="Add New Measurement Location" OnClick="linkAddNew_Click"><i class="icon-plus"></i></asp:LinkButton>
                        <asp:RequiredFieldValidator ID="rfvItem" runat="server" CssClass="error" ControlToValidate="ddlItem"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Item is required"
                            InitialValue="0">
                                <img src="Content/img/icon_warning.png" title="Item is required" alt="Item is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
            </fieldset>
            <fieldset>
                <asp:DataGrid ID="dgAddEditMLs" runat="server" CssClass="table" AllowCustomPaging="False"
                    AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                    OnItemDataBound="dgAddEditMLs_ItemDataBound" OnSortCommand="dgAddEditMLs_SortCommand"
                    OnItemCommand="dgAddEditMLs_ItemCommand">
                    <HeaderStyle CssClass="header" />
                    <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                    <Columns>
                        <asp:TemplateColumn Visible="false" HeaderText="ID">
                            <ItemTemplate>
                                <asp:Label ID="lblID" runat="server"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateColumn>
                         <asp:TemplateColumn HeaderText="Is Send">
                            <ItemTemplate>
                                <asp:CheckBox ID="chkIsSend" runat="server" CssClass="ismall changeissend" />
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:CheckBox ID="chkIsSend" runat="server" CssClass="ismall changeissend" />
                            </EditItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Key">
                            <ItemTemplate>
                                <asp:Label ID="lblKey" runat="server"></asp:Label>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtKey" runat="server" CssClass="ismall changekey"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvKey" runat="server" ErrorMessage="Key is required"
                                    ControlToValidate="txtKey" EnableClientScript="false">
                                                <img src="Content/img/icon_warning.png"  title="Key is required" alt="Key is required" />
                                </asp:RequiredFieldValidator>
                            </EditItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn HeaderText="Name">
                            <ItemTemplate>
                                <asp:Label ID="lblName" runat="server"></asp:Label>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtName" runat="server" CssClass=" changename"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvName" runat="server" ErrorMessage="Name is required" ControlToValidate="txtName" EnableClientScript="false">
                                    <img src="Content/img/icon_warning.png"  title="Name is required" alt="Name is required" />
                                </asp:RequiredFieldValidator>
                            </EditItemTemplate>
                        </asp:TemplateColumn>
                        <asp:TemplateColumn>
                            <ItemTemplate>
                                <div class="btn-group pull-right">
                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                        <i class="icon-cog"></i><span class="caret"></span></a>
                                    <ul class="dropdown-menu pull-right">
                                        <li>
                                            <asp:LinkButton ID="linkEdit" runat="server" CssClass="btn-link iedit" CausesValidation="false" CommandName="Edit" ToolTip="Edit Measurement Location"><i class="icon-pencil"></i>Edit</asp:LinkButton>
                                        </li>
                                        <li>
                                            <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" CausesValidation="false" CommandName="Delete" ToolTip="Delete Measurement Location"><i class="icon-trash"></i>Delete</asp:HyperLink>
                                        </li>
                                    </ul>
                                </div>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <div class="btn-group pull-right">
                                    <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                        <i class="icon-cog"></i><span class="caret"></span></a>
                                    <ul class="dropdown-menu pull-right">
                                        <li>
                                            <asp:LinkButton ID="linkSave" runat="server" CssClass="btn-link isave" CausesValidation="false"
                                                CommandName="Save" ToolTip="Save Measurement Location" OnClientClick=""><i class="icon-pencil"></i>Save</asp:LinkButton>
                                        </li>
                                    </ul>
                                </div>
                            </EditItemTemplate>
                        </asp:TemplateColumn>
                    </Columns>
                </asp:DataGrid>
            </fieldset>
        </div>
        <div class="modal-footer">
            <%--<asp:Button ID="btnSaveChanges" runat="server" CssClass="btn" OnClick="btnSaveChanges_Click"
                Text="Save" Url="/ViewItems.aspx" />--%>
        </div>
    </div>
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete MeasurementLocation</h3>
        </div>
        <div class="modal-body">
            Are you wish to delete this Measurement Location?
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
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var IsPopulateModel = ('<%=ViewState["IsPopulateModel"]%>' == 'True') ? true : false;
        var hdnIsNewML = "<%=hdnIsNewML.ClientID%>";
        var hdnSelectedMeasurementLocationListID = "<%=hdnSelectedMeasurementLocationListID.ClientID %>";
        var ddlItem = "<%=ddlItem.ClientID%>";
        var hdnKey = "<%=hdnKey.ClientID%>";
        var hdnName = "<%=hdnName.ClientID%>";
        var hdnIsSend = "<%=hdnIsSend.ClientID%>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            /*$('.iadd').click(function () {
            resetFieldsDefault('requestAddEdit');
            MeasurementLocationsAddEdit(this, true);
            });*/

            $('.iedit').click(function () {
                $('#' + hdnSelectedMeasurementLocationListID)[0].value = $(this).attr('qid');
            });

            $('.idelete').click(function () {
                $('#' + hdnSelectedMeasurementLocationListID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });

            $('.changekey').keyup(function () {
                $('#' + hdnKey).val($(this).val());
            });

            $('.changename').keyup(function () {
                $('#' + hdnName).val($(this).val());
            });

            $('.changeissend').click(function (e) {
                if (e.target.checked) {
                    $('#' + hdnIsSend).val(1);
                }
                else {
                    $('#' + hdnIsSend).val(0);
                }
            });

            $('.iml').click(function () {

            });
            if (IsPopulateModel) {
                var isNew = true;
                if ($('#' + hdnIsNewML).val() == "0") {
                    isNew = false;
                }

                MeasurementLocationsAddEdit(this, isNew);
            }

            if (!IsPageValid) {
                window.setTimeout(function () {
                    $('#requestAddEdit').modal('show');
                }, 10);
            }

            function MeasurementLocationsAddEdit(o, n) {
                $('div.alert-danger, span.error').hide();
                $('#requestAddEdit div.modal-header h3 span')[0].innerHTML = (n ? 'Add Measurement Location' : 'Edit Measurement Location');
                /*$('#' + btnSaveChanges).val(n ? 'Save Changes' : 'Update');
                $('#' + hdnSelectedMeasurementLocationListID).val(n ? '0' : $(o).attr('qid'));
                if (!n) {
                $('#' + ddlItem).val($(o).parents('tr').children('td')[1].innerHTML);
                }*/
                $('#requestAddEdit').modal('show');
            }

            /*function fillText(o) {
            $('#' + txtKey)[0].value = $(o).parents('tr').children('td')[3].childNodes[1].innerHTML.trim();
            $('#' + txtItemName)[0].value = $(o).parents('tr').children('td')[4].childNodes[1].innerHTML.trim();
            }*/
        });
    </script>
</asp:Content>
