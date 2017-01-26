using Dapper;
using Indico.BusinessObjects;
using Indico.Common;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using Telerik.Web.UI;

namespace Indico
{
    public partial class AddEditOrder : IndicoPage
    {
        #region enums

        #endregion

        #region Fields

        private int urlQueryID = -1;
        //private int urlVisualLayoutID = -1;
        //private int urlArtWorkID = -1;
        private int urlQueryReservationID = -1;
        private int orderID = -1;
        private int distributorid = -1;
        private string namenumberFilePath = string.Empty;
        private List<OrderDetail> listOrderDetails;
        private List<int> listDeletedODIDs = new List<int>();

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
                //} CloneOrder.aspx?id=1025

                return urlQueryID;
            }
        }

        //protected int VisualLayoutID
        //{
        //    get
        //    {
        //        return urlVisualLayoutID;
        //    }
        //}

        //protected int ArtWorkID
        //{
        //    get
        //    {
        //        return urlArtWorkID;
        //    }
        //}

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

        private List<int> ListDeletedODIDs
        {
            get
            {
                listDeletedODIDs = new List<int>();

                if (Session["ListDeletedODIDs"] != null)
                {
                    listDeletedODIDs = (List<int>)(Session["ListDeletedODIDs"]);
                }

                return listDeletedODIDs;
            }
            set
            {
                Session["ListDeletedODIDs"] = value;
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
            var pattern = new PatternBO { ID = 315 };
            pattern.GetObject();
            if (!IsPostBack)
            {
                PopulateControls(true);
            }
            else
            {
                ViewState["PopulateDropDown"] = false;
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
                OrderDetail objOrderDetail = (OrderDetail)item.DataItem;

                Literal lblOrderType = (Literal)item.FindControl("lblOrderType");
                lblOrderType.Text = objOrderDetail.OrderTypeName;

                Literal lblIndex = (Literal)item.FindControl("lblIndex");
                string index = ((objOrderDetail.Index + 1) < 10) ? ("0" + (objOrderDetail.Index + 1)) : (objOrderDetail.Index + 1).ToString();
                lblIndex.Text = index; // (objOrderDetail.Index + 1).ToString();

                Literal lblRepeat = (Literal)item.FindControl("lblRepeat");
                lblRepeat.Text = objOrderDetail.IsRepeat ? "Repeat" : string.Empty;

                Literal litEmbroidery = (Literal)item.FindControl("litEmbroidery");
                litEmbroidery.Text = objOrderDetail.IsEmbroidery ? "Yes" : "No";

                Literal litColorProfile = (Literal)item.FindControl("litColorProfile");
                litColorProfile.Text = objOrderDetail.ResolutionProfile;

                HyperLink hlVlNumber = (HyperLink)item.FindControl("hlVlNumber");
                hlVlNumber.Text = string.IsNullOrEmpty(objOrderDetail.VisualLayoutName) ? string.Empty : objOrderDetail.VisualLayoutName;
                hlVlNumber.NavigateUrl = "AddEditVisualLayout.aspx?id=" + objOrderDetail.VisualLayout;

                Literal lblVLNumber = (Literal)item.FindControl("lblVLNumber");
                lblVLNumber.Text = " / " + objOrderDetail.PatternName + " / " + objOrderDetail.FabricName;

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

                Repeater rptSizeQtyView = (Repeater)item.FindControl("rptSizeQtyView");
                rptSizeQtyView.DataSource = objOrderDetail.ListQtys.Where(m => m.Qty > 0);
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

                HtmlGenericControl ilabelimageView = (HtmlGenericControl)item.FindControl("ilabelimageView");

                HtmlAnchor linkEdit = (HtmlAnchor)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objOrderDetail.ID.ToString());
                linkEdit.Attributes.Add("index", objOrderDetail.Index.ToString());

                Literal litPocket = (Literal)item.FindControl("litPocket");
                litPocket.Text = objOrderDetail.PocketType;

                Literal lblQty = (Literal)item.FindControl("lblQty");
                lblQty.Text = objOrderDetail.ListQtys.Sum(m => m.Qty).ToString();

                Literal lblSurcharge = (Literal)item.FindControl("lblSurcharge");
                lblSurcharge.Text = objOrderDetail.DistributorSurcharge + "%";

                // decimal.TryParse(objOrderDetail.DistributorEditedPrice, out price);
                //lblTotal.Text = (objOrderDetail.EditedPrice != (decimal)0.00) ? Convert.ToDecimal((Convert.ToDecimal(objOrderDetail.EditedPrice * (1 + (decimal)(objOD.Surcharge / (decimal)100))) * objOrderDetail.Quantity).ToString()).ToString("0.00") : "0.00";
                //decimal surcharge = string.IsNullOrEmpty(objOrderDetail.IndimanSurCharge) ? 0 : decimal.Parse(objOrderDetail.IndimanSurCharge);
                //lblTotal.Text = (price != (decimal)0.00) ? Convert.ToDecimal((Convert.ToDecimal(price * (1 + (decimal)(surcharge / (decimal)100))) * objOrderDetail.ListQtys.Sum(m => m.Qty)).ToString()).ToString("0.00") : "0.00";

                Label lblTotal = (Label)item.FindControl("lblTotal");
                decimal price = decimal.Parse(objOrderDetail.DistributorEditedPrice) + (decimal.Parse(objOrderDetail.DistributorEditedPrice) * decimal.Parse(objOrderDetail.DistributorSurcharge) / 100);
                lblTotal.Text = ((price) * objOrderDetail.ListQtys.Sum(m => m.Qty)).ToString("0.00");

                //TextBox txtPercentage = (TextBox)item.FindControl("txtPercentage");
                TextBox txtEditedPrice = (TextBox)item.FindControl("txtEditedPrice");
                txtEditedPrice.Enabled = false;
                txtEditedPrice.Text = "$" + Convert.ToDecimal(objOrderDetail.DistributorEditedPrice.ToString()).ToString("0.00");

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
                                        || ((this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator) && currentStatus == OrderStatus.CoordinatorSubmitted)
                                        || (this.LoggedUserRoleName == UserRole.FactoryAdministrator);
                    //|| ((this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator) && currentStatus == OrderStatus.IndimanSubmitted);
                }

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objOrderDetail.ID.ToString());
                linkDelete.Attributes.Add("index", objOrderDetail.Index.ToString());
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
                if (!string.IsNullOrWhiteSpace(objOrderDetail.OrderDetailNotes) || !string.IsNullOrWhiteSpace(objOrderDetail.PriceComments) || !string.IsNullOrWhiteSpace(objOrderDetail.FactoryInstructions))
                {
                    item.BackColor = Color.LightYellow;
                }
            }
        }

        protected void btnDeleteOrderItem_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            //if (orderDetailId > 0)
            //{
            try
            {
                int orderDetailId = int.Parse(hdnSelectedID.Value);
                List<int> lstIDs = this.ListDeletedODIDs;
                lstIDs.Add(orderDetailId);
                this.ListDeletedODIDs = lstIDs;

                int index = int.Parse(hdnSelectedIndex.Value);
                OrderDetail objTempOD = this.ListOrderDetails.Where(m => m.Index == index).SingleOrDefault();
                hdnSelectedID.Value = objTempOD.Index.ToString();

                this.ListOrderDetails.RemoveAll(m => m.Index == index);

                dgOrderItems.DataSource = this.ListOrderDetails;
                dgOrderItems.DataBind();

                dgOrderItems.Visible = this.ListOrderDetails.Any();
                dvNoOrders.Visible = !this.ListOrderDetails.Any();

                this.lblTotalQty.InnerText = "Total Qty: " + this.ListOrderDetails.Sum(m => m.ListQtys.Sum(n => n.Qty)).ToString();
                this.hdnTotalQuantity.Value = "0";
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while deleting Order Detai in AddEditOrder.aspx page", ex);
            }
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

                PopulateVlImage(VisualLayoutId, 0);

                //populate Reservations
                PopulateReservations(VisualLayoutId, 0);

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

        protected void linkEdit_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            if (IsNotRefreshed)
            {
                try
                {
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

                    odTitle.InnerText = "Edit Order Detail - PO " + objTempOD.Order + " Shipment Date : " + txtShipmentDate.Text;

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
                    ddlLabel.ClearSelection();
                    ddlLabel.Items.FindByValue(objTempOD.Label.ToString()).Selected = true;
                    chkPhotoApprovalRequired.Checked = objTempOD.IsPhotoApprovalRequired;
                    chkBrandingKit.Checked = objTempOD.UseBrandingkit;
                    chkLockerPatch.Checked = objTempOD.UseLockerPatch;

                    txtPromoCode.Text = objTempOD.PromoCode;
                    txtPriceComments.Text = objTempOD.PriceComments;
                    txtFactoryDescription.Text = objTempOD.FactoryInstructions;
                    txtUnit.Text = ((objPattern.Unit ?? 0) > 0) ? objPattern.objUnit.Name : string.Empty;

                    txtIsNew.Text = (objTempOD.IsRepeat == true) ? "Repeat" : "New";
                    txtOdNotes.Text = objTempOD.OrderDetailNotes;

                    if (objTempOD.VisualLayout > 0)
                    {
                        ddlVlNumber.Items.FindByValue(objTempOD.VisualLayout.ToString()).Selected = true;
                        PopulateVlImage(objTempOD.VisualLayout, objTempOD.Label);
                        PopulateOrderItemDetails(objTempOD.Pattern, objTempOD.Fabric);
                        ddlVlNumber.Enabled = false;
                    }

                    rbNaNuYes.Checked = objTempOD.IsNamesAndNumbers;
                    rbNaNuNo.Checked = !rbNaNuYes.Checked;
                    rbNaNuYes_CheckedChanged(null, null);
                    NameNumberFilePath = objTempOD.NameAndNumbersFileName;

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
                    //ddlFabric.Enabled = ddlPattern.Enabled = false;

                    PopulatePrice(objTempOD.Pattern, objTempOD.Fabric, lstODQty.Sum(v => v.Qty), decimal.Parse(objTempOD.IndimanSurCharge), decimal.Parse(objTempOD.DistributorSurcharge), decimal.Parse(objTempOD.DistributorEditedPrice));

                    collapse1.Attributes.Add("class", "accordion-body collapse");
                    collapse2.Attributes.Add("class", "accordion-body collapse in");
                    collapse3.Attributes.Add("class", "accordion-body collapse");

                    bool isNotFactory = !(LoggedUserRoleName == UserRole.FactoryAdministrator || LoggedUserRoleName == UserRole.FactoryCoordinator);
                    hlNewVisualLayout.Visible = isNotFactory;
                    btnRefreshVL.Visible = isNotFactory;
                    ddlSizes.Visible = isNotFactory;

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
                if (Page.IsValid)
                {
                    try
                    {
                        using (var ts = new TransactionScope())
                        {
                            var objDistributorClientAddress = new DistributorClientAddressBO(ObjContext);

                            if (int.Parse(hdnAddressID.Value) > 0)
                            {
                                objDistributorClientAddress.ID = int.Parse(hdnAddressID.Value);
                                objDistributorClientAddress.GetObject();
                            }

                            objDistributorClientAddress.CompanyName = txtCompanyName.Text;
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
                            objDistributorClientAddress.Distributor = int.Parse(ddlDistributor.SelectedValue);

                            ObjContext.SaveChanges();
                            var myobService = new MyobService();
                            myobService.SaveAddress(objDistributorClientAddress.ID);

                            ts.Complete();

                            string addressType = this.hdnEditType.Value;
                            if (addressType == "Billing")
                            {
                                hdnBillingAddressID.Value = objDistributorClientAddress.ID.ToString();
                                hdnDespatchAddressID.Value = objDistributorClientAddress.ID.ToString();
                            }
                            //else if (addressType == "Despatch")
                            //{
                            //    hdnDespatchAddressID.Value = objDistributorClientAddress.ID.ToString();
                            //}
                            //else if (addressType == "Courier")
                            //{
                            //    hdnCourierAddressID.Value = objDistributorClientAddress.ID.ToString();
                            //}
                            else
                            {
                                hdnDespatchAddressID.Value = objDistributorClientAddress.ID.ToString();
                                hdnCourierAddressID.Value = objDistributorClientAddress.ID.ToString();
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
                sizeWarningAlert.Visible = true;
                rptSizeQty.DataSource = PopulateSizeDetails(null, int.Parse(ddlSizes.SelectedValue), null);
                rptSizeQty.DataBind();
            }
            else
            {
                sizeWarningAlert.Visible = false;
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
                    ProcessForm();
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

                if (ddlVlNumber.SelectedIndex < 1)
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "vgOrderDetail";
                    cv.ErrorMessage = "VisualLayout is required";
                    Page.Validators.Add(cv);
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
                        ProcessForm();

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

        protected void btnCancelOrder_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect("/AddEditOrder.aspx?id=" + OrderID);
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
                        ProcessForm();

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
                                var objSetting = new SettingsBO();
                                objSetting.Key = CustomSettings.ISOTO.ToString();
                                objSetting = objSetting.SearchObjects().SingleOrDefault();
                                mailTo = objSetting.Value;

                                objOrder.Status = GetOrderStatus(OrderStatus.IndimanSubmitted).ID;
                                objOrder.Modifier = LoggedUser.ID;
                                objOrder.ModifiedDate = DateTime.Now;
                                objOrder.OrderSubmittedDate = DateTime.Now;

                                SendOrderSubmissionEmail(OrderID, mailTo, "Factory", true, null);
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

        protected void btnEditCourier_Click(object sender, EventArgs e)
        {
            PopulateEditAddressDetails(int.Parse(ddlCourierAddress.SelectedValue), "Courier");
        }

        protected void btnEditBilling_Click(object sender, EventArgs e)
        {
            PopulateEditAddressDetails(int.Parse(hdnBillingAddressID.Value), "Billing");
        }

        protected void btnEditDespatch_Click(object sender, EventArgs e)
        {
            PopulateEditAddressDetails(int.Parse(hdnDespatchAddressID.Value), "Despatch");
        }

        protected void btnEditClient_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            try
            {
                ClientBO objClient = new ClientBO();
                objClient.ID = int.Parse(hdnClientID.Value);
                objClient.GetObject();

                lblClientDistributor.Text = objClient.objDistributor.Name;
                txtClientName.Text = objClient.Name;
                hdnEditClientID.Value = objClient.ID.ToString();

                ViewState["PopulateClient"] = true;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Editing Client on AddEditOrder.aspx", ex);
            }
        }

        protected void btnSaveClient_ServerClick(object sender, EventArgs e)
        {
            ResetViewStateValues();

            if (IsNotRefreshed)
            {
                if (Page.IsValid)
                {
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            ClientBO objClient = new ClientBO(ObjContext);

                            if (int.Parse(hdnEditClientID.Value) > 0)
                            {
                                objClient.ID = int.Parse(hdnEditClientID.Value);
                                objClient.GetObject();
                            }

                            objClient.Name = this.txtClientName.Text;
                            objClient.Distributor = int.Parse(this.ddlDistributor.SelectedValue);

                            ObjContext.SaveChanges();
                            ts.Complete();

                            hdnClientID.Value = objClient.ID.ToString();
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

                            objJobName.Client = int.Parse(hdnClientID.Value);
                            objJobName.Name = txtNewJobName.Text;
                            objJobName.Modifier = this.LoggedUser.ID;
                            objJobName.ModifiedDate = DateTime.Now;

                            ObjContext.SaveChanges();
                            hdnJobNameID.Value = objJobName.ID.ToString();
                            ts.Complete();
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
            try
            {
                JobNameBO objJobName = new JobNameBO();
                objJobName.ID = int.Parse(hdnJobNameID.Value);
                objJobName.GetObject();

                //this.ddlJobNameClient.Items.FindByValue(objJobName.Client.ToString()).Selected = true;
                this.txtNewJobName.Text = objJobName.Name;

                hdnEditJobNameID.Value = objJobName.ID.ToString();
                ViewState["PopulateJobName"] = true;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Editing Jobname on AddEditOrder.aspx", ex);
            }
        }

        protected void btnNewOrderDetail_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            if (IsNotRefreshed)
            {
                hdnSelectedID.Value = "-1";
                ResetOrderDetailForm();

                collapse1.Attributes.Add("class", "accordion-body collapse");
                collapse2.Attributes.Add("class", "accordion-body collapse in");
                collapse3.Attributes.Add("class", "accordion-body collapse");

                ViewState["PopulateOrderDetail"] = true;
            }
        }

        protected void rbNaNuYes_CheckedChanged(object sender, EventArgs e)
        {
            dvNaNPreview.Visible = lifileUploder.Visible = dvNotification.Visible = rbNaNuYes.Checked;
            ViewState["PopulateOrderDetail"] = true;
        }

        protected void btnRefreshVL_Click(object sender, EventArgs e)
        {
            int selJobName = int.Parse(hdnJobNameID.Value);
            if (selJobName > 0)
                PopulateVisualLayouts(selJobName);
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
                int distributorID = int.Parse(hdnDistributorID.Value);

                //ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                //objReturnInt = SettingsBO.ValidateField(itemID, "Client", "Name", this.txtClientName.Text);
                //args.IsValid = objReturnInt.RetVal == 1;

                args.IsValid = IndicoPage.ValidateField2(itemID, "Client", "Name", this.txtClientName.Text, "Distributor", distributorID.ToString()) == 1;
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
                int clientID = int.Parse(hdnClientID.Value);

                //ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                //objReturnInt = SettingsBO.ValidateField(itemID, "JobName", "Name", this.txtNewJobName.Text);
                //args.IsValid = objReturnInt.RetVal == 1;

                args.IsValid = IndicoPage.ValidateField2(itemID, "JobName", "Name", this.txtClientName.Text, "Client", clientID.ToString()) == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cfvJobName_ServerValidate on AddEditOrder.aspx", ex);
            }
        }

        protected void cfvCompanyName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int itemID = int.Parse(hdnAddressID.Value);
                int distributorID = int.Parse(hdnDistributorID.Value);

                args.IsValid = IndicoPage.ValidateField2(itemID, "DistributorClientAddress", "CompanyName", this.txtCompanyName.Text, "Distributor", distributorID.ToString()) == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cfvCompanyName_ServerValidate on AddEditOrder.aspx", ex);
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
                ResetHiddenFields();

                this.hlNewVisualLayout.Visible = !this.LoggedUser.IsDirectSalesPerson;
                this.btnRefreshVL.Visible = !this.LoggedUser.IsDirectSalesPerson;

                if (OrderID == 0)
                {
                    liOrderNumber.Visible = false;
                }

                ddlStatus.Enabled = (OrderID > 0) ? true : false;

                //liClient.Visible = false;

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
                int.TryParse(IndicoPage.GetSetting("OPP"), out processingPeriod);
                txtDesiredDate.Text = IndicoPage.GetNextWeekday(DayOfWeek.Tuesday).AddDays(7 * (processingPeriod - 1)).ToString("dd MMMM yyyy");
                litDateRequiredDescription.Text = "(Please consider order processing period is " + processingPeriod + " weeks)";

                //Populate Distributors
                ddlDistributor.Items.Clear();
                ddlDistributor.Items.Add(new ListItem("Select Distributor", "0"));

                UserRole loggedUserRole = this.LoggedUserRoleName;
                bool isDirectSales = this.LoggedUser.IsDirectSalesPerson;
                bool isDistributor = loggedUserRole == UserRole.DistributorAdministrator || loggedUserRole == UserRole.DistributorCoordinator;
                bool isIndico = loggedUserRole == UserRole.IndicoAdministrator || loggedUserRole == UserRole.IndicoCoordinator;
                bool isIndiman = loggedUserRole == UserRole.IndimanAdministrator || loggedUserRole == UserRole.IndimanCoordinator;

                CompanyBO objDis = new CompanyBO();
                objDis.IsActive = true;
                objDis.IsDelete = false;
                objDis.IsDistributor = true;

                if (isIndico && !isDirectSales)
                {
                    objDis.Coordinator = LoggedUser.ID;
                }

                List<CompanyBO> lstDistributors = objDis.SearchObjects().OrderBy(m => m.Name).ToList();
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

                //PopulateMYOBCardNumber();

                //Populate Payment Method
                PopulatePaymentMethod(false);

                //Populate Pattern
                //PoplatePatterns();

                PopulateVlImage(0, 0);

                //Populate Order Types
                ddlOrderType.Items.Clear();
                ddlOrderType.Items.Add(new ListItem("Select Order Type", "0"));

                List<OrderTypeBO> lstOrderTypes = new OrderTypeBO().SearchObjects();
                if (LoggedUserRoleName == UserRole.DistributorAdministrator || LoggedUserRoleName == UserRole.DistributorCoordinator)
                {
                    lstOrderTypes = lstOrderTypes.Where(o => o.ID != 3 && o.ID != 4).ToList();
                }
                else if (LoggedUser.IsDirectSalesPerson)
                {
                    lstOrderTypes = lstOrderTypes.Where(o => o.Name == "ORDER" ||
                        o.Name == "SAMPLE" ||
                        o.Name == "REPLACEMENT AT SAMPLE PRICE" ||
                        o.Name == "REPLACEMENT FREE OF COST" ||
                        o.Name == "TEST PANEL").ToList();
                    chkBrandingKit.Checked = true;
                }

                foreach (OrderTypeBO orderType in lstOrderTypes)
                {
                    ddlOrderType.Items.Add(new ListItem(orderType.Name, orderType.ID.ToString()));
                }

                if (OrderID > 0)
                {
                    OrderBO objOrder = new OrderBO();
                    objOrder.ID = OrderID;
                    objOrder.GetObject(false);

                    lblDistributorAddress.Visible = true;

                    txtDate.Text = objOrder.Date.ToString("dd MMMM yyyy");
                    txtDesiredDate.Text = objOrder.EstimatedCompletionDate.ToString("dd MMMM yyyy");
                    txtShipmentDate.Text = (objOrder.ShipmentDate != null) ? objOrder.ShipmentDate.Value.ToString("dd MMMM yyyy") : string.Empty;
                    txtRefference.Text = objOrder.ID.ToString();

                    txtPoNo.Text = (objOrder.PurchaseOrderNo != null) ? objOrder.PurchaseOrderNo.ToString() : string.Empty;
                    txtOldPoNo.Text = objOrder.OldPONo;

                    litHeaderText.Text += " - PO " + txtRefference.Text;
                    liClient.Visible = true;

                    rbDateYes.Checked = (objOrder.IsDateNegotiable) ? true : false;
                    rbDateNo.Checked = (!objOrder.IsDateNegotiable) ? true : false;

                    rdoRoadFreight.Checked = (objOrder.DeliveryOption == 1);
                    rdoAirbag.Checked = (objOrder.DeliveryOption == 2);
                    rdoPickup.Checked = (objOrder.DeliveryOption == 3);

                    OrderDetailBO objOrderDetail = objOrder.OrderDetailsWhereThisIsOrder.First();

                    rbWeeklyShipment.Checked = objOrderDetail.IsWeeklyShipment ?? false;
                    rbCourier.Checked = objOrderDetail.IsCourierDelivery ?? false;

                    ddlDistributor.Items.FindByValue(objOrderDetail.objVisualLayout.objClient.objClient.Distributor.ToString()).Selected = true;
                    hdnDistributorID.Value = objOrderDetail.objVisualLayout.objClient.objClient.Distributor.ToString();

                    txtNotes.Text = objOrder.Notes;
                    chkTAndC.Checked = objOrder.IsAcceptedTermsAndConditions;
                    chkIsGstExclude.Checked = objOrder.IsGSTExcluded;

                    hdnBillingAddressID.Value = (objOrder.BillingAddress ?? 0).ToString();
                    hdnDespatchAddressID.Value = (objOrder.DespatchToAddress ?? 0).ToString();
                    hdnCourierAddressID.Value = ((rbCourier.Checked) ? objOrderDetail.DespatchTo ?? 0 : 0).ToString();

                    hdnJobNameID.Value = objOrderDetail.objVisualLayout.Client.ToString();
                    hdnClientID.Value = objOrderDetail.objVisualLayout.objClient.Client.ToString();
                    lblJobName.Text = objOrderDetail.objVisualLayout.objClient.Name;
                    btnEditJobName.Visible = true;

                    PopulateOrderDetails();

                    OrderDetailBO objODetail = new OrderDetailBO();
                    objODetail.Order = objOrder.ID;

                    List<OrderDetailBO> lstOD = objODetail.SearchObjects();
                    decimal totalPRice = 0;
                    foreach (OrderDetailBO objOD in lstOD)
                    {
                        int qty = objOD.OrderDetailQtysWhereThisIsOrderDetail.ToList().Sum(m => m.Qty);
                        totalPRice += (decimal.Parse((objOD.EditedPrice ?? 0).ToString()) * ((decimal)(1 + (objOrderDetail.DistributorSurcharge ?? 0) / (decimal)100.00))) * qty;
                    }

                    PopulateReservations(0, 0);
                    PopulateBillingDetails(totalPRice, objOrder);

                    btnSubmit.Visible = !(LoggedUserRoleName == UserRole.FactoryAdministrator || LoggedUserRoleName == UserRole.FactoryCoordinator);
                    if (objOrder.objStatus.Name == "Indiman Submitted")
                    {
                        btnSubmit.Visible = false;
                    }
                    //&& (!(lstOD.Where(m => !m.VisualLayout.HasValue || m.VisualLayout.Value == 0).Count() > 0));

                    //Disable fields to Factory

                    bool isNotFactory = !(LoggedUserRoleName == UserRole.FactoryAdministrator || LoggedUserRoleName == UserRole.FactoryCoordinator);
                    txtDate.Enabled = isNotFactory;
                    txtPoNo.Enabled = isNotFactory;
                    ddlDistributor.Enabled = isNotFactory;
                    ddlClient.Enabled = isNotFactory;
                    ddlJobName.Enabled = isNotFactory;
                    ddlBillingAddress.Enabled = isNotFactory;
                    ddlDespatchAddress.Enabled = isNotFactory;
                    ddlStatus.Enabled = isNotFactory;
                    //txtRefference.Enabled = isNotFactory;
                    txtOldPoNo.Enabled = isNotFactory;
                    txtDesiredDate.Enabled = isNotFactory;

                    aAddClient.Visible = isNotFactory;
                    btnEditClient.Visible = isNotFactory;
                    ancNewJobName.Visible = isNotFactory;
                    btnEditJobName.Visible = isNotFactory;
                    aAddShippingAddress.Visible = isNotFactory;
                    btnEditBilling.Visible = isNotFactory;
                    ancDespatchAddress.Visible = isNotFactory;
                    btnEditDespatch.Visible = isNotFactory;

                    //  btnNewOrderDetail.Visible = isNotFactory;

                }
                //else if (QueryReservationID > 0)
                //{
                //    ResetDropdowns();

                //    ReservationBO objReservation = new ReservationBO();
                //    objReservation.ID = QueryReservationID;
                //    objReservation.GetObject();

                //    txtDate.Text = objReservation.OrderDate.ToString("dd MMM yyyy");
                //    ddlDistributor.Items.FindByValue(objReservation.Distributor.ToString()).Selected = true;
                //    PopulateDistributorClients(objReservation.Distributor);
                //    ddlJobName.Items.FindByValue(objReservation.Client.ToString()).Selected = true;
                //}
                else
                {
                    aAddClient.Attributes.Add("style", "display : none");
                    ancNewJobName.Attributes.Add("style", "display : none");
                    aAddShippingAddress.Attributes.Add("style", "display : none");
                    ancDespatchAddress.Attributes.Add("style", "display : none");

                    btnEditClient.Attributes.Add("style", "display : none");
                    btnEditJobName.Attributes.Add("style", "display : none");
                    btnEditBilling.Attributes.Add("style", "display : none");
                    btnEditDespatch.Attributes.Add("style", "display : none");
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

                    //if (OrderID == 0)
                    //{
                    //    PopulateDistributorClients(LoggedCompany.ID);
                    //}
                }

                if (ispostback && LoggedUser.IsDirectSalesPerson)
                {
                    // liDistributor.Visible = false;
                    ddlDistributor.ClearSelection();
                    ddlDistributor.Items.FindByValue(Distributor.ID.ToString()).Selected = true;
                    ddlDistributor.Enabled = false;

                    CompanyBO objDistributor = new CompanyBO();
                    objDistributor.ID = DistributorID;
                    objDistributor.GetObject(false);

                    lblDistributor.Text = objDistributor.Name + " - " + objDistributor.Number + "  " + objDistributor.Address1 + "  " + objDistributor.City + "  " + objDistributor.State + "  " + objDistributor.Postcode + "  " + objDistributor.objCountry.ShortName;
                    lblClientDistributor.Text = objDistributor.Name;

                    //liDistributor.Visible = false;
                    ddlDistributor.Enabled = false;
                    lblDistributor.Visible = true;

                    liAccessNo.Visible = false;

                    ViewState["PopulateDropDown"] = true;

                    //if (OrderID == 0)
                    //{
                    //    PopulateDistributorClients(DistributorID);
                    //}
                }

                //dvIndimanPrice.Visible = dvPercentage.Visible = (LoggedUserRoleName == UserRole.IndimanAdministrator) || (LoggedUserRoleName == UserRole.IndimanCoordinator)
                //        || (LoggedUserRoleName == UserRole.IndicoAdministrator) || (LoggedUserRoleName == UserRole.IndicoCoordinator);

                PopulateOrderStatus(QueryID);

                //if (OrderID == 0 && VisualLayoutID > 0)
                //{
                //    ddlVlNumber.Items.FindByValue(VisualLayoutID.ToString()).Selected = true;
                //    ddlVlNumber_SelectedIndexChange(this, EventArgs.Empty);
                //}
                //sizeWarningAlert.Visible = false;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Exception occured on PopulateControls()", ex);
            }
        }

        private void ProcessForm()
        {
            var testString = string.Empty;
            var orderstring = string.Empty;

            try
            {
                using (var ts = new TransactionScope())
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
                    objOrder.Client = int.Parse(hdnJobNameID.Value);
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
                    //objOrder.MYOBCardFile = int.Parse(ddlMYOBCardFile.SelectedValue);

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
                    objOrder.BillingAddress = int.Parse(hdnBillingAddressID.Value);
                    objOrder.DespatchToAddress = int.Parse(hdnDespatchAddressID.Value);

                    #endregion

                    #region Process Order Details From temp

                    foreach (int odID in ListDeletedODIDs)
                    {
                        OrderDetailBO objOrderDetail = new OrderDetailBO(ObjContext);
                        objOrderDetail.ID = odID;
                        objOrderDetail.GetObject();

                        PackingListBO objPL = new PackingListBO();
                        objPL.OrderDetail = odID;
                        List<PackingListBO> lstPL = objPL.SearchObjects();

                        foreach (PackingListBO pl in lstPL)
                        {
                            PackingListBO objPackingList = new PackingListBO(ObjContext);
                            objPackingList.ID = pl.ID;
                            objPackingList.GetObject();

                            PackingListSizeQtyBO objPLSQ = new PackingListSizeQtyBO();
                            objPLSQ.PackingList = pl.ID;
                            List<PackingListSizeQtyBO> lstPLSQ = objPLSQ.SearchObjects();

                            foreach (PackingListSizeQtyBO plsq in lstPLSQ)
                            {
                                PackingListSizeQtyBO objPackingListSizeQty = new PackingListSizeQtyBO(ObjContext);
                                objPackingListSizeQty.ID = plsq.ID;
                                objPackingListSizeQty.GetObject();

                                objPackingListSizeQty.Delete();
                            }

                            PackingListCartonItemBO objPLCI = new PackingListCartonItemBO();
                            objPLCI.PackingList = pl.ID;
                            List<PackingListCartonItemBO> lstPLCI = objPLCI.SearchObjects();

                            foreach (PackingListCartonItemBO plci in lstPLCI)
                            {
                                PackingListCartonItemBO objPackingListCartonItem = new PackingListCartonItemBO(ObjContext);
                                objPackingListCartonItem.ID = plci.ID;
                                objPackingListCartonItem.GetObject();

                                objPackingListCartonItem.Delete();
                            }

                            objPackingList.Delete();
                        }

                        OrderDetailQtyBO objODQ = new OrderDetailQtyBO();
                        objODQ.OrderDetail = odID;
                        List<OrderDetailQtyBO> lstODQ = objODQ.SearchObjects();

                        foreach (OrderDetailQtyBO qty in lstODQ)
                        {
                            OrderDetailQtyBO objClientOrderDetailOrderQty = new OrderDetailQtyBO(ObjContext);
                            objClientOrderDetailOrderQty.ID = qty.ID;
                            objClientOrderDetailOrderQty.GetObject();

                            objClientOrderDetailOrderQty.Delete();
                        }

                        objOrderDetail.Delete();
                    }

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

                        objOrderDetail.EditedPrice = decimal.Parse(objTempOD.DistributorEditedPrice);
                        objOrderDetail.Surcharge = decimal.Parse(objTempOD.IndimanSurCharge);
                        objOrderDetail.DistributorSurcharge = decimal.Parse(objTempOD.DistributorSurcharge);
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
                            objOrderDetail.DespatchTo = int.Parse(hdnCourierAddressID.Value);
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

                            if (objTempOD.ID > 0 && objTempQty.ID > 0)
                            {
                                objQty.ID = objTempQty.ID;
                                objQty.GetObject();
                            }

                            if (objTempOD.ID > 0)
                                objQty.OrderDetail = objTempOD.ID;
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

                    this.OrderID = objOrder.ID;

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

                    var nnFileTempDirectory = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Temp\\" + objOrder.ID.ToString();
                    if (Directory.Exists(nnFileTempDirectory))
                        Directory.Delete(nnFileTempDirectory, true);
                    ts.Complete();
                }

                //save to myob
                var myobService = new MyobService();
                myobService.SaveOrder(OrderID);
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
                //objTempOrderDetail.FromVisualLayout = rbVisualLayout.Checked;
                objTempOrderDetail.OrderType = int.Parse(ddlOrderType.SelectedValue);
                objTempOrderDetail.Label = int.Parse(ddlLabel.SelectedValue);
                objTempOrderDetail.RequestedDate = WeekEndDate;
                objTempOrderDetail.SheduledDate = WeekEndDate;
                objTempOrderDetail.ShipmentDate = WeekEndDate;

                //if (objTempOrderDetail.FromVisualLayout)
                //{
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

                objTempOrderDetail.OrderTypeName = ddlOrderType.SelectedItem.Text;

                objTempOrderDetail.PromoCode = txtPromoCode.Text;
                objTempOrderDetail.DistributorEditedPrice = txtDistributorPrice.Text;
                objTempOrderDetail.IndimanSurCharge = txtIndimanSurcharge.Text;
                objTempOrderDetail.DistributorSurcharge = txtDistributorSurcharge.Text;

                objTempOrderDetail.PriceComments = txtPriceComments.Text;
                objTempOrderDetail.OrderDetailNotes = txtOdNotes.Text;
                objTempOrderDetail.FactoryInstructions = txtFactoryDescription.Text;

                //objTempOrderDetail.IsRepeat = txtFactoryDsescription.Text;
                //objTempOrderDetail.IsEmbroidery = txtFactsoryDescription.Text;
                //objTempOrderDetail.ResolutionProfile = txtFactorsyDescription.Text;
                //objTempOrderDetail.PocketType = txtFactoryDesscription.Text;

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
                objTempOrderDetail.IsNamesAndNumbers = rbNaNuYes.Checked;
                string NNFileName = hdnUploadFiles.Value.Split(',')[0]; // asd_345.txt,ASD.txt

                if (objTempOrderDetail.IsNamesAndNumbers && !string.IsNullOrEmpty(NNFileName))
                {
                    objTempOrderDetail.NameAndNumbersFileName = NNFileName;

                    string NNFileTempDirectory = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Temp\\" + objTempOrderDetail.Guid; //lstOrderDetails.First().Order.ToString();
                    if (!Directory.Exists(NNFileTempDirectory))
                        Directory.CreateDirectory(NNFileTempDirectory);

                    string NNFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Temp\\" + NNFileName; // GetNameNumberFilePath(objOrderDetail.ID);
                    //string NNTempPath = NNFileTempDirectory + "\\" + objTempOrderDetail.Index.ToString();
                    //Directory.CreateDirectory(NNTempPath);

                    objTempOrderDetail.NameAndNumbersFilePath = NNFileTempDirectory + "\\" + NNFileName;

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

                //List<OrderDetailBO> lstOD = lstOrderDetails.OrderDetailsWhereThisIsOrder;
                decimal totalPRice = 0;
                foreach (OrderDetail objOD in lstOrderDetails)
                {
                    int qty = objOD.ListQtys.ToList().Sum(m => m.Qty);
                    totalPRice += (decimal.Parse(objOD.DistributorEditedPrice) * ((decimal)(1 + (decimal.Parse(objOD.DistributorSurcharge)) / (decimal)100.00))) * qty;
                }

                PopulateReservations(0, 0);
                PopulateBillingDetails(totalPRice, null);

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
                objOrder.GetObject(false);

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
            List<OrderDetailsView> lstOrderDetails = new List<OrderDetailsView>();

            if (OrderID > 0)
            {
                OrderBO objOrder = new OrderBO();
                objOrder.ID = orderID;
                objOrder.GetObject();

                //lstOrderDetails = OrderBO.GetOrderDetails(objOrder.ID, (objOrder.PaymentMethod != null && objOrder.PaymentMethod > 0) ? (objOrder.PaymentMethod == 1) ? 1 : 2 : 1);

                using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
                {
                    connection.Open();

                    lstOrderDetails = connection.Query<OrderDetailsView>(" EXEC	[dbo].[SPC_GetOrderDetailIndicoPrice] " +
                                                                            "@P_Order = '" + objOrder.ID + "'").ToList();

                    connection.Close();
                }

                OrderDetailBO objOrderDetail = new OrderDetailBO();
                objOrderDetail.ID = lstOrderDetails.First().OrderDetail;
                objOrderDetail.GetObject();

                ddlPaymentMethod.ClearSelection();
                ddlShipmentMode.ClearSelection();
                ddlCourierAddress.ClearSelection();

                ddlShipmentMode.Items.FindByValue(objOrderDetail.ShipmentMode.ToString()).Selected = true;
                ddlPaymentMethod.Items.FindByValue(objOrderDetail.PaymentMethod.ToString()).Selected = true;
                txtShipmentDate.Text = objOrderDetail.ShipmentDate.ToString("dd MMM yyyy");
                rbWeeklyShipment.Checked = objOrderDetail.IsWeeklyShipment ?? false;
                rbCourier.Checked = objOrderDetail.IsCourierDelivery ?? false;

                //if (rbCourier.Checked)
                //    ddlCourierAddress.Items.FindByValue(objOrderDetail.DespatchTo.ToString()).Selected = true;

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
                ddlVlNumber.Items.Clear();
                ddlVlNumber.Items.Add(new ListItem("Select Visual Layout Number", "0"));
                using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
                {
                    var vls = connection.Query<ActiveVisualLayout>(string.Format("SELECT * FROM [dbo].[ReturnActiveVisualLayoutsView] WHERE Client = {0}", jobName));
                    foreach (var vl in vls)
                    {
                        var vlText = ((vl.NameSuffix == null) ? vl.NamePrefix : vl.NamePrefix + vl.NameSuffix) + " - Pattern : " + vl.PatternNumber;
                        vlText += " - Fabric : " + vl.FabricCodeName;
                        ddlVlNumber.Items.Add(new ListItem(vlText, vl.VlID.ToString()));
                    }
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

            if (int.Parse(hdnClientID.Value.ToString()) < 1)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpOrderHeader";
                cv.ErrorMessage = "Client is required";
                Page.Validators.Add(cv);
            }

            if (int.Parse(hdnJobNameID.Value.ToString()) < 1)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpOrderHeader";
                cv.ErrorMessage = "Jobname is required";
                Page.Validators.Add(cv);
            }

            if (int.Parse(hdnBillingAddressID.Value.ToString()) < 1)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpOrderHeader";
                cv.ErrorMessage = "Billing address is required";
                Page.Validators.Add(cv);
            }

            if (int.Parse(hdnDespatchAddressID.Value.ToString()) < 1)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpOrderHeader";
                cv.ErrorMessage = "Despatch address is required";
                Page.Validators.Add(cv);
            }

            if (rbCourier.Checked && (int.Parse(hdnCourierAddressID.Value.ToString()) < 1))
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpOrderHeader";
                cv.ErrorMessage = "Courier Despatch address is required";
                Page.Validators.Add(cv);
            }

            if (dgOrderItems.Items.Count == 0)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpOrderHeader";
                cv.ErrorMessage = "No orders have been added";
                Page.Validators.Add(cv);
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
                objDistributor.GetObject(true);

                using (var connection = DatabaseConnection)
                {
                    var labels = connection.Query(string.Format("SELECT l.Name,l.ID FROM [dbo].[DistributorLabel] dl INNER JOIN [dbo].[Label] l ON l.ID = dl.Label WHERE dl.Distributor = {0} AND l.IsActive = 1", objDistributor.ID))
                        .Select(s => new { s.Name, s.ID }).ToList();
                    foreach (var label in labels)
                    {
                        ListItem listItemLabel = new ListItem(label.Name, label.ID.ToString());
                        ddlLabel.Items.Add(listItemLabel);
                    }

                }

                if (ddlLabel.Items.FindByText("BLACKCHROME HEAT SEAL") != null)
                {
                    ddlLabel.Items.FindByText("BLACKCHROME HEAT SEAL").Selected = true;
                }
            }
        }

        private void PopulateVlImage(int VisualLayoutId, int label)
        {
            string filepath = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";

            try
            {
                bool isFactory = this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator || this.LoggedUserRoleName == UserRole.FactoryPatternDeveloper;

                if (isFactory && label > 0)
                {
                    litVLImageCaption.Text = "Label Image";

                    LabelBO objLabel = new LabelBO();
                    objLabel.ID = label;
                    objLabel.GetObject();

                    string labelLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/Labels/" + objLabel.LabelImagePath;

                    if (File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + labelLocation))
                    {
                        filepath = labelLocation;
                    }
                }
                else if (VisualLayoutId > 0)
                {
                    filepath = IndicoPage.GetVLImagePath(VisualLayoutId);
                    if (string.IsNullOrEmpty(filepath))
                    {
                        filepath = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    }
                }
            }
            catch (Exception ex)
            {
            }

            imgvlImage.ImageUrl = filepath;
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
                objOrder.GetObject(true);

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

        private void PopulateReservationsDetails(int reservationID)
        {
            if (reservationID > 0)
            {
                ReservationBO objReservation = new ReservationBO();
                objReservation.ID = reservationID;
                objReservation.GetObject(true);

                litReservationDetail.Text = "RES - " + objReservation.ReservationNo.ToString("0000") + "    " + objReservation.objDistributor.Name;
            }
            else
            {
                litReservationDetail.Text = string.Empty;
            }

            litReservationDetail.Visible = (reservationID > 0) ? true : false;
            collapse2.Attributes.Add("class", "accordion-body collapse in");
        }

        private void SetOrderStatus(int orderdetail)
        {
            int notcompleted = 0;
            int complete = 0;
            int odStatus = 0;
            int cancelled = 0;

            OrderDetailBO objOD = new OrderDetailBO();
            objOD.ID = orderdetail;
            objOD.GetObject(true);

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

        private void PopulatePrice(int pattern, int fabricCode, int qty, decimal indimanSurcharge = 0, decimal distributorSurcharge = 0, decimal distrbutorEditedPrice = 0)
        {
            decimal percentage = decimal.Parse("0.42");
            decimal indimanPrice = IndicoPage.GetCostSheetPricePerVL(pattern, fabricCode);

            decimal normalDistriburtorPrice = (distrbutorEditedPrice > 0) ? distrbutorEditedPrice : (indimanPrice + indimanSurcharge) / (1 - percentage);
            decimal finalDistributorPrice = normalDistriburtorPrice + (normalDistriburtorPrice * distributorSurcharge / 100);
            decimal indimanFinalPrice = indimanPrice + indimanSurcharge;
            decimal salesValue = finalDistributorPrice * qty;
            decimal purchaseValue = indimanFinalPrice * qty;
            decimal grossProfit = salesValue - purchaseValue;

            this.hdnTotalQuantity.Value = qty.ToString();
            this.txtTotalQty.Text = qty.ToString();
            this.txtIndimanCostSheetPrice.Text = "$" + indimanPrice.ToString("0.00");
            this.txtIndimanSurcharge.Text = indimanSurcharge.ToString("0.00");
            this.txtIndimanFinalPrice.Text = "$" + indimanFinalPrice.ToString("0.00");
            this.txtIndimanPurchaseValue.Text = "$" + purchaseValue.ToString("0.00");

            this.txtDistributorPrice.Text = normalDistriburtorPrice.ToString("0.00");
            this.txtDistributorSurcharge.Text = distributorSurcharge.ToString("0.00");
            this.txtDistributorFinalPrice.Text = "$" + finalDistributorPrice.ToString("0.00");
            this.txtSalesValue.Text = "$" + salesValue.ToString("0.00");
            this.txtGrossProfit.Text = "$" + grossProfit.ToString("0.00");
            this.txtGrossMargin.Text = ((salesValue > 0) ? ((1 - (purchaseValue / salesValue)) * 100).ToString("0.00") : "0.00") + "%";
        }

        private void PopulateBillingDetails(decimal totalPRice, OrderBO objOrder) //List<OrderDetailBO> lstOD)
        {
            decimal zeroPrice = 0;
            decimal deliveryCharges = 0;
            decimal artWorkCharges = 0;
            decimal OtherCharges = 0;

            txtTotalValue.Text = totalPRice.ToString("0.00");

            try
            {
                if (objOrder != null)
                {
                    deliveryCharges = ((objOrder.DeliveryCharges ?? 0) == 0) ? zeroPrice : objOrder.DeliveryCharges.Value;
                    artWorkCharges = ((objOrder.ArtWorkCharges ?? 0) == 0) ? zeroPrice : objOrder.ArtWorkCharges.Value;
                    OtherCharges = ((objOrder.OtherCharges ?? 0) == 0) ? zeroPrice : objOrder.OtherCharges.Value;
                    txtOtherChargesDescription.Text = objOrder.OtherChargesDescription;
                }
                else
                {
                    deliveryCharges = decimal.Parse(txtDeliveryCharges.Text);
                    artWorkCharges = decimal.Parse(txtArtworkCharges.Text);
                    OtherCharges = decimal.Parse(txtOtherCharges.Text);
                    //txtOtherChargesDescription.Text = objOrder.OtherChargesDescription;
                }
            }
            catch (Exception ex)
            {

            }

            totalPRice += (deliveryCharges + artWorkCharges + OtherCharges);

            txtDeliveryCharges.Text = deliveryCharges.ToString("0.00");
            txtArtworkCharges.Text = artWorkCharges.ToString("0.00");
            txtOtherCharges.Text = OtherCharges.ToString("0.00");
            txtTotalValueExcludeGST.Text = totalPRice.ToString("0.00");

            txtGST.Text = (totalPRice / 10).ToString("0.00");
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

                decimal surCharge = decimal.Parse("0.00");
                int qty = 0;

                //if (lstOrderDetailQty.Any())
                //{
                //    OrderDetailBO objOrderDetail = new OrderDetailBO();
                //    objOrderDetail.ID = lstOrderDetailQty[0].OrderDetail;
                //    objOrderDetail.GetObject();

                //    surCharge = objOrderDetail.Surcharge;
                //    qty = lstOrderDetailQty.Sum(v => v.Qty);
                //}

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
                txtIndimanCostSheetPrice.Text = string.Empty;
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

                txtCompanyName.Text = objDistributorClientAddress.CompanyName;
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

        private List<OrderDetail> PopulateTempOrderDetails(List<OrderDetailsView> lstOrderDetails)
        {
            List<OrderDetail> lstTempOrderDetails = new List<OrderDetail>();

            int index = 0;
            string NNFileTempDirectory = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Temp\\";

            foreach (OrderDetailsView objOD in lstOrderDetails)
            {
                OrderDetail objOrderDetailtemp = new OrderDetail();

                OrderDetailBO objOrderDetail = new OrderDetailBO();
                objOrderDetail.ID = objOD.OrderDetail;
                objOrderDetail.GetObject();

                objOrderDetailtemp.Index = index++;
                objOrderDetailtemp.ID = objOD.OrderDetail;
                objOrderDetailtemp.OrderType = objOrderDetail.OrderType;
                objOrderDetailtemp.Label = objOD.Label;

                objOrderDetailtemp.UseBrandingkit = objOrderDetail.IsBrandingKit;
                objOrderDetailtemp.UseLockerPatch = objOrderDetail.IsLockerPatch;
                objOrderDetailtemp.IsPhotoApprovalRequired = objOrderDetail.PhotoApprovalReq ?? false;

                objOrderDetailtemp.OrderTypeName = objOD.OrderType;
                objOrderDetailtemp.VisualLayout = objOD.VisualLayoutID;
                objOrderDetailtemp.Pattern = objOD.PatternID;
                objOrderDetailtemp.Fabric = objOD.FabricID;

                objOrderDetailtemp.VisualLayoutName = objOD.VisualLayout;

                objOrderDetailtemp.PatternName = objOD.Pattern;
                objOrderDetailtemp.FabricName = objOD.Fabric;
                objOrderDetailtemp.OrderDetailNotes = objOD.VisualLayoutNotes;
                objOrderDetailtemp.DistributorEditedPrice = objOD.DistributorEditedPrice.ToString("0.00");
                objOrderDetailtemp.StatusID = objOD.StatusID;
                objOrderDetailtemp.Status = objOD.Status;
                objOrderDetailtemp.Order = objOD.Order;
                objOrderDetailtemp.IndimanSurCharge = objOD.Surcharge.ToString("0.00");
                objOrderDetailtemp.DistributorSurcharge = objOD.DistributorSurcharge.ToString("0.00");
                objOrderDetailtemp.PriceComments = objOD.EditedPriceRemarks;
                objOrderDetailtemp.OrderDetailNotes = objOD.VisualLayoutNotes;
                objOrderDetailtemp.FactoryInstructions = objOD.FactoryInstructions;

                objOrderDetailtemp.IsRepeat = objOD.IsRepeat;
                objOrderDetailtemp.IsEmbroidery = objOD.IsEmbroidery;
                objOrderDetailtemp.ResolutionProfile = objOD.ResolutionProfile;
                objOrderDetailtemp.PocketType = objOD.PocketType;

                OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                objOrderDetailQty.OrderDetail = objOD.OrderDetail;
                objOrderDetailtemp.ListQtys = objOrderDetailQty.SearchObjects();

                //NN File Processing
                try
                {
                    if (!string.IsNullOrEmpty(objOrderDetail.NameAndNumbersFilePath))
                    {
                        //if (!Directory.Exists(NNFileTempDirectory))
                        //    Directory.CreateDirectory(NNFileTempDirectory);
                        //IndicoPage.EmptyDirectory(new DirectoryInfo(NNFileTempDirectory));

                        string NNFilePath = GetNameNumberFilePath(objOrderDetail.ID);
                        //string NNTempPath = NNFileTempDirectory + "\\" + objOD.OrderDetail.ToString();
                        string NNTempDirectory = NNFileTempDirectory + "\\" + objOrderDetailtemp.Guid;
                        Directory.CreateDirectory(NNTempDirectory);

                        objOrderDetailtemp.NameAndNumbersFileName = objOrderDetail.NameAndNumbersFilePath;
                        objOrderDetailtemp.NameAndNumbersFilePath = NNTempDirectory + "\\" + objOrderDetail.NameAndNumbersFilePath;
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
            //ViewState["PopulateDeleteOrdersMsg"] = false;
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

                populateLabels(int.Parse(hdnDistributorID.Value));
                PopulateVisualLayouts(int.Parse(hdnJobNameID.Value));
                PopulateVlImage(0, 0);

                ddlSizes.ClearSelection();
                ddlSizes.Visible = false;
                ddlVlNumber.Enabled = true;

                txtPriceComments.Text = string.Empty;
                txtOdNotes.Text = string.Empty;
                txtFactoryDescription.Text = string.Empty;

                txtDistributorPrice.Text = string.Empty;
                txtDistributorSurcharge.Text = string.Empty;
                txtDistributorSurcharge.Text = string.Empty;
                txtDistributorFinalPrice.Text = string.Empty;

                litFabric.Text = string.Empty;
                litPattern.Text = string.Empty;

                rptSizeQty.DataSource = null;
                rptSizeQty.DataBind();

                txtTotalQty.Text = "0";
                txtUnit.Text = string.Empty;
                txtIndimanCostSheetPrice.Text = string.Empty;
                txtPromoCode.Text = string.Empty;

                litfileName.Text = string.Empty;
                uploadImage.ImageUrl = "\\IndicoData\\NameAndNumbersFiles\\no_files_found.jpg";
                lifileUploder.Visible = true;
                hdnDeleteFile.Value = "0";
                hdnUploadFiles.Value = string.Empty;
                dvNotification.Visible = true;
                linkDelete.Visible = false;
                rbNaNuNo.Checked = true;
                rbNaNuYes_CheckedChanged(null, null);

                hlNewVisualLayout.NavigateUrl = "/AddEditVisualLayout.aspx?jobnameid=" + hdnJobNameID.Value;

                btnAddOrder.InnerHtml = "Add Order Detail";
                btnAddOrder.Attributes.Add("data-loading-text", "Saving...");
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while ResetOrderDetailForm from AddEditOrder.aspx", ex);
            }
        }

        private void ResetHiddenFields()
        {
            Session["OrderID"] = null;
            hdnDistributorID.Value = "0";
            hdnClientID.Value = "0";
            hdnJobNameID.Value = "0";
            hdnBillingAddressID.Value = "0";
            hdnDespatchAddressID.Value = "0";
            hdnCourierAddressID.Value = "0";
            hdnLabelID.Value = "0";
            hdnVisualLayoutID.Value = "0";
            hdnEditClientID.Value = "0";
            hdnEditJobNameID.Value = "0";
        }

        #endregion

        #region WebMethods

        [WebMethod]
        public static List<ListItem> GetClients(int id)
        {
            List<ListItem> clients = new List<ListItem>();

            try
            {
                if (id > 0)
                {
                    ClientBO objClient = new ClientBO();
                    objClient.Distributor = id;

                    List<ClientBO> lstJobNames = objClient.SearchObjects();

                    clients = lstJobNames.Select(m => (new ListItem
                    {
                        Value = m.ID.ToString(),
                        Text = m.Name.ToString()
                    })).ToList();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while GetClients from AddEditOrder.aspx", ex);
            }

            return clients;
        }

        [WebMethod]
        public static List<ListItem> GetJobNames(int id)
        {
            List<ListItem> jobNames = new List<ListItem>();

            try
            {
                if (id > 0)
                {
                    JobNameBO objJobName = new JobNameBO();
                    objJobName.Client = id;

                    List<JobNameBO> lstJobNames = objJobName.SearchObjects();

                    jobNames = lstJobNames.Select(m => (new ListItem
                    {
                        Value = m.ID.ToString(),
                        Text = m.Name.ToString()
                    })).ToList();
                }

            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while GetJobNames from AddEditOrder.aspx", ex);
            }

            return jobNames;
        }

        [WebMethod]
        public static List<ListItem> GetBillingAddress(int id)
        {
            List<ListItem> clients = new List<ListItem>();

            try
            {
                if (id > 0)
                {
                    DistributorClientAddressBO objAddress = new DistributorClientAddressBO();
                    objAddress.Distributor = id;

                    List<DistributorClientAddressBO> lstAddress = objAddress.SearchObjects();

                    clients = lstAddress.Select(m => (new ListItem
                    {
                        Value = m.ID.ToString(),
                        Text = m.CompanyName.ToString()
                    })).ToList();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while GetBillingAddress from AddEditOrder.aspx", ex);
            }

            return clients;
        }

        [WebMethod]
        public static List<ListItem> GetLabels(int id)
        {
            List<ListItem> labels = new List<ListItem>();

            try
            {
                if (id > 0)
                {
                    CompanyBO objDistributor = new CompanyBO();
                    objDistributor.ID = id;
                    objDistributor.GetObject();

                    List<LabelBO> lstLabels = objDistributor.DistributorLabelsWhereThisIsDistributor;

                    labels = lstLabels.Select(m => (new ListItem
                    {
                        Value = m.ID.ToString(),
                        Text = m.Name.ToString()
                    })).ToList();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while GetLabels from AddEditOrder.aspx", ex);
            }

            return labels;
        }

        [WebMethod]
        public static List<ListItem> GetVisualLayouts(int id)
        {
            List<ListItem> visualLayouts = new List<ListItem>();

            try
            {
                if (id > 0)
                {
                    List<VisualLayoutBO> lstVisualLayout = new List<VisualLayoutBO>();
                    VisualLayoutBO objVisualLayout = new VisualLayoutBO();
                    objVisualLayout.Client = id;

                    lstVisualLayout = objVisualLayout.SearchObjects().Where(m => (m.FabricCode ?? 0) > 0 && m.Pattern > 0).ToList();

                    visualLayouts = lstVisualLayout.Select(m => (new ListItem
                    {
                        Value = m.ID.ToString(),
                        Text = ((m.NameSuffix == null) ? m.NamePrefix : m.NamePrefix + m.NameSuffix) + " - Pattern : " + m.objPattern.Number + ((m.FabricCode.HasValue && m.FabricCode.Value > 0) ? " - Fabric : " + m.objFabricCode.NickName : string.Empty)
                    })).ToList();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while GetVisualLayouts from AddEditOrder.aspx", ex);
            }

            return visualLayouts;
        }

        [WebMethod]
        public static string GetClientDetails(int id)
        {
            string details = string.Empty;

            try
            {
                if (id > 0)
                {
                    ClientBO objClient = new ClientBO();
                    objClient.ID = id;
                    objClient.GetObject();

                    details = objClient.FOCPenalty ? "This is a FOC Penalty Client" : objClient.Name;
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while GetClientDetails from AddEditOrder.aspx", ex);
            }

            return details;
        }

        [WebMethod]
        public static string GetDistributorDetails(int id)
        {
            string details = string.Empty;

            try
            {
                if (id > 0)
                {
                    CompanyBO objDistributor = new CompanyBO();
                    objDistributor.ID = id;
                    objDistributor.GetObject();

                    if (objDistributor.Number != null && objDistributor.Address1 != null && objDistributor.City != null && objDistributor.State != null && objDistributor.Postcode != null)
                    {
                        details = objDistributor.Number + "  " + objDistributor.Address1 + "  " + objDistributor.City + "  " + objDistributor.State + "  " + objDistributor.Postcode + "  " + objDistributor.objCountry.ShortName;
                        //lblDistributorAddress.ForeColor = Color.Black;
                    }
                    else
                    {
                        details = "Address details are not available for this Distributor";
                        //lblDistributorAddress.ForeColor = Color.Red;
                    }
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while GetDistributorDetails from AddEditOrder.aspx", ex);
            }

            return details;
        }

        [WebMethod]
        public static string GetAddressDetails(int id)
        {
            string details = string.Empty;

            try
            {
                if (id > 0)
                {
                    DistributorClientAddressBO objDCA = new DistributorClientAddressBO();
                    objDCA.ID = id;
                    objDCA.GetObject();

                    details = objDCA.CompanyName + "  " + objDCA.Address + "  " + objDCA.PostCode + "  " + objDCA.Suburb + "  " +
                        objDCA.PostCode + "  " + objDCA.State + "  " + objDCA.objCountry.ShortName;
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while GetAddressDetails from AddEditOrder.aspx", ex);
            }

            return details;
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
            public string Guid { get; set; }

            public bool IsPhotoApprovalRequired { get; set; }
            public bool UseBrandingkit { get; set; }
            public bool UseLockerPatch { get; set; }


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
            public string DistributorEditedPrice { get; set; }
            public string IndimanSurCharge { get; set; }
            public string DistributorSurcharge { get; set; }

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

            public bool IsEmbroidery { get; set; }
            public bool IsRepeat { get; set; }
            public string ResolutionProfile { get; set; }
            public string PocketType { get; set; }

            public int Reservation { get; set; }
            public int StatusID { get; set; }
            public string Status { get; set; }
            public int Order { get; set; }

            internal OrderDetail()
            {
                this.ListQtys = new List<OrderDetailQtyBO>();
                this.Guid = System.Guid.NewGuid().ToString();
            }
        }

        public class ActiveVisualLayout
        {
            public int VlID { get; set; }
            public string NamePrefix { get; set; }
            public int? NameSuffix { get; set; }
            public string PatternNumber { get; set; }
            public string FabricCodeName { get; set; }
        }

        #endregion
    }
}