<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Indico.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Order Processing System" />
    <title>Order Processing System</title>

    <link href="Content/css/bootstrap.css" rel="stylesheet" />
    <link href="Content/css/bs-callout.css" rel="stylesheet" />
    <link href="Content/css/form-signin.css" rel="stylesheet" />

    <script src="Content/js/jquery/jquery-1.10.1.min.js"></script>
    <script src="Content/js/modernizr-2.5.3-respond-1.1.0.min.js"></script>
</head>
<body>
    <div class="container">

        <div id="dvErrorMessage" runat="server" class="signin-error" visible="false">
            <div class=" alert alert-danger" role="alert">
                <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <strong>Incorrect Username / Password Combination.</strong><br />
                Passwords are case sensitive. Please check your <b>CAPS</b> lock key.
            </div>
        </div>

        <form id="boxFrom" runat="server" defaultbutton="btnLogin">
            <div class="form-signin">
                <div class="signin-logo">
                    <img src="Content/img/logo_login.png" alt="Logo" />
                </div>
                <!-- /Logo -->
                <div id="loginBox" runat="server" class="signin-content" visible="true">

                    <div id="boxWarning" runat="server" class="bs-callout bs-callout-danger" visible="false">
                        <h4>Inactive !</h4>
                        <p>Your account was inactive. Please contact the administrator.</p>
                    </div>

                    <label class="sr-only">Username</label>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Username"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvUsername" runat="server" CssClass="bs-callout bs-callout-danger" ControlToValidate="txtUsername" ValidationGroup="validatelogin" Display="Dynamic" EnableClientScript="false" ErrorMessage="Enter your username">
                    </asp:RequiredFieldValidator>

                    <label class="sr-only">Password</label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" placeholder="Password" TextMode="Password"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" CssClass="bs-callout bs-callout-danger" ControlToValidate="txtPassword" ValidationGroup="validatelogin" Display="Dynamic" EnableClientScript="false" ErrorMessage="Password can't be blank">
                    </asp:RequiredFieldValidator>

                    <div class="checkbox">
                        <label class="pull-right">
                            <a id="linkForgot" runat="server" class="iforgetpassword" href="javascript:void(0);">Forgot your password ?</a>
                        </label>
                        <label>
                            <asp:CheckBox ID="chkRememberMe" runat="server" />Remember me
                        </label>
                    </div>
                    <asp:Button ID="btnLogin" runat="server" CssClass="btn btn-lg btn-primary btn-block" OnClick="btnLogin_Click" ValidationGroup="validatelogin" Text="Login" />
                </div>
                <!-- /Login -->
                <div id="requestForgetPassword" class="modal fade" data-backdrop="static" keyboard="false">
                    <div class="modal-dialog">
                        <div class="modal-content">

                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                                <h4 class="modal-title">Forget Password</h4>
                            </div>
                            <div class="modal-body">
                                <label class="sr-only">Email Address</label>
                                <asp:TextBox ID="txtEmailAddress" runat="server" CssClass="form-control" placeholder="Email Address"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvEmailAddress" runat="server" CssClass="bs-callout bs-callout-danger" ControlToValidate="txtEmailAddress" ValidationGroup="validateresetpassword" Display="Dynamic" EnableClientScript="false" ErrorMessage="Enter your email address">                                        
                                </asp:RequiredFieldValidator>
                                <asp:RegularExpressionValidator ID="revEmail" runat="server" CssClass="bs-callout bs-callout-danger" ErrorMessage="Invalid Email format" ValidationExpression="\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ControlToValidate="txtEmailAddress" EnableClientScript="false">
                                </asp:RegularExpressionValidator>
                            </div>
                            <div class="modal-footer">
                                <a id="linkBack" runat="server" class="btn btn-link pull-left" href="~/login.aspx"><span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>Back</a>
                                <button id="btnReset" runat="server" class="btn btn-primary" onserverclick="btnReset_Click" validationgroup="validateresetpassword" type="submit">
                                    Reset Password
                                </button>
                            </div>
                        </div>
                        <!-- /.modal-content -->
                    </div>
                    <!-- /.modal-dialog -->
                </div>
                <!-- /.modal -->
                <div class="modal fade" role="dialog" aria-hidden="true">

                    <div class="modal-body">
                        <div class="control-group">
                            <label class="control-label"></label>
                            <div class="controls">
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                    </div>
                </div>
                <!-- /FogetPassword -->
            </div>
        </form>
    </div>
    <!-- /container -->
    <script src="Content/js/bootstrap.js"></script>
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        $('.iforgetpassword').click(function () {
            $('#requestForgetPassword').modal('show')
        });
        if (IsPageValid) {
            window.setTimeout(function () {
                $('#requestForgetPassword').modal('show');
            }, 10);
        }
    </script>
</body>
</html>
