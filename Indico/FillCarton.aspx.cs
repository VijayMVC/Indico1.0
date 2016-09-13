using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Transactions;

using Indico.BusinessObjects;
using Indico.Common;
using System.Text.RegularExpressions;

namespace Indico
{
    public partial class FillCarton : IndicoPage
    {
        #region Enums

        private enum PolyBagFillingStatus
        {
            Invalid = 0,
            Available,
            Filled
        }

        #endregion

        #region Fields

        private int cartonNO = 0;
        private int orderDetailQtyID = 0;
        private int sizeID = 0;
        private int weekendCapacityID = 0;
        private int addedSizeID = 0;
        private DateTime qpWeekEndDate = new DateTime(1100, 1, 1);
        private List<PackingListBO> m_source;
        private bool isCompleted = false;
        private int noRecords = 1;
        private int noPolybags = 0;
        private bool isError = true;
        private string errorMessage = string.Empty;
        private PolyBagFillingStatus polyBagStatus = PolyBagFillingStatus.Invalid;
        private int itemNo = 0;

        #endregion

        #region Properties

        protected DateTime WeekEndDate
        {
            get
            {
                if (qpWeekEndDate != new DateTime(1100, 1, 1))
                    return qpWeekEndDate;

                qpWeekEndDate = DateTime.Now.AddDays(-(int)DateTime.Now.DayOfWeek).AddDays(5);

                return qpWeekEndDate;
            }
        }

        protected int CartonNo
        {
            get
            {
                if (cartonNO == 0)
                {
                    if (Request.QueryString["CartonNo"] != null)
                    {
                        cartonNO = int.Parse(Request.QueryString["CartonNo"].ToString());
                    }
                    else if (Session["CartonNo"] != null)
                    {
                        try
                        {
                            cartonNO = Convert.ToInt32(Session["CartonNo"]);
                        }
                        catch (Exception) { }
                    }
                }

                return cartonNO;
            }
            set
            {
                cartonNO = value;
                Session["CartonNo"] = value;
            }
        }

        protected int OrderDetailQtyID
        {
            get
            {
                if (orderDetailQtyID == 0 && Session["OrderDetailQtyID"] != null)
                {
                    try
                    {
                        orderDetailQtyID = Convert.ToInt32(Session["OrderDetailQtyID"]);
                    }
                    catch (Exception) { }
                }
                return orderDetailQtyID;
            }
            set
            {
                orderDetailQtyID = value;
                Session["OrderDetailQtyID"] = value;
            }
        }

        protected int ItemNo
        {
            get
            {
                if (itemNo == 0 && Session["itemNo"] != null)
                {
                    try
                    {
                        itemNo = Convert.ToInt32(Session["itemNo"]);
                    }
                    catch (Exception) { }
                }
                return itemNo;
            }
            set
            {
                itemNo = value;
                Session["itemNo"] = value;
            }
        }

        protected int SizeID
        {
            get
            {
                if (sizeID == 0 && Session["SizeID"] != null)
                {
                    try
                    {
                        sizeID = Convert.ToInt32(Session["SizeID"]);
                    }
                    catch (Exception) { }
                }
                return sizeID;
            }
            set
            {
                sizeID = value;
                Session["SizeID"] = value;
            }
        }

        protected int WeekendCapacityID
        {
            get
            {
                if (weekendCapacityID == 0 && Session["WeekendCapacityID"] != null)
                {
                    //try
                    //{
                    //    weekendCapacityID = Convert.ToInt32(Session["WeekendCapacityID"]);
                    //}
                    //catch (Exception) { }

                    WeeklyProductionCapacityBO objWPC = new WeeklyProductionCapacityBO();
                    objWPC.WeekendDate = this.WeekEndDate;
                    objWPC = objWPC.SearchObjects().SingleOrDefault();

                    if (objWPC != null)
                    {
                        weekendCapacityID = objWPC.ID;
                    }
                }
                return weekendCapacityID;
            }
            //set
            //{
            //    weekendCapacityID = value;
            //    Session["WeekendCapacityID"] = value;
            //}
        }

        private List<PackingListBO> Source
        {
            get
            {
                if (m_source == null)
                {
                    if (Session["Source"] == null || Session["Source"].GetType() != typeof(List<PackingListBO>))
                        return null;

                    List<PackingListBO> dv = ((List<PackingListBO>)Session["Source"]);

                    m_source = dv;
                }

                return m_source;
            }
            set
            {
                m_source = value;
                if (value != null)
                {
                    Session["Source"] = ((List<PackingListBO>)value); ;
                }
                else
                {
                    Session["Source"] = null;
                }
            }
        }

