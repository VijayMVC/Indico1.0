<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="EditInformation.aspx.cs" Inherits="Indico.EditInformation" %>

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
            <div class="inner">
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>">
                </asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <fieldset>
                    <legend>Personal </legend>                   
                    <div class="control-group">
                        <label class="control-label required">
                            First Name</label>
                        <div class="controls">
                            <asp:TextBox ID="txtFirstName" runat="server" MaxLength="32"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvFirstName" Font-Bold="True" runat="server" EnableClientScript="False"
                                ErrorMessage="First name can't be blank" ControlToValidate="txtFirstName" ForeColor=""
                                Display="Dynamic">
                            <img src="Content/img/icon_warning.png" class="" title="First name can't be blank" alt="First name can't be blank" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Last Name</label>
                        <div class="controls">
                            <asp:TextBox ID="txtLastName" runat="server" MaxLength="32"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvLastName" runat="server" EnableClientScript="False"
                                ErrorMessage="Last name can't be blank" ControlToValidate="txtLastName" ForeColor=" "
                                Display="Dynamic">
                            <img src="Content/img/icon_warning.png" class="" title="Last name can't be blank" alt="Last name can't be blank" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Email</label>
                        <div class="controls">
                            <asp:TextBox ID="txtEmailAddress" runat="server" MaxLength="64"></asp:TextBox>
                            <asp:CustomValidator ID="cfvEmailChecker" runat="server" ErrorMessage="Email is already used in the system."
                                Enabled="true" Display="None" EnableClientScript="false" SetFocusOnError="true"
                                OnServerValidate="cfvEmailChecker_ServerValidate"><img src="Content/img/icon_warning.png" class="" title="Email is already used in the system." alt="Email is already used in the system." /></asp:CustomValidator>
                            <asp:RequiredFieldValidator ID="rfvContactEmail" runat="server" ErrorMessage="Email address is required"
                                ControlToValidate="txtEmailAddress" Display="Dynamic" EnableClientScript="False">
                            <img src="Content/img/icon_warning.png" title="Email address is required" alt="Email address is required" />
                            </asp:RequiredFieldValidator>
                            <asp:RegularExpressionValidator ID="rfvEmailAddress" runat="server" ErrorMessage="Invalid email address"
                                ControlToValidate="txtEmailAddress" Display="Dynamic" EnableClientScript="False"
                                ValidationExpression="^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$"
                                Font-Size="10pt">
                            <img src="Content/img/icon_warning.png" class="" title="Invalid email address" alt="Invalid email address" />
                            </asp:RegularExpressionValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Phone</label>
                        <div class="controls">
                            <asp:TextBox ID="txtPhoneNo" runat="server"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Mobile</label>
                        <div class="controls">
                            <asp:TextBox ID="txtMobileNo" runat="server"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Home</label>
                        <div class="controls">
                            <asp:TextBox ID="txtHomeNo" runat="server"></asp:TextBox>
                        </div>
                    </div>
                </fieldset>
                <fieldset>
                    <legend>Username </legend>
                    <div class="control-group">
                        <label class="control-label required">
                            Username</label>
                        <div class="controls">
                            <asp:TextBox ID="txtUsername" runat="server" MaxLength="20"></asp:TextBox>
                            <asp:CustomValidator ID="cfvUsername" runat="server" ErrorMessage="Username is already used in the system."
                                Enabled="true" Display="None" EnableClientScript="false" SetFocusOnError="true"
                                OnServerValidate="cfvUsername_ServerValidate">
                            <img src="Content/img/icon_warning.png" title="Username is already used in the system." alt="Username is already used in the system." />
                            </asp:CustomValidator>
                            <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ErrorMessage="Username can't be blank"
                                ControlToValidate="txtUsername" Display="Dynamic" EnableClientScript="False">
                            <img src="Content/img/icon_warning.png" title="Username is required" alt="Username is required" />
                            </asp:RequiredFieldValidator>
                            <p class="extra-helper">
                                <asp:Literal ID="litUserRoel" runat="server"></asp:Literal>
                            </p>
                        </div>
                    </div>
                </fieldset>
                <div class="form-actions">
                    <button id="btnSaveChanges" runat="server" class="btn btn-primary" onclick="btnSaveChanges_Click"
                        type="submit" data-loading-text="Saving...">
                        Save Changes
                    </button>
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
</asp:Content>
