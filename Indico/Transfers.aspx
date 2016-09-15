<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Transfers.aspx.cs" Inherits="Indico.Transfers"  MasterPageFile="~/Indico.Master" %>

<asp:Content ID="aspContent" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <style type="text/css">
        .panel {
          padding: 15px;
          margin-bottom: 20px;
          background-color: #ffffff;
          border: 1px solid #dddddd;
          border-radius: 4px;
          -webkit-box-shadow: 0 1px 1px rgba(0, 0, 0, 0.05);
          box-shadow: 0 1px 1px rgba(0, 0, 0, 0.05);
        }

        .panel-heading {
          padding: 10px 15px;
          margin: -15px -15px 15px;
          font-size: 17.5px;
          font-weight: 500;      
          background-color: #f5f5f5;
          border-bottom: 1px solid #dddddd;
          border-top-right-radius: 3px;
          border-top-left-radius: 3px;
        }

        .panel-footer {
          padding: 10px 15px;
          margin: 15px -15px -15px;
          background-color: #f5f5f5;
          border-top: 1px solid #dddddd;
          border-bottom-right-radius: 3px;
          border-bottom-left-radius: 3px;
        }

        .panel-primary {
          border-color: #428bca;
        }

        .panel-primary .panel-heading {
          color: #ffffff;
          background-color: #428bca;
          border-color: #428bca;
        }

        .panel-success {
          border-color: #d6e9c6;
        }

        .panel-success .panel-heading {
          color: #468847;
          background-color: #dff0d8;
          border-color: #d6e9c6;
        }

        .panel-warning {
          border-color: #fbeed5;
        }

        .panel-warning .panel-heading {
          color: #c09853;
          background-color: #fcf8e3;
          border-color: #fbeed5;
        }

        .panel-danger {
          border-color: #eed3d7;
        }

        .panel-danger .panel-heading {
          color: #b94a48;
          background-color: #f2dede;
          border-color: #eed3d7;
        }

        .panel-info {
          border-color: #bce8f1;
        }

        .panel-info .panel-heading {
          color: #3a87ad;
          background-color: #d9edf7;
          border-color: #bce8f1;
        }

        .inlineContent {
            display: inline;
        }

        .transferButton {
            margin-left: 100px;
        }
    </style>
    
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>

    <div class="page">
        <div class="page-header">
            <h3>
                <asp:Literal ID="HearText" runat="server"></asp:Literal>
            </h3>
        </div>
        <div class="page-content">
            <div class="panel panel-primary">
                <div class="panel-heading">Transfer Job Names</div>
                <div class="panel-body">
                    <div class="form-inline">
                        <label>From Distributor </label>
                        <asp:DropDownList ID="FromDistributorDropDown" Width="300" runat="server" CssClass="input-medium select2" AutoPostBack="True"
                            OnSelectedIndexChanged="OnFromDistributorDropDownSelectionChanged">
                        </asp:DropDownList>
                        
                        <label style="margin-left: 20px;">Job name </label>
                        <asp:DropDownList ID="JobNameDropDown" Width="300" Enabled="False" runat="server" CssClass="input-medium select2" AutoPostBack="True"
                            OnSelectedIndexChanged="OnJobNameDropDownSelectionChanged">
                        </asp:DropDownList>
                        
                        <label style="margin-left: 50px;">Transfer To </label>
                        <asp:DropDownList ID="ToDistributorDropDown" Width="300" Enabled="False" runat="server" CssClass="input-medium select2" AutoPostBack="True"
                            OnSelectedIndexChanged="OnToDistributorDropDownSelectionChanged">
                        </asp:DropDownList>
                        
                        <asp:Button runat="server" ID="TransferJobNameButton" Text="Transfer job name"  CssClass="btn btn-info transferButton" Enabled="False" OnClick="OnTransferJobNameButtonClick" />
                    </div>
                    
                </div>
            </div>
            
            <div class="panel panel-primary">
                <div class="panel-heading">Transfer Products</div>
                <div class="panel-body">
                    <div class="form-inline">
                        <label>From Distributor </label>
                        <asp:DropDownList ID="FromDistributorVlDropDown" Width="300" runat="server" CssClass="input-medium select2" AutoPostBack="True"
                            OnSelectedIndexChanged="OnFromDistributorVlDropDownSelectionChanged">
                        </asp:DropDownList>

                        <label  style="margin-left: 50px;" >From Job name </label>
                        <asp:DropDownList ID="FromJobNameDropDown" Width="300"  runat="server" CssClass="input-medium select2" AutoPostBack="True"
                            OnSelectedIndexChanged="OnFromJobNameDropDownSelectionChanged">
                        </asp:DropDownList>
                    </div>
                    <div style="margin-top: 20px;">
                        <label class="text-info">(control and click to select multiple items)</label>
                        <telerik:RadListBox CheckBoxes="True" ShowCheckAll="True" RenderMode="Native" runat="server" ID="ProductsListBox" SelectionMode="Multiple" Height="600px" Width="800px">
                            <Items>
                               
                            </Items>
                        </telerik:RadListBox>
                    </div>
                    
                   <div class="form-inline" style="margin-top: 20px;">
                       <label>To Distributor </label>
                        <asp:DropDownList ID="ToDistributorVlDropDown" Width="300" runat="server" CssClass="input-medium select2" AutoPostBack="True"
                            OnSelectedIndexChanged="OnToDistributorVlDropDownSelectionChanged">
                        </asp:DropDownList>

                        <label  style="margin-left: 50px;">To Job name </label>
                        <asp:DropDownList ID="ToJobNameDropDown" Width="300" runat="server" CssClass="input-medium select2" AutoPostBack="True"
                            OnSelectedIndexChanged="OnToJobNameDropDownSelectionChanged">
                        </asp:DropDownList>
                       
                       <asp:Button runat="server" ID="TransferProductsButton" Text="Transfer Products"  CssClass="btn btn-info transferButton" Enabled="False" OnClick="OnTransferProductsButtonClick" />
                    </div>
                    
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript">
        $(document).ready(function() {
            $(".select2").select2();
        });
        
    </script>
</asp:Content>

