<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditCompany.aspx.cs" Inherits="Indico.AddEditCompany" %>

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
                    <legend>Details </legend>
                    <div class="control-group">
                        <label class="control-label required">
                            Type</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlType" runat="server">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvType" runat="server" ErrorMessage="Company type is required"
                                ControlToValidate="ddlType" InitialValue="0" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Company Type is required" alt="Company type is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Name</label>
                        <div class="controls">
                            <asp:TextBox ID="txtName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvName" runat="server" ErrorMessage="Name is required"
                                ControlToValidate="txtName" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Name is required" alt="Name is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Number</label>
                        <div class="controls">
                            <asp:TextBox ID="txtNumber" runat="server"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Address 1</label>
                        <div class="controls">
                            <asp:TextBox ID="txtAddress1" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvAddress1" runat="server" ErrorMessage="Address1 is required"
                                ControlToValidate="txtAddress1" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Address1 is required" alt="Address1 is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Address 2</label>
                        <div class="controls">
                            <asp:TextBox ID="txtAddress2" runat="server"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            City</label>
                        <div class="controls">
                            <asp:TextBox ID="txtCity" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvCity" runat="server" ErrorMessage="City is required"
                                ControlToValidate="txtCity" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="City is required" alt="City is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            State</label>
                        <div class="controls">
                            <asp:TextBox ID="txtState" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvState" runat="server" ErrorMessage="State is required"
                                ControlToValidate="txtState" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="State is required" alt="State is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Postal Code</label>
                        <div class="controls">
                            <asp:TextBox ID="txtPostalCode" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvPostalCode" runat="server" ErrorMessage="Postal Code is required"
                                ControlToValidate="txtPostalCode" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Postal Code is required" alt="Postal Code is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Country</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlCountry" runat="server">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvCountry" runat="server" ErrorMessage="Country is required"
                                ControlToValidate="ddlCountry" InitialValue="0" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Country is required" alt="Country is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Phone No 1</label>
                        <div class="controls">
                            <asp:TextBox ID="txtPhoneNo1" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvPhoneNo1" runat="server" ErrorMessage="Phone No 1 is required"
                                ControlToValidate="txtPhoneNo1" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Phone No 1 is required" alt="Phone No 1 is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Phone No 2</label>
                        <div class="controls">
                            <asp:TextBox ID="txtPhoneNo2" runat="server"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Mobile No</label>
                        <div class="controls">
                            <asp:TextBox ID="txtMobileNo" runat="server"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Email
                        </label>
                        <div class="controls">
                            <asp:TextBox ID="txtEmailAddress" runat="server"></asp:TextBox>
                            <asp:CustomValidator ID="cvEmailAddress" runat="server" ErrorMessage="This Email Address is already being used"
                                OnServerValidate="cfvEmailAddress_Validate" ControlToValidate="txtEmailAddress"
                                ValidateEmptyText="true">
                        <img src="Content/img/icon_warning.png"  title="This Email Address is already being used" alt="This Email Address is already being used" />
                            </asp:CustomValidator>
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ErrorMessage="Email  is required"
                                ControlToValidate="txtEmailAddress" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Email is required" alt="Email is required" />
                            </asp:RequiredFieldValidator>
                            <asp:RegularExpressionValidator ID="revEmail" runat="server" ErrorMessage="Invalid email format"
                                ValidationExpression="\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ControlToValidate="txtEmailAddress"
                                EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Invalid email format" alt="Invalid email format" />
                            </asp:RegularExpressionValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Fax No</label>
                        <div class="controls">
                            <asp:TextBox ID="txtFaxNo" runat="server"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Nick Name</label>
                        <div class="controls">
                            <asp:TextBox ID="txtNickName" runat="server"></asp:TextBox>
                        </div>
                    </div>
                    <legend>User Information</legend>
                    <div class="control-group">
                        <label id="lblUserName" runat="server" class="control-label required">
                            Username</label>
                        <div class="controls">
                            <asp:TextBox ID="txtUsername" runat="server"></asp:TextBox>
                            <asp:CustomValidator ID="cfvUsername" runat="server" ErrorMessage="This Username is already being used"
                                OnServerValidate="cfvUserName_Validate" ControlToValidate="txtUsername" ValidateEmptyText="true">
                        <img src="Content/img/icon_warning.png"  title="This Username is already being used" alt="This Username is already being used" />
                            </asp:CustomValidator>
                            <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ErrorMessage="Username is required"
                                ControlToValidate="txtUsername" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Username is required" alt="Username is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label id="lblFirstName" runat="server" class="control-label required">
                            First Name</label>
                        <div class="controls">
                            <asp:TextBox ID="txtGivenName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvGivenName" runat="server" ErrorMessage="Given Name is required"
                                ControlToValidate="txtGivenName" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Given Name is required" alt="Given Name is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label id="lblLastName" runat="server" class="control-label required">
                            Last Name</label>
                        <div class="controls">
                            <asp:TextBox ID="txtFamilyName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvFamilyName" runat="server" ErrorMessage="Family Name is required"
                                ControlToValidate="txtFamilyName" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Family Name is required" alt="Family Name is required" />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                </fieldset>
                <div class="form-actions">
                    <button id="btnSaveChanges" runat="server" class="btn btn-primary" type="submit"
                        onserverclick="btnSaveChanges_Click">
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
