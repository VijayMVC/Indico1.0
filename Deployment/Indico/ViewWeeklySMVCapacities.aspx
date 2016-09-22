<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewWeeklySMVCapacities.aspx.cs" Inherits="Indico.ViewWeeklySMVCapacities"  MasterPageFile="~/Indico.Master" %>
<asp:Content ID="Content" ContentPlaceHolderID="iContentPlaceHolder" runat="server" >
    <asp:ScriptManager ID="PatternScriprtManaget" runat="server">
    </asp:ScriptManager>
    <div class="Page">
        <div class="page-header">
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div> <!--End Of The Page-Header-->
         <div class="page-content">
            <div class="row-fluid">
                 <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h4>
                        <a title="Weekly SMV Capacities.">Weekly SMV Capacities.</a>
                    </h4>
                    <p>
                        There are no data for  Weekly SMV capacities
                    </p>
                </div> <!-- Empty COntent-->
                <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                    <h4>Your search - <strong>
                        <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                        any documents.</h4>
                </div> <!--dvNoSearchResult-->
                <div id="dvDataContent" runat="server">
                    <div class="search-control clearfix">
                        <div class="form-inline pull-right">
                            <label>
                                From</label>
                            <asp:DropDownList ID="ddlMonth" runat="server" AutoPostBack="True" CssClass="input-medium"
                                OnSelectedIndexChanged="ddlMonth_SelectedIndexChanged">
                            </asp:DropDownList>
                            <asp:DropDownList ID="ddlYear" runat="server" AutoPostBack="True" CssClass="input-small"
                                OnSelectedIndexChanged="ddlYear_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                        <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>
                    </div> <!-- End Of Search Control --> 
                    
                   <telerik:RadGrid runat="server" ID="WeeklySMVSummaryRedGrid" AllowPaging="True" AllowFilteringByColumn="true" ShowGroupPanel="false" 
                                    PageSize="20"  ShowFooter="True"   Skin="Metro" CssClass="RadGrid"
                                    AutoGenerateColumns="false" AllowSorting="true" EnableEmbeddedSkins="true"
                                    OnItemCommand="OnWeeklySmvSummaryRedGridItemCommand"
                                    OnItemDataBound="OnWeeklySmvSummaryRedGridItemDataBound"
                                    OnPageIndexChanged="OnWeeklySmvSummaryRedGridPageIndexChanged"
                                    OnPageSizeChanged="OnWeeklySmvSummaryRedGridPageSizeChanged"
                                    OnSortCommand="OnWeeklySmvSummaryRedGridSortCommand">
                       <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                       <HeaderStyle BorderWidth="1px"></HeaderStyle>
                       <MasterTableView AllowFilteringByColumn="true">
                          <SortExpressions>
                              <telerik:GridSortExpression FieldName="WeekEndDate" SortOrder="Ascending"/>
                          </SortExpressions>
                          <ColumnGroups>
                                <telerik:GridColumnGroup HeaderText="Shirts & Other" Name="Polos" HeaderStyle-HorizontalAlign="Center">
                                </telerik:GridColumnGroup>
                                <telerik:GridColumnGroup HeaderText="Outerwear" Name="Jackets" HeaderStyle-HorizontalAlign="Center">
                                </telerik:GridColumnGroup>
                                <telerik:GridColumnGroup HeaderText="Total" Name="Total" HeaderStyle-HorizontalAlign="Center">
                                </telerik:GridColumnGroup>
                            </ColumnGroups>
                           <Columns>
                            <telerik:GridTemplateColumn HeaderText="Year/Week #"  AllowFiltering="false">
                                <ItemTemplate>
                                    <asp:HyperLink Target="_blank" ID="linkWeekYear" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                             <telerik:GridDateTimeColumn  HeaderText="Order Cut-off Time" Groupable="false" DataField="OrderCutOffDate"
                                                        PickerType="DatePicker" EnableTimeIndependentFiltering="true" FilterControlWidth="100px"
                                                        DataFormatString="{0:dddd, dd MMMM  yyyy}"/>
                            <telerik:GridDateTimeColumn HeaderText="Despatch from Factory (ETD)" Groupable="false" DataField="EstimatedDateOfDespatch"
                                                        PickerType="DatePicker" EnableTimeIndependentFiltering="true" FilterControlWidth="100px"
                                                        DataFormatString="{0:dddd, dd MMMM  yyyy}"/>
                            <telerik:GridDateTimeColumn HeaderText="Friday of the week" Groupable="false" DataField="WeekEndDate"
                                                        PickerType="DatePicker" EnableTimeIndependentFiltering="true" FilterControlWidth="100px"
                                                        DataFormatString="{0:dd MMMM yyyy}">
                            </telerik:GridDateTimeColumn>
                            <telerik:GridDateTimeColumn HeaderText="Expected Arrival Adelaide (ETA)" Groupable="false" DataField="EstimatedDateOfArrival"
                                                        PickerType="DatePicker" EnableTimeIndependentFiltering="true" FilterControlWidth="100px"
                                                        DataFormatString="{0:dddd, dd MMMM  yyyy}">
                            </telerik:GridDateTimeColumn>
                            <telerik:GridBoundColumn  HeaderText="Working Days" Groupable="false" AllowFiltering="False" FilterControlWidth="0" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                            </telerik:GridBoundColumn>
                           <telerik:GridTemplateColumn  HeaderText="Firm" AllowFiltering="false" ColumnGroupName="Polos" Aggregate="Sum" DataField="PoloFirms" FooterAggregateFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:HyperLink ID="PoloFirmLink" runat="server"><i class="icon-th-list"></i></asp:HyperLink>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn  HeaderText="Reservation" AllowFiltering="false" ColumnGroupName="Polos"   Aggregate="Sum" DataField="PoloReservations" FooterAggregateFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:HyperLink ID="PoloReservationsLink" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>

                            <telerik:GridTemplateColumn HeaderText="On Hold" AllowFiltering="false" ColumnGroupName="Polos" Aggregate="Sum" DataField="PoloHolds" FooterAggregateFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:HyperLink ID="PoloHoldLink" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn HeaderText="Total" AllowFiltering="false" ColumnGroupName="Polos" Aggregate="Sum" DataField="PoloTotal"  FooterAggregateFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:HyperLink ID="PoloTotalLink" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn HeaderText="Capacities" AllowFiltering="false" ColumnGroupName="Polos"  Aggregate="Sum" DataField="PoloCapacity" FooterAggregateFormatString="{0:N0}">
                                <ItemTemplate>
                                    <asp:TextBox ID="PoloCapacityTextBox" runat="server" CssClass="input-mini text-center"></asp:TextBox>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn HeaderText="Balance" AllowFiltering="false" ColumnGroupName="Polos" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="PoloBalanceLabel" runat="server"></asp:Label>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                               

                            <telerik:GridTemplateColumn HeaderText="Firm" AllowFiltering="false" ColumnGroupName="Jackets"  Aggregate="Sum" DataField="OuterWareFirms"  FooterAggregateFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:HyperLink ID="OuterwareFirmLink" runat="server"><i class="icon-th-list"></i></asp:HyperLink>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn HeaderText="Reservation" AllowFiltering="false" ColumnGroupName="Jackets"  Aggregate="Sum" DataField="OuterwareReservations"  FooterAggregateFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:HyperLink ID="OuterwareReservationsLink" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn HeaderText="On Hold" AllowFiltering="false" ColumnGroupName="Jackets"  Aggregate="Sum" DataField="OuterwareHolds"  FooterAggregateFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:HyperLink ID="OuterwareHoldLink" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn HeaderText="Total" AllowFiltering="false" ColumnGroupName="Jackets" Aggregate="Sum" DataField="OuterwareTotal"  FooterAggregateFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:HyperLink ID="OuterwareTotalLink" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn HeaderText="Capacities" AllowFiltering="false" ColumnGroupName="Jackets"  Aggregate="Sum" DataField="OuterwareCapacity"  FooterAggregateFormatString="{0:N0}">
                                <ItemTemplate>
                                    <asp:TextBox ID="OuterwareCapacityTextBox" runat="server" CssClass="input-mini text-center"></asp:TextBox>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn HeaderText="Balance" AllowFiltering="false" ColumnGroupName="Jackets" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="OuterwareBalanceLabel" runat="server"></asp:Label>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn HeaderText="Firm" AllowFiltering="false" ColumnGroupName="Total" Aggregate="Sum" DataField="TotalFirm"  FooterAggregateFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" >
                                <ItemTemplate>
                                    <asp:HyperLink ID="TotalFirmLink" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn HeaderText="Capacity" AllowFiltering="false" ColumnGroupName="Total" Aggregate="Sum" DataField="TotalCapacity"  FooterAggregateFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:HyperLink ID="TotalCapacityLink" runat="server"></asp:HyperLink>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn HeaderText="Holidays" AllowFiltering="false">
                                <ItemTemplate>
                                    <asp:TextBox ID="HolidaysTextBox" runat="server" CssClass="input-mini text-center"></asp:TextBox>
                                    <asp:HiddenField ID="hdnWeekendDate" runat="server" Value="" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                             <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                         <%--                   <li>
                                                <asp:LinkButton ID="linkPackingList" runat="server" title="Create Packing List" ToolTip="Create Packing Plan"><i class="icon-pencil"></i>Create Packing Plan</asp:LinkButton>
                                            </li>
                                            <li id="liViewPacking" runat="server">
                                                <asp:LinkButton ID="lnkViewPackingList" runat="server" title="Create Packing List" ToolTip="Create Packing List"><i class="icon-eye-open"></i>View Packing List</asp:LinkButton>
                                            </li>--%>
                                            <li>
                                                <asp:LinkButton ID="linkEditCapacity" runat="server" title="Save Capacity" ToolTip="Save Capacity" OnClick="OnlnkEditCapacityClick"><i class="icon-edit"></i>Save</asp:LinkButton>
                                            </li>
                                            <%--<li>
                                                <asp:HyperLink ID="linkWeekDetails" runat="server" ToolTip="View Week Details"><i class="icon-list-alt"></i>Week Details</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="linkSummary" runat="server" ToolTip="View Week Summary Details"><i class="icon-align-justify"></i>Week Summary</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="linkInvoice" runat="server" ToolTip="Create Invoice" Visible="true"><i class="icon-plus"></i>Create Invoice</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:HyperLink ID="linkViewInvoice" runat="server" ToolTip="View Invoice"><i class="icon-th-list"></i>View Invoice</asp:HyperLink>
                                            </li>
                                            <li>
                                                <asp:LinkButton ID="btnCreateBatchLabel" runat="server" ToolTip="Print Batch Labels" OnClick="OnbtnCreateBatchLabelClick"><i class="icon-download-alt"></i>Print Batch Labels</asp:LinkButton>
                                            </li>
                                            <li>
                                                <asp:LinkButton ID="btnCreateShippingDetail" runat="server" ToolTip="Print Shipping Details" OnClick="OnbtnCreateShipmentDetailClick"><i class="icon-download-alt"></i>Print Shipping Details</asp:LinkButton>
                                            </li>--%>
                                        </ul>
                                    </div>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                       </Columns>
                       </MasterTableView>
                       <ClientSettings AllowDragToGroup="false">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="false" />
                   </telerik:RadGrid> <!--End Of WeeklyPiecesSummaryRedGrid-->
                 </div> <!--End Of Data Context -->
           </div> <!-- End Of Row-->
        </div><!--End Of Page Content-->
    </div> <!--End Of The Page-->
    
</asp:Content>