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
using Telerik.Web.UI;
using System.Web.UI.HtmlControls;

namespace Indico
{
    public partial class AddEditIndimanInvoice : IndicoPage
    {
        #region Fields

        private int urlQueryID = -1;
        private int createdInvoiceId;
        private DateTime _weekendate = new DateTime(1100, 1, 1);
        private string weekNo = string.Empty;
        private int _distributorClientAddress = 0;
        private int _shipmentid = 0;
        private int urlWeeklyID = -1;
        private decimal totalamount = 0;
        //private decimal totalrate = 0;
        private int totalqty = 0;
        private decimal totalfactoryrate = 0;
        private int weekid = 0;
        private DateTime urlweekendate = new DateTime(1100, 1, 1);

        #endregion

        #region Properties

        public int CreatedInvoiceId
        {
            get
            {
                int createdInvoiceId = (ViewState["createdInvoiceId"] != null) ? int.Parse(ViewState["createdInvoiceId"].ToString()) : 0;
                //if()
                //{

                //}
                return createdInvoiceId;
            }
            set
            {
                ViewState["createdInvoiceId"] = value;
            }
        }

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["InvoiceSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "ID";
                }
                return sort;
            }
            set
            {
                ViewState["InvoiceSortExpression"] = value;
            }
        }

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

        protected DateTime WeekEndDate
        {
            get
            {
                if (_weekendate == new DateTime(1100, 1, 1) && ViewState["WeekEndDate"] != null)
                {
                    _weekendate = Convert.ToDateTime(ViewState["WeekEndDate"].ToString());
                }
                return _weekendate;
            }
        }

        protected string WeekNo
        {
            get
            {
                if (string.IsNullOrEmpty(weekNo))
                {
                    weekNo = ViewState["weekNo"].ToString();
                }

                return weekNo;
            }
        }

        protected int DistributorClientAddress
        {
            get
            {
                if (_distributorClientAddress == 0 && ViewState["DistributorClientAddress"] != null)
                {
                    _distributorClientAddress = int.Parse(ViewState["DistributorClientAddress"].ToString());
                }
                return _distributorClientAddress;
            }
        }

        protected int ShipmentModeID
        {
            get
            {
                if (_shipmentid == 0 && ViewState["ShipmentID"] != null)
                {
                    _shipmentid = int.Parse(ViewState["ShipmentID"].ToString());
                }
                return _shipmentid;
            }
        }

        protected int WeeklyCapacityID
        {
            get
            {
                if (urlWeeklyID > -1)
                    return urlWeeklyID;

                urlWeeklyID = 0;
                if (Request.QueryString["wid"] != null)
                {
                    urlWeeklyID = Convert.ToInt32(Request.QueryString["wid"].ToString());
                }
                return urlWeeklyID;
            }
        }

        protected DateTime WeeklyCapacityDate
        {
            get
            {
                if (urlweekendate != new DateTime(1100, 1, 1))
                    return urlweekendate;

                urlweekendate = new DateTime(1100, 1, 1);
                if (Request.QueryString["widdate"] != null)
                {
                    urlweekendate = Convert.ToDateTime(Request.QueryString["widdate"].ToString());
                }
                return urlweekendate;
            }
        }

        protected int WeekID
        {
            get
            {
                if (weekid == 0)
                {
                    weekid = int.Parse(ViewState["weekid"].ToString());
                }

                return weekid;
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

        protected void RadInvoice_ItemDataBound(object sender, GridItemEventArgs e)
        {
            //GridPagerItem item = (GridPagerItem)e.Item;

            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if ((item.ItemIndex > -1 && item.DataItem is ReturnInvoiceOrderDetailViewBO))
                {
                    ReturnInvoiceOrderDetailViewBO objInvoiceOrderDetailView = (ReturnInvoiceOrderDetailViewBO)item.DataItem;

                    //Label lblQty = (Label)item.FindControl("lblQty");
                    //lblQty.Text = objInvoiceOrderDetailView.Qty.ToString();

                    TextBox txtRate = (TextBox)item.FindControl("txtRate");
                    txtRate.Text = Convert.ToDecimal(objInvoiceOrderDetailView.FactoryRate.ToString()).ToString("0.00");
                    txtRate.Attributes.Add("orderdetail", objInvoiceOrderDetailView.OrderDetail.ToString());
                    txtRate.Attributes.Add("invoiceorder", objInvoiceOrderDetailView.InvoiceOrder.ToString());

                    Literal litRate = (Literal)item.FindControl("litRate");
                    litRate.Text = Convert.ToDecimal(objInvoiceOrderDetailView.FactoryRate.ToString()).ToString("0.00");
                    litRate.Visible = false;

                    decimal qty = Convert.ToDecimal(objInvoiceOrderDetailView.Qty.ToString());
                    decimal amount = 0;
                    decimal total = 0;

                    if (this.LoggedUserRoleName == UserRole.IndimanAdministrator)
                    {
                        litRate.Visible = true;
                        txtRate.Visible = false;
                        amount = Convert.ToDecimal(objInvoiceOrderDetailView.IndimanRate.ToString());
                        total = qty * amount;
                    }

                    totalamount = totalamount + total;
                    //totalrate = totalrate + amount;
                    totalqty = totalqty + (int)objInvoiceOrderDetailView.Qty;
                    totalfactoryrate = totalfactoryrate + (decimal)objInvoiceOrderDetailView.FactoryRate;



                    TextBox txtIndimanRate = (TextBox)item.FindControl("txtIndimanRate");
                    txtIndimanRate.Text = Convert.ToDecimal(objInvoiceOrderDetailView.IndimanRate.ToString()).ToString("0.00");

                    Label lblAmount = (Label)item.FindControl("lblAmount");
                    lblAmount.Text = total.ToString("0.00");

                    //HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    //linkDelete.Attributes.Add("indexid", item.ItemIndex.ToString());
                    //linkDelete.Attributes.Add("qid", objInvoiceOrderDetailView.InvoiceOrder.ToString());
                    //linkDelete.Attributes.Add("odid", objInvoiceOrderDetailView.OrderDetail.ToString());
                }
            }

            if (e.Item is GridFooterItem)
            {
                var item = e.Item as GridFooterItem;

                Label lblTotalAmount = (Label)item.FindControl("lblTotalAmount");
                lblTotalAmount.Text = totalamount.ToString("0.00");

                //Label lblTotalRate = (Label)item.FindControl("lblTotalRate");
                //lblTotalRate.Text = totalrate.ToString("0.00");

                //Label lblQty = (Label)item.FindControl("lblQty");
                //lblQty.Text = totalqty.ToString();

                Label lbltotalfactoryrate = (Label)item.FindControl("lbltotalfactoryrate");
                lbltotalfactoryrate.Text = totalfactoryrate.ToString("0.00");
                lbltotalfactoryrate.Visible = false;
            }
        }

        protected void RadInvoice_SortCommand(object sender, Telerik.Web.UI.GridSortCommandEventArgs e)
        {
            this.RebindGrid();
        }

        protected void RadInvoice_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.RebindGrid();
            }
        }

        protected void btnCreateInvoice_Click(object sender, EventArgs e)
        {

            if (Session["InvoiceOrderDetails"] == null)
            {
                CustomValidator cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "validateInvoice";
                cv.ErrorMessage = "No Shipment details have been added";
                Page.Validators.Add(cv);
            }

            if (Page.IsValid)
            {
                this.ProcessForm();
                Response.Redirect("/ViewIndimanInvoices.aspx");
            }
        }

        protected void cfvInvoiceNumber_Validate(object sender, ServerValidateEventArgs e)
        {
            if (!string.IsNullOrEmpty(txtInvoiceNo.Text))
            {
                List<InvoiceBO> lstInvoiceNo = new List<InvoiceBO>();
                lstInvoiceNo = (from o in (new InvoiceBO()).GetAllObject().ToList()
                                where o.InvoiceNo.ToLower().Trim() == txtInvoiceNo.Text.ToLower().Trim() && (o.ID != QueryID)
                                select o).ToList();

                e.IsValid = !(lstInvoiceNo.Count > 0);
            }
        }

        protected void cvIndimanInvoiceNo_ServerValidate(object source, ServerValidateEventArgs e)
        {
            if (!string.IsNullOrEmpty(txtIndimanInvoiceNo.Text))
            {
                List<InvoiceBO> lstInvoiceNo = new List<InvoiceBO>();
                lstInvoiceNo = (from o in (new InvoiceBO()).GetAllObject().ToList()
                                where (o.IndimanInvoiceNo != null) ? o.IndimanInvoiceNo.ToLower().Trim() == txtIndimanInvoiceNo.Text.ToLower().Trim() && (o.ID != QueryID) : false
                                select o).ToList();

                e.IsValid = !(lstInvoiceNo.Count > 0);
            }
        }

        protected void RadComboWeek_SelectedIndexChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
        {
            DateTime WeekendDate = DateTime.Parse(this.RadComboWeek.SelectedItem.Text);
            int id = int.Parse(this.RadComboWeek.SelectedValue);

            if (WeekendDate != null)
            {
                //this.PopulateShipmentDates(WeekendDate, id);
                this.PopulateInvoiceShipmentDates(WeekendDate, id);
            }

            this.ddlShipmentDates.Enabled = (WeekendDate != new DateTime(1100, 1, 1)) ? true : false;
        }

        protected void RadComboWeek_ItemDataBound(object sender, RadComboBoxItemEventArgs e)
        {
            RadComboBoxItem item = e.Item;

            if (item.Index > -1 && item.DataItem is WeeklyProductionCapacityBO)
            {
                WeeklyProductionCapacityBO objWeeklyProductionCapacity = (WeeklyProductionCapacityBO)item.DataItem;

                Literal litWeekNo = (Literal)item.FindControl("litWeekNo");
                litWeekNo.Text = objWeeklyProductionCapacity.WeekNo + "/" + objWeeklyProductionCapacity.WeekendDate.Year;

                Literal litETD = (Literal)item.FindControl("litETD");
                litETD.Text = objWeeklyProductionCapacity.WeekendDate.ToString("dd MMMM yyyy");

                item.Value = objWeeklyProductionCapacity.ID.ToString();
            }
        }

        protected void RadComboShipmentKey_ItemDataBound(object sender, RadComboBoxItemEventArgs e)
        {
            RadComboBoxItem item = e.Item;

            if (item.Index > -1 && item.DataItem is ReturnWeeklySummaryViewBO)
            {
                ReturnWeeklySummaryViewBO objWeeklySummaryView = (ReturnWeeklySummaryViewBO)item.DataItem;

                Literal litShipTo = (Literal)item.FindControl("litShipTo");
                litShipTo.Text = objWeeklySummaryView.CompanyName;

                Literal litWeek = (Literal)item.FindControl("litWeek");
                litWeek.Text = WeekNo;

                Literal litETD = (Literal)item.FindControl("litETD");
                litETD.Text = WeekEndDate.ToString("dd MMMM yyyy");

                Literal litMode = (Literal)item.FindControl("litMode");
                litMode.Text = objWeeklySummaryView.ShipmentMode;

                Literal litQty = (Literal)item.FindControl("litQty");
                litQty.Text = objWeeklySummaryView.Qty.ToString();

                item.Value = objWeeklySummaryView.DistributorClientAddress.ToString() + "," + objWeeklySummaryView.ShipmentModeID.ToString();
            }

        }

        protected void RadComboShipmentKey_SelectedIndexChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
        {
            int id = int.Parse(this.RadComboShipmentKey.SelectedValue.Split(',')[0]);
            int shipmentid = int.Parse(this.RadComboShipmentKey.SelectedValue.Split(',')[1]);

            if (id > 0 && shipmentid > 0)
            {
                ViewState["DistributorClientAddress"] = id;
                ViewState["ShipmentID"] = shipmentid;

                DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO();
                objDistributorClientAddress.ID = id;
                objDistributorClientAddress.GetObject();

                ShipmentModeBO objShipmentMode = new ShipmentModeBO();
                objShipmentMode.ID = shipmentid;
                objShipmentMode.GetObject();

                this.txtShipTo.Text = objDistributorClientAddress.CompanyName;
                this.txtShipmentMode.Text = objShipmentMode.Name;

                string state = (objDistributorClientAddress.State != null) ? objDistributorClientAddress.Suburb : string.Empty;

                this.lblShipmentKeyAddress.Text = objDistributorClientAddress.CompanyName + " , " + objDistributorClientAddress.Address + " , " + objDistributorClientAddress.Suburb + " " + state + " , " + objDistributorClientAddress.objCountry.ShortName + " , " + objDistributorClientAddress.PostCode;

                this.populateInvoiceOrders(0, id, true, shipmentid, false);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            //NNM
            int id = int.Parse(this.hdnSelectedID.Value);
            int indexid = int.Parse(this.hdnIndexID.Value);
            int orderdetail = int.Parse(this.hdnOrderDetail.Value);

            try
            {
                if (id > 0)
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        InvoiceOrderBO objInvoiceOrder = new InvoiceOrderBO(this.ObjContext);
                        objInvoiceOrder.ID = id;
                        objInvoiceOrder.GetObject();

                        objInvoiceOrder.Delete();

                        this.ObjContext.SaveChanges();
                        ts.Complete();

                    }
                    this.populateInvoiceOrders(this.QueryID, this.DistributorClientAddress, false, this.ShipmentModeID, false);
                }
                else
                {
                    if (indexid > -1)
                    {
                        List<ReturnInvoiceOrderDetailViewBO> lstInvoiceOrderDetailView = (List<ReturnInvoiceOrderDetailViewBO>)Session["InvoiceOrderDetails"];

                        lstInvoiceOrderDetailView.RemoveAt(indexid);

                        Session["InvoiceOrderDetails"] = lstInvoiceOrderDetailView;

                        this.RadInvoice.DataSource = lstInvoiceOrderDetailView;
                        this.RadInvoice.DataBind();

                    }
                }

                // changing the orderdetail shipment date and scheduled date and delete the packing list details
                //this.ChangeOrderDetails(orderdetail, id);

            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while deleting or removing order details from the AddEditInvoicePage.aspx", ex);
            }
        }

        protected void ddlShipmentDates_SelectedIndexChanged(object sender, EventArgs e)
        {
            //NNM
            DateTime ShipmentDate = DateTime.Parse(this.ddlShipmentDates.SelectedItem.Text);

            if (ShipmentDate != null)
            {
                this.PopulateShipmentKey(ShipmentDate);
            }

            this.RadComboShipmentKey.Enabled = (ShipmentDate != null) ? true : false;
        }

        protected void btnSaveShippingAddress_ServerClick(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                int id = 0;
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO(this.ObjContext);
                        if (id > 0)
                        {
                            objDistributorClientAddress.ID = id;
                            objDistributorClientAddress.GetObject();
                        }

                        objDistributorClientAddress.CompanyName = this.txtCOmpanyName.Text;
                        objDistributorClientAddress.Address = this.txtShipToAddress.Text;
                        objDistributorClientAddress.Suburb = this.txtSuburbCity.Text;
                        objDistributorClientAddress.State = this.txtShipToState.Text;
                        objDistributorClientAddress.PostCode = this.txtShipToPostCode.Text;
                        objDistributorClientAddress.ContactPhone = this.txtShipToPhone.Text;
                        objDistributorClientAddress.ContactName = this.txtShipToContactName.Text;
                        objDistributorClientAddress.Country = int.Parse(this.ddlShipToCountry.SelectedValue);
                        objDistributorClientAddress.Port = int.Parse(this.ddlShipToPort.SelectedValue);

                        this.ObjContext.SaveChanges();
                        ts.Complete();

                        id = objDistributorClientAddress.ID;
                    }

                    this.PopulateBillTo(id);
                    ViewState["PopulateShippingAddress"] = true;
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while Saving Distributor Client Address AddEditInvoice.aspx", ex);
                }
            }

            else
            {
                ViewState["PopulateShippingAddress"] = false;
            }

        }

        protected void cvBillTo_ServerValidate(object source, ServerValidateEventArgs e)
        {
            if (this.chkIsBillTo.Checked)
            {
                e.IsValid = (int.Parse(this.ddlBillTo.SelectedValue) > 0) ? true : false;
            }
        }

        protected void btnIndimanInvoice_Click(object sender, EventArgs e)
        {
            if (this.QueryID > 0)
            {
                try
                {
                    string pdfFilePath = Common.GenerateOdsPdf.GenerateIndimanInvoice(this.QueryID);

                    this.DownloadPDFFile(pdfFilePath);
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while printing Indiman Invoice from ViewInvoices.aspx", ex);
                }
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = ((this.QueryID > 0) ? "Edit " : "New ") + this.ActivePage.Heading;
            this.spanShipmentError.Visible = false;
            this.lblShipmentKeyAddress.Text = string.Empty;
            this.btnIndimanInvoice.Visible = (this.QueryID > 0) ? true : false;

            var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
            var monday = DateTime.Today.AddDays(-daysTillMonday);

            // populate RadComboWeek
            this.RadComboWeek.Items.Clear();
            List<WeeklyProductionCapacityBO> lstWeeklyCapacities;

            if (this.QueryID > 0)
            {
                lstWeeklyCapacities = (new WeeklyProductionCapacityBO()).SearchObjects().ToList();
            }
            else
            {
                lstWeeklyCapacities = (new WeeklyProductionCapacityBO()).SearchObjects().Where(o => o.WeekendDate >= DateTime.Now.AddMonths(-1) && o.WeekendDate.Year >= DateTime.Now.Year).ToList();

            }
            //List<WeeklyProductionCapacityBO> 
            this.RadComboWeek.DataSource = lstWeeklyCapacities;
            this.RadComboWeek.DataBind();

            // populate Invoice Status
            this.ddlStatus.Items.Clear();
            this.ddlStatus.Items.Add(new ListItem("Select a Status", "0"));
            List<InvoiceStatusBO> lstStatus = (new InvoiceStatusBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (InvoiceStatusBO ins in lstStatus)
            {
                this.ddlStatus.Items.Add(new ListItem(ins.Name, ins.ID.ToString()));
            }

            //populate Bank
            this.ddlBank.Items.Clear();
            this.ddlBank.Items.Add(new ListItem("Select a Bank", "0"));
            List<BankBO> lstBanks = (new BankBO()).GetAllObject();
            foreach (BankBO bank in lstBanks)
            {
                this.ddlBank.Items.Add(new ListItem(bank.Name + " - " + bank.AccountNo, bank.ID.ToString()));
            }

            //populate bill to
            this.PopulateBillTo();

            // populate Destination Port
            this.ddlShipToPort.Items.Clear();
            this.ddlShipToPort.Items.Add(new ListItem("Select Destination Port", "0"));
            List<DestinationPortBO> lstDestinationPort = (new DestinationPortBO()).GetAllObject();
            foreach (DestinationPortBO ds in lstDestinationPort)
            {
                this.ddlShipToPort.Items.Add(new ListItem(ds.Name, ds.ID.ToString()));
            }

            // Populate Country
            this.ddlShipToCountry.Items.Clear();
            this.ddlShipToCountry.Items.Add(new ListItem("Select Country", "0"));
            List<CountryBO> lstCountries = (new CountryBO()).GetAllObject().OrderBy(o => o.ShortName).ToList();
            foreach (CountryBO country in lstCountries)
            {
                this.ddlShipToCountry.Items.Add(new ListItem(country.ShortName, country.ID.ToString()));
            }

            Session["InvoiceOrderDetails"] = null;

            this.populateInvoiceOrders();

            if (this.QueryID > 0)
            {
                InvoiceBO objInvoice = new InvoiceBO();
                objInvoice.ID = this.QueryID;
                objInvoice.GetObject();

                this.RadComboWeek.Items.FindItemByValue(objInvoice.WeeklyProductionCapacity.ToString()).Selected = true;
                //this.PopulateShipmentDates(this.GetWeeklyProductionCapacityDetails(objInvoice.WeeklyProductionCapacity).WeekendDate, (int)objInvoice.WeeklyProductionCapacity);

                //this.PopulateShipmentDates(objInvoice.ShipmentDate, (int)objInvoice.WeeklyProductionCapacity);

                this.PopulateInvoiceShipmentDates(objInvoice.objWeeklyProductionCapacity.WeekendDate, (int)objInvoice.WeeklyProductionCapacity);

                this.ddlShipmentDates.Items.FindByText(objInvoice.ShipmentDate.ToString("dd MMMM yyyy")).Selected = true;
                this.PopulateShipmentKey(objInvoice.ShipmentDate);
                this.txtInvoiceDate.Text = objInvoice.InvoiceDate.ToString("dd MMMM yyyy");
                this.txtAwbNo.Text = objInvoice.AWBNo;
                this.txtShipTo.Text = objInvoice.objShipTo.CompanyName;
                this.txtShipmentMode.Text = objInvoice.objShipmentMode.Name;
                this.RadComboShipmentKey.Enabled = false;
                this.txtInvoiceNo.Text = objInvoice.InvoiceNo;
                this.txtIndimanInvoiceNo.Text = objInvoice.IndimanInvoiceNo;
                this.ddlStatus.Items.FindByValue(objInvoice.Status.ToString()).Selected = true;
                this.chkIsBillTo.Checked = (bool)objInvoice.IsBillTo;
                this.ddlBillTo.Items.FindByValue(objInvoice.BillTo.ToString()).Selected = true;
                this.ddlBank.Items.FindByValue(objInvoice.Bank.ToString()).Selected = true;

                ViewState["DistributorClientAddress"] = objInvoice.ShipTo;
                ViewState["ShipmentID"] = objInvoice.ShipmentMode;

                DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO();
                objDistributorClientAddress.ID = objInvoice.ShipTo;
                objDistributorClientAddress.GetObject();

                string state = (objDistributorClientAddress.State != null) ? objDistributorClientAddress.Suburb : string.Empty;

                this.lblShipmentKeyAddress.Text = objDistributorClientAddress.CompanyName + " , " + objDistributorClientAddress.Address + " , " + objDistributorClientAddress.Suburb + " " + state + " , " + objDistributorClientAddress.objCountry.ShortName + " , " + objDistributorClientAddress.PostCode;

                //is logged user role Factory Admin or Coordinator
                RadInvoice.Columns[13].Visible = false;
                this.populateInvoiceOrders(this.QueryID, objInvoice.ShipTo, false, objInvoice.ShipmentMode, false);
            }

            // if Redirect From WeeklySummary Page
            if (this.WeeklyCapacityDate != new DateTime(1100, 1, 1))
            {
                this.RadComboWeek.Items.FindItemByValue(this.WeeklyCapacityID.ToString()).Selected = true;
                // this.PopulateShipmentKey(this.WeeklyCapacityID);
                this.PopulateShipmentDates(this.WeeklyCapacityDate, this.WeeklyCapacityID);
            }
        }

        private void ProcessForm()
        {
            //NNM
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    #region Create InvoiceHeader

                    InvoiceBO objInvoice = new InvoiceBO(this.ObjContext);
                    if (QueryID > 0)
                    {
                        objInvoice.ID = this.QueryID;
                        objInvoice.GetObject();
                    }
                    else
                    {
                        objInvoice.Creator = this.LoggedUser.ID;
                        objInvoice.CreatedDate = DateTime.Now;
                    }
                    objInvoice.InvoiceNo = this.txtInvoiceNo.Text;
                    objInvoice.InvoiceDate = Convert.ToDateTime(this.txtInvoiceDate.Text);
                    objInvoice.ShipTo = this.DistributorClientAddress;
                    objInvoice.AWBNo = this.txtAwbNo.Text;
                    objInvoice.WeeklyProductionCapacity = int.Parse(this.RadComboWeek.SelectedValue);
                    objInvoice.ShipmentMode = this.ShipmentModeID;
                    objInvoice.IndimanInvoiceNo = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? this.txtIndimanInvoiceNo.Text : string.Empty;
                    objInvoice.IsBillTo = this.chkIsBillTo.Checked;
                    objInvoice.BillTo = (this.chkIsBillTo.Checked) ? int.Parse(this.ddlBillTo.SelectedValue) : 22;
                    objInvoice.Bank = int.Parse(this.ddlBank.SelectedValue);

                    if (this.LoggedUserRoleName == UserRole.IndimanAdministrator)
                    {
                        objInvoice.IndimanInvoiceDate = Convert.ToDateTime(this.txtIndimanInvoiceDate.Text);
                    }

                    objInvoice.Modifier = this.LoggedUser.ID;
                    objInvoice.ModifiedDate = DateTime.Now;

                    this.ObjContext.SaveChanges();

                    ViewState["InvoiceId"] = objInvoice.ID;

                    #endregion

                    #region InvoiceOrderDetail

                    foreach (GridDataItem item in RadInvoice.Items)
                    {
                        TextBox txtRate = (TextBox)item.FindControl("txtRate");
                        int id = int.Parse(((System.Web.UI.WebControls.WebControl)(txtRate)).Attributes["invoiceorder"].ToString());
                        int orderdetail = int.Parse(((System.Web.UI.WebControls.WebControl)(txtRate)).Attributes["orderdetail"].ToString());

                        TextBox txtIndimanRate = (TextBox)item.FindControl("txtIndimanRate");

                        InvoiceOrderBO objInvoiceOrder = new InvoiceOrderBO(this.ObjContext);
                        if (id > 0)
                        {
                            objInvoiceOrder.ID = id;
                            objInvoiceOrder.GetObject();
                        }

                        objInvoiceOrder.Invoice = int.Parse(ViewState["InvoiceId"].ToString());
                        objInvoiceOrder.OrderDetail = orderdetail;
                        objInvoiceOrder.FactoryPrice = Convert.ToDecimal(txtRate.Text);
                        objInvoiceOrder.IndimanPrice = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? Convert.ToDecimal(txtIndimanRate.Text) : Convert.ToDecimal("0");

                    }
                    this.ObjContext.SaveChanges();

                    #endregion

                    #region Change Order Detail Status

                    List<int> lstOrders = new List<int>();
                    int orderid = 0;

                    if (this.ddlStatus.SelectedItem.Text == "Shipped")
                    {
                        foreach (GridDataItem item in RadInvoice.Items)
                        {
                            TextBox txtRate = (TextBox)item.FindControl("txtRate");
                            int orderdetail = int.Parse(((System.Web.UI.WebControls.WebControl)(txtRate)).Attributes["orderdetail"].ToString());

                            OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                            objOrderDetail.ID = orderdetail;
                            objOrderDetail.GetObject();

                            if (objOrderDetail.Order != orderid)
                            {
                                lstOrders.Add(objOrderDetail.Order);
                                orderid = objOrderDetail.Order;
                            }

                            objOrderDetail.Status = 16;
                        }

                        this.ObjContext.SaveChanges();
                    }

                    #endregion

                    #region Change Order Status

                    if (lstOrders.Count > 0)
                    {
                        foreach (int order in lstOrders)
                        {
                            OrderBO objOrder = new OrderBO(this.ObjContext);
                            objOrder.ID = order;
                            objOrder.GetObject();

                            objOrder.Status = 21;
                        }

                        this.ObjContext.SaveChanges();
                    }

                    #endregion

                    ts.Complete();
                }

            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Adding or Updating Invoicing", ex);
            }
        }

        private void populateInvoiceOrders(int invoice = 0, int distributorclientaddress = 0, bool isNew = true, int shipmentid = 0, bool isPopulate = true)
        {
            if (isPopulate)
            {
                this.RadInvoice.Visible = false;
            }
            else
            {
                List<ReturnInvoiceOrderDetailViewBO> lstInvoiceOrderDetails = new List<ReturnInvoiceOrderDetailViewBO>();

                lstInvoiceOrderDetails = InvoiceBO.InvoiceOrderDetailView(invoice, distributorclientaddress, isNew, DateTime.Parse(this.ddlShipmentDates.SelectedValue), shipmentid);

                if (lstInvoiceOrderDetails.Count > 0)
                {
                    this.RadInvoice.DataSource = lstInvoiceOrderDetails;
                    this.RadInvoice.DataBind();
                    this.dvEmptyContentInvoiceOrders.Visible = false;
                    this.RadInvoice.Visible = true;

                    Session["InvoiceOrderDetails"] = lstInvoiceOrderDetails;
                }
                else
                {
                    this.RadInvoice.Visible = false;
                    this.dvEmptyContentInvoiceOrders.Visible = true;
                }
            }


        }

        private void PopulateShipmentKey(DateTime ShipmentDate)
        {
            List<ReturnWeeklySummaryViewBO> lstWeeklySummary = new List<ReturnWeeklySummaryViewBO>();
            List<ReturnWeeklySummaryViewBO> lst = new List<ReturnWeeklySummaryViewBO>();
            lst = OrderDetailBO.GetWeekSummary(ShipmentDate, true);

            List<int> lstshipmentID = (new InvoiceBO()).SearchObjects().Where(o => o.WeeklyProductionCapacity == WeekID).Select(o => o.ShipTo).ToList();

            List<int> lstShipTo = lst.Select(o => (int)o.DistributorClientAddress).ToList();

            List<int> lstShipmentKeyID = lstShipTo.Except(lstshipmentID).ToList();

            if (this.QueryID == 0)
            {
                if (lst.Count > 0)
                {
                    if (lstShipmentKeyID.Count > 0)
                    {
                        foreach (int ShipmentKey in lstShipmentKeyID)
                        {
                            lstWeeklySummary.AddRange(lst.Where(o => o.DistributorClientAddress == ShipmentKey).ToList());
                        }
                    }
                    else
                    {
                        lstWeeklySummary = lst;
                    }
                }
                else
                {
                    this.spanShipmentError.InnerText = "No shipments for this Week";
                    this.spanShipmentError.Visible = true;
                }
            }
            else
            {
                List<InvoiceBO> lstshipments = (new InvoiceBO()).SearchObjects().Where(o => o.WeeklyProductionCapacity == WeekID).ToList();

                foreach (InvoiceBO item in lstshipments.Where(o => o.ID == this.QueryID))
                {
                    lstWeeklySummary.AddRange(lst.Where(o => o.DistributorClientAddress == item.ShipTo && o.ShipmentModeID == item.ShipmentMode).ToList());
                }
            }

            if (lstWeeklySummary.Count > 0)
            {
                this.RadComboShipmentKey.Items.Clear();

                this.RadComboShipmentKey.DataSource = lstWeeklySummary;
                this.RadComboShipmentKey.DataBind();
            }
            else
            {
                //this.spanShipmentError.Visible = true;
            }
        }

        private void RebindGrid()
        {
            if (Session["InvoiceOrderDetails"] != null)
            {
                RadInvoice.DataSource = (List<ReturnInvoiceOrderDetailViewBO>)Session["InvoiceOrderDetails"];
                RadInvoice.DataBind();
            }
        }

        private void ChangeOrderDetails(int orderdetail, int invoiceorder)
        {
            try
            {
                if (orderdetail > 0)
                {
                    InvoiceOrderBO objInvoiceOrder = new InvoiceOrderBO(this.ObjContext);
                    objInvoiceOrder.ID = invoiceorder;
                    objInvoiceOrder.GetObject();

                    DateTime nextmonday = objInvoiceOrder.objOrderDetail.SheduledDate.AddDays(7 - objInvoiceOrder.objOrderDetail.SheduledDate.DayOfWeek == DayOfWeek.Monday ? 7 : (int)objInvoiceOrder.objOrderDetail.SheduledDate.DayOfWeek);

                    using (TransactionScope ts = new TransactionScope())
                    {
                        PackingListBO objPList = new PackingListBO();
                        objPList.OrderDetail = orderdetail;

                        List<PackingListBO> lstPackingLists = objPList.SearchObjects();

                        foreach (PackingListBO objpl in lstPackingLists)
                        {
                            PackingListSizeQtyBO objPlsq = new PackingListSizeQtyBO();
                            objPlsq.PackingList = objpl.ID;
                            List<PackingListSizeQtyBO> lstPackingListSizeQty = objPlsq.SearchObjects();

                            // delete the PackingListSizeQtyBO details
                            foreach (PackingListSizeQtyBO objplsqi in lstPackingListSizeQty)
                            {
                                PackingListSizeQtyBO objPackingListSizeQtyItem = new PackingListSizeQtyBO(this.ObjContext);
                                objPackingListSizeQtyItem.ID = objplsqi.ID;
                                objPackingListSizeQtyItem.GetObject();

                                objPackingListSizeQtyItem.Delete();
                            }

                            //this.ObjContext.SaveChanges();

                            PackingListCartonItemBO objPLCI = new PackingListCartonItemBO();
                            objPLCI.PackingList = objpl.ID;
                            List<PackingListCartonItemBO> lstPackingListCartonItems = objPLCI.SearchObjects();

                            // delete the PackingListCartonItemBO details
                            foreach (PackingListCartonItemBO objplci in lstPackingListCartonItems)
                            {
                                PackingListCartonItemBO objPackingListCartonItem = new PackingListCartonItemBO(this.ObjContext);
                                objPackingListCartonItem.ID = objplci.ID;
                                objPackingListCartonItem.GetObject();

                                objPackingListCartonItem.Delete();
                            }

                            //this.ObjContext.SaveChanges();

                            // delete the PackingListBO details

                            PackingListBO objPackingList = new PackingListBO(this.ObjContext);
                            objPackingList.ID = objpl.ID;
                            objPackingList.GetObject();

                            objPackingList.Delete();

                        }

                        //Creating new packing list record for next week
                        List<WeeklyProductionCapacityBO> lstwpc = (new WeeklyProductionCapacityBO()).SearchObjects().Where(o => o.WeekendDate >= nextmonday && o.WeekendDate <= nextmonday.AddDays(7)).ToList();

                        PackingListBO objp = new PackingListBO();
                        objp.WeeklyProductionCapacity = lstwpc[0].ID;

                        List<PackingListBO> lst = objp.SearchObjects();

                        if (lst.Count > 0)
                        {
                            PackingListBO objNewPl = new PackingListBO(this.ObjContext);
                            objNewPl.Carton = 1;
                            objNewPl.CartonNo = 0;
                            objNewPl.CreatedDate = objNewPl.ModifiedDate = DateTime.Now;
                            objNewPl.Creator = objNewPl.Modifier = this.LoggedUser.ID;
                            objNewPl.OrderDetail = orderdetail;
                            objNewPl.WeeklyProductionCapacity = lstwpc[0].ID;
                            objNewPl.PackingQty = 0;

                            this.ObjContext.SaveChanges();

                            int Newplid = objNewPl.ID;

                            OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                            objOrderDetailqty.OrderDetail = orderdetail;

                            List<OrderDetailQtyBO> lstOrderDetailsQty = objOrderDetailqty.SearchObjects();

                            foreach (OrderDetailQtyBO objOdq in lstOrderDetailsQty)
                            {
                                if (objOdq.Qty > 0)
                                {
                                    PackingListSizeQtyBO objPackingListSizeQty = new PackingListSizeQtyBO(this.ObjContext);
                                    objPackingListSizeQty.PackingList = Newplid;
                                    objPackingListSizeQty.Size = objOdq.Size;
                                }
                            }
                        }
                        //this.ObjContext.SaveChanges();

                        //change the shipment date, scheduled date
                        OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                        objOrderDetail.ID = orderdetail;
                        objOrderDetail.GetObject();

                        objOrderDetail.SheduledDate = nextmonday;
                        objOrderDetail.ShipmentDate = nextmonday;

                        this.ObjContext.SaveChanges();

                        ts.Complete();
                    }
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while deleting or adding packing list details and changing the shipment date and scheduled date from the AddEditInvoce.aspx", ex);
            }
        }

        private void PopulateShipmentDates(DateTime WeekendDate, int id = 0)
        {
            ViewState["WeekEndDate"] = this.GetWeeklyProductionCapacityDetails(id).WeekendDate;
            ViewState["weekNo"] = this.GetWeeklyProductionCapacityDetails(id).WeekNo + "/" + this.GetWeeklyProductionCapacityDetails(id).WeekendDate.Year;
            ViewState["weekid"] = id;

            List<ReturnShipmentDatesViewBO> lstShipmentDates = new List<ReturnShipmentDatesViewBO>();

            lstShipmentDates = InvoiceBO.GetShipmentDates(WeekendDate);

            this.ddlShipmentDates.Items.Clear();
            this.ddlShipmentDates.Items.Add(new ListItem("Select a Shipment Date"));
            foreach (ReturnShipmentDatesViewBO shipdates in lstShipmentDates)
            {
                this.ddlShipmentDates.Items.Add(new ListItem(Convert.ToDateTime(shipdates.ShipmentDate.ToString()).ToString("dd MMMM yyyy")));
            }
        }

        private void PopulateInvoiceShipmentDates(DateTime WeekendDate, int id = 0)
        {
            ViewState["WeekEndDate"] = this.GetWeeklyProductionCapacityDetails(id).WeekendDate;
            ViewState["weekNo"] = this.GetWeeklyProductionCapacityDetails(id).WeekNo + "/" + this.GetWeeklyProductionCapacityDetails(id).WeekendDate.Year;
            ViewState["weekid"] = id;

            List<DateTime> lstDates = new List<DateTime>();

            for (int i = 0; i < 5; i++)
            {
                lstDates.Add(WeekendDate.AddDays(-i));
            }

            this.ddlShipmentDates.Items.Clear();
            this.ddlShipmentDates.Items.Add(new ListItem("Select a Shipment Date"));
            foreach (DateTime shipdates in lstDates)
            {
                this.ddlShipmentDates.Items.Add(new ListItem(Convert.ToDateTime(shipdates.ToString()).ToString("dd MMMM yyyy")));
            }
        }

        private WeeklyProductionCapacityBO GetWeeklyProductionCapacityDetails(int id)
        {
            WeeklyProductionCapacityBO objWeeklyProduntionCapacity = new WeeklyProductionCapacityBO();
            objWeeklyProduntionCapacity.ID = id;
            objWeeklyProduntionCapacity.GetObject();

            return objWeeklyProduntionCapacity;
        }

        private void PopulateBillTo(int id = 0)
        {
            //populate Bill To
            this.ddlBillTo.Items.Clear();
            this.ddlBillTo.Items.Add(new ListItem("Select a Bill To", "0"));
            List<DistributorClientAddressBO> lstDistributorClientAddress = (new DistributorClientAddressBO()).GetAllObject();
            foreach (DistributorClientAddressBO dca in lstDistributorClientAddress)
            {
                this.ddlBillTo.Items.Add(new ListItem(dca.CompanyName, dca.ID.ToString()));
            }

            if (id > 0)
            {
                this.ddlBillTo.Items.FindByValue(id.ToString()).Selected = true;
            }
        }

        #endregion
    }
}