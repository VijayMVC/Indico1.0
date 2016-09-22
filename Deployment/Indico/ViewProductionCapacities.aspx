<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewProductionCapacities.aspx.cs" Inherits="Indico.ViewProductionCapacities" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <style type="text/css">
    </style>
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnNewProductionCapacity" runat="server" class="btn btn-link pull-right"
                   onclick="showConfirmDialog();"></a>
               <%-- <a id="btnNewCorrectDates1" runat="server" class="btn btn-link iadd"
                     onserverclick="btnNewCorrectDates_Click"></a>
                <input type="button" id="btnCorrectDates" runat="server" class="btn btn-primary pull-right" name="CorrectDates" value="1" onserverclick="btnNewCorrectDates_Click"/>--%>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="ialert alert-info">
                    <h4>
                        <a href="<%--javascript:PopulateThisYearProductionCapacity(true);--%>" title="This Year Production Capacity.">This Year Production Capacity.</a>
                    </h4>
                    <p>
                        There are no data for production capacities
                    </p>
                </div>
                <!-- / -->
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <div class="form-inline pull-right">
                            <asp:Label ID="lblDataAdded" runat="server">Data added until</asp:Label>
                            <label>
                                From</label>
                            <asp:DropDownList ID="ddlMonth" runat="server" AutoPostBack="True" CssClass="input-medium"
                                OnSelectedIndexChanged="ddlMonth_SelectedIndexChanged">
                            </asp:DropDownList>
                            <asp:DropDownList ID="ddlYear" runat="server" AutoPostBack="True" CssClass="input-small"
                                OnSelectedIndexChanged="ddlYear_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                        <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>
                    </div>
                    <!-- / -->
                    <!-- Data Table -->
                    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro"
                        EnableEmbeddedSkins="true">
                    </telerik:RadAjaxLoadingPanel>
                    <%-- <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" DefaultLoadingPanelID="RadAjaxLoadingPanel1">
                        <AjaxSettings>
                            <telerik:AjaxSetting AjaxControlID="RadGridProductionCapacities">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadGridProductionCapacities"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                        EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                    </telerik:RadAjaxManager>--%>
                    <telerik:RadGrid ID="RadGridProductionCapacities" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="false" OnPageSizeChanged="RadGridProductionCapacities_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridProductionCapacities_PageIndexChanged" ShowFooter="false"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridProductionCapacities_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridProductionCapacities_ItemCommand"
                        OnSortCommand="RadGridProductionCapacities_SortCommand">
                        <HeaderStyle BorderWidth="1px" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true">
                            <ColumnGroups>
                                <telerik:GridColumnGroup HeaderText="Shirts & Other" Name="Polos" HeaderStyle-HorizontalAlign="Center">
                                </telerik:GridColumnGroup>
                                <telerik:GridColumnGroup HeaderText="Outerwear" Name="Outer" HeaderStyle-HorizontalAlign="Center">
                                </telerik:GridColumnGroup>
                            </ColumnGroups>
                            <Columns>
                                <telerik:GridDateTimeColumn DataField="EstimatedDateOfDespatch" HeaderText="ETD" Groupable="false"
                                    SortExpression="EstimatedDateOfDespatch" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridDateTimeColumn DataField="OrderCutOffDate" HeaderText="Order Cut-Off Date" Groupable="false"
                                    SortExpression="OrderCutOffDate" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridTemplateColumn HeaderText="Week Number" AllowFiltering="False">
                                    <ItemTemplate>
                                        <asp:Label ID="lblWeekNumber" runat="server"></asp:Label>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn HeaderText="Working Days" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" DataField="NoOfHolidays" SortExpression="NoOfHolidays" AllowFiltering="false">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn HeaderText="Hours Per Day" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" DataField="HoursPerDay" SortExpression="HoursPerDay" AllowFiltering="false">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn HeaderText="Holidays" DataField="Notes" AllowSorting="false" AllowFiltering="false">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn HeaderText="Sales Target" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" DataField="SalesTarget" SortExpression="SalesTarget" FilterControlWidth="25px">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="Production Capacity"  ItemStyle-HorizontalAlign="Right" AllowFiltering="False" ColumnGroupName="Polos">
                                    <ItemTemplate>
                                        <asp:Literal ID="litPoloProdCap" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Upto 5Pcs Capacity" ItemStyle-HorizontalAlign="Right"  AllowFiltering="False" ColumnGroupName="Polos">
                                    <ItemTemplate>
                                        <asp:Literal ID="litPolo5PcsCap" runat="server" ></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Samples Capacity" ItemStyle-HorizontalAlign="Right" AllowFiltering="False" ColumnGroupName="Polos">
                                    <ItemTemplate>
                                        <asp:Literal ID="litPoloSamplesCap" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Workers" ItemStyle-HorizontalAlign="Right" AllowFiltering="False" ColumnGroupName="Polos">
                                    <ItemTemplate>
                                        <asp:Literal ID="litPoloWorkers" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Efficiency" ItemStyle-HorizontalAlign="Right" AllowFiltering="False" ColumnGroupName="Polos">
                                    <ItemTemplate>
                                        <asp:Literal ID="litPoloEfficiency" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Production Capacity" ItemStyle-HorizontalAlign="Right" AllowFiltering="False" ColumnGroupName="Outer">
                                    <ItemTemplate>
                                        <asp:Literal ID="litOuterProdCap" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Upto 5Pcs Capacity" ItemStyle-HorizontalAlign="Right" AllowFiltering="False" ColumnGroupName="Outer">
                                    <ItemTemplate>
                                        <asp:Literal ID="litOuter5PcsCap" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Samples Capacity" ItemStyle-HorizontalAlign="Right" AllowFiltering="False" ColumnGroupName="Outer">
                                    <ItemTemplate>
                                        <asp:Literal ID="litOuterSamplesCap" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Workers" ItemStyle-HorizontalAlign="Right" AllowFiltering="False" ColumnGroupName="Outer">
                                    <ItemTemplate>
                                        <asp:Literal ID="litOuterWorkers" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Efficiency" ItemStyle-HorizontalAlign="Right" AllowFiltering="False" ColumnGroupName="Outer">
                                    <ItemTemplate>
                                        <asp:Literal ID="litOuterEfficiency" runat="server"></asp:Literal>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <a id="linkEdit" runat="server" class="btn-link ieditss" onserverclick="linkEdit_ServerClick" title="Edit Production Capacity"><i class="icon-pencil"></i>Edit</a>
                                                </li>
                                                <%--<li>
                                                    <a id="linkSave" runat="server" class="btn-link" onserverclick="linkSave_ServerClick" title="Save Production Capacities"><i class="icon-pencil"></i>Save</a>
                                                </li>--%>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="false">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="false" />
                    </telerik:RadGrid>
                </div>
                <!-- / -->
                <!-- No Search Result -->
                <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                    <h4>Your search - <strong>
                        <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                            any documents.</h4>
                </div>
                <!-- / -->
                <!-- / -->
            </div>
            <!-- / -->
        </div>
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedProductionCapacityID" runat="server" Value="0" />
    <!-- Add / Edit ProductionCapacity -->
    <div id="confirmDialog" class="modal fade" role ="dialog" aria-hidden="true"  data-backdrop="static" style="display: none;">
         <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <label>Confirm to add new weeks!</label>
            </h3>
        </div>
        <div class="modal-body" style="width: inherit">
            <p>Do you want to weeks for the next year ?</p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">No</button>
            <button id="AddNextYearButton" data-dismiss="modal" runat="server" class="btn btn-primary" onserverclick="OnAddNextYearButtonClick" type="submit" >Yes</button>
        </div>
    </div>
    <div id="requestAddEditProductionCapacity" class="modal fade" role="dialog"
        aria-hidden="true" keyboard="false" data-backdrop="static" style="display: none;">
        <!-- Popup Header -->
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                <asp:Label ID="lblPopupHeaderText" runat="server" Text="New Topic"></asp:Label>
            </h3>
        </div>
        <!-- / -->
        <div class="modal-body" style="width: inherit">
            <asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
                ValidationGroup="vgProductCapacity" DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"></asp:ValidationSummary>
            <!-- / -->
            <div id="wrap" style="padding: 0; margin: 0; width: 100%;">
                <%--   <div id="left_div" style="width: 70%; display: inline-block;">--%>
                <legend>Capacity Details</legend>
                <fieldset class="panel" style="margin: 0; padding: 0; background: transparent; border: 0;">
                    <div class="control-group">
                        <label class="control-label">
                            Week no</label>
                        <div class="controls">
                            <asp:Label ID="lblWeekNo" runat="server"></asp:Label>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Saturday of week</label>
                        <div class="controls">
                            <asp:Label ID="lblFridayOfWeekPop" runat="server"></asp:Label>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label  required">
                            Hours per day</label>
                        <div class="controls">
                            <asp:TextBox ID="txtWorkingHours" runat="server" MaxLength="255" Rows="2"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label  required">
                            Working days</label>
                        <div class="controls">
                            <asp:TextBox ID="txtWorkingDays" type="number" min="0" step="1" runat="server" MaxLength="255" Rows="2"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">
                            Holiday description</label>
                        <div class="controls">
                            <asp:TextBox ID="txtNotes" runat="server" CssClass="topic_d" MaxLength="255" TextMode="MultiLine"
                                Rows="2"></asp:TextBox>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label  required">
                            Order cut-off date</label>
                        <div class="controls">
                            <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                <asp:TextBox CssClass="input-medium" ID="txtOrderCutOffDate" runat="server"></asp:TextBox>
                                <span class="add-on"><i class="icon-calendar"></i></span>
                            </div>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label  required">
                            Expected date Of despatch</label>
                        <div class="controls">
                            <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                <asp:TextBox CssClass="input-medium" ID="txtETD" runat="server"></asp:TextBox>
                                <span class="add-on"><i class="icon-calendar"></i></span>
                            </div>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label  required">
                            Expected date of arrival</label>
                        <div class="controls">
                            <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                <asp:TextBox CssClass="input-medium" ID="txtETA" runat="server"></asp:TextBox>
                                <span class="add-on"><i class="icon-calendar"></i></span>
                            </div>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Sales target</label>
                        <div class="controls">
                            <asp:TextBox ID="txtSalesTaget" type="number" min="0" step="1" runat="server"></asp:TextBox>
                        </div>
                    </div>
                </fieldset>
                <asp:Repeater ID="rptItemTypes" runat="server" OnItemDataBound="rptItemTypes_ItemDataBound">
                    <ItemTemplate>
                        <legend>
                            <asp:Literal ID="litItemType" runat="server"></asp:Literal></legend>
                        <fieldset class="panel" style="margin: 0; padding: 0; background: transparent; border: 0;">
                            <div class="form-inline control-group">
                                <label class="control-label  required" style="margin-right: 10px;">Total Capacity (per day)</label>
                                <asp:TextBox ID="txtTotalCapacity" CssClass="total" type="number" min="0" step="0.01" runat="server"></asp:TextBox> per week : <asp:TextBox ID="txtTotalCapacityWeek" runat="server" ReadOnly="True"></asp:TextBox>
                            </div>
                            <div class="form-inline control-group">
                                <label class="control-label  required" style="margin-right: 10px;">Upto 5 Pcs Capacity (per day)</label>
                                <asp:TextBox ID="txt5PcsCapacity" CssClass="fivepcs" type="number" min="0" step="0.01" runat="server"></asp:TextBox> per week : <asp:TextBox ID="txt5PcsCapacityWeek" min="0" step="1" runat="server" ReadOnly="True"></asp:TextBox>
                            </div>
                            <div class="form-inline control-group">
                                <label class="control-label  required" style="margin-right: 10px;">Samples Capacity (per day)</label>    
                                <asp:TextBox ID="txtSampleCapacity" CssClass="sample" type="number" min="0" step="0.01" runat="server"></asp:TextBox> per week : <asp:TextBox ID="txtSampleCapacityWeek"  min="0" step="1" runat="server" ReadOnly="True"></asp:TextBox>
                            </div>

                            <div class="form-inline control-group">
                                <label class="control-label  required" style="margin-right: 10px;">Workers</label>  
                                <asp:TextBox ID="txtWorkers" type="number" min="0" step="1" runat="server"></asp:TextBox> 
                            </div>
                            <div class="form-inline control-group">
                                <label class="control-label  required" style="margin-right: 10px;">Efficiency </label>
                                <asp:TextBox ID="txtEfficiency" type="number"  min="0" step="0.01" runat="server"></asp:TextBox>    
                            </div>
                        </fieldset>
                        <asp:HiddenField ID="hdnProdCapDetailID" runat="server" Value="0" />
                        <asp:HiddenField ID="hdnItemTypeID" runat="server" Value="0" />
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnSaveChanges" runat="server" class="btn btn-primary" onserverclick="btnSaveChanges_Click"
                validationgroup="vgProductCapacity" type="submit">
                Save Changes</button>
        </div>
    </div>
    <!-- / -->
    <!-- / -->
    <!-- Page Scripts -->
    <script type="text/javascript">
        var IsValid = ('<%=ViewState["IsPageValid"]%>' == 'True') ? true : false;
        var IsPopulateModel = ('<%=ViewState["IsPopulateModel"]%>' === 'True') ? true : false;
        var hdnSelectedProductionCapacityID = "<%=hdnSelectedProductionCapacityID.ClientID %>";
        var lblFridayOfWeekPop = "<%=lblFridayOfWeekPop.ClientID %>";
        var lblWeekNo = "<%=lblWeekNo.ClientID %>";
        var txtNotes = "<%=txtNotes.ClientID %>";
        var btnSaveChanges = "<%=btnSaveChanges.ClientID %>";
        var txtSalesTaget = "<%=txtSalesTaget.ClientID %>";
    </script>
    <script type="text/javascript">
        // this function sets values after calculations (should call when a control value changed)
        function setupControlValues() {
            <% if (rptItemTypes.Items.Count > 0) %>
            <%
               { %>
            <% var polo = rptItemTypes.Items[0];%>
            <% var outerware = rptItemTypes.Items[1];%>
            var workingDays = parseInt($('#<%=txtWorkingDays.ClientID%>').val());
            var polototalcapacity = $('#<%=polo.FindControl("txtTotalCapacity").ClientID%>');
            var polototalcapacityWeek = $('#<%=polo.FindControl("txtTotalCapacityWeek").ClientID%>');
            var polouptoFiveCapacity = $('#<%=polo.FindControl("txt5PcsCapacity").ClientID%>');
            var polouptoFiveCapacityWeek = $('#<%=polo.FindControl("txt5PcsCapacityWeek").ClientID%>');
            var poloSampleCapacity = $('#<%=polo.FindControl("txtSampleCapacity").ClientID%>');
            var poloSampleCapacityWeek = $('#<%=polo.FindControl("txtSampleCapacityWeek").ClientID%>');
            var outerwaretotalcapacity = $('#<%=outerware.FindControl("txtTotalCapacity").ClientID%>');
            var outerwaretotalcapacityWeek = $('#<%=outerware.FindControl("txtTotalCapacityWeek").ClientID%>');
            var outerwareuptoFiveCapacity = $('#<%=outerware.FindControl("txt5PcsCapacity").ClientID%>');
            var outerwareuptoFiveCapacityWeek = $('#<%=outerware.FindControl("txt5PcsCapacityWeek").ClientID%>');
            var outerwareSampleCapacity = $('#<%=outerware.FindControl("txtSampleCapacity").ClientID%>');
            var outerwareSampleCapacityWeek = $('#<%=outerware.FindControl("txtSampleCapacityWeek").ClientID%>');

            polototalcapacityWeek.val(Math.round(polototalcapacity.val() * workingDays));
            polouptoFiveCapacityWeek.val(Math.round(polouptoFiveCapacity.val() * workingDays));
            poloSampleCapacityWeek.val(Math.round(poloSampleCapacity.val() * workingDays));

            outerwaretotalcapacityWeek.val(Math.round(outerwaretotalcapacity.val() * workingDays));
            outerwareuptoFiveCapacityWeek.val(Math.round(outerwareuptoFiveCapacity.val() * workingDays));
            outerwareSampleCapacityWeek.val(Math.round(outerwareSampleCapacity.val() * workingDays));
            <% } %>
        }
        //setup chnage events of modal controls
        function SetupChangeEvents() {
            $('#<%=txtWorkingDays.ClientID%>').on("input", setupControlValues);
            $(".total").on("input", setupControlValues);
            $(".fivepcs").on("input", setupControlValues);
            $(".sample").on("input", setupControlValues);
        }

        function showConfirmDialog() {
            $('#confirmDialog').modal('show');
        }

        $(document).ready(function () {
            if (!IsValid) {
                window.setTimeout(function () {
                    $('#requestAddEditProductionCapacity').modal('show');
                }, 10);
            }

            $('.datepicker').datepicker({ format: 'dd MM yyyy' });

            $('.ieditss').click(function () {
                $('#' + hdnSelectedProductionCapacityID).val($(this).attr('qid'));
            });
            function populateDetails(o) {
                $('div.alert-danger, span.error').hide();
                $('#requestAddEditProductionCapacity').modal('show');
            }

            if (IsPopulateModel) {
                populateDetails(this);
            }
        });

        SetupChangeEvents();
    </script>
    <!-- / -->
</asp:Content>
