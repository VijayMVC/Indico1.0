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

using Indico.Common;
using Indico.BusinessObjects;
using System.Threading;

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
            this.ddlShipToAddress.Items.Clear();
            this.ddlShipToAddress.Items.Add(new ListItem("Select Ship To", "0"));
            List<DistributorClientAddressBO> lstDistributorClientAddress = (new DistributorClientAddressBO()).GetAllObject().OrderBy(o => o.CompanyName).ToList();
            foreach (DistributorClientAddressBO item in lstDistributorClientAddress)
            {
                this.ddlShipToAddress.Items.Add(new ListItem(item.CompanyName, item.ID.ToString()));
            }

            //Populate Shipment Modes
            this.ddlShipmentMode.Items.Clear();
            this.ddlShipmentMode.Items.Add(new ListItem("Select Shipment Mode", "0"));
            List<ShipmentModeBO> lstShipmentMode = (new ShipmentModeBO()).GetAllObject();
            foreach (ShipmentModeBO shipmentMode in lstShipmentMode)
            {
                this.ddlShipmentMode.Items.Add(new ListItem(shipmentMode.Name, shipmentMode.ID.ToString()));
            }

            //Populate Status
            this.ddlStatus.Items.Clear();
            List<ReservationStatusBO> lstReservationStatus = (new ReservationStatusBO()).GetAllObject();
            foreach (ReservationStatusBO status in lstReservationStatus)
            {
                this.ddlStatus.Items.Add(new ListItem(status.Name, status.ID.ToString()));
            }

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
                this.liStatus.Visible = true;
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
                this.ddlShipmentMode.Items.FindByValue(objReservation.ShipmentMode.ToString()).Selected = true;
                this.ddlStatus.Items.FindByValue(objReservation.Status.ToString()).Selected = true;
                this.txtShippingDate.Text = objReservation.ShipmentDate.ToString("dd MMM yyyy");
                this.txtQty.Text = objReservation.Qty.ToString();
                this.txtNotes.Text = objReservation.Notes;
                this.ddlShipToAddress.Items.FindByValue((objReservation.ShipTo != null && objReservation.ShipTo > 0) ? objReservation.ShipTo.ToString() : "0").Selected = true;

                PopulateShipToAddress();
            }
            else
            {
                this.liStatus.Visible = false;
            }
        }

        //private void PopulatePatterns()
        //{
        //    // Hide Controls
        //    this.dvEmptyContentPattern.Visible = false;
        //    this.dvDataContentPattern.Visible = false;
        //    this.dvNoSearchResultPattern.Visible = false;

        //    string searchText = this.txtSearchPattern.Text.ToLower();

        //    PatternBO objPattern = new PatternBO();
        //    List<PatternBO> lstPatterns = objPattern.GetAllObject().AsQueryable().OrderBy(SortExpression).ToList();

        //    if (searchText != string.Empty)
        //    {
        //        lstPatterns = (from o in lstPatterns.AsQueryable().OrderBy(SortExpression)
        //                       where o.Number.ToLower().Contains(searchText) ||
        //                             o.NickName.ToLower().Contains(searchText) ||
        //                             o.objItem.Name.ToLower().Contains(searchText) ||
        //                             o.objPrinterType.Name.ToLower().Contains(searchText)
        //                       select o).ToList();
        //    }

        //    if (lstPatterns.Count > 0)
        //    {
        //        this.dgPatterns.AllowPaging = (lstPatterns.Count > this.dgPatterns.PageSize);
        //        this.dgPatterns.DataSource = lstPatterns;
        //        this.dgPatterns.DataBind();

        //        this.dvDataContentPattern.Visible = true;
        //    }
        //    else if ((searchText != string.Empty && searchText != "search"))
        //    {
        //        this.lblSerchKeyPattern.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

        //        this.dvDataContentPattern.Visible = true;
        //        this.dvNoSearchResultPattern.Visible = true;
        //    }
        //    else
        //    {
        //        this.dvEmptyContentPattern.Visible = true;
        //    }

        //    this.dgPatterns.Visible = (lstPatterns.Count > 0);
        //}

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm()
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    ReservationBO objReservation = new ReservationBO(this.ObjContext);
                    if (this.QueryID > 0)
                    {
                        objReservation.ID = this.QueryID;
                        objReservation.GetObject();
                    }

                    if (this.QueryID == 0)
                    {
                        objReservation.ReservationNo = objReservation.GetAllObject().Count == 0 ? 1 : objReservation.GetAllObject().Select(o => o.ReservationNo).Max() + 1;
                    }

                    objReservation.OrderDate = DateTime.Parse(this.txtDate.Text);
                    objReservation.Pattern = int.Parse(this.ddlPattern.SelectedValue);

                    objReservation.Coordinator = int.Parse(this.ddlCoordinator.SelectedValue);
                    objReservation.Distributor = int.Parse(this.ddlDistributor.SelectedValue);
                    objReservation.Client = this.txtClient.Text;

                    objReservation.ShipTo = int.Parse(this.ddlShipToAddress.SelectedValue);

                    objReservation.ShipmentMode = int.Parse(this.ddlShipmentMode.SelectedValue);
                    objReservation.ShipmentDate = DateTime.Parse(this.txtShippingDate.Text);
                    objReservation.Qty = int.Parse(this.txtQty.Text.Trim());
                    objReservation.Status = (this.QueryID == 0) ? 6 : int.Parse(this.ddlStatus.SelectedValue);
                    objReservation.Notes = this.txtNotes.Text.Trim();
                    objReservation.DateModified = DateTime.Now;
                    objReservation.Modifier = this.LoggedUser.ID;

                    if (this.QueryID == 0)
                    {
                        objReservation.Creator = this.LoggedUser.ID;
                        objReservation.DateCreated = DateTime.Now;

                        //objReservation.Add();
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();

                    new Thread(new ThreadStart(SendEmail)).Start();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving or updating reservations in AddEditReservations.aspx", ex);
            }
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
            int shipto = int.Parse(this.ddlShipToAddress.SelectedValue);

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
        }

        #endregion
    }
}