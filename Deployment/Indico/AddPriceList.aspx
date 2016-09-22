<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddPriceList.aspx.cs" Inherits="Indico.AddPriceList" MaintainScrollPositionOnPostback="true"
    EnableViewState="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnDefaultValue" runat="server" class="btn btn-link iadd pull-right" type="button"
                    onserverclick="btnDefaultValue_Click">
                    Edit Default Values</a>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="inner">
                <asp:ValidationSummary ID="PriceListvalidationSummary" runat="server" CssClass="alert alert-danger"
                    ValidationGroup="pricelistLabel" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>">
                </asp:ValidationSummary>
                <!-- Download Excel --->
                <div id="dvGenerateExcelContent" runat="server" class="itoggle-content" style="display block;">
                    <legend>Details </legend>
                    <%--  <div class="iaccess-bar iclearfix">--%>
                    <%--</div>--%>
                    <div class="control-group">
                        <div class="controls">
                            <label class="checkbox inline">
                                <asp:RadioButton ID="rbDistributor" GroupName="type" runat="server" Checked="true" />
                                Distributor
                            </label>
                            <label class="checkbox inline">
                                <asp:RadioButton ID="rbLabel" GroupName="type" runat="server" />
                                Label
                            </label>
                        </div>
                    </div>
                    <div id="lidistributor" runat="server" class="control-group" style="display: block">
                        <label class="control-label">
                            Distributor</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlDistributorsExcel" runat="server" AutoPostBack="false" Enabled="true">
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div id="lilabel" runat="server" style="display: none" class="control-group">
                        <label class="control-label">
                            Label</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddlLabelExcel" runat="server" AutoPostBack="false" Enabled="true">
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="control-group">
                        <div class="controls">
                            <label class="checkbox inline">
                                <asp:RadioButton ID="rbcifPrice" GroupName="price" runat="server" Checked="true" />
                                CIF Price
                            </label>
                            <label class="checkbox inline">
                                <asp:RadioButton ID="rbfobPrice" GroupName="price" runat="server" />
                                FOB Price
                            </label>
                        </div>
                    </div>
                    <div id="dvHide" runat="server">
                        <li style="display: none">
                            <label class="checkbox">
                                <asp:RadioButton ID="rbeditedPrice" GroupName="aa" runat="server" class="Edited"
                                    Checked="true" />
                                Edited Price
                            </label>
                            <label class="checkbox">
                                <asp:RadioButton ID="rbCalculatedPrice" GroupName="aa" runat="server" class="Calculated" />
                                Calculated Price
                            </label>
                        </li>
                    </div>
                    <legend>Set Up Fees</legend>
                    <div class="control-group">
                        <div class="controls">
                            <button id="btnDefaultValuesFees" runat="server" class="btn btn-success pull-right idefault"
                                value="" type="button">
                                Use Default Fees</button>
                        </div>
                    </div>
                    <div class="control-group">
                        <div class="controls">
                            <label class="checkbox inline">
                                <asp:CheckBox ID="checkCreativeDesign" runat="server" class="icheck" Checked="true" />
                                Creative Design
                            </label>
                            <asp:TextBox ID="txtCreativeDesign" runat="server" CssClass="input-small cDesign"
                                Text="0" />
                        </div>
                    </div>
                    <div class="control-group">
                        <div class="controls">
                            <label class="checkbox inline">
                                <asp:CheckBox ID="checkStudioDesign" runat="server" class="icheck" Checked="true" />
                                Studio Design
                            </label>
                            <asp:TextBox ID="txtStudioDesign" runat="server" CssClass="input-small sDesign" Text="0" />
                        </div>
                    </div>
                    <div class="control-group">
                        <div class="controls">
                            <label class="checkbox inline">
                                <asp:CheckBox ID="checkThirdPartyDesign" runat="server" class="icheck" Checked="true" />
                                Third Party Design
                            </label>
                            <asp:TextBox ID="txtThirdPartyDesign" runat="server" CssClass="input-small tpDesign"
                                Text="0" />
                        </div>
                    </div>
                    <legend>Individual Names and Numbers</legend>
                    <div class="control-group">
                        <div class="controls">
                            <label class="checkbox inline">
                                <asp:CheckBox ID="checkPositionOne" runat="server" class="icheck" Checked="true" />
                                1 Position
                            </label>
                            <asp:TextBox ID="txtPositionOne" runat="server" CssClass="input-small pOne" Text="0" />
                        </div>
                    </div>
                    <div class="control-group">
                        <div class="controls">
                            <label class="checkbox inline">
                                <asp:CheckBox ID="checkPositionTwo" runat="server" class="icheck" Checked="true" />
                                2 Position
                            </label>
                            <asp:TextBox ID="txtPositionTwo" runat="server" CssClass="input-small pTwo" Text="0" />
                        </div>
                    </div>
                    <div class="control-group">
                        <div class="controls">
                            <label class="checkbox inline">
                                <asp:CheckBox ID="checkPositionThree" runat="server" class="icheck" Checked="true" />
                                3 Position
                            </label>
                            <asp:TextBox ID="txtPositionThree" runat="server" CssClass="input-small ismall pThree"
                                Text="0" />
                        </div>
                    </div>
                    <div class="form-actions">
                        <button id="btnDownloadExcel" runat="server" class="btn btn-primary generate-excel"
                            type="submit" onserverclick="btnDownloadExcel_Click">
                            Download</button>
                        <button id="btnDownloadLabelExcel" runat="server" class="btn btn-primary generate-excel"
                            validationgroup="pricelist" onserverclick="btnDownloadLabelExcel_Click" type="button"
                            style="display: none">
                            Download</button>
                    </div>
                </div>
            </div>
            <!-- /-->
        </div>
        <asp:HiddenField ID="hdnUserID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
        <!-- / -->
        <!-- Default Value -->
        <div id="dvDefaultValue" class="modal fade" role="dialog" aria-hidden="true">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    ×</button>
                <h3>
                    Default Price List Values</h3>
            </div>
            <div class="modal-body">
                <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                    ValidationGroup="valDefaultValue" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>">
                </asp:ValidationSummary>
                <div class="control-group">
                    <label class="control-label required">
                        Crative Design
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtAddCreativeDesign" runat="server">
                        </asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvAddCreativeDesign" runat="server" CssClass="error"
                            ControlToValidate="txtAddCreativeDesign" Display="Dynamic" EnableClientScript="False"
                            ErrorMessage="Creative design is required" ValidationGroup="valDefaultValue">
                                <img src="Content/img/icon_warning.png" title="Creative design is required" alt="Creative design is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Studio Design
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtAddStudioDesign" runat="server">
                        </asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvAddStudioDesign" runat="server" CssClass="error"
                            ControlToValidate="txtAddStudioDesign" Display="Dynamic" EnableClientScript="False"
                            ErrorMessage="Studio design is required" ValidationGroup="valDefaultValue">
                                <img src="Content/img/icon_warning.png" title="Studio design is required" alt="Studio design is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Third Party Design
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtAddThirdParydesign" runat="server">
                        </asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvAddThirdParydesign" runat="server" CssClass="error"
                            ControlToValidate="txtAddThirdParydesign" Display="Dynamic" EnableClientScript="False"
                            ErrorMessage="Third party design is required" ValidationGroup="valDefaultValue">
                                <img src="Content/img/icon_warning.png" title="Third party design is required" alt="Third party design is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Position One
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtAddPosition1" runat="server">
                        </asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvAddPosition1" runat="server" CssClass="error"
                            ControlToValidate="txtAddPosition1" Display="Dynamic" EnableClientScript="False"
                            ErrorMessage="Postion one is required" ValidationGroup="valDefaultValue">
                                <img src="Content/img/icon_warning.png" title="Postion one is required" alt="Postion one is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Position Two
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtAddPosition2" runat="server">
                        </asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvAddPosition2" runat="server" CssClass="error"
                            ControlToValidate="txtAddPosition2" Display="Dynamic" EnableClientScript="False"
                            ErrorMessage="Postion two is required" ValidationGroup="valDefaultValue">
                                <img src="Content/img/icon_warning.png" title="Postion two is required" alt="Postion two is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Position Three
                    </label>
                    <div class="controls">
                        <asp:TextBox ID="txtAddPosition3" runat="server">
                        </asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvAddPosition3" runat="server" CssClass="error"
                            ControlToValidate="txtAddPosition3" Display="Dynamic" EnableClientScript="False"
                            ErrorMessage="Postion three is required" ValidationGroup="valDefaultValue">
                                <img src="Content/img/icon_warning.png" title="Postion three is required" alt="Postion three is required" />
                        </asp:RequiredFieldValidator>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">
                    Close</button>
                <button id="btnSaveDefaultValue" runat="server" class="btn btn-primary" validationgroup="valDefaultValue"
                    data-loading-text="Saving..." type="submit" onserverclick="btnSaveDefaultValue_Click">
                    Save Changes</button>
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <script type="text/javascript">
        var populateDefaultValue = ('<%=ViewState["populateDefaultValue"]%>' == 'True') ? true : false;
        var rbDistributor = "<%=rbDistributor.ClientID%>";
        var rbLabel = "<%=rbLabel.ClientID%>";
        var btnDownloadExcel = "<%=btnDownloadExcel.ClientID%>";
        var btnDownloadLabelExcel = "<%=btnDownloadLabelExcel.ClientID%>";
        var lidistributor = "<%=lidistributor.ClientID%>";
        var lilabel = "<%=lilabel.ClientID%>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            if (populateDefaultValue) {
                window.setTimeout(function () {
                    $('#dvDefaultValue').modal('show');
                }, 10);
            }
            $('.iadd').click(function () {
                $('div.ivalidator, span.error').hide();
                window.setTimeout(function () {
                    $('#dvDefaultValue').modal('show');
                }, 10);
            });


            $('input[type=checkbox]').change(function () {
                if ($(this).attr('checked')) {
                    $(this).parents('label').next('input[type=text]').val('0');
                }
                else {
                    $(this).parents('label').next('input[type=text]').val('');
                }
            });

            $('.idefault').click(function () {
                $('input[type=checkbox]:checked').each(function () {
                    $(this).parents('label').next('input[type=text]').val($(this).parent('span').attr('df'));
                });
            });

            $('#' + rbDistributor).click(function () {
                $('#' + lidistributor).show();
                $('#' + lilabel).hide();
                $('#' + btnDownloadExcel).show();
                $('#' + btnDownloadLabelExcel).hide();
            });
            $('#' + rbLabel).click(function () {
                $('#' + lidistributor).hide();
                $('#' + lilabel).show();
                $('#' + btnDownloadExcel).hide();
                $('#' + btnDownloadLabelExcel).show();
            });
        });
    </script>
</asp:Content>
