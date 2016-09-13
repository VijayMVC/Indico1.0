using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class AddEditClient : IndicoPage
    {
        #region Fields

        private int urlQueryID = -1;
        string EmailAddress;
        string FirstName;
        int createdClientId = 0;
        int urlDistributorID = -1;
        int urlVlID = -1;
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

                if (Request.QueryString["dir"] != null)
                {
                    urlDistributorID = Convert.ToInt32(Request.QueryString["dir"].ToString());
                }

                if (Request.QueryString["vl"] != null)
                {
                    urlVlID = Convert.ToInt32(Request.QueryString["vl"].ToString());
                }

                if (Request.QueryString["od"] != null)
                {
                    urlOrderID = Convert.ToInt32(Request.QueryString["od"].ToString());
                }

                return urlQueryID;
            }
        }

        protected int DistributorID
        {
            get
            {
                if (urlDistributorID > -1)
                    return urlDistributorID;

                urlDistributorID = 0;
                if (Request.QueryString["dir"] != null)
                {
                    urlDistributorID = Convert.ToInt32(Request.QueryString["dir"].ToString());
                }
                else if (LoggedUser.IsDirectSalesPerson)
                {
                    urlDistributorID = this.Distributor.ID;
                }

                return urlDistributorID;
            }
        }

        protected int VisualLayoutID
        {
            get
            {
                return urlVlID;
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

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                int client = this.ProcessForm();

                if (VisualLayoutID > -1)
                {
                    Response.Redirect("/AddEditVisualLayout.aspx?id=" + this.VisualLayoutID + "&clt=" + client);
                }
                else if (this.OrderID > -1)
                {
                    Response.Redirect("/AddEditOrder.aspx?clt=" + client);
                }
                else
                {
                    Response.Redirect("/ViewClients.aspx");
                }
            }
        }

        protected void btnClose_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect("/ViewClients.aspx");
        }

        protected void cfvEmailAddress_Validate(object sender, ServerValidateEventArgs e)
        {
            //Check EmailAddress Already Being Used
            if (!String.IsNullOrEmpty(this.txtEmailAddress.Text))
            {
                List<JobNameBO> lstemail = (from em in (new JobNameBO()).GetAllObject().ToList()
                                            where em.Email == this.txtEmailAddress.Text && em.ID != QueryID
                                            select em).ToList();

                e.IsValid = !(lstemail.Count > 0);
            }
        }

        protected void btnSaveNew_Click(object sender, EventArgs e)
        {
            try
            {
                if (this.IsNotRefresh)
                {
                    if (Page.IsValid)
                    {
                        ViewState["isPopulate"] = false;
                        try
                        {
                            using (TransactionScope ts = new TransactionScope())
                            {
                                ClientTypeBO objClientType = new ClientTypeBO(this.ObjContext);

                                objClientType.Name = this.txtNewName.Text;
                                objClientType.Description = this.txtNewDescription.Text;

                                objClientType.Add();
                                this.ObjContext.SaveChanges();
                                ts.Complete();
                            }
                        }
                        catch (Exception ex)
                        {
                            // Log the error
                            //IndicoLogging.log("Error occured while Adding the Item", ex);
                        }
                        Response.Redirect("/AddEditClient.aspx");
                    }
                    else
                    {
                        ViewState["isPopulate"] = true;
                        validationSummaryAddEdit.Visible = !(Page.IsValid);
                    }
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving pattern", ex);
            }
        }

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                //ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                //objReturnInt = SettingsBO.ValidateField(this.QueryID, "JobName", "Name", this.txtName.Text);              
                //args.IsValid = objReturnInt.RetVal == 1;

                int clientID = int.Parse(this.ddlClient.SelectedValue);
                args.IsValid = IndicoPage.ValidateField2(this.QueryID, "JobName", "Name", this.txtName.Text, "Client", clientID.ToString()) == 1;        
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on AddEditClient.aspx", ex);
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            ViewState["isPopulate"] = false;
            //Header Text
            this.litHeaderText.Text = ((this.QueryID > 0) ? "Edit " : "New ") + this.ActivePage.Heading;

            // Popup Header Text
            this.lblPopupHeaderText.Text = "New Client Type";

            // Populate IsDestributors
            //this.ddlCompany.Items.Add(new ListItem("Select Distributor", "0"));
            //CompanyBO objCompany = new CompanyBO();
            //objCompany.IsDistributor = true;

            //List<CompanyBO> lstCompany = new List<CompanyBO>();
            //lstCompany = (from o in objCompany.SearchObjects().OrderBy(m => m.Name).AsQueryable().ToList<CompanyBO>()
            //              where o.IsDistributor == true
            //              select o).ToList();
            //foreach (CompanyBO company in lstCompany)
            //{
            //    this.ddlCompany.Items.Add(new ListItem(company.Name, company.ID.ToString()));
            //}

            //Populate Clients
            this.ddlClient.Items.Add(new ListItem("Select Client", "0"));

            ClientBO objClient = new ClientBO();

            if (LoggedUser.IsDirectSalesPerson)
            {
                objClient.Distributor = DistributorID;
            }
            else if (LoggedUserRoleName == UserRole.DistributorAdministrator || LoggedUserRoleName == UserRole.DistributorCoordinator)
            {
                objClient.Distributor = LoggedCompany.ID;
            }

            List<ClientBO> lstClient = (from o in objClient.SearchObjects().OrderBy(m => m.Name).AsQueryable().ToList<ClientBO>()
                                        select o).ToList(); 
            foreach (ClientBO client in lstClient)
            {
                this.ddlClient.Items.Add(new ListItem(client.Name, client.ID.ToString()));
            }

            // Populate CountryBO
            this.ddlCountry.Items.Add(new ListItem("Select Your Country"));
            List<CountryBO> lstCountry = (new CountryBO()).GetAllObject().AsQueryable().OrderBy("ShortName").ToList();
            foreach (CountryBO country in lstCountry)
            {
                this.ddlCountry.Items.Add(new ListItem(country.ShortName, country.ID.ToString()));
            }

            // If QueryId is grater than zero, edit mode.
            if (this.QueryID > 0)
            {
                JobNameBO objJobName = new JobNameBO(this.ObjContext);
                objJobName.ID = this.QueryID;
                objJobName.GetObject();

                this.ddlClient.SelectedValue = objJobName.Client.ToString();
                this.txtName.Text = objJobName.Name;
                this.txtAddress1.Text = objJobName.Address;
                this.txtCity.Text = objJobName.City;
                this.txtState.Text = objJobName.State;
                this.txtPostalCode.Text = objJobName.PostalCode;
                if (!string.IsNullOrEmpty(objJobName.Country))
                    this.ddlCountry.Items.FindByText(objJobName.Country).Selected = true; //.SelectedItem.Text = objJobName.Country;
                this.txtPhoneNo1.Text = objJobName.Phone;
                this.txtEmailAddress.Text = objJobName.Email;
            }
            else
            {
                this.ddlCountry.Items.FindByValue("14").Selected = true;
            }
        }

        private int ProcessForm()
        {
            int client = 0;
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    JobNameBO objJobName = new JobNameBO(this.ObjContext);
                    if (QueryID > 0)
                    {
                        objJobName.ID = QueryID;
                        objJobName.GetObject();
                    }
                    else
                    {
                        objJobName.Creator = this.LoggedUser.ID;
                        objJobName.CreatedDate = DateTime.Now;
                    }

                    objJobName.Client = int.Parse(this.ddlClient.SelectedValue);
                    objJobName.Name = this.txtName.Text;
                    objJobName.Address = this.txtAddress1.Text;
                    objJobName.City = this.txtCity.Text;
                    objJobName.State = this.txtState.Text;
                    objJobName.PostalCode = this.txtPostalCode.Text;

                    if (ddlCountry.SelectedIndex > 0)
                        objJobName.Country = this.ddlCountry.SelectedItem.Text;  //int.Parse(this.ddlCountry.SelectedValue);
                    objJobName.Phone = this.txtPhoneNo1.Text;
                    objJobName.Email = this.txtEmailAddress.Text;
                    objJobName.Modifier = this.LoggedUser.ID;
                    objJobName.ModifiedDate = DateTime.Now;

                    this.ObjContext.SaveChanges();
                    ts.Complete();

                    client = objJobName.ID;

                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving clients", ex);
            }

            return client;
        }

        private void SendEmail()
        {
            try
            {
                string hosturl = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/";
                string emailcontent = String.Format("<p>A new acoount set up for u at <a href =\"http://{0}\">\"http://{0}/</a></p>" +
                                                    "<p>To complete your registration simply clik the link below to sign in<br>" +
                                                    "<a href=\"http://{0}Welcome.aspx?id={1}\">http://{0}Welcome.aspx?id={1}</a></p>",
                                                    hosturl, createdClientId.ToString());

                IndicoEmail.SendMailNotificationsToExternalUsers(this.LoggedUser, EmailAddress, FirstName, "Add New Client", emailcontent);

                //string hostUrl = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/";
                //string emailContent = "Welcome";

                //IndicoEmail.SendMailNotificationsToExternalUsers(this.LoggedUser, EmailAddress, FirstName, "Add New Client", emailContent);

            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while send client email", ex);
            }
        }

        #endregion

        protected void ddlCountry_SelectedIndexChanged(object sender, EventArgs e)
        {

        }
    }
}