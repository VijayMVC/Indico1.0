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
using System.IO;
using System.Drawing;

namespace Indico
{
    public partial class ViewPackingLists : IndicoPage
    {
        #region Fields

        private DateTime qpWeekEndDate = new DateTime(1100, 1, 1);
        private List<PackingList> m_source;
        private int grandTotal = 0;
        private int grandFilledTotal = 0;

        #endregion

        #region Properties

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

        private List<PackingList> Source
        {
            get
            {
                if (m_source == null)
                {
                    if (Session["Source"] == null || Session["Source"].GetType() != typeof(List<PackingList>))
                        return null;

                    List<PackingList> dv = ((List<PackingList>)Session["Source"]);

                    m_source = dv;
                }

                return m_source;
            }
            set
            {
                m_source = value;
                if (value != null)
                {
                    Session["Source"] = ((List<PackingList>)value); ;
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

        protected void rptPackingList_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is PackingList)
            {
                PackingList objPacking = (PackingList)item.DataItem;

                Literal litCartonNo = (Literal)item.FindControl("litCartonNo");
                HiddenField hdnPackingListID = (HiddenField)item.FindControl("hdnPackingListID");
                LinkButton btnStartPackingCarton = (LinkButton)item.FindControl("btnStartPackingCarton");
                LinkButton btnAutoFill = (LinkButton)item.FindControl("btnAutoFill");
                Literal litTotal = (Literal)item.FindControl("litTotal");
                HiddenField hdnCartonNo = (HiddenField)item.FindControl("hdnCartonNo");
                HiddenField hdnShipTo = (HiddenField)item.FindControl("hdnShipTo");
                HiddenField hdnShipmentMode = (HiddenField)item.FindControl("hdnShipmentMode");
                HiddenField hdnWeeklyID = (HiddenField)item.FindControl("hdnWeeklyID");
                LinkButton btnPrintLabel = (LinkButton)item.FindControl("btnPrintLabel");


                litCartonNo.Text = "Carton #" + objPacking.CartonNo.ToString();
                hdnCartonNo.Value = objPacking.CartonNo.ToString();

                hdnShipTo.Value = objPacking.ListPackingList[0].ShipTo.ToString();
                hdnShipmentMode.Value = objPacking.ListPackingList[0].ShipmentMode.ToString();
                hdnWeeklyID.Value = objPacking.ListPackingList[0].WeeklyProductionCapacity.ToString();

                InvoiceOrderBO objInvoiceOrder = new InvoiceOrderBO();
                objInvoiceOrder.OrderDetail = (int)objPacking.ListPackingList[0].OrderDetail;



                btnPrintLabel.Visible = (objInvoiceOrder.SearchObjects().Count > 0) ? true : false;

                int cartonTotal = 0;
                int cartonFilledTotal = 0;

                foreach (var s in objPacking.ListPackingList)
                {
                    //List<PackingListSizeQtyBO> lstPackListQtys = s.PackingListSizeQtysWhereThisIsPackingList.Where(m => m.Qty > 0).ToList();
                    //cartonTotal += lstPackListQtys.Select(m => m.Qty).Sum();

                    //List<PackingListCartonItemBO> lstPackListCartonItems = s.PackingListCartonItemsWhereThisIsPackingList.Where(m => m.Count > 0).ToList();
                    //cartonFilledTotal += lstPackListCartonItems.Select(m => m.Count).Sum();

                    cartonTotal += s.PackingTotal.Value;
                    cartonFilledTotal += s.ScannedTotal.Value;

                    hdnPackingListID.Value = s.PackingList.ToString();
                }

                grandTotal += cartonTotal;

                if (cartonFilledTotal == 0)
                {
                    //start packing
                    btnStartPackingCarton.Text = "Start Packing";
                }
                else if (cartonTotal > cartonFilledTotal)
                {
                    //resume
                    btnStartPackingCarton.Text = "Resume Packing";
                }
                else if (cartonTotal == cartonFilledTotal)
                {
                    //finished
                    btnStartPackingCarton.Visible = false;
                    btnAutoFill.Visible = false;
                }

                litTotal.Text = "Total " + cartonTotal.ToString();

                DataGrid dgPackingList = (DataGrid)item.FindControl("dgPackingList");
                dgPackingList.DataSource = objPacking.ListPackingList;
                dgPackingList.DataBind();
            }
        }

        protected void rptPackingList_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            HiddenField hdnCartonNo = (HiddenField)e.Item.FindControl("hdnCartonNo");
            int cartonNo = int.Parse(hdnCartonNo.Value.ToString());

            if (Source != null)
            {
                List<PackingList> PackingList = Source.Where(m => m.CartonNo == cartonNo).ToList();

                if (e.CommandName == "PrintLabel")
                {
                    HiddenField hdnShipTo = (HiddenField)e.Item.FindControl("hdnShipTo");

                    int shipto = int.Parse(hdnShipTo.Value);

                    HiddenField hdnShipmentMode = (HiddenField)e.Item.FindControl("hdnShipmentMode");

                    string shipmentmode = hdnShipmentMode.Value;

                    this.GenerateLabels(PackingList, shipto, shipmentmode);
                }
                else if (e.CommandName == "StartPacking")
                {
                    Response.Redirect("FillCarton.aspx?cartonNo=" + cartonNo + "&&weekendDate=" + WeekEndDate.ToShortDateString());
                }
                else if (e.CommandName == "AutoFill")
                {
                    //HiddenField hdnPackingListID = (HiddenField)e.Item.FindControl("hdnPackingListID");
                    // Auto filling the carton
                    this.AutoFillCarton(PackingList);
                    this.PopulateDataGrid();
                }
                else if (e.CommandName == "ResetCarton")
                {
                    HiddenField hdnWeeklyID = (HiddenField)e.Item.FindControl("hdnWeeklyID");
                    int weeklyid = int.Parse(hdnWeeklyID.Value);

                    try
                    {
                        if (cartonNo > 0 && weeklyid > 0)
                        {
                            //List<PackingListBO> lstPackingLists = GetPolyBagData();
                            PackingListBO objPackBO = new PackingListBO();
                            objPackBO.WeeklyProductionCapacity = weeklyid;
                            objPackBO.CartonNo = cartonNo;

                            List<PackingListBO> lstPackingLists = objPackBO.SearchObjects().ToList();

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
                        IndicoLogging.log.Error("Error occured while deleting PackingListCartonItems in ViewPackingLists.aspx", ex);
                    }

                    this.PopulateDataGrid();
                }
            }
            else
            {
                Response.Redirect(Request.RawUrl);
            }
        }

        protected void rptDistributor_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int?, PackingListViewBO>)
            {
                List<PackingListViewBO> lstPackingListsGroup = ((IGrouping<int?, PackingListViewBO>)item.DataItem).ToList();

                if (lstPackingListsGroup[0].ShipmentMode != null)
                {
                    Literal litComapny = (Literal)item.FindControl("litComapny");
                    litComapny.Text = lstPackingListsGroup[0].CompanyName;

                    Literal litDate = (Literal)item.FindControl("litDate");
                    //litDate.Text = Convert.ToDateTime(lstOrderDetailsGroup[0].ShipmentDate.ToString()).ToString("dd MMMM yyyy");

                    Literal litAddress = (Literal)item.FindControl("litAddress");
                    litAddress.Text = lstPackingListsGroup[0].Address;

                    Literal litSuberb = (Literal)item.FindControl("litSuberb");
                    litSuberb.Text = lstPackingListsGroup[0].Suberb;

                    Literal litPostCode = (Literal)item.FindControl("litPostCode");
                    litPostCode.Text = lstPackingListsGroup[0].State + " " + lstPackingListsGroup[0].PostCode + " , " + lstPackingListsGroup[0].Country;

                    // Literal litCountry = (Literal)item.FindControl("litCountry");
                    //litCountry.Text = lstOrderDetailsGroup[0].Country;

                    Literal litContactDetails = (Literal)item.FindControl("litContactDetails");
                    litContactDetails.Text = lstPackingListsGroup[0].ContactDetails;

                    Repeater rptModes = (Repeater)item.FindControl("rptModes");

                    List<IGrouping<int, PackingListViewBO>> lstModesGroup = lstPackingListsGroup.GroupBy(o => (int)o.ShimentModeID).ToList();

                    if (lstModesGroup.Count > 0)
                    {
                        rptModes.DataSource = lstModesGroup;
                        rptModes.DataBind();
                    }
                }

                // Literal litGrandTotal = (Literal)item.FindControl("litGrandTotal");
                // litGrandTotal.Text = "Total" + " " + total.ToString();

            }
        }

