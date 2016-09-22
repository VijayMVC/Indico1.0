<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewFactoryPrices.aspx.cs"
    Inherits="Indico.ViewFactoryPrices" MasterPageFile="~/Indico.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h1>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h1>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="inner">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info" visible="false">
                    <h2>
                        <a href="AddEditClient.aspx" title="Add an Company.">Add the first Clent.</a>
                    </h2>
                    <p>
                        You can add as many clients as you like.
                    </p>
                </div>
                <!-- / -->
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search" />
                        </asp:Panel>
                    </div>
                    <!-- / -->

                    <asp:DataGrid ID="dataGridClient" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20">
                        <HeaderStyle CssClass="header" />
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="ID" HeaderText="ID" Visible="false" HeaderStyle-CssClass="hide"
                                ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Name" SortExpression="Name" HeaderStyle-Width="25%">
                                <ItemTemplate>
                                    <asp:Label ID="lblName" runat="server" Text=""></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:BoundColumn DataField="Email" HeaderText="Email" ItemStyle-Width="18%" SortExpression="Email"></asp:BoundColumn>
                            <asp:BoundColumn DataField="Phone1" HeaderText="Phone  No." ItemStyle-Width="15%"
                                SortExpression="Phone1"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Company" SortExpression="Distributor" HeaderStyle-Width="10%">
                                <ItemTemplate>
                                    <asp:Label ID="lblCompany" runat="server" Text=""></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Type" SortExpression="Type" HeaderStyle-Width="10%">
                                <ItemTemplate>
                                    <asp:Label ID="lblType" runat="server" Text=""></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:BoundColumn DataField="Country" HeaderText="Country" runat="server" SortExpression="Country"
                                HeaderStyle-Width="10%"></asp:BoundColumn>
                            <asp:BoundColumn DataField="City" HeaderText="City" runat="server" SortExpression="City"
                                HeaderStyle-Width="15%"></asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="Edit" ItemStyle-Width="4%">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lbEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Client"
                                        Text="Edit" CommandName="Edit"></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Delete" ItemStyle-Width="4%">
                                <ItemTemplate>
                                    <asp:HyperLink ID="lnkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Client">Delete</asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
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
    <asp:HiddenField ID="hdnSelectedClientID" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal">
        <div class="modal-header">
            <h2>Delete Client</h2>
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Client
        </div>
        <div class="modal-footer">
            <asp:Button ID="btnDelete" runat="server" CssClass="btn" Text="Yes" Url="/ViewItems.aspx" />
            <input id="btnCancel" class="btn firePopupCancel" type="button" value="No" />
        </div>
    </div>
    <!-- / -->
</asp:Content>
