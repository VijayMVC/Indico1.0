<%@ Page EnableEventValidation="False" Language="C#" AutoEventWireup="true" CodeBehind="StockView.aspx.cs" MasterPageFile="~/Indico.Master" Inherits="Indico.StockView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <asp:ScriptManager runat="server"></asp:ScriptManager>
    <asp:HiddenField ID="hdnSelectedItemID" runat="server" Value="0" />
    <div class="page">
        <div class="page-header">
            <div class="header-actions">
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>

         <div class="page-content">

            <div class="row-fluid">
                <div class="wrapper">
                     <input id="txtSearch" runat="server" name="txtSearch" size="20" class="riTextBox riEnabled" type="text" value="" style="height: 25px;" />
                     <%--<asp:Button runat="server" CssClass="btn btn-primary" ID="SearchGoButton" OnClick="SearchGoButton_Click" Text="Go"/>--%>
                     <button type="button" id="searchbutton" runat="server" class="btn btn-info" onserverclick="searchbutton_Click"><i class="icon-search"></i></button>
                   <br /><br />
                    <telerik:RadGrid ID="StockGrid" runat="server" AllowPaging="true" AllowFilteringByColumn="true"  OnItemDataBound="StockGrid_ItemDataBound"
                        ShowGroupPanel="true" ShowFooter="false" OnPageSizeChanged="StockGrid_PageSizeChanged" OnItemCommand="StockGrid_ItemCommand"
                        PageSize="20" OnPageIndexChanged="StockGrid_PageIndexChanged" EnableHeaderContextMenu="true"
                        EnableHeaderContextFilterMenu="true" AutoGenerateColumns="false"  OnSortCommand="StockGrid_SortCommand"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true" >
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <GroupingSettings CaseSensitive="false" />
                        <MasterTableView AllowFilteringByColumn="true" TableLayout="Auto" GroupsDefaultExpanded="false">
                            <Columns>
                                 <telerik:GridBoundColumn  DataField="Code"  SortExpression="Code" HeaderText="Code"
                                     Groupable="True" UniqueName="Code" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Name"  SortExpression="Name" HeaderText="Name"
                                     Groupable="True" UniqueName="Name" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Category"  SortExpression="Category" HeaderText="Category"
                                     Groupable="True" UniqueName="Category" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="SubCategory"  SortExpression="SubCategory" HeaderText="SubCategory"
                                     Groupable="True" UniqueName="SubCategory" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Colour"  SortExpression="Colour" HeaderText="Colour"
                                     Groupable="True" UniqueName="Colour" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Attribute"  SortExpression="Attribute" HeaderText="Attribute"
                                     Groupable="True" UniqueName="Attribute" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="MinLevel"  SortExpression="MinLevel" HeaderText="Min Level"
                                     Groupable="True" UniqueName="MinLevel" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Uom"  SortExpression="Uom" HeaderText="UOM"
                                     Groupable="True" UniqueName="Uom" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="SupplierCode"  SortExpression="SupplierCode" HeaderText="Supplier"
                                     Groupable="True" UniqueName="SupplierCode" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Purchaser"  SortExpression="Purchaser" HeaderText="Purchaser"
                                     Groupable="True" UniqueName="Purchaser" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Balance"  SortExpression="Balance" HeaderText="Balance"
                                     Groupable="True" UniqueName="Balance" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 
                                  

                            </Columns>

                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="True" AllowGroupExpandCollapse="true" AllowExpandCollapse="true">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="true" />
                    </telerik:RadGrid>
                    </div>

                  
            </div>
        </div>
    </div>
    </asp:Content>