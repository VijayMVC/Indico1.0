using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Transactions;
using System.Web.UI.WebControls;
using Dapper;
using Indico.BusinessObjects;
using Indico.Common;
using Telerik.Web.UI;

using Indico.Models;
using Indico.Common.Extensions;

namespace Indico
{
    public partial class AddEditInvoice : IndicoPage
    {
        #region Fields

        private IDbConnection _connection = GetIndicoConnnection();
        DateTime _exdate;
        private int _urlQueryID = -1;
        private DateTime _weekendate = new DateTime(1100, 1, 1);
        private string _weekNo = string.Empty;
        private int _distributorClientAddress = 0;
        private int _shipmentid = 0;
        private int _urlWeeklyID = -1;
        private int _weekid = 0;
        private DateTime _urlweekendate = new DateTime(1100, 1, 1);
        private DateTime _urlshipmentate = new DateTime(1100, 1, 1);
        private int _urlshipmentkey = -1;
        private string _urlinvoiceno = string.Empty;
        private int _urlshipmentmode = -1;
        private int _costsheet = -1;
        private DateTime _startdate;

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
                if (_urlQueryID > -1)
                    return _urlQueryID;

                _urlQueryID = 0;
                if (Request.QueryString["id"] != null)
                {
                    _urlQueryID = Convert.ToInt32(Request.QueryString["id"].ToString());
                }
                return _urlQueryID;
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
                if (string.IsNullOrEmpty(_weekNo))
                {
                    _weekNo = ViewState["weekNo"].ToString();
                }

