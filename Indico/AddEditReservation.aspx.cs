
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.IO;
using System.Drawing;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using Dapper;
using Indico.Common;
using Indico.BusinessObjects;
using System.Threading;
using Indico.Models;

namespace Indico
{
    public partial class AddEditReservation : IndicoPage
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

        private string SortExpression
        {
            get
            {
                string sort = (string)Session["PatternSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Number";
                }
                return sort;
            }
            set
            {
                Session["PatternSortExpression"] = value;
            }
        }

        #endregion

        #region Constructors

        #endregion

        #region Events

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

                if (QueryID > 0)
                {
                    PopulateControls2();
                }
            }
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                this.ProcessForm();
                Response.Redirect("/ViewReservations.aspx");
            }
        }

        protected void ddlShipTo_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        

        protected void ddlShipToAddress_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateShipToAddress();
        }


        public void ProcessForm()
        {

            if (QueryID > 0)
            {
                using (var connection = GetIndicoConnnection())
                {

                    var query = string.Format("UPDATE [dbo].[Reservation] SET OrderDate='{0}',Pattern={1},Coordinator={2},Distributor={3},Client='{4}',ShipmentDate='{5}',Qty={6},Notes='{7}',DateCreated='{8}',DateModified='{9}',Creator={10},Modifier={11},Status={12},QtyPolo={13},QtyOutwear={14} WHERE ID={15} ", DateTime.Parse(txtDate.Text).ToString("yyyyMMdd"), ddlPattern.SelectedValue, ddlCoordinator.SelectedValue, ddlDistributor.SelectedValue, txtClient.Text, DateTime.Parse(txtShippingDate.Text).ToString("yyyyMMdd"), txtQty.Text, txtNotes.Text, DateTime.Now.ToString("yyyyMMdd"), DateTime.Now.ToString("yyyyMMdd"), LoggedUser.ID, LoggedUser.ID, 1, txtQtyPolo.Text, txtQtyOutwear.Text,QueryID);
                    connection.Execute(query);
                    Response.Redirect("ViewReservations.aspx");
                }

            }
            else
            {
                using (var connection = GetIndicoConnnection())
                {

                    var query = string.Format("INSERT INTO [dbo].[Reservation] (OrderDate,Pattern,Coordinator,Distributor,Client,ShipmentDate,Qty,Notes,DateCreated,DateModified,Creator,Modifier,Status,QtyPolo,QtyOutwear) VALUES('{0}',{1},{2},{3},'{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}','{14}')", DateTime.Parse(txtDate.Text).ToString("yyyyMMdd"), ddlPattern.SelectedValue, ddlCoordinator.SelectedValue, ddlDistributor.SelectedValue, txtClient.Text, DateTime.Parse(txtShippingDate.Text).ToString("yyyyMMdd"), txtQty.Text, txtNotes.Text, DateTime.Now.ToString("yyyyMMdd"), DateTime.Now.ToString("yyyyMMdd"), LoggedUser.ID, LoggedUser.ID, 1, txtQtyPolo.Text, txtQtyOutwear.Text);
                    connection.Execute(query);
                    Response.Redirect("ViewReservations.aspx");

                }
            }
        }





        /*  protected void ddlDistributor_SelectedIndexChanged(object sender, EventArgs e)
          {
              CompanyBO objDistributor = new CompanyBO();
              objDistributor.ID = int.Parse(this.ddlDistributor.SelectedValue);
              objDistributor.GetObject();

              //Populate Clients
              this.ddlClientOrJobName.Items.Clear();
              this.ddlClientOrJobName.Items.Add(new ListItem("Select Client", "0"));
              List<ClientBO> lstClients = objDistributor.ClientsWhereThisIsDistributor;
              foreach (ClientBO client in lstClients)
              {
                  this.ddlClientOrJobName.Items.Add(new ListItem(client.Name, client.ID.ToString()));
              }

              this.lblCoordinator.Text = (objDistributor.Coordinator != null && objDistributor.Coordinator > 0) ? objDistributor.objCoordinator.GivenName + " " + objDistributor.objCoordinator.FamilyName : "No Coordinator";
              this.hdnCoordinator.Value = (objDistributor.Coordinator != null && objDistributor.Coordinator > 0) ? objDistributor.Coordinator.ToString() : "0";
          }*/

        #endregion

        #region Methods

        /*
    private void PopulateControls()
    {
        //Header Text
        this.litHeaderText.Text = (this.QueryID > 0) ? "Edit Reservation" : "New Reservation";
        this.divReservationNo.Visible = (this.QueryID > 0) ? true : false;

        ViewState["PopulatePatern"] = false;
        // this.PopulatePatterns();

        this.txtDate.Text = DateTime.Now.ToString("dd MMMM yyyy");

        //Populate Coordinator
        this.ddlCoordinator.Items.Clear();
        this.ddlCoordinator.Items.Add(new ListItem("Select Coordinator", "0"));
        List<UserBO> lstCoordinators = (new UserBO()).GetAllObject().Where(o => o.objCompany.Type == 3).ToList(); ;
        foreach (UserBO coordinator in lstCoordinators)
        {
            this.ddlCoordinator.Items.Add(new ListItem(coordinator.GivenName + " " + coordinator.FamilyName, coordinator.ID.ToString()));
        }

        //Populate Distributors
        this.ddlDistributor.Items.Clear();
        this.ddlDistributor.Items.Add(new ListItem("Select Distributor", "0"));
        List<CompanyBO> lstDistributors = (new CompanyBO()).GetAllObject().Where(o => o.IsDistributor == true).OrderBy(o => o.Name).ToList(); ;
        foreach (CompanyBO distributor in lstDistributors)
        {
            this.ddlDistributor.Items.Add(new ListItem(distributor.Name, distributor.ID.ToString()));
        }

        //Populate Ship To            
        //this.ddlShipToAddress.Items.Clear();
        //this.ddlShipToAddress.Items.Add(new ListItem("Select Ship To", "0"));

       List<DistributorClientAddressBO> lstDistributorClientAddress = (new DistributorClientAddressBO()).GetAllObject().OrderBy(o => o.CompanyName).ToList();

        //Populate Shipment Modes
        //this.ddlShipmentMode.Items.Clear();
        //this.ddlShipmentMode.Items.Add(new ListItem("Select Shipment Mode", "0"));
        List<ShipmentModeBO> lstShipmentMode = (new ShipmentModeBO()).GetAllObject();

        //Populate Status
        //.ddlStatus.Items.Clear();
        List<ReservationStatusBO> lstReservationStatus = (new ReservationStatusBO()).GetAllObject();

        // populate Pattern
        this.ddlPattern.Items.Clear();
        this.ddlPattern.Items.Add(new ListItem("Select a Pattern", "0"));
        List<PatternBO> lstPattern = (new PatternBO()).GetAllObject().Where(o => o.IsActive == true).OrderBy(o => o.Number).ToList();
        foreach (PatternBO pattern in lstPattern)
        {
            this.ddlPattern.Items.Add(new ListItem(pattern.Number + " - " + pattern.NickName, pattern.ID.ToString()));
        }

        if (this.LoggedUser.IsDirectSalesPerson)
        {
            this.ddlDistributor.Items.FindByValue(this.Distributor.ID.ToString()).Selected = true;
            this.ddlCoordinator.Items.FindByValue(this.Distributor.Coordinator.ToString()).Selected = true;
            this.ddlDistributor.Enabled = this.ddlCoordinator.Enabled = false;
        }
        else if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
        {
            this.ddlCoordinator.Items.FindByValue(LoggedUser.ID.ToString()).Selected = true;
            this.ddlCoordinator.Enabled = false;
            lstDistributors = lstDistributors.Where(m => m.Coordinator == LoggedUser.ID).ToList();

            lstDistributors.Clear();
            foreach (CompanyBO distributor in lstDistributors)
            {
                this.ddlDistributor.Items.Add(new ListItem(distributor.Name, distributor.ID.ToString()));
            }
        }

        if (this.QueryID > 0)
        {
            //this.liStatus.Visible = true;
            this.ResetDropdowns();

            ReservationBO objReservation = new ReservationBO();
            objReservation.ID = this.QueryID;
            objReservation.GetObject();

            this.txtDate.Text = objReservation.OrderDate.ToString("dd MMM yyyy");
            this.ddlPattern.Items.FindByValue(objReservation.Pattern.ToString()).Selected = true;
            this.txtReservationNo.Text = "RES - " + objReservation.ReservationNo.ToString("0000");

            this.ddlCoordinator.Items.FindByValue(objReservation.Coordinator.ToString()).Selected = true;
            this.ddlDistributor.Items.FindByValue(objReservation.Distributor.ToString()).Selected = true;
            this.txtClient.Text = objReservation.Client.ToString();
            //this.ddlShipmentMode.Items.FindByValue(objReservation.ShipmentMode.ToString()).Selected = true;
            //this.ddlStatus.Items.FindByValue(objReservation.Status.ToString()).Selected = true;
            this.txtShippingDate.Text = objReservation.ShipmentDate.ToString("dd MMM yyyy");
            this.txtQty.Text = objReservation.Qty.ToString();
            this.txtNotes.Text = objReservation.Notes;
            //this.ddlShipToAddress.Items.FindByValue((objReservation.ShipTo != null && objReservation.ShipTo > 0) ? objReservation.ShipTo.ToString() : "0").Selected = true;

            PopulateShipToAddress();
        }
        else
        {
            //this.liStatus.Visible = false;
        }
    }

*/


        private void PopulateControls2()
        {
            this.litHeaderText.Text = (this.QueryID > 0) ? "Edit Reservation" : "New Reservation";

            if(this.QueryID>0)
            {
                var connection = GetIndicoConnnection();
                var result = connection.Query<ReservationBalanceModel>(String.Format("SELECT * FROM [dbo].[Reservation_balanceView] WHERE ID={0}",QueryID));
                foreach(var record in result)
                {   
                    
                    txtClient.Text = record.Client;
                    txtDate.Text =Convert.ToString(record.ReservationDate);
                    txtShippingDate.Text = Convert.ToString(record.ShipmentDate);
                    txtQty.Text = Convert.ToString(record.Qty);
                    txtQtyOutwear.Text = Convert.ToString(record.QtyOutwear);
                    txtQtyPolo.Text= Convert.ToString(record.QtyPolo);
                    txtNotes.Text = record.Notes;

                    ddlDistributor.SelectedIndex = ddlDistributor.Items.IndexOf(ddlDistributor.Items.FindByText(record.Distributor));
                    ddlCoordinator.SelectedIndex = ddlCoordinator.Items.IndexOf(ddlCoordinator.Items.FindByText(record.Coordinator));
                    ddlPattern.SelectedIndex = ddlPattern.Items.IndexOf(ddlPattern.Items.FindByText(record.Pattern));

                

                }
            }
        }



        public static List<PatternModel> GetPattern()
        {
            using (var connection = GetIndicoConnnection())
            {
                return connection.Query<PatternModel>("SELECT ID,NickName FROM [dbo].[Pattern]").ToList();
            }
        }

        public static List<UserModel> GetCordinator()
        {
            using (var connection = GetIndicoConnnection())
            {
                return connection.Query<UserModel>("SELECT ID,UserName FROM [dbo].[User]").ToList();
            }
        }

        public static List<DistributorModel> GetDistributor()
        {
            using(var connection = GetIndicoConnnection())
            {
                return connection.Query<DistributorModel>("SELECT ID,Name FROM [dbo].[Company]").ToList();
            }
        }

        public void PopulateControls()
        {
            var cat = new PatternModel { NickName = "Please Select", ID = 0 };
            var cats = new List<PatternModel> { cat };
            cats.AddRange(GetPattern());
            ddlPattern.DataSource = cats;
            ddlPattern.DataBind();

            var coordinator = new UserModel { ID = 0, Username = "Please select" };
            var coordinators = new List<UserModel> { coordinator };
            coordinators.AddRange(GetCordinator());
            ddlCoordinator.DataSource = coordinators;
            ddlCoordinator.DataBind();

            var distributor = new DistributorModel { ID = 0, Name = "Please select" };
            var distributors = new List<DistributorModel> { distributor };
            distributors.AddRange(GetDistributor());
            ddlDistributor.DataSource = distributors;
            ddlDistributor.DataBind();
        }

        private void ResetDropdowns()
        {
            foreach (Control control in this.dvPageContent.Controls)
            {
                if (control is DropDownList)
                {
                    foreach (ListItem item in ((DropDownList)control).Items)
                    {
                        if (item.Selected)
                            ((DropDownList)control).Items.FindByValue(item.Value).Selected = false;
                    }
                }
            }
        }

        private void SendEmail()
        {
            try
            {
                string reciveremail = this.LoggedCompany.objOwner.EmailAddress;
                string recivername = this.LoggedCompany.objOwner.GivenName;

                string hostUrl = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/";
                string emailContent = "New Reservation has been placed";
                IndicoEmail.SendMailNotificationsToExternalUsers(this.LoggedUser, reciveremail, recivername, "New Reservation has been placed", emailContent);
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while send client order email", ex);
            }
        }

        private void PopulateShipToAddress()
        {
            //int shipto = int.Parse(this.ddlShipToAddress.SelectedValue);
            /*
            if (shipto > 0)
            {
                DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO();
                objDistributorClientAddress.ID = shipto;
                objDistributorClientAddress.GetObject();

                string state = (string.IsNullOrEmpty(objDistributorClientAddress.State)) ? string.Empty : objDistributorClientAddress.State;

                this.lblShipToAddress.Text = objDistributorClientAddress.CompanyName + " " +
                                             objDistributorClientAddress.Address + " " +
                                             objDistributorClientAddress.Suburb + " " + state + " " +
                                             objDistributorClientAddress.objCountry.ShortName + " " +
                                             objDistributorClientAddress.PostCode + " ( " +
                                             objDistributorClientAddress.ContactName + " " +
                                             objDistributorClientAddress.ContactPhone + " ) ";
            }
            this.lblShipToAddress.Visible = (shipto > 0) ? true : false;
            */
        }
        
        #endregion
      
    }
}