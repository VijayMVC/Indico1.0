<%@ Page EnableEventValidation="False" Language="C#" AutoEventWireup="true" CodeBehind="InventoryItem.aspx.cs" MasterPageFile="~/Indico.Master" Inherits="Indico.InventoryItem" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <asp:ScriptManager runat="server"></asp:ScriptManager>
    <asp:HiddenField ID="hdnSelectedItemID" runat="server" Value="0" />
    <div class="page">
        <div class="page-header">
            <div class="header-actions">
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>

        <div class="page-content">

            <div class="row-fluid">
                <div class="wrapper">
                     <input id="txtSearch" runat="server" name="txtSearch" size="20" class="riTextBox riEnabled" type="text" value="" style="height: 25px;" />
                     <%--<asp:Button runat="server" CssClass="btn btn-primary" ID="SearchGoButton" OnClick="SearchGoButton_Click" Text="Go"/>--%>
                     <button type="button" id="searchbutton" onserverclick="searchbutton_ServerClick" runat="server" class="btn btn-info"><i class="icon-search"></i></button>

                    <div class="pull-right">
                        <input type="button" class="btn btn-primary" runat="server" value="New Item" id="btnAdd" style="height: 25px;"/><br />
                    </div>
                    <br />
                    <br />
                    <telerik:RadGrid ID="ItemGrid" runat="server" AllowPaging="true" AllowFilteringByColumn="true" 
                        ShowGroupPanel="true" ShowFooter="false" OnPageSizeChanged="ItemGrid_PageSizeChanged" OnItemCommand="ItemGrid_ItemCommand"
                        PageSize="20" OnPageIndexChanged="ItemGrid_PageIndexChanged" EnableHeaderContextMenu="true"
                        EnableHeaderContextFilterMenu="true" AutoGenerateColumns="false" OnItemDataBound="ItemGrid_ItemDataBound" OnSortCommand="ItemGrid_SortCommand"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true" >
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <GroupingSettings CaseSensitive="false" />
                        <MasterTableView AllowFilteringByColumn="true" TableLayout="Auto" GroupsDefaultExpanded="false">
                            <Columns>
                                 <telerik:GridBoundColumn  DataField="Code"  SortExpression="Code" HeaderText="Code"
                                     Groupable="True" UniqueName="Code" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Name"  SortExpression="Name" HeaderText="Name"
                                     Groupable="True" UniqueName="Name" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Category"  SortExpression="Category" HeaderText="Category"
                                     Groupable="True" UniqueName="Category" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="SubCategory"  SortExpression="SubCategory" HeaderText="Sub Category"
                                     Groupable="True" UniqueName="SubCategory" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Colour"  SortExpression="Colour" HeaderText="Colour"
                                     Groupable="True" UniqueName="Colour" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Attribute"  SortExpression="Attribute" HeaderText="Attribute"
                                     Groupable="True" UniqueName="Attribute" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="MinLevel"  SortExpression="MinLevel" HeaderText="Min Level"
                                     Groupable="True" UniqueName="MinLevel" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Uom"  SortExpression="Uom" HeaderText="UOM"
                                     Groupable="True" UniqueName="Uom" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="SupplierCode"  SortExpression="SupplierCode" HeaderText="Supplier"
                                     Groupable="True" UniqueName="SupplierCode" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Purchaser"  SortExpression="PurchaserId" HeaderText="Purchaser"
                                     Groupable="True" UniqueName="PurchaserId" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 
                                 <telerik:GridBoundColumn  DataField="Status"  SortExpression="Status" HeaderText="Status"
                                     Groupable="True" UniqueName="Status" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>

                                  <telerik:GridTemplateColumn UniqueName="UserFunctions" HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Item"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                                </li>
                                                
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>

                            </Columns>

                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="True" AllowGroupExpandCollapse="true" AllowExpandCollapse="true">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="true" />
                    </telerik:RadGrid>
                </div>

                  
            </div>
        </div>
    </div>


    <!--Modals-->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete Item</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Item?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                Close</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" onserverclick="btnDelete_ServerClick"
                data-loading-text="Deleting..." type="submit">
                Yes</button>
        </div>
    </div>
    <!--Modals-->

    <div id="requestAddEdit" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            
               <h3 id="lbledit">Edit Item</h3>
            <h3 id="lbladd">Add Item</h3>
        </div>
        <div class="modal-body">
            <asp:UpdatePanel runat="server">
                 <ContentTemplate>
                        <div class="alert alert-danger" id="dvAlert" style="display:none;">
              
                </div>
                      <div class="control-group">
                    <label class="control-label required">
                        Code</label>
                    <div class="controls">
                        <asp:TextBox ID="txtCode" runat="server" MaxLength="128"></asp:TextBox>
                                              
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Name</label>
                    <div class="controls">
                        <asp:TextBox ID="txtName" runat="server" MaxLength="128"></asp:TextBox>
                                              
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Category</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlCategory" DataValueField="ID" DataTextField="Name" runat="server" CssClass="topic_d" MaxLength="255" AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged"></asp:DropDownList>
                        <%--                        <asp:RequiredFieldValidator ID="rfvCategory" runat="server" CssClass="error" ControlToValidate="ddlCategory"
                                Display="Dynamic" EnableClientScript="False" ErrorMessage="Category is required">
                                    <img src="Content/img/icon_warning.png" title="Category is required" alt="Category is required" />
                            </asp:RequiredFieldValidator>--%>
                    </div>
                </div>


                <div class="control-group">
                    <label class="control-label required">
                        Sub Category</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlSubCat" runat="server" AutoPostBack="true" DataValueField="ID" DataTextField="Name" CssClass="topic_d"  MaxLength="255"></asp:DropDownList>
                        <%--                        <asp:RequiredFieldValidator ID="RfvddlSubCat" runat="server" CssClass="error" ControlToValidate="ddlSubCat"
                                Display="Dynamic" EnableClientScript="False" ErrorMessage="Sub Category is required">
                                    <img src="Content/img/icon_warning.png" title="Sub Category is required" alt="Sub Category is required" />
                            </asp:RequiredFieldValidator>--%>
                    </div>
                </div>


                <div class="control-group">
                    <label class="control-label required">
                        Colour</label>
                    <div class="controls">
                        <asp:TextBox ID="txtColor" runat="server" CssClass="topic_d" MaxLength="255"></asp:TextBox>
                        <%--                        <asp:RequiredFieldValidator ID="RfvColour" runat="server" CssClass="error" ControlToValidate="Colour"
                                Display="Dynamic" EnableClientScript="False" ErrorMessage="Colour is required">
                                    <img src="Content/img/icon_warning.png" title="Colour is Required" alt="Colour is required" />
                            </asp:RequiredFieldValidator>--%>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label required">
                        Attribute</label>
                    <div class="controls">
                        <asp:TextBox ID="txtAttribute" runat="server" CssClass="topic_d" MaxLength="255"></asp:TextBox>
                        <%--                        <asp:RequiredFieldValidator ID="RfvAttribute" runat="server" CssClass="error" ControlToValidate="Attribute"
                                Display="Dynamic" EnableClientScript="False" ErrorMessage="Attribute is required">
                                    <img src="Content/img/icon_warning.png" title="Attribute is Required" alt="Attribute is required" />
                            </asp:RequiredFieldValidator>--%>
                    </div>
                </div>


                <div class="control-group">
                    <label class="control-label required">
                        Min Level</label>
                    <div class="controls">
                        <asp:TextBox ID="txtMinLevel" runat="server" CssClass="topic_d" MaxLength="255"></asp:TextBox>
                        <%--                        <asp:RequiredFieldValidator ID="RfvMinLevel" runat="server" CssClass="error" ControlToValidate="MinLevel"
                                Display="Dynamic" EnableClientScript="False" ErrorMessage="MinLevel is required">
                                    <img src="Content/img/icon_warning.png" title="MinLevel is Required" alt="MinLevel is required" />
                            </asp:RequiredFieldValidator>--%>
                    </div>
                </div>


                <div class="control-group">
                    <label class="control-label required">
                        Unit of Measure</label>
                    <div class="controls">
                        <asp:DropDownList ID="Uom" AutoPostBack="true"  DataValueField="ID" DataTextField="Name" runat="server" CssClass="topic_d" MaxLength="255"></asp:DropDownList>
                        <%--                        <asp:RequiredFieldValidator ID="RfvUom" runat="server" CssClass="error" ControlToValidate="Uom"
                                Display="Dynamic" EnableClientScript="False" ErrorMessage="Unit of Measure is required">
                                    <img src="Content/img/icon_warning.png" title="Unit of Measure is Required" alt="Unit of Measure is required" />
                            </asp:RequiredFieldValidator>--%>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label required">
                        Supplier</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlSuplierCode" AutoPostBack="true" DataValueField="ID" DataTextField="Name" runat="server" CssClass="topic_d" MaxLength="255"></asp:DropDownList>
                        <%--                        <asp:RequiredFieldValidator ID="RfvSupplierCode" runat="server" CssClass="error" ControlToValidate="SupplierCode"
                                Display="Dynamic" EnableClientScript="False" ErrorMessage="Supplier Code is required">
                                    <img src="Content/img/icon_warning.png" title="Supplier Code is Required" alt="Supplier Code is required" />
                            </asp:RequiredFieldValidator>--%>
                    </div>
                </div>


                <div class="control-group">
                    <label class="control-label required">
                        Purchaser</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlPurchaser" AutoPostBack="true" DataValueField="ID" DataTextField="Name" runat="server" CssClass="topic_d" MaxLength="255"></asp:DropDownList>
                        <%--                        <asp:RequiredFieldValidator ID="RfvPurchaserId" runat="server" CssClass="error" ControlToValidate="PurchaserId"
                                Display="Dynamic" EnableClientScript="False" ErrorMessage="Purchaser Id is Required">
                                    <img src="Content/img/icon_warning.png" title="Purchaser Id is Required" alt="Purchaser Id is required" />
                            </asp:RequiredFieldValidator>--%>
                    </div>
                </div>


                 </ContentTemplate>
            </asp:UpdatePanel>
            
        </div> 
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
            <button id="btnSaveChanges" class="btn btn-primary" type="button">Save Changes</button>
             <button id="addButton" class="btn btn-primary" type="button">Add</button>

             <button id="saveButtonServer" runat="server" class="btn btn-primary" style="display:none;" onserverclick="btnSaveChanges_ServerClick" type="submit"></button>
             <button id="addButtonServer" runat="server" class="btn btn-primary" style="display:none;" onserverclick="addButton_ServerClick" type="submit"></button>

        </div>
    </div>

