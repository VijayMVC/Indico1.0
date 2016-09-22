<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Welcome.aspx.cs" Inherits="Indico.Welcome" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Order Processing System</title>
    <link rel="shortcut icon" href="favicon.ico" />
    <link href="Content/css/bootstrap2.3.2/css/bootstrap.css" rel="stylesheet" />
    <link href="Content/css/bootstrap2.3.2/css/bootstrap-responsive.css" rel="stylesheet" />
    <%--<link href="Content/css/styles.css" rel="stylesheet" type="text/css" />--%>

    <link href="Content/css/bs-callout.css" rel="stylesheet" />
    <link href="Content/css/form-signin.css" rel="stylesheet" />
</head>
<body style="text-align: center">
    <div class="container" style="text-align: center">
        <%--        <div class="wrapper">
            <div class="ibox-wrapper">
                <div class="ibox-frame">
                    <div class="ibox-inner">
                        <!-- Logo -->
                        <div class="ibox-logo">
                            <img src="Content/img/logo_login.png" alt="Logo" />
                        </div>
                        <!-- / -->
                        <div class="ibox-form">--%>
        <form id="welcomeForm" defaultbutton="btnSaveChanges" runat="server" style="text-align: center">
            <div style="background-color: #fff; margin-top: 30px; position: relative; text-align: center">
                <div class="signin-logo">
                    <img src="Content/img/logo_login.png" alt="Logo" />
                </div>
                <!-- /Logo -->
                <div id="loginBox" runat="server" class="signin-content" visible="true">
                    <!-- Welcome Box -->
                    <fieldset>
                        <p class="muted">
                            This is a secure site.Please complete the form below by creating your own password
                                to gain access. <span>All fields are required.</span>
                        </p>
                        <div class="control-group">
                            <label class="control-label">
                                Username
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtUserName" runat="server" AutoComplete="off"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvUserName" runat="server" ControlToValidate="txtUserName"
                                    Display="Dynamic" EnableClientScript="false" ErrorMessage="Enter your username">
                                <span class="alert alert-error">Enter your username</span>
                                </asp:RequiredFieldValidator>
                                <asp:CustomValidator ID="cvUserName" runat="server" Display="Dynamic" EnableClientScript="false"
                                    ErrorMessage="This Username is already being used" OnServerValidate="cvUserName_Validate">
                                <span class="alert alert-error">Username is already being used</span>
                                </asp:CustomValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                First Name
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtFirstName" runat="server" AutoCompleteType="FirstName"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" ControlToValidate="txtFirstName"
                                    Display="Dynamic" EnableClientScript="false" ErrorMessage="First Name is required">
                                <span class="alert alert-error">First Name is required</span>
                                </asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Last Name
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtLastName" runat="server" AutoCompleteType="LastName"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvLastName" runat="server" ControlToValidate="txtLastName"
                                    Display="Dynamic" EnableClientScript="false" ErrorMessage="Last Name is required">
                                <span class="alert alert-error">Last Name is required</span>
                                </asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Password
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtChoosePassword" runat="server" AutoComplete="off" TextMode="Password"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvChoosePassword" runat="server" ControlToValidate="txtChoosePassword"
                                    Display="Dynamic" EnableClientScript="false" ErrorMessage="Password can't be blank">
                                <span class="alert alert-error">Password can't be blank</span>
                                </asp:RequiredFieldValidator>
                                <asp:CustomValidator ID="cvChoosePassword" runat="server" ErrorMessage="" ControlToValidate="txtChoosePassword"
                                    Display="Dynamic" EnableClientScript="false" OnServerValidate="cvPasswordLength_Validate"
                                    ValidateEmptyText="true">
                                    <span class="alert alert-error">
                                        <asp:Literal ID="litMessage" runat="server"></asp:Literal></span>
                                </asp:CustomValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Confirm Password
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtConfirmPassword" runat="server" AutoComplete="off" TextMode="Password"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword"
                                    Display="Dynamic" EnableClientScript="false" ErrorMessage="Confirm Password is required">
                                <span class="alert alert-error">Confirm password can't be blank</span>
                                </asp:RequiredFieldValidator>
                                <asp:CompareValidator ID="cfvConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword"
                                    ControlToCompare="txtChoosePassword" Display="Dynamic" EnableClientScript="false"
                                    ErrorMessage="Passwords are mismatch">
                                <span class="alert alert-error">Passwords are mismatch</span>
                                </asp:CompareValidator>
                            </div>
                        </div>
                        <div class="iform-action">
                            <asp:Button ID="btnSaveChanges" runat="server" CssClass="btn btn-primary" Text="Activate User"
                                OnClick="btnSaveChanges_Click" />
                        </div>
                    </fieldset>
                    <!-- / -->
                </div>
            </div>
        </form>
        <%--</div>
                    </div>
                </div>
            </div>
        </div>--%>
    </div>
</body>
</html>
