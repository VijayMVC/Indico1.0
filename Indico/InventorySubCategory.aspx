<%@ Page EnableEventValidation="False" Language="C#" AutoEventWireup="true" CodeBehind="InventorySubCategory.aspx.cs" MasterPageFile="~/Indico.Master" Inherits="Indico.InventorySubCategory" %>
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
                    <button type="button" id="searchbutton" onclick="" runat="server" class="btn btn-info" onserverclick="searchbutton_ServerClick"><i class="icon-search"></i></button>

                    <div class="pull-right">
                        <input type="button" class="btn btn-primary" runat="server" value="New Sub Category" id="btnAdd" style="height: 25px;" /><br />
                    </div>
                    <br />
                    <br />
 <telerik:RadGrid ID="SubCategoryGrid" runat="server" AllowPaging="true" AllowFilteringByColumn="true"
                        ShowGroupPanel="true" ShowFooter="false" OnPageSizeChanged="SubCategoryGrid_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="SubCategoryGrid_PageIndexChanged" EnableHeaderContextMenu="true"
                        EnableHeaderContextFilterMenu="true" AutoGenerateColumns="false" OnItemDataBound="SubCategoryGrid_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true" OnItemCommand="SubCategoryGrid_ItemCommand" OnSortCommand="SubCategoryGrid_SortCommand">
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <GroupingSettings CaseSensitive="false" />
                        <MasterTableView AllowFilteringByColumn="true" TableLayout="Auto" GroupsDefaultExpanded="false">
                            <Columns>

                                <telerik:GridBoundColumn DataField="Name" SortExpression="Name" HeaderText="Name"
                                    Groupable="True" UniqueName="Name" FilterControlWidth="60px" AutoPostBackOnFilter="True" CurrentFilterFunction="Contains">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="CategoryName" SortExpression="CategoryName" HeaderText="Category Name"
                                    Groupable="True" UniqueName="CategoryName" FilterControlWidth="60px" AutoPostBackOnFilter="True" CurrentFilterFunction="Contains">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn UniqueName="UserFunctions" HeaderText="" AllowFiltering="false">

                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Item"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                                </li>
                                                <%--
                                                    <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Item"><i class="icon-trash" ></i> Delete</asp:HyperLink>
                                                </li>
                                                     --%>
                                                
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
            <h3>Delete Category</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete Sub Category?
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
            <h3 id="lbladd">Add Sub Category</h3>
            <h3 id="lbledit">Edit Sub Category</h3>
        </div>
        <div class="modal-body">
            <asp:UpdatePanel runat="server">
                <ContentTemplate>
                    <div class="alert alert-danger" id="dvAlert" style="display: none;">
                    </div>
                    <div class="control-group">
                        <label class="control-label required">
                            Name</label>
                        <div class="controls">
                            <asp:TextBox ID="txtName" runat="server" MaxLength="128"></asp:TextBox>
                            <%--                        <asp:RequiredFieldValidator ID="rfvName" runat="server" CssClass="error"
                                ControlToValidate="txtName" Display="Dynamic" EnableClientScript="False"
                                ErrorMessage="Name is required">
                                    <img src="Content/img/icon_warning.png" title="Name is required" alt="Name is required" />
                            </asp:RequiredFieldValidator>--%>
                            <%--                         <asp:CustomValidator ID="cvTxtName" runat="server" OnServerValidate="cvTxtName_ServerValidate" ErrorMessage="Name is already in use"
                                ControlToValidate="txtName" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Name is already in use" alt="Name is already in use" />
                            </asp:CustomValidator>--%>
                        </div>
                        <br />
                        <label class="control-label required" id="l1">
                            Category</label>
                        <div class="controls">
                            <asp:DropDownList ID="ddCategory" DataTextField="Name" DataValueField="ID" runat="server" MaxLength="128"></asp:DropDownList>
                            <%--                        <asp:RequiredFieldValidator ID="rfvName" runat="server" CssClass="error"
                                ControlToValidate="txtName" Display="Dynamic" EnableClientScript="False"
                                ErrorMessage="Name is required">
                                    <img src="Content/img/icon_warning.png" title="Name is required" alt="Name is required" />
                            </asp:RequiredFieldValidator>--%>
                            <%--                         <asp:CustomValidator ID="cvTxtName" runat="server" OnServerValidate="cvTxtName_ServerValidate" ErrorMessage="Name is already in use"
                                ControlToValidate="txtName" EnableClientScript="false">
                                 <img src="Content/img/icon_warning.png"  title="Name is already in use" alt="Name is already in use" />
                            </asp:CustomValidator>--%>
                        </div>

                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
            <button id="btnSaveChanges" class="btn btn-primary" type="button">Save Changes</button>
            <button id="addButton" class="btn btn-primary" type="button">Add</button>

            <button id="saveButtonServer" runat="server" class="btn btn-primary" style="display: none;" onserverclick="saveButtonServer_ServerClick" type="submit"></button>
            <button id="addButtonServer" runat="server" class="btn btn-primary" style="display: none;" onserverclick="addButtonServer_ServerClick" type="submit"></button>

        </div>
    </div>

    <!--Modals-->

     <script type="text/javascript">
         (function ($) {


         var SubcategoryName = "#<%=txtName.ClientID%>";
            var addButton = "#addButton";
            var saveButton = "#btnSaveChanges";
            var addNewSubCategoryButton = "#<%=btnAdd.ClientID%>";

         function onDeleteClick() {
                var qid = $(this).attr("qid");
                 $("#<%=hdnSelectedItemID.ClientID%>").val(qid);
                $("#requestDelete").modal("show");
         }

          function onEditClick() {
                var qid = $(this).attr("qid");
                $("#<%=hdnSelectedItemID.ClientID%>").val(qid);
                loadData(qid);
                $(addButton).hide();
                $("#l1").hide();
                $(saveButton).show();
                $("#lbladd").hide();
                $("#lbledit").show();
                $("#<%=ddCategory.ClientID%>").hide();
                $("#requestAddEdit").modal("show");
            }

         function getDataFromPage(method, data, success, error) {
             $.ajax({
                 type: "POST",
                 url: "InventorySubCategory.aspx/" + method,
                 data: JSON.stringify(data ? data : {}),
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
                    $("#<%=txtName.ClientID%>").val(data.Name);

                });
          }

         function onAddNewButtonClick() {
             $(saveButton).hide();
             $(addButton).show();
             $("#lbladd").show();
             $("#lbledit").hide();
             $("#requestAddEdit").find("input").val("");
             $("#<%=ddCategory.ClientID%>").show();
             $("#l1").show();
             $("#lbladd").show();
             $("#lbledit").hide();
             $("#requestAddEdit").modal("show");
         }

         function validateControl(dd, name) {
             console.log($(dd).val());
             return !$(dd).val() ? " " + name + " is required. </br>" : "";
         }

         function isFormValid() {
                var error = "";
                error += validateControl("#<%=txtName.ClientID%>", "Name");

                if (error) {
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

             $(addNewSubCategoryButton).on("click", onAddNewButtonClick);

             $(addButton).on("click", onAddButtonClick);
             $(saveButton).on("click", onSaveButtonClick);

         });

         })(window.jQuery);

          function showModal() {
            $('#requestAddEdit').modal('show');
        }
    </script>
    </asp:Content>




        













































































