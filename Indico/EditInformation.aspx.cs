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
    public partial class EditInformation : IndicoPage
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
            if (this.IsNotRefresh)
            {
                if (Page.IsValid)
                {
                    ProcessForm();

                    Response.Redirect("/EditInformation.aspx");
                }

                this.validationSummary.Visible = !Page.IsValid;
            }
        }

        protected void cfvUsername_ServerValidate(object source, ServerValidateEventArgs args)
        {
            if (!String.IsNullOrEmpty(this.txtUsername.Text))
            {
                List<UserBO> lstUser = (from o in (new UserBO()).SearchObjects()
                                        where o.Username.ToLower() != this.LoggedUser.Username.ToLower() &&
                                              o.Username.ToLower() == this.txtUsername.Text.ToLower().Trim()
                                        select o).ToList();
                args.IsValid = !(lstUser.Count > 0);
            }
            else
            {
                return;
            }
        }

        protected void cfvEmailChecker_ServerValidate(object source, ServerValidateEventArgs args)
        {
            if (!String.IsNullOrEmpty(this.txtEmailAddress.Text))
            {
                List<UserBO> lstUser = (from o in (new UserBO()).SearchObjects()
                                        where o.EmailAddress.ToLower() != this.LoggedUser.EmailAddress.ToLower() &&
                                              o.EmailAddress.ToLower() == this.txtEmailAddress.Text.ToLower().Trim()
                                        select o).ToList();

                args.IsValid = !(lstUser.Count > 0);
            }
            else
            {
                return;
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

            this.txtFirstName.Text = this.LoggedUser.GivenName;
            this.txtLastName.Text = this.LoggedUser.FamilyName;
            this.txtEmailAddress.Text = this.LoggedUser.EmailAddress;
            this.txtMobileNo.Text = ((!string.IsNullOrEmpty(this.LoggedUser.MobileTelephoneNumber)) ? this.LoggedUser.MobileTelephoneNumber : string.Empty);
            this.txtPhoneNo.Text = ((!string.IsNullOrEmpty(this.LoggedUser.OfficeTelephoneNumber)) ? this.LoggedUser.OfficeTelephoneNumber : string.Empty);
            this.txtHomeNo.Text = ((!string.IsNullOrEmpty(this.LoggedUser.HomeTelephoneNumber)) ? this.LoggedUser.HomeTelephoneNumber : string.Empty);

            this.txtUsername.Text = this.LoggedUser.Username;
            this.litUserRoel.Text = "User Role : " + this.LoggedUserRole.Name;
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
                    //Update Information
                    UserBO objUser = new UserBO(this.ObjContext);
                    objUser.ID = this.LoggedUser.ID;
                    objUser.GetObject();

                    objUser.GivenName = this.txtFirstName.Text.ToString();
                    objUser.FamilyName = this.txtLastName.Text.ToString();
                    objUser.EmailAddress = this.txtEmailAddress.Text.ToString();
                    objUser.MobileTelephoneNumber = this.txtMobileNo.Text;
                    objUser.OfficeTelephoneNumber = this.txtPhoneNo.Text;
                    objUser.HomeTelephoneNumber = this.txtHomeNo.Text;
                    objUser.Username = this.txtUsername.Text;                   

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while update the user details", ex);
            }
        }

        #endregion
    }
}