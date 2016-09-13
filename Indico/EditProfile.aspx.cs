using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Indico.BusinessObjects;
using Indico.Common;
using System.Transactions;

namespace Indico
{
    public partial class EditProfile : IndicoPage
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
            if (!Page.IsValid)
            {
               // this.btnSave_Click();
            }
            ViewState["IsPageValied"] = Page.IsValid;
            this.validationSummary.Visible = !Page.IsValid;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            ViewState["IsPageValied"] = !Page.IsValid;
            this.ProcessForm();
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

            CompanyBO objCompany = new CompanyBO();
            objCompany.ID = this.LoggedUser.Company;
            objCompany.GetObject();

            //populate cordinators
            List<UserBO> lstUsers = objCompany.UsersWhereThisIsCompany;
            this.ddlCoordinator.Items.Add(new ListItem("Select coordinator", "0"));
            foreach (UserBO user in lstUsers)
            {
                this.ddlCoordinator.Items.Add(new ListItem(user.GivenName, user.ID.ToString()));
            }

            //Populate Countries
            List<CountryBO> lstCountries = (new CountryBO()).GetAllObject();
            foreach (CountryBO country in lstCountries)
            {
                this.ddlCountry.Items.Add(new ListItem(country.Name, country.ID.ToString()));
            }
            //UserBO objUser = new UserBO(this.ObjContext);
            //objUser.ID = 
            //objUser.GetObject();

            
            this.txtName.Text = objCompany.Name;
            this.txtNickName.Text = objCompany.NickName;
            this.ddlCoordinator.SelectedValue = objCompany.Coordinator.ToString();
            this.ddlCoordinator.Enabled = false;
            this.txtFirstName.Text = LoggedCompany.objCoordinator.GivenName;
            this.txtLastName.Text = LoggedCompany.objCoordinator.FamilyName;


            this.txtAddress1.Text = objCompany.Address1;
            this.txtAddress2.Text = objCompany.Address2;
            this.txtCity.Text = objCompany.City;
            this.txtState.Text = objCompany.State;
            this.txtPostcode.Text = objCompany.Postcode;
            this.ddlCountry.SelectedValue = objCompany.Country.ToString();
            this.txtPhone1.Text = objCompany.Phone1;
            this.txtPhone2.Text = objCompany.Phone2;
            this.txtMobile.Text = LoggedCompany.objCoordinator.MobileTelephoneNumber;
            this.txtEmailAddress.Text = objCompany.objCoordinator.EmailAddress;
            this.txtFaxNo.Text = objCompany.Fax;
            rfvGender.Enabled = false;
            rfvCoordinator.Enabled = false;
        }

        private void ProcessForm()
        {
            using(TransactionScope ts = new TransactionScope())
            {
                try
                {
                    rfvGender.Enabled = false;
                    rfvCoordinator.Enabled = false;
                    CompanyBO objCompany = new CompanyBO(this.ObjContext);
                    objCompany.ID = this.LoggedUser.Company;
                    objCompany.GetObject();

                    objCompany.Name = this.txtName.Text;
                    objCompany.NickName = this.txtNickName.Text;
                    objCompany.Coordinator = int.Parse(this.ddlCoordinator.SelectedValue);
                    LoggedCompany.objCoordinator.GivenName = txtFirstName.Text;
                    LoggedCompany.objCoordinator.FamilyName = txtLastName.Text;

                    objCompany.Address1 = this.txtAddress1.Text;
                    objCompany.Address2 = this.txtAddress2.Text;
                    objCompany.City = this.txtCity.Text;
                    objCompany.State = this.txtState.Text;
                    objCompany.Postcode = this.txtPostcode.Text;
                    objCompany.Country = int.Parse(this.ddlCountry.SelectedValue);
                    LoggedCompany.objCoordinator.OfficeTelephoneNumber = this.txtPhone1.Text;
                    LoggedCompany.objCoordinator.HomeTelephoneNumber = this.txtPhone2.Text;
                    LoggedCompany.objCoordinator.MobileTelephoneNumber = this.txtMobile.Text;
                    LoggedCompany.objCoordinator.EmailAddress = this.txtEmailAddress.Text;
                    //objCompany.Fax = this.txtFaxNo.Text;                    

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                    this.validationSummary.Visible = !Page.IsValid;
                }
                catch (Exception ex)
                {

                }
            }
        }

        #endregion
    }
}