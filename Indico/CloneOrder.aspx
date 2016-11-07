<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true" EnableEventValidation="false"
    CodeBehind="CloneOrder.aspx.cs" Inherits="Indico.CloneOrder" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
            </div>
            <h3>Clone Order</h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                ValidationGroup="valGrpClone" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
              <div class="control-group">
                <label class="control-label">
                    Distributor</label>
                <div class="controls">
                    <asp:Label ID="lblDistributor" runat="server" style="margin-top: 2px !important;"></asp:Label>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">
                    Client</label>
                <div class="controls">
                    <asp:Label ID="lblClient" runat="server" style="margin-top: 2px !important;"></asp:Label>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">
                    Job Name</label>
                <div class="controls">
                    <asp:Label ID="lblJobName" runat="server" style="margin-top: 2px !important;"></asp:Label>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">
                    Billing Address</label>
                <div class="controls">
                    <asp:Label ID="lblBillingAddress" runat="server" style="margin-top: 2px !important;"></asp:Label>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">
                    Despatch Address</label>
                <div class="controls">
                    <asp:Label ID="lblDespatchAddress" runat="server" style="margin-top: 2px !important;"></asp:Label>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">
                    Date Required in Customers Hand</label>
                <div class="controls">
                    <asp:Label ID="lblDateRequiredinCustomersHand" runat="server" style="margin-top: 2px !important;"></asp:Label>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">
                    Shipment Date</label>
                <div class="controls">
                    <asp:Label ID="lblShipmentDate" runat="server" style="margin-top: 2px !important;"></asp:Label>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">
                    Shipment Term</label>
                <div class="controls">
                    <asp:Label ID="lblShipmentTerm" runat="server" style="margin-top: 2px !important;"></asp:Label>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">
                    Shipment Mode</label>
                <div class="controls">
                    <asp:Label ID="lblShipmentMode" runat="server" style="margin-top: 2px !important;"></asp:Label>
                </div>
            </div>
        </div>
        <div class="page-content">
            <asp:Repeater ID="rptOrderDetails" runat="server" OnItemDataBound="rptOrderDetails_ItemDataBound" EnableViewState="true">
                <ItemTemplate>
                    <div class="control-group">
                        <asp:CheckBox ID="chkOrderDetail" runat="server" style="margin-left: 10px; margin-top: 1px;"></asp:CheckBox>
                        <asp:HiddenField ID="hdnODID" runat="server" Value="0" />
                        <asp:Label ID="lblVisualLayout" runat="server" style="margin-left: 10px;"></asp:Label>
                        <a id="ancVLImage" runat="server" style="margin-left: 10px;" target="_blank"><i id="ivlimageView" runat="server" class="icon-eye-open"></i></a>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:CustomValidator ID="cvOrderDetails" runat="server" ValidationGroup="valGrpClone" OnServerValidate="cvOrderDetails_ServerValidate" ErrorMessage="Visual Layout is required"
                ToolTip="Visual Layout is required">
                <img src="Content/img/icon_warning.png" style="padding-left:180px"  title="Visual Layout is required" alt="Visual Layout is required" />
            </asp:CustomValidator>
        </div>
        <div class="form-actions">
            <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_Click"
                data-loading-text="Saving..." type="submit" validationgroup="valGrpClone">
                Save Changes
            </button>
            <button id="btnClose" runat="server" class="btn btn-default" type="submit" causesvalidation="false" onserverclick="btnClose_ServerClick">
                Cancel                                       
            </button>
        </div>
    </div>
</asp:Content>
