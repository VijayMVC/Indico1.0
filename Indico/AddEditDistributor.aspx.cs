using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class AddEditDistributor : IndicoPage
    {
        #region Fields

        private int urlQueryID = -1;
        private int urlOrderID = -1;

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

                if (Request.QueryString["od"] != null)
                {
                    urlOrderID = Convert.ToInt32(Request.QueryString["od"].ToString());
                }

                return urlQueryID;
            }


        }

        protected int OrderID
        {
            get
            {
                return urlOrderID;
            }
        }

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

        //protected void cfvEmailAddress_Validate(object sender, ServerValidateEventArgs e)
        //{
        //    try
        //    {
        //        CompanyBO objCompany = new CompanyBO();
        //        objCompany.ID = QueryID;
        //        objCompany.GetObject();

        //        ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
        //        objReturnInt = SettingsBO.ValidateField(objCompany.Owner ?? 0, "User", "EmailAddress", this.txtEmailAddress.Text);
        //        e.IsValid = objReturnInt.RetVal == 1;
        //    }
        //    catch (Exception ex)
        //    {
        //        IndicoLogging.log.Error("Error occured while cfvEmailAddress_Validate on AddEditDistributor.aspx", ex);
        //    }
        //}

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                int distributor = this.ProcessForm();

                if (this.OrderID > -1)
                {
                    Response.Redirect("/AddEditOrder.aspx?dir=" + distributor);
                }
                else
                {
                    Response.Redirect("/ViewDistributors.aspx");
                }

            }
        }

        //protected void cvGivenName_Validate(object sender, ServerValidateEventArgs e)
        //{
        //    if (!string.IsNullOrEmpty(this.txtGivenName.Text))
        //    {
        //        e.IsValid = (this.txtGivenName.Text.Length > 32) ? false : true;
        //    }
        //}

        //protected void cvLastName_Validate(object sender, ServerValidateEventArgs e)
        //{
        //    if (!string.IsNullOrEmpty(this.txtFamilyName.Text))
        //    {
        //        e.IsValid = (this.txtFamilyName.Text.Length > 32) ? false : true;
        //    }
        //}

        //protected void cvName_ServerValidate(object source, ServerValidateEventArgs e)
        //{
        //    List<CompanyBO> lstCompany = new List<CompanyBO>();
        //    if (!string.IsNullOrEmpty(this.txtName.Text))
        //    {
        //        lstCompany = (from o in (new CompanyBO()).GetAllObject()
        //                      where o.ID != this.QueryID && o.Name.Trim().ToLower() == this.txtName.Text.Trim().ToLower()
        //                      select o).ToList();
        //    }

        //    e.IsValid = !(lstCompany.Count > 0);
        //}

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(this.QueryID, "Company", "Name", this.txtName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on AddEditDistributor.aspx", ex);
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
            this.litHeaderText.Text = ((this.QueryID > 0) ? "Edit " : "New ") + this.ActivePage.Heading;

            // Populate Country
            this.ddlCountry.Items.Add(new ListItem("Select Your Country", "0"));
            List<CountryBO> lstCountry = (new CountryBO()).GetAllObject().AsQueryable().OrderBy("ShortName").ToList();
            foreach (CountryBO country in lstCountry)
            {
                this.ddlCountry.Items.Add(new ListItem(country.ShortName, country.ID.ToString()));
            }

            // Populate Primary Coordinator
            this.ddlCoordinator.Items.Add(new ListItem("Select Your Primary Coordinator", "0"));
            List<UserBO> lstCoordinator = (from co in new UserBO().GetAllObject().AsQueryable().OrderBy("GivenName").ToList()
                                           where co.objCompany.Type == 3
                                           select co).ToList();
            foreach (UserBO coordinator in lstCoordinator)
            {
                this.ddlCoordinator.Items.Add(new ListItem(coordinator.GivenName + " " + coordinator.FamilyName, coordinator.ID.ToString()));
            }

            if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
            {
                this.ddlCoordinator.ClearSelection();
                this.ddlCoordinator.SelectedValue = this.LoggedUser.ID.ToString();
                this.ddlCoordinator.Enabled = false;
            }

            // Populate Secondary Coordinator
            //this.ddlSecondaryCoordinator.Items.Add(new ListItem("Select Your Secondary Coordinator", "0"));
            //List<UserBO> lstSecondaryCoordinator = (from co in new UserBO().GetAllObject().AsQueryable().OrderBy("GivenName").ToList()
            //                                        where co.objCompany.Type == 3
            //                                        select co).ToList();
            //foreach (UserBO coordinator in lstSecondaryCoordinator)
            //{
            //    this.ddlSecondaryCoordinator.Items.Add(new ListItem(coordinator.GivenName + " " + coordinator.FamilyName, coordinator.ID.ToString()));
            //}

            if (QueryID > 0)
            {
                CompanyBO objDistributor = new CompanyBO();
                objDistributor.ID = this.QueryID;
                objDistributor.GetObject();

                this.txtName.Text = objDistributor.Name;
                this.txtCompanyNumber.Text = objDistributor.Number;
                this.txtNickName.Text = objDistributor.NickName;
                this.txtAddress1.Text = objDistributor.Address1;
                this.txtAddress2.Text = objDistributor.Address2;
                this.txtCity.Text = objDistributor.City;
                this.txtState.Text = objDistributor.State;
                this.txtPostalCode.Text = objDistributor.Postcode;
                this.ddlCountry.SelectedValue = objDistributor.Country.ToString();
                this.txtPhoneNo1.Text = objDistributor.Phone1;
                this.txtPhoneNo2.Text = objDistributor.Phone2;
                this.txtFaxNo.Text = objDistributor.Fax;
                this.chkBackOrder.Checked = objDistributor.IsBackOrder ?? false;
                this.chkIsActive.Checked = objDistributor.IsActive ?? false;

                // populate owner details
                //if (objDistributor.Name.Contains("BLACKCHROME"))
                //{
                //    this.dvUser.Visible = false;
                //}
                //else
                //{
                //    this.txtGivenName.Text = objDistributor.objOwner.GivenName;
                //    this.txtFamilyName.Text = objDistributor.objOwner.FamilyName;
                //    this.txtEmailAddress.Text = objDistributor.objOwner.EmailAddress;
                //}

                this.ddlCoordinator.SelectedValue = objDistributor.Coordinator.ToString();
                //this.ddlSecondaryCoordinator.SelectedValue = objDistributor.SecondaryCoordinator.ToString();
            }
            else
            {
                this.ddlCountry.SelectedValue = this.ddlCountry.Items.FindByValue("14").Value;
            }
        }

        private int ProcessForm()
        {
            int distributor = 0;
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    CompanyBO objDistributor = new CompanyBO(this.ObjContext);
                    if (this.QueryID > 0)
                    {
                        objDistributor.ID = this.QueryID;
                        objDistributor.GetObject();
                    }
                    else
                    {
                        objDistributor.Creator = this.LoggedUser.ID;
                        objDistributor.CreatedDate = DateTime.Now;
                        objDistributor.IsActive = true;
                        objDistributor.IsDelete = false;
                    }
                    objDistributor.Modifier = this.LoggedUser.ID;
                    objDistributor.ModifiedDate = DateTime.Now;

                    objDistributor.Type = 4; //Distributor
                    objDistributor.IsDistributor = true;
                    objDistributor.Name = this.txtName.Text;
                    objDistributor.NickName = this.txtNickName.Text;
                    objDistributor.Number = this.txtCompanyNumber.Text;
                    objDistributor.Address1 = this.txtAddress1.Text;
                    objDistributor.Address2 = this.txtAddress2.Text;
                    objDistributor.City = this.txtCity.Text;
                    objDistributor.State = this.txtState.Text;
                    objDistributor.Postcode = this.txtPostalCode.Text;
                    objDistributor.Country = int.Parse(this.ddlCountry.SelectedValue);
                    objDistributor.Phone1 = this.txtPhoneNo1.Text;
                    objDistributor.Phone2 = this.txtPhoneNo2.Text;
                    objDistributor.Fax = this.txtFaxNo.Text;
                    //objDistributor.Email = this.txtEmailAddress.Text;                     
                    objDistributor.Coordinator = int.Parse(ddlCoordinator.SelectedValue);
                    //objDistributor.SecondaryCoordinator = int.Parse(this.ddlSecondaryCoordinator.SelectedValue);
                    objDistributor.IsBackOrder = this.chkBackOrder.Checked;
                    objDistributor.IsActive = this.chkIsActive.Checked;

                    this.ObjContext.SaveChanges();

                    distributor = objDistributor.ID;

                    //UserBO objUser = null;
                    //if (this.QueryID == 0)
                    //{
                    //    objUser = new UserBO(this.ObjContext);
                    //    objUser.Company = distributor;

                    //    objUser.IsDistributor = true;
                    //    objUser.Status = 3; //Invited
                    //    objUser.Username = this.txtEmailAddress.Text;
                    //    objUser.Password = UserBO.GetNewEncryptedRandomPassword();
                    //    objUser.GivenName = this.txtGivenName.Text;
                    //    objUser.FamilyName = this.txtFamilyName.Text;
                    //    objUser.EmailAddress = this.txtEmailAddress.Text;
                    //    objUser.Creator = this.LoggedUser.ID;
                    //    objUser.CreatedDate = DateTime.Now;
                    //    objUser.HomeTelephoneNumber = this.txtPhoneNo1.Text;
                    //    objUser.OfficeTelephoneNumber = this.txtPhoneNo2.Text;
                    //    objUser.Modifier = this.LoggedUser.ID;
                    //    objUser.ModifiedDate = DateTime.Now;
                    //    objUser.Guid = Guid.NewGuid().ToString();

                    //    RoleBO objRole = new RoleBO(this.ObjContext);
                    //    objRole.ID = 10; // Distributor Administrator
                    //    objRole.GetObject();

                    //    objUser.UserRolesWhereThisIsUser.Add(objRole);
                    //    objUser.CompanysWhereThisIsOwner.Add(objDistributor);

                    //    this.ObjContext.SaveChanges();

                    //    //Send Invitation Email
                    //    string hosturl = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/";
                    //    string emailcontent = String.Format("<p>A new acoount set up for u at <a href =\"http://{0}\">\"http://{0}/</a></p>" +
                    //                                        "<p>To complete your registration simply clik the link below to sign in<br>" +
                    //                                        "<a href=\"http://{0}Welcome.aspx?guid={1}&id={2}\">http://{0}Welcome.aspx?guid={1}&id={2}</a></p>",
                    //                                        hosturl, objUser.Guid, objUser.ID.ToString());

                    //    IndicoEmail.SendMailNotifications(this.LoggedUser, objUser, "Activate Your New Account", emailcontent);
                    //}
                    //else
                    //{
                    //    if (!objDistributor.Name.Contains("BLACKCHROME"))
                    //    {
                    //        objUser = new UserBO(this.ObjContext);
                    //        objUser.ID = (int)objDistributor.Owner;
                    //        objUser.GetObject();

                    //        objUser.GivenName = this.txtGivenName.Text;
                    //        objUser.FamilyName = this.txtFamilyName.Text;
                    //        objUser.EmailAddress = this.txtEmailAddress.Text;

                    //        ObjContext.SaveChanges();
                    //    }
                    //}
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while send Distributor email", ex);
            }

            return distributor;
        }

        #endregion
    }
}