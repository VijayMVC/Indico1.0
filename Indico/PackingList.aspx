<%@ Page Title="" Language="C#" AutoEventWireup="true" MasterPageFile="~/Indico.Master"
    CodeBehind="PackingList.aspx.cs" Inherits="Indico.PackingList" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->

                <legend>Details</legend>
                <div class="control-group">
                    <label class="control-label">
                        Shipment Mode
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlShipmentMode" runat="server"></asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Shipping Company
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlShippingAddress" runat="server"></asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <div class="controls">
                        <button id="btnSearch" runat="server" class="btn" type="submit" data-loading-text="Searching..." onserverclick="btnSearch_ServerClick">
                            Search</button>
                    </div>
                </div>
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h4>No order details found.</h4>
                </div>
                <!-- / -->
                <legend>Packing Details</legend>
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <%-- <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>--%>
                    </div>
                    <%-- <asp:Repeater ID="rptDistributor" runat="server" OnItemDataBound="rptDistributor_ItemDataBound">
                        <ItemTemplate>
                            <div class="clearfix">
                                <div class="alert alert-block alert-info pull-right span4">
                                    <!--<button data-dismiss="alert" class="close" type="button">×</button>-->
                                    <h4 class="alert-heading">
                                        <asp:Literal ID="litDate" runat="server"></asp:Literal>
                                    </h4>
                                    <p>
                                        <asp:Literal ID="litComapny" runat="server"></asp:Literal>
                                        <br />
                                        <asp:Literal ID="litAddress" runat="server"></asp:Literal>
                                        <br />
                                        <asp:Literal ID="litSuberb" runat="server"></asp:Literal>
                                        <br />
                                        <asp:Literal ID="litPostCode" runat="server"></asp:Literal>
                                        <br />
                                        <!--<asp:Literal ID="litCountry" runat="server"></asp:Literal>
                                        <br />-->
                                        <asp:Literal ID="litContactDetails" runat="server"></asp:Literal>
                                    </p>
                                </div>
                            </div>
                            <asp:Repeater ID="rptModes" runat="server" OnItemDataBound="rptModes_ItemDataBound">
                                <ItemTemplate>
                                    <h3>
                                        <asp:Literal ID="litShipmentMode" runat="server"></asp:Literal>
                                    </h3>--%>
                    <telerik:RadGrid ID="RadPackingList" runat="server" AllowPaging="false" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadPackingList_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadPackingList_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="false" EnableHeaderContextFilterMenu="false" OnGroupsChanging="RadPackingList_GroupsChanging"
                        AutoGenerateColumns="false" OnItemDataBound="RadPackingList_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadPackingList_ItemCommand"
                        OnSortCommand="RadPackingList_SortCommand">
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true">
                            <GroupByExpressions>
                                <telerik:GridGroupByExpression>
                                    <SelectFields>
                                        <telerik:GridGroupByField FieldAlias="CompanyName" FieldName="CompanyName"></telerik:GridGroupByField>
                                    </SelectFields>
                                    <GroupByFields>
                                        <telerik:GridGroupByField FieldName="CompanyName" SortOrder="None"></telerik:GridGroupByField>
                                    </GroupByFields>
                                </telerik:GridGroupByExpression>
                                <telerik:GridGroupByExpression>
                                    <SelectFields>
                                        <telerik:GridGroupByField FieldAlias="ShipmentMode" FieldName="ShipmentMode"></telerik:GridGroupByField>
                                    </SelectFields>
                                    <GroupByFields>
                                        <telerik:GridGroupByField FieldName="ShipmentMode" SortOrder="None"></telerik:GridGroupByField>
                                    </GroupByFields>
                                </telerik:GridGroupByExpression>
                            </GroupByExpressions>
                            <Columns>
                                <telerik:GridTemplateColumn HeaderText="ID" Groupable="false" Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblID" runat="server"></asp:Literal>
                                        <asp:Literal ID="lblParentID" runat="server"></asp:Literal>
                                        <asp:Literal ID="lblOrderDetailID" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Carton" Groupable="false" FilterControlWidth="25px" AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains" DataField="CartonNo">
                                    <ItemTemplate>
                                        <asp:TextBox Width="18" ID="txtCarton" runat="server"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Total" Groupable="false" AutoPostBackOnFilter="false" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="litTotal" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Size" Groupable="false" AllowFiltering="false">
                                    <ItemTemplate>
                                        <ol class="ioderlist-table">
                                            <asp:Repeater ID="rptSizeQtyView" runat="server" OnItemDataBound="rptSizeQtyView_ItemDataBound">
                                                <ItemTemplate>
                                                    <li class="idata-column">
                                                        <ul>
                                                            <li class="icell-header">
                                                                <asp:Literal ID="litHeading" runat="server"></asp:Literal>
                                                            </li>
                                                            <li class="icell-data">
                                                                <asp:Label ID="lblSize" runat="server" Visible="false"></asp:Label>
                                                                <asp:TextBox ID="txtQty" runat="server" Text="0" EnableViewState="true"></asp:TextBox>
                                                            </li>
                                                        </ul>
                                                    </li>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </ol>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="OrderNumber" SortExpression="OrderNumber" HeaderText="PO No" AllowSorting="true" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true" Groupable="false"
                                    FilterControlWidth="75px" DataField="OrderNumber">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Client" SortExpression="Client" HeaderText="Client" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Client">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Distributor" SortExpression="Distributor" HeaderText="Distributor" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Distributor">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="VLName" SortExpression="VLName" HeaderText="VL No" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="VLName">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Pattern" SortExpression="Pattern" HeaderText="Description" AllowSorting="true" CurrentFilterFunction="Contains" Groupable="false"
                                    FilterControlWidth="100px" AutoPostBackOnFilter="true" DataField="Pattern">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn AllowFiltering="false" Groupable="false">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtCartonAmount" Width="18" runat="server"></asp:TextBox>
                                        <asp:LinkButton ID="lnkSplitRow" runat="server" CommandName="Duplicate" CssClass="inprogress"></asp:LinkButton>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false" Visible="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:LinkButton ID="btnSave" Visible="false" runat="server" CssClass="btn-link iedit" ToolTip="Save Packing List" CommandName="Save"><i class="icon-edit"></i>Save</asp:LinkButton></li>
                                                </li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="true">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="true" />
                    </telerik:RadGrid>

                    <%--<asp:DataGrid ID="dgPackingList" runat="server" CssClass="table" AllowCustomPaging="False"
                                        AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                                        OnItemDataBound="dgPackingList_ItemDataBound" OnItemCommand="dgPackingList_ItemCommand">
                                        <HeaderStyle CssClass="header" />
                                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                                        <Columns>
                                            <asp:TemplateColumn HeaderText="ID" Visible="false">
                                                <ItemTemplate>
                                                    <asp:Literal ID="lblID" runat="server"></asp:Literal>
                                                    <asp:Literal ID="lblParentID" runat="server"></asp:Literal>
                                                    <asp:Literal ID="lblOrderDetailID" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Carton" ItemStyle-Width="4%">
                                                <ItemTemplate>
                                                    <asp:TextBox Width="18" ID="txtCarton" runat="server"></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Total" ItemStyle-Width="4%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="lblTotal" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Size" ItemStyle-Width="30%">
                                                <ItemTemplate>
                                                    <ol class="ioderlist-table">
                                                        <asp:Repeater ID="rptSizeQtyView" runat="server" OnItemDataBound="rptSizeQtyView_ItemDataBound">
                                                            <ItemTemplate>
                                                                <li class="idata-column">
                                                                    <ul>
                                                                        <li class="icell-header">
                                                                            <asp:Literal ID="litHeading" runat="server"></asp:Literal>
                                                                        </li>
                                                                        <li class="icell-data">
                                                                            <asp:Label ID="lblSize" runat="server" Visible="false"></asp:Label>
                                                                            <asp:TextBox ID="txtQty" runat="server" Text="0" EnableViewState="true"></asp:TextBox>
                                                                        </li>
                                                                    </ul>
                                                                </li>
                                                            </ItemTemplate>
                                                        </asp:Repeater>
                                                    </ol>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="PO No" ItemStyle-Width="4%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="lblPoNo" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Client" ItemStyle-Width="12%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="lblClient" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Distributor" ItemStyle-Width="12%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="lblDistributor" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="VL No" ItemStyle-Width="8%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="lblVLName" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Description" ItemStyle-Width="20%">
                                                <ItemTemplate>
                                                    <asp:Literal ID="lblDescription" runat="server"></asp:Literal>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn ItemStyle-Width="6%">
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtCartonAmount" Width="18" runat="server"></asp:TextBox>
                                                    <asp:LinkButton ID="lnkSplitRow" runat="server" CommandName="Duplicate" CssClass="inprogress"></asp:LinkButton>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn ItemStyle-Width="6%">
                                                <ItemTemplate>
                                                    <div class="btn-group pull-right" style="display: none;">
                                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                                        <ul class="dropdown-menu pull-right">
                                                            <li>
                                                                <asp:LinkButton ID="btnSave" Visible="false" runat="server" CssClass="btn-link iedit"
                                                                    ToolTip="Save Packing List" CommandName="Save"><i class="icon-edit"></i>Save</asp:LinkButton></li>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                        </Columns>
                                    </asp:DataGrid>--%>
                    <%--  </ItemTemplate>
                            </asp:Repeater>
                        </ItemTemplate>
                    </asp:Repeater>--%>
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> did not match
                            any Prices.
                        </h4>
                    </div>
                </div>
                <!-- / -->
                <!-- Empty Content -->
                <div id="dvEmptyContentPackingList" runat="server" class="alert alert-info">
                    <h4>
                        <asp:Literal ID="litErrorMeassage" runat="server"></asp:Literal></h4>
                </div>
                <!-- / -->
                <div class="form-actions" id="dvButton" runat="server">
                    <button id="btnProceed" runat="server" class="btn btn-primary inprogress" type="submit"
                        onserverclick="btnProceed_Click">
                        Save changes</button>
                </div>
            </div>
        </div>
    </div>
    <asp:HiddenField ID="hdnVlNumbers" runat="server" />
    <script type="text/javascript">
        var hdnVlNumbers = '<%=hdnVlNumbers.ClientID%>';
        $(document).ready(function () {
            var vl = $('#' + hdnVlNumbers).val().split(',');
            for (var i = 0; i < vl.length; i++) {
                if (vl[i] != '') {
                    $('td:contains(' + vl[i] + ')').parent().css('background-color', '#F08080');
                }
            }
        });
        //var inProgress = ('<%=ViewState["inProgress"]%>' == "True") ? true : false;
        //$(document).ready(function () {
        //    if (inProgress) {
        //        $('#waitingOverly').modal('show');
        //    }    
        //});
    </script>
</asp:Content>