        public string InputClientID { get; set; }

        private bool IsError
        {
            get
            {
                if (Session["IsError"] != null)
                {
                    try
                    {
                        isError = Convert.ToBoolean(Session["IsError"]);
                    }
                    catch (Exception) { }
                }
                return isError;
            }
            set
            {
                isError = value;
                Session["IsError"] = value;
            }
        }

        private string ErrorMessage
        {
            get
            {
                if (Session["ErrorMessage"] != null)
                {
                    try
                    {
                        errorMessage = Session["ErrorMessage"].ToString();
                    }
                    catch (Exception) { }
                }
                return errorMessage;
            }
            set
            {
                errorMessage = value;
                Session["ErrorMessage"] = value;
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
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                PopulateControls();
            }
        }

        /*protected void dgPackingList_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is PackingListBO)
            {
                PackingListBO objPacking = (PackingListBO)item.DataItem;

                Literal lblParentID = (Literal)item.FindControl("lblParentID");

                Literal lblCartonNo = (Literal)item.FindControl("lblCartonNo");
                lblCartonNo.Text = objPacking.CartonNo.ToString();

                Literal lblDistributor = (Literal)item.FindControl("lblDistributor");
                lblDistributor.Text = objPacking.objOrderDetail.objOrder.objDistributor.Name;

                Literal lblClient = (Literal)item.FindControl("lblClient");
                lblClient.Text = objPacking.objOrderDetail.objOrder.objClient.Name;

                Literal lblVLName = (Literal)item.FindControl("lblVLName");
                lblVLName.Text = objPacking.objOrderDetail.objVisualLayout.NamePrefix + objPacking.objOrderDetail.objVisualLayout.NameSuffix;

                Literal lblDescription = (Literal)item.FindControl("lblDescription");
                lblDescription.Text = objPacking.objOrderDetail.objPattern.NickName;

                Literal lblPoNo = (Literal)item.FindControl("lblPoNo");
                lblPoNo.Text = objPacking.objOrderDetail.Order.ToString();

                LinkButton lnkSplitRow = (LinkButton)item.FindControl("lnkSplitRow");
                Repeater rptSizeQtyView = (Repeater)item.FindControl("rptSizeQtyView");

                Label lblTotal = (Label)item.FindControl("lblTotal");
                Label lblFilled = (Label)item.FindControl("lblFilled");

                PackingListSizeQtyBO objPackSize = new PackingListSizeQtyBO();
                objPackSize.PackingList = objPacking.ID;
                if (this.IsPolyBag)
                {
                    objPackSize.Size = this.SizeID;
                }


                List<PackingListSizeQtyBO> lstPackListQtys = objPackSize.SearchObjects();// objPacking.PackingListSizeQtysWhereThisIsPackingList.Where(m => m.Qty > 0).ToList();
                rptSizeQtyView.DataSource = lstPackListQtys;
                rptSizeQtyView.DataBind();

                lblTotal.Text = lstPackListQtys.Select(m => m.Qty).Sum().ToString();

                PackingListCartonItemBO objPackingListCartonItem = new PackingListCartonItemBO();
                objPackingListCartonItem.PackingList = objPacking.ID;

                List<PackingListCartonItemBO> lstPackListCartonItemQtys = objPackingListCartonItem.SearchObjects();
                lblFilled.Text = lstPackListCartonItemQtys.Select(m => m.Count).Sum().ToString();

                noPolybags = noPolybags + lstPackListQtys.Select(m => m.Qty).Sum();

                if (lstPackListQtys.Select(m => m.Qty).Sum() == lstPackListCartonItemQtys.Select(m => m.Count).Sum())
                {
                    isCompleted = true;
                    noRecords = noRecords + item.ItemIndex;
                }
            }
        }*/

