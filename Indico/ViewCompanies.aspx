<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewCompanies.aspx.cs" Inherits="Indico.ViewCompanies" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddCompany" runat="server" class="btn btn-link pull-right" href="~/AddEditCompany.aspx">
                    New Company</a>
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
                        <a href="AddEditCompany.aspx" title="Add an Company.">Add the first Company.</a>
                    </h4>
                    <p>
                        You can add as many Company as you like.</p>
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
                    <asp:DataGrid ID="dataGridCompany" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dataGridCompany_ItemDataBound" OnPageIndexChanged="dataGridCompany_PageIndexChanged"
                        OnSortCommand="dataGridCompany_SortCommand" OnItemCommand="dataGridCompany_ItemCommand">
                        
                        <HeaderStyle CssClass="header" />
                        
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="ID" HeaderText="ID" Visible="false" HeaderStyle-CssClass="hide"
                                ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Company Type" SortExpression="Type">
                                <ItemTemplate>
                                    <asp:Label ID="lblCompanyType" runat="server" Text=""></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:BoundColumn DataField="Name" HeaderText="Name" SortExpression="Name"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Coordinator" SortExpression="Coordinator">
                                <ItemTemplate>
                                    <asp:Label ID="lblCoordinator" runat="server" Text=""></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:BoundColumn DataField="NickName" HeaderText="Nick Name" SortExpression="NickName">
                            </asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:LinkButton ID="lbEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Item"
                                                    Text="Edit" CommandName="Edit"><i class="icon-pencil"></i>Edit</asp:LinkButton>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="lnkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Item"><i class="icon-trash"></i>Delete</asp:HyperLink>
                                            </li>
                                        </ul>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>
                            Your search - <strong>
                                <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> did not match
                            any documents.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedCompanyID" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                Delete Company</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Company?
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" type="submit" onserverclick="btnDelete_Click">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <script type="text/javascript">
        var hdnSelectedID = "<%=hdnSelectedCompanyID.ClientID %>";
    </script>
    <script type="text/javascript">
        $('.idelete').click(function () {
            $('#' + hdnSelectedID)[0].value = $(this).parents('tr').children('td').first()[0].innerHTML;
            $('#requestDelete').modal('show');
        });
    </script>
</asp:Content>
