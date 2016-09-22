<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewVisualLayouts.aspx.cs" Inherits="Indico.ViewVisualLayouts" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddVL" class="btn btn-link pull-right" runat="server" href="AddEditVisualLayout.aspx">New Product</a>
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
                        <a href="AddEditVisualLayout.aspx" title="Add an item.">Add the first Product.</a>
                    </h4>
                    <p>
                        You can add as many Products as you like.
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
                        <div class="form-inline pull-right">
                            <label> Filter by</label>
                            <asp:DropDownList ID="ddlSortByActive" runat="server" AutoPostBack="True" CssClass="input-small"
                                OnSelectedIndexChanged="ddlSortByActive_SelectedIndexChanged">
                                <asp:ListItem Value="1">Active</asp:ListItem>
                                <asp:ListItem Value="2">InActive</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                    <!-- / -->
                    <telerik:RadGrid ID="RadGridVisualLayouts" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadGridVisualLayouts_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridVisualLayouts_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridVisualLayouts_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnGroupsChanging="RadGridVisualLayouts_GroupsChanging" OnItemCommand="RadGridVisualLayouts_ItemCommand"
                        OnSortCommand="RadGridVisualLayouts_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true" GroupsDefaultExpanded="false">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Name" SortExpression="Name" HeaderText="Number" CurrentFilterFunction="Contains" AutoPostBackOnFilter="false"
                                    FilterControlWidth="50px" DataField="Name">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="Image" AllowFiltering="false">
                                    <ItemTemplate>
                                        <a id="ancMainImage" runat="server" target="_blank"><i id="iVlimageView" runat="server"
                                            class="icon-eye-open"></i></a>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="Coordinator" SortExpression="Coordinator" HeaderText="Coordinator" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true"
                                    DataField="Coordinator">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Distributor" SortExpression="Distributor" HeaderText="Distributor" CurrentFilterFunction="Contains"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true"
                                    DataField="Distributor">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Client" SortExpression="Client" HeaderText="Client"
                                    FilterControlWidth="100px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    DataField="Client">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="JobName" SortExpression="JobName" HeaderText="JobName"
                                    FilterControlWidth="100px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    DataField="JobName">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Pattern" SortExpression="Pattern" HeaderText="Pattern" CurrentFilterFunction="Contains"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true"
                                    DataField="Pattern">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Fabric" SortExpression="Fabric" HeaderText="Fabric" CurrentFilterFunction="Contains"
                                    FilterControlWidth="75px" AutoPostBackOnFilter="true"
                                    DataField="Fabric">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="SizeSet" SortExpression="SizeSet" HeaderText="Size Set" CurrentFilterFunction="Contains"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true"
                                    DataField="SizeSet">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderStyle-Width="100px" UniqueName="ResolutionProfile" HeaderText="Resolution Profile" AllowFiltering="false" ItemStyle-Width="100px">
                                    <ItemTemplate>
                                        <asp:DropDownList CssClass="input-medium" ID="ddlResolutionProfile" runat="server" OnSelectedIndexChanged="ddlResolutionProfile_SelectedIndexChanged"
                                            AutoPostBack="true">
                                        </asp:DropDownList>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderStyle-Width="100px" UniqueName="Printer" HeaderText="Printer" AllowFiltering="false" ItemStyle-Width="100px">
                                    <ItemTemplate>
                                        <asp:DropDownList CssClass="input-medium" ID="ddlPrinter" runat="server" OnSelectedIndexChanged="ddlPrinter_SelectedIndexChanged"
                                            AutoPostBack="true">
                                        </asp:DropDownList>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridCheckBoxColumn UniqueName="IsCommonProduct" Visible="false" HeaderText="Common" DataField="IsCommonProduct" AllowFiltering="false" ItemStyle-CssClass="rfdCheckboxChecked" ItemStyle-HorizontalAlign="Center"
                                    AllowSorting="true">
                                </telerik:GridCheckBoxColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false" UniqueName="UserFunctions">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="lnkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Product"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Product"><i class="icon-trash"></i>Delete</asp:HyperLink>

                                                </li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="True">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="true" />
                    </telerik:RadGrid>
                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> did not match
                            any Products.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <!-- Delete Product  -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Product
            </h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Product?
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
    <!-- / -->
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValid"]%>' == 'True') ? true : false;
        var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";        
    </script>
    <script type="text/javascript">
        $(document).ready(function () {

            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });

            $('input').keyup(function (e) {
                if ($('#' + txtPage).val() != '') {
                    if (e.which == 13) {
                        return false;
                    }
                }
            });
        });
    </script>
</asp:Content>
