<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Indico.Master" CodeBehind="ViewPatternAccessory.aspx.cs"
    Inherits="Indico.ViewPatternAccessory" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnPatternAccessory" runat="server" class="btn btn-link iadd pull-right">New
                    Pattern Accessory</a>
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
                        <a href="javascript:ItemPatternAccessoryAddEdit(this, true, 'New Pattern Accessory');"
                            title="Add a Pattern Accessory.">Add the first Pattern Accessory.</a>
                    </h4>
                    <p>
                        You can add as many Pattern Accessories as you like.</p>
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
                    <asp:DataGrid ID="dgPatternAccessory" runat="server" CssClass="table" AutoGenerateColumns="false"
                        AllowSorting="true" GridLines="None" AllowPaging="True" PageSize="20" AllowCustomPaging="False"
                        OnItemDataBound="dgPatternAccessory_ItemDataBound" OnPageIndexChanged="dgPatternAccessory_PageIndexChanged"
                        OnSortCommand="dgPatternAccessory_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:TemplateColumn HeaderText="Pattern" SortExpression="Pattern">
                                <ItemTemplate>
                                    <asp:Literal ID="lblpattern" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Accessory" SortExpression="Assesorry">
                                <ItemTemplate>
                                    <asp:Literal ID="lblAccessory" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Accessory Category">
                                <ItemTemplate>
                                    <asp:Literal ID="lblAccessoryCategory" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li><a id="linkEdit" runat="server" class="btn-link iedit" title="Edit Assesorry Category"
                                                onserverclick="linkEdit_Click"><i class="icon-pencil"></i>Edit</a></li>
                                            <li><a id="linkDelete" runat="server" class="btn-link idelete" title="Delete Assesorry Category">
                                                <i class="icon-trash"></i>Delete </a></li>
                                        </ul>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>
                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>
                            Your search - <strong>
                                <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                            any Pattern Accessories.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedPatternAccessoryID" runat="server" Value="0" />
    <!-- Add / Edit ItemAttribute -->
    <div id="requestAddEditPatternAccessory" class="modal fade" role="dialog" aria-hidden="true"
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
                DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>">
            </asp:ValidationSummary>
            <!-- / -->
            <fieldset class="panel" style="margin: 0; padding: 0; background: transparent; border: 0;">
                <div class="control-group">
                    <label class="control-label required">
                        Pattern</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlPattern" runat="server">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvItem" runat="server" CssClass="error" ControlToValidate="ddlPattern"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Item is required"
                            InitialValue="0">
                                <img src="Content/img/icon_warning.png" title="Item is required" alt="Item is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Accessory Category</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlAccessoryCategory" runat="server" OnSelectedIndexChanged="ddlAccessoryCategory_SelectedIndexChange"
                            AutoPostBack="true">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvCategoryAccessory" runat="server" CssClass="error"
                            ControlToValidate="ddlAccessoryCategory" Display="Dynamic" EnableClientScript="False"
                            ErrorMessage="Accessory Category is required" InitialValue="0">
                                <img src="Content/img/icon_warning.png" title="Accessory Category is required" alt="Accessory Category is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Accessory</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlAccessory" runat="server">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvAccessory" runat="server" CssClass="error" ControlToValidate="ddlAccessory"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Accessory is required"
                            InitialValue="0">
                                <img src="Content/img/icon_warning.png" title="Accessory is required" alt="Accessory is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
            </fieldset>
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
    <div id="requestDeletePatternAccessory" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static" style="display: none;">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                Delete Pattern Accessories</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Pattern Accessory?</p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary " onserverclick="btnDelete_Click"
                data-loading-text="Deleting...">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var IsValied = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var hdnSelectedPatternAccessoryID = "<%=hdnSelectedPatternAccessoryID.ClientID %>";
        var ddlPattern = "<%=ddlPattern.ClientID %>";
        var ddlAccessory = "<%=ddlAccessory.ClientID%>";
        var ddlAccessoryCategory = "<%=ddlAccessoryCategory.ClientID%>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID%>";
    </script>
    <script type="text/javascript">

        if (!IsValied) {
            window.setTimeout(function () {
                $('#requestAddEditPatternAccessory').modal('show');
            }, 10);
        }

        $('.iadd').click(function () {
            ItemPatternAccessoryAddEdit(this, true);
        });

        /*$('.iedit').click(function () {
        ItemPatternAccessoryAddEdit(this, false);
        })*;*/

        $('.idelete').click(function () {
            $('#' + hdnSelectedPatternAccessoryID)[0].value = $(this).attr('qid');
            $('#requestDeletePatternAccessory').modal('show');
        });

        function ItemPatternAccessoryAddEdit(o, n) {
            //Hide the validation summary
            $('div.alert-danger, span.error').hide();
            //Set the popup header text
            $('#requestAddEditPatternAccessory div.modal-header h3 span')[0].innerHTML = (n ? 'New Pattern Accessory' : 'Edit Pattern Accessory');
            //Set the popup save button text
            $('#' + btnSaveChanges)[0].innerHTML = (n) ? 'Save Changes' : 'Update';
            //Set item sttribute ID
            $('#' + hdnSelectedPatternAccessoryID)[0].value = (n ? '0' : $(o).attr('qid'));
            //If this is edit mode the the parent, name and description or not set default     

            if (!n) {
                $('#' + ddlPattern).val($(o).attr('patid'));
                $('#' + ddlAccessory).val($(o).attr('catid'));
                $('#' + ddlAccessoryCategory).val($(o).attr('accid'));
            }
            $('#requestAddEditPatternAccessory').modal('show');
        }
    </script>
    <!-- / -->
</asp:Content>