        /*protected void rptSizeQtyView_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PackingListSizeQtyBO)
            {
                Literal litHeading = (Literal)item.FindControl("litHeading");
                Literal litQty = (Literal)item.FindControl("litQty");
                HiddenField hdnPLSQtyID = (HiddenField)item.FindControl("hdnPLSQtyID");
                HiddenField hdnCartonNo = (HiddenField)item.FindControl("hdnCartonNo");
                LinkButton lnkAddItem = (LinkButton)item.FindControl("lnkAddItem");

                PackingListSizeQtyBO objPackingListQty = (PackingListSizeQtyBO)item.DataItem;

                hdnPLSQtyID.Value = objPackingListQty.ID.ToString();
                hdnCartonNo.Value = objPackingListQty.objPackingList.CartonNo.ToString();

                PackingListCartonItemBO objpackCartonItem = new PackingListCartonItemBO();
                objpackCartonItem.PackingList = objPackingListQty.PackingList;
                objpackCartonItem.Size = objPackingListQty.Size;

                List<PackingListCartonItemBO> lstCartonItem = objpackCartonItem.SearchObjects();

                litHeading.Text = objPackingListQty.objSize.SizeName;
                string outOfQty = "/" + objPackingListQty.Qty.ToString();
                string result = (lstCartonItem.Any()) ?
                                (lstCartonItem.SingleOrDefault().Count == objPackingListQty.Qty) ? lstCartonItem.SingleOrDefault().Count.ToString() :
                                                                                                    lstCartonItem.SingleOrDefault().Count.ToString() + outOfQty :
                    "0" + outOfQty;

                if (!lstCartonItem.Any())
                {
                    litQty.Text = "<span class=\"label label-info\">" + result + "</span>";
                }
                else if (lstCartonItem.SingleOrDefault().Count == objPackingListQty.Qty)
                {
                    HtmlControl liCellData = (HtmlControl)item.FindControl("liCellData");
                    liCellData.Attributes.Add("class", "icell-data");

                    litQty.Text = "<span class=\"label label-success\">" + result + "</span>";
                    lnkAddItem.Visible = false;
                }
                else if (lstCartonItem.SingleOrDefault().Count <= objPackingListQty.Qty)
                {
                    litQty.Text = "<span class=\"label label-info\">" + result + "</span>";
                }

                if (this.addedSizeID == objPackingListQty.Size)
                {
                    this.addedSizeID = 0;
                    litQty.Text = (lnkAddItem.Visible == false) ? "<span class=\"badge badge-success\">" + result + "</span>" : "<span class=\"badge badge-info\">" + result + "</span>";
                }
            }
        }*/

        /*protected void rptSizeQtyView_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                if (e.CommandName == "AddItem")
                {
                    HiddenField hdnPLSQtyID = (HiddenField)e.Item.FindControl("hdnPLSQtyID");
                    HiddenField hdnCartonNo = (HiddenField)e.Item.FindControl("hdnCartonNo");

                    int plQtyID = int.Parse(hdnPLSQtyID.Value);
                    int cartonNo = int.Parse(hdnCartonNo.Value);

                    PackingListSizeQtyBO objPL = new PackingListSizeQtyBO();
                    objPL.ID = plQtyID;
                    objPL.GetObject();

                    OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
                    objOrderDetailQty.OrderDetail = objPL.objPackingList.OrderDetail;
                    objOrderDetailQty.Size = objPL.Size;

                    List<OrderDetailQtyBO> lst = objOrderDetailQty.SearchObjects();

                    if (lst.Any() && lst.Count == 1)
                    {
                        objOrderDetailQty = lst.SingleOrDefault();
                        this.AddItem(objOrderDetailQty.ID, cartonNo);
                    }
                }
                this.txtPolybag.Focus();
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Adding Poly Bags to the system manually FillCarton.aspx page", ex);
            }

            txtPolybag.Text = string.Empty;
        }*/

