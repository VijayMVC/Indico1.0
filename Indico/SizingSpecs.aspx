<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SizingSpecs.aspx.cs" Inherits="Indico.SizingSpecs" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Blackchrome Sportswear</title>
    <link href="/Content/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/Content/css/bcs-style.css" rel="stylesheet" />
    <script src="/Content/js/jquery-2.1.3.min.js"></script>
    <script src="/Content/js/jquery-migrate-1.2.1.min.js"></script>
</head>
<body>
    <div class="container-fluid wrapper">
        <form id="frmMain" runat="server">
            <asp:Literal ID="litPostBackScript" runat="server"></asp:Literal>
            <div class="row">
                <!--Search-->
                <div class="col-md-5 col-sm-5 col-xs-12">
                    <div class="gspec-search">
                        <input id="txtSearch" runat="server" class="form-control input-sm" name="search" placeholder="To search type and hit enter..." type="text" />
                        <button id="btnSearch" runat="server" class="btn btn-primary btn-sm" onserverclick="btnSearch_Click">
                            <span aria-hidden="true" class="glyphicon glyphicon-search"></span>
                        </button>
                    </div>
                </div>
                <!--Navigation-->
                <div class="col-md-7 col-sm-7 col-xs-12">
                    <div class="gspec-menu row">
                        <%--<div class="col-md-2 col-sm-2 col-xs-12">&nbsp;</div>--%>
                        <asp:Repeater ID="rptMenuItem" runat="server" OnItemDataBound="rptMenuItem_ItemDataBound">
                            <ItemTemplate>
                                <div class="col-md-2 col-sm-2 col-xs-12 dropdown">
                                    <asp:HyperLink ID="ancMenu" runat="server" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="true"></asp:HyperLink>
                                    <ul class="col-md-2 col-sm-2 col-xs-12 dropdown-menu" role="menu">
                                        <li role="presentation">
                                            <a href="javascript:void(0);">
                                                <strong>
                                                    <asp:Literal ID="lblMenu" runat="server"></asp:Literal></strong>
                                            </a>
                                        </li>
                                        <li class="divider" role="presentation"></li>
                                        <asp:Repeater ID="rptCategory" runat="server" OnItemDataBound="rptCategory_ItemDataBound">
                                            <ItemTemplate>
                                                <li role="presentation">
                                                    <asp:HyperLink ID="ancCategory" runat="server"></asp:HyperLink>
                                                </li>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </ul>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
            <div class="row">
                <!--SortBy-->
                <div class="col-md-4 col-sm-6 col-xs-12 pull-left">
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="sorting">
                                <label>Sort by:</label>
                                <asp:LinkButton runat="server" ID="btnCoreRange" OnClick="btnSortBy_Click" Text="Core Range" CommandName="CoreRange"></asp:LinkButton>
                                | 
                            <asp:LinkButton runat="server" ID="btnNumber" OnClick="btnSortBy_Click" Text="Number" CommandName="Number"></asp:LinkButton>
                                | 
                                <asp:LinkButton runat="server" ID="btnNewest" OnClick="btnSortBy_Click" Text="Newest" CommandName="Newest"></asp:LinkButton>
                                <!--| 
                                <asp:LinkButton runat="server" ID="btnPopular" OnClick="btnSortBy_Click" Text="Most popular" CommandName="Popular"></asp:LinkButton>
                        | 
                                <asp:LinkButton runat="server" ID="btnRating" OnClick="btnSortBy_Click" Text="Rating" CommandName="Rating"></asp:LinkButton>-->
                            </div>
                        </div>
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="info">
                                <asp:Literal ID="litDisplayMessage" runat="server" Text="Displaying 0 - 0 of 0"></asp:Literal>
                            </div>
                        </div>
                    </div>
                </div>
                <!--Pagination-->
                <div class="col-md-8 col-sm-11 col-xs-12">
                    <nav id="dvPagingHeader" runat="server" class="pull-right">
                        <ul class="pagination">
                            <li>
                                <asp:LinkButton ID="lbHeaderPrevious" runat="server" OnClick="lbHeaderPrevious_Click">
                                            <span aria-hidden="true">&laquo;</span>
                                </asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbHeaderPreviousDots" runat="server" OnClick="lbHeaderPreviousDots_Click">
                                ...
                                </asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbHeader1" runat="server" CssClass="active" OnClick="lbHeader1_Click">1</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbHeader2" runat="server" OnClick="lbHeader1_Click">2</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbHeader3" runat="server" OnClick="lbHeader1_Click">3</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbHeader4" runat="server" OnClick="lbHeader1_Click">4</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbHeader5" runat="server" OnClick="lbHeader1_Click">5</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbHeader6" runat="server" OnClick="lbHeader1_Click">6</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbHeader7" runat="server" OnClick="lbHeader1_Click">7</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbHeader8" runat="server" OnClick="lbHeader1_Click">8</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbHeader9" runat="server" OnClick="lbHeader1_Click">9</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbHeader10" runat="server" OnClick="lbHeader1_Click">10</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbHeaderNextDots" runat="server" OnClick="lbHeaderNextDots_Click">
                                ...
                                </asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbHeaderNext" runat="server" OnClick="lbHeaderNext_Click">
                                            <span aria-hidden="true">&raquo;</span>
                                </asp:LinkButton>
                            </li>
                        </ul>
                    </nav>
                </div>
            </div>
            <div class="row">
                <!-- Empty Content -->
                <div id="dvEmptyContent" runat="server" class="col-md-12 col-sm-12 col-xs-12">
                    <div class="alert alert-info">
                        <h4>There are no items to display.</h4>
                    </div>
                </div>
                <!-- Data Content -->
                <div id="dvDataContent" runat="server" class="col-md-12 col-sm-12 col-xs-12">
                    <div class="gspec-bloks">
                        <asp:Repeater ID="rptGarmentSpecs" runat="server" OnItemDataBound="rptGarmentSpecs_ItemDataBound">
                            <ItemTemplate>
                                <div class="block-wrap">
                                    <div class="block">
                                        <a id="linkPattern" runat="server" data-toggle="tooltip" data-placement="bottom" pattern="0" title="Click to View">
                                            <div class="block-image">
                                                <asp:Image ID="imgItem" runat="server" />
                                            </div>
                                            <label id="lblDescription" runat="server" class="block-desc-main"></label>
                                            <label id="lblAgeGroupGender" runat="server" class="block-desc-other">MENS - ADULT</label>
                                            <label id="lblSizeSet" runat="server" class="block-desc-other">XS - 5XL</label>
                                        </a>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
                <!-- No Search Result -->
                <div id="dvNoSearchResult" runat="server" class="col-md-12 col-sm-12 col-xs-12">
                    <div class="message search" visible="false">
                        <h4>Your search - <strong>
                            <asp:Label ID="lblSerchKey" runat="server"></asp:Label></strong> did not match any records.
                        </h4>
                    </div>
                </div>
            </div>
            <div class="row">
                <!--Pagination-->
                <div class="col-md-offset-5 col-md-7 col-sm-offset-1 col-sm-11 col-xs-12">
                    <nav id="dvPagingFooter" runat="server" class="pull-right">
                        <ul class="pagination">
                            <li>
                                <asp:LinkButton ID="lbFooterPrevious" runat="server" class="paginatorPreviousButton" OnClick="lbHeaderPrevious_Click">
                                            <span aria-hidden="true">&laquo;</span>
                                </asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbFooterPreviousDots" runat="server" class="" OnClick="lbHeaderPreviousDots_Click">
                                ...
                                </asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbFooter1" runat="server" CssClass="active" OnClick="lbHeader1_Click">1</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbFooter2" runat="server" OnClick="lbHeader1_Click">2</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbFooter3" runat="server" OnClick="lbHeader1_Click">3</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbFooter4" runat="server" OnClick="lbHeader1_Click">4</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbFooter5" runat="server" OnClick="lbHeader1_Click">5</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbFooter6" runat="server" OnClick="lbHeader1_Click">6</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbFooter7" runat="server" OnClick="lbHeader1_Click">7</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbFooter8" runat="server" OnClick="lbHeader1_Click">8</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbFooter9" runat="server" OnClick="lbHeader1_Click">9</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbFooter10" runat="server" OnClick="lbHeader1_Click">10</asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbFooterNextDots" runat="server" class="dots" OnClick="lbHeaderNextDots_Click">
                                ...
                                </asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton ID="lbFooterNext" runat="server" class="paginatorNextButton" OnClick="lbHeaderNext_Click" Text="Next">
                                            <span aria-hidden="true">&raquo;</span>
                                </asp:LinkButton>
                            </li>
                        </ul>
                    </nav>
                </div>
            </div>
        </form>
    </div>
    <script>
        var btnsearch = '<%=this.btnSearch.ClientID%>';
    </script>
    <script src="/Content/js/bootstrap.min.js"></script>
    <script src="/Content/js/jquery.elevatezoom.js"></script>
    <script src="/Content/js/bcs-script.js"></script>
</body>
</html>