        protected void rptModes_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, PackingListViewBO>)
            {
                List<PackingListViewBO> lstPackingListMode = ((IGrouping<int, PackingListViewBO>)item.DataItem).ToList();

                DataGrid dgPackingList = (DataGrid)item.FindControl("dgPackingList");
                //dgPackingList.Attributes.Add("uid", lstPackingListsGroup[0].ShipTo.ToString().Trim());

                Literal litShipmentMode = (Literal)item.FindControl("litShipmentMode");
                litShipmentMode.Text = lstPackingListMode[0].ShipmentMode;

                Repeater rptPackingList = (Repeater)item.FindControl("rptPackingList");

                List<PackingList> PackingLists = new List<PackingList>();
                IEnumerable<IGrouping<int?, PackingListViewBO>> lst = lstPackingListMode.GroupBy(m => m.CartonNo).ToList();

                foreach (IGrouping<int?, PackingListViewBO> objPackingList in lst)
                {
                    PackingList objPackingListItem = new PackingList();
                    objPackingListItem.CartonNo = objPackingList.Key.Value;

                    foreach (PackingListViewBO item1 in objPackingList)
                    {
                        objPackingListItem.ListPackingList.Add(item1);
                    }

                    PackingLists.Add(objPackingListItem);
                }

                if (lstPackingListMode.Count > 0)
                {
                    rptPackingList.DataSource = PackingLists;
                    rptPackingList.DataBind();

                    Source = PackingLists;
                }
            }
        }

        protected void dgPackingList_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is PackingListViewBO)
            {
                PackingListViewBO objPacking = (PackingListViewBO)item.DataItem;

                Literal lblID = (Literal)item.FindControl("lblID");
                lblID.Text = objPacking.PackingList.ToString();

                Literal lblParentID = (Literal)item.FindControl("lblParentID");

                Literal lblDistributor = (Literal)item.FindControl("lblDistributor");
                lblDistributor.Text = objPacking.Distributor;

                Literal lblClient = (Literal)item.FindControl("lblClient");
                lblClient.Text = objPacking.Client;

                Literal lblVLName = (Literal)item.FindControl("lblVLName");
                lblVLName.Text = objPacking.VLName;

                Literal lblDescription = (Literal)item.FindControl("lblDescription");
                lblDescription.Text = objPacking.Pattern;

                Literal lblPoNo = (Literal)item.FindControl("lblPoNo");
                lblPoNo.Text = objPacking.OrderNumber.ToString();

                LinkButton lnkSplitRow = (LinkButton)item.FindControl("lnkSplitRow");
                Repeater rptSizeQtyView = (Repeater)item.FindControl("rptSizeQtyView");

                PackingListSizeQtyBO objPackSizeQty = new PackingListSizeQtyBO();
                objPackSizeQty.PackingList = objPacking.PackingList.Value;

                List<PackingListSizeQtyBO> lstPackListQtys = objPackSizeQty.SearchObjects().Where(m => m.Qty > 0).ToList();
                rptSizeQtyView.DataSource = lstPackListQtys;
                rptSizeQtyView.DataBind();

                int total = objPacking.PackingTotal.Value; // lstPackListQtys.Select(m => m.Qty).Sum();

                Literal lblTotal = (Literal)item.FindControl("lblTotal");
                lblTotal.Text = total.ToString();
            }
        }

        protected void rptSizeQtyView_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PackingListSizeQtyBO)
            {
                Literal litHeading = (Literal)item.FindControl("litHeading");
                Label lblSize = (Label)item.FindControl("lblSize");
                Label lblQty = (Label)item.FindControl("lblQty");

                PackingListSizeQtyBO objPackingListQty = (PackingListSizeQtyBO)item.DataItem;
                litHeading.Text = objPackingListQty.objSize.SizeName;
                lblSize.Text = objPackingListQty.Size.ToString();
                lblQty.Text = objPackingListQty.Qty.ToString();
            }
        }

        protected void btnPrintLabels_Click(object sender, EventArgs e)
        {
            List<PackingList> PackingList = new List<PackingList>();

            foreach (RepeaterItem item in rptDistributor.Items)
            {
                Repeater rptModes = (Repeater)item.FindControl("rptModes");

                foreach (RepeaterItem modeItems in rptModes.Items)
                {
                    Repeater rptPackingList = (Repeater)modeItems.FindControl("rptPackingList");

                    foreach (RepeaterItem plItems in rptPackingList.Items)
                    {
                        LinkButton btnPrintLabel = (LinkButton)plItems.FindControl("btnPrintLabel");

                        HiddenField hdnCartonNo = (HiddenField)plItems.FindControl("hdnCartonNo");
                        int cartonNo = int.Parse(hdnCartonNo.Value.ToString());

                        if (cartonNo > 0 && Source.Count > 0 && btnPrintLabel.Visible == true)
                        {
                            PackingList.Add(Source.Where(m => m.CartonNo == cartonNo).SingleOrDefault());
                        }
                    }
                }
            }

            if (PackingList.Count > 0)
            {
                //PackingList.Add(Source.Where(m=>m.CartonNo!=0).sin

                this.GenerateLabels(PackingList, 0, string.Empty);
            }

        }

        protected void btnScan_Click(object sender, EventArgs e)
        {
            try
            {
                string cartonNo = txtBarcode.Text.Split('-')[0];
                string weekendCapId = txtBarcode.Text.Split('-')[1];

                Response.Redirect("FillCarton.aspx?cID=" + cartonNo + "&&wID=" + weekendCapId);
            }
            catch (Exception ex)
            {

            }

            txtBarcode.Text = string.Empty;
        }

        protected void btnViewCartons_Click(object sender, EventArgs e)
        {
            Response.Redirect("/ViewCartons.aspx?WeekendDate=" + this.WeekEndDate);
        }

        protected void btnPrintReport_Click(object sender, EventArgs e)
        {
            if (this.WeekEndDate != null && this.WeekEndDate != new DateTime(1001, 1, 1))
            {
                string pdfpath = GenerateOdsPdf.GeneratePackingReportPDF(this.WeekEndDate, int.Parse(this.ddlShipmentMode.SelectedValue), int.Parse(this.ddlShippingAddress.SelectedValue));

                if (File.Exists(pdfpath))
                {
                    this.DownloadPDFFile(pdfpath);
                }
            }
        }

        protected void btnPrintReset_Click(object sender, EventArgs e)
        {
            try
            {
                this.GenerateResetCarton();
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while printing the Reset Barcode from ViewPackingList.aspx page", ex);
            }
        }

        protected void btnSearch_ServerClick(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnClientPackingList_Click(object sender, EventArgs e)
        {
            if (this.WeekEndDate != null && this.WeekEndDate != new DateTime(1001, 1, 1))
            {
                string pdfpath = GenerateOdsPdf.GenerateClientPackingListReport(this.WeekEndDate, int.Parse(this.ddlShipmentMode.SelectedValue), int.Parse(this.ddlShippingAddress.SelectedValue));

                if (File.Exists(pdfpath))
                {
                    this.DownloadPDFFile(pdfpath);
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
            litHeaderText.Text = "Packing List For " + WeekEndDate.ToString("dd/MM/yyyy"); // this.ActivePage.Heading;

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

        private void PopulateDataGrid()
        {
            //List<PackingList> PackingLists = new List<PackingList>();
            List<PackingListViewBO> lstPackingLists = new List<PackingListViewBO>();

            if (int.Parse(this.ddlShipmentMode.SelectedValue) > 0 || int.Parse(this.ddlShippingAddress.SelectedValue) > 0)
            {
                lstPackingLists = PackingListBO.GetPackingList(this.WeekEndDate, int.Parse(this.ddlShipmentMode.SelectedValue), int.Parse(this.ddlShippingAddress.SelectedValue));

                if (lstPackingLists.Count > 0)
                {
                    //IEnumerable<IGrouping<int?, PackingListViewBO>> lst = lstPackingLists.GroupBy(m => m.CartonNo).ToList();

                    //List<IGrouping<int, PackingListViewBO>> lst = lstPackingLists.GroupBy(m => m.CartonNo).ToList();

                    //Source = lstPackingLists;

                    //this.rptPackingList.DataSource = lstPackingLists.GroupBy(m => m.CartonNo).ToList();
                    //this.rptPackingList.DataBind();

                    this.rptDistributor.DataSource = lstPackingLists.GroupBy(m => m.ShipTo).ToList();
                    this.rptDistributor.DataBind();

                    this.litGrandTotal.Visible = true;
                    this.dvEmptyContent.Visible = false;
                    this.btnPrintLabels.Visible = true;
                    this.btnViewCartons.Visible = true;
                    this.btnStartPacking.Visible = true;
                    this.litGrandTotal.Visible = true;
                    this.rptDistributor.Visible = true;
                }
                else
                {
                    this.litErrorMeassaage.Text = "No Packing list details found.";
                    this.dvEmptyContent.Visible = true;
                    this.btnPrintLabels.Visible = false;
                    this.btnViewCartons.Visible = false;
                    this.btnStartPacking.Visible = false;
                    this.litGrandTotal.Visible = false;
                    this.rptDistributor.Visible = false;
                }


            }
            else
            {
                this.litErrorMeassaage.Text = "Please select Shipment Mode and Shipping Address";
                this.dvEmptyContent.Visible = true;
                this.btnPrintLabels.Visible = false;
                this.btnViewCartons.Visible = false;
                this.btnStartPacking.Visible = false;
                this.litGrandTotal.Visible = false;
                this.rptDistributor.Visible = false;
            }

            litGrandTotal.Text = "Grand Total: " + grandTotal;

            //NNM
            /*  foreach (IGrouping<int?, PackingListViewBO> objPackingList in lst)
              {
                  PackingList objPackingListItem = new PackingList();
                  objPackingListItem.CartonNo = objPackingList.Key.Value;

                  foreach (PackingListViewBO item in objPackingList)
                  {
                      objPackingListItem.ListPackingList.Add(item);
                  }

                  PackingLists.Add(objPackingListItem);
              }*/

            /*if (PackingLists.Any())
            {
                Source = PackingLists;

                this.rptPackingList.DataSource = PackingLists;
                this.rptPackingList.DataBind();

                
            }*/
            /*  else
              {
                  dvEmptyContent.Visible = true;
                  this.btnPrintLabels.Visible = false;
                  this.btnViewCartons.Visible = false;
                  this.btnStartPacking.Visible = false;
              }*/

            /* if (PackingLists.Where(m => m.CartonNo == 0).Count() > 0)
             {
                 this.btnPrintLabels.Visible = false;
                 this.btnViewCartons.Visible = false;
                 this.btnStartPacking.Visible = false;
             }*/
        }

        private void GenerateLabels(List<PackingList> lstPackingList, int shipto, string shipmentmode)
        {
            string imageLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Barcode\\" + Guid.NewGuid() + "\\";
            Directory.CreateDirectory(imageLocation);
            string tempPath = imageLocation + "temp.jpg";

            foreach (PackingList obj in lstPackingList)
            {
                Bitmap lblBM = new Bitmap(400, 275);
                using (Graphics gfx = Graphics.FromImage(lblBM))
                using (SolidBrush brush = new SolidBrush(Color.White))
                {
                    gfx.FillRectangle(brush, 0, 0, 400, 275);
                }
                lblBM.Save(tempPath);

                string labelText = string.Empty;
                string qty = string.Empty;
                List<KeyValuePair<int, string>> listOrderDetails = new List<KeyValuePair<int, string>>();

                foreach (PackingListViewBO objPackingList in obj.ListPackingList)
                {
                    qty = string.Empty;
                    listOrderDetails.Add(new KeyValuePair<int, string>(objPackingList.PackingList.Value, objPackingList.OrderNumber.Value.ToString()));
                    listOrderDetails.Add(new KeyValuePair<int, string>(objPackingList.PackingList.Value, objPackingList.Client));
                    listOrderDetails.Add(new KeyValuePair<int, string>(objPackingList.PackingList.Value, objPackingList.VLName));

                    PackingListSizeQtyBO objSizeQty = new PackingListSizeQtyBO();
                    objSizeQty.PackingList = objPackingList.PackingList.Value;

                    foreach (PackingListSizeQtyBO objPackSize in objSizeQty.SearchObjects())
                    {
                        string delimeter = string.IsNullOrEmpty(qty) ? string.Empty : ", ";
                        qty = qty + delimeter + objPackSize.objSize.SizeName + "/" + objPackSize.Qty;
                    }

                    listOrderDetails.Add(new KeyValuePair<int, string>(objPackingList.PackingList.Value, qty));
                }

                labelText = obj.CartonNo + "-" + obj.ListPackingList[0].WeeklyProductionCapacity.ToString();

                /* DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO();
                 objDistributorClientAddress.ID = shipto;
                 objDistributorClientAddress.GetObject();*/

                InvoiceOrderBO objInvoiceOrder = new InvoiceOrderBO();
                objInvoiceOrder.OrderDetail = (int)obj.ListPackingList[0].OrderDetail;

                string invoiceno = objInvoiceOrder.SearchObjects().Select(o => o.objInvoice.InvoiceNo).SingleOrDefault();


                GenerateBarcode.GenerateCartonLabel(lblBM, obj.CartonNo.ToString(), listOrderDetails, labelText, imageLocation, invoiceno/* objDistributorClientAddress, shipmentmode*/);

                lblBM.Dispose();
                File.Delete(tempPath);
            }

            // string excelFileName = "CartonLabels" + ".xlsx";

            // CreateExcelDocument excell_app = new CreateExcelDocument(imageLocation, excelFileName, 400, 255, 255, true); //(imageLocation, excelFileName, 400, 275, 275, true); NNM
            string pdfpath = GenerateOdsPdf.PrintCartonBarcode(imageLocation);

            foreach (string imagePath in Directory.GetFiles(imageLocation, "*.jpg"))
            {
                File.Delete(imagePath);
            }

            //this.DownloadExcelFile(imageLocation + excelFileName);//NNM
            if (File.Exists(pdfpath))
            {
                this.DownloadPDFFile(pdfpath);
            }
        }

        private void AutoFillCarton(List<PackingList> lstPackingList)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {

                    //PackingListSizeQtyBO obj = new PackingListSizeQtyBO();
                    //obj.PackingList = PackingListID;

                    //List<PackingListSizeQtyBO> lstPackingListSizeQty = obj.SearchObjects();

                    foreach (PackingList item in lstPackingList)
                    {
                        foreach (PackingListViewBO plv in item.ListPackingList)
                        {

                            List<PackingListSizeQtyBO> lstPackingListSizeQty = (new PackingListSizeQtyBO()).GetAllObject().Where(o => o.PackingList == plv.PackingList).ToList();

                            foreach (PackingListSizeQtyBO plsq in lstPackingListSizeQty)
                            {

                                PackingListCartonItemBO objPackListCartonItem = new PackingListCartonItemBO();
                                objPackListCartonItem.PackingList = plsq.PackingList;
                                objPackListCartonItem.Size = plsq.Size;
                                List<PackingListCartonItemBO> lstCartonItem = objPackListCartonItem.SearchObjects();

                                if (!lstCartonItem.Any())
                                {
                                    // no records
                                    PackingListCartonItemBO objPackListCartonItemToSave = new PackingListCartonItemBO(this.ObjContext);
                                    objPackListCartonItemToSave.PackingList = objPackListCartonItem.PackingList;
                                    objPackListCartonItemToSave.Size = objPackListCartonItem.Size;
                                    objPackListCartonItemToSave.Count = plsq.Qty;
                                }
                                else if (lstCartonItem.Any())// && (lstCartonItem.SingleOrDefault().Count <plsq.objPackingList.bjOrderDetailQty.Qty))
                                {
                                    //update
                                    PackingListCartonItemBO objPackListCartonItemToSave = new PackingListCartonItemBO(this.ObjContext);
                                    objPackListCartonItemToSave.ID = lstCartonItem.SingleOrDefault().ID;
                                    objPackListCartonItemToSave.GetObject();

                                    objPackListCartonItemToSave.Count = plsq.Qty;
                                }
                            }
                        }
                    }
                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Saving PackingListCartonItem From ViewPackingLists.aspx Page when click AutoFillCarton Function", ex);
            }
        }

        private void GenerateResetCarton()
        {
            //NNM

            string imageLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Barcode\\" + Guid.NewGuid() + "\\";
            Directory.CreateDirectory(imageLocation);
            string tempPath = imageLocation + "temp.jpg";

            Bitmap lblBM = new Bitmap(400, 275);
            using (Graphics gfx = Graphics.FromImage(lblBM))
            using (SolidBrush brush = new SolidBrush(Color.White))
            {
                gfx.FillRectangle(brush, 0, 0, 400, 275);
            }
            lblBM.Save(tempPath);

            string imagePath = GenerateBarcode.GenerateResetLabel(lblBM, "Reset", imageLocation);

            string pdfPath = GenerateOdsPdf.PrintResetBarcode(imageLocation, imagePath);

            lblBM.Dispose();
            File.Delete(tempPath);

            // download pdf
            if (File.Exists(pdfPath))
            {
                this.DownloadPDFFile(pdfPath);
            }

            // delete image file
            if (File.Exists(imagePath))
            {
                File.Delete(imagePath);
            }

        }

        #endregion

        #region Internal Class

        public class PackingList
        {
            public int CartonNo;
            public List<PackingListViewBO> ListPackingList;

            public PackingList()
            {
                ListPackingList = new List<PackingListViewBO>();
            }
        }

        #endregion
    }
}