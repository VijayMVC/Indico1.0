<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewPriceLists.aspx.cs" Inherits="Indico.ViewPriceLists" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-actions">
                <a id="btnAddPriceList" runat="server" class="btn btn-link pull-right" href="~/AddPriceList.aspx">
                    New Price List</a>
            </div>
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h3>
            <!-- / -->
            <!-- Page Content -->
            <div class="page-content">
                <div class="row-fluid">
                    <!-- Empty Content -->
                    <div id="dvEmptyContent" runat="server" class="alert alert-info">
                        <h4>
                            <a href="/AddPriceList.aspx" title="Add an Company.">Add the first Price List.</a>
                        </h4>
                        <p>
                            You can add as many price lists as you like.</p>
                    </div>
                    <!-- / -->
                    <!-- Data Content -->
                    <div id="dvDataContent" runat="server">
                        <!-- Search Control -->
                        <div class="search-control clearfix">
                            <div class="form-inline pull-right">
                                <label>
                                    Type</label>
                                <asp:DropDownList ID="ddlType" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlType_SelectedIndexChanged">
                                    <asp:ListItem Value="0">All</asp:ListItem>
                                    <asp:ListItem Value="1">Distributor</asp:ListItem>
                                    <asp:ListItem Value="2">Label</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                                <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                    OnClick="btnSearch_Click" /></asp:Panel>
                        </div>
                        <!-- / -->
                        <!-- Data Table -->
                        <div class="accordion-group">
                            <div class="accordion-heading">
                                <a class="accordion-toggle" data-toggle="collapse" href="#collapse1">Price List</a>
                                <div id="collapse1" class="accordion-body collapse in">
                                    <div class="accordion-inner">
                                        <asp:DataGrid ID="dgPriceLists" runat="server" CssClass="table" AllowCustomPaging="False"
                                            AllowPaging="True" AllowSorting="true" AutoGenerateColumns="false" GridLines="None"
                                            PageSize="20" OnItemDataBound="dgPriceLists_ItemDataBound" OnPageIndexChanged="dgPriceLists_PageIndexChanged">
                                            <HeaderStyle CssClass="header" />
                                            
                                            
                                            <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                                            <Columns>
                                                <asp:TemplateColumn HeaderText="Type">
                                                    <ItemTemplate>
                                                        <asp:Literal ID="lblType" runat="server"></asp:Literal>
                                                    </ItemTemplate>
                                                </asp:TemplateColumn>
                                                <asp:TemplateColumn HeaderText="Name">
                                                    <ItemTemplate>
                                                        <asp:Literal ID="litDistributor" runat="server"></asp:Literal>
                                                    </ItemTemplate>
                                                </asp:TemplateColumn>
                                                <asp:TemplateColumn HeaderText="Term">
                                                    <ItemTemplate>
                                                        <asp:Literal ID="litPriceTerm" runat="server"></asp:Literal>
                                                    </ItemTemplate>
                                                </asp:TemplateColumn>
                                                <asp:TemplateColumn HeaderText="Designs">
                                                    <ItemTemplate>
                                                        <asp:Literal ID="litDesigns" runat="server"></asp:Literal>
                                                    </ItemTemplate>
                                                </asp:TemplateColumn>
                                                <asp:TemplateColumn HeaderText="Positions">
                                                    <ItemTemplate>
                                                        <asp:Literal ID="litPositions" runat="server"></asp:Literal>
                                                    </ItemTemplate>
                                                </asp:TemplateColumn>
                                                <asp:TemplateColumn HeaderText="File Name">
                                                    <ItemTemplate>
                                                        <asp:Literal ID="lblFileName" runat="server"></asp:Literal>
                                                    </ItemTemplate>
                                                </asp:TemplateColumn>
                                                <asp:TemplateColumn HeaderText="Created Date">
                                                    <ItemTemplate>
                                                        <asp:Literal ID="lblCreatedDate" runat="server"></asp:Literal>
                                                    </ItemTemplate>
                                                </asp:TemplateColumn>
                                                <asp:TemplateColumn HeaderText="Status">
                                                    <ItemTemplate>
                                                        <asp:Literal ID="lblStatus" runat="server"></asp:Literal>
                                                    </ItemTemplate>
                                                </asp:TemplateColumn>
                                                <asp:TemplateColumn HeaderText="">
                                                    <ItemTemplate>
                                                        <div class="btn-group pull-right">
                                                            <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                                                                <i class="icon-cog"></i><span class="caret"></span></a>
                                                            <ul class="dropdown-menu pull-right">
                                                                <li>
                                                                    <asp:LinkButton ID="linkDownload" runat="server" CssClass="btn-link iexcel" OnClick="btnDownload_Click"
                                                                        ToolTip="Download File"><i class="icon-download-alt"></i>Download</asp:LinkButton></li>
                                                                <li>
                                                                    <asp:HyperLink ID="linkOnProgress" runat="server" CssClass="btn-link iloading" ToolTip="In Progress"><i class="icon-refresh"></i>Progress</asp:HyperLink></li>
                                                                <li>
                                                                    <asp:HyperLink ID="linkDelete" data-toggle="tooltip" runat="server" CssClass="btn-link idelete"
                                                                        CommandName="Delete Excel" ToolTip="Delete Excel"><i class="icon-trash"></i>Delete
                                                                    </asp:HyperLink>
                                                                </li>
                                                            </ul>
                                                        </div>
                                                    </ItemTemplate>
                                                </asp:TemplateColumn>
                                            </Columns>
                                        </asp:DataGrid>
                                    </div>
                                </div>
                                <!-- / -->
                                <!-- No Search Result -->
                                <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                                    <h4>
                                        Your search - <strong>
                                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                                        any distributor pricelist.</h4>
                                </div>
                                <!-- / -->
                                <!-- dv empty result -->
                                <div id="dvemptyresult" runat="server" class="alert alert-info" visible="false">
                                    <h4>
                                        No Distributor Price Lists Found</h4>
                                    <p>
                                        You can add as many distributor price lists as you like</p>
                                </div>
                            </div>
                            <!-- / -->
                        </div>
                        <!-- / -->
                    </div>
                </div>
                <!-- / -->
            </div>
        </div>
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnUserID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnSelectedID" runat="server" Value="0" />
    <asp:HiddenField ID="hdnType" runat="server" Value="" />
    <!-- Delete Excel -->
    <div id="requestDelete" class="modal fade" role="dialog" aria-hidden="true"
        keyboard="false" data-backdrop="static">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                ×</button>
            <h3>
                Delete Price List</h3>
        </div>
        <div class="modal-body">
            <p>
                Are you sure you wish to delete this price list?</p>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">
                No</button>
            <button id="btnDelete" runat="server" class="btn btn-primary" type="submit" onserverclick="btnDelete_Click"
                data-loading-text="Deleting...">
                Yes</button>
        </div>
    </div>
    <!-- / -->
    <!-- Progressbar -->
    <div id="dvProgress" class="modal transparent">
        <h4 class="progress-title">
            Generating Price List ...</h4>
        <div class="progress active">
            <div class="bar" style="width: 0%;">
            </div>
        </div>
        <asp:Button ID="btnDownload" runat="server" CssClass="hide hideOverly" OnClick="btnDownload_Click" />
    </div>
    <!-- / -->
    <!-- / -->
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var hdnSelectedID = "<%=hdnSelectedID.ClientID%>";
        var hdnType = "<%=hdnType.ClientID%>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.idelete').click(function () {
                $('#' + hdnSelectedID).val($(this).attr('qid'));
                $('#' + hdnType).val($(this).attr('istype'));
                $('#requestDelete').modal('show');
            });


            //isPostBack();
            window.setTimeout(function () { window.location = window.location; }, (1000 * 30));
        });
        /* var postbackTimer;
        function isPostBack() {
        postbackTimer = setInterval('postBack()', 1000);

        }*/
        /*    function postBack() {
        $.ajax({
        type: 'POST',
        url: '/ViewPriceLists.aspx/Progress',
        contentType: "application/json; charset=utf-8",
        data: '{"UserID":"' + $('input[type=hidden[id$=hdnUserID]').val() + '"}',
        dataType: 'json',
        error: function (xhr, ajaxOptions, thrownError) {
        //alert('Status : ' + xhr.status + '\n Message : ' + xhr.statusText + '\n ex : ' + thrownError);
        },
        success: function (msg) {
        if (Number(msg.d) == 100) {
        //  $('#' + btnPostBack).click();
        $('.is').addClass('complete');
        $('.is').text('Complete');
        $('.iloading').hide();
        $('.iexcel').show();
        clearInterval(postbackTimer);
        }
        else if (Number(msg.d) > 0) {
        //$('#dvProgress .progress .bar')[0].style.width = Number(msg.d) + '%';
        }
        }
        });
        }*/
    </script>
</asp:Content>
