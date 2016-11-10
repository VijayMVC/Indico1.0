using Dapper;
using Indico.BusinessObjects;
using Indico.Common;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using Telerik.Web.UI;

namespace Indico
{
    public partial class ViewOrders : IndicoPage
    {
        #region Fields

        private int urlQueryID = -1;
        private DateTime qpWeekEndDate = new DateTime(1100, 1, 1);
        private string qpType = null;
        string orderNumber = string.Empty;
        int visualLayout = 0;
        private List<OrderDetailStatusBO> lstOrderDetailStatus = null;
        private List<ResolutionProfileBO> lstResolutionProfiles = null;

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["VisualLayoutSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "0";
                }
                return sort;
            }
            set
            {
                ViewState["VisualLayoutSortExpression"] = value;
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
                //if (qpWeekEndDate != new DateTime(1100, 1, 1))
                //    return qpWeekEndDate;
                if (Request.QueryString["WeekendDate"] != null)
                {
                    qpWeekEndDate = Convert.ToDateTime(Request.QueryString["WeekendDate"].ToString());
                }
                return qpWeekEndDate;
            }
        }

        protected string Type
        {
            get
            {
                if (qpType != null)
                    return qpType;
                qpType = null;
                if (Request.QueryString["Type"] != null)
                {
                    qpType = Request.QueryString["Type"].ToString();
                }
                return qpType;
            }
            set
            {
                qpType = value;
            }
        }

        protected List<OrderDetailStatusBO> OrderDetailsStatus
        {
            get
            {
                if (Session["OrderDetailStatus"] != null)
                {
                    lstOrderDetailStatus = (List<OrderDetailStatusBO>)Session["OrderDetailStatus"];
                }
                else
                {
                    lstOrderDetailStatus = (new OrderDetailStatusBO()).GetAllObject().Where(o => o.ID == (int)OrderDetailStatusBO.ODStatus.ODSPrinted ||
                                                                                                 o.ID == (int)OrderDetailStatusBO.ODStatus.OnHold ||
                                                                                                 o.ID == (int)OrderDetailStatusBO.ODStatus.Cancelled ||
                                                                                                 o.ID == (int)OrderDetailStatusBO.ODStatus.Shipped ||
                                                                                                 o.ID == (int)OrderDetailStatusBO.ODStatus.PreShipped ||
                                                                                                 o.ID == (int)OrderDetailStatusBO.ODStatus.WaitingInfo).ToList();

                    Session["OrderDetailStatus"] = lstOrderDetailStatus;
                }
                return lstOrderDetailStatus;
            }
        }

        protected List<ResolutionProfileBO> ResolutionProfiles
        {
            get
            {
                if (Session["ResolutionProfiles"] != null)
                {
                    lstResolutionProfiles = (List<ResolutionProfileBO>)Session["ResolutionProfiles"];
                }
                else
                {
                    lstResolutionProfiles = (new ResolutionProfileBO()).GetAllObject().OrderBy(o => o.Name).ToList();

                    Session["ResolutionProfiles"] = lstResolutionProfiles;
                }
                return lstResolutionProfiles;
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

        protected void rptSizeQtyView_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objClientOrderDetailOrderQty = (OrderDetailQtyBO)item.DataItem;

                Literal litHeading = (Literal)item.FindControl("litHeading");
                litHeading.Text = objClientOrderDetailOrderQty.objSize.SizeName;

                //Literal litTotal = (Literal)item.FindControl("litTotal");
                //litTotal.Text = "Total";

                Label lblQty = (Label)item.FindControl("lblQty");
                lblQty.Text = objClientOrderDetailOrderQty.Qty.ToString();

                //Label lblTotal = (Label)item.FindControl("lblTotal");
                //int total = +objClientOrderDetailOrderQty.Qty;
                //lblTotal.Text = total.ToString();
            }
        }

        protected void RadGridOrders_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
            ViewState["PopulateOrderDetails"] = false;
        }

        protected void RadGridOrders_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
            ViewState["PopulateOrderDetails"] = false;
        }

        protected void RadGridOrders_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
            ViewState["PopulateOrderDetails"] = false;
        }

        protected void RadGridOrders_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is OrdersView)
                {
                    OrdersView objOrderDetailsView = (OrdersView)item.DataItem;

                    HyperLink lnkPONumber = (HyperLink)item.FindControl("lnkPONumber");
                    lnkPONumber.Text = objOrderDetailsView.Order;

                    int index = objOrderDetailsView.Order.IndexOf("-");
                    string orderID = objOrderDetailsView.Order.Substring(0, index);                    
                    lnkPONumber.NavigateUrl = "AddEditOrder.aspx?id=" + orderID;

                    CheckBox chkGenerateLabel = (CheckBox)item.FindControl("chkGenerateLabel");
                    //chkGenerateLabel.Enabled = (objOrderDetailsView.OrderDetailStatusID == (int)OrderDetailStatusBO.ODStatus.PreShipped || objOrderDetailsView.OrderDetailStatusID == (int)OrderDetailStatusBO.ODStatus.ODSPrinted || objOrderDetailsView.OrderDetailStatusID == (int)OrderDetailStatusBO.ODStatus.OnHold) ? true : false;
                    chkGenerateLabel.Attributes.Add("order", orderID);
                    chkGenerateLabel.Attributes.Add("status", objOrderDetailsView.OrderStatusID.ToString());
                    chkGenerateLabel.Attributes.Add("class", "iCheck");

                    HyperLink linkVL = (HyperLink)item.FindControl("linkVL");
                    linkVL.NavigateUrl = "AddEditVisualLayout.aspx?id=" + objOrderDetailsView.VisualLayoutID;
                    linkVL.Text = objOrderDetailsView.VisualLayout;

                    CheckBox chkIsAcceptedTC = (CheckBox)item.FindControl("chkIsAcceptedTC");
                    chkIsAcceptedTC.Checked = objOrderDetailsView.IsAcceptedTermsAndConditions ?? false;
                    chkIsAcceptedTC.Attributes.Add("qid", orderID);

                    TextBox txtScheduleDate = (TextBox)item.FindControl("txtScheduleDate");
                    txtScheduleDate.Text = (objOrderDetailsView.ShipmentDate != null) ? Convert.ToDateTime(objOrderDetailsView.ShipmentDate).ToString("MMM dd, yyyy") : DateTime.Now.ToString("MMM dd, yyyy");
                    txtScheduleDate.Attributes.Add("qid", objOrderDetailsView.OrderDetail.ToString());

                    LinkButton btnPrintMeasurements = (LinkButton)item.FindControl("btnPrintMeasurements");
                    btnPrintMeasurements.Attributes.Add("ODID", objOrderDetailsView.OrderDetail.ToString());

                    //HtmlAnchor ancNameNumberFile = (HtmlAnchor)item.FindControl("ancNameNumberFile");
                    HtmlGenericControl iNameNumberFile = (HtmlGenericControl)item.FindControl("iNameNumberFile");

                    string NNFilePath = GetNameNumberFilePath((int)objOrderDetailsView.OrderDetail);
                    //iNameNumberFile.Attributes.Add("class", File.Exists(NNFilePath) ? string.Empty : "icon-remove");

                    HtmlAnchor ancDownloadNameAndNumberFile = (HtmlAnchor)item.FindControl("ancDownloadNameAndNumberFile");
                    if (File.Exists(NNFilePath))
                        ancDownloadNameAndNumberFile.Attributes.Add("downloadUrl", NNFilePath);
                    else
                        ancDownloadNameAndNumberFile.Visible = false;

                    UserRole loggedUserRole = this.LoggedUserRoleName;
                    bool isDirectSales = this.LoggedUser.IsDirectSalesPerson;
                    bool isDistributor = loggedUserRole == UserRole.DistributorAdministrator || loggedUserRole == UserRole.DistributorCoordinator;
                    bool isIndico = loggedUserRole == UserRole.IndicoAdministrator || loggedUserRole == UserRole.IndicoCoordinator;
                    bool isIndiman = loggedUserRole == UserRole.IndimanAdministrator || loggedUserRole == UserRole.IndimanCoordinator;
                    bool isFactory = loggedUserRole == UserRole.FactoryAdministrator || loggedUserRole == UserRole.FactoryCoordinator;

                    LinkButton btnPrintODS = (LinkButton)item.FindControl("btnPrintODS");
                    btnPrintODS.Attributes.Add("ODSID", objOrderDetailsView.OrderDetail.ToString());

                    Literal litOrderDetailStatus = (Literal)item.FindControl("litOrderDetailStatus");
                    DropDownList ddlOrderDetailStatus = (DropDownList)item.FindControl("ddlOrderDetailStatus");
                    if (isFactory)
                    {
                        ddlOrderDetailStatus.Attributes.Add("odid", objOrderDetailsView.OrderDetail.ToString());
                        ddlOrderDetailStatus.Items.Add(new ListItem("New", "0"));

                        foreach (OrderDetailStatusBO ods in OrderDetailsStatus)
                        {
                            ddlOrderDetailStatus.Items.Add(new ListItem(ods.Name, ods.ID.ToString()));
                        }

                        ddlOrderDetailStatus.Items.FindByValue(objOrderDetailsView.OrderDetailStatusID.ToString()).Selected = true;
                        ddlOrderDetailStatus.Visible = true;
                    }
                    else
                    {
                        litOrderDetailStatus.Text = "<span class=\"label label-" + objOrderDetailsView.OrderDetailStatus.ToLower().Replace(" ", string.Empty).Trim() + "\">" + objOrderDetailsView.OrderDetailStatus + "</span>";
                        litOrderDetailStatus.Visible = true;
                    }

                    HtmlAnchor ancMainImage = (HtmlAnchor)item.FindControl("ancMainImage");
                    HtmlGenericControl ivlmainimageView = (HtmlGenericControl)item.FindControl("ivlmainimageView");

                    ancMainImage.HRef = IndicoPage.GetVLImagePath((int)objOrderDetailsView.VisualLayoutID);

                    Literal lblStatus = (Literal)item.FindControl("lblStatus");
                    string orderStatus = string.Empty;

                    if (isDistributor
                        && (objOrderDetailsView.OrderStatusID > 22)
                        && (objOrderDetailsView.OrderStatusID < 31)
                        )
                    {
                        orderStatus = "In Progress";
                    }
                    else
                    {
                        orderStatus = objOrderDetailsView.OrderStatus;
                    }

                    Literal litOrderDetailValue = (Literal)item.FindControl("litOrderDetailValue");
                    litOrderDetailValue.Text = String.Format("{0:n}", objOrderDetailsView.EditedPrice);

                    LinkButton lnkQuantity = (LinkButton)item.FindControl("lnkQuantity");
                    lnkQuantity.Text = String.Format("{0:n0}", objOrderDetailsView.Quantity);
                    lnkQuantity.Enabled = false;
                    lnkQuantity.ToolTip = string.Empty;

                    OrderDetailQtyBO objOrderDetail = new OrderDetailQtyBO();
                    objOrderDetail.OrderDetail = (int)objOrderDetailsView.OrderDetail;
                    List<OrderDetailQtyBO> lstODQty = objOrderDetail.SearchObjects().Where(m => m.Qty > 0).ToList();
                    string toolTipText = string.Empty;
                    foreach (OrderDetailQtyBO objQty in lstODQty)
                    {
                        toolTipText += objQty.objSize.SizeName + "/" + objQty.Qty + ", ";
                    }
                    toolTipText = string.IsNullOrEmpty(toolTipText) ? string.Empty : toolTipText.Remove(toolTipText.Length - 2);
                    lnkQuantity.ToolTip = toolTipText;

                    string orderStatusClass = "\"label label-" + orderStatus.ToLower().Replace(" ", string.Empty).Trim();
                    //orderStatusClass = "\"btn-warning";                    
                    lblStatus.Text = " <span class=" + orderStatusClass + "\"> " + orderStatus + " </span>";

                    if (objOrderDetailsView.HasNotes)
                    {
                        e.Item.BackColor = Color.LightYellow;
                    }

                    HyperLink linkEditView = (HyperLink)item.FindControl("linkEditView");
                    linkEditView.NavigateUrl = "AddEditOrder.aspx?id=" + orderID;

                    var lbCreateNewFrom = (HyperLink)item.FindControl("lbCreateNewFrom");
                    if (isDirectSales || LoggedUserRoleName == UserRole.IndimanAdministrator || LoggedUserRoleName == UserRole.IndimanCoordinator)
                    {
                        lbCreateNewFrom.Visible = true;
                        lbCreateNewFrom.Attributes.Add("oddid", orderID);
                    }
                    else
                    {
                        lbCreateNewFrom.Visible = false;
                    }
                    lbCreateNewFrom.NavigateUrl = "CloneOrder.aspx?id=" + orderID;

                    LinkButton lbDownloadDistributorPO = (LinkButton)item.FindControl("lbDownloadDistributorPO");
                    lbDownloadDistributorPO.Attributes.Add("oddid", orderID);

                    var lbDownloadDistributorPofOrOffice = (LinkButton)item.FindControl("lbDownloadDistributorPOForOffice");
                    lbDownloadDistributorPofOrOffice.Attributes.Add("oddid", orderID);

                    LinkButton btnGenerateBatchLabel = (LinkButton)item.FindControl("btnGenerateBatchLabel");
                    btnGenerateBatchLabel.Attributes.Add("qid", orderID);
                    btnGenerateBatchLabel.Visible = (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator);

                    HyperLink lbSubmitOrder = (HyperLink)item.FindControl("lbSubmitOrder");
                    lbSubmitOrder.Attributes.Add("order", orderID);
                    lbSubmitOrder.Attributes.Add("status", objOrderDetailsView.OrderStatusID.ToString());

                    LinkButton btnSaveOrder = (LinkButton)item.FindControl("btnSaveOrder");
                    btnSaveOrder.Attributes.Add("qid", orderID);

                    LinkButton btnChangeStatus = (LinkButton)item.FindControl("btnChangeStatus");
                    btnChangeStatus.Attributes.Add("odid", objOrderDetailsView.OrderDetail.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", orderID);

                    HyperLink linkCancelledOrderDetail = (HyperLink)item.FindControl("linkCancelledOrderDetail");
                    linkCancelledOrderDetail.Attributes.Add("oddid", objOrderDetailsView.OrderDetail.ToString());

                    Label lblShippingAddress = (Label)item.FindControl("lblShippingAddress");
                    lblShippingAddress.Text = (objOrderDetailsView.WeeklyShipment) ? "Adelaide Warehouse" : objOrderDetailsView.DespatchTo;

                    OrderStatus currentStatus = this.GetOrderStatus(int.Parse(objOrderDetailsView.OrderStatusID.ToString()));

                    bool isEditEnable = (isDirectSales && currentStatus == OrderStatus.New) ||
                                           (!isDirectSales && isIndico && currentStatus == OrderStatus.DistributorSubmitted) ||
                                          (!isDirectSales && isIndiman && (currentStatus == OrderStatus.New || currentStatus == OrderStatus.DistributorSubmitted || currentStatus == OrderStatus.CoordinatorSubmitted)) ||
                                          (isFactory && currentStatus != OrderStatus.Completed);

                    linkEditView.Visible = lnkPONumber.Enabled = isEditEnable;
                    lbSubmitOrder.Visible = chkGenerateLabel.Visible = isEditEnable && !isFactory;
                    btnSaveOrder.Visible = isEditEnable;
                    linkDelete.Visible = isEditEnable;
                    btnChangeStatus.Visible = isEditEnable && isFactory;
                    linkCancelledOrderDetail.Visible = isEditEnable;

                    if (!string.IsNullOrEmpty(ancMainImage.HRef))
                    {
                        ancMainImage.Attributes.Add("class", "btn-link preview");
                        ivlmainimageView.Attributes.Add("class", "icon-eye-open");

                        List<float> lstVLImageDimensions = (new ImageProcess()).GetResizedImageDimension(960, 720, 420, 360);
                        if (lstVLImageDimensions.Count > 0)
                        {
                            ancMainImage.Attributes.Add("height", lstVLImageDimensions[0].ToString());
                            ancMainImage.Attributes.Add("width", lstVLImageDimensions[1].ToString());
                        }
                    }
                    else
                    {
                        ancMainImage.Title = "Visual Layout Image Not Available";
                        ivlmainimageView.Attributes.Add("class", "icon-eye-close");
                    }

                    DropDownList ddlResolutionProfile = (DropDownList)item.FindControl("ddlResolutionProfile");
                    ddlResolutionProfile.Items.Clear();
                    ddlResolutionProfile.Items.Add(new ListItem("Select a Resolution Profile", "0"));
                    foreach (ResolutionProfileBO res in ResolutionProfiles)
                    {
                        ddlResolutionProfile.Items.Add(new ListItem(res.Name, res.ID.ToString()));
                    }

                    ddlResolutionProfile.Items.FindByValue(objOrderDetailsView.ResolutionProfile.ToString()).Selected = true;

                    LinkButton btnCHangeResolution = (LinkButton)item.FindControl("btnCHangeResolution");
                    btnCHangeResolution.Visible = isFactory;
                    btnCHangeResolution.Attributes.Add("vid", objOrderDetailsView.VisualLayoutID.ToString());
                    if (objOrderDetailsView.FOCPenalty)
                    {
                        item.Cells[18].BackColor = Color.Red;
                        item.Cells[18].ForeColor = Color.White;
                        item.Cells[18].Font.Bold = true;
                        item.Cells[18].ToolTip = "This is a FOC Penalty Client";
                    }
                }
            }
            else if (e.Item is GridFilteringItem)
            {
                RadComboBox radComboOrderDetailStatus = (RadComboBox)e.Item.FindControl("radComboOrderDetailStatus");
                radComboOrderDetailStatus.DataSource = OrderDetailsStatus;
                radComboOrderDetailStatus.DataBind();
                radComboOrderDetailStatus.SelectedValue = (ViewState["OrderDetailStatus"] != null) ? ViewState["OrderDetailStatus"].ToString() : "0";

                RadComboBox radComboOrderStatus = (RadComboBox)e.Item.FindControl("radComboOrderStatus");
                radComboOrderStatus.DataSource = this.PopulateDataGridOrderStatus();
                radComboOrderStatus.DataBind();
                radComboOrderStatus.SelectedValue = this.ddlStatus.SelectedValue;
            }

        }

        protected void RadGridOrders_ItemCommand(object sender, GridCommandEventArgs e)
        {
            this.ReBindGrid();
            ViewState["PopulateOrderDetails"] = false;
        }

        protected void RadGridOrders_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            //this.ReBindGrid();
            //ViewState["PopulateOrderDetails"] = false;
        }

        protected void RadGridOrders_CustomAggregate(object sender, GridCustomAggregateEventArgs e)
        {
            switch (e.Column.UniqueName)
            {
                case "Pattern":
                    try
                    {
                        GridFooterItem footeritem = RadGridOrders.MasterTableView.GetItems(GridItemType.Footer)[0] as GridFooterItem;
                        int qty = int.Parse(footeritem.Cells[5].Text.Replace(",", ""));
                        decimal value = decimal.Parse(footeritem.Cells[6].Text.Replace("$", "").Replace(",", ""));

                        e.Result = "Avg Price for Piece : $" + String.Format("{0:n}", value / qty);
                    }
                    catch (Exception ex)
                    {

                    }
                    break;
                default:
                    break;
            }
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;

            this.PopulateDataGrid();
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;
            ViewState["OrderDetailStatus"] = 0;

            this.PopulateDataGrid();
        }

        protected void btnPrintODS_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                try
                {
                    string odsID = ((System.Web.UI.WebControls.WebControl)(sender)).Attributes["ODSID"].ToString();

                    OrderDetailBO obj = new OrderDetailBO();
                    obj.ID = int.Parse(odsID);
                    obj.GetObject();

                    string pdfFilePath = Common.GenerateOdsPdf.GenerateODSPDF(obj);

                    this.DownloadPDFFile(Server.MapPath(pdfFilePath));
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while printing ODS", ex);
                }
            }
        }

        protected void btnPrintMeasurements_Click(object sender, EventArgs e)
        {
            try
            {
                string odID = ((System.Web.UI.WebControls.WebControl)(sender)).Attributes["ODID"].ToString();

                OrderDetailBO obj = new OrderDetailBO();
                obj.ID = int.Parse(odID);
                obj.GetObject();

                string filePath = GenerateOdsPdf.GenerateMeasurementExcel(obj);

                FileInfo fileInfo = new FileInfo(filePath);
                string outputName = System.Text.RegularExpressions.Regex.Replace(fileInfo.Name, @"\W+", "_");
                outputName = System.Text.RegularExpressions.Regex.Replace(outputName, "_xlsx", ".xlsx");
                Response.ClearContent();
                Response.ClearHeaders();
                Response.AddHeader("Content-Type", "application/vnd.ms-excel");
                Response.AddHeader("Content-Disposition", string.Format("attachment; filename = {0}", outputName));
                Response.AddHeader("Content-Length", (fileInfo.Length).ToString("F0"));
                Response.TransmitFile(filePath);
                Response.Flush();
                Response.Close();
                Response.BufferOutput = true;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while creating measurement location excel in ViewOrders Page", ex);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int orderId = int.Parse(this.hdnSelectedID.Value);

            if (Page.IsValid)
            {
                try
                {
                    ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                    objReturnInt = OrderBO.DeleteOrder(orderId);
                    if (objReturnInt.RetVal == 0)
                    {
                        IndicoLogging.log.Error("btnDelete_Click : Error occured while Deleting the Price ViewOrders.aspx, SPC_DeleteOrder ");
                    }
                    // Populate active Orders
                    this.PopulateControls();

                }
                catch (Exception ex)
                {
                    // Log the error
                    IndicoLogging.log.Error("btnDelete_Click : Error occured while Deleting the Price ViewOrders.aspx", ex);
                }
            }
        }

        protected void linkButttonEditFactoryStatus_Click(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;

            if (this.IsNotRefresh)
            {
                int order = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["oddsid"].ToString());
                int orderdetailcount = 0;
                bool isStarted = false;
                OrderDetailBO objorderdetail = new OrderDetailBO();
                objorderdetail.Order = order;

                List<OrderDetailBO> lstOrderDetail = objorderdetail.SearchObjects().ToList();

                if (lstOrderDetail.Count > 0)
                {
                    this.dgFactoryOrderDetailStatus.DataSource = lstOrderDetail;
                    this.dgFactoryOrderDetailStatus.DataBind();
                    this.dgFactoryOrderDetailStatus.Visible = true;
                }


                foreach (OrderDetailBO item in lstOrderDetail)
                {
                    if (item.Status == 7)
                    {
                        orderdetailcount++;
                    }
                    if (item.Status != null && item.Status > 0)
                    {
                        isStarted = true;
                    }
                }

                this.dgFactoryOrderDetailStatus.Columns[1].Visible = false;
                this.dgFactoryOrderDetailStatus.Columns[3].Visible = false;
                this.btnSubmit.Visible = (lstOrderDetail.Count == orderdetailcount) ? false : true;
                this.btnFactoryHold.Visible = (isStarted || objorderdetail.objOrder.objStatus.Name == "Factory Hold") ? false : true;
                this.hdnOrderID.Value = lstOrderDetail[0].Order.ToString();
                ViewState["PopulateOrderDetailsStatus"] = true;
            }
            else
            {
                ViewState["PopulateOrderDetails"] = false;
                ViewState["PopulateWeeklyOrderDetails"] = false;
                ViewState["PopulateDepartmentDetails"] = false;
                ViewState["PopulateEditDepartmentDetails"] = false;
                ViewState["PopulateOrderDetailsStatus"] = false;
            }
        }

        protected void dgFactoryOrderDetailStatus_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailBO)
            {
                OrderDetailBO objOrderDetails = (OrderDetailBO)item.DataItem;

                Label lblOrderDetail = (Label)item.FindControl("lblOrderDetail");
                lblOrderDetail.Text = objOrderDetails.objVisualLayout.NamePrefix + objOrderDetails.objVisualLayout.NameSuffix;

                CheckBox chkOdsPrinted = (CheckBox)item.FindControl("chkOdsPrinted");
                CheckBox chkPrinting = (CheckBox)item.FindControl("chkPrinting");
                CheckBox chkHeatPress = (CheckBox)item.FindControl("chkHeatPress");
                CheckBox chkSewing = (CheckBox)item.FindControl("chkSewing");
                CheckBox chkFactoryPacking = (CheckBox)item.FindControl("chkFactoryPacking");
                CheckBox chkFactoryShipped = (CheckBox)item.FindControl("chkFactoryShipped");
                /*CheckBox chkFactoryCompleted = (CheckBox)item.FindControl("chkFactoryCompleted");*/
                Label lblCompleted = (Label)item.FindControl("lblCompleted");

                Repeater rptPrinted = (Repeater)item.FindControl("rptPrinted");
                Repeater rptPressed = (Repeater)item.FindControl("rptPressed");
                Repeater rptSewing = (Repeater)item.FindControl("rptSewing");
                Repeater rptPacked = (Repeater)item.FindControl("rptPacked");
                Repeater rptShipped = (Repeater)item.FindControl("rptShipped");

                List<OrderDetailQtyBO> lstOrderDetailQty = objOrderDetails.OrderDetailQtysWhereThisIsOrderDetail.ToList();
                List<FactoryOrderDetialBO> lstFactoryOrderDetailPrint = (new FactoryOrderDetialBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetails.ID && (o.OrderDetailStatus == 2 || o.OrderDetailStatus == 8)).ToList();


                if (lstFactoryOrderDetailPrint.Count > 0)
                {
                    rptPrinted.DataSource = lstFactoryOrderDetailPrint;
                }
                else
                {
                    rptPrinted.DataSource = lstOrderDetailQty;
                }
                rptPrinted.DataBind();

                List<FactoryOrderDetialBO> lstFactoryOrderDetailPressed = (new FactoryOrderDetialBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetails.ID && (o.OrderDetailStatus == 3 || o.OrderDetailStatus == 9)).ToList();

                if (lstFactoryOrderDetailPressed.Count > 0)
                {
                    rptPressed.DataSource = lstFactoryOrderDetailPressed;
                }
                else
                {
                    rptPressed.DataSource = lstOrderDetailQty;
                }
                rptPressed.DataBind();

                List<FactoryOrderDetialBO> lstFactoryOrderDetailSewing = (new FactoryOrderDetialBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetails.ID && (o.OrderDetailStatus == 4 || o.OrderDetailStatus == 10)).ToList();

                if (lstFactoryOrderDetailSewing.Count > 0)
                {
                    rptSewing.DataSource = lstFactoryOrderDetailSewing;
                }
                else
                {
                    rptSewing.DataSource = lstOrderDetailQty;
                }
                rptSewing.DataBind();

                List<FactoryOrderDetialBO> lstFactoryOrderDetailPacking = (new FactoryOrderDetialBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetails.ID && (o.OrderDetailStatus == 5 || o.OrderDetailStatus == 11)).ToList();

                if (lstFactoryOrderDetailPacking.Count > 0)
                {
                    rptPacked.DataSource = lstFactoryOrderDetailPacking;
                }
                else
                {
                    rptPacked.DataSource = lstOrderDetailQty;
                }
                rptPacked.DataBind();

                List<FactoryOrderDetialBO> lstFactoryOrderDetailShipped = (new FactoryOrderDetialBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetails.ID && (o.OrderDetailStatus == 6 || o.OrderDetailStatus == 12)).ToList();

                if (lstFactoryOrderDetailShipped.Count > 0)
                {
                    rptShipped.DataSource = lstFactoryOrderDetailShipped;
                }
                else
                {
                    rptShipped.DataSource = lstOrderDetailQty;
                }
                rptShipped.DataBind();

                #region Filter
                switch (objOrderDetails.Status.Value)
                {
                    case 0:
                        chkOdsPrinted.Enabled = true;
                        chkPrinting.Enabled = false;
                        chkPrinting.Enabled = false;
                        chkHeatPress.Enabled = false;
                        chkSewing.Enabled = false;
                        chkFactoryPacking.Enabled = false;
                        chkFactoryShipped.Enabled = false;
                        lblCompleted.Text = "No";
                        chkOdsPrinted.Attributes.Add("sid", "1");
                        break;
                    case 1:
                        chkOdsPrinted.Checked = true;
                        chkOdsPrinted.Enabled = false;
                        chkPrinting.Enabled = false;
                        chkPrinting.Checked = true;
                        chkHeatPress.Enabled = false;
                        chkSewing.Enabled = false;
                        chkFactoryPacking.Enabled = false;
                        chkFactoryShipped.Enabled = false;
                        lblCompleted.Text = "No";
                        break;
                    case 2:
                        chkOdsPrinted.Checked = true;
                        chkPrinting.Enabled = false;
                        chkPrinting.Checked = true;
                        chkHeatPress.Enabled = false;
                        chkSewing.Enabled = false;
                        chkFactoryPacking.Enabled = false;
                        chkFactoryShipped.Enabled = false;
                        lblCompleted.Text = "No";
                        break;
                    case 3:
                        chkOdsPrinted.Checked = true;
                        chkPrinting.Checked = true;
                        chkHeatPress.Enabled = false;
                        chkHeatPress.Checked = true;
                        chkSewing.Enabled = false;
                        chkFactoryPacking.Enabled = false;
                        chkFactoryShipped.Enabled = false;
                        lblCompleted.Text = "No";
                        break;
                    case 4:
                        chkOdsPrinted.Checked = true;
                        chkPrinting.Checked = true;
                        chkHeatPress.Checked = true;
                        chkSewing.Enabled = false;
                        chkSewing.Checked = true;
                        chkFactoryPacking.Enabled = false;
                        chkFactoryShipped.Enabled = false;
                        lblCompleted.Text = "No";
                        break;
                    case 5:
                        chkOdsPrinted.Checked = true;
                        chkPrinting.Checked = true;
                        chkHeatPress.Checked = true;
                        chkSewing.Checked = true;
                        chkFactoryPacking.Enabled = false;
                        chkFactoryPacking.Checked = true;
                        chkFactoryShipped.Enabled = false;
                        lblCompleted.Text = "No";
                        break;
                    case 6:
                        chkOdsPrinted.Checked = true;
                        chkPrinting.Checked = true;
                        chkHeatPress.Checked = true;
                        chkSewing.Checked = true;
                        chkFactoryPacking.Checked = true;
                        chkFactoryShipped.Enabled = false;
                        chkFactoryShipped.Checked = true;
                        lblCompleted.Text = "No";
                        break;
                    case 7:
                        chkFactoryShipped.Checked = true;
                        chkFactoryPacking.Checked = true;
                        chkSewing.Checked = true;
                        chkOdsPrinted.Checked = true;
                        chkPrinting.Checked = true;
                        chkHeatPress.Checked = true;
                        lblCompleted.Text = "Yes";
                        break;
                    case 8:
                        chkOdsPrinted.Checked = true;
                        chkPrinting.Checked = true;
                        chkHeatPress.Enabled = false;
                        chkHeatPress.Checked = true;
                        chkSewing.Enabled = false;
                        chkFactoryPacking.Enabled = false;
                        chkFactoryShipped.Enabled = false;
                        lblCompleted.Text = "No";
                        break;
                    case 9:
                        chkOdsPrinted.Checked = true;
                        chkPrinting.Checked = true;
                        chkHeatPress.Checked = true;
                        chkSewing.Enabled = false;
                        chkSewing.Checked = true;
                        chkFactoryPacking.Enabled = false;
                        chkFactoryShipped.Enabled = false;
                        lblCompleted.Text = "No";
                        break;
                    case 10:
                        chkOdsPrinted.Checked = true;
                        chkPrinting.Checked = true;
                        chkHeatPress.Checked = true;
                        chkSewing.Checked = true;
                        chkFactoryPacking.Enabled = false;
                        chkFactoryPacking.Checked = true;
                        chkFactoryShipped.Enabled = false;
                        lblCompleted.Text = "No";
                        break;
                    case 11:
                        chkOdsPrinted.Checked = true;
                        chkPrinting.Checked = true;
                        chkHeatPress.Checked = true;
                        chkSewing.Checked = true;
                        chkFactoryPacking.Checked = true;
                        chkFactoryShipped.Enabled = false;
                        chkFactoryShipped.Checked = true;
                        lblCompleted.Text = "No";
                        break;
                    case 12:
                        chkOdsPrinted.Checked = true;
                        chkPrinting.Checked = true;
                        chkHeatPress.Checked = true;
                        chkSewing.Checked = true;
                        chkFactoryPacking.Checked = true;
                        chkFactoryShipped.Checked = true;
                        lblCompleted.Text = "Yes";
                        break;
                }

                #endregion

                chkOdsPrinted.Attributes.Add("odetailid", objOrderDetails.ID.ToString());

            }
        }

        protected void rptPrinted_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objOrderDetailQty = (OrderDetailQtyBO)item.DataItem;

                Label lblPrintSize = (Label)item.FindControl("lblPrintSize");
                lblPrintSize.Text = objOrderDetailQty.objSize.SizeName;
                lblPrintSize.Attributes.Add("odid", objOrderDetailQty.OrderDetail.ToString());
                lblPrintSize.Attributes.Add("fid", "0");
                lblPrintSize.Attributes.Add("sid", objOrderDetailQty.Size.ToString());

                TextBox txtPrintStartedDate = (TextBox)item.FindControl("txtPrintStartedDate");
                txtPrintStartedDate.Text = DateTime.Now.ToString("MMM dd, yyyy");
                txtPrintStartedDate.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                TextBox txtPrintQty = (TextBox)item.FindControl("txtPrintQty");
                txtPrintQty.Text = "0";
                txtPrintQty.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;
                txtPrintQty.ToolTip = objOrderDetailQty.Qty.ToString();

                Label lblPrintTotalQty = (Label)item.FindControl("lblPrintTotalQty");
                lblPrintTotalQty.Text = "0" + "(" + objOrderDetailQty.Qty.ToString() + ") ";
                lblPrintTotalQty.Attributes.Add("tqty", objOrderDetailQty.Qty.ToString());
                lblPrintTotalQty.Attributes.Add("amount", "0");


            }
            else if (item.ItemIndex > -1 && item.DataItem is FactoryOrderDetialBO)
            {
                FactoryOrderDetialBO objFactoryOrderDetail = (FactoryOrderDetialBO)item.DataItem;
                bool isEnable = true;
                string totalqty = string.Empty;

                OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                objOrderDetailQty.OrderDetail = objFactoryOrderDetail.OrderDetail;
                foreach (OrderDetailQtyBO odq in objOrderDetailQty.SearchObjects())
                {
                    if (objFactoryOrderDetail.Size == odq.Size)
                    {
                        if (odq.Qty == 0)
                        {
                            isEnable = false;
                        }
                        totalqty = odq.Qty.ToString();
                    }
                }

                Label lblPrintSize = (Label)item.FindControl("lblPrintSize");
                lblPrintSize.Text = objFactoryOrderDetail.objSize.SizeName;
                lblPrintSize.Attributes.Add("odid", objFactoryOrderDetail.OrderDetail.ToString());
                lblPrintSize.Attributes.Add("fid", objFactoryOrderDetail.ID.ToString());
                lblPrintSize.Attributes.Add("sid", objFactoryOrderDetail.Size.ToString());

                TextBox txtPrintStartedDate = (TextBox)item.FindControl("txtPrintStartedDate");
                txtPrintStartedDate.Text = Convert.ToDateTime(objFactoryOrderDetail.StartedDate).ToString("MMM dd, yyyy");
                txtPrintStartedDate.Enabled = isEnable;

                TextBox txtPrintQty = (TextBox)item.FindControl("txtPrintQty");
                txtPrintQty.Text = objFactoryOrderDetail.CompletedQty.ToString();
                txtPrintQty.Enabled = isEnable;
                txtPrintQty.ToolTip = totalqty;


                Label lblPrintTotalQty = (Label)item.FindControl("lblPrintTotalQty");
                lblPrintTotalQty.Text = objFactoryOrderDetail.CompletedQty.ToString() + "(" + totalqty + ") ";
                lblPrintTotalQty.Attributes.Add("tqty", totalqty);
                lblPrintTotalQty.Attributes.Add("amount", objFactoryOrderDetail.CompletedQty.ToString());

            }
        }

        protected void rptPressed_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objOrderDetailQty = (OrderDetailQtyBO)item.DataItem;

                Label lblPressedSize = (Label)item.FindControl("lblPressedSize");
                lblPressedSize.Text = objOrderDetailQty.objSize.SizeName;
                lblPressedSize.Attributes.Add("odid", objOrderDetailQty.OrderDetail.ToString());
                lblPressedSize.Attributes.Add("fid", "0");
                lblPressedSize.Attributes.Add("sid", objOrderDetailQty.Size.ToString());


                TextBox txtPressedStartedDate = (TextBox)item.FindControl("txtPressedStartedDate");
                txtPressedStartedDate.Text = DateTime.Now.ToString("MMM dd, yyyy");
                txtPressedStartedDate.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                TextBox txtPressedQty = (TextBox)item.FindControl("txtPressedQty");
                txtPressedQty.Text = "0";
                txtPressedQty.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                Label lblPressedTotalQty = (Label)item.FindControl("lblPressedTotalQty");
                lblPressedTotalQty.Text = "0" + "(" + objOrderDetailQty.Qty.ToString() + ") ";
                lblPressedTotalQty.Attributes.Add("tqty", objOrderDetailQty.Qty.ToString());
                lblPressedTotalQty.Attributes.Add("amount", "0");
            }
            else if (item.ItemIndex > -1 && item.DataItem is FactoryOrderDetialBO)
            {
                FactoryOrderDetialBO objFactoryOrderDetail = (FactoryOrderDetialBO)item.DataItem;
                bool isEnable = true;
                string totalQty = string.Empty;

                OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                objOrderDetailQty.OrderDetail = objFactoryOrderDetail.OrderDetail;

                foreach (OrderDetailQtyBO odq in objOrderDetailQty.SearchObjects())
                {
                    if (objFactoryOrderDetail.Size == odq.Size)
                    {
                        if (odq.Qty == 0)
                        {
                            isEnable = false;
                        }
                        totalQty = odq.Qty.ToString();
                    }
                }

                Label lblPressedSize = (Label)item.FindControl("lblPressedSize");
                lblPressedSize.Text = objFactoryOrderDetail.objSize.SizeName;
                lblPressedSize.Attributes.Add("odid", objFactoryOrderDetail.OrderDetail.ToString());
                lblPressedSize.Attributes.Add("fid", objFactoryOrderDetail.ID.ToString());
                lblPressedSize.Attributes.Add("sid", objFactoryOrderDetail.Size.ToString());

                TextBox txtPressedStartedDate = (TextBox)item.FindControl("txtPressedStartedDate");
                txtPressedStartedDate.Text = Convert.ToDateTime(objFactoryOrderDetail.StartedDate).ToString("MMM dd, yyyy");
                txtPressedStartedDate.Enabled = isEnable;

                TextBox txtPressedQty = (TextBox)item.FindControl("txtPressedQty");
                txtPressedQty.Text = objFactoryOrderDetail.CompletedQty.ToString();
                txtPressedQty.Enabled = isEnable;

                Label lblPressedTotalQty = (Label)item.FindControl("lblPressedTotalQty");
                lblPressedTotalQty.Text = objFactoryOrderDetail.CompletedQty.ToString() + "(" + totalQty + ") ";
                lblPressedTotalQty.Attributes.Add("tqty", totalQty);
                lblPressedTotalQty.Attributes.Add("amount", objFactoryOrderDetail.CompletedQty.ToString());
            }
        }

        protected void rptSewing_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objOrderDetailQty = (OrderDetailQtyBO)item.DataItem;

                Label lblSewingSize = (Label)item.FindControl("lblSewingSize");
                lblSewingSize.Text = objOrderDetailQty.objSize.SizeName;
                lblSewingSize.Attributes.Add("odid", objOrderDetailQty.OrderDetail.ToString());
                lblSewingSize.Attributes.Add("fid", "0");
                lblSewingSize.Attributes.Add("sid", objOrderDetailQty.Size.ToString());

                TextBox txtSewingStartedDate = (TextBox)item.FindControl("txtSewingStartedDate");
                txtSewingStartedDate.Text = DateTime.Now.ToString("MMM dd, yyyy");
                txtSewingStartedDate.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                TextBox txtSewingQty = (TextBox)item.FindControl("txtSewingQty");
                txtSewingQty.Text = "0";
                txtSewingQty.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                Label lblSewingTotalQty = (Label)item.FindControl("lblSewingTotalQty");
                lblSewingTotalQty.Text = "0" + "(" + objOrderDetailQty.Qty.ToString() + ") ";
                lblSewingTotalQty.Attributes.Add("tqty", objOrderDetailQty.Qty.ToString());
                lblSewingTotalQty.Attributes.Add("tqty", objOrderDetailQty.Qty.ToString());
                lblSewingTotalQty.Attributes.Add("amount", "0");

            }
            else if (item.ItemIndex > -1 && item.DataItem is FactoryOrderDetialBO)
            {
                FactoryOrderDetialBO objFactoryOrderDetail = (FactoryOrderDetialBO)item.DataItem;
                bool isEnable = true;
                string totalQty = string.Empty;

                OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                objOrderDetailQty.OrderDetail = objFactoryOrderDetail.OrderDetail;

                foreach (OrderDetailQtyBO odq in objOrderDetailQty.SearchObjects())
                {
                    if (objFactoryOrderDetail.Size == odq.Size)
                    {
                        if (odq.Qty == 0)
                        {
                            isEnable = false;
                        }
                        totalQty = odq.Qty.ToString();
                    }
                }

                Label lblSewingSize = (Label)item.FindControl("lblSewingSize");
                lblSewingSize.Text = objFactoryOrderDetail.objSize.SizeName;
                lblSewingSize.Attributes.Add("odid", objFactoryOrderDetail.OrderDetail.ToString());
                lblSewingSize.Attributes.Add("fid", objFactoryOrderDetail.ID.ToString());
                lblSewingSize.Attributes.Add("sid", objFactoryOrderDetail.Size.ToString());

                TextBox txtSewingStartedDate = (TextBox)item.FindControl("txtSewingStartedDate");
                txtSewingStartedDate.Text = Convert.ToDateTime(objFactoryOrderDetail.StartedDate).ToString("MMM dd, yyyy");
                txtSewingStartedDate.Enabled = isEnable;

                TextBox txtSewingQty = (TextBox)item.FindControl("txtSewingQty");
                txtSewingQty.Text = objFactoryOrderDetail.CompletedQty.ToString();
                txtSewingQty.Enabled = isEnable;

                Label lblSewingTotalQty = (Label)item.FindControl("lblSewingTotalQty");
                lblSewingTotalQty.Text = objFactoryOrderDetail.CompletedQty.ToString() + "(" + totalQty + ") ";
                lblSewingTotalQty.Attributes.Add("tqty", totalQty);
                lblSewingTotalQty.Attributes.Add("amount", objFactoryOrderDetail.CompletedQty.ToString());
            }
        }

        protected void rptPacked_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objOrderDetailQty = (OrderDetailQtyBO)item.DataItem;

                Label lblPackedSize = (Label)item.FindControl("lblPackedSize");
                lblPackedSize.Text = objOrderDetailQty.objSize.SizeName;
                lblPackedSize.Attributes.Add("odid", objOrderDetailQty.OrderDetail.ToString());
                lblPackedSize.Attributes.Add("fid", "0");
                lblPackedSize.Attributes.Add("sid", objOrderDetailQty.Size.ToString());

                TextBox txtPackedStartedDate = (TextBox)item.FindControl("txtPackedStartedDate");
                txtPackedStartedDate.Text = DateTime.Now.ToString("MMM dd, yyyy");
                txtPackedStartedDate.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                TextBox txtPackedQty = (TextBox)item.FindControl("txtPackedQty");
                txtPackedQty.Text = "0";
                txtPackedQty.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                Label lblPackingTotal = (Label)item.FindControl("lblPackingTotal");
                lblPackingTotal.Text = "0" + "(" + objOrderDetailQty.Qty.ToString() + ") ";
                lblPackingTotal.Attributes.Add("tqty", objOrderDetailQty.Qty.ToString());
                lblPackingTotal.Attributes.Add("amount", "0");

            }
            else if (item.ItemIndex > -1 && item.DataItem is FactoryOrderDetialBO)
            {
                FactoryOrderDetialBO objFactoryOrderDetail = (FactoryOrderDetialBO)item.DataItem;
                bool isEnable = true;
                string totalQty = string.Empty;

                OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                objOrderDetailQty.OrderDetail = objFactoryOrderDetail.OrderDetail;

                foreach (OrderDetailQtyBO odq in objOrderDetailQty.SearchObjects())
                {
                    if (objFactoryOrderDetail.Size == odq.Size)
                    {
                        if (odq.Qty == 0)
                        {
                            isEnable = false;
                        }

                        totalQty = odq.Qty.ToString();
                    }
                }

                Label lblPackedSize = (Label)item.FindControl("lblPackedSize");
                lblPackedSize.Text = objFactoryOrderDetail.objSize.SizeName;
                lblPackedSize.Attributes.Add("odid", objFactoryOrderDetail.OrderDetail.ToString());
                lblPackedSize.Attributes.Add("fid", objFactoryOrderDetail.ID.ToString());
                lblPackedSize.Attributes.Add("sid", objFactoryOrderDetail.Size.ToString());


                TextBox txtPackedStartedDate = (TextBox)item.FindControl("txtPackedStartedDate");
                txtPackedStartedDate.Text = Convert.ToDateTime(objFactoryOrderDetail.StartedDate).ToString("MMM dd, yyyy");
                txtPackedStartedDate.Enabled = isEnable;

                TextBox txtPackedQty = (TextBox)item.FindControl("txtPackedQty");
                txtPackedQty.Text = objFactoryOrderDetail.CompletedQty.ToString();
                txtPackedQty.Enabled = isEnable;

                Label lblPackingTotal = (Label)item.FindControl("lblPackingTotal");
                lblPackingTotal.Text = objFactoryOrderDetail.CompletedQty.ToString() + "(" + totalQty + ") ";
                lblPackingTotal.Attributes.Add("tqty", totalQty);
                lblPackingTotal.Attributes.Add("amount", objFactoryOrderDetail.CompletedQty.ToString());

            }
        }

        protected void rptShipped_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objOrderDetailQty = (OrderDetailQtyBO)item.DataItem;

                Label lblShippedSize = (Label)item.FindControl("lblShippedSize");
                lblShippedSize.Text = objOrderDetailQty.objSize.SizeName;
                lblShippedSize.Attributes.Add("odid", objOrderDetailQty.OrderDetail.ToString());
                lblShippedSize.Attributes.Add("fid", "0");
                lblShippedSize.Attributes.Add("sid", objOrderDetailQty.Size.ToString());

                TextBox txtShippedStartedDate = (TextBox)item.FindControl("txtShippedStartedDate");
                txtShippedStartedDate.Text = DateTime.Now.ToString("MMM dd, yyyy");
                txtShippedStartedDate.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                TextBox txtShippedQty = (TextBox)item.FindControl("txtShippedQty");
                txtShippedQty.Text = "0";
                txtShippedQty.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                Label lblShippedTotal = (Label)item.FindControl("lblShippedTotal");
                lblShippedTotal.Text = "0" + "(" + objOrderDetailQty.Qty.ToString() + ") ";
                lblShippedTotal.Attributes.Add("tqty", objOrderDetailQty.Qty.ToString());
                lblShippedTotal.Attributes.Add("amount", "0");

            }
            else if (item.ItemIndex > -1 && item.DataItem is FactoryOrderDetialBO)
            {
                FactoryOrderDetialBO objFactoryOrderDetail = (FactoryOrderDetialBO)item.DataItem;
                bool isEnable = true;
                string totalQty = string.Empty;

                OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                objOrderDetailQty.OrderDetail = objFactoryOrderDetail.OrderDetail;

                foreach (OrderDetailQtyBO odq in objOrderDetailQty.SearchObjects())
                {
                    if (objFactoryOrderDetail.Size == odq.Size)
                    {
                        if (odq.Qty == 0)
                        {
                            isEnable = false;
                        }

                        totalQty = odq.Qty.ToString();
                    }
                }

                Label lblShippedSize = (Label)item.FindControl("lblShippedSize");
                lblShippedSize.Text = objFactoryOrderDetail.objSize.SizeName;
                lblShippedSize.Attributes.Add("odid", objFactoryOrderDetail.OrderDetail.ToString());
                lblShippedSize.Attributes.Add("fid", objFactoryOrderDetail.ID.ToString());
                lblShippedSize.Attributes.Add("sid", objFactoryOrderDetail.Size.ToString());

                TextBox txtShippedStartedDate = (TextBox)item.FindControl("txtShippedStartedDate");
                txtShippedStartedDate.Text = Convert.ToDateTime(objFactoryOrderDetail.StartedDate).ToString("MMM dd, yyyy");
                txtShippedStartedDate.Enabled = isEnable;

                TextBox txtShippedQty = (TextBox)item.FindControl("txtShippedQty");
                txtShippedQty.Text = objFactoryOrderDetail.CompletedQty.ToString();
                txtShippedQty.Enabled = isEnable;

                Label lblShippedTotal = (Label)item.FindControl("lblShippedTotal");
                lblShippedTotal.Text = objFactoryOrderDetail.CompletedQty.ToString() + "(" + totalQty + ") ";
                lblShippedTotal.Attributes.Add("tqty", totalQty);
                lblShippedTotal.Attributes.Add("amount", objFactoryOrderDetail.CompletedQty.ToString());
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;

            int facid = 0;
            int odid = 0;
            int sizeid = 0;
            int odstatusid = 0;
            string date = string.Empty;
            int qty = 0;
            int orderdetail = 0;
            int totalQTY = 0;
            int amount = 0;
            int total = 0;
            //bool iscount = false;btnSubmitOrder_Click

            if (this.IsNotRefresh)
            {
                try
                {
                    foreach (DataGridItem item in dgFactoryOrderDetailStatus.Items)
                    {
                        #region ODSPrinted

                        CheckBox chkOdsPrinted = (CheckBox)item.FindControl("chkOdsPrinted");
                        orderdetail = int.Parse(((System.Web.UI.WebControls.WebControl)(chkOdsPrinted)).Attributes["odetailid"].ToString());


                        if (chkOdsPrinted.Checked == true && chkOdsPrinted.Enabled == true /*&& ischeck == false*/)
                        {
                            odstatusid = int.Parse(((System.Web.UI.WebControls.WebControl)(chkOdsPrinted)).Attributes["sid"].ToString());
                            using (TransactionScope ts = new TransactionScope())
                            {
                                OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                objOrderDetail.ID = orderdetail;
                                objOrderDetail.GetObject();

                                objOrderDetail.Status = odstatusid;

                                this.ObjContext.SaveChanges();
                                ts.Complete();
                            }
                        }

                        #endregion

                        #region Printing

                        CheckBox chkPrinting = (CheckBox)item.FindControl("chkPrinting");


                        if (chkPrinting.Enabled == false && chkPrinting.Checked == true)
                        {
                            bool completed = false;
                            amount = 0;
                            totalQTY = 0;
                            List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 2 || o.OrderDetailStatus == 8)).ToList();

                            foreach (FactoryOrderDetialBO fod in lst)
                            {
                                totalQTY = totalQTY + (int)fod.CompletedQty;
                            }

                            Repeater rptPrinted = (Repeater)item.FindControl("rptPrinted");
                            foreach (RepeaterItem rpitem in rptPrinted.Items)
                            {

                                Label lblPrintSize = (Label)rpitem.FindControl("lblPrintSize");
                                facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblPrintSize)).Attributes["fid"].ToString());
                                odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblPrintSize)).Attributes["odid"].ToString());
                                sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblPrintSize)).Attributes["sid"].ToString());

                                Label lblPrintTotalQty = (Label)rpitem.FindControl("lblPrintTotalQty");
                                total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblPrintTotalQty)).Attributes["tqty"].ToString());

                                TextBox txtPrintStartedDate = (TextBox)rpitem.FindControl("txtPrintStartedDate");
                                date = txtPrintStartedDate.Text;

                                TextBox txtPrintQty = (TextBox)rpitem.FindControl("txtPrintQty");
                                qty = int.Parse(txtPrintQty.Text);

                                if (facid > 0)
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                    objFactoryOrderDetail.ID = facid;
                                    objFactoryOrderDetail.GetObject();

                                    if (total != qty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                    else if (qty > objFactoryOrderDetail.CompletedQty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                }
                                else
                                {
                                    totalQTY = totalQTY + qty;
                                }

                                OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                objOrderDetailqty.OrderDetail = odid;

                                if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                {
                                    completed = true;
                                    odstatusid = 8;
                                }
                                else
                                {
                                    odstatusid = 2;
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);
                                    if (facid > 0)
                                    {
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();
                                        amount = (int)objFactoryOrderDetail.CompletedQty;

                                    }

                                    objFactoryOrderDetail.OrderDetail = odid;
                                    objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                    objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                    objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                    objFactoryOrderDetail.Size = sizeid;

                                    this.ObjContext.SaveChanges();

                                    ts.Complete();
                                }
                            }

                            using (TransactionScope ts = new TransactionScope())
                            {
                                OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                objOrderDetail.ID = odid;
                                objOrderDetail.GetObject();

                                objOrderDetail.Status = (completed == true) ? 8 : 2;

                                this.ObjContext.SaveChanges();
                                ts.Complete();
                            }
                        }

                        #endregion

                        #region HeatPress

                        CheckBox chkHeatPress = (CheckBox)item.FindControl("chkHeatPress");


                        if (chkHeatPress.Enabled == false && chkHeatPress.Checked == true)
                        {
                            bool completed = false;
                            amount = 0;
                            totalQTY = 0;
                            List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 3 || o.OrderDetailStatus == 9)).ToList();

                            foreach (FactoryOrderDetialBO fod in lst)
                            {
                                totalQTY = totalQTY + (int)fod.CompletedQty;
                            }

                            Repeater rptPressed = (Repeater)item.FindControl("rptPressed");
                            foreach (RepeaterItem rpritem in rptPressed.Items)
                            {
                                Label lblPressedSize = (Label)rpritem.FindControl("lblPressedSize");
                                facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblPressedSize)).Attributes["fid"].ToString());
                                odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblPressedSize)).Attributes["odid"].ToString());
                                sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblPressedSize)).Attributes["sid"].ToString());

                                Label lblPressedTotalQty = (Label)rpritem.FindControl("lblPressedTotalQty");
                                total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblPressedTotalQty)).Attributes["tqty"].ToString());

                                TextBox txtPressedStartedDate = (TextBox)rpritem.FindControl("txtPressedStartedDate");
                                date = txtPressedStartedDate.Text;

                                TextBox txtPressedQty = (TextBox)rpritem.FindControl("txtPressedQty");
                                qty = int.Parse(txtPressedQty.Text);

                                if (facid > 0)
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                    objFactoryOrderDetail.ID = facid;
                                    objFactoryOrderDetail.GetObject();

                                    if (total != qty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                    else if (qty > objFactoryOrderDetail.CompletedQty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                }
                                else
                                {
                                    totalQTY = totalQTY + qty;
                                }

                                OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                objOrderDetailqty.OrderDetail = odid;

                                if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                {
                                    completed = true;
                                    odstatusid = 9;
                                }
                                else
                                {
                                    odstatusid = 3;
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);

                                    if (facid > 0)
                                    {
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();
                                        amount = (int)objFactoryOrderDetail.CompletedQty;
                                    }

                                    objFactoryOrderDetail.OrderDetail = odid;
                                    objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                    objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                    objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                    objFactoryOrderDetail.Size = sizeid;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }
                            }
                            using (TransactionScope ts = new TransactionScope())
                            {
                                OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                objOrderDetail.ID = odid;
                                objOrderDetail.GetObject();

                                objOrderDetail.Status = (completed == true) ? 9 : 3;

                                this.ObjContext.SaveChanges();
                                ts.Complete();
                            }
                        }

                        #endregion

                        #region Sewing

                        CheckBox chkSewing = (CheckBox)item.FindControl("chkSewing");

                        if (chkSewing.Enabled == false && chkSewing.Checked == true)
                        {
                            bool completed = false;
                            amount = 0;
                            totalQTY = 0;
                            List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 4 || o.OrderDetailStatus == 10)).ToList();

                            foreach (FactoryOrderDetialBO fod in lst)
                            {
                                totalQTY = totalQTY + (int)fod.CompletedQty;
                            }

                            Repeater rptSewing = (Repeater)item.FindControl("rptSewing");
                            foreach (RepeaterItem rsitem in rptSewing.Items)
                            {
                                Label lblSewingSize = (Label)rsitem.FindControl("lblSewingSize");
                                facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblSewingSize)).Attributes["fid"].ToString());
                                odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblSewingSize)).Attributes["odid"].ToString());
                                sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblSewingSize)).Attributes["sid"].ToString());

                                Label lblSewingTotalQty = (Label)rsitem.FindControl("lblSewingTotalQty");
                                total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblSewingTotalQty)).Attributes["tqty"].ToString());

                                TextBox txtSewingStartedDate = (TextBox)rsitem.FindControl("txtSewingStartedDate");
                                date = txtSewingStartedDate.Text;

                                TextBox txtSewingQty = (TextBox)rsitem.FindControl("txtSewingQty");
                                qty = int.Parse(txtSewingQty.Text);

                                if (facid > 0)
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                    objFactoryOrderDetail.ID = facid;
                                    objFactoryOrderDetail.GetObject();

                                    if (total != qty)
                                    {
                                        totalQTY = totalQTY + qty;

                                    }
                                    else if (qty > objFactoryOrderDetail.CompletedQty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                }
                                else
                                {
                                    totalQTY = totalQTY + qty;
                                }

                                OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                objOrderDetailqty.OrderDetail = odid;

                                if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                {
                                    completed = true;
                                    odstatusid = 10;
                                }
                                else
                                {
                                    odstatusid = 4;
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);
                                    if (facid > 0)
                                    {
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();
                                        amount = (int)objFactoryOrderDetail.CompletedQty;
                                    }

                                    objFactoryOrderDetail.OrderDetail = odid;
                                    objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                    objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                    objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                    objFactoryOrderDetail.Size = sizeid;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }
                            }

                            using (TransactionScope ts = new TransactionScope())
                            {
                                OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                objOrderDetail.ID = odid;
                                objOrderDetail.GetObject();

                                objOrderDetail.Status = (completed == true) ? 10 : 4;

                                this.ObjContext.SaveChanges();
                                ts.Complete();
                            }
                        }

                        #endregion

                        #region Packing

                        CheckBox chkFactoryPacking = (CheckBox)item.FindControl("chkFactoryPacking");


                        if (chkFactoryPacking.Enabled == false && chkFactoryPacking.Checked == true)
                        {
                            bool completed = false;
                            amount = 0;
                            totalQTY = 0;
                            List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 5 || o.OrderDetailStatus == 11)).ToList();

                            foreach (FactoryOrderDetialBO fod in lst)
                            {
                                totalQTY = totalQTY + (int)fod.CompletedQty;
                            }

                            Repeater rptPacked = (Repeater)item.FindControl("rptPacked");
                            foreach (RepeaterItem rpaitem in rptPacked.Items)
                            {
                                Label lblPackedSize = (Label)rpaitem.FindControl("lblPackedSize");
                                facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblPackedSize)).Attributes["fid"].ToString());
                                odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblPackedSize)).Attributes["odid"].ToString());
                                sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblPackedSize)).Attributes["sid"].ToString());

                                Label lblPackingTotal = (Label)rpaitem.FindControl("lblPackingTotal");
                                total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblPackingTotal)).Attributes["tqty"].ToString());

                                TextBox txtPackedStartedDate = (TextBox)rpaitem.FindControl("txtPackedStartedDate");
                                date = txtPackedStartedDate.Text;

                                TextBox txtPackedQty = (TextBox)rpaitem.FindControl("txtPackedQty");
                                qty = int.Parse(txtPackedQty.Text);

                                if (facid > 0)
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                    objFactoryOrderDetail.ID = facid;
                                    objFactoryOrderDetail.GetObject();

                                    if (total != qty)
                                    {
                                        totalQTY = totalQTY + qty;

                                    }
                                    else if (qty > objFactoryOrderDetail.CompletedQty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                }
                                else
                                {
                                    totalQTY = totalQTY + qty;
                                }

                                OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                objOrderDetailqty.OrderDetail = odid;

                                if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                {
                                    completed = true;
                                    odstatusid = 11;
                                }
                                else
                                {
                                    odstatusid = 5;
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);

                                    if (facid > 0)
                                    {
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();
                                        amount = (int)objFactoryOrderDetail.CompletedQty;
                                    }

                                    objFactoryOrderDetail.OrderDetail = odid;
                                    objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                    objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                    objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                    objFactoryOrderDetail.Size = sizeid;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }
                            }

                            using (TransactionScope ts = new TransactionScope())
                            {
                                OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                objOrderDetail.ID = odid;
                                objOrderDetail.GetObject();

                                objOrderDetail.Status = (completed == true) ? 11 : 5;

                                this.ObjContext.SaveChanges();
                                ts.Complete();
                            }
                        }

                        #endregion

                        #region Shipped

                        CheckBox chkFactoryShipped = (CheckBox)item.FindControl("chkFactoryShipped");

                        if (chkFactoryShipped.Enabled == false && chkFactoryShipped.Checked == true)
                        {
                            bool completed = false;
                            amount = 0;
                            totalQTY = 0;
                            List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 6 || o.OrderDetailStatus == 12)).ToList();

                            foreach (FactoryOrderDetialBO fod in lst)
                            {
                                totalQTY = totalQTY + (int)fod.CompletedQty;
                            }

                            Repeater rptShipped = (Repeater)item.FindControl("rptShipped");
                            foreach (RepeaterItem rsitem in rptShipped.Items)
                            {
                                Label lblShippedSize = (Label)rsitem.FindControl("lblShippedSize");
                                facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblShippedSize)).Attributes["fid"].ToString());
                                odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblShippedSize)).Attributes["odid"].ToString());
                                sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblShippedSize)).Attributes["sid"].ToString());

                                Label lblShippedTotal = (Label)rsitem.FindControl("lblShippedTotal");
                                total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblShippedTotal)).Attributes["tqty"].ToString());

                                TextBox txtShippedStartedDate = (TextBox)rsitem.FindControl("txtShippedStartedDate");
                                date = txtShippedStartedDate.Text;

                                TextBox txtShippedQty = (TextBox)rsitem.FindControl("txtShippedQty");
                                qty = int.Parse(txtShippedQty.Text);

                                if (facid > 0)
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                    objFactoryOrderDetail.ID = facid;
                                    objFactoryOrderDetail.GetObject();

                                    if (total != qty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                    else if (qty > objFactoryOrderDetail.CompletedQty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                }
                                else
                                {
                                    totalQTY = totalQTY + qty;
                                }

                                OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                objOrderDetailqty.OrderDetail = odid;

                                if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                {
                                    completed = true;
                                    odstatusid = 12;
                                }
                                else
                                {
                                    odstatusid = 6;
                                }

                                if (odstatusid == 12)
                                {
                                    completed = true;
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);

                                    if (facid > 0)
                                    {
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();
                                        amount = (int)objFactoryOrderDetail.CompletedQty;
                                    }

                                    objFactoryOrderDetail.OrderDetail = odid;
                                    objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                    objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                    objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                    objFactoryOrderDetail.Size = sizeid;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }
                            }

                            using (TransactionScope ts = new TransactionScope())
                            {
                                OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                objOrderDetail.ID = odid;
                                objOrderDetail.GetObject();

                                objOrderDetail.Status = (completed == true) ? 7 : 6;

                                this.ObjContext.SaveChanges();

                                ts.Complete();
                            }
                        }
                        #endregion

                        this.SetOrderStatus(orderdetail);
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while saving order detail status in ViewOrders page", ex);
                }
            }

            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;

            this.PopulateControls();
        }

        protected void btnFactoryHold_OnClick(object sender, EventArgs e)
        {
            int OrderId = int.Parse(hdnOrderID.Value);
            if (this.IsNotRefresh)
            {
                if (OrderId > 0)
                {
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            OrderBO objOrder = new OrderBO(this.ObjContext);
                            objOrder.ID = OrderId;
                            objOrder.GetObject();

                            objOrder.Status = 27;

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while saving factory hold status", ex);
                    }

                }
                ViewState["PopulateOrderDetailsStatus"] = false;
                ViewState["PopulateWeeklyOrderDetails"] = false;
                ViewState["PopulateDepartmentDetails"] = false;
                this.PopulateControls();
            }
        }

        protected void rptWeeklyOrders_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is OrderBO)
            {
                OrderBO objOrder = (OrderBO)item.DataItem;

                List<OrderDetailBO> lstOrderDetails = objOrder.OrderDetailsWhereThisIsOrder;

                if (lstOrderDetails.Count > 0)
                {
                    HtmlGenericControl h3WeeklyOrders = (HtmlGenericControl)item.FindControl("h3WeeklyOrders");
                    h3WeeklyOrders.InnerHtml = "Order Number: " + objOrder.ID.ToString();
                    h3WeeklyOrders.Visible = true;

                    HtmlGenericControl lbldistributorClient = (HtmlGenericControl)item.FindControl("lbldistributorClient");
                    lbldistributorClient.InnerHtml = "Distributor: " + objOrder.objDistributor.Name + "    Client: " + objOrder.objClient.Name;
                    lbldistributorClient.Visible = true;

                    DataGrid dgWeeklyOrderDetails = (DataGrid)item.FindControl("dgWeeklyOrderDetails");
                    dgWeeklyOrderDetails.DataSource = lstOrderDetails;
                    dgWeeklyOrderDetails.DataBind();
                    dgWeeklyOrderDetails.Attributes.Add("odid", objOrder.ID.ToString());
                }

            }
        }

        protected void dgWeeklyOrderDetails_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailBO)
            {
                OrderDetailBO objOrderDetails = (OrderDetailBO)item.DataItem;

                Label lblWeeklyOrderDetail = (Label)item.FindControl("lblWeeklyOrderDetail");
                lblWeeklyOrderDetail.Text = objOrderDetails.objVisualLayout.NamePrefix + objOrderDetails.objVisualLayout.NameSuffix;

                CheckBox chkWeeklyOdsPrinted = (CheckBox)item.FindControl("chkWeeklyOdsPrinted");
                CheckBox chkWeeklyPrinting = (CheckBox)item.FindControl("chkWeeklyPrinting");
                CheckBox chkWeeklyHeatPress = (CheckBox)item.FindControl("chkWeeklyHeatPress");
                CheckBox chkWeeklySewing = (CheckBox)item.FindControl("chkWeeklySewing");
                CheckBox chkWeeklyFactoryPacking = (CheckBox)item.FindControl("chkWeeklyFactoryPacking");
                CheckBox chkWeeklyFactoryShipped = (CheckBox)item.FindControl("chkWeeklyFactoryShipped");
                /* CheckBox chkWeeklyFactoryCompleted = (CheckBox)item.FindControl("chkWeeklyFactoryCompleted");*/
                Label lblWeeklyCompleted = (Label)item.FindControl("lblWeeklyCompleted");

                Repeater rptWeeklyPrinted = (Repeater)item.FindControl("rptWeeklyPrinted");
                Repeater rptWeeklyPressed = (Repeater)item.FindControl("rptWeeklyPressed");
                Repeater rptWeeklySewing = (Repeater)item.FindControl("rptWeeklySewing");
                Repeater rptWeeklyPacked = (Repeater)item.FindControl("rptWeeklyPacked");
                Repeater rptWeeklyShipped = (Repeater)item.FindControl("rptWeeklyShipped");


                List<OrderDetailQtyBO> lstOrderDetailQty = objOrderDetails.OrderDetailQtysWhereThisIsOrderDetail.ToList();

                List<FactoryOrderDetialBO> lstFactoryOrderDetailPrint = (new FactoryOrderDetialBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetails.ID && (o.OrderDetailStatus == 2 || o.OrderDetailStatus == 8)).ToList();

                if (lstFactoryOrderDetailPrint.Count > 0)
                {
                    rptWeeklyPrinted.DataSource = lstFactoryOrderDetailPrint;
                }
                else
                {
                    rptWeeklyPrinted.DataSource = lstOrderDetailQty;
                }
                rptWeeklyPrinted.DataBind();

                List<FactoryOrderDetialBO> lstFactoryOrderDetailPressed = (new FactoryOrderDetialBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetails.ID && (o.OrderDetailStatus == 3 || o.OrderDetailStatus == 9)).ToList();

                if (lstFactoryOrderDetailPressed.Count > 0)
                {
                    rptWeeklyPressed.DataSource = lstFactoryOrderDetailPressed;
                }
                else
                {
                    rptWeeklyPressed.DataSource = lstOrderDetailQty;
                }
                rptWeeklyPressed.DataBind();

                List<FactoryOrderDetialBO> lstFactoryOrderDetailSewing = (new FactoryOrderDetialBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetails.ID && (o.OrderDetailStatus == 4 || o.OrderDetailStatus == 10)).ToList();

                if (lstFactoryOrderDetailSewing.Count > 0)
                {
                    rptWeeklySewing.DataSource = lstFactoryOrderDetailSewing;
                }
                else
                {
                    rptWeeklySewing.DataSource = lstOrderDetailQty;
                }
                rptWeeklySewing.DataBind();

                List<FactoryOrderDetialBO> lstFactoryOrderDetailPacking = (new FactoryOrderDetialBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetails.ID && (o.OrderDetailStatus == 5 || o.OrderDetailStatus == 11)).ToList();

                if (lstFactoryOrderDetailPacking.Count > 0)
                {
                    rptWeeklyPacked.DataSource = lstFactoryOrderDetailPacking;
                }
                else
                {
                    rptWeeklyPacked.DataSource = lstOrderDetailQty;
                }
                rptWeeklyPacked.DataBind();

                List<FactoryOrderDetialBO> lstFactoryOrderDetailShipped = (new FactoryOrderDetialBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetails.ID && (o.OrderDetailStatus == 6 || o.OrderDetailStatus == 12)).ToList();

                if (lstFactoryOrderDetailShipped.Count > 0)
                {
                    rptWeeklyShipped.DataSource = lstFactoryOrderDetailShipped;
                }
                else
                {
                    rptWeeklyShipped.DataSource = lstOrderDetailQty;
                }
                rptWeeklyShipped.DataBind();


                #region Filter
                switch (objOrderDetails.Status.Value)
                {
                    case 0:
                        chkWeeklyOdsPrinted.Enabled = false;
                        chkWeeklyPrinting.Enabled = false;
                        chkWeeklyHeatPress.Enabled = false;
                        chkWeeklySewing.Enabled = false;
                        chkWeeklyFactoryPacking.Enabled = false;
                        chkWeeklyFactoryShipped.Enabled = false;
                        lblWeeklyCompleted.Text = "No";
                        chkWeeklyOdsPrinted.Attributes.Add("sid", "1");
                        break;
                    case 1:
                        chkWeeklyOdsPrinted.Checked = true;
                        chkWeeklyOdsPrinted.Enabled = false;
                        chkWeeklyPrinting.Enabled = false;
                        chkWeeklyPrinting.Checked = true;
                        chkWeeklyHeatPress.Enabled = false;
                        chkWeeklySewing.Enabled = false;
                        chkWeeklyFactoryPacking.Enabled = false;
                        chkWeeklyFactoryShipped.Enabled = false;
                        lblWeeklyCompleted.Text = "No";
                        break;
                    case 2:
                        chkWeeklyOdsPrinted.Checked = true;
                        chkWeeklyPrinting.Enabled = false;
                        chkWeeklyPrinting.Checked = true;
                        chkWeeklyHeatPress.Enabled = false;
                        chkWeeklySewing.Enabled = false;
                        chkWeeklyFactoryPacking.Enabled = false;
                        chkWeeklyFactoryShipped.Enabled = false;
                        lblWeeklyCompleted.Text = "No";
                        break;
                    case 3:
                        chkWeeklyOdsPrinted.Checked = true;
                        chkWeeklyPrinting.Checked = true;
                        chkWeeklyHeatPress.Enabled = false;
                        chkWeeklyHeatPress.Checked = true;
                        chkWeeklySewing.Enabled = false;
                        chkWeeklyFactoryPacking.Enabled = false;
                        chkWeeklyFactoryShipped.Enabled = false;
                        lblWeeklyCompleted.Text = "No";
                        break;
                    case 4:
                        chkWeeklyOdsPrinted.Checked = true;
                        chkWeeklyPrinting.Checked = true;
                        chkWeeklyHeatPress.Checked = true;
                        chkWeeklySewing.Enabled = false;
                        chkWeeklySewing.Checked = true;
                        chkWeeklyFactoryPacking.Enabled = false;
                        chkWeeklyFactoryShipped.Enabled = false;
                        lblWeeklyCompleted.Text = "No";
                        break;
                    case 5:
                        chkWeeklyOdsPrinted.Checked = true;
                        chkWeeklyPrinting.Checked = true;
                        chkWeeklyHeatPress.Checked = true;
                        chkWeeklySewing.Checked = true;
                        chkWeeklyFactoryPacking.Enabled = false;
                        chkWeeklyFactoryPacking.Checked = true;
                        chkWeeklyFactoryShipped.Enabled = false;
                        lblWeeklyCompleted.Text = "No";
                        break;
                    case 6:
                        chkWeeklyFactoryShipped.Enabled = false;
                        chkWeeklyFactoryPacking.Checked = true;
                        chkWeeklySewing.Checked = true;
                        chkWeeklyOdsPrinted.Checked = true;
                        chkWeeklyPrinting.Checked = true;
                        chkWeeklyHeatPress.Checked = true;
                        lblWeeklyCompleted.Text = "No";
                        break;
                    case 7:
                        chkWeeklyFactoryShipped.Checked = true;
                        chkWeeklyFactoryPacking.Checked = true;
                        chkWeeklySewing.Checked = true;
                        chkWeeklyOdsPrinted.Checked = true;
                        chkWeeklyPrinting.Checked = true;
                        chkWeeklyHeatPress.Checked = true;
                        lblWeeklyCompleted.Text = "Yes";
                        break;
                    case 8:
                        chkWeeklyOdsPrinted.Checked = true;
                        chkWeeklyPrinting.Checked = true;
                        chkWeeklyHeatPress.Enabled = false;
                        chkWeeklyHeatPress.Checked = true;
                        chkWeeklySewing.Enabled = false;
                        chkWeeklyFactoryPacking.Enabled = false;
                        chkWeeklyFactoryShipped.Enabled = false;
                        lblWeeklyCompleted.Text = "No";
                        break;
                    case 9:
                        chkWeeklyOdsPrinted.Checked = true;
                        chkWeeklyPrinting.Checked = true;
                        chkWeeklyHeatPress.Checked = true;
                        chkWeeklySewing.Enabled = false;
                        chkWeeklySewing.Checked = true;
                        chkWeeklyFactoryPacking.Enabled = false;
                        chkWeeklyFactoryShipped.Enabled = false;
                        lblWeeklyCompleted.Text = "No";
                        break;
                    case 10:
                        chkWeeklyOdsPrinted.Checked = true;
                        chkWeeklyPrinting.Checked = true;
                        chkWeeklyHeatPress.Checked = true;
                        chkWeeklySewing.Checked = true;
                        chkWeeklyFactoryPacking.Enabled = false;
                        chkWeeklyFactoryPacking.Checked = true;
                        chkWeeklyFactoryShipped.Enabled = false;
                        lblWeeklyCompleted.Text = "No";
                        break;
                    case 11:
                        chkWeeklyOdsPrinted.Checked = true;
                        chkWeeklyPrinting.Checked = true;
                        chkWeeklyHeatPress.Checked = true;
                        chkWeeklySewing.Checked = true;
                        chkWeeklyFactoryPacking.Checked = true;
                        chkWeeklyFactoryShipped.Enabled = false;
                        chkWeeklyFactoryShipped.Checked = true;
                        lblWeeklyCompleted.Text = "No";
                        break;
                    case 12:
                        chkWeeklyOdsPrinted.Checked = true;
                        chkWeeklyPrinting.Checked = true;
                        chkWeeklyHeatPress.Checked = true;
                        chkWeeklySewing.Checked = true;
                        chkWeeklyFactoryPacking.Checked = true;
                        lblWeeklyCompleted.Text = "Yes";
                        chkWeeklyFactoryShipped.Checked = true;
                        break;
                }

                #endregion

                chkWeeklyOdsPrinted.Attributes.Add("odetailid", objOrderDetails.ID.ToString());
            }
        }

        protected void rptWeeklyPrinted_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objOrderDetailQty = (OrderDetailQtyBO)item.DataItem;

                Label lblWeeklyPrintSize = (Label)item.FindControl("lblWeeklyPrintSize");
                lblWeeklyPrintSize.Text = objOrderDetailQty.objSize.SizeName;
                lblWeeklyPrintSize.Attributes.Add("odid", objOrderDetailQty.OrderDetail.ToString());
                lblWeeklyPrintSize.Attributes.Add("fid", "0");
                lblWeeklyPrintSize.Attributes.Add("sid", objOrderDetailQty.Size.ToString());

                TextBox txtWeeklyPrintStartedDate = (TextBox)item.FindControl("txtWeeklyPrintStartedDate");
                txtWeeklyPrintStartedDate.Text = DateTime.Now.ToString("MMM dd, yyyy");
                txtWeeklyPrintStartedDate.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                TextBox txtWeeklyPrintQty = (TextBox)item.FindControl("txtWeeklyPrintQty");
                txtWeeklyPrintQty.Text = "0";
                txtWeeklyPrintQty.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                Label lblWeeklyPrintTotal = (Label)item.FindControl("lblWeeklyPrintTotal");
                lblWeeklyPrintTotal.Text = "0" + "(" + objOrderDetailQty.Qty.ToString() + ") ";
                lblWeeklyPrintTotal.Attributes.Add("tqty", objOrderDetailQty.Qty.ToString());
                lblWeeklyPrintTotal.Attributes.Add("amount", "0");

            }
            else if (item.ItemIndex > -1 && item.DataItem is FactoryOrderDetialBO)
            {
                FactoryOrderDetialBO objFactoryOrderDetail = (FactoryOrderDetialBO)item.DataItem;
                bool isEnable = true;
                string totalQty = string.Empty;

                OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                objOrderDetailQty.OrderDetail = objFactoryOrderDetail.OrderDetail;
                foreach (OrderDetailQtyBO odq in objOrderDetailQty.SearchObjects())
                {
                    if (objFactoryOrderDetail.Size == odq.Size)
                    {
                        if (odq.Qty == 0)
                        {
                            isEnable = false;
                        }

                        totalQty = odq.Qty.ToString();
                    }
                }

                Label lblWeeklyPrintSize = (Label)item.FindControl("lblWeeklyPrintSize");
                lblWeeklyPrintSize.Text = objFactoryOrderDetail.objSize.SizeName;
                lblWeeklyPrintSize.Attributes.Add("odid", objFactoryOrderDetail.OrderDetail.ToString());
                lblWeeklyPrintSize.Attributes.Add("fid", objFactoryOrderDetail.ID.ToString());
                lblWeeklyPrintSize.Attributes.Add("sid", objFactoryOrderDetail.Size.ToString());

                TextBox txtWeeklyPrintStartedDate = (TextBox)item.FindControl("txtWeeklyPrintStartedDate");
                txtWeeklyPrintStartedDate.Text = Convert.ToDateTime(objFactoryOrderDetail.StartedDate).ToString("MMM dd, yyyy");
                txtWeeklyPrintStartedDate.Enabled = isEnable;

                TextBox txtWeeklyPrintQty = (TextBox)item.FindControl("txtWeeklyPrintQty");
                txtWeeklyPrintQty.Text = objFactoryOrderDetail.CompletedQty.ToString();
                txtWeeklyPrintQty.Enabled = isEnable;

                Label lblWeeklyPrintTotal = (Label)item.FindControl("lblWeeklyPrintTotal");
                lblWeeklyPrintTotal.Text = objFactoryOrderDetail.CompletedQty.ToString() + "(" + totalQty + ")";
                lblWeeklyPrintTotal.Attributes.Add("tqty", totalQty);
                lblWeeklyPrintTotal.Attributes.Add("amount", objFactoryOrderDetail.CompletedQty.ToString());
            }
        }

        protected void rptWeeklyPressed_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objOrderDetailQty = (OrderDetailQtyBO)item.DataItem;

                Label lblWeeklyPressedSize = (Label)item.FindControl("lblWeeklyPressedSize");
                lblWeeklyPressedSize.Text = objOrderDetailQty.objSize.SizeName;
                lblWeeklyPressedSize.Attributes.Add("odid", objOrderDetailQty.OrderDetail.ToString());
                lblWeeklyPressedSize.Attributes.Add("fid", "0");
                lblWeeklyPressedSize.Attributes.Add("sid", objOrderDetailQty.Size.ToString());


                TextBox txtWeeklyPressedStartedDate = (TextBox)item.FindControl("txtWeeklyPressedStartedDate");
                txtWeeklyPressedStartedDate.Text = DateTime.Now.ToString("MMM dd, yyyy");
                txtWeeklyPressedStartedDate.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                TextBox txtWeeklyPressedQty = (TextBox)item.FindControl("txtWeeklyPressedQty");
                txtWeeklyPressedQty.Text = "0";
                txtWeeklyPressedQty.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                Label lblWeeklyPressTotal = (Label)item.FindControl("lblWeeklyPressTotal");
                lblWeeklyPressTotal.Text = "0" + "(" + objOrderDetailQty.Qty.ToString() + ") ";
                lblWeeklyPressTotal.Attributes.Add("tqty", objOrderDetailQty.Qty.ToString());
                lblWeeklyPressTotal.Attributes.Add("amount", "0");

            }
            else if (item.ItemIndex > -1 && item.DataItem is FactoryOrderDetialBO)
            {
                FactoryOrderDetialBO objFactoryOrderDetail = (FactoryOrderDetialBO)item.DataItem;
                bool isEnable = true;
                string totalQty = string.Empty;

                OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                objOrderDetailQty.OrderDetail = objFactoryOrderDetail.OrderDetail;

                foreach (OrderDetailQtyBO odq in objOrderDetailQty.SearchObjects())
                {
                    if (objFactoryOrderDetail.Size == odq.Size)
                    {
                        if (odq.Qty == 0)
                        {
                            isEnable = false;
                        }
                        totalQty = odq.Qty.ToString();
                    }
                }

                Label lblWeeklyPressedSize = (Label)item.FindControl("lblWeeklyPressedSize");
                lblWeeklyPressedSize.Text = objFactoryOrderDetail.objSize.SizeName;
                lblWeeklyPressedSize.Attributes.Add("odid", objFactoryOrderDetail.OrderDetail.ToString());
                lblWeeklyPressedSize.Attributes.Add("fid", objFactoryOrderDetail.ID.ToString());
                lblWeeklyPressedSize.Attributes.Add("sid", objFactoryOrderDetail.Size.ToString());

                TextBox txtWeeklyPressedStartedDate = (TextBox)item.FindControl("txtWeeklyPressedStartedDate");
                txtWeeklyPressedStartedDate.Text = Convert.ToDateTime(objFactoryOrderDetail.StartedDate).ToString("MMM dd, yyyy");
                txtWeeklyPressedStartedDate.Enabled = isEnable;

                TextBox txtWeeklyPressedQty = (TextBox)item.FindControl("txtWeeklyPressedQty");
                txtWeeklyPressedQty.Text = objFactoryOrderDetail.CompletedQty.ToString();
                txtWeeklyPressedQty.Enabled = isEnable;

                Label lblWeeklyPressTotal = (Label)item.FindControl("lblWeeklyPressTotal");
                lblWeeklyPressTotal.Text = objFactoryOrderDetail.CompletedQty.ToString() + "(" + totalQty + ")";
                lblWeeklyPressTotal.Attributes.Add("tqty", totalQty);
                lblWeeklyPressTotal.Attributes.Add("amount", objFactoryOrderDetail.CompletedQty.ToString());
            }
        }

        protected void rptWeeklySewing_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objOrderDetailQty = (OrderDetailQtyBO)item.DataItem;

                Label lblWeeklySewingSize = (Label)item.FindControl("lblWeeklySewingSize");
                lblWeeklySewingSize.Text = objOrderDetailQty.objSize.SizeName;
                lblWeeklySewingSize.Attributes.Add("odid", objOrderDetailQty.OrderDetail.ToString());
                lblWeeklySewingSize.Attributes.Add("fid", "0");
                lblWeeklySewingSize.Attributes.Add("sid", objOrderDetailQty.Size.ToString());

                TextBox txtWeeklySewingStartedDate = (TextBox)item.FindControl("txtWeeklySewingStartedDate");
                txtWeeklySewingStartedDate.Text = DateTime.Now.ToString("MMM dd, yyyy");
                txtWeeklySewingStartedDate.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                TextBox txtWeeklySewingQty = (TextBox)item.FindControl("txtWeeklySewingQty");
                txtWeeklySewingQty.Text = "0";
                txtWeeklySewingQty.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                Label lblWeeklySewingTotal = (Label)item.FindControl("lblWeeklySewingTotal");
                lblWeeklySewingTotal.Text = "0" + "(" + objOrderDetailQty.Qty.ToString() + ") ";
                lblWeeklySewingTotal.Attributes.Add("tqty", objOrderDetailQty.Qty.ToString());
                lblWeeklySewingTotal.Attributes.Add("amount", "0");

            }
            else if (item.ItemIndex > -1 && item.DataItem is FactoryOrderDetialBO)
            {
                FactoryOrderDetialBO objFactoryOrderDetail = (FactoryOrderDetialBO)item.DataItem;
                bool isEnable = true;
                string totalQty = string.Empty;

                OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                objOrderDetailQty.OrderDetail = objFactoryOrderDetail.OrderDetail;

                foreach (OrderDetailQtyBO odq in objOrderDetailQty.SearchObjects())
                {
                    if (objFactoryOrderDetail.Size == odq.Size)
                    {
                        if (odq.Qty == 0)
                        {
                            isEnable = false;
                        }

                        totalQty = odq.Qty.ToString();
                    }
                }

                Label lblWeeklySewingSize = (Label)item.FindControl("lblWeeklySewingSize");
                lblWeeklySewingSize.Text = objFactoryOrderDetail.objSize.SizeName;
                lblWeeklySewingSize.Attributes.Add("odid", objFactoryOrderDetail.OrderDetail.ToString());
                lblWeeklySewingSize.Attributes.Add("fid", objFactoryOrderDetail.ID.ToString());
                lblWeeklySewingSize.Attributes.Add("sid", objFactoryOrderDetail.Size.ToString());

                TextBox txtWeeklySewingStartedDate = (TextBox)item.FindControl("txtWeeklySewingStartedDate");
                txtWeeklySewingStartedDate.Text = Convert.ToDateTime(objFactoryOrderDetail.StartedDate).ToString("MMM dd, yyyy");
                txtWeeklySewingStartedDate.Enabled = isEnable;

                TextBox txtWeeklySewingQty = (TextBox)item.FindControl("txtWeeklySewingQty");
                txtWeeklySewingQty.Text = objFactoryOrderDetail.CompletedQty.ToString();
                txtWeeklySewingQty.Enabled = isEnable;

                Label lblWeeklySewingTotal = (Label)item.FindControl("lblWeeklySewingTotal");
                lblWeeklySewingTotal.Text = objFactoryOrderDetail.CompletedQty.ToString() + "(" + totalQty + ")";
                lblWeeklySewingTotal.Attributes.Add("tqty", totalQty);
                lblWeeklySewingTotal.Attributes.Add("amount", objFactoryOrderDetail.CompletedQty.ToString());
            }
        }

        protected void rptWeeklyPacked_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objOrderDetailQty = (OrderDetailQtyBO)item.DataItem;

                Label lblWeeklyPackedSize = (Label)item.FindControl("lblWeeklyPackedSize");
                lblWeeklyPackedSize.Text = objOrderDetailQty.objSize.SizeName;
                lblWeeklyPackedSize.Attributes.Add("odid", objOrderDetailQty.OrderDetail.ToString());
                lblWeeklyPackedSize.Attributes.Add("fid", "0");
                lblWeeklyPackedSize.Attributes.Add("sid", objOrderDetailQty.Size.ToString());

                TextBox txtWeeklyPackedStartedDate = (TextBox)item.FindControl("txtWeeklyPackedStartedDate");
                txtWeeklyPackedStartedDate.Text = DateTime.Now.ToString("MMM dd, yyyy");
                txtWeeklyPackedStartedDate.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                TextBox txtWeeklyPackedQty = (TextBox)item.FindControl("txtWeeklyPackedQty");
                txtWeeklyPackedQty.Text = "0";
                txtWeeklyPackedQty.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                Label lblWeeklyPackedTotal = (Label)item.FindControl("lblWeeklyPackedTotal");
                lblWeeklyPackedTotal.Text = "0" + "(" + objOrderDetailQty.Qty.ToString() + ") ";
                lblWeeklyPackedTotal.Attributes.Add("tqty", objOrderDetailQty.Qty.ToString());
                lblWeeklyPackedTotal.Attributes.Add("amount", "0");

            }
            else if (item.ItemIndex > -1 && item.DataItem is FactoryOrderDetialBO)
            {
                FactoryOrderDetialBO objFactoryOrderDetail = (FactoryOrderDetialBO)item.DataItem;
                bool isEnable = true;
                string totalQty = string.Empty;

                OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                objOrderDetailQty.OrderDetail = objFactoryOrderDetail.OrderDetail;

                foreach (OrderDetailQtyBO odq in objOrderDetailQty.SearchObjects())
                {
                    if (objFactoryOrderDetail.Size == odq.Size)
                    {
                        if (odq.Qty == 0)
                        {
                            isEnable = false;
                        }
                        totalQty = odq.Qty.ToString();
                    }
                }

                Label lblWeeklyPackedSize = (Label)item.FindControl("lblWeeklyPackedSize");
                lblWeeklyPackedSize.Text = objFactoryOrderDetail.objSize.SizeName;
                lblWeeklyPackedSize.Attributes.Add("odid", objFactoryOrderDetail.OrderDetail.ToString());
                lblWeeklyPackedSize.Attributes.Add("fid", objFactoryOrderDetail.ID.ToString());
                lblWeeklyPackedSize.Attributes.Add("sid", objFactoryOrderDetail.Size.ToString());


                TextBox txtWeeklyPackedStartedDate = (TextBox)item.FindControl("txtWeeklyPackedStartedDate");
                txtWeeklyPackedStartedDate.Text = Convert.ToDateTime(objFactoryOrderDetail.StartedDate).ToString("MMM dd, yyyy");
                txtWeeklyPackedStartedDate.Enabled = isEnable;

                TextBox txtWeeklyPackedQty = (TextBox)item.FindControl("txtWeeklyPackedQty");
                txtWeeklyPackedQty.Text = objFactoryOrderDetail.CompletedQty.ToString();
                txtWeeklyPackedQty.Enabled = isEnable;

                Label lblWeeklyPackedTotal = (Label)item.FindControl("lblWeeklyPackedTotal");
                lblWeeklyPackedTotal.Text = objFactoryOrderDetail.CompletedQty.ToString() + "(" + totalQty + ") ";
                lblWeeklyPackedTotal.Attributes.Add("tqty", totalQty);
                lblWeeklyPackedTotal.Attributes.Add("amount", objFactoryOrderDetail.CompletedQty.ToString());
            }
        }

        protected void rptWeeklyShipped_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objOrderDetailQty = (OrderDetailQtyBO)item.DataItem;

                Label lblWeeklyShippedSize = (Label)item.FindControl("lblWeeklyShippedSize");
                lblWeeklyShippedSize.Text = objOrderDetailQty.objSize.SizeName;
                lblWeeklyShippedSize.Attributes.Add("odid", objOrderDetailQty.OrderDetail.ToString());
                lblWeeklyShippedSize.Attributes.Add("fid", "0");
                lblWeeklyShippedSize.Attributes.Add("sid", objOrderDetailQty.Size.ToString());

                TextBox txtWeeklyShippedStartedDate = (TextBox)item.FindControl("txtWeeklyShippedStartedDate");
                txtWeeklyShippedStartedDate.Text = DateTime.Now.ToString("MMM dd, yyyy");
                txtWeeklyShippedStartedDate.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                TextBox txtWeeklyShippedQty = (TextBox)item.FindControl("txtWeeklyShippedQty");
                txtWeeklyShippedQty.Text = "0";
                txtWeeklyShippedQty.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                Label lblWeeklyShippedTotal = (Label)item.FindControl("lblWeeklyShippedTotal");
                lblWeeklyShippedTotal.Text = "0" + "(" + objOrderDetailQty.Qty.ToString() + ") ";
                lblWeeklyShippedTotal.Attributes.Add("tqty", objOrderDetailQty.Qty.ToString());
                lblWeeklyShippedTotal.Attributes.Add("amount", "0");

            }
            else if (item.ItemIndex > -1 && item.DataItem is FactoryOrderDetialBO)
            {
                FactoryOrderDetialBO objFactoryOrderDetail = (FactoryOrderDetialBO)item.DataItem;
                bool isEnable = true;
                string totalQty = string.Empty;

                OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                objOrderDetailQty.OrderDetail = objFactoryOrderDetail.OrderDetail;

                foreach (OrderDetailQtyBO odq in objOrderDetailQty.SearchObjects())
                {
                    if (objFactoryOrderDetail.Size == odq.Size)
                    {
                        if (odq.Qty == 0)
                        {
                            isEnable = false;
                        }

                        totalQty = odq.Qty.ToString();
                    }
                }

                Label lblWeeklyShippedSize = (Label)item.FindControl("lblWeeklyShippedSize");
                lblWeeklyShippedSize.Text = objFactoryOrderDetail.objSize.SizeName;
                lblWeeklyShippedSize.Attributes.Add("odid", objFactoryOrderDetail.OrderDetail.ToString());
                lblWeeklyShippedSize.Attributes.Add("fid", objFactoryOrderDetail.ID.ToString());
                lblWeeklyShippedSize.Attributes.Add("sid", objFactoryOrderDetail.Size.ToString());

                TextBox txtWeeklyShippedStartedDate = (TextBox)item.FindControl("txtWeeklyShippedStartedDate");
                txtWeeklyShippedStartedDate.Text = Convert.ToDateTime(objFactoryOrderDetail.StartedDate).ToString("MMM dd, yyyy");
                txtWeeklyShippedStartedDate.Enabled = isEnable;

                TextBox txtWeeklyShippedQty = (TextBox)item.FindControl("txtWeeklyShippedQty");
                txtWeeklyShippedQty.Text = objFactoryOrderDetail.CompletedQty.ToString();
                txtWeeklyShippedQty.Enabled = isEnable;

                Label lblWeeklyShippedTotal = (Label)item.FindControl("lblWeeklyShippedTotal");
                lblWeeklyShippedTotal.Text = objFactoryOrderDetail.CompletedQty.ToString() + "(" + totalQty + ") ";
                lblWeeklyShippedTotal.Attributes.Add("tqty", totalQty);
                lblWeeklyShippedTotal.Attributes.Add("amount", objFactoryOrderDetail.CompletedQty.ToString());
            }
        }

        protected void btnWeekOrders_OnClick(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;

            if (this.IsNotRefresh)
            {
                var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
                var monday = DateTime.Today.AddDays(daysTillMonday);

                var daysTillFriday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Saturday;
                var friday = DateTime.Today.AddDays(daysTillFriday);


                List<OrderBO> lstOrders = (from o in (new OrderBO()).SearchObjects().Where(o => o.ModifiedDate >= friday &&
                                                                                                             o.ModifiedDate <= monday &&
                                                                                                             (o.objStatus.Name == "Factory Hold" ||
                                                                                                             o.objStatus.Name == "Indiman Submitted" ||
                                                                                                             o.objStatus.Name == "In Progress" ||
                                                                                                             o.objStatus.Name == "Partialy Completed" ||
                                                                                                             o.objStatus.Name == "Completed")).OrderByDescending(o => o.CreatedDate)
                                           select o).ToList();

                if (lstOrders.Count > 0)
                {
                    this.rptWeeklyOrders.DataSource = lstOrders;
                    this.rptWeeklyOrders.DataBind();
                    this.dvWeeklyFactoryEmptyContent.Visible = false;
                    this.rptWeeklyOrders.Visible = true;
                    this.btnSubmitWeeklyOrders.Visible = true;
                }
                else
                {
                    this.rptWeeklyOrders.Visible = false;
                    this.dvWeeklyFactoryEmptyContent.Visible = true;
                    this.btnSubmitWeeklyOrders.Visible = false;
                }

                ViewState["PopulateWeeklyOrderDetails"] = true;
            }
            else
            {
                ViewState["PopulateOrderDetails"] = false;
                ViewState["PopulateOrderDetailsStatus"] = false;
                ViewState["PopulateDepartmentDetails"] = false;
                ViewState["PopulateEditDepartmentDetails"] = false;
                ViewState["PopulateWeeklyOrderDetails"] = false;
            }
        }

        protected void btnWeeklyOrdersSubmit_Click(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;

            if (this.IsNotRefresh)
            {
                try
                {
                    foreach (RepeaterItem item in rptWeeklyOrders.Items)
                    {
                        int facid = 0;
                        int odid = 0;
                        int sizeid = 0;
                        int odstatusid = 0;
                        string date = string.Empty;
                        int qty = 0;
                        int orderdetail = 0;
                        int totalQTY = 0;
                        int total = 0;
                        int amount = 0;
                        DataGrid dgWeeklyOrderDetails = (DataGrid)item.FindControl("dgWeeklyOrderDetails");

                        foreach (DataGridItem dgItem in dgWeeklyOrderDetails.Items)
                        {

                            #region ODSPrinted

                            CheckBox chkWeeklyOdsPrinted = (CheckBox)dgItem.FindControl("chkWeeklyOdsPrinted");
                            orderdetail = int.Parse(((System.Web.UI.WebControls.WebControl)(chkWeeklyOdsPrinted)).Attributes["odetailid"].ToString());


                            if (chkWeeklyOdsPrinted.Checked == true && chkWeeklyOdsPrinted.Enabled == true)
                            {
                                odstatusid = int.Parse(((System.Web.UI.WebControls.WebControl)(chkWeeklyOdsPrinted)).Attributes["sid"].ToString());
                                using (TransactionScope ts = new TransactionScope())
                                {
                                    OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                    objOrderDetail.ID = orderdetail;
                                    objOrderDetail.GetObject();

                                    objOrderDetail.Status = odstatusid;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }
                            }

                            #endregion

                            #region Printing

                            CheckBox chkWeeklyPrinting = (CheckBox)dgItem.FindControl("chkWeeklyPrinting");


                            if (chkWeeklyPrinting.Enabled == false && chkWeeklyPrinting.Checked == true)
                            {
                                bool completed = false;
                                amount = 0;
                                totalQTY = 0;
                                List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 2 || o.OrderDetailStatus == 8)).ToList();

                                foreach (FactoryOrderDetialBO fod in lst)
                                {
                                    totalQTY = totalQTY + (int)fod.CompletedQty;
                                }

                                Repeater rptWeeklyPrinted = (Repeater)dgItem.FindControl("rptWeeklyPrinted");
                                foreach (RepeaterItem rpitem in rptWeeklyPrinted.Items)
                                {
                                    Label lblWeeklyPrintSize = (Label)rpitem.FindControl("lblWeeklyPrintSize");
                                    facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyPrintSize)).Attributes["fid"].ToString());
                                    odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyPrintSize)).Attributes["odid"].ToString());
                                    sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyPrintSize)).Attributes["sid"].ToString());

                                    Label lblWeeklyPrintTotal = (Label)rpitem.FindControl("lblWeeklyPrintTotal");
                                    total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyPrintTotal)).Attributes["tqty"].ToString());

                                    TextBox txtWeeklyPrintStartedDate = (TextBox)rpitem.FindControl("txtWeeklyPrintStartedDate");
                                    date = txtWeeklyPrintStartedDate.Text;

                                    TextBox txtWeeklyPrintQty = (TextBox)rpitem.FindControl("txtWeeklyPrintQty");
                                    qty = int.Parse(txtWeeklyPrintQty.Text);

                                    if (facid > 0)
                                    {
                                        FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();

                                        if (total != qty)
                                        {
                                            totalQTY = totalQTY + qty;
                                        }
                                        else if (qty > objFactoryOrderDetail.CompletedQty)
                                        {
                                            totalQTY = totalQTY + qty;
                                        }
                                    }
                                    else
                                    {
                                        totalQTY = totalQTY + qty;
                                    }

                                    OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                    objOrderDetailqty.OrderDetail = odid;

                                    if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                    {
                                        completed = true;
                                        odstatusid = 8;
                                    }
                                    else
                                    {
                                        odstatusid = 2;
                                    }

                                    using (TransactionScope ts = new TransactionScope())
                                    {
                                        FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);
                                        if (facid > 0)
                                        {
                                            objFactoryOrderDetail.ID = facid;
                                            objFactoryOrderDetail.GetObject();
                                            amount = (int)objFactoryOrderDetail.CompletedQty;
                                        }

                                        objFactoryOrderDetail.OrderDetail = odid;
                                        objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                        objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                        objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                        objFactoryOrderDetail.Size = sizeid;

                                        this.ObjContext.SaveChanges();

                                        ts.Complete();
                                    }
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                    objOrderDetail.ID = odid;
                                    objOrderDetail.GetObject();

                                    objOrderDetail.Status = (completed == true) ? 8 : 2;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }
                                // ischeck = true;
                            }

                            #endregion

                            #region HeatPress

                            CheckBox chkWeeklyHeatPress = (CheckBox)dgItem.FindControl("chkWeeklyHeatPress");


                            if (chkWeeklyHeatPress.Enabled == false && chkWeeklyHeatPress.Checked == true)
                            {
                                bool completed = false;
                                amount = 0;
                                totalQTY = 0;
                                List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 3 || o.OrderDetailStatus == 9)).ToList();

                                foreach (FactoryOrderDetialBO fod in lst)
                                {
                                    totalQTY = totalQTY + (int)fod.CompletedQty;
                                }

                                Repeater rptWeeklyPressed = (Repeater)dgItem.FindControl("rptWeeklyPressed");
                                foreach (RepeaterItem rpritem in rptWeeklyPressed.Items)
                                {
                                    Label lblWeeklyPressedSize = (Label)rpritem.FindControl("lblWeeklyPressedSize");
                                    facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyPressedSize)).Attributes["fid"].ToString());
                                    odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyPressedSize)).Attributes["odid"].ToString());
                                    sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyPressedSize)).Attributes["sid"].ToString());

                                    Label lblWeeklyPressTotal = (Label)rpritem.FindControl("lblWeeklyPressTotal");
                                    total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyPressTotal)).Attributes["tqty"].ToString());

                                    TextBox txtWeeklyPressedStartedDate = (TextBox)rpritem.FindControl("txtWeeklyPressedStartedDate");
                                    date = txtWeeklyPressedStartedDate.Text;

                                    TextBox txtWeeklyPressedQty = (TextBox)rpritem.FindControl("txtWeeklyPressedQty");
                                    qty = int.Parse(txtWeeklyPressedQty.Text);

                                    if (facid > 0)
                                    {
                                        FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();

                                        if (total != qty)
                                        {
                                            totalQTY = totalQTY + qty;
                                        }
                                        else if (qty > objFactoryOrderDetail.CompletedQty)
                                        {
                                            totalQTY = totalQTY + qty;
                                        }
                                    }
                                    else
                                    {
                                        totalQTY = totalQTY + qty;
                                    }

                                    OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                    objOrderDetailqty.OrderDetail = odid;

                                    if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                    {
                                        completed = true;
                                        odstatusid = 9;
                                    }
                                    else
                                    {
                                        odstatusid = 3;
                                    }

                                    using (TransactionScope ts = new TransactionScope())
                                    {
                                        FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);

                                        if (facid > 0)
                                        {
                                            objFactoryOrderDetail.ID = facid;
                                            objFactoryOrderDetail.GetObject();
                                            amount = (int)objFactoryOrderDetail.CompletedQty;
                                        }

                                        objFactoryOrderDetail.OrderDetail = odid;
                                        objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                        objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                        objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                        objFactoryOrderDetail.Size = sizeid;

                                        this.ObjContext.SaveChanges();
                                        ts.Complete();
                                    }
                                }
                                using (TransactionScope ts = new TransactionScope())
                                {
                                    OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                    objOrderDetail.ID = odid;
                                    objOrderDetail.GetObject();

                                    objOrderDetail.Status = (completed == true) ? 9 : 3;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }
                                // ischeck = true;
                            }

                            #endregion

                            #region Sewing

                            CheckBox chkWeeklySewing = (CheckBox)dgItem.FindControl("chkWeeklySewing");

                            if (chkWeeklySewing.Enabled == false && chkWeeklySewing.Checked == true)
                            {
                                bool completed = false;
                                amount = 0;
                                totalQTY = 0;
                                List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 4 || o.OrderDetailStatus == 10)).ToList();

                                foreach (FactoryOrderDetialBO fod in lst)
                                {
                                    totalQTY = totalQTY + (int)fod.CompletedQty;
                                }

                                Repeater rptWeeklySewing = (Repeater)dgItem.FindControl("rptWeeklySewing");
                                foreach (RepeaterItem rsitem in rptWeeklySewing.Items)
                                {
                                    Label lblWeeklySewingSize = (Label)rsitem.FindControl("lblWeeklySewingSize");
                                    facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklySewingSize)).Attributes["fid"].ToString());
                                    odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklySewingSize)).Attributes["odid"].ToString());
                                    sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklySewingSize)).Attributes["sid"].ToString());

                                    Label lblWeeklySewingTotal = (Label)rsitem.FindControl("lblWeeklySewingTotal");
                                    total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklySewingTotal)).Attributes["tqty"].ToString());

                                    TextBox txtWeeklySewingStartedDate = (TextBox)rsitem.FindControl("txtWeeklySewingStartedDate");
                                    date = txtWeeklySewingStartedDate.Text;

                                    TextBox txtWeeklySewingQty = (TextBox)rsitem.FindControl("txtWeeklySewingQty");
                                    qty = int.Parse(txtWeeklySewingQty.Text);

                                    if (facid > 0)
                                    {
                                        FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();

                                        if (total != qty)
                                        {
                                            totalQTY = totalQTY + qty;
                                        }
                                        else if (qty > objFactoryOrderDetail.CompletedQty)
                                        {
                                            totalQTY = totalQTY + qty;
                                        }
                                    }
                                    else
                                    {
                                        totalQTY = totalQTY + qty;
                                    }

                                    OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                    objOrderDetailqty.OrderDetail = odid;

                                    if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                    {
                                        completed = true;
                                        odstatusid = 10;
                                    }
                                    else
                                    {
                                        odstatusid = 4;
                                    }

                                    using (TransactionScope ts = new TransactionScope())
                                    {
                                        FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);
                                        if (facid > 0)
                                        {
                                            objFactoryOrderDetail.ID = facid;
                                            objFactoryOrderDetail.GetObject();
                                            amount = (int)objFactoryOrderDetail.CompletedQty;
                                        }

                                        objFactoryOrderDetail.OrderDetail = odid;
                                        objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                        objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                        objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                        objFactoryOrderDetail.Size = sizeid;

                                        this.ObjContext.SaveChanges();
                                        ts.Complete();
                                    }
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                    objOrderDetail.ID = odid;
                                    objOrderDetail.GetObject();

                                    objOrderDetail.Status = (completed == true) ? 10 : 4;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }
                            }

                            #endregion

                            #region Packing

                            CheckBox chkWeeklyFactoryPacking = (CheckBox)dgItem.FindControl("chkWeeklyFactoryPacking");


                            if (chkWeeklyFactoryPacking.Enabled == false && chkWeeklyFactoryPacking.Checked == true)
                            {
                                bool completed = false;
                                amount = 0;
                                totalQTY = 0;
                                List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 5 || o.OrderDetailStatus == 11)).ToList();

                                foreach (FactoryOrderDetialBO fod in lst)
                                {
                                    totalQTY = totalQTY + (int)fod.CompletedQty;
                                }

                                Repeater rptWeeklyPacked = (Repeater)dgItem.FindControl("rptWeeklyPacked");
                                foreach (RepeaterItem rpaitem in rptWeeklyPacked.Items)
                                {
                                    Label lblWeeklyPackedSize = (Label)rpaitem.FindControl("lblWeeklyPackedSize");
                                    facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyPackedSize)).Attributes["fid"].ToString());
                                    odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyPackedSize)).Attributes["odid"].ToString());
                                    sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyPackedSize)).Attributes["sid"].ToString());

                                    Label lblWeeklyPackedTotal = (Label)rpaitem.FindControl("lblWeeklyPackedTotal");
                                    total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyPackedTotal)).Attributes["tqty"].ToString());

                                    TextBox txtWeeklyPackedStartedDate = (TextBox)rpaitem.FindControl("txtWeeklyPackedStartedDate");
                                    date = txtWeeklyPackedStartedDate.Text;

                                    TextBox txtWeeklyPackedQty = (TextBox)rpaitem.FindControl("txtWeeklyPackedQty");
                                    qty = int.Parse(txtWeeklyPackedQty.Text);

                                    if (facid > 0)
                                    {
                                        FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();

                                        if (total != qty)
                                        {
                                            totalQTY = totalQTY + qty;
                                        }
                                        else if (qty > objFactoryOrderDetail.CompletedQty)
                                        {
                                            totalQTY = totalQTY + qty;
                                        }
                                    }
                                    else
                                    {
                                        totalQTY = totalQTY + qty;
                                    }

                                    OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                    objOrderDetailqty.OrderDetail = odid;

                                    if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                    {
                                        completed = true;
                                        odstatusid = 11;
                                    }
                                    else
                                    {
                                        odstatusid = 5;
                                    }

                                    using (TransactionScope ts = new TransactionScope())
                                    {
                                        FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);

                                        if (facid > 0)
                                        {
                                            objFactoryOrderDetail.ID = facid;
                                            objFactoryOrderDetail.GetObject();
                                            amount = (int)objFactoryOrderDetail.CompletedQty;
                                        }

                                        objFactoryOrderDetail.OrderDetail = odid;
                                        objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                        objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                        objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                        objFactoryOrderDetail.Size = sizeid;

                                        this.ObjContext.SaveChanges();
                                        ts.Complete();
                                    }
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                    objOrderDetail.ID = odid;
                                    objOrderDetail.GetObject();

                                    objOrderDetail.Status = (completed == true) ? 11 : 5;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }
                            }

                            #endregion

                            #region Shipped
                            CheckBox chkWeeklyFactoryShipped = (CheckBox)dgItem.FindControl("chkWeeklyFactoryShipped");

                            if (chkWeeklyFactoryShipped.Enabled == false && chkWeeklyFactoryShipped.Checked == true)
                            {
                                bool completed = false;
                                amount = 0;
                                totalQTY = 0;
                                List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 6 || o.OrderDetailStatus == 12)).ToList();

                                foreach (FactoryOrderDetialBO fod in lst)
                                {
                                    totalQTY = totalQTY + (int)fod.CompletedQty;
                                }

                                Repeater rptWeeklyShipped = (Repeater)dgItem.FindControl("rptWeeklyShipped");
                                foreach (RepeaterItem rsitem in rptWeeklyShipped.Items)
                                {
                                    Label lblWeeklyShippedSize = (Label)rsitem.FindControl("lblWeeklyShippedSize");
                                    facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyShippedSize)).Attributes["fid"].ToString());
                                    odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyShippedSize)).Attributes["odid"].ToString());
                                    sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyShippedSize)).Attributes["sid"].ToString());

                                    Label lblWeeklyShippedTotal = (Label)rsitem.FindControl("lblWeeklyShippedTotal");
                                    total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblWeeklyShippedTotal)).Attributes["tqty"].ToString());

                                    TextBox txtWeeklyShippedStartedDate = (TextBox)rsitem.FindControl("txtWeeklyShippedStartedDate");
                                    date = txtWeeklyShippedStartedDate.Text;

                                    TextBox txtWeeklyShippedQty = (TextBox)rsitem.FindControl("txtWeeklyShippedQty");
                                    qty = int.Parse(txtWeeklyShippedQty.Text);

                                    if (facid > 0)
                                    {
                                        FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();

                                        if (total != qty)
                                        {
                                            totalQTY = totalQTY + qty;
                                        }
                                        else if (qty > objFactoryOrderDetail.CompletedQty)
                                        {
                                            totalQTY = totalQTY + qty;
                                        }
                                    }
                                    else
                                    {
                                        totalQTY = totalQTY + qty;
                                    }

                                    OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                    objOrderDetailqty.OrderDetail = odid;

                                    if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                    {
                                        completed = true;
                                        odstatusid = 12;
                                    }
                                    else
                                    {
                                        odstatusid = 6;
                                    }

                                    if (odstatusid == 12)
                                    {
                                        completed = true;
                                    }

                                    using (TransactionScope ts = new TransactionScope())
                                    {
                                        FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);

                                        if (facid > 0)
                                        {
                                            objFactoryOrderDetail.ID = facid;
                                            objFactoryOrderDetail.GetObject();
                                            amount = (int)objFactoryOrderDetail.CompletedQty;
                                        }

                                        objFactoryOrderDetail.OrderDetail = odid;
                                        objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                        objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                        objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                        objFactoryOrderDetail.Size = sizeid;

                                        this.ObjContext.SaveChanges();
                                        ts.Complete();
                                    }
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                    objOrderDetail.ID = odid;
                                    objOrderDetail.GetObject();

                                    objOrderDetail.Status = (completed == true) ? 7 : 6;

                                    this.ObjContext.SaveChanges();

                                    ts.Complete();
                                }
                            }
                            #endregion
                        }

                        // chnage the order status
                        this.SetOrderStatus(orderdetail);
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while saving weekly order detail status in ViewOrders page", ex);
                }
            }
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;
            this.PopulateControls();
        }

        protected void lbDownloadDistributorPO_Click(object sender, EventArgs e)
        {
            try
            {
                int odsID = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["oddid"].ToString());

                if (odsID > 0)
                {
                    //string pdfFilePath = Common.GenerateOdsPdf.GeneratePdfDistributorPO(odsID);
                    string pdfFilePath = Common.GenerateOdsPdf.GeneratePdfOrderReport(odsID);
                    this.DownloadPDFFile(pdfFilePath);
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while printing DistributorPO", ex);
            }
        }

        protected void lbDownloadDistributorPOForOffice_Click(object sender, EventArgs e)
        {
            var odsID = int.Parse(((WebControl)(sender)).Attributes["oddid"]);

            if (odsID <= 0)
                return;
            try
            {
                var pdfFilePath = GenerateOdsPdf.GeneratePdfOrderReportForOffice(odsID);
                DownloadPDFFile(pdfFilePath);
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occurred while printing DistributorPO For Office Use", ex);
            }

        }

        protected void btnSaveOrder_Click(object sender, EventArgs e)
        {
            try
            {
                ViewState["PopulateWeeklyCapacities"] = false;
                ViewState["PopulateOrderDetails"] = false;
                ViewState["PopulateOrderDetailsStatus"] = false;
                ViewState["PopulateWeeklyOrderDetails"] = false;
                ViewState["PopulateDepartmentDetails"] = false;
                ViewState["PopulateEditDepartmentDetails"] = false;
                ViewState["PopulateEditDepartmentDetails"] = false;

                //Repeater rptPrintODS = (Repeater)(((System.Web.UI.WebControls.WebControl)(sender)).FindControl("rptPrintODS"));
                if (this.hdnSheduleDate.Value != "0")
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        foreach (GridDataItem item in RadGridOrders.Items)
                        {
                            TextBox txtScheduleDate = (TextBox)item.FindControl("txtScheduleDate");
                            int detailID = int.Parse(txtScheduleDate.Attributes["qid"].ToString());

                            OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                            objOrderDetail.ID = detailID;
                            objOrderDetail.GetObject();

                            CheckBox chkIsAcceptedTC = (CheckBox)item.FindControl("chkIsAcceptedTC");
                            OrderBO objOrder = new OrderBO(this.ObjContext);
                            objOrder.ID = objOrderDetail.Order;
                            objOrder.GetObject();
                            objOrder.IsAcceptedTermsAndConditions = chkIsAcceptedTC.Checked;

                            objOrderDetail.RequestedDate = Convert.ToDateTime(txtScheduleDate.Text.Trim());
                            objOrderDetail.SheduledDate = Convert.ToDateTime(txtScheduleDate.Text.Trim());
                            objOrderDetail.ShipmentDate = Convert.ToDateTime(txtScheduleDate.Text.Trim());

                            /*if (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator)
                            {
                                if (objOrderDetail.objOrder.Status == 22 || objOrderDetail.objOrder.Status == 1)
                                {
                                    objOrderDetail.RequestedDate = Convert.ToDateTime(txtScheduleDate.Text.Trim());
                                    objOrderDetail.SheduledDate = Convert.ToDateTime(txtScheduleDate.Text.Trim());
                                    objOrderDetail.ShipmentDate = Convert.ToDateTime(txtScheduleDate.Text.Trim());
                                }
                            }
                            else if (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator)
                            {
                                if (objOrderDetail.objOrder.Status == 19 || objOrderDetail.objOrder.Status == 26 || objOrderDetail.objOrder.Status == 20)
                                {
                                    objOrderDetail.ShipmentDate = Convert.ToDateTime(txtScheduleDate.Text.Trim());
                                    objOrderDetail.SheduledDate = Convert.ToDateTime(txtScheduleDate.Text.Trim());
                                }
                            }
                            else if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator || this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator)
                            {
                                if (objOrderDetail.objOrder.Status == 18 || objOrderDetail.objOrder.Status == 23 || objOrderDetail.objOrder.Status == 24 || objOrderDetail.objOrder.Status == 25 || objOrderDetail.objOrder.Status == 26)
                                {
                                    objOrderDetail.SheduledDate = Convert.ToDateTime(txtScheduleDate.Text.Trim());
                                    objOrderDetail.ShipmentDate = Convert.ToDateTime(txtScheduleDate.Text.Trim());
                                }
                            }*/

                            // NNM
                            /*  // DateTime today = DateTime.Today;
                              DateTime dt = Convert.ToDateTime(txtScheduleDate.Text.Trim());
                              // The (... + 7) % 7 ensures we end up with a value in the range [0, 6]
                              int daysUntilFriday = ((int)DayOfWeek.Friday - (int)dt.DayOfWeek + 7) % 7;
                              DateTime nextFriday = dt.AddDays(daysUntilFriday);

                              int weeklyid = (new WeeklyProductionCapacityBO()).SearchObjects().Where(o => o.WeekendDate == nextFriday).Select(o => o.ID).SingleOrDefault();

                              List<PackingListBO> lstPackingList = (new PackingListBO()).SearchObjects().Where(o => o.OrderDetail == detailID).ToList();

                              if (lstPackingList.Count > 0)
                              {
                                  foreach (PackingListBO pl in lstPackingList)
                                  {
                                      PackingListBO objPackingList = new PackingListBO(this.ObjContext);
                                      objPackingList.ID = pl.ID;
                                      objPackingList.GetObject();

                                      objPackingList.WeeklyProductionCapacity = weeklyid;
                                  }
                              }

                              List<int> lstInvoiceOrders = (new InvoiceOrderBO()).SearchObjects().Where(o => o.OrderDetail == detailID).Select(o => o.Invoice).Distinct().ToList();

                              if (lstInvoiceOrders.Count > 0)
                              {
                                  foreach (int invoice in lstInvoiceOrders)
                                  {
                                      InvoiceBO objInvoice = new InvoiceBO(this.ObjContext);
                                      objInvoice.ID = invoice;
                                      objInvoice.GetObject();

                                      objInvoice.WeeklyProductionCapacity = weeklyid;
                                      objInvoice.ShipmentDate = Convert.ToDateTime(txtScheduleDate.Text.Trim());
                                  }
                              }*/
                        }

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("View Oeder: btnSaveOrder_Click, Error occured while saving shedule date.", ex);
            }

            this.PopulateDataGrid();
        }

        protected void btnGenerateBC_Click(object sender, EventArgs e)
        {
            //Repeater rptPrintODS = (Repeater)(((System.Web.UI.WebControls.WebControl)(sender)).FindControl("rptPrintODS"));
            List<OrderDetailQtyBO> lstOrderDetailsQty = new List<OrderDetailQtyBO>();

            foreach (GridDataItem item in RadGridOrders.Items)
            {
                CheckBox chkGenerateLabel = (CheckBox)item.FindControl("chkGenerateLabel");

                if (chkGenerateLabel.Checked)
                {
                    TextBox txtScheduleDate = (TextBox)item.FindControl("txtScheduleDate");
                    int detailID = int.Parse(txtScheduleDate.Attributes["qid"].ToString());

                    OrderDetailBO objOrderDetail = new OrderDetailBO();
                    objOrderDetail.ID = detailID;
                    objOrderDetail.GetObject();

                    foreach (OrderDetailQtyBO objODQ in objOrderDetail.OrderDetailQtysWhereThisIsOrderDetail.Where(m => m.Qty > 0).ToList())
                    {
                        lstOrderDetailsQty.Add(objODQ);
                    }
                }
            }

            this.GenerateLabels(lstOrderDetailsQty);
        }

        protected void btnGenerateLabels_Click(object sender, EventArgs e)
        {
            List<OrderDetailQtyBO> lstOrderDetailsQty = new List<OrderDetailQtyBO>();

            foreach (GridDataItem dgitem in this.RadGridOrders.Items)
            {

                CheckBox chkGenerateLabel = (CheckBox)dgitem.FindControl("chkGenerateLabel");

                if (chkGenerateLabel.Checked)
                {
                    TextBox txtScheduleDate = (TextBox)dgitem.FindControl("txtScheduleDate");
                    int detailID = int.Parse(txtScheduleDate.Attributes["qid"].ToString());

                    OrderDetailBO objOrderDetail = new OrderDetailBO();
                    objOrderDetail.ID = detailID;
                    objOrderDetail.GetObject();

                    foreach (OrderDetailQtyBO objODQ in objOrderDetail.OrderDetailQtysWhereThisIsOrderDetail.Where(m => m.Qty > 0).ToList())
                    {
                        lstOrderDetailsQty.Add(objODQ);
                    }
                }

            }
            ViewState["PopulateWeeklyCapacities"] = false;
            this.GenerateLabels(lstOrderDetailsQty);
        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;

            if (this.IsNotRefresh)
            {
                var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
                var monday = DateTime.Today.AddDays(daysTillMonday);

                var daysTillFriday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Saturday;
                var friday = DateTime.Today.AddDays(daysTillFriday);

                this.lblDepartmentName.Text = "PRINTING DEPARTMENT";
                this.lblDepartmentDate.Text = DateTime.Now.ToString("dd MMMM yyyy");
                dgDepatrmentOrderDetail.Columns[3].HeaderText = "Printed Qty";

                List<FactoryOrderDetialBO> lstFactoryOrderDetails = (new FactoryOrderDetialBO()).SearchObjects()
                                                                    .Where(o => (o.objOrderDetail.objOrder.ModifiedDate >= friday && o.objOrderDetail.objOrder.ModifiedDate <= monday) && (o.OrderDetailStatus == 2 || o.OrderDetailStatus == 8))
                                                                    .OrderBy(o => o.objOrderDetail.objOrder.CreatedDate).ToList();

                if (lstFactoryOrderDetails.Count > 0)
                {
                    dgDepatrmentOrderDetail.DataSource = lstFactoryOrderDetails;
                    dgDepatrmentOrderDetail.DataBind();
                    this.dvDeptEmptyContent.Visible = false;
                }
                else
                {
                    this.dvDeptEmptyContent.Visible = true;
                }

                ViewState["PopulateDepartmentDetails"] = true;
            }
        }

        protected void btnHeatPress_Click(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;

            if (this.IsNotRefresh)
            {
                var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
                var monday = DateTime.Today.AddDays(daysTillMonday);

                var daysTillFriday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Saturday;
                var friday = DateTime.Today.AddDays(daysTillFriday);

                this.lblDepartmentName.Text = "HAET PRESS DEPARTMENT";
                this.lblDepartmentDate.Text = DateTime.Now.ToString("dd MMMM yyyy");
                dgDepatrmentOrderDetail.Columns[3].HeaderText = "Heat Pressed Qty";

                List<FactoryOrderDetialBO> lstFactoryOrderDetails = (new FactoryOrderDetialBO()).SearchObjects()
                                                                    .Where(o => (o.objOrderDetail.objOrder.ModifiedDate >= friday && o.objOrderDetail.objOrder.ModifiedDate <= monday) && (o.OrderDetailStatus == 3 || o.OrderDetailStatus == 9))
                                                                    .OrderBy(o => o.objOrderDetail.objOrder.CreatedDate).ToList();

                if (lstFactoryOrderDetails.Count > 0)
                {
                    dgDepatrmentOrderDetail.DataSource = lstFactoryOrderDetails;
                    dgDepatrmentOrderDetail.DataBind();
                    this.dvDeptEmptyContent.Visible = false;
                }
                else
                {
                    this.dvDeptEmptyContent.Visible = true;
                }

                ViewState["PopulateDepartmentDetails"] = true;
            }
        }

        protected void btnSewing_Click(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;

            if (this.IsNotRefresh)
            {
                var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
                var monday = DateTime.Today.AddDays(daysTillMonday);

                var daysTillFriday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Saturday;
                var friday = DateTime.Today.AddDays(daysTillFriday);

                this.lblDepartmentName.Text = "SEWING DEPARTMENT";
                this.lblDepartmentDate.Text = DateTime.Now.ToString("dd MMMM yyyy");
                dgDepatrmentOrderDetail.Columns[3].HeaderText = "Sewing Qty";

                List<FactoryOrderDetialBO> lstFactoryOrderDetails = (new FactoryOrderDetialBO()).SearchObjects()
                                                                    .Where(o => (o.objOrderDetail.objOrder.ModifiedDate >= friday && o.objOrderDetail.objOrder.ModifiedDate <= monday) && (o.OrderDetailStatus == 4 || o.OrderDetailStatus == 10))
                                                                    .OrderBy(o => o.objOrderDetail.objOrder.CreatedDate).ToList();

                if (lstFactoryOrderDetails.Count > 0)
                {
                    dgDepatrmentOrderDetail.DataSource = lstFactoryOrderDetails;
                    dgDepatrmentOrderDetail.DataBind();
                    this.dvDeptEmptyContent.Visible = false;
                }
                else
                {
                    this.dvDeptEmptyContent.Visible = true;
                }

                ViewState["PopulateDepartmentDetails"] = true;
            }
        }

        protected void btnPacking_Click(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;

            if (this.IsNotRefresh)
            {
                var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
                var monday = DateTime.Today.AddDays(daysTillMonday);

                var daysTillFriday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Saturday;
                var friday = DateTime.Today.AddDays(daysTillFriday);

                this.lblDepartmentName.Text = "PACKING DEPARTMENT";
                this.lblDepartmentDate.Text = DateTime.Now.ToString("dd MMMM yyyy");
                dgDepatrmentOrderDetail.Columns[3].HeaderText = "Packed Qty";

                List<FactoryOrderDetialBO> lstFactoryOrderDetails = (new FactoryOrderDetialBO()).SearchObjects()
                                                                    .Where(o => (o.objOrderDetail.objOrder.ModifiedDate >= friday && o.objOrderDetail.objOrder.ModifiedDate <= monday) && (o.OrderDetailStatus == 5 || o.OrderDetailStatus == 11))
                                                                    .OrderBy(o => o.objOrderDetail.objOrder.CreatedDate).ToList();

                if (lstFactoryOrderDetails.Count > 0)
                {
                    dgDepatrmentOrderDetail.DataSource = lstFactoryOrderDetails;
                    dgDepatrmentOrderDetail.DataBind();
                    this.dvDeptEmptyContent.Visible = false;
                }
                else
                {
                    this.dvDeptEmptyContent.Visible = true;
                }

                ViewState["PopulateDepartmentDetails"] = true;
            }
        }

        protected void btnShipped_Click(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;

            if (this.IsNotRefresh)
            {
                var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
                var monday = DateTime.Today.AddDays(daysTillMonday);

                var daysTillFriday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Saturday;
                var friday = DateTime.Today.AddDays(daysTillFriday);

                this.lblDepartmentName.Text = "SHIPPING DEPARTMENT";
                this.lblDepartmentDate.Text = DateTime.Now.ToString("dd MMMM yyyy");
                dgDepatrmentOrderDetail.Columns[3].HeaderText = "Shipped Qty";

                List<FactoryOrderDetialBO> lstFactoryOrderDetails = (new FactoryOrderDetialBO()).SearchObjects()
                                                                    .Where(o => (o.objOrderDetail.objOrder.ModifiedDate >= friday && o.objOrderDetail.objOrder.ModifiedDate <= monday) && (o.OrderDetailStatus == 6 || o.OrderDetailStatus == 11))
                                                                    .OrderBy(o => o.objOrderDetail.objOrder.CreatedDate).ToList();

                if (lstFactoryOrderDetails.Count > 0)
                {
                    dgDepatrmentOrderDetail.DataSource = lstFactoryOrderDetails;
                    dgDepatrmentOrderDetail.DataBind();
                    this.dvDeptEmptyContent.Visible = false;
                }
                else
                {
                    this.dvDeptEmptyContent.Visible = true;
                }

                ViewState["PopulateDepartmentDetails"] = true;
            }
        }

        protected void dgDepatrmentOrderDetail_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is FactoryOrderDetialBO)
            {
                FactoryOrderDetialBO objFactoryOrderDetails = (FactoryOrderDetialBO)item.DataItem;
                int balance = 0;
                int qty = 0;

                Label lblDepartmentOrderNumber = (Label)item.FindControl("lblDepartmentOrderNumber");
                Label lblDepartmentVLNumber = (Label)item.FindControl("lblDepartmentVLNumber");
                Label lblDeptSize = (Label)item.FindControl("lblDeptSize");
                Label lblDeptQty = (Label)item.FindControl("lblDeptQty");
                Label lblTotalQty = (Label)item.FindControl("lblTotalQty");
                Label lblDeptBalance = (Label)item.FindControl("lblDeptBalance");

                List<OrderDetailQtyBO> lstOrderDetil = (new OrderDetailQtyBO().SearchObjects().Where(o => o.Size == objFactoryOrderDetails.Size && o.OrderDetail == objFactoryOrderDetails.OrderDetail && o.Qty > 0)).ToList();

                if (lstOrderDetil.Count > 0)
                {
                    if (objFactoryOrderDetails.objOrderDetail.objOrder.ID.ToString() != orderNumber)
                    {
                        lblDepartmentOrderNumber.Text = objFactoryOrderDetails.objOrderDetail.objOrder.ID.ToString();
                        orderNumber = objFactoryOrderDetails.objOrderDetail.objOrder.ID.ToString();
                    }

                    if (objFactoryOrderDetails.objOrderDetail.VisualLayout != visualLayout)
                    {
                        lblDepartmentVLNumber.Text = (objFactoryOrderDetails.objOrderDetail.VisualLayout > 0) ? (objFactoryOrderDetails.objOrderDetail.objVisualLayout.NameSuffix != null && objFactoryOrderDetails.objOrderDetail.objVisualLayout.NameSuffix > 0) ? objFactoryOrderDetails.objOrderDetail.objVisualLayout.NamePrefix + " " + objFactoryOrderDetails.objOrderDetail.objVisualLayout.NameSuffix : objFactoryOrderDetails.objOrderDetail.objVisualLayout.NamePrefix : string.Empty;
                        visualLayout = objFactoryOrderDetails.objOrderDetail.VisualLayout.Value;
                    }

                    lblDeptSize.Text = objFactoryOrderDetails.objSize.SizeName;

                    lblDeptQty.Text = objFactoryOrderDetails.CompletedQty.ToString();

                    qty = lstOrderDetil[0].Qty;
                    balance = (int)lstOrderDetil[0].Qty - (int)objFactoryOrderDetails.CompletedQty;

                    lblTotalQty.Text = qty.ToString();

                    lblDeptBalance.Text = balance.ToString();
                }
                else
                {
                    item.Visible = false;
                }
            }

        }

        protected void btnEditPrint_OnClick(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;

            if (this.IsNotRefresh)
            {
                var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
                var monday = DateTime.Today.AddDays(daysTillMonday);

                var daysTillFriday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Saturday;
                var friday = DateTime.Today.AddDays(daysTillFriday);

                this.lblEditDepartmentHeaderText.Text = "PRINTING DEPARTMENT";
                dgEditDepartmentDetails.Columns[1].HeaderText = "Printing";

                List<OrderDetailBO> lstOrderDetail = (new OrderDetailBO()).SearchObjects().Where(o => (o.Status == 2 || o.Status == 8 || o.Status == 1) &&
                                                                                                (o.objOrder.ModifiedDate >= friday && o.objOrder.ModifiedDate <= monday)).ToList();

                if (lstOrderDetail.Count > 0)
                {
                    this.dgEditDepartmentDetails.Attributes.Add("dept", "print");
                    dgEditDepartmentDetails.DataSource = lstOrderDetail;
                    dgEditDepartmentDetails.DataBind();
                    this.dgEditDepartmentDetails.Visible = true;
                    this.dvEditDepartmentEmptyContent.Visible = false;
                    this.btnEditDeptSubmit.Visible = true;
                }
                else
                {
                    this.dgEditDepartmentDetails.Visible = false;
                    this.dvEditDepartmentEmptyContent.Visible = true;
                    this.btnEditDeptSubmit.Visible = false;
                }

                ViewState["PopulateEditDepartmentDetails"] = true;
            }
        }

        protected void btnEditHeatPressed_OnClick(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;

            if (this.IsNotRefresh)
            {
                var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
                var monday = DateTime.Today.AddDays(daysTillMonday);

                var daysTillFriday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Saturday;
                var friday = DateTime.Today.AddDays(daysTillFriday);

                this.lblEditDepartmentHeaderText.Text = "HEAT PRESS DEPARTMENT";
                dgEditDepartmentDetails.Columns[1].HeaderText = "Heat Pressing";

                List<OrderDetailBO> lstOrderDetail = (new OrderDetailBO()).SearchObjects().Where(o => (o.Status == 3 || o.Status == 9 || o.Status == 8) &&
                                                                                                (o.objOrder.ModifiedDate >= friday && o.objOrder.ModifiedDate <= monday)).ToList();

                if (lstOrderDetail.Count > 0)
                {
                    this.dgEditDepartmentDetails.Attributes.Add("dept", "press");
                    dgEditDepartmentDetails.DataSource = lstOrderDetail;
                    dgEditDepartmentDetails.DataBind();
                    this.dgEditDepartmentDetails.Visible = true;
                    this.dvEditDepartmentEmptyContent.Visible = false;
                    this.btnEditDeptSubmit.Visible = true;
                }
                else
                {
                    this.dvEditDepartmentEmptyContent.Visible = true;
                    this.dgEditDepartmentDetails.Visible = false;
                    this.btnEditDeptSubmit.Visible = false;
                }

                ViewState["PopulateEditDepartmentDetails"] = true;
            }
        }

        protected void btnEditSewing_OnClick(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;

            if (this.IsNotRefresh)
            {
                var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
                var monday = DateTime.Today.AddDays(daysTillMonday);

                var daysTillFriday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Saturday;
                var friday = DateTime.Today.AddDays(daysTillFriday);

                this.lblEditDepartmentHeaderText.Text = "SEWING DEPARTMENT";
                dgEditDepartmentDetails.Columns[1].HeaderText = "Sewing";

                List<OrderDetailBO> lstOrderDetail = (new OrderDetailBO()).SearchObjects().Where(o => (o.Status == 4 || o.Status == 10 || o.Status == 9) &&
                                                                                                      (o.objOrder.ModifiedDate >= friday && o.objOrder.ModifiedDate <= monday)).ToList();

                if (lstOrderDetail.Count > 0)
                {
                    this.dgEditDepartmentDetails.Attributes.Add("dept", "sewing");
                    dgEditDepartmentDetails.DataSource = lstOrderDetail;
                    dgEditDepartmentDetails.DataBind();
                    this.dgEditDepartmentDetails.Visible = true;
                    this.dvEditDepartmentEmptyContent.Visible = false;
                    this.btnEditDeptSubmit.Visible = true;
                }
                else
                {
                    this.dvEditDepartmentEmptyContent.Visible = true;
                    this.dgEditDepartmentDetails.Visible = false;
                    this.btnEditDeptSubmit.Visible = false;
                }

                ViewState["PopulateEditDepartmentDetails"] = true;
            }
        }

        protected void btnEditPacked_OnClick(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;

            if (this.IsNotRefresh)
            {
                var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
                var monday = DateTime.Today.AddDays(daysTillMonday);

                var daysTillFriday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Saturday;
                var friday = DateTime.Today.AddDays(daysTillFriday);

                this.lblEditDepartmentHeaderText.Text = "PACKING DEPARTMENT";
                dgEditDepartmentDetails.Columns[1].HeaderText = "Packing";

                List<OrderDetailBO> lstOrderDetail = (new OrderDetailBO()).SearchObjects().Where(o => (o.Status == 5 || o.Status == 11 || o.Status == 10) &&
                                                                                                (o.objOrder.ModifiedDate >= friday && o.objOrder.ModifiedDate <= monday)).ToList();

                if (lstOrderDetail.Count > 0)
                {
                    this.dgEditDepartmentDetails.Attributes.Add("dept", "packed");
                    dgEditDepartmentDetails.DataSource = lstOrderDetail;
                    dgEditDepartmentDetails.DataBind();
                    this.dgEditDepartmentDetails.Visible = true;
                    this.dvEditDepartmentEmptyContent.Visible = false;
                    this.btnEditDeptSubmit.Visible = true;
                }
                else
                {
                    this.dvEditDepartmentEmptyContent.Visible = true;
                    this.dgEditDepartmentDetails.Visible = false;
                    this.btnEditDeptSubmit.Visible = false;
                }

                ViewState["PopulateEditDepartmentDetails"] = true;
            }
        }

        protected void btnEditShipped_OnClick(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;

            if (this.IsNotRefresh)
            {
                var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
                var monday = DateTime.Today.AddDays(daysTillMonday);

                var daysTillFriday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Saturday;
                var friday = DateTime.Today.AddDays(daysTillFriday);

                this.lblEditDepartmentHeaderText.Text = "SHIPPING DEPARTMENT";
                dgEditDepartmentDetails.Columns[1].HeaderText = "Shipping";

                List<OrderDetailBO> lstOrderDetail = (new OrderDetailBO()).SearchObjects().Where(o => (o.Status == 6 || o.Status == 12 || o.Status == 11) &&
                                                                                                (o.objOrder.ModifiedDate >= friday && o.objOrder.ModifiedDate <= monday)).ToList();

                if (lstOrderDetail.Count > 0)
                {
                    this.dgEditDepartmentDetails.Attributes.Add("dept", "shipped");
                    dgEditDepartmentDetails.DataSource = lstOrderDetail;
                    dgEditDepartmentDetails.DataBind();
                    this.dgEditDepartmentDetails.Visible = true;
                    this.dvEditDepartmentEmptyContent.Visible = false;
                    this.btnEditDeptSubmit.Visible = true;
                }
                else
                {
                    this.dgEditDepartmentDetails.Visible = false;
                    this.dvEditDepartmentEmptyContent.Visible = true;
                    this.btnEditDeptSubmit.Visible = false;
                }

                ViewState["PopulateEditDepartmentDetails"] = true;
            }
        }

        protected void dgEditDepartmentDetails_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailBO)
            {
                OrderDetailBO objOrderDetail = (OrderDetailBO)item.DataItem;
                string type = ((System.Web.UI.WebControls.WebControl)(sender)).Attributes["dept"].ToString();

                List<FactoryOrderDetialBO> lstFactoryOrderDetail = new List<FactoryOrderDetialBO>();

                Label lblDeptEditOrderDetail = (Label)item.FindControl("lblDeptEditOrderDetail");
                lblDeptEditOrderDetail.Text = (objOrderDetail.VisualLayout > 0) ? (objOrderDetail.objVisualLayout.NameSuffix != null && objOrderDetail.objVisualLayout.NameSuffix > 0) ? objOrderDetail.objVisualLayout.NamePrefix + " " + objOrderDetail.objVisualLayout.NameSuffix : objOrderDetail.objVisualLayout.NamePrefix : string.Empty;
                lblDeptEditOrderDetail.Attributes.Add("orderdetail", objOrderDetail.ID.ToString());

                Repeater rptEditDepartmentDetails = (Repeater)item.FindControl("rptEditDepartmentDetails");

                if (type == "print")
                {
                    lstFactoryOrderDetail = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == objOrderDetail.ID) && (o.OrderDetailStatus == 2 || o.OrderDetailStatus == 8)).ToList();

                    if (lstFactoryOrderDetail.Count > 0)
                    {
                        rptEditDepartmentDetails.DataSource = lstFactoryOrderDetail;
                    }
                    else
                    {
                        rptEditDepartmentDetails.DataSource = (new OrderDetailQtyBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetail.ID).ToList();
                    }
                }
                else if (type == "press")
                {
                    lstFactoryOrderDetail = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == objOrderDetail.ID) && (o.OrderDetailStatus == 3 || o.OrderDetailStatus == 9)).ToList();

                    if (lstFactoryOrderDetail.Count > 0)
                    {
                        rptEditDepartmentDetails.DataSource = lstFactoryOrderDetail;
                    }
                    else
                    {
                        rptEditDepartmentDetails.DataSource = (new OrderDetailQtyBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetail.ID).ToList();
                    }
                }
                else if (type == "sewing")
                {
                    lstFactoryOrderDetail = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == objOrderDetail.ID) && (o.OrderDetailStatus == 4 || o.OrderDetailStatus == 10)).ToList();

                    if (lstFactoryOrderDetail.Count > 0)
                    {
                        rptEditDepartmentDetails.DataSource = lstFactoryOrderDetail;
                    }
                    else
                    {
                        rptEditDepartmentDetails.DataSource = (new OrderDetailQtyBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetail.ID).ToList();
                    }
                }
                else if (type == "packed")
                {
                    lstFactoryOrderDetail = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == objOrderDetail.ID) && (o.OrderDetailStatus == 5 || o.OrderDetailStatus == 11)).ToList();

                    if (lstFactoryOrderDetail.Count > 0)
                    {
                        rptEditDepartmentDetails.DataSource = lstFactoryOrderDetail;
                    }
                    else
                    {
                        rptEditDepartmentDetails.DataSource = (new OrderDetailQtyBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetail.ID).ToList();
                    }
                }
                else if (type == "shipped")
                {
                    lstFactoryOrderDetail = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == objOrderDetail.ID) && (o.OrderDetailStatus == 6 || o.OrderDetailStatus == 12)).ToList();

                    if (lstFactoryOrderDetail.Count > 0)
                    {
                        rptEditDepartmentDetails.DataSource = lstFactoryOrderDetail;
                    }
                    else
                    {
                        rptEditDepartmentDetails.DataSource = (new OrderDetailQtyBO()).SearchObjects().Where(o => o.OrderDetail == objOrderDetail.ID).ToList();
                    }
                }
                rptEditDepartmentDetails.DataBind();
            }
        }

        protected void rptEditDepartmentDetails_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objOrderDetailQty = (OrderDetailQtyBO)item.DataItem;

                Label lblEditDeptSize = (Label)item.FindControl("lblEditDeptSize");
                lblEditDeptSize.Text = objOrderDetailQty.objSize.SizeName;
                lblEditDeptSize.Attributes.Add("odid", objOrderDetailQty.OrderDetail.ToString());
                lblEditDeptSize.Attributes.Add("fid", "0");
                lblEditDeptSize.Attributes.Add("sid", objOrderDetailQty.Size.ToString());

                TextBox txtEditDeptStartedDate = (TextBox)item.FindControl("txtEditDeptStartedDate");
                txtEditDeptStartedDate.Text = DateTime.Now.ToString("MMM dd, yyyy");
                txtEditDeptStartedDate.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;

                TextBox txtEditDeptQty = (TextBox)item.FindControl("txtEditDeptQty");
                txtEditDeptQty.Text = "0";
                txtEditDeptQty.Enabled = (objOrderDetailQty.Qty == 0) ? false : true;
                txtEditDeptQty.ToolTip = objOrderDetailQty.Qty.ToString();

                Label lblEditDeptTotal = (Label)item.FindControl("lblEditDeptTotal");
                lblEditDeptTotal.Text = "0" + "(" + objOrderDetailQty.Qty.ToString() + ") ";
                lblEditDeptTotal.Attributes.Add("tqty", objOrderDetailQty.Qty.ToString());
                lblEditDeptTotal.Attributes.Add("tqty", "0");


            }
            else if (item.ItemIndex > -1 && item.DataItem is FactoryOrderDetialBO)
            {
                FactoryOrderDetialBO objFactoryOrderDetail = (FactoryOrderDetialBO)item.DataItem;
                bool isEnable = true;
                string totalqty = string.Empty;

                OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                objOrderDetailQty.OrderDetail = objFactoryOrderDetail.OrderDetail;
                foreach (OrderDetailQtyBO odq in objOrderDetailQty.SearchObjects())
                {
                    if (objFactoryOrderDetail.Size == odq.Size)
                    {
                        if (odq.Qty == 0)
                        {
                            isEnable = false;
                        }
                        totalqty = odq.Qty.ToString();
                    }
                }

                Label lblEditDeptSize = (Label)item.FindControl("lblEditDeptSize");
                lblEditDeptSize.Text = objFactoryOrderDetail.objSize.SizeName;
                lblEditDeptSize.Attributes.Add("odid", objFactoryOrderDetail.OrderDetail.ToString());
                lblEditDeptSize.Attributes.Add("fid", objFactoryOrderDetail.ID.ToString());
                lblEditDeptSize.Attributes.Add("sid", objFactoryOrderDetail.Size.ToString());

                TextBox txtEditDeptStartedDate = (TextBox)item.FindControl("txtEditDeptStartedDate");
                txtEditDeptStartedDate.Text = Convert.ToDateTime(objFactoryOrderDetail.StartedDate).ToString("MMM dd, yyyy");
                txtEditDeptStartedDate.Enabled = isEnable;

                TextBox txtEditDeptQty = (TextBox)item.FindControl("txtEditDeptQty");
                txtEditDeptQty.Text = objFactoryOrderDetail.CompletedQty.ToString();
                txtEditDeptQty.Enabled = isEnable;
                txtEditDeptQty.ToolTip = totalqty;


                Label lblEditDeptTotal = (Label)item.FindControl("lblEditDeptTotal");
                lblEditDeptTotal.Text = objFactoryOrderDetail.CompletedQty.ToString() + "(" + totalqty + ") ";
                lblEditDeptTotal.Attributes.Add("tqty", totalqty);
                lblEditDeptTotal.Attributes.Add("tqty", objFactoryOrderDetail.CompletedQty.ToString());

            }
        }

        protected void btnEditDeptSubmit_Click(object sender, EventArgs e)
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;

            int facid = 0;
            int odid = 0;
            int sizeid = 0;
            int odstatusid = 0;
            string date = string.Empty;
            int qty = 0;
            int orderdetail = 0;
            int totalQTY = 0;
            int total = 0;
            string type = string.Empty;

            if (this.IsNotRefresh)
            {
                try
                {
                    foreach (DataGridItem item in dgEditDepartmentDetails.Items)
                    {
                        bool completed = false;
                        //bool iscount = false;
                        totalQTY = 0;
                        int amount = 0;


                        type = ((System.Web.UI.WebControls.WebControl)(dgEditDepartmentDetails)).Attributes["dept"].ToString();

                        Label lblDeptEditOrderDetail = (Label)item.FindControl("lblDeptEditOrderDetail");
                        orderdetail = int.Parse(((System.Web.UI.WebControls.WebControl)(lblDeptEditOrderDetail)).Attributes["orderdetail"].ToString());

                        #region Print

                        if (type == "print")
                        {

                            List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 2 || o.OrderDetailStatus == 8)).ToList();

                            foreach (FactoryOrderDetialBO fod in lst)
                            {
                                totalQTY = totalQTY + (int)fod.CompletedQty;
                            }

                            Repeater rptEditDepartmentDetails = (Repeater)item.FindControl("rptEditDepartmentDetails");

                            foreach (RepeaterItem ritem in rptEditDepartmentDetails.Items)
                            {
                                Label lblEditDeptSize = (Label)ritem.FindControl("lblEditDeptSize");
                                facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["fid"].ToString());
                                odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["odid"].ToString());
                                sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["sid"].ToString());

                                Label lblEditDeptTotal = (Label)ritem.FindControl("lblEditDeptTotal");
                                total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptTotal)).Attributes["tqty"].ToString());

                                TextBox txtEditDeptStartedDate = (TextBox)ritem.FindControl("txtEditDeptStartedDate");
                                date = txtEditDeptStartedDate.Text;

                                TextBox txtEditDeptQty = (TextBox)ritem.FindControl("txtEditDeptQty");
                                qty = int.Parse(txtEditDeptQty.Text);

                                if (facid > 0)
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                    objFactoryOrderDetail.ID = facid;
                                    objFactoryOrderDetail.GetObject();

                                    if (total != qty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                    else if (qty > objFactoryOrderDetail.CompletedQty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                }
                                else
                                {
                                    totalQTY = totalQTY + qty;
                                }

                                OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                objOrderDetailqty.OrderDetail = odid;

                                if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                {
                                    completed = true;
                                    odstatusid = 8;
                                }
                                else
                                {
                                    odstatusid = 2;
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);
                                    if (facid > 0)
                                    {
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();
                                        amount = (int)objFactoryOrderDetail.CompletedQty;
                                    }

                                    objFactoryOrderDetail.OrderDetail = odid;
                                    objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                    objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                    objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                    objFactoryOrderDetail.Size = sizeid;

                                    this.ObjContext.SaveChanges();

                                    ts.Complete();
                                }


                                using (TransactionScope ts = new TransactionScope())
                                {
                                    OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                    objOrderDetail.ID = odid;
                                    objOrderDetail.GetObject();

                                    objOrderDetail.Status = (completed == true) ? 8 : 2;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }

                            }

                        }
                        #endregion

                        #region Heat Press

                        if (type == "press")
                        {
                            List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 3 || o.OrderDetailStatus == 9)).ToList();

                            foreach (FactoryOrderDetialBO fod in lst)
                            {
                                totalQTY = totalQTY + (int)fod.CompletedQty;
                            }

                            Repeater rptEditDepartmentDetails = (Repeater)item.FindControl("rptEditDepartmentDetails");

                            foreach (RepeaterItem ritem in rptEditDepartmentDetails.Items)
                            {
                                Label lblEditDeptSize = (Label)ritem.FindControl("lblEditDeptSize");
                                facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["fid"].ToString());
                                odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["odid"].ToString());
                                sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["sid"].ToString());

                                Label lblEditDeptTotal = (Label)ritem.FindControl("lblEditDeptTotal");
                                total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptTotal)).Attributes["tqty"].ToString());

                                TextBox txtEditDeptStartedDate = (TextBox)ritem.FindControl("txtEditDeptStartedDate");
                                date = txtEditDeptStartedDate.Text;

                                TextBox txtEditDeptQty = (TextBox)ritem.FindControl("txtEditDeptQty");
                                qty = int.Parse(txtEditDeptQty.Text);

                                if (facid > 0)
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                    objFactoryOrderDetail.ID = facid;
                                    objFactoryOrderDetail.GetObject();

                                    if (total != qty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                    else if (qty > objFactoryOrderDetail.CompletedQty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                }
                                else
                                {
                                    totalQTY = totalQTY + qty;
                                }

                                OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                objOrderDetailqty.OrderDetail = odid;

                                if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                {
                                    completed = true;
                                    odstatusid = 9;
                                }
                                else
                                {
                                    odstatusid = 3;
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);
                                    if (facid > 0)
                                    {
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();
                                        amount = (int)objFactoryOrderDetail.CompletedQty;
                                    }

                                    objFactoryOrderDetail.OrderDetail = odid;
                                    objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                    objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                    objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                    objFactoryOrderDetail.Size = sizeid;

                                    this.ObjContext.SaveChanges();

                                    ts.Complete();
                                }


                                using (TransactionScope ts = new TransactionScope())
                                {
                                    OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                    objOrderDetail.ID = odid;
                                    objOrderDetail.GetObject();

                                    objOrderDetail.Status = (completed == true) ? 9 : 3;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }

                            }
                        }

                        #endregion

                        #region Sewing

                        if (type == "sewing")
                        {
                            List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 4 || o.OrderDetailStatus == 10)).ToList();

                            foreach (FactoryOrderDetialBO fod in lst)
                            {
                                totalQTY = totalQTY + (int)fod.CompletedQty;
                            }

                            Repeater rptEditDepartmentDetails = (Repeater)item.FindControl("rptEditDepartmentDetails");

                            foreach (RepeaterItem ritem in rptEditDepartmentDetails.Items)
                            {
                                Label lblEditDeptSize = (Label)ritem.FindControl("lblEditDeptSize");
                                facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["fid"].ToString());
                                odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["odid"].ToString());
                                sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["sid"].ToString());

                                Label lblEditDeptTotal = (Label)ritem.FindControl("lblEditDeptTotal");
                                total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptTotal)).Attributes["tqty"].ToString());

                                TextBox txtEditDeptStartedDate = (TextBox)ritem.FindControl("txtEditDeptStartedDate");
                                date = txtEditDeptStartedDate.Text;

                                TextBox txtEditDeptQty = (TextBox)ritem.FindControl("txtEditDeptQty");
                                qty = int.Parse(txtEditDeptQty.Text);

                                if (facid > 0)
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                    objFactoryOrderDetail.ID = facid;
                                    objFactoryOrderDetail.GetObject();

                                    if (total != qty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                    else if (qty > objFactoryOrderDetail.CompletedQty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                }
                                else
                                {
                                    totalQTY = totalQTY + qty;
                                }

                                OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                objOrderDetailqty.OrderDetail = odid;

                                if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                {
                                    completed = true;
                                    odstatusid = 10;
                                }
                                else
                                {
                                    odstatusid = 4;
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);
                                    if (facid > 0)
                                    {
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();
                                        amount = (int)objFactoryOrderDetail.CompletedQty;
                                    }

                                    objFactoryOrderDetail.OrderDetail = odid;
                                    objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                    objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                    objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                    objFactoryOrderDetail.Size = sizeid;

                                    this.ObjContext.SaveChanges();

                                    ts.Complete();
                                }


                                using (TransactionScope ts = new TransactionScope())
                                {
                                    OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                    objOrderDetail.ID = odid;
                                    objOrderDetail.GetObject();

                                    objOrderDetail.Status = (completed == true) ? 10 : 4;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }

                            }
                        }

                        #endregion

                        #region Packed

                        if (type == "packed")
                        {
                            List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 5 || o.OrderDetailStatus == 11)).ToList();

                            foreach (FactoryOrderDetialBO fod in lst)
                            {
                                totalQTY = totalQTY + (int)fod.CompletedQty;
                            }

                            Repeater rptEditDepartmentDetails = (Repeater)item.FindControl("rptEditDepartmentDetails");

                            foreach (RepeaterItem ritem in rptEditDepartmentDetails.Items)
                            {
                                Label lblEditDeptSize = (Label)ritem.FindControl("lblEditDeptSize");
                                facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["fid"].ToString());
                                odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["odid"].ToString());
                                sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["sid"].ToString());

                                Label lblEditDeptTotal = (Label)ritem.FindControl("lblEditDeptTotal");
                                total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptTotal)).Attributes["tqty"].ToString());

                                TextBox txtEditDeptStartedDate = (TextBox)ritem.FindControl("txtEditDeptStartedDate");
                                date = txtEditDeptStartedDate.Text;

                                TextBox txtEditDeptQty = (TextBox)ritem.FindControl("txtEditDeptQty");
                                qty = int.Parse(txtEditDeptQty.Text);

                                if (facid > 0)
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                    objFactoryOrderDetail.ID = facid;
                                    objFactoryOrderDetail.GetObject();

                                    if (total != qty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                    else if (qty > objFactoryOrderDetail.CompletedQty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                }
                                else
                                {
                                    totalQTY = totalQTY + qty;
                                }

                                OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                objOrderDetailqty.OrderDetail = odid;

                                if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                {
                                    completed = true;
                                    odstatusid = 11;
                                }
                                else
                                {
                                    odstatusid = 5;
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);
                                    if (facid > 0)
                                    {
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();
                                        amount = (int)objFactoryOrderDetail.CompletedQty;
                                    }

                                    objFactoryOrderDetail.OrderDetail = odid;
                                    objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                    objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                    objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                    objFactoryOrderDetail.Size = sizeid;

                                    this.ObjContext.SaveChanges();

                                    ts.Complete();
                                }


                                using (TransactionScope ts = new TransactionScope())
                                {
                                    OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                    objOrderDetail.ID = odid;
                                    objOrderDetail.GetObject();

                                    objOrderDetail.Status = (completed == true) ? 11 : 5;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }

                            }
                        }

                        #endregion

                        #region Shipped

                        if (type == "shipped")
                        {
                            List<FactoryOrderDetialBO> lst = (new FactoryOrderDetialBO()).SearchObjects().Where(o => (o.OrderDetail == orderdetail) && (o.OrderDetailStatus == 6 || o.OrderDetailStatus == 12)).ToList();

                            foreach (FactoryOrderDetialBO fod in lst)
                            {
                                totalQTY = totalQTY + (int)fod.CompletedQty;
                            }

                            Repeater rptEditDepartmentDetails = (Repeater)item.FindControl("rptEditDepartmentDetails");

                            foreach (RepeaterItem ritem in rptEditDepartmentDetails.Items)
                            {
                                Label lblEditDeptSize = (Label)ritem.FindControl("lblEditDeptSize");
                                facid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["fid"].ToString());
                                odid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["odid"].ToString());
                                sizeid = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptSize)).Attributes["sid"].ToString());

                                Label lblEditDeptTotal = (Label)ritem.FindControl("lblEditDeptTotal");
                                total = int.Parse(((System.Web.UI.WebControls.WebControl)(lblEditDeptTotal)).Attributes["tqty"].ToString());

                                TextBox txtEditDeptStartedDate = (TextBox)ritem.FindControl("txtEditDeptStartedDate");
                                date = txtEditDeptStartedDate.Text;

                                TextBox txtEditDeptQty = (TextBox)ritem.FindControl("txtEditDeptQty");
                                qty = int.Parse(txtEditDeptQty.Text);

                                if (facid > 0)
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO();
                                    objFactoryOrderDetail.ID = facid;
                                    objFactoryOrderDetail.GetObject();

                                    if (total != qty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                    else if (qty > objFactoryOrderDetail.CompletedQty)
                                    {
                                        totalQTY = totalQTY + qty;
                                    }
                                }
                                else
                                {
                                    totalQTY = totalQTY + qty;
                                }

                                OrderDetailQtyBO objOrderDetailqty = new OrderDetailQtyBO();
                                objOrderDetailqty.OrderDetail = odid;

                                if (totalQTY == int.Parse(objOrderDetailqty.SearchObjects().Select(o => o.Qty).Sum().ToString()))
                                {
                                    completed = true;
                                    odstatusid = 12;
                                }
                                else
                                {
                                    odstatusid = 6;
                                }

                                using (TransactionScope ts = new TransactionScope())
                                {
                                    FactoryOrderDetialBO objFactoryOrderDetail = new FactoryOrderDetialBO(this.ObjContext);
                                    if (facid > 0)
                                    {
                                        objFactoryOrderDetail.ID = facid;
                                        objFactoryOrderDetail.GetObject();
                                        amount = (int)objFactoryOrderDetail.CompletedQty;

                                    }

                                    objFactoryOrderDetail.OrderDetail = odid;
                                    objFactoryOrderDetail.OrderDetailStatus = odstatusid;
                                    objFactoryOrderDetail.CompletedQty = (total == qty) ? qty : amount + qty;
                                    objFactoryOrderDetail.StartedDate = Convert.ToDateTime(date);
                                    objFactoryOrderDetail.Size = sizeid;

                                    this.ObjContext.SaveChanges();

                                    ts.Complete();
                                }


                                using (TransactionScope ts = new TransactionScope())
                                {
                                    OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                    objOrderDetail.ID = odid;
                                    objOrderDetail.GetObject();

                                    objOrderDetail.Status = (completed == true) ? 7 : 6;

                                    this.ObjContext.SaveChanges();
                                    ts.Complete();
                                }

                            }
                        }

                        #endregion
                    }

                    this.SetOrderStatus(orderdetail);
                }
                catch (Exception ex)
                {

                    IndicoLogging.log.Error("Error occured while saving department factory Order detail ", ex);
                }
                ViewState["PopulateEditDepartmentDetails"] = false;
            }

            this.PopulateControls();
        }

        protected void btnSubmitOrder_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                try
                {
                    int order = int.Parse(this.hdnIndimanOrderID.Value);
                    int status = int.Parse(this.hdnOrderStatus.Value);
                    string mailTo = string.Empty;
                    OrderStatus currentOrderStatus = this.GetOrderStatus(status);

                    using (TransactionScope ts = new TransactionScope())
                    {
                        OrderBO objOrder = new OrderBO(this.ObjContext);
                        objOrder.ID = order;
                        objOrder.GetObject();

                        if (this.LoggedUser.IsDirectSalesPerson && currentOrderStatus == OrderStatus.New)
                        {
                            objOrder.Status = this.GetOrderStatus(OrderStatus.DistributorSubmitted).ID;
                            objOrder.Modifier = this.LoggedUser.ID;
                            objOrder.ModifiedDate = DateTime.Now;

                            this.SendOrderSubmissionEmail(order, this.Distributor.objCoordinator.EmailAddress,
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

                            this.SendOrderSubmissionEmail(order, mailTo, "Imports", true, CustomSettings.CSOCC);
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

                            this.SendOrderSubmissionEmail(order, mailTo, "Factory", true, null);
                        }

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while submitting Order", ex);
                }
            }

            //this.PopulateDataGrid();

            Response.Redirect("ViewOrders.aspx");
        }

        protected void lbSubmitOdsPrint_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                //Repeater rptPrintODS = (Repeater)((LinkButton)(sender)).FindControl("rptPrintODS");

                try
                {
                    foreach (GridDataItem item in RadGridOrders.Items)
                    {
                        CheckBox chkOdsPrintinted = (CheckBox)item.FindControl("chkOdsPrintinted");
                        int orderdetail = int.Parse(((System.Web.UI.WebControls.WebControl)(chkOdsPrintinted)).Attributes["odid"].ToString());

                        if (chkOdsPrintinted.Enabled == true && chkOdsPrintinted.Checked == true)
                        {
                            using (TransactionScope ts = new TransactionScope())
                            {
                                OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                                objOrderDetail.ID = orderdetail;
                                objOrderDetail.GetObject();

                                objOrderDetail.Status = 1;

                                this.ObjContext.SaveChanges();

                                OrderBO objOrder = new OrderBO(this.ObjContext);
                                objOrder.ID = objOrderDetail.Order;
                                objOrder.GetObject();

                                objOrder.Status = 19;

                                this.ObjContext.SaveChanges();

                                ts.Complete();

                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while updating Ods Printing Status in lbSubmitOdsPrint_Click", ex);
                }
            }
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;
            ViewState["PopulateIndimanSubmit"] = false;

            this.PopulateDataGrid();
        }

        protected void btnWeeklyCapacity_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                this.PopulateWeeklyCapacities();
                ViewState["PopulateWeeklyCapacities"] = true;
                ViewState["PopulateOrderDetails"] = false;
                ViewState["PopulateOrderDetailsStatus"] = false;
                ViewState["PopulateWeeklyOrderDetails"] = false;
                ViewState["PopulateDepartmentDetails"] = false;
                ViewState["PopulateEditDepartmentDetails"] = false;
                ViewState["PopulateEditDepartmentDetails"] = false;
            }
            else
            {
                ViewState["PopulateWeeklyCapacities"] = false;
            }
        }

        protected void dgWeeklySummary_ItemDataBound(object sender, DataGridItemEventArgs e)
        {

            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is WeeklyProductionCapacityBO)
            {
                WeeklyProductionCapacityBO objProductionCapacity = (WeeklyProductionCapacityBO)item.DataItem;

                Label lblWeekYear = (Label)item.FindControl("lblWeekYear");
                lblWeekYear.Text = objProductionCapacity.WeekNo + "/" + objProductionCapacity.WeekendDate.Year;

                Label lblWeekEnd = (Label)item.FindControl("lblWeekEnd");
                lblWeekEnd.Text = objProductionCapacity.WeekendDate.ToString("dd MMMM yyyy");

                Label lblCapacities = (Label)item.FindControl("lblCapacities");
                lblCapacities.Text = objProductionCapacity.Capacity.ToString("#,##0");

                List<ReturnProductionCapacitiesViewBO> lstPCV = OrderBO.Productioncapacities((DateTime?)objProductionCapacity.WeekendDate);

                Label lblkFirm = (Label)item.FindControl("lblkFirm");
                lblkFirm.Text = lstPCV[0].Firms.ToString();

                Label lblReservations = (Label)item.FindControl("lblReservations");
                lblReservations.Text = lstPCV[0].ResevationOrders.ToString() + " " + "(" + lstPCV[0].Resevations.ToString() + ")";

                Label lblTotal = (Label)item.FindControl("lblTotal");
                lblTotal.Text = (lstPCV[0].Firms + lstPCV[0].ResevationOrders).ToString();

                Label lblHold = (Label)item.FindControl("lblHold");
                lblHold.Text = lstPCV[0].Holds.ToString();
                //linkHold.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Hold";

                Label lblBalance = (Label)item.FindControl("lblBalance");
                lblBalance.Text = (objProductionCapacity.Capacity - (lstPCV[0].Firms + lstPCV[0].Resevations)).ToString();
                //linkBalance.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Balance";

                //Label lblJackets = (Label)item.FindControl("lblJackets");
                //lblJackets.Text = lstPCV[0].Jackets.ToString();
                ////linkJackets.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Jackets";

                Label lblSamples = (Label)item.FindControl("lblSamples");
                lblSamples.Text = lstPCV[0].Samples.ToString();
                //linkSamples.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Samples";

                Label lblHoliday = (Label)item.FindControl("lblHoliday");
                lblHoliday.Text = objProductionCapacity.NoOfHolidays.ToString();

                Label lbllessfiveitems = (Label)item.FindControl("lbllessfiveitems");
                lbllessfiveitems.Text = lstPCV[0].Less5Items.ToString();
                //linklessfiveitems.NavigateUrl = "ViewOrders.aspx?WeekendDate=" + objProductionCapacity.WeekendDate.ToString("dd/MM/yyyy") + "&Type=Lessfiveitems";

                /*LinkButton linkEditCapacity = (LinkButton)item.FindControl("linkEditCapacity");
                linkEditCapacity.Attributes.Add("pcid", objProductionCapacity.ID.ToString());*/
            }
        }

        protected void dgWeeklySummary_PageIndexChanged(object sender, DataGridPageChangedEventArgs e)
        {
            // Set page index
            if (this.IsNotRefresh)
            {
                this.dgWeeklySummary.CurrentPageIndex = e.NewPageIndex;

                this.PopulateWeeklyCapacities();
            }
            else
            {
                ViewState["PopulateWeeklyCapacities"] = false;
            }

        }

        protected void ddlMonth_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                this.PopulateWeeklyCapacities();
                ViewState["PopulateWeeklyCapacities"] = true;
                ViewState["PopulateOrderDetails"] = false;
                ViewState["PopulateOrderDetailsStatus"] = false;
                ViewState["PopulateWeeklyOrderDetails"] = false;
                ViewState["PopulateDepartmentDetails"] = false;
                ViewState["PopulateEditDepartmentDetails"] = false;
                ViewState["PopulateEditDepartmentDetails"] = false;
            }
            else
            {
                ViewState["PopulateWeeklyCapacities"] = false;
            }
        }

        protected void ddlYear_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {

                this.PopulateWeeklyCapacities();
                ViewState["PopulateWeeklyCapacities"] = true;
                ViewState["PopulateOrderDetails"] = false;
                ViewState["PopulateOrderDetailsStatus"] = false;
                ViewState["PopulateWeeklyOrderDetails"] = false;
                ViewState["PopulateDepartmentDetails"] = false;
                ViewState["PopulateEditDepartmentDetails"] = false;
                ViewState["PopulateEditDepartmentDetails"] = false;

            }
            else
            {
                ViewState["PopulateWeeklyCapacities"] = false;
            }
        }

        protected void ddlOrderDetailStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                int OrderDetailID = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["odid"].ToString());

                if (OrderDetailID > 0)
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                        objOrderDetail.ID = OrderDetailID;
                        objOrderDetail.GetObject();

                        objOrderDetail.Status = int.Parse(((System.Web.UI.WebControls.ListControl)(sender)).SelectedValue);

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                    SetOrderStatus(OrderDetailID);
                }

            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving orderdetail status in ViewOrders.aspx page", ex);
            }


            PopulateDataGrid();
        }

        protected void btnHold_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                ViewState["PopulateWeeklyCapacities"] = false;
                ViewState["PopulateOrderDetails"] = false;
                ViewState["PopulateOrderDetailsStatus"] = false;
                ViewState["PopulateWeeklyOrderDetails"] = false;
                ViewState["PopulateDepartmentDetails"] = false;
                ViewState["PopulateEditDepartmentDetails"] = false;
                ViewState["PopulateEditDepartmentDetails"] = false;

                int order = int.Parse(this.hdnIndimanOrderID.Value);
                int status = int.Parse(this.hdnOrderStatus.Value);

                if (this.LoggedUserRoleName == UserRole.IndimanCoordinator || this.LoggedUserRoleName == UserRole.IndimanAdministrator)
                {
                    if (order > 0 && (status == 18 || status == 24 || status == 25))
                    {
                        try
                        {
                            using (TransactionScope ts = new TransactionScope())
                            {
                                OrderBO objOrder = new OrderBO(this.ObjContext);
                                objOrder.ID = order;
                                objOrder.GetObject();


                                objOrder.Status = 25;

                                this.ObjContext.SaveChanges();
                                ts.Complete();
                            }

                        }
                        catch (Exception ex)
                        {
                            IndicoLogging.log.Error("Error occured while updating Order status lblSubmitOrder_Click", ex);
                        }
                    }
                }
                else if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
                {
                    if (order > 0 && (status == 18 || status == 22 || status == 26))
                    {
                        try
                        {
                            using (TransactionScope ts = new TransactionScope())
                            {
                                OrderBO objOrder = new OrderBO(this.ObjContext);
                                objOrder.ID = order;
                                objOrder.GetObject();


                                objOrder.Status = 23;

                                this.ObjContext.SaveChanges();
                                ts.Complete();
                            }

                        }
                        catch (Exception ex)
                        {
                            IndicoLogging.log.Error("Error occured while updating Order status lblSubmitOrder_Click", ex);
                        }
                    }
                }

            }

            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;
            ViewState["PopulateIndimanSubmit"] = false;

            this.PopulateDataGrid();
        }

        protected void ddlDistributor_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.DisableViewStates();

            // populate client
            ReturnOrdersClientsBO objOrdersClients = new ReturnOrdersClientsBO();
            OrderExtensions.BindList(this.ddlClients, ClientBO.GetDistriburorClients(int.Parse(this.ddlDistributor.SelectedValue)).ToList(), "ID", "Name");

            this.PopulateDataGrid();
        }

        protected void ddlCoordinator_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.DisableViewStates();

            this.PopulateDataGrid();
        }

        protected void ddlClients_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.DisableViewStates();

            this.PopulateDataGrid();
        }

        protected void btnSearchingDate_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(this.txtCheckin.Value) && !string.IsNullOrEmpty(this.txtCheckout.Value))
            {
                this.DisableViewStates();

                PopulateDataGrid();
            }
        }

        protected void btnGenerateBatchLabel_Click(object sender, EventArgs e)
        {
            int id = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["qid"].ToString());

            if (id > 0)
            {
                try
                {
                    string pdfpath = Common.GenerateOdsPdf.CreateBathLabel(id);
                    this.DownloadPDFFile(pdfpath);
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while creating Batch Label in side ViewWeeklyCapacities.aspx", ex);
                }
            }
        }

        protected void btnCHangeResolution_Click(object sender, EventArgs e)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    foreach (GridDataItem item in this.RadGridOrders.Items)
                    {
                        LinkButton btnCHangeResolution = (LinkButton)item.FindControl("btnCHangeResolution");

                        DropDownList ddlResolutionProfile = (DropDownList)item.FindControl("ddlResolutionProfile");

                        int id = int.Parse(((System.Web.UI.WebControls.WebControl)(btnCHangeResolution)).Attributes["vid"].ToString());
                        int resid = int.Parse(ddlResolutionProfile.SelectedValue);

                        if (id > 0)
                        {

                            VisualLayoutBO objVisualLayout = new VisualLayoutBO(this.ObjContext);
                            objVisualLayout.ID = id;
                            objVisualLayout.GetObject();

                            objVisualLayout.ResolutionProfile = resid;


                        }
                    }
                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Changing Resolution Profile from ViewOrders.aspx Page", ex);
            }

            this.PopulateDataGrid();
        }

        protected void btnChangeStatus_Click(object sender, EventArgs e)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    foreach (GridDataItem item in this.RadGridOrders.Items)
                    {
                        LinkButton btnChangeStatus = (LinkButton)item.FindControl("btnChangeStatus");
                        DropDownList ddlOrderDetailStatus = (DropDownList)item.FindControl("ddlOrderDetailStatus");

                        int OrderDetailID = int.Parse(((System.Web.UI.WebControls.WebControl)(btnChangeStatus)).Attributes["odid"].ToString());

                        if (OrderDetailID > 0)
                        {
                            OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                            objOrderDetail.ID = OrderDetailID;
                            objOrderDetail.GetObject();

                            objOrderDetail.Status = int.Parse(ddlOrderDetailStatus.SelectedValue);

                            this.ObjContext.SaveChanges();

                            // change the Order Status, depend on the OrderDetail Status

                            OrderDetailBO objOD = new OrderDetailBO();
                            objOD.Order = objOrderDetail.Order;

                            if (objOD.SearchObjects().Where(m => m.Status == null || m.Status < 1).ToList().Count == 0)
                            {
                                SetOrderStatus(OrderDetailID);
                            }
                        }
                    }

                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving orderdetail status in ViewOrders.aspx page", ex);
            }

            PopulateDataGrid();
        }

        protected void radComboOrderStatus_SelectedIndexChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
        {
            int id = int.Parse(e.Value.ToString());

            if (id > 0)
            {
                ViewState["OrderStatus"] = e.Value;
                ViewState["OrderDetailStatus"] = 0;
            }

            this.PopulateDataGrid();
        }

        protected void radComboOrderDetailStatus_SelectedIndexChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
        {
            if (Session["OrderDetailsView"] != null)
            {
                if (int.Parse(e.Value.ToString()) > 0)
                {
                    ViewState["ODS"] = e.Text;

                    ViewState["OrderDetailStatus"] = e.Value;

                    this.PopulateDataGrid();

                    // this.ReBindGrid();
                }
                else
                {
                    ViewState["OrderDetailStatus"] = e.Value;
                    this.PopulateDataGrid();
                }
            }


        }

        protected void btnCancelled_ServerClick(object sender, EventArgs e)
        {
            int id = int.Parse(this.hdnCancelledOrderDetail.Value);

            if (this.IsNotRefresh)
            {
                if (id > 0)
                {
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            OrderDetailBO objOrderDetail = new OrderDetailBO(this.ObjContext);
                            objOrderDetail.ID = id;
                            objOrderDetail.GetObject();

                            objOrderDetail.Status = 15;

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }

                        this.SetOrderStatus(id);
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while changing the order details status to cancelled", ex);
                    }
                }
            }

            ViewState["PopulateWeeklyCapacities"] = false;
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;

            this.PopulateDataGrid();
        }

        protected void btnExportToExcel_Click(object sender, EventArgs e)
        {
            this.ReBindGrid();

            string alternateText = "ExcelML";
            RadGridOrders.ExportSettings.Excel.Format = (GridExcelExportFormat)Enum.Parse(typeof(GridExcelExportFormat), alternateText);
            RadGridOrders.ExportSettings.IgnorePaging = false;
            RadGridOrders.ExportSettings.ExportOnlyData = true;
            RadGridOrders.ExportSettings.OpenInNewWindow = true;

            RadGridOrders.MasterTableView.ExportToExcel();
        }

        protected void ddlShipmentAddress_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.DisableViewStates();

            this.PopulateDataGrid();
        }

        protected void btnSubmitOrders_Click(object sender, EventArgs e)
        {
            try
            {
                foreach (GridDataItem item in this.RadGridOrders.Items)
                {
                    CheckBox chkGenerateLabel = (CheckBox)item.FindControl("chkGenerateLabel");

                    int order = int.Parse(chkGenerateLabel.Attributes["order"]);

                    if (chkGenerateLabel.Checked)
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            OrderBO objOrder = new OrderBO(this.ObjContext);
                            objOrder.ID = order;
                            objOrder.GetObject();

                            string mailTo = string.Empty;
                            OrderStatus currentOrderStatus = this.GetOrderStatus(objOrder.Status);

                            if (this.LoggedUser.IsDirectSalesPerson && currentOrderStatus == OrderStatus.New)
                            {
                                objOrder.Status = this.GetOrderStatus(OrderStatus.DistributorSubmitted).ID;
                                objOrder.Modifier = this.LoggedUser.ID;
                                objOrder.ModifiedDate = DateTime.Now;

                                this.SendOrderSubmissionEmail(order, this.Distributor.objCoordinator.EmailAddress,
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

                                this.SendOrderSubmissionEmail(order, mailTo, "Imports", true, CustomSettings.CSOCC);
                            }
                            else if (this.LoggedUserRoleName == UserRole.IndimanAdministrator) //  && currentOrderStatus == OrderStatus.CoordinatorSubmitted
                            {
                                SettingsBO objSetting = new SettingsBO();
                                objSetting.Key = CustomSettings.ISOTO.ToString();
                                objSetting = objSetting.SearchObjects().SingleOrDefault();
                                mailTo = objSetting.Value;

                                objOrder.Status = this.GetOrderStatus(OrderStatus.IndimanSubmitted).ID;
                                objOrder.Modifier = this.LoggedUser.ID;
                                objOrder.ModifiedDate = DateTime.Now;

                                this.SendOrderSubmissionEmail(order, mailTo, "Factory User", true, null);
                            }

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while submiting Order", ex);
            }

            Response.Redirect("ViewOrders.aspx");
        }

        protected void ancDownloadNameAndNumberFile_Click(object sender, EventArgs e)
        {
            string file = ((System.Web.UI.HtmlControls.HtmlControl)(sender)).Attributes["downloadUrl"].ToString();
            if (File.Exists(file))
            {
                DownloadFile(file);
            }
        }



        #endregion

        #region Methods

        private void GenerateLabels(List<OrderDetailQtyBO> lstOrderDetailsQty)
        {
            using (TransactionScope ts = new TransactionScope())
            {
                string imageLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Barcode\\" + Guid.NewGuid() + "\\";
                Directory.CreateDirectory(imageLocation);
                string tempPath = imageLocation + "temp.jpg";

                string VLNumber = string.Empty;
                string orderNumber = string.Empty;
                string size = string.Empty;
                string qty = string.Empty;
                string labelText = string.Empty;

                foreach (OrderDetailQtyBO objODQ in lstOrderDetailsQty)
                {
                    size = objODQ.objSize.SizeName;

                    for (int i = 1; i < objODQ.Qty + 1; i++)
                    {
                        qty = i + "/" + objODQ.Qty;
                        VLNumber = objODQ.objOrderDetail.objVisualLayout.NamePrefix;
                        orderNumber = objODQ.objOrderDetail.Order.ToString();

                        Bitmap lblBM = new Bitmap(348, 113);
                        using (Graphics gfx = Graphics.FromImage(lblBM))
                        using (SolidBrush brush = new SolidBrush(Color.White))
                        {
                            gfx.FillRectangle(brush, 0, 0, 378, 113);
                            gfx.SmoothingMode = SmoothingMode.HighQuality;
                            gfx.InterpolationMode = InterpolationMode.HighQualityBicubic;
                            gfx.PixelOffsetMode = PixelOffsetMode.HighQuality;
                        }
                        lblBM.Save(tempPath);

                        //Print Label
                        //labelText = objODQ.ID + "-" /*+ VLNumber + '-' + size +'-'*/ + qty;
                        labelText = objODQ.ID + "-" /*+ VLNumber + '-' + size +'-'*/ + i;
                        GenerateBarcode.GeneratePackingLabel(lblBM, orderNumber, VLNumber, size, qty, objODQ.objOrderDetail.objPattern.NickName, objODQ.objOrderDetail.objOrder.objDistributor.Name, objODQ.objOrderDetail.objOrder.objClient.Name, labelText, imageLocation + labelText.Replace('/', '_') + ".jpg");

                        lblBM.Dispose();
                        File.Delete(tempPath);
                    }
                }

                // string excelFileName = "PackingLabels" + ".xlsx";

                //  CreateExcelDocument excell_app = new CreateExcelDocument(imageLocation, excelFileName, 284, 90, 90, false); // new CreateExcelDocument(imageLocation, excelFileName, 284, 85, 85); NNM
                // print barcodes labels using PDF // NNM
                string pdfpath = GenerateOdsPdf.PrintPolyBagBarcode(imageLocation);

                foreach (string imagePath in Directory.GetFiles(imageLocation, "*.jpg"))
                {
                    File.Delete(imagePath);
                }

                //  this.DownloadExcelFile(imageLocation + excelFileName);
                if (File.Exists(pdfpath))
                {
                    this.DownloadPDFFile(pdfpath);
                }
            }
        }

        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;

            Session["OrderDetailsView"] = null;
            Session["OrderPageCount"] = 0;
            Session["LoadedPageNumber"] = 1;
            Session["totalCount"] = 1;
            Session["OrdersOrderBy"] = true;
            Session["OrderDetailStatus"] = null;
            ViewState["PopulateWeeklyCapacities"] = false;
            ViewState["OrderStatusText"] = null;
            ViewState["OrderDetailStatus"] = 0;

            if (LoggedUserRoleName == UserRole.FactoryAdministrator || LoggedUserRoleName == UserRole.FactoryCoordinator)
            {
                //this.dlFactoryDetails.Visible = true;
                this.btnEditShipped.Visible = true;
                this.btnEditPacked.Visible = true;
                this.btnEditSewing.Visible = true;
                this.btnEditHeatPressed.Visible = true;
                this.btnEditPrint.Visible = true;
                this.btnChangeDetailStatus.Visible = true;
            }

            this.ddlYear.Items.Clear();
            //this.ddlYear.Items.Add(new ListItem("All", "0"));
            List<int> lstYears = (new WeeklyProductionCapacityBO()).SearchObjects().Select(o => o.WeekendDate.Year).Distinct().ToList();
            foreach (int year in lstYears)
            {
                this.ddlYear.Items.Add(new ListItem(year.ToString()));
            }

            var exists = lstYears.Contains(DateTime.Now.Year);

            if (exists)
            {
                this.ddlYear.Items.FindByValue(DateTime.Now.Year.ToString()).Selected = true;
            }
            else
            {
                this.ddlYear.Items.FindByValue("0").Selected = true;
            }

            this.ddlMonth.Items.Clear();
            // this.ddlMonth.Items.Add(new ListItem("All", "0"));
            List<int> lstMonths = (new WeeklyProductionCapacityBO()).SearchObjects().Select(o => o.WeekendDate.Month).Distinct().ToList();
            foreach (int month in lstMonths)
            {
                string monthname = CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(month);
                this.ddlMonth.Items.Add(new ListItem(monthname, month.ToString()));
            }

            //populate Coordinators
            ReturnOrdersCoordinatorsBO objOrdersCoordinators = new ReturnOrdersCoordinatorsBO();
            OrderExtensions.BindList(this.ddlCoordinator, (from o in objOrdersCoordinators.SearchObjects() orderby o.Name select o).ToList(), "ID", "Name");

            // populate Distributors
            //ReturnOrdersDistributorsBO objOrdersDistributors = new ReturnOrdersDistributorsBO();
            //OrderExtensions.BindList(this.ddlDistributor, (from o in objDistributor.SearchObjects() orderby o.Name select o).ToList(), "ID", "Name");

            CompanyBO objDistributor = new CompanyBO();
            objDistributor.IsDistributor = true;
            objDistributor.IsActive = true;
            List<CompanyBO> lstDist = objDistributor.SearchObjects().OrderBy(m => m.Name).ToList();

            ddlDistributor.Items.Clear();
            ddlDistributor.Items.Add(new ListItem("All", "0"));
            foreach (CompanyBO dist in lstDist)
            {
                ddlDistributor.Items.Add(new ListItem(dist.Name, dist.ID.ToString()));
            }

            this.ddlDistributor.ClearSelection();
            this.ddlCoordinator.ClearSelection();

            if (this.LoggedUser.IsDirectSalesPerson)
            {
                this.dvAdminFilters.Visible = false;
                this.ddlDistributor.Items.FindByValue(this.Distributor.ID.ToString()).Selected = true;
                ddlDistributor.Enabled = false;
            }
            else if (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator)
            {
                this.dvAdminFilters.Visible = false;
                this.ddlDistributor.Items.FindByValue(this.LoggedCompany.ID.ToString()).Selected = true;
                ddlDistributor.Enabled = false;
            }
            else if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
            {
                if (this.ddlCoordinator.Items.FindByValue(this.LoggedUser.ID.ToString()) != null)
                {
                    this.ddlCoordinator.Items.FindByValue(this.LoggedUser.ID.ToString()).Selected = true;
                }
                //this.ddlCoordinator.Enabled = false;
            }

            // populate client
            ReturnOrdersClientsBO objOrdersClients = new ReturnOrdersClientsBO();
            OrderExtensions.BindList(this.ddlClients, ClientBO.GetDistriburorClients(int.Parse(this.ddlDistributor.SelectedValue)).ToList(), "ID", "Name");

            //populate shipment address
            //ReturnOrdersShipmentAddressViewBO objReturnOrdersShipmentAddress = new ReturnOrdersShipmentAddressViewBO();
            //OrderExtensions.BindList(this.ddlShipmentAddress, (from o in objReturnOrdersShipmentAddress.SearchObjects() orderby o.Name select o).ToList(), "ID", "Name");

            this.ddlMonth.Items.FindByValue(DateTime.Now.Month.ToString()).Selected = true;

            //populate Weekly Capacities button
            this.btnWeeklyCapacity.Visible = (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;
            this.btnGenerateLabels.Visible = false;
            //(this.LoggedUserRoleName == UserRole.IndicoAdministrator
            //|| this.LoggedUserRoleName == UserRole.IndimanAdministrator
            //|| this.LoggedUserRoleName == UserRole.FactoryAdministrator);

            // hide coulumns from the Grid
            this.RadGridOrders.MasterTableView.GetColumn("PaymentMethod").Display = false;
            this.RadGridOrders.MasterTableView.GetColumn("ShipmentMethod").Display = false;
            //this.RadGridOrders.MasterTableView.GetColumn("WeeklyShipment").Display = false;
            //this.RadGridOrders.MasterTableView.GetColumn("CourierDelivery").Display = false;
            //this.RadGridOrders.MasterTableView.GetColumn("AdelaideWareHouse").Display = false;
            //this.RadGridOrders.MasterTableView.GetColumn("ShippingAddress").Display = false;
            //this.RadGridOrders.MasterTableView.GetColumn("DestinationPort").Display = false;
            //this.RadGridOrders.MasterTableView.GetColumn("FollowingAddress").Display = false;
            this.RadGridOrders.MasterTableView.GetColumn("Creator").Display = false;
            this.RadGridOrders.MasterTableView.GetColumn("CreatedDate").Display = false;
            this.RadGridOrders.MasterTableView.GetColumn("Modifier").Display = false;
            this.RadGridOrders.MasterTableView.GetColumn("ModifiedDate").Display = false;
            this.RadGridOrders.MasterTableView.GetColumn("ResolutionProfile").Display = (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator) ? true : false;
            //this.RadGridOrders.MasterTableView.GetColumn("QA").Display = (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;
            //this.RadGridOrders.MasterTableView.GetColumn("ODS").Display = (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;
            this.RadGridOrders.MasterTableView.GetColumn("DetailStatus").Display = (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;
            this.RadGridOrders.MasterTableView.GetColumn("Distributor").Display = (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;
            this.RadGridOrders.MasterTableView.GetColumn("check").Display = (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;

            //this.btnChangeDetailStatus.Visible = (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator) ? true : false;
            //this.ddlDistributor.Visible = (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;
            //this.ddlCoordinator.Visible = (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;
            //this.lblDistributor.Visible = (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;
            //this.lblCoordinator.Visible = (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;

            //this.datepicker.Visible = (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;

            //Populate Order statuses for sorting
            this.populateOrderStatus();

            //if (this.LoggedUser.IsDirectSalesPerson)
            //{
            //    this.ddlDistributor.Items.FindByValue(this.Distributor.ID.ToString()).Selected = true;
            //}

            this.PopulateDataGrid();
        }

        private void PopulateDataGrid()
        {
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateWeeklyCapacities"] = false;
            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvEmptyContentFadmin.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;
            this.dvEmptyOrders.Visible = false;

            // order status text

            if (ViewState["OrderStatus"] != null)
            {
                this.ddlStatus.Items.FindByValue(this.ddlStatus.SelectedValue).Selected = false;
                this.ddlStatus.Items.FindByValue(ViewState["OrderStatus"].ToString()).Selected = true;
                ViewState["OrderStatus"] = null;
            }

            //this.ddlStatus.Items.FindByValue((ViewState["OrderStatus"] != null) ? ViewState["OrderStatus"].ToString() : this.ddlStatus.SelectedValue).Selected = true;

            // Search text
            string searchText = this.txtSearch.Text.ToLower().Trim();

            string selecteddate1 = "NULL";
            string selecteddate2 = "NULL";

            if (!string.IsNullOrEmpty(this.txtCheckin.Value) && !string.IsNullOrEmpty(this.txtCheckout.Value))
            {
                selecteddate1 = "'" + Convert.ToDateTime(this.txtCheckin.Value).ToString("yyyyMMdd") + "'";
                selecteddate2 = "'" + Convert.ToDateTime(this.txtCheckout.Value).ToString("yyyyMMdd") + "'";
            }

            List<OrdersView> lstOrderDetails = new List<OrdersView>();
            string status = string.Empty;
            int totalCount = 0;

            if (WeekEndDate != null && Type != null && Type != string.Empty)
            {
                int offset = WeekEndDate.DayOfWeek - DayOfWeek.Monday;

                DateTime lastMonday = WeekEndDate.AddDays(-offset);
                DateTime nextSunday = lastMonday.AddDays(6);
                int shipmentAddress = 0; // (int.Parse(this.ddlShipmentAddress.SelectedValue) > 0) ? int.Parse(this.ddlShipmentAddress.SelectedItem.Value) : 0;

                this.datepicker.Visible = false;
                //DateTime sevendaysEarlier = WeekEndDate.AddDays(-6);
                this.labelTotal.Visible = true;
                int count = 0;

                List<ReturnWeeklyOrderDetailQtysViewBO> lst = OrderDetailQtyBO.WeeklyOrderDetailQtys(this.WeekEndDate);

                foreach (ReturnWeeklyOrderDetailQtysViewBO item in lst)
                {
                    count = count + item.Quantity.Value;
                }

                //this.lblTotal.Text = count.ToString();

                if (!(this.CheckWeekEndDate(WeekEndDate) && this.CheckType(Type)))
                {
                    this.dvEmptyOrders.Visible = true;
                    this.litEmptyOrders.Text = "Invalid weekend date " + WeekEndDate.ToShortDateString() + " or type " + Type + " ";

                    return;
                }
                else
                {
                    #region dashboarddetails

                    //    status = (this.ddlStatus.SelectedValue == "AllSubmits") ? "22, 31, 26" : (int.Parse(this.ddlStatus.SelectedValue) > 0) ? this.ddlStatus.SelectedItem.Value : string.Empty;

                    //    switch (this.Type)
                    //    {
                    //        case "Firm":
                    //            this.litHeaderText.Text = "" + Type + " orders for period " + lastMonday.ToShortDateString() + " - " + nextSunday.ToShortDateString() + "";
                    //            if ((searchText != string.Empty) && (searchText != "search"))
                    //            {
                    //                lstOrderDetails = OrderBO.GetWeeklyFirmOrders(this.WeekEndDate, searchText, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out totalCount, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);
                    //            }
                    //            else
                    //            {
                    //                lstOrderDetails = OrderBO.GetWeeklyFirmOrders(this.WeekEndDate, string.Empty, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out totalCount, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);

                    //                if (lstOrderDetails.Count == 0)
                    //                {
                    //                    this.dvEmptyOrders.Visible = true;
                    //                    litEmptyOrders.Text = "There are no " + Type.ToLower() + " orders";
                    //                    return;
                    //                }
                    //            }
                    //            break;
                    //        case "Reservations":
                    //            this.litHeaderText.Text = "" + Type + " orders for period " + lastMonday.ToShortDateString() + " - " + nextSunday.ToShortDateString() + "";
                    //            if ((searchText != string.Empty) && (searchText != "search"))
                    //            {
                    //                lstOrderDetails = OrderBO.GetWeeklyReservationOrders(this.WeekEndDate, searchText, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out totalCount, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);
                    //            }
                    //            else
                    //            {
                    //                lstOrderDetails = OrderBO.GetWeeklyReservationOrders(this.WeekEndDate, string.Empty, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out totalCount, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);

                    //                if (lstOrderDetails.Count == 0)
                    //                {
                    //                    this.dvEmptyOrders.Visible = true;
                    //                    litEmptyOrders.Text = "There are no " + Type.ToLower() + " orders";
                    //                    return;
                    //                }
                    //            }
                    //            break;
                    //        case "Lessfiveitems":
                    //            this.litHeaderText.Text = "" + "Less Five Items" + " orders for period " + lastMonday.ToShortDateString() + " - " + nextSunday.ToShortDateString() + "";
                    //            if ((searchText != string.Empty) && (searchText != "search"))
                    //            {
                    //                lstOrderDetails = OrderBO.GetWeeklyLessFiveItemOrders(this.WeekEndDate, searchText, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out totalCount, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);
                    //            }
                    //            else
                    //            {
                    //                lstOrderDetails = OrderBO.GetWeeklyLessFiveItemOrders(this.WeekEndDate, string.Empty, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out totalCount, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);

                    //                if (lstOrderDetails.Count == 0)
                    //                {
                    //                    this.dvEmptyOrders.Visible = true;
                    //                    litEmptyOrders.Text = "There are no " + "less five items"/*Type.ToLower()*/ + " orders";
                    //                    return;
                    //                }
                    //            }
                    //            break;
                    //        case "Jackets":
                    //            this.litHeaderText.Text = "" + "Jackets" + " orders for period " + lastMonday.ToShortDateString() + " - " + nextSunday.ToShortDateString() + "";
                    //            if ((searchText != string.Empty) && (searchText != "search"))
                    //            {
                    //                lstOrderDetails = OrderBO.GetWeeklyJacketOrders(this.WeekEndDate, searchText, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out totalCount, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);
                    //            }
                    //            else
                    //            {
                    //                lstOrderDetails = OrderBO.GetWeeklyJacketOrders(this.WeekEndDate, string.Empty, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out totalCount, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);

                    //                if (lstOrderDetails.Count == 0)
                    //                {
                    //                    this.dvEmptyOrders.Visible = true;
                    //                    litEmptyOrders.Text = "There are no " + Type.ToLower() + " orders";
                    //                    return;
                    //                }
                    //            }
                    //            break;
                    //        case "Samples":
                    //            this.litHeaderText.Text = "" + Type + " orders for period " + lastMonday.ToShortDateString() + " - " + nextSunday.ToShortDateString() + "";
                    //            if ((searchText != string.Empty) && (searchText != "search"))
                    //            {
                    //                lstOrderDetails = OrderBO.GetWeeklySampleOrders(this.WeekEndDate, searchText, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out totalCount, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);
                    //            }
                    //            else
                    //            {
                    //                lstOrderDetails = OrderBO.GetWeeklySampleOrders(this.WeekEndDate, searchText, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out totalCount, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);

                    //                if (lstOrderDetails.Count == 0)
                    //                {
                    //                    this.dvEmptyOrders.Visible = true;
                    //                    litEmptyOrders.Text = "There are no sample orders";
                    //                    return;
                    //                }
                    //            }
                    //            break;
                    //        case "Total":
                    //            this.litHeaderText.Text = "" + Type + " orders  for period " + lastMonday.ToShortDateString() + " - " + nextSunday.ToShortDateString() + "";
                    //            if ((searchText != string.Empty) && (searchText != "search"))
                    //            {
                    //                List<OrderDetailsView> lstOrderDetails1 = OrderBO.GetWeeklyFirmOrders(this.WeekEndDate, searchText, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out totalCount, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);

                    //                List<OrderDetailsView> lstOrderDetails2 = OrderBO.GetWeeklyReservationOrders(this.WeekEndDate, searchText, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out totalCount, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);

                    //                foreach (OrderDetailsView obj in lstOrderDetails1)
                    //                {
                    //                    lstOrderDetails.Add(obj);
                    //                }
                    //                foreach (OrderDetailsView obj in lstOrderDetails2)
                    //                {
                    //                    lstOrderDetails.Add(obj);
                    //                }
                    //            }
                    //            else
                    //            {
                    //                int total1 = 0;
                    //                int total2 = 0;

                    //                List<OrderDetailsView> lstOrderDetails1 = OrderBO.GetWeeklyFirmOrders(this.WeekEndDate, searchText, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out total1, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, shipmentAddress);
                    //                List<OrderDetailsView> lstOrderDetails2 = OrderBO.GetWeeklyReservationOrders(this.WeekEndDate, searchText, status, int.Parse(SortExpression), OrderBy, pageIndex, dgPageSize, out total2, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, shipmentAddress);

                    //                totalCount = total1 + total2;

                    //                if (lstOrderDetails1.Count > 0 || lstOrderDetails2.Count > 0)
                    //                {
                    //                    foreach (OrderDetailsView obj in lstOrderDetails1)
                    //                    {
                    //                        lstOrderDetails.Add(obj);
                    //                    }

                    //                    foreach (OrderDetailsView obj in lstOrderDetails2)
                    //                    {
                    //                        lstOrderDetails.Add(obj);
                    //                    }
                    //                }
                    //                else
                    //                {
                    //                    this.dvEmptyOrders.Visible = true;
                    //                    litEmptyOrders.Text = "There are no " + Type.ToLower() + " orders";
                    //                    return;
                    //                }
                    //            }
                    //            break;
                    //        case "Hold":
                    //            this.litHeaderText.Text = "" + Type + " orders  for period " + lastMonday.ToShortDateString() + " - " + nextSunday.ToShortDateString() + "";
                    //            if ((searchText != string.Empty) && (searchText != "search"))
                    //            {
                    //                lstOrderDetails = OrderBO.GetWeeklyHoldOrders(this.WeekEndDate, searchText, status, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);
                    //            }
                    //            else
                    //            {
                    //                lstOrderDetails = OrderBO.GetWeeklyHoldOrders(this.WeekEndDate, searchText, status, (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? this.ddlCoordinator.SelectedItem.Text : string.Empty, (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? this.ddlDistributor.SelectedItem.Text : string.Empty, (int.Parse(this.ddlClients.SelectedValue) > 0) ? this.ddlClients.SelectedItem.Text : string.Empty, shipmentAddress);

                    //                if (lstOrderDetails.Count == 0)
                    //                {
                    //                    this.dvEmptyOrders.Visible = true;
                    //                    litEmptyOrders.Text = "There are no " + Type.ToLower() + " orders";
                    //                    return;
                    //                }
                    //            }
                    //            break;
                    //        default:
                    //            break;
                    //    }
                }
                #endregion
            }
            else
            {
                this.datepicker.Visible = (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator) ? false : true;

                searchText = (searchText != "search" || searchText != string.Empty) ? searchText : string.Empty;

                int client = (int.Parse(this.ddlClients.SelectedValue) > 0) ? int.Parse(this.ddlClients.SelectedItem.Value) : 0;
                int distributor = (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? int.Parse(this.ddlDistributor.SelectedItem.Value) : 0;
                int coordinator = (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? int.Parse(this.ddlCoordinator.SelectedItem.Value) : 0;
                int shipmentAddress = 0;
                int companyid = 0;

                if (this.LoggedUser.IsDirectSalesPerson)
                {
                    status = (this.ddlStatus.SelectedValue == "AllSubmits") ? "22, 31, 26" : (int.Parse(this.ddlStatus.SelectedValue) > 0) ? this.ddlStatus.SelectedItem.Value : "18,19,24,23,22,25,26,31";
                    coordinator = this.Distributor.Coordinator ?? 0;
                }
                else if (this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator)
                {
                    status = (this.ddlStatus.SelectedValue == "AllSubmits") ? "22, 31, 26" : (int.Parse(this.ddlStatus.SelectedValue) > 0) ? this.ddlStatus.SelectedItem.Value : "18,26,25,24,27,23,19,20,22,21,31";
                }
                else if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
                {
                    status = (this.ddlStatus.SelectedValue == "AllSubmits") ? "22, 31, 26" : (int.Parse(this.ddlStatus.SelectedValue) > 0) ? this.ddlStatus.SelectedItem.Value : "18,19,24,23,22,25,26,31";
                }
                else if (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator)
                {
                    status = (this.ddlStatus.SelectedValue == "AllSubmits") ? "22, 31, 26" : (int.Parse(this.ddlStatus.SelectedValue) > 0) ? this.ddlStatus.SelectedItem.Value : "27,26,19,20,21,28";
                }
                else if (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator)
                {
                    status = (this.ddlStatus.SelectedValue == "AllSubmits") ? "22, 31, 26" : (int.Parse(this.ddlStatus.SelectedValue) > 0) ? this.ddlStatus.SelectedItem.Value : "18,22,26,19,20,21";
                    companyid = this.LoggedCompany.ID;
                }

                //lstOrderDetails = OrderBO.GetOrders(searchText, companyid, status, coordinator, distributor, client, selecteddate1, selecteddate2, shipmentAddress);

                using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
                {
                    connection.Open();

                    lstOrderDetails = connection.Query<OrdersView>(" EXEC	[dbo].[SPC_ViewOrderDetails] " +
                                                                            "@P_SearchText = '" + searchText + "'," +
                                                                            "@P_LogCompanyID = " + companyid + "," +
                                                                            "@P_Status = '" + status + "'," +
                                                                            "@P_Coordinator = " + coordinator + "," +
                                                                            "@P_Distributor = " + distributor + "," +
                                                                            "@P_Client = " + client + "," +
                                                                            "@P_SelectedDate1 = " + selecteddate1 + "," +
                                                                            "@P_SelectedDate2 = " + selecteddate1 + "," +
                                                                            "@P_DistributorClientAddress = " + shipmentAddress).ToList();

                    connection.Close();
                }
            }

            if (ViewState["OrderDetailStatus"] != null && int.Parse(ViewState["OrderDetailStatus"].ToString()) > 0)
            {
                if (ViewState["ODS"] != null)
                {
                    string staus = ViewState["ODS"].ToString();
                    lstOrderDetails = lstOrderDetails.Where(o => o.OrderDetailStatus.ToLower().Trim().Contains(staus.ToLower().Trim())).ToList();
                }
            }

            if (lstOrderDetails.Count > 0)
            {
                //List<IGrouping<int, OrderDetailsView>> lstOrdersGroup = lstOrderDetails.GroupBy(o => (int)o.Order).ToList();

                this.RadGridOrders.AllowPaging = (lstOrderDetails.Count > this.RadGridOrders.PageSize);
                // if use CustomePaging
                //this.RadGridOrders.VirtualItemCount = (totalCount == 0) ? TotalCount : totalCount;
                //this.RadGridOrders.AllowCustomPaging = true;

                this.RadGridOrders.Columns[15].Visible = ((this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator))
                    ? false : true;

                //if (this.LoggedUser.IsDirectSalesPerson)
                //{
                //    lstOrderDetails = lstOrderDetails.Where(m => m.CreatorID.Value == this.LoggedUser.ID).ToList();
                //}

                lstOrderDetails = lstOrderDetails.OrderByDescending(m => m.Order).ToList();
                lstOrderDetails.ForEach(m => m.EditedPrice = m.EditedPrice * m.Quantity); //(m.EditedPrice ?? 0) * (1 + (decimal)m.Surcharge / (decimal)100) * (m.Quantity ?? 0));
                Session["OrderDetailsView"] = lstOrderDetails;

                var orders = lstOrderDetails.GroupBy(i => i.Order);
                foreach (var o in orders)
                {
                    var i = 1;
                    var vls = o.OrderByDescending(t => t.Order).ToList();
                    foreach (var vl in vls)
                    {
                        vl.Order = vl.Order + "-" + i;
                        i++;
                    }
                }
                lstOrderDetails = lstOrderDetails.OrderBy(d => d.Order).ToList();

                this.RadGridOrders.DataSource = lstOrderDetails;
                this.RadGridOrders.DataBind();

                if (this.LoggedUser.IsDirectSalesPerson)
                {
                    RadGridOrders.MasterTableView.GetColumn("Coordinator").Display = false;
                    RadGridOrders.MasterTableView.GetColumn("Distributor").Display = false;
                }

                if (this.LoggedUserRoleName == UserRole.FactoryAdministrator)
                {
                    RadGridOrders.MasterTableView.GetColumn("PrintMeasurements").Display = true;
                    RadGridOrders.MasterTableView.GetColumn("PrintODS").Display = true;
                }
                else
                {
                    RadGridOrders.MasterTableView.GetColumn("TCAccepted").Display = true;
                }

                //TotalCount = (totalCount == 0) ? TotalCount : totalCount;

                // Session["OrderPageCount"] = (TotalCount % dgPageSize == 0) ? (TotalCount / dgPageSize) : ((TotalCount / dgPageSize) + 1);

                this.dvDataContent.Visible = true;
                this.btnAddOrder.Visible = btnSubmitOrders.Visible = this.RadGridOrders.Columns[0].Visible = (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator) ? false : true;

                //this.dvNoSearchCriteria.Visible = false;
                //this.lblNoSearchText.Text = string.Empty;
                //this.lblTotal.Text = Qty.ToString();
            }
            else if ((searchText != string.Empty && searchText != "search") || ((int.Parse(this.ddlClients.SelectedValue)) != 0) || ((int.Parse(this.ddlCoordinator.SelectedValue)) != 0) || ((int.Parse(this.ddlDistributor.SelectedValue)) != 0) || (!string.IsNullOrEmpty(this.txtCheckin.Value) && !string.IsNullOrEmpty(this.txtCheckout.Value)) || (int.Parse(this.ddlStatus.SelectedValue) > 0)) // (((int.Parse(this.ddlStatus.SelectedValue)) != 18) || ((int.Parse(this.ddlStatus.SelectedValue)) != 26) || ((int.Parse(this.ddlStatus.SelectedValue)) != 0)))
            {
                if (this.LoggedUser.IsDirectSalesPerson)
                {
                    this.lblSearchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty) + " Filter by Status <strong>" + this.ddlStatus.SelectedItem.Text + "</strong> Distributor <strong>" + this.ddlDistributor.SelectedItem.Text + "</strong> Client <strong>" + this.ddlClients.SelectedItem.Text + "</strong> Order Date From <strong>" + this.txtCheckin.Value + "</strong> To <strong>" + this.txtCheckout.Value + "</strong>";
                }
                else
                {
                    this.lblSearchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty) + " Filter by Status <strong>" + this.ddlStatus.SelectedItem.Text + "</strong> Coordinator <strong>" + this.ddlCoordinator.SelectedItem.Text + "</strong> Distributor <strong>" + this.ddlDistributor.SelectedItem.Text + "</strong> Client <strong>" + this.ddlClients.SelectedItem.Text + "<strong>" + " Order Date From <strong>" + this.txtCheckin.Value + "</strong> To <strong>" + this.txtCheckout.Value + "</strong>";
                }

                this.btnAddOrder.Visible = (this.LoggedUserRoleName == UserRole.FactoryAdministrator) ? false : true;
                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;

                //this.dvNoSearchCriteria.Visible = false;
                //this.lblNoSearchText.Text = string.Empty;
            }
            else
            {
                if (this.LoggedUserRoleName == UserRole.FactoryAdministrator)
                {
                    this.dvEmptyContentFadmin.Visible = true;
                    this.btnAddOrder.Visible = false;
                }
                else
                {
                    //List<OrderBO> lstOrders = (new OrderBO()).GetAllObject().ToList();

                    //this.dvEmptyContent.Visible = (lstOrderDetails.Count > 0) ? false : true;
                    //this.dvDataContent.Visible = (lstOrderDetails.Count > 0) ? true : false;
                    //this.btnAddOrder.Visible = (lstOrderDetails.Count > 0) ? true : false;
                }
            }

            this.RadGridOrders.Visible = (lstOrderDetails.Count > 0);
            this.btnExportToExcel.Visible = (lstOrderDetails.Count > 0);

            ViewState["OrderStatus"] = null;
        }

        private bool CheckWeekEndDate(DateTime date)
        {
            List<WeeklyProductionCapacityBO> lstWeeklyProductionCapacity = new List<WeeklyProductionCapacityBO>();
            lstWeeklyProductionCapacity = (from o in (new WeeklyProductionCapacityBO()).GetAllObject().ToList()
                                           where o.WeekendDate == date
                                           select o).ToList();

            return (lstWeeklyProductionCapacity.Count > 0) ? true : false;
        }

        private bool CheckType(string type)
        {
            List<string> lstTypes = new List<string>() { "Firm", "Reservations", "Total", "Hold", "Balance", "Jackets", "Samples", "Lessfiveitems" };

            return ((from o in lstTypes
                     where o.ToLower() == type.ToLower()
                     select o).ToList().Count > 0) ? true : false;
        }

        private void populateOrderStatus()
        {
            List<OrderStatusBO> lstOrderStatus = new List<OrderStatusBO>();
            lstOrderStatus = new OrderStatusBO().SearchObjects().OrderBy(o => o.Sequence).ToList();

            if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
            {
                lstOrderStatus = (from o in lstOrderStatus.Where(o => this.GetOrderStatus(o.ID) == OrderStatus.New ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.IndicoHold ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.IndicoSubmitted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.IndimanSubmitted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.DistributorSubmitted ||
                                                                                              this.GetOrderStatus(o.ID) == OrderStatus.CoordinatorSubmitted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.InProgress ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.Completed ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.PartialyCompleted)
                                  select o).ToList();
            }
            else if (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator)
            {
                lstOrderStatus = (from o in lstOrderStatus.Where(o => this.GetOrderStatus(o.ID) == OrderStatus.New ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.DistributorSubmitted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.CoordinatorSubmitted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.IndimanSubmitted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.InProgress ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.Completed ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.Cancelled ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.PartialyCompleted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.FactoryHold)
                                  select o).ToList();
            }
            else if (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator)
            {
                lstOrderStatus = (from o in lstOrderStatus.Where(o => this.GetOrderStatus(o.ID) == OrderStatus.IndimanSubmitted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.InProgress ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.PartialyCompleted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.Completed ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.FactoryHold ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.Cancelled)
                                  select o).ToList();
            }

            // Populate Statuses
            this.ddlStatus.Items.Clear();
            foreach (OrderStatusBO orderStatus in lstOrderStatus)
            {
                this.ddlStatus.Items.Add(new ListItem(orderStatus.Name, (orderStatus.ID).ToString()));
            }

            this.ddlStatus.Items.Add(new ListItem("All", "0"));
            this.ddlStatus.Items.Add(new ListItem("All Submits", "AllSubmits"));

            // set default value to poulate DataGrid
            if (this.LoggedUser.IsDirectSalesPerson)
            {
                this.ddlStatus.Items.FindByValue("18").Selected = true;
            }
            else if ((this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator) && this.WeekEndDate == new DateTime(1100, 1, 1))
            {
                this.ddlStatus.Items.FindByValue("22").Selected = true;
            }
            else if ((this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator) && this.WeekEndDate == new DateTime(1100, 1, 1))
            {
                this.ddlStatus.Items.FindByValue("31").Selected = true;
            }
            else if ((this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator) && this.WeekEndDate == new DateTime(1100, 1, 1))
            {
                this.ddlStatus.Items.FindByValue("26").Selected = true;
            }
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
                        OrderBO objOrder = new OrderBO(this.ObjContext);
                        objOrder.ID = objOD.Order;
                        objOrder.GetObject();

                        objOrder.Status = odStatus;

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
            }
        }

        private void PopulateWeeklyCapacities()
        {
            // Hide Controls
            this.dvEmptyWeeklyCapacities.Visible = false;

            // get the first monday of the week
            var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
            var monday = DateTime.Today.AddDays(-daysTillMonday);

            // get the first monday  of specific month
            DateTime dt = DateTime.Now;
            if (this.ddlMonth.SelectedIndex > -1 && this.ddlYear.SelectedIndex > -1)
            {
                dt = new DateTime(int.Parse(this.ddlYear.SelectedValue), int.Parse(this.ddlMonth.SelectedValue), 1);
                dt = dt.AddDays(1);
            }

            // Search text
            string searchText = this.txtSearch.Text.ToLower().Trim();

            // Populate Item Attribute
            WeeklyProductionCapacityBO objProductionCapacity = new WeeklyProductionCapacityBO();

            // Sort by condition
            List<WeeklyProductionCapacityBO> lstProductionCapacity = new List<WeeklyProductionCapacityBO>();

            if (this.ddlYear.SelectedIndex > -1)
            {
                if (int.Parse(this.ddlMonth.SelectedValue) == DateTime.Now.Month)
                {
                    lstProductionCapacity = objProductionCapacity.SearchObjects().AsQueryable().Where(o => o.WeekendDate >= monday && o.WeekendDate.Year >= int.Parse(this.ddlYear.SelectedItem.Text)).OrderBy(o => o.WeekendDate).ToList<WeeklyProductionCapacityBO>();
                }
            }
            else if (this.ddlYear.SelectedIndex == -1)
            {
                lstProductionCapacity = objProductionCapacity.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<WeeklyProductionCapacityBO>();
            }
            else
            {
                lstProductionCapacity = objProductionCapacity.SearchObjects().AsQueryable().Where(o => o.WeekendDate.Date >= monday).OrderBy(o => o.WeekendDate).ToList<WeeklyProductionCapacityBO>();
            }

            if (this.ddlMonth.SelectedIndex > -1)
            {
                if (int.Parse(this.ddlMonth.SelectedValue) != DateTime.Now.Month)
                {
                    lstProductionCapacity = objProductionCapacity.SearchObjects().AsQueryable().Where(o => o.WeekendDate >= dt).OrderBy(o => o.WeekendDate).ToList<WeeklyProductionCapacityBO>();
                }

            }
            else if (this.ddlMonth.SelectedIndex == -1)
            {
                lstProductionCapacity = lstProductionCapacity.ToList<WeeklyProductionCapacityBO>();
            }


            if (lstProductionCapacity.Count > 0)
            {
                this.dgWeeklySummary.AllowPaging = (lstProductionCapacity.Count > this.dgWeeklySummary.PageSize);
                this.dgWeeklySummary.DataSource = lstProductionCapacity;
                this.dgWeeklySummary.DataBind();

                List<OrdersView> lst = (List<OrdersView>)Session["OrderDetailsView"];

                this.dvDataContent.Visible = (lst != null && lst.Count > 0) ? true : false; //true;
            }
            else
            {
                this.dvEmptyWeeklyCapacities.Visible = true;
            }

            this.dgWeeklySummary.Visible = (lstProductionCapacity.Count > 0);
        }

        private void DisableViewStates()
        {
            ViewState["PopulateWeeklyCapacities"] = false;
            ViewState["PopulateOrderDetails"] = false;
            ViewState["PopulateOrderDetailsStatus"] = false;
            ViewState["PopulateWeeklyOrderDetails"] = false;
            ViewState["PopulateDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;
            ViewState["PopulateEditDepartmentDetails"] = false;
        }

        private void ReBindGrid()
        {
            if (Session["OrderDetailsView"] != null)
            {
                RadGridOrders.DataSource = (List<OrdersView>)Session["OrderDetailsView"];
                RadGridOrders.DataBind();
            }
        }

        private List<OrderStatusBO> PopulateDataGridOrderStatus()
        {
            List<OrderStatusBO> lstOrderStatus = new List<OrderStatusBO>();

            if (this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator)
            {
                lstOrderStatus = (from o in (new OrderStatusBO()).SearchObjects().Where(o => this.GetOrderStatus(o.ID) == OrderStatus.New ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.IndimanHold ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.IndimanSubmitted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.IndicoSubmitted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.InProgress ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.Completed ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.PartialyCompleted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.FactoryHold ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.DistributorSubmitted).OrderBy(o => o.Name)
                                  select o).ToList();
            }
            else if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
            {
                lstOrderStatus = (from o in (new OrderStatusBO()).SearchObjects().Where(o => this.GetOrderStatus(o.ID) == OrderStatus.New ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.IndicoHold ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.IndicoSubmitted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.DistributorSubmitted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.InProgress ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.Completed ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.PartialyCompleted).OrderBy(o => o.Name)
                                  select o).ToList();
            }
            else if (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator)
            {
                lstOrderStatus = (from o in (new OrderStatusBO()).SearchObjects().Where(o => this.GetOrderStatus(o.ID) == OrderStatus.New ||
                                                                                           this.GetOrderStatus(o.ID) == OrderStatus.DistributorSubmitted ||
                                                                                           this.GetOrderStatus(o.ID) == OrderStatus.IndimanSubmitted ||
                                                                                           this.GetOrderStatus(o.ID) == OrderStatus.InProgress ||
                                                                                           this.GetOrderStatus(o.ID) == OrderStatus.Completed ||
                                                                                           this.GetOrderStatus(o.ID) == OrderStatus.Cancelled ||
                                                                                           this.GetOrderStatus(o.ID) == OrderStatus.PartialyCompleted ||
                                                                                           this.GetOrderStatus(o.ID) == OrderStatus.FactoryHold).OrderBy(o => o.Name)
                                  select o).ToList();
            }
            else if (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator)
            {
                lstOrderStatus = (from o in (new OrderStatusBO()).SearchObjects().Where(o => this.GetOrderStatus(o.ID) == OrderStatus.IndimanSubmitted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.InProgress ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.PartialyCompleted ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.Completed ||
                                                                                             this.GetOrderStatus(o.ID) == OrderStatus.FactoryHold).OrderBy(o => o.Name)
                                  select o).ToList();
            }



            return lstOrderStatus;
        }

        #endregion
    }
}
