<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewPriceLevels.aspx.cs" Inherits="Indico.ViewPriceLevels" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddPriceLevel" class="btn btn-link iadd pull-right" runat="server" qid="0">Add Price Level</a>
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
                        <a class="iadd" href="javascript:void(0);" qid="0" title="Add an item.">Add the first
                            price level.</a>
                    </h4>
                    <p>
                        You can add many price levels as you like.
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
                    <asp:DataGrid ID="dgPriceLevels" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dgPriceLevels_ItemDataBound" OnPageIndexChanged="dgPriceLevels_PageIndexChanged"
                        OnSortCommand="dgPriceLevels_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="Name" HeaderText="Name" SortExpression="Name"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Volume" HeaderText="Volume" SortExpression="Volume"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Markup" HeaderText="Markup" SortExpression="Markup"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Price Level"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Price Level"><i class="icon-trash"></i>Delete</asp:HyperLink>
                                            </li>
                                        </ul>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>
                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                            any orders.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <!-- Add Order Popup -->
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
            <div class="control-group">
                <label class="control-label required">
                    Name
                </label>
                <div class="controls">
                    <asp:TextBox ID="txtName" runat="server"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvName" runat="server" CssClass="error" ControlToValidate="txtName"
                        Display="Dynamic" EnableClientScript="False" ErrorMessage="Name is required.">
                            <img src="Content/img/icon_warning.png" title="Name is required." alt="Name is required." />
                    </asp:RequiredFieldValidator>
                     <asp:CustomValidator ID="cvTxtName" runat="server" OnServerValidate="cvTxtName_ServerValidate" ErrorMessage="Name is already in use"
                            ControlToValidate="txtName" EnableClientScript="false">
                             <img src="Content/img/icon_warning.png"  title="Name is already in use" alt="Name is already in use" />
                        </asp:CustomValidator>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label required">
                    Volume
                </label>
                <div class="controls">
                    <asp:TextBox ID="txtVolume" runat="server"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvVolume" runat="server" CssClass="error" ControlToValidate="txtVolume"
                        Display="Dynamic" EnableClientScript="False" ErrorMessage="Volume is required.">
                            <img src="Content/img/icon_warning.png" title="Volume is required." alt="Volume is required." />
                    </asp:RequiredFieldValidator>
                    <p class="extra-helper">
                        eg: 001 - 005
                    </p>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label required">
                    Markup
                </label>
                <div class="controls">
                    <asp:TextBox ID="txtMarkup" runat="server"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvMarkup" runat="server" CssClass="error" ControlToValidate="txtMarkup"
                        Display="Dynamic" EnableClientScript="False" ErrorMessage="Markup is required.">
                            <img src="Content/img/icon_warning.png" title="Markup is required." alt="Markup is required." />
                    </asp:RequiredFieldValidator>
                    <p class="extra-helper">
                        eg: 15
                    </p>
                </div>
            </div>
        </div>
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
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Price Level</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Price Level?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" type="submit" onserverclick="btnDelete_Click"
                data-loading-text="Deleting...">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValid"]%>' == 'True') ? true : false;
        var levelName = "<%=txtName.ClientID%>";
        var levelVolume = "<%=txtVolume.ClientID%>";
        var levelMarkup = "<%=txtMarkup.ClientID%>";
        var hdnSelectedID = "<%=hdnSelectedID.ClientID%>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID%>";
        var btnDelete = "<%=btnDelete.ClientID%>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.iadd').click(function () {
                resetFieldsDefault('requestAddEdit');
                itemAddEdit(this, true);
            });

            $('.iedit').click(function () {
                fillText(this);
                itemAddEdit(this, false);
            });

            $('.idelete').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                $('#requestDelete').modal('show');
            });

            if (!IsPageValid) {
                window.setTimeout(function () {
                    $('#requestAddEdit').modal('show');
                }, 10);
            }

            function itemAddEdit(o, n) {
                $('div.alert-danger, span.error').hide();
                $('#requestAddEdit div.modal-header h3 span')[0].innerHTML = (n ? 'Add Price Level' : 'Edit Price Level');
                $('#' + hdnSelectedID).val($(o).attr('qid'));
                $('#' + btnSaveChanges)[0].innerHTML = (n) ? 'Save Changes' : 'Update';
                $('#requestAddEdit').modal('show');
            }

            function fillText(o) {
                $('#' + levelName)[0].value = $(o).parents('tr').children('td')[0].innerHTML;
                $('#' + levelVolume)[0].value = $(o).parents('tr').children('td')[1].innerHTML
                $('#' + levelMarkup)[0].value = $(o).parents('tr').children('td')[2].innerHTML
            }
        });
    </script>
    <!-- / -->
</asp:Content>
