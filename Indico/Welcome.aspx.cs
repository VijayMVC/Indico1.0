using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class Welcome : IndicoPage
    {
        #region Fields

        private int urlQueryId = -1;

        #endregion

        #region Properties

        protected int QueryID
        {
            get
            {
                if (urlQueryId > -1)
                    return urlQueryId;

                urlQueryId = 0;
                if (Request.QueryString["id"] != null)
                {
                    urlQueryId = Convert.ToInt32(Request.QueryString["id"].ToString());
                }

                return urlQueryId;

            }

        }

        #endregion

        #region Constructors

        #endregion

        #region Event

        protected override void OnPreRender(EventArgs e)
        {
            //Page Refresh
            Session["IsPostBack"] = Server.UrlEncode(Guid.NewGuid().ToString());
            ViewState["IsPostBack"] = Session["IsPostBack"];
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                PopulateControls();
            }
        }

        protected void cvPasswordLength_Validate(object sender, ServerValidateEventArgs e)
        {
            //Check Password Strength
            if (txtChoosePassword.Text != null && txtChoosePassword.Text.Length > 6)
            {
                e.IsValid = true;

                this.litMessage.Text = "Password strength is good";
            }
            else
            {
                if (!String.IsNullOrEmpty(this.txtChoosePassword.Text))
                {
                    e.IsValid = false;
                    this.litMessage.Text = "Password strength is weak";
                }
                else
                {
                    cvChoosePassword.Visible = false;
                }
            }
        }

        protected void cvUserName_Validate(object sender, ServerValidateEventArgs e)
        {
            if (!String.IsNullOrEmpty(this.txtUserName.Text))
            {
                e.IsValid = UserBO.VlidateUsername(this.QueryID, this.txtUserName.Text.ToLower().Trim());
            }
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                this.ProcessForm();

                Response.Redirect("/Login.aspx");
            }
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            if (QueryID > 0)
            {
                UserBO objUser = new UserBO(this.ObjContext);
                objUser.ID = this.QueryID;
                objUser.GetObject();

                //Check User Status is Invited
                if (objUser.Status != 3)
                {
                    Response.Redirect("/Login.aspx");
                }
                else
                {
                    this.txtUserName.Text = objUser.Username;
                    this.txtFirstName.Text = objUser.GivenName;
                    this.txtLastName.Text = objUser.FamilyName;
                }
            }
            else
            {
                //Can't Redirect Welcome.aspx
                Response.Redirect("/Login.aspx");
            }
        }

        private void ProcessForm()
        {
            //Add User Details
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    UserBO objUser = new UserBO(this.ObjContext);
                    objUser.ID = QueryID;
                    objUser.GetObject();

                    if (objUser.IsDirectSalesPerson)
                    {
                        CompanyBO objDistributor = new CompanyBO(this.ObjContext);
                        objDistributor.Name = "BLACKCHROME - " + objUser.GivenName + " " + objUser.FamilyName;
                        objDistributor = objDistributor.SearchObjects().SingleOrDefault();

                        if (objDistributor != null)
                        {
                            objDistributor.Name = "BLACKCHROME - " + this.txtFirstName.Text + " " + this.txtLastName.Text;
                        }
                    }

                    objUser.GivenName = this.txtFirstName.Text;
                    objUser.FamilyName = this.txtLastName.Text;
                    objUser.Password = UserBO.GetNewEncryptedPassword(this.txtChoosePassword.Text);
                    objUser.Username = this.txtUserName.Text;
                    objUser.Status = 1;
                    objUser.IsActive = true;
                    objUser.IsDeleted = false;
                    objUser.Guid = Guid.NewGuid().ToString();

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        #endregion
    }
}