<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditClient.aspx.cs" Inherits="Indico.AddEditClient" %>

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
                <legend>Details </legend>
               <%-- <div class="control-group">
                    <label class="control-label required">
                        Distributor</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlCompany" runat="server" CssClass="input-xlarge">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvCompany" runat="server" ErrorMessage="Company  is required"
                            ControlToValidate="ddlCompany" InitialValue="0" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Company  is required" alt="Company  is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>--%>
                 <div class="control-group">
                    <label class="control-label required">
                        Client</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlClient" runat="server" CssClass="input-xlarge">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvClient" runat="server" ErrorMessage="Client is required"
                            ControlToValidate="ddlClient" InitialValue="0" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Client is required" alt="Client is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Job Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtName" runat="server" CssClass="input-xlarge"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvName" runat="server" ErrorMessage="Name  is required"
                            ControlToValidate="txtName" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Name is required" alt="Name  is required" />
                        </asp:RequiredFieldValidator>
                        <asp:CustomValidator ID="cvTxtName" runat="server" OnServerValidate="cvTxtName_ServerValidate" ErrorMessage="Name is already in use"
                            ControlToValidate="txtName" EnableClientScript="false">
                             <img src="Content/img/icon_warning.png"  title="Name is already in use" alt="Name is already in use" />
                        </asp:CustomValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Address
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtAddress1" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        City</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCity" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        State</label>
                    <div class="controls">
                        <asp:TextBox ID="txtState" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Postal Code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtPostalCode" runat="server" CssClass="iintiger"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Country</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlCountry" runat="server" OnSelectedIndexChanged="ddlCountry_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Phone</label>
                    <div class="controls">
                        <asp:TextBox ID="txtPhoneNo1" runat="server"></asp:TextBox>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Email</label>
                    <div class="controls">
                        <div class="input-prepend">
                            <span class="add-on"><i class="icon-envelope"></i></span>
                            <asp:TextBox ID="txtEmailAddress" runat="server"></asp:TextBox>
                        </div>
                        <asp:CustomValidator ID="cfvEmailAddress" runat="server" ErrorMessage="This Email Address is already being used"
                            OnServerValidate="cfvEmailAddress_Validate" ControlToValidate="txtEmailAddress"
                            ValidateEmptyText="true">
                        <img src="Content/img/icon_warning.png"  title="This Email Address Is already being used" alt="This Email Address is already being used" />
                        </asp:CustomValidator>
                        <asp:RegularExpressionValidator ID="revEmailAddress" runat="server" ErrorMessage="Invalid Email format"
                            ValidationExpression="\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ControlToValidate="txtEmailAddress"
                            EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Invalid Email format" alt="Invalid Email format" />
                        </asp:RegularExpressionValidator>
                    </div>
                </div>
            <div class="form-actions">
                <button id="btnSaveChanges" runat="server" class="btn btn-primary" type="submit"
                    data-loading-text="Saving..." onserverclick="btnSaveChanges_Click">
                    Save Changes</button>
                <button id="btnClose" runat="server" class="btn btn-default" type="submit" causesvalidation="false" onserverclick="btnClose_ServerClick">
                    Cancel                                       
                </button>
            </div>
            <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <!-- Add New Item -->
    <div id="requestAddEdit" class="modal">
        <!-- Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                &times;</button>
            <h2>
                <asp:Label ID="lblPopupHeaderText" runat="server"></asp:Label></h2>
        </div>
        <!-- / -->
        <!-- Content -->
        <div class="modal-body">
            <!-- Popup Validation -->
            <asp:ValidationSummary ID="validationSummaryAddEdit" runat="server" CssClass="alert alert-danger"
                ValidationGroup="vgNewItem" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <fieldset>
                <ol>
                    <li id="liName">
                        <label class="required">
                            Name</label>
                        <asp:TextBox ID="txtNewName" runat="server" MaxLength="128"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvItemName" runat="server" ControlToValidate="txtNewName"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Name is required"
                            ValidationGroup="vgNewItem">
                                <img src="Content/img/icon_warning.png" class="ierror" title="Name is required" alt="Name is required" />
                        </asp:RequiredFieldValidator>
                    </li>
                    <li id="liDescription">
                        <label>
                            Description</label>
                        <asp:TextBox ID="txtNewDescription" runat="server" CssClass="topic_d" MaxLength="255"
                            TextMode="MultiLine" Rows="2"></asp:TextBox>
                    </li>
                </ol>
            </fieldset>
        </div>
        <div class="modal-footer">
            <asp:Button ID="btnSaveNew" runat="server" CssClass="btn" OnClick="btnSaveNew_Click"
                Text="Save" Url="/AddEditClient.aspx" ValidationGroup="vgNewItem" />
        </div>
    </div>
    <!--/-->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var isPopulate = ('<%=ViewState["isPopulate"]%>' == 'True') ? true : false;
        //var ddlCompany = "< %=ddlCompany.ClientID %>"
        var ddlClient = "<%=ddlClient.ClientID %>"        
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            if (isPopulate) {
                window.setTimeout(function () {
                    showPopupBox('requestAddEdit', '600');
                }, 10);
            }

            //$('#' + ddlCompany).select2();
            $('#' + ddlClient).select2();            

            $('#ancAddNewItem').click(function () {
                $('div.ivalidator, img.ierror, span.ierror').hide();
                showPopupBox('requestAddEdit', '600');
            });
        });
    </script>
    <!--/-->
</asp:Content>
