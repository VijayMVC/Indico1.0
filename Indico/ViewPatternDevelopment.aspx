<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
   CodeBehind="ViewPatternDevelopment.aspx.cs" Inherits="Indico.ViewPatternDevelopment" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <asp:ScriptManager runat="server"></asp:ScriptManager>
     <div class="page-header">
            <div class="header-actions">
                <button id="BackButton" runat="server" class="btn btn-primary pull-right" visible="false">Back</button>
            </div>
            <h3>
                <asp:Literal ID="HeadLiteral" runat="server"></asp:Literal>
            </h3>
        </div> <!--page header-->
    <div class="page-content">
        <div class="row-fluid">
             <div id="dvDataContent" runat="server">
                <div class="search-control clearfix">
                    <div id="pnlSearch">
                    </div>
                </div>
                 <telerik:RadGrid ID="Grid" runat="server" AllowPaging="true" AllowFilteringByColumn="true"
                        ShowGroupPanel="true" ShowFooter="false" OnPageSizeChanged="OnGridPageSizeChanged"
                        PageSize="20" OnPageIndexChanged="OnGridPageIndexChanged" EnableHeaderContextMenu="true"
                        EnableHeaderContextFilterMenu="true" AutoGenerateColumns="false" OnItemDataBound="OnGridItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true" >
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <GroupingSettings CaseSensitive="false" />
                        <MasterTableView AllowFilteringByColumn="true" TableLayout="Auto" GroupsDefaultExpanded="false">
                            <Columns>
                                <telerik:GridBoundColumn  DataField="PatternNumber"  SortExpression="PatternNumber" HeaderText="Pattern Number"
                                     Groupable="false" UniqueName="PatternNumber" FilterControlWidth="60px"  AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" ></telerik:GridBoundColumn>
                                <telerik:GridBoundColumn  HeaderText="Description" DataField="Description" AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" SortExpression="Description"
                                     Groupable="False" UniqueName="Description" FilterControlWidth="60px"></telerik:GridBoundColumn>
                                
                                <telerik:GridBoundColumn Display="False"  HeaderText="Creator" DataField="Creator" AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" SortExpression="Creator"
                                     Groupable="False" UniqueName="Creator" FilterControlWidth="60px"></telerik:GridBoundColumn>
                                <telerik:GridDateTimeColumn Display="False" UniqueName="Created" DataField="Created" HeaderText="Created Date" FilterControlWidth="50px" Groupable="false" SortExpression="Created" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                
                                <telerik:GridBoundColumn Display="False" HeaderText="Last Modifier" DataField="LastModifier" AutoPostBackOnFilter="True" CurrentFilterFunction="Contains" SortExpression="LastModifier"
                                     Groupable="False" UniqueName="LastModifier" FilterControlWidth="60px"></telerik:GridBoundColumn>
                                <telerik:GridDateTimeColumn Display="False"  UniqueName="LastModified" DataField="LastModified" HeaderText="Modified Date" FilterControlWidth="50px" Groupable="false" SortExpression="LastModified" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                               
                                <telerik:GridTemplateColumn DataType="System.Boolean"  DataField="Spec" CurrentFilterFunction="NoFilter" FilterControlWidth="50px" AutoPostBackOnFilter="True"  HeaderText="Spec" Groupable="false" UniqueName="Spec">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="specCheckBox" CssClass="developmentCheckBox" runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn DataType="System.Boolean" DataField="LectraPattern" CurrentFilterFunction="NoFilter" FilterControlWidth="50px" AutoPostBackOnFilter="True"  HeaderText="Lectra Pattern" Groupable="false" UniqueName="LectraPattern">
                                    <ItemTemplate >
                                        <asp:CheckBox ID="lectraPatternCheckBox"  CssClass="developmentCheckBox"  runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn DataType="System.Boolean" DataField="WhiteSample" CurrentFilterFunction="NoFilter" FilterControlWidth="50px" AutoPostBackOnFilter="True" HeaderText="White Sample" Groupable="false" UniqueName="WhiteSample">
                                    <ItemTemplate>
                                        <asp:CheckBox Checked="false" ID="whiteSampleCheckBox" CssClass="developmentCheckBox" runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn DataType="System.Boolean" DataField="LogoPositioning" CurrentFilterFunction="NoFilter" FilterControlWidth="50px" AutoPostBackOnFilter="True" HeaderText="Logo Positioning" Groupable="false" UniqueName="LogoPositioning">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="logoPositioningCheckBox" CssClass="developmentCheckBox" runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn DataType="System.Boolean" DataField="Photo" CurrentFilterFunction="NoFilter" FilterControlWidth="50px" AutoPostBackOnFilter="True" HeaderText="Photo" Groupable="false" UniqueName="Photo">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="photoCheckBox" CssClass="developmentCheckBox" runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn DataType="System.Boolean" DataField="Fake3DVis" CurrentFilterFunction="NoFilter" FilterControlWidth="50px" AutoPostBackOnFilter="True" HeaderText="Fake 3D Vis"  Groupable="false" UniqueName="Fake3DVis">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="fake3dVisCheckBox" CssClass="developmentCheckBox" runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn DataType="System.Boolean" DataField="NestedWireframe" CurrentFilterFunction="NoFilter" FilterControlWidth="50px" AutoPostBackOnFilter="True" HeaderText="Nested Wireframe"  Groupable="false" UniqueName="NestedWireframe">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="nestedWireframeCheckBox" CssClass="developmentCheckBox" runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn DataType="System.Boolean" DataField="BySizeWireframe" CurrentFilterFunction="NoFilter" FilterControlWidth="50px" AutoPostBackOnFilter="True" HeaderText="BySizeWireframe" Groupable="false" UniqueName="BySizeWireframe">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="bySizeWireframeCheckBox" CssClass="developmentCheckBox" runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn DataType="System.Boolean" DataField="PreProd" CurrentFilterFunction="NoFilter" FilterControlWidth="50px" AutoPostBackOnFilter="True" HeaderText="Pre Prod" Groupable="false" UniqueName="PreProd">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="preProdCheckBox" CssClass="developmentCheckBox" runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn DataType="System.Boolean" DataField="SpecChart" CurrentFilterFunction="NoFilter" FilterControlWidth="50px" AutoPostBackOnFilter="True" HeaderText="Spec Chart" Groupable="false" UniqueName="SpecChart">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="specChartCheckBox" CssClass="developmentCheckBox" runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn DataType="System.Boolean" DataField="FinalTemplate" CurrentFilterFunction="NoFilter" FilterControlWidth="50px" AutoPostBackOnFilter="True" HeaderText="Final Template"  Groupable="false" UniqueName="FinalTemplate">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="finalTemplateCheckBox" CssClass="developmentCheckBox" runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn DataType="System.Boolean" DataField="TemplateApproved" CurrentFilterFunction="NoFilter" FilterControlWidth="50px" AutoPostBackOnFilter="True" HeaderText="Template Approved" Groupable="false" UniqueName="TemplateApproved">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="templateApprovedCheckBox" CssClass="developmentCheckBox" runat="server" Width="10px" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn  DataField="Remarks" CurrentFilterFunction="Contains" FilterControlWidth="60px" AutoPostBackOnFilter="True" HeaderText="Remarks" Groupable="false" UniqueName="Remarks">
                                    <ItemTemplate>
                                        <asp:TextBox ID="remarksTextBox" CssClass="reamrkstextBox" runat="server"  />
                                        <button class="editremarksbutton" type="button" title="edit remarks"><i class="icon-pencil"></i></button>
                                        <button class="saveremarksbutton btn-info" type="button" >Save Remarks</button>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn AllowFiltering="false" HeaderText="" Groupable="false" UniqueName="Action">
                                    <ItemTemplate>
                                        <button class="showhistorybutton btn-info" type="button" >Show History</button>
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
        <div id="dialogModal" class="modal fade" data-backdrop="static" data-keyboard="false" >
            <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title">Save Changes To The Selected</h4>
                </div>
                <div class="modal-body">
                    <p class="modal-message">One fine body&hellip;</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" id="closeButton" data-dismiss="modal">Close</button>
                    <button class="btn btn-primary" data-dismiss="modal" id="savechangesButton" type="button">Save changes</button>
                </div>
            </div>
            </div>
        </div>
        
         <div id="editRemarksmodal" class="modal fade" data-backdrop="static" data-keyboard="false" >
            <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <h4 class="modal-title">Edit Remarks</h4>
                </div>
                <div class="modal-body">
                    <textarea class="form-control" id="remarksTextArea" style="width: 100%; height: 100%">
                        
                    </textarea>
                </div>
                <div class="modal-footer">
                <button type="button" class="btn btn-secondary" id="close" data-dismiss="modal">Close</button>
                <button class="btn btn-primary" data-dismiss="modal" id="doneButtton" type="button">Done</button>
                </div>
            </div>
            </div>
        </div>
    </div>
    
    <script type="text/javascript">
        
        //$(document).ready(function () {
        //    $("#patternSelector").chosen({ no_results_text: "Oops, nothing found!", width: "150px" });
        //});
        //$("#searchButton").click(function() {
        //    var text = $("#PatternNumberTextBox").val();
        //    if (text.length > 0) {
        //        window.location = "ViewPatternDevelopment.aspx?Pattern=" + text;
        //    } else {
        //        window.location = "ViewPatternDevelopment.aspx";
        //    }
        //});

        function AskForSaveChanges(title, message, savechangesAction,cancelAction) {
            
            $("#dialogModal").find(".modal-title").text(title);
            $("#dialogModal").find(".modal-body").html("<p class=\"modal-message\">"+message+"</p>");
            $("#dialogModal").find("#savechangesButton").show();
            $("#dialogModal").find("#savechangesButton").off("click").click(savechangesAction);
            $("#dialogModal").find("#closeButton").off("click").click(cancelAction);
            $("#dialogModal").modal("show");
        }

        $(".saveremarksbutton").click(function() {
            var remarkstextBox = $(this).parent().find("input[type=text]");
            var id = $(this).closest("tr").attr("data-id");
            var remarks = $(remarkstextBox).val();
            $.ajax(
            {
                url: "ViewPatternDevelopment.aspx/SaveRemarks",
                type: "POST",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ id: id, remarks: remarks }),
                dataType: "json",
                async: true
            });
        });

        $(".showhistorybutton").click(function () {
            var id = $(this).closest("tr").attr("data-id");
            $.ajax(
            {
                url: "ViewPatternDevelopment.aspx/GetHistory",
                type: "POST",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ id: id }),
                dataType: "json",
                async: true ,
                success: function(v) {
                    var data = v.d;
                    if (data != null) {
                        $("#dialogModal").find(".modal-title").text("");
                        $("#dialogModal").find(".modal-body").html(data);
                        $("#dialogModal").find("#savechangesButton").hide();
                        $("#dialogModal").find("#savechangesButton").off("click");
                        $("#dialogModal").find("#closeButton").off("click");
                        $("#dialogModal").modal("show");
                    }
                }
            });
        });

        $(".developmentCheckBox").change(function() {
            var checkBox = $(this).children();
            var ischecked = checkBox.prop("checked");
            var user = "<%=LoggedUser.ID%>";
            var nextCheckBox;
            if (ischecked) {
                nextCheckBox = $(this).parent().nextAll().has(":checkbox").first().find(":checkbox");
                $(this).children().prop("disabled", true);
                nextCheckBox.prop("disabled", false);
               
            }
            var id =  $(this).closest("tr").attr("data-id");
            var field = $(this).attr("data-field");
            AskForSaveChanges("Save Change ? ", "Save changes you just made ?", function() {
                $.ajax(
                {
                    url: "ViewPatternDevelopment.aspx/SaveChanges",
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    data: JSON.stringify({ developmentId: id, field: field, value: ischecked ? "1" : "0", loggedUser: user }),
                    dataType: "json",
                    async: true
                });
            }, function () {
                checkBox.prop("disabled", false);
                checkBox.prop("checked", false);
                nextCheckBox = checkBox.parent().parent().nextAll().has(":checkbox").first().find(":checkbox");
                nextCheckBox.prop("disabled", true);
            });
        });

        $("#addNewDevelopmentButton").click(function () {
            $.ajax(
            {
                url: "ViewPatternDevelopment.aspx/GetNonDevelopedPatternsAsOptions",
                type: "POST",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true ,
                success: function (v) {
                    var data = v.d;
                    $("#patternSelector").append(data);
                    $("#newModal").modal("show");
                }
            });
        });

        $("#addnewdevelopmentbutton").click(function () {
            var val = $("#patternSelector").chosen().val();
            if (val+"".length > 0) {
                window.location = "ViewPatternDevelopment.aspx?Create=true&Pattern=" + val;
            }
        });

        $(".editremarksbutton").click(function () {
            var input = $(this).parent().find(".reamrkstextBox");
            var id = $(this).closest("tr").attr("data-id");
            $("#doneButtton").off("click");
            $("#remarksTextArea").val(input.val());
            $("#doneButtton").click(function () {
                var text = $("#remarksTextArea").val();
                input.val(text);
                $.ajax(
               {
                    url: "ViewPatternDevelopment.aspx/SaveRemarks",
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    data: JSON.stringify({ id: id, remarks: text }),
                    dataType: "json",
                    async: true
               });
            });
            $("#editRemarksmodal").modal("show");
        });
    </script>
</asp:Content>