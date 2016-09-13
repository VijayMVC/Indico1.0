using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;

using Indico.BusinessObjects;
using Indico.Common;
using System.Web.UI.HtmlControls;

namespace Indico
{
    public partial class ViewWeekDetails : IndicoPage
    {
        #region Fields
        private DateTime qpWeekEndDate = new DateTime(1100, 1, 1);
        private int total = 0;
        private string qpCompany = null;
        private int shipmentMode = -1;
        #endregion

        #region Properties

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

        protected string CompanyName
        {
            get
            {
                if (qpCompany != null)
                    return qpCompany;
                qpCompany = null;
                if (Request.QueryString["CompanyName"] != null)
                {
                    qpCompany = Request.QueryString["CompanyName"].ToString();
                }
                return qpCompany;
            }
            set
            {
                qpCompany = value;
            }
        }

        protected int ShipemtMode
        {
            get
            {
                if (shipmentMode > -1)
                    return shipmentMode;

                shipmentMode = 0;
                if (Request.QueryString["sm"] != null)
                {
                    shipmentMode = Convert.ToInt32(Request.QueryString["sm"].ToString());
                }
                return shipmentMode;
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
        
        protected void rptShipmentOrders_OnItemBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            total = 0;

            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, ReturnWeeklyAddressDetailsBO>)
            {
                List<ReturnWeeklyAddressDetailsBO> lstOrderDetailsGroup = ((IGrouping<int, ReturnWeeklyAddressDetailsBO>)item.DataItem).ToList();

                if (lstOrderDetailsGroup[0].ShipmentMode != null)
                {
                    Literal litComapny = (Literal)item.FindControl("litComapny");
                    litComapny.Text = lstOrderDetailsGroup[0].CompanyName;

                    Literal litDate = (Literal)item.FindControl("litDate");
                    litDate.Text = Convert.ToDateTime(lstOrderDetailsGroup[0].ShipmentDate.ToString()).ToString("dd MMMM yyyy");

                    Literal litAddress = (Literal)item.FindControl("litAddress");
                    litAddress.Text = lstOrderDetailsGroup[0].Address;

                    Literal litSuberb = (Literal)item.FindControl("litSuberb");
                    litSuberb.Text = lstOrderDetailsGroup[0].Suberb;

                    Literal litPostCode = (Literal)item.FindControl("litPostCode");
                    litPostCode.Text = lstOrderDetailsGroup[0].State + " " + lstOrderDetailsGroup[0].PostCode + " , " + lstOrderDetailsGroup[0].Country;

                    // Literal litCountry = (Literal)item.FindControl("litCountry");
                    //litCountry.Text = lstOrderDetailsGroup[0].Country;

                    Literal litContectDetails = (Literal)item.FindControl("litContectDetails");
                    litContectDetails.Text = lstOrderDetailsGroup[0].ContactDetails;

                    Repeater rptMode = (Repeater)item.FindControl("rptMode");
                    List<IGrouping<int, ReturnWeeklyAddressDetailsBO>> lstShipmentModeGroup = lstOrderDetailsGroup.GroupBy(o => (int)o.ShimentModeID).ToList();

                    if (lstShipmentModeGroup.Count > 0)
                    {
                        rptMode.DataSource = lstShipmentModeGroup;
                        rptMode.DataBind();
                    }

                    Literal litGrandTotal = (Literal)item.FindControl("litGrandTotal");
                    litGrandTotal.Text = "Total" + " " + total.ToString();

                }

            }
        }

