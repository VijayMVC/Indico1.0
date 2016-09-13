<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ChangePassword.aspx.cs" Inherits="Indico.ChangePassword" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>">
                </asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <fieldset>
                    <legend>Change Your Password </legend>
                    <div class="control-group">
                        <label class="control-label required">
                            Current Password</label>
                        <div class="controls">
                            <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password" MaxLength="255"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvCurrentPassword" runat="server" EnableClientScript="False"
                                ErrorMessage="Current password is required" ControlToValidate="txtCurrentPassword"
                                ForeColor=" " Display="Dynamic">
                        <img src="Content/img/icon_warning.png" title="Current password is required" alt="Current password is required" />
                            </asp:RequiredFieldValidator>
                            <asp:CustomValidator ID="cfvCurrentPassword" runat="server" EnableClientScript="False"
                                ErrorMessage="Incorrect password" ControlToValidate="txtCurrentPassword" ForeColor=" "
                                Display="Dynamic" OnServerValidate="cfvCurrentPassword_ServerValidate">
                            <img src="Content/img/icon_warning.png" title="Incorrect password" alt="Incorrect password" />
                            </asp:CustomValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            New Password</label>
                        <div class="controls">
                            <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" MaxLength="255"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" EnableClientScript="False"
                                ErrorMessage="New password is required" ControlToValidate="txtNewPassword" ForeColor=" "
                                Display="Dynamic">
                            <img src="Content/img/icon_warning.png" title="New password is required" alt="New password is required" />
                            </asp:RequiredFieldValidator>
                            <asp:CustomValidator ID="cfvNewPassword" runat="server" EnableClientScript="False"
                                ErrorMessage="Password must be at least 6 characters" ControlToValidate="txtNewPassword"
                                ForeColor=" " Display="Dynamic" OnServerValidate="cfvNewPassword_ServerValidate">
                            <img src="Content/img/icon_warning.png" title="Password must be at least 6 characters" alt="Password must be at least 6 characters" />
                            </asp:CustomValidator>
                            <p class="extra-helper">
                                <span class="label label-info">Hint:</span> Password must be at least 6 characters</p>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Confirm New Password</label>
                        <div class="controls">
                            <asp:TextBox ID="txtConfirmNewPassword" runat="server" TextMode="Password" MaxLength="255"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvConfirmNewPassword" runat="server" EnableClientScript="False"
                                ErrorMessage="Confirm new password is required" ControlToValidate="txtNewPassword"
                                ForeColor=" " Display="Dynamic">
                        <img src="Content/img/icon_warning.png" title="Confirm new password is required" alt="Confirm new password is required" />
                            </asp:RequiredFieldValidator>
                            <asp:CompareValidator ID="cvConfirmNewPassword" runat="server" ErrorMessage="Password do not match."
                                ControlToCompare="txtNewPassword" ControlToValidate="txtConfirmNewPassword">
                                     <img src="Content/img/icon_warning.png"  title="Password do not match." alt="Password do not match." /></asp:CompareValidator>
                        </div>
                    </div>
                </fieldset>
                <div class="form-actions">
                    <button id="btnSaveChanges" runat="server" class="btn btn-primary" type="submit"
                        data-loading-text="Saving..." onserverclick="btnSaveChanges_Click">
                        Change Password</button>
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
</asp:Content>
