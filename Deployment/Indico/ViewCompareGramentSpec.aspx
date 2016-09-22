<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true"
    CodeBehind="ViewCompareGramentSpec.aspx.cs" Inherits="Indico.ViewCompareGramentSpec" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
    </telerik:RadScriptManager>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h3>
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal></h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Empty Content -->
                <div class="row">
                    <div class="span12">
                        <div class="span4">
                            <div class="control-group">
                                <label class="control-label required">
                                    Pattern 1</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlPattern" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPattern_SelectedIndexChanged" CssClass="input-xlarge"></asp:DropDownList>
                                </div>
                            </div>
                        </div>
                        <div class="span4">
                            <div class="control-group">
                                <label class="control-label required">
                                    Pattern 2</label>
                                <div class="controls">
                                    <asp:DropDownList ID="ddlComparePattern" runat="server" Enabled="false" CssClass="input-xlarge"></asp:DropDownList>
                                </div>
                            </div>
                        </div>
                        <div class="span2">
                            <button id="btnCompareGarmenSpec" runat="server" class="btn btn-primary" type="submit" data-loading-text="Comparing..." onserverclick="btnCompareGarmenSpec_ServerClick">Compare</button>
                        </div>
                        <div class="span2">
                            <asp:HyperLink ID="linkNew" CssClass="btn btn-info" runat="server" NavigateUrl="~/ViewCompareGramentSpec.aspx">New</asp:HyperLink>
                        </div>
                    </div>
                </div>
                <!-- / -->
                <!-- Data Content -->
                <legend id="legPattern01" runat="server" visible="false">Pattern 1:
                    <asp:Literal ID="litPattern1" runat="server"></asp:Literal></legend>
                <div id="dvOriginalPattern" runat="server" visible="false">
                    <ol class="ioderlist-table">
                        <li class="idata-row">
                            <ul>
                                <li class="icell-header small">Key</li>
                                <li class="icell-header exlarge">Location</li>
                                <asp:Repeater ID="rptSpecSizeQtyHeader" runat="server" OnItemDataBound="rptSpecSizeQtyHeader_ItemDataBound">
                                    <ItemTemplate>
                                        <li class="icell-header">
                                            <asp:Literal ID="litCellHeader" runat="server"></asp:Literal>
                                        </li>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </ul>
                        </li>
                        <asp:Repeater ID="rptSpecML" runat="server" OnItemDataBound="rptSpecML_ItemDataBound">
                            <ItemTemplate>
                                <li class="idata-row">
                                    <ul>
                                        <li class="icell-header small">
                                            <asp:Literal ID="litCellHeaderKey" runat="server"></asp:Literal>
                                        </li>
                                        <li class="icell-header exlarge">
                                            <asp:Literal ID="litCellHeaderML" runat="server"></asp:Literal>
                                        </li>
                                        <asp:Repeater ID="rptSpecSizeQty" runat="server" OnItemDataBound="rptSpecSizeQty_ItemDataBound">
                                            <ItemTemplate>
                                                <li class="icell-data">
                                                    <asp:TextBox ID="txtQty" runat="server" CssClass="idouble"></asp:TextBox>
                                                </li>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </ul>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ol>
                    <!-- / -->
                </div>
                <div id="dvEmptyPattern" runat="server" class="alert alert-error fade-in" visible="false">
                    <button class="close" data-dismiss="alert" type="button">×</button>
                    <h4>Garment Specification is currently not available.
                    </h4>
                    <p>
                        You can add Garment Specification details for this pattern.
                    </p>
                    <p>
                        <asp:HyperLink ID="linkPattern" runat="server" CssClass="btn btn-danger">View Pattern</asp:HyperLink>
                    </p>
                </div>
                <legend id="legPattern02" runat="server" visible="false">Pattern 2:
                    <asp:Literal ID="litPattern2" runat="server"></asp:Literal></legend>
                <div id="dvComparePattern" runat="server" visible="false">
                    <ol class="ioderlist-table">
                        <li class="idata-row">
                            <ul>
                                <li class="icell-header small">Key</li>
                                <li class="icell-header exlarge">Location</li>
                                <asp:Repeater ID="rptCompareSpecSizeQtyHeader" runat="server" OnItemDataBound="rptCompareSpecSizeQtyHeader_ItemDataBound">
                                    <ItemTemplate>
                                        <li class="icell-header">
                                            <asp:Literal ID="litCellHeader" runat="server"></asp:Literal>
                                        </li>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </ul>
                        </li>
                        <asp:Repeater ID="rptCompareSpecML" runat="server" OnItemDataBound="rptCompareSpecML_ItemDataBound">
                            <ItemTemplate>
                                <li class="idata-row">
                                    <ul>
                                        <li class="icell-header small">
                                            <asp:Literal ID="litCellHeaderKey" runat="server"></asp:Literal>
                                        </li>
                                        <li class="icell-header exlarge">
                                            <asp:Literal ID="litCellHeaderML" runat="server"></asp:Literal>
                                        </li>
                                        <asp:Repeater ID="rptCompareSpecSizeQty" runat="server" OnItemDataBound="rptCompareSpecSizeQty_ItemDataBound">
                                            <ItemTemplate>
                                                <li class="icell-data">
                                                    <asp:TextBox ID="txtQty" runat="server" CssClass="idouble"></asp:TextBox>
                                                </li>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </ul>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ol>
                    <!-- / -->
                </div>
                <div id="dvComparePatternEmpty" runat="server" class="alert alert-error fade-in" visible="false">
                    <button class="close" data-dismiss="alert" type="button">×</button>
                    <h4>Garment Specification is currently not available.
                    </h4>
                    <p>
                        You can add Garment Specification details for this pattern.
                    </p>
                    <p>
                        <asp:HyperLink ID="linkComparePattern" runat="server" CssClass="btn btn-danger">View Pattern</asp:HyperLink>
                    </p>
                </div>
                <legend id="legDiffrence" runat="server" visible="false">Difference</legend>
                <div id="dvDiffrence" runat="server" visible="false">
                    <ol class="ioderlist-table">
                        <li class="idata-row">
                            <ul>
                                <li class="icell-header small">Key</li>
                                <li class="icell-header exlarge">Location</li>
                                <asp:Repeater ID="rptDiffSpecSizeQtyHeader" runat="server" OnItemDataBound="rptDiffSpecSizeQtyHeader_ItemDataBound">
                                    <ItemTemplate>
                                        <li class="icell-header">
                                            <asp:Literal ID="litCellHeader" runat="server"></asp:Literal>
                                        </li>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </ul>
                        </li>
                        <asp:Repeater ID="rptDiffSpecML" runat="server" OnItemDataBound="rptDiffSpecML_ItemDataBound">
                            <ItemTemplate>
                                <li class="idata-row">
                                    <ul>
                                        <li class="icell-header small">
                                            <asp:Literal ID="litCellHeaderKey" runat="server"></asp:Literal>
                                        </li>
                                        <li class="icell-header exlarge">
                                            <asp:Literal ID="litCellHeaderML" runat="server"></asp:Literal>
                                        </li>
                                        <asp:Repeater ID="rptDiffSpecSizeQty" runat="server" OnItemDataBound="rptDiffSpecSizeQty_ItemDataBound">
                                            <ItemTemplate>
                                                <li class="icell-data">
                                                    <asp:TextBox ID="txtQty" runat="server" CssClass="idouble"></asp:TextBox>
                                                </li>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </ul>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ol>
                    <!-- / -->
                </div>
                <div id="dvEmptyDiffrence" runat="server" class="alert alert-error fade-in" visible="false">
                    <button class="close" data-dismiss="alert" type="button">×</button>
                    <h4>Diffrences are not available. </h4>
                </div>
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
    <asp:HiddenField ID="hdnSelectedUserID" runat="server" Value="0" />
    <script type="text/javascript">
        var ddlPattern = "<%=ddlPattern.ClientID %>";
        var ddlComparePattern = "<%=ddlComparePattern.ClientID %>";
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#' + ddlPattern).select2();
            $('#' + ddlComparePattern).select2();
        });
    </script>
</asp:Content>
