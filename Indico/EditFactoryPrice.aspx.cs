using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

using Indico.BusinessObjects;
using Indico.Common;
using System.Threading;
using System.IO;
using System.Web.Services;
using Excel = Microsoft.Office.Interop.Excel;

namespace Indico
{
    public partial class EditFactoryPrice : IndicoPage
    {
        #region Fields

        private int urlQueryID = 0;
        private PatternBO _activePatternBO;
        private List<FabricCodeBO> _activePatternFabrics;

        #endregion

        #region Properties

        protected int QueryID
        {
            get
            {
                if (urlQueryID > 0)
                    return urlQueryID;

                urlQueryID = 0;
                if (Request.QueryString["id"] != null)
                {
                    urlQueryID = Convert.ToInt32(Request.QueryString["id"].ToString());
                }
                return urlQueryID;
            }
        }

        protected PatternBO ActivePattern
        {
            get
            {
                if (_activePatternBO == null || _activePatternBO.ID == 0)
                {
                    _activePatternBO = new PatternBO(this.ObjContext);
                    _activePatternBO.ID = this.QueryID;
                    _activePatternBO.GetObject();
                }
                return _activePatternBO;
            }
        }

        protected List<FabricCodeBO> FabricCodesWhereThisIsPattern
        {
            get
            {
                if (_activePatternFabrics == null || _activePatternFabrics.Count == 0)
                {
                    _activePatternFabrics = this.ActivePattern.PricesWhereThisIsPattern.OrderBy(o => o.ID).Select(o => o.objFabricCode).ToList();
                }
                return _activePatternFabrics;
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
        
        protected void rptSpecSizeQtyHeader_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
            {
                SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

                Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
                litCellHeader.Text = objSizeChart.objSize.SizeName;
            }
        }

        protected void rptSpecML_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, SizeChartBO>)
            {
                List<SizeChartBO> lstSizeChart = ((IGrouping<int, SizeChartBO>)item.DataItem).ToList();

                MeasurementLocationBO objML = new MeasurementLocationBO();
                objML.ID = lstSizeChart[0].MeasurementLocation;
                objML.GetObject();

                Literal litCellHeaderKey = (Literal)item.FindControl("litCellHeaderKey");
                litCellHeaderKey.Text = objML.Key;

                Literal litCellHeaderML = (Literal)item.FindControl("litCellHeaderML");
                litCellHeaderML.Text = objML.Name;

                Repeater rptSpecSizeQty = (Repeater)item.FindControl("rptSpecSizeQty");
                rptSpecSizeQty.DataSource = lstSizeChart;
                rptSpecSizeQty.DataBind();
            }
        }

