<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="Indico.Error" %>

<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Indico Errorr</title>
    <link rel="shortcut icon" href="/favicon.ico" />
    <link href="Content/css/bootstrap.min.css" rel="stylesheet" />    
    <style type="text/css">
        body {
            background: #f2f2f2;
            padding-top: 65px;
            text-align: center;
            font-family: Arial,Helvetica,sans-serif;
        }

        a, a:hover {
            color: #185787;
        }

        p {
            margin: 0;
            padding: 0 0 13px 0;
        }

        .container {
            width: 580px;
            background: #FFF;
        }

        .cta {
            background: #f1fafe;
            font-size: 14px;
            color: #1f1f1f;
            border-top: 1px solid #dae3ea;
            border-bottom: 1px solid #dae3ea;
            border-left: 1px solid #DDD;
            border-right: 1px solid #DDD;
            margin: 0;
            padding: 24px 19px 8px 39px;
            text-align: left;
        }

            .cta h3 {
                margin: -3px 0 14px 0;
            }

            .cta p {
                font-size: 12px;
                font-weight: normal;
                line-height: 20px;
            }

        .footer {
            color: #797c80;
            font-size: 12px;
            border-left: 1px solid #DDD;
            border-right: 1px solid #DDD;
            padding-top: 23px;
            padding-left: 39px;
            padding-right: 13px;
            padding-bottom: 23px;
            text-align: left;
        }

        .img_bottom {
            padding: 0;
            margin: 0;
        }

        .reopen {
            padding: 27px 39px 14px 39px;
            text-align: left;
            border-left: 1px solid #DDD;
            border-right: 1px solid #DDD;
            border-bottom: 1px solid #ddd;
        }

            .reopen h3 {
                color: #5c5c5c;
                font-weight: bold;
                font-size: 14px;
                padding: 0;
                margin: 0 0 18px 0;
            }

            .reopen p {
                margin: 0 0 15px 0;
                padding: 0;
                font-size: 12px;
                color: #4c4c4c;
                line-height: 20px;
            }

        .title {
            padding-top: 26px;
            padding-left: 39px;
            padding-right: 39px;
            text-align: left;
            border-top: 1px solid #ddd;
            border-left: 1px solid #DDD;
            border-right: 1px solid #DDD;
        }

            .title h2 {
                font-size: 34px;
                color: #363636;
                font-weight: normal;
                margin: 0 0 13px 0;
                padding: 0;
                letter-spacing: 0;
            }

            .title h3 {
                font-size: 16px;
                color: #3e434a;
                font-weight: normal;
                margin: 0 0 26px 0;
                padding: 0;
                line-height: 25px;
            }

        .unsub {
            margin-top: 100px;
            color: #f2f2f2;
        }

        .byline {
            display: block;
            font-size: 16px;
            color: #666;
            padding-top: 5px;
            padding-bottom: 7px;
        }
    </style>
</head>
<body>
    <div class="jumbotron">
        <table class="container" align="center" cellspacing="0" style="border: none" cellpadding="0" width="580" bgcolor="#FFFFFF">
            <tr>
                <td class="title">
                    <h2>Indico Application encountered an error it was unable to recover from</h2>
                    <%--<h3>@Resources.h3UnexpectedError1
                    <br />
                    @Resources.h3UnexpectedError2
                </h3>--%>
                </td>
            </tr>
            <tr>
                <td>
                    <button class="btn btn-primary btn-sm" onclick="window.history.back();" type="button">
                        Back
                    </button>
                </td>
            </tr>
            <%--<tr>
            <td class="reopen">
                <p>@Resources.pharagraphUnexpectedError <a href="mailto: @GMGColorConfiguration.AppConfiguration.HelpDeskEmailAddress?subject=@Resources.lblEmailSubject">@Resources.lblSiteOwner.ToLower()</a></p>
            </td>
        </tr>--%>
        </table>
    </div>
</body>
</html>
<%--<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Indico Error</title>
</head>
<body>
    <form id="form1" runat="server">

        <div id="mainContent">

            <!-- Page Heading -->

            <div class="container-fluid">
                <div class="row-fluid">
                    <div class="span12">
                        <h2>The Indico Application encountered an error it was unable to recover from</h2>
                        <div class="importantBox" style="overflow: auto;">
                            <pre style="font-size: 1.8em;"><asp:Literal id="litError" runat="server"></asp:Literal></pre>
                        </div>
                        <div class="alert">
                            <h4 id="pageInstructions" runat="server"></h4>
                            <button class="btn btn-primary btn-sm pull-right" onclick="window.history.back();" type="button">
                                <span aria-hidden="true" class="glyphicon glyphicon-chevron-left"></span>&nbsp;Back
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- BEGIN FOOTER CONTENT -->
            <!--  <div id="footer" style="display:none;">
	                    <ul>
		                    <li><span id="pbdTemplate__PageTemplate_InnerContents_FormView_Footer_FooterText">&copy; 2011 PMP Limited</span></li>
	                    </ul>
	                    <p>Powered by <strong>AdCast</strong></p> 
                    </div>  -->
            <!-- END FOOTER CONTENT -->

        </div>
    </form>
</body>
</html>--%>
