<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddEditSizes.aspx.cs" MasterPageFile="~/Indico.Master"
    Inherits="Indico.AddEditSizes" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h1>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </h1>
            <asp:Button ID="btnAddSizes" runat="server" CssClass="btn btn-primary iadd pull-right"
                OnClick="btnAddSizes_Click" Text="New Sizes" Url="/ViewSizes.aspx" />
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="inner">
                <!-- Page Data -->
                <fieldset>
                    <h3>Details
                    </h3>
                    <p class="required">
                        Indicates required fields
                    </p>
                    <ol>
                        <li>
                            <label class="required">
                                Size Set</label>
                            <asp:DropDownList ID="ddlSizeSet" runat="server">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvSizeSet" runat="server" ErrorMessage=" Size Set  is required"
                                ControlToValidate="ddlSizeSet" InitialValue="0" EnableClientScript="false">
                        <img src="Content/img/icon_warning.png"  title="Size Set is required" alt="Size Set  is required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label class="required">
                                Size Name</label>
                            <asp:TextBox ID="txtSizeName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvSizeName" runat="server" ErrorMessage="Size Name is required"
                                ControlToValidate="txtSizeName" EnableClientScript="false">
                        <img src="Content/img/icon_warning.png"  title="Size Name  is required" alt="Size Name is required" />
                            </asp:RequiredFieldValidator>
                        </li>
                        <li>
                            <label class="required">
                                Seq No</label>
                            <asp:TextBox ID="txtSeqNo" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvSeqNo" runat="server" ErrorMessage="Seq No is required"
                                ControlToValidate="txtSeqNo" EnableClientScript="false">
                        <img src="Content/img/icon_warning.png"  title="Seq No is required" alt="Seq No is required" />
                            </asp:RequiredFieldValidator>
                        </li>
                    </ol>
                </fieldset>
                <!-- / -->
                <!-- Data Content -->
                <div id="dvDataContent" runat="server">
                    <!-- Search Control -->
                    <div class="search-control clearfix">
                        <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-control-query" placeholder="Search"></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" CssClass="search-control-button" Text="Search"
                                OnClick="btnSearch_Click" />
                        </asp:Panel>
                    </div>
                    <!-- / -->
                    <!-- Data Table -->

                    <asp:DataGrid ID="dgAddEditSizes" runat="server" CssClass="table" AllowCustomPaging="False"
                        AllowPaging="True" AutoGenerateColumns="false" GridLines="None" PageSize="10"
                        OnItemDataBound="dgAddEditSizes_ItemDataBound" OnPageIndexChanged="dgAddEditSizes_PageIndexChanged">
                        <HeaderStyle CssClass="header" />


                        <PagerStyle CssClass="idata-pager" Mode="NumericPages" />
                        <Columns>
                            <asp:TemplateColumn HeaderText="Size Name" ItemStyle-Width="32%">
                                <ItemTemplate>
                                    <asp:Label ID="lblSizeName" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Seq No" ItemStyle-Width="30%">
                                <ItemTemplate>
                                    <asp:Label ID="lblSeqNo" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Size Set" ItemStyle-Width="30%">
                                <ItemTemplate>
                                    <asp:Label ID="lblSizeSet" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                            <asp:TemplateColumn HeaderText="Delete" ItemStyle-Width="4%">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkDelete" runat="server" CssClass="btn-link idelete" ToolTip="Delete Item"></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateColumn>
                        </Columns>
                    </asp:DataGrid>

                    <!-- / -->
                    <!-- No Search Result -->
                    <div id="dvNoSearchResult" runat="server" class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> - did not match
                            any documents.</h4>
                    </div>
                    <!-- / -->
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedSizeID" runat="server" Value="0" />
    <!-- Delete Item -->
    <div id="requestDelete" class="modal">
        <div class="modal-header">
            <h2>Delete Item</h2>
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        </div>
        <div class="modal-body">
            Are you sure you wish to delete this Item?
        </div>
        <div class="modal-footer">
            <asp:Button ID="btnDelete" runat="server" CssClass="btn firePopupSave" Text="Yes"
                Url="/ViewSizes.aspx" OnClick="btnDelete_Click" />
            <input id="btnCancel" class="btn firePopupCancel" type="button" value="No" />
        </div>
    </div>
    <!-- / -->
    <script type="text/javascript">
        var IsPageValid = ('<%=ViewState["IsPageValied"]%>' == 'True') ? true : false;
        var hdnSelectedSizeID = "<%=hdnSelectedSizeID.ClientID %>";         
    </script>
    <script type="text/javascript">
        $('.idelete').click(function () {
            $('#' + hdnSelectedSizeID)[0].value = $(this).attr('qid');
            showPopupBox('requestDelete', '380');
        });
    </script>
</asp:Content>
