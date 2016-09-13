<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewPrices.aspx.cs" Inherits="Indico.ViewPrices" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- /-->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
            <a id="btnAddPrice" runat="server" class="btn btn-link pull-right" href="/AddPatternFabricPrice.aspx">
                Add Pattern Fabric Price</a>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h4>
                        <a href="/AddPatternFabricPrice.aspx" title="Add an item.">Add the first price.</a>
                    </h4>
                    <p>
                        You can add many prices as you like.</p>
                </div>
                <div id="dvEmptyContentFactory" runat="server" class="alert alert-info">
                    <h4>
                        <a href="javascript:void(0);" title="There are no prices has been added.">There are
                            no prices has been added.</a>
                    </h4>
                    <p>
                        Once manufacturer add the prices for pattern you can modify prices as you like.</p>
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
                        <dl class="sortBy" runat="server" visible="false">
                            <dt>
                                <label>
                                    Filter by</label></dt>
                            <dd>
                                <asp:DropDownList ID="ddlFilterBy" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlSortBy_SelectedIndexChanged">
                                </asp:DropDownList>
                            </dd>
                        </dl>
                    </div>
                    <!-- / -->
                    <!-- Data Table -->
                    <asp:DataGrid ID="dgPrices" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                        PageSize="20" OnItemDataBound="dgPrices_ItemDataBound" OnPageIndexChanged="dgPrices_PageIndexChanged"
                        OnSortCommand="dgPrices_SortCommand">
                        <HeaderStyle CssClass="header" />
                        
                        
                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:TemplateColumn HeaderText="Sports Category">
                                <ItemTemplate>
                                    <asp:Label ID="lblSportsCategory" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Other Categories">
                                <ItemTemplate>
                                    <asp:Label ID="lblOtherCategories" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Pattern No.">
                                <ItemTemplate>
                                    <asp:Label ID="lblPatternNo" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Nick Name">
                                <ItemTemplate>
                                    <asp:Label ID="lblNickName" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Fabric Code">
                                <ItemTemplate>
                                    <div id="dvFabricCodes" runat="server">
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Modified Date">
                                <ItemTemplate>
                                    <asp:Label ID="lblModifiedDate" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:HyperLink ID="linkEditFactoryCost" runat="server" CssClass="btn-link iedit"><i class="icon-pencil"></i>Edit Factory Price</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="linkEditIndimanCost" runat="server" CssClass="btn-link iedit"
                                                    Visible="false"><i class="icon-pencil"></i>Edit Indiman Price</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="linkEditIndicoCost" runat="server" CssClass="btn-link iedit" Visible="false"><i class="icon-pencil"></i>Edit Indico Price</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete"><i class="icon-trash"></i>Delete</asp:HyperLink>
                                            </li>
                                        </ul>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>
                    <!-- / -->
                </div>
                <!-- / -->
                <!-- No Search Result -->
                <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                    <h4>
                        Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                        any orders.</h4>
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                Delete Pattern Fabric Code Price</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this patten fabric codes prices?</p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" type="submit" onserverclick="btnDelete_Click">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var hdnSelectedID = "<%=hdnSelectedID.ClientID%>";
        var btnDelete = "<%=btnDelete.ClientID%>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.idelete').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                $('#requestDelete').modal('show');                
            });
        });
    </script>
    <!-- / -->
</asp:Content>
