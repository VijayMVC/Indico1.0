<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="EditIndicoCIFPriceLevel.aspx.cs" Inherits="Indico.EditIndicoCIFPriceLevel" %>
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
           <iPriceLevels:PriceLevels ID="iPriceLevels" runat="server" IsFOB="false" DisplayPriceLevels="true" DisplayIndimanPrice ="true" />
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- / -->  
</asp:Content>
