<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewItemSubCategories.aspx.cs" Inherits="Indico.ViewItemSubCategories" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h1>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h1>
            <input id="btnAddSubCategory" type="button" class="btn btn-primary add pull-right" value="New Sub Category" />
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="inner">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="blankSlateIntro">
                    <h2>
                        <a href="javascript:itemAddEdit(this, true, 'New Item Sub-Category');" title="Add an item.">Add the first item sub-category.</a>
                    </h2>
                    <p>
                        You can add as many item sub-categories as you like.
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
                        <dl class="sortBy">
                            <dt>
                                <label>
                                    Filter by</label></dt>
                            <dd>
                                <asp:DropDownList ID="ddlSortBy" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlSortBy_SelectedIndexChanged">
                                    <asp:ListItem Value="2">All</asp:ListItem>
                                    <asp:ListItem Value="1">Active</asp:ListItem>
                                    <asp:ListItem Value="0">Inactive</asp:ListItem>
                                </asp:DropDownList>
                            </dd>
                        </dl>
                    </div>
                    <!-- / -->
                    <asp:DataGrid ID="dgItemSubCategory" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dgItemSubCategory_ItemDataBound" OnPageIndexChanged="dgItemSubCategory_PageIndexChanged"
                        OnSortCommand="dgItemSubCategory_SortCommand">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="ID" HeaderText="ID"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Item" SortExpression="Item" ItemStyle-Width="25%">
                                <ItemTemplate>
                                    <asp:Label ID="lblItemName" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:BoundColumn DataField="Name" HeaderText="Name" ItemStyle-Width="25%" SortExpression="Name"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Description" HeaderText="Description" ItemStyle-Width="42%"
                                SortExpression="Description"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Edit" ItemStyle-Width="4%">
                                <ItemTemplate>
                                    <asp:HyperLink ID="lnkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Item"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Delete" ItemStyle-Width="4%">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Item"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                            any documents.</h4>
                    </div>
                    <!-- / -->
                </div>
            </div>
        </div>
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedSubCategoryID" runat="server" Value="0" />
    <!-- Add / Edit Item -->
    <div id="requestAddEdit" class="modal">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h2>
                <asp:Label ID="lblPopupHeaderText" runat="server"></asp:Label></h2>
        </div>
        <!-- / -->
        <!-- Popup Validation -->
        <div id="dvPageValidation" runat="server" class="message error" visible="false">
            <h4>Errors were encountered while trying to process the form below:
            </h4>
            <asp:ValidationSummary ID="validationSummary" runat="server" ValidationGroup="vgItem"></asp:ValidationSummary>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <fieldset>
                <ol>
                    <li>
                        <label>
                            Item</label>
                        <asp:DropDownList ID="ddlItem" runat="server">
                        </asp:DropDownList>
                    </li>
                    <li>
                        <label class="required">
                            Name</label>
                        <asp:TextBox ID="txtName" runat="server" MaxLength="128"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvName" runat="server" CssClass="error" ControlToValidate="txtName"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Item name is required"
                            ValidationGroup="vgItem">
                                <img src="Content/img/icon_warning.png" title="Item name is required" alt="Item name is required" />
                        </asp:RequiredFieldValidator>
                    </li>
                    <li>
                        <label>
                            Description</label>
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="topic_d" MaxLength="255"
                            TextMode="MultiLine" Rows="2"></asp:TextBox>
                    </li>
                </ol>
            </fieldset>
            <div class="modal-footer">
                <asp:Button ID="btnSaveChanges" runat="server" CssClass="btn" OnClick="btnSaveChanges_Click"
                    Text="Save" Url="/ViewItems.aspx" ValidationGroup="vgItem" />
            </div>
        </div>
    </div>
    <!-- Delete Item -->
    <div id="requestDelete" class="modal">
        <div class="modal-header">
            <h2>Delete Item Sub-Category</h2>
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Sub-Category?
        </div>
        <div class="modal-footer">
            <asp:Button ID="btnDelete" runat="server" CssClass="btn" Text="Yes" Url="/ViewItems.aspx"
                OnClick="btnDelete_Click" />
            <input id="btnCancel" class="btn firePopupCancel" type="button" value="No" />
        </div>
    </div>
    <!-- / -->
    <script type="text/javascript">
        var IsValied = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var hdnSelectedID = "<%=hdnSelectedSubCategoryID.ClientID %>";

        var itemName = "<%=ddlItem.ClientID %>";
        var subCatName = "<%=txtName.ClientID%>";
        var subCatDescription = "<%=txtDescription.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.add, .edit').click(function () {
                if ($(this).hasClass('add')) {
                    itemAddEdit(this, true, 'New Item Sub-Category');
                }
                else {
                    fillText(this);
                    itemAddEdit(this, false, 'Edit Item Sub-Category');
                }
            });

            $('.delete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).parents('tr').children('td').first()[0].innerHTML;
                showPopupBox('requestDelete', '405', '-205');
            });

            if (!IsValied) {
                window.setTimeout(function () {
                    showPopupBox('requestAddEdit', '600', '-300');
                }, 10);
            }

            function fillText(o) {
                var selectedItemText = $(o).parents('tr').children('td').children()[0].innerHTML;
                $('#' + itemName + ' option').each(function (o) {
                    if (this.text == selectedItemText) {
                        this.selected = true;
                    }
                });

                //$('#' + itemName).val(selectedItemText);
                $('#' + subCatName)[0].value = $(o).parents('tr').children('td')[2].innerHTML;
                $('#' + subCatDescription)[0].value = $(o).parents('tr').children('td')[3].innerHTML
            }

            function resetText() {
                $('fieldset.panel input[type=text]').val('');
            }
        });
    </script>
</asp:Content>
