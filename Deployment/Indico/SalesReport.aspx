<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="SalesReport.aspx.cs" Inherits="Indico.SalesReport" %>

<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>

<asp:Content ID="aspContent" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <script type="text/javascript">
        $(document).ready(function () {
            var nowTemp = new Date();
            var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);
            $('.input-daterange').datepicker({ format: 'M dd, yyyy' });
        });
    </script>
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
                <div>
                    <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                        ValidationGroup="validateDate" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the report below</strong>"></asp:ValidationSummary>
                </div>
                <div class="search-control clearfix">
                    <div id="dvAdminFilters" runat="server" class="form-inline pull-left well well-sm">
                        <div class="pull-left" style="text">
                            <label>Distributor Name</label>
                            <asp:TextBox ID="txtName" runat="server" CssClass="input-large"></asp:TextBox>
                        <asp:RadioButton ID="rdoDirectSales" GroupName="DistributorType" runat="server" Checked="true" style="padding-left:40px" />
                            <label>Direct Sales</label>
                            <asp:RadioButton ID="rdoWholesale" GroupName="DistributorType" runat="server" style="padding-left:20px" />
                            <label>Wholesale</label>
                            <div style="display: none">
                                <label>Distributor</label>
                                <asp:DropDownList ID="ddlDistributor" runat="server" CssClass="input-xlarge"></asp:DropDownList>
                            </div>
                        </div>
                        <div class="input-daterange pull-left" style="padding-left:40px" id="datepicker" runat="server">
                            Order Date &nbsp <span class="add-on">From</span>
                            <input type="text" class="input-small" name="start" id="txtCheckin" runat="server" />
                            <asp:RequiredFieldValidator ID="rfvTxtCheckin" runat="server" ErrorMessage="Start date is required"
                                ValidationGroup="validateDate" ControlToValidate="txtCheckin" EnableClientScript="true">
                               <img src="Content/img/icon_warning.png"  title="Start date is required" alt="Start date is required" />
                            </asp:RequiredFieldValidator>
                            <span class="add-on">to</span>
                            <input type="text" class="input-small" name="end" id="txtCheckout" runat="server" />
                            <asp:RequiredFieldValidator ID="rfvTxtCheckout" runat="server" ErrorMessage="End date is required"
                                ValidationGroup="validateDate" ControlToValidate="txtCheckout" EnableClientScript="true">
                               <img src="Content/img/icon_warning.png"  title="End date is required" alt="End date is required" />
                            </asp:RequiredFieldValidator>
                             <asp:CustomValidator ID="cvDateRange" runat="server" ControlToValidate="txtCheckout" EnableClientScript="true"
                                    ErrorMessage="Start date should be less than end date" ValidationGroup="validateDate" OnServerValidate="cvDateRange_ServerValidate">
                                    <img src="Content/img/icon_warning.png"  title="Start date should be less than end date" alt="Start date should be less than end date" />
                                </asp:CustomValidator>
                        </div>
                        <div class="pull-left">
                            <asp:Button ID="btnViewReport" CssClass="btn btn-info" runat="server" Text="View Report" ValidationGroup="validateDate" OnClick="btnViewReport_OnClick" />
                            <asp:Button ID="btnPrintReport" CssClass="btn btn-info" runat="server" Text="Print Report" OnClick="btnPrintReport_OnClick" Visible="false" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="control-group">
                <rsweb:ReportViewer ID="rvSalesReport" runat="server" Width="1200px" Height="1000px">
                </rsweb:ReportViewer>
            </div>
        </div>
        <!-- / -->
    </div>

    <!-- / -->
    <script>
        var ddlDistributor = '<%= ddlDistributor.ClientID %>';

        $(document).ready(function () {
            $('#' + ddlDistributor).select2();
            $('a[alt="Word"]').hide();
            $('a[alt="Excel"]').hide();
        });
    </script>
</asp:Content>
