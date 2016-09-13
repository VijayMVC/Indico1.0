<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewWeeklyCapacities.aspx.cs"
    Inherits="Indico.ViewWeeklyCapacities" MasterPageFile="~/Indico.Master" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <asp:ScriptManager ID="PatternScriprtManaget" runat="server">
    </asp:ScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
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
                        <a href="<%--javascript:PopulateThisYearProductionCapacity(true);--%>" title="Weekly Capacities.">Weekly Capacities.</a>
                    </h4>
                    <p>
                        There are no data for Weekly capacities
                    </p>
                </div>
                <!-- / -->
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <div class="form-inline pull-right">
                            <label>Average</label>
                            <asp:TextBox ID="txtEstimatedValue" CssClass="input-small" Text="25" runat="server"></asp:TextBox>
                            <button id="btnCalulate" runat="server" class="btn-inverse" onserverclick="btnCalulate_ServerClick" type="submit">GO</button>
                            <label>
                                From</label>
                            <asp:DropDownList ID="ddlMonth" runat="server" AutoPostBack="True" CssClass="input-medium"
                                OnSelectedIndexChanged="ddlMonth_SelectedIndexChanged">
                            </asp:DropDownList>
                            <asp:DropDownList ID="ddlYear" runat="server" AutoPostBack="True" CssClass="input-small"
                                OnSelectedIndexChanged="ddlYear_SelectedIndexChanged">
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
                    <telerik:RadGrid ID="RadGridWeeklySummary" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="false" OnPageSizeChanged="RadGridWeeklySummary_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridWeeklySummary_PageIndexChanged" ShowFooter="false"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridWeeklySummary_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridWeeklySummary_ItemCommand"
                        OnSortCommand="RadGridWeeklySummary_SortCommand">
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <HeaderStyle BorderWidth="1px" />
                        <MasterTableView AllowFilteringByColumn="true">
                            <ColumnGroups>
                                <telerik:GridColumnGroup HeaderText="Units (pieces)" Name="Units" HeaderStyle-HorizontalAlign="Center">
                                </telerik:GridColumnGroup>
                                <telerik:GridColumnGroup HeaderText="Shirts & Other" Name="Polos" HeaderStyle-HorizontalAlign="Center" ParentGroupName="Units">
                                </telerik:GridColumnGroup>
                                <telerik:GridColumnGroup HeaderText="Outerwear" Name="Jackets" HeaderStyle-HorizontalAlign="Center" ParentGroupName="Units">
                                </telerik:GridColumnGroup>
                                <telerik:GridColumnGroup HeaderText="Total Units" Name="Total" HeaderStyle-HorizontalAlign="Center" ParentGroupName="Units">
                                </telerik:GridColumnGroup>
                            </ColumnGroups>
                            <Columns>
                                <telerik:GridTemplateColumn HeaderText="Week #/ Year" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:HyperLink Target="_blank" ID="linkWeekYear" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridDateTimeColumn DataField="WeekendDate" HeaderText="Friday of the week" Groupable="false"
                                    SortExpression="WeekendDate" PickerType="DatePicker" EnableTimeIndependentFiltering="true" FilterControlWidth="100px"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridTemplateColumn HeaderText="Firm" AllowFiltering="false" ColumnGroupName="Polos">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkFirm" runat="server"><i class="icon-th-list"></i></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Reservation" AllowFiltering="false" ColumnGroupName="Polos">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkReservations" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Total" AllowFiltering="false" ColumnGroupName="Polos">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkTotal" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="On Hold" AllowFiltering="false" ColumnGroupName="Polos">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkHold" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Capacities" AllowFiltering="false" ColumnGroupName="Polos">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtCapacity" runat="server" CssClass="input-mini text-center"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Balance" AllowFiltering="false" ColumnGroupName="Polos">
                                    <ItemTemplate>
                                        <asp:Label ID="lblBalance" runat="server"></asp:Label>
                                        <%--<asp:HyperLink ID="linkBalance" runat="server"></asp:HyperLink>--%>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="<=5 Items Orders" AllowFiltering="false" ColumnGroupName="Polos">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linklessfiveitems" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <%--<telerik:GridTemplateColumn HeaderText="Jacket Orders" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkJackets" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>--%>
                                <telerik:GridTemplateColumn HeaderText="Sample Orders" AllowFiltering="false" ColumnGroupName="Polos">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkSamples" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>

                                <%--Jacket columns --%>

                                <telerik:GridTemplateColumn HeaderText="Firm" AllowFiltering="false" ColumnGroupName="Jackets">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkJacketFirm" runat="server"><i class="icon-th-list"></i></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Reservation" AllowFiltering="false" ColumnGroupName="Jackets">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkJacketReservations" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Total" AllowFiltering="false" ColumnGroupName="Jackets">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkJacketTotal" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="On Hold" AllowFiltering="false" ColumnGroupName="Jackets">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkJacketHold" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Capacities" AllowFiltering="false" ColumnGroupName="Jackets">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtJacketCapacity" runat="server" CssClass="input-mini text-center"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Balance" AllowFiltering="false" ColumnGroupName="Jackets">
                                    <ItemTemplate>
                                        <asp:Label ID="lblJacketBalance" runat="server"></asp:Label>
                                        <%--<asp:HyperLink ID="linkBalance" runat="server"></asp:HyperLink>--%>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="<=5 Items Orders" AllowFiltering="false" ColumnGroupName="Jackets">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkJacketlessfiveitems" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Sample Orders" AllowFiltering="false" ColumnGroupName="Jackets">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkJacketSamples" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>

                                <telerik:GridTemplateColumn HeaderText="Firm" AllowFiltering="false" ColumnGroupName="Total">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkTotalFirm" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Capacity" AllowFiltering="false" ColumnGroupName="Total">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkTotalCapacity" runat="server"></asp:HyperLink>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>

                                <telerik:GridTemplateColumn HeaderText="Holidays" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtHolidays" runat="server" CssClass="input-mini text-center"></asp:TextBox>
                                        <asp:HiddenField ID="hdnWeekendDate" runat="server" Value="" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Sales Target" FilterControlWidth="50px" DataField="SalesTarget" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtSalesTarget" runat="server" CssClass="input-small text-center"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Estimated Target" FilterControlWidth="25px" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="litEstimatedValue" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Balance Value" FilterControlWidth="25px" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:Label ID="lblBalanceValue" runat="server"></asp:Label>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:LinkButton ID="linkPackingList" runat="server" title="Create Packing List" ToolTip="Create Packing Plan"><i class="icon-pencil"></i>Create Packing Plan</asp:LinkButton>
                                                </li>
                                                <li id="liViewPacking" runat="server">
                                                    <asp:LinkButton ID="lnkViewPackingList" runat="server" title="Create Packing List" ToolTip="Create Packing List"><i class="icon-eye-open"></i>View Packing List</asp:LinkButton>
                                                </li>
                                                <li>
                                                    <asp:LinkButton ID="linkEditCapacity" runat="server" title="Save Capacity" ToolTip="Save Capacity" OnClick="linkEditCapacity_Click"><i class="icon-edit"></i>Save</asp:LinkButton>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="linkWeekDetails" runat="server" ToolTip="View Week Details"><i class="icon-list-alt"></i>Week Details</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="linkSummary" runat="server" ToolTip="View Week Summary Details"><i class="icon-align-justify"></i>Week Summary</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="linkInvoice" runat="server" ToolTip="Create Invoice" Visible="true"><i class="icon-plus"></i>Create Invoice</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="linkViewInvoice" runat="server" ToolTip="View Invoice"><i class="icon-th-list"></i>View Invoice</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:LinkButton ID="btnCreateBatchLabel" runat="server" ToolTip="Print Batch Labels" OnClick="btnCreateBatchLabel_Click"><i class="icon-download-alt"></i>Print Batch Labels</asp:LinkButton>
                                                </li>
                                                <li>
                                                    <asp:LinkButton ID="btnCreateShippingDetail" runat="server" ToolTip="Print Shipping Details" OnClick="btnCreateShippingDetail_Click"><i class="icon-download-alt"></i>Print Shipping Details</asp:LinkButton>
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
                    <%--<asp:DataGrid ID="dgWeeklySummary" runat="server" CssClass="table" AutoGenerateColumns="false"
                        AllowSorting="true" GridLines="None" AllowPaging="True" PageSize="20" AllowCustomPaging="False"
                        OnItemDataBound="dgWeeklySummary_ItemDataBound" OnPageIndexChanged="dgWeeklySummary_PageIndexChanged"
                        OnSortCommand="dgWeeklySummary_SortCommand" OnItemCommand="dgPackingList_ItemCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:TemplateColumn HeaderText="Week #/ Year" SortExpression="WeekNo">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkWeekYear" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Weekend Date" SortExpression="WeekendDate">
                                <ItemTemplate>
                                    <asp:Literal ID="lblWeekEnd" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Firm Quantities">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkFirm" runat="server"><i class="icon-th-list"></i></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Reservation Quantities">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkReservations" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Total Quantities">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkTotal" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="On Hold">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkHold" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Capacities" SortExpression="Capacity">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtCapacity" runat="server" CssClass="input-mini text-center"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Balance Quantities">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkBalance" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="<=5 Items Orders">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linklessfiveitems" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Jacket Orders">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkJackets" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Sample Orders">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkSamples" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Holidays">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtHolidays" runat="server" CssClass="input-mini text-center"></asp:TextBox>
                                    <asp:HiddenField ID="hdnWeekendDate" runat="server" Value="" />
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:LinkButton ID="linkPackingList" runat="server" title="Create Packing List" ToolTip="Create Packing Plan"><i class="icon-pencil"></i>Create Packing Plan</asp:LinkButton>
                                            </li>
                                            <li id="liViewPacking" runat="server">
                                                <asp:LinkButton ID="lnkViewPackingList" runat="server" title="Create Packing List"
                                                    ToolTip="Create Packing List"><i class="icon-eye-open"></i>View Packing List</asp:LinkButton>
                                            </li>
                                            <li>
                                                <asp:LinkButton ID="linkEditCapacity" runat="server" title="Save Capacity" ToolTip="Save Capacity"
                                                    OnClick="linkEditCapacity_Click"><i class="icon-edit"></i>Save</asp:LinkButton>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="linkWeekDetails" runat="server" ToolTip="View Week Details"><i class="icon-list-alt"></i>Week Details</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="linkSummary" runat="server" ToolTip="View Week Summary Details"><i class="icon-align-justify"></i>Week Summary</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="linkInvoice" runat="server" ToolTip="Create Invoice" Visible="false"><i class="icon-plus"></i>Create Invoice</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="linkViewInvoice" runat="server" ToolTip="View Invoice"><i class="icon-th-list"></i>View Invoice</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:LinkButton ID="btnCreateBatchLabel" runat="server" ToolTip="Print Batch Labels"
                                                    OnClick="btnCreateBatchLabel_Click"><i class="icon-download-alt"></i>Print Batch Labels</asp:LinkButton>
                                            </li>
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
                        <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                        any documents.</h4>
                </div>
                <!-- / -->
            </div>
            <!-- / -->
        </div>
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedWeeklySummaryID" runat="server" Value="0" />
    <!-- Add / Edit Weekly Capacities -->
    <div id="requestAddEditWeeklyCapacities" class="modal" style="display: none;">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                &times;</button>
            <h2>
                <asp:Label ID="lblPopupHeaderText" runat="server" Text="New Topic"></asp:Label>
            </h2>
        </div>
        <!-- / -->
        <!-- Popup Validation -->
        <div id="dvPageValidation" runat="server" class="message error" visible="false">
            <h4>Errors were encountered while trying to process the form below:
            </h4>
            <asp:ValidationSummary ID="validationSummary" runat="server" ValidationGroup="vgProductCapacity"></asp:ValidationSummary>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <fieldset class="panel" style="margin: 0; padding: 0; background: transparent; border: 0;">
                <ol>
                    <li>
                        <label>
                            Firm</label>
                        <asp:TextBox ID="txtFirm" runat="server" MaxLength="128"></asp:TextBox>
                    </li>
                    <li>
                        <label>
                            Reservations</label>
                        <asp:TextBox ID="txtRes" runat="server" MaxLength="128"></asp:TextBox>
                    </li>
                    <li>
                        <label>
                            Total</label>
                        <asp:TextBox ID="txtTotal" runat="server" MaxLength="128"></asp:TextBox>
                    </li>
                    <li>
                        <label>
                            Hold</label>
                        <asp:TextBox ID="txtHold" runat="server" MaxLength="128"></asp:TextBox>
                    </li>
                    <li>
                        <label>
                            Balance</label>
                        <asp:TextBox ID="txtBal" runat="server" MaxLength="128"></asp:TextBox>
                    </li>
                    <li>
                        <label>
                            =<5 Items</label>
                        <asp:TextBox ID="txtCompare" runat="server" MaxLength="128"></asp:TextBox>
                    </li>
                    <li>
                        <label>
                            Jackets</label>
                        <asp:TextBox ID="txtjkts" runat="server" MaxLength="128"></asp:TextBox>
                    </li>
                    <li>
                        <label>
                            Samples</label>
                        <asp:TextBox ID="txtsmpls" runat="server" MaxLength="128"></asp:TextBox>
                    </li>
                    <li>
                        <label>
                            Holidays</label>
                        <asp:TextBox ID="txtHoliday" runat="server" MaxLength="128"></asp:TextBox>
                    </li>
                </ol>
            </fieldset>
        </div>
        <div class="modal-footer">
            <asp:Button ID="btnSaveChanges" runat="server" CssClass="btn iblue firePopupSave"
                OnClick="btnSaveChanges_Click" Text="Save Changes" Url="/ViewWeeklyCapacities.aspx"
                ValidationGroup="vgProductCapacity" />
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var IsValied = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var hdnSelectedWeeklySummaryID = "<%=hdnSelectedWeeklySummaryID.ClientID %>";
        var txtFirm = "<%=txtFirm.ClientID %>";
        var txtRes = "<%=txtRes.ClientID %>";
        var txtHold = "<%=txtHold.ClientID %>";
        var txtTotal = "<%=txtTotal.ClientID %>";
        var txtBal = "<%=txtBal.ClientID %>";
        var txtCompare = "<%=txtCompare.ClientID %>";
        var txtjkts = "<%=txtjkts.ClientID %>";
        var txtsmpls = "<%=txtsmpls.ClientID %>";
        var txtHoliday = "<%=txtHoliday.ClientID %>";

    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $(document).ready(function () {
                if (!IsValied) {
                    window.setTimeout(function () {
                        showPopupBox('requestAddEditWeeklyCapacities', '600');
                    }, 10);
                }

                //        $('.iedit').click(function () {
                //            WeeklyCapacitiesAddEdit(this, false);
                //        });


                function WeeklyCapacitiesAddEdit(o, n) {
                    //Hide the validation summary
                    $('div.error, span.error').hide();
                    //Set the popup header text
                    $('#requestAddEditWeeklyCapacities div.modal-header h2 span')[0].innerHTML = (n ? 'New Weekly Summary' : 'Edit Weekly Summary');
                    //Set the popup save button text
                    $('#requestAddEditWeeklyCapacities div.modal-footer input.firePopupSave')[0].value = (n ? 'Save Changes' : 'Update');
                    //Set item sttribute ID
                    $('#' + hdnSelectedWeeklySummaryID)[0].value = (n ? '0' : $(o).attr('qid'));

                    //If this is edit mode the the parent, name and description or not set default            
                    $('#' + txtFirm)[0].value = (n ? '' : $(o).parents('tr').children('td')[2].children[0].innerHTML);
                    $('#' + txtRes)[0].value = (n ? '' : $(o).parents('tr').children('td')[3].children[0].innerHTML);
                    $('#' + txtHold)[0].value = (n ? '' : $(o).parents('tr').children('td')[5].children[0].innerHTML);
                    $('#' + txtTotal)[0].value = (n ? '' : $(o).parents('tr').children('td')[4].children[0].innerHTML);
                    $('#' + txtBal)[0].value = (n ? '' : $(o).parents('tr').children('td')[7].children[0].innerHTML);
                    $('#' + txtCompare)[0].value = (n ? '' : $(o).parents('tr').children('td')[8].children[0].innerHTML);
                    $('#' + txtjkts)[0].value = (n ? '' : $(o).parents('tr').children('td')[9].children[0].innerHTML);
                    $('#' + txtsmpls)[0].value = (n ? '' : $(o).parents('tr').children('td')[10].children[0].innerHTML);
                    $('#' + txtHoliday)[0].value = (n ? '' : $(o).parents('tr').children('td')[11].children[0].innerHTML);
                    // $('#' + txtNotes)[0].value = (n ? '' : (($(o).parents('tr').children('td')[3].children[0].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[3].children[0].innerHTML));

                    showPopupBox('requestAddEditWeeklyCapacities', '600');
                }
            });
        });
    </script>
    <!-- / -->
</asp:Content>
