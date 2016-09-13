<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewDescriptionGrid.aspx.cs" Inherits="Indico.ViewDescriptionGrid" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Empty Content -->
                <!-- / -->
                <%--Data Content--%>
                <div id="dvDataContent" runat="server">
                    <div class="search-control clearfix">
                        <div class="form-inline pull-right">
                            <label>
                                Blackchrome</label>
                            <asp:DropDownList ID="ddlWebService" runat="server" AutoPostBack="True" CssClass="input-medium"
                                OnSelectedIndexChanged="ddlWebService_SelectedIndexChanged">
                                <asp:ListItem Value="0">All</asp:ListItem>
                                <asp:ListItem Value="1">Posted</asp:ListItem>
                                <asp:ListItem Value="2">Not yet posted</asp:ListItem>
                            </asp:DropDownList>
                            <label>
                                Filter by</label>
                            <asp:DropDownList ID="ddlSortByActive" runat="server" AutoPostBack="True" CssClass="input-small"
                                OnSelectedIndexChanged="ddlSortByActive_SelectedIndexChanged">
                                <asp:ListItem Value="1">Active</asp:ListItem>
                                <asp:ListItem Value="2">InActive</asp:ListItem>
                            </asp:DropDownList>
                            <asp:DropDownList ID="ddlSortByGarmentSpec" runat="server" AutoPostBack="True" CssClass="input-medium"
                                OnSelectedIndexChanged="ddlSortByGarmentSpec_SelectedIndexChanged">
                                <asp:ListItem Value="0">All</asp:ListItem>
                                <asp:ListItem Value="1">Completed</asp:ListItem>
                                <asp:ListItem Value="2">Not Completed</asp:ListItem>
                                <asp:ListItem Value="3">Partialy Completed</asp:ListItem>
                                <asp:ListItem Value="4">Spec Missing</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="pull-right" style="margin-top: 4px; margin-right: 20px;">
                            <asp:LinkButton ID="btnlinkCompleated" runat="server" OnClick="linkSortby_Click"
                                ToolTip="Completed" status="comp">
                                <span class="badge badge-completed">&nbsp;</span>&nbsp;Completed
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnlinkPartiallyCompleted" runat="server" OnClick="linkSortby_Click"
                                ToolTip="Partially Completed" status="pcomp">
                                <span class="badge badge-partialycompleted">&nbsp;</span>&nbsp;Partially Completed
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnlinkNotCompleted" runat="server" OnClick="linkSortby_Click"
                                ToolTip="Not Completed" status="ncomp">
                                <span class="badge badge-notcompleted">&nbsp;</span>&nbsp;Not Completed
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnlinkSpecMissing" runat="server" OnClick="linkSortby_Click"
                                ToolTip="Spec Missing" status="specm">
                                <span class="badge badge-specmissing">&nbsp;</span>&nbsp;Spec Missing
                            </asp:LinkButton>
                        </div>
                        <!-- Search Control -->
                        <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>
                    </div>
                    <!-- / -->
                    <!-- Data Table -->
                    <telerik:RadGrid ID="RadGridPattern" runat="server" AllowPaging="true" AllowFilteringByColumn="true"
                        ShowGroupPanel="true" ShowFooter="false" OnPageSizeChanged="RadGridPattern_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridPattern_PageIndexChanged" EnableHeaderContextMenu="true"
                        EnableHeaderContextFilterMenu="true" AutoGenerateColumns="false" OnItemDataBound="RadGridPattern_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnGroupsChanging="RadGridPattern_GroupsChanging" OnItemCommand="RadGridPattern_ItemCommand"
                        OnSortCommand="RadGridPattern_SortCommand">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <GroupingSettings CaseSensitive="false" />
                        <MasterTableView AllowFilteringByColumn="true" TableLayout="Auto" GroupsDefaultExpanded="false">
                            <Columns>
                                <telerik:GridBoundColumn UniqueName="Number" SortExpression="Number" HeaderText="Number"
                                    CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" FilterControlWidth="60px"
                                    DataField="Number">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="NickName" SortExpression="NickName" HeaderText="Auto Description"
                                    CurrentFilterFunction="Contains" FilterControlWidth="110px" AutoPostBackOnFilter="true"
                                    DataField="NickName">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="SubItem" SortExpression="SubItem" HeaderText="Sub Item"
                                    FilterControlWidth="100px" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                    DataField="SubItem">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="CoreCategory" SortExpression="CoreCategory"
                                    HeaderText="Core Category" CurrentFilterFunction="Contains" FilterControlWidth="100px"
                                    AutoPostBackOnFilter="true" DataField="CoreCategory">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="Manual Description" Groupable="false" DataField="Remarks">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtManualDescription" TextMode="MultiLine" runat="server"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Marketing Description" Groupable="false" DataField="MarketingDescription">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtMarketingDescription" TextMode="MultiLine" runat="server"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Notes" Groupable="false" DataField="PatternNotes">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txNotes" TextMode="MultiLine" runat="server"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Factory Description" Groupable="false" DataField="FactoryDescription">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtFactoryDescription" TextMode="MultiLine" runat="server"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="Gender" SortExpression="Gender" HeaderText="Gender"
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="Gender">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Item" SortExpression="Item" HeaderText="Item"
                                    CurrentFilterFunction="Contains" FilterControlWidth="100px" AutoPostBackOnFilter="true"
                                    DataField="Item">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="AgeGroup" SortExpression="AgeGroup" HeaderText="Age Group"
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="AgeGroup">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="CorePattern" SortExpression="CorePattern" HeaderText="Corr Pattern"
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="CorePattern">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="SizeSet" SortExpression="SizeSet" HeaderText="Size Set"
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="SizeSet">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="OriginRef" SortExpression="OriginRef" HeaderText="Origin Ref."
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="OriginRef">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="PrinterType" SortExpression="PrinterType" HeaderText="Printer Type"
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="PrinterType">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="SpecialAttributes" SortExpression="SpecialAttributes" HeaderText="Special Attributes"
                                    CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="SpecialAttributes">
                                </telerik:GridBoundColumn>
                                <telerik:GridNumericColumn UniqueName="ConvertionFactor" SortExpression="ConvertionFactor" HeaderText="Convertion Factor" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="true"
                                    DataField="ConvertionFactor">
                                </telerik:GridNumericColumn>
                                <telerik:GridTemplateColumn UniqueName="Spec" HeaderText="Spec" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblStatus" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn UniqueName="Post" HeaderText="Post" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="litPost" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:LinkButton ID="lbSave" runat="server" OnClick="lbSave_Click" CssClass="btn-link" ToolTip="Save"><i class="icon-pencil"></i>Save</asp:LinkButton>
                                                </li>

                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="True" AllowGroupExpandCollapse="true" AllowExpandCollapse="true">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="true" />
                    </telerik:RadGrid>

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
    <asp:HiddenField ID="hdnSelectedAgeGroupID" runat="server" Value="0" />
    <!-- Add / Edit Item -->

    <!-- Delete Item -->

    <!-- / -->
    <script type="text/javascript">
        $(document).ready(function () {

        });
    </script>
</asp:Content>