                return _weekNo;
            }
        }

        protected int WeekID
        {
            get
            {
                if (_weekid == 0)
                {
                    _weekid = int.Parse(ViewState["weekid"].ToString());
                }

                return _weekid;
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
                if (_urlWeeklyID > -1)
                    return _urlWeeklyID;

                _urlWeeklyID = 0;
                if (Request.QueryString["wid"] != null)
                {
                    _urlWeeklyID = Convert.ToInt32(Request.QueryString["wid"].ToString());
                }
                return _urlWeeklyID;
            }
        }

        protected DateTime WeeklyCapacityDate
        {
            get
            {
                if (_urlweekendate != new DateTime(1100, 1, 1))
                    return _urlweekendate;

                _urlweekendate = new DateTime(1100, 1, 1);
                if (Request.QueryString["widdate"] != null)
                {
                    _urlweekendate = Convert.ToDateTime(Request.QueryString["widdate"].ToString());
                }
                return _urlweekendate;
            }
        }

        protected DateTime ShipmentDate
        {
            get
            {
                if (_urlshipmentate != new DateTime(1100, 1, 1))
                    return _urlshipmentate;

                _urlshipmentate = new DateTime(1100, 1, 1);
                if (Request.QueryString["sdate"] != null)
                {
                    _urlshipmentate = Convert.ToDateTime(Request.QueryString["sdate"].ToString());
                }
                return _urlshipmentate;
            }
        }

        protected int ShipmentKey
        {
            get
            {
                if (_urlshipmentkey > -1)
                    return _urlshipmentkey;

                _urlshipmentkey = 0;
                if (Request.QueryString["smkey"] != null)
                {
                    _urlshipmentkey = Convert.ToInt32(Request.QueryString["smkey"].ToString());
                }
                return _urlshipmentkey;
            }
        }

        protected string InvoiceNo
        {
            get
            {
                if (!string.IsNullOrEmpty(_urlinvoiceno))
                    return _urlinvoiceno;

                _urlinvoiceno = string.Empty;
                if (Request.QueryString["invno"] != null)
                {
                    _urlinvoiceno = Request.QueryString["invno"].ToString();
                }
                return _urlinvoiceno;
            }
        }

        protected int ShipmentMode
        {
            get
            {
                if (_urlshipmentmode > -1)
                    return _urlshipmentmode;

                _urlshipmentmode = 0;
                if (Request.QueryString["smid"] != null)
                {
                    _urlshipmentmode = Convert.ToInt32(Request.QueryString["smid"].ToString());
                }
                return _urlshipmentmode;
            }
        }

        protected int CostSheet
        {
            get
            {
                if (_costsheet > -1)
                    return _costsheet;

                _costsheet = 0;
                if (Request.QueryString["csid"] != null)
                {
                    _costsheet = Convert.ToInt32(Request.QueryString["csid"].ToString());
                }
                return _costsheet;
            }
        }

        #endregion

        #region Constructors

        #endregion

        #region Events

       

        protected void Page_PreRender(object sender, EventArgs e)
        {
            Session["IsPostBack"] = Server.UrlEncode(Guid.NewGuid().ToString());
            ViewState["IsPostBack"] = Session["IsPostBack"];
        }

       





        protected void RadInvoice_ItemDataBound(object sender, GridItemEventArgs e)
        {
            //GridPagerItem item = (GridPagerItem)e.Item;
            /*
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if ((item.ItemIndex > -1 && item.DataItem is ReturnInvoiceOrderDetailViewBO))
                {
                    
                    ReturnInvoiceOrderDetailViewBO objInvoiceOrderDetailView = (ReturnInvoiceOrderDetailViewBO)item.DataItem;

                    Label lblQty = (Label)item.FindControl("lblQty");
                    lblQty.Text = objInvoiceOrderDetailView.Qty.ToString();

                    TextBox txtRate = (TextBox)item.FindControl("txtRate");
                    txtRate.Text = Convert.ToDecimal(objInvoiceOrderDetailView.FactoryRate.ToString()).ToString("0.00");
                    txtRate.Attributes.Add("orderdetail", objInvoiceOrderDetailView.OrderDetail.ToString());
                    txtRate.Attributes.Add("invoiceorder", objInvoiceOrderDetailView.InvoiceOrder.ToString());

                    HiddenField hdnOrderDetail = (HiddenField)item.FindControl("hdnOrderDetail");
                    hdnOrderDetail.Value = objInvoiceOrderDetailView.OrderDetail.ToString();

                    decimal qty = Convert.ToDecimal(objInvoiceOrderDetailView.Qty.ToString());
                    decimal amount = 0;
                    decimal total = 0;

                    amount = Convert.ToDecimal(objInvoiceOrderDetailView.FactoryRate.ToString());
                    total = qty * amount;
                    totalamount = totalamount + total;
                    // totalrate = totalrate + amount;
                    totalqty = totalqty + (int)objInvoiceOrderDetailView.Qty;


                    Label lblAmount = (Label)item.FindControl("lblAmount");
                    lblAmount.Text = total.ToString("0.00");

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("indexid", item.ItemIndex.ToString());
                    linkDelete.Attributes.Add("qid", objInvoiceOrderDetailView.InvoiceOrder.ToString());
                    linkDelete.Attributes.Add("odid", objInvoiceOrderDetailView.OrderDetail.ToString());

                    LinkButton lbCostSheet = (LinkButton)item.FindControl("lbCostSheet");
                    lbCostSheet.Attributes.Add("csid", objInvoiceOrderDetailView.CostSheet.ToString());
                    lbCostSheet.Attributes.Add("patid", objInvoiceOrderDetailView.PatternID.ToString());
                    lbCostSheet.Attributes.Add("fabid", objInvoiceOrderDetailView.FabricID.ToString());
                    lbCostSheet.Attributes.Add("invo", objInvoiceOrderDetailView.InvoiceOrder.ToString());
                    //linkCostSheet.NavigateUrl = (objInvoiceOrderDetailView.CostSheet > 0) ? "AddEditFactoryCostSheet.aspx?id=" + objInvoiceOrderDetailView.CostSheet : "AddEditFactoryCostSheet.aspx?pat=" + objInvoiceOrderDetailView.PatternID.ToString() + "&fab=" + objInvoiceOrderDetailView.FabricID.ToString();
                    lbCostSheet.Text = (objInvoiceOrderDetailView.CostSheet > 0) ? "View Cost Sheet" : "Create Cost Sheet";
                    lbCostSheet.ToolTip = (objInvoiceOrderDetailView.CostSheet > 0) ? "View Cost Sheet" : "Create Cost Sheet";
                }
            }

            if (e.Item is GridFooterItem)
            {
                var item = e.Item as GridFooterItem;

                Label lblTotalAmount = (Label)item.FindControl("lblTotalAmount");
                lblTotalAmount.Text = totalamount.ToString("0.00");

                 Label lblTotalRate = (Label)item.FindControl("lblTotalRate");
                  lblTotalRate.Text = totalrate.ToString("0.00");

                Label lblQty = (Label)item.FindControl("lblQty");
                lblQty.Text = totalqty.ToString();
            }
            */

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

        //protected void btnCreateInvoice_Click(object sender, EventArgs e)
        //{
        //    if (Session["InvoiceOrderDetails"] == null)
        //    {
        //        CustomValidator cv = new CustomValidator();
        //        cv.IsValid = false;
        //        cv.ValidationGroup = "validateInvoice";
        //        cv.ErrorMessage = "No Shipment details have been added";
        //        Page.Validators.Add(cv);
        //    }

        //    if (Page.IsValid)
        //    {
        //        this.ProcessForm();
        //        Response.Redirect("/ViewInvoices.aspx");
        //    }
        //}

        protected void cfvInvoiceNumber_Validate(object sender, ServerValidateEventArgs e)
        {
            if (!string.IsNullOrEmpty(txtInvoiceNo.Text))
            {
                //List<InvoiceBO> lstInvoiceNo = new List<InvoiceBO>();

                //int id = (QueryID > 0) ? this.QueryID : CreatedInvoiceId;

                //lstInvoiceNo = (from o in (new InvoiceBO()).GetAllObject().ToList()
                //                where o.InvoiceNo.ToLower().Trim() == txtInvoiceNo.Text.ToLower().Trim() && (o.ID != id)
                //                select o).ToList();

                //e.IsValid = !(lstInvoiceNo.Count > 0);

                try
                {
                    int id = (QueryID > 0) ? this.QueryID : CreatedInvoiceId;
                    ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                    objReturnInt = SettingsBO.ValidateField(id, "Invoice", "InvoiceNo", this.txtInvoiceNo.Text);
                    e.IsValid = objReturnInt.RetVal == 1;
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on AddEditInvoice.aspx", ex);
                }
            }
        }



        protected void OnWeekDataBound(object sender, RadComboBoxItemEventArgs e)
        {
            var item = e.Item;
            if (item.Index > -1 && item.DataItem is WeekNoWeekendDateModel)
            {
                var @object = (WeekNoWeekendDateModel)item.DataItem;

                var weekNoLiteral = GetControl<Literal>(item, "litWeekNo");
                weekNoLiteral.Text = @object.WeekNo.ToString();

                var litEtd = GetControl<Literal>(item, "litETD");
                litEtd.Text = @object.WeekendDate.ToString("dd MMMM yyyy");
            }
        }

        protected void RadComboShipmentKey_ItemDataBound(object sender, RadComboBoxItemEventArgs e)
        {
            var item = e.Item;

            if (item.Index > -1 && item.DataItem is ShipmentkeyModel)
            {
                var shipmentKey = (ShipmentkeyModel)item.DataItem;

                var litShipTo = GetControl<Literal>(item, "litShipTo");
                litShipTo.Text = shipmentKey.ShipTo;

                var litWeek = GetControl<Literal>(item, "litDestinationPort");
                litWeek.Text = shipmentKey.DestinationPort;

                var litetd = GetControl<Literal>(item, "litETD");
                litetd.Text = shipmentKey.ShipmentDate.ToString("dd MMMM yyyy");

                var litPriceTerm = GetControl<Literal>(item, "litPriceTerm");
                litPriceTerm.Text = shipmentKey.PriceTerm;

                var quantityLiteral = GetControl<Literal>(item, "litQty");
                quantityLiteral.Text = shipmentKey.Qty.ToString();
            }

        }

        //protected void RadComboShipmentKey_SelectedIndexChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
        //{
        //    int id = int.Parse(this.RadComboShipmentKey.SelectedValue.Split(',')[0]);
        //    int shipmentid = int.Parse(this.RadComboShipmentKey.SelectedValue.Split(',')[1]);

        //    if (id > 0 && shipmentid > 0)
        //    {
        //        ViewState["DistributorClientAddress"] = id;
        //        ViewState["ShipmentID"] = shipmentid;
        //        DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO();
        //        objDistributorClientAddress.ID = id;
        //        objDistributorClientAddress.GetObject();

        //        ShipmentModeBO objShipmentMode = new ShipmentModeBO();
        //        objShipmentMode.ID = shipmentid;
        //        objShipmentMode.GetObject();

        //        //this.txtShipTo.Text = objDistributorClientAddress.CompanyName;
        //        this.ShipmentModeDropDownList.Text = objShipmentMode.Name;

        //        string state = (objDistributorClientAddress.State != null) ? objDistributorClientAddress.Suburb : string.Empty;

        //        this.lblShipmentKeyAddress.Text = objDistributorClientAddress.CompanyName + " , " + objDistributorClientAddress.Address + " , " + objDistributorClientAddress.Suburb + " , " + state + " , " + objDistributorClientAddress.objCountry.ShortName + " , " + objDistributorClientAddress.PostCode;


        //        this.populateInvoiceOrders(0, id, true, shipmentid, false, id, true);


        //    }
        //}

    protected void btnDelete_Click(object sender, EventArgs e)
        {
            //NNM
            int id = int.Parse(this.hdnSelectedID.Value);
            int indexid = int.Parse(this.hdnIndexID.Value);


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
                        List<ReturnInvoiceOrderDetailViewBO> lstNotInvoiceOrderDetail = new List<ReturnInvoiceOrderDetailViewBO>();

                        #region Add

                        //lstNotInvoiceOrderDetail.AddRange(lstInvoiceOrderDetailView.Where(o => o.OrderDetail == orderdetail).ToList());

                        Session["NotInvoiceOrderDetails"] = lstNotInvoiceOrderDetail;

                        this.PopulateNotExistingOrderGrid(lstNotInvoiceOrderDetail);

                        #endregion

                        #region Remove

                        lstInvoiceOrderDetailView.RemoveAt(indexid);

                        Session["InvoiceOrderDetails"] = lstInvoiceOrderDetailView;

                        this.PopulateInvoiceOrderGrid(lstInvoiceOrderDetailView);

                        #endregion
                    }
                }

                // changing the orderdetail shipment date and scheduled date and delete the packing list details
                //this.ChangeOrderDetails(orderdetail, id); // NNM ()

            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while deleting or removing order details from the AddEditInvoicePage.aspx", ex);
            }
        }
        /*
        protected void ddlShipmentDates_SelectedIndexChanged(object sender, EventArgs e)
        {
            DateTime ShipmentDate = DateTime.Parse(this.ddlShipmentDates.SelectedItem.Text);

            if (ShipmentDate != null)
            {
                this.PopulateShipmentKey(ShipmentDate);
            }

            this.RadComboShipmentKey.Enabled = (ShipmentDate != null) ? true : false;
        }
        */
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
                        //objDistributorClientAddress.Client = int.Parse(this.ddlDistributor.SelectedValue);

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

        //TODO Remove
        //protected void cvBillTo_ServerValidate(object source, ServerValidateEventArgs e)
        //{
        //    if (this.chkIsBillTo.Checked)
        //    {
        //        e.IsValid = (int.Parse(this.BillToDropDownList.SelectedValue) > 0) ? true : false;
        //    }
        //}

        protected void btnFactoryDetail_Click(object sender, EventArgs e)
        {
            if (this.QueryID > 0)
            {
                try
                {
                    string pdfFilePath = Common.GenerateOdsPdf.GenerateJKInvoiceDetail(this.QueryID);

                    this.DownloadPDFFile(pdfFilePath);
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while printing JKInvoiceOrderDetail from AddEditInvoice.aspx", ex);
                }
            }
        }

        protected void btnInvoiceSummary_Click(object sender, EventArgs e)
        {
            if (this.QueryID > 0)
            {
                try
                {
                    string pdfFilePath = Common.GenerateOdsPdf.GenerateJKInvoiceSummary(this.QueryID);

                    this.DownloadPDFFile(pdfFilePath);
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while printing JKInvoiceSummary from AddEditInvoice.aspx", ex);
                }
            }
        }

        protected void dgNotExistingInvoiceOrders_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            var item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is ReturnInvoiceOrderDetailViewBO)
            {
                ReturnInvoiceOrderDetailViewBO objInvoiceOrderDetailView = (ReturnInvoiceOrderDetailViewBO)item.DataItem;

                Literal litQty = (Literal)item.FindControl("litQty");
                litQty.Text = objInvoiceOrderDetailView.Qty.ToString();

                LinkButton lbAdd = (LinkButton)item.FindControl("lbAdd");
                lbAdd.Attributes.Add("oid", objInvoiceOrderDetailView.OrderDetail.ToString());
            }
        }

        protected void lbAdd_Click(object sender, EventArgs e)
        {
            int odid = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["oid"].ToString());

            if (odid > 0)
            {
                List<ReturnInvoiceOrderDetailViewBO> lstInvoiceOrderDetail = new List<ReturnInvoiceOrderDetailViewBO>();
                List<ReturnInvoiceOrderDetailViewBO> lstNotInvoiceOrderDetail = new List<ReturnInvoiceOrderDetailViewBO>();

                if (Session["InvoiceOrderDetails"] != null && Session["NotInvoiceOrderDetails"] != null)
                {
                    lstNotInvoiceOrderDetail = (List<ReturnInvoiceOrderDetailViewBO>)Session["NotInvoiceOrderDetails"];

                    #region Add

                    lstInvoiceOrderDetail = (List<ReturnInvoiceOrderDetailViewBO>)Session["InvoiceOrderDetails"];

                    lstInvoiceOrderDetail.AddRange(lstNotInvoiceOrderDetail.Where(o => o.OrderDetail == odid).ToList());

                    Session["InvoiceOrderDetails"] = lstInvoiceOrderDetail;

                    this.PopulateInvoiceOrderGrid(lstInvoiceOrderDetail);

                    #endregion

                    #region Remove

                    lstNotInvoiceOrderDetail = lstNotInvoiceOrderDetail.Where(o => o.OrderDetail != odid).ToList();

                    Session["NotInvoiceOrderDetails"] = lstNotInvoiceOrderDetail;

                    this.PopulateNotExistingOrderGrid(lstNotInvoiceOrderDetail);

                    #endregion
                }

            }
        }

        protected void lbCostSheet_Click(object sender, EventArgs e)
        {
            int costsheet = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["csid"].ToString());
            int pattern = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["patid"].ToString());
            int fabric = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["fabid"].ToString());
            int invoiceorder = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["invo"].ToString());

            /* InvoiceBO objInvoice = new InvoiceBO();
             objInvoice.ID = this.QueryID;
             objInvoice.GetObject();*/


            FactoryInvoice objFactoryInvoice = new FactoryInvoice();
            objFactoryInvoice.Week = int.Parse(this.WeekComboBox.SelectedValue);
            //objFactoryInvoice.ShipmentDate = Convert.ToDateTime(this.ddlShipmentDates.SelectedItem.Text);
            objFactoryInvoice.ShipmentKey = (this.DistributorClientAddress > 0) ? this.DistributorClientAddress : (this.RadComboShipmentKey.Items.Count > 0) ? int.Parse(this.RadComboShipmentKey.SelectedValue) : 0;
            objFactoryInvoice.InvoiceNo = this.txtInvoiceNo.Text;
            objFactoryInvoice.InvoiceDate = (!string.IsNullOrEmpty(this.txtInvoiceDate.Text)) ? Convert.ToDateTime(this.txtInvoiceDate.Text) : DateTime.Now;
            objFactoryInvoice.AWBNoo = this.txtAwbNo.Text;
            //objFactoryInvoice.IsBillTo = this.chkIsBillTo.Checked;
            //objFactoryInvoice.BillTo = int.Parse(this.BillToDropDownList.SelectedValue);
            objFactoryInvoice.Bank = int.Parse(this.BankDropDownList.SelectedValue);
            objFactoryInvoice.Status = int.Parse(this.StatusDropDownList.SelectedValue);
            objFactoryInvoice.InvoiceOrder = invoiceorder;
            objFactoryInvoice.Invoice = (this.QueryID > 0) ? this.QueryID : this.CreatedInvoiceId;
            objFactoryInvoice.ShipmentMode = this.ShipmentModeID;

            Session["FactoryInvoice"] = objFactoryInvoice;

            if (costsheet > 0 && (this.QueryID > 0 || this.CreatedInvoiceId > 0))
            {
                int inv = (this.QueryID > 0) ? this.QueryID : this.CreatedInvoiceId;

                Response.Redirect("AddEditFactoryCostSheet.aspx?id=" + costsheet + "&inv=" + inv.ToString());
            }
            else if (pattern > 0 && fabric > 0 && costsheet > 0)
            {
                Response.Redirect("AddEditFactoryCostSheet.aspx?pat=" + pattern.ToString() + "&fab=" + fabric.ToString() + "&id=" + costsheet.ToString());
            }
            else if (pattern > 0 && fabric > 0)
            {
                Response.Redirect("AddEditFactoryCostSheet.aspx?pat=" + pattern.ToString() + "&fab=" + fabric.ToString());
            }

        }

        //protected void btnChangeCost_ServerClick(object sender, EventArgs e)
        //{
        //    decimal cost;
        //    if (!string.IsNullOrEmpty(this.txtFactoryCost.Text) && decimal.TryParse(this.txtFactoryCost.Text, out cost))
        //    {
        //        List<int> lstOrderDetails = new List<int>();

        //        foreach (GridDataItem item in ItemGrid.Items)
        //        {
        //            HiddenField hdnOrderDetail = (HiddenField)item.FindControl("hdnOrderDetail");
        //            lstOrderDetails.Add(int.Parse(hdnOrderDetail.Value));
        //        }

        //        if (Session["InvoiceOrderDetails"] != null)
        //        {
        //            List<ReturnInvoiceOrderDetailViewBO> lst = (List<ReturnInvoiceOrderDetailViewBO>)Session["InvoiceOrderDetails"];

        //            List<ReturnInvoiceOrderDetailViewBO> lstChangeFactoryRate = lst.Where(o => lstOrderDetails.Contains((int)o.OrderDetail)).Select(x => { x.FactoryRate = decimal.Parse(this.txtFactoryCost.Text); return x; }).ToList();//.ToList().ForEach(x => x.FactoryRate = decimal.Parse(this.txtFactoryCost.Text));

        //            //List<int> lstChangeOrderDetails = lstChangeFactoryRate.Select(o => (int)o.OrderDetail).ToList();

        //            lst = lst.Where(o => !lstChangeFactoryRate.Select(x => (int)x.OrderDetail).ToList().Contains((int)o.OrderDetail)).ToList();

        //            lst.AddRange(lstChangeFactoryRate);

        //            Session["InvoiceOrderDetails"] = lst;

        //        }

        //        this.ItemGrid.DataSource = null;
        //        this.ItemGrid.DataBind();

        //        this.RebindGrid();
        //    }

        //    this.txtFactoryCost.Text = string.Empty;
        //}

        #endregion

        #region Methods




        ///// <summary>
        ///// Populate the controls.
        ///// </summary>
        //private void PopulateControls()
        //{
        //    using (var connection = GetIndicoConnnection())
        //    {
        //        this.litHeaderText.Text = ((this.QueryID > 0) ? "Edit " : "New ") + this.ActivePage.Heading;
        //        this.spanShipmentError.Visible = false;
        //        this.btnFactoryDetail.Visible = (this.QueryID > 0) ? true : false;
        //        this.btnInvoiceSummary.Visible = (this.QueryID > 0) ? true : false;
        //        this.dvEmptyNotExistingOrders.Visible = true;
        //        this.litMeassage.Text = "Please add the orders to the system";
        //        this.dgNotExistingInvoiceOrders.Visible = false;
        //        this.dvFactoryRate.Visible = false;

        //        this.lblShipmentKeyAddress.Text = string.Empty;

        //        var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
        //        var monday = DateTime.Today.AddDays(-daysTillMonday);

        //        this.WeekComboBox.Enabled = (this.QueryID > 0) ? false : true;
        //        //this.ddlShipmentDates.Enabled = (this.QueryID > 0) ? false : true;

        //        // populate Invoice Status
        //        this.StatusDropDownList.Items.Clear();
        //        this.StatusDropDownList.Items.Add(new ListItem("Select a Status", "0"));
        //        List<InvoiceStatusBO> lstStatus = (new InvoiceStatusBO()).GetAllObject().OrderBy(o => o.Name).ToList();
        //        foreach (InvoiceStatusBO ins in lstStatus)
        //        {
        //            this.StatusDropDownList.Items.Add(new ListItem(ins.Name, ins.ID.ToString()));
        //        }

        //        //populate Bank
        //        this.BankDropDownList.Items.Clear();
        //        this.BankDropDownList.Items.Add(new ListItem("Select a Bank", "0"));
        //        List<BankBO> lstBanks = (new BankBO()).GetAllObject();
        //        foreach (BankBO bank in lstBanks)
        //        {
        //            this.BankDropDownList.Items.Add(new ListItem(bank.Name + " - " + bank.AccountNo, bank.ID.ToString()));
        //        }

        //        //populate bill to
        //        this.PopulateBillTo();

        //        // populate Destination Port
        //        this.ddlShipToPort.Items.Clear();
        //        this.ddlShipToPort.Items.Add(new ListItem("Select Destination Port", "0"));
        //        List<DestinationPortBO> lstDestinationPort = (new DestinationPortBO()).GetAllObject();
        //        foreach (DestinationPortBO ds in lstDestinationPort)
        //        {
        //            this.ddlShipToPort.Items.Add(new ListItem(ds.Name, ds.ID.ToString()));
        //        }

        //        // Populate Country
        //        this.ddlShipToCountry.Items.Clear();
        //        this.ddlShipToCountry.Items.Add(new ListItem("Select Country", "0"));
        //        List<CountryBO> lstCountries = (new CountryBO()).GetAllObject().OrderBy(o => o.ShortName).ToList();
        //        foreach (CountryBO country in lstCountries)
        //        {
        //            this.ddlShipToCountry.Items.Add(new ListItem(country.ShortName, country.ID.ToString()));
        //        }

        //        //populate Distributor
        //        this.ddlDistributor.Items.Clear();
        //        this.ddlDistributor.Items.Add(new ListItem("Select a Distributor", "0"));
        //        List<CompanyBO> lstDistributors = (new CompanyBO()).GetAllObject().Where(o => o.IsDistributor == true).OrderBy(o => o.Name).ToList();
        //        foreach (CompanyBO distributor in lstDistributors)
        //        {
        //            this.ddlDistributor.Items.Add(new ListItem(distributor.Name, distributor.ID.ToString()));
        //        }


        //        // populate WeekComboBox
        //        WeekComboBox.Items.Clear();
        //        if (QueryID == 0)
        //        {

        //            //TODO Remove
        //            //List<WeeklyProductionCapacityBO> lstWeeklyCapacities = (new WeeklyProductionCapacityBO()).SearchObjects().Where(o => o.WeekendDate >= DateTime.Now.AddMonths(-1) && o.WeekendDate.Year >= DateTime.Now.Year).ToList();
        //            //this.WeekComboBox.DataSource = lstWeeklyCapacities;
        //            //this.WeekComboBox.DataBind();
        //        }

        //        Session["InvoiceOrderDetails"] = null;

        //        this.populateInvoiceOrders();

        //        if (this.QueryID > 0)
        //        {
        //            InvoiceBO objInvoice = new InvoiceBO();
        //            objInvoice.ID = this.QueryID;
        //            objInvoice.GetObject();

        //            DateTime date = objInvoice.objWeeklyProductionCapacity.WeekendDate;
        //            List<WeeklyProductionCapacityBO> lstWeeklyCapacities = (new WeeklyProductionCapacityBO()).SearchObjects().Where(o => o.WeekendDate >= date.AddMonths(-1) && o.WeekendDate.Year >= date.Year).ToList();
        //            this.WeekComboBox.DataSource = lstWeeklyCapacities;
        //            this.WeekComboBox.DataBind();

        //            this.WeekComboBox.Items.FindItemByValue(objInvoice.WeeklyProductionCapacity.ToString()).Selected = true;
        //            //this.PopulateShipmentDates(this.GetWeeklyProductionCapacityDetails(objInvoice.WeeklyProductionCapacity).WeekendDate, (int)objInvoice.WeeklyProductionCapacity);

        //            this.PopulateInvoiceShipmentDates(objInvoice.objWeeklyProductionCapacity.WeekendDate, (int)objInvoice.WeeklyProductionCapacity);
        //            //this.ddlShipmentDates.Items.FindByText(objInvoice.ShipmentDate.ToString("dd MMMM yyyy")).Selected = true;
        //            this.PopulateShipmentKey(objInvoice.ShipmentDate);
        //            this.txtInvoiceDate.Text = objInvoice.InvoiceDate.ToString("dd MMMM yyyy");
        //            this.txtAwbNo.Text = objInvoice.AWBNo;
        //            //this.txtShipTo.Text = objInvoice.objShipTo.CompanyName;
        //            this.ShipmentModeDropDownList.Text = objInvoice.objShipmentMode.Name;
        //            this.RadComboShipmentKey.Enabled = false;
        //            this.txtInvoiceNo.Text = objInvoice.InvoiceNo;
        //            this.StatusDropDownList.Items.FindByValue(objInvoice.Status.ToString()).Selected = true;
        //            this.chkIsBillTo.Checked = (bool)objInvoice.IsBillTo;
        //            this.BillToDropDownList.Items.FindByValue(objInvoice.BillTo.ToString()).Selected = true;
        //            this.BankDropDownList.Items.FindByValue(objInvoice.Bank.ToString()).Selected = true;


        //            ViewState["DistributorClientAddress"] = objInvoice.ShipTo;
        //            ViewState["ShipmentID"] = objInvoice.ShipmentMode;

        //            DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO();
        //            objDistributorClientAddress.ID = objInvoice.ShipTo;
        //            objDistributorClientAddress.GetObject();

        //            string state = (objDistributorClientAddress.State != null) ? objDistributorClientAddress.Suburb : string.Empty;

        //            this.lblShipmentKeyAddress.Text = objDistributorClientAddress.CompanyName + " , " + objDistributorClientAddress.Address + " , " + objDistributorClientAddress.Suburb + " , " + state + " , " + objDistributorClientAddress.objCountry.ShortName + " , " + objDistributorClientAddress.PostCode;


        //            this.populateInvoiceOrders(this.QueryID, objInvoice.ShipTo, false, objInvoice.ShipmentMode, false);
        //        }
        //        else
        //        {
        //            // set default invoice status
        //            this.StatusDropDownList.Items.FindByText("PreShipped").Selected = true;
        //        }

        //        // if Redirect From WeeklySummary Page
        //        if (this.WeeklyCapacityDate != new DateTime(1100, 1, 1) && this.WeeklyCapacityID > 0)
        //        {
        //            this.WeekComboBox.Items.FindItemByValue(this.WeeklyCapacityID.ToString()).Selected = true;
        //            this.PopulateShipmentDates(this.WeeklyCapacityDate, this.WeeklyCapacityID);
        //        }

        //        if (this.WeeklyCapacityDate != new DateTime(1100, 1, 1) && this.ShipmentDate != new DateTime(1100, 1, 1) && this.ShipmentKey > 0 && !string.IsNullOrEmpty(this.InvoiceNo) && this.ShipmentMode > 0)
        //        {
        //            int wid = (new WeeklyProductionCapacityBO()).GetAllObject().Where(o => o.WeekendDate == this.WeeklyCapacityDate).Select(o => o.ID).SingleOrDefault();

        //            this.WeekComboBox.Items.FindItemByValue(wid.ToString()).Selected = true;

        //            this.PopulateShipmentDates(this.WeeklyCapacityDate);

        //            //this.ddlShipmentDates.Items.FindByText(this.ShipmentDate.ToString("dd MMMM yyyy")).Selected = true;

        //            this.PopulateShipmentKey(this.ShipmentDate);

        //            this.RadComboShipmentKey.Items.FindItemByValue(this.ShipmentKey.ToString() + "," + this.ShipmentMode.ToString()).Selected = true;

        //            this.txtInvoiceNo.Text = this.InvoiceNo;

        //            DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO();
        //            objDistributorClientAddress.ID = this.ShipmentKey;
        //            objDistributorClientAddress.GetObject();

        //            ShipmentModeBO objShipmentMode = new ShipmentModeBO();
        //            objShipmentMode.ID = this.ShipmentMode;
        //            objShipmentMode.GetObject();

        //            //this.txtShipTo.Text = objDistributorClientAddress.CompanyName;
        //            this.ShipmentModeDropDownList.Text = objShipmentMode.Name;
        //            ViewState["DistributorClientAddress"] = this.ShipmentKey;
        //            ViewState["ShipmentID"] = this.ShipmentMode;

        //            string state = (objDistributorClientAddress.State != null) ? objDistributorClientAddress.Suburb : string.Empty;

        //            this.lblShipmentKeyAddress.Text = objDistributorClientAddress.CompanyName + " , " + objDistributorClientAddress.Address + " , " + objDistributorClientAddress.Suburb + " " + state + " , " + objDistributorClientAddress.objCountry.ShortName + " , " + objDistributorClientAddress.PostCode;


        //            this.populateInvoiceOrders(0, this.ShipmentKey, true, this.ShipmentMode, false, wid, true);
        //        }

        //        if (this.CostSheet > 0)
        //        {
        //            FactoryInvoice objFactoryInvoice = (FactoryInvoice)Session["FactoryInvoice"];

        //            if (objFactoryInvoice.InvoiceOrder > 0)
        //            {
        //                CostSheetBO objCostSheet = new CostSheetBO();
        //                objCostSheet.ID = this.CostSheet;
        //                objCostSheet.GetObject();

        //                using (TransactionScope ts = new TransactionScope())
        //                {
        //                    InvoiceOrderBO objInvoiceOrder = new InvoiceOrderBO(this.ObjContext);
        //                    objInvoiceOrder.ID = objFactoryInvoice.InvoiceOrder;
        //                    objInvoiceOrder.GetObject();

        //                    objInvoiceOrder.FactoryPrice = (objCostSheet.QuotedFOBCost != null && objCostSheet.QuotedFOBCost != 0) ? objCostSheet.QuotedFOBCost : objCostSheet.JKFOBCost;

        //                    this.ObjContext.SaveChanges();
        //                    ts.Complete();
        //                }
        //            }

        //            this.WeekComboBox.Items.FindItemByValue(objFactoryInvoice.Week.ToString()).Selected = true;

        //            this.PopulateShipmentDates(this.GetWeeklyProductionCapacityDetails(objFactoryInvoice.Week).WeekendDate);

        //            //this.ddlShipmentDates.Items.FindByText(objFactoryInvoice.ShipmentDate.ToString("dd MMMM yyyy")).Selected = true;

        //            this.PopulateShipmentKey(objFactoryInvoice.ShipmentDate);

        //            this.CreatedInvoiceId = objFactoryInvoice.Invoice;

        //            if (this.CreatedInvoiceId == 0 && this.RadComboShipmentKey.Items.Count > 0)
        //            {
        //                this.RadComboShipmentKey.Items.FindItemByValue(objFactoryInvoice.ShipmentKey.ToString() + "," + objFactoryInvoice.ShipmentMode.ToString()).Selected = true;
        //            }
        //            //this.RadComboShipmentKey.Items.FindItemByValue(objFactoryInvoice.ShipmentKey.ToString() + "," + objFactoryInvoice.ShipmentMode.ToString()).Selected = true;

        //            this.txtInvoiceNo.Text = objFactoryInvoice.InvoiceNo;
        //            this.txtInvoiceDate.Text = objFactoryInvoice.InvoiceDate.ToString("dd MMMM yyyy");
        //            this.txtAwbNo.Text = objFactoryInvoice.AWBNoo;
        //            this.chkIsBillTo.Checked = objFactoryInvoice.IsBillTo;
        //            this.BillToDropDownList.Items.FindByValue(this.BillToDropDownList.SelectedValue).Selected = false;
        //            this.BillToDropDownList.Items.FindByValue(objFactoryInvoice.BillTo.ToString()).Selected = true;
        //            this.BankDropDownList.Items.FindByValue(this.BankDropDownList.SelectedValue).Selected = false;
        //            this.BankDropDownList.Items.FindByValue(objFactoryInvoice.Bank.ToString()).Selected = true;
        //            this.StatusDropDownList.Items.FindByValue(this.StatusDropDownList.SelectedValue).Selected = false;
        //            this.StatusDropDownList.Items.FindByValue(objFactoryInvoice.Status.ToString()).Selected = true;

        //            DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO();
        //            objDistributorClientAddress.ID = objFactoryInvoice.ShipmentKey;
        //            objDistributorClientAddress.GetObject();

        //            ShipmentModeBO objShipmentMode = new ShipmentModeBO();
        //            objShipmentMode.ID = objFactoryInvoice.ShipmentMode;
        //            objShipmentMode.GetObject();

        //            //this.txtShipTo.Text = objDistributorClientAddress.CompanyName;
        //            this.ShipmentModeDropDownList.Text = objShipmentMode.Name;
        //            ViewState["DistributorClientAddress"] = objFactoryInvoice.ShipmentKey;
        //            ViewState["ShipmentID"] = objFactoryInvoice.ShipmentMode;

        //            string state = (objDistributorClientAddress.State != null) ? objDistributorClientAddress.Suburb : string.Empty;
        //            this.lblShipmentKeyAddress.Text = objDistributorClientAddress.CompanyName + " , " + objDistributorClientAddress.Address + " , " + objDistributorClientAddress.Suburb + " " + state + " , " + objDistributorClientAddress.objCountry.ShortName + " , " + objDistributorClientAddress.PostCode;
        //            this.populateInvoiceOrders(objFactoryInvoice.Invoice, objFactoryInvoice.ShipmentKey, true, objFactoryInvoice.ShipmentMode, false, (int)objFactoryInvoice.Week, true);
        //        }
        //    }

        //}

        private void ProcessForm()
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    #region Change Shipment Date & Packing List

                    //  int weeklyid = 0;

                    WeeklyProductionCapacityBO objWeeklyProductionCapacity = new WeeklyProductionCapacityBO();

                    if (this.chkChangeOrderDate.Checked == true)
                    {
                        int week = this.GetWeekOfYear(Convert.ToDateTime(txtInvoiceDate.Text.Trim()));

                        objWeeklyProductionCapacity = (new WeeklyProductionCapacityBO()).SearchObjects().Where(o => o.WeekNo == week && o.WeekendDate.Year == Convert.ToDateTime(txtInvoiceDate.Text.Trim()).Year).SingleOrDefault();

                        PackingListBO objPack = new PackingListBO();
                        objPack.WeeklyProductionCapacity = objWeeklyProductionCapacity.ID;

                        List<PackingListBO> lstPack = objPack.SearchObjects();

                        if (lstPack.Count == 0)
                        {
                            ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                            objReturnInt = PackingListBO.InsertPackingList(objWeeklyProductionCapacity.WeekendDate, this.LoggedUser.ID);

                            if (objReturnInt.RetVal == 0)
                            {
                                IndicoLogging.log.Error("ProcessForm() : Error occured while Inserting the PackingList AddEditInvoice.aspx, SPC_CreatingPackingList");
                            }
                        }

                        foreach (GridDataItem item in ItemGrid.Items)
                        {
                            TextBox txtRate = (TextBox)item.FindControl("txtRate");
                            int orderdetail = int.Parse(((System.Web.UI.WebControls.WebControl)(txtRate)).Attributes["orderdetail"].ToString());

                            OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                            objOrderDetail.ID = orderdetail;
                            objOrderDetail.GetObject();

                            objOrderDetail.SheduledDate = Convert.ToDateTime(this.txtInvoiceDate.Text);
                            objOrderDetail.ShipmentDate = Convert.ToDateTime(this.txtInvoiceDate.Text);

                            PackingListBO objPacking = new PackingListBO();
                            objPacking.OrderDetail = orderdetail;

                            List<PackingListBO> lstPackingList = objPacking.SearchObjects();

                            if (lstPackingList.Count > 0)
                            {
                                foreach (PackingListBO pl in lstPackingList)
                                {
                                    PackingListBO objPackingList = new PackingListBO(this.ObjContext);
                                    objPackingList.ID = pl.ID;
                                    objPackingList.GetObject();

                                    objPackingList.WeeklyProductionCapacity = objWeeklyProductionCapacity.ID;
                                    objPackingList.Modifier = this.LoggedUser.ID;
                                    objPackingList.ModifiedDate = DateTime.Now;
                                }
                            }
                        }

                        this.ObjContext.SaveChanges();
                    }

                    #endregion

                                #region Create Invoice Header

                                InvoiceBO objInvoice = new InvoiceBO(this.ObjContext);
                                if (QueryID > 0 || this.CreatedInvoiceId > 0)
                                {
                                    objInvoice.ID = (this.QueryID > 0) ? this.QueryID : this.CreatedInvoiceId;
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
                                objInvoice.WeeklyProductionCapacity = (this.chkChangeOrderDate.Checked == true) ? objWeeklyProductionCapacity.ID : int.Parse(this.WeekComboBox.SelectedValue);
                                objInvoice.ShipmentMode = this.ShipmentModeID;
                                //objInvoice.ShipmentDate = (this.chkChangeOrderDate.Checked == true) ? Convert.ToDateTime(this.txtInvoiceDate.Text) : Convert.ToDateTime(this.ddlShipmentDates.SelectedItem.Text);
                                objInvoice.Status = int.Parse(this.StatusDropDownList.SelectedValue);
                                //objInvoice.IsBillTo = this.chkIsBillTo.Checked;
                                //objInvoice.BillTo = (this.chkIsBillTo.Checked) ? int.Parse(this.BillToDropDownList.SelectedValue) : 22;
                                objInvoice.Bank = int.Parse(this.BankDropDownList.SelectedValue);
                                //objInvoice.IndimanInvoiceNo = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? this.txtIndimanInvoiceNo.Text : string.Empty;

                                //if (this.LoggedUserRoleName == UserRole.IndimanAdministrator)
                                //{
                                //    objInvoice.IndimanInvoiceDate = Convert.ToDateTime(this.txtIndimanInvoiceDate.Text);
                                //}

                                objInvoice.Modifier = this.LoggedUser.ID;
                                objInvoice.ModifiedDate = DateTime.Now;

                                this.ObjContext.SaveChanges();

                                ViewState["InvoiceId"] = objInvoice.ID;

                                #endregion

                                #region InvoiceOrderDetail

                                foreach (GridDataItem item in ItemGrid.Items)
                                {
                                    TextBox txtRate = (TextBox)item.FindControl("txtRate");
                                    int id = int.Parse(((System.Web.UI.WebControls.WebControl)(txtRate)).Attributes["invoiceorder"].ToString());
                                    int orderdetail = int.Parse(((System.Web.UI.WebControls.WebControl)(txtRate)).Attributes["orderdetail"].ToString());

                                    InvoiceOrderBO objInvoiceOrder = new InvoiceOrderBO(this.ObjContext);
                                    if (id > 0)
                                    {
                                        objInvoiceOrder.ID = id;
                                        objInvoiceOrder.GetObject();
                                    }

                                    objInvoiceOrder.Invoice = int.Parse(ViewState["InvoiceId"].ToString());
                                    objInvoiceOrder.OrderDetail = orderdetail;
                                    objInvoiceOrder.FactoryPrice = Convert.ToDecimal(txtRate.Text);
                                    // objInvoiceOrder.IndimanPrice = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? Convert.ToDecimal(txtIndimanRate.Text) : Convert.ToDecimal("0");

                                }
                                this.ObjContext.SaveChanges();

                                #endregion

                                #region Change Order Detail Status

                                List<int> lstOrders = new List<int>();
                                int orderid = 0;
                                int odstatus = 0;
                                int osatus = 0;


                                if (this.StatusDropDownList.SelectedValue == "5")
                                {
                                    odstatus = 16;
                                    osatus = 21;
                                }
                                else if (this.StatusDropDownList.SelectedValue == "4")
                                {
                                    odstatus = 17;
                                    osatus = 19;
                                }

                                foreach (GridDataItem item in ItemGrid.Items)
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

                                    objOrderDetail.Status = odstatus;
                                }

                                this.ObjContext.SaveChanges();


                                #endregion

                                #region Change Order Status

                                if (lstOrders.Count > 0)
                                {
                                    foreach (int order in lstOrders)
                                    {
                                        OrderBO objOrder = new OrderBO(this.ObjContext);
                                        objOrder.ID = order;
                                        objOrder.GetObject();

                                        objOrder.Status = osatus;
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

        public void loadWeekNo()
        {
            int difdate = 0;
            DateTime todaydate = DateTime.Today.Date;
            DateTime expdate = new DateTime();
            string todayday = todaydate.DayOfWeek.ToString();
            if (todayday == "Tuesday")
            {
                difdate = 0;
            }

            if (todayday == "Wednesday")
            {
                difdate = 6;
            }

            if (todayday == "Thursday")
            {

                difdate = 5;
            }

            if (todayday == "Friday")
            {

                difdate = 4;
            }

            if (todayday == "Saturday")
            {

                difdate = 3;
            }

            if (todayday == "Sunday")
            {

                difdate = 2;
            }

            if (todayday == "Monday")
            {

                difdate = 1;
            }

            expdate = todaydate.AddDays(difdate);

            var connection = GetIndicoConnnection();

            var result1 = connection.Query<WeekNoWeekendDateModel>(string.Format("SELECT ID,WeekNo,WeekendDate,'make' FROM [dbo].[WeeklyProductionCapacity] WHERE WeekendDate>='{0}'", expdate.GetSQLDateString())).ToList();
            //result1.ForEach(c => c.Makeweeknoyear());
            WeekComboBox.DataSource = result1;
            WeekComboBox.DataBind();

        }

        public void loadPort()
        {

            var connection = GetIndicoConnnection();

            var result1 = connection.Query<PortModel>("SELECT ID,Name FROM [dbo].[DestinationPort]");

            PortDropDownList.DataSource = result1;
            PortDropDownList.DataBind();
        }

        public void loadMode()
        {
            var connection = GetIndicoConnnection();

            var result1 = connection.Query<ModeModel>("SELECT ID,Name FROM [dbo].[ShipmentMode]");
            ShipmentModeDropDownList.DataSource = result1;
            ShipmentModeDropDownList.DataBind();

        }

        public void loadStatus()
        {

            var connection = GetIndicoConnnection();
            var result1 = connection.Query<NameIdModel>("SELECT ID,Name FROM [dbo].[InvoiceStatus]");
            StatusDropDownList.DataSource = result1;
            StatusDropDownList.DataBind();

        }

        public void loadBanks()
        {
            var connection = GetIndicoConnnection();
            var result1 = connection.Query<NameIdModel>("SELECT ID,Name FROM [dbo].[Bank]");
            BankDropDownList.DataSource = result1;
            BankDropDownList.DataBind();
        }

        public void loadBillTo()
        {

            var connection = GetIndicoConnnection();
            var result1 = connection.Query<AddressIdModel>("SELECT ID,Address FROM [dbo].[DistributorClientAddress]");
            BillToDropDownList.DataSource = result1;
            BillToDropDownList.DataBind();


        }

        private void populateInvoiceOrders(int invoice = 0, int distributorclientaddress = 0, bool isNew = true, int shipmentid = 0, bool isPopulate = true, int wid = 0, bool isweekly = false)
        {
            List<ReturnInvoiceOrderDetailViewBO> lstInvoiceOrderDetails = new List<ReturnInvoiceOrderDetailViewBO>();
            List<ReturnInvoiceOrderDetailViewBO> lst = new List<ReturnInvoiceOrderDetailViewBO>();
            List<int> lstnotexists = new List<int>();

            if (isPopulate)
            {
                this.ItemGrid.Visible = false;
            }
            else
            {
                if (this.QueryID == 0)
                {
                    if (isweekly)
                    {
                        InvoiceBO objInvoice = new InvoiceBO();
                        objInvoice.WeeklyProductionCapacity = wid;
                        //objInvoice.ShipmentDate = DateTime.Parse(this.ddlShipmentDates.SelectedValue);
                        objInvoice.ShipTo = distributorclientaddress;
                        //objInvoice.Status = 4;

                        List<InvoiceBO> lstInvoice = objInvoice.SearchObjects().Where(o => o.Status == 4).ToList();

                        if (lstInvoice.Count > 0)
                        {
                            //lstInvoiceOrderDetails = InvoiceBO.InvoiceOrderDetailView(lstInvoice[0].ID, distributorclientaddress, false, DateTime.Parse(this.ddlShipmentDates.SelectedValue), shipmentid);

                            // lst = InvoiceBO.InvoiceOrderDetailView(0, distributorclientaddress, isNew, DateTime.Parse(this.ddlShipmentDates.SelectedValue), shipmentid);

                            lstnotexists = lst.Select(o => (int)o.OrderDetail).ToList().Except(lstInvoiceOrderDetails.Select(o => (int)o.OrderDetail).ToList()).ToList();

                            if (lstnotexists.Count > 0)
                            {
                                lst = lst.Where(o => lstnotexists.Contains(o.OrderDetail ?? 0)).ToList();

                                this.PopulateNotExistingOrderGrid(lst);

                                CreatedInvoiceId = lstInvoice[0].ID;

                                this.ManageInvoice();
                            }
                            else
                            {
                               // this.litMeassage.Text = "All the Orders are added to the system";
                            }
                        }
                        else
                        {
                            lstInvoice = objInvoice.SearchObjects().Where(o => o.Status == 5).ToList();

                            if (lstInvoice.Count > 0)
                            {
                                //lstInvoiceOrderDetails = InvoiceBO.InvoiceOrderDetailView(lstInvoice[0].ID, distributorclientaddress, false, DateTime.Parse(this.ddlShipmentDates.SelectedValue), shipmentid);

                                //lst = InvoiceBO.InvoiceOrderDetailView(0, distributorclientaddress, isNew, DateTime.Parse(this.ddlShipmentDates.SelectedValue), shipmentid);

                                lstnotexists = lst.Select(o => (int)o.OrderDetail).ToList().Except(lstInvoiceOrderDetails.Select(o => (int)o.OrderDetail).ToList()).ToList();

                                if (lstnotexists.Count > 0)
                                {
                                    lstInvoiceOrderDetails = lst.Where(o => lstnotexists.Contains(o.OrderDetail ?? 0)).ToList();
                                }
                            }
                            else
                            {
                                // lstInvoiceOrderDetails = InvoiceBO.InvoiceOrderDetailView(invoice, distributorclientaddress, isNew, DateTime.Parse(this.ddlShipmentDates.SelectedValue), shipmentid);
                            }
                        }
                    }
                    else
                    {
                        //lstInvoiceOrderDetails = InvoiceBO.InvoiceOrderDetailView(invoice, distributorclientaddress, isNew, DateTime.Parse(this.ddlShipmentDates.SelectedValue), shipmentid);
                    }
                }
                else
                {
                    InvoiceBO objInvoice = new InvoiceBO();
                    objInvoice.ID = this.QueryID;
                    objInvoice.GetObject();

                    if (objInvoice.Status == 5)
                    {
                        //lstInvoiceOrderDetails = InvoiceBO.InvoiceOrderDetailView(invoice, distributorclientaddress, isNew, DateTime.Parse(this.ddlShipmentDates.SelectedValue), shipmentid);
                    }
                    else
                    {
                        // lstInvoiceOrderDetails = InvoiceBO.InvoiceOrderDetailView(this.QueryID, distributorclientaddress, isNew, DateTime.Parse(this.ddlShipmentDates.SelectedValue), shipmentid);

                        //lst = InvoiceBO.InvoiceOrderDetailView(0, distributorclientaddress, true, DateTime.Parse(this.ddlShipmentDates.SelectedValue), shipmentid);

                        lstnotexists = lst.Select(o => (int)o.OrderDetail).ToList().Except(lstInvoiceOrderDetails.Select(o => (int)o.OrderDetail).ToList()).ToList();

                        if (lstnotexists.Count > 0)
                        {
                            lst = lst.Where(o => lstnotexists.Contains(o.OrderDetail ?? 0)).ToList();

                            this.PopulateNotExistingOrderGrid(lst);

                            //  CreatedInvoiceId = lstInvoice[0].ID;
                        }
                        else
                        {
                          //  this.litMeassage.Text = "All the Orders are added to the system";
                        }
                    }
                }

                this.PopulateInvoiceOrderGrid(lstInvoiceOrderDetails);
            }
        }

        private void PopulateShipmentKey(DateTime ShipmentDate)
        {
            List<ReturnWeeklySummaryViewBO> lstWeeklySummary = new List<ReturnWeeklySummaryViewBO>();
            List<ReturnWeeklySummaryViewBO> lst = new List<ReturnWeeklySummaryViewBO>();
            lst = OrderDetailBO.GetWeekSummary(ShipmentDate, true);

            List<int> lstshipmentID = (new InvoiceBO()).SearchObjects().Where(o => o.WeeklyProductionCapacity == WeekID && o.ShipmentDate == ShipmentDate).Select(o => o.ShipTo).ToList();

            List<int> lstShipTo = lst.Select(o => o.DistributorClientAddress != null ? (int)o.DistributorClientAddress : 0).ToList();

            List<int> lstShipmentKeyID = lstShipTo.Except(lstshipmentID).ToList();

            if (this.QueryID == 0)
            {
                if (lst.Count > 0)
                {
                    if (lstShipmentKeyID.Count > 0)
                    {
                        foreach (var shipmentKey in lstShipmentKeyID)
                        {
                            lstWeeklySummary.AddRange(lst.Where(o => o.DistributorClientAddress == shipmentKey).ToList());
                        }
                        // spanShipmentError.Visible = false;
                    }
                    else
                    {
                        if (lstshipmentID.Count == 0)
                        {
                            lstWeeklySummary = lst;
                        }
                        else
                        {
                           // this.spanShipmentError.InnerText = "All the Shipments added to the system";
                           // this.spanShipmentError.Visible = true;
                        }
                    }
                }
                else
                {
                   // this.spanShipmentError.InnerText = "No shipments for this Week";
                   // this.spanShipmentError.Visible = true;
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
                ItemGrid.DataSource = (List<ReturnInvoiceOrderDetailViewBO>)Session["InvoiceOrderDetails"];
                ItemGrid.DataBind();
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

            //this.ddlShipmentDates.Items.Clear();
            //this.ddlShipmentDates.Items.Add(new ListItem("Select a Shipment Date"));
            foreach (ReturnShipmentDatesViewBO shipdates in lstShipmentDates)
            {
                // this.ddlShipmentDates.Items.Add(new ListItem(Convert.ToDateTime(shipdates.ShipmentDate.ToString()).ToString("dd MMMM yyyy")));
            }

            //this.ddlShipmentDates.Enabled = (WeekendDate != new DateTime(1100, 1, 1)) ? true : false;
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

            //this.ddlShipmentDates.Items.Clear();
            //this.ddlShipmentDates.Items.Add(new ListItem("Select a Shipment Date"));
            foreach (DateTime shipdates in lstDates)
            {
                //this.ddlShipmentDates.Items.Add(new ListItem(Convert.ToDateTime(shipdates.ToString()).ToString("dd MMMM yyyy")));
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
            this.BillToDropDownList.Items.Clear();
            this.BillToDropDownList.Items.Add(new ListItem("Select a Bill To", "0"));
            List<DistributorClientAddressBO> lstDistributorClientAddress = (new DistributorClientAddressBO()).GetAllObject().OrderBy(o => o.CompanyName).ToList();
            foreach (DistributorClientAddressBO dca in lstDistributorClientAddress)
            {
                this.BillToDropDownList.Items.Add(new ListItem(dca.CompanyName, dca.ID.ToString()));
            }

            if (id > 0)
            {
                this.BillToDropDownList.Items.FindByValue(id.ToString()).Selected = true;
            }
        }

        private void PopulateInvoiceOrderGrid(List<ReturnInvoiceOrderDetailViewBO> lstInvoiceOrderDetails)
        {
            if (lstInvoiceOrderDetails.Count > 0)
            {
                this.ItemGrid.DataSource = lstInvoiceOrderDetails;
                this.ItemGrid.DataBind();
                //this.dvEmptyContentInvoiceOrders.Visible = false;
          //      this.dvFactoryRate.Visible = true;
                this.ItemGrid.Visible = true;

                Session["InvoiceOrderDetails"] = lstInvoiceOrderDetails;
            }
            else
            {
                this.ItemGrid.Visible = false;
            //    this.dvEmptyContentInvoiceOrders.Visible = true;
            //    this.dvFactoryRate.Visible = false;
            }
        }

        private void PopulateNotExistingOrderGrid(List<ReturnInvoiceOrderDetailViewBO> lstNotInvoiceOrderDetails)
        {
            if (lstNotInvoiceOrderDetails.Count > 0)
            {

               // this.dgNotExistingInvoiceOrders.DataSource = lstNotInvoiceOrderDetails;
               // this.dgNotExistingInvoiceOrders.DataBind();

                Session["NotInvoiceOrderDetails"] = lstNotInvoiceOrderDetails;
            }

           // this.dgNotExistingInvoiceOrders.Visible = (lstNotInvoiceOrderDetails.Count > 0) ? true : false;
           // this.dvEmptyNotExistingOrders.Visible = (lstNotInvoiceOrderDetails.Count > 0) ? false : true;
           // this.litMeassage.Text = "All the Orders are added to the system";
        }

        private void ManageInvoice()
        {
            if (CreatedInvoiceId > 0)
            {
                InvoiceBO objInvoice = new InvoiceBO();
                objInvoice.ID = CreatedInvoiceId;
                objInvoice.GetObject();

                this.txtInvoiceNo.Text = objInvoice.InvoiceNo;
                this.txtInvoiceDate.Text = objInvoice.InvoiceDate.ToString("dd MMMM yyyy");
                this.BankDropDownList.Items.FindByValue(objInvoice.Bank.ToString()).Selected = true;

              //  this.chkIsBillTo.Checked = (bool)objInvoice.IsBillTo;
                this.BillToDropDownList.Items.FindByValue(objInvoice.BillTo.ToString()).Selected = true;
                this.txtAwbNo.Text = objInvoice.AWBNo;
                this.StatusDropDownList.Items.FindByValue(objInvoice.Status.ToString()).Selected = true;

            }
        }

        //private int GetIso8601WeekOfYear(DateTime time)
        //{
        //    // Seriously cheat.  If its Monday, Tuesday or Wednesday, then it'll 
        //    // be the same week# as whatever Thursday, Friday or Saturday are,
        //    // and we always get those right
        //    DayOfWeek day = CultureInfo.InvariantCulture.Calendar.GetDayOfWeek(time);
        //    if (day >= DayOfWeek.Monday && day <= DayOfWeek.Wednesday)
        //    {
        //        time = time.AddDays(3);
        //    }

        //    // Return the week of our adjusted day
        //    return CultureInfo.InvariantCulture.Calendar.GetWeekOfYear(time, CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday);
        //}

        #endregion

        protected void CostSheetButton_Click(object sender, EventArgs e)
        {

        }

    }

    #region Internal Class

    internal class FactoryInvoice
    {
        public int Week { get; set; }
        public DateTime ShipmentDate { get; set; }
        public int ShipmentKey { get; set; }
        public string InvoiceNo { get; set; }
        public DateTime InvoiceDate { get; set; }
        public bool IsBillTo { get; set; }
        public int BillTo { get; set; }
        public int Bank { get; set; }
        public int Status { get; set; }
        public string AWBNoo { get; set; }
        public int InvoiceOrder { get; set; }
        public int Invoice { get; set; }
        public int ShipmentMode { get; set; }
    }

    #endregion
}