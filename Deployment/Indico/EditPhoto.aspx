<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="EditPhoto.aspx.cs" Inherits="Indico.EditPhoto" %>

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
                <div id="dvPageValidation" runat="server" class="message error" visible="false">
                    <h4>
                        <asp:Label ID="lblErrorMessageTitle" runat="server" Text="Errors were encountered while trying to process the form below:"></asp:Label>
                    </h4>
                    <asp:ValidationSummary ID="validationSummary" runat="server"></asp:ValidationSummary>
                </div>
                <!-- / -->
                <!-- Page Data -->
                <fieldset>
                    <legend>Personal Photo </legend>
                    <div class="control-group">
                        <div class="controls">
                            <label class="checkbox">
                                <asp:Image ID="imgProfilePicture" runat="server" CssClass="avatar128" />
                            </label>
                            <table id="uploadtable_1" class="file_upload_files" multirow="false" setdefault="true">
                                <tr id="profilePictureRow" runat="server">
                                </tr>
                            </table>
                            <input id="hdnProfilePicture" runat="server" name="hdnProfilePicture" type="hidden"
                                value="" />
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Photo</label>
                        <div class="controls">
                            <div id="dropzone_1" class="fileupload preview single setdefault">
                                <input id="file_1" name="file_1" type="file" />
                                <button id="btnup_1" type="submit">
                                    Upload</button>
                                <div id="divup_1">
                                    Drag photo here or click to upload</div>
                            </div>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                        </label>
                        <div class="controls">
                            <p class="extra-helper">
                                <span class="label label-info">Hint:</span>You can upload .JPG, .PNG, or .GIF type
                                image. Your image will be resized if it is larger than <strong>54px wide</strong>
                                or <strong>54px tall</strong>.
                            </p>
                        </div>
                    </div>
                </fieldset>
                <div class="form-actions">
                    <button id="btnSaveChanges" runat="server" class="btn btn-primary" data-loading-text="Uploading..."
                        onserverclick="btnSaveChanges_Click" type="submit">
                        Upload Photo</button>
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
</asp:Content>
