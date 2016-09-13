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
using System.Threading;
using Telerik.Web.UI;

using Indico.Common;
using Indico.BusinessObjects;
using System.Web.Services;

namespace Indico
{
    public partial class AddEditOrder : IndicoPage
    {
        #region enums

        #endregion

        #region Fields

        private int urlQueryID = -1;
        private int urlVisualLayoutID = -1;
        private int urlArtWorkID = -1;
        private int urlQueryReservationID = -1;
        private int orderID = -1;
        private int distributorid = -1;
        private int billingAddress = 0;
        private int newClient = 0;
        private int despatchAddress = 0;
        private int courierAddress = 0;
        private string namenumberFilePath = string.Empty;
        private List<OrderDetail> listOrderDetails;

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

                //if (Request.QueryString["vln"] != null)
                //{
                //    urlVisualLayoutID = Convert.ToInt32(Request.QueryString["vln"].ToString());
                //}

                return urlQueryID;
            }
        }

        protected int VisualLayoutID
        {
            get
            {
                return urlVisualLayoutID;
            }
        }

        protected int ArtWorkID
        {
            get
            {
                return urlArtWorkID;
            }
        }

        protected int QueryReservationID
        {
            get
            {
                if (urlQueryReservationID > -1)
                    return urlQueryReservationID;

                urlQueryReservationID = 0;
                if (Request.QueryString["rid"] != null)
                {
                    urlQueryReservationID = Convert.ToInt32(Request.QueryString["rid"].ToString());
                }
                return urlQueryReservationID;
            }
        }

        protected int OrderID
        {
            get
            {
                orderID = 0;

                if (Request.QueryString["id"] != null)
                {
                    orderID = Convert.ToInt32(Request.QueryString["id"].ToString());
                }
                else if (Session["OrderID"] != null)
                {
                    orderID = int.Parse(Session["OrderID"].ToString());
                }

                return orderID;
            }
            set
            {
                Session["OrderID"] = value;
            }
        }

        private List<OrderDetail> ListOrderDetails
        {
            get
            {
                listOrderDetails = new List<OrderDetail>();

                if (Session["ListOrderDetails"] != null)
                {
                    listOrderDetails = (List<OrderDetail>)(Session["ListOrderDetails"]);
                }

                return listOrderDetails;
            }
            set
            {
                Session["ListOrderDetails"] = value;
            }
        }

        public bool IsNotRefreshed
        {
            get
            {
                return (Session["IsPostBack"].ToString() == ViewState["IsPostBack"].ToString());
            }
        }

        protected int DistributorID
        {
            get
            {
                if (distributorid > -1)
                    return distributorid;

                distributorid = 0;
                if (Request.QueryString["dir"] != null)
                {
                    distributorid = Convert.ToInt32(Request.QueryString["dir"].ToString());
                }
                else if (LoggedUser.IsDirectSalesPerson)
                {
                    distributorid = this.Distributor.ID;
                }

                return distributorid;
            }
        }

        private string NameNumberFilePath
        {
            get
            {
                if (ViewState["NameNumberFilePath"] != null)
                {
                    namenumberFilePath = (string)ViewState["NameNumberFilePath"].ToString();
                }

                return namenumberFilePath;
            }
            set
            {
                ViewState["NameNumberFilePath"] = value;
            }
        }

        #endregion

        #region Constructors

        #endregion

        #region Events

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateControls(true);
            }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            //Page Refresh
            Session["IsPostBack"] = Server.UrlEncode(Guid.NewGuid().ToString());
            ViewState["IsPostBack"] = Session["IsPostBack"];
        }

        protected void rptSizeQty_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeDetails)
            {
                SizeDetails objSize = (SizeDetails)item.DataItem;

                HiddenField hdnQtyID = (HiddenField)item.FindControl("hdnQtyID");
                hdnQtyID.Value = objSize.OrderDetailsQty.ToString();

                Literal litHeading = (Literal)item.FindControl("litHeading");
                litHeading.Text = objSize.SizeName;

                TextBox txtQty = (TextBox)item.FindControl("txtQty");
                txtQty.Text = objSize.Value.ToString();
                txtQty.Attributes.Add("Size", objSize.Size.ToString());
            }
            /*else if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objClientOrderQty = (OrderDetailQtyBO)item.DataItem;

                HiddenField hdnQtyID = (HiddenField)item.FindControl("hdnQtyID");
                hdnQtyID.Value = objClientOrderQty.ID.ToString();

                Literal litHeading = (Literal)item.FindControl("litHeading");
                litHeading.Text = objClientOrderQty.objSize.SizeName;

                TextBox txtQty = (TextBox)item.FindControl("txtQty");
                txtQty.Text = objClientOrderQty.Qty.ToString();
                txtQty.Attributes.Add("Size", objClientOrderQty.Size.ToString());
            }*/
        }

        protected void rptSizeQtyView_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objClientOrderDetailOrderQty = (OrderDetailQtyBO)item.DataItem;

                Literal litHeading = (Literal)item.FindControl("litHeading");
                litHeading.Text = objClientOrderDetailOrderQty.objSize.SizeName;

                Label lblQty = (Label)item.FindControl("lblQty");
                lblQty.Text = objClientOrderDetailOrderQty.Qty.ToString();
            }
        }

        protected void dgOrderItems_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is OrderDetail)
            {
                //ReturnOrderDetailsIndicoPriceViewBO objOrderDetail = (ReturnOrderDetailsIndicoPriceViewBO)item.DataItem;
                OrderDetail objOrderDetail = (OrderDetail)item.DataItem;

                Literal lblOrderType = (Literal)item.FindControl("lblOrderType");
                lblOrderType.Text = objOrderDetail.OrderTypeName;

                Literal lblVLNumber = (Literal)item.FindControl("lblVLNumber");
                lblVLNumber.Text = (string.IsNullOrEmpty(objOrderDetail.VisualLayoutName) ? string.Empty : objOrderDetail.VisualLayoutName + " / ")
                    + objOrderDetail.PatternName + " / " + objOrderDetail.FabricName;

                HtmlAnchor ancVLImage = (HtmlAnchor)item.FindControl("ancVLImage");
                HtmlGenericControl ivlimageView = (HtmlGenericControl)item.FindControl("ivlimageView");

                ancVLImage.HRef = IndicoPage.GetVLImagePath(objOrderDetail.VisualLayout);
                if (File.Exists(Server.MapPath(ancVLImage.HRef)))
                {
                    ancVLImage.Attributes.Add("class", "btn-link preview");
                    ivlimageView.Attributes.Add("class", "icon-eye-open");
                    List<float> lstVLImageDimensions = (new ImageProcess()).GetResizedImageDimension(960, 720, 420, 360);
                    if (lstVLImageDimensions.Count > 0)
                    {
                        ancVLImage.Attributes.Add("height", lstVLImageDimensions[0].ToString());
                        ancVLImage.Attributes.Add("width", lstVLImageDimensions[1].ToString());
                    }
                }
                else
                {
                    ancVLImage.Title = "Main Visual Layout Image Not Found";
                    ivlimageView.Attributes.Add("class", "icon-eye-close");
                }

                //OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                //objOrderDetailQty.OrderDetail = objOrderDetail.ID;

                Repeater rptSizeQtyView = (Repeater)item.FindControl("rptSizeQtyView");
                rptSizeQtyView.DataSource = objOrderDetail.ListQtys; // objOrderDetailQty.SearchObjects();
                rptSizeQtyView.DataBind();

                Literal lblOdNotes = (Literal)item.FindControl("lblOdNotes");
                lblOdNotes.Text = objOrderDetail.OrderDetailNotes;

                Literal lblVlNotes = (Literal)item.FindControl("lblVlNotes");
                //lblVlNotes.Text = objOrderDetail.objVisualLayout.Description;

                HtmlAnchor ancNameNumberFile = (HtmlAnchor)item.FindControl("ancNameNumberFile");
                HtmlGenericControl iNameNumberFile = (HtmlGenericControl)item.FindControl("iNameNumberFile");

                string NNFilePath = objOrderDetail.NameAndNumbersFilePath; // GetNameNumberFilePath(objOrderDetail.ID);
                iNameNumberFile.Attributes.Add("class", File.Exists(NNFilePath) ? "icon-ok" : "icon-remove");

                HtmlAnchor ancDownloadNameAndNumberFile = (HtmlAnchor)item.FindControl("ancDownloadNameAndNumberFile");
                if (File.Exists(NNFilePath))
                    ancDownloadNameAndNumberFile.Attributes.Add("downloadUrl", NNFilePath);
                else
                    ancDownloadNameAndNumberFile.Visible = false;

                //HtmlAnchor ancLabelImagePreview = (HtmlAnchor)item.FindControl("ancLabelImagePreview");
                HtmlGenericControl ilabelimageView = (HtmlGenericControl)item.FindControl("ilabelimageView");

                //string imagePath = GetLabelImagePath((int)objOrderDetail.OrderDetail);
                //if (!string.IsNullOrEmpty(imagePath))
                //{
                //    if (!File.Exists(Server.MapPath(imagePath)))
                //    {
                //        imagePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                //    }

                //    ancLabelImagePreview.HRef = imagePath;
                //    System.Drawing.Image vlLabel = System.Drawing.Image.FromFile(Server.MapPath(imagePath));
                //    SizeF imageLabel = vlLabel.PhysicalDimension;
                //    vlLabel.Dispose();

                //    ancLabelImagePreview.Attributes.Add("class", "btn-link preview");
                //    ilabelimageView.Attributes.Add("class", "icon-eye-open");

                //    List<float> lstLabelImageDimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(imageLabel.Width)), Convert.ToInt32(Math.Abs(imageLabel.Height)), 218);

                //    if (lstLabelImageDimensions.Count > 0)
                //    {
                //        ancLabelImagePreview.Attributes.Add("height", lstLabelImageDimensions[0].ToString());
                //        ancLabelImagePreview.Attributes.Add("width", lstLabelImageDimensions[1].ToString());
                //    }
                //}
                //else
                //{
                //    ancLabelImagePreview.Title = "Label Image Not Found";
                //    ilabelimageView.Attributes.Add("class", "icon-eye-close");
                //}

                //HtmlAnchor ancDownloadLabel = (HtmlAnchor)item.FindControl("ancDownloadLabel");
                //if (File.Exists(Server.MapPath(imagePath)))
                //    ancDownloadLabel.Attributes.Add("downloadUrl", Server.MapPath(imagePath));
                //else
                //    ancDownloadLabel.Visible = false;

                HtmlAnchor linkEdit = (HtmlAnchor)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objOrderDetail.ID.ToString());
                linkEdit.Attributes.Add("index", objOrderDetail.Index.ToString());

                //OrderDetailBO objOD = new OrderDetailBO();
                //objOD.ID = objOrderDetail.ID;
                //objOD.GetObject();

                // linkEdit.Visible = (objOD.PackingListsWhereThisIsOrderDetail.Count > 0) ? false : true;

                //Literal litPrice = (Literal)item.FindControl("litPrice"); //vl.HasValue ? vl.Value : 0, aw.HasValue ? aw.Value : 0
                //litPrice.Text = IndicoPage.CalculateIndimanPricePerVL(objOD.Pattern, objOD.FabricCode, objOrderDetail.Quantity ?? 0).ToString("0.00");

                VisualLayoutBO objVL = new VisualLayoutBO();
                objVL.ID = objOrderDetail.VisualLayout;
                objVL.GetObject();

                Literal litPocket = (Literal)item.FindControl("litPocket");
                litPocket.Text = ((objVL.PocketType ?? 0) > 0) ? objVL.objPocketType.Name : string.Empty;

                Literal lblQty = (Literal)item.FindControl("lblQty");
                lblQty.Text = objOrderDetail.ListQtys.Sum(m => m.Qty).ToString();

                Literal lblSurcharge = (Literal)item.FindControl("lblSurcharge");
                lblSurcharge.Text = objOrderDetail.SurCharge;

                Label lblTotal = (Label)item.FindControl("lblTotal");

                decimal price = 0;
                decimal.TryParse(objOrderDetail.EditedPrice, out price);

                //lblTotal.Text = (objOrderDetail.EditedPrice != (decimal)0.00) ? Convert.ToDecimal((Convert.ToDecimal(objOrderDetail.EditedPrice * (1 + (decimal)(objOD.Surcharge / (decimal)100))) * objOrderDetail.Quantity).ToString()).ToString("0.00") : "0.00";
                decimal surcharge = string.IsNullOrEmpty(objOrderDetail.SurCharge) ? 0 : decimal.Parse(objOrderDetail.SurCharge);
                lblTotal.Text = (price != (decimal)0.00) ? Convert.ToDecimal((Convert.ToDecimal(price * (1 + (decimal)(surcharge / (decimal)100))) * objOrderDetail.ListQtys.Sum(m => m.Qty)).ToString()).ToString("0.00") : "0.00";

                //TextBox txtPercentage = (TextBox)item.FindControl("txtPercentage");
                TextBox txtEditedPrice = (TextBox)item.FindControl("txtEditedPrice");
                txtEditedPrice.Enabled = false;
                txtEditedPrice.Text = "$" + ((objOrderDetail.EditedPrice != null && price != 0) ? Convert.ToDecimal(objOrderDetail.EditedPrice.ToString()).ToString("0.00")
                    : "0.00");

                //TextBox txtPriceRemarks = (TextBox)item.FindControl("txtPriceRemarks");
                //txtPriceRemarks.Text = objOrderDetail.EditedPriceRemarks;
                bool isDeleteEnabled = true;
                if (objOrderDetail.Order > 0)
                {
                    OrderBO objOrder = new OrderBO();
                    objOrder.ID = (int)objOrderDetail.Order;
                    objOrder.GetObject();

                    OrderStatus currentStatus = this.GetOrderStatus(objOrder.Status);
                    isDeleteEnabled = (this.LoggedUser.IsDirectSalesPerson && currentStatus == OrderStatus.New)
                                        || ((this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) && currentStatus == OrderStatus.New)
                                        || ((this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator) && currentStatus == OrderStatus.DistributorSubmitted)
                                        || ((this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator) && currentStatus == OrderStatus.CoordinatorSubmitted);
                    //|| ((this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator) && currentStatus == OrderStatus.IndimanSubmitted);
                }

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objOrderDetail.ID.ToString());
                linkEdit.Attributes.Add("index", objOrderDetail.Index.ToString());
                linkDelete.Visible = isDeleteEnabled; // (objOrder.objCreator.IsDistributor == false && (GetOrderStatus(objOrder.Status) == OrderStatus.New || GetOrderStatus(objOrder.Status) == OrderStatus.IndimanSubmitted));

                LinkButton libtnSaveRemarks = (LinkButton)item.FindControl("libtnSaveRemarks");
                libtnSaveRemarks.Attributes.Add("qid", objOrderDetail.ID.ToString());
                linkEdit.Attributes.Add("index", objOrderDetail.Index.ToString());

                HyperLink linkCancelDetail = (HyperLink)item.FindControl("linkCancelDetail");
                linkCancelDetail.Attributes.Add("qid", objOrderDetail.ID.ToString());
                linkEdit.Attributes.Add("index", objOrderDetail.Index.ToString());
                linkCancelDetail.Visible = (objOrderDetail.StatusID == 15 || objOrderDetail.StatusID == 16 || objOrderDetail.StatusID == 7) ? false : true;

                Literal litDetailStatus = (Literal)item.FindControl("litDetailStatus");
                litDetailStatus.Text = "<span class=\"label label-" + objOrderDetail.Status.ToLower().Replace(" ", string.Empty).Trim() + "\">" + objOrderDetail.Status + "</span>";
            }
        }

        protected void btnDeleteOrderItem_Click(object sender, EventArgs e)
        {
            int orderDetailId = int.Parse(hdnSelectedID.Value);

            if (orderDetailId > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        OrderDetailBO objClientOrderDetail = new OrderDetailBO(ObjContext);
                        objClientOrderDetail.ID = orderDetailId;
                        objClientOrderDetail.GetObject();

                        foreach (PackingListBO pl in objClientOrderDetail.PackingListsWhereThisIsOrderDetail)
                        {
                            PackingListBO objPackingList = new PackingListBO(ObjContext);
                            objPackingList.ID = pl.ID;
                            objPackingList.GetObject();

                            foreach (PackingListSizeQtyBO plsq in objPackingList.PackingListSizeQtysWhereThisIsPackingList)
                            {
                                PackingListSizeQtyBO objPackingListSizeQty = new PackingListSizeQtyBO(ObjContext);
                                objPackingListSizeQty.ID = plsq.ID;
                                objPackingListSizeQty.GetObject();

                                objPackingListSizeQty.Delete();
                            }

                            ObjContext.SaveChanges();

                            foreach (PackingListCartonItemBO plci in objPackingList.PackingListCartonItemsWhereThisIsPackingList)
                            {
                                PackingListCartonItemBO objPackingListCartonItem = new PackingListCartonItemBO(ObjContext);
                                objPackingListCartonItem.ID = plci.ID;
                                objPackingListCartonItem.GetObject();

                                objPackingListCartonItem.Delete();
                            }

                            // ObjContext.SaveChanges();                            

                            objPackingList.Delete();

                            ObjContext.SaveChanges();
                        }

                        foreach (OrderDetailQtyBO qty in objClientOrderDetail.OrderDetailQtysWhereThisIsOrderDetail)
                        {
                            OrderDetailQtyBO objClientOrderDetailOrderQty = new OrderDetailQtyBO(ObjContext);
                            objClientOrderDetailOrderQty.ID = qty.ID;
                            objClientOrderDetailOrderQty.GetObject();

                            objClientOrderDetailOrderQty.Delete();
                        }

                        objClientOrderDetail.Delete();

                        ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while deleting Order Detai in AddEditOrder.aspx page", ex);
                }
            }
            //PopulateControls(false);
            //PopulateOrderDetails();

            Response.Redirect("/AddEditOrder.aspx?id=" + OrderID);
        }

        protected void btnDeleteOrderItems_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            CreateOrder();

            #region Delete Existing Order Details

            OrderBO objOrder = new OrderBO();
            objOrder.ID = OrderID;
            objOrder.GetObject();

            List<OrderDetailBO> lstClientOrderDetails = objOrder.OrderDetailsWhereThisIsOrder;

            using (TransactionScope ts = new TransactionScope())
            {
                try
                {
                    foreach (OrderDetailBO clientOrderDetail in lstClientOrderDetails)
                    {
                        OrderDetailBO objOrderDetail = new OrderDetailBO(ObjContext);
                        objOrderDetail.ID = clientOrderDetail.ID;
                        objOrderDetail.GetObject();

                        //Delete Order Quantities.
                        List<OrderDetailQtyBO> lstClientOrderDetailOrderQties = objOrderDetail.OrderDetailQtysWhereThisIsOrderDetail;
                        foreach (OrderDetailQtyBO orderQty in lstClientOrderDetailOrderQties)
                        {
                            OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO(ObjContext);
                            objOrderDetailQty.ID = orderQty.ID;
                            objOrderDetailQty.GetObject();

                            objOrderDetailQty.Delete();
                            ObjContext.SaveChanges();
                        }

                        objOrderDetail.Delete();
                        ObjContext.SaveChanges();
                    }
                    ts.Complete();
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }

            #endregion

            //PopulateControls(false);

            //PopulateOrderDetails();

            populateOrder();

            //int distributorId = int.Parse(hdnSelectedDistributorId.Value);

            //foreach (ListItem item in ddlDistributor.Items)
            //{
            //    if (item.Selected)
            //        ddlDistributor.Items.FindByValue(item.Value).Selected = false;
            //}
            //ddlDistributor.Items.FindByValue(distributorId.ToString()).Selected = true;

            //if (distributorId == 0)
            //{
            //    ddlJobName.Items.Clear();
            //}
            //else
            //{
            //    CompanyBO objDistributor = new CompanyBO();
            //    objDistributor.ID = distributorId;
            //    objDistributor.GetObject();

            //    //Populate Clients
            //    ddlJobName.Items.Clear();
            //    ddlJobName.Items.Add(new ListItem("Select Client", "0"));
            //    List<ClientBO> lstClients = objDistributor.ClientsWhereThisIsDistributor;
            //    foreach (ClientBO client in lstClients)
            //    {
            //        ddlJobName.Items.Add(new ListItem(client.Name, client.ID.ToString()));
            //    }

            //    foreach (ListItem item in ddlJobName.Items)
            //    {
            //        if (item.Selected)
            //            ddlJobName.Items.FindByValue(item.Value).Selected = false;
            //    }
            //    ddlJobName.Items.FindByValue(hdnSelectedClientId.Value).Selected = true;

            //    //PopulateVislalLayouts(true);
            //}
        }

        protected void btnDeleteOrderItemsCancel_Click(object sender, EventArgs e)
        {
            OrderBO objOrder = new OrderBO();
            objOrder.ID = OrderID;
            objOrder.GetObject();

            foreach (ListItem item in ddlDistributor.Items)
            {
                if (item.Selected)
                    ddlDistributor.Items.FindByValue(item.Value).Selected = false;
            }
            ddlDistributor.Items.FindByValue(objOrder.Distributor.ToString()).Selected = true;

            //Populate Clients
            ddlJobName.Items.Clear();
            ddlJobName.Items.Add(new ListItem("Select Client", "0"));
            List<ClientBO> lstClients = objOrder.objDistributor.ClientsWhereThisIsDistributor;
            foreach (ClientBO client in lstClients)
            {
                ddlJobName.Items.Add(new ListItem(client.Name, client.ID.ToString()));
            }

            foreach (ListItem item in ddlJobName.Items)
            {
                if (item.Selected)
                    ddlJobName.Items.FindByValue(item.Value).Selected = false;
            }
            ddlJobName.Items.FindByValue(objOrder.Client.ToString()).Selected = true;

            ResetViewStateValues();
        }

        protected void ddlDistributor_SelectedIndexChanged(object sender, EventArgs e)
        {
            //if (ddlDistributor.SelectedIndex != 0)
            //{
            ddlClient.Items.Clear();
            ddlJobName.Items.Clear();
            //ddlBillingAddress.Items.Clear();
            //ddlDespatchAddress.Items.Clear();
            //ddlVlNumber.Items.Clear();

            PopulateDistributorClients(int.Parse(ddlDistributor.SelectedValue));

            PopulateClientAddresses(int.Parse(ddlDistributor.SelectedValue));
            //}
            //else
            //{            

            lblDistributorAddress.Visible = false;
            //}
            ResetViewStateValues();
        }

        protected void ddlClient_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateJobNames(int.Parse(ddlClient.SelectedValue));
        }

        protected void ddlJobName_SelectedIndexChanged(object sender, EventArgs e)
        {
            populateJobNameDetails(int.Parse(ddlJobName.SelectedValue));
        }

        protected void ddlVlNumber_SelectedIndexChange(object sender, EventArgs e)
        {
            ResetViewStateValues();

            //ddlArtWork.ClearSelection();
            int VisualLayoutId = int.Parse(ddlVlNumber.SelectedValue);

            if (VisualLayoutId > 0)
            {
                VisualLayoutBO objVLNumber = new VisualLayoutBO();
                objVLNumber.ID = VisualLayoutId;
                objVLNumber.GetObject();

                txtOdNotes.Text = objVLNumber.Description;
                litPocket.Text = (objVLNumber.PocketType.HasValue && objVLNumber.PocketType.Value > 0) ? objVLNumber.objPocketType.Name : string.Empty;

                PopulateVlImage(VisualLayoutId);

                //populate Reservations
                PopulateReservations(VisualLayoutId, 0);

                //populateItems

                int orderDetailId = int.Parse(hdnSelectedID.Value);

                if (orderDetailId < 1)
                {
                    PopulateOrderItemDetails(objVLNumber.Pattern, objVLNumber.FabricCode ?? 0);
                }
            }
            else
            {
                litPocket.Text = string.Empty;
                rptSizeQty.DataSource = null;
                rptSizeQty.DataBind();
            }
            ViewState["populateVlNotes"] = true;
            // PopulateFileUploder(rptUploadFile, hdnUploadFiles);
        }

        //protected void ddlArtWork_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    ddlVlNumber.ClearSelection();
        //    //int ArtWorkId = int.Parse(ddlArtWork.SelectedValue);

        //    if (ArtWorkId > 0)
        //    {
        //        ArtWorkBO objArtWork = new ArtWorkBO();
        //        objArtWork.ID = ArtWorkId;
        //        objArtWork.GetObject();

        //        ddlSizes.Visible = true;

        //        ddlSizes.Items.Clear();
        //        ddlSizes.Items.Add(new ListItem("Select a Size", "0"));

        //        List<SizeBO> lstVLSizes = objArtWork.objPattern.objSizeSet.SizesWhereThisIsSizeSet;

        //        List<SizeBO> lstSizes = lstVLSizes.Where(o => o.IsDefault == false).ToList();
        //        foreach (SizeBO size in lstSizes)
        //        {
        //            ddlSizes.Items.Add(new ListItem(size.SizeName, size.ID.ToString()));
        //        }

        //        // populate the VisualLayout Note
        //        txtUnit.Text = (objArtWork.objPattern.Unit != null && objArtWork.objPattern.Unit > 0) ? objArtWork.objPattern.objUnit.Name : string.Empty;
        //        // txtOdNotes.Text = objArtWork.Description;

        //        /*List<SizeBO> lstSizes =*/
        //        List<OrderDetailQtyBO> lstOrderDetailQty = new List<OrderDetailQtyBO>();
        //        rptSizeQty.DataSource = PopulateSizeDetails(lstVLSizes.Where(o => o.IsDefault == true).OrderBy(o => o.SeqNo).ToList(), 0, lstOrderDetailQty, false);
        //        rptSizeQty.DataBind();

        //        PopulateVlImage(0);

        //        //populate price
        //       //PopulatePrice(0, ArtWorkId, 0);

        //        // populate Reservations
        //        //PopulateReservations(0, ArtWorkId);
        //    }
        //    else
        //    {
        //        rptSizeQty.DataSource = null;
        //        rptSizeQty.DataBind();
        //    }
        //}

        protected void linkEdit_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            if (IsNotRefreshed)
            {
                try
                {
                    odTitle.InnerText = "Edit Order Detail";

                    int index = int.Parse(((HtmlAnchor)sender).Attributes["index"].ToString());

                    OrderDetail objTempOD = this.ListOrderDetails.Where(m => m.Index == index).SingleOrDefault();

                    hdnSelectedID.Value = objTempOD.Index.ToString();
                    ddlSizes.Visible = true;

                    List<OrderDetailQtyBO> lstExsistingSizes = objTempOD.ListQtys;

                    PatternBO objPattern = new PatternBO();
                    objPattern.ID = objTempOD.Pattern;
                    objPattern.GetObject();

                    SizeBO objSizeBo = new SizeBO();
                    objSizeBo.SizeSet = objPattern.SizeSet;

                    List<int> lstSizes = objSizeBo.SearchObjects().Where(o => o.IsDefault == false).Select(o => o.ID).ToList();
                    List<int> lst = lstSizes.Except(lstExsistingSizes.Select(o => o.Size)).ToList();

                    ResetOrderDetailForm();

                    ddlSizes.Items.Clear();
                    ddlSizes.Items.Add(new ListItem("Select a Size", "0"));
                    foreach (int size in lst)
                    {
                        SizeBO objSize = new SizeBO();
                        objSize.ID = size;
                        objSize.GetObject();

                        ddlSizes.Items.Add(new ListItem(objSize.SizeName, size.ToString()));
                    }

                    ddlOrderType.Items.FindByValue(objTempOD.OrderType.ToString()).Selected = true;
                    ddlLabel.Items.FindByValue(objTempOD.Label.ToString()).Selected = true;
                    chkPhotoApprovalRequired.Checked = objTempOD.IsPhotoApprovalRequired;
                    chkBrandingKit.Checked = objTempOD.UseBrandingkit;
                    chkLockerPatch.Checked = objTempOD.UseLockerPatch;

                    txtPromoCode.Text = objTempOD.PromoCode;
                    txtPriceComments.Text = objTempOD.PriceComments;
                    txtFactoryDescription.Text = objTempOD.FactoryInstructions;
                    txtUnit.Text = ((objPattern.Unit ?? 0) > 0) ? objPattern.objUnit.Name : string.Empty;

                    txtIsNew.Text = (objTempOD.IsRepeat == true) ? "Repeat" : "New";
                    rbNaNuYes.Checked = objTempOD.IsNamesAndNumbers;
                    rbNaNuNo.Checked = !rbNaNuYes.Checked;
                    NameNumberFilePath = objTempOD.NameAndNumbersFileName;
                    txtOdNotes.Text = objTempOD.OrderDetailNotes;

                    if (objTempOD.VisualLayout > 0)
                    {
                        ddlVlNumber.Items.FindByValue(objTempOD.VisualLayout.ToString()).Selected = true;

                        PopulateVlImage(objTempOD.VisualLayout);

                        rbVisualLayout.Checked = true;
                        rbPatternFabric.Checked = false;
                        ddlVlNumber.Enabled = false;
                        dvFromVL.Attributes.Add("style", "display:none");
                    }
                    else
                    {
                        ddlPattern.Items.FindByValue(objTempOD.Pattern.ToString()).Selected = true;
                        this.PopulateFabrics(objTempOD.Pattern);

                        ddlFabric.ClearSelection();

                        if (ddlFabric.Items.FindByValue(objTempOD.Fabric.ToString()) != null)
                        {
                            ddlFabric.Items.FindByValue(objTempOD.Fabric.ToString()).Selected = true;
                        }

                        rbPatternFabric.Checked = true;
                        rbVisualLayout.Checked = false;
                        ddlVlNumber.Enabled = true;
                        dvFromVL.Attributes.Remove("style");
                    }

                    if (!string.IsNullOrEmpty(objTempOD.NameAndNumbersFileName))
                    {
                        string NameAndNumberFilePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/NameAndNumbersFiles/" + objTempOD.Order.ToString() + "/" + objTempOD.ID.ToString() + "/" + objTempOD.NameAndNumbersFileName;
                        string NameAndNumberFileIconPath = GetNameNumberFileIconPath(objTempOD.ID);

                        if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + NameAndNumberFilePath))
                            litfileName.Visible = false;

                        litfileName.Text = Path.GetFileName(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + NameAndNumberFilePath);
                        uploadImage.ImageUrl = NameAndNumberFileIconPath;
                        lifileUploder.Visible = false;
                        hdnDeleteFile.Value = objTempOD.ID.ToString();
                        dvNotification.Visible = false;
                        linkDelete.Visible = true;
                    }
                    else
                    {
                        litfileName.Text = string.Empty;
                        uploadImage.ImageUrl = "\\IndicoData\\NameAndNumbersFiles\\no_files_found.jpg";
                        lifileUploder.Visible = true;
                        hdnDeleteFile.Value = objTempOD.ID.ToString();
                        dvNotification.Visible = true;
                        linkDelete.Visible = false; ddlOrderType.Items.FindByValue(objTempOD.OrderType.ToString()).Selected = true;
                    }

                    PopulateReservations(objTempOD.VisualLayout, 0, true);

                    if (objTempOD.Reservation > 0)
                    {
                        RadComboReservations.Items.FindItemByValue(objTempOD.Reservation.ToString()).Selected = true;
                        PopulateReservationsDetails(objTempOD.Reservation);
                    }

                    List<OrderDetailQtyBO> lstODQty = lstExsistingSizes.OrderBy(o => o.objSize.SeqNo).ToList();

                    rptSizeQty.DataSource = PopulateSizeDetails(null, 0, lstODQty, false);
                    rptSizeQty.DataBind();

                    btnAddOrder.InnerHtml = "Update Order Detail";
                    btnAddOrder.Attributes.Add("data-loading-text", "Updating...");
                    ddlFabric.Enabled = ddlPattern.Enabled = false;

                    PopulatePrice(objTempOD.Pattern, objTempOD.Fabric, lstODQty.Sum(v => v.Qty), decimal.Parse(objTempOD.SurCharge), decimal.Parse(objTempOD.EditedPrice));

                    ViewState["PopulateOrderDetail"] = true;
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while editing orderdetail from AddEditOrder.aspx", ex);
                }
            }
        }

        protected void ancDownloadNameAndNumberFile_Click(object sender, EventArgs e)
        {
            string file = ((System.Web.UI.HtmlControls.HtmlControl)(sender)).Attributes["downloadUrl"].ToString();
            if (File.Exists(file))
            {
                DownloadFile(file);
            }
        }

        protected void ancDownloadLabel_Click(object sender, EventArgs e)
        {
            string file = ((System.Web.UI.HtmlControls.HtmlControl)(sender)).Attributes["downloadUrl"].ToString();
            if (File.Exists(file))
            {
                DownloadFile(file);
            }
        }

        protected void ancAddNewVL_Click(object sender, EventArgs e)
        {
            if (int.Parse(ddlDistributor.SelectedValue) > 0)
            {
                if (int.Parse(ddlJobName.SelectedValue) > 0)
                {
                    #region PopulateOrders

                    CreateOrder();

                    #endregion
                    Response.Redirect("/AddEditVisualLayout.aspx?orr=" + QueryID.ToString() + "&dir=" + ddlDistributor.SelectedValue + "&clt=" + ddlJobName.SelectedValue);

                }
                else
                {
                    litMeassage.Text = "Client is required";
                }
            }
            else
            {
                litMeassage.Text = "Distributor is required";
            }
        }

        protected void libtnSaveRemarks_Click(object sender, EventArgs e)
        {
            int orderdetail = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["qid"].ToString());

            TextBox txtEditedPrice = (TextBox)((LinkButton)(sender)).FindControl("txtEditedPrice");
            TextBox txtPriceRemarks = (TextBox)((LinkButton)(sender)).FindControl("txtPriceRemarks");

            if (orderdetail > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        OrderDetailBO objOrderDetail = new OrderDetailBO(ObjContext);
                        objOrderDetail.ID = orderdetail;
                        objOrderDetail.GetObject();

                        if (!string.IsNullOrEmpty(txtEditedPrice.Text))
                        {
                            objOrderDetail.EditedPrice = Convert.ToDecimal(txtEditedPrice.Text);
                        }

                        if (!string.IsNullOrEmpty(txtPriceRemarks.Text))
                        {
                            objOrderDetail.EditedPriceRemarks = txtPriceRemarks.Text;
                        }
                        ObjContext.SaveChanges();
                        ts.Complete();
                    }

                    //PopulateControls(false);
                    PopulateOrderDetails();
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while saving Order Detail's Edited Price and Price Remarks in AddEditOrders.aspx", ex);
                }
            }
        }

        protected void btnSaveShippingAddress_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            if (IsNotRefreshed)
            {
                CreateOrder();

                if (Page.IsValid)
                {
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO(ObjContext);

                            if (int.Parse(hdnAddressID.Value) > 0)
                            {
                                objDistributorClientAddress.ID = int.Parse(hdnAddressID.Value);
                                objDistributorClientAddress.GetObject();
                            }

                            objDistributorClientAddress.CompanyName = txtCOmpanyName.Text;
                            objDistributorClientAddress.Address = txtShipToAddress.Text;
                            objDistributorClientAddress.Suburb = txtSuburbCity.Text;
                            objDistributorClientAddress.State = txtShipToState.Text;
                            objDistributorClientAddress.PostCode = txtShipToPostCode.Text;
                            objDistributorClientAddress.ContactPhone = txtShipToPhone.Text;
                            objDistributorClientAddress.EmailAddress = txtShipToEmail.Text;

                            objDistributorClientAddress.ContactName = txtShipToContactName.Text;
                            objDistributorClientAddress.Country = int.Parse(ddlShipToCountry.SelectedValue);
                            objDistributorClientAddress.AddressType = int.Parse(ddlAdderssType.SelectedValue);
                            objDistributorClientAddress.Port = int.Parse(ddlShipToPort.SelectedValue);
                            //objDistributorClientAddress.Client = int.Parse(ddlJobName.SelectedValue);
                            objDistributorClientAddress.Distributor = int.Parse(ddlDistributor.SelectedValue);

                            ObjContext.SaveChanges();
                            ts.Complete();

                            string addressType = this.hdnEditType.Value;
                            if (addressType == "Billing")
                            {
                                this.billingAddress = objDistributorClientAddress.ID;
                            }
                            else if (addressType == "Despatch")
                            {
                                this.despatchAddress = objDistributorClientAddress.ID;
                            }
                            else if (addressType == "Courier")
                            {
                                this.courierAddress = objDistributorClientAddress.ID;
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while Saving Distributor Client Address AddEditOrder.aspx", ex);
                    }
                }
                else
                {
                    ViewState["PopulateShippingAddress"] = true;
                }

                populateOrder();
            }
        }

        protected void RadComboReservations_ItemDataBound(object sender, RadComboBoxItemEventArgs e)
        {
            RadComboBoxItem item = e.Item;

            if (item.Index > -1 && item.DataItem is ReservationBO)
            {
                ReservationBO objReservation = (ReservationBO)item.DataItem;

                Literal litReservation = (Literal)item.FindControl("litReservation");
                litReservation.Text = "RES-" + objReservation.ReservationNo.ToString("0000");

                Literal litOrderWeek = (Literal)item.FindControl("litOrderWeek");
                litOrderWeek.Text = objReservation.OrderDate.ToString("dd MMM yyyy");

                Literal litETD = (Literal)item.FindControl("litETD");
                litETD.Text = objReservation.ShipmentDate.ToString("dd MMM yyyy");

                Literal litDistributor = (Literal)item.FindControl("litDistributor");
                litDistributor.Text = objReservation.objDistributor.Name;

                Literal litClient = (Literal)item.FindControl("litClient");
                litClient.Text = objReservation.Client;

                Literal litStatus = (Literal)item.FindControl("litStatus");
                litStatus.Text = "<span class=\"label label-" + objReservation.objStatus.Name.ToLower().Replace(" ", string.Empty).Trim() + "\">" + objReservation.objStatus.Name + "</span>";

                item.Value = objReservation.ID.ToString();

            }
        }

        protected void RadComboReservations_SelectedIndexChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
        {
            int id = (!string.IsNullOrEmpty(RadComboReservations.SelectedValue)) ? int.Parse(RadComboReservations.SelectedValue) : 0;
            PopulateReservationsDetails(id);
        }

        protected void btnCancelled_ServerClick(object sender, EventArgs e)
        {
            int id = int.Parse(hdncancelledorderdetail.Value);

            if (id > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        OrderDetailBO objOrderDetail = new OrderDetailBO(ObjContext);
                        objOrderDetail.ID = id;
                        objOrderDetail.GetObject();

                        objOrderDetail.Status = 15;

                        ObjContext.SaveChanges();

                        ts.Complete();
                    }

                    SetOrderStatus(id);
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while changing the Order detail status in AddEditOrder.aspx page", ex);
                }
            }

            //PopulateControls(false);
            PopulateOrderDetails();
        }

        protected void ddlSizes_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (int.Parse(ddlSizes.SelectedValue) > 0)
            {
                /*rptSizeQty.DataSource = null;
                rptSizeQty.DataBind();*/

                rptSizeQty.DataSource = PopulateSizeDetails(null, int.Parse(ddlSizes.SelectedValue), null);
                rptSizeQty.DataBind();
            }
        }

        protected void btnDeleteFile_ServerClick(object sender, EventArgs e)
        {
            int id = int.Parse(hdnDeleteFile.Value);

            if (id > 0)
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    OrderDetailBO objOrderDetail = new OrderDetailBO(ObjContext);
                    objOrderDetail.ID = id;
                    objOrderDetail.GetObject();

                    objOrderDetail.NameAndNumbersFilePath = string.Empty;

                    ObjContext.SaveChanges();
                    ts.Complete();

                    NameNumberFilePath = string.Empty;
                }

                //dvFilePreview.Attributes.Add("style", "display:none;");
                litfileName.Text = string.Empty;
                uploadImage.ImageUrl = "\\IndicoData\\NameAndNumbersFiles\\no_files_found.jpg";
                lifileUploder.Visible = true;
                dvNotification.Visible = true;
                linkDelete.Visible = false;
            }
        }

        protected void lbDownloadDistributorPO_Click(object sender, EventArgs e)
        {
            try
            {
                int odsID = OrderID;

                if (odsID > 0)
                {
                    // string pdfFilePath = Common.GenerateOdsPdf.GeneratePdfDistributorPO(odsID);
                    string pdfFilePath = Common.GenerateOdsPdf.GeneratePdfOrderReport(odsID);
                    DownloadPDFFile(pdfFilePath);
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while printing DistributorPO", ex);
            }
        }

        protected void btnTAndC_ServerClick(object sender, EventArgs e)
        {
            string filePath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/IndicoTermsAndConditions.pdf";
            FileInfo fileInfo = new FileInfo(filePath);
            string outputName = System.Text.RegularExpressions.Regex.Replace(fileInfo.Name, @"\W+", "_");
            outputName = System.Text.RegularExpressions.Regex.Replace(outputName, "_pdf", ".pdf");
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Content-Type", "application/pdf");
            Response.AddHeader("Content-Disposition", string.Format("attachment; filename = {0}", outputName));
            Response.AddHeader("Content-Length", (fileInfo.Length).ToString("F0"));
            Response.TransmitFile(filePath);
            Response.Flush();
            Response.Close();
            Response.BufferOutput = true;
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (IsNotRefreshed)
            {
                ValidateOrder();

                if (Page.IsValid)
                {
                    ProcessForm(false);
                    Response.Redirect("/ViewOrders.aspx");
                }
            }
        }

        protected void btnAddOrder_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            if (IsNotRefreshed)
            {
                CustomValidator cv = null;

                if (rbVisualLayout.Checked && ddlVlNumber.SelectedIndex < 1)
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "vgOrderDetail";
                    cv.ErrorMessage = "VisualLayout is required";
                    Page.Validators.Add(cv);
                }
                else if (rbPatternFabric.Checked)
                {
                    if (ddlPattern.SelectedIndex < 1)
                    {
                        cv = new CustomValidator();
                        cv.IsValid = false;
                        cv.ValidationGroup = "vgOrderDetail";
                        cv.ErrorMessage = "Pattern is required";
                        Page.Validators.Add(cv);
                    }

                    if (ddlFabric.SelectedIndex < 1)
                    {
                        cv = new CustomValidator();
                        cv.IsValid = false;
                        cv.ValidationGroup = "vgOrderDetail";
                        cv.ErrorMessage = "Fabric is required";
                        Page.Validators.Add(cv);
                    }
                }

                if (hdnTotalQuantity.Value == "0")
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "vgOrderDetail";
                    cv.ErrorMessage = "Order Details quantity should be greater than zero";
                    Page.Validators.Add(cv);
                }

                if (rbNaNuYes.Checked == true && string.IsNullOrEmpty(hdnUploadFiles.Value) && string.IsNullOrEmpty(NameNumberFilePath))
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "vgOrderDetail";
                    cv.ErrorMessage = "Name & Number file is required";
                    Page.Validators.Add(cv);
                }

                // validate Deduct  Reservation Qty in OrderDetail
                if (RadComboReservations.Items.Count > 0 && !string.IsNullOrEmpty(RadComboReservations.SelectedValue) && int.Parse(RadComboReservations.SelectedValue) > 0)
                {
                    ReservationBO objReservation = new ReservationBO();
                    objReservation.ID = int.Parse(RadComboReservations.SelectedValue);
                    objReservation.GetObject();

                    int totalQuentity = int.Parse(hdnTotalQuantity.Value);

                    int reservationqty = objReservation.Qty - ((objReservation.OrderDetailsWhereThisIsReservation.Count > 0) ? objReservation.OrderDetailsWhereThisIsReservation.Sum(o => o.OrderDetailQtysWhereThisIsOrderDetail.Sum(p => p.Qty)) : 0);

                    reservationqty = reservationqty - totalQuentity;

                    if (totalQuentity > reservationqty)
                    {
                        cv = new CustomValidator();
                        cv.IsValid = false;
                        cv.ValidationGroup = "vgOrderDetail";
                        cv.ErrorMessage = "Your order quantity is greater than reservation quantity ";
                        Page.Validators.Add(cv);
                    }
                }

                if (Page.IsValid)
                {
                    ProcessOrderDetailForm();

                    //Response.Redirect("/AddEditOrder.aspx?id=" + OrderID);
                }
                else
                {
                    ViewState["PopulateOrderDetail"] = true;
                }
            }
        }

        protected void btnPrint_ServerClick(object sender, EventArgs e)
        {
            if (IsNotRefreshed)
            {
                ValidateOrder();

                try
                {
                    if (Page.IsValid)
                    {
                        ProcessForm(false);

                        int odsID = OrderID;

                        if (odsID > 0)
                        {
                            //string pdfFilePath = Common.GenerateOdsPdf.GeneratePdfDistributorPO(odsID);
                            string pdfFilePath = Common.GenerateOdsPdf.GeneratePdfOrderReport(odsID);
                            DownloadPDFFile(pdfFilePath);
                        }
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while printing Order Report", ex);
                }
            }
        }

        protected void btnClose_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect("/ViewOrders.aspx");
        }

        protected void ddlBillingAddress_SelectedIndexChanged(object sender, EventArgs e)
        {
            ResetViewStateValues();

            int dAddressID = int.Parse(ddlBillingAddress.SelectedValue);

            if (dAddressID > 0)
            {
                DistributorClientAddressBO objDCA = new DistributorClientAddressBO();
                objDCA.ID = dAddressID;
                objDCA.GetObject();

                lblBillingAddress.Text = objDCA.CompanyName + "  " + objDCA.Address + "  " + objDCA.PostCode + "  " + objDCA.Suburb + "  " +
                    objDCA.PostCode + "  " + objDCA.State + "  " + objDCA.objCountry.ShortName;
                btnEditBilling.Visible = true;

                ddlDespatchAddress.ClearSelection();
                ddlDespatchAddress.Items.FindByValue(dAddressID.ToString()).Selected = true;
                ddlDespatchAddress_SelectedIndexChanged(null, null);
            }
            else
            {
                lblBillingAddress.Text = string.Empty;
                btnEditBilling.Visible = false;
            }
        }

        protected void ddlDespatchAddress_SelectedIndexChanged(object sender, EventArgs e)
        {
            ResetViewStateValues();
            int dAddressID = int.Parse(ddlDespatchAddress.SelectedValue);

            if (dAddressID > 0)
            {
                DistributorClientAddressBO objDCA = new DistributorClientAddressBO();
                objDCA.ID = dAddressID;
                objDCA.GetObject();

                lblDespatchAddress.Text = objDCA.CompanyName + "  " + objDCA.Address + "  " + objDCA.PostCode + "  " + objDCA.Suburb + "  " +
                    objDCA.PostCode + "  " + objDCA.State + "  " + objDCA.objCountry.ShortName;

                btnEditDespatch.Visible = true;
            }
            else
            {
                lblDespatchAddress.Text = string.Empty;
                btnEditDespatch.Visible = false;
            }
        }

        protected void ddlPattern_SelectedIndexChanged(object sender, EventArgs e)
        {
            int pattern = int.Parse(ddlPattern.SelectedValue.ToString());
            int fabric = (ddlFabric.Items.Count > 0) ? int.Parse(ddlFabric.SelectedValue.ToString()) : 0;

            PopulateFabrics(pattern);
            PopulateOrderItemDetails(pattern, fabric);
        }

        protected void ddlFabric_SelectedIndexChanged(object sender, EventArgs e)
        {
            int pattern = int.Parse(ddlPattern.SelectedValue.ToString());
            int fabric = int.Parse(ddlFabric.SelectedValue.ToString());

            PopulateOrderItemDetails(pattern, fabric);
        }

        protected void rbVisualLayout_CheckedChanged(object sender, EventArgs e)
        {
            if (int.Parse(hdnSelectedID.Value) < 1)
            {
                if (rbVisualLayout.Checked)
                {
                    ddlVlNumber_SelectedIndexChange(null, null);
                }
                else if (rbPatternFabric.Checked)
                {
                    ddlPattern_SelectedIndexChanged(null, null);
                }
            }

            //if (rbVisualLayout.Checked)
            //{
            //    if (ddlVlNumber.SelectedIndex < 1)
            //    {
            //        rptSizeQty.Visible = false;
            //    }
            //    else
            //    {
            //        if (int.Parse(hdnSelectedID.Value) < 1)
            //            ddlVlNumber_SelectedIndexChange(null, null);
            //        rptSizeQty.Visible = true;
            //    }
            //}
            //else if (rbPatternFabric.Checked)
            //{
            //    if (ddlFabric.SelectedIndex < 1 && ddlPattern.SelectedIndex < 1)
            //    {
            //        rptSizeQty.Visible = false;
            //    }
            //    else
            //    {
            //        if (int.Parse(hdnSelectedID.Value) < 1)
            //            ddlPattern_SelectedIndexChanged(null, null);
            //        rptSizeQty.Visible = true;
            //    }
            //}
        }

        protected void btnCancelOrder_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect("/AddEditOrder.aspx?id=" + OrderID);
        }

        protected void btnSaveClient_ServerClick(object sender, EventArgs e)
        {
            ResetViewStateValues();

            if (IsNotRefreshed)
            {
                CreateOrder();

                if (Page.IsValid)
                {
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            ClientBO objClient = new ClientBO(ObjContext);

                            if (int.Parse(hdnClientID.Value) > 0)
                            {
                                objClient.ID = int.Parse(hdnClientID.Value);
                                objClient.GetObject();
                            }

                            objClient.Name = this.txtClientName.Text;
                            objClient.Distributor = int.Parse(this.ddlDistributor.SelectedValue);

                            ObjContext.SaveChanges();
                            ts.Complete();

                            newClient = objClient.ID;
                        }
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while Saving Client in AddEditOrder.aspx", ex);
                    }
                }
                else
                {
                    ViewState["PopulateClient"] = true;
                }

                populateOrder();
            }
        }

        protected void btnSubmit_ServerClick(object sender, EventArgs e)
        {
            if (IsNotRefreshed)
            {
                ValidateOrder();

                try
                {
                    if (Page.IsValid)
                    {
                        ProcessForm(false);

                        using (TransactionScope ts = new TransactionScope())
                        {
                            OrderBO objOrder = new OrderBO(this.ObjContext);
                            objOrder.ID = this.OrderID;
                            objOrder.GetObject();

                            string mailTo = string.Empty;
                            OrderStatus currentOrderStatus = this.GetOrderStatus(objOrder.Status);

                            if (this.LoggedUser.IsDirectSalesPerson && currentOrderStatus == OrderStatus.New)
                            {
                                objOrder.Status = this.GetOrderStatus(OrderStatus.DistributorSubmitted).ID;
                                objOrder.Modifier = this.LoggedUser.ID;
                                objOrder.ModifiedDate = DateTime.Now;

                                this.SendOrderSubmissionEmail(this.OrderID, this.Distributor.objCoordinator.EmailAddress,
                                    this.Distributor.objCoordinator.GivenName + " " + this.Distributor.objCoordinator.FamilyName, true, CustomSettings.DSOCC);
                            }
                            else if (this.LoggedUserRoleName == UserRole.IndicoCoordinator && currentOrderStatus == OrderStatus.DistributorSubmitted)
                            {
                                SettingsBO objSetting = new SettingsBO();
                                objSetting.Key = CustomSettings.CSOTO.ToString();
                                objSetting = objSetting.SearchObjects().SingleOrDefault();
                                mailTo = objSetting.Value;

                                objOrder.Status = this.GetOrderStatus(OrderStatus.CoordinatorSubmitted).ID;
                                objOrder.Modifier = this.LoggedUser.ID;
                                objOrder.ModifiedDate = DateTime.Now;

                                this.SendOrderSubmissionEmail(this.OrderID, mailTo, "Imports", true, CustomSettings.CSOCC);
                            }
                            else if (this.LoggedUserRoleName == UserRole.IndimanAdministrator) // && currentOrderStatus == OrderStatus.CoordinatorSubmitted)
                            {
                                SettingsBO objSetting = new SettingsBO();
                                objSetting.Key = CustomSettings.ISOTO.ToString();
                                objSetting = objSetting.SearchObjects().SingleOrDefault();
                                mailTo = objSetting.Value;

                                objOrder.Status = this.GetOrderStatus(OrderStatus.IndimanSubmitted).ID;
                                objOrder.Modifier = this.LoggedUser.ID;
                                objOrder.ModifiedDate = DateTime.Now;

                                this.SendOrderSubmissionEmail(this.OrderID, mailTo, "Factory", true, null);
                            }

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }

                        Response.Redirect("ViewOrders.aspx");
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while submiting Order", ex);
                }
            }
        }

        protected void ddlCourierAddress_SelectedIndexChanged(object sender, EventArgs e)
        {
            ResetViewStateValues();

            int dAddressID = int.Parse(ddlCourierAddress.SelectedValue);

            if (dAddressID > 0)
            {
                DistributorClientAddressBO objDCA = new DistributorClientAddressBO();
                objDCA.ID = dAddressID;
                objDCA.GetObject();

                lblCourierAddress.Text = objDCA.CompanyName + "  " + objDCA.Address + "  " + objDCA.PostCode + "  " + objDCA.Suburb + "  " +
                    objDCA.PostCode + "  " + objDCA.State + "  " + objDCA.objCountry.ShortName;

                btnEditCourier.Visible = true;

                this.ddlDespatchAddress.ClearSelection();
                this.ddlDespatchAddress.Items.FindByValue(dAddressID.ToString()).Selected = true;
                this.ddlDespatchAddress_SelectedIndexChanged(null, null);
            }
            else
            {
                lblCourierAddress.Text = string.Empty;
                btnEditCourier.Visible = false;
            }
        }

        protected void btnEditCourier_Click(object sender, EventArgs e)
        {
            PopulateEditAddressDetails(int.Parse(ddlCourierAddress.SelectedValue), "Courier");
        }

        protected void btnEditBilling_Click(object sender, EventArgs e)
        {
            PopulateEditAddressDetails(int.Parse(ddlBillingAddress.SelectedValue), "Billing");
        }

        protected void btnEditDespatch_Click(object sender, EventArgs e)
        {
            PopulateEditAddressDetails(int.Parse(ddlDespatchAddress.SelectedValue), "Despatch");
        }

        protected void btnEditClient_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            try
            {
                ClientBO objClient = new ClientBO();
                objClient.ID = int.Parse(ddlClient.SelectedValue);
                objClient.GetObject();

                hdnClientID.Value = objClient.ID.ToString();

                lblClientDistributor.Text = objClient.objDistributor.Name;
                txtClientName.Text = objClient.Name;

                ViewState["PopulateClient"] = true;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Editing Distributor Client Address on AddEditOrder.aspx", ex);
            }
        }

        protected void btnSaveJobName_ServerClick(object sender, EventArgs e)
        {
            ResetViewStateValues();
            if (IsNotRefreshed)
            {
                if (Page.IsValid)
                {
                    try
                    {
                        int newJobName = 0;
                        using (TransactionScope ts = new TransactionScope())
                        {
                            JobNameBO objJobName = new JobNameBO(this.ObjContext);

                            int id = int.Parse(hdnEditJobNameID.Value);

                            if (id > 0)
                            {
                                objJobName.ID = id;
                                objJobName.GetObject();
                            }
                            else
                            {
                                objJobName.Creator = this.LoggedUser.ID;
                                objJobName.CreatedDate = DateTime.Now;
                            }

                            objJobName.Client = int.Parse(ddlClient.SelectedValue);
                            objJobName.Name = txtNewJobName.Text;
                            objJobName.Modifier = this.LoggedUser.ID;
                            objJobName.ModifiedDate = DateTime.Now;

                            ObjContext.SaveChanges();
                            newJobName = objJobName.ID;
                            ts.Complete();
                        }

                        if (newJobName > 0)
                        {
                            ddlClient_SelectedIndexChanged(null, null);
                            ddlJobName.ClearSelection();
                            ddlJobName.Items.FindByValue(newJobName.ToString()).Selected = true;
                            ddlJobName_SelectedIndexChanged(null, null);
                        }
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while Saving Job Name", ex);
                    }
                }
                else
                {
                    ViewState["PopulateJobName"] = true;
                }
            }
        }

        protected void btnEditJobName_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            JobNameBO objJobName = new JobNameBO();
            objJobName.ID = int.Parse(ddlJobName.SelectedValue);
            objJobName.GetObject();

            //this.ddlJobNameClient.Items.FindByValue(objJobName.Client.ToString()).Selected = true;
            this.txtNewJobName.Text = objJobName.Name;

            hdnEditJobNameID.Value = objJobName.ID.ToString();
            ViewState["PopulateJobName"] = true;
        }

        protected void btnNewOrderDetail_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            if (IsNotRefreshed)
            {
                hdnSelectedID.Value = "-1";
                ResetOrderDetailForm();

                ViewState["PopulateOrderDetail"] = true;
            }
        }

        #region validations

        protected void cvDate_OnServerValidate(object sender, ServerValidateEventArgs e)
        {
            DateTime tempDateTime;
            if (!string.IsNullOrEmpty(txtDate.Text))
            {
                if (DateTime.TryParse(txtDate.Text, out tempDateTime))
                {
                    e.IsValid = true;
                }
                else
                {
                    e.IsValid = false;
                }
            }
        }

        protected void cvDesiredDate_OnServerValidate(object sender, ServerValidateEventArgs e)
        {
            DateTime tempDateTime;
            if (!string.IsNullOrEmpty(txtDesiredDate.Text))
            {
                if (DateTime.TryParse(txtDesiredDate.Text, out tempDateTime))
                {
                    e.IsValid = true;
                }
                else
                {
                    e.IsValid = false;
                }
            }
        }

        protected void cvTxtClientName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int itemID = int.Parse(hdnClientID.Value);
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(itemID, "Client", "Name", this.txtClientName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtClientName_ServerValidate on AddEditOrder.aspx", ex);
            }
        }

        protected void cfvJobName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int itemID = int.Parse(hdnEditJobNameID.Value);
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(itemID, "JobName", "Name", this.txtNewJobName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cfvJobName_ServerValidate on AddEditOrder.aspx", ex);
            }
        }

        #endregion

        #endregion

        #region Methods

        private void PopulateControls(bool ispostback)
        {
            try
            {
                ResetViewStateValues();

                if (OrderID == 0)
                {
                    liOrderNumber.Visible = false;
                }

                ddlStatus.Enabled = (OrderID > 0) ? true : false;

                liClient.Visible = false;

                uploadImage.ImageUrl = "\\IndicoData\\NameAndNumbersFiles\\no_files_found.jpg";

                //Page Refresh
                Session["isRefresh"] = Server.UrlEncode(System.DateTime.Now.ToString());

                this.ListOrderDetails = new List<OrderDetail>();

                //Header Text
                litHeaderText.Text = (OrderID > 0) ? "Edit Order" : "New Order";
                lbDownloadDistributorPO.Visible = (OrderID > 0) ? true : false;

                txtDate.Text = DateTime.Now.ToString("dd MMMM yyyy");
                // txtDesiredDate.Text = DateTime.Now.AddDays(7 * 5).ToString("dd MMMM yyyy");
                int processingPeriod = 5;
                int.TryParse(IndicoPage.GetSetting("OPP"), out  processingPeriod);
                txtDesiredDate.Text = IndicoPage.GetNextWeekday(DayOfWeek.Tuesday).AddDays(7 * (processingPeriod - 1)).ToString("dd MMMM yyyy");
                litDateRequiredDescription.Text = "(Please consider order processing period is " + processingPeriod + " weeks)";

                //Populate Distributors
                ddlDistributor.Items.Clear();
                ddlDistributor.Items.Add(new ListItem("Select Distributor", "0"));
                List<CompanyBO> lstDistributors = (new CompanyBO()).GetAllObject().Where(o => o.IsDistributor == true && o.IsActive == true && o.IsDelete == false).OrderBy(o => o.Name).ToList(); ;
                foreach (CompanyBO distributor in lstDistributors)
                {
                    ddlDistributor.Items.Add(new ListItem(distributor.Name, distributor.ID.ToString()));
                }

                // Populate Country
                ddlShipToCountry.Items.Clear();
                ddlShipToCountry.Items.Add(new ListItem("Select Country", "0"));
                List<CountryBO> lstCountries = (new CountryBO()).GetAllObject().OrderBy(o => o.ShortName).ToList();
                foreach (CountryBO country in lstCountries)
                {
                    ddlShipToCountry.Items.Add(new ListItem(country.ShortName, country.ID.ToString()));
                }

                // Populate AddressType
                ddlAdderssType.Items.Clear();
                ddlAdderssType.Items.Add(new ListItem("Select an Address Type", "-1"));
                int addressType = 0;
                foreach (AddressType type in Enum.GetValues(typeof(AddressType)))
                {
                    ddlAdderssType.Items.Add(new ListItem(type.ToString(), addressType++.ToString()));
                }

                //populate shipment mode
                ddlShipmentMode.Items.Clear();
                //ddlShipmentMode.Items.Add(new ListItem("Select Your Shipment Mode", "0"));
                List<ShipmentModeBO> lstShipmentModes = (new ShipmentModeBO()).GetAllObject().OrderBy(o => o.Name).ToList();
                foreach (ShipmentModeBO sMode in lstShipmentModes)
                {
                    ddlShipmentMode.Items.Add(new ListItem(sMode.Name, sMode.ID.ToString()));
                }

                // set default Shipment Mode
                if (QueryID == 0 || OrderID == 0)
                {
                    ddlShipmentMode.Items.FindByValue("1").Selected = true;
                }

                // populate Destination Port
                ddlShipToPort.Items.Clear();
                ddlShipToPort.Items.Add(new ListItem("Select Destination Port", "0"));
                List<DestinationPortBO> lstDestinationPort = (new DestinationPortBO()).GetAllObject();
                foreach (DestinationPortBO ds in lstDestinationPort)
                {
                    ddlShipToPort.Items.Add(new ListItem(ds.Name, ds.ID.ToString()));
                }

                //Populate Payment Method
                PopulatePaymentMethod(false);

                //Populate Pattern
                PoplatePatterns();

                //Populate Order Types
                ddlOrderType.Items.Clear();
                ddlOrderType.Items.Add(new ListItem("Select Order Type", "0"));

                List<OrderTypeBO> lstOrderTypes = null;
                if (LoggedUserRoleName == UserRole.DistributorAdministrator || LoggedUserRoleName == UserRole.DistributorCoordinator)
                {
                    lstOrderTypes = (new OrderTypeBO()).SearchObjects().Where(o => o.ID != 3 && o.ID != 4).ToList();
                }
                else if (LoggedUser.IsDirectSalesPerson)
                {
                    lstOrderTypes = (new OrderTypeBO()).SearchObjects().Where(o => o.ID < 3).ToList();
                    chkBrandingKit.Checked = true;
                }
                else
                {
                    lstOrderTypes = (new OrderTypeBO()).GetAllObject();
                }

                foreach (OrderTypeBO orderType in lstOrderTypes)
                {
                    ddlOrderType.Items.Add(new ListItem(orderType.Name, orderType.ID.ToString()));
                }

                if (OrderID > 0)
                {
                    OrderBO objOrder = new OrderBO();
                    objOrder.ID = OrderID;
                    objOrder.GetObject();

                    populateLabels(objOrder.Distributor);
                    PopulateDistributorClients(objOrder.Distributor);
                    PopulateJobNames(objOrder.objClient.Client ?? 0);
                    PopulateVisualLayouts(objOrder.Client);
                    PopulateMYOBCardNumber(objOrder.Distributor);

                    lblDistributorAddress.Visible = true;

                    txtDate.Text = objOrder.Date.ToString("dd MMMM yyyy");
                    txtDesiredDate.Text = objOrder.EstimatedCompletionDate.ToString("dd MMMM yyyy");
                    txtShipmentDate.Text = (objOrder.ShipmentDate != null) ? objOrder.ShipmentDate.Value.ToString("dd MMMM yyyy") : string.Empty;
                    txtRefference.Text = objOrder.ID.ToString();

                    txtPoNo.Text = (objOrder.PurchaseOrderNo != null) ? objOrder.PurchaseOrderNo.ToString() : string.Empty;
                    txtOldPoNo.Text = objOrder.OldPONo;
                    ddlDistributor.Items.FindByValue(objOrder.Distributor.ToString()).Selected = true;
                    liClient.Visible = true;
                    ddlClient.Items.FindByValue(objOrder.objClient.Client.ToString()).Selected = true;
                    ddlJobName.Items.FindByValue(objOrder.Client.ToString()).Selected = true;
                    litJobName.Text = objOrder.objClient.Name;
                    btnEditJobName.Visible = true;
                    rbDateYes.Checked = (objOrder.IsDateNegotiable) ? true : false;
                    rbDateNo.Checked = (!objOrder.IsDateNegotiable) ? true : false;

                    rdoRoadFreight.Checked = (objOrder.DeliveryOption == 1);
                    rdoAirbag.Checked = (objOrder.DeliveryOption == 2);
                    rdoPickup.Checked = (objOrder.DeliveryOption == 3);

                    OrderDetailBO objOrderDetail = objOrder.OrderDetailsWhereThisIsOrder.First();
                    rbWeeklyShipment.Checked = objOrderDetail.IsWeeklyShipment ?? false;
                    rbCourier.Checked = (!objOrderDetail.objDespatchTo.IsAdelaideWarehouse && (objOrderDetail.IsCourierDelivery ?? false));

                    txtNotes.Text = objOrder.Notes;
                    chkTAndC.Checked = objOrder.IsAcceptedTermsAndConditions;
                    chkIsGstExclude.Checked = objOrder.IsGSTExcluded;

                    // populate Shipping Address Details
                    PopulateClientAddresses(objOrder.Distributor, (int)objOrder.BillingAddress, (int)objOrder.DespatchToAddress, (rbCourier.Checked) ? objOrderDetail.DespatchTo ?? 0 : 0);

                    if (ddlMYOBCardFile.Items.Count > 0)
                    {
                        ddlMYOBCardFile.ClearSelection();

                        if (ddlMYOBCardFile.Items.FindByValue(objOrder.MYOBCardFile.ToString()) != null)
                        {
                            ddlMYOBCardFile.Items.FindByValue((objOrder.MYOBCardFile != null && objOrder.MYOBCardFile > 0) ? objOrder.MYOBCardFile.ToString() : "0").Selected = true;
                        }
                        else
                        {
                            ddlMYOBCardFile.Items.FindByValue("0").Selected = true;
                        }
                    }

                    //Populate OrderItems
                    PopulateOrderDetails();

                    ddlDistributor.Enabled = false;
                    ddlClient.Enabled = false;
                    ddlJobName.Enabled = false;

                    List<OrderDetailBO> lstOD = objOrder.OrderDetailsWhereThisIsOrder;

                    PopulateReservations(0, 0);
                    PopulateBillingDetails(lstOD);

                    btnSubmit.Visible = !(LoggedUserRoleName == UserRole.FactoryAdministrator || LoggedUserRoleName == UserRole.FactoryCoordinator) && (!(lstOD.Where(m => !m.VisualLayout.HasValue || m.VisualLayout.Value == 0).Count() > 0));
                }
                else if (QueryReservationID > 0)
                {
                    ResetDropdowns();

                    ReservationBO objReservation = new ReservationBO();
                    objReservation.ID = QueryReservationID;
                    objReservation.GetObject();

                    txtDate.Text = objReservation.OrderDate.ToString("dd MMM yyyy");
                    ddlDistributor.Items.FindByValue(objReservation.Distributor.ToString()).Selected = true;
                    PopulateDistributorClients(objReservation.Distributor);
                    ddlJobName.Items.FindByValue(objReservation.Client.ToString()).Selected = true;
                }
                //}

                // Hide not part of the Distributor

                if (LoggedUserRoleName == UserRole.DistributorAdministrator || LoggedUserRoleName == UserRole.DistributorCoordinator)
                {
                    ddlDistributor.Enabled = false;
                    ddlDistributor.Items.FindByValue(LoggedCompany.ID.ToString()).Selected = true;
                    lblClientDistributor.Text = LoggedCompany.Name;

                    liAccessNo.Visible = false;
                    liPaymentMethod.Visible = false;
                    liOrderStatus.Visible = false;
                    liClient.Visible = true;
                    ancAddNewVL.Visible = false;

                    if (OrderID == 0)
                    {
                        PopulateDistributorClients(LoggedCompany.ID);
                    }
                }

                if (ispostback && LoggedUser.IsDirectSalesPerson)
                {
                    // liDistributor.Visible = false;
                    ddlDistributor.ClearSelection();
                    ddlDistributor.Items.FindByValue(Distributor.ID.ToString()).Selected = true;
                    ddlDistributor.Enabled = false;

                    CompanyBO objDistributor = new CompanyBO();
                    objDistributor.ID = DistributorID;
                    objDistributor.GetObject();

                    lblDistributor.Text = objDistributor.Name + " - " + objDistributor.Number + "  " + objDistributor.Address1 + "  " + objDistributor.City + "  " + objDistributor.State + "  " + objDistributor.Postcode + "  " + objDistributor.objCountry.ShortName;
                    lblClientDistributor.Text = objDistributor.Name;

                    liDistributor.Visible = false;
                    lblDistributor.Visible = true;

                    liAccessNo.Visible = false;

                    if (OrderID == 0)
                    {
                        PopulateDistributorClients(DistributorID);
                    }
                }

                dvIndimanPrice.Visible = dvPercentage.Visible = (LoggedUserRoleName == UserRole.IndimanAdministrator) || (LoggedUserRoleName == UserRole.IndimanCoordinator)
                        || (LoggedUserRoleName == UserRole.IndicoAdministrator) || (LoggedUserRoleName == UserRole.IndicoCoordinator);

                PopulateOrderStatus(QueryID);

                if (OrderID == 0 && VisualLayoutID > 0)
                {
                    ddlVlNumber.Items.FindByValue(VisualLayoutID.ToString()).Selected = true;
                    ddlVlNumber_SelectedIndexChange(this, EventArgs.Empty);
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Exception occured on PopulateControls()", ex);
            }
        }

        private void ProcessForm(bool isTemp)
        {
            string testString = string.Empty;
            string orderstring = string.Empty;

            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    //string NNFileName = hdnUploadFiles.Value.Split(',')[0];

                    #region Create Order

                    OrderBO objOrder = new OrderBO(ObjContext);

                    if (OrderID > 0)
                    {
                        objOrder.ID = OrderID;
                        objOrder.GetObject();
                    }
                    else
                    {
                        objOrder.Status = 18;
                    }

                    objOrder.Date = Convert.ToDateTime(txtDate.Text);
                    objOrder.OrderSubmittedDate = Convert.ToDateTime(txtDate.Text);
                    objOrder.EstimatedCompletionDate = Convert.ToDateTime(txtDesiredDate.Text);
                    //  objOrder.ShipmentDate = Convert.ToDateTime(txtShipmentDate.Text);
                    objOrder.Client = int.Parse(ddlJobName.SelectedValue);
                    objOrder.Distributor = (LoggedUserRoleName == UserRole.DistributorAdministrator || LoggedUserRoleName == UserRole.DistributorCoordinator) ? LoggedCompany.ID : int.Parse(ddlDistributor.SelectedValue);
                    objOrder.IsTemporary = false; // isTemp
                    //objOrder.Status = int.Parse(ddlStatus.SelectedValue); // (LoggedUserRoleName == UserRole.DistributorAdministrator || LoggedUserRoleName == UserRole.DistributorCoordinator) ? (isTemp) ? 18 : 22 : (LoggedUserRoleName == UserRole.IndimanAdministrator || LoggedUserRoleName == UserRole.IndimanCoordinator) ? 26 : int.Parse(ddlStatus.SelectedValue);
                    objOrder.Modifier = LoggedUser.ID;
                    objOrder.ModifiedDate = DateTime.Now;

                    if (LoggedUser.IsDirectSalesPerson)
                    {
                        ddlDistributor.Items.FindByValue(DistributorID.ToString()).Selected = true;
                        objOrder.Distributor = DistributorID;
                    }

                    if (OrderID == 0)
                    {
                        objOrder.Creator = LoggedUser.ID;
                        objOrder.CreatedDate = DateTime.Now;
                    }

                    objOrder.PurchaseOrderNo = txtPoNo.Text;
                    objOrder.OldPONo = txtOldPoNo.Text.Trim();

                    // objOrder.PaymentMethod = int.Parse(ddlPaymentMethod.SelectedValue);
                    //objOrder.ShipmentMode = int.Parse(ddlShipmentMode.SelectedValue);
                    //objOrder.IsWeeklyShipment = (rbWeeklyShipment.Checked);
                    //objOrder.IsCourierDelivery = (rbCourier.Checked);
                    objOrder.MYOBCardFile = int.Parse(ddlMYOBCardFile.SelectedValue);

                    objOrder.Notes = txtNotes.Text;
                    objOrder.IsDateNegotiable = (rbDateYes.Checked == true) ? true : (!rbDateNo.Checked);

                    objOrder.DeliveryOption = (rdoRoadFreight.Checked) ? 1 : (rdoAirbag.Checked) ? 2 : 3;

                    objOrder.IsAcceptedTermsAndConditions = chkTAndC.Checked;
                    objOrder.IsGSTExcluded = chkIsGstExclude.Checked;

                    //Direct Sales Billing Data
                    objOrder.DeliveryCharges = decimal.Parse(txtDeliveryCharges.Text);
                    objOrder.ArtWorkCharges = decimal.Parse(txtArtworkCharges.Text);
                    objOrder.OtherCharges = decimal.Parse(txtOtherCharges.Text);
                    objOrder.OtherChargesDescription = txtOtherChargesDescription.Text;
                    objOrder.BillingAddress = int.Parse(ddlBillingAddress.SelectedValue);
                    objOrder.DespatchToAddress = int.Parse(ddlDespatchAddress.SelectedValue);

                    #endregion

                    #region SaveOrderDetails

                    //List<int> lstODIds = objOrder.OrderDetailsWhereThisIsOrder.Select(m => m.ID).ToList();

                    //foreach (int odID in lstODIds)
                    //{
                    //    OrderDetailBO objODetail = new OrderDetailBO(this.ObjContext);
                    //    objODetail.ID = odID;
                    //    objODetail.GetObject();

                    //    //Delivery details
                    //    objODetail.ShipmentDate = Convert.ToDateTime(txtShipmentDate.Text);
                    //    objODetail.PaymentMethod = int.Parse(ddlPaymentMethod.SelectedValue);
                    //    objODetail.ShipmentMode = int.Parse(ddlShipmentMode.SelectedValue);
                    //    objODetail.IsCourierDelivery = (rbCourier.Checked);
                    //    objODetail.IsWeeklyShipment = (rbWeeklyShipment.Checked);
                    //    if (rbCourier.Checked)
                    //        objODetail.DespatchTo = int.Parse(ddlCourierAddress.SelectedValue);
                    //    else
                    //    {
                    //        // Is weekly shipment selected then depatch to address will Indico Pvt Ltd
                    //        // Goto DistributorClientAddress table and serach for Indico Pvt Ltd and get the ID of that record
                    //        DistributorClientAddressBO address = new DistributorClientAddressBO();
                    //        address.IsAdelaideWarehouse = true;
                    //        var list = address.SearchObjects();
                    //        objODetail.DespatchTo = list.Single().ID; // 105;
                    //    }

                    //    if (RadComboReservations.Items.Count > 0 && !string.IsNullOrEmpty(RadComboReservations.SelectedValue) && int.Parse(RadComboReservations.SelectedValue) > 0)
                    //    {
                    //        objODetail.Reservation = int.Parse(RadComboReservations.SelectedValue);
                    //    }
                    //}

                    //ObjContext.SaveChanges();

                    #endregion

                    #region Process Order Details From temp

                    foreach (OrderDetail objTempOD in ListOrderDetails)
                    {
                        OrderDetailBO objOrderDetail = new OrderDetailBO(ObjContext);

                        if (objTempOD.ID > 0)
                        {
                            objOrderDetail.ID = objTempOD.ID;
                            objOrderDetail.GetObject();
                        }

                        objOrderDetail.OrderType = objTempOD.OrderType;
                        objOrderDetail.Label = objTempOD.Label;

                        objOrderDetail.VisualLayout = objTempOD.VisualLayout;
                        objOrderDetail.Pattern = objTempOD.Pattern;
                        objOrderDetail.FabricCode = objTempOD.Fabric;

                        //objOrderDetail.NameAndNumbersFilePath = objTempOD.;

                        objOrderDetail.VisualLayoutNotes = objTempOD.OrderDetailNotes;
                        objOrderDetail.PhotoApprovalReq = objTempOD.IsPhotoApprovalRequired;
                        objOrderDetail.IsBrandingKit = objTempOD.UseBrandingkit;
                        objOrderDetail.IsLockerPatch = objTempOD.UseLockerPatch;
                        objOrderDetail.RequestedDate = objTempOD.RequestedDate;
                        objOrderDetail.SheduledDate = objTempOD.SheduledDate;
                        objOrderDetail.ShipmentDate = objTempOD.ShipmentDate;
                        objOrderDetail.IsRequiredNamesNumbers = objTempOD.IsNamesAndNumbers;

                        objOrderDetail.EditedPrice = decimal.Parse(objTempOD.EditedPrice);
                        objOrderDetail.Surcharge = decimal.Parse(objTempOD.SurCharge);
                        objOrderDetail.EditedPriceRemarks = objTempOD.PriceComments;
                        objOrderDetail.FactoryInstructions = objTempOD.FactoryInstructions;
                        objOrderDetail.PromoCode = objTempOD.PromoCode;

                        //Delivery details
                        objOrderDetail.ShipmentDate = Convert.ToDateTime(txtShipmentDate.Text);
                        objOrderDetail.PaymentMethod = int.Parse(ddlPaymentMethod.SelectedValue);
                        objOrderDetail.ShipmentMode = int.Parse(ddlShipmentMode.SelectedValue);
                        objOrderDetail.IsCourierDelivery = (rbCourier.Checked);
                        objOrderDetail.IsWeeklyShipment = (rbWeeklyShipment.Checked);

                        if (!string.IsNullOrEmpty(objTempOD.NameAndNumbersFileName))
                        {
                            objOrderDetail.NameAndNumbersFilePath = objTempOD.NameAndNumbersFileName;
                        }

                        if (rbCourier.Checked)
                            objOrderDetail.DespatchTo = int.Parse(ddlCourierAddress.SelectedValue);
                        else
                        {
                            // Is weekly shipment selected then depatch to address will Indico Pvt Ltd
                            // Goto DistributorClientAddress table and serach for Indico Pvt Ltd and get the ID of that record
                            DistributorClientAddressBO address = new DistributorClientAddressBO();
                            address.IsAdelaideWarehouse = true;
                            var list = address.SearchObjects();
                            objOrderDetail.DespatchTo = list.Single().ID; // 105;
                        }

                        if (objTempOD.VisualLayout > 0)
                        {
                            OrderDetailBO objDetail = new OrderDetailBO();
                            objDetail.VisualLayout = objTempOD.VisualLayout;
                            List<OrderDetailBO> lstOrderDetails = objDetail.SearchObjects().Where(o => o.objOrder.Distributor == int.Parse(ddlDistributor.SelectedValue)).ToList();
                            objOrderDetail.IsRepeat = (lstOrderDetails.Count > 0) ? false : true;
                        }

                        foreach (OrderDetailQtyBO objTempQty in objTempOD.ListQtys)
                        {
                            OrderDetailQtyBO objQty = new OrderDetailQtyBO(this.ObjContext);

                            if (objTempOD.ID > 0)
                            {
                                objQty.ID = objTempQty.ID;
                                objQty.GetObject();
                            }

                            objQty.Size = objTempQty.Size;
                            objQty.Qty = objTempQty.Qty;

                            if (objTempOD.ID == 0)
                            {
                                objOrderDetail.OrderDetailQtysWhereThisIsOrderDetail.Add(objQty);
                            }
                        }

                        if (objTempOD.ID == 0)
                        {
                            objOrder.OrderDetailsWhereThisIsOrder.Add(objOrderDetail);
                        }
                    }

                    ObjContext.SaveChanges();

                    int index = 0;
                    foreach (OrderDetailBO objDetail in objOrder.OrderDetailsWhereThisIsOrder)
                    {
                        OrderDetail objODTemp = this.ListOrderDetails[index];

                        if (!string.IsNullOrEmpty(objDetail.NameAndNumbersFilePath))
                        {
                            string oldFilieLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "/NameAndNumbersFiles/" + objDetail.Order.ToString() + "/" + objDetail.ID.ToString() + "/" + objDetail.NameAndNumbersFilePath;
                            if (File.Exists(oldFilieLocation))
                            {
                                File.Delete(oldFilieLocation);
                            }
                        }

                        if (objODTemp.IsNamesAndNumbers && !string.IsNullOrEmpty(objODTemp.NameAndNumbersFileName))
                        {
                            string NNFileSourceLocation = objODTemp.NameAndNumbersFilePath;//IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Temp\\" + objODTemp.NameAndNumbersFileName;
                            string NNFileDestinationPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\NameAndNumbersFiles\\" + objOrder.ID.ToString() + "\\" + objDetail.ID.ToString();

                            if (File.Exists(NNFileSourceLocation))
                            {
                                if (!Directory.Exists(NNFileDestinationPath))
                                    Directory.CreateDirectory(NNFileDestinationPath);
                                File.Copy(NNFileSourceLocation, NNFileDestinationPath + "\\" + objODTemp.NameAndNumbersFileName);
                            }
                        }

                        index++;
                    }

                    #endregion

                    string NNFileTempDirectory = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Temp\\" + objOrder.ID.ToString();
                    Directory.Delete(NNFileTempDirectory, true);

                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Exception occured when adding order infomation", ex);
            }
        }

        private void ProcessOrderDetailForm()
        {
            try
            {
                int index = int.Parse(hdnSelectedID.Value);

                int selectedVisualLayoutID = int.Parse(ddlVlNumber.SelectedValue.ToString());
                DateTime etd = Convert.ToDateTime(txtDesiredDate.Text).AddDays(-14);
                DateTime WeekEndDate = (new WeeklyProductionCapacityBO()).SearchObjects().Where(o => o.WeekNo == GetWeekOfYear(etd) && o.WeekendDate.Year == etd.Year).Select(o => o.WeekendDate).SingleOrDefault();
                OrderDetail objTempOrderDetail;

                List<OrderDetail> lstOrderDetails = this.ListOrderDetails;

                if (index > -1)
                {
                    objTempOrderDetail = lstOrderDetails[index];
                }
                else
                {
                    objTempOrderDetail = new OrderDetail();
                    objTempOrderDetail.Status = "New";
                    objTempOrderDetail.StatusID = 0;
                    objTempOrderDetail.Index = lstOrderDetails.Any() ? lstOrderDetails.Select(m => m.Index).Max() + 1 : 0;
                }

                objTempOrderDetail.IsPhotoApprovalRequired = (chkPhotoApprovalRequired.Checked);
                objTempOrderDetail.UseBrandingkit = (chkBrandingKit.Checked);
                objTempOrderDetail.UseLockerPatch = (chkLockerPatch.Checked);
                objTempOrderDetail.FromVisualLayout = rbVisualLayout.Checked;
                objTempOrderDetail.OrderType = int.Parse(ddlOrderType.SelectedValue);
                objTempOrderDetail.Label = int.Parse(ddlLabel.SelectedValue);
                objTempOrderDetail.RequestedDate = WeekEndDate;
                objTempOrderDetail.SheduledDate = WeekEndDate;
                objTempOrderDetail.ShipmentDate = WeekEndDate;

                if (objTempOrderDetail.FromVisualLayout)
                {
                    objTempOrderDetail.VisualLayout = int.Parse(ddlVlNumber.SelectedValue.ToString());
                    objTempOrderDetail.VisualLayoutName = ddlVlNumber.SelectedItem.Text;

                    VisualLayoutBO objVL = new VisualLayoutBO();
                    objVL.ID = objTempOrderDetail.VisualLayout;
                    objVL.GetObject();

                    objTempOrderDetail.VisualLayoutName = objVL.NamePrefix;
                    objTempOrderDetail.Pattern = objVL.Pattern;
                    objTempOrderDetail.Fabric = objVL.FabricCode ?? 0;
                    objTempOrderDetail.PatternName = objVL.objPattern.Number;
                    objTempOrderDetail.FabricName = objVL.objFabricCode.NickName;
                }
                else
                {
                    objTempOrderDetail.Pattern = int.Parse(ddlPattern.SelectedValue.ToString());
                    objTempOrderDetail.Fabric = int.Parse(ddlFabric.SelectedValue.ToString());

                    PatternBO objPattern = new PatternBO();
                    objPattern.ID = objTempOrderDetail.Pattern;
                    objPattern.GetObject();

                    FabricCodeBO objFabric = new FabricCodeBO();
                    objFabric.ID = objTempOrderDetail.Fabric;
                    objFabric.GetObject();

                    objTempOrderDetail.PatternName = objPattern.Number;
                    objTempOrderDetail.FabricName = objFabric.NickName;
                }

                objTempOrderDetail.OrderTypeName = ddlOrderType.SelectedItem.Text;

                objTempOrderDetail.PromoCode = txtPromoCode.Text;
                objTempOrderDetail.EditedPrice = txtDistributorPrice.Text;
                //objTempOrderDetail.NormalMargin = txtPercentage.Text;
                objTempOrderDetail.SurCharge = txtSurcharge.Text;
                objTempOrderDetail.PriceComments = txtPriceComments.Text;
                objTempOrderDetail.OrderDetailNotes = txtOdNotes.Text;
                objTempOrderDetail.FactoryInstructions = txtFactoryDescription.Text;
                objTempOrderDetail.IsNamesAndNumbers = (rbNaNuYes.Checked == true) ? true : (!rbNaNuNo.Checked);

                if (RadComboReservations.Items.Count > 0 && !string.IsNullOrEmpty(RadComboReservations.SelectedValue) && int.Parse(RadComboReservations.SelectedValue) > 0)
                {
                    objTempOrderDetail.Reservation = int.Parse(RadComboReservations.SelectedValue);
                }

                OrderDetailBO objDetail = new OrderDetailBO();
                objDetail.VisualLayout = selectedVisualLayoutID;
                List<OrderDetailBO> lstOrderDetailBOs = objDetail.SearchObjects().Where(o => o.objOrder.Distributor == int.Parse(ddlDistributor.SelectedValue)).ToList();
                objTempOrderDetail.IsRepeat = (lstOrderDetailBOs.Count > 0) ? false : true;

                objTempOrderDetail.ListQtys = new List<OrderDetailQtyBO>();

                foreach (RepeaterItem item in rptSizeQty.Items)
                {
                    int orderQtyId = int.Parse(((HiddenField)item.FindControl("hdnQtyID")).Value);
                    TextBox txtQty = (TextBox)item.FindControl("txtQty");

                    OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                    objOrderDetailQty.ID = orderQtyId;
                    objOrderDetailQty.Size = int.Parse(txtQty.Attributes["size"].ToString());
                    objOrderDetailQty.Qty = int.Parse(txtQty.Text);

                    objTempOrderDetail.ListQtys.Add(objOrderDetailQty);
                }

                //NN Files
                string NNFileName = hdnUploadFiles.Value.Split(',')[0]; // asd_345.txt,ASD.txt
                objTempOrderDetail.IsNamesAndNumbers = rbNaNuYes.Checked;

                if (!string.IsNullOrEmpty(NNFileName))
                {
                    objTempOrderDetail.NameAndNumbersFileName = NNFileName;
                    //}

                    //NN File Processing
                    //if (!string.IsNullOrEmpty(objOrderDetail.NameAndNumbersFilePath))
                    //{

                    string NNFileTempDirectory = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Temp\\" + lstOrderDetails.First().Order.ToString();
                    if (!Directory.Exists(NNFileTempDirectory))
                        Directory.CreateDirectory(NNFileTempDirectory);

                    string NNFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Temp\\" + NNFileName; // GetNameNumberFilePath(objOrderDetail.ID);
                    string NNTempPath = NNFileTempDirectory + "\\" + objTempOrderDetail.Index.ToString();
                    Directory.CreateDirectory(NNTempPath);

                    objTempOrderDetail.NameAndNumbersFilePath = NNTempPath + "\\" + NNFileName;

                    File.Copy(NNFilePath, objTempOrderDetail.NameAndNumbersFilePath);
                }

                if (index > -1)
                {
                    lstOrderDetails[index] = objTempOrderDetail;
                }
                else
                {
                    lstOrderDetails.Add(objTempOrderDetail);
                }

                this.ListOrderDetails = lstOrderDetails;

                dgOrderItems.DataSource = this.ListOrderDetails;
                dgOrderItems.DataBind();

                dgOrderItems.Visible = this.ListOrderDetails.Any();
                dvNoOrders.Visible = !this.ListOrderDetails.Any();

                this.lblTotalQty.InnerText = "Total Qty: " + this.ListOrderDetails.Sum(m => m.ListQtys.Sum(n => n.Qty)).ToString();
                this.hdnTotalQuantity.Value = "0";
            }
            catch (Exception ex)
            {

            }
        }

        private void PopulateOrderStatus(int orderId)
        {
            List<OrderStatusBO> lstOrderStatus = new OrderStatusBO().SearchObjects();

            ddlStatus.Items.Clear();
            foreach (OrderStatusBO orderStatus in lstOrderStatus)
            {
                ddlStatus.Items.Add(new ListItem(orderStatus.Name, orderStatus.ID.ToString()));
            }

            if (orderId > 0)
            {
                OrderBO objOrder = new OrderBO();
                objOrder.ID = orderId;
                objOrder.GetObject();

                ddlStatus.Items.FindByValue(objOrder.Status.ToString()).Selected = true;
            }
            else
            {
                ddlStatus.Items.FindByValue("18").Selected = true;
            }
        }

        //private void PopulateOrderStatus(int orderId)
        //{
        //    OrderStatusBO objOrderStatus = new OrderStatusBO();
        //    List<OrderStatusBO> lstOrderStatus = new List<OrderStatusBO>();
        //    int inProgress = 0;
        //    int Completed = 0;
        //    // int notStarted = 0;
        //    int orderDetailCount = 0;


        //    if (orderId > 0)
        //    {
        //        OrderBO objOrder = new OrderBO();
        //        objOrder.ID = orderId;
        //        objOrder.GetObject();
        //        orderDetailCount = objOrder.OrderDetailsWhereThisIsOrder.Count;

        //        // var hasOrderdetailStatus = objOrder.OrderDetailsWhereThisIsOrder.Where(o => o.Status != null).ToList();

        //        if ((GetOrderStatus(objOrder.objStatus.ID) == OrderStatus.New) /*&& hasOrderdetailStatus.Count > 0*/)
        //        {
        //            if (LoggedUserRoleName == UserRole.IndicoAdministrator || LoggedUserRoleName == UserRole.IndicoCoordinator)
        //            {
        //                lstOrderStatus = (from o in objOrderStatus.GetAllObject().Where(o => GetOrderStatus(o.ID) != OrderStatus.Completed &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.PartialyCompleted &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.InProgress &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.FactoryHold &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.DistributorSubmitted &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.IndimanHold &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.IndimanSubmitted)
        //                                  select o).ToList();
        //            }
        //            else if (LoggedUserRoleName == UserRole.IndimanAdministrator || LoggedUserRoleName == UserRole.IndimanCoordinator)
        //            {
        //                lstOrderStatus = (from o in objOrderStatus.GetAllObject().Where(o => GetOrderStatus(o.ID) != OrderStatus.Completed &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.PartialyCompleted &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.InProgress &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.FactoryHold &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.DistributorSubmitted &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.IndicoHold &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.IndicoSubmitted)
        //                                  select o).ToList();
        //            }
        //        }
        //        else if (GetOrderStatus(objOrder.objStatus.ID) == OrderStatus.DistributorSubmitted /*&& hasOrderdetailStatus.Count > 0*/)
        //        {
        //            lstOrderStatus = (from o in objOrderStatus.GetAllObject().Where(o => GetOrderStatus(o.ID) != OrderStatus.Completed &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.PartialyCompleted &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.InProgress &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.FactoryHold &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.New &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.IndimanHold &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.IndimanSubmitted)
        //                              select o).ToList();
        //        }
        //        else if (GetOrderStatus(objOrder.objStatus.ID) == OrderStatus.IndicoHold /*&& hasOrderdetailStatus.Count > 0*/)
        //        {
        //            lstOrderStatus = (from o in objOrderStatus.GetAllObject().Where(o => GetOrderStatus(o.ID) != OrderStatus.Completed &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.PartialyCompleted &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.InProgress &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.FactoryHold &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.New &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.DistributorSubmitted &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.IndimanHold &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.IndimanSubmitted)
        //                              select o).ToList();
        //        }
        //        else if (GetOrderStatus(objOrder.objStatus.ID) == OrderStatus.IndicoSubmitted /*&& hasOrderdetailStatus.Count > 0*/)
        //        {
        //            if (LoggedUserRoleName == UserRole.IndicoAdministrator || LoggedUserRoleName == UserRole.IndicoCoordinator)
        //            {
        //                lstOrderStatus = (from o in objOrderStatus.GetAllObject().Where(o => GetOrderStatus(o.ID) != OrderStatus.Completed &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.PartialyCompleted &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.InProgress &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.FactoryHold &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.New &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.DistributorSubmitted &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.IndicoHold &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.IndimanHold &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.IndimanSubmitted)
        //                                  select o).ToList();
        //            }
        //            else if (LoggedUserRoleName == UserRole.IndimanAdministrator || LoggedUserRoleName == UserRole.IndimanCoordinator)
        //            {
        //                lstOrderStatus = (from o in objOrderStatus.GetAllObject().Where(o => GetOrderStatus(o.ID) != OrderStatus.Completed &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.PartialyCompleted &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.InProgress &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.FactoryHold &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.New &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.DistributorSubmitted &&
        //                                                                                     GetOrderStatus(o.ID) != OrderStatus.IndicoHold)
        //                                  select o).ToList();
        //            }
        //        }
        //        else if (GetOrderStatus(objOrder.objStatus.ID) == OrderStatus.IndimanHold /*&& hasOrderdetailStatus.Count > 0*/)
        //        {
        //            lstOrderStatus = (from o in objOrderStatus.GetAllObject().Where(o => GetOrderStatus(o.ID) != OrderStatus.Completed &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.PartialyCompleted &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.InProgress &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.FactoryHold &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.New &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.DistributorSubmitted &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.IndicoHold &&
        //                                                                                 GetOrderStatus(o.ID) != OrderStatus.IndicoSubmitted)
        //                              select o).ToList();
        //        }
        //        else if (GetOrderStatus(objOrder.objStatus.ID) == OrderStatus.IndicoHold /*&& hasOrderdetailStatus.Count > 0*/)
        //        {
        //            lstOrderStatus = (from o in objOrderStatus.SearchObjects().Where(o => GetOrderStatus(o.ID) != OrderStatus.FactoryHold &&
        //                                                                                  GetOrderStatus(o.ID) != OrderStatus.IndimanHold &&
        //                                                                                  GetOrderStatus(o.ID) != OrderStatus.InProgress &&
        //                                                                                  GetOrderStatus(o.ID) != OrderStatus.PartialyCompleted &&
        //                                                                                  GetOrderStatus(o.ID) != OrderStatus.Completed)
        //                              select o).ToList();
        //        }
        //        else if (GetOrderStatus(objOrder.objStatus.ID) == OrderStatus.IndimanSubmitted /*&& hasOrderdetailStatus.Count > 0*/)
        //        {
        //            lstOrderStatus = (from o in objOrderStatus.SearchObjects().Where(o => GetOrderStatus(o.ID) != OrderStatus.New &&
        //                                                                                  GetOrderStatus(o.ID) != OrderStatus.IndicoHold &&
        //                                                                                  GetOrderStatus(o.ID) != OrderStatus.IndicoSubmitted)
        //                              select o).ToList();
        //        }
        //        else if (GetOrderStatus(objOrder.objStatus.ID) == OrderStatus.FactoryHold /*&& hasOrderdetailStatus.Count > 0*/)
        //        {
        //            lstOrderStatus = (from o in objOrderStatus.SearchObjects().Where(o => GetOrderStatus(o.ID) == OrderStatus.FactoryHold ||
        //                                                                                  GetOrderStatus(o.ID) == OrderStatus.Cancelled ||
        //                                                                                  GetOrderStatus(o.ID) == OrderStatus.InProgress ||
        //                                                                                  GetOrderStatus(o.ID) == OrderStatus.IndimanSubmitted ||
        //                                                                                  GetOrderStatus(o.ID) == OrderStatus.PartialyCompleted ||
        //                                                                                  GetOrderStatus(o.ID) == OrderStatus.Completed)
        //                              select o).ToList();
        //        }
        //        else if (GetOrderStatus(objOrder.objStatus.ID) == OrderStatus.Completed)
        //        {
        //            lstOrderStatus = (from o in objOrderStatus.SearchObjects().Where(o => GetOrderStatus(o.ID) == OrderStatus.Completed) select o).ToList();
        //        }
        //        else if (GetOrderStatus(objOrder.objStatus.ID) == OrderStatus.PartialyCompleted)
        //        {
        //            lstOrderStatus = (from o in objOrderStatus.SearchObjects().Where(o => GetOrderStatus(o.ID) == OrderStatus.PartialyCompleted ||
        //                                                                                  GetOrderStatus(o.ID) == OrderStatus.Cancelled)
        //                              select o).ToList();
        //        }
        //        else if (GetOrderStatus(objOrder.objStatus.ID) == OrderStatus.InProgress)
        //        {
        //            lstOrderStatus = (from o in objOrderStatus.SearchObjects().Where(o => GetOrderStatus(o.ID) == OrderStatus.InProgress ||
        //                                                                                  GetOrderStatus(o.ID) == OrderStatus.PartialyCompleted ||
        //                                                                                  GetOrderStatus(o.ID) == OrderStatus.Completed ||
        //                                                                                  GetOrderStatus(o.ID) == OrderStatus.Cancelled)
        //                              select o).ToList();
        //        }

        //        else if (GetOrderStatus(objOrder.objStatus.ID) == OrderStatus.Cancelled)
        //        {
        //            lstOrderStatus = (from o in objOrderStatus.SearchObjects().Where(o => GetOrderStatus(o.ID) == OrderStatus.Cancelled)
        //                              select o).ToList();
        //        }
        //    }
        //    else
        //    {
        //        //Not Submitted ----> Not Submitted, Submitted
        //        lstOrderStatus = objOrderStatus.GetAllObject().Take(1).ToList();
        //    }

        //    ddlStatus.Items.Clear();
        //    foreach (OrderStatusBO orderStatus in lstOrderStatus)
        //    {
        //        ddlStatus.Items.Add(new ListItem(orderStatus.Name, orderStatus.ID.ToString()));
        //    }
        //    if (orderId > 0)
        //    {
        //        OrderBO objOrder = new OrderBO();
        //        objOrder.ID = orderId;
        //        objOrder.GetObject();

        //        foreach (ListItem item in ddlStatus.Items)
        //        {
        //            if (item.Selected)
        //                ddlStatus.Items.FindByValue(item.Value).Selected = false;
        //        }

        //        if ((inProgress == 0 || Completed == 0) && orderDetailCount == 0)
        //        {
        //            ddlStatus.Items.FindByValue(objOrder.Status.ToString()).Selected = true;
        //        }
        //        else
        //        {
        //            lstOrderStatus = lstOrderStatus.Where(o => o.ID == objOrder.Status).ToList();
        //            if (lstOrderStatus.Count > 0)
        //            {
        //                ddlStatus.Items.FindByValue(objOrder.Status.ToString()).Selected = true;
        //            }
        //        }
        //    }
        //}

        private void PopulateOrderDetails()
        {
            List<ReturnOrderDetailsIndicoPriceViewBO> lstOrderDetails = new List<ReturnOrderDetailsIndicoPriceViewBO>();

            if (OrderID > 0)
            {
                OrderBO objOrder = new OrderBO();
                objOrder.ID = orderID;
                objOrder.GetObject();

                lstOrderDetails = OrderBO.GetOrderDetails(objOrder.ID, (objOrder.PaymentMethod != null && objOrder.PaymentMethod > 0) ? (objOrder.PaymentMethod == 1) ? 1 : 2 : 1);

                OrderDetailBO objOrderDetail = new OrderDetailBO();
                objOrderDetail.ID = lstOrderDetails.First().OrderDetail ?? 0;
                objOrderDetail.GetObject();

                ddlPaymentMethod.ClearSelection();
                ddlShipmentMode.ClearSelection();
                ddlCourierAddress.ClearSelection();

                ddlShipmentMode.Items.FindByValue(objOrderDetail.ShipmentMode.ToString()).Selected = true;
                ddlPaymentMethod.Items.FindByValue(objOrderDetail.PaymentMethod.ToString()).Selected = true;
                txtShipmentDate.Text = objOrderDetail.ShipmentDate.ToString("dd MMM yyyy");
                rbWeeklyShipment.Checked = objOrderDetail.IsWeeklyShipment ?? false;
                rbCourier.Checked = objOrderDetail.IsCourierDelivery ?? false;

                if (rbCourier.Checked)
                    ddlCourierAddress.Items.FindByValue(objOrderDetail.DespatchTo.ToString()).Selected = true;

                this.ListOrderDetails = PopulateTempOrderDetails(lstOrderDetails);

                dgOrderItems.DataSource = this.ListOrderDetails;
                dgOrderItems.DataBind();
            }

            dgOrderItems.Visible = (lstOrderDetails.Count() > 0);
            dvNoOrders.Visible = !(lstOrderDetails.Count() > 0);

            this.lblTotalQty.InnerText = "Total Qty: " + lstOrderDetails.Sum(m => m.Quantity).ToString();
            this.hdnTotalQuantity.Value = "0";
        }

        private void PopulateVisualLayouts(int jobName)
        {
            if (jobName > 0)
            {
                List<VisualLayoutBO> lstVisualLayout = new List<VisualLayoutBO>();
                VisualLayoutBO objVisualLayout = new VisualLayoutBO();

                ddlVlNumber.Items.Clear();
                ddlVlNumber.Items.Add(new ListItem("Select Visual Layout Number", "0"));

                objVisualLayout.Client = jobName;
                lstVisualLayout = objVisualLayout.SearchObjects().Where(m => (m.FabricCode ?? 0) > 0 && m.Pattern > 0).ToList();

                foreach (VisualLayoutBO vlNumber in lstVisualLayout)
                {
                    string vlText = ((vlNumber.NameSuffix == null) ? vlNumber.NamePrefix : vlNumber.NamePrefix + vlNumber.NameSuffix) + " - Pattern : " + vlNumber.objPattern.Number;
                    vlText += (vlNumber.FabricCode.HasValue && vlNumber.FabricCode.Value > 0) ? " - Fabric : " + vlNumber.objFabricCode.NickName : string.Empty;
                    ddlVlNumber.Items.Add(new ListItem(vlText, vlNumber.ID.ToString()));
                }
            }
        }

        private void PopulatePaymentMethod(Boolean isNew)
        {
            ddlPaymentMethod.Items.Clear();
            //ddlPaymentMethod.Items.Add(new ListItem("Select Payment Term", "0"));
            List<PaymentMethodBO> lstPaymentMethod = (new PaymentMethodBO()).GetAllObject();
            foreach (PaymentMethodBO paymentMode in lstPaymentMethod)
            {
                ddlPaymentMethod.Items.Add(new ListItem(paymentMode.Name, paymentMode.ID.ToString()));
            }

            if (isNew)
            {
                ddlPaymentMethod.SelectedValue = ddlPaymentMethod.Items.FindByValue(lstPaymentMethod.Last().ID.ToString()).Value;
            }
            else
            {
                if (OrderID == 0)
                {
                    ddlPaymentMethod.SelectedValue = ddlPaymentMethod.Items.FindByValue(lstPaymentMethod.First().ID.ToString()).Value;
                }
            }
        }

        private void DownloadOrderReport()
        {
            try
            {
                decimal deliveryCharge = string.IsNullOrEmpty(txtDeliveryCharges.Text) ? 0 : decimal.Parse(txtDeliveryCharges.Text);
                decimal artWorkCharge = string.IsNullOrEmpty(txtArtworkCharges.Text) ? 0 : decimal.Parse(txtArtworkCharges.Text);
                decimal additionalCharge = string.IsNullOrEmpty(txtOtherCharges.Text) ? 0 : decimal.Parse(txtOtherCharges.Text);
                decimal gstAmount = string.IsNullOrEmpty(txtGST.Text) ? 0 : decimal.Parse(txtGST.Text);

                string pdfFilePath = Common.GenerateOdsPdf.GenerateOrderReport(OrderID, deliveryCharge, artWorkCharge, additionalCharge, gstAmount);
                DownloadPDFFile(pdfFilePath);
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while printing JKInvoiceSummary from AddEditInvoice.aspx", ex);
            }
        }

        private void ValidateOrder()
        {
            CustomValidator cv = null;

            rfvOrderType.Enabled = false;
            rfvLabel.Enabled = false;

            //if ((DateTime.Parse(txtDesiredDate.Text) - DateTime.Parse(txtShipmentDate.Text)).TotalDays < 5)
            //{
            //    cv = new CustomValidator();
            //    cv.IsValid = false;
            //    cv.ValidationGroup = "valGrpOrderHeader";
            //    cv.ErrorMessage = "Difference between shipment date and required date is 5 days. Please verify it is adequate to meet the deadline.";
            //    Page.Validators.Add(cv);
            //}

            if (dgOrderItems.Items.Count == 0)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpOrderHeader";
                cv.ErrorMessage = "No orders have been added";
                Page.Validators.Add(cv);
            }
        }

        private void ResetDropdowns()
        {
            foreach (Control control in dvPageContent.Controls)
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

        private void DisableControls()
        {
            dgOrderItems.Columns[7].Visible = false;
            dgOrderItems.Columns[8].Visible = false;
            btnAddOrder.Visible = false;
            ancNewPaymentMethod.Visible = false;

            foreach (Control control in dvPageContent.Controls)
            {
                if (control is DropDownList)
                {
                    if (((DropDownList)control).ID != "ddlStatus")
                        ((DropDownList)control).Enabled = false;
                }
                else if (control is TextBox)
                    ((TextBox)control).Enabled = false;
                else if (control is RadioButtonList)
                    ((RadioButtonList)control).Enabled = false;
                else if (control is CheckBox)
                    ((CheckBox)control).Enabled = false;
            }
        }

        private void PopulateDistributorClients(int distributor)
        {
            //Populate Clients
            ddlClient.Items.Clear();
            ddlClient.Items.Add(new ListItem("Select Client", "0"));

            lblDistributorAddress.Text = string.Empty;

            if (distributor > 0)
            {
                ClientBO objClient = new ClientBO();
                objClient.Distributor = distributor;
                List<ClientBO> lstClients = objClient.SearchObjects().OrderBy(o => o.Name).ToList();

                foreach (ClientBO client in lstClients)
                {
                    ddlClient.Items.Add(new ListItem(client.Name, client.ID.ToString()));
                }

                CompanyBO objDistributor = new CompanyBO();
                objDistributor.ID = distributor;
                objDistributor.GetObject();

                if (objDistributor.Number != null && objDistributor.Address1 != null && objDistributor.City != null && objDistributor.State != null && objDistributor.Postcode != null)
                {
                    lblDistributorAddress.Text = objDistributor.Number + "  " + objDistributor.Address1 + "  " + objDistributor.City + "  " + objDistributor.State + "  " + objDistributor.Postcode + "  " + objDistributor.objCountry.ShortName;
                    lblDistributorAddress.ForeColor = Color.Black;
                }
                else
                {
                    lblDistributorAddress.Text = "Address details are not available for this Distributor";
                    lblDistributorAddress.ForeColor = Color.Red;
                }

                PopulateClientAddresses(distributor, 0, 0);
            }

            lblDistributorAddress.Visible = true;
            ddlClient.Enabled = true;
            liClient.Visible = true;

            populateLabels(distributor);
            PopulateMYOBCardNumber(distributor);

            if (newClient > 0)
            {
                ddlClient.ClearSelection();
                ddlClient.Items.FindByValue(newClient.ToString()).Selected = true;
            }

            if (distributor > 0) //  && this.LoggedUser.IsDirectSalesPerson
            {
                aAddClient.Visible = true;
            }
            else
            {
                aAddClient.Visible = false;
            }
        }

        private void PopulateJobNames(int client)
        {
            ResetViewStateValues();

            ddlJobName.Items.Clear();
            ddlJobName.Items.Add(new ListItem("Select Job Name", "0"));
            litClient.Text = string.Empty;
            btnEditClient.Visible = false;

            ancNewJobName.Visible = false;
            litJobName.Text = string.Empty;
            btnEditJobName.Visible = false;

            if (client > 0)
            {
                JobNameBO objJob = new JobNameBO();
                objJob.Client = client;

                List<JobNameBO> lstJobNames = objJob.SearchObjects();

                foreach (JobNameBO jobName in lstJobNames)
                {
                    ddlJobName.Items.Add(new ListItem(jobName.Name, jobName.ID.ToString()));
                }

                ClientBO objClient = new ClientBO();
                objClient.ID = client;
                objClient.GetObject();

                litClient.Text = objClient.Name;
                lblFOCPenaltyClient.Visible = objClient.FOCPenalty ? true : false;
                if (objClient.FOCPenalty)
                {
                    liClient.Style.Add("background-color", "red");
                }
                else
                {
                    liClient.Style.Remove("background-color");
                }
                aAddClient.Visible = true;
                btnEditClient.Visible = true;
                ancNewJobName.Visible = true;
            }
        }

        private void populateLabels(int distributor)
        {
            ddlLabel.Items.Clear();
            ddlLabel.Items.Add(new ListItem("Select Label", "0"));

            if (distributor > 0)
            {
                CompanyBO objDistributor = new CompanyBO();
                objDistributor.ID = distributor;
                objDistributor.GetObject(false);

                List<LabelBO> lstLabels = objDistributor.DistributorLabelsWhereThisIsDistributor;

                foreach (LabelBO label in lstLabels)
                {
                    ListItem listItemLabel = new ListItem(label.Name, label.ID.ToString());
                    ddlLabel.Items.Add(listItemLabel);
                }
            }
        }

        private void PopulateMYOBCardNumber(int dristributor)
        {
            ddlMYOBCardFile.Items.Clear();
            ddlMYOBCardFile.Items.Add(new ListItem("Select MYOB Card File", "0"));

            if (dristributor > 0)
            {
                List<MYOBCardFileBO> lstMYOB = (new MYOBCardFileBO()).SearchObjects().OrderBy(m => m.Name).ToList();

                foreach (MYOBCardFileBO label in lstMYOB)
                {
                    ListItem listItemLabel = new ListItem(label.Name, label.ID.ToString());
                    ddlMYOBCardFile.Items.Add(listItemLabel);
                }
            }

            //ddlMYOBCardFile.Enabled = (ddlMYOBCardFile.Items.Count > 1) ? true : false;
        }

        private void populateJobNameDetails(int jobName)
        {
            ResetViewStateValues();

            hdnSelectedDistributorId.Value = ddlDistributor.SelectedValue.ToString();
            hdnSelectedClientId.Value = ddlJobName.SelectedValue.ToString();

            ancNewJobName.Visible = true;
            litJobName.Text = string.Empty;
            btnEditJobName.Visible = false;

            if (OrderID > 0)//delete order items if exist.
            {
                OrderBO objOrder = new OrderBO();
                objOrder.ID = OrderID;
                objOrder.GetObject();

                if (objOrder.OrderDetailsWhereThisIsOrder.Count > 0)
                {
                    //ViewState["PopulateDeleteOrdersMsg"] = true;
                    return;
                }
            }

            PopulateVisualLayouts(jobName);
            //PopulateClientAddresses(jobName, billingAddress, despatchAddress);
            PopulateVlImage(0);

            if (jobName > 0)
            {
                hdnSelectedID.Value = "0";
                txtOdNotes.Text = "";

                ddlOrderType.ClearSelection();
                ddlVlNumber.ClearSelection();
                ddlVlNumber.Enabled = true;

                litJobName.Text = string.Empty;
                btnEditJobName.Visible = true;

                JobNameBO objJobName = new JobNameBO();
                objJobName.ID = jobName;
                objJobName.GetObject();

                litJobName.Text = objJobName.Name;
                btnEditJobName.Visible = true;
            }
            //else
            //{
            //    aAddShippingAddress.Visible = false;
            //    ancDespatchAddress.Visible = false;
            //    lblBillingAddress.Text = lblDespatchAddress.Text = string.Empty;
            //}

            rptSizeQty.DataSource = null;
            rptSizeQty.DataBind();

            if (QueryReservationID > 0)
            {
                ReservationBO objReservation = new ReservationBO();
                objReservation.ID = QueryReservationID;
                objReservation.GetObject();
                int orderDetailQty = 0;
                foreach (OrderBO o in objReservation.OrdersWhereThisIsReservation)
                {
                    if (o.OrderDetailsWhereThisIsOrder.Count > 0)
                    {
                        orderDetailQty += o.OrderDetailsWhereThisIsOrder[0].OrderDetailQtysWhereThisIsOrderDetail.Sum(m => m.Qty);
                    }
                }
                int reservationQty = objReservation.Qty - orderDetailQty;
                if (QueryReservationID > 0)
                {
                    lblreservationQty.Text = "Only " + reservationQty + " quentities available for this reservation";
                }
                else
                {
                    lblreservationQty.Text = "";
                }
            }
        }

        private void PoplatePatterns()
        {
            ddlPattern.Items.Clear();
            ddlPattern.Items.Add(new ListItem("Select Pattern", "0"));

            PatternBO objPattern = new PatternBO();
            objPattern.IsActive = true;
            List<PatternBO> lstPatterns = objPattern.SearchObjects();

            foreach (PatternBO pt in lstPatterns)
            {
                this.ddlPattern.Items.Add(new ListItem(pt.Number + " - " + pt.NickName, pt.ID.ToString()));
            }
        }

        private void PopulateFabrics(int pattern)
        {
            ddlFabric.Items.Clear();

            if (pattern > 0)
            {
                ddlFabric.Items.Add(new ListItem("Select Fabric", "0"));

                PatternBO objPattern = new PatternBO();
                objPattern.ID = pattern;
                objPattern.GetObject();

                List<FabricCodeBO> lstFabricCodes = objPattern.PricesWhereThisIsPattern.Select(m => m.objFabricCode).ToList();

                foreach (FabricCodeBO fc in lstFabricCodes)
                {
                    this.ddlFabric.Items.Add(new ListItem(fc.NickName + " (" + fc.Code + ")", fc.ID.ToString()));
                }
            }
        }

        private void PopulateVlImage(int VisualLayoutId)
        {
            string filepath = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
            if (VisualLayoutId > 0)
            {
                filepath = IndicoPage.GetVLImagePath(VisualLayoutId);
                if (string.IsNullOrEmpty(filepath))
                {
                    filepath = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }
            }
            imgvlImage.ImageUrl = filepath;
        }

        private void PopulateClientAddresses(int distributor, int billingID = 0, int despatchID = 0, int courierID = 0)
        {
            ddlBillingAddress.Items.Clear();
            ddlDespatchAddress.Items.Clear();
            ddlCourierAddress.Items.Clear();
            lblBillingAddress.Text = string.Empty;
            lblDespatchAddress.Text = string.Empty;

            btnEditCourier.Visible = false;
            btnEditBilling.Visible = false;
            btnEditDespatch.Visible = false;

            if (distributor > 0)
            {
                DistributorClientAddressBO objDisClientAddress = new DistributorClientAddressBO();
                //objDisClientAddress.Client = jobName;
                objDisClientAddress.Distributor = distributor;
                List<DistributorClientAddressBO> lstDistributorClientAddress = objDisClientAddress.SearchObjects();

                //if (this.LoggedUser.IsDirectSalesPerson)
                //{
                //    lstDistributorClientAddress = lstDistributorClientAddress.Where(m => m.Client > 0 && m.objClient.objClient.Distributor == this.Distributor.ID).ToList();
                //}

                ddlBillingAddress.Items.Add(new ListItem("Select Billing Address", "0"));
                ddlDespatchAddress.Items.Add(new ListItem("Select Despatch Address", "0"));
                ddlCourierAddress.Items.Add(new ListItem("Select Despatch Address", "0"));

                foreach (DistributorClientAddressBO item in lstDistributorClientAddress)
                {
                    ddlBillingAddress.Items.Add(new ListItem(item.CompanyName, item.ID.ToString()));
                    ddlDespatchAddress.Items.Add(new ListItem(item.CompanyName, item.ID.ToString()));
                    ddlCourierAddress.Items.Add(new ListItem(item.CompanyName, item.ID.ToString()));
                }

                ddlBillingAddress.Enabled = true;
                ddlDespatchAddress.Enabled = true;
                ddlCourierAddress.Enabled = true;
                aAddShippingAddress.Visible = true;
                ancDespatchAddress.Visible = true;
                ancCourierAddress.Visible = true;

                lblBillingAddress.Text = lblDespatchAddress.Text = lblCourierAddress.Text = string.Empty;

                if (billingID > 0)
                {
                    btnEditBilling.Visible = true;
                    ddlBillingAddress.Items.FindByValue(billingID.ToString()).Selected = true;

                    DistributorClientAddressBO objDCA = new DistributorClientAddressBO();
                    objDCA.ID = billingID;
                    objDCA.GetObject();

                    lblBillingAddress.Text = objDCA.CompanyName + "  " + objDCA.Address + "  " + objDCA.PostCode + "  " + objDCA.Suburb + "  " +
                            objDCA.PostCode + "  " + objDCA.State + "  " + objDCA.objCountry.ShortName;
                }

                if (despatchID > 0)
                {
                    btnEditDespatch.Visible = true;
                    ddlDespatchAddress.Items.FindByValue(despatchID.ToString()).Selected = true;

                    DistributorClientAddressBO objDCAD = new DistributorClientAddressBO();
                    objDCAD.ID = despatchID;
                    objDCAD.GetObject();

                    lblDespatchAddress.Text = objDCAD.CompanyName + "  " + objDCAD.Address + "  " + objDCAD.PostCode + "  " + objDCAD.Suburb + "  " +
                            objDCAD.PostCode + "  " + objDCAD.State + "  " + objDCAD.objCountry.ShortName;
                }

                if (courierID > 0)
                {
                    btnEditCourier.Visible = true;
                    ddlCourierAddress.Items.FindByValue(courierID.ToString()).Selected = true;

                    DistributorClientAddressBO objDCAD = new DistributorClientAddressBO();
                    objDCAD.ID = courierID;
                    objDCAD.GetObject();

                    lblCourierAddress.Text = objDCAD.CompanyName + "  " + objDCAD.Address + "  " + objDCAD.PostCode + "  " + objDCAD.Suburb + "  " +
                            objDCAD.PostCode + "  " + objDCAD.State + "  " + objDCAD.objCountry.ShortName;
                }
            }
            else
            {
                aAddShippingAddress.Visible = false;
                ancDespatchAddress.Visible = false;
            }
        }

        private void PopulateReservations(int? vlid, int? awid, bool IsEditClick = false)
        {
            RadComboReservations.Items.Clear();

            List<ReservationBO> lstReservations = new List<ReservationBO>();
            ReservationBO objReservation = new ReservationBO();

            if (QueryID > 0 || OrderID > 0)
            {
                OrderBO objOrder = new OrderBO();
                objOrder.ID = (QueryID > 0) ? QueryID : OrderID;
                objOrder.GetObject();

                objReservation.Distributor = objOrder.Distributor;
                lstReservations = objReservation.SearchObjects();

                if (!IsEditClick)
                {
                    foreach (int res in objOrder.OrderDetailsWhereThisIsOrder.Select(m => (m.Reservation != null) ? m.Reservation : 0))
                    {
                        lstReservations = lstReservations.Where(m => m.ID != res).ToList();
                    }
                }
            }
            else
            {
                objReservation.Distributor = int.Parse(ddlDistributor.SelectedValue);
                lstReservations = objReservation.SearchObjects();
            }

            //PopulateReservationsDetails();

            if (lstReservations.Count > 0)
            {
                RadComboReservations.Enabled = true;

                RadComboReservations.DataSource = lstReservations;
                RadComboReservations.DataBind();
            }

            if (QueryID == 0 || OrderID == 0)
            {
                OrderDetailBO objOrderDetail = new OrderDetailBO();
                List<OrderDetailBO> lstOrderDetails = new List<OrderDetailBO>();

                if (vlid.HasValue && vlid > 0)
                {
                    objOrderDetail.VisualLayout = vlid;
                    lstOrderDetails = objOrderDetail.SearchObjects().Where(o => o.objOrder.Distributor == int.Parse(ddlDistributor.SelectedValue)).ToList();
                }
                else if (awid.HasValue && awid > 0)
                {
                    objOrderDetail.ArtWork = awid;
                    lstOrderDetails = objOrderDetail.SearchObjects().Where(o => o.objOrder.Distributor == int.Parse(ddlDistributor.SelectedValue)).ToList();
                }

                txtIsNew.Text = (lstOrderDetails.Count > 0) ? "Repeat" : "New";
            }
        }

        private void PopulateCourierAddress(int id)
        {
            DistributorClientAddressBO objDistributorAddress = new DistributorClientAddressBO();
            objDistributorAddress.ID = id;
            objDistributorAddress.GetObject();

            string state = (objDistributorAddress.State != null) ? objDistributorAddress.Suburb : string.Empty;

            //lblCourierAddress.Text = objDistributorAddress.CompanyName + " " + objDistributorAddress.Address + " " + objDistributorAddress.Suburb + " " + state + " " + objDistributorAddress.objCountry.ShortName + " " + objDistributorAddress.PostCode;

            //txtShipCompany.Text = objDistributorAddress.CompanyName;
            //txtShipAddress.Text = objDistributorAddress.Address;
            //txtShipSuburb.Text = objDistributorAddress.Suburb;
            //txtShipPostCode.Text = objDistributorAddress.PostCode;
            //txtShipState.Text = state;
            //txtShipCountry.Text = objDistributorAddress.objCountry.ShortName;
            //txtShipContact.Text = objDistributorAddress.ContactName;
            //txtShipPhone.Text = objDistributorAddress.ContactPhone;

            //lnbCourierAddress.Visible = true;

            //lblCourierAddress.Visible = true;
            //lblShiptoAddress.Visible = true;

            //collapse2.Attributes.Add("class", "accordion-body collapse in");
        }

        private void PopulateReservationsDetails(int reservationID)
        {
            if (reservationID > 0)
            {
                ReservationBO objReservation = new ReservationBO();
                objReservation.ID = reservationID;
                objReservation.GetObject();

                litReservationDetail.Text = "RES - " + objReservation.ReservationNo.ToString("0000") + "    " + objReservation.objDistributor.Name;
            }
            else
            {
                litReservationDetail.Text = string.Empty;
            }

            litReservationDetail.Visible = (reservationID > 0) ? true : false;
            collapse4.Attributes.Add("class", "accordion-body collapse in");
        }

        private void SetOrderStatus(int orderdetail)
        {
            int notcompleted = 0;
            int complete = 0;
            int odStatus = 0;
            int cancelled = 0;

            OrderDetailBO objOD = new OrderDetailBO();
            objOD.ID = orderdetail;
            objOD.GetObject();

            if (objOD.Order > 0)
            {
                OrderDetailBO objOrderDetails = new OrderDetailBO();
                objOrderDetails.Order = objOD.Order;
                List<OrderDetailBO> lstOrderDetails = objOrderDetails.SearchObjects();

                if (objOD.Status == 14)
                {
                    odStatus = 27;
                }
                else
                {
                    foreach (OrderDetailBO orderDetail in lstOrderDetails)
                    {
                        if ((orderDetail.Status != null && orderDetail.Status > 0) && (orderDetail.objStatus.Priority == 14 ||
                             orderDetail.objStatus.Priority == 16 || orderDetail.objStatus.Priority == 1 || orderDetail.objStatus.Priority == 17 ||
                             orderDetail.objStatus.Priority == 18))
                        {
                            notcompleted++;
                        }
                        if ((orderDetail.Status != null && orderDetail.Status > 0) && orderDetail.objStatus.Priority == 16)
                        {
                            complete++;
                        }
                        if ((orderDetail.Status != null && orderDetail.Status > 0) && orderDetail.objStatus.Priority == 15)
                        {
                            cancelled++;
                        }
                    }

                    if (lstOrderDetails.Count == complete)
                    {
                        odStatus = 21;
                    }
                    else if ((complete > 0 && notcompleted > 0 && cancelled == 0) || (complete > 0 && notcompleted == 0 && cancelled == 0))
                    {
                        odStatus = 20;
                    }
                    else if (notcompleted > 0 && complete == 0)
                    {
                        odStatus = 19;
                    }
                    else if (cancelled != lstOrderDetails.Count && cancelled != lstOrderDetails.Count)
                    {
                        odStatus = 19;
                    }
                    else if (lstOrderDetails.Count == cancelled)
                    {
                        odStatus = 28;
                    }
                }

                if (objOD.Order > 0 && odStatus > 0)
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        OrderBO objOrder = new OrderBO(ObjContext);
                        objOrder.ID = objOD.Order;
                        objOrder.GetObject();

                        objOrder.Status = odStatus;

                        ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
            }
        }

        private List<SizeDetails> PopulateSizeDetails(List<SizeBO> lstSize = null, int Size = 0, List<OrderDetailQtyBO> lstOrderDetailQty = null, bool isAdd = true)
        {
            List<SizeDetails> lst = new List<SizeDetails>();

            if (isAdd == true)
            {
                if (rptSizeQty.Items.Count > 0)
                {
                    foreach (RepeaterItem item in rptSizeQty.Items)
                    {
                        HiddenField hdnQtyID = (HiddenField)item.FindControl("hdnQtyID");

                        Literal litHeading = (Literal)item.FindControl("litHeading");

                        TextBox txtQty = (TextBox)item.FindControl("txtQty");

                        lst.Add(new SizeDetails()
                        {
                            OrderDetailsQty = int.Parse(hdnQtyID.Value),
                            SizeName = litHeading.Text,
                            Size = int.Parse(((System.Web.UI.WebControls.WebControl)(txtQty)).Attributes["Size"].ToString()),
                            Value = int.Parse(txtQty.Text)
                        });
                    }
                }
            }

            if (lstSize != null && lstSize.Count > 0)
            {
                foreach (SizeBO sizeset in lstSize)
                {
                    lst.Add(new SizeDetails()
                    {
                        OrderDetailsQty = 0,
                        SizeName = sizeset.SizeName,
                        Size = sizeset.ID,
                        Value = 0
                    });
                }
            }

            if (lstOrderDetailQty != null && lstOrderDetailQty.Count > 0)
            {
                foreach (OrderDetailQtyBO odq in lstOrderDetailQty)
                {
                    lst.Add(new SizeDetails()
                    {
                        OrderDetailsQty = odq.ID,
                        SizeName = odq.objSize.SizeName,
                        Size = odq.Size,
                        Value = odq.Qty

                    });
                }
            }

            if (Size > 0 && lst.Where(m => m.Size == Size).Count() == 0)
            {
                SizeBO objSize = new SizeBO();
                objSize.ID = Size;
                objSize.GetObject();

                lst.Add(new SizeDetails()
                {
                    OrderDetailsQty = 0,
                    SizeName = objSize.SizeName,
                    Size = Size,
                    Value = 0
                });
            }

            return lst;
        }

        private void CreateOrder()
        {
            PopulateOrders objPopulateOrders = new PopulateOrders();

            //Order
            objPopulateOrders.OrderNumber = txtRefference.Text;
            objPopulateOrders.Date = Convert.ToDateTime(txtDate.Text);
            objPopulateOrders.DesiredDate = Convert.ToDateTime(txtDesiredDate.Text);
            if (!string.IsNullOrEmpty(txtShipmentDate.Text))
                objPopulateOrders.ShipmentDate = Convert.ToDateTime(txtShipmentDate.Text);

            objPopulateOrders.Distributor = int.Parse(ddlDistributor.SelectedValue);

            if (objPopulateOrders.Distributor > 0)
            {
                objPopulateOrders.MYOBCardFile = int.Parse(ddlMYOBCardFile.SelectedValue);
                objPopulateOrders.Client = (ddlClient.SelectedIndex > 0) ? int.Parse(ddlClient.SelectedValue) : 0;
                objPopulateOrders.JobName = (ddlJobName.SelectedIndex > 0) ? int.Parse(ddlJobName.SelectedValue) : 0;
            }
            objPopulateOrders.AccessPONo = txtOldPoNo.Text;
            objPopulateOrders.DistributorPONo = txtPoNo.Text;
            objPopulateOrders.PaymentMethod = int.Parse(ddlPaymentMethod.SelectedValue);
            objPopulateOrders.isPhotoApprovalRequired = chkPhotoApprovalRequired.Checked;
            objPopulateOrders.IsBrandingKit = chkBrandingKit.Checked;
            objPopulateOrders.IsLockerPatch = chkLockerPatch.Checked;
            objPopulateOrders.OrderStatus = int.Parse(ddlStatus.SelectedValue);
            objPopulateOrders.ShipmentMode = int.Parse(ddlShipmentMode.SelectedValue);
            objPopulateOrders.DeliveryOption = (rdoRoadFreight.Checked) ? 1 : (rdoAirbag.Checked) ? 2 : (rdoPickup.Checked) ? 3 : 0;
            objPopulateOrders.OrderType = int.Parse(ddlOrderType.SelectedValue);
            objPopulateOrders.Label = int.Parse(ddlLabel.SelectedValue);
            objPopulateOrders.VisualLayout = (ddlVlNumber.SelectedValue != "" && int.Parse(ddlVlNumber.SelectedValue) > 0) ? int.Parse(ddlVlNumber.SelectedValue) : 0;
            //objPopulateOrders.ArtWork = int.Parse(ddlArtWork.SelectedValue);
            objPopulateOrders.IsRepeat = (txtIsNew.Text == "New") ? false : true;
            objPopulateOrders.Reservations = (RadComboReservations.SelectedValue != "" && int.Parse(RadComboReservations.SelectedValue) > 0) ? int.Parse(RadComboReservations.SelectedValue) : 0;
            objPopulateOrders.OrderNotes = txtNotes.Text;
            objPopulateOrders.PromoCode = txtPromoCode.Text;

            //Delivery Details
            objPopulateOrders.IsWeeklyShipment = rbWeeklyShipment.Checked;
            objPopulateOrders.BillingAddress = (ddlBillingAddress.SelectedValue != "" && int.Parse(ddlBillingAddress.SelectedValue) > 0) ? int.Parse(ddlBillingAddress.SelectedValue) : 0;
            objPopulateOrders.DespatchAddress = (ddlDespatchAddress.SelectedValue != "" && int.Parse(ddlDespatchAddress.SelectedValue) > 0) ? int.Parse(ddlDespatchAddress.SelectedValue) : 0;
            objPopulateOrders.CourierAddress = (ddlCourierAddress.SelectedValue != "" && int.Parse(ddlCourierAddress.SelectedValue) > 0) ? int.Parse(ddlCourierAddress.SelectedValue) : 0;
            objPopulateOrders.IsCourier = rbCourier.Checked;

            Session["PopulateOrders"] = objPopulateOrders;
        }

        private void populateOrder()
        {
            PopulateOrders objPopulateOrders = (PopulateOrders)Session["PopulateOrders"];

            ResetDropdowns();
            //populate Distributor Delivery Address
            lblDistributorAddress.Visible = true;

            txtDate.Text = objPopulateOrders.Date.ToString("dd MMMM yyyy");
            txtDesiredDate.Text = objPopulateOrders.DesiredDate.ToString("dd MMMM yyyy");

            txtPromoCode.Text = objPopulateOrders.PromoCode;
            txtShipmentDate.Text = objPopulateOrders.ShipmentDate.HasValue ? objPopulateOrders.ShipmentDate.Value.ToString("dd MMMM yyyy") : String.Empty;
            txtRefference.Text = objPopulateOrders.OrderNumber;
            txtNotes.Text = objPopulateOrders.OrderNotes;

            rdoRoadFreight.Checked = (objPopulateOrders.DeliveryOption == 1);
            rdoAirbag.Checked = (objPopulateOrders.DeliveryOption == 2);
            rdoPickup.Checked = (objPopulateOrders.DeliveryOption == 3);

            //TODO NNM
            rbWeeklyShipment.Checked = objPopulateOrders.IsWeeklyShipment;
            rbCourier.Checked = objPopulateOrders.IsCourier;

            txtPoNo.Text = objPopulateOrders.DistributorPONo;
            txtOldPoNo.Text = objPopulateOrders.AccessPONo;
            chkPhotoApprovalRequired.Checked = objPopulateOrders.isPhotoApprovalRequired;
            chkBrandingKit.Checked = objPopulateOrders.IsBrandingKit;
            chkLockerPatch.Checked = objPopulateOrders.IsLockerPatch;

            ddlDistributor.ClearSelection();
            ddlDistributor.Items.FindByValue((DistributorID > 0) ? DistributorID.ToString() : objPopulateOrders.Distributor.ToString()).Selected = true;

            if (objPopulateOrders.Distributor > 0)
            {
                ddlMYOBCardFile.Items.FindByValue(objPopulateOrders.MYOBCardFile.ToString()).Selected = true;
            }

            PopulateDistributorClients((DistributorID > 0) ? DistributorID : objPopulateOrders.Distributor);

            objPopulateOrders.BillingAddress = (this.billingAddress > 0) ? this.billingAddress : objPopulateOrders.BillingAddress;
            objPopulateOrders.DespatchAddress = (this.despatchAddress > 0) ? this.despatchAddress : objPopulateOrders.DespatchAddress;
            objPopulateOrders.CourierAddress = (this.courierAddress > 0) ? this.courierAddress : objPopulateOrders.CourierAddress;

            PopulateClientAddresses((DistributorID > 0) ? DistributorID : objPopulateOrders.Distributor,
                objPopulateOrders.BillingAddress,
                 objPopulateOrders.DespatchAddress,
                 objPopulateOrders.CourierAddress);

            if (newClient > 0 || objPopulateOrders.Client > 0)
            {
                int client = (newClient > 0) ? newClient : objPopulateOrders.Client;
                populateJobNameDetails(objPopulateOrders.JobName);
                PopulateVisualLayouts(objPopulateOrders.JobName);
                PopulateReservations(VisualLayoutID, ArtWorkID);

                ddlClient.ClearSelection();
                ddlClient.Items.FindByValue(client.ToString()).Selected = true;

                if (objPopulateOrders.JobName > 0)
                {
                    ddlJobName.ClearSelection();
                    ddlJobName.Items.FindByValue(objPopulateOrders.JobName.ToString()).Selected = true;
                }

                if (objPopulateOrders.VisualLayout > 0)
                {
                    ddlVlNumber.Items.FindByValue(objPopulateOrders.VisualLayout.ToString()).Selected = true;
                    ddlVlNumber_SelectedIndexChange(null, null);
                }
            }

            ddlOrderType.ClearSelection();
            ddlLabel.ClearSelection();
            ddlPaymentMethod.ClearSelection();
            ddlShipmentMode.ClearSelection();

            ddlOrderType.Items.FindByValue(objPopulateOrders.OrderType.ToString()).Selected = true;
            ddlLabel.Items.FindByValue(objPopulateOrders.Label.ToString()).Selected = true;
            ddlPaymentMethod.Items.FindByValue(objPopulateOrders.PaymentMethod.ToString()).Selected = true;
            ddlShipmentMode.Items.FindByValue(objPopulateOrders.ShipmentMode.ToString()).Selected = true;
            txtIsNew.Text = (objPopulateOrders.IsRepeat == true) ? "Repeat" : "New";

            Session["PopulateOrders"] = null;
        }

        //private void PopulatePrice(int pattern, int fabricCode, int Qty, decimal editedPrice = 0)
        //{
        //    decimal indimanPrice = IndicoPage.CalculateIndimanPricePerVL(pattern, fabricCode, Qty);
        //    decimal percentage = decimal.Parse("0.58");
        //    decimal distrbutorEditedPrice = editedPrice; // (editedPrice > 0) ? editedPrice : (indimanPrice / percentage);

        //    txtPrice.Text = indimanPrice.ToString("0.00");
        //    txtDistributorPrice.Text = distrbutorEditedPrice.ToString("0.00");
        //    txtPercentage.Text = (distrbutorEditedPrice > 0) ? (100 * (1 - (indimanPrice / distrbutorEditedPrice))).ToString("0.00") : "0.00";

        //    /*VisualLayoutBO objVisualLayout = new VisualLayoutBO();
        //    objVisualLayout.ID = vl;
        //    objVisualLayout.GetObject();

        //    PriceBO objPrice = new PriceBO();
        //    objPrice.Pattern = objVisualLayout.Pattern;
        //    objPrice.FabricCode = objVisualLayout.FabricCode;

        //    int price = objPrice.SearchObjects().Select(o => o.ID).SingleOrDefault();

        //    PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO();
        //    objPriceLevelCost.Price = price;
        //    objPriceLevelCost = objPriceLevelCost.SearchObjects()[0];

        //    txtPrice.Text = objPriceLevelCost.IndimanCost.ToString("0.00");

        //    //decimal plIndimanCost = objPriceLevelCost.SearchObjects()[0].IndimanCost;
        //    //DistributorPriceMarkupBO objDPPM = new DistributorPriceMarkupBO();
        //    //objDPPM.PriceLevel = objPriceLevelCost.ID;
        //    //decimal dpMarkup = objDPPM.SearchObjects().Where(m => m.Distributor == null || m.Distributor == 0).ToList()[0].Markup;
        //    //decimal value = (plIndimanCost * 100) / (100 - dpMarkup);

        //    DistributorPriceLevelCostBO objDPLC = new DistributorPriceLevelCostBO();
        //    objDPLC.PriceTerm = 1;
        //    objDPLC.PriceLevelCost = objPriceLevelCost.ID;

        //    List<DistributorPriceLevelCostBO> lstLevelCosts = objDPLC.SearchObjects().Where(m => m.Distributor == null || m.Distributor == 0).ToList();

        //    if (lstLevelCosts.Any())
        //    {
        //        txtPrice.Text = lstLevelCosts[0].IndicoCost.ToString("0.00");
        //    }*/
        //}

        private void PopulatePrice(int pattern, int fabricCode, int qty, decimal surcharge, decimal distrbutorEditedPrice = 0)
        {
            decimal indimanPrice = IndicoPage.GetCostSheetPricePerVL(pattern, fabricCode); // IndicoPage.CalculateIndimanPricePerVL(pattern, fabricCode, Qty);
            decimal percentage = decimal.Parse("0.58");
            //decimal distrbutorEditedPrice = editedPrice; // (editedPrice > 0) ? editedPrice : (indimanPrice / percentage);

            this.txtPrice.Text = indimanPrice.ToString("0.00");
            this.txtDistributorPrice.Text = distrbutorEditedPrice.ToString("0.00");
            this.txtPercentage.Text = (distrbutorEditedPrice > 0) ? (100 * (1 - (indimanPrice / distrbutorEditedPrice))).ToString("0.00") : "0.00";

            // Calcuate the surcharge values
            this.txtSurcharge.Text = surcharge.ToString();
            this.txtPriceWithSurcharge.Text = (distrbutorEditedPrice * (1 + (surcharge / 100))).ToString("0.00");
            this.txtMarginWithSurcharge.Text = (decimal.Parse(this.txtPriceWithSurcharge.Text) > 0) ? (100 * (1 - (indimanPrice / decimal.Parse(this.txtPriceWithSurcharge.Text)))).ToString("0.00") : "0.00";
            this.txtTotalValueSurcharge.Text = ((decimal)(distrbutorEditedPrice * (1 + (decimal)surcharge / 100) * qty)).ToString("0.00");
        }

        private void PopulateBillingDetails(List<OrderDetailBO> lstOD)
        {
            decimal zeroPrice = 0;
            decimal totalPRice = 0;
            decimal deliveryCharges = 0;
            decimal artWorkCharges = 0;
            decimal OtherCharges = 0;

            foreach (OrderDetailBO objOD in lstOD)
            {
                int qty = objOD.OrderDetailQtysWhereThisIsOrderDetail.ToList().Sum(m => m.Qty);
                totalPRice += (decimal.Parse((objOD.EditedPrice ?? 0).ToString()) * ((decimal)(1 + (decimal)objOD.Surcharge / (decimal)100.00))) * qty;
            }

            txtTotalValue.Text = totalPRice.ToString("0.00");

            if (lstOD.Any())
            {
                OrderBO objOrder = lstOD.First().objOrder;
                deliveryCharges = ((objOrder.DeliveryCharges ?? 0) == 0) ? zeroPrice : objOrder.DeliveryCharges.Value;
                artWorkCharges = ((objOrder.ArtWorkCharges ?? 0) == 0) ? zeroPrice : objOrder.ArtWorkCharges.Value;
                OtherCharges = ((objOrder.OtherCharges ?? 0) == 0) ? zeroPrice : objOrder.OtherCharges.Value;
                totalPRice += (deliveryCharges + artWorkCharges + OtherCharges);
                //Direct Sales Billing Data

                txtDeliveryCharges.Text = deliveryCharges.ToString("0.00");
                txtArtworkCharges.Text = artWorkCharges.ToString("0.00");
                txtOtherCharges.Text = OtherCharges.ToString("0.00");
                txtOtherChargesDescription.Text = objOrder.OtherChargesDescription;
            }

            txtGST.Text = "10.00";
            txtGrandTotal.Text = (totalPRice + (totalPRice / 10)).ToString("0.00");
        }

        private void PopulateOrderItemDetails(int patternID, int fabricID)
        {
            ddlSizes.Visible = true;
            ddlSizes.Items.Clear();
            ddlSizes.Items.Add(new ListItem("Select a Size", "0"));

            if ((patternID * fabricID) > 0)
            {
                PatternBO objPattern = new PatternBO();
                objPattern.ID = patternID;
                objPattern.GetObject();

                List<SizeBO> lstVLSizes = objPattern.objSizeSet.SizesWhereThisIsSizeSet;

                List<SizeBO> lstSizes = lstVLSizes.Where(o => o.IsDefault == false).ToList();
                foreach (SizeBO size in lstSizes)
                {
                    ddlSizes.Items.Add(new ListItem(size.SizeName, size.ID.ToString()));
                }

                txtUnit.Text = (objPattern.Unit != null && objPattern.Unit > 0) ? objPattern.objUnit.Name : string.Empty;

                List<OrderDetailQtyBO> lstOrderDetailQty = new List<OrderDetailQtyBO>();
                rptSizeQty.DataSource = PopulateSizeDetails(lstVLSizes.Where(o => o.IsDefault == true).OrderBy(o => o.SeqNo).ToList(), 0, lstOrderDetailQty, false);
                rptSizeQty.DataBind();
                rptSizeQty.Visible = true;

                // SDS

                decimal surCharge = decimal.Parse("0.00");
                int qty = 0;

                if (lstOrderDetailQty.Any())
                {
                    OrderDetailBO objOrderDetail = new OrderDetailBO();
                    objOrderDetail.ID = lstOrderDetailQty[0].OrderDetail;
                    objOrderDetail.GetObject();

                    surCharge = objOrderDetail.Surcharge;
                    qty = lstOrderDetailQty.Sum(v => v.Qty);
                }

                this.PopulatePrice(patternID, fabricID, qty, surCharge, 0);

                FabricCodeBO objFabCode = new FabricCodeBO();
                objFabCode.ID = fabricID;
                objFabCode.GetObject();

                litFabric.Text = objFabCode.NickName + " (" + objFabCode.Code + ")";
                litPattern.Text = objPattern.Number + " - " + objPattern.NickName;

                dvPatternLit.Visible = dvFabricLit.Visible = dvPocketLit.Visible = true;
            }
            else
            {
                dvPatternLit.Visible = dvFabricLit.Visible = dvPocketLit.Visible = false;
                rptSizeQty.DataSource = null;
                rptSizeQty.DataBind();

                litFabric.Text = string.Empty;
                litPattern.Text = string.Empty;
                txtUnit.Text = string.Empty;
                txtPrice.Text = string.Empty;
            }

            ViewState["populateVlNotes"] = true;
        }

        private void PopulateEditAddressDetails(int address, string addressType)
        {
            ResetViewStateValues();

            try
            {
                DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO();
                objDistributorClientAddress.ID = address;
                objDistributorClientAddress.GetObject();

                txtCOmpanyName.Text = objDistributorClientAddress.CompanyName;
                txtShipToAddress.Text = objDistributorClientAddress.Address;
                txtSuburbCity.Text = objDistributorClientAddress.Suburb;
                txtShipToState.Text = objDistributorClientAddress.State;
                txtShipToPostCode.Text = objDistributorClientAddress.PostCode;
                txtShipToPhone.Text = objDistributorClientAddress.ContactPhone;
                txtShipToEmail.Text = objDistributorClientAddress.EmailAddress;
                txtShipToContactName.Text = objDistributorClientAddress.ContactName;

                ddlShipToCountry.ClearSelection();
                ddlAdderssType.ClearSelection();
                ddlShipToPort.ClearSelection();
                ddlDistributor.ClearSelection();

                ddlShipToCountry.Items.FindByValue(objDistributorClientAddress.Country.ToString()).Selected = true;
                ddlAdderssType.Items.FindByValue(objDistributorClientAddress.AddressType.ToString()).Selected = true;
                ddlShipToPort.Items.FindByValue(objDistributorClientAddress.Port.ToString()).Selected = true;
                ddlDistributor.Items.FindByValue(objDistributorClientAddress.Distributor.ToString()).Selected = true;

                hdnAddressID.Value = address.ToString();
                hdnEditType.Value = addressType;

                ViewState["PopulateShippingAddress"] = true;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Editing Distributor Client Address on AddEditOrder.aspx", ex);
            }
        }

        private List<OrderDetail> PopulateTempOrderDetails(List<ReturnOrderDetailsIndicoPriceViewBO> lstOrderDetails)
        {
            List<OrderDetail> lstTempOrderDetails = new List<OrderDetail>();

            int index = 0;
            string NNFileTempDirectory = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Temp\\" + lstOrderDetails.First().Order.ToString();
            if (!Directory.Exists(NNFileTempDirectory))
                Directory.CreateDirectory(NNFileTempDirectory);
            IndicoPage.EmptyDirectory(new DirectoryInfo(NNFileTempDirectory));

            foreach (ReturnOrderDetailsIndicoPriceViewBO objOD in lstOrderDetails)
            {
                OrderDetail objOrderDetailtemp = new OrderDetail();

                OrderDetailBO objOrderDetail = new OrderDetailBO();
                objOrderDetail.ID = objOD.OrderDetail ?? 0;
                objOrderDetail.GetObject();

                objOrderDetailtemp.Index = index++;
                objOrderDetailtemp.ID = objOD.OrderDetail ?? 0;
                objOrderDetailtemp.OrderType = objOrderDetail.OrderType;
                objOrderDetailtemp.Label = objOD.Label ?? 0;

                objOrderDetailtemp.UseBrandingkit = objOrderDetail.IsBrandingKit;
                objOrderDetailtemp.UseLockerPatch = objOrderDetail.IsLockerPatch;
                objOrderDetailtemp.IsPhotoApprovalRequired = objOrderDetail.PhotoApprovalReq ?? false;

                objOrderDetailtemp.OrderTypeName = objOD.OrderType;
                objOrderDetailtemp.VisualLayout = objOD.VisualLayoutID ?? 0;
                objOrderDetailtemp.Pattern = objOD.PatternID ?? 0;
                objOrderDetailtemp.Fabric = objOD.FabricID ?? 0;
                objOrderDetailtemp.VisualLayoutName = objOD.VisualLayout;
                objOrderDetailtemp.PatternName = objOD.Pattern;
                objOrderDetailtemp.FabricName = objOD.Fabric;
                objOrderDetailtemp.OrderDetailNotes = objOD.VisualLayoutNotes;
                objOrderDetailtemp.EditedPrice = objOD.EditedPrice.Value.ToString("0.00");
                objOrderDetailtemp.StatusID = objOD.StatusID ?? 0;
                objOrderDetailtemp.Status = objOD.Status;
                objOrderDetailtemp.Order = objOD.Order ?? 0;
                objOrderDetailtemp.SurCharge = objOD.Surcharge.Value.ToString("0.00");
                objOrderDetailtemp.EditedPrice = objOD.EditedPrice.Value.ToString("0.00");

                OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                objOrderDetailQty.OrderDetail = objOD.OrderDetail ?? 0;
                objOrderDetailtemp.ListQtys = objOrderDetailQty.SearchObjects();

                //NN File Processing
                try
                {
                    if (!string.IsNullOrEmpty(objOrderDetail.NameAndNumbersFilePath))
                    {
                        string NNFilePath = GetNameNumberFilePath(objOrderDetail.ID);
                        string NNTempPath = NNFileTempDirectory + "\\" + objOD.OrderDetail.ToString();
                        Directory.CreateDirectory(NNTempPath);

                        objOrderDetailtemp.NameAndNumbersFileName = objOrderDetail.NameAndNumbersFilePath;
                        objOrderDetailtemp.NameAndNumbersFilePath = NNTempPath + "\\" + objOrderDetail.NameAndNumbersFilePath;
                        File.Copy(NNFilePath, objOrderDetailtemp.NameAndNumbersFilePath);

                        objOrderDetailtemp.IsNamesAndNumbers = true;
                    }
                }
                catch (Exception ex)
                {

                }

                lstTempOrderDetails.Add(objOrderDetailtemp);
            }

            return lstTempOrderDetails;
        }

        private void ResetViewStateValues()
        {
            ViewState["PopulateShippingAddress"] = false;
            ViewState["PopulateDeleteOrdersMsg"] = false;
            ViewState["PopulatePaymentMethod"] = false;
            ViewState["PopulateShippingAddress"] = false;
            ViewState["PopulateClient"] = false;
            ViewState["PopulateJobName"] = false;
            ViewState["PopulateScrolling"] = false;
            ViewState["PopulateOrderDetail"] = false;
        }

        private void ResetOrderDetailForm()
        {
            try
            {
                odTitle.InnerText = "New Order Detail";

                chkPhotoApprovalRequired.Checked = false;
                chkBrandingKit.Checked = false;
                chkLockerPatch.Checked = false;

                ddlOrderType.ClearSelection();
                ddlLabel.ClearSelection();
                ddlVlNumber.ClearSelection();
                ddlPattern.ClearSelection();
                ddlFabric.ClearSelection();
                ddlSizes.ClearSelection();
                ddlSizes.Visible = false;
                dvFromVL.Attributes.Add("style", "display:block");
                ddlVlNumber.Enabled = true;
                ddlPattern.Enabled = true;
                ddlFabric.Enabled = true;
                linkDelete.Visible = false;

                txtPriceComments.Text = string.Empty;
                txtOdNotes.Text = string.Empty;
                txtFactoryDescription.Text = string.Empty;

                txtDistributorPrice.Text = string.Empty;
                txtPercentage.Text = string.Empty;
                txtSurcharge.Text = string.Empty;
                txtPriceWithSurcharge.Text = string.Empty;
                txtMarginWithSurcharge.Text = string.Empty;
                txtTotalValueSurcharge.Text = string.Empty;

                rptSizeQty.DataSource = null;
                rptSizeQty.DataBind();

                txtTotalQty.Text = "0";
                txtUnit.Text = string.Empty;
                txtPrice.Text = string.Empty;
                txtPromoCode.Text = string.Empty;

                btnAddOrder.InnerHtml = "Add Order Detail";
                btnAddOrder.Attributes.Add("data-loading-text", "Saving...");
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while new orderdetail from AddEditOrder.aspx", ex);
            }
        }

        #endregion

        #region Internal Class

        internal class SizeDetails
        {
            public int OrderDetailsQty { get; set; }
            public string SizeName { get; set; }
            public int Size { get; set; }
            public int Value { get; set; }
        }

        internal class OrderDetail
        {
            public int Index { get; set; }
            public int ID { get; set; }

            public bool IsPhotoApprovalRequired { get; set; }
            public bool UseBrandingkit { get; set; }
            public bool UseLockerPatch { get; set; }
            public bool FromVisualLayout { get; set; }

            public int OrderType { get; set; }
            public int Label { get; set; }

            public DateTime RequestedDate { get; set; }
            public DateTime SheduledDate { get; set; }
            public DateTime ShipmentDate { get; set; }

            public int VisualLayout { get; set; }
            public int Pattern { get; set; }
            public int Fabric { get; set; }

            public string OrderTypeName { get; set; }
            public string VisualLayoutName { get; set; }
            public string PatternName { get; set; }
            public string FabricName { get; set; }

            public List<OrderDetailQtyBO> ListQtys { get; set; }

            public string PromoCode { get; set; }

            public string EditedPrice { get; set; }
            //public string NormalMargin { get; set; }
            public string SurCharge { get; set; }

            public string PriceComments { get; set; }
            public string OrderDetailNotes { get; set; }
            public string FactoryInstructions { get; set; }

            public bool IsNamesAndNumbers { get; set; }
            public string NameAndNumbersFileName { get; set; }
            public string NameAndNumbersFilePath { get; set; }

            public int PaymentMethod { get; set; }
            public int ShipmentMode { get; set; }
            public bool IsCourierDelivery { get; set; }
            public bool IsWeeklyShipment { get; set; }

            public int Reservation { get; set; }
            public bool IsRepeat { get; set; }

            public int StatusID { get; set; }
            public string Status { get; set; }
            public int Order { get; set; }

            internal OrderDetail()
            {
                this.ListQtys = new List<OrderDetailQtyBO>();
            }
        }

        #endregion
    }
}