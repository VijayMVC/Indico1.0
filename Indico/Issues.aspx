<%@ Page EnableEventValidation="False" Language="C#" AutoEventWireup="true" CodeBehind="Issues.aspx.cs" MasterPageFile="~/Indico.Master" Inherits="Indico.Issues" %>

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
                     <button type="button" id="searchbutton" runat="server" class="btn btn-info" onserverclick="searchbutton_Click"><i class="icon-search"></i></button>

                    <div class="pull-right">
                        <input type="button"  class="btn btn-primary" runat="server" value="New Issue" id="btnAdd" style="height: 25px;"/><br />
                    </div>
                    <br />
                    <br />
                    <telerik:RadGrid ID="IssuesGrid" runat="server" AllowPaging="true" AllowFilteringByColumn="true" 
                        ShowGroupPanel="true" ShowFooter="false" OnPageSizeChanged="IssuesGrid_PageSizeChanged" OnItemCommand="IssuesGrid_ItemCommand"
                        PageSize="20" OnPageIndexChanged="IssuesGrid_PageIndexChanged" EnableHeaderContextMenu="true"
                        EnableHeaderContextFilterMenu="true" AutoGenerateColumns="false" OnItemDataBound="IssuesGrid_ItemDataBound" OnSortCommand="IssuesGrid_SortCommand"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true" >
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <GroupingSettings CaseSensitive="false" />
                        <MasterTableView AllowFilteringByColumn="true" TableLayout="Auto" GroupsDefaultExpanded="false">
                            <Columns>
                                 <telerik:GridDateTimeColumn DataFormatString="{0:dd MMMM yyyy}" DataField="Date"  SortExpression="Date" HeaderText="Date"
                                     Groupable="True" UniqueName="Date" FilterControlWidth="100px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridDateTimeColumn>
                                 <telerik:GridBoundColumn  DataField="TransactionNo"  SortExpression="TransactionNo" HeaderText="Transaction No"
                                     Groupable="True" UniqueName="TransactionNo" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="ItemName"  SortExpression="ItemName" HeaderText="Item"
                                     Groupable="True" UniqueName="ItemName" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 <telerik:GridBoundColumn  DataField="Quantity"  SortExpression="Quantity" HeaderText="Quantity"
                                     Groupable="True" UniqueName="Quantity" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                 
                                  <telerik:GridTemplateColumn UniqueName="UserFunctions" HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Item"><i class="icon-pencil"></i>Edit</asp:HyperLink>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Item"><i class="icon-trash" ></i> Delete</asp:HyperLink>
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
            <h3>Delete Issues</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Issue?
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
            
               <h3 id="lbledit">Edit Issue</h3>
            <h3 id="lbladd">Add Issue</h3>
        </div>
        <div class="modal-body">
            <asp:UpdatePanel runat="server">
                 <ContentTemplate>
                        <div class="alert alert-danger" id="dvAlert" style="display:none;">
              
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Date</label>
                    
                                <div class="controls">
                                    <div data-date-viewmode="years" data-date-format="dd MM yyyy" class="input-append date datepicker">
                                        <asp:TextBox ID="txtDate" runat="server"></asp:TextBox>
                                        <span class="add-on"><i class="icon-calendar"></i></span>
                                    </div>
