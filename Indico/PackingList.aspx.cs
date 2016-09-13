using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;
using Indico.BusinessObjects;
using Indico.Common;
using Telerik.Web.UI;

namespace Indico
{
    public partial class PackingList : IndicoPage
    {
        #region Enums

        #endregion

        #region Fields

        private DateTime qpWeekEndDate = new DateTime(1100, 1, 1);
        private List<PackingListViewBO> m_source;
        private int parentPackingListID = 0;

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["OrderSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "OrderCreatedDate desc";
                }
                return sort;
            }
            set
            {
                ViewState["OrderSortExpression"] = value;
            }
        }

        protected DateTime WeekEndDate
        {
            get
            {
                if (qpWeekEndDate != new DateTime(1100, 1, 1))
                    return qpWeekEndDate;
                qpWeekEndDate = DateTime.Now;
                if (Request.QueryString["WeekendDate"] != null)
                {
                    qpWeekEndDate = Convert.ToDateTime(Request.QueryString["WeekendDate"].ToString());

                }
                return qpWeekEndDate;
            }
        }

        private List<PackingListViewBO> Source
        {
            get
            {
                if (m_source == null)
                {
                    if (Session["Source"] == null || Session["Source"].GetType() != typeof(List<PackingListViewBO>))
                        return null;

                    List<PackingListViewBO> dv = ((List<PackingListViewBO>)Session["Source"]);

                    m_source = dv;
                }

                return m_source;
            }
            set
            {
                m_source = value;
                if (value != null)
                {
                    Session["Source"] = ((List<PackingListViewBO>)value); ;
                }
                else
                {
                    Session["Source"] = null;
                }
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

        //protected void dgPackingList_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;

        //    if (item.ItemIndex > -1 && item.DataItem is PackingListViewBO)
        //    {
        //        PackingListViewBO objPacking = (PackingListViewBO)item.DataItem;

        //        Literal lblID = (Literal)item.FindControl("lblID");
        //        lblID.Text = objPacking.PackingList.ToString();

        //        Literal lblOrderDetailID = (Literal)item.FindControl("lblOrderDetailID");
        //        lblOrderDetailID.Text = objPacking.OrderDetail.ToString();

        //        Literal lblParentID = (Literal)item.FindControl("lblParentID");

        //        TextBox txtCarton = (TextBox)item.FindControl("txtCarton");
        //        txtCarton.Text = (objPacking.CartonNo == 0) ? string.Empty : objPacking.CartonNo.ToString();


        //        Literal lblDistributor = (Literal)item.FindControl("lblDistributor");
        //        lblDistributor.Text = objPacking.Distributor;

        //        Literal lblClient = (Literal)item.FindControl("lblClient");
        //        lblClient.Text = objPacking.Client;

        //        Literal lblVLName = (Literal)item.FindControl("lblVLName");
        //        lblVLName.Text = objPacking.VLName;

        //        Literal lblDescription = (Literal)item.FindControl("lblDescription");
        //        lblDescription.Text = objPacking.Pattern;

        //        Literal lblPoNo = (Literal)item.FindControl("lblPoNo");
        //        lblPoNo.Text = objPacking.OrderNumber.ToString();

        //        LinkButton lnkSplitRow = (LinkButton)item.FindControl("lnkSplitRow");
        //        Repeater rptSizeQtyView = (Repeater)item.FindControl("rptSizeQtyView");
        //        int total = 0;

        //        InvoiceOrderBO objInvoiceOrder = new InvoiceOrderBO();
        //        objInvoiceOrder.OrderDetail = (int)objPacking.OrderDetail;

        //        TextBox txtCartonAmount = (TextBox)item.FindControl("txtCartonAmount");

        //        List<InvoiceOrderBO> lstInvoiceOrders = objInvoiceOrder.SearchObjects();

        //        if (lstInvoiceOrders.Count == 0)
        //        {
        //            item.BackColor = System.Drawing.Color.AliceBlue;
        //        }

        //        if (objPacking.PackingList == 0) // duplicate
        //        {
        //            //OrderDetailQtyBO objODQty = new OrderDetailQtyBO();
        //            //objODQty.OrderDetail = objPacking.OrderDetail.Value;

        //            //List<OrderDetailQtyBO> lstODs = objODQty.SearchObjects().Where(m => m.Qty > 0).ToList();

        //            PackingListSizeQtyBO objPackListSizeQty = new PackingListSizeQtyBO();
        //            objPackListSizeQty.PackingList = parentPackingListID;

        //            List<PackingListSizeQtyBO> lstODs = objPackListSizeQty.SearchObjects().Where(m => m.Qty > 0).ToList();

        //            lstODs.ForEach(o => o.Qty = 0);
        //            lnkSplitRow.Text = "Cancel";
        //            lnkSplitRow.CommandName = "Cancel";
        //            lblParentID.Text = parentPackingListID.ToString(); // objPacking.OrderDetail.ToString();

        //            rptSizeQtyView.DataSource = lstODs;
        //            total = lstODs.Select(m => m.Qty).Sum();
        //        }
        //        else // original
        //        {
        //            lnkSplitRow.Text = "Split";
        //            lnkSplitRow.CommandName = "Duplicate";
        //            lblParentID.Text = "0";
        //            parentPackingListID = objPacking.PackingList.Value;

        //            PackingListSizeQtyBO objPackListSizeQty = new PackingListSizeQtyBO();
        //            objPackListSizeQty.PackingList = objPacking.PackingList.Value;

        //            List<PackingListSizeQtyBO> lstPackListQtys = objPackListSizeQty.SearchObjects().Where(m => m.Qty > 0).ToList();
        //            rptSizeQtyView.DataSource = lstPackListQtys;
        //            total = lstPackListQtys.Select(m => m.Qty).Sum();
        //            lnkSplitRow.Visible = total > 1;
        //        }

        //        rptSizeQtyView.DataBind();
        //        Literal lblTotal = (Literal)item.FindControl("lblTotal");
        //        lblTotal.Text = total.ToString();
        //    }
        //}

        //protected void dgPackingList_PageIndexChanged(object sender, DataGridPageChangedEventArgs e)
        //{
        //    //this.dgPackingList.CurrentPageIndex = e.NewPageIndex;
        //    //this.PopulateDataGrid();
        //}

        protected void rptSizeQtyView_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1)
            {
                Literal litHeading = (Literal)item.FindControl("litHeading");
                Label lblSize = (Label)item.FindControl("lblSize");
                TextBox txtQty = (TextBox)item.FindControl("txtQty");

                if (item.DataItem is OrderDetailQtyBO)
                {
                    OrderDetailQtyBO objClientOrderDetailOrderQty = (OrderDetailQtyBO)item.DataItem;
                    litHeading.Text = objClientOrderDetailOrderQty.objSize.SizeName;
                    lblSize.Text = objClientOrderDetailOrderQty.Size.ToString();
                    txtQty.Text = objClientOrderDetailOrderQty.Qty.ToString();
                }
                else if (item.DataItem is PackingListSizeQtyBO)
                {
                    PackingListSizeQtyBO objPackingListQty = (PackingListSizeQtyBO)item.DataItem;
                    litHeading.Text = objPackingListQty.objSize.SizeName;
                    lblSize.Text = objPackingListQty.Size.ToString();
                    txtQty.Text = objPackingListQty.Qty.ToString();
                }
            }
        }

        //protected void dgPackingList_ItemCommand(object source, DataGridCommandEventArgs e)
        //{
        //    if (e.CommandName == "Duplicate")
        //    {
        //        ValidateGrid();

        //        if (Page.IsValid)
        //        {
        //            this.ProcessForm();

        //            TextBox txtCartonAmount = (TextBox)e.Item.FindControl("txtCartonAmount");

        //            PackingListBO objPacking = new PackingListBO();
        //            objPacking.ID = int.Parse(((Literal)e.Item.FindControl("lblID")).Text);
        //            objPacking.GetObject();

        //            DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO();
        //            objDistributorClientAddress.ID = (int)objPacking.objOrderDetail.objOrder.DespatchToExistingClient;
        //            objDistributorClientAddress.GetObject();

        //            this.Source = null;
        //            this.Source = GetData();

        //            int length = (!string.IsNullOrEmpty(txtCartonAmount.Text)) ? int.Parse(txtCartonAmount.Text) : 1; //2; // user input
        //            int listIndex = Source.IndexOf(Source.Where(m => m.PackingList == objPacking.ID).SingleOrDefault());

        //            for (int i = 0; i < length; i++)
        //            {
        //                PackingListViewBO objDuplicatePacking = new PackingListViewBO();
        //                objDuplicatePacking.PackingList = 0;
        //                objDuplicatePacking.WeeklyProductionCapacity = objPacking.WeeklyProductionCapacity;
        //                objDuplicatePacking.CartonNo = objPacking.CartonNo;
        //                objDuplicatePacking.OrderDetail = objPacking.OrderDetail;
        //                objDuplicatePacking.Client = objPacking.objOrderDetail.objOrder.objClient.Name;
        //                objDuplicatePacking.Distributor = objPacking.objOrderDetail.objOrder.objDistributor.Name;
        //                objDuplicatePacking.Pattern = objPacking.objOrderDetail.objPattern.Number + " " + objPacking.objOrderDetail.objPattern.NickName;
        //                objDuplicatePacking.OrderNumber = objPacking.objOrderDetail.Order;
        //                objDuplicatePacking.VLName = objPacking.objOrderDetail.objVisualLayout.NamePrefix + " " + objPacking.objOrderDetail.objVisualLayout.NameSuffix;
        //                objDuplicatePacking.PackingTotal = 0;
        //                objDuplicatePacking.ScannedTotal = 0;
        //                //shipment data
        //                objDuplicatePacking.ShimentModeID = objPacking.objOrderDetail.objOrder.ShipmentMode;
        //                objDuplicatePacking.ShipTo = objPacking.objOrderDetail.objOrder.DespatchToExistingClient ?? 0;
        //                objDuplicatePacking.CompanyName = objDistributorClientAddress.CompanyName;
        //                objDuplicatePacking.Address = objDistributorClientAddress.Address;
        //                objDuplicatePacking.Suberb = objDistributorClientAddress.Suburb;
        //                objDuplicatePacking.State = objDistributorClientAddress.State;
        //                objDuplicatePacking.PostCode = objDistributorClientAddress.PostCode;
        //                objDuplicatePacking.Country = objDistributorClientAddress.objCountry.ShortName;
        //                objDuplicatePacking.ContactDetails = objDistributorClientAddress.ContactName + " " + objDistributorClientAddress.ContactPhone;
        //                objDuplicatePacking.IsWeeklyShipment = objPacking.objOrderDetail.objOrder.IsWeeklyShipment;
        //                objDuplicatePacking.IsAdelaideWareHouse = objPacking.objOrderDetail.objOrder.IsAdelaideWareHouse;

        //                Source.Insert(++listIndex, objDuplicatePacking);
        //            }

        //            this.PopulateDataGrid(true);
        //        }
        //    }
        //    else if (e.CommandName == "Cancel")
        //    {
        //        Source.RemoveAt(e.Item.ItemIndex);
        //        this.PopulateDataGrid();
        //    }
        //    else if (e.CommandName == "Save")
        //    {
        //        // Find Better Solution for this
        //        try
        //        {
        //            using (TransactionScope ts = new TransactionScope())
        //            {
        //                Literal lblID = (Literal)e.Item.FindControl("lblID");
        //                Literal lblParentID = (Literal)e.Item.FindControl("lblParentID");
        //                Literal lblOrderDetailID = (Literal)e.Item.FindControl("lblOrderDetailID");
        //                TextBox txtCarton = (TextBox)e.Item.FindControl("txtCarton");
        //                Repeater rptSizeQtyView = (Repeater)e.Item.FindControl("rptSizeQtyView");

        //                int packingListID = int.Parse(lblID.Text);
        //                int parentPackingListID = int.Parse(lblParentID.Text);
        //                int orderDetailID = int.Parse(lblOrderDetailID.Text);

        //                if (packingListID > 0)
        //                {
        //                    PackingListBO objPackingList = new PackingListBO(this.ObjContext);
        //                    objPackingList.ID = packingListID;
        //                    objPackingList.GetObject();

        //                    int validateTotal = 0;
        //                    foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
        //                    {
        //                        TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");
        //                        validateTotal += int.Parse(txtQty.Text);
        //                    }

        //                    if (validateTotal > 0)
        //                    {
        //                        objPackingList.CartonNo = (string.IsNullOrEmpty(txtCarton.Text)) ? 0 : int.Parse(txtCarton.Text);

        //                        foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
        //                        {
        //                            Label lblSize = (Label)rptItem.FindControl("lblSize");
        //                            TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");

        //                            PackingListSizeQtyBO objPackListSizeQty = new PackingListSizeQtyBO();
        //                            objPackListSizeQty.PackingList = packingListID;
        //                            objPackListSizeQty.Size = int.Parse(lblSize.Text);

        //                            objPackListSizeQty = objPackListSizeQty.SearchObjects().SingleOrDefault();

        //                            PackingListSizeQtyBO objPackListSizeQtyUpdate = new PackingListSizeQtyBO(this.ObjContext);
        //                            objPackListSizeQtyUpdate.ID = objPackListSizeQty.ID;
        //                            objPackListSizeQtyUpdate.GetObject();

        //                            objPackListSizeQtyUpdate.Qty = int.Parse(txtQty.Text);
        //                        }
        //                    }
        //                    else
        //                    {
        //                        foreach (PackingListSizeQtyBO obj in objPackingList.PackingListSizeQtysWhereThisIsPackingList)
        //                        {
        //                            PackingListSizeQtyBO objPackListSizeQtyDelete = new PackingListSizeQtyBO(this.ObjContext);
        //                            objPackListSizeQtyDelete.ID = obj.ID;
        //                            objPackListSizeQtyDelete.GetObject();
        //                            objPackListSizeQtyDelete.Delete();
        //                        }

        //                        objPackingList.Delete();
        //                    }
        //                }
        //                else
        //                {
        //                    int validateTotal = 0;
        //                    foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
        //                    {
        //                        TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");
        //                        validateTotal += int.Parse(txtQty.Text);
        //                    }

        //                    if (validateTotal > 0)
        //                    {
        //                        PackingListBO objPackingList = new PackingListBO();
        //                        objPackingList.ID = parentPackingListID;
        //                        objPackingList.GetObject();

        //                        PackingListBO objNewPackingList = new PackingListBO(this.ObjContext);
        //                        objNewPackingList.WeeklyProductionCapacity = objPackingList.WeeklyProductionCapacity;
        //                        objNewPackingList.CartonNo = (string.IsNullOrEmpty(txtCarton.Text)) ? 0 : int.Parse(txtCarton.Text);
        //                        objNewPackingList.Carton = objPackingList.Carton;
        //                        objNewPackingList.OrderDetail = objPackingList.OrderDetail;
        //                        objNewPackingList.Remarks = string.Empty;
        //                        objNewPackingList.Creator = objNewPackingList.Modifier = this.LoggedUser.ID;
        //                        objNewPackingList.CreatedDate = objNewPackingList.ModifiedDate = DateTime.Now;

        //                        foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
        //                        {
        //                            Label lblSize = (Label)rptItem.FindControl("lblSize");
        //                            TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");

        //                            PackingListSizeQtyBO objSizeQ = new PackingListSizeQtyBO(this.ObjContext);
        //                            objSizeQ.Size = int.Parse(lblSize.Text);
        //                            objSizeQ.Qty = int.Parse(txtQty.Text);

        //                            objNewPackingList.PackingListSizeQtysWhereThisIsPackingList.Add(objSizeQ);
        //                        }
        //                    }
        //                }

        //                this.ObjContext.SaveChanges();
        //                ts.Complete();
        //            }
        //        }
        //        catch (Exception ex)
        //        {
        //            IndicoLogging.log.Error("Error occured while saving Paking List for a Record from PackingList.aspx", ex);
        //        }
        //    }
        //}

        protected void btnProceed_Click(object sender, EventArgs e)
        {
            ValidateGrid();

            if (Page.IsValid)
            {
                this.ProcessForm();
                Response.Redirect("ViewPackingLists.aspx?WeekendDate=" + this.WeekEndDate.ToString("dd/MM/yyyy"));
            }
        }

        //protected void rptDistributor_ItemDataBound(object sender, RepeaterItemEventArgs e)
        //{
        //    RepeaterItem item = e.Item;

        //    if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, PackingListViewBO>)
        //    {
        //        List<PackingListViewBO> lstPackingListsGroup = ((IGrouping<int, PackingListViewBO>)item.DataItem).ToList();

        //        if (lstPackingListsGroup[0].ShipmentMode != null)
        //        {
        //            Literal litComapny = (Literal)item.FindControl("litComapny");
        //            litComapny.Text = lstPackingListsGroup[0].CompanyName;

        //            Literal litDate = (Literal)item.FindControl("litDate");
        //            //litDate.Text = Convert.ToDateTime(lstOrderDetailsGroup[0].ShipmentDate.ToString()).ToString("dd MMMM yyyy");

        //            Literal litAddress = (Literal)item.FindControl("litAddress");
        //            litAddress.Text = lstPackingListsGroup[0].Address;

        //            Literal litSuberb = (Literal)item.FindControl("litSuberb");
        //            litSuberb.Text = lstPackingListsGroup[0].Suberb;

        //            Literal litPostCode = (Literal)item.FindControl("litPostCode");
        //            litPostCode.Text = lstPackingListsGroup[0].State + " " + lstPackingListsGroup[0].PostCode + " , " + lstPackingListsGroup[0].Country;

        //            // Literal litCountry = (Literal)item.FindControl("litCountry");
        //            //litCountry.Text = lstOrderDetailsGroup[0].Country;

        //            Literal litContactDetails = (Literal)item.FindControl("litContactDetails");
        //            litContactDetails.Text = lstPackingListsGroup[0].ContactDetails;

        //            Repeater rptModes = (Repeater)item.FindControl("rptModes");

        //            List<IGrouping<int, PackingListViewBO>> lstModesGroup = lstPackingListsGroup.GroupBy(o => (int)o.ShimentModeID).ToList();

        //            if (lstModesGroup.Count > 0)
        //            {
        //                rptModes.DataSource = lstModesGroup;
        //                rptModes.DataBind();
        //            }

        //            // Literal litGrandTotal = (Literal)item.FindControl("litGrandTotal");
        //            // litGrandTotal.Text = "Total" + " " + total.ToString();
        //        }
        //    }
        //}

        //protected void rptModes_ItemDataBound(object sender, RepeaterItemEventArgs e)
        //{
        //    RepeaterItem item = e.Item;

        //    if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, PackingListViewBO>)
        //    {
        //        List<PackingListViewBO> lstPackingListMode = ((IGrouping<int, PackingListViewBO>)item.DataItem).ToList();

        //        RadGrid dgPackingList = (RadGrid)item.FindControl("RadPackingList");
        //        //dgPackingList.Attributes.Add("uid", lstPackingListsGroup[0].ShipTo.ToString().Trim());

        //        Literal litShipmentMode = (Literal)item.FindControl("litShipmentMode");
        //        litShipmentMode.Text = lstPackingListMode[0].ShipmentMode;

        //        if (lstPackingListMode.Count > 0)
        //        {
        //            dgPackingList.DataSource = lstPackingListMode;
        //            dgPackingList.DataBind();
        //        }
        //    }
        //}

        protected void btnSearch_ServerClick(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void RadPackingList_PageSizeChanged(object sender, Telerik.Web.UI.GridPageSizeChangedEventArgs e)
        {
            this.RebindGrid();
        }

        protected void RadPackingList_PageIndexChanged(object sender, Telerik.Web.UI.GridPageChangedEventArgs e)
        {
            this.RebindGrid();
        }

        protected void RadPackingList_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is PackingListViewBO)
                {
                    PackingListViewBO objPacking = (PackingListViewBO)item.DataItem;

                    Literal lblID = (Literal)item.FindControl("lblID");
                    lblID.Text = objPacking.PackingList.ToString();

                    Literal lblOrderDetailID = (Literal)item.FindControl("lblOrderDetailID");
                    lblOrderDetailID.Text = objPacking.OrderDetail.ToString();

                    Literal lblParentID = (Literal)item.FindControl("lblParentID");

                    TextBox txtCarton = (TextBox)item.FindControl("txtCarton");
                    txtCarton.Text = (objPacking.CartonNo == 0) ? string.Empty : objPacking.CartonNo.ToString();

                    InvoiceOrderBO objInvoiceOrder = new InvoiceOrderBO();
                    objInvoiceOrder.OrderDetail = (int)objPacking.OrderDetail;

                    TextBox txtCartonAmount = (TextBox)item.FindControl("txtCartonAmount");

                    LinkButton lnkSplitRow = (LinkButton)item.FindControl("lnkSplitRow");

                    Repeater rptSizeQtyView = (Repeater)item.FindControl("rptSizeQtyView");
                    int total = 0;

                    List<InvoiceOrderBO> lstInvoiceOrders = objInvoiceOrder.SearchObjects();

                    if (lstInvoiceOrders.Count == 0)
                    {
                        item.BackColor = System.Drawing.Color.AliceBlue;
                    }

                    if (objPacking.PackingList == 0) // duplicate
                    {
                        //OrderDetailQtyBO objODQty = new OrderDetailQtyBO();
                        //objODQty.OrderDetail = objPacking.OrderDetail.Value;

                        //List<OrderDetailQtyBO> lstODs = objODQty.SearchObjects().Where(m => m.Qty > 0).ToList();

                        PackingListSizeQtyBO objPackListSizeQty = new PackingListSizeQtyBO();
                        objPackListSizeQty.PackingList = parentPackingListID;

                        List<PackingListSizeQtyBO> lstODs = objPackListSizeQty.SearchObjects().Where(m => m.Qty > 0).ToList();

                        lstODs.ForEach(o => o.Qty = 0);
                        lnkSplitRow.Text = "Cancel";
                        lnkSplitRow.CommandName = "Cancel";
                        lblParentID.Text = parentPackingListID.ToString(); // objPacking.OrderDetail.ToString();

                        rptSizeQtyView.DataSource = lstODs;
                        total = lstODs.Select(m => m.Qty).Sum();
                        txtCartonAmount.Visible = false;
                    }
                    else // original
                    {
                        lnkSplitRow.Text = "Split";
                        lnkSplitRow.CommandName = "Duplicate";
                        lblParentID.Text = "0";
                        parentPackingListID = objPacking.PackingList.Value;

                        PackingListSizeQtyBO objPackListSizeQty = new PackingListSizeQtyBO();
                        objPackListSizeQty.PackingList = objPacking.PackingList.Value;

                        List<PackingListSizeQtyBO> lstPackListQtys = objPackListSizeQty.SearchObjects().Where(m => m.Qty > 0).ToList();
                        rptSizeQtyView.DataSource = lstPackListQtys;
                        total = lstPackListQtys.Select(m => m.Qty).Sum();
                        lnkSplitRow.Visible = total > 1;
                        txtCartonAmount.Visible = total > 1;
                    }

                    rptSizeQtyView.DataBind();
                    Literal litTotal = (Literal)item.FindControl("litTotal");
                    litTotal.Text = total.ToString();
                }

            }
        }

        protected void RadPackingList_ItemCommand(object sender, Telerik.Web.UI.GridCommandEventArgs e)
        {
            if (e.CommandName == "Duplicate")
            {
                ValidateGrid();

                if (Page.IsValid)
                {
                    this.ProcessForm();

                    TextBox txtCartonAmount = (TextBox)e.Item.FindControl("txtCartonAmount");

                    PackingListBO objPacking = new PackingListBO();
                    objPacking.ID = int.Parse(((Literal)e.Item.FindControl("lblID")).Text);
                    objPacking.GetObject();

                    DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO();
                    objDistributorClientAddress.ID = (int)objPacking.objOrderDetail.objOrder.DespatchToAddress;
                    objDistributorClientAddress.GetObject();

                    this.Source = null;
                    this.Source = GetData();

                    int length = (!string.IsNullOrEmpty(txtCartonAmount.Text)) ? int.Parse(txtCartonAmount.Text) : 1; //2; // user input
                    int listIndex = Source.IndexOf(Source.Where(m => m.PackingList == objPacking.ID).SingleOrDefault());

                    for (int i = 0; i < length; i++)
                    {
                        PackingListViewBO objDuplicatePacking = new PackingListViewBO();
                        objDuplicatePacking.PackingList = 0;
                        objDuplicatePacking.WeeklyProductionCapacity = objPacking.WeeklyProductionCapacity;
                        objDuplicatePacking.CartonNo = objPacking.CartonNo;
                        objDuplicatePacking.OrderDetail = objPacking.OrderDetail;
                        objDuplicatePacking.Client = objPacking.objOrderDetail.objOrder.objClient.Name;
                        objDuplicatePacking.Distributor = objPacking.objOrderDetail.objOrder.objDistributor.Name;
                        objDuplicatePacking.Pattern = objPacking.objOrderDetail.objPattern.Number + " " + objPacking.objOrderDetail.objPattern.NickName;
                        objDuplicatePacking.OrderNumber = objPacking.objOrderDetail.Order;
                        objDuplicatePacking.VLName = objPacking.objOrderDetail.objVisualLayout.NamePrefix + " " + objPacking.objOrderDetail.objVisualLayout.NameSuffix;
                        objDuplicatePacking.PackingTotal = 0;
                        objDuplicatePacking.ScannedTotal = 0;
                        //shipment data
                        objDuplicatePacking.ShimentModeID = objPacking.objOrderDetail.objOrder.ShipmentMode;
                        objDuplicatePacking.ShipTo = objPacking.objOrderDetail.objOrder.DespatchToAddress ?? 0;
                        objDuplicatePacking.CompanyName = objDistributorClientAddress.CompanyName;
                        objDuplicatePacking.Address = objDistributorClientAddress.Address;
                        objDuplicatePacking.Suberb = objDistributorClientAddress.Suburb;
                        objDuplicatePacking.State = objDistributorClientAddress.State;
                        objDuplicatePacking.PostCode = objDistributorClientAddress.PostCode;
                        objDuplicatePacking.Country = objDistributorClientAddress.objCountry.ShortName;
                        objDuplicatePacking.ContactDetails = objDistributorClientAddress.ContactName + " " + objDistributorClientAddress.ContactPhone;
                        objDuplicatePacking.IsWeeklyShipment = objPacking.objOrderDetail.objOrder.IsWeeklyShipment;
                        objDuplicatePacking.IsAdelaideWareHouse = objPacking.objOrderDetail.objOrder.IsAdelaideWareHouse;
                        objDuplicatePacking.ShimentModeID = objPacking.objOrderDetail.objOrder.objShipmentMode.ID;
                        objDuplicatePacking.ShipmentMode = objPacking.objOrderDetail.objOrder.objShipmentMode.Name;

                        Source.Insert(++listIndex, objDuplicatePacking);
                    }

                    this.PopulateDataGrid(true);
                }
            }
            else if (e.CommandName == "Cancel")
            {
                Source.RemoveAt(e.Item.ItemIndex);
                this.PopulateDataGrid();
            }
            else if (e.CommandName == "Save")
            {
                // Find Better Solution for this
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        Literal lblID = (Literal)e.Item.FindControl("lblID");
                        Literal lblParentID = (Literal)e.Item.FindControl("lblParentID");
                        Literal lblOrderDetailID = (Literal)e.Item.FindControl("lblOrderDetailID");
                        TextBox txtCarton = (TextBox)e.Item.FindControl("txtCarton");
                        Repeater rptSizeQtyView = (Repeater)e.Item.FindControl("rptSizeQtyView");

                        int packingListID = int.Parse(lblID.Text);
                        int parentPackingListID = int.Parse(lblParentID.Text);
                        int orderDetailID = int.Parse(lblOrderDetailID.Text);

                        if (packingListID > 0)
                        {
                            PackingListBO objPackingList = new PackingListBO(this.ObjContext);
                            objPackingList.ID = packingListID;
                            objPackingList.GetObject();

                            int validateTotal = 0;
                            foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
                            {
                                TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");
                                validateTotal += int.Parse(txtQty.Text);
                            }

                            if (validateTotal > 0)
                            {
                                objPackingList.CartonNo = (string.IsNullOrEmpty(txtCarton.Text)) ? 0 : int.Parse(txtCarton.Text);

                                foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
                                {
                                    Label lblSize = (Label)rptItem.FindControl("lblSize");
                                    TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");

                                    PackingListSizeQtyBO objPackListSizeQty = new PackingListSizeQtyBO();
                                    objPackListSizeQty.PackingList = packingListID;
                                    objPackListSizeQty.Size = int.Parse(lblSize.Text);

                                    objPackListSizeQty = objPackListSizeQty.SearchObjects().SingleOrDefault();

                                    PackingListSizeQtyBO objPackListSizeQtyUpdate = new PackingListSizeQtyBO(this.ObjContext);
                                    objPackListSizeQtyUpdate.ID = objPackListSizeQty.ID;
                                    objPackListSizeQtyUpdate.GetObject();

                                    objPackListSizeQtyUpdate.Qty = int.Parse(txtQty.Text);
                                }
                            }
                            else
                            {
                                foreach (PackingListSizeQtyBO obj in objPackingList.PackingListSizeQtysWhereThisIsPackingList)
                                {
                                    PackingListSizeQtyBO objPackListSizeQtyDelete = new PackingListSizeQtyBO(this.ObjContext);
                                    objPackListSizeQtyDelete.ID = obj.ID;
                                    objPackListSizeQtyDelete.GetObject();
                                    objPackListSizeQtyDelete.Delete();
                                }

                                objPackingList.Delete();
                            }
                        }
                        else
                        {
                            int validateTotal = 0;
                            foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
                            {
                                TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");
                                validateTotal += int.Parse(txtQty.Text);
                            }

                            if (validateTotal > 0)
                            {
                                PackingListBO objPackingList = new PackingListBO();
                                objPackingList.ID = parentPackingListID;
                                objPackingList.GetObject();

                                PackingListBO objNewPackingList = new PackingListBO(this.ObjContext);
                                objNewPackingList.WeeklyProductionCapacity = objPackingList.WeeklyProductionCapacity;
                                objNewPackingList.CartonNo = (string.IsNullOrEmpty(txtCarton.Text)) ? 0 : int.Parse(txtCarton.Text);
                                objNewPackingList.Carton = objPackingList.Carton;
                                objNewPackingList.OrderDetail = objPackingList.OrderDetail;
                                objNewPackingList.Remarks = string.Empty;
                                objNewPackingList.Creator = objNewPackingList.Modifier = this.LoggedUser.ID;
                                objNewPackingList.CreatedDate = objNewPackingList.ModifiedDate = DateTime.Now;

                                foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
                                {
                                    Label lblSize = (Label)rptItem.FindControl("lblSize");
                                    TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");

                                    PackingListSizeQtyBO objSizeQ = new PackingListSizeQtyBO(this.ObjContext);
                                    objSizeQ.Size = int.Parse(lblSize.Text);
                                    objSizeQ.Qty = int.Parse(txtQty.Text);

                                    objNewPackingList.PackingListSizeQtysWhereThisIsPackingList.Add(objSizeQ);
                                }
                            }
                        }

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while saving Paking List for a Record from PackingList.aspx", ex);
                }
            }
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.RebindGrid();
            }
        }

        protected void RadPackingList_SortCommand(object sender, Telerik.Web.UI.GridSortCommandEventArgs e)
        {
            this.RebindGrid();
        }

        protected void RadPackingList_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.RebindGrid();
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            litHeaderText.Text = this.ActivePage.Heading;
            this.Source = null;

            this.ddlShipmentMode.Items.Clear();
            this.ddlShipmentMode.Items.Add(new ListItem("Select a Shipment Mode", "0"));
            List<ShipmentModeBO> lstShipmentModes = (new ShipmentModeBO()).GetAllObject().ToList();
            foreach (ShipmentModeBO sm in lstShipmentModes)
            {
                this.ddlShipmentMode.Items.Add(new ListItem(sm.Name, sm.ID.ToString()));
            }

            this.ddlShippingAddress.Items.Clear();
            this.ddlShippingAddress.Items.Add(new ListItem("Select Shipping Address", "0"));
            List<ReturnShippingAddressWeekendDateBO> lstShippingAddresses = PackingListBO.GetShippingAddressWeekendDate(this.WeekEndDate);
            foreach (ReturnShippingAddressWeekendDateBO sa in lstShippingAddresses)
            {
                this.ddlShippingAddress.Items.Add(new ListItem(sa.CompanyName, sa.ID.ToString()));
            }

            this.PopulateDataGrid();
        }

        private void PopulateDataGrid(bool isduplicate = false)
        {
            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvEmptyContentPackingList.Visible = false;

            List<PackingListViewBO> lstPackList = new List<PackingListViewBO>();

            lstPackList = (isduplicate) ? Source : GetData(); // objPack.SearchObjects().Where(m => m.objWeeklyProductionCapacity.WeekendDate == WeekEndDate).ToList();

            if (lstPackList.Count > 0)
            {
                //this.dgPackingList.DataSource = lstPackList;
                //this.dgPackingList.DataBind();

                if (int.Parse(this.ddlShipmentMode.SelectedValue) > 0 || int.Parse(this.ddlShippingAddress.SelectedValue) > 0)
                {
                    this.RadPackingList.DataSource = null;
                    this.RadPackingList.DataBind();

                    this.RadPackingList.DataSource = lstPackList;//.GroupBy(o => (int)o.ShipTo).ToList();
                    this.RadPackingList.DataBind();
                    this.dvEmptyContentPackingList.Visible = false;
                    this.RadPackingList.Visible = true;
                    this.dvButton.Visible = true;

                    Source = lstPackList;
                }
                else
                {
                    this.dvEmptyContentPackingList.Visible = true;
                    this.litErrorMeassage.Text = "Please select Shipment Mode and Shipping Address";
                    this.RadPackingList.Visible = false;
                    this.dvButton.Visible = false;
                }

                this.dvDataContent.Visible = true;
            }
            else
            {
                if (int.Parse(this.ddlShipmentMode.SelectedValue) == 0 && int.Parse(this.ddlShippingAddress.SelectedValue) == 0)
                {

                    if (this.WeekEndDate != new DateTime(1100, 1, 1))
                    {
                        try
                        {
                            ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                            objReturnInt = PackingListBO.InsertPackingList(this.WeekEndDate, this.LoggedUser.ID);

                            if (objReturnInt.RetVal == 0)
                            {
                                IndicoLogging.log.Error("PopulateDataGrid() : Error occured while Inserting the PackingList PackingList.aspx, SPC_CreatingPackingList");
                            }
                        }
                        catch (Exception ex)
                        {

                            IndicoLogging.log.Error("PopulateDataGrid() : Error occured while Inserting the PackingList PackingList.aspx", ex);
                        }

                       // this.PopulateDataGrid();
                    }
                    else
                    {
                        this.dvEmptyContent.Visible = true;
                    }
                }
                else
                {
                    this.dvEmptyContentPackingList.Visible = true;
                    this.litErrorMeassage.Text = "No Packing list details";
                    this.RadPackingList.Visible = false;
                    this.dvButton.Visible = false;
                }
            }
        }

        private List<PackingListViewBO> GetData()
        {
            var PackingLists = new List<PackingListViewBO>();

            //NNM
            //if (Source != null && Source.Count > 0)
            // {
            //PackingLists = Source;
            // }
            // else
            // {                
            PackingLists = PackingListBO.GetPackingList(this.WeekEndDate, int.Parse(this.ddlShipmentMode.SelectedValue), int.Parse(this.ddlShippingAddress.SelectedValue)); //.GroupBy(o => (int)o.ShipTo).ToList();                                                                
            //  }

            //Source = PackingLists;

            return PackingLists;
        }

        private void ValidateGrid()
        {
            bool isValid = true;
            string message = string.Empty;
            string vlnumbers = string.Empty;

            List<int> lstExistCarton = null;
            List<int> lsttotalcarton = new List<int>();

            try
            {
                List<ODQty> lstEditedValues = new List<ODQty>();
                List<ODQty> lstExistedValues = new List<ODQty>();
                List<ReturnWeeklyOrderDetailQtysViewBO> lstWeeklyOrderDetailsQtys = new List<ReturnWeeklyOrderDetailQtysViewBO>();
                lstWeeklyOrderDetailsQtys = OrderDetailQtyBO.WeeklyOrderDetailQtys(this.WeekEndDate);

                foreach (ReturnWeeklyOrderDetailQtysViewBO WeeklyOrderDetailsQty in lstWeeklyOrderDetailsQtys)
                {
                    ODQty odQty = new ODQty();
                    odQty.OrderDetailID = WeeklyOrderDetailsQty.OrderDetail.Value;

                    odQty.LstSizeQtys.Add(new KeyValuePair<int, int>(WeeklyOrderDetailsQty.SizeID.Value, WeeklyOrderDetailsQty.Quantity.Value));
                    lstExistedValues.Add(odQty);
                }

                List<KeyValuePair<int, int>> lstCartonOD = new List<KeyValuePair<int, int>>();

                //foreach (RepeaterItem rptDistributorItem in rptDistributor.Items)
                //{
                //Repeater rptModes = (Repeater)rptDistributorItem.FindControl("rptModes");

                //foreach (RepeaterItem item in rptModes.Items)
                //{
                // RadGrid dgPackingList = (RadGrid)item.FindControl("RadPackingList");

                lstExistCarton = new List<int>();

                foreach (GridDataItem dgItem in RadPackingList.Items)
                {
                    Literal lblID = (Literal)dgItem.FindControl("lblID");
                    Literal lblParentID = (Literal)dgItem.FindControl("lblParentID");
                    Literal lblOrderDetailID = (Literal)dgItem.FindControl("lblOrderDetailID");
                    TextBox txtCarton = (TextBox)dgItem.FindControl("txtCarton");
                    Repeater rptSizeQtyView = (Repeater)dgItem.FindControl("rptSizeQtyView");

                    int packingListID = int.Parse(lblID.Text);
                    int parentPackingListID = int.Parse(lblParentID.Text);
                    int orderDetailID = int.Parse(lblOrderDetailID.Text);
                    int cartonNo = int.Parse(string.IsNullOrEmpty(txtCarton.Text) ? 0.ToString() : txtCarton.Text);

                    // Check carton number Text box is Empty
                    if (!string.IsNullOrEmpty(txtCarton.Text))
                    {
                        lstExistCarton.Add(int.Parse(txtCarton.Text));
                    }

                    if (!lstCartonOD.Where(m => m.Key == orderDetailID && m.Value == cartonNo).Any())
                    {
                        lstCartonOD.Add(new KeyValuePair<int, int>(orderDetailID, cartonNo));
                    }
                    else
                    {
                        // user has split an order detail and still uses same carton number.. 
                        message = "User has split an Order detail and still uses same Carton";
                        isValid = false;
                        break;
                    }

                    if (packingListID > 0)
                    {
                        ODQty odQty = new ODQty();
                        odQty.OrderDetailID = orderDetailID;

                        foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
                        {
                            Label lblSize = (Label)rptItem.FindControl("lblSize");
                            TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");

                            odQty.LstSizeQtys.Add(new KeyValuePair<int, int>(int.Parse(lblSize.Text), int.Parse(txtQty.Text)));
                        }

                        lstEditedValues.Add(odQty);
                    }
                    else
                    {
                        ODQty odQty = new ODQty();
                        odQty.OrderDetailID = orderDetailID;

                        foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
                        {
                            Label lblSize = (Label)rptItem.FindControl("lblSize");
                            TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");

                            odQty.LstSizeQtys.Add(new KeyValuePair<int, int>(int.Parse(lblSize.Text), int.Parse(txtQty.Text)));
                        }

                        lstEditedValues.Add(odQty);
                    }
                }
                //}

                // Check Duplicate Carton No
                if (lsttotalcarton.Count > 0)
                {
                    //NNM
                    //if (lsttotalcarton.Intersect(lstExistCarton).Count() > 0) 
                    //{
                    //    //var except = lsttotalcarton.Except(lstexistCarton);
                    //    message = "Same Carton No. use in Diffrent Address";
                    //    isValid = false;
                    //    break;
                    //}
                    //else
                    //{
                    lsttotalcarton.AddRange(lstExistCarton.Distinct());
                    //}
                }
                else
                {
                    //lstexistCarton.Distinct();
                    lsttotalcarton.AddRange(lstExistCarton.Distinct());
                }
                //}



                if (isValid)
                {
                    List<ODQty> lstExisted = lstExistedValues.OrderBy(x => x.OrderDetailID).ToList();

                    foreach (ODQty odExistedQty in lstExisted)
                    {
                        IEnumerable<IGrouping<int, ODQty>> lstEdited = lstEditedValues.GroupBy(x => x.OrderDetailID);

                        foreach (IGrouping<int, ODQty> odEditedQty in lstEdited)
                        {
                            if (odEditedQty.Key == odExistedQty.OrderDetailID)
                            {
                                foreach (KeyValuePair<int, int> sizeQty in odExistedQty.LstSizeQtys)
                                {
                                    List<KeyValuePair<int, int>> LstEditedSizeQtys = new List<KeyValuePair<int, int>>();

                                    foreach (ODQty item in odEditedQty)
                                    {
                                        foreach (KeyValuePair<int, int> keyValue in item.LstSizeQtys)
                                        {
                                            LstEditedSizeQtys.Add(keyValue);
                                        }
                                    }

                                    if (sizeQty.Value != LstEditedSizeQtys.Where(m => m.Key == sizeQty.Key).Sum(m => m.Value))
                                    {
                                        //packing list order detail qty total values are less than order detail qty total values
                                        message = "Packing list Qty total should be equal to Order detail Qty total";
                                        isValid = false;

                                        int vl = (new OrderDetailBO()).SearchObjects().Where(o => o.ID == odExistedQty.OrderDetailID).Select(o => o.VisualLayout.Value).SingleOrDefault();

                                        VisualLayoutBO objVL = new VisualLayoutBO();
                                        objVL.ID = vl;
                                        objVL.GetObject();

                                        vlnumbers = objVL.NamePrefix + ",";
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                isValid = false;
                message = ex.Message;
            }

            CustomValidator cv = new CustomValidator();
            cv.IsValid = isValid;
            cv.ErrorMessage = message;
            //cv.ErrorMessage = "No orders have been added";

            if (!string.IsNullOrEmpty(vlnumbers))
            {
                this.hdnVlNumbers.Value = vlnumbers;
            }

            Page.Validators.Add(cv);
        }

        private void ProcessForm()
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    //foreach (RepeaterItem rptDistributorItem in rptDistributor.Items)
                    //{
                    //Repeater rptModes = (Repeater)rptDistributorItem.FindControl("rptModes");

                    //foreach (RepeaterItem item in rptModes.Items)
                    //{
                    //RadGrid dgPackingList = (RadGrid)item.FindControl("RadPackingList");

                    foreach (GridDataItem dgItem in RadPackingList.Items)
                    {
                        Literal lblID = (Literal)dgItem.FindControl("lblID");
                        Literal lblParentID = (Literal)dgItem.FindControl("lblParentID");
                        Literal lblOrderDetailID = (Literal)dgItem.FindControl("lblOrderDetailID");
                        TextBox txtCarton = (TextBox)dgItem.FindControl("txtCarton");
                        Repeater rptSizeQtyView = (Repeater)dgItem.FindControl("rptSizeQtyView");

                        int packingListID = int.Parse(lblID.Text);
                        int parentPackingListID = int.Parse(lblParentID.Text);
                        int orderDetailID = int.Parse(lblOrderDetailID.Text);

                        if (packingListID > 0)
                        {
                            PackingListBO objPackingList = new PackingListBO(this.ObjContext);
                            objPackingList.ID = packingListID;
                            objPackingList.GetObject();

                            int validateTotal = 0;
                            foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
                            {
                                TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");
                                validateTotal += int.Parse(txtQty.Text);
                            }

                            if (validateTotal > 0)
                            {
                                objPackingList.CartonNo = (string.IsNullOrEmpty(txtCarton.Text)) ? 0 : int.Parse(txtCarton.Text);

                                foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
                                {
                                    Label lblSize = (Label)rptItem.FindControl("lblSize");
                                    TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");

                                    PackingListSizeQtyBO objPackListSizeQty = new PackingListSizeQtyBO();
                                    objPackListSizeQty.PackingList = packingListID;
                                    objPackListSizeQty.Size = int.Parse(lblSize.Text);

                                    objPackListSizeQty = objPackListSizeQty.SearchObjects().SingleOrDefault();

                                    PackingListSizeQtyBO objPackListSizeQtyUpdate = new PackingListSizeQtyBO(this.ObjContext);
                                    objPackListSizeQtyUpdate.ID = objPackListSizeQty.ID;
                                    objPackListSizeQtyUpdate.GetObject();

                                    objPackListSizeQtyUpdate.Qty = int.Parse(txtQty.Text);
                                }
                            }
                            else
                            {
                                foreach (PackingListSizeQtyBO obj in objPackingList.PackingListSizeQtysWhereThisIsPackingList)
                                {
                                    PackingListSizeQtyBO objPackListSizeQtyDelete = new PackingListSizeQtyBO(this.ObjContext);
                                    objPackListSizeQtyDelete.ID = obj.ID;
                                    objPackListSizeQtyDelete.GetObject();
                                    objPackListSizeQtyDelete.Delete();
                                }

                                objPackingList.Delete();
                            }
                        }
                        else
                        {
                            int validateTotal = 0;
                            foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
                            {
                                TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");
                                validateTotal += int.Parse(txtQty.Text);
                            }

                            if (validateTotal > 0)
                            {
                                PackingListBO objPackingList = new PackingListBO();
                                objPackingList.ID = parentPackingListID;
                                objPackingList.GetObject();

                                PackingListBO objNewPackingList = new PackingListBO(this.ObjContext);
                                objNewPackingList.WeeklyProductionCapacity = objPackingList.WeeklyProductionCapacity;
                                objNewPackingList.CartonNo = (string.IsNullOrEmpty(txtCarton.Text)) ? 0 : int.Parse(txtCarton.Text);
                                objNewPackingList.Carton = objPackingList.Carton;
                                objNewPackingList.OrderDetail = objPackingList.OrderDetail;
                                objNewPackingList.Remarks = string.Empty;
                                objNewPackingList.Creator = objNewPackingList.Modifier = this.LoggedUser.ID;
                                objNewPackingList.CreatedDate = objNewPackingList.ModifiedDate = DateTime.Now;

                                foreach (RepeaterItem rptItem in rptSizeQtyView.Items)
                                {
                                    Label lblSize = (Label)rptItem.FindControl("lblSize");
                                    TextBox txtQty = (TextBox)rptItem.FindControl("txtQty");
                                    int newQty = int.Parse(txtQty.Text);

                                    if (newQty > 0)
                                    {
                                        PackingListSizeQtyBO objSizeQ = new PackingListSizeQtyBO(this.ObjContext);
                                        objSizeQ.Size = int.Parse(lblSize.Text);
                                        objSizeQ.Qty = newQty;

                                        objNewPackingList.PackingListSizeQtysWhereThisIsPackingList.Add(objSizeQ);
                                    }
                                }
                            }
                        }
                    }

                    // }
                    //}

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }

            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving Packing list Details From the PackingList.aspx Page", ex);
            }
        }

        private void RebindGrid()
        {
            if (Source != null)
            {
                this.RadPackingList.DataSource = Source;//.GroupBy(o => (int)o.ShipTo).ToList();
                this.RadPackingList.DataBind();
            }
        }

        #endregion

        #region Internal Class

        public class ODQty
        {
            public int OrderDetailID;
            public List<KeyValuePair<int, int>> LstSizeQtys;

            public ODQty()
            {
                LstSizeQtys = new List<KeyValuePair<int, int>>();
            }
        }

        #endregion
    }
}