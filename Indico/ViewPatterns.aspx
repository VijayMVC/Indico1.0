<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewPatterns.aspx.cs" Inherits="Indico.ViewPatterns" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <asp:ScriptManager ID="PatternScriprtManaget" runat="server">
    </asp:ScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <button id="btnBack" runat="server" class="btn btn-primary pull-right" visible="false"
                    onserverclick="btnBack_Click">
                    Back</button>
                <a id="btnAddPattern" runat="server" class="btn btn-link pull-right" href="~/AddEditPattern.aspx" visible="false">New Pattern</a>
                <a id="btnAddPatternOtherCategories" runat="server" class="btn btn-link pull-right" onserverclick="btnAddPatternOtherCategories_Click">Add Other Categories</a>
                <a id="btnComapreGarmentSpec" runat="server" class="btn btn-link pull-right" href="~/ViewCompareGramentSpec.aspx">Compare Garment Specifications</a>
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
                        <a href="AddEditPattern.aspx" title="Add an item.">Add the first pattern.</a>
                    </h4>
                    <p>
                        You can add as many patterns as you like.
                    </p>
                </div>
                <!-- / -->
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <div class="form-inline pull-right">
                            <label>
                                Blackchrome</label>
                            <asp:DropDownList ID="ddlWebService" runat="server" AutoPostBack="True" CssClass="input-medium"
                                OnSelectedIndexChanged="ddlWebService_SelectedIndexChanged">
                                <asp:ListItem Value="0">All</asp:ListItem>
                                <asp:ListItem Value="1">Posted</asp:ListItem>
                                <asp:ListItem Value="2">Not yet posted</asp:ListItem>
                            </asp:DropDownList>
                            <label>
                                Filter by</label>
                            <asp:DropDownList ID="ddlSortByActive" runat="server" AutoPostBack="True" CssClass="input-small"
                                OnSelectedIndexChanged="ddlSortByActive_SelectedIndexChanged">
                                <asp:ListItem Value="1">Active</asp:ListItem>
                                <asp:ListItem Value="2">InActive</asp:ListItem>
                            </asp:DropDownList>
                            <asp:DropDownList ID="ddlSortByGarmentSpec" runat="server" AutoPostBack="True" CssClass="input-medium"
                                OnSelectedIndexChanged="ddlSortByGarmentSpec_SelectedIndexChanged">
                                <asp:ListItem Value="0">All</asp:ListItem>
                                <asp:ListItem Value="1">Completed</asp:ListItem>
                                <asp:ListItem Value="2">Not Completed</asp:ListItem>
                                <asp:ListItem Value="3">Partialy Completed</asp:ListItem>
                                <asp:ListItem Value="4">Spec Missing</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="pull-right" style="margin-top: 4px; margin-right: 20px;">
                            <asp:LinkButton ID="btnlinkCompleated" runat="server" OnClick="linkSortby_Click"
                                ToolTip="Completed" status="comp">
                                <span class="badge badge-completed">&nbsp;</span>&nbsp;Completed
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnlinkPartiallyCompleted" runat="server" OnClick="linkSortby_Click"
                                ToolTip="Partially Completed" status="pcomp">
                                <span class="badge badge-partialycompleted">&nbsp;</span>&nbsp;Partially Completed
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnlinkNotCompleted" runat="server" OnClick="linkSortby_Click"
                                ToolTip="Not Completed" status="ncomp">
                                <span class="badge badge-notcompleted">&nbsp;</span>&nbsp;Not Completed
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnlinkSpecMissing" runat="server" OnClick="linkSortby_Click"
                                ToolTip="Spec Missing" status="specm">
                                <span class="badge badge-specmissing">&nbsp;</span>&nbsp;Spec Missing
                            </asp:LinkButton>
                        </div>
                        <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>
                        <!-- / -->
                    </div>
                    <!-- / -->
                    <!-- Data Table -->
                    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
                    </telerik:RadAjaxLoadingPanel>
                    <telerik:RadGrid ID="RadGridPattern" runat="server" AllowPaging="true" AllowFilteringByColumn="true"
                        ShowGroupPanel="true" ShowFooter="false" OnPageSizeChanged="RadGridPattern_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridPattern_PageIndexChanged" EnableHeaderContextMenu="true"
                        EnableHeaderContextFilterMenu="true" AutoGenerateColumns="false" OnItemDataBound="RadGridPattern_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnGroupsChanging="RadGridPattern_GroupsChanging" OnItemCommand="RadGridPattern_ItemCommand"
                        OnSortCommand="RadGridPattern_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <GroupingSettings CaseSensitive="false" />
                        <MasterTableView AllowFilteringByColumn="true" TableLayout="Auto" GroupsDefaultExpanded="false">
                            <Columns>
                                <telerik:GridTemplateColumn AllowFiltering="false" Groupable="false" UniqueName="chkSelect">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkSelect" runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="Number" SortExpression="Number" HeaderText="Number"
                                    CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" FilterControlWidth="60px"
                                    DataField="Number">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="NickName" SortExpression="NickName" HeaderText="Nick Name"
                                    CurrentFilterFunction="Contains" FilterControlWidth="110px" AutoPostBackOnFilter="true"
                                    DataField="NickName">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Gender" SortExpression="Gender" HeaderText="Gender"
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="Gender">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Item" SortExpression="Item" HeaderText="Item"
                                    CurrentFilterFunction="Contains" FilterControlWidth="100px" AutoPostBackOnFilter="true"
                                    DataField="Item">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="SubItem" SortExpression="SubItem" HeaderText="Sub Item"
                                    FilterControlWidth="100px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    DataField="SubItem">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="AgeGroup" SortExpression="AgeGroup" HeaderText="Age Group"
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="AgeGroup">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="CorePattern" SortExpression="CorePattern" HeaderText="Corresp Pattern"
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="CorePattern">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="CoreCategory" SortExpression="CoreCategory"
                                    HeaderText="Core Category" CurrentFilterFunction="Contains" FilterControlWidth="100px"
                                    AutoPostBackOnFilter="true" DataField="CoreCategory">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="SizeSet" SortExpression="SizeSet" HeaderText="Size Set"
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="SizeSet">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="OriginRef" SortExpression="OriginRef" HeaderText="Origin Ref."
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="OriginRef">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Keywords" SortExpression="Keywords" HeaderText="Keywords"
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="Keywords">
                                </telerik:GridBoundColumn>
                                <%--<telerik:GridCheckBoxColumn UniqueName="IsCoreRange" HeaderText="Is CoreRange" DataField="IsCoreRange" AllowFiltering="false" ItemStyle-CssClass="rfdCheckboxChecked" ItemStyle-HorizontalAlign="Center"
                                    AllowSorting="true">
                                </telerik:GridCheckBoxColumn>--%>
                                <telerik:GridTemplateColumn AllowFiltering="false" Groupable="false" HeaderText="Is CoreRange">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkIsCoreRange" runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="PrinterType" SortExpression="PrinterType" HeaderText="Printer Type"
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="PrinterType">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="SpecialAttributes" SortExpression="SpecialAttributes" HeaderText="Special Attributes"
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="SpecialAttributes">
                                </telerik:GridBoundColumn>
                                <telerik:GridNumericColumn UniqueName="ConvertionFactor" SortExpression="ConvertionFactor" HeaderText="Convertion Factor" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="ConvertionFactor">
                                </telerik:GridNumericColumn>
                                <telerik:GridBoundColumn UniqueName="Remarks" SortExpression="Remarks" HeaderText="Remarks"
                                    CurrentFilterFunction="Contains" FilterControlWidth="100px" AutoPostBackOnFilter="true"
                                    DataField="Remarks">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="GS(cms)" AllowFiltering="false" ItemStyle-Width="5%"
                                    ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="ancDownloadPDF" runat="server" CssClass="btn-link iprintpdf ipdf"
                                            OnClick="ancDownloadPDF_click" ToolTip="Download PDF" Text="Download PDF" Visible="false"><i class="icon-download-alt"></i></asp:LinkButton>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Spec/Details" AllowFiltering="false" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="ancGarmentSpec" runat="server" CssClass="btn-link iclick ispec" OnClick="ancGarmentSpec_click" ToolTip="Garment Spec" Text="Garment Spec"><i class="icon-th-list"></i></asp:LinkButton>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Images" AllowFiltering="false" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <a id="ancTemplateImage" runat="server"><i id="iimageView"
                                            runat="server" class="icon-eye-open"></i></a>
                                        <div id="previewTemplate" runat="server" style="display: none;">                                           
                                        </div>
                                         <a id="ancFullImage" runat="server" target="_blank" visible="false">View</a>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Post" AllowFiltering="false" UniqueName="Post">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="linkaws" runat="server" OnClick="linkws_OnClick" Visible="false"
                                            Text="Send"></asp:LinkButton>
                                        <asp:LinkButton ID="linkdws" runat="server" OnClick="linkws_OnClick" Visible="false"
                                            Text="Remove"></asp:LinkButton>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Spec" AllowFiltering="false" UniqueName="Spec">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblStatus" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn UniqueName="UserFunctions" HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Pattern"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Pattern"><i class="icon-trash" ></i> Delete</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="addEditPatternDevelopmentLink" runat="server" CssClass="btn-link iadd" ToolTip="Create Pattern Development"><i class="icon-plus-sign"  ></i> Create Development</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="checkDevelopmentHistoryLink" Visible="False" runat="server" CssClass="btn-link checkhistoryLink" ToolTip="Check Pattern Development History"><i class="icon-search"></i> Check Development History</asp:HyperLink>
                                                </li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="True" AllowGroupExpandCollapse="true" AllowExpandCollapse="true">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="true" />
                    </telerik:RadGrid>
                    <div>
                        <button id="btnSaveChanges" runat="server" class="btn btn-primary pull-right" text=""
                            data-loading-text="Saving..." onserverclick="btnSaveChanges_ServerClick" type="submit">
                            Save Changes</button>
                    </div>
                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> did not match
                            any patterns.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedPatternID" runat="server" Value="0" />
    <!-- Garment Spec -->
    <div id="requestGarmentSpec" class="modal modal-medium hide fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblPopupHeaderText" runat="server" Text="Pattern Spec/Details"></asp:Label></h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div id="dvgarmentSpecContent" class="modal-body">
            <div id="dvSpecGrdEmpty" runat="server" class="alert alert-info">
                <h4>Garment Specification is currently not available.
                </h4>
                <p id="paraSpecError" runat="server" class="extra-helper">
                </p>
            </div>
            <div id="dvSpecGrd" runat="server" visible="false">
                <h1>Garment Specification</h1>
                <div style="border-bottom: #CCCCCC solid 1px; height: 24px;">
                    <asp:Label ID="lblDescription" runat="server" CssClass="pull-left"></asp:Label>
                    <asp:Label ID="lblDate" runat="server" CssClass="pull-right"></asp:Label>
                </div>
                <div class="form-actions" id="divPatternTemplateImageContainer" runat="server">
                    <div class="igarment">
                        <asp:Image ID="imgPatternTemplateImage" runat="server" ImageUrl="" class="img-polaroid" />
                    </div>
                </div>
                <div class="igarment">
                    <asp:Image ID="imgPatternCompressionImage" runat="server" class="img-polaroid" />
                </div>
                <div id="garmentSpecModalTableContainer" runat="server">
                    <fieldset>
                        <div class="control-group">
                            <label class="control-label">
                                Conversion</label>
                            <div class="controls">
                                <asp:DropDownList ID="ddlConvert" runat="server">
                                    <asp:ListItem Text="Centimeters" Value="0" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="Inches" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                    </fieldset>
                    <fieldset>
                        <div class="control-group">
                            <div class="controls">
                                <ol id="olSpecGrd" class="ioderlist-table">
                                    <li class="idata-row">
                                        <ul>
                                            <li class="icell-header small">Key</li>
                                            <li class="icell-header exlarge">Location</li>
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
                                                                <asp:Label ID="lblQty" runat="server" CssClass="idouble"></asp:Label>
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
                    </fieldset>
                </div>

            </div>
        </div>
        <!-- / -->
        <!-- Popup Footer -->
        <div class="modal-footer">
            <!--  <input type="button" id="btnPrint" value="Print" class="btn" onclick="javascript:printPattern('dvgarmentSpecContent');">-->
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnPrintPDF" runat="server" class="btn btn-primary igspdf" onserverclick="btnPrintPDF_OnClick"
                type="submit">
                <i class="icon-print icon-white"></i>Print</button>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnPatternID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnSelectedPattern" runat="server" />
    <!-- Pattern Other Categories -->
    <div id="dvPatternOtherCategories" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Select Other Categories</h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <asp:DataGrid ID="dgCategory" runat="server" CssClass="table" AllowCustomPaging="False"
                AllowPaging="False" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                OnItemDataBound="dgCategory_ItemDataBound">
                <HeaderStyle CssClass="header" />
                <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                <Columns>
                    <asp:TemplateColumn HeaderText="" ItemStyle-Width="10%" SortExpression="">
                        <ItemTemplate>
                            <asp:CheckBox ID="chkSelect" runat="server" />
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:BoundColumn DataField="Name" HeaderText="Name" ItemStyle-Width="30%" SortExpression="Name"></asp:BoundColumn>
                    <asp:BoundColumn DataField="Description" HeaderText="Description" ItemStyle-Width="60%"
                        SortExpression="Description"></asp:BoundColumn>
                </Columns>
            </asp:DataGrid>
        </div>
        <!-- / -->
        <!-- Popup Footer -->
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnUpdatePatternOtherCategories" runat="server" class="btn btn-primary" type="submit"
                data-loading-text="Saving..." onserverclick="btnUpdatePatternOtherCategories_Click">
                Save Changes</button>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Pattern</h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Pattern?
            </p>
        </div>
        <!-- / -->
        <!-- Popup Footer -->
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" onserverclick="btnDelete_Click"
                data-loading-text="Deleting..." type="submit">
                Yes</button>
        </div>
        <!-- / -->
    </div>
    <div id="developmentHistoryModal" class="modal fade" data-backdrop="static" data-keyboard="false">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title">Save Changes To The Selected</h4>
                </div>
                <div class="modal-body">
                    <p class="modal-message">One fine body&hellip;</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" id="closeButton" data-dismiss="modal">Close</button>
                    <button class="btn btn-primary" data-dismiss="modal" id="savechangesButton" type="button">Save changes</button>
                </div>
            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
    </div>
    <!-- /.modal -->
    <!-- / -->
    <!-- Pattern Category Warning Message -->
    <div id="dvPatternOtherCategoryWarning" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Add Other Categories</h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <p>
                Please confirm you wish to proceed and add Other Categorie(s)?
            </p>
        </div>
        <!-- / -->
        <!-- Popup Footer -->
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSavePatternOtherCategories" runat="server" class="btn btn-primary"
                data-loading-text="Saving..." onserverclick="btnSavePatternOtherCategories_Click">
                Save Changes
            </button>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:LinkButton ID="btnHide" runat="server" Style="display: none;" OnClick="ancGarmentSpec_click" />
    <!-- Page Scripts -->
    <script type="text/javascript">
        var ShowSpec = ('<%=ViewState["ShowSpec"]%>' == 'True') ? true : false;
        var ShowPatternOtherCat = ('<%=ViewState["ShowPatternOtherCat"]%>' == 'True') ? true : false;
        var ShowConfirmPatternCat = ('<%=ViewState["ShowConfirmPatternCat"]%>' == 'True') ? true : false;
        var dvSpecGrd = "<%=dvSpecGrd.ClientID %>";
        var hdnSelectedPatternID = "<%=hdnSelectedPatternID.ClientID %>"
        var ddlConvert = "<%=ddlConvert.ClientID %>";
        var btnHide = "<%=btnHide.ClientID %>";
        var hdnPatternID = "<%=hdnPatternID.ClientID %>";
        //var dvPageNo = "< %=dvPageNo.ClientID %>";
        //var litMaxPageNo = "< %=litMaxPageNo.ClientID %>";
        //var lbdgHeader1Custome = "< %=lbdgHeader1Custome.ClientID %>";
        //var txtPage = "< %=txtPage.ClientID %>";
    </script>
    <script type="text/javascript">
        $(".checkhistoryLink").click(function () {
            var id = $(this).attr("data-developmentID");
            console.log(id);
            if (id.length < 1)
                return;
            $.ajax(
            {
                url: "ViewPatternDevelopment.aspx/GetHistory",
                type: "POST",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ id: id }),
                dataType: "json",
                async: true,
                success: function (v) {
                    var data = v.d;
                    if (data != null) {
                        $("#developmentHistoryModal").find(".modal-title").text("History Of Pattern Development - " + id);
                        $("#developmentHistoryModal").find(".modal-body").html(data);
                        $("#developmentHistoryModal").find("#savechangesButton").hide();
                        $("#developmentHistoryModal").find("#savechangesButton").click(function () { });
                        $("#developmentHistoryModal").find("#closeButton").click(function () { });
                        $("#developmentHistoryModal").modal("show");
                    }
                }
            });
        });
        $(document).ready(function () {
            $('.idelete').click(function () {
                $('#' + hdnSelectedPatternID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });

            $('#' + ddlConvert).change(function () {
                //$('#' + dvSpecGrd + ' .ioderlist-table').find("lblQty").each(function () {
                if ($('#' + ddlConvert).val() == 0) {
                    __doPostBack($('#' + btnHide).attr('name'), '');
                    $('#' + ddlConvert).find('option:selected').attr('selected', 'selected');
                    //$('#' + btnHide).click()

                }
                else {
                    $('#' + ddlConvert).find('option:selected').attr('selected', 'selected');
                    $('#' + ddlConvert).find('option:selected').prev('option').removeAttr('selected');
                }
                $('#olSpecGrd').find('.idouble').each(function () {
                    var qty = Number($(this)[0].innerHTML);
                    var convertType = Number($('#' + ddlConvert).val());

                    if (convertType == 1) {
                        //Convert to centimeter
                        var inches = Math.round(parseFloat(qty * 0.39).toFixed(2))
                        $(this)[0].innerHTML = inches;
                        //  $('#' + ddlConvert).find('option:selected').removeAttr('selected').next('option').attr('selected', 'selected');
                        //var cen = Math.round(parseFloat(qty * 2.54).toFixed(2))
                        //$(this)[0].innerHTML = cen;
                    }
                });

            });

            if (ShowSpec) {
                ShowGarmentSpec();
            }

            if (ShowPatternOtherCat) {
                ShowPatternOtherCategories();
            }

            if (ShowConfirmPatternCat) {
                ShowConfirmPatternCategories();
            }

            function ShowGarmentSpec() {
                window.setTimeout(function () {
                    $('#requestGarmentSpec').modal('show');
                }, 10);
            }

            function ShowPatternOtherCategories() {
                window.setTimeout(function () {
                    $('#dvPatternOtherCategories').modal('show');
                }, 10);
            }

            function ShowConfirmPatternCategories() {
                window.setTimeout(function () {
                    $('#dvPatternOtherCategoryWarning').modal('show');
                }, 10);
            }
        });
        $('.igspdf').click(function () {
            // $('#' + hdnPatternID).val($('.ispec').attr('qid'));
        });

        $('.iclick').click(function () {
            // $('#' + hdnPatternID).val($('.ispec').attr('qid'));
        });

        $('#' + txtPage).keyup(function () {
            var val = parseInt($('#' + litMaxPageNo)[0].innerHTML);
            var pageno = parseInt($(this).val());
            if (pageno > val) {
                $('#' + dvPageNo).attr('class', 'control-group error')
                $('#' + lbdgHeader1Custome).attr('disabled', 'disabled');
            }
            else {
                $('#' + dvPageNo).attr('class', 'control-group')
                $('#' + lbdgHeader1Custome).removeAttr("disabled");
            }
        });

        $('input').keyup(function (e) {
            if ($('#' + txtPage).val() != '') {
                if (e.which == 13) {
                    return false;
                }
            }
        });

        function CollapseAll(event) {
            var tableView = $find('<%=RadGridPattern.ClientID %>').get_masterTableView();
            var rows = tableView.get_element().rows;
            for (var i = 0, len = tableView.get_element().rows.length; i < len; i++) {
                var button = tableView._getGroupExpandButton(rows[i]);
                if (button) {
                    var groupLevel = button.id.split("__")[2];
                    if (groupLevel == 0) {
                        tableView._toggleGroupsExpand(button, event);
                    }
                }
            }
        }

        // printPattern();
        /*function printPattern(elementID) {
        var html = document.getElementById(elementID).innerHTML;
        var windowUrl = 'about:blank';
        var uniqueName = new Date();
        var windowName = 'Print' + uniqueName.getTime();
        var printWindow = window.open(windowUrl, windowName, 'left=100000,top=100000');
        printWindow.document.write('<html>');
        printWindow.document.write('<head>');        
        printWindow.document.write('<link href="/Content/css/styles.css" rel="stylesheet" type="text/css" />');
        printWindow.document.write('</head>');
        printWindow.document.write('<body>');
        printWindow.document.write(html);
        printWindow.document.write('</body>');
        printWindow.document.write('</html>');
        printWindow.document.close();
        printWindow.focus();
        printWindow.print();
        printWindow.close();
        }*/

        //function populateDiv(control) {
        //    var hero = $(control).attr('hero');
        //    var nohero_1 = $(control).attr('nohero_1');
        //    var nohero_2 = $(control).attr('nohero_2');
        //    var nohero_3 = $(control).attr('nohero_3');
        //    var windowUrl = 'about:blank';
        //    var uniqueName = new Date();
        //    var windowName = 'Preview' + uniqueName.getTime();
        //    var printWindow = window.open(windowUrl, windowName);
        //    printWindow.document.write('<html>');
        //    printWindow.document.write('<link href="/Content/css/styles.css" rel="stylesheet" type="text/css" />');
        //    printWindow.document.write('</head>');
        //    printWindow.document.write('<body>');
        //    printWindow.document.write('<div class="igarment">');
        //    printWindow.document.write('<img src="' + hero + '"/>');
        //    printWindow.document.write('</div>');
        //    printWindow.document.write('<div class="igarment">');
        //    printWindow.document.write('<img src="' + nohero_1 + '"/>');
        //    printWindow.document.write('</div>');
        //    printWindow.document.write('<div class="igarment">');
        //    printWindow.document.write('<img src="' + nohero_2 + '"/>');
        //    printWindow.document.write('</div>');
        //    printWindow.document.write('<div class="igarment">');
        //    printWindow.document.write('<img src="' + nohero_3 + '"/>');
        //    printWindow.document.write('</div>');
        //    printWindow.document.write('</body>');
        //    printWindow.document.write('/<html>');
        //}


    </script>
</asp:Content>