        protected void rptMode_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, ReturnWeeklyAddressDetailsBO>)
            {
                List<ReturnWeeklyAddressDetailsBO> lstmodes = ((IGrouping<int, ReturnWeeklyAddressDetailsBO>)item.DataItem).ToList();

                Literal litShipmentMode = (Literal)item.FindControl("litShipmentMode");
                litShipmentMode.Text = lstmodes[0].ShipmentMode;

                DataGrid dgOrders = (DataGrid)item.FindControl("dgOrders");

                if (lstmodes.Count > 0)
                {
                    dgOrders.DataSource = lstmodes;
                    dgOrders.DataBind();
                }
            }
        }

        protected void dgOrders_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is ReturnWeeklyAddressDetailsBO)
            {
                ReturnWeeklyAddressDetailsBO ObjOrderDetails = (ReturnWeeklyAddressDetailsBO)item.DataItem;

                HyperLink linkOrderNO = (HyperLink)item.FindControl("linkOrderNO");
                linkOrderNO.Text = ObjOrderDetails.Order.ToString();
                linkOrderNO.NavigateUrl = "AddEditOrder.aspx?id=" + ObjOrderDetails.Order.ToString();

                Literal litCoordinator = (Literal)item.FindControl("litCoordinator");
                litCoordinator.Text = ObjOrderDetails.Coordinator;

                Literal litDistributor = (Literal)item.FindControl("litDistributor");
                litDistributor.Text = ObjOrderDetails.Distributor;

                Literal litClient = (Literal)item.FindControl("litClient");
                litClient.Text = ObjOrderDetails.Client;

                Literal litScheduleDate = (Literal)item.FindControl("litScheduleDate");
                litScheduleDate.Text = Convert.ToDateTime(ObjOrderDetails.ShipmentDate.ToString()).ToString("dd MMMM yyyy");

                Literal litOrderType = (Literal)item.FindControl("litOrderType");
                litOrderType.Text = ObjOrderDetails.OrderType;

                Literal litVisualLayout = (Literal)item.FindControl("litVisualLayout");
                litVisualLayout.Text = ObjOrderDetails.VisualLayout;

                Literal litPattern = (Literal)item.FindControl("litPattern");
                litPattern.Text = ObjOrderDetails.Pattern;

                Literal litQty = (Literal)item.FindControl("litQty");
                litQty.Text = ObjOrderDetails.Quantity.ToString();

                total = total + (int)ObjOrderDetails.Quantity;

                /*Literal lblStatus = (Literal)item.FindControl("lblStatus");
                lblStatus.Text = " <span class=\"label label-" + ObjVisualLayouts.OrderStatus.ToLower().Replace(" ", string.Empty).Trim() + "\"> " + ObjVisualLayouts.OrderStatus + " </span>";*/

                /*Repeater rptPrintODS = (Repeater)item.FindControl("rptPrintODS");

                if (ObjVisualLayouts.Count > 0)
                {
                    rptPrintODS.DataSource = ObjVisualLayouts;
                    rptPrintODS.DataBind();
                }*/

            }
        }

        /*protected void rptPrintODS_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is ReturnWeeklyAddressDetailsBO)
            {
                ReturnWeeklyAddressDetailsBO objOrderDetail = (ReturnWeeklyAddressDetailsBO)item.DataItem;
                int count = item.ItemIndex;
                count++;

                OrderBO objOrder = new OrderBO();
                objOrder.ID = (int)objOrderDetail.Order;
                objOrder.GetObject();

                Literal dvVlName = (Literal)item.FindControl("dvVlName");
                dvVlName.Text = "<a href=\"AddEditVisualLayout.aspx?id=" + objOrderDetail.VisualLayoutID + "\">" + objOrderDetail.VisualLayout + "</a>";


                Literal dvOrderQty = (Literal)item.FindControl("dvOrderQty");
                dvOrderQty.Text = objOrderDetail.Quantity.ToString();

                Literal dvOrderType = (Literal)item.FindControl("dvOrderType");
                dvOrderType.Text = objOrderDetail.OrderType;

                Literal dvPattern = (Literal)item.FindControl("dvPattern");
                dvPattern.Text = objOrderDetail.Pattern;

                Literal litOrderDetailStatus = (Literal)item.FindControl("litOrderDetailStatus");
                litOrderDetailStatus.Text = "<span class=\"label label-" + objOrderDetail.OrderDetailStatus.ToLower().Replace(" ", string.Empty).Trim() + "\">" + objOrderDetail.OrderDetailStatus + "</span>";

                Literal litScheduleDate = (Literal)item.FindControl("litScheduleDate");
                if (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator)
                {
                    litScheduleDate.Text = (objOrderDetail.RequestedDate != null) ? Convert.ToDateTime(objOrderDetail.RequestedDate).ToString("MMM dd, yyyy") : DateTime.Now.ToString("MMM dd, yyyy");
                }
                else if (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator)
                {
                    litScheduleDate.Text = (objOrderDetail.ShipmentDate != null) ? Convert.ToDateTime(objOrderDetail.ShipmentDate).ToString("MMM dd, yyyy") : DateTime.Now.ToString("MMM dd, yyyy");
                }
                else if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator || this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator)
                {
                    litScheduleDate.Text = (objOrderDetail.SheduledDate != null) ? Convert.ToDateTime(objOrderDetail.SheduledDate).ToString("MMM dd, yyyy") : DateTime.Now.ToString("MMM dd, yyyy");
                }

                total = total + (int)objOrderDetail.Quantity;
                /*HtmlAnchor ancMainImage = (HtmlAnchor)item.FindControl("ancMainImage");
                HtmlGenericControl ivlmainimageView = (HtmlGenericControl)item.FindControl("ivlmainimageView");

                ancMainImage.HRef = this.GetVLImagePath((int)objOrderDetail.VisualLayoutID);

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

            }
        }*/

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;

            this.PopulateDataGrid();

        }

        private void PopulateDataGrid()
        {
            {
                if (this.WeekEndDate != new DateTime(1100, 1, 1))
                {
                    List<ReturnWeeklyAddressDetailsBO> lstWeeklyAddressDetils = new List<ReturnWeeklyAddressDetailsBO>();

                    lstWeeklyAddressDetils = OrderDetailBO.GetOrderDetailsAddressDetails(this.WeekEndDate, (CompanyName != null) ? CompanyName : string.Empty, this.ShipemtMode);

                    List<IGrouping<int, ReturnWeeklyAddressDetailsBO>> lstAddressOrderDetails = lstWeeklyAddressDetils.GroupBy(o => (int)o.ShipTo).ToList();

                    if (lstAddressOrderDetails.Count > 0)
                    {
                        this.rptShipmentOrders.DataSource = lstAddressOrderDetails;
                        this.rptShipmentOrders.DataBind();
                    }
                }
            }
        }

        #endregion
        
    }
}