<%--                                    <asp:RequiredFieldValidator ID="rfvStrikeDate" runat="server" ErrorMessage="Strike Date is required"
                                        ValidationGroup="validateEmb" ControlToValidate="txtDate" EnableClientScript="false">
                                <img src="Content/img/icon_warning.png"  title="Strike Date is required" alt="Strike Date is required" />
                                    </asp:RequiredFieldValidator>--%>
                                </div>
                            
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Transaction No</label>
                    <div class="controls">
                        <asp:TextBox ID="TransactionNo"  runat="server" CssClass="topic_d" MaxLength="255" AutoPostBack="true"></asp:TextBox>
                        <%--                        <asp:RequiredFieldValidator ID="rfvCategory" runat="server" CssClass="error" ControlToValidate="ddlCategory"
                                Display="Dynamic" EnableClientScript="False" ErrorMessage="Category is required">
                                    <img src="Content/img/icon_warning.png" title="Category is required" alt="Category is required" />
                            </asp:RequiredFieldValidator>--%>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label required">
                        Item</label>
                    <div class="controls">
                        <asp:DropDownList ID="ddlItem" runat="server" AutoPostBack="true" DataValueField="ID" DataTextField="Name" CssClass="topic_d"  MaxLength="255" OnSelectedIndexChanged="ddlItem_SelectedIndexChanged"></asp:DropDownList>
                        <%--                        <asp:RequiredFieldValidator ID="RfvddlSubCat" runat="server" CssClass="error" ControlToValidate="ddlSubCat"
                                Display="Dynamic" EnableClientScript="False" ErrorMessage="Sub Category is required">
                                    <img src="Content/img/icon_warning.png" title="Sub Category is required" alt="Sub Category is required" />
                            </asp:RequiredFieldValidator>--%>
                    </div>
                    <br />
                    <label class="control-label" id="l1">
                        Available Quantity</label>


                    <div class="controls">
                       <asp:TextBox ID="qinh" runat="server" ReadOnly="true"></asp:TextBox>
                        <%--                        <asp:RequiredFieldValidator ID="RfvddlSubCat" runat="server" CssClass="error" ControlToValidate="ddlSubCat"
                                Display="Dynamic" EnableClientScript="False" ErrorMessage="Sub Category is required">
                                    <img src="Content/img/icon_warning.png" title="Sub Category is required" alt="Sub Category is required" />
                            </asp:RequiredFieldValidator>--%>
                    </div>
                </div>


                <div class="control-group">
                    <label class="control-label required">
                        Quantity</label>
                    <div class="controls">
                        <asp:TextBox ID="txtQty" runat="server" CssClass="topic_d" MaxLength="255"></asp:TextBox>
                        
                    </div>
                    <br />
                    <span id="s1" runat="server" style="color:red" align="center"></span>
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
        $(document).ready(function () {
             
           
            $('.datepicker').datepicker({ format: 'dd MM yyyy' });
            var ItemDropDown = "#<%=ddlItem.ClientID%>";
            var qty="#<%=txtQty.ClientID%>";
            var tno = "#<%=TransactionNo.ClientID%>"; 
            var item = "#<%=ddlItem.ClientID%>"; 
            var qinh = "#<%=qinh.ClientID%>";
            var s1="#<%=s1.ClientID%>";
            var addButton="#addButton";
            var saveButton = "#btnSaveChanges";
            var addNewItemButton = "#<%=btnAdd.ClientID%>";
            
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
                $(qinh).hide();
                $("#l1").hide();
                $("#lbladd").hide();
                $("#lbledit").show();
                $(saveButton).show();
                $("#requestAddEdit").modal("show");
            }

            function getDataFromPage(method, data, success, error) {
                $.ajax({
                    type: "POST",
                    url: "Issues.aspx/"+method,
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
                    $("#<%=TransactionNo.ClientID%>").val(data.TransactionNo);
                    $("#<%=ddlItem.ClientID%>").val(data.Item);
                    $("#<%=txtQty.ClientID%>").val(data.Quantity);
                    $("#<%=txtDate.ClientID%>").datepicker("setDate", new Date(data.Date));
                     reloadAllDropDowns();

                });
            }


            function onAddNewButtonClick() {


                $(saveButton).hide();
                $(addButton).show();
                $("#lbladd").show();
                $("#lbledit").hide();
                $(qinh).show();
                $("#l1").show();
                
                $("#requestAddEdit").find("input").val("");
                
                $("#requestAddEdit").find("select").val(0);
                $("#requestAddEdit").modal("show");
                //$(name).val("")
                //$(colour).value = "";
                //$(attribute).value = "";
                //$(minlevel).value = "";
            }
            

            function validateControl(dd, name) {
                console.log($(dd).val());
                return !$(dd).val()?" "+name+ " is required. </br>":"";
            }


            function isFormValid() {
                var error = "";
               
                 error += validateControl("#<%=txtDate.ClientID%>", "Date");
                error += validateControl("#<%=TransactionNo.ClientID%>", "TransactionNo");
                error += validateControl("#<%=ddlItem.ClientID%>", "Item");
                error += validateControl("#<%=txtQty.ClientID%>", "Quantity");

                if ($(item)[0].selectedIndex == 0) {
                    error += "Item is required<br/>";
                }

                if ($(qty).val() > $(qinh).val())
                {
                    error += "Issued quantity must be simillar or less than available quantity";
                }
                if(error){
                    $("#dvAlert").html(error);
                    $("#dvAlert").show();
                    return false;
                }
              

                return true;

            }


            function isFormValid2() {
                var error = "";
               
                 error += validateControl("#<%=txtDate.ClientID%>", "Date");
                error += validateControl("#<%=TransactionNo.ClientID%>", "TransactionNo");
                error += validateControl("#<%=ddlItem.ClientID%>", "Item");
                error += validateControl("#<%=txtQty.ClientID%>", "Quantity");

                if ($(item)[0].selectedIndex == 0) {
                    error += "Item is required<br/>";
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
                if (isFormValid2()) {
                    console.log("form valid");
                    $("#<%=saveButtonServer.ClientID%>").click();
                }
            }

            $(function () {
                $(".idelete").on("click", onDeleteClick);
                $(".iedit").on("click", onEditClick);
               
                $(addNewItemButton).on("click", onAddNewButtonClick);
               
                $(addButton).on("click", onAddButtonClick);
                $(saveButton).on("click", onSaveButtonClick);

            });

        })(window.jQuery);



        function showModal() {
            $('#requestAddEdit').modal('show');
        }
    </script>
    

</asp:Content>


