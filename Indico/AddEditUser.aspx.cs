using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;
using System.IO;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class AddEditUser : IndicoPage
    {
        #region Fields

        private int urlQueryID = -1;



        #endregion

        #region Properties

        protected int QueryID
        {
            get
            {
                if (urlQueryID > -1)
                    return urlQueryID;

                urlQueryID = 0;
                if (Request.QueryString["id"] != null)
                {
                    urlQueryID = Convert.ToInt32(Request.QueryString["id"].ToString());
                }
                return urlQueryID;
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

        protected void cfvUserName_Validate(object sender, ServerValidateEventArgs e)
        {
            if (!String.IsNullOrEmpty(this.txtUsername.Text))
            {
                e.IsValid = UserBO.VlidateUsername(this.QueryID, this.txtUsername.Text.ToLower().Trim());
            }
        }

        protected void cfvEmailAddress_Validate(object sender, ServerValidateEventArgs e)
        {
            //List<UserBO> lstEmailAddress = new List<UserBO>();
            //if (!String.IsNullOrEmpty(this.txtEmailAddress.Text))
            //{
            //    lstEmailAddress = (from o in (new UserBO()).GetAllObject()
            //                       where o.ID != this.QueryID && o.EmailAddress == this.txtEmailAddress.Text.Trim()
            //                       select o).ToList();
            //}

            //e.IsValid = !(lstEmailAddress.Count > 0);

            try
            {
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(this.QueryID, "User", "EmailAddress", this.txtEmailAddress.Text);
                e.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on AddEditUser.aspx", ex);
            }
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                this.ProcessForm();

                Session["isChangeUser"] = true;
                Response.Redirect("/ViewUsers.aspx");
            }
        }

        protected void btnClose_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect("/ViewUsers.aspx");
        }

        protected void ddlCompany_SelectedIndexChange(object sender, EventArgs e)
        {
            int company = int.Parse(this.ddlCompany.SelectedItem.Value);
            this.ddlRole.Enabled = true;
            if (company > 0)
            {
                CompanyBO objComapny = new CompanyBO();
                objComapny.ID = company;
                objComapny.GetObject();
                //Populate User Role
                this.ddlRole.Items.Clear();
                this.ddlRole.Items.Add(new ListItem("Select Your Role", "0"));
                List<RoleBO> lstRole = new List<RoleBO>();
                switch (objComapny.Type)
                {
                    case 1: //Factory
                        {
                            lstRole = (from o in (new RoleBO()).SearchObjects()
                                       where o.ID > 1 && o.ID < 5
                                       select o).ToList();
                            break;
                        }
                    case 2: //Manufacturer
                        {
                            lstRole = (from o in (new RoleBO()).SearchObjects()
                                       where o.ID > 4 && o.ID < 7 // 4- 7
                                       select o).ToList();
                            break;
                        }
                    case 3: //Sales
                        {
                            lstRole = (from o in (new RoleBO()).SearchObjects()
                                       where o.ID > 6 && o.ID < 10
                                       select o).ToList();
                            break;
                        }
                    case 4: //Distributor
                        {
                            lstRole = (from o in (new RoleBO()).SearchObjects()
                                       where o.ID > 9 && o.ID < 12
                                       select o).ToList();
                            break;
                        }
                }
                foreach (RoleBO role in lstRole)
                {
                    this.ddlRole.Items.Add(new ListItem(role.Description, role.ID.ToString()));
                }
            }
        }

        protected void btnResetPassword_OnClick(object sender, EventArgs e)
        {
            this.ProcessReset();
        }

        protected void cvGivenName_Validate(object sender, ServerValidateEventArgs e)
        {
            if (!string.IsNullOrEmpty(this.txtGivenName.Text))
            {
                e.IsValid = (this.txtGivenName.Text.Length > 32) ? false : true;
            }
        }

        protected void cvLastName_Validate(object sender, ServerValidateEventArgs e)
        {
            if (!string.IsNullOrEmpty(this.txtFamilyName.Text))
            {
                e.IsValid = (this.txtFamilyName.Text.Length > 32) ? false : true;
            }
        }

        # endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            //Header Text
            this.litHeaderText.Text = ((this.QueryID > 0) ? "Edit " : "New ") + this.ActivePage.Heading;

            //populate Image
            this.imgUser.Visible = (this.QueryID > 0) ? true : false;

            //populate Blackchrome
            this.dvCheckBox.Visible = (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;

            // Populate Company
            this.ddlCompany.Items.Add(new ListItem("Select company", "0"));
            List<CompanyBO> lstCotype = new List<CompanyBO>();
            if (this.LoggedUserRoleName == UserRole.IndimanAdministrator)
            {
                lstCotype = (from o in (new CompanyBO()).SearchObjects()
                             where o.Name != "System" && (o.objType.Name == "Factory" ||
                                   o.objType.Name == "Manufacturer" ||
                                   o.objType.Name == "Sales" ||
                                   o.objType.Name == "Distributor")
                             select o).ToList();
            }
            else if (this.LoggedUserRoleName == UserRole.SiteAdministrator)
            {
                lstCotype = (from o in (new CompanyBO()).SearchObjects()
                             where o.Name != "System" && (o.objType.Name == "Factory" ||
                                   o.objType.Name == "Manufacturer" ||
                                   o.objType.Name == "Sales")
                             select o).ToList();
            }
            else if (this.LoggedUserRoleName == UserRole.DistributorAdministrator)
            {
                lstCotype = (from o in (new CompanyBO()).SearchObjects()
                             where (o.objType.Name == "Distributor" &&
                                     o.ID == this.LoggedCompany.ID)
                             select o).ToList();
            }
            else
            {
                lstCotype = (from o in (new CompanyBO()).SearchObjects()
                             where o.Type == this.LoggedCompany.Type
                             select o).ToList();
            }
            foreach (CompanyBO company in lstCotype)
            {
                this.ddlCompany.Items.Add(new ListItem(company.Name, company.ID.ToString()));
            }

            if (this.LoggedUserRoleName == UserRole.DistributorAdministrator)
            {
                this.ddlCompany.Items.FindByValue(this.LoggedUser.Company.ToString()).Selected = true;
                this.dvCompany.Visible = false;
                this.ddlCompany_SelectedIndexChange(null, null);
            }

            //Populate User Status
            this.ddlStatus.Items.Add(new ListItem("Select Status", "0")); ;
            List<UserStatusBO> lstUserStatus = (new UserStatusBO()).GetAllObject().Where(o => o.Name != "Deleted").ToList();
            foreach (UserStatusBO ststus in lstUserStatus)
            {
                this.ddlStatus.Items.Add(new ListItem(ststus.Name, ststus.ID.ToString()));
            }
            //this.ddlRole.Enabled = (this.QueryID > 0) ? true : false;

            if (this.QueryID > 0)
            {
                UserBO objUser = new UserBO(this.ObjContext);
                objUser.ID = this.QueryID;
                objUser.GetObject();

                this.ddlCompany.SelectedValue = objUser.Company.ToString();
                this.ddlStatus.SelectedValue = objUser.Status.ToString();
                this.txtUsername.Text = objUser.Username;
                this.txtGivenName.Text = objUser.GivenName;
                this.txtFamilyName.Text = objUser.FamilyName;
                this.txtEmailAddress.Text = objUser.EmailAddress;
                this.txtMobileTelephoneNo.Text = objUser.MobileTelephoneNumber;
                this.txtHomeTelephoneNo.Text = objUser.HomeTelephoneNumber;
                this.txtOfficeTelephoneNo.Text = objUser.OfficeTelephoneNumber;
                this.chkHttpPost.Checked = (objUser.HaveAccessForHTTPPost != null) ? (bool)objUser.HaveAccessForHTTPPost : false;
                this.txtDesignation.Text = objUser.Designation;

                this.chkDirectSales.Checked = objUser.IsDirectSalesPerson;
                this.dvDirectSales.Visible = CompanyExtensions.IsIndicoAdelade(objUser.objCompany);

                //Populate User Role     
                this.ddlCompany_SelectedIndexChange(null, null);

                if (objUser.UserRolesWhereThisIsUser.Count > 0)
                {
                    this.ddlRole.Items.FindByValue(objUser.UserRolesWhereThisIsUser[0].ID.ToString()).Selected = true;
                }
                else
                {
                    this.ddlRole.Items.FindByValue("0").Selected = true;
                }

                // Disable User Role
                this.ddlRole.Enabled = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) && !(this.LoggedCompany.Owner == objUser.ID);

                // Password 
                if (this.LoggedUserRoleName == UserRole.IndimanAdministrator)
                {
                    //this.fieldPassword.Visible = true;
                    this.btnResetPassword.Visible = true;
                }

                imgUser.AlternateText = objUser.PhotoPath;
                imgUser.ImageUrl = UserBO.GetProfilePicturePath(objUser, UserBO.ImageSize.Medium);
            }
            else
            {
                // Enebled false when Add a New User
                this.btnResetPassword.Visible = false;
                this.ddlStatus.SelectedValue = "3"; // Invited
                this.ddlStatus.Enabled = false;
            }
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
                    UserBO objUser = new UserBO(this.ObjContext);
                    if (this.QueryID > 0)
                    {
                        objUser.ID = QueryID;
                        objUser.GetObject();
                        objUser.UserRolesWhereThisIsUser.Clear();
                    }
                    else
                    {
                        objUser.Password = UserBO.GetNewEncryptedRandomPassword();
                        objUser.Guid = Guid.NewGuid().ToString();
                        objUser.Creator = this.LoggedUser.ID;
                        objUser.CreatedDate = DateTime.Now;
                    }
                    objUser.Modifier = this.LoggedUser.ID;
                    objUser.ModifiedDate = DateTime.Now;

                    objUser.IsDistributor = (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? true : false;
                    objUser.GivenName = this.txtGivenName.Text;
                    objUser.FamilyName = this.txtFamilyName.Text;
                    objUser.EmailAddress = this.txtEmailAddress.Text;
                    objUser.MobileTelephoneNumber = this.txtMobileTelephoneNo.Text;
                    objUser.HomeTelephoneNumber = this.txtHomeTelephoneNo.Text;
                    objUser.OfficeTelephoneNumber = this.txtOfficeTelephoneNo.Text;
                    objUser.Username = this.txtUsername.Text;
                    objUser.Company = int.Parse(this.ddlCompany.SelectedValue);
                    objUser.Status = int.Parse(this.ddlStatus.SelectedValue);
                    objUser.HaveAccessForHTTPPost = this.chkHttpPost.Checked;
                    objUser.IsDirectSalesPerson = this.chkDirectSales.Checked;
                    objUser.Designation = this.txtDesignation.Text;

                    RoleBO objRole = new RoleBO(this.ObjContext);
                    objRole.ID = int.Parse(this.ddlRole.SelectedValue);
                    objRole.GetObject();

                    objUser.UserRolesWhereThisIsUser.Add(objRole);

                    if (this.QueryID == 0 && objUser.IsDirectSalesPerson)
                    {
                        CompanyBO objDistributor = new CompanyBO(this.ObjContext);
                        objDistributor.Name = "BLACKCHROME - " + objUser.GivenName + " " + objUser.FamilyName;
                        objDistributor.IsDistributor = true;
                        objDistributor.Creator = this.LoggedUser.ID;
                        objDistributor.CreatedDate = DateTime.Now;
                        objDistributor.Modifier = this.LoggedUser.ID;
                        objDistributor.ModifiedDate = DateTime.Now;
                        objDistributor.IsActive = true;
                        objDistributor.IsDelete = false;
                        objDistributor.IsBackOrder = true;

                        objDistributor.Type = 4; //Distributor
                        objDistributor.Country = 14;
                        objDistributor.Coordinator = 44;

                        objUser.CompanysWhereThisIsOwner.Add(objDistributor);
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();

                    // Send Invitation Email
                    if (this.QueryID == 0)
                    {
                        string hostUrl = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/";
                        string emailContent = "<p>A new account has been created. " +
                                              "<p>To complete your registration, simply click the link below.<br>" +
                                              "<a href=\"http://" + hostUrl + "Welcome.aspx?guid=" + objUser.Guid + "&id=" + objUser.ID + "\">http://" + hostUrl + "Welcome.aspx?guid=" + objUser.Guid + "&id=" + objUser.ID + "</a></p>";

                        IndicoEmail.SendMailNotifications(this.LoggedUser, objUser, "New account has been created", emailContent);
                    }
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("btnSaveChanges_Click. Error occured while adding user account details to the database", ex);
            }
        }

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
                    objUser.ID = this.QueryID;
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

                //IndicoEmail.SendMailNotifications(objAdministrator, objUser, "Request Password Change", emailContent);
                IndicoEmail.SendChangePasswordEmailNitifications(objUser, "Request Password Change", emailContent);

                Response.Redirect("/ViewUsers.aspx");
            }
            else
            {
                //this.boxWarning.InnerText = "The email address is doesn't exist.";
                //this.boxWarning.Visible = true;

                IndicoLogging.log.InfoFormat("Login.btnReset_Click() Reset password fail for email address {0} into host {1} with session id {2} from {3}",
                                    this.txtEmailAddress.Text.Trim(), Request.Url.Host, Session.SessionID, Request.UserHostAddress);
                Session.Abandon();
            }
        }

        #endregion
    }
}