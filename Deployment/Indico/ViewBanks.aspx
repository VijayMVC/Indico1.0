<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewBanks.aspx.cs" Inherits="Indico.ViewBanks" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddAgeGroup" runat="server" class="btn btn-link iadd pull-right">New Bank</a>
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
                    <h2>
                        <a href="javascript:BankAddEdit(this, true, 'New Bank');" title="Add an Bank.">Add the first Bank.</a>
                    </h2>
                    <p>
                        You can add as many Banks as you like.
                    </p>
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
                            <telerik:AjaxSetting AjaxControlID="RadGridBank">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridBank"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridBank" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="false" OnPageSizeChanged="RadGridBank_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridBank_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridBank_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridBank_ItemCommand"
                        OnSortCommand="RadGridBank_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Name" SortExpression="Name" HeaderText="Name" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="100px" DataField="Name">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Branch" SortExpression="Branch" HeaderText="Branch" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Branch">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="AccountNo" SortExpression="AccountNo" HeaderText="Account No" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="AccountNo">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="SwiftCode" SortExpression="SwiftCode" HeaderText="Swift Code" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="SwiftCode">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Number" SortExpression="Number" HeaderText="Number" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Number">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Address" SortExpression="Address" HeaderText="Address" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Address">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="City" SortExpression="City" HeaderText="City" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="City">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="State" SortExpression="State" HeaderText="State" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="State">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Postcode" SortExpression="Postcode" HeaderText="Postcode" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Postcode">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Country" SortExpression="Country" HeaderText="Country" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Country">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Bank"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Bank"><i class="icon-trash"></i>Delete</asp:HyperLink>
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
                                                <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Bank"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                            <li>
                                                <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Bank"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
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
    <asp:HiddenField ID="hdnSelectedBankID" runat="server" Value="0" />
    <!-- Add / Edit Item -->
    <div id="requestAddEdit" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
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
            <!-- Popup Validation -->
            <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <fieldset>
                <div class="control-group">
                    <label class="control-label required">
                        Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtName" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvName" runat="server" CssClass="error" ControlToValidate="txtName" Display="Dynamic" EnableClientScript="False" ErrorMessage="Name is required">
                                <img src="Content/img/icon_warning.png" title="Name is required" alt="Name is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Branch</label>
                    <div class="controls">
                        <asp:TextBox ID="txtBranch" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvBranch" runat="server" CssClass="error" ControlToValidate="txtBranch" Display="Dynamic" EnableClientScript="False" ErrorMessage="Branch is required">
                                <img src="Content/img/icon_warning.png" title="Name is required" alt="Name is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Number</label>
                    <div class="controls">
                        <asp:TextBox ID="txtNumber" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Address</label>
                    <div class="controls">
                        <asp:TextBox ID="txtAddress" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        City</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCity" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        State</label>
                    <div class="controls">
                        <asp:TextBox ID="txtState" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Postcode</label>
                    <div class="controls">
                        <asp:TextBox ID="txtPostcode" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Country</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlCountry" runat="server"></asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Account NO</label>
                    <div class="controls">
                        <asp:TextBox ID="txtAccountNo" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvAccountNo" runat="server" CssClass="error" ControlToValidate="txtAccountNo" Display="Dynamic" EnableClientScript="False" ErrorMessage="Account No is required">
                                <img src="Content/img/icon_warning.png" title="Account No is required" alt="Account No is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Swift Code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtSwiftCode" runat="server"></asp:TextBox>
                    </div>
                </div>
            </fieldset>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_Click"
                data-loading-text="Saving..." type="submit" text="">
                Save Changes</button>
        </div>
    </div>
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Bank</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Bank?
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" onserverclick="btnDelete_Click" data-loading-text="Deleting..." type="submit">Yes</button>
        </div>
    </div>
    <!-- / -->
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var txtName = "<%=txtName.ClientID%>";
        var txtBranch = "<%=txtBranch.ClientID%>";
        var txtNumber = "<%=txtNumber.ClientID%>";
        var txtAddress = "<%=txtAddress.ClientID%>";
        var txtCity = "<%=txtCity.ClientID%>";
        var txtState = "<%=txtState.ClientID%>";
        var txtPostcode = "<%=txtPostcode.ClientID%>";
        var ddlCountry = "<%=ddlCountry.ClientID%>";
        var txtAccountNo = "<%=txtAccountNo.ClientID%>";
        var txtSwiftCode = "<%=txtSwiftCode.ClientID%>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID%>";
        var hdnSelectedID = "<%=hdnSelectedBankID.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.iadd').click(function () {
                resetFieldsDefault('requestAddEdit');
                BankAddEdit(this, true);
            });

            $('.iedit').click(function () {
                fillText(this);
                BankAddEdit(this, false);
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

            function BankAddEdit(o, n) {
                $('div.alert-danger, span.error').hide();
                $('#requestAddEdit div.modal-header h3 span')[0].innerHTML = (n ? 'Add Bank' : 'Edit Bank');
                $('#' + btnSaveChanges)[0].innerHTML = (n) ? 'Save Changes' : 'Update';
                $('#' + hdnSelectedID).val(n ? '0' : $(o).attr('qid'));
                $('#requestAddEdit').modal('show');
            }

            function fillText(o) {
                $('#' + txtName)[0].value = $(o).parents('tr').children('td')[0].innerHTML;
                $('#' + txtBranch)[0].value = (($(o).parents('tr').children('td')[1].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[1].innerHTML);
                $('#' + txtAccountNo)[0].value = (($(o).parents('tr').children('td')[2].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[2].innerHTML);
                $('#' + txtSwiftCode)[0].value = (($(o).parents('tr').children('td')[3].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[3].innerHTML);
                $('#' + txtNumber)[0].value = (($(o).parents('tr').children('td')[4].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[4].innerHTML);
                $('#' + txtAddress)[0].value = (($(o).parents('tr').children('td')[5].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[5].innerHTML);
                $('#' + txtCity)[0].value = (($(o).parents('tr').children('td')[6].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[6].innerHTML);
                $('#' + txtState)[0].value = (($(o).parents('tr').children('td')[7].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[7].innerHTML);
                $('#' + txtPostcode)[0].value = (($(o).parents('tr').children('td')[8].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[8].innerHTML);
                $('#' + ddlCountry)[0].value = (($(o).parents('tr').children('td')[9].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[9].innerHTML);
            }
        });
    </script>
</asp:Content>
