<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewCostSheets.aspx.cs" Inherits="Indico.ViewCostSheets" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>


<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">

    <style type="text/css">
        .alignright {
            text-align: right;
        }
    </style>
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddUser" runat="server" class="btn btn-link pull-right" href="~/AddEditFactoryCostSheet.aspx">New Cost Sheet</a>
                <asp:LinkButton ID="btnBulkCostSheet" runat="server" CssClass="btn btn-link" OnClick="btnBulkCostSheet_Click"><i class="icon-print"></i>Print All Cost Sheets</asp:LinkButton>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="alert alert-info">
                    <h4>
                        <a href="AddEditFactoryCostSheet.aspx" title="Add a Cost Sheet.">Add the first Cost
                            Sheet.</a>
                    </h4>
                    <p>
                        You can add as many cost sheets as you like.
                    </p>
                </div>
                <!-- / -->
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <div class="search-control clearfix">
                        <div class="form-inline pull-right">
                            <label>
                                Fob Cost</label>
                            <asp:DropDownList ID="ddlFocCost" runat="server" AutoPostBack="True" CssClass="input-medium"
                                OnSelectedIndexChanged="ddlFocCost_SelectedIndexChanged">
                                <asp:ListItem Text="All" Value="0"></asp:ListItem>
                                <asp:ListItem Text="0.00" Value="1"></asp:ListItem>
                            </asp:DropDownList>
                            <label>
                                Indiman CIF</label>
                            <asp:DropDownList ID="ddlIndimanCIF" runat="server" AutoPostBack="True" CssClass="input-medium"
                                OnSelectedIndexChanged="ddlIndimanCIF_SelectedIndexChanged">
                                <asp:ListItem Text="All" Value="0"></asp:ListItem>
                                <asp:ListItem Text="0.00" Value="1"></asp:ListItem>
                            </asp:DropDownList>
                            <label>Exchange Rate</label>
                            <asp:TextBox ID="txtExchangeRate" CssClass="input-mini" runat="server"></asp:TextBox>
                            <label>Duty Rate</label>
                            <asp:TextBox ID="txtDutyRate" CssClass="input-mini" runat="server"></asp:TextBox>
                            <button id="btnChange" runat="server" type="submit" onserverclick="btnChange_ServerClick" class="btn btn-info">Change</button>
                        </div>
                        <!-- Search Control -->
                        <div class="search-control clearfix">
                            <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                                <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search" data-loading-text="Changing..."
                                    OnClick="btnSearch_Click" />
                            </asp:Panel>
                        </div>
                    </div>
                    <!-- / -->
                    <!-- Data Table -->
                    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro"
                        EnableEmbeddedSkins="true">
                    </telerik:RadAjaxLoadingPanel>                  
                    <telerik:RadGrid ID="RadGridCostSheet" runat="server" AllowPaging="true" AllowFilteringByColumn="true" ShowGroupPanel="true" OnPageSizeChanged="RadGridCostSheet_PageSizeChanged"
                        PageSize="20" OnPageIndexChanged="RadGridCostSheet_PageIndexChanged" ShowFooter="false" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true"
                        AutoGenerateColumns="false" OnItemDataBound="RadGridCostSheet_ItemDataBound"
                        Skin="Metro" CssClass="RadGrid" AllowSorting="true" EnableEmbeddedSkins="true"
                        OnItemCommand="RadGridCostSheet_ItemCommand"
                        OnSortCommand="RadGridCostSheet_SortCommand" EnableLinqExpressions="false">
                        <HeaderContextMenu OnItemClick="HeaderContextMenu_ItemCLick"></HeaderContextMenu>
                        <GroupingSettings CaseSensitive="false" />
                        <PagerStyle Mode="NextPrevNumericAndAdvanced"></PagerStyle>
                        <MasterTableView AllowFilteringByColumn="true" GroupsDefaultExpanded="false" ShowGroupFooter="true" ShowFooter="false">
                            <Columns>
                                <telerik:GridTemplateColumn UniqueName="CostSheet"  SortExpression="CostSheet" HeaderText="CostSheet" AutoPostBackOnFilter="false" FilterControlWidth="75px" DataField="CostSheet">
                                    <ItemTemplate>
                                        <asp:Label  ID="lblCostSheet" runat="server"></asp:Label>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="Category" SortExpression="Category" HeaderText="Category" CurrentFilterFunction="Contains" AutoPostBackOnFilter="false" FilterControlWidth="75px" DataField="Category">
                                 </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="PatternNumber" SortExpression="PatternNumber" HeaderText="Pattern Number" CurrentFilterFunction="Contains" FilterControlWidth="50px" AutoPostBackOnFilter="false" DataField="PatternNumber">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Pattern" SortExpression="Pattern" HeaderText="Pattern Description" CurrentFilterFunction="Contains" FilterControlWidth="100px" AutoPostBackOnFilter="false" DataField="Pattern">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn UniqueName="Fabric" SortExpression="Fabric" HeaderText="Fabric" FilterControlWidth="100px" AutoPostBackOnFilter="false" DataField="Fabric">
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn UniqueName="QuostedFOBCost" ItemStyle-HorizontalAlign="Right" Groupable="false" SortExpression="QuotedFOBCost" HeaderText="FOB Cost" CurrentFilterFunction="EqualTo"
                                    DataType="System.Decimal" Aggregate="Sum" FooterText="FOB Cost:"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="QuotedFOBCost">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtFOBCost" CssClass="alignright" runat="server" Width="60px" Height="15px"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn UniqueName="ExchangeRate" Groupable="false" AllowFiltering="true" SortExpression="ExchangeRate" CurrentFilterFunction="EqualTo"
                                    HeaderText="" FilterControlWidth="50px" AutoPostBackOnFilter="false" DataField="ExchangeRate" ItemStyle-HorizontalAlign="Right">
                                    <HeaderTemplate>
                                        <asp:Literal runat="server" Text="Exchange Rate"></asp:Literal>
                                        <div>
                                            <asp:TextBox ID="txtApplyExchangeRate" BorderStyle="Inset" Height="10px" Text="" runat="server" Width="40px"></asp:TextBox>
                                            <asp:Button ID="btnExchangeRate" CssClass="btn-info" runat="server" Text="Apply" Width="50px" OnClick="btnExchangeRate_Click" />
                                        </div>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtExchangeRate" CssClass="alignright" runat="server" Width="60px" Height="15px"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn UniqueName="QuotedCIF" AllowFiltering="true" Groupable="false" SortExpression="QuotedCIF" CurrentFilterFunction="EqualTo"
                                    HeaderText="" FilterControlWidth="50px" AutoPostBackOnFilter="false" DataField="QuotedCIF" ItemStyle-HorizontalAlign="Right">
                                    <HeaderTemplate>
                                        <asp:Literal runat="server" Text="Quoted CIF"></asp:Literal>
                                        <div>
                                            <asp:TextBox ID="txtApplyQuotedCIF" BorderStyle="Inset" Height="10px" Text="" runat="server" Width="40px"></asp:TextBox>
                                            <asp:Button ID="btnQuotedCIF" CssClass="btn-info" runat="server" Text="Apply" Width="50px" OnClick="btnQuotedCIF_Click" />
                                        </div>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtQuotedCIF" runat="server" Width="60px" CssClass="alignright" Height="15px"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn UniqueName="DutyRate" AllowFiltering="true" Groupable="false" SortExpression="DutyRate" CurrentFilterFunction="EqualTo"
                                    HeaderText="" FilterControlWidth="50px" AutoPostBackOnFilter="false" DataField="DutyRate" ItemStyle-HorizontalAlign="Right">
                                    <HeaderTemplate>
                                        <asp:Literal runat="server" Text="Duty Rate"></asp:Literal>
                                        <div>
                                            <asp:TextBox ID="txtApplyDutyRate" BorderStyle="Inset" Height="10px" Text="" runat="server" Width="40px"></asp:TextBox>
                                            <asp:Button ID="btnDutyRate" CssClass="btn-info" runat="server" Text="Apply" Width="50px" OnClick="btnDutyRate_Click" />
                                        </div>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtDutyRate" runat="server" Width="60px" CssClass="alignright" Height="15px"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn UniqueName="SMVRate" AllowFiltering="true" Groupable="false" SortExpression="SMVRate" CurrentFilterFunction="EqualTo"
                                    HeaderText="" FilterControlWidth="50px" AutoPostBackOnFilter="false" DataField="SMVRate" ItemStyle-HorizontalAlign="Right">
                                    <HeaderTemplate>
                                        <asp:Literal runat="server" Text="SMV Rate"></asp:Literal>
                                        <div>
                                            <asp:TextBox ID="txtApplySMVRate" BorderStyle="Inset" Height="10px" Text="" runat="server" Width="40px"></asp:TextBox>
                                            <asp:Button ID="btnSMVRate" CssClass="btn-info" runat="server" Text="Apply" Width="50px" OnClick="btnSMVRate_Click" />
                                        </div>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtSMVRate" runat="server" Width="60px" CssClass="alignright" Height="15px"></asp:TextBox>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridNumericColumn UniqueName="QuotedMP" SortExpression="QuotedMP" HeaderText="Quoted MP" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="QuotedMP" ItemStyle-HorizontalAlign="Right">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="SMV" SortExpression="SMV" HeaderText="SMV" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="SMV" ItemStyle-HorizontalAlign="Right">
                                </telerik:GridNumericColumn>                                
                                <telerik:GridNumericColumn UniqueName="TotalFabricCost" SortExpression="TotalFabricCost" HeaderText="Fabric Cost" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="TotalFabricCost" ItemStyle-HorizontalAlign="Right">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="TotalAccessoriesCost" SortExpression="TotalAccessoriesCost" HeaderText="Accessories Cost" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="TotalAccessoriesCost" ItemStyle-HorizontalAlign="Right">
                                </telerik:GridNumericColumn>                                
                                <telerik:GridTemplateColumn UniqueName="ShowToIndico" AutoPostBackOnFilter="True" Visible="true" HeaderText="Show To Indico"
                                    DataType="System.Boolean" CurrentFilterFunction="NoFilter" DataField="ShowToIndico" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblShowToIndico" runat="server" Width="60px" ></asp:Label>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridNumericColumn UniqueName="CalculateCM" SortExpression="CalculateCM" HeaderText="Calculate CM" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="CalculateCM">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="HPCost" SortExpression="HPCost" HeaderText="HP Cost" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="HPCost">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="LabelCost" SortExpression="LabelCost" HeaderText="Label Cost" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="LabelCost">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="CM" SortExpression="CM" HeaderText="CM" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="CM">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="JKFOBCost" SortExpression="JKFOBCost" HeaderText="JK FOB Cost" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="JKFOBCost">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="Roundup" SortExpression="Roundup" HeaderText="Round up" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="Roundup">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="SubCons" SortExpression="SubCons" HeaderText="Sub. Cons." DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="SubCons">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="MarginRate" SortExpression="MarginRate" HeaderText="Margin Rate" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="MarginRate">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="Duty" SortExpression="Duty" HeaderText="Duty" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="Duty">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="AirFregiht" SortExpression="AirFregiht" HeaderText="Air Fregiht" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="AirFregiht">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="ImpCharges" SortExpression="ImpCharges" HeaderText="Imp Charges" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="ImpCharges">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="Landed" SortExpression="Landed" HeaderText="Landed" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="Landed">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="MGTOH" SortExpression="MGTOH" HeaderText="MGT OH" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="MGTOH">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="IndicoOH" SortExpression="IndicoOH" HeaderText="Indico OH" DataFormatString="{0:0.00} " CurrentFilterFunction="Contains" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="IndicoOH">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="InkCost" SortExpression="InkCost" HeaderText="Ink Cost" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="InkCost">
                                </telerik:GridNumericColumn>
                                <telerik:GridNumericColumn UniqueName="PaperCost" SortExpression="PaperCost" HeaderText="Paper Cost" DataFormatString="{0:0.00} " CurrentFilterFunction="EqualTo" DataType="System.Decimal" Aggregate="Sum"
                                    FilterControlWidth="50px" AutoPostBackOnFilter="false"
                                    DataField="PaperCost">
                                </telerik:GridNumericColumn>
                                <telerik:GridDateTimeColumn UniqueName="ModifiedDate" DataField="ModifiedDate" HeaderText="Modified Date" FilterControlWidth="50px" Groupable="false" SortExpression="ModifiedDate" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridDateTimeColumn UniqueName="IndimanModifiedDate" DataField="IndimanModifiedDate" HeaderText="Indiman Modified Date" FilterControlWidth="50px" Groupable="false" SortExpression="IndimanModifiedDate" PickerType="DatePicker" EnableTimeIndependentFiltering="true"
                                    DataFormatString="{0:dd MMMM yyyy}">
                                </telerik:GridDateTimeColumn>
                                <telerik:GridTemplateColumn UniqueName="PatternImage" HeaderText="Images" AllowFiltering="false" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <a id="ancTemplateImage" onclick="return false;" runat="server" href="javascript:void(0);"><i id="iimageView"
                                            runat="server" class="icon-eye-open"></i></a>
                                        <div id="previewTemplate" runat="server" style="display: none;">
                                        </div>
                                        <a id="ancFullImage" runat="server" target="_blank" visible="false">View</a>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="" AllowFiltering="false">
                                    <ItemTemplate>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                            <ul class="dropdown-menu pull-right">
                                                <li>
                                                    <asp:HyperLink ID="linkEdit" runat="server" CssClass="btn-link iedit" ToolTip="Edit Cost Sheet"><i class="icon-pencil"></i>Edit</asp:HyperLink></li>
                                                <li>
                                                    <asp:LinkButton ID="btnSaveCostSheet" runat="server" CommandName="SaveCostSheet" CssClass="btn-link" ToolTip="Save Cost Sheet"><i class="icon-save"></i>Save</asp:LinkButton></li>
                                                <li>
                                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete CostSheet"><i class="icon-trash"></i>Delete</asp:HyperLink></li>
                                                <li>
                                                    <asp:LinkButton ID="btnPrintJkCostSheet" runat="server" CssClass="btn-link" OnClick="btnPrintJkCostSheet_Click" ToolTip="Print Factory Cost Sheet"><i class="icon-print"></i>Print Factory Cost Sheet</asp:LinkButton></li>
                                                <li>
                                                    <asp:LinkButton ID="btnIndimanCostSheet" runat="server" CssClass="btn-link" OnClick="btnIndimanCostSheet_Click" ToolTip="Print Indiman Cost Sheet"><i class="icon-print"></i>Print Indiman Cost Sheet</asp:LinkButton>
                                                </li>
                                                <li>
                                                    <asp:HyperLink ID="linkClone" runat="server" CssClass="btn-link iedit" ToolTip="Clone Cost Sheet"><i class="icon-edit"></i>Clone Cost Sheet</asp:HyperLink></li>
                                                <li>
                                                    <%--  <li>
                                                    <asp:HyperLink ID="lnkShowToIndico" runat="server" CssClass="btn-link iedit" ToolTip="Show to Indico"><i class="icon-edit"></i>Show to Indico</asp:HyperLink></li>
                                                <li> --%>
                                                <li>
                                                    <asp:LinkButton ID="btnShowToIndico" runat="server" CssClass="btn-link iedit" OnClick="btnShowToIndico_Click" ToolTip="Show to Indico"><i class="icon-edit"></i>Show to Indico</asp:LinkButton></li>
                                                <li>
                                            </ul>
                                        </div>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                        </MasterTableView>
                        <ClientSettings AllowDragToGroup="True">
                        </ClientSettings>
                        <GroupingSettings ShowUnGroupButton="true" />
                    </telerik:RadGrid>                   
                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> did not match
                            any Cost Sheet.</h4>
                    </div>
                </div>
                <!-- / -->
            </div>
            <!-- / -->
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <!-- Add / Edit Item -->
    <!-- Delete Item -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true" keyboard="false"
        data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>Delete CostSheet</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this Cost Sheet?
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" data-loading-text="Deleting..."
                type="submit" onserverclick="btnDelete_Click">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <script type="text/javascript">
        var hdnSelectedID = "<%=hdnSelectedID.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.idelete').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                $('#requestDelete').modal('show');
            });
        });
        $(".prevent").on("click", function (e) {

            e.preventDefault();

        });
    </script>
</asp:Content>
