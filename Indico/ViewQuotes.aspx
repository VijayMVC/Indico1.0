<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewQuotes.aspx.cs" Inherits="Indico.ViewQuotes" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddQuote" runat="server" class="btn btn-link pull-right" href="~/AddEditQuote.aspx">New Quote</a>
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
                        <a href="AddEditQuote.aspx" title="Add an Orders.">Add the first Quote.</a>
                    </h4>
                    <p>
                        You can add as many Quotes as you like.
                    </p>
                </div>
                <!-- / -->
                <!--Data Content-->
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <div class="form-inline pull-right">
                            <label>
                                Filter by Status</label>
                            <asp:DropDownList ID="ddlSortStatus" CssClass="input-small" runat="server" AutoPostBack="True"
                                OnSelectedIndexChanged="ddlSortBy_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
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
                    <telerik:RadGrid ID="RadGridQuotes" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadGridQuotes_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridQuotes_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridQuotes_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnGroupsChanging="RadGridQuotes_GroupsChanging" OnItemCommand="RadGridQuotes_ItemCommand"
                        OnSortCommand="RadGridQuotes_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <GroupingSettings CaseSensitive="false" />
                        <MasterTableView AllowFilteringByColumn="true" GroupsDefaultExpanded="false">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Quote" SortExpression="Quote" HeaderText="Quote" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    FilterControlWidth="50px" DataField="Quote">
                                </telerik:GridBoundColumn>
                                <telerik:GridDateTimeColumn DataField="DateQuoted" HeaderText="Date Quoted" FilterControlWidth="110px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true"
                                    SortExpression="DateQuoted" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridBoundColumn UniqueName="Creator" SortExpression="Creator" HeaderText="From" CurrentFilterFunction="Contains"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true" DataField="Creator">
                                </telerik:GridBoundColumn>
                                <telerik:GridDateTimeColumn DataField="QuoteExpiryDate" HeaderText="Expiry Date" FilterControlWidth="110px" CurrentFilterFunction="EqualTo" AutoPostBackOnFilter="true"
                                    SortExpression="QuoteExpiryDate" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridBoundColumn UniqueName="JobName" SortExpression="JobName" HeaderText="JobName" CurrentFilterFunction="Contains"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true"
                                    DataField="JobName">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="Status" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblStatus" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false" Visible="false">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="linkViewQuotes" runat="server" CssClass="btn-link ispec" ToolTip="View Quote" Text="View Quote" OnClick="linkViewQuotes_OnClick"><i class="icon-th-list"></i></asp:LinkButton>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:LinkButton ID="lbResendMail" runat="server" Text="Resend Mail" CssClass="btn-link iupdate" ToolTip="Resend Mail" OnClick="lbResendMail_OnClick" Visible="false"><i class="icon-repeat"></i>Resend Mail</asp:LinkButton>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Quote"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:HyperLink data-toggle="tooltip" data-original-title="Delete Quote" ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip=""><i class="icon-trash"></i>Delete</asp:HyperLink>
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
                    <%--<asp:DataGrid ID="dgQuotes" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dgQuotes_ItemDataBound" OnPageIndexChanged="dgQuotes_PageIndexChanged"
                        OnSortCommand="dgQuotes_SortCommand">
                        <HeaderStyle CssClass="header" />   
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="ID" HeaderText="No." SortExpression="ID"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Quoted" SortExpression="DateQuoted">
                                <ItemTemplate>
                                    <asp:Literal ID="lblDateQuoted" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="From">
                                <ItemTemplate>
                                    <asp:Literal ID="lblFrom" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="To">
                                <ItemTemplate>
                                    <asp:Literal ID="lblTo" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Expiry Date" SortExpression="QuoteExpiryDate">
                                <ItemTemplate>
                                    <asp:Literal ID="lblQuoteExpiryDate" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Job Name" SortExpression="JobName">
                                <ItemTemplate>
                                    <asp:Literal ID="lblJobName" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Pattern" SortExpression="Pattern">
                                <ItemTemplate>
                                    <asp:Literal ID="lblPattern" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Fabric" SortExpression="Fabric">
                                <ItemTemplate>
                                    <asp:Literal ID="lblFabric" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Status" SortExpression="Status">
                                <ItemTemplate>
                                    <asp:Literal ID="lblStatus" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="View">
                                <ItemTemplate>
                                    <asp:LinkButton ID="linkViewQuotes" runat="server" CssClass="btn-link ispec" ToolTip="View Quote"
                                        Text="View Quote" OnClick="linkViewQuotes_OnClick"><i class="icon-th-list"></i></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:LinkButton ID="lbResendMail" runat="server" Text="Resend Mail" CssClass="btn-link iupdate"
                                                    ToolTip="Resend Mail" OnClick="lbResendMail_OnClick" Visible="false"><i class="icon-repeat"></i>Resend Mail
                                                </asp:LinkButton></li>
                                            <li>
                                                <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Quote"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                            <li>
                                                <asp:HyperLink data-toggle="tooltip" data-original-title="Delete Quote" ID="linkDelete"
                                                    runat="server" CssClass="btn-link idelete" ToolTip=""><i class="icon-trash"></i>Delete</asp:HyperLink></li>
                                        </ul>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>--%>
                    <!-- / -->
                </div>
                <!-- / -->
                <!-- No Search Result -->
                <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                    <h4>Your search - <strong>
                        <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> did not match
                        any quote.</h4>
                </div>
                <!-- / -->
            </div>
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- View Quote Details -->
    <div id="requestViewQuotes" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
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
            <fieldset>
                <div class="control-group">
                    <label class="control-label">
                        Contact Name</label>
                    <div class="controls">
                        <asp:TextBox ID="lblContactName" runat="server" disabled></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Job Name
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="lblJobName" runat="server" disabled></asp:TextBox>
                    </div>
                </div>
                <div id="liItem" runat="server" class="control-group">
                    <label class="control-label">
                        Item</label>
                    <div class="controls">
                        <asp:TextBox ID="lblPattern" runat="server" disabled></asp:TextBox>
                    </div>
                </div>
                <div id="liFabric" runat="server" class="control-group">
                    <label class="control-label">
                        Fabric</label>
                    <div class="controls">
                        <asp:TextBox ID="lblFabricCode" runat="server" disabled></asp:TextBox>
                    </div>
                </div>
                <div id="liPrice" runat="server" class="control-group">
                    <label class="control-label">
                        Indiman Price</label>
                    <div class="controls">
                        <asp:TextBox ID="lblIndimanPrice" runat="server" disabled></asp:TextBox>
                    </div>
                </div>
                <div id="liquantity" runat="server" class="control-group">
                    <label class="control-label">
                        Indicated Quantity</label>
                    <div class="controls">
                        <asp:TextBox ID="lblQuantity" runat="server" disabled></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Approx. despatch Date</label>
                    <div class="controls">
                        <asp:TextBox ID="lblDiliveryDate" runat="server" disabled></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Date Quoted</label>
                    <div class="controls">
                        <asp:TextBox ID="lblQuotedDate" runat="server" disabled></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Expire On</label>
                    <div class="controls">
                        <asp:TextBox ID="lblExpiryDate" runat="server" disabled></asp:TextBox>
                    </div>
                </div>
                <div id="liNotes" runat="server" class="control-group">
                    <label class="control-label">
                        Notes</label>
                    <div class="controls">
                        <asp:TextBox ID="lblNotes" runat="server" disabled></asp:TextBox>
                    </div>
                </div>
                <div id="liDistributor" runat="server" class="control-group">
                    <label class="control-label">
                        Distributor</label>
                    <div class="controls">
                        <asp:TextBox ID="lblDistributor" runat="server" disabled></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Status</label>
                    <div class="controls">
                        <asp:TextBox ID="lblStatus" runat="server" disabled></asp:TextBox>
                    </div>
                </div>
            </fieldset>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedPatternAccessoryID" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Quote</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Quote?
            </p>
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
        var populateViewQuote = ('<%=ViewState["populateViewQuote"]%>' == 'True') ? true : false;
        var hdnSelectedID = "<%=hdnSelectedPatternAccessoryID.ClientID %>";
        var txtSearch = "<%=txtSearch.ClientID %>";
        var btnSearch = "<%=btnSearch.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {

            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show')
            });

            if (populateViewQuote) {
                $('#requestViewQuotes').modal('show')
            }
            $('#' + txtSearch).keypress(function (e) {
                if (e.which == 13) {
                    $('#' + btnSearch).click();
                }
            });
        });
    </script>
</asp:Content>
