<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Navigation.ascx.cs"
    Inherits="Indic.Controls.Navigation" %>

<div class="navbar navbar-inverse">
    <div class="navbar-inner">
        <div class="container-fluid">
            <button data-target=".nav-collapse" data-toggle="collapse" class="btn btn-navbar" type="button">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="brand" href="javascript:void(0);"></a>
            <div class="nav-collapse collapse">
                <ul class="nav pull-right">
                    <li class="dropdown<%=this.IsSettingActive%>">
                        <a class="dropdown-toggle" data-toggle="dropdown" href="javascript:void(0);">
                            <span class="avatar-name">
                                <asp:Literal ID="litUsername" runat="server"></asp:Literal>
                            </span>
                            <div class="avatar-default">
                                <img src="<%=Indico.BusinessObjects.UserBO.GetProfilePicturePath(this.LoggedUser, Indico.BusinessObjects.UserBO.ImageSize.Default)%>" alt="Profile Picture" />
                            </div>
                            <b class="caret"></b>
                        </a>
                        <div class="user-info dropdown-menu">
                            <div class="info-warp span4">
                                <a class="avatar-large pull-left" data-original-title="Change Photo" data-placement="bottom" href="/EditPhoto.aspx">
                                    <img src="<%=Indico.BusinessObjects.UserBO.GetProfilePicturePath(this.LoggedUser, Indico.BusinessObjects.UserBO.ImageSize.Large)%>" alt="Profile Picture" />
                                </a>
                                <div class="warp-data">
                                    <label><strong><%=this.litUsername.Text%></strong></label>
                                    <label class="text-info"><%=this.LoggedUser.EmailAddress.Trim()%></label>
                                    <label>&nbsp;</label>
                                    <a class="btn btn-primary" href="/EditInformation.aspx">Information</a> <a class="btn btn-link pull-right" href="/ChangePassword.aspx">Change Password</a>
                                </div>
                            </div>
                            <a class="btn btn-inverse pull-right" href="/Logout.aspx" data-original-title="Signout"
                                rel="nofollow"><i class="icon-off icon-white" style="padding-right: 0;"></i>
                            </a>
                        </div>
                    </li>
                </ul>
                <ul id="ulNavigation" runat="server" class="nav">
                </ul>
            </div>
            <!--/.nav-collapse -->
        </div>
    </div>
</div>
