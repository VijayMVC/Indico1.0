<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="AddEditQuote.aspx.cs" Inherits="Indico.AddEditQuote" MaintainScrollPositionOnPostback="true"
    EnableEventValidation="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnCCEmailAddress" runat="server" onserverclick="btnCCEmailAddress_Click"
                    class="btn btn-link pull-right">CC E-Mail List</a> <a id="linkCCEmail" href="#dvEmailAddresses"
                        role="button" style="display: none;" class="btn" data-toggle="modal"></a>
                <asp:Literal ID="lblQuoteStatus" runat="server"></asp:Literal>
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
                    ValidationGroup="ValidateQuotes" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <asp:ValidationSummary ID="validationSummaryDetail" runat="server" CssClass="alert alert-danger"
                    ValidationGroup="ValidateQuotesDetail" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
                <!-- / -->
                <!-- Page Data -->
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#<%=collapse1.ClientID%>">General
                            Details</a>
                    </div>
                    <div id="collapse1" runat="server" class="accordion-body collapse in">
                        <div class="accordion-inner">
                            <div class="control-group">
                                <label class="control-label required">
                                    Quote Date
                                </label>
                                <div class="controls">
                                    <asp:TextBox ID="txtDateQuoted" runat="server" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Contact Name
                                </label>
                                <div class="controls">
                                    <asp:TextBox ID="txtContactName" runat="server"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvContactName" runat="server" ErrorMessage="Contact name is required" ControlToValidate="txtContactName" EnableClientScript="false" ValidationGroup="ValidateQuotes">
                            <img src="Content/img/icon_warning.png"  title="Contact name is required" alt="Contact name is required" />
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Contact Email</label>
                                <div class="controls">
                                    <div class="input-prepend">
                                        <span class="add-on"><i class="icon-envelope"></i></span>
                                        <asp:TextBox ID="txtClientEmail" runat="server" CssClass="input-large"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvClientEmail" runat="server" ErrorMessage="Client Email is required"
                                        ControlToValidate="txtClientEmail" EnableClientScript="false" ValidationGroup="ValidateQuotes">
                            <img src="Content/img/icon_warning.png"  title="Client Email is required" alt="Client Email is required" />
                                    </asp:RequiredFieldValidator>
                                    <asp:RegularExpressionValidator ID="revClientEmail" runat="server" ErrorMessage="Invalid Email format"
                                        ValidationExpression="\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ControlToValidate="txtClientEmail"
                                        EnableClientScript="false" ValidationGroup="ValidateQuotes">
                                 <img src="Content/img/icon_warning.png"  title="Invalid Email format" alt="Invalid Email format" />
                                    </asp:RegularExpressionValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Job Name</label>
                                <div class="controls">
                                    <asp:TextBox ID="txtJobName" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <%--  <div class="control-group">
                                <label class="control-label">
                                    Distributor
                                </label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlDistributor" runat="server">
                                    </asp:DropDownList>
                                </div>
                            </div>--%>
                            <div class="control-group">
                                <label class="control-label">
                                    Status</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlStatus" runat="server">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Currency</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlCurrency" runat="server">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Quote Expiry Date
                                </label>
                                <div class="controls">
                                    <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                        <asp:TextBox ID="txtQuoteExpiryDate" runat="server"> </asp:TextBox>
                                        <span class="add-on"><i class="icon-calendar"></i></span>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvQuoteExpiryDate" runat="server" ErrorMessage="Quote Expiry Date is required"
                                        ControlToValidate="txtQuoteExpiryDate" EnableClientScript="false" ValidationGroup="ValidateQuotes">
                                <img src="Content/img/icon_warning.png"  title="Quote No is required" alt="Quote Expiry Date is required" />
                                    </asp:RequiredFieldValidator>
                                    <asp:CustomValidator ID="cvQuoteExpiryDate" runat="server" ErrorMessage="Invalid Quote Expires Date"
                                        EnableClientScript="false" ControlToValidate="txtQuoteExpiryDate" OnServerValidate="cvQuoteExpiryDate_OnServerValidate"
                                        ValidateEmptyText="true" ValidationGroup="ValidateQuotes">
                             <img src="Content/img/icon_warning.png"  title="Invalid Quote Expires Date" alt="Invalid Quote Expires Date" />
                                    </asp:CustomValidator>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="accordion-group">
                    <div class="accordion-heading">
                        <a class="accordion-toggle" data-toggle="collapse" href="#<%=collapse2.ClientID%>">Quote
                            Details</a>
                    </div>
                    <div id="collapse2" runat="server" class="accordion-body collapse">
                        <div class="accordion-inner">
                            <h4>New Quote Detail</h4>
                            <div class="control-group">
                                <label class="control-label required">
                                    Pattern
                                </label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlPattern" AutoPostBack="true" OnSelectedIndexChanged="ddlPattern_SelectedIndexChanged" runat="server" CssClass="input-xlarge">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvPattern" runat="server" ErrorMessage="Pattern is required" ControlToValidate="ddlPattern" InitialValue="0" EnableClientScript="false" ValidationGroup="ValidateQuotesDetail">
                            <img src="Content/img/icon_warning.png"  title="Pattern is required" alt="Pattern is required" />
                                    </asp:RequiredFieldValidator>
                                    <span class="text-error">
                                        <asp:Literal ID="litPatternError" runat="server" Visible="false"></asp:Literal>
                                    </span>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label required">
                                    Fabric
                                </label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlFabric" AutoPostBack="true" OnSelectedIndexChanged="ddlFabric_SelectedIndexChanged" runat="server" CssClass="input-xlarge">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvFabric" runat="server" ErrorMessage="Fabric is required" ControlToValidate="ddlFabric" InitialValue="0" EnableClientScript="false" ValidationGroup="ValidateQuotesDetail">
                            <img src="Content/img/icon_warning.png"  title="Fabric is required" alt="Fabric is required" />
                                    </asp:RequiredFieldValidator>
                                    <asp:Label ID="lblErrorMeassage" CssClass="text-error" runat="server" Visible="false"></asp:Label>
                                </div>
                            </div>
                            <%-- <div class="control-group">
                                <label class="control-label">
                                    VisualLayout
                                </label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlVisualLayout" runat="server" CssClass="input-large">
                                    </asp:DropDownList>
                                </div>
                            </div>--%>
                            <div class="control-group">
                                <label class="control-label">
                                    Terms
                                </label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlPriceTerm" runat="server">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Design Type
                                </label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlDesignType" runat="server">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Unit
                                </label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlUnits" runat="server">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="control-group">
                                <div class="controls checkbox">
                                    <asp:CheckBox ID="chkIsGST" runat="server" Text="" />Is GST
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    GST
                                </label>
                                <div class="controls">
                                    <div class="input-prepend input-append">
                                        <%--<span class="add-on">$</span> "^([1-9][0-9]*\.[0-9]+)|([0-9]+)$" --%>
                                        <asp:TextBox ID="txtGST" runat="server" CssClass="input-medium"></asp:TextBox>
                                        <span class="add-on">%</span>
                                        <asp:RegularExpressionValidator ID="rfvGST" ControlToValidate="txtGST" ValidationExpression="^(\d+|\d*[.]\d+)%?$"
                                            EnableClientScript="false" ErrorMessage="Please enter a number for GST" runat="server"
                                            ValidationGroup="ValidateQuotesDetail">
                                <img src="Content/img/icon_warning.png"  title="Please enter a number for GST" alt="Please enter a number for GST" />
                                        </asp:RegularExpressionValidator>
                                    </div>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label ">
                                    Price
                                </label>
                                <div class="controls">
                                    <div class="input-prepend input-append">
                                        <span class="add-on">$</span>
                                        <asp:TextBox ID="txtIndimanPrice" runat="server" CssClass="input-medium"></asp:TextBox>
                                        <%-- <span class="add-on">.00</span>--%>
                                    </div>
                                    <asp:RegularExpressionValidator ID="rfvIndimanPrice" ControlToValidate="txtIndimanPrice" ValidationExpression="^[0-9]{0,6}(\.[0-9]{1,2})?$"
                                        EnableClientScript="false" ErrorMessage="Please enter a number for price" runat="server"
                                        ValidationGroup="ValidateQuotesDetail">
                                <img src="Content/img/icon_warning.png"  title="Please enter a number for price" alt="Please enter a number for price" />
                                    </asp:RegularExpressionValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Design Fee
                                </label>
                                <div class="controls">
                                    <div class="input-prepend input-append">
                                        <span class="add-on">$</span>
                                        <asp:TextBox ID="txtDesignFee" CssClass="input-medium" runat="server"></asp:TextBox>
                                        <%-- <span class="add-on">.00</span>--%>
                                        <asp:RegularExpressionValidator ID="rfvDesignFee" ControlToValidate="txtDesignFee" ValidationExpression="^[0-9]{0,6}(\.[0-9]{1,2})?$"
                                            EnableClientScript="false" ErrorMessage="Please enter a number for Design Fee" runat="server"
                                            ValidationGroup="ValidateQuotesDetail">
                                <img src="Content/img/icon_warning.png"  title="Please enter a number for Design Fee" alt="Please enter a number for Design Fee" />
                                        </asp:RegularExpressionValidator>
                                    </div>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Quantity (Units)
                                </label>
                                <div class="controls">
                                    <asp:TextBox ID="txtQty" runat="server"></asp:TextBox>
                                    <asp:RegularExpressionValidator ID="rfvQuantity" ControlToValidate="txtQty" ValidationExpression="^\d*\.?\d+$"
                                        EnableClientScript="false" ErrorMessage="Please enter a number for quantity" runat="server"
                                        ValidationGroup="ValidateQuotesDetail">
                                <img src="Content/img/icon_warning.png"  title="Please enter a number for quantity" alt="Please enter a number for quantity" />
                                    </asp:RegularExpressionValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Notes
                                </label>
                                <div class="controls">
                                    <asp:TextBox ID="txtNotes" TextMode="MultiLine" runat="server"></asp:TextBox>
                                    <asp:CustomValidator ID="cvNotes" runat="server" ErrorMessage="Note length cannot be exceeded 255 characters"
                                        EnableClientScript="false" ControlToValidate="txtNotes" OnServerValidate="cvNotes_OnServerValidate"
                                        ValidationGroup="ValidateQuotesDetail" ValidateEmptyText="true">
                                 <img src="Content/img/icon_warning.png"  title="Note length cannot be exceeded 255 characters" alt="Note length cannot be exceeded 255 characters" />
                                    </asp:CustomValidator>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">
                                    Delivery Date
                                </label>
                                <div class="controls">
                                    <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                        <asp:TextBox ID="txtDeliveryDate" runat="server" CssClass="datepicker"></asp:TextBox>
                                        <span class="add-on"><i class="icon-calendar"></i></span>
                                    </div>
                                    <asp:CustomValidator ID="cvtxtDeliveryDate" runat="server" ErrorMessage="Invalid Delivery Date"
                                        EnableClientScript="false" ControlToValidate="txtDeliveryDate" OnServerValidate="cvDeliveryDate_OnServerValidate"
                                        ValidateEmptyText="true" ValidationGroup="ValidateQuotesDetail">
                             <img src="Content/img/icon_warning.png"  title="Invalid Delivery Date" alt="Invalid Delivery Date" />
                                    </asp:CustomValidator>
                                </div>
                            </div>

                            <div class="iclearfix icenter">
                                <button id="btnQuoteDetail" runat="server" class="btn btn-success" validationgroup="ValidateQuotesDetail" data-loading-text="Adding..." type="submit" onserverclick="btnQuoteDetail_ServerClick">
                                    Add Quote Detail</button>
                            </div>
                            <h4>Added Quote Detail</h4>
                            <asp:DataGrid ID="dgQuoteDetails" runat="server" CssClass="table" AllowCustomPaging="False"
                                AllowPaging="False" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                                OnItemDataBound="dgQuoteDetails_ItemDataBound">
                                <HeaderStyle CssClass="header" />
                                <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                                <Columns>
                                    <asp:TemplateColumn HeaderText="Delivery Date">
                                        <ItemTemplate>
                                            <asp:Literal ID="litDeliveryDate" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Pattern">
                                        <ItemTemplate>
                                            <asp:Literal ID="litPattern" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Fabric">
                                        <ItemTemplate>
                                            <asp:Literal ID="litFabic" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="VisualLayout">
                                        <ItemTemplate>
                                            <asp:Literal ID="litVisualLayout" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Design Type">
                                        <ItemTemplate>
                                            <asp:Literal ID="litDesignType" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Price Term">
                                        <ItemTemplate>
                                            <asp:Literal ID="litPriceTerm" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Qty" ItemStyle-HorizontalAlign="Right">
                                        <ItemTemplate>
                                            <asp:Literal ID="litQty" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Indiman Price" ItemStyle-HorizontalAlign="Right">
                                        <ItemTemplate>
                                            <asp:Literal ID="litIndimanPrice" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Is GST">
                                        <ItemTemplate>
                                            <asp:CheckBox ID="chkIsGST" runat="server" Enabled="false" />
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="GST">
                                        <ItemTemplate>
                                            <asp:Literal ID="litGST" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="Total Value" ItemStyle-HorizontalAlign="Right">
                                        <ItemTemplate>
                                            <asp:Literal ID="litTotal" runat="server"></asp:Literal>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                    <asp:TemplateColumn HeaderText="">
                                        <ItemTemplate>
                                            <div class="btn-group">
                                                <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                    <i class="icon-cog"></i><span class="caret"></span></a>
                                                <ul class="dropdown-menu pull-right" style="position: relative">
                                                    <li>
                                                        <a id="linkEdit" runat="server" class="btn-link iedit" title="Edit Item" onserverclick="linkEdit_ServerClick"><i class="icon-pencil"></i>Edit</a>
                                                    </li>
                                                </ul>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateColumn>
                                </Columns>
                            </asp:DataGrid>
                            <!-- No Orders -->
                            <div id="dvNoQuotes" runat="server" class="alert alert-info">
                                <h4>No quotes have been added.</h4>
                                <p>
                                    Once you add an quote, you'll see the details below.
                                </p>
                            </div>
                            <!-- / -->
                        </div>
                    </div>

                    <!-- / -->
                </div>
                <div class="form-actions">
                    <button id="btnSaveChanges" runat="server" data-loading-text="Saving..." class="btn btn-primary"
                        type="submit" onserverclick="btnSaveChanges_Click" validationgroup="ValidateQuotes">
                        Save Changes</button>
                    <button id="btnSaveChangesSendMail" data-loading-text="Saving..." runat="server"
                        class="btn btn-primary" onserverclick="btnSaveChangesSendMail_Click" validationgroup="ValidateQuotes">
                        Save & Send Mail</button>
                </div>
            </div>
            <!-- / -->
        </div>
        <!-- AddEdit Emails -->
        <div id="dvEmailAddresses" class="modal fade" role="dialog" aria-hidden="true" keyboard="false" data-backdrop="static">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                <h3>Email Addresses</h3>
            </div>
            <div class="modal-body">
                <h5>CC List</h5>
                <div class="stack-wrapper">
                    <asp:ListBox ID="lstBoxCccNewUsers" runat="server" CssClass="pull-right"></asp:ListBox>
                    <div class="pull-right">
                        <button id="ccnext" class="btn" type="button">></button>
                        <button id="ccback" class="btn" type="button"><</button>
                        <button id="ccNextAll" class="btn" type="button">>></button>
                        <button id="ccBackAll" class="btn" type="button"><<</button>
                    </div>
                    <asp:ListBox ID="lstBoxCcExistUsers" runat="server"></asp:ListBox>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
                <button id="btnSaveEmailAddresses" runat="server" class="btn btn-primary isend" type="submit" data-loading-text="Saving..." onserverclick="btnSaveEmailAddresses_OnClick">Save Changes</button>
            </div>
        </div>
        <!-- / -->
        <asp:HiddenField ID="hdnEmailAddressesTo" runat="server" Value="" />
        <asp:HiddenField ID="hdnEmailAddressesCC" runat="server" Value="" />
        <script type="text/javascript">
            var txtDeliveryDate = "<%=txtDeliveryDate.ClientID %>";
            var txtQuoteExpiryDate = "<%=txtQuoteExpiryDate.ClientID %>";
            var lstBoxCcExistUsers = "<%=lstBoxCcExistUsers.ClientID%>";
            var lstBoxCccNewUsers = "<%=lstBoxCccNewUsers.ClientID%>";
            var hdnEmailAddressesTo = "<%=hdnEmailAddressesTo.ClientID%>";
            var hdnEmailAddressesCC = "<%=hdnEmailAddressesCC.ClientID%>";
            var PopulateEmailAddress = ('<%=ViewState["PopulateEmailAddress"]%>' == "True") ? true : false;
            var ddlPattern = "<%=ddlPattern.ClientID%>";
            var ddlFabric = "<%=ddlFabric.ClientID%>";
            //var ddlVisualLayout = "< %=ddlVisualLayout.ClientID%>";
        </script>
        <script type="text/javascript">
            $(document).ready(function () {

                //            $("#" + txtQuoteExpiryDate).datepicker({
                //                changemonth: true,
                //                changeyear: true,
                //                format: 'dd MM yyyy',
                //                mindate: 0,
                //                numberofmonths: 1
                //            });
                //            $("#" + txtDeliveryDate).datepicker({
                //                changeMonth: true,
                //                changeYaer: true,
                //                format: 'dd MM yyyy',
                //                minDate: 0,
                //                numberOfMonths: 1
                //            });
                $('.datepicker').datepicker({ format: 'dd MM yyyy' });

                // $('#dp3').datepicker();

                $('.isend').click(function () {
                    var selectedVal = '';
                    var selectedValCC = '';
                    $('#' + hdnEmailAddressesTo).val('');
                    $('#' + hdnEmailAddressesCC).val('');

                    /* $('#' + lstBoxToNewUsers).find('option').each(function () {
                    selectedVal += $(this).val() + ','
                    $('#' + hdnEmailAddressesTo).val(selectedVal);
                    });*/
                    $('#' + lstBoxCccNewUsers).find('option').each(function () {
                        selectedValCC += $(this).val() + ','
                        $('#' + hdnEmailAddressesCC).val(selectedValCC);
                    });
                });
                if (PopulateEmailAddress) {
                    $('#linkCCEmail').click();
                }

                $('#' + ddlPattern).select2();
                $('#' + ddlFabric).select2();
                //$('#' + ddlVisualLayout).select2();

                /*$('#Tonext').click(function () {
                /*if ($('#' + lstBoxToExistUsers).find('option:selected').val() != undefined) {
                selectedVal += $('#' + lstBoxToExistUsers).find('option:selected').val() + ',';
                }               
                $('#' + hdnEmailAddressesTo).val(selectedVal);
                $('#' + lstBoxToExistUsers).find('option:selected').appendTo($('#' + lstBoxToNewUsers));
                });*/

                /* $('#Toback').click(function () {
                /* selectedVal = selectedVal.split(',');
                selectedVal.splice(selectedVal.valueOf($('#' + lstBoxToNewUsers).find('option:selected').index()), 1)
                $('#' + hdnEmailAddressesTo).val(selectedVal.join(','));
                $('#' + lstBoxToNewUsers).find('option:selected').appendTo($('#' + lstBoxToExistUsers));
                });*/
                /* $('#toNextAll').click(function () {
                //  selectedVal = '';
                /*  $('#' + lstBoxToExistUsers).find('option').each(function () {
                selectedVal += $(this).val() + ','
                $('#' + hdnEmailAddressesTo).val(selectedVal);
                });
                $('#' + lstBoxToExistUsers).find('option').appendTo($('#' + lstBoxToNewUsers));
                });*/
                /* $('#toBackAll').click(function () {
                $('#' + hdnEmailAddressesTo).val('');
                $('#' + lstBoxToNewUsers).find('option').appendTo($('#' + lstBoxToExistUsers));
                });
                */
                $('#ccnext').click(function () {
                    /*  if ($('#' + lstBoxCcExistUsers).find('option:selected').val() != undefined) {
                    selectedValCC += $('#' + lstBoxCcExistUsers).find('option:selected').val() + ',';
                    }
                    $('#' + hdnEmailAddressesCC).val(selectedValCC);*/
                    $('#' + lstBoxCcExistUsers).find('option:selected').appendTo($('#' + lstBoxCccNewUsers));
                });
                $('#ccback').click(function () {
                    /* selectedValCC = selectedValCC.split(',');
                    selectedValCC.splice(selectedValCC.valueOf($('#' + lstBoxCccNewUsers).find('option:selected').index()), 1)
                    $('#' + hdnEmailAddressesCC).val(selectedValCC.join(','));*/
                    $('#' + lstBoxCccNewUsers).find('option:selected').appendTo($('#' + lstBoxCcExistUsers));
                });
                $('#ccNextAll').click(function () {
                    /* selectedValCC = '';
                    $('#' + lstBoxCcExistUsers).find('option').each(function () {
                    selectedValCC += $(this).val() + ','
                    $('#' + hdnEmailAddressesCC).val(selectedValCC);
                    });*/
                    $('#' + lstBoxCcExistUsers).find('option').appendTo($('#' + lstBoxCccNewUsers));
                });
                $('#ccBackAll').click(function () {
                    $('#' + hdnEmailAddressesCC).val('');
                    $('#' + lstBoxCccNewUsers).find('option').appendTo($('#' + lstBoxCcExistUsers));
                });
            });
        </script>
</asp:Content>
