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
    public partial class AddEditCompany : IndicoPage
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

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                this.ProcessForm();

                Response.Redirect("/ViewCompanies.aspx");
            }

            this.validationSummary.Visible = !Page.IsValid;
        }

        protected void cfvEmailAddress_Validate(object sender, ServerValidateEventArgs e)
        {
            if (!String.IsNullOrEmpty(this.txtEmailAddress.Text))
            {
                List<UserBO> lstCompanyEmail = (from em in (new UserBO()).GetAllObject().ToList()
                                                where em.EmailAddress == this.txtEmailAddress.Text.Trim() && em.ID != QueryID
                                                select em).ToList();

                e.IsValid = !(lstCompanyEmail.Count > 0);
            }
        }

        protected void cfvUserName_Validate(object sender, ServerValidateEventArgs e)
        {
            if (!String.IsNullOrEmpty(this.txtUsername.Text))
            {

                string username = txtUsername.Text.ToLower();

                List<UserBO> lstUserName = new List<UserBO>();

                lstUserName = (from u in (new UserBO()).GetAllObject().ToList()
                            where u.Username.ToLower() == username && u.ID != QueryID
                            select u).ToList();


                e.IsValid = !(lstUserName.Count > 0);
            }
        }

        # endregion

        #region Methods

        private void PopulateControls()
        {
            CompanyBO objCompany = new CompanyBO(this.ObjContext);
            UserBO objUser = new UserBO(this.ObjContext);


           //Populate Company Type
            this.ddlType.Items.Add(new ListItem("Select Company Type", "0"));
            List<CompanyTypeBO> lstCotype = (new CompanyTypeBO()).GetAllObject();
            foreach (CompanyTypeBO companytype in lstCotype)
            {
                this.ddlType.Items.Add(new ListItem(companytype.Name, companytype.ID.ToString()));
            }

           //Populate Country
            this.ddlType.Items.Add(new ListItem("Select Your Country", "0")); ;

            List<CountryBO> lstCountryName = (new CountryBO()).GetAllObject().AsQueryable().OrderBy("ShortName").ToList();
            foreach (CountryBO country in lstCountryName)
            {
                this.ddlCountry.Items.Add(new ListItem(country.ShortName, country.ID.ToString()));
            }
            this.ddlCountry.SelectedValue = this.ddlCountry.Items.FindByValue("14").Value;

            if (this.QueryID > 0)
            {
                objCompany.ID = this.QueryID;
                objCompany.GetObject();

                this.ddlType.SelectedValue = objCompany.Type.ToString();
                this.txtName.Text = objCompany.Name;
                this.txtNumber.Text = objCompany.Number;
                this.txtAddress1.Text = objCompany.Address1;
                this.txtAddress2.Text = objCompany.Address2;
                this.txtNickName.Text = objCompany.NickName;
                this.txtCity.Text = objCompany.City;
                this.txtState.Text = objCompany.State;
                this.txtPostalCode.Text = objCompany.Postcode;
                this.ddlCountry.Text = objCompany.Country.ToString();
                this.txtPhoneNo1.Text = objCompany.Phone1;
                this.txtPhoneNo2.Text = objCompany.Phone2;                
                this.txtFaxNo.Text = objCompany.Fax;
                this.txtNickName.Text = objCompany.NickName;

                lblUserName.Visible = false;
                txtUsername.Visible = false;
                lblFirstName.Visible = false;
                txtGivenName.Visible = false;
                txtFamilyName.Visible = false;
                lblLastName.Visible = false;
                cfvUsername.Enabled = false;
                rfvUsername.Enabled = false;
                rfvGivenName.Enabled = false;
                rfvFamilyName.Enabled = false;
            }
        }

        private void ProcessForm()
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {

                    CompanyBO objCompany = new CompanyBO(this.ObjContext);
                    if (this.QueryID > 0)
                    {
                        objCompany.ID = QueryID;
                        objCompany.GetObject();
                    }

                    objCompany.Type = int.Parse(this.ddlType.SelectedValue);
                    objCompany.Name = this.txtName.Text;
                    objCompany.Number = this.txtNumber.Text;
                    objCompany.Address1 = this.txtAddress1.Text;
                    objCompany.Address2 = this.txtAddress2.Text;
                    objCompany.City = this.txtCity.Text;
                    objCompany.State = this.txtState.Text;
                    objCompany.Postcode = this.txtPostalCode.Text;
                    objCompany.Country = int.Parse(this.ddlCountry.SelectedValue);
                    objCompany.Phone1 = this.txtPhoneNo1.Text;
                    objCompany.Phone2 = this.txtPhoneNo2.Text;                    
                    objCompany.Fax = this.txtFaxNo.Text;
                    objCompany.NickName = this.txtNickName.Text;
                    objCompany.Creator = this.LoggedUser.ID;
                    objCompany.CreatedDate = DateTime.Now;
                    objCompany.Modifier = this.LoggedUser.ID;
                    objCompany.ModifiedDate = DateTime.Now;

                    if (this.QueryID == 0)
                    {
                        UserBO objUser = new UserBO(this.ObjContext);

                        objUser.Company = int.Parse(this.ddlType.SelectedValue);
                        objUser.Username = this.txtUsername.Text;
                        objUser.GivenName = this.txtGivenName.Text;
                        objUser.FamilyName = this.txtFamilyName.Text;
                        objUser.Password = UserBO.GetNewRandomPassword();
                        objUser.EmailAddress = this.txtEmailAddress.Text;
                        objUser.MobileTelephoneNumber = this.txtMobileNo.Text;
                        objUser.OfficeTelephoneNumber = this.txtPhoneNo1.Text;
                        objUser.HomeTelephoneNumber = this.txtPhoneNo2.Text;
                        objUser.Creator = this.LoggedUser.ID;
                        objUser.CreatedDate = DateTime.Now;
                        objUser.Modifier = this.LoggedUser.ID;
                        objUser.ModifiedDate = DateTime.Now;                        

                        objUser.CompanysWhereThisIsOwner.Add(objCompany);
                        objUser.Status = 2;
                    }

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