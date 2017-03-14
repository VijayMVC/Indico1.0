using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class ViewShipmentAddresses : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["DistributorClientAddressSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "CompanyName";
                }
                return sort;
            }
            set
            {
                ViewState["AgeGroupsSortExpression"] = value;
            }
        }

        public bool IsNotRefresh
        {
            get
            {
                return (Session["IsPostBack"].ToString() == ViewState["IsPostBack"].ToString());
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
        /// 
        protected void Page_PreRender(object sender, EventArgs e)
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

        protected void RadGridShipmentAddress_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridShipmentAddress_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
            ViewState["IsPageValied"] = true;
        }

        protected void RadGridShipmentAddress_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
            ViewState["IsPageValied"] = true;
        }

        protected void RadGridShipmentAddress_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }

            ViewState["IsPageValied"] = true;
        }

        protected void RadGridShipmentAddress_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is DistributorClientAddressBO)
                {
                    DistributorClientAddressBO objDistributorClientAddress = (DistributorClientAddressBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");

                    Literal litCountry = (Literal)item.FindControl("litCountry");
                    Literal litClient = (Literal)item.FindControl("litClient");
                    Literal litDistributor = (Literal)item.FindControl("litDistributor");
                    Literal litPort = (Literal)item.FindControl("litPort");
                    Literal litAddressType = (Literal)item.FindControl("litAddressType");

                    litCountry.Text = objDistributorClientAddress.objCountry.ShortName;
                    litPort.Text = (objDistributorClientAddress.Port.HasValue && objDistributorClientAddress.Port > 0) ? objDistributorClientAddress.objPort.Name : string.Empty;

                    if (objDistributorClientAddress.AddressType.HasValue)
                    {
                        litAddressType.Text = (objDistributorClientAddress.AddressType.Value == 1) ? "RESIDENTIAL" : "BUSINESS";
                    }
                    litClient.Text = (objDistributorClientAddress.Client.HasValue && objDistributorClientAddress.Client > 0) ? objDistributorClientAddress.objClient.Name : string.Empty;
                    litDistributor.Text = (objDistributorClientAddress.Distributor.HasValue && objDistributorClientAddress.Distributor > 0) ? objDistributorClientAddress.objDistributor.Name : string.Empty;

                    linkEdit.Attributes.Add("qid", objDistributorClientAddress.ID.ToString());
                    linkDelete.Attributes.Add("qid", objDistributorClientAddress.ID.ToString());

                    linkDelete.Visible = (objDistributorClientAddress.OrdersWhereThisIsBillingAddress.Any() || objDistributorClientAddress.OrdersWhereThisIsDespatchToAddress.Any() || objDistributorClientAddress.OrderDetailsWhereThisIsDespatchTo.Any()) ? false : true;
                }
            }
        }

        protected void btnSaveShippingAddress_ServerClick(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int shipmentaddressid = int.Parse(this.hdnSelectedShipmentAddressID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(shipmentaddressid);
                    // TODO Add Later - MYOBSERVICE
                    //var myobService = new MyobService();
                    //myobService.SaveAddress(shipmentaddressid);
                    Response.Redirect("/ViewShipmentAddresses.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        //protected void dataGridAgeGroup_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is DistributorClientAddressBO)
        //    {
        //        DistributorClientAddressBO objDistributorClientAddress = (DistributorClientAddressBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objDistributorClientAddress.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objDistributorClientAddress.ID.ToString());
        //        linkDelete.Visible = (objDistributorClientAddress.PatternsWhereThisIsAgeGroup.Count == 0);
        //    }
        //}

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["IsPageValied"] = true;
            this.PopulateDataGrid();
        }

        //protected void btnSaveChanges_Click(object sender, EventArgs e)
        //{
        //    if (this.IsNotRefresh)
        //    {
        //        int addressid = int.Parse(this.hdnSelectedaddressid.Value.Trim());

        //        if (Page.IsValid)
        //        {
        //            this.ProcessForm(addressid, false);

        //            Response.Redirect("/ViewAgeGroups.aspx");
        //        }

        //        ViewState["IsPageValied"] = (Page.IsValid);
        //    }
        //}

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int addressid = int.Parse(this.hdnSelectedShipmentAddressID.Value.Trim());

            if (Page.IsValid && addressid > 0)
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO(this.ObjContext);
                    objDistributorClientAddress.ID = addressid;
                    objDistributorClientAddress.GetObject();

                    objDistributorClientAddress.Delete();

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;

        }

        //protected void dataGridAgeGroup_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridAgeGroup.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dataGridAgeGroup_SortCommand(object source, DataGridSortCommandEventArgs e)
        //{
        //    string sortDirection = String.Empty;
        //    if (!SortExpression.ToUpper().StartsWith(e.SortExpression) && !SortExpression.ToUpper().Trim().EndsWith("ASC"))
        //    {
        //        sortDirection = " asc";
        //    }
        //    else
        //    {
        //        sortDirection = (SortExpression.ToUpper().EndsWith("DESC")) ? " asc" : " desc";
        //    }
        //    this.SortExpression = e.SortExpression + sortDirection;

        //    this.PopulateDataGrid();

        //    foreach (DataGridColumn col in this.dataGridAgeGroup.Columns)
        //    {
        //        if (col.Visible && col.SortExpression == e.SortExpression)
        //        {
        //            col.HeaderStyle.CssClass = "selected " + ((sortDirection.ToUpper() != " DESC") ? "sortDown" : "sortUp");
        //        }
        //        else
        //        {
        //            col.HeaderStyle.CssClass = "";
        //        }
        //    }
        //}

        //protected void cvDistributor_ServerValidate(object source, ServerValidateEventArgs args)
        //{
        //    if (rbClient.Checked)
        //    {
        //        args.IsValid = int.Parse(ddlClient.SelectedValue) > 0;
        //        cvDistributor.ErrorMessage = "Client is required.";
        //    }
        //    else if (rbDistributor.Checked)
        //    {
        //        args.IsValid = int.Parse(ddlDistributor.SelectedValue) > 0;
        //        cvDistributor.ErrorMessage = "Distributor is required.";
        //    }
        //}

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int shipmentaddressid = int.Parse(this.hdnSelectedShipmentAddressID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(shipmentaddressid, "DistributorClientAddress", "Address", this.txtShipToAddress.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewShipmentAddresses.aspx", ex);
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;

            lblPopupHeaderText.Text = "New Address";
            ViewState["IsPageValied"] = true;
            Session["ShipmentAddressDetails"] = null;

            // populate Country
            this.ddlShipToCountry.Items.Clear();
            this.ddlShipToCountry.Items.Add(new ListItem("Select a Country", "0"));
            List<CountryBO> lstCountries = (new CountryBO()).GetAllObject();
            foreach (CountryBO country in lstCountries)
            {
                this.ddlShipToCountry.Items.Add(new ListItem(country.ShortName, country.ID.ToString()));
            }

            //populate Ports
            this.ddlShipToPort.Items.Clear();
            this.ddlShipToPort.Items.Add(new ListItem("Select a Port", "0"));
            List<DestinationPortBO> lstDestinationPorts = (new DestinationPortBO()).GetAllObject();
            foreach (DestinationPortBO port in lstDestinationPorts)
            {
                this.ddlShipToPort.Items.Add(new ListItem(port.Name, port.ID.ToString()));
            }

            //populate clients
            //this.ddlClient.Items.Clear();
            //this.ddlClient.Items.Add(new ListItem("Select a Client", "0"));

            //ClientBO objClient = new ClientBO();
            //List<ClientBO> lstClients = objClient.SearchObjects().OrderBy(o => o.Name).ToList();

            this.RadGridShipmentAddress.MasterTableView.GetColumn("CountryID").Display = false;
            this.RadGridShipmentAddress.MasterTableView.GetColumn("PortID").Display = false;
            this.RadGridShipmentAddress.MasterTableView.GetColumn("ClientID").Display = false;
            this.RadGridShipmentAddress.MasterTableView.GetColumn("DistributorID").Display = false;
            this.RadGridShipmentAddress.MasterTableView.GetColumn("AddressTypeID").Display = false;

            //if (this.LoggedUser.IsDirectSalesPerson)
            //{
            //    lstClients = lstClients.Where(m => m.Distributor == this.Distributor.ID).ToList();
            //}
            //if (this.LoggedUser.IsDirectSalesPerson)
            //{
            //    this.dvDistributor.Attributes.Add("style", "display:none");
            //}
            //else if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
            //{
            //    lstClients = lstClients.Where(m => m.objDistributor.Coordinator == this.LoggedUser.ID).ToList();
            //}

            //foreach (ClientBO client in lstClients)
            //{
            //    this.ddlClient.Items.Add(new ListItem(client.Name, client.ID.ToString()));
            //}

            // Populate Distributors
            this.ddlDistributor.Items.Clear();
            this.ddlDistributor.Items.Add(new ListItem("Select a Distributor", "0"));

            CompanyBO objDistributor = new CompanyBO();
            objDistributor.IsDistributor = true;
            List<CompanyBO> lstDistributors = new List<CompanyBO>();

            if (this.LoggedUser.IsDirectSalesPerson)
            {
                objDistributor.ID = this.Distributor.ID;
                lstDistributors = objDistributor.SearchObjects();
            }
            else if (LoggedUserRoleName == UserRole.DistributorAdministrator || LoggedUserRoleName == UserRole.DistributorCoordinator)
            {
                lstDistributors = objDistributor.SearchObjects();
            }
            else
            {
                lstDistributors = objDistributor.SearchObjects();
            }

            lstDistributors = lstDistributors.OrderBy(m => m.Name).ToList();

            foreach (CompanyBO distributor in lstDistributors)
            {
                this.ddlDistributor.Items.Add(new ListItem(distributor.Name, distributor.ID.ToString()));
            }

            if (this.LoggedUser.IsDirectSalesPerson)
            {
                this.ddlDistributor.Items.FindByValue(this.Distributor.ID.ToString()).Selected = true;
                this.ddlDistributor.Enabled = false;
            }

            //Populate Address Type
            this.ddlAdderssType.Items.Clear();
            this.ddlAdderssType.Items.Add(new ListItem("Select an Address Type", "-1"));
            int addressType = 0;
            foreach (AddressType type in Enum.GetValues(typeof(AddressType)))
            {
                this.ddlAdderssType.Items.Add(new ListItem(type.ToString(), addressType++.ToString()));
            }

            this.PopulateDataGrid();
        }

        private void PopulateDataGrid()
        {
            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            // Search text
            string searchText = this.txtSearch.Text.ToLower().Trim();

            // Populate Items

            //   List<int> lstClientIDs = 

            DistributorClientAddressBO objDisClientAddress = new DistributorClientAddressBO();

            if (this.LoggedUser.IsDirectSalesPerson)
            {
                objDisClientAddress.Distributor = this.Distributor.ID;
            }

            List<DistributorClientAddressBO> lstDistributorClientAddress;

            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstDistributorClientAddress = objDisClientAddress.SearchObjects().Where(m => m.CompanyName.ToUpper().Contains(searchText.ToUpper())).ToList();
            }
            else
            {
                lstDistributorClientAddress = objDisClientAddress.SearchObjects();
            }

            //DistributorClientAddressDetailsViewBO lstDistributorClientAddress = new DistributorClientAddressDetailsViewBO();

            //if (this.LoggedUser.IsDirectSalesPerson)
            //{
            //    lstDistributorClientAddress = lstDistributorClientAddress.Where(m => m.Client > 0 && m.objClient.objClient.Distributor == this.Distributor.ID).ToList();
            //}
            //else if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
            //{

            //}
            //   objDistributorClientAddress.DistributorID = 

            //List<DistributorClientAddressDetailsViewBO> lstDistributorClientAddress = new List<DistributorClientAddressDetailsViewBO>();
            //if ((searchText != string.Empty) && (searchText != "search"))
            //{
            //    lstDistributorClientAddress = (from o in objDistributorClientAddress.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
            //                                   where o.CompanyName.ToLower().Contains(searchText) ||
            //                                         o.ContactName.ToLower().Contains(searchText) ||
            //                                         o.Address.ToLower().Contains(searchText) ||
            //                                         o.Suburb.ToLower().Contains(searchText) ||
            //                                         o.Country.ToLower().Contains(searchText) ||
            //                                         o.Port.ToLower().Contains(searchText)
            //                                   select o).ToList();
            //}
            //else
            //{
            //    lstDistributorClientAddress = objDistributorClientAddress.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            //}

            if (lstDistributorClientAddress.Count > 0)
            {
                this.RadGridShipmentAddress.AllowPaging = (lstDistributorClientAddress.Count > this.RadGridShipmentAddress.PageSize);
                this.RadGridShipmentAddress.DataSource = lstDistributorClientAddress;
                this.RadGridShipmentAddress.DataBind();
                Session["ShipmentAddressDetails"] = lstDistributorClientAddress;

                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search"))
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyContent.Visible = true;
                this.btnAddAddress.Visible = false;
            }

            this.RadGridShipmentAddress.Visible = (lstDistributorClientAddress.Count > 0);
        }

        private void ProcessForm(int addressid)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO(this.ObjContext);
                    if (addressid > 0)
                    {
                        objDistributorClientAddress.ID = addressid;
                        objDistributorClientAddress.GetObject();
                    }

                    objDistributorClientAddress.Address = this.txtShipToAddress.Text;
                    objDistributorClientAddress.Suburb = this.txtSuburbCity.Text;
                    objDistributorClientAddress.PostCode = this.txtShipToPostCode.Text;
                    objDistributorClientAddress.Country = int.Parse(this.ddlShipToCountry.SelectedValue);
                    objDistributorClientAddress.ContactName = this.txtShipToContactName.Text;
                    objDistributorClientAddress.EmailAddress = this.txtShipToEmail.Text;
                    objDistributorClientAddress.ContactPhone = this.txtShipToPhone.Text;
                    objDistributorClientAddress.CompanyName = this.txtCOmpanyName.Text;
                    objDistributorClientAddress.State = this.txtShipToState.Text;
                    objDistributorClientAddress.Port = int.Parse(this.ddlShipToPort.SelectedValue);
                    //if (rbClient.Checked)
                    //{
                    //    objDistributorClientAddress.Client = int.Parse(this.ddlClient.SelectedValue);
                    //    objDistributorClientAddress.Distributor = null;
                    //}
                    //else
                    //{
                    objDistributorClientAddress.Distributor = int.Parse(this.ddlDistributor.SelectedValue);
                    objDistributorClientAddress.Client = null;
                    //}
                    objDistributorClientAddress.AddressType = int.Parse(this.ddlAdderssType.SelectedValue);
                    objDistributorClientAddress.IsAdelaideWarehouse = false;

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Adding or Updating the Distributor Client Address in ViewShipmentAddress.aspx", ex);
            }
        }

        private void ReBindGrid()
        {
            if (Session["ShipmentAddressDetails"] != null)
            {
                RadGridShipmentAddress.DataSource = (List<DistributorClientAddressBO>)Session["ShipmentAddressDetails"];
                RadGridShipmentAddress.DataBind();
            }
        }

        #endregion
    }
}