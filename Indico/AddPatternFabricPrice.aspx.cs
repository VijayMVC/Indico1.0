using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class AddPatternFabricPrice : IndicoPage
    {
        #region Fields

        private int _urlQueryID;
        private PatternBO _activePatternBO;
        private List<FabricCodeBO> _activePatternFabrics;

        private bool isEnableIndimanCost = true;

        #endregion

        #region Properties

        protected int QueryID
        {
            get
            {
                if (_urlQueryID > 0)
                    return _urlQueryID;

                _urlQueryID = int.Parse(this.hdnPattern.Value.Trim());
                if ((_urlQueryID == 0) && (Request.QueryString["id"] != null))
                {
                    _urlQueryID = Convert.ToInt32(Request.QueryString["id"].ToString());
                }
                return _urlQueryID;
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

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["PriceSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "ID";
                }
                return sort;
            }
            set
            {
                ViewState["PriceSortExpression"] = value;
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
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                PopulateControls();
            }
        }

        protected override void OnPreRender(EventArgs e)
        {
            //Page Refresh
            Session["IsPostBack"] = Server.UrlEncode(Guid.NewGuid().ToString());
            ViewState["IsPostBack"] = Session["IsPostBack"];
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
            if (item.ItemIndex > -1 && item.DataItem is FabricCodeBO)
            {

                FabricCodeBO objFabric = (FabricCodeBO)item.DataItem;
                PriceBO objPrice = (new PriceBO()).GetAllObject().SingleOrDefault(o => o.Pattern == int.Parse(this.hdnPattern.Value) && o.FabricCode == objFabric.ID);

                Literal lblCreator = (Literal)item.FindControl("lblCreator");
                Literal lblCreateDate = (Literal)item.FindControl("lblCreateDate");
                LinkButton btnAddNote = (LinkButton)item.FindControl("btnAddNote");
                Literal litModifier = (Literal)item.FindControl("litModifier");
                Literal litMofiedDate = (Literal)item.FindControl("litMofiedDate");
                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");

                if (objPrice != null)
                {
                    lblCreator.Text = objPrice.objCreator.GivenName + " " + objPrice.objCreator.FamilyName;
                    lblCreateDate.Text = objPrice.CreatedDate.ToString("dd MMMM yyyy");
                    litModifier.Text = objPrice.objModifier.GivenName + " " + objPrice.objModifier.FamilyName;
                    litMofiedDate.Text = objPrice.ModifiedDate.ToString("dd MMMM yyyy");
                    btnAddNote.Attributes.Add("pid", objPrice.ID.ToString());
                    linkDelete.Attributes.Add("qid", objPrice.ID.ToString());
                    linkEdit.Attributes.Add("pid", objPrice.ID.ToString());
                    linkEdit.Attributes.Add("fid", objFabric.ID.ToString());
                }
                else
                {
                    lblCreator.Text = LoggedUser.GivenName + " " + LoggedUser.FamilyName;
                    lblCreateDate.Text = DateTime.Now.ToString("dd MMMM yyyy");
                    litModifier.Text = LoggedUser.GivenName + " " + LoggedUser.FamilyName;
                    litMofiedDate.Text = DateTime.Now.ToString("dd MMMM yyyy");
                }

               
                
            }
        }

        protected void rptPriceLevelCost_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {/*
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is DistributorPriceMarkupBO)
            {
                DistributorPriceMarkupBO objPriceMarkup = (DistributorPriceMarkupBO)item.DataItem;

                Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
                litCellHeader.Text = objPriceMarkup.objPriceLevel.Name + "<em>( " + objPriceMarkup.objPriceLevel.Volume + " )</em>";

                HiddenField hdnCellID = (HiddenField)item.FindControl("hdnCellID");
                hdnCellID.Value = "0";

                TextBox txtCIFPrice = (TextBox)item.FindControl("txtCIFPrice");
                txtCIFPrice.Attributes.Add("level", objPriceMarkup.PriceLevel.ToString());
                txtCIFPrice.Text = "0.00";
                txtCIFPrice.Enabled = isEnableIndimanCost;

                Label lblFOBPrice = (Label)item.FindControl("lblFOBPrice");
                lblFOBPrice.Text = "0.00";

                Label lblMarkup = (Label)item.FindControl("lblMarkup");
                lblMarkup.Text = objPriceMarkup.Markup + "%";

                Label lblCIFCost = (Label)item.FindControl("lblCIFCost");
                lblCIFCost.Text = "$0.0";

                Label lblFOBCost = (Label)item.FindControl("lblFOBCost");
                lblFOBCost.Text = "$0.0";
            }
            else if (item.ItemIndex > -1 && item.DataItem is PriceLevelCostBO)
            {
                PriceLevelCostBO objPriceLevelCost = (PriceLevelCostBO)item.DataItem;
                DistributorPriceMarkupBO objPriceMarkup = objPriceLevelCost.objPriceLevel.DistributorPriceMarkupsWhereThisIsPriceLevel.SingleOrDefault(o => (int)o.Distributor == int.Parse(this.ddlDistributors.SelectedValue.Trim()));

                decimal convertion = objPriceLevelCost.objPrice.objPattern.ConvertionFactor;
                decimal factoryCost = objPriceLevelCost.FactoryCost;
                decimal indimanCIFCost = (factoryCost == 0) ? 0 : Math.Round(Convert.ToDecimal((factoryCost * (100 + objPriceMarkup.Markup)) / 100), 2);

                Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
                litCellHeader.Text = objPriceLevelCost.objPriceLevel.Name + "<em>( " + objPriceLevelCost.objPriceLevel.Volume + " )</em>";

                HiddenField hdnCellID = (HiddenField)item.FindControl("hdnCellID");
                hdnCellID.Value = objPriceLevelCost.ID.ToString();

                TextBox txtCIFPrice = (TextBox)item.FindControl("txtCIFPrice");
                txtCIFPrice.Attributes.Add("level", objPriceLevelCost.PriceLevel.ToString());
                txtCIFPrice.Text = objPriceLevelCost.IndimanCost.ToString("0.00");
                txtCIFPrice.Enabled = isEnableIndimanCost;

                Label lblFOBPrice = (Label)item.FindControl("lblFOBPrice");
                lblFOBPrice.Text = ((objPriceLevelCost.IndimanCost != 0) ? (objPriceLevelCost.IndimanCost - objPriceLevelCost.objPrice.objPattern.ConvertionFactor).ToString("0.00") : "0.00");

                Label lblMarkup = (Label)item.FindControl("lblMarkup");
                lblMarkup.Text = objPriceMarkup.Markup.ToString() + "%";

                Label lblCIFCost = (Label)item.FindControl("lblCIFCost");
                lblCIFCost.Text = "$" + indimanCIFCost.ToString("0.00");

                Label lblFOBCost = (Label)item.FindControl("lblFOBCost");
                lblFOBCost.Text = "$" + ((indimanCIFCost == 0) ? 0 : Convert.ToDecimal(indimanCIFCost - convertion)).ToString("0.00");
            }
        */
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int priceID = int.Parse(this.hdnSelectedID.Value.Trim());
            if (Page.IsValid)
            {
                try
                {

                    ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                    objReturnInt = PriceBO.DeletePrice(priceID);
                    if (objReturnInt.RetVal == 0)
                    {
                        IndicoLogging.log.Error("btnDelete_Click : Error occured while Deleting the Price AddPatternFabric.aspx, SP_DeletePrice ");
                    }
                    // Populate active pattern fabrics
                    this.PopulatePatternFabrics();
                }
                catch (Exception ex)
                {
                    // Log the error
                    IndicoLogging.log.Error("btnDelete_Click : Error occured while Deleting the Price AddPatternFabric.aspx", ex);
                }
            }
        }

        protected void ddlDistributors_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Populate pattern
            this.PopulatePattern();
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            /*  ViewState["PopulatePatern"] = false;
              ViewState["PopulateFabric"] = false;

              if (Session["IsRefresh"].ToString() == ViewState["IsRefresh"].ToString())
              {
                  int queryId = int.Parse(this.hdnPattern.Value.Trim());
                  if (Page.IsValid && queryId > 0)
                  {
                      try
                      {
                          using (TransactionScope ts = new TransactionScope())
                          {
                              PatternBO objPattern = new PatternBO(this.ObjContext);
                              objPattern.ID = queryId;
                              objPattern.GetObject();

                              //objPattern.ConvertionFactor = decimal.Parse(this.txtConvertionFactor.Text.Trim());
                              //objPattern.PriceRemarks = this.txtRemarks.Text.Trim();

                              this.ObjContext.SaveChanges();
                              ts.Complete();
                          }

                          this.PopulateControls();
                      }
                      catch (Exception ex)
                      {
                          IndicoLogging.log.Error("AddEditIndimanPrice.aspx btnSaveChanges_Click()", ex);
                      }

                      Response.Redirect("/ViewPrices.aspx");
                  }
                  Session["IsRefresh"] = Server.UrlEncode(System.DateTime.Now.ToString());
              }
          */
        }

        protected void btnAddNote_Click(object sender, EventArgs e)
        {
            int price = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["pid"]);
            btnSave.Attributes.Add("priceid", price.ToString());
            if (price > 0)
            {
                PriceBO objPrice = new PriceBO();
                objPrice.ID = price;
                objPrice.GetObject();
                lblNoteHeading.Text = string.IsNullOrEmpty(objPrice.Remarks) ? "Add New Note" : "Edit Note";
                txtAddNote.Text = objPrice.Remarks;
            }
            ViewState["populateaddNewNote"] = true;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int price = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["priceid"]);
            if (price > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        PriceBO objPrice = new PriceBO(this.ObjContext);
                        objPrice.ID = price;
                        objPrice.GetObject();

                        objPrice.Remarks = txtAddNote.Text;
                        objPrice.Modifier = LoggedUser.ID;
                        objPrice.ModifiedDate = DateTime.Now;
                        ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                catch (Exception ex)
                {

                    IndicoLogging.log.Error("Error occured while ading/updating note(btnSaveNote_Click()) AddPatternFabricPricePage", ex);
                }
            }
            ViewState["populateaddNewNote"] = false;
            this.PopulatePatternFabrics();
        }

        protected void btnIndimanPrice_Click(object sender, EventArgs e)
        {
            //if (this.txtPattern.Text != string.Empty)
            //{
            //    Response.Redirect("/EditIndimanPrice.aspx?id=" + txtPattern.Text.Split('-')[0].ToString());
            //}

            if (int.Parse(this.ddlPattern.SelectedValue) > 0)
            {
                Response.Redirect("/EditIndimanPrice.aspx?id=" + this.ddlPattern.SelectedItem.Text.Split('-')[0].ToString());
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            //if (int.Parse(this.ddlPattern.SelectedValue) > 0 /*this.txtPattern.Text != string.Empty*/)
            //{
            //    string searchText = this.ddlPattern.SelectedItem.Text.ToLower().Trim();//this.txtPattern.Text.ToLower().Trim();
            //    List<PatternBO> lstPattern = (from o in (new PatternBO()).SearchObjects().Where(o => o.NickName.ToLower().Trim() == searchText ||
            //                                                                                         o.Number.ToLower().Trim() == searchText &&
            //                                                                                         o.IsActive == true)
            //                                  select o).ToList();
            //    if (lstPattern.Count > 0)
            //    {
            //        foreach (PatternBO pattern in lstPattern)
            //        {
            //            _activePatternBO = null;
            //            _activePatternFabrics = null;
            //            this.hdnPattern.Value = pattern.ID.ToString();
            //            this.PopulatePattern();
            //        }
            //    }
            //    else
            //    {
            //        this.dvEmptyContent.Visible = true;
            //        this.dvNoResult.Visible = false;
            //    }

            //}
            //else
            //{
            //    this.dvNoResult.Visible = true;
            //    this.dvEmptyContent.Visible = false;
            //    this.dgSelectedFabrics.Visible = false;
            //    this.divAddFabric.Visible = false;
            //}


            this.Search();
        }

        protected void btnAddFabric_Click(object sender, EventArgs e)
        {
            ViewState["populateaddNewNote"] = false;

            int qid = int.Parse(this.ddlFabric.SelectedValue); //int.Parse(((System.Web.UI.WebControls.LinkButton)(sender)).Attributes["qid"].ToString());
            if (qid > 0)
            {
                // Hide selected fabric
                //PRW ((System.Web.UI.WebControls.LinkButton)sender).Parent.Parent.Visible = false;

                FabricCodeBO objFabric = new FabricCodeBO(this.ObjContext);
                objFabric.ID = qid;
                objFabric.GetObject();

                // Add selected fabric
                this.FabricCodesWhereThisIsPattern.Add(objFabric);

                // Populate active pattern fabrics
                this.PopulatePatternFabrics();
                this.ProcessForm(qid);
                this.PopulatePatternFabrics();
                this.PopulateFabrics();
            }

            ViewState["PopulatePatern"] = false;
            ViewState["PopulateFabric"] = false;
        }

        protected void btnSaveFabric_Click(object sender, EventArgs e)
        {
            int fabric = int.Parse(this.ddlEditFabric.SelectedValue);
            int price = int.Parse(this.hdnSelectedID.Value);
            if (fabric > 0 && price > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        PriceBO objPrice = new PriceBO(this.ObjContext);
                        objPrice.ID = price;
                        objPrice.GetObject();

                        objPrice.FabricCode = fabric;
                        objPrice.Modifier = LoggedUser.ID;
                        objPrice.ModifiedDate = DateTime.Now;

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while Changing Fabric in AddPatternFabric.aspx page", ex);
                }
            }
            this.Search();
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            // Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;
            // Hide noResult Div
            this.dvNoResult.Visible = false;

            this.PopulatePatterns();


            if (this.QueryID > 0)
            {
                // Set active pattern ID
                this.hdnPattern.Value = this.QueryID.ToString();

                // Populate active pattern
                this.PopulatePattern();
                //Populate PatternDataGrid
                //PRW this.PopulateDataGridPatterns();
            }
            else
            {
                // Populate patterns
                //PRW this.PopulateDataGridPatterns();

                this.dgSelectedFabrics.Visible = false;
                this.dvEmptyContent.Visible = (this.dgSelectedFabrics.Visible);
            }

            // Populate fabrics
            this.ddlEditFabric.Items.Clear();
            this.ddlEditFabric.Items.Add(new ListItem("Select  Fabric", "0"));
            List<FabricCodeBO> lstFabrics = (new FabricCodeBO()).GetAllObject().OrderBy(o => o.Code).ToList();
            foreach (FabricCodeBO fab in lstFabrics)
            {
                this.ddlEditFabric.Items.Add(new ListItem(fab.Code + " - " + fab.Name, fab.ID.ToString()));
            }

            // Page Refresh
            Session["IsRefresh"] = Server.UrlEncode(System.DateTime.Now.ToString());

            //visible Indiman Price
            this.btnIndimanPrice.Visible = (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator) ? false : true;

            // Set default values
            ViewState["IsPageValied"] = true;
            ViewState["PopulatePatern"] = false;
            ViewState["PopulateFabric"] = false;
            ViewState["populateaddNewNote"] = false;
        }

        private void PopulatePatternFabrics()
        {
            this.dgSelectedFabrics.DataSource = FabricCodesWhereThisIsPattern;
            this.dgSelectedFabrics.DataBind();

            this.dgSelectedFabrics.Visible = (FabricCodesWhereThisIsPattern.Count > 0);
            this.dvEmptyContent.Visible = !(this.dgSelectedFabrics.Visible);
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm(int fabricCode)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {

                    List<PriceBO> lstPrices = (from o in (new PriceBO()).SearchObjects()
                                               where o.Pattern == this.ActivePattern.ID &&
                                                     o.FabricCode == fabricCode
                                               select o).ToList();
                    PriceBO objPrice = new PriceBO(this.ObjContext);
                    if (lstPrices.Count > 0)
                    {
                        objPrice.ID = lstPrices[0].ID;
                        objPrice.GetObject();
                    }
                    else
                    {
                        objPrice.Pattern = int.Parse(this.hdnPattern.Value.Trim());
                        objPrice.FabricCode = fabricCode;
                        objPrice.EnableForPriceList = false;

                        objPrice.Creator = this.LoggedUser.ID;
                        objPrice.CreatedDate = Convert.ToDateTime(DateTime.Now.ToString("g"));
                    }
                    objPrice.Modifier = this.LoggedUser.ID;
                    objPrice.ModifiedDate = Convert.ToDateTime(DateTime.Now.ToString("g"));

                    this.ObjContext.SaveChanges();

                    if (lstPrices.Count == 0)
                    {

                        foreach (int priceLevel in (new PriceLevelBO()).GetAllObject().Select(o => o.ID))
                        {
                            PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO(this.ObjContext);

                            objPriceLevelCost.FactoryCost = 0;
                            objPriceLevelCost.IndimanCost = 0;
                            objPriceLevelCost.Creator = this.LoggedUser.ID;
                            objPriceLevelCost.CreatedDate = DateTime.Now;
                            objPriceLevelCost.Modifier = this.LoggedUser.ID;
                            objPriceLevelCost.ModifiedDate = DateTime.Now;
                            objPriceLevelCost.PriceLevel = priceLevel;
                            objPrice.PriceLevelCostsWhereThisIsPrice.Add(objPriceLevelCost);
                            this.ObjContext.SaveChanges();
                        }
                    }
                    //this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Adding the Item", ex);
            }
        }

        private void PopulatePatterns()
        {
            Dictionary<int, string> patterns = (new PatternBO()).SearchObjects().AsQueryable().OrderBy(o => o.Number).Where(o => o.IsActive == true).Select(o => new { Key = o.ID, Value = (o.Number + " - " + o.NickName) }).ToDictionary(o => o.Key, o => o.Value);
            Dictionary<int, string> dicPatterns = new Dictionary<int, string>();

            dicPatterns.Add(0, "Please select or type...");
            foreach (KeyValuePair<int, string> item in patterns)
            {
                dicPatterns.Add(item.Key, item.Value);
            }

            this.ddlPattern.DataSource = dicPatterns;
            this.ddlPattern.DataTextField = "Value";
            this.ddlPattern.DataValueField = "Key";
            this.ddlPattern.DataBind();
        }

        private void PopulatePattern()
        {

            // Populate pattern data
            //this.txtPattern.Text = this.ActivePattern.Number + " - " + this.ActivePattern.NickName;
            // this.txtConvertionFactor.Text = this.ActivePattern.ConvertionFactor.ToString();
            //this.txtRemarks.Text = (this.ActivePattern.PriceRemarks != null) ? this.ActivePattern.PriceRemarks.ToString() : string.Empty;
            //this.linkSearchPattern.Visible = true;
            this.linkViewPattern.Visible = true;
            //.ddlDistributors.Enabled = true;

            //PRW this.btnAddFabric.Visible = true;
            this.divAddFabric.Visible = true;

            // Populate pattern popup data
            this.txtPatternNo.Text = this.ActivePattern.Number;
            this.txtItemName.Text = this.ActivePattern.objItem.Name;
            this.txtSizeSet.Text = this.ActivePattern.objSizeSet.Name;
            this.txtAgeGroup.Text = (this.ActivePattern.AgeGroup != null && this.ActivePattern.AgeGroup > 0) ? this.ActivePattern.objAgeGroup.Name : string.Empty;
            this.txtPrinterType.Text = (this.ActivePattern.PrinterType != null && this.ActivePattern.PrinterType > 0) ? this.ActivePattern.objPrinterType.Name : string.Empty;
            this.txtKeyword.Text = this.ActivePattern.Keywords;
            this.txtOriginalRef.Text = this.ActivePattern.OriginRef;
            this.txtSubItem.Text = (this.ActivePattern.SubItem != 0 && this.ActivePattern.SubItem > 0) ? this.ActivePattern.objSubItem.Name : string.Empty;
            this.txtGender.Text = (this.ActivePattern.Gender != null && this.ActivePattern.Gender > 0) ? this.ActivePattern.objGender.Name : string.Empty;
            this.txtNickName.Text = this.ActivePattern.NickName;
            this.txtCorrPattern.Text = this.ActivePattern.CorePattern;
            this.txtConsumption.Text = this.ActivePattern.Consumption;

            List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = (this.ActivePattern.SizeChartsWhereThisIsPattern).OrderBy(o => o.MeasurementLocation).GroupBy(o => o.MeasurementLocation).ToList();
            if (lstSizeChartGroup.Count > 0)
            {
                this.rptSpecSizeQtyHeader.DataSource = (List<SizeChartBO>)lstSizeChartGroup[0].ToList();
                this.rptSpecSizeQtyHeader.DataBind();

                this.rptSpecML.DataSource = lstSizeChartGroup;
                this.rptSpecML.DataBind();
            }
            this.linkSpecification.Visible = (lstSizeChartGroup.Count > 0);

            // Populate active pattern fabrics
            this.PopulatePatternFabrics();
            //PRW this.PopulateDataGridFabrics();
            this.PopulateFabrics();
        }

        private void PopulateFabrics()
        {
            Dictionary<int, string> fabrics = (new FabricCodeBO()).SearchObjects().AsQueryable().OrderBy(o => o.Name).ToList().Select(o => new { Key = o.ID, Value = (o.Code + " - " + o.Name) }).ToDictionary(o => o.Key, o => o.Value);
            Dictionary<int, string> dicFabrics = new Dictionary<int, string>();

            dicFabrics.Add(0, "Please select or type...");
            foreach (KeyValuePair<int, string> item in fabrics)
            {
                dicFabrics.Add(item.Key, item.Value);
            }

            dicFabrics = dicFabrics.Where(o => !this.FabricCodesWhereThisIsPattern.Select(m => m.ID).Contains(o.Key)).ToDictionary(o => o.Key, o => o.Value);

            this.ddlFabric.DataSource = dicFabrics;
            this.ddlFabric.DataTextField = "Value";
            this.ddlFabric.DataValueField = "Key";
            this.ddlFabric.DataBind();
        }

        private void Search()
        {
            int Pattern = int.Parse(this.ddlPattern.SelectedValue);

            if (Pattern > 0)
            {
                _activePatternBO = null;
                _activePatternFabrics = null;

                // Set active pattern ID
                this.hdnPattern.Value = Pattern.ToString();

                // Populate pattern
                this.PopulatePattern();
            }

            ViewState["PopulatePatern"] = false;
            ViewState["PopulateFabric"] = false;
        }

        #endregion
    }
}