<!--Modals-->
    <script type="text/javascript">



        (function ($,document) {

            var categoryDropDown = "#<%=ddlCategory.ClientID%>";

            var uom="#<%=Uom.ClientID%>";
            var supplier="#<%=ddlSuplierCode.ClientID%>";
            
            var addButton="#addButton";
            var saveButton = "#btnSaveChanges";
            var addNewItemButton = "#<%=btnAdd.ClientID%>";
            var purchaser = "#<%=ddlPurchaser.ClientID%>";
            var code="#<%=txtCode.ClientID%>";
            var txtName = "#<%=txtName.ClientID%>";
            var ddlSubCat = "#<%=ddlSubCat.ClientID%>";
            var category = "#<%=ddlCategory.ClientID%>";
            var uom="#<%=Uom.ClientID%>";
            var supplier = "#<%=ddlSuplierCode.ClientID%>";
            var purchaser="#<%=ddlPurchaser.ClientID%>";
            function onDeleteClick() {
                var qid = $(this).attr("qid");
                $("#<%=hdnSelectedItemID.ClientID%>").val(qid);
                $("#requestDelete").modal("show");
            }

            function onEditClick(){
                var qid = $(this).attr("qid");
                $("#<%=hdnSelectedItemID.ClientID%>").val(qid);
                loadData(qid);
                $(addButton).hide();
                $("#lbladd").hide();
                $("#lbledit").show();
                $(saveButton).show();
                
                $("#QINH").hide();
                $("#requestAddEdit").modal("show");
            }

            function getDataFromPage(method, data, success, error) {
                $.ajax({
                    type: "POST",
                    url: "InventoryItem.aspx/"+method,
                    data: JSON.stringify(data?data:{}),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: success
                });
            }

            function loadData(id) {

               // loadAllDropdowns();
                getDataFromPage("GetItemData", { code: id }, function (data) {
                    data = data.d;
                    console.log(data);
                    $("#<%=txtCode.ClientID%>").val(data.Code);
                    $("#<%=txtName.ClientID%>").val(data.Name);
                    $("#<%=txtColor.ClientID%>").val(data.Colour);
                    $("#<%=txtAttribute.ClientID%>").val(data.Attribute);
                    $("#<%=txtMinLevel.ClientID%>").val(data.MinLevel);
                    $("#<%=ddlCategory.ClientID%>").val(data.Category);
                    $("#<%=ddlSubCat.ClientID%>").val(data.SubCategory);
                    $("#<%=Uom.ClientID%>").val(data.Uom);
                    $("#<%=ddlSuplierCode.ClientID%>").val(data.SupplierCode);
                    $("#<%=ddlPurchaser.ClientID%>").val(data.Purchaser);

                    reloadAllDropDowns();

                });
            }

            function reloadAllDropDowns() {
                reloadSelect("#<%=ddlCategory.ClientID%>");
                reloadSelect("#<%=ddlSubCat.ClientID%>");
                reloadSelect("#<%=Uom.ClientID%>");
                reloadSelect("#<%=ddlSuplierCode.ClientID%>");
                reloadSelect("#<%=ddlPurchaser.ClientID%>");
            }

            function reloadSelect(select) {
                $(select).select2("destroy");
                $(select).select2({ width: "20%" });
            }

            function loadAllDropdowns() {

                //loadDropDown("GetCategories", { parent: 0 }, categoryDropDown);
                //loadDropDown("GetUom", {}, uom);
                //loadDropDown("GetSupplier", {}, supplier);
                //loadDropDown("GetPurchaser", {}, purchaser);
            }


            function loadDropDown(method, data, dropdown) {

                getDataFromPage(method, data, function (data) {
                    fillDropDown(data.d, dropdown);
                });
            }

            function onAddNewButtonClick() {


                $(saveButton).hide();
                $(addButton).show();
                $("#lbladd").show();
                $("#lbledit").hide();
                loadAllDropdowns();
                $("#requestAddEdit").find("input").val("");
                $("#requestAddEdit").find("select").val(0);
                reloadAllDropDowns();
                $("#requestAddEdit").modal("show");
                //$(name).val("")
                //$(colour).value = "";
                //$(attribute).value = "";
                //$(minlevel).value = "";
            }


            function fillDropDown(items, dd) {

                if (!items || items.length < 1)
                    return;
                var ddl = $(dd);
                $(ddl).empty();
                for (var i = 0 ; i < items.length; i++) {
                    $(ddl).append('<option value="' + items[i].ID + '">' + items[i].Name + '</option>')
                }

                $(ddl).trigger('change');
            }

            function onCategoryChange() {
                var id =$(this).val();
                getDataFromPage("GetCategories", { parent: id }, function (data) {
                    fillDropDown(data.d, "#<%=ddlSubCat.ClientID%>");
                    reloadSelect("#<%=ddlSubCat.ClientID%>");
                });
            }



            function validateControl(dd, name) {
                console.log($(dd).val());
                return !$(dd).val()?" "+name+ " is required. </br>":"";
            }

            function isFormValid() {
                var error = "";
                error += validateControl(code, "Code");
                error += validateControl("#<%=txtName.ClientID%>", "Name");
                error += validateControl("#<%=txtColor.ClientID%>", "Color");
                error += validateControl("#<%=txtAttribute.ClientID%>", "Attribute");
                error += validateControl("#<%=txtMinLevel.ClientID%>", "Min Level");
                error += validateControl(categoryDropDown,"Category");
                error += validateControl(ddlSubCat,"Sub Category");
                error += validateControl(uom,"Unit Of Measure");
                error += validateControl(supplier,"Sub Category");
                error += validateControl(purchaser, "Purchaser");

                if($(category)[0].selectedIndex==0)
                {
                    error += "Category is required<br/>";
                }
                
                if ($(uom)[0].selectedIndex == 0) {
                    error += "Unit Of Measure is required<br/>";
                }

                if ($(supplier)[0].selectedIndex == 0) {
                    error += "Supplier is required<br/>";
                }

                if ($(purchaser)[0].selectedIndex == 0) {
                    error += "Purchaser is required<br/>";
                }


                if(error){
                    $("#dvAlert").html(error);
                    $("#dvAlert").show();
                    return false;
                }
                return true;

            }
            
            function onAddButtonClick() {

                if (isFormValid()) {
                    $("#<%=addButtonServer.ClientID%>").click();
                }

            }

            function onSaveButtonClick() {
                console.log("save button click");
                if (isFormValid()) {
                    console.log("form valid");
                    $("#<%=saveButtonServer.ClientID%>").click();
                }
            }

            $(function () {
                $(".idelete").on("click", onDeleteClick);
                $(".iedit").on("click", onEditClick);
                $(categoryDropDown).change(onCategoryChange);
                $(addNewItemButton).on("click", onAddNewButtonClick);
                $("select").select2({ width: "25%" });
                $(addButton).on("click", onAddButtonClick);
                $(saveButton).on("click",onSaveButtonClick);

            });

        })(window.jQuery,document);

        function showModal() {
            $('#requestAddEdit').modal('show');
        }
    </script>

</asp:Content>

































