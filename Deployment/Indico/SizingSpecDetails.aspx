<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SizingSpecDetails.aspx.cs" Inherits="Indico.SizingSpecDetails" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Blackchrome Sportswear</title>
    <link href="/Content/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/Content/css/bcs-style.css" rel="stylesheet" />
    <script src="/Content/js/jquery-2.1.3.min.js"></script>
    <script src="/Content/js/jquery-migrate-1.2.1.min.js"></script>
</head>
<body>
    <div class="container">
        <form id="frmMain" runat="server">
            <asp:Literal ID="litPostBackScript" runat="server"></asp:Literal>
            <div id="overlay" class="row">
                <div class="col-md-12 col-sm-12 col-xs-12" style="margin-top: 20px;">
                    <%--<button class="btn btn-primary btn-sm pull-right" onclick="window.history.back();" type="button">
                        <span aria-hidden="true" class="glyphicon glyphicon-chevron-left"></span>&nbsp;Back
                    </button>--%>
                    <img src="/IndicoData/Logo/blackchrome2015.png" style="margin-left: -35px;" />
                </div>
                <div class="col-md-12 col-sm-12 col-xs-12">
                    <div class="row">
                        <div class="col-md-6 col-sm-6 col-xs-12">
                            <div class="item-images">
                                <div id="imageother" class="images-other">
                                    <a id="lnkImage1" runat="server" href="#" data-image="data/noimage-item-1.png" data-zoom-image="data/noimage-item-1.png">
                                        <img id="imgOther1" runat="server" class="zoom-thumb" src="data/noimage-item-1.png" />
                                    </a>
                                    <a id="lnkImage2" runat="server" href="#" data-image="data/noimage-item-2.png" data-zoom-image="data/noimage-item-2.png">
                                        <img id="imgOther2" runat="server" class="zoom-thumb" src="data/noimage-item-2.png" />
                                    </a>
                                    <a id="lnkImage3" runat="server" href="#" data-image="data/noimage-item-3.png" data-zoom-image="data/noimage-item-3.png">
                                        <img id="imgOther3" runat="server" class="zoom-thumb" src="data/noimage-item-3.png" />
                                    </a>
                                </div>
                                <div class="image-hero">
                                    <a href="javascript:void(0);">
                                        <img id="imgHero" runat="server" src="data/noimage-item-1.png" />
                                    </a>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6 col-sm-6 col-xs-12">
                            <div class="item-detail">
                                <h4 id="lblNumber" runat="server"></h4>
                                <h3 id="lblRemarks" runat="server"></h3>
                                <h4 id="lblGender" runat="server"></h4>
                                <h5 id="lblDescription" runat="server"></h5>
                                <div class="overlay-social">
                                    <div>
                                        <a class="addthis_button_preferred_1"></a>
                                        <a class="addthis_button_preferred_2"></a>
                                        <a class="addthis_button_preferred_3"></a>
                                        <a class="addthis_button_preferred_4"></a>
                                        <a class="addthis_button_compact"></a>
                                        <a class="addthis_counter addthis_bubble_style"></a>
                                    </div>
                                </div>
                                <div class="download-pdf">
                                    <asp:LinkButton class="btn btn-primary btn-sm" runat="server" ID="lbDownload" OnClick="lbDownload_Click">Download Size Spec PDF <span aria-hidden="true" class="glyphicon glyphicon-download-alt"></span></asp:LinkButton>
                                </div>
                                <!--<div class="customer">
                                    <label>Customer Rating </label>
                                    <div style="display: none;" class="ajax-icon">
                                        <img alt="loading" src="Content/img/ajax-loader.gif" />
                                    </div>
                                    <div class="stars">
                                        <asp:LinkButton ID="btnStarRating1" runat="server" OnClick="btnStarRating_Click" ToolTip="1">
                                            <span class="glyphicon glyphicon-star" aria-hidden="true"></span>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnStarRating2" runat="server" OnClick="btnStarRating_Click" ToolTip="2">
                                            <span class="glyphicon glyphicon-star" aria-hidden="true"></span>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnStarRating3" runat="server" OnClick="btnStarRating_Click" ToolTip="3">
                                            <span class="glyphicon glyphicon-star" aria-hidden="true"></span>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnStarRating4" runat="server" OnClick="btnStarRating_Click" ToolTip="4">
                                            <span class="glyphicon glyphicon-star" aria-hidden="true"></span>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnStarRating5" runat="server" OnClick="btnStarRating_Click" ToolTip="5">
                                            <span class="glyphicon glyphicon-star" aria-hidden="true"></span>
                                        </asp:LinkButton>
                                        <asp:Label ID="lblStarMsg" runat="server">(Product rated 0 times)</asp:Label>
                                    </div>
                                    <span>Click on the star to give your rating</span>
                                </div>-->
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-12 col-sm-12 col-xs-12">
                    <div class="item-gspec">
                        <img id="imgGamentSpec" runat="server" src="images/003.jpg" />
                    </div>
                </div>
                <div class="col-md-12 col-sm-12 col-xs-12">
                    <table class="table table-striped">
                        <caption>
                            <label>Garment Specification</label>
                            <div class="btn-group pull-right" id="dvUnits" runat="server" visible="false">
                                <a class="btn btn-primary btn-sm" href="javascript:void(0);">inches</a>
                                <a class="btn btn-primary btn-sm active" href="javascript:void(0);">cm</a>
                            </div>
                        </caption>
                        <tbody>
                            <asp:Literal ID="litSpecBody" runat="server" Visible="false"></asp:Literal>
                        </tbody>
                    </table>
                    <asp:Image ID="imgSpec" runat="server" Visible="false" />
                    <asp:HiddenField ID="hdnType" runat="server" Value="0" />
                </div>
                <div class="col-md-12 col-sm-12 col-xs-12">
                    <p class="text-info pull-right inches">Tolerance +/- 0.5 inches</p>
                    <p class="text-info pull-right cm">Tolerance +/- 1.0 cm</p>
                </div>
            </div>
        </form>
    </div>
    <script>var type = '<%=this.hdnType.ClientID%>';</script>
    <script src="/Content/js/bootstrap.min.js"></script>
    <script src="/Content/js/jquery.elevatezoom.js"></script>
    <script src="/Content/js/bcs-script.js"></script>
</body>
</html>
