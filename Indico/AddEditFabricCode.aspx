<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditFabricCode.aspx.cs" Inherits="Indico.AddEditFabricCode" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger" ValidationGroup="valCombined"
                    DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <legend>Code</legend>
                <div class="control-group">
                    <label class="control-label">
                        Code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtFabricCode" runat="server" Enabled="false" ValidationGroup="valCombined" CssClass="input-xxlarge"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvFabric" runat="server" ErrorMessage="Code is required."
                            ControlToValidate="txtFabricCode" EnableClientScript="false"
                            Display="Dynamic" ValidationGroup="valCombined">
                                            <img src="Content/img/icon_warning.png"  title="Code is required." alt="Code is required." />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <legend>Fabric Builder</legend>
                <div class="control-group">
                    <div class="controls">
                        <asp:DropDownList ID="ddlFabricCodeType" runat="server" CssClass="input-medium" AutoPostBack="true"
                            ValidationGroup="valCombined" OnSelectedIndexChanged="ddlFabricCodeType_SelectedIndexChanged">
                        </asp:DropDownList>
                        <asp:DropDownList ID="ddlAddFabrics" runat="server" CssClass="input-xxlarge" ValidationGroup="valCombined"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlAddFabrics_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <asp:DataGrid ID="dgvAddEditFabrics" runat="server" CssClass="table igridfabric" AllowCustomPaging="False"
                        AutoGenerateColumns="false" GridLines="None" PageSize="10" OnItemDataBound="dgvAddEditFabrics_ItemDataBound"
                        OnItemCommand="dgvAddEditFabrics_ItemCommand">
                        <HeaderStyle CssClass="header" />
                        <Columns>
                            <asp:TemplateColumn HeaderText="ID" Visible="false">
                                <ItemTemplate>
                                    <asp:Literal ID="litID" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn Visible="false">
                                <ItemTemplate>
                                    <asp:Literal ID="litFabricTypeID" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Fabric Code Type">
                                <ItemTemplate>
                                    <asp:Literal ID="litFabricType" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Fabric">
                                <ItemTemplate>
                                    <asp:Literal ID="litCode" runat="server"></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Nick Name">
                                <ItemTemplate>
                                    <asp:Literal ID="litFabricNickName" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Supplier">
                                <ItemTemplate>
                                    <asp:Literal ID="litFabricSupplier" runat="server" Text=""></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Where" Visible="false">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtWhere" runat="server" Text=""></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn>
                                <ItemTemplate>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <asp:LinkButton CommandName="Delete" ID="linkDelete" runat="server" CssClass="btn-link ifdelete" ValidationGroup="valCombined"
                                                    ToolTip="Delete "><i class="icon-trash"></i>Delete</asp:LinkButton>
                                            </li>
                                        </ul>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>
                    <div id="dvEmptyFabrics" runat="server" class="alert alert-info">
                        <h4>There are no Fabrics added.
                        </h4>
                        <p>
                            You can add many Fabrics.
                        </p>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Factory Description</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCombinedName" runat="server" MaxLength="255" CssClass="input-xxlarge"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvCombinedName" runat="server" CssClass="error" ControlToValidate="txtCombinedName" ValidationGroup="valCombined"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Factory Description is required">
                                <img src="Content/img/icon_warning.png" title="Factory Description is required" alt="Factory Description is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Sales Description</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCombinedNickName" runat="server" MaxLength="255" CssClass="input-xxlarge"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvCombinedNickName" runat="server" CssClass="error" ControlToValidate="txtCombinedNickName" ValidationGroup="valCombined"
                            Display="Dynamic" EnableClientScript="False" ErrorMessage="Sales Description is required">
                                <img src="Content/img/icon_warning.png" title="Sales Description is required" alt="Sales Description is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Is Active</label>
                    <div class="controls">
                        <asp:CheckBox ID="chkCombinedIsActive" runat="server" Checked="true" />
                    </div>
                </div>
                <div class="form-actions">
                    <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_ServerClick" validationgroup="valCombined"
                        data-loading-text="Saving..." type="submit">
                        Save Changes</button>
                    <a class="btn btn-default" href="ViewFabricCodes.aspx?type=0">Close</a>
                    <%--<button id="btnClose" runat="server" class="btn btn-default" type="submit" causesvalidation="false" onserverclick="btnClose_ServerClick">
                        Cancel                                       
                    </button>--%>
                </div>
                <!-- / -->
            </div>
        </div>
    </div>
    <!-- / -->
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var ddlAddFabrics = "<%=ddlAddFabrics.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {

            //Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);

            //function EndRequest(sender, args) {
            //    if (args.get_error() == undefined) {
            //        BindEvents();
            //    }
            //}

            BindEvents();

            function BindEvents() {
                $('#' + ddlAddFabrics).select2();
            }
        });
    </script>
</asp:Content>
