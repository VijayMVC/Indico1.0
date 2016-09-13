<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewSportsCategories.aspx.cs" Inherits="Indico.ViewSportsCategories" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h1>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h1>
            <input id="btnAddSportCatagories" runat="server" class="btn btn-primary iadd pull-right"
                type="button" value="New Sports Category" />
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="inner">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h2>
                        <a href="javascript:SportCategoryAddEdit(this, true, 'New Sports Category');" title="Add an Sport Category.">Add the first Sports Category.</a>
                    </h2>
                    <p>
                        You can add as many sport categories as you like.
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

                    <asp:DataGrid ID="dataGridSportCategory" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dataGridSportCategory_ItemDataBound" OnPageIndexChanged="dataGridSportCategory_PageIndexChanged"
                        OnSortCommand="dataGridSportCategory_SortCommand">
                        <HeaderStyle CssClass="header" />


                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="Name" HeaderText="Name" ItemStyle-Width="30%" SortExpression="Name"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Description" HeaderText="Description" ItemStyle-Width="62%"
                                SortExpression="Description"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Edit" ItemStyle-Width="4%">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Sport Category"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Delete" ItemStyle-Width="4%">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Sport Category"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>

                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> did not match
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
    <asp:HiddenField ID="hdnSelectedSportCategoryID" runat="server" Value="0" />
    <!-- Add / Edit Item -->
    <div id="requestAddEdit" class="modal">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h2>
                <asp:Label ID="lblPopupHeaderText" runat="server"></asp:Label></h2>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <!-- Popup Validation -->
            <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <fieldset>
                <p class="required">
                    Indicates required fields
                </p>
                <ol>
                    <li>
                        <label class="required">
                            Name</label>
                        <asp:TextBox ID="txtSportCategoryName" runat="server" MaxLength="128"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvSportCategoryName" runat="server" CssClass="error"
                            ControlToValidate="txtSportCategoryName" Display="Dynamic" EnableClientScript="False"
                            ErrorMessage="Name is required">
                                <img src="Content/img/icon_warning.png" title="Name is required" alt="Name is required" />
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
        </div>
        <div class="modal-footer">
            <asp:Button ID="btnSaveChanges" runat="server" CssClass="btn" OnClick="btnSaveChanges_Click"
                Text="Save Changes" Url="/ViewSportCategories.aspx" />
        </div>
    </div>
    <!-- Delete Item -->
    <div id="requestDelete" class="modal">
        <div class="modal-header">
            <h2>Delete Sport Category</h2>
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Sport Category?
        </div>
        <div class="modal-footer">
            <asp:Button ID="btnDelete" runat="server" CssClass="btn" Text="Yes" Url="/ViewAgeGroups.aspx"
                OnClick="btnDelete_Click" />
            <input id="btnCancel" class="btn firePopupCancel" type="button" value="No" />
        </div>
    </div>
    <!-- / -->
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValid"]%>' == 'True') ? true : false;
        var sportcategoryName = "<%=txtSportCategoryName.ClientID%>";
        var sportcategoryDescription = "<%=txtDescription.ClientID%>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID%>";
        var hdnSelectedID = "<%=hdnSelectedSportCategoryID.ClientID %>";      
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.iadd').click(function () {
                resetFieldsDefault('requestAddEdit');
                SportCategoryAddEdit(this, true);
            });

            $('.iedit').click(function () {
                fillText(this);
                SportCategoryAddEdit(this, false);
            });

            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                showPopupBox('requestDelete', '380');
            });

            if (!IsPageValid) {
                window.setTimeout(function () {
                    showPopupBox('requestAddEdit', '640');
                }, 10);
            }

            function SportCategoryAddEdit(o, n) {
                $('div.ivalidator, span.error').hide();
                $('#requestAddEdit div.modal-header h2 span')[0].innerHTML = (n ? 'Add Sports Category' : 'Edit Sports Category');
                $('#' + btnSaveChanges).val(n ? 'Save Changes' : 'Update');
                $('#' + hdnSelectedID).val(n ? '0' : $(o).attr('qid'));
                showPopupBox('requestAddEdit', '640');
            }

            function fillText(o) {
                $('#' + sportcategoryName)[0].value = $(o).parents('tr').children('td')[0].innerHTML;
                $('#' + sportcategoryDescription)[0].value = (($(o).parents('tr').children('td')[1].innerHTML == '&nbsp;') ? '' : $(o).parents('tr').children('td')[1].innerHTML);
            }
        });
    </script>
</asp:Content>
