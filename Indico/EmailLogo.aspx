<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="EmailLogo.aspx.cs" Inherits="Indico.EmailLogo" %>

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
            <div class="inner">
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>">
                </asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <fieldset id="fieldDetails" runat="server">
                    <legend>Details </legend>
                    <table id="uploadtable_1" class="file_upload_files" multirow="false" setdefault="false">
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
                                        <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Image">Delete</asp:HyperLink>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </table>
                    <input id="hdnUploadFiles" runat="server" name="hdnUploadFiles" type="hidden" value="" />
                    <div class="control-group">
                        <label class="control-label required">
                            Email Logo</label>
                        <div class="controls">
                            <div id="dropzone_1" class="fileupload preview single hide-dropzone setdefault">
                                <input id="file_1" name="file_1" type="file" />
                                <button id="btnup_1" type="submit">
                                    Upload</button>
                                <div id="divup_1">
                                    Drag file here or click to upload</div>
                            </div>
                            <asp:CustomValidator ID="cvLabel" runat="server" ErrorMessage="Email logo is required."
                                EnableClientScript="false" Display="Dynamic" OnServerValidate="cvLabel_OnServerValidate">                            
                            <img src="Content/img/icon_warning.png"  title="Email logo is required." alt="Email logo is required." />
                            </asp:CustomValidator>
                        </div>
                    </div>
                    <div>
                        <label class="control-label ">
                        </label>
                        <p class="help-block">
                            <span class="label label-info">Hint:</span> You can drag & drop files from your
                            desktop on this webpage with Google Chrome, Mozilla Firefox and Apple Safari.
                            <!--[if IE]>
                            <strong>Microsoft Explorer has currently no support for Drag & Drop or multiple file selection.</strong>
                            <![endif]-->
                        </p>
                    </div>
                </fieldset>
                <div class="form-actions" id="dvFormAction" runat="server">
                    <button id="btnAddEmailLogo" runat="server" class="btn btn-primary" type="submit"
                        data-loading-text="Saving..." onserverclick="btnAddEmailLogo_Click">
                        Add Email Logo</button>
                </div>
                <!-- / -->
                <!-- Lables -->
                <fieldset id="fieldpopulateEmailLogo" runat="server">
                    <legend>Logo </legend>
                    <div class="control-group">
                        <div id="dvEmailLogo" runat="server" visible="false">
                            <ul class="thumbnails text-center">
                                <asp:Repeater ID="rptEmailLogo" runat="server" OnItemDataBound="rptEmailLogo_ItemDataBound">
                                    <ItemTemplate>
                                        <li class="span4">
                                            <div class="thumbnail">
                                                <asp:Image ID="imgEmailLogo" runat="server" CssClass="" />
                                                <div class="caption">
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Email Logo"
                                                        Visible="false">Edit</asp:HyperLink>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Email Logo"><i class="icon-trash"></i></asp:HyperLink>
                                                </div>
                                            </div>
                                        </li>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </ul>
                        </div>
                    </div>
                </fieldset>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedId" runat="server" Value="0" />
    <!-- Delete Label -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                Delete Email Logo</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this email logo?</p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" type="submit" onserverclick="btnDelete_Click"
                data-loading-text="Deleting...">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var hdnSelectedId = "<%=hdnSelectedId.ClientID %>";        
    </script>
    <script type="text/javascript">
        //ShowHideDistributor();
        $(document).ready(function () {
            $('.idelete').click(function () {
                $('#' + hdnSelectedId)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });
        });
    </script>
    <!-- / -->
</asp:Content>
