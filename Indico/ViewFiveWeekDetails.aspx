<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewFiveWeekDetails.aspx.cs" Inherits="Indico.ViewFiveWeekDetails" MasterPageFile="~/Indico.Master" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="aspContent" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <style type="text/css">
        .customLegendWrapper {
            text-align: center;
            padding-top: 15px;
        }
 
        .customLegend {
            background-color: transparent;
            color: black;
            width: 50%;
            display: inline-block;
            *display: inline;
            zoom: 1;
            padding: 5px;
            margin: 0 auto;
            color: black;
            display: table;
            font-weight: bold;
            font-size: 15px;
        }
 
        .customLegend div {
            display: inline-block;
            *display: inline;
            zoom: 1;
            margin: 0 5px;
            height: 10px;
            margin-top: 10px;
        }
 
        .customLegend div div {
            width: 12px;
            height: 12px;
            vertical-align: -1px;
            _vertical-align: middle;
        }
 
        .customLegend .capacity div {
            background-color: #30abf2;
        }
 
        .customLegend .totalOrders div {
            background-color: #dc63ee;
        }
    
        .customLegend .totalOrdersCE div {
            background-color: #e74c3c;
        }

        .customLegend .firmOrders div {
            background-color: #00cc66;
        }

        .customLegend .reservations div {
            background-color: #ff9900;
        }

        .customLegend .samples div {
            background-color: #7f8c8d;
        }
        #mainContainer {
            margin-left: 20px;
            margin-right: 20px;
        }
    </style>
    <script type="text/javascript">
        function reloadPage() {
            window.location.reload();
            reloadthis();
        }

        function reloadthis() {
            setTimeout(reloadPage, 60000);
        }

        reloadthis();
    </script>
    <div class="Page"> 
        <div id="mainContainer">
            <telerik:RadHtmlChart  runat="server" ID="PoloChart" >
            <PlotArea>
                <Series>
                    <telerik:ColumnSeries Name="Capacity" DataFieldY="Capacity">
                            <Appearance >
                            <FillStyle BackgroundColor="#30abf2" ></FillStyle>
                        </Appearance>
                        <LabelsAppearance >
                                <TextStyle Bold="true" FontSize="15px" Color="#30abf2" />
                        </LabelsAppearance>
                        <TooltipsAppearance DataFormatString="{0} Capacity" Color="White"></TooltipsAppearance>
                    </telerik:ColumnSeries>
                        <telerik:ColumnSeries Name="Total Orders" DataFieldY="TotalOrders" ColorField="TotalOrdersColor">
                        <Appearance>
                            <FillStyle BackgroundColor="#dc63ee"></FillStyle>
                        </Appearance>
                            <LabelsAppearance DataField="TotalText" >
                                <TextStyle Bold="true" FontSize="15px" Color="#dc63ee"/>
                            </LabelsAppearance>
                        <TooltipsAppearance DataFormatString="{0} Total" Color="White"></TooltipsAppearance>
                    </telerik:ColumnSeries>
                    <telerik:ColumnSeries Name="Firm Orders" DataFieldY="FirmOrders">
                        <Appearance>
                            <FillStyle BackgroundColor="#00cc66"></FillStyle>
                        </Appearance>
                            <LabelsAppearance>
                                <TextStyle Bold="true" FontSize="15px" Color="#00cc66" />
                            </LabelsAppearance>
                        <TooltipsAppearance DataFormatString="{0} Firm" Color="White"></TooltipsAppearance>
                    </telerik:ColumnSeries>
                           
                    <telerik:ColumnSeries Name="Reservations" DataFieldY="Reservations">
                        <Appearance>
                            <FillStyle BackgroundColor="#ff9900"></FillStyle>
                        </Appearance>
                        <LabelsAppearance>
                                <TextStyle Bold="true"  FontSize="15px" Color="#ff9900"/>
                            </LabelsAppearance>
                        <TooltipsAppearance DataFormatString="{0} Reservation" Color="White"></TooltipsAppearance>
                    </telerik:ColumnSeries>
                    <telerik:ColumnSeries Name="Samples" DataFieldY="Samples">
                        <Appearance>
                            <FillStyle BackgroundColor="#7f8c8d"></FillStyle>
                        </Appearance>
                        <LabelsAppearance>
                                <TextStyle Bold="true" FontSize="15px" Color="#7f8c8d" />
                            </LabelsAppearance>
                        <TooltipsAppearance DataFormatString="{0} Samples" Color="White"></TooltipsAppearance>
                    </telerik:ColumnSeries>
                </Series>
                <Appearance>
                    <FillStyle BackgroundColor="Transparent"></FillStyle>
                </Appearance>
                <XAxis DataLabelsField="Week" AxisCrossingValue="0" Color="black" MajorTickType="Outside" MinorTickType="Outside"
                    Reversed="false">
                    <LabelsAppearance RotationAngle="0" Skip="0" Step="1" >
                        <TextStyle Bold="True" FontSize="15"></TextStyle>
                    </LabelsAppearance>
                    <TitleAppearance Position="Center" RotationAngle="0">
                    </TitleAppearance>
                </XAxis>
                <YAxis AxisCrossingValue="0" Color="black" MajorTickSize="1" MajorTickType="Outside"
                    MinorTickType="None" Reversed="false">
                    <LabelsAppearance DataFormatString="{0}" RotationAngle="0" Skip="0" Step="1"></LabelsAppearance>
                    <TitleAppearance Position="Center" RotationAngle="0">
                    </TitleAppearance>
                </YAxis>
            </PlotArea>
            <Appearance>
                <FillStyle BackgroundColor="Transparent"></FillStyle>
            </Appearance>
            <ChartTitle Text="Polo And Others">
                <Appearance>
                    <TextStyle Bold="True" Color="Black" FontSize="18" Italic="True" />
                </Appearance>
            </ChartTitle>
            <Legend >
                <Appearance  BackgroundColor="Transparent"  Position="Bottom" Visible="False">
                    <TextStyle Bold="True"></TextStyle>
                </Appearance>
            </Legend>
        </telerik:RadHtmlChart>
        <div class="customLegendWrapper">
            <div class="customLegend">
                <div class="capacity">
                    <div>
                    </div>
                    Capacity
                </div>
                <div class="totalOrders">
                    <div>
                    </div>
                    Total
                </div>
                <div class="totalOrdersCE">
                    <div>
                    </div>
                    Total (Capacity Exceeded)
                </div>
                <div class="firmOrders">
                    <div>
                    </div>
                    Firm
                </div>
                <div class="reservations">
                    <div>
                    </div>
                    Reservations
                </div>
                <div class="samples">
                    <div>
                    </div>
                    Samples
                </div>
            </div>
        </div>
        <br/>
        <br/>
       <telerik:RadHtmlChart  runat="server" ID="OuterwareChart" >
            <PlotArea>
                <Series>
                     <telerik:ColumnSeries Name="Capacity" DataFieldY="Capacity">
                            <Appearance >
                            <FillStyle BackgroundColor="#30abf2" ></FillStyle>
                        </Appearance>
                        <LabelsAppearance >
                                <TextStyle Bold="true" FontSize="15px" Color="#30abf2" />
                        </LabelsAppearance>
                        <TooltipsAppearance DataFormatString="{0} Capacity" Color="White"></TooltipsAppearance>
                    </telerik:ColumnSeries>
                        <telerik:ColumnSeries Name="Total Orders" DataFieldY="TotalOrders" ColorField="TotalOrdersColor">
                        <Appearance>
                            <FillStyle BackgroundColor="#dc63ee"></FillStyle>
                        </Appearance>
                            <LabelsAppearance DataField="TotalText" >
                                <TextStyle Bold="true" FontSize="15px" Color="#dc63ee"/>
                            </LabelsAppearance>
                        <TooltipsAppearance DataFormatString="{0} Total" Color="White"></TooltipsAppearance>
                    </telerik:ColumnSeries>
                    <telerik:ColumnSeries Name="Firm Orders" DataFieldY="FirmOrders">
                        <Appearance>
                            <FillStyle BackgroundColor="#00cc66"></FillStyle>
                        </Appearance>
                            <LabelsAppearance>
                                <TextStyle Bold="true" FontSize="15px" Color="#00cc66" />
                            </LabelsAppearance>
                        <TooltipsAppearance DataFormatString="{0} Firm" Color="White"></TooltipsAppearance>
                    </telerik:ColumnSeries>
                           
                    <telerik:ColumnSeries Name="Reservations" DataFieldY="Reservations">
                        <Appearance>
                            <FillStyle BackgroundColor="#ff9900"></FillStyle>
                        </Appearance>
                        <LabelsAppearance>
                                <TextStyle Bold="true"  FontSize="15px" Color="#ff9900"/>
                            </LabelsAppearance>
                        <TooltipsAppearance DataFormatString="{0} Reservation" Color="White"></TooltipsAppearance>
                    </telerik:ColumnSeries>
                    <telerik:ColumnSeries Name="Samples" DataFieldY="Samples">
                        <Appearance>
                            <FillStyle BackgroundColor="#7f8c8d"></FillStyle>
                        </Appearance>
                        <LabelsAppearance>
                                <TextStyle Bold="true" FontSize="15px" Color="#7f8c8d" />
                            </LabelsAppearance>
                        <TooltipsAppearance DataFormatString="{0} Samples" Color="White"></TooltipsAppearance>
                    </telerik:ColumnSeries>
                </Series>
                <Appearance>
                    <FillStyle BackgroundColor="Transparent"></FillStyle>
                </Appearance>
                <XAxis DataLabelsField="Week" AxisCrossingValue="0" Color="black" MajorTickType="Outside" MinorTickType="Outside" 
                    Reversed="false">
                    <LabelsAppearance RotationAngle="0" Skip="0" Step="1" >
                        <TextStyle Bold="True" FontSize="15"></TextStyle>
                    </LabelsAppearance>
                    <TitleAppearance Position="Center" RotationAngle="0">
                    </TitleAppearance>
                    
                </XAxis>
                <YAxis AxisCrossingValue="0" Color="black" MajorTickSize="1" MajorTickType="Outside"
                    MinorTickType="None" Reversed="false">
                    <LabelsAppearance DataFormatString="{0}" RotationAngle="0" Skip="0" Step="1"></LabelsAppearance>
                    <TitleAppearance Position="Center" RotationAngle="0">
                    </TitleAppearance>
                </YAxis>
            </PlotArea>
            <Appearance>
                <FillStyle BackgroundColor="Transparent"></FillStyle>
            </Appearance>
            <ChartTitle Text="Outerwear">
                <Appearance>
                    <TextStyle Bold="True" Color="Black" FontSize="18" Italic="True" />
                </Appearance>
            </ChartTitle>
            <Legend >
                <Appearance  BackgroundColor="Transparent"  Position="Bottom" Visible="False">
                    <TextStyle Bold="True"></TextStyle>
                </Appearance>
            </Legend>
        </telerik:RadHtmlChart>
        <div class="customLegendWrapper">
            <div class="customLegend">
                <div class="capacity">
                    <div>
                    </div>
                    Capacity
                </div>
                <div class="totalOrders">
                    <div>
                    </div>
                    Total
                </div>
                <div class="totalOrdersCE">
                    <div>
                    </div>
                    Total (Capacity Exceeded)
                </div>
                <div class="firmOrders">
                    <div>
                    </div>
                    Firm
                </div>
                <div class="reservations">
                    <div>
                    </div>
                    Reservations
                </div>
                <div class="samples">
                    <div>
                    </div>
                    Samples
                </div>
            </div>
        </div>
        </div>
    </div>
    
</asp:Content>