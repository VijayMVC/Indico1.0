<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditDistributor.aspx.cs" Inherits="Indico.AddEditDistributor" %>

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
                    DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <legend>Coordinator Information </legend>
                <div class="control-group" id="dvCheckBox" runat="server">
                    <div class="controls">
                        <label class="checkbox inline">
                            <asp:CheckBox ID="chkBackOrder" runat="server" />
                            Enable Back Orders
                        </label>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtName" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvName" runat="server" ErrorMessage="Name is required"
                            ControlToValidate="txtName" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png" title="Name is required" alt="Name is required" />
                           <%-- <asp:CustomValidator ID="cvName" runat="server" ErrorMessage="This Name is already being used" OnServerValidate="cvName_ServerValidate" ControlToValidate="txtName" ValidateEmptyText="true">
                                <img src="Content/img/icon_warning.png"  title="This Name is already being used" alt="This Name is already being used" />
                            </asp:CustomValidator>--%>
                        </asp:RequiredFieldValidator>
                         <asp:CustomValidator ID="cvTxtName" runat="server" OnServerValidate="cvTxtName_ServerValidate" ErrorMessage="Name is already in use"
                            ControlToValidate="txtName" EnableClientScript="false">
                             <img src="Content/img/icon_warning.png"  title="Name is already in use" alt="Name is already in use" />
                        </asp:CustomValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Country</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlCountry" runat="server" CssClass="input-xlarge">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvCountry" runat="server" ErrorMessage="Country is required"
                            ControlToValidate="ddlCountry" EnableClientScript="false" InitialValue="0">
                           <img src="Content/img/icon_warning.png"  title="Country is required" alt="Country is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Primary Coordinator
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlCoordinator" runat="server" CssClass="input-xlarge">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvddlCoordinator" runat="server" ErrorMessage="Coordinator is required"
                            ControlToValidate="ddlCoordinator" EnableClientScript="false" InitialValue="0">
                           <img src="Content/img/icon_warning.png"  title="Coordinator is required" alt="Coordinator is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <%--  <div class="control-group">
                    <label class="control-label">
                        Secondary Coordinator
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlSecondaryCoordinator" runat="server">
                        </asp:DropDownList>
                    </div>
                </div>--%>
                <div class="control-group">
                    <label class="control-label">
                        Nick Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtNickName" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                        <div class="controls">
                            <label class="checkbox inline">
                                <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" />
                                Is Active
                            </label>
                        </div>
                    </div>
                <legend>Contact Information </legend>
                <div class="control-group">
                    <label class="control-label">
                        Number</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCompanyNumber" runat="server"></asp:TextBox>
                       <%-- <asp:RequiredFieldValidator ID="rfvCompanyNumber" runat="server" ErrorMessage="Number is required"
                            ControlToValidate="txtCompanyNumber" EnableClientScript="false">
                           <img src="Content/img/icon_warning.png"  title="Number is required" alt="Number is required" />
                        </asp:RequiredFieldValidator>--%>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Address 1</label>
                    <div class="controls">
                        <asp:TextBox ID="txtAddress1" runat="server"></asp:TextBox>
                       <%-- <asp:RequiredFieldValidator ID="rfvAddress1" runat="server" ErrorMessage="Address 1 is required"
                            ControlToValidate="txtAddress1" EnableClientScript="false">
                           <img src="Content/img/icon_warning.png"  title="Address 1 is required" alt="Address 1 is required" />
                        </asp:RequiredFieldValidator>--%>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Address 2</label>
                    <div class="controls">
                        <asp:TextBox ID="txtAddress2" runat="server">
                        </asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        City</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCity" runat="server"></asp:TextBox>
                       <%-- <asp:RequiredFieldValidator ID="rfv" runat="server" ErrorMessage="City is required"
                            ControlToValidate="txtCity" EnableClientScript="false">
                           <img src="Content/img/icon_warning.png"  title="City is required" alt="City is required" />
                        </asp:RequiredFieldValidator>--%>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        State</label>
                    <div class="controls">
                        <asp:TextBox ID="txtState" runat="server"></asp:TextBox>
                       <%-- <asp:RequiredFieldValidator ID="rfvState" runat="server" ErrorMessage="State is required"
                            ControlToValidate="txtState" EnableClientScript="false">
                           <img src="Content/img/icon_warning.png"  title="State is required" alt="State is required" />
                        </asp:RequiredFieldValidator>--%>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Postal Code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtPostalCode" runat="server"></asp:TextBox>
                       <%-- <asp:RequiredFieldValidator ID="rfvPostalCOde" runat="server" ErrorMessage="Postal Code is required"
                            ControlToValidate="txtPostalCode" EnableClientScript="false">
                           <img src="Content/img/icon_warning.png"  title="Postal Code is required" alt="Postal Code is required" />
                        </asp:RequiredFieldValidator>--%>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Phone 1</label>
                    <div class="controls">
                        <asp:TextBox ID="txtPhoneNo1" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Phone 2</label>
                    <div class="controls">
                        <asp:TextBox ID="txtPhoneNo2" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Mobile
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtMobileNo" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Fax
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtFaxNo" runat="server"></asp:TextBox>
                    </div>
                </div>
               <%-- <div id="dvUser" runat="server">
                    <legend>User Information </legend>
                    <div class="control-group">
                        <label class="control-label required">
                            First Name</label>
                        <div class="controls">
                            <asp:TextBox ID="txtGivenName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvGivenName" runat="server" ErrorMessage="Given Name Is Required"
                                ControlToValidate="txtGivenName" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Given Name Is Required" alt="Given Name Is Required" />
                            </asp:RequiredFieldValidator>
                            <asp:CustomValidator ID="cvGivenName" runat="server" ErrorMessage="First Name length cannot be exceeded 32 characters"
                                OnServerValidate="cvGivenName_Validate" ControlToValidate="txtGivenName" ValidateEmptyText="true">
                        <img src="Content/img/icon_warning.png"  title="First Name length cannot be exceeded 32 characters" alt="First Name length cannot be exceeded 32 characters" />
                            </asp:CustomValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Last Name</label>
                        <div class="controls">
                            <asp:TextBox ID="txtFamilyName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvFamilyName" runat="server" ErrorMessage="Family Name is Required"
                                ControlToValidate="txtFamilyName" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Family Name is Required" alt="Family Name is Required" />
                            </asp:RequiredFieldValidator>
                            <asp:CustomValidator ID="cvLastName" runat="server" ErrorMessage="Last Name length cannot be exceeded 32 characters"
                                OnServerValidate="cvLastName_Validate" ControlToValidate="txtFamilyName" ValidateEmptyText="true">
                        <img src="Content/img/icon_warning.png"  title="Last Name length cannot be exceeded 32 characters" alt="Last Name length cannot be exceeded 32 characters" />
                            </asp:CustomValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Email</label>
                        <div class="controls">
                            <div class="input-prepend">
                                <span class="add-on"><i class="icon-envelope"></i></span>
                                <asp:TextBox ID="txtEmailAddress" runat="server"></asp:TextBox>
                            </div>
                            <asp:RequiredFieldValidator ID="rfvEmailAddress" runat="server" ErrorMessage="Email Address is Required"
                                ControlToValidate="txtEmailAddress" EnableClientScript="false">
                            <img src="Content/img/icon_warning.png"  title="Email Address is Required" alt="Email Address is Required" />
                            </asp:RequiredFieldValidator>
                            <asp:CustomValidator ID="cvEmailAddress" runat="server" ErrorMessage="This Email Address is already being used"
                                OnServerValidate="cfvEmailAddress_Validate" ControlToValidate="txtEmailAddress"
                                ValidateEmptyText="true">
                        <img src="Content/img/icon_warning.png"  title="This Email Address Is Already Being Used" alt="This Email Address Is Already Being Used" />
                            </asp:CustomValidator>
                            <asp:RegularExpressionValidator ID="revEmailAddress" runat="server" ErrorMessage="Invalid Email format"
                                ValidationExpression="\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ControlToValidate="txtEmailAddress"
                                EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Invalid Email format" alt="Invalid Email format" />
                            </asp:RegularExpressionValidator>
                        </div>
                    </div>                    
                </div>--%>
                <div class="form-actions">
                    <button id="btnSaveChanges" runat="server" class="btn btn-primary" type="submit"
                        data-loading-text="Saving..." onserverclick="btnSaveChanges_Click">
                        Save Changes</button>
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <script type="text/javascript">
        var ddlCountry = "<%=ddlCountry.ClientID %>"
        var ddlCoordinator = "<%=ddlCoordinator.ClientID %>"
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#' + ddlCountry).select2();
            $('#' + ddlCoordinator).select2();
        });
    </script>
</asp:Content>
