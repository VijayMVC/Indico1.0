<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditUser.aspx.cs" Inherits="Indico.AddEditUser" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <button id="btnResetPassword" visible="false" runat="server" class="btn btn-link  pull-right" onserverclick="btnResetPassword_OnClick">
                    Reset Password</button>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <legend>Details </legend>
                <div class="control-group" id="dvCompany" runat="server">
                    <label class="control-label required">
                        Company</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlCompany" CssClass="input-xlarge" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCompany_SelectedIndexChange">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvCompany" runat="server" ErrorMessage="Company is required"
                            ControlToValidate="ddlCompany" InitialValue="0" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Company  is required" alt="Company is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Role</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlRole" runat="server" Enabled="false">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvddlRole" runat="server" ErrorMessage="Role  is required"
                            ControlToValidate="ddlRole" InitialValue="0" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Role  is required" alt="Role  is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Status</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlStatus" runat="server">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvStatus" runat="server" ErrorMessage="Status  is required"
                            ControlToValidate="ddlStatus" InitialValue="0" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Status  is required" alt="Status  is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Designation</label>
                    <div class="controls">
                        <asp:TextBox ID="txtDesignation" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group" id="dvCheckBox" runat="server">
                    <div class="controls">
                        <label class="checkbox inline">
                            <asp:CheckBox ID="chkHttpPost" runat="server" />
                            Allow Access Blackchrome
                        </label>
                    </div>
                </div>
                <div class="control-group" id="dvDirectSales" runat="server">
                    <div class="controls">
                        <label class="checkbox inline">
                            <asp:CheckBox ID="chkDirectSales" runat="server" />
                            Is Direct Sales Person
                        </label>
                    </div>
                </div>
                <legend>Username </legend>
                <div class="control-group">
                    <label class="control-label required">
                        Username</label>
                    <div class="controls">
                        <asp:TextBox ID="txtUsername" runat="server" autocomplete="off"></asp:TextBox>                        
                        <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ErrorMessage="Username is required"
                            ControlToValidate="txtUsername" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Username is required" alt="Username is required" />
                        </asp:RequiredFieldValidator>
                        <asp:CustomValidator ID="cvUsername" runat="server" ErrorMessage="This Username is already being used"
                            OnServerValidate="cfvUserName_Validate" ControlToValidate="txtUsername" ValidateEmptyText="true">
                        <img src="Content/img/icon_warning.png"  title="This Username is already being used" alt="This Username is already being used" />
                        </asp:CustomValidator>
                    </div>
                </div>
                <legend>Personal </legend>
                <div class="control-group">
                    <div class="controls">
                        <label>
                            <asp:Image ID="imgUser" runat="server" CssClass="avatar64 img-polaroid" />
                        </label>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        First Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtGivenName" runat="server"></asp:TextBox>
                        <asp:CustomValidator ID="cvGivenName" runat="server" ErrorMessage="First Name length cannot be exceeded 32 characters"
                            OnServerValidate="cvGivenName_Validate" ControlToValidate="txtGivenName" ValidateEmptyText="true">
                        <img src="Content/img/icon_warning.png"  title="First Name length cannot be exceeded 32 characters" alt="First Name length cannot be exceeded 32 characters" />
                        </asp:CustomValidator>
                        <asp:RequiredFieldValidator ID="rfvGivenName" runat="server" ErrorMessage="Given Name is required"
                            ControlToValidate="txtGivenName" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Given Name is required" alt="Given Name is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Last Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtFamilyName" runat="server"></asp:TextBox>
                        <asp:CustomValidator ID="cvLastName" runat="server" ErrorMessage="Last Name length cannot be exceeded 32 characters"
                            OnServerValidate="cvLastName_Validate" ControlToValidate="txtFamilyName" ValidateEmptyText="true">
                        <img src="Content/img/icon_warning.png"  title="Last Name length cannot be exceeded 32 characters" alt="Last Name length cannot be exceeded 32 characters" />
                        </asp:CustomValidator>
                        <asp:RequiredFieldValidator ID="rfvFamilyName" runat="server" ErrorMessage="Family Name is required"
                            ControlToValidate="txtFamilyName" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Family Name is required" alt="Family Name is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Email
                    </label>
                    <div class="controls">
                        <div class="input-prepend">
                            <span class="add-on"><i class="icon-envelope"></i></span>
                            <asp:TextBox ID="txtEmailAddress" runat="server"></asp:TextBox>
                        </div>
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ErrorMessage="Email Address is Required"
                            ControlToValidate="txtEmailAddress" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Email Address is required" alt="Email Address is required" />
                        </asp:RequiredFieldValidator>
                        <asp:RegularExpressionValidator ID="revEmail" runat="server" ErrorMessage="Invalid Email format"
                            ValidationExpression="\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ControlToValidate="txtEmailAddress"
                            EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Invalid Email format" alt="Invalid Email format" />
                        </asp:RegularExpressionValidator>
                        <asp:CustomValidator ID="cvEmail" runat="server" ErrorMessage="This Email Address is already being used"
                            OnServerValidate="cfvEmailAddress_Validate" ControlToValidate="txtEmailAddress"
                            ValidateEmptyText="true">
                        <img src="Content/img/icon_warning.png"  title="This Email Address is already being used" alt="This Email Address is already being used" />
                        </asp:CustomValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Phone
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtOfficeTelephoneNo" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvOfficeTelephoneNo" runat="server" ErrorMessage="Office Phone No is required"
                            ControlToValidate="txtOfficeTelephoneNo" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Office Phone No is required" alt="Office Phone No is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Mobile
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtMobileTelephoneNo" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Home
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtHomeTelephoneNo" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="form-actions">
                    <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_Click"
                        data-loading-text="Saving..." type="submit">
                        Save Changes</button>
                    <button id="btnClose" runat="server" class="btn btn-default" type="submit" causesvalidation="false" onserverclick="btnClose_ServerClick">
                        Cancel                                       
                    </button>
                </div>
                <!-- / -->
            </div>
        </div>
    </div>
    <!-- / -->
    <!-- / -->
    <script type="text/javascript">       
        var ddlCompany = "<%=ddlCompany.ClientID %>"
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#' + ddlCompany).select2();
        });
    </script>
</asp:Content>