        protected void btnScanCarton_Click(object sender, EventArgs e)
        {
            if (this.txtCarton.Text != "Reset")
            {
                try
                {
                    string prefix = txtCarton.Text.Split('-')[0];
                    if (prefix.ToUpper() == "C")
                    {
                        string cartonNo = txtCarton.Text.Split('-')[1];
                        string weekendCapId = txtCarton.Text.Split('-')[2];

                        //this.WeekendCapacityID = int.Parse(weekendCapId);
                        this.CartonNo = int.Parse(cartonNo);

                        if (GetCartonData().Any())
                        {
                            this.AddItem(this.OrderDetailQtyID, this.CartonNo);
                        }
                        else
                        {
                            DisplayCartonErrorMessage("ස්කෑන් කරන ලද පෙට්ටිය මෙම සතියට අදාළ නොවේ.<br/><br/>Scanned Carton is not related to this week.");
                        }
                    }
                    else
                    {
                        DisplayCartonErrorMessage("ස්කෑන් කිරීම දෝෂ සහිතයි.<br/><br/>Scanning not successful.");
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while scan the carton using barcode scanner FillCarton.aspx page", ex);
                    DisplayCartonErrorMessage("ස්කෑන් කිරීම දෝෂ සහිතයි.<br/><br/>Scanning not successful.");
                }
            }
            else
            {
                Response.Redirect(Request.RawUrl);
            }
        }

        protected void btnScanPolyBag_Click(object sender, EventArgs e)
        {
            this.ResetParameters();

            if (this.txtPolybag.Text != "Reset")
            {
                try
                {
                    string prefix = /*txtPolybag.Text.Split('-')[0]*/ Regex.Split(txtPolybag.Text, @"(?<=[a-zA-Z])(?=\d)")[0];

                    if (prefix.ToUpper() == "P")
                    {
                        string orderDetailQtyID = Regex.Split(txtPolybag.Text, @"(?<=[a-zA-Z])(?=\d)")[1].Split('-')[0];
                        this.OrderDetailQtyID = int.Parse(orderDetailQtyID);
                        this.ItemNo = int.Parse(Regex.Split(txtPolybag.Text, @"(?<=[a-zA-Z])(?=\d)")[1].Split('-')[1]);

                        if (GetPolyBagData().Any())
                        {
                            PopulateCartonData();
                            SetScanControls(false);
                        }
                        else
                        {
                            if (this.polyBagStatus == PolyBagFillingStatus.Filled)
                            {
                                //filled message
                                SetPolyBagErrorMessage("ස්කෑන් කරන ලද පොලි බෑගය, පෙට්ටියකට අසුරා ඇත..<br/><br/>The scanned Polybag is already packed to the carton..");
                            }
                            else
                            {
                                SetPolyBagErrorMessage("ස්කෑන් කරන ලද පොලි බෑගයට අදාළ පෙට්ටියක් සොයා ගත නොහැක.<br/><br/>A Carton can't be found to the scanned Poly bag.");
                            }
                        }
                    }
                    else
                    {
                        SetPolyBagErrorMessage("ස්කෑන් කිරීම දෝෂ සහිතයි.<br/><br/>Scanning not successful.");
                    }
                }
                catch (Exception ex)
                {
                    SetPolyBagErrorMessage("ස්කෑන් කිරීම දෝෂ සහිතයි.<br/><br/>Scanning not successful.");
                    IndicoLogging.log.Error("Error occured while adding Poly Bags to the system using barcode scanner FillCarton.aspx page", ex);
                }

                if (this.IsError)
                {
                    Response.Redirect(Request.RawUrl);
                }
                else
                {
                    this.dvError.Visible = false;
                }
            }
            else
            {
                Response.Redirect(Request.RawUrl);
            }
        }

        protected void btnResetPacking_Click(object sender, EventArgs e)
        {
            List<PackingListBO> lstPackingLists = GetPolyBagData();
            var objPackBO = new PackingListBO();
            objPackBO.WeeklyProductionCapacity = WeekendCapacityID;
            objPackBO.CartonNo = CartonNo;

            lstPackingLists = objPackBO.SearchObjects().ToList();

            foreach (PackingListBO objPack in lstPackingLists)
            {
                List<int> lstPackListCartonItemQtys = objPack.PackingListCartonItemsWhereThisIsPackingList.Select(m => m.ID).ToList();

                foreach (int id in lstPackListCartonItemQtys)
                {
                    PackingListCartonItemBO obj = new PackingListCartonItemBO(this.ObjContext);
                    obj.ID = id;
                    obj.GetObject();

                    obj.Delete();
                }
            }

            this.ObjContext.SaveChanges();
        }

        protected void rptPackingList_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {

        }

        protected void rptCarton_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is PackingListBO)
            {
                PackingListBO objPacking = (PackingListBO)item.DataItem;

                Literal litCartonNo = (Literal)item.FindControl("litCartonNo");
                litCartonNo.Text = "පෙට්ටිය " + objPacking.CartonNo.ToString() + "<br/>Carton " + objPacking.CartonNo.ToString();

                HiddenField hdnCartonNo = (HiddenField)item.FindControl("hdnCartonNo");
                hdnCartonNo.Value = objPacking.CartonNo.ToString();

                Image imgCarton = (Image)item.FindControl("imgCarton");
                imgCarton.Attributes.Add("cid", objPacking.CartonNo.ToString());

                //HyperLink linkReset = (HyperLink)item.FindControl("linkReset");
                //linkReset.Attributes.Add("cid", objPacking.CartonNo.ToString());
                //linkReset.Attributes.Add("wid", objPacking.WeeklyProductionCapacity.ToString());
            }
        }

