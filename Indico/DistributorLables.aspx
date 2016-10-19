<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="DistributorLables.aspx.cs" Inherits="Indico.DistributorLables" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
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
            <div class="inner">
                <!-- Page Validation -->
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <fieldset>
                    <legend>Details</legend>
                    <div class="control-group">
                        <div class="controls">
                            <p class="required">
                                Indicates required fields
                            </p>
                        </div>
                    </div>
                    <div class="control-group">
                        <div class="controls checkbox">
                            <asp:CheckBox ID="chbIsSample" runat="server" AutoPostBack="true" OnCheckedChanged="chbIsSample_CheckedChanged" />Is
                            Sample
                        </div>
                    </div>
                    <div id="dvDistributor" runat="server" class="control-group">
                        <label class="control-label required">
                            Distributor
                        </label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlDistributor" runat="server" AutoPostBack="true" CssClass="input-large" OnSelectedIndexChanged="ddlDistributor_SelectedIndexChanged">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvDistributor" runat="server" ErrorMessage="Distributor is required."
                                ControlToValidate="ddlDistributor" InitialValue="0" EnableClientScript="false"
                                Display="Dynamic">
                               <img src="Content/img/icon_warning.png"  title="Distributor is required." alt="Distributor is required." />
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label required">
                            Label Name
                        </label>
                        <div class="controls">
                            <asp:TextBox ID="txtLabelName" runat="server"></asp:TextBox>
                            <asp:Label CssClass="text-error" ID="nameExists" Visible="false" runat="server">Label Name Already exists</asp:Label>
                        </div>                            
                            <asp:RequiredFieldValidator ID="rfvLabelName" runat="server" ErrorMessage="Label Name is required."
                                ControlToValidate="txtLabelName" EnableClientScript="false" Display="Dynamic">
                            
                               <img src="Content/img/icon_warning.png"  title="Label Name is required." alt="Label Name is required." />
                            </asp:RequiredFieldValidator>
                            <%--<asp:RequiredFieldValidator ID="rfvLabeNotAvailable" runat="server" ErrorMessage="Label Name Already exists."
                                ControlToValidate="txtLabelName" EnableClientScript="false" Display="Dynamic">
                                <img src="Content/img/icon_warning.png"  title="Label Name Already exists." alt="Label Name Already exists." />
                             </asp:RequiredFieldValidator>--%>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                        </label>
                        <div class="controls">
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
                        <label class="control-label required">
                            Label
                        </label>
                        <div class="controls">
                            <div>
                                <asp:Image ID="imgLabel" runat="server" />
                                <asp:HiddenField ID="hdnEditLabel" runat="server" Value="0" />
                            </div>
                            <div id="dropzone_1" class="fileupload preview">
                                <input id="file_1" name="file_1" type="file" />
                                <button id="btnup_1" type="submit">
                                    Upload</button>
                                <div id="divup_1">
                                    Drag file here or click to upload
                                </div>
                            </div>
                            <asp:CustomValidator ID="cvLabel" runat="server" ErrorMessage="Label is required."
                                EnableClientScript="false" Display="Dynamic" OnServerValidate="cvLabel_OnServerValidate">                            
                            <img src="Content/img/icon_warning.png"  title="Label Name is required." alt="Label Name is required." />
                            </asp:CustomValidator>
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
                </fieldset>
                <div class="form-actions">
                    <button id="btnAddLabel" runat="server" class="btn btn-primary" onserverclick="btnAddLabel_Click"
                        data-loading-text="Adding..." type="submit">
                        Add Label</button>
                </div>
                <!-- / -->
                <!-- Lables -->
                <div id="dvLabels" runat="server" visible="false" class="text-center">
                    <ul class="thumbnails">
                        <asp:Repeater ID="rptLabels" runat="server" OnItemDataBound="rptLabels_ItemDataBound" OnItemCommand="rptLabels_ItemCommand">
                            <ItemTemplate>
                                <li class="span4">
                                    <div class="thumbnail">
                                        <asp:Image ID="imgLabel" runat="server" />
                                        <div class="caption">
                                            <h4>
                                                <asp:Label ID="lblItemName" runat="server" /><h4>
                                                    <asp:LinkButton ID="linkEdit" runat="server" CssClass="btn-link" ToolTip="Edit Label" CausesValidation="false"><i class="icon-pencil"></i></asp:LinkButton>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass=" btn-link idelete" ToolTip="Delete Label"><i class="icon-trash"></i></asp:HyperLink>
                                                    <asp:HyperLink ID="linkInactivate" Visible="false" runat="server" CssClass=" btn-link inactivate" ToolTip="Inactivate Label"><i class="icon-off"></i></asp:HyperLink>
                                                    <asp:HyperLink ID="linkReactivate" Visible="false" runat="server" CssClass=" btn-link reactivate" ToolTip="Reactivate Label"><i class="icon-repeat"></i></asp:HyperLink>
                                                    <asp:HiddenField ID="hdnLabelID" runat="server" Value="0" />
                                        </div>
                                    </div>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ul>
                </div>
                <div id="dvPagingFooter" class="paginator" runat="server">
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
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedId" runat="server" Value="0" />
    <!-- Delete Label -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Label</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Label?
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" data-loading-text="Deleting..."
                type="submit" onserverclick="btnDelete_Click">
                Yes
            </button>
        </div>
    </div>

     <!-- inactive Label -->
    <div id="requestInactive" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>inactive Label</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to inactive this Label?
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnInactivate" runat="server" class="btn btn-primary" 
                onserverclick="btnInactivate_Click">
                Yes
            </button>
        </div>
    </div>

              <!-- reactive Label -->
    <div id="requestReactive" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>reactive Label</h3>
        </div>
        <div class="modal-body">
            Are you sure you wish to reactivate this Label?
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="BtnReactivate" runat="server" class="btn btn-primary" 
                onserverclick="btnReactivate_Click">
                Yes
            </button>
        </div>
    </div>





1300 EPROMO LABEL

    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var hdnSelectedId = "<%=hdnSelectedId.ClientID %>";
        var chbIsSample = "<%=chbIsSample.ClientID %>";
        var ddlDistributor = "<%=ddlDistributor.ClientID %>";
    </script>
    <script type="text/javascript">
        
        //ShowHideDistributor();
        $(document).ready(function () {
            $('.idelete').click(function () {
                $('#' + hdnSelectedId)[0].value = $(this).attr('qid');
                $('#requestDelete').modal('show');
            });

            $('.inactivate').click(function () {
                console.log("inactivate modal");
                $('#' + hdnSelectedId)[0].value = $(this).attr('qid');
                console.log($(this).attr('qid'));
                $('#requestInactive').modal('show');
            });

            $('.reactivate').click(function () {
                console.log("reactivate modal");
                $('#' + hdnSelectedId)[0].value = $(this).attr('qid');
                $('#requestReactive').modal('show');
            });


           

           

      

            $('#<%=txtLabelName.ClientID%>').keyup(function () {
                $('#<%=nameExists.ClientID%>').hide();
            });

                    //$('#' + chbissample).change(function () {
                    //    showhidedistributor();
                    //});

                    //function showhidedistributor() {
                    //    if ($('#' + chbissample).is(':checked')) {
                    //        $('#dvdistributor').hide();
                    //    }
                    //    else {
                    //        $('#dvdistributor').show();
                    //    }
                    //}            
            $('#' + ddlDistributor).select2();
        });
    </script>
    <!-- / -->
</asp:Content>
