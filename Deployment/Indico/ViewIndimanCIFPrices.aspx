<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewIndimanCIFPrices.aspx.cs" Inherits="Indico.ViewIndimanCIFPrices" %>

<%@ Register TagPrefix="iPriceLevels" TagName="PriceLevels" Src="~/Controls/IndicoPriceLevels.ascx" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
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
            <iPriceLevels:PriceLevels ID="iPriceLevels" runat="server" IsFOB="false" DisplayCostSheet="true" DisplayFabricPrice="true" DisplayJKPrice="true" DisplayFOBCost="true" DisplayMarginRates="true" DisplayIndimanPrice="true" />
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- / -->
</asp:Content>
