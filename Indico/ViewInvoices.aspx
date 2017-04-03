<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewInvoices.aspx.cs" Inherits="Indico.ViewInvoices" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <%--  Header Text--%>
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddInvoice" runat="server" class="btn btn-link pull-right" href="~/AddEditInvoice.aspx">New Invoice</a>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div>
        <%-- Page content--%>
        <div class="page-content">
            <div class="inner">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h4>
                        <a id="aAddNewInvoice" runat="server" href="AddEditInvoice.aspx" title="Add an Invoice.">Add the first Invoice.</a>
                    </h4>
                    <p>
                        You can add as many Invoices as you like.
                    </p>
                </div>
                <!-- / -->
                <%-- Data Content--%>
                <div id="dvDataContent" runat="server">
                    <%-- Search Pannel--%>
                    <div class="search-control clearfix">
                        <asp:Panel ID="panlSearch" runat="server">
                            <asp:TextBox ID="SearchTextBox" runat="server" CssClass="search-control-query"
                                placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="OnSearchButtonClick"
                                CssClass="search-control-button"></asp:Button>
                        </asp:Panel>
                    </div>
                    <%--Data Grid--%>
                    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro"
                        EnableEmbeddedSkins="false">
                    </telerik:RadAjaxLoadingPanel>
                    <%-- <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadInvoice">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadInvoice"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="InvoiceGrid" runat="server" AllowPaging="true" AutoGenerateColumns="false"
                        Skin="Metro" CssClass="RadGrid_Rounded" ShowStatusBar="true" ShowGroupPanel="true" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AllowFilteringByColumn="true" OnItemCommand="OnInvoiceGridItemCommand" GridLines="None"
                        Visible="false" EnableEmbeddedBaseStylesheet="true" EnableEmbeddedSkins="true"
                        OnItemDataBound="OnInvoiceGridDataBound" AllowSorting="true" PageSize="20" OnPageIndexChanged="OnInvoiceGridPageIndexChanged"
                        OnGroupsChanging="OnInvoiceGridGroupChanging" OnSortCommand="OnInvoiceGridSortCommand">
                        <HeaderContextMenu OnItemClick="OnInvoiceGridHeaderContextMenuItemClick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView ShowFooter="true" ShowGroupFooter="true">
                            <Columns>
                                <telerik:GridDateTimeColumn DataField="InvoiceDate" HeaderText="Factory Invoice Date" FilterControlWidth="110px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true"
                                    SortExpression="InvoiceDate" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridBoundColumn UniqueName="InvoiceNo" SortExpression="InvoiceNo" HeaderText="Factory Invoice No." CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    FilterControlWidth="50px" DataField="InvoiceNo">
                                </telerik:GridBoundColumn>
                                <telerik:GridDateTimeColumn DataField="ETD" HeaderText="ETD" FilterControlWidth="110px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true"
                                    SortExpression="ETD" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridBoundColumn UniqueName="ShipTo" SortExpression="ShipTo" HeaderText="Ship To" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true"
                                    FilterControlWidth="110px" DataField="ShipTo">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="ShipmentMode" SortExpression="ShipmentMode" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true"
                                    FilterControlWidth="110px" HeaderText="Shipment Mode" DataField="ShipmentMode">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="AWBNo" SortExpression="AWBNo" HeaderText="AWB No." CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true"
                                    FilterControlWidth="110px" DataField="AWBNo">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="BillTo" SortExpression="BillTo" HeaderText="Bill To" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    FilterControlWidth="100px" DataField="BillTo">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="Status" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="litStatus" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="Qty" HeaderText="Qty" DataField="Qty" AllowFiltering="false" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true" Aggregate="Sum" DataFormatString="{0}">
                                </telerik:GridBoundColumn>
                                <telerik:GridNumericColumn UniqueName="FactoryTotal" SortExpression="FactoryTotal" HeaderText="Amount" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="FactoryTotal">
                                </telerik:GridNumericColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link" ToolTip="Edit Invoice"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="linkCreIndiInvoice" runat="server" CssClass="btn-link iremove" ToolTip="Create Indiman Invoice"><i class="icon-pencil"></i>Create Indiman Invoice</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:LinkButton ID="btnInvoiceDetail" runat="server" CssClass="btn-link" OnClick="btnPrintInvoiceDetail_Click" ToolTip="Print Invoice Detail"><i class="icon-download-alt"></i>Print Invoice Detail</asp:LinkButton>
                                                </li>
                                                <li>
                                                    <asp:LinkButton ID="btnInvoiceSummary" runat="server" CssClass="btn-link" OnClick="btnPrintInvoiceSummary_Click" ToolTip="Print Invoice Summary"><i class="icon-download-alt"></i>Print Invoice Summary</asp:LinkButton>
                                                </li>
                                                <li>
                                                    <asp:LinkButton ID="btnCombineInvoice" runat="server" CssClass="btn-link" OnClick="btnCombineInvoice_Click" ToolTip="Print Combined Invoice"><i class="icon-download-alt"></i>Print Combined Invoice</asp:LinkButton>
                                                </li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="True">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="true" />
                    </telerik:RadGrid>
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> did not match
                            any Invoice.</h4>
                    </div>
                    <!-- / -->
                </div>
            </div>
        </div>
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Invoice</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this invoice?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-danger" type="submit" onserverclick="btnDelete_Click"
                data-loading-text="Deleting...">
                Yes</button>
        </div>
    </div>
    <asp:Button ID="btnPrintInvoice" runat="server" OnClick="btnPrintInvoiceDetail_Click"
        Style="display: none;" />
    <asp:Button ID="btnPrintInvoiceSummary" runat="server" OnClick="btnPrintInvoiceSummary_Click"
        Style="display: none;" />
    <asp:Button ID="btnCombineInvoice" runat="server" OnClick="btnCombineInvoice_Click"
        Style="display: none;" />
    <script type="text/javascript">
        var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
        var txtSearchInvoiceNo = "<%=SearchTextBox.ClientID %>";
        var btnSearch = "<%=btnSearch.ClientID %>";
        var btnPrintInvoice = "<%=btnPrintInvoice.ClientID %>";
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var btnPrintInvoiceSummary = "<%=btnPrintInvoiceSummary.ClientID %>";
        var btnCombineInvoice = "<%=btnCombineInvoice.ClientID %>";       
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });

            $('#' + txtSearchInvoiceNo).keypress(function (e) {
                if (e.which == 13) {
                    $('#' + btnSearch).click();
                }
            });

            $('.iprintinginvdetail').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                $('#' + btnPrintInvoice).click();
            });

            $('.iprintinginvsummary').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                $('#' + btnPrintInvoiceSummary).click();
            });

            $('.iprintingcombine').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                $('#' + btnCombineInvoice).click();
            });
        });
    </script>
</asp:Content>
