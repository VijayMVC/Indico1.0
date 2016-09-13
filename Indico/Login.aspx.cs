using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class Login : IndicoPage
    {
        #region Properties

        public bool IsNotRefresh
        {
            get
            {
                return (Session["IsPostBack"].ToString() == ViewState["IsPostBack"].ToString());
            }
        }

        #endregion

        #region Events

        protected void Page_PreRender(object sender, EventArgs e)
        {
            //Page Refresh
            Session["IsPostBack"] = Server.UrlEncode(Guid.NewGuid().ToString());
            ViewState["IsPostBack"] = Session["IsPostBack"];
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                this.PopulateControls();
            }
        }

        protected void linkForgot_Click(object sender, EventArgs e)
        {
            this.dvErrorMessage.Visible = false;
            this.boxWarning.Visible = false;

            this.loginBox.Visible = false;
            //this.forgotBox.Visible = true;
        }

        protected void linkBack_Click(object sender, EventArgs e)
        {
            this.dvErrorMessage.Visible = false;
            this.boxWarning.Visible = false;

            this.loginBox.Visible = true;
            //this.forgotBox.Visible = false;
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (this.Page.IsValid)
            {
                this.ProcessLogin();
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (this.Page.IsValid)
                {
                    this.ProcessReset();
                }

                ViewState["IsPageValid"] = !(Page.IsValid);
            }
            else
            {
                ViewState["IsPageValid"] = false;
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            ViewState["IsPageValid"] = false;

            if ((Session["in_uid"] != null) && (this.LoggedUser != null && this.LoggedUser.ID > 0))
            {
                Response.Redirect("/Default.aspx");
            }
            else
            {
                HttpCookie cookieUsername = Request.Cookies["indico-usrnm"];
                HttpCookie cookiePassword = Request.Cookies["indico-pswrd"];

                if ((cookieUsername != null && cookiePassword != null) && (!String.IsNullOrEmpty(cookieUsername.Value) && !String.IsNullOrEmpty(cookiePassword.Value)))
                {
                    // Just Load the Values in TextBoxes From Cookies
                    this.txtUsername.Text = cookieUsername.Value.ToString();
                    this.txtPassword.Text = cookiePassword.Value.ToString();
                    this.chkRememberMe.Checked = true;

                    this.ProcessLogin();
                }
            }
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessLogin()
        {
            //check if remember me checkbox is checked on login            
            Response.Cookies["indico-usrnm"].Value = (chkRememberMe.Checked) ? txtUsername.Text : string.Empty;
            Response.Cookies["indico-usrnm"].Expires = (chkRememberMe.Checked) ? DateTime.Now.AddDays(14) : DateTime.Now.AddDays(-15);

            Response.Cookies["indico-pswrd"].Value = (chkRememberMe.Checked) ? txtPassword.Text : string.Empty;
            Response.Cookies["indico-pswrd"].Expires = (chkRememberMe.Checked) ? DateTime.Now.AddDays(14) : DateTime.Now.AddDays(-15);

            #region
            var objUser = new UserBO();
            objUser = objUser.Login(txtUsername.Text, txtPassword.Text);
            #endregion

            this.dvErrorMessage.Visible = !(objUser.ID > 0);
            if (objUser.ID > 0)
            {
                if (objUser.Status == 3 && objUser.objStatus.Name == "Inactive")
                {
                    objUser = null;
                    this.boxWarning.InnerText = "Your account was inactive. Please contact the administrator.";
                    this.boxWarning.Visible = true;
                }
                else
                {
                    Session["in_uid"] = objUser.ID.ToString();
                    Session["in_sid"] = Session.SessionID.ToString();
                    Session["in_rid"] = objUser.UserRolesWhereThisIsUser[0].ID.ToString();
                    Session["in_cid"] = this.LoggedCompany.ID.ToString();

                    IndicoLogging.log.InfoFormat("Login.btnLogin_Click() Login success for {0} {1} (ID: {2}) into host {3} with session id {4} from {5}",
                                                 objUser.GivenName, objUser.FamilyName, objUser.ID, Request.Url.Host, Session.SessionID, Request.UserHostAddress);

                    if (Request.Params["do"] != null)
                    {
                        Uri destUri = new Uri(Server.UrlDecode(Request.Params["do"]));
                        try
                        {
                            if (destUri.Host == Request.Url.Host && destUri.AbsoluteUri.ToLower().IndexOf("logout.aspx") < 0)
                            {
                                Response.Redirect(destUri.AbsoluteUri);
                            }
                        }
                        catch (HttpException hex)
                        {
                            IndicoLogging.log.ErrorFormat("Login.btnLogin_Click() Error occured while redirect to page {0}. {1}", destUri.AbsoluteUri, (Environment.NewLine + "Exception :" + hex.Message.ToString()));
                        }
                    }
                    Response.Redirect("/Default.aspx");
                }
            }
            else
            {
                IndicoLogging.log.InfoFormat("Login.btnLogin_Click() Login fail for username {0} into host {1} with session id {2} from {3}",
                                             this.txtUsername.Text.Trim(), Request.Url.Host, Session.SessionID, Request.UserHostAddress);
                Session.Abandon();
            }
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessReset()
        {
            var lstUser = (from o in (new UserBO()).SearchObjects().AsQueryable().ToList<UserBO>()
                           where o.EmailAddress == this.txtEmailAddress.Text.ToLower().Trim()
                           select o).ToList();

            if (lstUser.Count > 0)
            {
                UserBO objUser = new UserBO(this.ObjContext);

                string password = UserBO.GetNewRandomPassword();
                using (TransactionScope ts = new TransactionScope())
                {
                    objUser.ID = lstUser[0].ID;
                    objUser.GetObject();

                    objUser.Password = UserBO.GetNewEncryptedPassword(password);

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }

                UserBO objAdministrator = new UserBO();
                objAdministrator.ID = (int)objUser.objCompany.Owner;
                objAdministrator.GetObject();

                string hostUrl = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/";
                string emailContent = "<p>Your password has been changed. Please use the given password to login to your account. <br/>" + password + "</p>" +
                                      "<p>To complete your registration, simply click the link below to sign in.<br>" +
                                      "<a href=\"http://" + hostUrl + "Welcome.aspx?guid=" + objUser.Guid + "&id=" + objUser.ID + "\">http://" + hostUrl + "Welcome.aspx?guid=" + objUser.Guid + "&id=" + objUser.ID + "</a></p>";

                IndicoEmail.SendMailNotifications(objAdministrator, objUser, "Request Password Change", emailContent);

                Response.Redirect("/Login.aspx");
            }
            else
            {
                this.boxWarning.InnerText = "The email address is doesn't exist.";
                this.boxWarning.Visible = true;

                IndicoLogging.log.InfoFormat("Login.btnReset_Click() Reset password fail for email address {0} into host {1} with session id {2} from {3}",
                                    this.txtEmailAddress.Text.Trim(), Request.Url.Host, Session.SessionID, Request.UserHostAddress);
                Session.Abandon();
            }
        }

        #endregion
    }
}