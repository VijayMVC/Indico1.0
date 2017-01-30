<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
	CodeBehind="AddEditClientOrder.aspx.cs" Inherits="Indico.AddEditClientOrder" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
	<!-- Page -->
	<div class="page">
		<!-- Page Header -->
		<div class="page-header">
			<h1>
				<asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h1>
		</div>
		<!-- / -->
		<!-- Page Content -->
		<div class="page-content">
			<div id="dvPageContent" runat="server" class="inner">
				<!-- Page Validation -->
				<asp:ValidationSummary ID="validationSummary" runat="server" CssClass="alert alert-danger"
					DisplayMode="BulletList" HeaderText="<strong>Errors were encountered while trying to process the form below</strong>"
					ValidationGroup="valGrpOrderHeader"></asp:ValidationSummary>
				<!-- / -->
				<!-- Page Data -->
				<ul class="itoggler-ul">
					<li class="itoggle-row">
						<div class="itoggle-header active">
							<h3>General Details</h3>
						</div>
						<div class="itoggle-content" style="display: block;">
							<fieldset>
								<h4>
									<asp:Literal ID="litCoordinator" runat="server" Text="Your coordinator is "></asp:Literal>
								</h4>
								<p class="required">
									Indicates required fields
								</p>
								<ol>
									<li>
										<label>
											Date</label>
										<asp:TextBox ID="txtDate" runat="server" Enabled="false"></asp:TextBox>
									</li>
									<li>
										<label class="required">
											Desired Date</label>
										<asp:TextBox ID="txtDesiredDate" runat="server" CssClass="datePick"></asp:TextBox>
										<asp:RequiredFieldValidator ID="rfvDesiredDate" runat="server" ErrorMessage="Desired Date is required." ControlToValidate="txtDesiredDate" ValidationGroup="valGrpOrderHeader" EnableClientScript="false" Display="Dynamic">
											<img src="Content/img/icon_warning.png"  title="Desired Date is required." alt="Desired Date is required." />
										</asp:RequiredFieldValidator>
										<p class="extra-helper">
											(Please consider order processing period is 4 weeks)
										</p>
									</li>
									<li>
										<label class="required">
											Your Refference</label>
										<asp:TextBox ID="txtRefference" runat="server"></asp:TextBox>
										<asp:RequiredFieldValidator ID="rfvRefference" runat="server" ErrorMessage="Refference is required." ControlToValidate="txtRefference" ValidationGroup="valGrpOrderHeader" EnableClientScript="false" Display="Dynamic">
											<img src="Content/img/icon_warning.png"  title="Refference is required." alt="Refference is required." />
										</asp:RequiredFieldValidator>
									</li>
									<li>
										<label class="required">
											Client / Job Name</label>
										<asp:DropDownList ID="ddlClientOrJobName" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlClientOrJobName_SelectedIndexChanged">
										</asp:DropDownList>
										<asp:RequiredFieldValidator ID="rfvClientOrJobName" runat="server" ErrorMessage="Client / Job Name is required." ControlToValidate="ddlClientOrJobName" ValidationGroup="valGrpOrderHeader" InitialValue="0" EnableClientScript="false" Display="Dynamic">
											<img src="Content/img/icon_warning.png"  title="Client / Job Name is required." alt="Client / Job Name is required." />
										</asp:RequiredFieldValidator>
									</li>
								</ol>
							</fieldset>
						</div>
					</li>
					<li class="itoggle-row">
						<div class="itoggle-header active">
							<h3>Order Details</h3>
						</div>
						<div class="itoggle-content">
							<fieldset>
								<h3></h3>
								<h5>New Order Detail</h5>
								<ol>
									<li>
										<label class="required">
											Order Type</label>
										<asp:DropDownList ID="ddlOrderType" runat="server">
										</asp:DropDownList>
										<asp:RequiredFieldValidator ID="rfvOrderType" runat="server" ErrorMessage="Order Type is required." ControlToValidate="ddlOrderType" InitialValue="0" ValidationGroup="valGrpOrder" EnableClientScript="false" Display="Dynamic">
											<img src="Content/img/icon_warning.png"  title="Order Type is required." alt="Order Type is required." />
										</asp:RequiredFieldValidator>
									</li>
									<li>
										<label class="required">
											Visual Layout</label>
										<asp:DropDownList ID="ddlVlNumber" runat="server" AutoPostBack="true" Enabled="false"
											CssClass="firePopupChange" OnSelectedIndexChanged="ddlVlNumber_SelectedIndexChange"
											Url="/AddEditClientOrder.aspx">
										</asp:DropDownList>
										<div class="search-control">
											<asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
												<input id="txtVLSearch" runat="server" disabled="disabled" class="search-control-query" type="text" />
												<input class="search-control-button" type="button" />
												<input class="search-control-clear" type="button" />
											</asp:Panel>
										</div>
										<asp:RequiredFieldValidator ID="rfvVlNumber" runat="server" ErrorMessage="Visual Layout Number is required" ControlToValidate="ddlVlNumber" InitialValue="0" ValidationGroup="valGrpOrder" EnableClientScript="false" Display="Dynamic">
											<img src="Content/img/icon_warning.png"  title="Visual Layout Number is required" alt="Visual Layout Number is required" />
										</asp:RequiredFieldValidator>
										<a id="ancVlImagePreview" runat="server" visible="false"></a></li>
									<li>
										<ol id="olSizeQuantities" class="ioderlist-table">
											<asp:Repeater ID="rptSizeQty" runat="server" OnItemDataBound="rptSizeQty_ItemDataBound">
												<ItemTemplate>
													<li class="idata-column">
														<ul>
															<li class="icell-header">
																<asp:Literal ID="litHeading" runat="server"></asp:Literal>
															</li>
															<li class="icell-data">
																<asp:TextBox ID="txtQty" runat="server" CssClass="iintiger" Width="40"></asp:TextBox>
																<asp:HiddenField ID="hdnQtyID" runat="server" Value="0" />
															</li>
														</ul>
													</li>
												</ItemTemplate>
											</asp:Repeater>
										</ol>
									</li>
									<li>
										<label>
											Total Quantity
										</label>
										<asp:Label ID="lblTotalQty" runat="server" Text=""></asp:Label>
									</li>
									<li>
										<label>
											Visual Layout Notes</label>
										<asp:TextBox ID="txtVlNotes" runat="server" TextMode="MultiLine"></asp:TextBox>
									</li>
									<!-- name and nunber file -->
									<li>
										<fieldset id="fsNameNumberFile" runat="server" class="icenter" visible="false">
											<asp:Image ID="imgNameNumberFile" runat="server" />
											<asp:Label ID="lblNameNumberFileName" runat="server" Text=""></asp:Label>
										</fieldset>
									</li>
									<!-- / -->
									<li>
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
									</li>
									<li>
										<label>
											File</label>
										<div id="dropzone_1" class="fileupload preview">
											<input id="file_1" name="file_1" type="file" />
											<button id="btnup_1" type="submit">
												Upload</button>
											<div id="divup_1">
												Drag file here or click to upload
											</div>
										</div>
										<p class="extra-helper">
											<strong>Hint:</strong> You can drag & drop files from your desktop on this webpage
											with Google Chrome, Mozilla Firefox and Apple Safari.
											<!--[if IE]>
												<strong>Microsoft Explorer has currently no support for Drag & Drop or multiple file selection.</strong>
											<![endif]-->
										</p>
									</li>
								</ol>
								<div class="iaccess-bar iclearfix icenter">
									<asp:Button ID="btnAdd" runat="server" CssClass="btn btn-success" OnClick="btnAdd_Click"
										Text="Add Order Detail" Url="/AddEditClientOrder.aspx" ValidationGroup="valGrpOrder" />
								</div>
								<h3></h3>
								<h5>Added Order Details</h5>
								<ol>
									<li>
										<!-- Data Table -->
										<asp:DataGrid ID="dgOrderItems" runat="server" CssClass="table" AllowCustomPaging="False"
											AllowPaging="False" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
											OnItemDataBound="dgOrderItems_ItemDataBound">
											<HeaderStyle CssClass="header" />
											<PagerStyle CssClass="idata-pager" Mode="NumericPages" />
											<Columns>
												<asp:TemplateColumn HeaderText="Order Type" ItemStyle-Width="10%">
													<ItemTemplate>
														<asp:Label ID="lblOrderType" runat="server" Text=""></asp:Label>
													</ItemTemplate>
												</asp:TemplateColumn>
												<asp:TemplateColumn HeaderText="VL Number / Pattern Number / Fabric" ItemStyle-Width="18%">
													<ItemTemplate>
														<asp:Label ID="lblVLNumber" runat="server" Text=""></asp:Label>
													</ItemTemplate>
												</asp:TemplateColumn>
												<asp:TemplateColumn HeaderText="Visual Layout Image" ItemStyle-Width="4%">
													<ItemTemplate>
														<a id="ancVLImage" runat="server"></a>
													</ItemTemplate>
												</asp:TemplateColumn>
												<asp:TemplateColumn HeaderText="Quantities" ItemStyle-Width="38%">
													<ItemTemplate>
														<ol class="ioderlist-table">
															<asp:Repeater ID="rptSizeQtyView" runat="server" OnItemDataBound="rptSizeQtyView_ItemDataBound">
																<ItemTemplate>
																	<li class="idata-row">
																		<ul>
																			<li class="icell-header">
																				<asp:Literal ID="litHeading" runat="server"></asp:Literal>
																			</li>
																			<li class="icell-data">
																				<asp:Label ID="lblQty" runat="server" Text=""></asp:Label>
																			</li>
																		</ul>
																	</li>
																</ItemTemplate>
															</asp:Repeater>
														</ol>
													</ItemTemplate>
												</asp:TemplateColumn>
												<asp:TemplateColumn HeaderText="VL Notes" ItemStyle-Width="18%">
													<ItemTemplate>
														<asp:Label ID="lblVlNotes" runat="server" Text=""></asp:Label>
													</ItemTemplate>
												</asp:TemplateColumn>
												<asp:TemplateColumn HeaderText="Name & Number File" ItemStyle-Width="8%">
													<ItemTemplate>
														<a id="ancNameNumberFile" runat="server" title="Name & Number File" href="javascript:void(0);"></a>
													</ItemTemplate>
												</asp:TemplateColumn>
												<asp:TemplateColumn HeaderText="Edit" ItemStyle-Width="4%">
													<ItemTemplate>
														<a id="linkEdit" runat="server" class="btn-link iedit" title="Edit Item" onserverclick="linkEdit_Click"></a>
													</ItemTemplate>
												</asp:TemplateColumn>
												<asp:TemplateColumn HeaderText="Delete" ItemStyle-Width="4%">
													<ItemTemplate>
														<asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Order"></asp:HyperLink>
													</ItemTemplate>
												</asp:TemplateColumn>
											</Columns>
										</asp:DataGrid>
										<!-- / -->
										<!-- No Orders -->
										<div id="dvNoOrders" runat="server" class="alert alert-info">
											<h2>No orders have been added.</h2>
											<p>
												Once you add an order, you'll see the details below.
											</p>
										</div>
										<!-- / -->
									</li>
								</ol>
							</fieldset>
						</div>
					</li>
					<li class="itoggle-row">
						<div class="itoggle-header active">
							<h3>Shipment Mode
							</h3>
						</div>
						<div class="itoggle-content">
							<fieldset>
								<ol>
									<li>
										<label class="required">
											Ship To</label>
									</li>
									<li>
										<label class="checkbox">
											<asp:RadioButton ID="rbAdelaideOffice" runat="server" CssClass="iweekly" GroupName="shiptoMethod"
												Checked="true" />Pick up from Indico Adelaide office
										</label>
									</li>
									<li>
										<label class="checkbox">
											<asp:RadioButton ID="rbCourier" runat="server" CssClass="icourier" GroupName="shiptoMethod" />
											Special international courier delivery
										</label>
										<label style="color: Red">
											(International courier charges apply. Please obtain estimate from coordinator).</label>
									</li>
									<li id="liSelectOption" runat="server" style="display: none">
										<label class="checkbox">
											<asp:RadioButton ID="rbShipToMe" runat="server" CssClass="isdistributor" Checked="true"
												GroupName="shipto" />
											Ship To Me
										</label>
										<label class="checkbox isuffix">
											<asp:RadioButton ID="rbShipToMyClient" runat="server" CssClass="isedistributor" GroupName="shipto" />
											Ship to My Client
										</label>
										<label class="checkbox isuffix">
											<asp:RadioButton ID="rbShipToNewClient" runat="server" CssClass="isnewclient" GroupName="shipto" />
											Ship to New Client
										</label>
									</li>
								</ol>
								<div id="dvCourier" runat="server">
									<ol id="olMyAddress" runat="server" style="display: none;">
										<li>
											<label id="lblMyAddress" runat="server">
											</label>
										</li>
									</ol>
									<ol id="olShipToMyClient" runat="server" style="display: none">
										<li>
											<label class="required">
												Existing Clients</label>
											<asp:DropDownList ID="ddlShipToMyClients" runat="server">
											</asp:DropDownList>
										</li>
									</ol>
									<ol id="olDeliveryInformation" runat="server" style="display: none">
										<li>
											<label class="required">
												Contact Name</label>
											<asp:TextBox ID="txtShipToContactName" runat="server"></asp:TextBox>
										</li>
										<li>
											<label class="required">
												Address</label>
											<asp:TextBox ID="txtShipToAddress" runat="server"></asp:TextBox>
											<p class="extra-helper" style="color: Red">
												Street Address required. PO Box not acceptable
											</p>
										</li>
										<li>
											<label class="required">
												Suburb</label>
											<asp:TextBox ID="txtShipToSuburb" runat="server"></asp:TextBox>
										</li>
										<li>
											<label class="required">
												Post Code</label>
											<asp:TextBox ID="txtShipToPostCode" runat="server"></asp:TextBox>
										</li>
										<li>
											<label class="required">
												Country</label>
											<asp:DropDownList ID="ddlShipToCountry" runat="server">
											</asp:DropDownList>
										</li>
										<li>
											<label class="required">
												Phone Number</label>
											<asp:TextBox ID="txtShipToPhone" runat="server"></asp:TextBox>
										</li>
									</ol>
								</div>
							</fieldset>
						</div>
					</li>
					<div class="form-actions">
						<asp:Button ID="btnSaveChanges" runat="server" CssClass="btn btn-primary" Text="Submit"
							OnClick="btnSaveChanges_Click" ValidationGroup="valGrpOrderHeader" />
					</div>
					<!-- / -->
				</ul>
			</div>
		</div>
		<!-- / -->
	</div>
	<!-- / -->
	<asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
	<!-- Delete Item -->
	<div id="requestDeleteOrder" class="modal">
		<div class="modal-header">
			<h2>Delete Order</h2>
			<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		</div>
		<div class="modal-body">
			Are you sure you wish to delete this order?
		</div>
		<div class="modal-footer">
			<asp:Button ID="btnDeleteOrderItem" runat="server" CssClass="btn" Text="Yes"
				Url="/AddEditClientOrder.aspx" OnClick="btnDeleteOrderItem_Click" />
			<input id="btnDeleteOrderItemCancel" class="btn firePopupCancel" type="button"
				value="No" />
		</div>
	</div>
	<!-- / -->
	<!-- Delete Existing Order Items -->
	<div id="requestDeleteOrders" class="modal">
		<asp:HiddenField ID="hdnSelectedClientId" runat="server" Value="0" />
		<div class="modal-header">
			<h2>Delete Order Items</h2>
			<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		</div>
		<div class="modal-body">
			There are some order items associated with this client,Are you sure you wish to
			delete this order items?
		</div>
		<div class="modal-footer">
			<asp:Button ID="btnDeleteOrderItems" runat="server" CssClass="btn" Text="Yes"
				Url="/AddEditClientOrder.aspx" OnClick="btnDeleteOrderItems_Click" />
			<asp:Button ID="btnDeleteOrderItemsCancel" runat="server" CssClass="btn" Text="No"
				Url="/AddEditClientOrder.aspx" OnClick="btnDeleteOrderItemsCancel_Click" />
		</div>
	</div>
	<!-- / -->
	<!-- Page Scripts -->
	<script type="text/javascript">
		var txtDate = '<%=txtDate.ClientID%>';
		var txtDesiredDate = '<%=txtDesiredDate.ClientID%>';
		var PopulateDeleteOrdersMsg = ('<%=ViewState["PopulateDeleteOrdersMsg"]%>' == 'True') ? true : false;
		var ddlVlNumber = "<%=ddlVlNumber.ClientID %>";
		var txtVLSearch = "<%=txtVLSearch.ClientID %>";
		var ddlClientOrJobName = "<%=ddlClientOrJobName.ClientID %>";
		var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
		var lblTotalQty = "<%=lblTotalQty.ClientID %>";

		var rbCourier = "<%=rbCourier.ClientID %>";
		var liSelectOption = "<%=liSelectOption.ClientID %>";
		var dvCourier = "<%=dvCourier.ClientID %>";
		var rbShipToMe = "<%=rbShipToMe.ClientID %>";
		var olMyAddress = "<%=olMyAddress.ClientID %>";
		var rbShipToMyClient = "<%=rbShipToMyClient.ClientID %>";
		var olShipToMyClient = "<%=olShipToMyClient.ClientID %>";
		var rbShipToNewClient = "<%=rbShipToNewClient.ClientID %>";
		var olDeliveryInformation = "<%=olDeliveryInformation.ClientID %>";
		var rbAdelaideOffice = "<%=rbAdelaideOffice.ClientID %>";
	</script>
	<script type="text/javascript">
		$(document).ready(function () {
			var dates = $("#" + txtDate + ", #" + txtDesiredDate).datepicker({
				changeMonth: true,
				dateFormat: 'dd MM yy',
				minDate: 0,
				numberOfMonths: 1,
				onSelect: function (selectedDate) {
					var option = this.id == txtDate ? "minDate" : "maxDate",
					instance = $(this).data("datepicker");
					date = $.datepicker.parseDate(
						instance.settings.dateFormat ||
						$.datepicker._defaults.dateFormat,
						selectedDate, instance.settings);
					dates.not(this).datepicker("option", option, date);
				}
			});
		});

		AdelaideOffice();
		Courier();

		$('#' + rbAdelaideOffice).change(function () {
			AdelaideOffice();
		});

		$('#' + rbCourier).change(function () {
			Courier();
		});

		$('#' + rbShipToMe).change(function () {
			ShipToMe();
		});

		$('#' + rbShipToMyClient).change(function () {
			ShipToMyClient();
		});

		$('#' + rbShipToNewClient).change(function () {
			ShipToNewClient();
		});

		function AdelaideOffice() {
			if ($('#' + rbAdelaideOffice).is(":checked")) {
				$('#' + dvCourier).hide();
				$('#' + liSelectOption).hide();
				ShipToMe();
				ShipToMyClient();
				ShipToNewClient();
			}
			else {
				$('#' + dvCourier).show();
				$('#' + liSelectOption).show();
			}
		}

		function Courier() {
			if ($('#' + rbCourier).is(":checked")) {
				$('#' + dvCourier).show();
				$('#' + liSelectOption).show();
				ShipToMe();
				ShipToMyClient();
				ShipToNewClient();
			}
			else {
				$('#' + dvCourier).hide();
				$('#' + liSelectOption).hide();
			}
		}

		function ShipToMe() {
			if ($('#' + rbCourier).is(":checked") && $('#' + rbShipToMe).is(":checked")) {
				$('#' + dvCourier).show();
				$('#' + olMyAddress).show();
				$('#' + olShipToMyClient).hide();
				$('#' + olDeliveryInformation).hide();
			}
			else {
				$('#' + olMyAddress).hide();
			}
		}

		function ShipToMyClient() {
			if ($('#' + rbCourier).is(":checked") && $('#' + rbShipToMyClient).is(":checked")) {
				$('#' + dvCourier).show();
				$('#' + olMyAddress).hide();
				$('#' + olShipToMyClient).show();
				$('#' + olDeliveryInformation).hide();
			}
			else {
				$('#' + olShipToMyClient).hide();
			}
		}

		function ShipToNewClient() {
			if ($('#' + rbCourier).is(":checked") && $('#' + rbShipToNewClient).is(":checked")) {
				$('#' + dvCourier).show();
				$('#' + olMyAddress).hide();
				$('#' + olShipToMyClient).hide();
				$('#' + olDeliveryInformation).show();
			}
			else {
				$('#' + olDeliveryInformation).hide();
			}
		}

		$('.iintiger').keyup(function () {
			calculateTotalQty();
		});

		calculateTotalQty();

		if (PopulateDeleteOrdersMsg) {
			window.setTimeout(function () {
				populateDeleteOrdersMessage();
			}, 10);
		}

		$('.idelete').click(function () {
			$('#' + hdnSelectedID)[0].value = $(this).attr('qid');
			showPopupBox('requestDeleteOrder')
		});

		function populateDeleteOrdersMessage() {
			showPopupBox('requestDeleteOrders');
		}

		function calculateTotalQty() {
			var qty = 0;
			$('#olSizeQuantities input[type=text]').each(function () {
				qty += Number($(this)[0].value);
			});

			$('#' + lblTotalQty).text(qty);
		}

		$('#' + txtVLSearch).keyup(function () {
			var filterdItems = $("#" + ddlVlNumber + " option:contains('" + $(this)[0].value + "')");
			$('#' + ddlVlNumber).val('0');
			$('#' + ddlVlNumber + ' option').hide();
			$("#" + ddlVlNumber + " option[value=0]").show();
			$(filterdItems).show();
		});
	</script>
	<!-- / -->
</asp:Content>
