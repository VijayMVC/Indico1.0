<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditPattern.aspx.cs" Inherits="Indico.AddEditPattern" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <button id="btnSaveChange" runat="server" class="btn btn-primary iadd pull-right"
                    data-loading-text="Saving..." validationgroup="validatePattern" onserverclick="btnSaveChanges_Click"
                    visible="false" type="submit">
                    Save Changes</button>
                <a id="btnActivateWS" runat="server" class="btn btn-link pull-right" type="submit" onserverclick="btnActivateWS_Click"></a>
                <asp:Literal ID="lblGarmentSpecStatus" runat="server"></asp:Literal>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div id="dvPageContent" runat="server" class="row-fluid">
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    ValidationGroup="validatePattern" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#collapse1">Details</a>
                    </div>
                    <div id="collapse1" class="accordion-body collapse">
                        <div class="accordion-inner">
                            <div class="control-group">
                                <div class="controls">
                                    <label class="checkbox">
                                        <asp:CheckBox ID="chbIsActive" runat="server" />
                                        Is Active
                                    </label>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Number</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtPatternNumber" runat="server"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvPatternNumber" runat="server" ErrorMessage="Pattern Number is required"
                                        ValidationGroup="validatePattern" ControlToValidate="txtPatternNumber" EnableClientScript="false">
                                            <img src="Content/img/icon_warning.png"  title="Pattern Number is required" alt="Pattern Number is required" />
                                    </asp:RequiredFieldValidator>
                                    <asp:CustomValidator ID="cfvPatternNumber" runat="server" ErrorMessage="Pattern Number already exists"
                                        EnableClientScript="false" ControlToValidate="txtPatternNumber" ValidationGroup="validatePattern"
                                        OnServerValidate="cfvPatternNumber_OnValidate">
                                            <img src="Content/img/icon_warning.png"  title="Pattern Number already exists" alt="Pattern Number already exists" />
                                    </asp:CustomValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Manual Description</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Origin Ref</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtOriginRef" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Corresponding Pattern</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtCorrespondingPattern" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Consumption</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtConsumption" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Keywords</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtKeyWords" runat="server" TextMode="MultiLine"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Special Attributes</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtSpecialAttributes" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Factory Description</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtFactoryDescription" runat="server" TextMode="MultiLine"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Print Type</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlPrintType" runat="server">
                                    </asp:DropDownList>
                                    <a id="ancAddNewPrintType" class="btn-link iadd" title="Add New Printer Type"><i
                                        class="icon-plus"></i></a>
                                    <asp:RequiredFieldValidator ID="rfvPrintType" runat="server" ErrorMessage="Print Type is required"
                                        ValidationGroup="validatePattern" ControlToValidate="ddlPrintType" InitialValue="0"
                                        EnableClientScript="false">
                        <img src="Content/img/icon_warning.png"  title="Print Type is required" alt="Print Type Set is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Production Line</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlProductionLine" runat="server">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Notes</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Marketing  Description</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtMarketingDescription" runat="server" TextMode="MultiLine"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Conversion Factor</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtConvertionFactor" runat="server" CssClass="idouble"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvConversionFactor" runat="server" ErrorMessage="Conversion Factor is required"
                                        ControlToValidate="txtConvertionFactor" EnableClientScript="false" ValidationGroup="validatePattern">
                        <img src="Content/img/icon_warning.png"  title="Conversion Factor is required" alt="Conversion Factor is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    HTS Code</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtHtsCode" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    SMV</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtSMV" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Core Range</label>
                                <div class="controls">
                                    <asp:CheckBox ID="chkCoreRange" runat="server" />
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Supplier</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlSupplier" runat="server" />
                                    <asp:RequiredFieldValidator ID="rfvSupplier" runat="server" ErrorMessage="Supplier is required"
                                        ValidationGroup="validatePattern" ControlToValidate="ddlSupplier" InitialValue="0"
                                        EnableClientScript="false">
                        <img src="Content/img/icon_warning.png"  title="Supplier is required" alt="Supplier is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#<%=collapse2.ClientID%>">Item
                            Information</a>
                    </div>
                    <div id="collapse2" runat="server" class="accordion-body collapse">
                        <div class="accordion-inner">
                            <div class="span6">
                                <div class="control-group">
                                    <label class="control-label required">
                                        Item Group</label>
                                    <div class="controls">
                                        <asp:DropDownList ID="ddlItemGroup" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlItemGroup_SelectedIndexChanged">
                                        </asp:DropDownList>
                                        <a id="ancAddNewItem" class="btn-link iadd" title="Add New Item" data-placement="bottom">
                                            <i class="icon-plus"></i></a>
                                        <asp:RequiredFieldValidator ID="rfvItemGroup" runat="server" ErrorMessage="Item Group  is required"
                                            ValidationGroup="validatePattern" ControlToValidate="ddlItemGroup" InitialValue="0"
                                            EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Item Group  is required" alt="Item Group  is required" />
                                        </asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="control-group">
                                    <label class="control-label">
                                        Item Sub Group</label>
                                    <div class="controls">
                                        <asp:DropDownList ID="ddlItemSubGroup" runat="server">
                                        </asp:DropDownList>
                                        <a id="ancAddNewItemSubCategory" class="btn-link iadd" title="Add New Item Sub-Category">
                                            <i class="icon-plus"></i></a>
                                    </div>
                                </div>
                                <div class="control-group">
                                    <label class="control-label required">
                                        Gender</label>
                                    <div class="controls">
                                        <asp:DropDownList ID="ddlGender" runat="server">
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="rfvGender" runat="server" ErrorMessage="Gender is required"
                                            ValidationGroup="validatePattern" ControlToValidate="ddlGender" InitialValue="0"
                                            EnableClientScript="false">
                                        <img src="Content/img/icon_warning.png"  title="Gender is required" alt="Gender is required" />
                                        </asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="control-group">
                                    <label class="control-label">
                                        Age Group</label>
                                    <div class="controls">
                                        <asp:DropDownList ID="ddlAgeGroup" runat="server">
                                        </asp:DropDownList>
                                        <a id="ancAddNewAgeGroup" class="btn-link iadd" title="Add New Age Group" runat="server"><i class="icon-plus"></i></a>
                                    </div>
                                </div>
                                <div class="control-group">
                                    <label class="control-label required">
                                        Size Set</label>
                                    <div class="controls">
                                        <asp:DropDownList ID="ddlSizeSet" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSizeSet_SelectedIndexChanged">
                                        </asp:DropDownList>
                                        <a id="ancAddNewSizeSet" class="btn-link iadd" title="Add New Size Set" runat="server"><i class="icon-plus"></i></a>
                                        <asp:RequiredFieldValidator ID="rfvSizeSet" runat="server" ErrorMessage="Size Set is required"
                                            ValidationGroup="validatePattern" ControlToValidate="ddlSizeSet" InitialValue="0"
                                            EnableClientScript="false">
                                        <img src="Content/img/icon_warning.png"  title="Size Set Group is required" alt="Size Set is required" />
                                        </asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="control-group">
                                    <label class="control-label">
                                        Automatic Description</label>
                                    <div class="controls">
                                        <asp:TextBox ID="txtNickName" runat="server" Enabled="false" EnableViewState="true"
                                            TextMode="MultiLine"></asp:TextBox>
                                        <a id="btnCopytoClipboard" class="btn-link iclipboard" type="button" title="Copy"><i
                                            class="icon-copy"></i></a>
                                    </div>
                                </div>
                                <div class="control-group">
                                    <label class="control-label ">
                                        Unit</label>
                                    <div class="controls">
                                        <asp:DropDownList ID="ddlUnits" runat="server">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                            <div id="dvItemAttributes" runat="server" class="span6">
                                <h5 class="iattribute-title">Item Attributes</h5>
                                <asp:Repeater ID="rptItemAttribute" runat="server" OnItemDataBound="rptrItemAtrribute_OnItemDataBound">
                                    <ItemTemplate>
                                        <div class="control-group">
                                            <label class="control-label ">
                                                <asp:Literal ID="litItemAtributeName" runat="server" />
                                            </label>
                                            <div class="controls">
                                                <asp:DropDownList ID="ddlSubAttributes" runat="server" CssClass="subAttributes">
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#collapse3">Categories</a>
                    </div>
                    <div id="collapse3" class="accordion-body collapse">
                        <div class="accordion-inner">
                            <div class="control-group">
                                <label class="control-label required">
                                    Core Category</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlCoreCategory" runat="server">
                                    </asp:DropDownList>
                                    <a id="ancAddNewCoreCategory" class="btn-link iadd" title="Add New Core Category"
                                        data-placement="bottom"><i class="icon-plus"></i></a>
                                    <asp:RequiredFieldValidator ID="rfvCoreCategory" InitialValue="0" runat="server"
                                        ErrorMessage="Core Category  is required" ControlToValidate="ddlCoreCategory"
                                        ValidationGroup="validatePattern" EnableClientScript="false">
                                            <img src="Content/img/icon_warning.png"  title="Core Category Group is required" alt="Core Category is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <asp:CheckBoxList ID="lstOtherCategories" runat="server" CssClass="checkbox-columns vertical"
                                RepeatDirection="Vertical">
                            </asp:CheckBoxList>
                        </div>
                    </div>
                </div>
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#iContentPlaceHolder_collapse4">Photo Images</a>
                    </div>
                    <div id="collapse4" class="accordion-body collapse" runat="server">
                        <div class="accordion-inner">
                            <p class="help-block" style="margin-bottom: 10px;">
                                <span class="label label-info">Hint:</span> Please ensure the photo image is at least 1000 pixels in width x 1000 pixels in height
                            </p>
                            <ol class="inlineupload" style="">
                                <li class="text-center">
                                    <label class="file_preview">
                                        <asp:Image ID="uploadPhotoImageOne" runat="server" CssClass="img-polaroid" />
                                    </label>
                                    <table id="uploadtable_2" class="file_upload_files" multirow="false" setdefault="true">
                                        <tr id="tableRowfileUpload">
                                            <td class="file_preview"></td>
                                            <td>
                                                <b>
                                                    <asp:Literal ID="litFileInformation" runat="server"></asp:Literal></b>
                                            </td>
                                            <td class="file_name">
                                                <asp:Literal ID="litfileName" runat="server"></asp:Literal>
                                            </td>
                                            <td>
                                                <asp:Literal ID="litfileType" runat="server"></asp:Literal>
                                            </td>
                                            <td id="filesize" class="file_size" runat="server">
                                                <asp:Literal ID="litfileSize" runat="server"></asp:Literal>
                                            </td>
                                            <td>
                                                <asp:HyperLink ID="linkDeleteImageOne" data-toggle="modal" runat="server" CssClass="btn-link idelete ione"
                                                    ToolTip="Delete Photo Image One" NavigateUrl="#requestDeleteTemplateImage" Visible="false"><i class="icon-trash"></i></asp:HyperLink>
                                            </td>
                                        </tr>
                                    </table>

                                    <input id="hdnPhotoImageOne" runat="server" name="hdnUploadFiles" type="hidden" value="0" />
                                    <div id="dvUploader_1" runat="server" class="file_upload_controller">
                                        <div id="dropzone_2" class="fileupload preview single hide-dropzone setdefault" maxfilesize="1024">
                                            <input id="hdnIsValid_2" type="hidden" value="1" />
                                            <input id="file_2" name="file_2" type="file" />
                                            <button id="btnup_2" type="submit">
                                                Upload
                                            </button>
                                            <div id="divup_2">
                                                Drag file here or click to upload
                                            </div>
                                            <p class="extra-helper">
                                                <strong>Hint:</strong>Please ensure the photo image is at least 1000 pixels in width x 1000 pixels in height
                                            </p>
                                        </div>
                                    </div>

                                </li>
                                <li>
                                    <label class="file_preview">
                                        <asp:Image ID="uploadPhotoImageTwo" runat="server" CssClass="img-polaroid" />
                                    </label>
                                    <table id="uploadtable_3" class="file_upload_files" multirow="false" setdefault="true">
                                        <tr id="tableRowfileUpload_2">
                                            <td class="file_preview"></td>
                                            <td>
                                                <b>
                                                    <asp:Literal ID="litFileInformation_2" runat="server"></asp:Literal></b>
                                            </td>
                                            <td class="file_name">
                                                <asp:Literal ID="litfileName_2" runat="server"></asp:Literal>
                                            </td>
                                            <td>
                                                <asp:Literal ID="litfileType_2" runat="server"></asp:Literal>
                                            </td>
                                            <td id="filesize_2" class="file_size" runat="server">
                                                <asp:Literal ID="litfileSize_2" runat="server"></asp:Literal>
                                            </td>
                                            <td>
                                                <asp:HyperLink ID="linkDeleteImageTwo" data-toggle="modal" runat="server" CssClass="btn-link idelete itwo"
                                                    ToolTip="Delete Photo Image Two" NavigateUrl="#requestDeleteTemplateImage" Visible="false"><i class="icon-trash"></i></asp:HyperLink>
                                            </td>
                                        </tr>
                                    </table>
                                    <input id="hdnPhotoImageTwo" runat="server" name="hdnUploadFiles" type="hidden" value="0" />
                                    <div id="dvUploader_2" runat="server" class="file_upload_controller">
                                        <div id="dropzone_3" class="fileupload preview single hide-dropzone setdefault" maxfilesize="1024">
                                            <input id="hdnIsValid_3" type="hidden" value="1" />
                                            <input id="file_3" name="file_2" type="file" />
                                            <button id="btnup_3" type="submit">
                                                Upload
                                            </button>
                                            <div id="divup_3">
                                                Drag file here or click to upload
                                            </div>
                                            <p class="extra-helper">
                                                <strong>Hint:</strong> You can drag & drop files from your desktop on this webpage
                                                with Google Chrome, Mozilla Firefox and Apple Safari.
                                            </p>
                                        </div>
                                    </div>
                                </li>
                                <li>
                                    <label class="file_preview">
                                        <asp:Image ID="uploadPhotoImageThree" runat="server" CssClass="img-polaroid" />
                                    </label>
                                    <table id="uploadtable_4" class="file_upload_files" multirow="false" setdefault="true">
                                        <tr id="tableRowfileUpload_3">
                                            <td class="file_preview"></td>
                                            <td>
                                                <asp:Literal ID="litFileInformation_3" runat="server"></asp:Literal>
                                            </td>
                                            <td class="file_name">
                                                <asp:Literal ID="litfileName_3" runat="server"></asp:Literal>
                                            </td>
                                            <td>
                                                <asp:Literal ID="litfileType_3" runat="server"></asp:Literal>
                                            </td>
                                            <td id="filesize_3" class="file_size" runat="server">
                                                <asp:Literal ID="litfileSize_3" runat="server"></asp:Literal>
                                            </td>
                                            <td>
                                                <asp:HyperLink ID="linkDeleteImageThree" data-toggle="modal" runat="server" CssClass="btn-link idelete ithree" ToolTip="Delete Photo Image Three" NavigateUrl="#requestDeleteTemplateImage"
                                                    Visible="false"><i class="icon-trash"></i></asp:HyperLink>
                                            </td>
                                        </tr>
                                    </table>
                                    <input id="hdnPhotoImageThree" runat="server" name="hdnUploadFiles" type="hidden"
                                        value="0" />
                                    <div id="dvUploader_3" runat="server" class="file_upload_controller">
                                        <div id="dropzone_4" class="fileupload preview single hide-dropzone setdefault" maxfilesize="1024">
                                            <input id="hdnIsValid_4" type="hidden" value="1" />
                                            <input id="file_4" name="file_2" type="file" />
                                            <button id="btnup_4" type="submit">
                                                Upload
                                            </button>
                                            <div id="divup_4">
                                                Drag file here or click to upload
                                            </div>
                                            <p class="extra-helper">
                                                <strong>Hint:</strong> You can drag & drop files from your desktop on this webpage
                                                with Google Chrome, Mozilla Firefox and Apple Safari.
                                            </p>
                                        </div>
                                    </div>
                                </li>
                            </ol>
                        </div>
                    </div>
                </div>
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#<%=collapse5.ClientID%>">Accessories</a>
                    </div>
                    <div id="collapse5" runat="server" class="accordion-body collapse">
                        <div class="accordion-inner">
                            <div class="control-group">
                                <div class="controls">
                                    <button id="btnPatternAccessory" runat="server" class="btn btn-success pull-right" visible="false"
                                        type="button" onserverclick="btnAddAccessory_Click">
                                        Add Pattern Accessory
                                    </button>
                                </div>
                            </div>
                            <div id="dvPatternAccessory" runat="server" visible="false">
                                <ul class="itoggler-ul">
                                    <asp:DataGrid ID="dgPatternAccessories" runat="server" CssClass="table" AllowCustomPaging="False"
                                        AutoGenerateColumns="false" GridLines="None" PageSize="10" OnItemDataBound="dgPatternAccessories_ItemDataBound"
                                        OnItemCommand="dgPatternAccessories_onItemCommand">
                                        <HeaderStyle CssClass="header" />
                                        <Columns>
                                            <asp:TemplateColumn HeaderText="Name">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblPatternAccessory" runat="server" Text=""></asp:Label>
                                                    <asp:HiddenField ID="hdnPatternPatternAccessoryID" runat="server" Value="0" />
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Category">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblPatternAccessoryCategory" runat="server" Text=""></asp:Label>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <%-- <asp:TemplateColumn HeaderText="Colour" ItemStyle-Width="24%">
                                    <ItemTemplate>
                                        <asp:Label ID="lblPatternAccessoryColor" runat="server" Text=""></asp:Label>
                                        <li>
                                            <div id="dvPatternAccessoryColor" runat="server">
                                            </div>
                                        </li>
                                    </ItemTemplate>
                                </asp:TemplateColumn>--%>
                                            <asp:TemplateColumn HeaderText="Code">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblPatternAccessoryCode" runat="server" Text=""></asp:Label>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="" Visible="false">
                                                <ItemTemplate>
                                                    <div class="btn-group pull-right">
                                                        <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                            <i class="icon-cog"></i><span class="caret"></span></a>
                                                        <ul class="dropdown-menu pull-right">
                                                            <li>
                                                                <asp:LinkButton CommandName="Delete" ID="linkDelete" runat="server" CssClass="btn-link idelete"
                                                                    ToolTip="Delete "><i class="icon-trash"></i>Delete</asp:LinkButton>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>
                                        </Columns>
                                    </asp:DataGrid>
                                </ul>
                                <!-- / -->
                            </div>
                            <!-- Empty Content -->
                            <div id="dvEmptyContentAccessory" runat="server" class="alert alert-info">
                                <h4>There are no Accessories added to this Pattern.
                                </h4>
                                <p>
                                    You can add many Accessories to this Pattern.
                                </p>
                            </div>
                            <!-- / -->
                        </div>
                    </div>
                </div>
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#iContentPlaceHolder_collapse6">Garment Measurement
                            Image</a>
                    </div>
                    <div id="collapse6" class="accordion-body collapse" runat="server">
                        <div class="accordion-inner">
                            <a class="pull-left" onmouseover="onhelphover(event,'templateHelpDiv')" onmouseout="onhelphover(event,'templateHelpDiv')" id="templateInfo">
                                <img src="/Content/img/info-icon.png" style="width: 25px; height: 25px;"></a>
                            <div class="ihero well " style="width: 500px; display: none; height: 350px; overflow: hidden" id="templateHelpDiv">
                                <h4>example measurement image: </h4>
                                <img src="Content/img/examples/example-patternTemplateImage.jpg" width="" />
                            </div>
                            <fieldset id="fsTemplateImages" runat="server">
                                <div id="dvPatternTemplateUpload" ishide="true" runat="server">
                                    <div class="control-group">
                                        <div class="controls">
                                            <table id="uploadtable_1" class="file_upload_files" setdefault="false" ishide="true">
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
                                                                <asp:HyperLink ID="linkDelete" Visible="True" runat="server" CssClass="btn-link idelete" ToolTip="Delete Image"><i class="icon-trash"></i></asp:HyperLink>
                                                            </td>
                                                        </tr>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </table>
                                            <input id="hdnUploadFiles" runat="server" name="hdnUploadFiles" type="hidden" value="" />
                                        </div>
                                        <div class="control-group">
                                            <label class="control-label">
                                            </label>
                                            <div id="liDropZone" runat="server">
                                                <div id="dropzone_1" class="fileupload preview single hide-dropzone">
                                                    <input id="file_1" name="file_1" type="file" />
                                                    <button id="btnup_1" type="submit">
                                                        Upload</button>
                                                    <div id="divup_1">
                                                        Drag file here or click to upload
                                                    </div>
                                                </div>
                                                <%-- <asp:CustomValidator ID="cvTemplateImage" runat="server" ErrorMessage="Template Image is required."
                                                        EnableClientScript="false" Display="Dynamic" OnServerValidate="cvTemplateImage_OnServerValidate">                            
                                                            <img src="Content/img/icon_warning.png"  title="Template Image is required." alt="Template Image is required." />
                                                    </asp:CustomValidator>--%>
                                            </div>
                                        </div>
                                        <div>
                                            <label class="control-label ">
                                            </label>
                                            <p class="help-block">
                                                <span class="label label-info">Hint:</span> Please ensure the photo image is at least 1000 pixels in width x 1000 pixels in height
                                                <!--[if IE]>
                            <strong>Microsoft Explorer has currently no support for Drag & Drop or multiple file selection.</strong>
                            <![endif]-->
                                            </p>

                                        </div>
                                    </div>
                                </div>
                            </fieldset>
                            <!-- Pattern Templates -->
                            <div id="dvEmptyContentPatternTemplates" runat="server" class="alert alert-info">
                                <h4>No template images found.
                                </h4>
                            </div>
                            <div id="dvPatternTemplates" runat="server" class="text-center">
                                <ul class="thumbnails">
                                    <li class="span6 inlineupload">
                                        <div class="file_preview">
                                            <asp:Image ID="imgTemplateImage" runat="server" ImageUrl="" Visible="False" class="img-polaroid" />
                                            <div class="caption">
                                                <asp:HyperLink ID="linkDeletePatternTemplateImage" runat="server" CssClass="btn-link idelete igarmentimage"
                                                    ToolTip="Delete Garment Measurement Image"><i class="icon-trash"></i></asp:HyperLink>
                                            </div>
                                        </div>
                                    </li>
                                </ul>
                                <div id="dvPagingFooter" class="paginator" runat="server" visible="false">
                                    <div class="paginatorRight">
                                        <!--<span class="displaying-num">Displaying 1-10 of <span id="spFooterTotal" runat="server">
                            </span></span>-->
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
                        </div>
                    </div>
                </div>
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#collapse7">Garment Specification</a>
                    </div>
                    <div id="collapse7" class="accordion-body collapse">
                        <div class="accordion-inner">
                            <h4>Size Guide</h4>
                            <a class="pull-left" onmouseover="onhelphover(event,'compressionHelpDiv')" onmouseout="onhelphover(event,'compressionHelpDiv')">
                                <img src="/Content/img/info-icon.png" style="width: 25px; height: 25px;"></a>
                            <div class="well" style="width: 500px; display: none; height: 350px;" id="compressionHelpDiv">
                                <h4>Example Size Guide: </h4>
                                <img src="Content/img/examples/example-pattern-compressionImage.JPG" width="" />
                            </div>
                            <div class="control-group">
                                <div class="controls">
                                    <label class="checkbox">
                                        <asp:CheckBox ID="chkDisplayCompressionImage" runat="server" />
                                        &nbsp; Display Size Guide in Blackhrome
                                    </label>
                                </div>
                            </div>

                            <div class="control-group">
                                <div class="controls">
                                    <label class="checkbox">
                                        <asp:Image ID="imgCompression" runat="server" CssClass="avatar128" />
                                    </label>
                                    <table id="uploadtable_5" class="file_upload_files" multirow="false" setdefault="true">
                                        <tr id="profilePictureRow" runat="server">
                                        </tr>
                                    </table>
                                    <input id="hdnCompressionImage" runat="server" name="hdnCompressionImage" type="hidden"
                                        value="" />
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Size Guide</label>
                                <div class="controls">
                                    <div id="dropzone_5" class="fileupload preview single setdefault">
                                        <input id="file_5" name="file_5" type="file" />
                                        <button id="btnup_5" type="submit">
                                            Upload</button>
                                        <div id="divup_5">
                                            Drag photo here or click to upload
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                </label>
                                <div class="controls">
                                    <p class="extra-helper">
                                        <span class="label label-info">Hint:</span> You can upload .JPG, .PNG, or .GIF type image.
                                    </p>
                                </div>
                            </div>

                            <div id="dvEmptyContentGarmentSpec" runat="server" class="alert alert-info">
                                <h4>Garment Specification is currently not available.
                                </h4>
                                <p id="paraSpecError" runat="server">
                                    To generate the garment specification, you have to select "Item" and "Size set"
                                </p>
                            </div>
                            <hr />
                            <h4>Garment specification</h4>
                            <!-- / -->
                            <div id="dvSpecGrd" runat="server" visible="false">
                                <ol class="ioderlist-table">
                                    <li class="idata-row">
                                        <ul>
                                            <li class="icell-header small">Key</li>
                                            <li class="icell-header exlarge">Location</li>
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
                                                        <asp:CheckBox ID="chkIsSend" runat="server" />
                                                        <asp:Literal ID="litCellHeaderKey" runat="server"></asp:Literal>
                                                    </li>
                                                    <li class="icell-header exlarge">
                                                        <asp:Literal ID="litCellHeaderML" runat="server"></asp:Literal>
                                                    </li>
                                                    <asp:Repeater ID="rptSpecSizeQty" runat="server" OnItemDataBound="rptSpecSizeQty_ItemDataBound">
                                                        <ItemTemplate>
                                                            <li class="icell-data">
                                                                <asp:TextBox ID="txtQty" runat="server" CssClass="idouble"></asp:TextBox>
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
                    </div>
                </div>
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#collapse8">Pattern History</a>
                    </div>
                    <div id="collapse8" class="accordion-body collapse">
                        <div class="accordion-inner">
                            <asp:DataGrid ID="dgPatternHistory" runat="server" CssClass="table" AllowCustomPaging="False"
                                AllowPaging="false" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                                PageSize="10" OnItemDataBound="dgPatternHistory_ItemDataBound">
                                <HeaderStyle CssClass="header" />
                                <Columns>
                                    <asp:TemplateColumn HeaderText="Pattern">
                                        <ItemTemplate>
                                            <asp:Literal ID="litPattern" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Modifier">
                                        <ItemTemplate>
                                            <asp:Literal ID="litModifier" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Modified Time / Date ">
                                        <ItemTemplate>
                                            <asp:Literal ID="litModifiedDate" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Meassage">
                                        <ItemTemplate>
                                            <asp:Literal ID="litMeassage" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                </Columns>
                            </asp:DataGrid>
                            <div id="dvNoteEmptyContentPHistory" runat="server" class="alert alert-info">
                                <h4>No Pattern History
                                </h4>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="form-actions">
                    <button id="btnSaveChanges" runat="server" class="btn btn-primary" text="" validationgroup="validatePattern"
                        data-loading-text="Saving..." onserverclick="btnSaveChanges_Click" type="submit">
                        Save Changes</button>
                    <button id="btnClose" runat="server" class="btn btn-default" type="submit" causesvalidation="false" onserverclick="btnClose_ServerClick">
                        Cancel                                       
                    </button>
                </div>
                <!-- / -->
            </div>
            <!-- / -->
        </div>
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnAddNew" runat="server" Value="0" />
    <asp:HiddenField ID="hdnSelected" runat="server" Value="0" />
    <asp:HiddenField ID="hdnPhotoImageIDOne" runat="server" Value="0" />
    <asp:HiddenField ID="hdnPhotoImageIDTwo" runat="server" Value="0" />
    <asp:HiddenField ID="hdnPhotoImageIDThree" runat="server" Value="0" />
    <asp:HiddenField ID="hdnNickName" runat="server" />
    <asp:HiddenField ID="hdnGarmentImage" runat="server" />
    <asp:HiddenField ID="hdnChangeGramentSpec" runat="server" />
    <!-- Add Pattern Accessory -->
    <div id="requestAddEditAccessory" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblPopupHeaderTextAccessory" runat="server" Text="Add Pattern Accessory"></asp:Label></h3>
        </div>
        <!-- / -->
        <!--Popup Content-->
        <div class="modal-body">
            <!-- Page Validation -->
            <asp:ValidationSummary ID="validationSummaryAddEditAccessory" runat="server" CssClass="alert alert-danger"
                ValidationGroup="ValidationAccessory" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <fieldset>
                <div class="control-group">
                    <label class="control-label required">
                        Category
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlPatternAccessoryCategory" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlPatternAccessoryCategory_SelectedIndexChanged">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvPatternAccessory" runat="server" ErrorMessage="Pattern Accessory Category is required"
                            ControlToValidate="ddlPatternAccessory" InitialValue="0" EnableClientScript="false"
                            ValidationGroup="ValidationAccessory">
                        <img src="Content/img/icon_warning.png" class="ierror" title="Pattern Accessory Category is required" alt="Pattern Accessory Category is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label">
                        Accessory
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlPatternAccessory" runat="server" Enabled="false">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvPatternAccessoryCategory" runat="server" ErrorMessage="Pattern Accessory is required"
                            ControlToValidate="ddlPatternAccessoryCategory" InitialValue="0" EnableClientScript="false"
                            ValidationGroup="ValidationAccessory">
                        <img src="Content/img/icon_warning.png" class="ierror" title="Pattern Accessory is required" alt="Pattern Accessory is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
            </fieldset>
        </div>
        <!-- / -->
        <!-- Popup Footer -->
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnAddPatternAccessory" runat="server" class="btn btn-primary" validationgroup="ValidationAccessory"
                data-loading-text="Adding..." onserverclick="btnAddPatternAccessory_Click" type="submit">
                Add
            </button>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <!-- Add New Item -->
    <div id="requestAddEdit" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblPopupHeaderText" runat="server"></asp:Label></h3>
        </div>
        <!-- / -->
        <!-- Popup Content -->
        <div class="modal-body">
            <!-- Popup Validation -->
            <asp:ValidationSummary ID="validationSummaryAddEdit" runat="server" CssClass="alert alert-danger"
                DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"
                ValidationGroup="vgNewItem"></asp:ValidationSummary>
            <!-- / -->
            <fieldset>
                <div id="liItem" class="control-group">
                    <label class="control-label required">
                        Item</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlItem" runat="server">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvItem" runat="server" ControlToValidate="ddlItem"
                            InitialValue="0" Display="Dynamic" EnableClientScript="false" ErrorMessage="Item is required"
                            ValidationGroup="vgNewItem">
                                <img src="Content/img/icon_warning.png" class="ierror" title="Item is required" alt="Item is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div id="liName" class="control-group">
                    <label class="control-label required">
                        Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtNewName" runat="server" MaxLength="128"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvItemName" runat="server" ControlToValidate="txtNewName"
                            EnableClientScript="false" ErrorMessage="Name is required" ValidationGroup="vgNewItem">
                                <img src="Content/img/icon_warning.png" class="ierror" title="Name is required" alt="Name is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div id="liDescription" lass="control-group">
                    <label class="control-label">
                        Description</label>
                    <div class="controls">
                        <asp:TextBox ID="txtNewDescription" runat="server" CssClass="topic_d" MaxLength="255"
                            TextMode="MultiLine" Rows="2"></asp:TextBox>
                    </div>
                </div>
            </fieldset>
        </div>
        <!-- / -->
        <!-- Popup Footer -->
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveNew" runat="server" class="btn btn-primary" onserverclick="btnSaveNew_Click"
                data-loading-text="Saving..." type="submit" validationgroup="vgNewItem">
                Save Changes</button>
        </div>
        <!-- / -->
    </div>
    <!--/-->
    <!-- Delete Pattern Accessory -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Pattern Accessory</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Pattern Accessory?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" onserverclick="btnDelete_Click"
                data-loading-text="Deleting..." type="submit">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Delete Template Image -->
    <div id="requestDeleteTemplateImage" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Photo Image</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Photo Image?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDeleteTmpImg" runat="server" class="btn btn-primary" text="" onserverclick="btnDeleteTmpImg_Click"
                type="submit">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <div id="dvDeleteGarmentmeasurementImage" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Garment Measurement Image</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Garment Measurement Image?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDeleteGarmentMeasurement" runat="server" class="btn btn-primary" onserverclick="btnDeleteGarmentMeasurement_OnClick"
                type="submit">
                Yes</button>
        </div>
    </div>
    <!-- Delete Size Chart Value -->
    <div id="requestSizeChart" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Size Chart Data</h3>
        </div>
        <div class="modal-body">
            <p>
                Existing Size Chart data will be deleted from the Pattern when change the Size Set.
                Do you want to continue?
            </p>
        </div>
        <div class="modal-footer">
            <button id="btnNo" runat="server" class="btn" onserverclick="btnNo_Click"
                type="submit">
                No</button>
            <button id="btnDeleteSizeset" runat="server" class="btn btn-primary" onserverclick="btnDeleteSizeset_Click"
                type="submit">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <script type="text/javascript">
        var PopulateAccessoryUI = ('<%=ViewState["PopulateAccessoryUI"]%>' == 'True') ? true : false;
        var PopulateNickName = ('<%=ViewState["PopulateNickName"]%>' == 'True') ? true : false;
        var titleText = '<%=ViewState["titleText"]%>';
        var btnAddPatternAccessory = '<%=btnAddPatternAccessory.ClientID %>';
        var ddlPatternAccessory = '<%=ddlPatternAccessory.ClientID %>';
        var ddlPatternAccessoryCategory = '<%=ddlPatternAccessoryCategory.ClientID %>';
        var dgPatternAccessories = '<%=dgPatternAccessories.ClientID %>';
        var hdnAddNew = '<%=hdnAddNew.ClientID %>';
        var hdnSelected = '<%=hdnSelected.ClientID %>';
        var hdnPhotoImageIDOne = '<%=hdnPhotoImageIDOne.ClientID %>';
        var hdnPhotoImageIDTwo = '<%=hdnPhotoImageIDTwo.ClientID %>';
        var hdnPhotoImageIDThree = '<%=hdnPhotoImageIDThree.ClientID %>';
        var isPopulate = ('<%=ViewState["isPopulate"]%>' == 'True') ? true : false;
        var ddlItemSubGroup = '<%=ddlItemSubGroup.ClientID %>';
        var ddlGender = '<%=ddlGender.ClientID %>';
        var ddlAgeGroup = '<%=ddlAgeGroup.ClientID %>';
        var txtNickName = '<%=txtNickName.ClientID %>';
        var hdnNickName = '<%=hdnNickName.ClientID %>';
        var PopulateSizeChart = ('<%=ViewState["PopulateSizeChart"]%>' == 'True') ? true : false;
        var linkDeletePatternTemplateImage = '<%=linkDeletePatternTemplateImage.ClientID %>';
        var hdnGarmentImage = '<%=hdnGarmentImage.ClientID %>';
        var hdnChangeGramentSpec = '<%=hdnChangeGramentSpec.ClientID %>';
        var ancAddNewSizeSet = '<%=ancAddNewSizeSet.ClientID %>';
        var ancAddNewAgeGroup = '<%=ancAddNewAgeGroup.ClientID %>';          
    </script>
    <script type="text/javascript">
        function onhelphover(e, divid) {

            var left = (e.clientX + 25) + "px";
            var top = (e.clientY + 25) + "px";

            var div = document.getElementById(divid);

            div.style.left = left;
            div.style.top = top;

            $("#" + divid).toggle();
            return false;
        }
        //$("#templateInfo").popover({
        //    placement: 'bottom', //placement of the popover. also can use top, bottom, left or right
        //    title: '<div style="text-align:center; color:red; text-decoration:underline; font-size:14px;"> Muah ha ha</div>', //this is the top title bar of the popover. add some basic css
        //    html: 'true', //needed to show html of course
        //    content: '<div id="popOverBox"><img src="http://www.hd-report.com/wp-content/uploads/2008/08/mr-evil.jpg" width="251" height="201" /></div>' //this is the content of the html box. add the image here or anything you want really.
        //});
        $('#<%=btnSaveChanges.ClientID%>').click(function () {
            if (($('#hdnIsValid_2').val() == '0') || ($('#hdnIsValid_3').val() == '0') || ($('#hdnIsValid_4').val() == '0')) {
                $(this).addClass('hideOverly');
                return false;
            }
            else {
                $(this).removeClass('hideOverly');
            }
        });

        $('#' + linkDeletePatternTemplateImage).click(function () {
            $('#' + hdnGarmentImage).val($(this).attr('tempimgid'));
            $('#dvDeleteGarmentmeasurementImage').modal('show');
        });

        $(document).ready(function () {
            //var leftmargin = (($(window).width() - (422 * 3)) / 2);
            //$('.inlineupload').css('margin-left', leftmargin);

            if (PopulateSizeChart) {
                $('#requestSizeChart').modal('show');
            }

            $('.idouble').keypress(function () {
                $('#' + hdnChangeGramentSpec).val('change');
            });


        });

        isPatternTemplate();

        // Generate NickName --------------------
        /*('.generate-nikname').change(function (e) {
        var Name = '';
        if ($('#' + ddlItemSubGroup).val() != '0') {
        Name = $('#' + ddlItemSubGroup).find(":selected").text();
        }
        if ($('#' + ddlGender).val() != '0') {
        Name += ' ' + $('#' + ddlGender).find(":selected").text();
        }
        if ($('#' + ddlAgeGroup).val() != '0') {
        Name += ' ' + $('#' + ddlAgeGroup).find(":selected").text();
        }
        if ($('#' + ddlItemAttribute).val() != '0') {
        Name += ' ' + $('#' + ddlItemAttribute).find(":selected").text();
        }
        if (Name != '') {
        $('#btnCopytoClipboard').removeAttr("disabled");
        $('#' + txtNickName)[0].value += ' ' + Name;
        }
        });*/

        if (PopulateNickName) {
            GenerateNickName();
        }

        $('.subAttributes').change(function () {
            GenerateNickName();
        });

        $('#' + ddlItemSubGroup).change(function () {
            GenerateNickName();
        });

        $('#' + ddlGender).change(function () {
            GenerateNickName();
        });

        $('#' + ddlAgeGroup).change(function () {
            GenerateNickName();
        });

        /*$('#' + ddlItemAttribute).change(function () {
        GenerateNickName(); 
        });*/

        function GenerateNickName(e) {
            var Name = '';
            if ($('#' + ddlItemSubGroup).val() != '0') {
                Name = $('#' + ddlItemSubGroup).find(":selected").text();
            }
            if ($('#' + ddlGender).val() != '0') {
                Name += ' ' + $('#' + ddlGender).find(":selected").text();
            }
            if ($('#' + ddlAgeGroup).val() != '0') {
                Name += ' ' + $('#' + ddlAgeGroup).find(":selected").text()
            }

            if ($('.subAttributes').val() != undefined) {
                var selectedItem = '';
                $('.subAttributes').each(function () {
                    if ($(this).attr("selected", "selected")) {
                        selectedItem += ' ' + $(this).find(":selected").text().split('Select Sub Attribute');
                        selectedItem = selectedItem.replace(',', '');
                    }
                });
                Name += ' ' + selectedItem;
            }

            //selectedItem = '';
            /*if ($('#' + ddlItemAttribute).val() != '0') {
            Name += ' ' + $('#' + ddlItemAttribute).find(":selected").text();
            }*/
            if (Name != '') {
                $('#btnCopytoClipboard').removeAttr("disabled");
                $('#' + txtNickName)[0].value = Name;
                $('#' + hdnNickName).val(Name);
            }
        }


        $('#btnCopytoClipboard').click(function () {
            window.prompt("Copy to clipboard: Ctrl+C, Enter", $('#' + hdnNickName).val());
        });

        ///--------------------------------------------

        if (isPopulate) {
            window.setTimeout(function () {
                switch ($('#' + hdnSelected)[0].value) {
                    case 'ancAddNewItem':
                        loadNew('Item', true, false, false, 'New Item');
                        break;
                    case 'ancAddNewItemAttribute':
                        loadNew('ItemAttribute', false, false, false, 'New Item Attribute');
                        break;

                    case 'ancAddNewItemSubCategory':
                        loadNew('ItemSubCategory', false, false, false, 'New Item Sub-Category');
                        break;
                    case 'ancAddNewGender':
                        loadNew('Gender', true, true, false, 'New Gender');
                        break;
                    case 'ancAddNewAgeGroup':
                        loadNew('AgeGroup', true, false, false, 'New Age Group');
                        break;
                    case 'ancAddNewSizeSet':
                        loadNew('SizeSet', true, false, false, 'New Size Set');
                        break;
                    case 'ancAddNewCoreCategory':
                        loadNew('CoreCategory', true, false, false, 'New Core Category');
                        break;
                    case 'ancAddNewPrintType':
                        loadNew('PrintType', true, false, false, 'New Print Type');
                        break;
                    default:
                        break;
                }
            }, 20);
        }

        /*$('.iaccessories').click(function () {
        $('#' + hdnSelected)[0].value = $(this).attr('qid');
        //$('#requestDelete').modal('show');            
        });*/

        $('#ancAddNewItem').click(function () {
            $('#' + hdnSelected)[0].value = 'ancAddNewItem';
            loadNew('Item', true, false, true, 'New Item');
        });

        $('#ancAddNewItemAttribute').click(function () {
            $('#' + hdnSelected)[0].value = 'ancAddNewItemAttribute';
            loadNew('ItemAttribute', false, false, true, 'New Item Attribute');
        });

        $('#ancAddNewItemSubCategory').click(function () {
            $('#' + hdnSelected)[0].value = 'ancAddNewItemSubCategory';
            loadNew('ItemSubCategory', false, false, true, 'New Item Sub-Category');
        });

        $('#ancAddNewGender').click(function () {
            $('#' + hdnSelected)[0].value = 'ancAddNewGender';
            loadNew('Gender', true, true, true, true, 'New Gender');
        });

        $('#' + ancAddNewAgeGroup).click(function () {
            $('#' + hdnSelected)[0].value = 'ancAddNewAgeGroup';
            loadNew('AgeGroup', true, false, true, 'New Age Group');
        });

        $('#' + ancAddNewSizeSet).click(function () {
            $('#' + hdnSelected)[0].value = 'ancAddNewSizeSet';
            loadNew('SizeSet', true, false, true, 'New Size Set');
        });

        $('#ancAddNewCoreCategory').click(function () {
            $('#' + hdnSelected)[0].value = 'ancAddNewCoreCategory';
            loadNew('CoreCategory', true, false, true, 'New Core Category');
        });

        $('#ancAddNewPrintType').click(function () {
            $('#' + hdnSelected)[0].value = 'ancAddNewPrintType';
            $('option:selected', '#' + ddlPatternAccessory).remove();
            loadNew('PrintType', true, false, true, 'New Print Type');
        });

        $('#btnPatternAccessory').click(function () {
            resetFieldsDefault('requestAddEditAccessory');
            $('div.ivalidator,img.aierror,span.error').hide();
            PopulateAccessory();
        });


        if (PopulateAccessoryUI) {
            window.setTimeout(function () {
                PopulateAccessory();
            }, 10);
        }

        $('.ione').click(function () {
            $('#' + hdnSelected)[0].value = $('#' + hdnPhotoImageIDOne).val();
        });

        $('.itwo').click(function () {
            $('#' + hdnSelected)[0].value = $('#' + hdnPhotoImageIDTwo).val();
        });

        $('.ithree').click(function () {
            $('#' + hdnSelected)[0].value = $('#' + hdnPhotoImageIDThree).val();
        });

        function loadNew(newName, isHideItemDropdown, isHideDescription, isNew, titleText) {
            $('#' + hdnAddNew)[0].value = newName;

            if (isHideItemDropdown) {
                $('#liItem').hide();
            }
            else {
                $('#liItem').show();
            }
            if (isHideDescription) {
                $('#liDescription').hide();
            }
            else {
                $('#liDescription').show();
            }
            if (isNew) {
                isPopulate = false;
                if (!isPopulate) {
                    resetFieldsDefault('requestAddEdit');
                    $('div.ivalidator, img.ierror, span.ierror').hide();
                }
            }
            $('#requestAddEdit div.modal-header h3 span')[0].innerHTML = titleText;
            $('#requestAddEdit').modal('show');
        }

        function PopulateAccessory() {
            $('#requestAddEditAccessory div.modal-header h3 span')[0].innerHTML = "Pattern Accessory";
            $('#' + btnAddPatternAccessory)[0].innerHTML = "Add";
            $('#requestAddEditAccessory').modal('show');
        }

        function isPatternTemplate() {
            $('#dvPatternTemplateUpload').show();
        }


    </script>
</asp:Content>
