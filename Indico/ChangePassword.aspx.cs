using System;
using System.Collections.Generic;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class ChangePassword : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        #endregion

        #region Constructors

        #endregion

        #region Events

        /// <summary>
        /// Page load event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>

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

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {

            if (Page.IsValid)
            {
                this.ProcessForm();

                Response.Redirect("/Logout.aspx");
            }

            this.validationSummary.Visible = !Page.IsValid;
        }

        protected void cfvCurrentPassword_ServerValidate(object source, ServerValidateEventArgs e)
        {
            // Validate old password
            var objUser = new UserBO(this.ObjContext);
            objUser = objUser.Login(this.LoggedUser.Username, txtCurrentPassword.Text);

            if (objUser.ID > 0)
            {
                e.IsValid = true;
            }
            else
            {
                e.IsValid = false;
            }
        }

        protected void cfvNewPassword_ServerValidate(object source, ServerValidateEventArgs e)
        {
            // Validate old password length
            if (this.txtNewPassword.Text.Length > 5)
            {
                e.IsValid = true;
            }
            else
            {
                e.IsValid = false;
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            // Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm()
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    //Change Password
                    UserBO objUBO = new UserBO(this.ObjContext);
                    objUBO.ID = this.LoggedUser.ID;
                    objUBO.GetObject();

                    objUBO.Password = UserBO.GetNewEncryptedPassword(this.txtNewPassword.Text.Trim());
                    objUBO.ModifiedDate = Convert.ToDateTime(DateTime.Now.ToString("g"));

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Change password", ex);
            }
        }

        #endregion
    }
}