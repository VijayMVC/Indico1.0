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
    public partial class AddEditIndimanPrice : IndicoPage
    {
        #region Fields

        private int _urlQueryID;
        private PatternBO _activePatternBO;
        private List<FabricCodeBO> _activePatternFabrics;

        private bool isEnableIndimanCost = false;

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


        protected void dgPatterns_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PatternBO)
            {
                PatternBO objPattern = (PatternBO)item.DataItem;

                Label lblItemName = (Label)item.FindControl("lblItemName");
                lblItemName.Text = objPattern.objItem.Name;

                Label lblGender = (Label)item.FindControl("lblGender");
                lblGender.Text = objPattern.objGender.Name;

                Label lblIsAcitve = (Label)item.FindControl("lblIsAcitve");
                lblIsAcitve.Text = (objPattern.IsActive ? "Inactive" : "Active");

                LinkButton btnSelectPattern = (LinkButton)item.FindControl("btnSelectPattern");
                btnSelectPattern.Attributes.Add("qid", objPattern.ID.ToString());
            }
        }

        protected void dgPatterns_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dgPatterns.CurrentPageIndex = e.NewPageIndex;

            // Populate patterns datagrid
            this.PopulateDataGridPatterns();

            ViewState["PopulatePatern"] = true;
            ViewState["PopulateFabric"] = false;
        }

        protected void dgPatterns_SortCommand(object source, DataGridSortCommandEventArgs e)
        {
            string sortDirection = String.Empty;
            if (!SortExpression.ToUpper().StartsWith(e.SortExpression) && !SortExpression.ToUpper().Trim().EndsWith("ASC"))
            {
                sortDirection = " asc";
            }
            else
            {
                sortDirection = (SortExpression.ToUpper().EndsWith("DESC")) ? " asc" : " desc";
            }
            this.SortExpression = e.SortExpression + sortDirection;

            // Populate patterns datagrid
            this.PopulateDataGridPatterns();

            foreach (DataGridColumn col in this.dgPatterns.Columns)
            {
                if (col.Visible && col.SortExpression == e.SortExpression)
                {
                    col.HeaderStyle.CssClass = "selected " + ((sortDirection.ToUpper() != " DESC") ? "sortDown" : "sortUp");
                }
                else
                {
                    col.HeaderStyle.CssClass = ((col.HeaderStyle.CssClass == "hide") ? "hide" : string.Empty);
                }
            }

            ViewState["PopulatePatern"] = true;
            ViewState["PopulateFabric"] = false;
        }

        protected void btnSearchPattern_Click(object sender, EventArgs e)
        {
            // Populate patterns datagrid
            this.PopulateDataGridPatterns();

            ViewState["PopulatePatern"] = true;
            ViewState["PopulateFabric"] = false;
        }

        protected void btnSelectPattern_Click(object sender, EventArgs e)
        {
            int qid = int.Parse(((System.Web.UI.WebControls.LinkButton)(sender)).Attributes["qid"].ToString());
            if (qid > 0)
            {
                _activePatternBO = null;
                _activePatternFabrics = null;

                // Set active pattern ID
                this.hdnPattern.Value = qid.ToString();

                // Populate pattern
                this.PopulatePattern();
            }

            ViewState["PopulatePatern"] = false;
            ViewState["PopulateFabric"] = false;
        }


        protected void dgFabrics_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is FabricCodeBO)
            {
                FabricCodeBO objFabric = (FabricCodeBO)item.DataItem;

                LinkButton btnSelectFabric = (LinkButton)item.FindControl("btnSelectFabric");
                btnSelectFabric.Attributes.Add("qid", objFabric.ID.ToString());
                btnSelectFabric.Attributes.Add("index", item.ItemIndex.ToString());
            }
        }

        protected void dgFabrics_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dgFabrics.CurrentPageIndex = e.NewPageIndex;

            // Populate fabrics datagrid
            this.PopulateDataGridFabrics();

            ViewState["PopulatePatern"] = false;
            ViewState["PopulateFabric"] = true;
        }

        protected void dgFabrics_SortCommand(object source, DataGridSortCommandEventArgs e)
        {
            string sortDirection = String.Empty;
            if (!SortExpression.ToUpper().StartsWith(e.SortExpression) && !SortExpression.ToUpper().Trim().EndsWith("ASC"))
            {
                sortDirection = " asc";
            }
            else
            {
                sortDirection = (SortExpression.ToUpper().EndsWith("DESC")) ? " asc" : " desc";
            }
            this.SortExpression = e.SortExpression + sortDirection;

            // Populate fabrics data grid
            this.PopulateDataGridFabrics();

            foreach (DataGridColumn col in this.dgFabrics.Columns)
            {
                if (col.Visible && col.SortExpression == e.SortExpression)
                {
                    col.HeaderStyle.CssClass = "selected " + ((sortDirection.ToUpper() != " DESC") ? "sortDown" : "sortUp");
                }
                else
                {
                    col.HeaderStyle.CssClass = ((col.HeaderStyle.CssClass == "hide") ? "hide" : string.Empty);
                }
            }

            ViewState["PopulatePatern"] = false;
            ViewState["PopulateFabric"] = true;
        }

        protected void btnSearchFabric_Click(object sender, EventArgs e)
        {
            // Populate fabrics datagrid
            this.PopulateDataGridFabrics();

            ViewState["PopulatePatern"] = false;
            ViewState["PopulateFabric"] = true;
        }

        protected void btnSelectFabric_Click(object sender, EventArgs e)
        {
            int qid = int.Parse(((System.Web.UI.WebControls.LinkButton)(sender)).Attributes["qid"].ToString());
            if (qid > 0)
            {
                // Hide selected fabric
                ((System.Web.UI.WebControls.LinkButton)sender).Parent.Parent.Visible = false;

                FabricCodeBO objFabric = new FabricCodeBO(this.ObjContext);
                objFabric.ID = qid;
                objFabric.GetObject();

                // Add selected fabric
                this.FabricCodesWhereThisIsPattern.Add(objFabric);

                // Populate active pattern fabrics
                this.PopulatePatternFabrics();
            }

            ViewState["PopulatePatern"] = false;
            ViewState["PopulateFabric"] = false;
        }


        protected void dgSelectedFabrics_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is FabricCodeBO)
            {
                FabricCodeBO objFabric = (FabricCodeBO)item.DataItem;
                PriceBO objPrice = (new PriceBO()).GetAllObject().SingleOrDefault(o => o.Pattern == int.Parse(this.hdnPattern.Value) && o.FabricCode == objFabric.ID);

                Literal litSetCost = (Literal)item.FindControl("litSetCost");
                litSetCost.Text = "Set cost for all levels";

                HtmlInputText txtSetCost = (HtmlInputText)item.FindControl("txtSetCost");

                HtmlControl olPriceTable = (HtmlControl)item.FindControl("olPriceTable");
                HtmlButton btnApply = (HtmlButton)item.FindControl("btnApply");
                btnApply.Attributes.Add("table", olPriceTable.ClientID);

                HtmlButton btnUpdate = (HtmlButton)item.FindControl("btnUpdate");
                btnUpdate.Attributes.Add("qid", objFabric.ID.ToString());
                btnUpdate.InnerText = (objPrice != null) ? "Update" : "Add";

                HtmlButton btnDelete = (HtmlButton)item.FindControl("btnDelete");
                btnDelete.Attributes.Add("qid", objFabric.ID.ToString());

                Repeater rptPriceLevelCost = (Repeater)item.FindControl("rptPriceLevelCost");
                if (objPrice != null) // Update
                {
                    decimal factoryCost = objPrice.PriceLevelCostsWhereThisIsPrice.Select(o => o.FactoryCost).Aggregate((x, y) => x + y);
                    isEnableIndimanCost = (factoryCost > 0);

                    litSetCost.Visible = isEnableIndimanCost;
                    txtSetCost.Visible = isEnableIndimanCost;
                    btnApply.Visible = isEnableIndimanCost;
                    btnUpdate.Visible = isEnableIndimanCost;
                    
                    rptPriceLevelCost.DataSource = objPrice.PriceLevelCostsWhereThisIsPrice;                    
                }
                else // Add New
                {
                    litSetCost.Visible = false;
                    txtSetCost.Visible = false;
                    btnApply.Visible = false;

                    List<DistributorPriceMarkupBO> lstPriceMarkups = (new DistributorPriceMarkupBO()).GetAllObject().Where(o => (int)o.Distributor == int.Parse(this.ddlDistributors.SelectedValue.Trim())).ToList();
                    rptPriceLevelCost.DataSource = lstPriceMarkups;
                }
                rptPriceLevelCost.DataBind();
            }
        }

        protected void rptPriceLevelCost_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
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
                txtCIFPrice.Enabled = false;

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
        }


        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            int fabricCode = int.Parse(((System.Web.UI.HtmlControls.HtmlControl)(sender)).Attributes["qid"]);
            if (fabricCode > 0)
            {
                Repeater rptPriceLevelCost = (Repeater)((System.Web.UI.HtmlControls.HtmlButton)(sender)).FindControl("rptPriceLevelCost");
                if (rptPriceLevelCost != null)
                {
                    this.ProcessForm(rptPriceLevelCost, fabricCode);

                    this.dgSelectedFabrics.DataSource = this.FabricCodesWhereThisIsPattern;
                    this.dgSelectedFabrics.DataBind();
                }
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int fabricCode = int.Parse(this.hdnSelectedID.Value.Trim());
            if (Page.IsValid)
            {
                try
                {
                    List<PriceBO> lstPrices = (from o in (new PriceBO()).SearchObjects()
                                               where o.Pattern == int.Parse(this.hdnPattern.Value.Trim()) &&
                                                     o.FabricCode == fabricCode
                                               select o).ToList();
                    if (lstPrices.Count > 0)
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            PriceBO objPrice = new PriceBO(this.ObjContext);
                            objPrice.ID = lstPrices[0].ID;
                            objPrice.GetObject();

                            foreach (PriceLevelCostBO itemPLC in objPrice.PriceLevelCostsWhereThisIsPrice)
                            {
                                PriceLevelCostBO objPLC = new PriceLevelCostBO(this.ObjContext);
                                objPLC.ID = itemPLC.ID;
                                objPLC.GetObject();

                                foreach (DistributorPriceLevelCostBO itemDPLC in objPLC.DistributorPriceLevelCostsWhereThisIsPriceLevelCost)
                                {
                                    DistributorPriceLevelCostBO objDPLC = new DistributorPriceLevelCostBO(this.ObjContext);
                                    objDPLC.ID = itemDPLC.ID;
                                    objDPLC.GetObject();

                                    objDPLC.Delete();
                                }
                                objPLC.Delete();
                            }
                            objPrice.Delete();

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }
                    }

                    // Populate active pattern fabrics
                    this.PopulatePatternFabrics();
                }
                catch (Exception ex)
                {
                    // Log the error
                    IndicoLogging.log.Error("btnDelete_Click : Error occured while Adding the Item", ex);
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
            ViewState["PopulatePatern"] = false;
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

                            objPattern.ConvertionFactor = decimal.Parse(this.txtConvertionFactor.Text.Trim());
                            objPattern.PriceRemarks = this.txtRemarks.Text.Trim();

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

            // Populate distributors dropdown
            List<int> lstDistributors = (new DistributorPriceMarkupBO()).GetAllObject().Where(o => o.Distributor != 0).Select(o => (int)o.Distributor).Distinct().ToList();
            this.ddlDistributors.Items.Add(new ListItem("PLATINUM", "0"));
            foreach (int id in lstDistributors)
            {
                CompanyBO item = new CompanyBO(this.ObjContext);
                item.ID = id;
                item.GetObject();

                this.ddlDistributors.Items.Add(new ListItem(item.Name, item.ID.ToString()));
            }

            if (this.QueryID > 0)
            {
                // Set active pattern ID
                this.hdnPattern.Value = this.QueryID.ToString();

                // Populate active pattern
                this.PopulatePattern();
                //Populate PatternDataGrid
                this.PopulateDataGridPatterns();
            }
            else
            {
                // Populate patterns
                this.PopulateDataGridPatterns();

                this.dgSelectedFabrics.Visible = false;
                this.dvEmptyContent.Visible = !(this.dgSelectedFabrics.Visible);
            }

            // Populate fabrics
            this.PopulateDataGridFabrics();

            // Page Refresh
            Session["IsRefresh"] = Server.UrlEncode(System.DateTime.Now.ToString());

            // Set default values
            ViewState["IsPageValied"] = true;
            ViewState["PopulatePatern"] = false;
            ViewState["PopulateFabric"] = false;
        }

        private void PopulatePattern()
        {
            // Populate pattern data
            this.txtPattern.Text = this.ActivePattern.Number + " - " + this.ActivePattern.NickName;
            this.txtConvertionFactor.Text = this.ActivePattern.ConvertionFactor.ToString();
            this.txtRemarks.Text = (this.ActivePattern.PriceRemarks != null) ? this.ActivePattern.PriceRemarks.ToString() : string.Empty;
            this.linkSearchPattern.Visible = true;
            this.linkViewPattern.Visible = true;
            this.ddlDistributors.Enabled = true;
            this.btnAddFabric.Visible = true;

            // Populate pattern popup data
            this.txtPatternNo.Text = this.ActivePattern.Number;
            this.txtItemName.Text = this.ActivePattern.objItem.Name;
            this.txtSizeSet.Text = this.ActivePattern.objSizeSet.Name;
            this.txtAgeGroup.Text = this.ActivePattern.objAgeGroup.Name;
            this.txtPrinterType.Text = this.ActivePattern.objPrinterType.Name;
            this.txtKeyword.Text = this.ActivePattern.Keywords;
            this.txtOriginalRef.Text = this.ActivePattern.OriginRef;
            this.txtSubItem.Text = this.ActivePattern.objSubItem.Name;
            this.txtGender.Text = this.ActivePattern.objGender.Name;
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
        }

        private void PopulatePatternFabrics()
        {
            this.dgSelectedFabrics.DataSource = FabricCodesWhereThisIsPattern;
            this.dgSelectedFabrics.DataBind();

            this.dgSelectedFabrics.Visible = (FabricCodesWhereThisIsPattern.Count > 0);
            this.dvEmptyContent.Visible = !(this.dgSelectedFabrics.Visible);
        }

        private void PopulateDataGridPatterns()
        {
            // Hide Controls
            this.dvEmptyContentPattern.Visible = false;
            this.dvDataContentPattern.Visible = false;
            this.dvNoSearchResultPattern.Visible = false;

            // Search text
            string searchText = this.txtSearchPattern.Text.ToLower().Trim();

            // Populate Items
            List<PatternBO> lstPatterns = new List<PatternBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstPatterns = (from o in (new PatternBO()).SearchObjects()
                               where o.ID != this.ActivePattern.ID &&
                                     o.Number.ToLower().Contains(searchText)
                               select o).AsQueryable().OrderBy(SortExpression).ToList();
            }
            else
            {
                lstPatterns = (new PatternBO()).SearchObjects().Where(o => o.ID != this.ActivePattern.ID).AsQueryable().OrderBy(SortExpression).ToList();
            }

            if (lstPatterns.Count > 0)
            {
                this.dgPatterns.AllowPaging = (lstPatterns.Count > this.dgPatterns.PageSize);
                this.dgPatterns.DataSource = lstPatterns;
                this.dgPatterns.DataBind();

                this.dvDataContentPattern.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search"))
            {
                this.lblSerchKeyPattern.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                this.dvDataContentPattern.Visible = true;
                this.dvNoSearchResultPattern.Visible = true;
            }
            else
            {
                this.dvEmptyContentPattern.Visible = true;
            }
            this.dgPatterns.Visible = (lstPatterns.Count > 0);
        }

        private void PopulateDataGridFabrics()
        {
            // Hide Controls
            this.dvEmptyContentFabric.Visible = false;
            this.dvDataContentFabric.Visible = false;
            this.dvNoSearchResultFabric.Visible = false;

            // Search text
            string searchText = this.txtSearchFabric.Text.ToLower().Trim();

            // Populate Items
            List<FabricCodeBO> lstFabrics = new List<FabricCodeBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstFabrics = (from o in (new FabricCodeBO()).SearchObjects()
                              where o.Code.ToLower().Contains(searchText) ||
                                    o.Name.ToLower().Contains(searchText) ||
                                    o.NickName.ToLower().Contains(searchText)
                              select o).AsQueryable().OrderBy(SortExpression).ToList();
            }
            else
            {
                lstFabrics = (new FabricCodeBO()).SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            }
            lstFabrics = lstFabrics.Where(o => !this.FabricCodesWhereThisIsPattern.Select(m => m.ID).Contains(o.ID)).ToList();

            if (lstFabrics.Count > 0)
            {
                this.dgFabrics.AllowPaging = (lstFabrics.Count > this.dgFabrics.PageSize);
                this.dgFabrics.DataSource = lstFabrics;
                this.dgFabrics.DataBind();

                this.dvDataContentFabric.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search"))
            {
                this.lblSerchKeyFabric.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                this.dvDataContentFabric.Visible = true;
                this.dvNoSearchResultFabric.Visible = true;
            }
            else
            {
                this.dvEmptyContentFabric.Visible = true;
            }
            this.dgFabrics.Visible = (lstFabrics.Count > 0);
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm(Repeater dataRepeater, int fabricCode)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    this.ActivePattern.ConvertionFactor = Convert.ToDecimal(decimal.Parse(this.txtConvertionFactor.Text.Trim()).ToString("0.00"));
                    this.ActivePattern.PriceRemarks = this.txtRemarks.Text.Trim();

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

                        objPrice.Creator = this.LoggedUser.ID;
                        objPrice.CreatedDate = Convert.ToDateTime(DateTime.Now.ToString("g"));
                    }
                    objPrice.Modifier = this.LoggedUser.ID;
                    objPrice.ModifiedDate = Convert.ToDateTime(DateTime.Now.ToString("g"));

                    foreach (RepeaterItem item in dataRepeater.Items)
                    {
                        HiddenField hdnCellID = (HiddenField)item.FindControl("hdnCellID");
                        TextBox txtCIFPrice = (TextBox)item.FindControl("txtCIFPrice");

                        int priceLevel = int.Parse(txtCIFPrice.Attributes["level"].ToString().Trim());
                        int priceLevelCost = int.Parse(hdnCellID.Value.Trim());

                        PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO(this.ObjContext);
                        if (priceLevelCost > 0)
                        {
                            objPriceLevelCost.ID = priceLevelCost;
                            objPriceLevelCost.GetObject();
                        }
                        else
                        {
                            objPriceLevelCost.PriceLevel = priceLevel;
                            objPrice.PriceLevelCostsWhereThisIsPrice.Add(objPriceLevelCost);
                        }
                        objPriceLevelCost.IndimanCost = Convert.ToDecimal(decimal.Parse(txtCIFPrice.Text.Trim()).ToString("0.00"));
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Adding the Item", ex);
            }
        }

        #endregion
    }
}