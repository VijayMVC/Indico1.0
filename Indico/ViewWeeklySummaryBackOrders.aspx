<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewWeeklySummaryBackOrders.aspx.cs" Inherits="Indico.ViewWeeklySummaryBackOrders"  MasterPageFile="~/Indico.Master" %>


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
                 <div id="dvEmptyContent" runat="server" Visible="false" class="alert alert-info">
                    <h4>
                        <a title="Weekly SMV Capacities.">Weekly Summaries (Backorder)</a>
                    </h4>
                    <p>
                        There are no data for Backorder
                    </p>
                </div> <!-- Empty COntent-->
                <div id="dvNoSearchResult" runat="server"  class="message search" visible="false">
                    <h4>Your search - <strong>
                        <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                        any documents.</h4>
                </div> <!--dvNoSearchResult-->
                <div id="dvDataContent" runat="server">
                    <div class="search-control clearfix">
                        <div class="form-inline pull-left">
                             <div class="input-daterange pull-left" style="padding-left: 40px" id="datepicker" runat="server">

                                ETD <span class="add-on"> from</span>
                                <input type="text" class="input-small" name="start" id="txtCheckin" runat="server"  />
                                <span class="add-on">to</span>
                                <input type="text" class="input-small" name="end" id="txtCheckout" runat="server" style="margin-right: 5px;" />
                            </div>
                            <asp:Button ID="ShowButton" CssClass="btn btn-info" runat="server" Text="Show"  OnClick="OnShowButtonClick" />
                        </div>
                    </div> <!-- End Of Search Control --> 
                 </div>
                
                 <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server">
                    </telerik:RadAjaxLoadingPanel>
                  <div class="demo-container no-bg">
   
                   <telerik:RadGrid  ID="SummariesGrid" runat="server" AllowPaging="true" AllowFilteringByColumn="true"
                        ShowGroupPanel="true" ShowFooter="True" PageSize="50" EnableHeaderContextMenu="true" 
                        EnableHeaderContextFilterMenu="true" AutoGenerateColumns="false" OnItemDataBound="OnSummariesGridItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true" >
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <GroupingSettings CaseSensitive="false" />
                            <MasterTableView  ShowGroupFooter="true" AllowMultiColumnSorting="false">
                                <ColumnGroups>
                                    <telerik:GridColumnGroup Name="Pieces" HeaderText="Pieces" HeaderStyle-HorizontalAlign="Center"/>
                                    <telerik:GridColumnGroup Name="Jackets" HeaderText="Jackets" HeaderStyle-HorizontalAlign="Center" />
                                    <telerik:GridColumnGroup Name="UptoFiveOrders" HeaderText="Upto 5 Orders" HeaderStyle-HorizontalAlign="Center" />
                                    <telerik:GridColumnGroup Name="Samples" HeaderText="Samples" HeaderStyle-HorizontalAlign="Center"/>
                                </ColumnGroups>
                                <Columns>
                                    <telerik:GridTemplateColumn  FooterText=""  DataField="WeekNumber" FilterControlWidth="50px" HeaderText="Week #" UniqueName="WeekNumber" SortExpression="WeekNumber"  CurrentFilterFunction="StartsWith" AutoPostBackOnFilter="true" Groupable="false">
                                        <ItemTemplate>
                                            <asp:HyperLink target="_blank" ID="weekLink" runat="server"  />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridDateTimeColumn AllowSorting="True"  FooterText="" FilterControlWidth="100px" DataField="OrderCutOffDate" AutoPostBackOnFilter="true" HeaderText="Order Cut Off" UniqueName="OrderCutOffDate" SortExpression="OrderCutOffDate"  AllowFiltering="True" PickerType="DatePicker" Groupable="false"></telerik:GridDateTimeColumn>
                                    <telerik:GridDateTimeColumn AllowSorting="True"  FooterText="" FilterControlWidth="100px" DataField="EstimatedDateOfDespatch" AutoPostBackOnFilter="true"  HeaderText="Dispatch From Factory" UniqueName="EstimatedDateOfDespatch" SortExpression="EstimatedDateOfDespatch" PickerType="DatePicker" AllowFiltering="True" Groupable="false"></telerik:GridDateTimeColumn>
                                    <telerik:GridDateTimeColumn AllowSorting="True"  FooterText="" FilterControlWidth="100px" DataField="EstimatedDateOfArrival" AutoPostBackOnFilter="true" HeaderText="Expected Arrival Date" UniqueName="EstimatedDateOfArrival" SortExpression="EstimatedDateOfArrival" PickerType="DatePicker" AllowFiltering="True" Groupable="false"></telerik:GridDateTimeColumn>
                                    <telerik:GridTemplateColumn FooterStyle-Font-Bold="True" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ColumnGroupName="Pieces" FooterAggregateFormatString="{0:N0}" Aggregate="Sum" FooterStyle-ForeColor="Green" AllowFiltering="False" DataField="PoloFirms" FilterControlWidth="50px" HeaderText="Firm Orders" Groupable="false" UniqueName="PoloFirms" >
                                        <ItemTemplate>
                                            <asp:HyperLink target="_blank"  ID="poloFirmsLink"  runat="server"  />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn FooterStyle-Font-Bold="True" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ColumnGroupName="Pieces" FooterAggregateFormatString="{0:N0}" Aggregate="Sum" FooterStyle-ForeColor="Green"  AllowFiltering="False" DataField="PoloReservations" FilterControlWidth="50px" HeaderText="Reservations" Groupable="false" UniqueName="PoloReservations" >
                                        <ItemTemplate>
                                            <asp:HyperLink target="_blank"   ID="poloReservationsLink"  runat="server"  />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn FooterStyle-Font-Bold="True" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ColumnGroupName="Pieces" FooterAggregateFormatString="{0:N0}" Aggregate="Sum" FooterStyle-ForeColor="Green" AllowFiltering="False"  DataField="PoloHolds" FilterControlWidth="50px" HeaderText="Holds" Groupable="false" UniqueName="PoloHolds" >
                                        <ItemTemplate>
                                            <asp:HyperLink target="_blank"  ID="poloHoldLink"  runat="server"  />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn FooterStyle-Font-Bold="True" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ColumnGroupName="Pieces" FooterAggregateFormatString="{0:N0}" Aggregate="Sum" FooterStyle-ForeColor="Green"  AllowFiltering="False" DataField="TotalPolo" FilterControlWidth="50px" HeaderText="Total" Groupable="false" UniqueName="TotalPolo" >
                                        <ItemTemplate>
                                            <asp:HyperLink target="_blank"  ID="totalPoloLink"  runat="server"  />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                        <telerik:GridTemplateColumn FooterStyle-Font-Bold="True" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ColumnGroupName="Pieces" FooterAggregateFormatString="{0:N0}" Aggregate="Sum" FooterStyle-ForeColor="Green" AllowFiltering="False" DataField="PoloCapacity" FilterControlWidth="50px" HeaderText="Capacity" Groupable="false" UniqueName="TotalPiecesCapacity" >
                                        <ItemTemplate>
                                            <asp:Label  ID="totalCapacityLabel"  runat="server"  />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn FooterStyle-Font-Bold="True" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ColumnGroupName="Pieces" AllowFiltering="False" FilterControlWidth="50px" HeaderText="+/-" DataField="PoloBalance" Groupable="false" UniqueName="Balance" >
                                        <ItemTemplate>
                                            <asp:Label  ID="balanceLabel"  runat="server"  />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                        <telerik:GridTemplateColumn FooterStyle-Font-Bold="True" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ColumnGroupName="Jackets" FooterAggregateFormatString="{0:N0}" Aggregate="Sum" FooterStyle-ForeColor="Green" AllowFiltering="False" DataField="OuterWareFirms" FilterControlWidth="50px" HeaderText="Jkts" Groupable="false" UniqueName="Jackets" >
                                        <ItemTemplate>
                                            <asp:HyperLink target="_blank"  ID="jacketsLink"  runat="server"  />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn ColumnGroupName="Jackets" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" AllowFiltering="False" FilterControlWidth="50px" HeaderText="Capacity" DataField="OuterwareCapacity" Groupable="False" UniqueName="JacketsCapacity" >
                                        <ItemTemplate>
                                            <asp:Label ID="jacketsCapacityLabel"  runat="server"  />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn FooterStyle-Font-Bold="True" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ColumnGroupName="UptoFiveOrders" FooterAggregateFormatString="{0:N0}" Aggregate="Sum" FooterStyle-ForeColor="Green" AllowFiltering="False" DataField="UptoFiveItems" FilterControlWidth="50px" HeaderText="<=5" Groupable="False" UniqueName="UptoFiveOrders" >
                                        <ItemTemplate>
                                            <asp:HyperLink target="_blank"  ID="uptoFiveOrdersLink"  runat="server"  />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn  ColumnGroupName="UptoFiveOrders" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" AllowFiltering="False" FilterControlWidth="50px" HeaderText="Capacity" DataField="UptoFiveItemsCapacity" Groupable="False" UniqueName="UptoFiveOrdersCapacity" >
                                        <ItemTemplate>
                                            <asp:Label ID="uptoFiveOrderscapacityLabel"  runat="server"  />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn FooterStyle-Font-Bold="True" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ColumnGroupName="Samples" FooterAggregateFormatString="{0:N0}" Aggregate="Sum" FooterStyle-ForeColor="Green" AllowFiltering="False" DataField="Samples" FilterControlWidth="50px" HeaderText="Smpls" Groupable="False" UniqueName="Samples" >
                                        <ItemTemplate>
                                            <asp:HyperLink target="_blank"  ID="samplesLink"  runat="server"  />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridTemplateColumn ColumnGroupName="Samples" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"  AllowFiltering="False" FilterControlWidth="50px" DataField="SampleCapacity" HeaderText="capacity" Groupable="False" UniqueName="SamplesCapacity" >
                                        <ItemTemplate>
                                            <asp:Label ID="samplesCapacityLable"  runat="server"  />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                </Columns>
                                                       
                            </MasterTableView>
                            <GroupingSettings ShowUnGroupButton="false" CaseSensitive="false" RetainGroupFootersVisibility="true"></GroupingSettings>
                        </telerik:RadGrid>
                  </div>
            </div>
        </div> <!--page content-->
        <script src="Content/js/bootstrap2.3.2/bootstrap-datepicker.js"></script>
        <script type="text/javascript">
            $(".input-daterange").datepicker({ format: "M dd, yyyy" });
        </script>
    </div>
</asp:Content>