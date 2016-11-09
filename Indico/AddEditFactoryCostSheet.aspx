<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditFactoryCostSheet.aspx.cs" Inherits="Indico.AddEditFactoryCostSheet" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="aPrintJKCostSheet" runat="server" class="btn btn-link pull-right" onserverclick="aPrintJKCostSheet_Click"
                    visible="false"><i class="icon-print"></i>Print Factory Cost Sheet</a>
                <a id="aPrintIndimanCostSheet" runat="server" class="btn btn-link pull-right" onserverclick="aPrintIndimanCostSheet_Click" visible="true">
                    <i class="icon-print"></i>Print Indiman Cost Sheet</a>
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
                    ValidationGroup="validateCostsheet" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <div class="span12">
                    <div class="span4">
                        <legend>Details </legend>
                        <div class="control-group">
                            <label class="control-label">
                                Pattern</label>
                            <div class="controls">
                                <asp:DropDownList ID="ddlPattern" runat="server" CssClass="input-xlarge" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlPattern_SelectedIndexChange">
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvPattern" runat="server" ErrorMessage="Pattern is required"
                                    ValidationGroup="validateCostsheet" ControlToValidate="ddlPattern" InitialValue="0"
                                    EnableClientScript="false">
                                    <img src="Content/img/icon_warning.png"  title="Pattern  is required" alt="Pattern is required" />
                                </asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Fabric</label>
                            <div class="controls">
                                <asp:DropDownList ID="ddlFabric" runat="server" CssClass="input-xlarge" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlFabric_SelectedIndexChanged">
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvFabric" runat="server" ErrorMessage="Fabric is required"
                                    ValidationGroup="validateCostsheet" ControlToValidate="ddlFabric" InitialValue="0"
                                    EnableClientScript="false">
                                    <img src="Content/img/icon_warning.png"  title="Fabric  is required" alt="Fabric is required" />
                                </asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                            </label>
                            <div class="controls">
                                <asp:Label ID="lblVLCount" runat="server" ForeColor="Red"></asp:Label>
                            </div>
                        </div>
                    </div>
                    <div class="span4">
                        <legend>Pattern Details </legend>
                        <div class="control-group">
                            <label class="control-label">
                                Pattern Number</label>
                            <div class="controls">
                                <asp:TextBox ID="txtPatternNo" runat="server" Enabled="false"></asp:TextBox>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Item Name</label>
                            <div class="controls">
                                <asp:TextBox ID="txtItemName" runat="server" Enabled="false"></asp:TextBox>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Size Set</label>
                            <div class="controls">
                                <asp:TextBox ID="txtSizeSet" runat="server" Enabled="false"></asp:TextBox>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Age Group</label>
                            <div class="controls">
                                <asp:TextBox ID="txtAgeGroup" runat="server" Enabled="false"></asp:TextBox>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Printer Type</label>
                            <div class="controls">
                                <asp:TextBox ID="txtPrinterType" runat="server" Enabled="false"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="span4">
                        <legend>&nbsp;</legend>
                        <div class="control-group">
                            <label class="control-label">
                                Sub Item Name</label>
                            <div class="controls">
                                <asp:TextBox ID="txtSubItem" runat="server" Enabled="false"></asp:TextBox>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Gender</label>
                            <div class="controls">
                                <asp:TextBox ID="txtGender" runat="server" Enabled="false"></asp:TextBox>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Nick Name</label>
                            <div class="controls">
                                <asp:TextBox ID="txtNickName" runat="server" TextMode="MultiLine" Enabled="false"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="span12">
                    <div class="span6">
                        <legend>Fabric Details</legend>
                        <div class="control-group">
                            <div class="controls">
                                <asp:DropDownList ID="ddlFabrics" runat="server" CssClass="input-xxlarge pull-right"
                                    AutoPostBack="true" OnSelectedIndexChanged="ddlFabrics_SelectedIndexChange">
                                </asp:DropDownList>
                            </div>
                        </div>
                        <asp:DataGrid ID="dgAddEditFabrics" runat="server" CssClass="table igridfabric" AllowCustomPaging="False"
                            AutoGenerateColumns="false" GridLines="None" PageSize="10" OnItemDataBound="dgAddEditFabrics_ItemDataBound"
                            OnItemCommand="dgAddEditFabrics_onItemCommand" ShowFooter="true">
                            <HeaderStyle CssClass="header" />
                            <Columns>
                                <asp:TemplateColumn HeaderText="Fabric">
                                    <ItemTemplate>
                                        <asp:Literal ID="litCode" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="NickName">
                                    <ItemTemplate>
                                        <asp:Literal ID="litFabricNickName" runat="server" Text=""></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Supplier">
                                    <ItemTemplate>
                                        <asp:Literal ID="litFabricSupplier" runat="server" Text=""></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Consumption">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtCons" runat="server" CssClass="input-mini ifcons" EnableViewState="true"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Unit">
                                    <ItemTemplate>
                                        <asp:Literal ID="litUnit" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Fabric Price">
                                    <ItemTemplate>
                                        <asp:Label ID="litFabricPrice" runat="server" CssClass="ifprice"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Fabric Cost">
                                    <ItemTemplate>
                                        <asp:Label ID="lblfabricCost" runat="server" EnableViewState="true" CssClass="ifcost"></asp:Label>
                                        <asp:TextBox ID="txtFabricCost" CssClass="txifcost" runat="server" Style="display: none;"></asp:TextBox>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTotalFabricCost" runat="server" EnableViewState="true" CssClass="ifabtotal"></asp:Label>
                                    </FooterTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn>
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:LinkButton CommandName="Delete" ID="linkDelete" runat="server" CssClass="btn-link ifdelete"
                                                        ToolTip="Delete "><i class="icon-trash"></i>Delete</asp:LinkButton>
                                                </li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                            </Columns>
                        </asp:DataGrid>
                        <div id="dvEmptyFabrics" runat="server" class="alert alert-info">
                            <h4>There are no Fabrics added to this Cost Sheet.
                            </h4>
                            <p>
                                You can add many Fabrics to this Cost Sheet.
                            </p>
                        </div>
                    </div>
                    <div class="span6">
                        <legend>Accessory Details</legend>
                        <div class="control-group">
                            <div class="controls">
                                <asp:DropDownList ID="ddlAccessory" runat="server" CssClass="input-xxlarge pull-right"
                                    AutoPostBack="true" OnSelectedIndexChanged="ddlAccessory_SelectedIndexChange">
                                </asp:DropDownList>
                            </div>
                        </div>
                        <asp:DataGrid ID="dgAccessories" runat="server" CssClass="table igridaccessory" AllowCustomPaging="False"
                            AutoGenerateColumns="false" GridLines="None" PageSize="10" OnItemDataBound="dgAccessories_ItemDataBound"
                            OnItemCommand="dgAccessories_onItemCommand" ShowFooter="true">
                            <HeaderStyle CssClass="header" />
                            <Columns>
                                <asp:TemplateColumn HeaderText="Accessory">
                                    <ItemTemplate>
                                        <asp:Literal ID="litName" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Description">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblAccessoryDescription" runat="server" Text=""></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Supplier">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSupplier" runat="server" Text=""></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Accessory Price">
                                    <ItemTemplate>
                                        <asp:Label ID="litAccessoryPrice" runat="server" CssClass="iaprice"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Consumption">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtcons" runat="server" CssClass="input-mini iacons" EnableViewState="true"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Unit">
                                    <ItemTemplate>
                                        <asp:Literal ID="litaccessoryUnit" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Accessory Cost">
                                    <ItemTemplate>
                                        <asp:Label ID="lblaccessoryCost" EnableViewState="true" runat="server" CssClass="iacost"></asp:Label>
                                        <asp:TextBox ID="txtAccessoryCost" CssClass="txtiacost" runat="server" Style="display: none;"></asp:TextBox>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTotalAccessoryCost" runat="server" EnableViewState="true" CssClass="iacctotal"></asp:Label>
                                    </FooterTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn>
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:LinkButton CommandName="Delete" ID="linkDelete" runat="server" CssClass="btn-link iadelete"
                                                        EnableViewState="true" ToolTip="Delete "><i class="icon-trash"></i>Delete</asp:LinkButton>
                                                </li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                            </Columns>
                        </asp:DataGrid>
                        <div id="dvEmptyAccessories" runat="server" class="alert alert-info">
                            <h4>There are no Accessories added to this Cost Sheet.
                            </h4>
                            <p>
                                You can add many Accessories to this Cost Sheet.
                            </p>
                        </div>
                    </div>
                </div>
                <div class="span12">
                    <legend>Price Details </legend>
                    <div class="control-group">
                        <label class="control-label">
                            SMV
                        </label>
                        <div class="controls">
                            <asp:TextBox ID="txtsmv" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                            <asp:RegularExpressionValidator ID="revsmv" runat="server" ErrorMessage="SMV should be Numeric value."
                                ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                ControlToValidate="txtsmv" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="SMV should be Numeric value." alt="SMV should be Numeric value." />
                            </asp:RegularExpressionValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            SMV Rate
                        </label>
                        <div class="controls">
                            <asp:TextBox ID="txtsmvrate" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                            <asp:RegularExpressionValidator ID="revSMVRate" runat="server" ErrorMessage="SMV Rate should be Numeric value."
                                ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                ControlToValidate="txtsmvrate" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="SMV Rate should be Numeric value." alt="SMV Rate should be Numeric value." />
                            </asp:RegularExpressionValidator>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Calculated CM
                        </label>
                        <div class="controls">
                            <asp:TextBox ID="txtcalccm" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                            <asp:RegularExpressionValidator ID="revCalculatedCM" runat="server" ErrorMessage="Calulated CM should be Numeric value."
                                ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                ControlToValidate="txtcalccm" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Calulated CM should be Numeric value." alt="Calulated CM should be Numeric value." />
                            </asp:RegularExpressionValidator>
                        </div>
                    </div>
                </div>
                <div class="span12">
                    <div class="span4">
                        <div class="control-group">
                            <label class="control-label">
                                &nbsp;</label>
                            <div class="controls">
                                &nbsp;
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Total Fabric Cost
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txttotalFabricCost" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="revTotalFabricCost" runat="server" ErrorMessage="Total Fabric Cost should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txttotalFabricCost" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Total Fabric Cost should be Numeric value." alt="Total Fabric Cost should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Total Accessories Cost
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtAccessoriesCost" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="revAccessoryCost" runat="server" ErrorMessage="Total Accessory Cost should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtAccessoriesCost" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Total Accessory Cost should be Numeric value." alt="Total Accessory Cost should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Heat Press Overhead
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtHeatPressOverhead" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="revHeadPressed" runat="server" ErrorMessage="Heat Press Overhead should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtHeatPressOverhead" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Heat Press Overhead should be Numeric value." alt="Heat Press Overhead should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Label Cost
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtLabelCost" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="revLabelCost" runat="server" ErrorMessage="Label Cost should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtLabelCost" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Label Cost should be Numeric value." alt="Label Cost should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Packing(Sewing threads, cartons, import/export, etc.)
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtPacking" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="revOther" runat="server" ErrorMessage="Other Cost should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtPacking" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Other Cost should be Numeric value." alt="Other Cost should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                    </div>
                    <div id="dvIndiman1" runat="server" class="span4">
                        <div class="control-group">
                            <label class="control-label">
                                &nbsp;</label>
                            <div class="controls">
                                &nbsp;
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Sublimation Consumption
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtSublimationConsumption" runat="server" CssClass="input-mini"
                                    EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvSublimationConsumption" runat="server" ErrorMessage="Sublimation Consumption should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtSublimationConsumption" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Sublimation Consumption should be Numeric value." alt="Sublimation Consumption should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Duty Rate %
                            </label>
                            <div class="controls">
                                <div class="input-append">
                                    <asp:TextBox ID="txtDutyRate" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                    <span class="add-on">%</span>
                                </div>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                            </label>
                            <div class="controls">
                                <asp:Literal runat="server">Consumption</asp:Literal>
                                <asp:Literal runat="server">&nbsp;&nbsp;Rate</asp:Literal>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label input">
                                <asp:TextBox ID="txtCF1" runat="server" CssClass="input-medium" EnableViewState="true"></asp:TextBox>
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtCONS1" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:TextBox ID="txtRate1" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvCONS1" runat="server" ErrorMessage="Consumption should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtCONS1" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Consumption should be Numeric value." alt="Consumption should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label input">
                                <asp:TextBox ID="txtCF2" runat="server" CssClass="input-medium" EnableViewState="true"></asp:TextBox>
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtCONS2" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:TextBox ID="txtRate2" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvCONS2" runat="server" ErrorMessage="Consumption should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtCONS2" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Consumption should be Numeric value." alt="Consumption should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label input">
                                <asp:TextBox ID="txtCF3" runat="server" CssClass="input-medium" EnableViewState="true"></asp:TextBox>
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtCONS3" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:TextBox ID="txtRate3" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvCONS3" runat="server" ErrorMessage="Consumption should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtCONS3" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Consumption should be Numeric value." alt="Consumption should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                    </div>
                    <div id="dvIndiman2" runat="server" class="span4">
                        <div class="control-group">
                            <label class="control-label">
                                Exchange Rate
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtExchangeRate" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                FOB (AUD)
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtFOB" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvFOB" runat="server" ErrorMessage="FOB should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtFOB" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="FOB should be Numeric value." alt="FOB should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Duty
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtDuty" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false">></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvDuty" runat="server" ErrorMessage="Duty should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtDuty" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Duty should be Numeric value." alt="Duty should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Cost 1
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtCost1" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false">></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvCost" runat="server" ErrorMessage="Cost should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtCost1" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Cost should be Numeric value." alt="Cost should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Cost 2
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtCost2" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false">></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvCost2" runat="server" ErrorMessage="Cost should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtCost2" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Cost should be Numeric value." alt="Cost should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Cost 3
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtCost3" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false">></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvCost3" runat="server" ErrorMessage="Cost should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtCost2" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Cost should be Numeric value." alt="Cost should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="span12">
                    <div class="span4">
                        <div class="control-group">
                            <label class="control-label">
                                Wastage %
                            </label>
                            <div class="controls">
                                <div class="input-append">
                                    <asp:TextBox ID="txtWastage" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                    <span class="add-on">%</span>
                                </div>
                                <asp:TextBox ID="txtSubWastage" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="revWastage" runat="server" ErrorMessage="Wastage should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtSubWastage" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Wastage should be Numeric value." alt="Wastage should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Finance %
                            </label>
                            <div class="controls">
                                <div class="input-append">
                                    <asp:TextBox ID="txtFinance" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                    <span class="add-on">%</span>
                                </div>
                                <asp:TextBox ID="txtSubFinance" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="revFinance" runat="server" ErrorMessage="Finance should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtSubFinance" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Finance should be Numeric value." alt="Finance should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                CM
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtCM" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="revCm" runat="server" ErrorMessage="CM should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtCM" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="CM should be Numeric value." alt="CM should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                FOB Cost
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtFobCost" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="revFobCost" runat="server" ErrorMessage="Fob Cost should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtFobCost" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Fob Cost should be Numeric value." alt="Fob Cost should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Quoted FOB
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtJKFobQuoted" runat="server" CssClass="input-mini" Style="background-color: #FBDB0C;"
                                    EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="revJkQuotedFOB" runat="server" ErrorMessage="JK Quoted FOB Cost should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtJKFobQuoted" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="JK Quoted FOB Cost should be Numeric value." alt="JK Quoted FOB Cost should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Round Up
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtRoundUp" runat="server" CssClass="input-mini" Enabled="false" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="revRoundUp" runat="server" ErrorMessage="Round Up should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtRoundUp" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Round Up should be Numeric value." alt="Round Up should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                    </div>
                    <div id="dvIndiman3" runat="server" class="span4">
                        <div class="control-group">
                            <label class="control-label">
                                Ink
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtInk" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:TextBox ID="txtInkRate" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvInk" runat="server" ErrorMessage="Ink should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtInk" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Ink should be Numeric value." alt="Ink should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Paper
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtPaper" runat="server" CssClass="input-mini" Enabled="false" EnableViewState="true"></asp:TextBox>
                                <asp:TextBox ID="txtPaperRate" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvPaper" runat="server" ErrorMessage="Paper should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtPaper" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Paper should be Numeric value." alt="Paper should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                    </div>
                    <div id="dvIndiman4" runat="server" class="span4">
                        <div class="control-group">
                            <label class="control-label">
                                Ink + 2%
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtInkCost" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvInkCost" runat="server" ErrorMessage="Ink Cost should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtInkCost" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Ink Cost should be Numeric value." alt="Ink Cost should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Paper + 2%
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtPaperCost" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvPaperCost" runat="server" ErrorMessage="Paper Cost should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtPaperCost" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Paper Cost should be Numeric value." alt="Paper Cost should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Air Freight
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtAirFreight" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvAirFreight" runat="server" ErrorMessage="Air Freight should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtAirFreight" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Air Freight should be Numeric value." alt="Air Freight should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Imp Charges
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtImpCharges" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvImpCharges" runat="server" ErrorMessage="Imp Cahrges should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtImpCharges" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Imp Cahrges should be Numeric value." alt="Imp Cahrges should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Mgt OH
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtMgtOH" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvMgtOH" runat="server" ErrorMessage="Mgt OH should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtMgtOH" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Mgt OH should be Numeric value." alt="Mgt OH should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Indico OH
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtIndicoOH" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvIndicoOH" runat="server" ErrorMessage="Indico OH should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtIndicoOH" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Indico OH should be Numeric value." alt="Indico OH should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Depr
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtDepar" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvDepr" runat="server" ErrorMessage="Depr. should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtDepar" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Depr. should be Numeric value." alt="Depr. should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Landed
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtLanded" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvLanded" runat="server" ErrorMessage="Landed should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtLanded" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Landed should be Numeric value." alt="Landed should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="span12">
                    <div class="span4">
                        <div class="control-group">
                            <label class="control-label">
                                Last Modifier (Factory)
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtModifer" runat="server" Enabled="false"></asp:TextBox>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Last Modified Date (Factory)
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtModifiedDate" runat="server" Enabled="false"></asp:TextBox>
                            </div>
                        </div>
                        <div id="dvIndimanModifier" runat="server">
                            <div class="control-group">
                                <label class="control-label">
                                    Last Modifier (Indiman)
                                </label>
                                <div class="controls">
                                    <asp:TextBox ID="txtIndimanModifier" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Last Modified Date (Indiman)
                                </label>
                                <div class="controls">
                                    <asp:TextBox ID="txtIndimanModifiedDate" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Remarks
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine"></asp:TextBox>
                            </div>
                        </div>
                        <div class="control-group" id="dvShowToIndico" runat="server">
                            <label class="control-label">
                                Show to Indico
                            </label>
                            <div class="controls">
                                <asp:DropDownList ID="ddlShowToIndico" runat="server" Width="70px"></asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <div id="dvIndiman5" runat="server" class="span4">
                        <div class="control-group">
                            <label class="control-label">
                                Margin Rate %
                            </label>
                            <div class="controls">
                                <div class="input-append">
                                    <asp:TextBox ID="txtMarginRate" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                    <span class="add-on">%</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="dvIndiman6" runat="server" class="span4">
                        <div class="control-group">
                            <label class="control-label">
                                CIF
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtCIF" runat="server" CssClass="input-mini" Enabled="false" EnableViewState="true"></asp:TextBox>
                                <asp:TextBox ID="txtCalMgn" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                <div class="input-append">
                                    <asp:TextBox ID="txtMp" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                    <span class="add-on">%</span>
                                </div>
                                <asp:RegularExpressionValidator ID="rfvCIF" runat="server" ErrorMessage="CIF should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtCIF" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="CIF should be Numeric value." alt="CIF should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Quoted CIF
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtQuotedCif" runat="server" CssClass="input-mini" EnableViewState="true"
                                    Style="background-color: #FBDB0C;"></asp:TextBox>
                                <asp:TextBox ID="txtActMgn" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                <div class="input-append">
                                    <asp:TextBox ID="txtQuotedMp" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                    <span class="add-on">%</span>
                                </div>
                                <asp:RegularExpressionValidator ID="rfvQuotedCif" runat="server" ErrorMessage="Quoted CIF should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtQuotedCif" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Quoted CIF should be Numeric value." alt="Quoted CIF should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                FOB Factor
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtFobFactor" runat="server" CssClass="input-mini" EnableViewState="true"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvFobFactor" runat="server" ErrorMessage="FOB Factor should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtFobFactor" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="FOB Factor should be Numeric value." alt="FOB Factor should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                Quoted FOB
                            </label>
                            <div class="controls">
                                <asp:TextBox ID="txtQuotedFOB" runat="server" CssClass="input-mini" EnableViewState="true" Enabled="false"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="rfvQuotedFOB" runat="server" ErrorMessage="Quoted FOB should be Numeric value."
                                    ValidationGroup="validateCostsheet" ValidationExpression="^[-+]?[0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?$"
                                    ControlToValidate="txtQuotedFOB" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Quoted FOB should be Numeric value." alt="Quoted FOB should be Numeric value." />
                                </asp:RegularExpressionValidator>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="span12">
                    <div class="span6">
                        <legend>Factory Remarks History</legend>
                        <asp:DataGrid ID="dgViewNote" runat="server" CssClass="table" AllowCustomPaging="False"
                            AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                            PageSize="10" OnItemDataBound="dgViewNote_ItemDataBound">
                            <HeaderStyle CssClass="header" />
                            <Columns>
                                <asp:TemplateColumn HeaderText="Modifier">
                                    <ItemTemplate>
                                        <asp:Literal ID="litModifier" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Modified Date">
                                    <ItemTemplate>
                                        <asp:Literal ID="litModifiedDate" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Remarks">
                                    <ItemTemplate>
                                        <asp:Literal ID="litRemarks" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn>
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link iremarksdelete"
                                                        ToolTip="Delete Cost Sheet"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                            </Columns>
                        </asp:DataGrid>
                        <!-- No Factory Remarks -->
                        <div id="dvNoFactoryRemarks" runat="server" class="alert alert-info">
                            <h4>No Factory Remarks have been added.</h4>
                            <p>
                                Once you add an remarks, you'll see the details below.
                            </p>
                        </div>
                        <!-- / -->
                    </div>
                    <div class="span6" id="dvIndimanRemarks" runat="server">
                        <legend>Indiman Remarks History</legend>
                        <asp:DataGrid ID="dgIndimanViewNote" runat="server" CssClass="table" AllowCustomPaging="False"
                            AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                            PageSize="10" OnItemDataBound="dgIndimanViewNote_ItemDataBound">
                            <HeaderStyle CssClass="header" />
                            <Columns>
                                <asp:TemplateColumn HeaderText="Modifier">
                                    <ItemTemplate>
                                        <asp:Literal ID="litModifier" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Modified Date">
                                    <ItemTemplate>
                                        <asp:Literal ID="litModifiedDate" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Remarks">
                                    <ItemTemplate>
                                        <asp:Literal ID="litRemarks" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn>
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link iIndimanremarksdelete"
                                                        ToolTip="Delete Cost Sheet"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                            </Columns>
                        </asp:DataGrid>
                        <!-- No Factory Remarks -->
                        <div id="dvNoIndimanRemarks" runat="server" class="alert alert-info">
                            <h4>No Indiman Remarks have been added.</h4>
                            <p>
                                Once you add an remarks, you'll see the details below.
                            </p>
                        </div>
                        <!-- / -->
                    </div>
                </div>
                <div class="span12">
                    <legend>Garment Measurement Image</legend>
                    <div style="display: none">
                        <div class="control-group text-center">
                            <label class="control-label">
                            </label>
                            <div class="controls">
                                <table id="uploadtable_1" class="file_upload_files" multirow="true" setdefault="false">
                                    <asp:Repeater ID="rptUploadFile" runat="server">
                                        <ItemTemplate>
                                            <tr id="tableRowfileUpload">
                                                <td class="file_preview">
                                                    <asp:Image ID="uploadImage" Height="" Width="" runat="server" ImageUrl="" />
                                                </td>
                                                <td class="file_name">
                                                    <asp:Literal ID="litfileName" runat="server"></asp:Literal>
                                                </td>
                                                <td id="filesize" class="file_size" runat="server">
                                                    <asp:Literal ID="litfileSize" runat="server"></asp:Literal>
                                                </td>
                                                <td class="file_delete">
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Image"><i class="icon-trash"></i></asp:HyperLink>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </table>
                                <input id="hdnUploadFiles" runat="server" name="hdnUploadFiles" type="hidden" value="" />
                            </div>
                        </div>
                        <div class="control-group text-center">
                            <label class="control-label required">
                            </label>
                            <div class="controls">
                                <div id="dropzone_1" multirow="true" class="fileupload preview">
                                    <input id="file_1" name="file_1" type="file" />
                                    <button id="btnup_1" type="submit">
                                        Upload</button>
                                    <div id="divup_1">
                                        Drag file here or click to upload
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div>
                            <label class="control-label">
                            </label>
                            <p class="extra-helper">
                                <span class="label label-info">Hint:</span> You can drag & drop files from your
                                desktop on this webpage with Google Chrome, Mozilla Firefox and Apple Safari.
                                <!--[if IE]>
                            <strong>Microsoft Explorer has currently no support for Drag & Drop or multiple file selection.</strong>
                            <![endif]-->
                            </p>
                        </div>
                    </div>
                </div>
                <div id="dvCostSheetImages" runat="server" visible="false" class="text-center">
                    <ul class="thumbnails">
                        <li class="span4">
                            <div class="thumbnail">
                                <asp:Image ID="imgCostSheet" runat="server" />
                                <div class="caption">
                                    <h4>
                                        <asp:Label ID="lblItemName" runat="server" />
                                    </h4>
                                    <p>
                                        <div class="btn-group" style="display: none;">
                                            <a class="btn" href="#"><i class="icon-picture"></i>Image</a> <a class="btn dropdown-toggle"
                                                data-toggle="dropdown" href="#"><span class="caret"></span></a>
                                            <ul class="dropdown-menu">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Cost Sheet Image"
                                                        Visible="false">Edit</asp:HyperLink></li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass=" btn-link ideleteimage" ToolTip="Delete Cost Sheet Image"><i class="icon-trash"></i> Delete</asp:HyperLink>
                                                </li>
                                            </ul>
                                        </div>
                                    </p>
                                </div>
                            </div>
                        </li>
                    </ul>
                </div>
                <div class="span12">
                    <div class="form-actions">
                        <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_Click"
                            validationgroup="validateCostsheet" type="submit" data-loading-text="Saving...">
                            Save Changes</button>
                        <a id="btnAddUser" runat="server" class="btn" href="~/ViewCostSheets.aspx">Cancel</a>
                        <button id="btnClone" runat="server" class="btn btn-default" onserverclick="btnClone_ServerClick"
                            validationgroup="validateCostsheet" type="submit" data-loading-text="Cloning...">
                            Clone Cost Sheet</button>
                        <asp:Button ID="btnShowHide" runat="server" Text="Show to Indico" Width="172px" CssClass="btn btn-default" OnClick="btnShowHide_Click" />
                    </div>
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnDeleteImage" runat="server" Value="0" />
    <asp:HiddenField ID="hdnisAccess" runat="server" Value="0" />
    <!-- <div id="dvViewNote" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblViewNoteTitle" runat="server" Text="View Notes"></asp:Label>
            </h3>
        </div>
        <div class="modal-body">
            <fieldset>
            </fieldset>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
        </div>
    </div>-->
    <div id="dvDeleteCostSheetImage" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Cost Sheet Image</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Cost Sheet Image?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDeleteCostSheetImage" runat="server" class="btn btn-primary" onserverclick="btnDeleteCostSheetImage_OnClick"
                data-loading-text="Deleting..." type="submit">
                Yes</button>
        </div>
    </div>
    <div id="dvDeleteRemarks" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Cost Sheet Remarks</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Cost Sheet Remark?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDeleteCostSheet" runat="server" class="btn btn-primary" onserverclick="btnDeleteCostSheet_OnClick"
                data-loading-text="Deleting..." type="submit">
                Yes</button>
        </div>
    </div>
    <asp:HiddenField ID="hdnRemarks" runat="server" />
    <asp:HiddenField ID="hdnRemarksType" runat="server" />
    <script type="text/javascript">
        var ddlPattern = "<%=ddlPattern.ClientID %>";
        var ddlFabric = "<%=ddlFabric.ClientID %>";
        var ddlFabrics = "<%=ddlFabrics.ClientID %>";
        var ddlAccessory = "<%=ddlAccessory.ClientID %>";
        var txtJKFobQuoted = "<%=txtJKFobQuoted.ClientID %>";
        var txtFobCost = "<%=txtFobCost.ClientID %>";
        var txtRoundUp = "<%=txtRoundUp.ClientID %>";
        var txtsmv = "<%=txtsmv.ClientID %>";
        var txtsmvrate = "<%=txtsmvrate.ClientID %>";
        var txtcalccm = "<%=txtcalccm.ClientID %>";
        var txtCM = "<%=txtCM.ClientID %>";
        var txttotalFabricCost = "<%=txttotalFabricCost.ClientID %>";
        var txtSubWastage = "<%=txtSubWastage.ClientID %>";
        var txtHeatPressOverhead = "<%=txtHeatPressOverhead.ClientID %>";
        var txtLabelCost = "<%=txtLabelCost.ClientID %>";
        var txtPacking = "<%=txtPacking.ClientID %>";
        var txtWastage = "<%=txtWastage.ClientID %>";
        var txtFinance = "<%=txtFinance.ClientID %>";
        var txtSubFinance = "<%=txtSubFinance.ClientID %>";
        var dgAddEditFabrics = "<%=dgAddEditFabrics.ClientID %>";
        var dgAccessories = "<%=dgAccessories.ClientID %>";
        var txtAccessoriesCost = "<%=txtAccessoriesCost.ClientID %>";
        var deleteFabric = ('<%=ViewState["deleteFabric"]%>' == 'True') ? true : false;
        var hdnDeleteImage = "<%=hdnDeleteImage.ClientID %>";
        var hdnisAccess = "<%=hdnisAccess.ClientID %>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID %>";
        var txtExchangeRate = "<%=txtExchangeRate.ClientID %>";
        var txtFOB = "<%=txtFOB.ClientID %>";
        var txtDutyRate = "<%=txtDutyRate.ClientID %>";
        var txtDuty = "<%=txtDuty.ClientID %>";
        var txtCost1 = "<%=txtCost1.ClientID %>";
        var txtCost2 = "<%=txtCost2.ClientID %>";
        var txtCost3 = "<%=txtCost3.ClientID %>";
        var txtCONS1 = "<%=txtCONS1.ClientID %>";
        var txtCONS2 = "<%=txtCONS2.ClientID %>";
        var txtCONS3 = "<%=txtCONS3.ClientID %>";
        var txtRate1 = "<%=txtRate1.ClientID %>";
        var txtRate2 = "<%=txtRate2.ClientID %>";
        var txtRate3 = "<%=txtRate3.ClientID %>";
        var txtInk = "<%=txtInk.ClientID %>";
        var txtInkRate = "<%=txtInkRate.ClientID %>";
        var txtInkCost = "<%=txtInkCost.ClientID %>";
        var txtSublimationConsumption = "<%=txtSublimationConsumption.ClientID %>";
        var txtPaper = "<%=txtPaper.ClientID %>";
        var txtPaperRate = "<%=txtPaperRate.ClientID %>";
        var txtPaperCost = "<%=txtPaperCost.ClientID %>";
        var txtAirFreight = "<%=txtAirFreight.ClientID %>";
        var txtImpCharges = "<%=txtImpCharges.ClientID %>";
        var txtMgtOH = "<%=txtMgtOH.ClientID %>";
        var txtIndicoOH = "<%=txtIndicoOH.ClientID %>";
        var txtDepar = "<%=txtDepar.ClientID %>";
        var txtLanded = "<%=txtLanded.ClientID %>";
        var txtCIF = "<%=txtCIF.ClientID %>";
        var txtCalMgn = "<%=txtCalMgn.ClientID %>";
        var txtMp = "<%=txtMp.ClientID %>";
        var txtMarginRate = "<%=txtMarginRate.ClientID %>";
        var txtQuotedCif = "<%=txtQuotedCif.ClientID %>";
        var txtActMgn = "<%=txtActMgn.ClientID %>";
        var txtQuotedMp = "<%=txtQuotedMp.ClientID %>";
        var txtQuotedFOB = "<%=txtQuotedFOB.ClientID %>";
        var txtFobFactor = "<%=txtFobFactor.ClientID %>";
        var deleteAccessory = ('<%=ViewState["deleteAccessory"]%>' == 'True') ? true : false;
        var deleteFabric = ('<%=ViewState["deleteFabric"]%>' == 'True') ? true : false;
        var ViewNote = ('<%=ViewState["ViewNote"]%>' == 'True') ? true : false;
        var CalculateIndiman = ('<%=ViewState["CalculateIndiman"]%>' == 'True') ? true : false;
        var hdnRemarks = "<%=hdnRemarks.ClientID %>";
        var hdnRemarksType = "<%=hdnRemarksType.ClientID %>";
        var accTotalID = "<%=this.accTotalID %>";
        var fabTotalID = "<%=this.fabTotalID %>";
    </script>
    <script type="text/javascript">
        /* function validate_grid() {
        $('.igridaccessory').find('.iacons').each(function () {
        if ($(this).val() == '') {
        $(this).css('border-color', '#FF0000');
        return false;
        }
        });
        $('.igridfabric').find('.ifcons').each(function () {
        if ($(this).val() == '') {
        $(this).css('border-color', '#FF0000');
        return false;
        }
        });
        return true;
        }*/

        $(document).ready(function () {

            $('#' + ddlPattern).select2();
            $('#' + ddlFabric).select2();
            $('#' + ddlFabrics).select2();
            $('#' + ddlAccessory).select2();

            $('.ideleteimage').click(function () {
                $('#' + hdnDeleteImage).val($(this).attr('qid'));
                $('#dvDeleteCostSheetImage').modal('show');
            });

            $('.iremarksdelete').click(function () {
                $('#' + hdnRemarks).val($(this).attr('qid'));
                $('#' + hdnRemarksType).val($(this).attr('type'));
                $('#dvDeleteRemarks').modal('show');
            });

            $('.iIndimanremarksdelete').click(function () {
                $('#' + hdnRemarks).val($(this).attr('qid'));
                $('#' + hdnRemarksType).val($(this).attr('type'));
                $('#dvDeleteRemarks').modal('show');
            });

            if (CalculateIndiman) {
                calculateFactoryCost();
            }

            /*if (ViewNote) {
            window.setTimeout(function () {
            $('#dvDeleteRemarks').modal('hide');
            $('#dvViewNote').modal('show');
            }, 10);
            }*/

            $('.ifcons').keyup(function () {
                if ($(this).val() != '' && $.isNumeric($(this).val())) {
                    var price = parseFloat($(this).closest('tr').find('.ifprice')[0].innerHTML).toFixed(2);
                    var cons = parseFloat($(this).val());
                    var fabCost = (Math.round(price * cons * 100) / 100);
                    $(this).closest('tr').find('.ifcost')[0].innerHTML = fabCost;
                    $(this).closest('tr').find('.txifcost').val(fabCost);
                    $(this).removeAttr('style');
                }
                else {
                    $(this).attr('style', 'border-color:#FF0000');
                    $(this).closest('tr').find('.ifcost')[0].innerHTML = '0.00';
                }

                calculateFabricDataGrid();
            });


            if (deleteFabric) {
                calculateFabricDataGrid();

                if ($('#' + txtSubWastage).val() != '') {
                    calculateWastage();
                    calculateFinance();
                    if ($('#' + txtSubFinance).val() != '' && $('#' + txtSubWastage).val() != '') {
                        calculateFactoryCost();
                    }
                }
            }

            $('.iacons').keyup(function () {
                if ($(this).val() != '' && $.isNumeric($(this).val())) {
                    var price = parseFloat($(this).closest('tr').find('.iaprice')[0].innerHTML).toFixed(2);
                    var cons = parseFloat($(this).val());
                    var accCost = (Math.round(price * cons * 100) / 100);
                    $(this).closest('tr').find('.iacost')[0].innerHTML = accCost;
                    $(this).closest('tr').find('.txtiacost').val(accCost);
                    $(this).removeAttr('style');
                }
                else {
                    $(this).attr('style', 'border-color:#FF0000');
                    $(this).closest('tr').find('.iacost')[0].innerHTML = '0.00';
                }
                calculateAccessoryDataGrid();
            });

            if (deleteAccessory) {
                calculateAccessoryDataGrid();

                if ($('#' + txtSubWastage).val() != '') {
                    calculateWastage();
                    calculateFinance();
                    if ($('#' + txtSubFinance).val() != '' && $('#' + txtSubWastage).val() != '') {
                        calculateFactoryCost();
                    }
                }
            }

            $('#' + txtJKFobQuoted).keyup(function () {
                calculateRoundUp();
            });

            $('#' + txtsmv).keyup(function () {

                if ($(this).val() != '' && $.isNumeric($('#' + txtsmv).val())) {
                    if ($('#' + txtsmvrate).val() != '' && $.isNumeric($('#' + txtsmvrate).val())) {
                        $('#' + txtcalccm).val(parseFloat((parseFloat($('#' + txtsmvrate).val()) * parseFloat($('#' + txtsmv).val()))).toFixed(2));
                        $('#' + txtCM).val($('#' + txtcalccm).val());
                        $('#' + txtsmvrate).removeAttr('style');
                    }
                    else {
                        $(this).attr('style', 'border-color:#FF0000');
                        $('#' + txtcalccm).val('');
                        $('#' + txtCM).val('');
                    }
                    $(this).removeAttr('style');
                }
                else {
                    $(this).attr('style', 'border-color:#FF0000');
                }

                if ($('#' + txtSubFinance).val() != '' && $('#' + txtSubWastage).val() != '') {
                    calculateFactoryCost();
                }
            });

            $('#' + txtsmvrate).keyup(function () {

                //if ($(this).val() != '' && $.isNumeric($('#' + txtsmv).val())) {
                //    if ($('#' + txtsmvrate).val() != '' && $.isNumeric($('#' + txtsmvrate).val())) {
                //        $('#' + txtcalccm).val(parseFloat((parseFloat($('#' + txtsmvrate).val()) * parseFloat($('#' + txtsmv).val()))).toFixed(2));
                //        $('#' + txtCM).val($('#' + txtcalccm).val());
                //        $('#' + txtsmvrate).removeAttr('style');
                //    }
                //    else {
                //        $(this).attr('style', 'border-color:#FF0000');
                //        $('#' + txtcalccm).val('');
                //        $('#' + txtCM).val('');
                //    }
                //    $(this).removeAttr('style');
                //}
                //else {
                //    $(this).attr('style', 'border-color:#FF0000');
                //}

                //if ($('#' + txtSubFinance).val() != '' && $('#' + txtSubWastage).val() != '') {
                //    calculateFactoryCost();
                //}

                calculateSMV();
            });

            //$('#' + txtSubWastage).click(function () {
            //    calculateWastage();
            //});

            $('#' + txtWastage).keyup(function () {
                calculateWastage();
            });

            $('#' + txttotalFabricCost).keyup(function () {
                calculateFinance();
            });

            $('#' + txtAccessoriesCost).keyup(function () {
                calculateWastage();
                calculateFinance();
            });

            $('#' + txtHeatPressOverhead).keyup(function () {
                calculateWastage();
                calculateFinance();
            });

            $('#' + txtLabelCost).keyup(function () {
                calculateWastage();
                calculateFinance();
            });

            $('#' + txtPacking).keyup(function () {
                calculateWastage();
                calculateFinance();
            });

            //$('#' + txtSubFinance).click(function () {
            //    calculateFinance();
            //});

            $('#' + txtFinance).keyup(function () {
                calculateFinance();
            });

            $('#' + txtExchangeRate).keyup(function () {

                if ($('#' + txtExchangeRate).val() != '' && $.isNumeric($('#' + txtExchangeRate).val())) {
                    calculateFOBAUD();
                }
                else {
                    //$('#' + txtExchangeRate).attr('style', 'border-color:#FF0000');
                    $('#' + txtExchangeRate).val('');
                }
            });

            $('#' + txtFOB).keyup(function () {

                if ($('#' + txtFOB).val() != '' && $.isNumeric($('#' + txtFOB).val())) {
                    calculateFOBAUD();
                }
                else {
                    $('#' + txtFOB).attr('style', 'border-color:#FF0000');
                    $('#' + txtFOB).val('');
                }
            });

            $('#' + txtDutyRate).keyup(function () {
                calculateDuty();
            });

            $('#' + txtRate1).keyup(function () {
                calculateCost1();
            });

            $('#' + txtCONS1).keyup(function () {
                calculateCost1();
            });

            $('#' + txtRate2).keyup(function () {
                calculateCost2();
            });

            $('#' + txtCONS2).keyup(function () {
                calculateCost2();
            });

            $('#' + txtRate3).keyup(function () {
                calculateCost3();
            });

            $('#' + txtCONS3).keyup(function () {
                calculateCost3();
            });

            //calculate Ink cost
            $('#' + txtInk).keyup(function () {
                calculateInkCost();
            });

            //calculate Ink cost
            $('#' + txtInkRate).keyup(function () {
                calculateInkCost();
            });

            //calculate paper consumtion
            $('#' + txtSublimationConsumption).keyup(function () {

                if ($(this).val() != '' && $.isNumeric($(this).val())) {

                    $(this).removeAttr('style');
                    var papercons = (parseFloat($('#' + txtSublimationConsumption).val()) * 1.1);
                    $('#' + txtPaper).val(papercons.toFixed(2));
                    calculatePaperCost();
                }
                else {
                    $(this).attr('style', 'border-color:#FF0000');
                }

            });

            //calculate paper cost
            $('#' + txtPaper).keyup(function () {
                calculatePaperCost();
            });

            //calculate paper cost
            $('#' + txtPaperRate).keyup(function () {
                calculatePaperCost();
            });

            //calculate Landed Cost
            $('#' + txtAirFreight).keyup(function () {
                calculateLanded();
            });

            //calculate Landed Cost
            $('#' + txtImpCharges).keyup(function () {
                calculateLanded();
            });

            //calculate Landed Cost
            $('#' + txtMgtOH).keyup(function () {
                calculateLanded();
            });

            //calculate Landed Cost
            $('#' + txtIndicoOH).keyup(function () {
                calculateLanded();
            });

            //calculate Landed Cost
            $('#' + txtDepar).keyup(function () {
                calculateLanded();
            });

            //calculate Indimancif
            $('#' + txtMarginRate).keyup(function () {
                calculateIndimanCIF();
            });

            $('#' + txtQuotedCif).keyup(function () {
                calculateActMgn();
                calculateQuotedMP();

                if ($('#' + txtQuotedFOB).val() != '') {
                    calculateQuotedFOB();
                }
            });

            $('#' + txtFobFactor).keyup(function () {
                calculateQuotedFOB();
            });
        });

        function calculateSMV() {
            if ($('#' + txtsmv).val() != '' && $.isNumeric($('#' + txtsmv).val())) {
                if ($('#' + txtsmvrate).val() != '' && $.isNumeric($('#' + txtsmvrate).val())) {
                    $('#' + txtcalccm).val(parseFloat((parseFloat($('#' + txtsmvrate).val()) * parseFloat($('#' + txtsmv).val()))).toFixed(2));
                    $('#' + txtCM).val($('#' + txtcalccm).val());
                    $('#' + txtsmvrate).removeAttr('style');
                }
                else {
                    $('#' + txtsmv).attr('style', 'border-color:#FF0000');
                    $('#' + txtcalccm).val('');
                    $('#' + txtCM).val('');
                }
                $('#' + txtsmv).removeAttr('style');
            }
            else {
                $('#' + txtsmv).attr('style', 'border-color:#FF0000');
            }

            if ($('#' + txtSubFinance).val() != '' && $('#' + txtSubWastage).val() != '') {
                calculateFactoryCost();
            }
        }

        function calculateAccessoryDataGrid() {
            var value = 0;
            $('.igridaccessory').find('.iacost').each(function () {
                value += parseFloat($(this)[0].innerHTML);
            });
            $('#' + txtAccessoriesCost).val(value.toFixed(2));
            $('#' + accTotalID).text(value.toFixed(2));

            calculateWastage();
            calculateFinance();
            if ($('#' + txtSubFinance).val() != '' && $('#' + txtSubWastage).val() != '') {
                calculateFactoryCost();
            }
        }

        function calculateInkCost() {
            if ($('#' + txtInk).val() != '' && $.isNumeric($('#' + txtInk).val())) {

                $('#' + txtInk).removeAttr('style');

                if ($('#' + txtInkRate).val() != '' && $.isNumeric($('#' + txtInkRate).val())) {

                    $('#' + txtInkRate).removeAttr('style');
                    var inkcost = (parseFloat($('#' + txtInk).val()) * parseFloat($('#' + txtInkRate).val()) * 1.02);
                    $('#' + txtInkCost).val(inkcost.toFixed(3));
                    calculateLanded();
                }
                else {
                    $('#' + txtInkRate).attr('style', 'border-color:#FF0000');
                }

            }
            else {
                $('#' + txtInk).attr('style', 'border-color:#FF0000');
            }
        }

        function calculateCost1() {
            if ($('#' + txtRate1).val() != '' && $.isNumeric($('#' + txtRate1).val())) {
                $('#' + txtRate1).removeAttr('style');

                if ($('#' + txtCONS1).val() != '' && $.isNumeric($('#' + txtCONS1).val())) {

                    $('#' + txtCONS1).removeAttr('style');

                    var cost1 = (parseFloat($('#' + txtCONS1).val()) * parseFloat($('#' + txtRate1).val()));
                    $('#' + txtCost1).val(cost1.toFixed(2));
                    if ($('#' + txtLanded).val() != '') {
                        calculateLanded();
                    }
                }
                else {
                    $('#' + txtCONS1).attr('style', 'border-color:#FF0000');
                }
            } else {
                $('#' + txtRate1).attr('style', 'border-color:#FF0000');
            }
        }

        function calculateCost2() {
            if ($('#' + txtRate2).val() != '' && $.isNumeric($('#' + txtRate2).val())) {
                $('#' + txtRate2).removeAttr('style');

                if ($('#' + txtCONS2).val() != '' && $.isNumeric($('#' + txtCONS2).val())) {

                    $('#' + txtCONS2).removeAttr('style');

                    var cost2 = (parseFloat($('#' + txtCONS2).val()) * parseFloat($('#' + txtRate2).val()));
                    $('#' + txtCost2).val(cost2.toFixed(2));
                    if ($('#' + txtLanded).val() != '') {
                        calculateLanded();
                    }
                }
                else {
                    $('#' + txtCONS2).attr('style', 'border-color:#FF0000');
                }
            } else {
                $('#' + txtRate2).attr('style', 'border-color:#FF0000');
            }
        }

        function calculateCost3() {
            if ($('#' + txtRate3).val() != '' && $.isNumeric($('#' + txtRate3).val())) {

                $('#' + txtRate3).removeAttr('style');

                if ($('#' + txtCONS3).val() != '' && $.isNumeric($('#' + txtCONS3).val())) {

                    $('#' + txtCONS3).removeAttr('style');

                    var cost3 = (parseFloat($('#' + txtCONS3).val()) * parseFloat($('#' + txtRate3).val()));
                    $('#' + txtCost3).val(cost3.toFixed(2));
                    calculateLanded();
                }
                else {
                    $('#' + txtCONS3).attr('style', 'border-color:#FF0000');
                }
            } else {
                $('#' + txtRate3).attr('style', 'border-color:#FF0000');
            }
        }

        function calculateFOBAUD() {
            if ($('#' + txtExchangeRate).val() != '' && $.isNumeric($('#' + txtExchangeRate).val())) {

                if ($('#' + txtJKFobQuoted).val() != '' && $('#' + txtJKFobQuoted).val() != '0.00') {
                    var fobaud = (parseFloat($('#' + txtJKFobQuoted).val()) / parseFloat($('#' + txtExchangeRate).val()))
                    $('#' + txtFOB).val(fobaud.toFixed(2));
                    calculateDuty();
                }
                else {
                    var fobaud = (parseFloat($('#' + txtFobCost).val()) / parseFloat($('#' + txtExchangeRate).val()))
                    $('#' + txtFOB).val(fobaud.toFixed(2));
                    calculateDuty();
                }
                if ($('#' + txtLanded).val() != '') {
                    calculateLanded();
                }
            } else {
                $('#' + txtExchangeRate).attr('style', 'border-color:#FF0000');
            }
        }

        function calculateDuty() {
            if ($('#' + txtDutyRate).val() != '' && $.isNumeric($('#' + txtDutyRate).val().replace('%', ''))) {
                var duty = ((parseFloat($('#' + txtDutyRate).val().replace('%', '')) * parseFloat($('#' + txtFOB).val())) / 100);
                $('#' + txtDuty).val(duty.toFixed(2));
                if ($('#' + txtLanded).val() != '') {
                    calculateLanded();
                }
            }
            else {
                $('#' + txtDutyRate).attr('style', 'border-color:#FF0000');
            }
        }

        function calculateFinance() {
            if ($('#' + txtAccessoriesCost).val() != '' && $.isNumeric($('#' + txtAccessoriesCost).val())) {

                $('#' + txtAccessoriesCost).removeAttr('style');

                if ($('#' + txttotalFabricCost).val() != '' && $.isNumeric($('#' + txtAccessoriesCost).val())) {

                    $('#' + txttotalFabricCost).removeAttr('style');

                    if ($('#' + txtFinance).val() != '') {

                        var cal = ((parseFloat($('#' + txtFinance).val().replace('%', '')) * (parseFloat($('#' + txttotalFabricCost).val()) + parseFloat($('#' + txtAccessoriesCost).val()) + parseFloat($('#' + txtHeatPressOverhead).val()) + parseFloat($('#' + txtLabelCost).val()) + parseFloat($('#' + txtPacking).val()))) / 100);
                        $('#' + txtSubFinance).val(cal.toFixed(2));
                        $('#' + txtFinance).removeAttr('style');
                        calculateFactoryCost();
                    }
                    else {
                        $('#' + txtFinance).attr('style', 'border-color:#FF0000');
                        $('#' + txtSubFinance).val('');
                    }
                }

                else {
                    $('#' + txttotalFabricCost).attr('style', 'border-color:#FF0000');
                    $('#' + txtSubFinance).val('');
                }
            }
            else {
                $('#' + txtAccessoriesCost).attr('style', 'border-color:#FF0000');
                $('#' + txtSubFinance).val('');
            }
        }

        function calculateFactoryCost() {
            if ($('#' + txtSubFinance).val() != '' && $('#' + txtSubWastage).val() != '') {

                var value = (parseFloat($('#' + txttotalFabricCost).val()) + parseFloat($('#' + txtAccessoriesCost).val()) + parseFloat($('#' + txtHeatPressOverhead).val()) + parseFloat($('#' + txtLabelCost).val()) + parseFloat($('#' + txtPacking).val()) + parseFloat($('#' + txtSubFinance).val()) + parseFloat($('#' + txtSubWastage).val()) + parseFloat($('#' + txtCM).val()));
                if (isNaN(value)) {
                    $('#' + txtFobCost).val('0.00');
                }
                else {
                    $('#' + txtFobCost).val(value.toFixed(2));
                    calculateRoundUp();
                    calculateFOBAUD();
                }
            }
        }

        function calculateWastage() {
            if ($('#' + txtAccessoriesCost).val() != '' && $.isNumeric($('#' + txtAccessoriesCost).val())) {

                $('#' + txtAccessoriesCost).removeAttr('style');

                if ($('#' + txtHeatPressOverhead).val() != '' && $.isNumeric($('#' + txtHeatPressOverhead).val())) {

                    $('#' + txtHeatPressOverhead).removeAttr('style');

                    if ($('#' + txtLabelCost).val() != '' && $.isNumeric($('#' + txtLabelCost).val())) {

                        $('#' + txtLabelCost).removeAttr('style');

                        if ($('#' + txtPacking).val() != '' && $.isNumeric($('#' + txtPacking).val())) {

                            $('#' + txtPacking).removeAttr('style');

                            if ($('#' + txtWastage).val() != '') {

                                var cal = (parseFloat(($('#' + txtWastage).val().replace('%', '')) * (parseFloat($('#' + txtAccessoriesCost).val()) + parseFloat($('#' + txtHeatPressOverhead).val()) + parseFloat($('#' + txtLabelCost).val()) + parseFloat($('#' + txtPacking).val()))) / 100);
                                $('#' + txtSubWastage).val(cal.toFixed(2));
                                $('#' + txtWastage).removeAttr('style');
                                calculateFactoryCost();
                            }
                            else {
                                $('#' + txtWastage).attr('style', 'border-color:#FF0000');
                                $('#' + txtSubWastage).val('');
                            }
                        }
                        else {
                            $('#' + txtPacking).attr('style', 'border-color:#FF0000');
                            $('#' + txtSubWastage).val('');
                        }
                    }
                    else {
                        $('#' + txtLabelCost).attr('style', 'border-color:#FF0000');
                        $('#' + txtSubWastage).val('');
                    }
                }
                else {
                    $('#' + txtHeatPressOverhead).attr('style', 'border-color:#FF0000');
                    $('#' + txtSubWastage).val('');
                }
            }
            else {
                $('#' + txtAccessoriesCost).attr('style', 'border-color:#FF0000');
                $('#' + txtSubWastage).val('');
            }
        }

        function calculateRoundUp() {
            if ($.isNumeric($('#' + txtJKFobQuoted).val()) && $('#' + txtJKFobQuoted).val() != '') {
                var cal = (parseFloat($('#' + txtJKFobQuoted).val()) - parseFloat($('#' + txtFobCost).val()))
                $('#' + txtRoundUp).val(cal.toFixed(2));
                $('#' + txtJKFobQuoted).attr('style', 'background-color: #FBDB0C;');
                calculateFOBAUD();
            }
            else {
                $('#' + txtJKFobQuoted).attr('style', 'border-color:#FF0000; background-color: #FBDB0C;');
                $('#' + txtRoundUp).val('');
            }
        }

        function calculateFabricDataGrid() {
            var value = 0;
            $('.igridfabric').find('.ifcost').each(function () {
                value += parseFloat($(this)[0].innerHTML);
            });

            $('#' + txttotalFabricCost).val(value.toFixed(2));
            $('#' + fabTotalID).text(value.toFixed(2));

            calculateWastage();
            calculateFinance();
            if ($('#' + txtSubFinance).val() != '' && $('#' + txtSubWastage).val() != '') {
                calculateFactoryCost();
            }
        }

        function calculateQuotedFOB() {

            if ($('#' + txtQuotedCif).val() != '' && $.isNumeric($('#' + txtQuotedCif).val())) {
                var fobfactor = (parseFloat($('#' + txtQuotedCif).val()) - parseFloat($('#' + txtFobFactor).val()));
                $('#' + txtQuotedFOB).val(fobfactor.toFixed(2));
            }
        }

        function calculateIndimanCIF() {
            if ($('#' + txtLanded).val() != '' && $('#' + txtMarginRate).val().replace('%', '') != '') {
                var indimancif = (parseFloat($('#' + txtLanded).val()) / (1 - ($('#' + txtMarginRate).val().replace('%', '') / 100)));
                $('#' + txtCIF).val(indimancif.toFixed(2));
                calculateMGN();
                calculatedMP();

                if ($('#' + txtQuotedCif).val() != '') {
                    calculateActMgn();
                    calculateQuotedMP();
                }
            }
        }

        function calculatePaperCost() {

            if ($('#' + txtPaper).val() != '' && $.isNumeric($('#' + txtPaper).val())) {

                $('#' + txtPaper).removeAttr('style');

                if ($('#' + txtPaperRate).val() != '' && $.isNumeric($('#' + txtPaperRate).val())) {

                    $('#' + txtPaperRate).removeAttr('style');
                    var papercost = (parseFloat($('#' + txtPaper).val()) * parseFloat($('#' + txtPaperRate).val()) * 1.2);
                    $('#' + txtPaperCost).val(papercost.toFixed(2));
                    calculateLanded();
                }
                else {
                    $('#' + txtPaperRate).attr('style', 'border-color:#FF0000');
                }

            }
            else {
                $('#' + txtPaper).attr('style', 'border-color:#FF0000');
            }
        }

        function calculateLanded() {

            if ($('#' + txtFOB).val() != '' && $.isNumeric($('#' + txtFOB).val())) {

                $('#' + txtFOB).removeAttr('style');

                if ($('#' + txtDuty).val() != '' && $.isNumeric($('#' + txtDuty).val())) {

                    $('#' + txtDuty).removeAttr('style');

                    if ($.isNumeric($('#' + txtCost1).val())) {

                        $('#' + txtCost1).removeAttr('style');

                        if ($.isNumeric($('#' + txtCost2).val())) {

                            $('#' + txtCost2).removeAttr('style');

                            if ($.isNumeric($('#' + txtCost3).val())) {

                                $('#' + txtCost3).removeAttr('style');

                                if ($.isNumeric($('#' + txtInkCost).val())) {

                                    $('#' + txtInkCost).removeAttr('style');

                                    if ($.isNumeric($('#' + txtPaperCost).val())) {

                                        $('#' + txtPaperCost).removeAttr('style');

                                        if ($.isNumeric($('#' + txtAirFreight).val())) {

                                            $('#' + txtAirFreight).removeAttr('style');

                                            if ($.isNumeric($('#' + txtImpCharges).val())) {

                                                $('#' + txtImpCharges).removeAttr('style');

                                                if ($.isNumeric($('#' + txtMgtOH).val())) {

                                                    $('#' + txtMgtOH).removeAttr('style');

                                                    if ($.isNumeric($('#' + txtIndicoOH).val())) {

                                                        $('#' + txtIndicoOH).removeAttr('style');

                                                        if ($.isNumeric($('#' + txtDepar).val())) {

                                                            $('#' + txtDepar).removeAttr('style');

                                                            $('#' + txtLanded).removeAttr('style');
                                                            var landed = (parseFloat($('#' + txtFOB).val()) + parseFloat($('#' + txtDuty).val()) + parseFloat($('#' + txtCost1).val()) + parseFloat($('#' + txtCost2).val()) + parseFloat($('#' + txtCost3).val()) + parseFloat($('#' + txtInkCost).val()) + parseFloat($('#' + txtPaperCost).val()) + parseFloat($('#' + txtAirFreight).val()) + parseFloat($('#' + txtImpCharges).val()) + parseFloat($('#' + txtMgtOH).val()) + parseFloat($('#' + txtIndicoOH).val()) + parseFloat($('#' + txtDepar).val()))
                                                            $('#' + txtLanded).val(landed.toFixed(2));
                                                            calculateIndimanCIF();
                                                        }
                                                        else {
                                                            $('#' + txtDepar).attr('style', 'border-color:#FF0000');
                                                        }
                                                    }
                                                    else {
                                                        $('#' + txtIndicoOH).attr('style', 'border-color:#FF0000');
                                                    }

                                                }
                                                else {
                                                    $('#' + txtMgtOH).attr('style', 'border-color:#FF0000');
                                                }
                                            }
                                            else {
                                                $('#' + txtImpCharges).attr('style', 'border-color:#FF0000');
                                            }

                                        }
                                        else {
                                            $('#' + txtAirFreight).attr('style', 'border-color:#FF0000');
                                        }

                                    }
                                    else {
                                        $('#' + txtPaperCost).attr('style', 'border-color:#FF0000');
                                    }

                                }
                                else {
                                    $('#' + txtInkCost).attr('style', 'border-color:#FF0000');
                                }
                            }
                            else {
                                $('#' + txtCost3).attr('style', 'border-color:#FF0000');
                            }
                        }
                        else {
                            $('#' + txtCost2).attr('style', 'border-color:#FF0000');
                        }
                    }
                    else {

                        $('#' + txtCost1).attr('style', 'border-color:#FF0000');
                    }
                }
                else {
                    $('#' + txtDuty).attr('style', 'border-color:#FF0000');
                }
            }
            else {
                $('#' + txtFOB).attr('style', 'border-color:#FF0000');
            }
        }

        function calculateActMgn() {
            if ($('#' + txtQuotedCif).val() != '' && $('#' + txtLanded).val() && $.isNumeric($('#' + txtLanded).val()) && $.isNumeric($('#' + txtQuotedCif).val())) {
                var actmgn = (parseFloat($('#' + txtQuotedCif).val()) - parseFloat($('#' + txtLanded).val()));
                $('#' + txtActMgn).val(actmgn.toFixed(2));
            }
        }

        function calculateQuotedMP() {
            if ($('#' + txtQuotedCif).val() != '' && $('#' + txtLanded).val() && $.isNumeric($('#' + txtLanded).val()) && $.isNumeric($('#' + txtQuotedCif).val())) {
                var qmp = ((1 - (parseFloat($('#' + txtLanded).val())) / parseFloat($('#' + txtQuotedCif).val())) * 100);

                if ($.isNumeric(qmp)) {
                    $('#' + txtQuotedMp).val(qmp.toFixed(2));
                }
                else {
                    $('#' + txtQuotedMp).val('0.00');
                }
            }
        }

        function calculateMGN() {
            if ($('#' + txtCIF).val() != '' && $('#' + txtLanded).val() && $.isNumeric($('#' + txtLanded).val()) && $.isNumeric($('#' + txtCIF).val())) {
                var mgn = (parseFloat($('#' + txtCIF).val()) - parseFloat($('#' + txtLanded).val()));
                $('#' + txtCalMgn).val(mgn.toFixed(2));
            }
        }

        function calculatedMP() {
            if ($('#' + txtCIF).val() != '' && $('#' + txtLanded).val() && $.isNumeric($('#' + txtLanded).val()) && $.isNumeric($('#' + txtCIF).val())) {
                var mp = ((1 - (parseFloat($('#' + txtLanded).val())) / parseFloat($('#' + txtCIF).val())) * 100);
                $('#' + txtMp).val(mp.toFixed(2));
            }
        }
    </script>
</asp:Content>
