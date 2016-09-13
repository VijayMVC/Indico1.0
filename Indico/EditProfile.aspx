<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="EditProfile.aspx.cs" Inherits="Indico.EditProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h1>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h1>
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
                    <h3>
                        Personal
                    </h3>
                    <p class="required">
                        Indicates required fields
                    </p>
                    <ol>
                        <li>
                            <label class="required">
                                Name</label>
                            <asp:TextBox ID="txtName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvName" runat="server" ErrorMessage="Name Is Required"
                                ControlToValidate="txtName" EnableClientScript="false" Display="Dynamic">
                            <img src="Content/img/icon_warning.png"  title="Name Is Required" alt="Name Is Required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label class="required">
                                Nick Name</label>
                            <asp:TextBox ID="txtNickName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvNickName" runat="server" ErrorMessage="Nick Name Is Required"
                                ControlToValidate="txtNickName" EnableClientScript="false" Display="Dynamic">
                            <img src="Content/img/icon_warning.png"  title="Nick Name Is Required" alt="Nick Name Is Required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label class="required">
                                Coordinator</label>
                            <asp:DropDownList ID="ddlCoordinator" runat="server">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvCoordinator" runat="server" ErrorMessage="Coordinator Is Required"
                                ControlToValidate="ddlCoordinator" InitialValue="0" EnableClientScript="false"
                                Display="Dynamic">
                            <img src="Content/img/icon_warning.png"  title="Nick Name Is Required" alt="Nick Name Is Required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label class="required">
                                Title</label>
                            <asp:DropDownList ID="ddlGender" runat="server">
                                <asp:ListItem Text="Title" Value="0"></asp:ListItem>
                                <asp:ListItem Text="Mr." Value="1"></asp:ListItem>
                                <asp:ListItem Text="Ms." Value="2"></asp:ListItem>
                                <asp:ListItem Text="Mis." Value="3"></asp:ListItem>
                                <asp:ListItem Text="Other" Value="4"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvGender" runat="server" ErrorMessage="Gender Is Required"
                                ControlToValidate="ddlGender" InitialValue="0" EnableClientScript="false" Display="Dynamic">
                            <img src="Content/img/icon_warning.png"  title="Gender Is Required" alt="Gender Is Required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label class="required">
                                First Name</label>
                            <asp:TextBox ID="txtFirstName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" ErrorMessage="First Name Is Required"
                                ControlToValidate="txtFirstName" EnableClientScript="false" Display="Dynamic">
                            <img src="Content/img/icon_warning.png"  title="First Name Is Required" alt="First Name Is Required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label class="required">
                                Last Name</label>
                            <asp:TextBox ID="txtLastName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvLastName" runat="server" ErrorMessage="Last Name Is Required"
                                ControlToValidate="txtLastName" EnableClientScript="false" Display="Dynamic">
                            <img src="Content/img/icon_warning.png"  title="Last Name Is Required" alt="Last Name Is Required" />
                            </asp:RequiredFieldValidator>
                        </li>
                    </ol>
                </fieldset>
                <fieldset>
                    <h3>
                        Contact Information
                    </h3>
                    <ol>
                        <li>
                            <label class="required">
                                Address 1</label>
                            <asp:TextBox ID="txtAddress1" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvAddress1" runat="server" ErrorMessage="Address1 Is Required"
                                ControlToValidate="txtAddress1" EnableClientScript="false" Display="Dynamic">
                            <img src="Content/img/icon_warning.png"  title="Address1 Is Required" alt="Address1 Is Required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label>
                                Address 2</label>
                            <asp:TextBox ID="txtAddress2" runat="server"></asp:TextBox>
                        </li>
                        <li>
                            <label class="required">
                                City</label>
                            <asp:TextBox ID="txtCity" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvCity" runat="server" ErrorMessage="City Is Required"
                                ControlToValidate="txtCity" EnableClientScript="false" Display="Dynamic">
                            <img src="Content/img/icon_warning.png"  title="City Is Required" alt="City Is Required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label class="required">
                                State</label>
                            <asp:TextBox ID="txtState" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvState" runat="server" ErrorMessage="State Is Required"
                                ControlToValidate="txtState" EnableClientScript="false" Display="Dynamic">
                            <img src="Content/img/icon_warning.png"  title="State Is Required" alt="State Is Required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label class="required">
                                Postcode</label>
                            <asp:TextBox ID="txtPostcode" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvPostcode" runat="server" ErrorMessage="Postcode Is Required"
                                ControlToValidate="txtPostcode" EnableClientScript="false" Display="Dynamic">
                            <img src="Content/img/icon_warning.png"  title="Postcode Is Required" alt="Postcode Is Required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label class="required">
                                Country</label>
                            <asp:DropDownList ID="ddlCountry" runat="server">
                            </asp:DropDownList>
                        </li>
                        <li>
                            <label class="required">
                                Phone 1</label>
                            <asp:TextBox ID="txtPhone1" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvPhone1" runat="server" ErrorMessage="Phone 1 Is Required"
                                ControlToValidate="txtPhone1" EnableClientScript="false" Display="Dynamic">
                            <img src="Content/img/icon_warning.png"  title="Phone 1 Is Required" alt="Phone 1 Is Required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label>
                                Phone 2</label>
                            <asp:TextBox ID="txtPhone2" runat="server"></asp:TextBox>
                        </li>
                        <li>
                            <label>
                                Mobile</label>
                            <asp:TextBox ID="txtMobile" runat="server"></asp:TextBox>
                        </li>
                        <li>
                            <label>
                                Fax</label>
                            <asp:TextBox ID="txtFaxNo" runat="server"></asp:TextBox>
                        </li>
                        <li>
                            <label class="required">
                                Email</label>
                            <asp:TextBox ID="txtEmailAddress" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvEmailAddress" runat="server" ErrorMessage="Email Is Required"
                                ControlToValidate="txtEmailAddress" EnableClientScript="false" Display="Dynamic">
                            <img src="Content/img/icon_warning.png"  title="Email Is Required" alt="Email Is Required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label>
                                Web</label>
                            <asp:TextBox ID="txtWeb" runat="server"></asp:TextBox>
                        </li>
                    </ol>
                </fieldset>
                <div class="form-actions">
                    <asp:Button ID="btnSaveChanges" runat="server" CssClass="btn btn-primary" Text="Save Changes"
                        OnClick="btnSaveChanges_Click" />
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <!-- Save Profile -->
    <div id="requestConfirm" class="modal">
        <div class="modal-header">
            <h2>
                Save Profile</h2>
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        </div>
        <div class="modal-body">
            Are you sure you wish to save this changes?
        </div>
        <div class="modal-footer">
            <asp:Button ID="btnSave" runat="server" CssClass="btn" Text="Yes" Url="/EditProfile.aspx"
                OnClick="btnSave_Click" />
            <input id="btnCancel" class="btn firePopupCancel" type="button" value="No" />
        </div>
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var isValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
    </script>
    <script type="text/javascript">
        if (isValid) {
            window.setTimeout(function () {
                showPopupBox('requestConfirm', '405', '-205');
            }, 10);
        }
    </script>
    <!-- / -->
</asp:Content>
