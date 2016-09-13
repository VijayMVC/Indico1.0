<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewBackOrders.aspx.cs" Inherits="Indico.ViewBackOrders" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
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
                    <h4>No back orders added for this week</h4>
                </div>
                <!-- / -->
                <%--Data Content--%>
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
                    <%-- <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadGridBackOrders">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridBackOrders"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridBackOrders" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="false" OnPageSizeChanged="RadGridBackOrders_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridBackOrders_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridBackOrders_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridBackOrders_ItemCommand"
                        OnSortCommand="RadGridBackOrders_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Distributor" SortExpression="Distributor" HeaderText="Distributor" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="100px" DataField="Distributor">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Coordinator" SortExpression="Coordinator" HeaderText="Coordinator" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Coordinator">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="Coordinator E-mail" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtCoordinatorEmail" runat="server"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="Qty" SortExpression="Qty" HeaderText="Qty" ItemStyle-Width="50px" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true" DataField="Qty">
                                </telerik:GridBoundColumn>
                                <telerik:GridCheckBoxColumn UniqueName="BackOrder" HeaderText="Is Back Order" DataField="BackOrder" ItemStyle-Width="100px" FilterControlWidth="10px" AllowFiltering="false" ItemStyle-CssClass="rfdCheckboxChecked" ItemStyle-HorizontalAlign="Center" AllowSorting="true">
                                </telerik:GridCheckBoxColumn>
                                <telerik:GridTemplateColumn HeaderText="Distributor E-mail" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtDistributorEmail" runat="server"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Email Sent" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="litEmailSent" runat="server"></asp:Literal>
                                        <asp:HiddenField ID="hdnWeekLyID" runat="server" />
                                        <asp:HiddenField ID="hdnSendMail" runat="server" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:LinkButton ID="btnSendMail" runat="server" CssClass="btn-link" ToolTip="Send Mail" OnClick="btnSendMail_Click"><i class="icon-envelope"></i>Send Mail</asp:LinkButton>
                                                </li>
                                                <li>
                                                    <asp:LinkButton ID="btnSave" runat="server" CssClass="btn-link" ToolTip="Save" OnClick="btnSave_Click"><i class="icon-trash"></i>Save</asp:LinkButton>
                                                </li>
                                                <li>
                                                    <asp:LinkButton ID="btnDownloadBackOrder" runat="server" CssClass="btn-link" ToolTip="Download Back Order" OnClick="btnDownloadBackOrder_Click"><i class="icon-download-alt"></i>Download Back Order</asp:LinkButton>
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
                    <%--<asp:DataGrid ID="dataGridAgeGroup" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dataGridAgeGroup_ItemDataBound" OnPageIndexChanged="dataGridAgeGroup_PageIndexChanged"
                        OnSortCommand="dataGridAgeGroup_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="Name" HeaderText="Name" SortExpression="Name"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Description" HeaderText="Description" SortExpression="Description"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Age Group"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                            <li>
                                                <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Age Group"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
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
                </div>
                <!-- / -->
            </div>
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedAgeGroupID" runat="server" Value="0" />
    <!-- Add / Edit Item -->

    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Age Group</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Age Group?
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <%-- <button id="btnDelete" runat="server" class="btn btn-primary" onserverclick="btnDelete_Click"
                data-loading-text="Deleting..." type="submit">
                Yes</button>--%>
        </div>
    </div>
    <!-- / -->
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var hdnSelectedID = "<%=hdnSelectedAgeGroupID.ClientID %>";
    </script>
    <script type="text/javascript">
        /* $(document).ready(function () {
             $('.iadd').click(function () {
                 resetFieldsDefault('requestAddEdit');
                 AgeGroupAddEdit(this, true);
             });
 
             $('.iedit').click(function () {
                 fillText(this);
                 AgeGroupAddEdit(this, false);
             });
 
             $('.idelete').click(function () {
                 $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                 $('#requestDelete').modal('show');
             });
 
             if (!IsPageValid) {
                 window.setTimeout(function () {
                     $('#requestAddEdit').modal('show');
                 }, 10);
             }
 
             function AgeGroupAddEdit(o, n) {
                 $('div.alert-danger, span.error').hide();
                 $('#requestAddEdit div.modal-header h3 span')[0].innerHTML = (n ? 'Add Age Group' : 'Edit Age Group');
                 $('#' + btnSaveChanges)[0].innerHTML = (n) ? 'Save Changes' : 'Update';
                 $('#' + hdnSelectedID).val(n ? '0' : $(o).attr('qid'));
                 $('#requestAddEdit').modal('show');
             }
 
             function fillText(o) {
                 $('#' + agegroupmName)[0].value = $(o).parents('tr').children('td')[0].innerHTML;
                 $('#' + agegroupDescription)[0].value = (($(o).parents('tr').children('td')[1].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[1].innerHTML);
             }
         });*/
    </script>
</asp:Content>
