<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="PendingPrice.aspx.cs" Inherits="Indico.PendingPrice" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="inner">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h4>
                        No Pending Prices.</h4>
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
                    <asp:DataGrid ID="dgPendingPrice" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dgPendingPrice_ItemDataBound" OnPageIndexChanged="dgPendingPrice_PageIndexChanged"
                        OnSortCommand="dgPendingPrice_SortCommand">
                        
                        <HeaderStyle CssClass="header" />
                        
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:BoundColumn DataField="ID" HeaderText="ID" Visible="false" HeaderStyle-CssClass="hide"
                                ItemStyle-CssClass="hide"></asp:BoundColumn>
                            <asp:BoundColumn DataField="PatternNumber" HeaderText="Number" SortExpression="PatternNumber">
                            </asp:BoundColumn>
                            <asp:BoundColumn DataField="NickName" HeaderText="NickName" SortExpression="NickName">
                            </asp:BoundColumn>
                            <asp:BoundColumn DataField="Gender" HeaderText="Gender" SortExpression="Gender">
                            </asp:BoundColumn>
                            <asp:BoundColumn DataField="SubItemName" HeaderText="Sub Item Name" SortExpression="SubItemName">
                            </asp:BoundColumn>
                            <asp:BoundColumn DataField="AgeGroup" HeaderText="Age group" SortExpression="AgeGroup">
                            </asp:BoundColumn>
                            <asp:BoundColumn DataField="CoreCategory" HeaderText="Core Category" SortExpression="CoreCategory">
                            </asp:BoundColumn>
                            <asp:BoundColumn DataField="CorePattern" HeaderText="Corr.Pattern" SortExpression="CorePattern">
                            </asp:BoundColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Add Price"><i class="icon-pencil"></i>Edit</asp:HyperLink>
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
                            any Prices.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
</asp:Content>