        protected void rptSpecSizeQty_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
            {
                SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

                Label lblCellData = (Label)item.FindControl("lblCellData");
                lblCellData.Text = objSizeChart.Val.ToString();
            }
        }

        protected void dgSelectedFabrics_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PriceLevelCostViewBO)
            {
                PriceLevelCostViewBO objPriceLevelCostView = (PriceLevelCostViewBO)item.DataItem;

                Literal lblPatternNumber = (Literal)item.FindControl("lblPatternNumber");
                lblPatternNumber.Text = objPriceLevelCostView.Number;

                Literal lblNickName = (Literal)item.FindControl("lblNickName");
                lblNickName.Text = objPriceLevelCostView.NickName;

                Literal lblFabricName = (Literal)item.FindControl("lblFabricName");
                lblFabricName.Text = objPriceLevelCostView.FabricCodeName;

                HtmlControl olPriceTable = (HtmlControl)item.FindControl("olPriceTable");
                HtmlButton btnApply = (HtmlButton)item.FindControl("btnApply");
                btnApply.Attributes.Add("table", olPriceTable.ClientID);
                btnApply.Attributes.Add("qid", objPriceLevelCostView.ID.ToString());
                btnApply.Attributes.Add("pnumber", objPriceLevelCostView.Number);
                btnApply.Attributes.Add("fname", objPriceLevelCostView.FabricCodeName);
                btnApply.Attributes.Add("nickname", objPriceLevelCostView.NickName);

                LinkButton btnUpdate = (LinkButton)item.FindControl("btnUpdate");
                /*btnUpdate.Attributes.Add("qid", objPriceLevelCostView.ID.ToString());
                btnUpdate.Attributes.Add("pnumber", objPriceLevelCostView.Number);
                btnUpdate.Attributes.Add("fname", objPriceLevelCostView.FabricCodeName);
                btnUpdate.Attributes.Add("nickname", objPriceLevelCostView.NickName);*/

                HyperLink linkAddEditNote = (HyperLink)item.FindControl("linkAddEditNote");
                linkAddEditNote.Attributes.Add("PriceID", objPriceLevelCostView.ID.ToString());


                FactoryPriceRemarksBO objFactoryPriceRemarks = new FactoryPriceRemarksBO();
                objFactoryPriceRemarks.Price = objPriceLevelCostView.ID.Value;
                List<FactoryPriceRemarksBO> lstFactoryPriceRemarks = objFactoryPriceRemarks.SearchObjects().ToList();

                if (lstFactoryPriceRemarks.Count > 0)
                {

                    LinkButton btnViewNote = (LinkButton)item.FindControl("btnViewNote");
                    btnViewNote.Attributes.Add("pid", objPriceLevelCostView.ID.ToString());
                    btnViewNote.Visible = true;
                }

                //HtmlButton btnDelete = (HtmlButton)item.FindControl("btnDelete");
                //btnDelete.Attributes.Add("qid", lstPrices[0].ID.ToString());

                PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO();
                objPriceLevelCost.Price = (int)objPriceLevelCostView.ID;
                List<PriceLevelCostBO> lstPriceLevelCost = objPriceLevelCost.SearchObjects();

                Repeater rptPriceLevelCost = (Repeater)item.FindControl("rptPriceLevelCost");
                rptPriceLevelCost.DataSource = lstPriceLevelCost;
                rptPriceLevelCost.DataBind();
            }
        }

        protected void rptPriceLevelCost_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PriceLevelCostBO)
            {
                PriceLevelCostBO objPriceLevelCost = (PriceLevelCostBO)item.DataItem;

                Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
                litCellHeader.Text = objPriceLevelCost.objPriceLevel.Name + "<em>( " + objPriceLevelCost.objPriceLevel.Volume + " )</em>";

                HiddenField hdnCellID = (HiddenField)item.FindControl("hdnCellID");
                hdnCellID.Value = objPriceLevelCost.ID.ToString();

                Label lblCellData = (Label)item.FindControl("lblCellData");
                lblCellData.Attributes.Add("level", objPriceLevelCost.PriceLevel.ToString());
                lblCellData.Text = objPriceLevelCost.FactoryCost.ToString("0.00");
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            int priceID = int.Parse(((System.Web.UI.HtmlControls.HtmlControl)(sender)).Attributes["qid"]);
            if (priceID > 0)
            {
                Repeater rptPriceLevelCost = (Repeater)((System.Web.UI.HtmlControls.HtmlControl)(sender)).FindControl("rptPriceLevelCost");
                if (rptPriceLevelCost != null)
                {
                   this.ProcessForm(rptPriceLevelCost, priceID);

                    // Populate active pattern fabrics
                    this.GetPriceLevelCostList();
                }
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int fabricCode = int.Parse(this.hdnSelectedID.Value.Trim());
            if (Page.IsValid)
            {
                /*try
                {
                    List<PriceBO> lstPrices = (from o in (new PriceBO()).SearchObjects()
                                               where o.Pattern == this.QueryID &&
                                                     o.FabricCode == fabricCode
                                               select o).ToList();
                    if (lstPrices.Count > 0)
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            PriceBO objPrice = new PriceBO(this.ObjContext);
                            objPrice.ID = lstPrices[0].ID;
                            objPrice.GetObject();

                            foreach (PriceLevelCostBO item in objPrice.PriceLevelCostsWhereThisIsPrice)
                            {
                                PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO(this.ObjContext);
                                objPriceLevelCost.ID = item.ID;
                                objPriceLevelCost.GetObject();

                                objPriceLevelCost.Delete();
                            }

                            objPrice.Delete();

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }

                        // Populate Fabric codes
                        this.PopulateDataGrid();
                    }
                }
                catch (Exception)
                {
                    // Log the error
                    //IndicoLogging.log("btnDelete_Click : Error occured while Adding the Item", ex);
                }*/
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(this.txtSearchAny.Text))
            {
                this.GetPriceLevelCostList();
                ViewState["populateProgress"] = false;

            }
            else
            {
                this.dvEmptyContent.Visible = true;
                this.dgSelectedFabrics.Visible = false;
                this.h2EmptyContent.InnerText = "Please enter value to search";
                this.pEmptyContent.InnerText = string.Empty;
            }

        }

        protected void dgSelectFabrics_PageIndexChanged(object sender, DataGridPageChangedEventArgs e)
        {
            this.dgSelectedFabrics.CurrentPageIndex = e.NewPageIndex;
            this.GetPriceLevelCostList();
        }

        protected void btnSaveNote_Click(object sender, EventArgs e)
        {
            int Priceid = int.Parse(this.PriceID.Value);
            if (this.IsNotRefresh)
            {
                if (Page.IsValid)
                {
                    if (Priceid > 0)
                    {
                        try
                        {
                            using (TransactionScope ts = new TransactionScope())
                            {
                                FactoryPriceRemarksBO objFactoryPriceRemarks = new FactoryPriceRemarksBO(this.ObjContext);
                                objFactoryPriceRemarks.Remarks = this.txtNote.Text;
                                objFactoryPriceRemarks.Price = Priceid;
                                objFactoryPriceRemarks.Creator = LoggedUser.ID;
                                objFactoryPriceRemarks.CreatedDate = DateTime.Now;

                                this.ObjContext.SaveChanges();
                                ts.Complete();
                            }
                        }
                        catch (Exception ex)
                        {
                            IndicoLogging.log.Error("Error occured while saving factory price remarks", ex);
                        }
                    }
                }
                ViewState["populateAddEditNote"] = !(Page.IsValid);
                ViewState["PopulateViewNote"] = false;
                this.GetPriceLevelCostList();
            }
        }

        protected void btnViewNote_Click(object sender, EventArgs e)
        {
            int priceid = (sender != null) ? int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["pid"]) : 0;
            if (this.IsNotRefresh)
            {
                if (priceid > 0)
                {
                    FactoryPriceRemarksBO objFactoryPriceRemarks = new FactoryPriceRemarksBO();
                    objFactoryPriceRemarks.Price = priceid;
                    List<FactoryPriceRemarksBO> lstFactoryPriceRemarks = objFactoryPriceRemarks.SearchObjects().ToList();

                    if (lstFactoryPriceRemarks.Count > 0)
                    {
                        this.dgViewNote.DataSource = lstFactoryPriceRemarks;
                        this.dgViewNote.DataBind();
                        this.dvNoteEmptyContent.Visible = false;
                        this.dgViewNote.Visible = true;
                    }
                    else
                    {
                        this.dvNoteEmptyContent.Visible = true;
                        this.dgViewNote.Visible = false;
                    }
                }

                ViewState["populateAddEditNote"] = false;
                ViewState["PopulateViewNote"] = true;
            }
            else
            {
                ViewState["populateAddEditNote"] = false;
                ViewState["PopulateViewNote"] = false;
            }
        }

        protected void dgViewNote_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is FactoryPriceRemarksBO)
            {
                FactoryPriceRemarksBO objFactoryPriceRemarks = (FactoryPriceRemarksBO)item.DataItem;
                UserBO objUser = new UserBO();
                objUser.ID = objFactoryPriceRemarks.Creator;
                List<UserBO> lstUser = objUser.SearchObjects().ToList();

                Literal lblCreator = (Literal)item.FindControl("lblCreator");
                if (lstUser.Count > 0)
                {
                    lblCreator.Text = lstUser[0].FamilyName + " " + lstUser[0].GivenName;
                }
                Literal lblCreatedDate = (Literal)item.FindControl("lblCreatedDate");
                lblCreatedDate.Text = objFactoryPriceRemarks.CreatedDate.ToShortDateString();

                Literal lblRemarks = (Literal)item.FindControl("lblRemarks");
                lblRemarks.Text = objFactoryPriceRemarks.Remarks;

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("pr", objFactoryPriceRemarks.ID.ToString());
            }
        }

        protected void btnDeleteFactoryPriceRemarks_Click(object sender, EventArgs e)
        {
            int id = int.Parse(this.hdnFactoryPriceRemarks.Value);
            if (this.IsNotRefresh)
            {
                if (id > 0)
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        FactoryPriceRemarksBO objFactoryPriceRemarks = new FactoryPriceRemarksBO(this.ObjContext);
                        objFactoryPriceRemarks.ID = id;
                        objFactoryPriceRemarks.GetObject();

                        objFactoryPriceRemarks.Delete();

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }

                }
            }
            ViewState["populateAddEditNote"] = false;
            ViewState["PopulateViewNote"] = false;
            this.GetPriceLevelCostList();
        }

        protected void btndownloadExcel_Click(object sender, EventArgs e)
        {
            //if (this.IsNotRefresh)
            //{

            #region PriceTerm

            int priceTerm = 0;
            string priceTermName = string.Empty;
            if (this.ddlPriceTerm.SelectedValue == "1")
            {
                priceTerm = 1;
                priceTermName = "CIF Price";
            }
            else if (this.ddlPriceTerm.SelectedValue == "1")
            {
                priceTerm = 2;
                priceTermName = "FOB Price";
            }

            #endregion

            string fileName = "Factory_" + this.ddlExcelDistributor.SelectedItem.Text.Trim().ToUpper() + "_" + ((priceTerm == 1) ? "CIF" : "FOB") + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".xlsx";
            string filepath = String.Format("{0}{1}", (IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\PriceLists\"), fileName);
            ViewState["filePath"] = fileName;

            Thread oThread = new Thread(new ThreadStart(() => GenerateExcel(filepath, int.Parse(this.ddlPriceTerm.SelectedValue), this.ddlPriceTerm.SelectedItem.Text)));
            oThread.IsBackground = true;
            oThread.Start();
            ViewState["populateProgress"] = true;
            // this.GenerateExcel(filePath, int.Parse(this.ddlPriceTerm.SelectedValue), this.ddlPriceTerm.SelectedItem.Text); 
            //ViewState["PopulateEmailAddress"] = false;                
            //}
        }

        protected void btnDownload_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                string filename = ViewState["filePath"].ToString();
                string filePath = String.Format("{0}{1}", (IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\PriceLists\"), filename);

                while (true)
                {
                    if (File.Exists(filePath))
                    {
                        try
                        {
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
                            //Response.End();                      
                        }
                        catch (Exception ex)
                        {
                            // Log the error
                            IndicoLogging.log.Error("Fail to download Indiman excel file.", ex);
                        }
                    }
                    break;
                }
            }
            ViewState["populateProgress"] = false;
            //ViewState["PopulateEmailAddress"] = false;

        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            ViewState["populateAddEditNote"] = false;
            ViewState["PopulateViewNote"] = false;

            this.dvEmptyContent.Visible = false;
            this.litHeaderText.Text = this.ActivePage.Heading;

            //Populate Fabric Code 
            List<FabricCodeBO> lstFabricCode = (from o in (new FabricCodeBO()).SearchObjects().OrderBy(o => o.Name) select o).ToList();
            this.ddlFabricCode.Items.Add(new ListItem("Select Fabric Name", "0"));
            foreach (FabricCodeBO fabriccode in lstFabricCode)
            {
                this.ddlFabricCode.Items.Add(new ListItem(fabriccode.Name, fabriccode.ID.ToString()));
            }

            if (this.QueryID > 0)
            {
                // Header Text
                // this.litHeaderText.Text = this.ActivePage.Heading;

                // Populate active fabric
                this.GetPriceLevelCostList();

                // Set default values
                ViewState["IsPageValied"] = true;
            }
            else
            {
                //this.GetPriceLevelCostList();
                //Response.Redirect("/ViewPrices.aspx");
            }

            // populate price term
            this.ddlPriceTerm.Items.Clear();
            this.ddlPriceTerm.Items.Add(new ListItem("Select Price Term", "0"));
            List<PriceTermBO> lstPriceTerm = (new PriceTermBO()).SearchObjects().ToList();
            foreach (PriceTermBO pt in lstPriceTerm)
            {
                this.ddlPriceTerm.Items.Add(new ListItem(pt.Name, pt.ID.ToString()));
            }

            this.ddlPriceTerm.Items.FindByValue("1").Selected = true;

            // Populate distributors dropdown
            this.ddlExcelDistributor.Items.Clear();
            List<int> lstDistributors = (new DistributorPriceMarkupBO()).GetAllObject().Where(o => o.Distributor != 0).Select(o => (int)o.Distributor).Distinct().ToList();
            this.ddlExcelDistributor.Items.Add(new ListItem("PLATINUM", "0"));
            foreach (int id in lstDistributors)
            {
                CompanyBO item = new CompanyBO(this.ObjContext);
                item.ID = id;
                item.GetObject();

                this.ddlExcelDistributor.Items.Add(new ListItem(item.Name, item.ID.ToString()));
            }

            this.btndownloadExcel.Visible = (this.LoggedUserRoleName == UserRole.FactoryAdministrator) ? true : false;
        }

        //private void PopulatePattern()
        //{
        //    // Populate pattern data
        //    this.txtPattern.Text = this.ActivePattern.Number + " - " + this.ActivePattern.NickName;
        //    //this.txtConvertionFactor.Text = this.ActivePattern.ConvertionFactor.ToString();
        //    //this.txtRemarks.Text = (this.ActivePattern.PriceRemarks != null) ? this.ActivePattern.PriceRemarks.ToString() : string.Empty;
        //    this.linkViewPattern.Visible = true;

        //    // Populate pattern popup data
        //    this.txtPatternNo.Text = this.ActivePattern.Number;
        //    this.txtItemName.Text = this.ActivePattern.objItem.Name;
        //    this.txtSizeSet.Text = this.ActivePattern.objSizeSet.Name;
        //    this.txtAgeGroup.Text = this.ActivePattern.objAgeGroup.Name;
        //    this.txtPrinterType.Text = this.ActivePattern.objPrinterType.Name;
        //    this.txtKeyword.Text = this.ActivePattern.Keywords;
        //    this.txtOriginalRef.Text = this.ActivePattern.OriginRef;
        //    this.txtSubItem.Text = this.ActivePattern.objSubItem.Name;
        //    this.txtGender.Text = this.ActivePattern.objGender.Name;
        //    this.txtNickName.Text = this.ActivePattern.NickName;
        //    this.txtCorrPattern.Text = this.ActivePattern.CorePattern;
        //    this.txtConsumption.Text = this.ActivePattern.Consumption;

        //    List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = (this.ActivePattern.SizeChartsWhereThisIsPattern).OrderBy(o => o.MeasurementLocation).GroupBy(o => o.MeasurementLocation).ToList();
        //    if (lstSizeChartGroup.Count > 0)
        //    {
        //        this.rptSpecSizeQtyHeader.DataSource = (List<SizeChartBO>)lstSizeChartGroup[0].ToList();
        //        this.rptSpecSizeQtyHeader.DataBind();

        //        this.rptSpecML.DataSource = lstSizeChartGroup;
        //        this.rptSpecML.DataBind();
        //    }
        //    this.linkSpecification.Visible = (lstSizeChartGroup.Count > 0);

        //    // Populate active pattern fabrics
        //    this.PopulatePatternFabrics();
        //}

        //private void PopulatePatternFabrics()
        //{
        //    this.dgSelectedFabrics.DataSource = FabricCodesWhereThisIsPattern;
        //    this.dgSelectedFabrics.DataBind();

        //    this.dgSelectedFabrics.Visible = (FabricCodesWhereThisIsPattern.Count > 0);
        //    this.dvEmptyContent.Visible = !(this.dgSelectedFabrics.Visible);
        //}

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm(Repeater repeaterCost, int priceID)
        {
            try
            {
                string price = string.Empty;

                using (TransactionScope ts = new TransactionScope())
                {
                    PriceBO objPrice = new PriceBO(this.ObjContext);
                    objPrice.ID = priceID;
                    objPrice.GetObject();

                    objPrice.Modifier = this.LoggedUser.ID;
                    objPrice.ModifiedDate = Convert.ToDateTime(DateTime.Now.ToString("g"));

                    foreach (RepeaterItem item in repeaterCost.Items)
                    {
                        HiddenField hdnCellID = (HiddenField)item.FindControl("hdnCellID");
                        Label lblCellData = (Label)item.FindControl("lblCellData");

                        int priceLevel = int.Parse(lblCellData.Attributes["level"].ToString().Trim());
                        int priceLevelCost = int.Parse(hdnCellID.Value.Trim());

                        PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO(this.ObjContext);
                        if (priceLevelCost > 0)
                        {
                            objPriceLevelCost.ID = priceLevelCost;
                            objPriceLevelCost.GetObject();

                            if (this.hdnFactoryPrice.Value != "0")
                            {
                                price = this.hdnFactoryPrice.Value;
                            }
                            else if (this.hdnFactoryPrice.Value == "0")
                            {
                                price = "0";
                            }
                            else
                            {
                                price = lblCellData.Text;
                            }                            
                        }
                        else
                        {
                            objPriceLevelCost.Creator = this.LoggedUser.ID;
                            objPriceLevelCost.CreatedDate = DateTime.Now;
                        }

                        objPriceLevelCost.FactoryCost = Convert.ToDecimal(decimal.Parse(price.Trim()).ToString("0.00"));
                        objPriceLevelCost.Modifier = this.LoggedUser.ID;
                        objPriceLevelCost.ModifiedDate = DateTime.Now;
                    }
                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }

                Thread threadSendMail = new Thread(new ThreadStart(this.SendEmail));
                threadSendMail.Start();
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while editing factory price EditFactoryPrice.aspx", ex);
            }
        }

        private void GetPriceLevelCostList()
        {
            string search = this.txtSearchAny.Text.Trim().ToLower();
            string pnumber = this.txtPattern.Text.Trim();
            string pnickname = this.txtPatternNickName.Text.Trim().ToLower();
            int fcode = int.Parse(this.ddlFabricCode.SelectedValue);

            List<PriceLevelCostViewBO> lstPriceLevelCostView = new List<PriceLevelCostViewBO>();
            if (!string.IsNullOrEmpty(search))
            {
                lstPriceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o => o.Number.ToLower().Contains(search) ||
                                                                                                 o.NickName.ToLower().Contains(search) ||
                                                                                                 o.FabricCodeName.ToLower().Contains(search)).ToList();
            }
            else if (QueryID > 0)
            {
                lstPriceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o => o.Pattern == QueryID).ToList();
                this.txtPatternNickName.Text = lstPriceLevelCostView[0].NickName;
                this.txtPattern.Text = lstPriceLevelCostView[0].Number;
            }
            else
            {
                if (!string.IsNullOrEmpty(pnumber) && !string.IsNullOrEmpty(pnickname))
                {
                    lstPriceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o => o.Number.ToLower().Contains(pnumber) ||
                                                                                                   o.NickName.ToLower().Contains(pnickname) ||
                                                                                                   o.FabricCode.Value == fcode).ToList();
                }
                else if (!string.IsNullOrEmpty(pnumber))
                {
                    lstPriceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o => o.Number.Trim().Contains(pnumber) ||
                                                                                                    o.FabricCode.Value == fcode).ToList();
                }
                else if (!string.IsNullOrEmpty(pnickname))
                {
                    lstPriceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o => o.NickName.ToLower().Contains(pnickname) ||
                                                                                                    o.FabricCode.Value == fcode).ToList();
                }
            }

            if (lstPriceLevelCostView.Count > 0)
            {
                this.dgSelectedFabrics.AllowPaging = (lstPriceLevelCostView.Count > this.dgSelectedFabrics.PageSize);
                this.dgSelectedFabrics.DataSource = lstPriceLevelCostView;
                this.dgSelectedFabrics.DataBind();
                this.dgSelectedFabrics.Visible = (lstPriceLevelCostView.Count > 0);
                this.dvEmptyContent.Visible = !(this.dgSelectedFabrics.Visible);

            }
            else
            {
                this.dgSelectedFabrics.Visible = (lstPriceLevelCostView.Count > 0);
                this.dvEmptyContent.Visible = true;
                this.h2EmptyContent.InnerText = "There are no Fabrics associated with this Pattern.";
                this.pEmptyContent.InnerText = "Once Pattern is added then you will be able to add Fabrics.";
            }
        }

        private void SendEmail()
        {
            try
            {
                string pnumber = this.hdnPattern.Value.Split(',')[0].ToString();
                string fName = this.hdnFabric.Value;
                string NickName = this.hdnPattern.Value.Split(',')[1].ToString();
                if (pnumber != string.Empty && fName != string.Empty)
                {
                    string emailContent = "<p>Dear Administrator,<br><br>" +
                                          "The Price has been added or edited on " + DateTime.Now.ToLongDateString() + " for the following Pattern: <br><br>" +
                                          "Pattern Number: " + pnumber + " <br>" +
                                          "Nick Name: " + NickName + "<br>" +
                                          "Fabric Name: " + fName + "<br><br>" +
                                          "Regrads, <br>" +
                                          "OPS Team</p><br>";

                    string mailcc = IndicoConfiguration.AppConfiguration.FactoryAdministratorEmail;
                    if (mailcc != string.Empty)
                    {
                        IndicoEmail.SendMailFromSystem("Indico OPS", IndicoConfiguration.AppConfiguration.IndimanAdministratorEmail, mailcc, "Factory price has been added or edited", emailContent, true);
                    }
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while send email for factory price change", ex);
            }
        }

        private void GenerateExcel(string filePath, int priceTerm, string priceTermName)
        {
            // get a write lock on scCacheKeys
            IndicoPage.RWLock.AcquireWriterLock(Timeout.Infinite);

            string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\factoryprogress_" + 1 + ".txt";
            if (File.Exists(textFilePath))
            {
                File.Delete(textFilePath);
            }

            // Excel
            double xlProgress = 0;
            int i = 0;
            string creativeDesign = string.Empty;
            string studioDesign = string.Empty;
            string thirdPartyDesign = string.Empty;
            string position1 = string.Empty;
            string position2 = string.Empty;
            string position3 = string.Empty;
            string priceValidDate = string.Empty;
            int row = 7;

            DefaultValuesPriceListBO objDefaultPriceList = new DefaultValuesPriceListBO().SearchObjects().SingleOrDefault();
            //string lines = xlProgress.ToString();           

            CreateExcelDocument excell_app = new CreateExcelDocument(true);

            #region checkDesign

            /*if (checkCreativeDesign.Checked)
            {
                if (!string.IsNullOrEmpty(txtCreativeDesign.Text) && this.txtCreativeDesign.Text != objDefaultPriceList.CreativeDesign.ToString())
                {
                    creativeDesign = "Creative Design Set Up Fee: $" + txtCreativeDesign.Text + " + GST per Job";
                }
                else
                {
                    creativeDesign = "Creative Design Set Up Fee: $" + objDefaultPriceList.CreativeDesign.ToString() + " + GST per Job";
                }
            }
            if (checkStudioDesign.Checked)
            {
                if (!string.IsNullOrEmpty(txtStudioDesign.Text) && this.txtStudioDesign.Text != objDefaultPriceList.StudioDesign.ToString())
                {
                    studioDesign = "Studio Design Set Up Fee: $" + txtStudioDesign.Text + " + GST per Job";
                }
                else
                {
                    studioDesign = "Studio Design Set Up Fee: $" + objDefaultPriceList.StudioDesign.ToString() + " + GST per Job";
                }
            }
            if (checkThirdPartyDesign.Checked)
            {
                if (!string.IsNullOrEmpty(txtThirdPartyDesign.Text) && this.txtThirdPartyDesign.Text != objDefaultPriceList.ThirdPartyDesign.ToString())
                {
                    thirdPartyDesign = "Third Party Design Set Up Fee: $" + txtThirdPartyDesign.Text + " + GST per Job";
                }
                else
                {
                    thirdPartyDesign = "Third Party Design Set Up Fee: $" + objDefaultPriceList.ThirdPartyDesign.ToString() + " + GST per Job";
                }
            }*/

            #endregion

            #region checkPsotion

            /*if (checkPositionOne.Checked)
            {
                if (!string.IsNullOrEmpty(txtPositionOne.Text) && this.txtPositionOne.Text != objDefaultPriceList.Position1.ToString())
                {
                    position1 = "1 x Position @ $" + txtPositionOne.Text + " - eg name on left chest";
                }
                else
                {
                    position1 = "1 x Position @ $" + objDefaultPriceList.Position1.ToString() + " - eg name on left chest";
                }
            }
            if (checkPositionTwo.Checked)
            {
                if (!string.IsNullOrEmpty(txtPositionTwo.Text) && this.txtPositionTwo.Text != objDefaultPriceList.Position2.ToString())
                {
                    position2 = "2 x Positions @ $" + txtPositionTwo.Text + " - eg names on left chest and upper back";
                }
                else
                {
                    position2 = "2 x Positions @ $" + objDefaultPriceList.Position2.ToString() + " - eg names on left chest and upper back";
                }
            }
            if (checkPositionThree.Checked)
            {
                if (!string.IsNullOrEmpty(txtPositionThree.Text) && this.txtPositionThree.Text != objDefaultPriceList.Position3.ToString())
                {
                    position3 = "3 x Positions @ $" + txtPositionThree.Text + " - eg names on left chest, upper back and number on lower back";
                }
                else
                {
                    position3 = "3 x Positions @ $" + objDefaultPriceList.Position3.ToString() + " - eg names on left chest, upper back and number on lower back";
                }
            }*/
            #endregion

            try
            {
                int distributor = int.Parse(this.ddlExcelDistributor.SelectedValue);

                String excelType = string.Empty;
                PriceBO objPrice = new PriceBO();
                ExcelPriceLevelCostViewBO excel = new ExcelPriceLevelCostViewBO();
                List<ExcelPriceLevelCostViewBO> lstpr = (from o in excel.SearchObjects()
                                                         orderby o.SportsCategory
                                                         select o).ToList();

                // first row
                excell_app.AddHeaderData(1, 1, "" + this.ddlExcelDistributor.SelectedItem.Text.ToUpper() + " - " + priceTermName + " PRICE LIST ALL PLUS GST PLUS LOCAL FREIGHT EX-ADELAIDE", "A1", "D1", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
                // Second row
                excell_app.AddHeaderData(2, 1, "INDICO PTY LTD", "A2", "B2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
                excell_app.AddHeaderData(2, 3, "Published Date: " + DateTime.Now.ToString("dd MMMM yyyy") + "", "C2", "D2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
                excell_app.AddHeaderData(2, 5, "" + creativeDesign + "     " + studioDesign + "     " + thirdPartyDesign + "", "E2", "F2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
                excell_app.AddHeaderData(2, 9, "QUANTITY", "G2", "N2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                // Third row
                // excell_app.AddHeaderData(3, 3, priceValidDate, "C5", "D5", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "dd MMMM yyyy");
                // Fourth row
                excell_app.AddHeaderData(4, 1, "Individual Names & Numbers are charged as follows:     " + position1 + "     " + position2 + "    " + position3 + " ", "A4", "F4", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
                excell_app.AddHeaderData(4, 9, "All re-orders under 20 units wll have the benefit of receiving the 20 unit price", "G4", "N4", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                // Column headers
                excell_app.AddHeaderData(6, 1, "SPORTS CATEGORY", "A6", "A6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                excell_app.AddHeaderData(6, 2, "OTHER CATEGORIES", "B6", "B6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                excell_app.AddHeaderData(6, 3, "PATTERN", "C6", "C6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                excell_app.AddHeaderData(6, 4, "ITEM SUB CATEGORY", "D6", "D6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                excell_app.AddHeaderData(6, 5, "DESCRIPTION", "E6", "E6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                excell_app.AddHeaderData(6, 6, "FABRIC", "F6", "F6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                excell_app.AddHeaderDataWithBackgroundColor(6, 7, "", "G6", "G6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
                //excell_app.AddHeaderDataWithBackgroundColor(6, 8, "'6 - 9", "H6", "H6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
                //excell_app.AddHeaderDataWithBackgroundColor(6, 9, "'10 - 19", "I6", "I6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
                //excell_app.AddHeaderData(6, 10, "20 - 49", "J6", "J6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                //excell_app.AddHeaderData(6, 11, "50 - 99", "K6", "K6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                //excell_app.AddHeaderData(6, 12, "100 - 249", "L6", "L6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                //excell_app.AddHeaderData(6, 13, "250 - 499", "M6", "M6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                //excell_app.AddHeaderData(6, 14, "500+", "N6", "N6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
                //------------------------------------------------------------------------------------------------------------------------\\

                string categoryName = string.Empty;
                // int row = 7;

                DistributorPatternPriceLevelCostViewBO cost = new DistributorPatternPriceLevelCostViewBO();
                DistributorNullPatternPriceLevelCostViewBO nullCost = new DistributorNullPatternPriceLevelCostViewBO();
                List<DistributorPatternPriceLevelCostViewBO> lstCost = null;
                List<DistributorNullPatternPriceLevelCostViewBO> lstNullCost = null;

                List<int> indicoPrice = new List<int>();
                foreach (ExcelPriceLevelCostViewBO o in lstpr)
                {
                    if (distributor == 0)
                    {
                        nullCost.Price = o.PriceID;
                        lstNullCost = nullCost.SearchObjects();
                    }
                    else
                    {
                        cost.Price = o.PriceID;
                        cost.Distributor = distributor;
                        lstCost = cost.SearchObjects();
                    }

                    if (categoryName == string.Empty || categoryName != o.SportsCategory)
                    {
                        excell_app.AddData(row, 1, "", "A" + row, "A" + row, null, Excel.XlHAlign.xlHAlignLeft);
                        categoryName = o.SportsCategory;

                        row++;
                    }
                    excell_app.AddData(row, 1, o.SportsCategory, "A" + row, "A" + row, null, Excel.XlHAlign.xlHAlignLeft);
                    excell_app.AddData(row, 2, o.OtherCategories, "B" + row, "B" + row, null, Excel.XlHAlign.xlHAlignLeft);
                    excell_app.AddData(row, 3, "'" + o.Number, "C" + row, "C" + row, "@", Excel.XlHAlign.xlHAlignLeft);
                    excell_app.AddData(row, 4, (o.ItemSubCategoris != null) ? o.ItemSubCategoris.ToUpper() : string.Empty, "D" + row, "D" + row, null, Excel.XlHAlign.xlHAlignLeft);
                    excell_app.AddData(row, 5, o.NickName.ToUpper(), "E" + row, "E" + row, null, Excel.XlHAlign.xlHAlignLeft);
                    excell_app.AddData(row, 6, o.FabricCodenNickName.ToUpper(), "F" + row, "F" + row, null, Excel.XlHAlign.xlHAlignLeft);

                    if (distributor != 0)
                    {
                        excell_app.AddDataWithBackgroundColor(row, 7, lstCost[0].FactoryCost.ToString(), "G" + row, "G" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 8, lstCost[1].FactoryCost.ToString(), "H" + row, "H" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 9, lstCost[2].FactoryCost.ToString(), "I" + row, "I" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 10, lstCost[3].FactoryCost.ToString(), "J" + row, "J" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 11, lstCost[4].FactoryCost.ToString(), "K" + row, "K" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 12, lstCost[5].FactoryCost.ToString(), "L" + row, "L" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 13, lstCost[6].FactoryCost.ToString(), "M" + row, "M" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 14, lstCost[7].FactoryCost.ToString(), "N" + row, "N" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                    }
                    else
                    {
                        excell_app.AddDataWithBackgroundColor(row, 7, lstNullCost[0].FactoryCost.ToString(), "G" + row, "G" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 8, lstNullCost[1].FactoryCost.ToString(), "H" + row, "H" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 9, lstNullCost[2].FactoryCost.ToString(), "I" + row, "I" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 10, lstNullCost[3].FactoryCost.ToString(), "J" + row, "J" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 11, lstNullCost[4].FactoryCost.ToString(), "K" + row, "K" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 12, lstNullCost[5].FactoryCost.ToString(), "L" + row, "L" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 13, lstNullCost[6].FactoryCost.ToString(), "M" + row, "M" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

                        //excell_app.AddDataWithBackgroundColor(row, 14, lstNullCost[7].FactoryCost.ToString(), "N" + row, "N" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
                    }
                    row++;
                    i++;

                    xlProgress = Math.Round(((double.Parse("100") / double.Parse(lstpr.Count.ToString())) * i), 0);

                    // Writing progress in text file.
                    string lines = xlProgress.ToString();
                    System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
                    file.WriteLine(lines);
                    file.Close();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Generation Excel.", ex);
            }
            finally
            {
                // Set AutoFilter colums
                excell_app.AutoFilter(row);
                // Save & Close the Excel Document
                excell_app.CloseDocument(filePath);

                // release the lock
                IndicoPage.RWLock.ReleaseWriterLock();


            }
        }

        [WebMethod]
        public static string Progress(string UserID)
        {
            string percentage = "0";
            string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\factoryprogress_" + 1 + ".txt";

            if (File.Exists(textFilePath))
            {
                try
                {
                    using (StreamReader sr = new StreamReader(textFilePath))
                    {
                        try
                        {
                            percentage = sr.ReadToEnd();
                        }
                        catch (Exception ex)
                        {
                            // Log the error
                            IndicoLogging.log.Error("Error occured while reading file. " + textFilePath, ex);
                        }
                        finally
                        {
                            sr.Close();
                        }
                    }
                }
                catch { }
            }
            return percentage;
        }
        #endregion
    }
}