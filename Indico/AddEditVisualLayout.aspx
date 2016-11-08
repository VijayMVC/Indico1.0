<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditVisualLayout.aspx.cs" Inherits="Indico.AddEditVisualLayout" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <style type="text/css">
        .icon-remove {
            color: red;
            cursor: pointer;
            cursor: hand;
        }
    </style>

    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <!-- Page -->
    <div class="page">
        
        <!-- Page Header -->
        <div class="page-header">
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"
                    ValidationGroup="valGrpVL"></asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <legend>Details</legend>
                <%-- <div class="control-group">
                    <div class="controls">
                        <label class="checkbox inline">
                            <asp:CheckBox ID="checkIsCommonproduct" runat="server" OnCheckedChanged="IsCommonProduct_Changed"
                                AutoPostBack="true" />
                            Is Common Product?
                        </label>
                    </div>
                </div>--%>
                <input type="text" style="display: none;" runat="server" ID="serverImagePath"/>

                <div class="control-group">
                    <div class="controls">
                        <label class="checkbox">
                            <asp:CheckBox ID="chkIsActive" runat="server" Checked ="true" />
                            Is Active
                        </label>
                    </div>
                </div>
                <div class="control-group" runat="server" visible="false">
                    <div class="controls">
                        <label class="checkbox inline">
                            <asp:RadioButton ID="rbGenerate" runat="server" GroupName="vlNumber"
                                AutoPostBack="true" OnCheckedChanged="IsProduct_OnCheckChanged" />
                            Generate
                        </label>
                        <label class="checkbox inline">
                            <asp:RadioButton ID="rbCustom" runat="server" GroupName="vlNumber" AutoPostBack="true"
                                OnCheckedChanged="IsProduct_OnCheckChanged" />
                            Custom
                        </label>
                    </div>
                </div>
                <div id="liPrinterType" runat="server" class="control-group">
                    <label class="control-label">
                        Print Type
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlPrinterType" runat="server" CssClass="input-xlarge">
                            <%-- AutoPostBack="true" OnSelectedIndexChanged="ddlPrintType_SelectedIndexChange"--%>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label id="lblProductNumber" runat="server" class="control-label required">
                        Product Number
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtProductNumber" runat="server" Enabled="false"> <%--AutoPostBack="true" OnTextChanged="txtProductNumber_TextChanged"--%>
                        </asp:TextBox>
                        <asp:Button ID="btnCheckName" runat="server" Text="Check Name" CssClass="btn-info" OnClick="btnCheckName_Click" />
                        <asp:Label ID="lblCheckName" runat="server"></asp:Label>
                        <button style="display: none;"  ID="checkImageOnServerButton" class="btn-info" title="Check if the image is available in the server!">Check Image</button>
                        <asp:RequiredFieldValidator ID="rfvProductNumber" runat="server" ErrorMessage="Product number is required"
                            ControlToValidate="txtProductNumber" EnableClientScript="false" ValidationGroup="valGrpVL"
                            InitialValue="0">
                            <img src="Content/img/icon_warning.png"  title="Product number is required" alt="Product Number is required" />
                        </asp:RequiredFieldValidator>
                        <asp:CustomValidator ID="cvProductNumber" runat="server" ErrorMessage="This Product number already being used."
                            EnableClientScript="false" ValidationGroup="valGrpVL" ControlToValidate="txtProductNumber"
                            OnServerValidate="cvProductNumber_OnServerValidate">
                                <img src="Content/img/icon_warning.png"  title="This Product number already being used." alt="This Product number already being used." />
                        </asp:CustomValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">By-Size Artwork?</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlBySizeArtwork" CssClass="input-xlarge" runat="server"></asp:DropDownList>

                    </div>
                </div>
                <asp:UpdateProgress ID="upDistributor" runat="server" AssociatedUpdatePanelID="updatePnlDistributor">
                    <ProgressTemplate>
                        <div style="position: fixed; text-align: center; height: 100%; width: 100%; top: 0; right: 0; left: 0; z-index: 9999999; background-color: #000000; opacity: 0.7;">
                            <span style="border-width: 0px; position: fixed; padding: 50px; background-color: #FFFFFF; font-size: 24px; left: 40%; top: 40%;">Loading...</span>
                        </div>
                    </ProgressTemplate>
                </asp:UpdateProgress>
                <div id="dvHideColums" runat="server">
                    <asp:UpdatePanel ID="updatePnlDistributor" runat="server">
                        <ContentTemplate>
                            <div class="control-group">
                                <label class="control-label required">
                                    Distributor</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlDistributor" CssClass="input-xlarge" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlDistributor_SelectedIndexChange">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Primary Coordinator</label>
                                <div class="controls">
                                    <b>
                                        <asp:Label ID="lblPrimaryCoordinator" runat="server"></asp:Label></b>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Client</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlClient" CssClass="input-xlarge" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlClient_SelectedIndexChanged" Enabled="true">
                                    </asp:DropDownList>
                                    <a id="ancNewClient" runat="server" visible="false" class="btn btn-link" onclick="javascript:AddNewClient();" title="Add New Client"><i class="icon-plus"></i></a>
                                    <asp:Literal ID="litClient" runat="server"></asp:Literal>
                                    <a id="ancEditClient" runat="server" visible="false" class="btn btn-link" onclick="javascript:EditClient();" title="Edit Client"><i class="icon-pencil"></i></a>
                                    <%--<asp:LinkButton ID="btnEditClient" runat="server" Visible="false" class="btn btn-link" OnClick="btnEditClient_Click"><i class="icon-pencil"></i></asp:LinkButton>--%>
                                    <asp:RequiredFieldValidator ID="rfvClient" runat="server" ErrorMessage="Client is required."
                                        ControlToValidate="ddlClient" InitialValue="0" EnableClientScript="false"
                                        Display="Dynamic" ValidationGroup="valGrpOrderHeader">
                                            <img src="Content/img/icon_warning.png"  title="Client is required." alt="Client is required." />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Job Name</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlJobName" CssClass="input-xlarge" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlJobName_SelectedIndexChanged">
                                    </asp:DropDownList>
                                    <a id="ancNewJobName" runat="server" visible="false" class="btn btn-link" onclick="javascript:AddNewJobName();" title="Add New Job Name"><i class="icon-plus"></i></a>
                                    <asp:Literal ID="litJobName" runat="server"></asp:Literal>
                                    <asp:LinkButton ID="btnEditJobName" runat="server" Visible="false" class="btn btn-link" OnClick="btnEditJobName_Click" ToolTip="Edit JobName"><i class="icon-pencil"></i></asp:LinkButton>
                                    <asp:RequiredFieldValidator ID="rfvClientOrJobName" runat="server" ErrorMessage="Job Name is required."
                                        ControlToValidate="ddlJobName" InitialValue="0" EnableClientScript="false"
                                        Display="Dynamic" ValidationGroup="valGrpOrderHeader">
                                            <img src="Content/img/icon_warning.png"  title="Job Name is required." alt="Job Name is required." />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group" id="lblSecCord" runat="server" visible="false">
                                <label class="control-label">
                                    Secondary Coordinator</label>
                                <div class="controls">
                                    <b>
                                        <asp:Label ID="lblSecondaryCoordinator" runat="server" Visible="false"></asp:Label></b>
                                </div>
                            </div>
                        </ContentTemplate>
                        <Triggers>
                            <asp:PostBackTrigger ControlID="btnEditJobName" />
                            <asp:PostBackTrigger ControlID="btnEditJobName" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>
                <asp:UpdateProgress ID="upFabric" runat="server" AssociatedUpdatePanelID="updatePnlFabric">
                    <ProgressTemplate>
                        <div style="position: fixed; text-align: center; height: 100%; width: 100%; top: 0; right: 0; left: 0; z-index: 9999999; background-color: #000000; opacity: 0.7;">
                            <span style="border-width: 0px; position: fixed; padding: 50px; background-color: #FFFFFF; font-size: 24px; left: 40%; top: 40%;">Loading...</span>
                        </div>
                    </ProgressTemplate>
                </asp:UpdateProgress>
                <asp:UpdatePanel ID="updatePnlFabric" runat="server">
                    <ContentTemplate>
                        <div class="control-group">
                            <label class="control-label required">
                                Pattern</label>
                            <div class="controls">
                                <asp:DropDownList ID="ddlPattern" CssClass="input-xlarge" runat="server" OnSelectedIndexChanged="ddlPattern_OnSelectedIndexChanged"
                                    AutoPostBack="true">
                                </asp:DropDownList>
                                <span class="text-error">
                                    <asp:Literal ID="litPatternError" runat="server" Visible="false"></asp:Literal>
                                </span>
                                <asp:LinkButton ID="linkViewPattern" runat="server" CssClass="btn-link ipattern"
                                    ToolTip="View Pattern" OnClick="linkViewPattern_Click" Visible="false">Pattern</asp:LinkButton>
                                <asp:LinkButton ID="linkSpecification" runat="server" CssClass="btn-link ispec" ToolTip="View Garment Specification"
                                    OnClick="linkSpecification_Click" Visible="false">Sepecification</asp:LinkButton>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label required">
                                Fabric</label>
                            <div class="controls">
                                <asp:DropDownList ID="ddlFabric" CssClass="input-xlarge" runat="server" Enabled="true" OnSelectedIndexChanged="ddlFabric_SelectedIndexChanged" AutoPostBack="true">
                                </asp:DropDownList>
                                <asp:Label ID="lblFabricDescription" runat="server"></asp:Label>
                                <asp:RequiredFieldValidator ID="rfvFabric" runat="server" ErrorMessage="Fabric is required."
                                    ControlToValidate="ddlFabric" InitialValue="0" EnableClientScript="false"
                                    Display="Dynamic" ValidationGroup="valGrpVL">
                                            <img src="Content/img/icon_warning.png"  title="Fabric is required." alt="Fabric is required." />
                                </asp:RequiredFieldValidator>
                                <asp:Label ID="lblVLFabricErrorText" runat="server" ForeColor="Red"></asp:Label>
                            </div>
                        </div>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="ddlPattern" EventName="SelectedIndexChanged" />
                        <asp:AsyncPostBackTrigger ControlID="ddlFabric" EventName="SelectedIndexChanged" />
                    </Triggers>
                </asp:UpdatePanel>
                <div class="span6">
                    <%--<div>
                        <legend>Fabric Details</legend>
                        <div class="control-group">
                            <div class="controls">
                                <asp:DropDownList ID="ddlFabricCodeType" runat="server" CssClass="input-medium" AutoPostBack="true" OnSelectedIndexChanged="ddlFabricCodeType_SelectedIndexChanged">
                                </asp:DropDownList>
                                <asp:DropDownList ID="ddlAddFabrics" runat="server" CssClass="input-xxlarge pull-right"
                                    AutoPostBack="true" OnSelectedIndexChanged="ddlAddFabrics_SelectedIndexChange">
                                </asp:DropDownList>
                            </div>
                        </div>
                        <asp:DataGrid ID="dgvAddEditFabrics" runat="server" CssClass="table igridfabric" AllowCustomPaging="False"
                            AutoGenerateColumns="false" GridLines="None" PageSize="10" OnItemDataBound="dgvAddEditFabrics_ItemDataBound"
                            OnItemCommand="dgvAddEditFabrics_onItemCommand">
                            <HeaderStyle CssClass="header" />
                            <Columns>
                                <asp:TemplateColumn HeaderText="ID" Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="litID" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <%-- <asp:TemplateColumn HeaderText="VisualLayoutFabricID" Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="litVFID" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>--% >
                                <asp:TemplateColumn Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="litFabricTypeID" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateColumn>
                                <asp:TemplateColumn HeaderText="Fabric Code Type">
                                    <ItemTemplate>
                                        <%--<asp:DropDownList ID="ddlfabricCodeType" runat="server" OnSelectedIndexChanged ="ddlfabricCodeType_SelectedIndexChanged"></asp:DropDownList>--% >
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
                                <asp:TemplateColumn HeaderText="Where">
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
                            <h4>There are no Fabrics added to this Visual Layout.
                            </h4>
                            <p>
                                You can add many Fabrics to this Visual Layout.
                            </p>
                        </div>
                    </div>--%>
                    <div class="control-group">
                        <label class="control-label">
                            Resolution Profile</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlResolutionProfile" CssClass="input-xlarge" runat="server">
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">Pocket</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlPocketType" CssClass="input-xlarge" runat="server"></asp:DropDownList>
                        </div>
                    </div>
                    <div class="control-group">
                    <div class="controls">
                        <label class="checkbox">
                            <asp:CheckBox ID="chkIsEmbroidery" runat="server" />
                            Embrodery? Yes
                        </label>
                    </div>
                </div>
                    <!-- View Pattern -->
                    <div id="dvViewPattern" class="modal">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                            &times;</button>
                        <div class="modal-header">
                            <h2>Pattern Details</h2>
                        </div>
                        <div class="modal-body">
                            <fieldset class="info">
                                <ol>
                                    <li>
                                        <label>
                                            Pattern Number</label>
                                        <asp:TextBox ID="txtPatternNo" runat="server" Enabled="false"></asp:TextBox>
                                    </li>
                                    <li>
                                        <label>
                                            Item Name</label>
                                        <asp:TextBox ID="txtItemName" runat="server" Enabled="false"></asp:TextBox>
                                    </li>
                                    <li>
                                        <label>
                                            Size Set</label>
                                        <asp:TextBox ID="txtSizeSet" runat="server" Enabled="false"></asp:TextBox>
                                    </li>
                                    <li>
                                        <label>
                                            Age Group</label>
                                        <asp:TextBox ID="txtAgeGroup" runat="server" Enabled="false"></asp:TextBox>
                                    </li>
                                    <li>
                                        <label>
                                            Printer Trpe</label>
                                        <asp:TextBox ID="txtPrinterType" runat="server" Enabled="false"></asp:TextBox>
                                    </li>
                                    <li>
                                        <label>
                                            Keywords</label>
                                        <asp:TextBox ID="txtKeyword" runat="server" Enabled="false"></asp:TextBox>
                                    </li>
                                    <li>
                                        <label>
                                            Original Ref</label>
                                        <asp:TextBox ID="txtOriginalRef" runat="server" Enabled="false"></asp:TextBox>
                                    </li>
                                    <li>
                                        <label>
                                            Sub Item Name</label>
                                        <asp:TextBox ID="txtSubItem" runat="server" Enabled="false"></asp:TextBox>
                                    </li>
                                    <li>
                                        <label>
                                            Gender</label>
                                        <asp:TextBox ID="txtGender" runat="server" Enabled="false"></asp:TextBox>
                                    </li>
                                    <li>
                                        <label>
                                            Nick Name</label>
                                        <asp:TextBox ID="txtNickName" runat="server" Enabled="false"></asp:TextBox>
                                    </li>
                                    <li>
                                        <label>
                                            Corr Pattern</label>
                                        <asp:TextBox ID="txtCorrPattern" runat="server" Enabled="false"></asp:TextBox>
                                    </li>
                                    <li>
                                        <label>
                                            Consumption</label>
                                        <asp:TextBox ID="txtConsumption" runat="server" Enabled="false"></asp:TextBox>
                                    </li>
                                </ol>
                            </fieldset>
                        </div>
                    </div>
                    <!-- / -->
                    <!-- View Garment Specification -->
                    <div id="dvViewSpecification" class="modal garmentSpec">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                                &times;</button>
                            <h3>Garment Specification</h3>
                        </div>
                        <div class="modal-body">
                            <ol class="ioderlist-table">
                                <li class="idata-row">
                                    <ul>
                                        <li class="icell-header small">Key</li>
                                        <li class="icell-header exlarge">Loacation</li>
                                        <asp:Repeater ID="rptSpecSizeQtyHeader" runat="server" OnItemDataBound="rptSpecSizeQtyHeader_ItemDataBound">
                                            <ItemTemplate>
                                                <li class="icell-header">
                                                    <asp:Literal ID="litCellHeader" runat="server"></asp:Literal>
                                                </li>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </ul>
                                </li>
                                <asp:Repeater ID="rptSpecML" runat="server" OnItemDataBound="rptSpecML_ItemDataBound">
                                    <ItemTemplate>
                                        <li class="idata-row">
                                            <ul>
                                                <li class="icell-header small">
                                                    <asp:Literal ID="litCellHeaderKey" runat="server"></asp:Literal>
                                                </li>
                                                <li class="icell-header exlarge">
                                                    <asp:Literal ID="litCellHeaderML" runat="server"></asp:Literal>
                                                </li>
                                                <asp:Repeater ID="rptSpecSizeQty" runat="server" OnItemDataBound="rptSpecSizeQty_ItemDataBound">
                                                    <ItemTemplate>
                                                        <li class="icell-data">
                                                            <asp:Label ID="lblCellData" runat="server"></asp:Label>
                                                        </li>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </ul>
                                        </li>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </ol>
                        </div>
                    </div>
                    <!-- / -->
                    <!-- VL Image Uploader -->
                    <div class="control-group" id="uploadContainer">
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
                    <div class="control-group">
                        <label class="control-label">
                            Product Images
                        </label>

                        <div class="controls" style="">
                            <div id="serverImageContainer" style="display: none;">
                                 <div class="form-inline">
                                     
                                    <img alt="" src="" runat="server" style="max-width: 400px" title="Image From the FTP server" id="serverImgaeHolder" />
                                    <span class="icon icon-remove" id="removeServerImageIcon" title="Do not use server Image (upload new images)"></span>
                                </div>
                            </div>
                            
                                                    <div id="dropzone_1" multirow="true" class="fileupload preview">
                            <input id="file_1" name="file_1" type="file" />
                            <button id="btnup_1" type="submit">
                                Upload</button>
                            <div id="divup_1">
                                Drag file here or click to upload
                            </div>

                            <div>
                                <label class="control-label ">
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


                        
                    </div>

                    <!-- / -->
                    <div class="control-group">
                        <label class="control-label">
                            Notes</label>
                        <div class="controls">
                            <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine"></asp:TextBox>
                        </div>
                    </div>                    
                    <!-- VL Image -->
                    <div id="dvEmptyContentVLImages" runat="server" class="alert alert-info">
                        <h4>There are no Product images found.
                        </h4>
                        <p>
                            You can add many Product images as you like.
                        </p>
                    </div>
                    <div id="dvVLImagePreview" runat="server">
                        <legend>Product Images</legend>
                        <ul class="thumbnails text-center">
                            <asp:Repeater ID="rptVisualLayouts" runat="server" OnItemDataBound="rptVisualLayouts_ItemDataBound">
                                <ItemTemplate>
                                    <li class="span3">
                                        <div class="thumbnail">
                                            <asp:Image ID="imgVisualLayout" runat="server" CssClass="img-rounded" />
                                            <div class="caption">
                                                <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn btn-primary idelete"
                                                    ToolTip="Delete Visual Layout Image"><i class="icon-trash icon-white"></i> Delete</asp:HyperLink>
                                                <asp:CheckBox ID="chkHeroImage" runat="server" CssClass="ivlImage" onChange="javascript:checkChanged(this);" />
                                                <asp:Label ID="lblimage" runat="server">Is Visual</asp:Label>
                                            </div>
                                        </div>
                                    </li>
                                </ItemTemplate>
                            </asp:Repeater>
                        </ul>
                        <div id="dvPagingFooter" class="paginator" runat="server">
                            <div class="paginatorRight">
                                <asp:LinkButton ID="lbFooterPrevious" runat="server" class="paginatorPreviousButton"
                                    OnClick="lbHeaderPrevious_Click"></asp:LinkButton>
                                <asp:LinkButton ID="lbFooterPreviousDots" runat="server" class="" OnClick="lbHeaderPreviousDots_Click">...</asp:LinkButton>
                                <asp:LinkButton ID="lbFooter1" CssClass="paginatorLink current" runat="server" OnClick="lbHeader1_Click">1</asp:LinkButton>
                                <asp:LinkButton ID="lbFooter2" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">2</asp:LinkButton>
                                <asp:LinkButton ID="lbFooter3" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">3</asp:LinkButton>
                                <asp:LinkButton ID="lbFooter4" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">4</asp:LinkButton>
                                <asp:LinkButton ID="lbFooter5" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">5</asp:LinkButton>
                                <asp:LinkButton ID="lbFooter6" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">6</asp:LinkButton>
                                <asp:LinkButton ID="lbFooter7" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">7</asp:LinkButton>
                                <asp:LinkButton ID="lbFooter8" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">8</asp:LinkButton>
                                <asp:LinkButton ID="lbFooter9" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">9</asp:LinkButton>
                                <asp:LinkButton ID="lbFooter10" CssClass="paginatorLink" runat="server" OnClick="lbHeader1_Click">10</asp:LinkButton>
                                <asp:LinkButton ID="lbFooterNextDots" runat="server" class="dots" OnClick="lbHeaderNextDots_Click">...</asp:LinkButton>
                                <asp:LinkButton ID="lbFooterNext" runat="server" class="paginatorNextButton" OnClick="lbHeaderNext_Click"></asp:LinkButton>
                            </div>
                        </div>
                    </div>
                    <!-- / -->
                    <!-- Data Content -->
                    <asp:UpdatePanel ID="UpdatePatternAccessory" runat="server">
                        <ContentTemplate>
                            <div id="dvNewDataContent" runat="server" visible="false">
                                <legend>Accessories </legend>
                                <div id="dvAccessoryEmptyContent" runat="server" class="alert alert-info">
                                    <h4>No Accessories Found
                                    </h4>
                                </div>
                                <!-- Data grid -->
                                <asp:DataGrid ID="dgPatternAccessory" runat="server" CssClass="table" AutoGenerateColumns="false"
                                    AllowSorting="true" GridLines="None" AllowPaging="false" AllowCustomPaging="False"
                                    OnItemDataBound="dgPatternAccessory_ItemDataBound">
                                    <HeaderStyle CssClass="header" />
                                    <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                                    <Columns>
                                        <asp:TemplateColumn HeaderText="Pattern Number" Visible="false">
                                            <ItemTemplate>
                                                <asp:Label ID="lblPatternNumber" runat="server"></asp:Label>
                                                <asp:Label ID="lblPatternID" runat="server" Visible="false"></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                        <asp:TemplateColumn HeaderText="Accessory Name">
                                            <ItemTemplate>
                                                <asp:Label ID="lblAccessoryName" runat="server"></asp:Label>
                                                <asp:Label ID="lblAccessoryID" runat="server" Visible="false"></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                        <asp:TemplateColumn HeaderText="Accessory Category">
                                            <ItemTemplate>
                                                <asp:Label ID="lblAccessoryCategory" runat="server"></asp:Label>
                                                <asp:Label ID="lblAccessoryCategoryID" runat="server" Visible="false"></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                        <asp:TemplateColumn HeaderText="Code">
                                            <ItemTemplate>
                                                <asp:Label ID="lblCategoryCode" runat="server"></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                        <asp:TemplateColumn HeaderText="Accessory Color" Visible="false">
                                            <ItemTemplate>
                                                <asp:DropDownList ID="ddlAccessoryColor" runat="server" onchange="colorchange(this)">
                                                </asp:DropDownList>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                        <asp:TemplateColumn Visible="false">
                                            <ItemTemplate>
                                                <div class="color-picker-frame">
                                                    <div id="dvAccessoryColor" runat="server" class="icolor">
                                                    </div>
                                                </div>
                                            </ItemTemplate>
                                        </asp:TemplateColumn>
                                    </Columns>
                                </asp:DataGrid>
                                <!-- / -->
                                <!-- No Search Result -->
                                <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                                    <h4>Your search - <strong>
                                        <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                                    any documents.</h4>
                                </div>
                                <!-- / -->
                            </div>
                            <script type="text/javascript">
                                function colorchange(sender) {
                                    $(sender).closest('tr').find('.icolor').attr('style', 'background-color:' + $('option:selected', sender).attr('color'));
                                }
                            </script>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="ddlPattern" EventName="SelectedIndexChanged" />
                        </Triggers>
                    </asp:UpdatePanel>
                    <div class="form-actions">                        
                        <button id="btnSaveChanges" runat="server" class="btn btn-primary" type="submit"
                            data-loading-text="Saving..." onserverclick="btnSaveChanges_Click" validationgroup="valGrpVL">
                            Save Changes</button>
                        <button id="btnSaveAndCreateNew" runat="server" class="btn btn-primary" type="submit"
                            data-loading-text="Saving..." onserverclick="btnSaveAndCreateNew_Click" validationgroup="valGrpVL">
                            Save and Create New
                        </button>
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
        <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnEditJobNameID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnClientID" runat="server" Value="0" />
        <!-- Delete VL Image -->
        <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    ×</button>
                <h3>Delete Product Image</h3>
            </div>
            <div class="modal-body">
                <p>
                    Are you sure you wish to delete this Image?
                </p>
            </div>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">
                    No</button>
                <button id="btnDeleteVLImage" runat="server" class="btn btn-primary" type="submit"
                    onserverclick="btnDeleteVLImage_Click">
                    Yes</button>
            </div>
        </div>
        <!-- / -->
        <!-- Client-->
        <div id="addjobClient" class="modal fade" role="dialog" aria-hidden="true" keyboard="false">
            <asp:UpdatePanel runat="server" ID="UpdateDistributor" UpdateMode="Always">
                <ContentTemplate>
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                            ×</button>
                        <h3 id="titleClient">New Client</h3>
                    </div>
                    <div class="modal-body">
                        <!-- Validation-->
                        <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="alert alert-danger"
                            ValidationGroup="cliorjob" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                        <!-- / -->
                        <fieldset>
                            <div class="control-group">
                                <label class="control-label required">
                                    Distributor</label>
                                <div class="controls">
                                    <asp:DropDownList CssClass="input-xlarge" ID="ddlClientDistributor" runat="server" Enabled="false">
                                    </asp:DropDownList>
                                    <%--     <asp:Label ID="lblclient" runat ="server">123</asp:Label>  --%>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Client</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtNewClient" runat="server"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" CssClass="error" ValidationGroup="cliorjob"
                                        ControlToValidate="txtNewClient" Display="Dynamic" EnableClientScript="false"
                                        ErrorMessage="Client is required">
                                <img src="Content/img/icon_warning.png" title="Client is required" alt="Client is required" />
                                    </asp:RequiredFieldValidator>
                                    <asp:CustomValidator ID="cvTxtClientName" runat="server" OnServerValidate="cvTxtClientName_ServerValidate" ErrorMessage="Name is already in use" ValidationGroup="cliorjob"
                                        ControlToValidate="txtNewClient" EnableClientScript="false">
                             <img src="Content/img/icon_warning.png"  title="Name is already in use" alt="Name is already in use" />
                                    </asp:CustomValidator>
                                </div>
                            </div>
                        </fieldset>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">
                    Close</button>
                <button id="btnSaveClientorJob" runat="server" class="btn btn-primary" type="submit"
                    validationgroup="cliorjob" data-loading-text="Saving..." onserverclick="btnSaveClient_ServerClick">
                    Save</button>
            </div>
        </div>
        <!-- Job Name-->
        <div id="addjobName" class="modal fade" role="dialog" aria-hidden="true" keyboard="false">
            <asp:UpdatePanel runat="server" ID="UpdateJobName" UpdateMode="Always">
                <ContentTemplate>
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                            ×</button>
                        <h3 id="titleJobName">New Job Name</h3>
                    </div>
                    <div class="modal-body">
                        <!-- Validation-->
                        <asp:ValidationSummary ID="vsNewJobName" runat="server" CssClass="alert alert-danger"
                            ValidationGroup="newJobName" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                        <!-- / -->
                        <fieldset>
                            <div class="control-group">
                                <label class="control-label required">
                                    Client</label>
                                <div class="controls">
                                    <asp:DropDownList CssClass="input-xlarge" ID="ddlJobNameClient" runat="server" Enabled="false">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvJobNameClient" runat="server" ErrorMessage="Client is required" Display="Dynamic" ValidationGroup="newJobName"
                                        ControlToValidate="ddlJobNameClient" InitialValue="0" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Client is required" alt="Client is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Job Name</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtNewJobName" runat="server"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvNewJobName" runat="server" CssClass="error" ValidationGroup="newJobName"
                                        ControlToValidate="txtNewJobName" Display="Dynamic" EnableClientScript="false"
                                        ErrorMessage="Job Name is required">
                                <img src="Content/img/icon_warning.png" title="Job Name is required" alt="Job Name is required" />
                                    </asp:RequiredFieldValidator>
                                    <asp:CustomValidator ID="cfvJobName" runat="server" OnServerValidate="cfvJobName_ServerValidate" ErrorMessage="Name is already in use" ValidationGroup="newJobName"
                                        ControlToValidate="txtNewJobName" EnableClientScript="false">
                             <img src="Content/img/icon_warning.png"  title="Name is already in use" alt="Name is already in use" />
                                    </asp:CustomValidator>
                                </div>
                            </div>                       
                        </fieldset>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">
                    Close</button>
                <button id="btnSaveJobName" runat="server" class="btn btn-primary" type="submit"
                    validationgroup="newJobName" data-loading-text="Saving..." onserverclick="btnSaveJobName_ServerClick">
                    Save</button>
            </div>
        </div>

        <div class="modal hide fade" id="imageFoundModal" tabindex="-1" role="dialog">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                        <h4 class="modal-title">Image Found!</h4>
                    </div>
                    <div class="modal-body">
                        <% if (QueryID > 0)
                           { %>
                               <p>An image found for this product in the blackchrome server. Do want to replace current product image with this one?</p>
                           <% } %>
                       
                         <%  else%>
                          <% {%>
                               <p>An image found for this product in the blackchrome server. Do want to add this image for this product?</p> 
                           <%} %>
                        <img src="#" id="imageFoundModalImage" style="margin: 30px; max-width: 500px; max-height: 500px" alt="" />
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" id="imageFoundModalNoButton" data-dismiss="modal">No</button>
                        <button type="button" class="btn btn-primary" id="imageFoundModalYesButton" data-dismiss="modal">Yes</button>
                    </div>
                </div>
                <!-- /.modal-content -->
            </div>
            <!-- /.modal-dialog -->
        </div>
        <!-- /.modal -->
    </div>
    <!-- Page Script -->
    <script type="text/javascript">
        var PopulatePatern = ('<%=ViewState["PopulatePatern"]%>' == "True") ? true : false;
        var PopulateFabric = ('<%=ViewState["PopulateFabric"]%>' == "True") ? true : false;
        var PopulateClientOrJob = ('<%=ViewState["PopulateClientOrJob"]%>' == 'True') ? true : false;
        var PopulateJobName = ('<%=ViewState["PopulateJobName"]%>' == "True") ? true : false;
        var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
        var rbGenerate = "<%=rbGenerate.ClientID %>";
        var txtProductNumber = "<%=txtProductNumber.ClientID %>";
        var rbCustom = "<%=rbCustom.ClientID %>";
        var dvHideColums = "<%=dvHideColums.ClientID %>"
        var ddlPrinterType = "<%=ddlPrinterType.ClientID %>";
        var ddlPattern = "<%=ddlPattern.ClientID %>";
        var ddlFabric = "<%=ddlFabric.ClientID %>";
        var ddlPrinterType = "<%=ddlPrinterType.ClientID %>";
        var ddlClient = "<%=ddlClient.ClientID %>";
        var ddlDistributor = "<%=ddlDistributor.ClientID %>";
        var ddlPocketType = "<%=ddlPocketType.ClientID %>";
        var ddlResolutionProfile = "<%=ddlResolutionProfile.ClientID %>";
        //var ddlAddFabrics = "< %=ddlAddFabrics.ClientID%>";
        var ddlJobName = "<%=ddlJobName.ClientID%>";
        var txtNewClient = "<%=txtNewClient.ClientID%>";
        var txtNewJobName = "<%=txtNewJobName.ClientID%>";
        var hdnEditJobNameID = "<%=hdnEditJobNameID.ClientID%>";
        var hdnClientID = "<%=hdnClientID.ClientID%>";              
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            if (PopulatePatern) {
                window.setTimeout(function () {
                    showPopupBox('dvViewPattern');
                }, 10);
            }

            if (PopulateFabric) {
                window.setTimeout(function () {
                    showPopupBox('dvViewSpecification', ($(window).width() * 0.7));
                }, 10);
            }

            $('.idelete').click(function () {
                $('#' + hdnSelectedID)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });

            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
            function EndRequest(sender, args) {
                if (args.get_error() == undefined) {
                    BindEvents();
                }
            }

            BindEvents();

            function BindEvents() {
                $('#' + ddlPattern).select2();
                $('#' + ddlFabric).select2();
                $('#' + ddlPrinterType).select2();
                $('#' + ddlClient).select2();
                $('#' + ddlDistributor).select2();
                $('#' + ddlPocketType).select2();
                $('#' + ddlResolutionProfile).select2();
                //$('#' + ddlAddFabrics).select2();
                $('#' + ddlJobName).select2();
            }

            $('.igridview input[type=checkbox]').click(function () {
                var id = this.id;
                if (!this.checked) {
                    this.checked = true;
                }
                else {
                    $('.igridview input[type=checkbox]').each(function () {
                        if (this.id != id) {
                            this.checked = false;
                        }
                    });
                }
            });

            if (PopulateClientOrJob) {
                $('#addjobClient').modal('show');
            }

            if (PopulateJobName) {
                $('#addjobName').modal('show');
            }

            /*$('.ivlImage').click(function () {
            $('.ivlImage input[type=checkbox]').each(function () {
            $(this).prop("checked", false);
            });
            $(this).attr('checked', true);
            });*/
        });

        $("#<%=txtProductNumber.ClientID%>").keyup(function () {
            var button = $("#checkImageOnServerButton");
            $(button).text("Check Image");
            $(button).removeClass("btn-danger");
            $(button).addClass("btn-info");
            $(button).prop("disabled", false);
        });

        $("#removeServerImageIcon").click(function () {
            $("#<%=serverImagePath.ClientID%>").val("");
            $("#<%=serverImgaeHolder.ClientID%>").attr("src", "");
            $("#uploadContainer").show();
            $("#dropzone_1").show();
            $("#serverImageContainer").hide();
            <% if (QueryID > 0)
               {%>
                    $("#<%=dvVLImagePreview.ClientID%>").show();
            <% }%>

            
        });

        function checkChanged(e) {
            $('.ivlImage input[type=checkbox]').each(function () {
                $(this).prop("checked", false);
            });
            $(e).children('input[type=checkbox]').prop('checked', true)
        }

        function AddNewClient() {
            $('div.alert-danger, span.error').hide();
            $('#titleClient').text('New Client');
            $('#' + hdnClientID).val('0');
            $('#' + txtNewClient).val('');
            $('#addjobClient').modal('show');
            $('#' + hdnSelectedID).val('New');
        }

        function AddNewJobName() {
            $('div.alert-danger, span.error').hide();
            $('#addjobName').modal('show');
            $('#titleJobName').text('New Job Name');
            $('#' + txtNewJobName).val('');
            $('#' + hdnEditJobNameID).val('0');
            $('#' + hdnSelectedID).val('New');
        }

        function EditClient() {
            $('div.alert-danger, span.error').hide();
            $('#titleClient').text('Edit Client');
            $('#' + hdnClientID).val($('#' + ddlClient).val());
            $('#' + txtNewClient).val($('#' + ddlClient + ' :selected').text());
            $('#addjobClient').modal('show');
        }

        function toggleImageCheckButton() {
            var val = $("#<%=lblCheckName.ClientID%>").text();
            if (val === "Available.") {
                var str = $("#<%=txtProductNumber.ClientID%>").val();
                var pattern = new RegExp("[\\[Vv\\]\\[Ll\\]\\d{1,}.*]");
                var result = pattern.test(str);
                if (result)
                    $("#checkImageOnServerButton").show();
                else {
                    $("#checkImageOnServerButton").hide();
                }
            }
        }

        toggleImageCheckButton();

        function showImageFoundModal(imagepath) {
            $("#imageFoundModalImage").attr("src",imagepath);
            $('#imageFoundModal').modal('show');
            $("#imageFoundModalYesButton").click(function () {
                $("#<%=serverImgaeHolder.ClientID%>").attr("src", imagepath);
                $("#<%=serverImagePath.ClientID%>").val(imagepath);
                console.log($("#<%=serverImagePath.ClientID%>"));
                console.log($("#<%=serverImagePath.ClientID%>").val());
                $("#dropzone_1").hide();
                $("#uploadContainer").hide();
                $("#serverImageContainer").show();
                <% if (QueryID > 0)
                    {%>
                         $("#<%=dvVLImagePreview.ClientID%>").hide();
                    <% }%>
            });
            
        }

        $("#checkImageOnServerButton").click(function(e) {
            e.preventDefault();
            console.log("clicked");
            var target = $("#<%=txtProductNumber.ClientID%>");
            var vl = target.attr("value");
            console.log(vl);
            $(e.target).text("Checking .. please wait");
            $(e.target).prop("disabled", true);
            $.ajax(
            {
                url: "AddEditVisualLayout.aspx/CheckImageAvailable",
                type: "POST",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ vlname: vl }),
                dataType: "json",
                async: true,
                success: function (v) {
                    console.log(v);
                    var data = v.d;
                    if (data === null) {
                        $(e.target).text("No Image Available");
                        $(e.target).removeClass("btn-info");
                        $(e.target).addClass("btn-danger");
                    }
                    else {
                        $(e.target).text("Check Image");
                        $(e.target).prop("disabled", false);
                        showImageFoundModal(data);
                    }
                }
            });
        });
    </script>
    <!-- / -->
</asp:Content>
