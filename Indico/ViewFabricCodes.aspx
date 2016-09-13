<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewFabricCodes.aspx.cs"
    Inherits="Indico.ViewFabricCodes" MasterPageFile="~/Indico.Master" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions" runat="server">
                <asp:DropDownList ID="ddlFilterFabricType" runat="server" Width="200px" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterFabricType_SelectedIndexChanged"></asp:DropDownList>
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
                        <a href="javascript:AddEditPureFabric(this, true, 'New Fabric Codes');" title="Add Fabric Codes.">Add the first Fabric Code.</a>
                    </h4>
                    <p>
                        You can add as many Fabric Codes as you like.
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
                            <a id="btnNewPureFabric" runat="server" class="btn btn-link iaddPure pull-right">New Pure Fabric</a>
                            <a id="btnNewCombinedFabric" runat="server" class="btn btn-link pull-right" href="AddEditFabricCode.aspx">New Combined Fabric</a>
                            <%--<asp:LinkButton ID="btnNewCombinedFabric" runat="server" CssClass="btn btn-link pull-right" OnClick="btnNewCombinedFabric_Click">New Combined Fabric</asp:LinkButton>--%>
                        </asp:Panel>
                    </div>

                    <!-- / -->
                    <!-- Data Table -->
                    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro"
                        EnableEmbeddedSkins="true">
                    </telerik:RadAjaxLoadingPanel>
                    <%--<telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadGridFabricCode">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridFabricCode"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridFabricCode" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadGridFabricCode_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridFabricCode_PageIndexChanged" ShowFooter="false" OnGroupsChanging="RadGridFabricCode_GroupsChanging" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridFabricCode_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridFabricCode_ItemCommand"
                        OnSortCommand="RadGridFabricCode_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true" GroupsDefaultExpanded="false">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Code" SortExpression="Code" HeaderText="Code" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    FilterControlWidth="100px" DataField="Code">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Name" SortExpression="Name" HeaderText="Name" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Name">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="SupplierID" SortExpression="SupplierID" HeaderText="" AllowSorting="false" AllowFiltering="false"
                                    AutoPostBackOnFilter="true" DataField="SupplierID">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Supplier" SortExpression="Supplier" HeaderText="Supplier" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Supplier">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="CountryID" SortExpression="CountryID" HeaderText="" AllowSorting="false" AllowFiltering="false"
                                    AutoPostBackOnFilter="true" DataField="CountryID">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Country" SortExpression="Country" HeaderText="Country" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Country">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Material" SortExpression="Material" HeaderText="Material" AllowSorting="true" AllowFiltering="true"
                                    AutoPostBackOnFilter="true" DataField="Material">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="GSM" SortExpression="GSM" HeaderText="GSM" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="GSM">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="DenierCount" SortExpression="DenierCount" HeaderText="" AllowSorting="false" AllowFiltering="false"
                                    AutoPostBackOnFilter="true" DataField="DenierCount">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Filaments" SortExpression="Filaments" HeaderText="Filaments" AllowSorting="true" AllowFiltering="true"
                                    AutoPostBackOnFilter="true" DataField="Filaments">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="NickName" SortExpression="NickName" HeaderText="Nick Name" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="NickName">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="SerialOrder" SortExpression="SerialOrder" HeaderText="Serial Order" AllowSorting="true" AllowFiltering="true"
                                    AutoPostBackOnFilter="true" DataField="SerialOrder">
                                </telerik:GridBoundColumn>
                                <telerik:GridNumericColumn UniqueName="FabricPrice" SortExpression="FabricPrice" HeaderText="Fabric Price" DataFormatString="{0:0.00} " CurrentFilterFunction="Contains"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="FabricPrice">
                                </telerik:GridNumericColumn>
                                <telerik:GridBoundColumn UniqueName="LandedCurrency" SortExpression="LandedCurrency" HeaderText="Landed Currency" AllowSorting="true" AllowFiltering="true"
                                    AutoPostBackOnFilter="true" DataField="LandedCurrency">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="FabricWidth" SortExpression="FabricWidth" HeaderText="Fabric Width" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="FabricWidth">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="UnitID" SortExpression="UnitID" HeaderText="" AllowSorting="false" AllowFiltering="false"
                                    AutoPostBackOnFilter="true" DataField="UnitID">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Unit" SortExpression="Unit" HeaderText="Unit" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Unit">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="FabricColorID" SortExpression="FabricColorID" HeaderText="" AllowSorting="false" AllowFiltering="false"
                                    AutoPostBackOnFilter="true" DataField="FabricColorID">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="IsActive" SortExpression="IsActive" HeaderText="Is Active" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true" DataField="IsActive">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="IsPure" Display="false" SortExpression="IsPure" HeaderText="Is Pure" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true" DataField="IsPure">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="IsLining" SortExpression="IsLiningFabric" HeaderText="Is Lining" AllowSorting="true" CurrentFilterFunction="Contains"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true" DataField="IsLiningFabric">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <a id="linkEdit" runat="server" class="btn-link iedit" title="Edit Fabric"><i class="icon-pencil"></i>Edit</a>
                                                </li>
                                                <li>
                                                    <a id="linkBreakDown" runat="server" class="btn-link" title="Edit Fabric"><i class="icon-pencil"></i>Edit</a>
                                                    <%--<asp:LinkButton ID="linkBreakDown" runat="server" OnClick="linkBreakDown_Click" class="btn-link" ToolTip="Edit Fabric"><i class="icon-pencil"></i>Edit</asp:LinkButton>--%>
                                                </li>
                                                <li>
                                                    <a id="linkDelete" runat="server" class="btn-link idelete" title="Delete Fabric"><i class="icon-trash"></i>Delete</a>

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
    <asp:HiddenField ID="hdnSelectedFabricCodeID" runat="server" Value="0" />
    <!-- Add / Edit Fabric Code -->
    <div id="dvAddEditPureFabric" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static" style="display: none;">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblPopupHeaderText" runat="server" Text="New Topic"></asp:Label>
            </h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <!-- Popup Validation -->
            <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <fieldset class="panel" style="margin: 0; padding: 0; background: transparent; border: 0;">
                <div class="control-group">
                    <label class="control-label required">
                        Code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCode" runat="server" MaxLength="128"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvCode" runat="server" CssClass="error" ControlToValidate="txtCode"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Code is required">
                                <img src="Content/img/icon_warning.png" title="Code is required" alt="Code is required" />
                        </asp:RequiredFieldValidator>
                         <asp:CustomValidator ID="cvTxtName" runat="server" OnServerValidate="cvTxtName_ServerValidate" ErrorMessage="Code is already in use"
                            ControlToValidate="txtCode" EnableClientScript="false">
                             <img src="Content/img/icon_warning.png"  title="Code already in use" alt="Code is already in use" />
                        </asp:CustomValidator>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label required">
                        Factory Description</label>
                    <div class="controls">
                        <asp:TextBox ID="txtName" runat="server" MaxLength="128"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvName" runat="server" CssClass="error" ControlToValidate="txtName"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Factory Description is required">
                                <img src="Content/img/icon_warning.png" title="Factory Description is required" alt="Factory Description is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Sales Description</label>
                    <div class="controls">
                        <asp:TextBox ID="txtNickName" runat="server" MaxLength="128"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvNickName" runat="server" CssClass="error" ControlToValidate="txtNickName"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Sales Description is required">
                                <img src="Content/img/icon_warning.png" title="Sales Description is required" alt="Sales Description is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Is Active</label>
                    <div class="controls">
                        <asp:CheckBox ID="chbIsActive" runat="server" Checked="true" />
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Is Pure</label>
                    <div class="controls">
                        <asp:CheckBox ID="chbIsPure" runat="server" Checked="true" Enabled="false" />
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Is Lining</label>
                    <div class="controls">
                        <asp:CheckBox ID="chkIsLining" runat="server" />
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Supplier</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlSupplier" runat="server">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvSupplier" runat="server" CssClass="error" ControlToValidate="ddlSupplier"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Supplier is required"
                            InitialValue="0">
                                <img src="Content/img/icon_warning.png" title="Supplier is required" alt="Supplier is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Country</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlCountry" runat="server">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvCountry" runat="server" CssClass="error" ControlToValidate="ddlCountry"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Country is required"
                            InitialValue="0">
                                <img src="Content/img/icon_warning.png" title="Country is required" alt="Country is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Material</label>
                    <div class="controls">
                        <asp:TextBox ID="txtMaterial" runat="server" MaxLength="128"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        GSM</label>
                    <div class="controls">
                        <asp:TextBox ID="txtGsm" runat="server" MaxLength="128"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Denier Count</label>
                    <div class="controls">
                        <asp:TextBox ID="txtDenierCount" runat="server" MaxLength="128"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Filaments</label>
                    <div class="controls">
                        <asp:TextBox ID="txtFilaments" runat="server" MaxLength="128"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Serial Order</label>
                    <div class="controls">
                        <asp:TextBox ID="txtSerialOrder" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Price</label>
                    <div class="controls">
                        <asp:TextBox ID="txtFabricPrice" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Landed Currency</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlLandedCurrency" runat="server">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Fabric Width</label>
                    <div class="controls">
                        <asp:TextBox ID="txtFabricWidth" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Unit</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlUnit" runat="server">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Fabric Color</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlFabricColor" runat="server">
                        </asp:DropDownList>
                    </div>
                </div>
            </fieldset>
        </div>
        <!-- / -->
        <!-- Popup Footer -->
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_Click"
                data-loading-text="Saving..." type="submit">
                Save Changes</button>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <!-- Add / Edit Fabric Code -->
    <%--<div id="dvAddEditCombinedFabric" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static" style="display: none;">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Combined Fabric
            </h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <!-- Popup Validation -->
            <asp:ValidationSummary ID="vsCombined" runat="server" CssClass="alert alert-danger" ValidationGroup="valCombined"
                DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <fieldset class="panel" style="margin: 0; padding: 0; background: transparent; border: 0;">
                <div class="control-group">
                    <label class="control-label">
                        Code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtFabricCode" runat="server" Enabled="false" ValidationGroup="valCombined" CssClass="input-xxlarge"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvFabric" runat="server" ErrorMessage="Code is required."
                            ControlToValidate="txtFabricCode" EnableClientScript="false"
                            Display="Dynamic" ValidationGroup="valCombined">
                                            <img src="Content/img/icon_warning.png"  title="Code is required." alt="Code is required." />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div>
                    <legend>Fabric Details</legend>
                    <div class="control-group">
                        <div class="controls">
                            <asp:DropDownList ID="ddlFabricCodeType" runat="server" CssClass="input-medium" AutoPostBack="true"
                                ValidationGroup="valCombined" OnSelectedIndexChanged="ddlFabricCodeType_SelectedIndexChanged">
                            </asp:DropDownList>
                            <asp:DropDownList ID="ddlAddFabrics" runat="server" CssClass="input-xxlarge pull-right"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlAddFabrics_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                    </div>
                    <asp:DataGrid ID="dgvAddEditFabrics" runat="server" CssClass="table igridfabric" AllowCustomPaging="False"
                        AutoGenerateColumns="false" GridLines="None" PageSize="10" OnItemDataBound="dgvAddEditFabrics_ItemDataBound"
                        OnItemCommand="dgvAddEditFabrics_ItemCommand">
                        <HeaderStyle CssClass="header" />
                        <Columns>
                            <asp:TemplateColumn HeaderText="ID" Visible="false">
                                <ItemTemplate>
                                    <asp:Literal ID="litID" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn Visible="false">
                                <ItemTemplate>
                                    <asp:Literal ID="litFabricTypeID" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Fabric Code Type">
                                <ItemTemplate>
                                    <asp:Literal ID="litFabricType" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Fabric">
                                <ItemTemplate>
                                    <asp:Literal ID="litCode" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Nick Name">
                                <ItemTemplate>
                                    <asp:Literal ID="litFabricNickName" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Supplier">
                                <ItemTemplate>
                                    <asp:Literal ID="litFabricSupplier" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Where" Visible="false">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtWhere" runat="server" Text=""></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn>
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:LinkButton CommandName="Delete" ID="linkDelete" runat="server" CssClass="btn-link ifdelete" ValidationGroup="valCombined"
                                                    ToolTip="Delete "><i class="icon-trash"></i>Delete</asp:LinkButton>
                                            </li>
                                        </ul>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>
                    <div id="dvEmptyFabrics" runat="server" class="alert alert-info">
                        <h4>There are no Fabrics added.
                        </h4>
                        <p>
                            You can add many Fabrics.
                        </p>
                    </div>
                </div>
            </fieldset>
            <div class="control-group">
                <label class="control-label required">
                    Factory Description</label>
                <div class="controls">
                    <asp:TextBox ID="txtCombinedName" runat="server" MaxLength="128"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" CssClass="error" ControlToValidate="txtCombinedName" ValidationGroup="valCombined"
                        Display="Dynamic" EnableClientScript="False" ErrorMessage="Factory Description is required">
                                <img src="Content/img/icon_warning.png" title="Factory Description is required" alt="Factory Description is required" />
                    </asp:RequiredFieldValidator>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label required">
                    Sales Description</label>
                <div class="controls">
                    <asp:TextBox ID="txtCombinedNickName" runat="server" MaxLength="128"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" CssClass="error" ControlToValidate="txtCombinedNickName" ValidationGroup="valCombined"
                        Display="Dynamic" EnableClientScript="False" ErrorMessage="Sales Description is required">
                                <img src="Content/img/icon_warning.png" title="Sales Description is required" alt="Sales Description is required" />
                    </asp:RequiredFieldValidator>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">
                    Is Active</label>
                <div class="controls">
                    <asp:CheckBox ID="chkCombinedIsActive" runat="server" Checked="true" />
                </div>
            </div>
        </div>
        <!-- / -->
        <!-- Popup Footer -->
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnCombinedSave" runat="server" class="btn btn-primary" onserverclick="btnCombinedSave_ServerClick" validationgroup="valCombined"
                data-loading-text="Saving..." type="submit">
                Save Changes</button>
        </div>
        <!-- / -->
    </div>--%>
    <!-- / -->

    <!-- Delete Item -->
    <div id="requestDeleteFabricCode" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static" style="display: none;">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Fabric Code</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Fabric?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDeleteFabricCode" runat="server" class="btn btn-primary" type="submit"
                data-loading-text="Deleting..." onserverclick="btnDeleteFabricCode_Click">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var IsValidPure = ('<%=ViewState["IsPageValidPure"]%>' == 'True') ? true : false;
        var IsValidCombined = ('<%=ViewState["IsPageValidCombined"]%>' == 'True') ? true : false;
        var hdnSelectedFabricCodeID = "<%=hdnSelectedFabricCodeID.ClientID %>";
        var txtCode = "<%=txtCode.ClientID%>";
        var txtName = "<%=txtName.ClientID %>";
        var txtMaterial = "<%=txtMaterial.ClientID%>";
        var txtGsm = "<%=txtGsm.ClientID %>";
        var ddlSupplier = "<%=ddlSupplier.ClientID %>";
        var ddlCountry = "<%=ddlCountry.ClientID%>";
        var txtDenierCount = "<%=txtDenierCount.ClientID %>";
        var txtFilaments = "<%=txtFilaments.ClientID %>";
        var txtNickName = "<%=txtNickName.ClientID %>";
        var txtSerialOrder = "<%=txtSerialOrder.ClientID%>";
        var txtFabricPrice = "<%=txtFabricPrice.ClientID %>";
        var ddlLandedCurrency = "<%=ddlLandedCurrency.ClientID %>";
        var txtFabricWidth = "<%=txtFabricWidth.ClientID %>";
        var ddlUnit = "<%=ddlUnit.ClientID %>";
        var ddlFabricColor = "<%=ddlFabricColor.ClientID %>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID %>";
        var chbIsActive = "<%=chbIsActive.ClientID %>";
        var chbIsPure = "<%=chbIsPure.ClientID %>";
        var chkIsLining = "<%=chkIsLining.ClientID %>";
        //var ddlAddFabrics = "< %=ddlAddFabrics.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            if (!IsValidPure) {
                window.setTimeout(function () {
                    $('#dvAddEditPureFabric').modal('show');
                }, 10);
            }

            if (!IsValidCombined) {
                window.setTimeout(function () {
                    $('#dvAddEditCombinedFabric').modal('show');
                }, 10);
            }

            $('.iaddPure').click(function () {
                AddEditPureFabric(this, true);
            });

            //$('.iaddCombined').click(function () {
            //    AddEditCombinedFabric(this, true);
            //});

            $('.iedit').click(function () {
                AddEditPureFabric(this, false);
            });

            //$('.iBreakDown').click(function () {
            //    AddEditCombinedFabric(this, false);
            //});

            $('.idelete').click(function () {
                $('#' + hdnSelectedFabricCodeID)[0].value = $(this).attr('qid');
                $('#requestDeleteFabricCode').modal('show');
            });

            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
            function EndRequest(sender, args) {
                if (args.get_error() == undefined) {
                    BindEvents();
                }
            }

            BindEvents();

            function BindEvents() {
                $('#' + ddlAddFabrics).select2();
            }

            //function AddEditCombinedFabric(o, n) {
            //    $('div.alert-danger, span.error').hide();
            //    $('#dvAddEditPureFabric div.modal-header h3 span')[0].innerHTML = (n ? 'New Combined Fabric' : 'Edit Combined Fabric');
            //    $('#' + hdnSelectedFabricCodeID)[0].value = (n ? '0' : $(o).attr('qid'));

            //    $('#dvAddEditCombinedFabric').modal('show');
            //}

            function AddEditPureFabric(o, n) {
                $('div.alert-danger, span.error').hide();
                $('#dvAddEditPureFabric div.modal-header h3 span')[0].innerHTML = (n ? 'New Pure Fabric' : 'Edit Fabric');
                $('#' + btnSaveChanges)[0].innerHTML = (n) ? 'Save Changes' : 'Update';
                $('#' + hdnSelectedFabricCodeID)[0].value = (n ? '0' : $(o).attr('qid'));

                $('#' + txtCode)[0].value = (n ? '' : $(o).parents('tr').children('td')[0].innerHTML);
                $('#' + txtName)[0].value = (n ? '' : $(o).parents('tr').children('td')[1].innerHTML);
                $('#' + ddlSupplier)[0].value = (n ? '' : $(o).parents('tr').children('td')[2].innerHTML);
                $('#' + ddlCountry)[0].value = (n ? 0 : $(o).parents('tr').children('td')[4].innerHTML);
                $('#' + txtMaterial)[0].value = (n ? '' : (($(o).parents('tr').children('td')[6].innerHTML != '&nbsp;') ? $(o).parents('tr').children('td')[6].innerHTML : ''));
                $('#' + txtGsm)[0].value = (n ? '' : (($(o).parents('tr').children('td')[7].innerHTML != '&nbsp;') ? $(o).parents('tr').children('td')[7].innerHTML : ''));
                $('#' + txtDenierCount)[0].value = (n ? '' : (($(o).parents('tr').children('td')[8].innerHTML != '&nbsp;') ? $(o).parents('tr').children('td')[8].innerHTML : ''));
                $('#' + txtFilaments)[0].value = (n ? '' : (($(o).parents('tr').children('td')[9].innerHTML != '&nbsp;') ? $(o).parents('tr').children('td')[9].innerHTML : ''));
                $('#' + txtNickName)[0].value = (n ? '' : (($(o).parents('tr').children('td')[10].innerHTML != '&nbsp;') ? $(o).parents('tr').children('td')[10].innerHTML : ''));
                $('#' + txtSerialOrder)[0].value = (n ? '' : (($(o).parents('tr').children('td')[11].innerHTML != '&nbsp;') ? $(o).parents('tr').children('td')[11].innerHTML : ''));
                $('#' + txtFabricPrice)[0].value = (n ? '' : (($(o).parents('tr').children('td')[12].innerHTML != '&nbsp;') ? $(o).parents('tr').children('td')[12].innerHTML : ''));
                $('#' + ddlLandedCurrency)[0].value = (n ? 0 : $(o).parents('tr').children('td')[13].innerHTML);
                $('#' + txtFabricWidth)[0].value = (n ? '' : (($(o).parents('tr').children('td')[14].innerHTML != '&nbsp;') ? $(o).parents('tr').children('td')[14].innerHTML : ''));
                $('#' + ddlUnit)[0].value = (n ? 0 : $(o).parents('tr').children('td')[15].innerHTML);
                $('#' + ddlFabricColor)[0].value = (n ? 0 : $(o).parents('tr').children('td')[17].innerHTML);
                $('#' + chbIsActive)[0].checked = (n ? 'checked' : $(o).parents('tr').children('td')[18].innerHTML == "True");
               // $('#' + chbIsPure)[0].checked = (n ? '' : $(o).parents('tr').children('td')[19].innerHTML == "True");
                $('#' + chkIsLining)[0].checked = (n ? '' : $(o).parents('tr').children('td')[20].innerHTML == "True");

                //if ($('#' + chbIsPure)[0].checked == false) {
                //    $('#' + txtCode)[0].disabled = true;
                //}

                $('#dvAddEditPureFabric').modal('show');
            }
        });
    </script>
    <!-- / -->
</asp:Content>