        protected void rptCarton_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            try
            {
                if (e.CommandName == "AddItem")
                {
                    HiddenField hdnCartonNo = (HiddenField)e.Item.FindControl("hdnCartonNo");

                    int cartonNo = int.Parse(hdnCartonNo.Value);

                    if (this.OrderDetailQtyID > 0 && cartonNo > 0)
                    {
                        this.AddItem(this.OrderDetailQtyID, cartonNo);
                    }

                    this.SetScanControls(false);
                }
                //this.txtPolybag.Focus();
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Adding Poly Bags to the system manually FillCarton.aspx page", ex);
            }

        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            //NNM
            int carton = int.Parse(this.hdnCarton.Value);
            int week = int.Parse(this.hdnWeekID.Value);

            try
            {
                if (carton > 0 && week > 0)
                {
                    List<PackingListBO> lstPackingLists = GetPolyBagData();
                    var objPackBO = new PackingListBO();
                    objPackBO.WeeklyProductionCapacity = week;
                    objPackBO.CartonNo = carton;

                    lstPackingLists = objPackBO.SearchObjects().ToList();

                    using (TransactionScope ts = new TransactionScope())
                    {
                        foreach (PackingListBO objPack in lstPackingLists)
                        {
                            List<int> lstPackListCartonItemQtys = objPack.PackingListCartonItemsWhereThisIsPackingList.Select(m => m.ID).ToList();

                            foreach (int id in lstPackListCartonItemQtys)
                            {
                                PackingListCartonItemBO obj = new PackingListCartonItemBO(this.ObjContext);
                                obj.ID = id;
                                obj.GetObject();

                                obj.Delete();
                            }
                        }

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while deleting PackingListCartonItems in PackingList.aspx", ex);
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading; // +" # " + CartonNo;
            this.litPolyBags.Text = "මීළඟ පොලි බෑගය ස්කෑන් කරන්න...<br/><br/><br/><br/>Please scan the next Poly bag...";
            this.litCarton.Text = "පෙට්ටිය ස්කෑන් කරන්න...<br/><br/><br/><br/>Please scan the carton..."; // "Please scan the cartons ...";
            this.litAddress.Text = string.Empty;
            this.dvError.Visible = false;

            this.ResetParameters();
            this.OrderDetailQtyID = 0;

            //if (this.WeekEndDate != new DateTime(1100, 1, 1))
            //{
            //    WeeklyProductionCapacityBO objWPC = new WeeklyProductionCapacityBO();
            //    objWPC.WeekendDate = this.WeekEndDate;
            //    objWPC = objWPC.SearchObjects().SingleOrDefault();

            //    if (objWPC != null)
            //    {
            //        this.WeekendCapacityID = objWPC.ID;
            //    }
            //}

            //if (this.CartonNo > 0 && this.WeekendCapacityID > 0)
            //{
            //    if (GetPolyBagData().Any())
            //    {
            //        //PopulateDataGrid();
            //        this.InputClientID = this.txtPolybag.ClientID;
            //    }
            //    else
            //    {
            //        //dvEmptyContent.Visible = true;
            //        // litNoResult.Text = "No cartons found.";
            //        //NNM
            //        this.h3Carton.Attributes.Add("class", "text-error");
            //        this.litCarton.Text = "Scaned carton details can not find in the System.";
            //        this.InputClientID = this.txtPolybag.ClientID;
            //    }
            //}
            //else
            //{
            //NNM       

            //this.dvScanCarton.Attributes.Add("style", "display:none;");
            //this.dvScanPolyBag.Attributes.Add("style", "display:block;");
            this.SetScanControls(true);
            //this.h3PolyBags.Attributes.Add("class", "text-info");            

            if (this.IsError)
            {
                this.dvError.Visible = true;
                this.lblError.Text = this.ErrorMessage;
                Page.SetFocus(txtPolybag);

                this.IsError = false;
            }
            //}
        }

        /*
        private void PopulateDataGrid(bool IsPolyBag = true)
        {
            if (IsPolyBag)
            {
                List<PackingListBO> lstPackingLists = GetPolyBagData();  //objPack.SearchObjects().Where(m => m.WeeklyProductionCapacity == WeekendCapacityID && m.CartonNo == CartonNo).ToList();

                if (lstPackingLists.Any())
                {
                    this.dvEmptyContent.Attributes.Add("style", "display:none;");
                    this.dvScanCarton.Attributes.Add("style", "display:block;");
                    this.dvScanPolyBag.Attributes.Add("style", "display:none;");

                    this.dvDataContent.Attributes.Add("style", "display:block;");
                    this.h3Carton.Attributes.Add("class", "text-info");
                    this.litCarton.Text = "Please scan the cartons ...";

                    dgPackingList.DataSource = lstPackingLists;
                    dgPackingList.DataBind();

                    if ((isCompleted == true) && (noRecords == lstPackingLists.Count))
                    {
                        // when carton completed
                        this.h3PolyBags.Attributes.Add("class", "text-success");
                        this.litPolyBags.Text = "Filling Carton is completed. There are <span class=\"badge badge-success\">" + noPolybags.ToString() + "</span> polybags in the Carton.";
                    }
                }
                else
                {
                    //dvEmptyContent.Visible = true;
                    //litNoResult.Text = "No polybags found.";
                    this.dvScanCarton.Attributes.Add("style", "display:none;");
                    this.dvScanPolyBag.Attributes.Add("style", "display:block;");
                    this.h3PolyBags.Attributes.Add("class", "text-error");
                    this.litPolyBags.Text = "Scaned polybag details can not find in the System.";
                }
            }
            else
            {
                List<PackingListBO> lstPackingLists = GetCartonData();  //objPack.SearchObjects().Where(m => m.WeeklyProductionCapacity == WeekendCapacityID && m.CartonNo == CartonNo).ToList();

                if (lstPackingLists.Any())
                {
                    this.dvEmptyContent.Attributes.Add("style", "display:none;");
                    this.dvScanPolyBag.Attributes.Add("style", "display:block;");
                    this.dvScanCarton.Attributes.Add("style", "display:none;");

                    this.dvDataContent.Attributes.Add("style", "display:block;");
                    this.h3PolyBags.Attributes.Add("class", "text-info");
                    this.litPolyBags.Text = "Please scan the Poly bag...";

                    dgPackingList.DataSource = lstPackingLists;
                    dgPackingList.DataBind();

                    if ((isCompleted == true) && (noRecords == lstPackingLists.Count))
                    {
                        // when carton completed
                        this.h3PolyBags.Attributes.Add("class", "text-success");
                        this.litPolyBags.Text = "Filling Carton is completed. There are <span class=\"badge badge-success\">" + noPolybags.ToString() + "</span> polybags in the Carton.";
                    }
                }
                else
                {                    
                    //litNoResult.Text = "No polybags found.";
                    this.dvScanPolyBag.Attributes.Add("style", "display:none;");
                    this.dvScanCarton.Attributes.Add("style", "display:block;");
                    this.h3Carton.Attributes.Add("class", "text-error");
                    this.litCarton.Text = "Scaned carton details can not find in the System.";
                }
            }

            Session["IsPolyBag"] = IsPolyBag;
        }
        */

        private void SetScanControls(bool isPolybag)
        {
            this.txtCarton.Text = string.Empty;
            this.txtPolybag.Text = string.Empty;

            this.InputClientID = (isPolybag) ? this.txtPolybag.ClientID : this.txtCarton.ClientID;

            if (isPolybag)
            {
                this.txtPolybag.Focus();
            }
            else
            {
                this.txtCarton.Focus();
            }

            this.dvScanPolyBag.Visible = isPolybag;
            this.dvScanCarton.Visible = !isPolybag;
        }

        private void PopulateCartonData()
        {
            List<PackingListBO> lstPackingLists = GetPolyBagData();

            if (lstPackingLists.Any())
            {
                OrderDetailBO objOrderDetail = new OrderDetailBO();
                objOrderDetail.ID = lstPackingLists[0].OrderDetail;
                objOrderDetail.GetObject();

                /* OrderBO objOrder = new OrderBO();
                 objOrder.ID = objOrderDetail.Order;
                 objOrder.GetObject();

                 DistributorClientAddressBO objAddress = new DistributorClientAddressBO();
                 objAddress.ID = (int)objOrder.DespatchToExistingClient;
                 objAddress.GetObject();*/

                InvoiceOrderBO objInvoiceOrder = new InvoiceOrderBO();
                objInvoiceOrder.OrderDetail = objOrderDetail.ID;

                //string state = (string.IsNullOrEmpty(objAddress.State)) ? string.Empty : objAddress.State;

                this.litAddress.Text = objInvoiceOrder.SearchObjects().Select(o => o.objInvoice.InvoiceNo).SingleOrDefault();

                this.dvScanCarton.Attributes.Add("style", "display:block;");
                this.dvScanPolyBag.Attributes.Add("style", "display:none;");

                this.dvDataContent.Attributes.Add("style", "display:block;");
                this.h3Carton.Attributes.Add("class", "text-info");

                rptCarton.DataSource = lstPackingLists;
                rptCarton.DataBind();

                if ((isCompleted == true) && (noRecords == lstPackingLists.Count))
                {
                    // when carton completed
                    this.h3PolyBags.Attributes.Add("class", "text-success");
                    this.litPolyBags.Text = "Filling Carton is completed. There are <span class=\"badge badge-success\">" + noPolybags.ToString() + "</span> polybags in the Carton.";
                }
            }
            else
            {
                this.dvScanCarton.Attributes.Add("style", "display:none;");
                this.dvScanPolyBag.Attributes.Add("style", "display:block;");
                this.h3PolyBags.Attributes.Add("class", "text-error");
                this.litPolyBags.Text = "Scanned polybag details can not find in the System.";
            }
        }

        private List<PackingListBO> GetPolyBagData()
        {
            List<PackingListBO> PackingLists = new List<PackingListBO>();
            List<PackingListCartonItemBO> lstCartonItems = new List<PackingListCartonItemBO>();

            PackingListBO objPacking = new PackingListBO();

            if (Source != null)
            {
                PackingLists = Source;
            }
            else
            {
                OrderDetailQtyBO obj = new OrderDetailQtyBO();
                obj.ID = this.OrderDetailQtyID;
                obj.GetObject();

                this.SizeID = obj.Size;

                var objPack = new PackingListBO();
                //objPack.WeeklyProductionCapacity = WeekendCapacityID;
                objPack.OrderDetail = obj.OrderDetail;
                //objPack.CartonNo = CartonNo;

                DateTime monday = WeekEndDate.AddDays(-(int)WeekEndDate.DayOfWeek - 6);

                // List<PackingListBO> loadedPackingLists = objPack.SearchObjects().Where(m => m.PackingListSizeQtysWhereThisIsPackingList.Where(o => o.Qty > 0).Select(s => s.Size).Contains(this.SizeID) && m.objWeeklyProductionCapacity.WeekendDate.Date == WeekEndDate.Date && m.CartonNo > 0).ToList(); //.Where(m => m.PackingListCartonItemsWhereThisIsPackingList.Where(k => k.Size == this.SizeID).SingleOrDefault().Count < m.PackingListSizeQtysWhereThisIsPackingList.Where(k => k.Size == this.SizeID).SingleOrDefault().Qty).ToList();

                List<PackingListBO> loadedPackingLists = objPack.SearchObjects().Where(m => m.PackingListSizeQtysWhereThisIsPackingList.Where(s => s.Qty > 0).Select(s => s.Size).Contains(this.SizeID) && (DateTime.Compare(m.objWeeklyProductionCapacity.WeekendDate.Date, monday.Date) > -1) && m.CartonNo > 0).ToList(); //.Where(m => m.PackingListCartonItemsWhereThisIsPackingList.Where(k => k.Size == this.SizeID).SingleOrDefault().Count < m.PackingListSizeQtysWhereThisIsPackingList.Where(k => k.Size == this.SizeID).SingleOrDefault().Qty).ToList();

                foreach (PackingListBO objPackingList in loadedPackingLists)
                {
                    PackingListCartonItemBO objCartonItem = new PackingListCartonItemBO();
                    objCartonItem.Size = this.SizeID;
                    objCartonItem.PackingList = objPackingList.ID;
                    objCartonItem.Count = this.ItemNo;

                    lstCartonItems = objCartonItem.SearchObjects();

                    if (lstCartonItems.Any() && lstCartonItems.Count == 1)
                    {
                        this.polyBagStatus = PolyBagFillingStatus.Filled;
                        break;
                    }
                    else
                    {
                        PackingLists.Add(objPackingList);
                        this.polyBagStatus = PolyBagFillingStatus.Available;
                    }
                }
            }

            if (this.polyBagStatus == PolyBagFillingStatus.Filled)
            {
                PackingLists.Clear();
            }

            Source = PackingLists;

            return PackingLists;
        }

        private List<PackingListBO> GetCartonData()
        {
            var PackingLists = new List<PackingListBO>();

            if (Source != null)
            {
                PackingLists = Source;
            }
            else
            {
                OrderDetailQtyBO obj = new OrderDetailQtyBO();
                obj.ID = this.OrderDetailQtyID;
                obj.GetObject();

                this.SizeID = obj.Size;

                var objPack = new PackingListBO();
                objPack.WeeklyProductionCapacity = WeekendCapacityID;
                // objPack.OrderDetail = obj.OrderDetail;
                objPack.CartonNo = CartonNo;

                PackingLists = objPack.SearchObjects().ToList();
            }

            Source = PackingLists;

            return PackingLists;
        }

        private void ResetParameters()
        {
            this.Source = null;
            this.CartonNo = 0;
        }

        private void SetPolyBagErrorMessage(string message)
        {
            this.IsError = true;
            this.ErrorMessage = message;
        }

        private void DisplayCartonErrorMessage(string message)
        {
            this.dvError.Visible = true;
            this.lblError.Text = message;
            SetScanControls(false);
        }

        private void AddItem(int orderDetailQtyID, int cartonNo)
        {
            OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO();
            objOrderDetailQty.ID = orderDetailQtyID;
            objOrderDetailQty.GetObject();

            List<PackingListBO> lstPackingList = Source.Where(m => m.OrderDetail == objOrderDetailQty.OrderDetail && m.CartonNo == cartonNo).ToList();

            if (lstPackingList.Any())
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    //PackingListCartonItemBO objPackListCartonItem = new PackingListCartonItemBO();
                    //objPackListCartonItem.PackingList = lstPackingList.SingleOrDefault().ID;
                    //objPackListCartonItem.Size = objOrderDetailQty.Size;
                    //List<PackingListCartonItemBO> lstCartonItem = objPackListCartonItem.SearchObjects();

                    ////PackingListSizeQtyBO objPackingListSizeQty = new PackingListSizeQtyBO();
                    ////objPackingListSizeQty.PackingList = lstPackingList.SingleOrDefault().ID;
                    ////objPackingListSizeQty.Size = objOrderDetailQty.Size;
                    ////List<PackingListSizeQtyBO> lstSizeQty = objPackingListSizeQty.SearchObjects();

                    //if (!lstCartonItem.Any())
                    //{
                    //    // no records
                    //    PackingListCartonItemBO objPackListCartonItemToSave = new PackingListCartonItemBO(this.ObjContext);
                    //    objPackListCartonItemToSave.PackingList = objPackListCartonItem.PackingList;
                    //    objPackListCartonItemToSave.Size = objPackListCartonItem.Size;
                    //    objPackListCartonItemToSave.Count = 1; // objPackListCartonItem.Count + 1;

                    //    addedSizeID = objPackListCartonItem.Size;
                    //}
                    //else if (lstCartonItem.Any() && (lstCartonItem.SingleOrDefault().Count < objOrderDetailQty.Qty))
                    //{
                    //    //update
                    //    PackingListCartonItemBO objPackListCartonItemToSave = new PackingListCartonItemBO(this.ObjContext);
                    //    objPackListCartonItemToSave.ID = lstCartonItem.SingleOrDefault().ID;
                    //    objPackListCartonItemToSave.GetObject();
                    //    objPackListCartonItemToSave.Count++;

                    //    addedSizeID = objPackListCartonItem.Size;
                    //}
                    ////else if (lstCartonItem.Any() && (lstCartonItem.SingleOrDefault().Count == lstSizeQty.SingleOrDefault().Qty))
                    ////{
                    ////    //filled
                    ////}

                    PackingListCartonItemBO objPackListCartonItem = new PackingListCartonItemBO(this.ObjContext);
                    objPackListCartonItem.PackingList = lstPackingList.SingleOrDefault().ID;
                    objPackListCartonItem.Size = objOrderDetailQty.Size;
                    objPackListCartonItem.Count = this.ItemNo; // objPackListCartonItem.Count + 1;

                    addedSizeID = objPackListCartonItem.Size;

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }

                DisplaySuccessMessage(cartonNo);
            }
            else // wrong poly bag
            {
                DisplayCartonErrorMessage("ස්කෑන් කරන ලද පොලි බෑගය මෙම පෙට්ටියට අදාළ නොවේ. <br/><br/>නැවත නිවැරදි පෙට්ටිය ස්කෑන් කරන්න.<br/><br/>Scanned Poly bag should not go to this Carton.<br/><br/>Please scan the correct Carton.");
            }
        }

        private void DisplaySuccessMessage(int cartonNo)
        {
            this.IsError = false;
            this.dvError.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvScanCarton.Visible = false;
            this.dvSuccess.Visible = true;
            this.lblSuccess.Text = cartonNo + " වන පෙට්ටියට අසුරන ලදී. <br/><br/>Filled successfully to Carton " + cartonNo;
            Response.AddHeader("REFRESH", "2;URL=FillCarton.aspx");
            // Response.Redirect(Request.RawUrl);
        }

        #endregion
    }
}