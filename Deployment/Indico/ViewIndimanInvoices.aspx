<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewIndimanInvoices.aspx.cs" Inherits="Indico.ViewIndimanInvoices" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <link href="Content/img/Telerik/Grid.Metro.css" rel="stylesheet" />
    <link href="Content/img/Telerik/Ajax.Metro.css" rel="stylesheet" />
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <%--  Header Text--%>
        <div class="page-header">
            <%--<div class="header-actions">
                <a id="btnAddInvoice" runat="server" class="btn btn-link pull-right" href="~/AddEditInvoice.aspx">
                    New Invoice</a>
            </div>--%>
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
                        <asp:Literal ID="litNoInvoice" runat="server">No Invoices added</asp:Literal></h4>
                </div>
                <!-- / -->
                <%-- Data Content--%>
                <div id="dvDataContent" runat="server">
                    <%-- Search Pannel--%>
                    <div class="search-control clearfix">
                        <asp:Panel ID="panlSearch" runat="server">
                            <asp:TextBox ID="txtSearchInvoiceNo" runat="server" CssClass="search-control-query"
                                placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click"
                                CssClass="search-control-button"></asp:Button>
                        </asp:Panel>
                    </div>
                    <%--Data Grid--%>
                    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro"
                        EnableEmbeddedSkins="false">
                    </telerik:RadAjaxLoadingPanel>
                    <%--   <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadInvoice">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadInvoice"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadIndimanInvoice" runat="server" AllowPaging="true" AllowSorting="true" AutoGenerateColumns="false"
                        Skin="Metro" CssClass="RadGrid_Rounded" ShowStatusBar="true" ShowGroupPanel="true" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AllowFilteringByColumn="true" OnItemCommand="RadIndimanInvoice_ItemCommand" GridLines="None"
                        Visible="false" EnableEmbeddedBaseStylesheet="true" EnableEmbeddedSkins="true"
                        OnItemDataBound="RadIndimanInvoice_ItemDataBound" PageSize="20" OnPageIndexChanged="RadIndimanInvoice_PageIndexChanged"
                        OnGroupsChanging="RadIndimanInvoice_GroupsChanging" OnSortCommand="RadIndimanInvoice_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
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
                                <telerik:GridBoundColumn UniqueName="IndimanInvoiceNo" SortExpression="IndimanInvoiceNo" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    FilterControlWidth="50px" HeaderText="Indiman Invoice No." DataField="IndimanInvoiceNo">
                                </telerik:GridBoundColumn>
                                <telerik:GridDateTimeColumn DataField="IndimanInvoiceDate" HeaderText="Indiman Invoice Date" FilterControlWidth="110px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true"
                                    SortExpression="IndimanInvoiceDate" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridBoundColumn UniqueName="InvoiceDate" SortExpression="InvoiceDate" HeaderText="Factory Invoice Date" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    FilterControlWidth="110px" DataField="InvoiceDate">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="ShipTo" SortExpression="ShipTo" HeaderText="Ship To" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    FilterControlWidth="110px" DataField="ShipTo">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="ShipmentMode" SortExpression="ShipmentMode" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    FilterControlWidth="110px" HeaderText="Shipment Mode" DataField="ShipmentMode">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="AWBNo" SortExpression="AWBNo" HeaderText="AWB No." CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    FilterControlWidth="110px" DataField="AWBNo">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Qty" HeaderText="Qty" DataField="Qty" AllowFiltering="false" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Aggregate="Sum" DataFormatString="{0}">
                                </telerik:GridBoundColumn>
                                <telerik:GridNumericColumn UniqueName="IndimanTotal" SortExpression="IndimanTotal" HeaderText="Amount" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="IndimanTotal">
                                </telerik:GridNumericColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iremove" ToolTip="Edit Invoice"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:LinkButton ID="btnIndimanInvoice" runat="server" CssClass="btn-link" OnClick="btnIndimanInvoice_Click" ToolTip="Print Indiman Invoice"><i class="icon-download-alt"></i>Print Indiman Invoice</asp:LinkButton>
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
                            any Indiman Invoice.</h4>
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
            <h3>Delete Indiman Invoice</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this indiman invoice?
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
    <asp:Button ID="btnIndimanInvoice" runat="server" OnClick="btnIndimanInvoice_Click"
        Style="display: none;" />
    <script type="text/javascript">
        var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
        var txtSearchInvoiceNo = "<%=txtSearchInvoiceNo.ClientID %>";
        var btnSearch = "<%=btnSearch.ClientID %>";
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var btnIndimanInvoice = "<%=btnIndimanInvoice.ClientID %>";
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

            $('.iprintindimaninvoice').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                $('#' + btnIndimanInvoice).click();
            });
        });
    </script>
</asp:Content>
