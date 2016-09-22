<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditEmbroidery.aspx.cs" Inherits="Indico.AddEditEmbroidery" %>

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
                    ValidationGroup="validateEmb" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>">
                </asp:ValidationSummary>
                <asp:ValidationSummary ID="validationSummaryDetail" runat="server" CssClass="alert alert-danger"
                    ValidationGroup="validateEmbDetail" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>">
                </asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#<%=collapse1.ClientID%>">Details</a>
                    </div>
                    <div id="collapse1" runat="server" class="accordion-body collapse in">
                        <div class="accordion-inner">
                            <div class="control-group">
                                <label class="control-label required">
                                    Emb Strike Off Date</label>
                                <div class="controls">
                                    <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                        <asp:TextBox ID="txtEmbStrikeOffDate" runat="server"></asp:TextBox>
                                        <span class="add-on"><i class="icon-calendar"></i></span>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvStrikeDate" runat="server" ErrorMessage="Strike Date is required"
                                        ValidationGroup="validateEmb" ControlToValidate="txtEmbStrikeOffDate" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Strike Date is required" alt="Strike Date is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Job Name</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtJobName" runat="server"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvJobName" runat="server" ErrorMessage="Job Name is required"
                                        ValidationGroup="validateEmb" ControlToValidate="txtJobName" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Job Name is required" alt="Job Name is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Distributor
                                </label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlDistributor" runat="server" OnSelectedIndexChanged="ddlDistributor_SelectedIndexChanged"
                                        AutoPostBack="true">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvDistributors" runat="server" ErrorMessage="Distributor is required"
                                        ValidationGroup="validateEmb" ControlToValidate="ddlDistributor" InitialValue="0"
                                        EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Distributor is required" alt="Distributor is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Coordinator</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtCoordinator" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Client</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtClient" runat="server"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Client is required"
                                        ValidationGroup="validateEmb" ControlToValidate="txtClient" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Client is required" alt="Client is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Product</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtProduct" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Emb Photo Required By</label>
                                <div class="controls">
                                    <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                        <asp:TextBox ID="txtRequiredBy" runat="server"></asp:TextBox>
                                        <span class="add-on"><i class="icon-calendar"></i></span>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvPhotoRequired" runat="server" ErrorMessage="Emb Photo is required"
                                        ValidationGroup="validateEmb" ControlToValidate="txtRequiredBy" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Emb Photo is required" alt="Emb Photo is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Assigned to</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlAssigned" runat="server">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvAssignedto" runat="server" ErrorMessage="Assigned is required"
                                        ValidationGroup="validateEmb" ControlToValidate="ddlAssigned" InitialValue="0"
                                        EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Assigned is required" alt="Assigned is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#<%=collapse2.ClientID%>">Embroidery
                            Details</a>
                    </div>
                    <div id="collapse2" runat="server" class="accordion-body collapse">
                        <div class="accordion-inner">
                            <div class="control-group">
                                <label class="control-label required">
                                    Location</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtLocation" runat="server"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Location is required"
                                        ValidationGroup="validateEmbDetail" ControlToValidate="txtLocation" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Location is required" alt="Location is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Fabric Color</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlFabricColor" runat="server">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Fabric Color is required"
                                        ValidationGroup="validateEmbDetail" ControlToValidate="ddlFabricColor" InitialValue="0"
                                        EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Fabric Color is required" alt="Fabric Color is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Fabric</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlFabric" runat="server">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvFabric" runat="server" ErrorMessage="Fabric Type is required"
                                        ValidationGroup="validateEmbDetail" ControlToValidate="ddlFabric" InitialValue="0"
                                        EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Fabric Type is required" alt="Fabric Type is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Height(mm)</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtHeight" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Width(mm)</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtWidth" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Status</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlStatus" runat="server">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvStatus" runat="server" ErrorMessage="Status is required"
                                        ValidationGroup="validateEmbDetail" ControlToValidate="ddlFabricColor" InitialValue="0"
                                        EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Status is required" alt="Status is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Notes</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine"></asp:TextBox>
                                </div>
                            </div>
                            <!-- Embroidery Image -->
                            <!-- Image_1-->
                            <div id="dvRequestedImage" runat="server">
                                <div class="control-group">
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
                                                            <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Embroidery Image"><i class="icon-trash"></i></asp:HyperLink>
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
                                        Requested Images
                                    </label>
                                    <div class="controls">
                                        <div id="dropzone_1" multirow="true" class="fileupload preview single hide-dropzone setdefault">
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
                            <!--/-->
                            <!-- Produced Image-->
                            <div id="dvProducedImage" runat="server">
                                <div class="control-group">
                                    <label class="control-label">
                                    </label>
                                    <div class="controls">
                                        <table id="uploadtable_2" class="file_upload_files" multirow="true" setdefault="false">
                                            <asp:Repeater ID="rptUploadFile_2" runat="server">
                                                <ItemTemplate>
                                                    <tr id="tableRowfileUpload">
                                                        <td class="file_preview">
                                                            <asp:Image ID="uploadImage_1" Height="" Width="" runat="server" ImageUrl="" />
                                                        </td>
                                                        <td class="file_name">
                                                            <asp:Literal ID="litfileName_1" runat="server"></asp:Literal>
                                                        </td>
                                                        <td id="filesize" class="file_size" runat="server">
                                                            <asp:Literal ID="litfileSize_1" runat="server"></asp:Literal>
                                                        </td>
                                                        <td class="file_delete">
                                                            <asp:HyperLink ID="linkDelete_1" runat="server" CssClass="btn-link idelete" ToolTip="Delete Embroidery Image"><i class="icon-trash"></i></asp:HyperLink>
                                                        </td>
                                                    </tr>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </table>
                                        <input id="hdnUploadFiles_1" runat="server" name="hdnUploadFiles" type="hidden" value="" />
                                    </div>
                                </div>
                                <div class="control-group">
                                    <label class="control-label">
                                        produced Images
                                    </label>
                                    <div class="controls">
                                        <div id="dropzone_2" multirow="true" class="fileupload preview single hide-dropzone setdefault">
                                            <input id="file_2" name="file_2" type="file" />
                                            <button id="btnup_2" type="submit">
                                                Upload</button>
                                            <div id="divup_2">
                                                Drag file here or click to upload
                                            </div>
                                        </div>
                                    </div>
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
                            <!-- / -->
                            <div id="dvEmptyContentEmbReqImage" runat="server" class="alert alert-info">
                                <h4>
                                    There are no Embroidery Requested images found.
                                </h4>
                                <p>
                                    You can add many Embroidery requsted images as you like.
                                </p>
                            </div>
                            <div id="dvEmbroideryEmbProImage" runat="server" class="alert alert-info">
                                <h4>
                                    There are no Embroidery Produced images found.
                                </h4>
                                <p>
                                    You can add many Embroidery produced images as you like.
                                </p>
                            </div>
                            <div id="dvEmbroideryImagePreview" runat="server">
                                <legend>Embroidery Images</legend>
                                <ul class="thumbnails text-center">
                                    <li class="span3" id="liRequestedImage" runat="server">
                                        <div class="thumbnail">
                                            <asp:Image ID="imgEmbroiderRequested" runat="server" CssClass="img-rounded" />
                                            <div class="caption">
                                            <h3>Requested Image</h3>
                                                <asp:HyperLink ID="linkDeleteRequested" runat="server" CssClass="btn btn-primary ideleteimage"
                                                    ToolTip="Delete Embroidery Requested Image"><i class="icon-trash icon-white"></i> Delete</asp:HyperLink>
                                            </div>
                                        </div>
                                    </li>
                                    <li class="span3" id="liProducedImage" runat="server">
                                        <div class="thumbnail">
                                            <asp:Image ID="imgEmbroideryProduced" runat="server" CssClass="img-rounded" />
                                            <div class="caption">
                                            <h3>Produced Image</h3>
                                                <asp:HyperLink ID="linkDeleteProduced" runat="server" CssClass="btn btn-primary ideleteimage"
                                                    ToolTip="Delete Embroidery Produced Image"><i class="icon-trash icon-white"></i> Delete</asp:HyperLink>
                                            </div>
                                        </div>
                                    </li>
                                </ul>
                            </div>
                            <!-- / -->
                            <div class="iclearfix icenter">
                                <button id="btnAddEmbroidery" runat="server" class="btn btn-success" validationgroup="validateEmbDetail"
                                    data-loading-text="Adding..." type="submit" onserverclick="btnAddEmbroidery_Click">
                                    Add Ebroidery Detail</button>
                            </div>
                            <legend>Embroider Details </legend>
                            <!-- Data Table -->
                            <asp:DataGrid ID="dgEmbroiderDetails" runat="server" CssClass="table" AllowCustomPaging="False"
                                AllowPaging="False" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                                OnItemDataBound="dgEmbroiderDetails_ItemDataBound">
                                <HeaderStyle CssClass="header" />
                                <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                                <Columns>
                                    <asp:TemplateColumn HeaderText="Location">
                                        <ItemTemplate>
                                            <asp:Literal ID="litLocation" runat="server" Text=""></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Fabric Type">
                                        <ItemTemplate>
                                            <asp:Literal ID="litFabricType" runat="server" Text=""></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Fabric Color">
                                        <ItemTemplate>
                                            <div class="color-picker-frame">
                                                <div id="dvFabricColor" runat="server" class="icolor">
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Width(mm)">
                                        <ItemTemplate>
                                            <asp:Literal ID="litWidth" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Height(mm)">
                                        <ItemTemplate>
                                            <asp:Literal ID="litHeight" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Requested Image">
                                        <ItemTemplate>
                                            <a id="ancRequestedIamge" runat="server"><i id="iReqimageView" runat="server" class="icon-eye-open">
                                            </i></a>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Produce Image">
                                        <ItemTemplate>
                                            <a id="ancProducedIamge" runat="server"><i id="iProimageView" runat="server" class="icon-eye-open">
                                            </i></a>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Compare Images">
                                        <ItemTemplate>
                                            <a id="linkCompare" runat="server" cssclass="btn-link" tooltip="Compare Embroidery Image"
                                                onserverclick="linkCompare_Click"><i class="icon-picture"></i></a>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Status">
                                        <ItemTemplate>
                                            <asp:Literal ID="litStatus" runat="server" Text=""></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Notes">
                                        <ItemTemplate>
                                            <asp:Literal ID="litNotes" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="">
                                        <ItemTemplate>
                                            <div class="btn-group">
                                                <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                    <i class="icon-cog"></i><span class="caret"></span></a>
                                                <ul class="dropdown-menu pull-right">
                                                    <li><a id="linkEdit" runat="server" class="btn-link iedit" title="Edit Item" onserverclick="linkEdit_Click">
                                                        <i class="icon-pencil"></i>Edit</a> </li>
                                                    <li>
                                                        <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Embroider Detail"><i class="icon-trash"></i>Delete</asp:HyperLink>
                                                    </li>
                                                </ul>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                </Columns>
                            </asp:DataGrid>
                            <!-- / -->
                            <!-- No Orders -->
                            <div id="dvNoEmbroiderDetails" runat="server" class="alert alert-info">
                                <h4>
                                    No Embroider details have been added.</h4>
                                <p>
                                    Once you add an embroider details, you'll see the details below.
                                </p>
                            </div>
                            <!-- / -->
                        </div>
                    </div>
                </div>
                <div class="form-actions">
                    <button id="btnSaveChanges" runat="server" class="btn btn-primary" type="submit"
                        validationgroup="validateEmb" data-loading-text="Saving..." onserverclick="btnSaveChanges_Click">
                        Save Changes</button>
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnCoordinator" runat="server" Value="0" />
    <asp:HiddenField ID="hdnEmbDetail" runat="server" Value="0" />
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnEmbImage" runat="server" Value="0" />
    <!-- Delete Embroidery Detail -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                Delete Embroidery Detail</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Embroidery Detail?
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" onserverclick="btnDelete_Click"
                data-loading-text="Deleting..." type="submit">
                Yes</button>
        </div>
    </div>
    <!--/-->
    <!-- Compare Embroidery Image  -->
    <div id="requestCompareImage" class="modal modal-medium hide fade" role="dialog"
        aria-hidden="true" keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                Compare Embroidery Images</h3>
        </div>
        <div class="modal-body">
            <div class="text-center">
                <ul class="thumbnails text-center">
                    <li class="span5">
                        <div class="thumbnail">
                            <asp:Image ID="imgRequestedImage" runat="server" CssClass="img-rounded" />
                            <div class="caption">
                                <h3>
                                    Requested Image</h3>
                            </div>
                        </div>
                    </li>
                    <li class="span5">
                        <div class="thumbnail">
                            <asp:Image ID="imgProducedImage" runat="server" CssClass="img-rounded" />
                            <div class="caption">
                                <h3>
                                    Produced Image</h3>
                            </div>
                        </div>
                    </li>
                </ul>
            </div>
            <div id="dvNoEmbroideryImages" runat="server" class="alert alert-info">
                <h4>
                    There are no Embroidery images found.
                </h4>
            </div>
        </div>
        <div class="modal-footer">
        </div>
    </div>
    <!--/-->
    <!-- Delete Embroidery Image -->
    <div id="requsetDeleteImage" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                Delete Embroidery Detail Image</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Embroidery Detail Image?
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDleteImage" runat="server" class="btn btn-primary" onserverclick="btnDleteImage_Click"
                data-loading-text="Deleting..." type="submit">
                Yes</button>
        </div>
    </div>
    <!--/-->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var isPopulate = ('<%=ViewState["isPopulate"]%>' == 'True') ? true : false;
        var isCompareImage = ('<%=ViewState["isCompareImage"]%>' == 'True') ? true : false;
        var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
        var hdnEmbImage = "<%=hdnEmbImage.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.datepicker').datepicker({ format: 'dd MM yyyy' });

            $('.idelete').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                $('#requestDelete').modal('show');
            });

            $('.ideleteimage').click(function () {
                $('#requsetDeleteImage').modal('show');
                $('#' + hdnEmbImage).val($(this).attr('qid'));
            });

            if (isCompareImage) {
                $('#requestCompareImage').modal('show');
            }
        });
    </script>
    <!--/-->
</asp:Content>
