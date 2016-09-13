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
using System.Threading;
using Excel = Microsoft.Office.Interop.Excel;
using System.IO;
using System.Web.Services;

//using DocumentFormat.openxml_Excel.Packaging;
//using openxml_Excel = DocumentFormat.openxml_Excel.Spreadsheet;
//using DocumentFormat.openxml_Excel;
using System.Data;

using ClosedXML.Excel;

namespace Indico
{
    public partial class EditIndimanPrice : IndicoPage
    {
        #region Fields

        private string _urlQueryID = string.Empty;
        private PatternBO _activePatternBO;
        private List<FabricCodeBO> _activePatternFabrics;
        private object misValue = System.Reflection.Missing.Value;
        private bool isEnableIndimanCost = true;

        #endregion

        #region Properties

        protected string QueryID
        {
            get
            {
                if (!string.IsNullOrEmpty(_urlQueryID))
                    return _urlQueryID;

                //_urlQueryID = this.hdnPattern.Value.Trim();
                if ((string.IsNullOrEmpty(_urlQueryID)) && (Request.QueryString["id"] != null))
                {
                    _urlQueryID = Request.QueryString["id"].ToString();
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
                    _activePatternBO.ID = int.Parse(this.QueryID);
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

        public List<PriceLevelCostViewBO> lstPriceLevelCostView { get; set; }

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

        //protected void rptSpecSizeQtyHeader_ItemDataBound(object sender, RepeaterItemEventArgs e)
        //{
        //    RepeaterItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
        //    {
        //        SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

        //        Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
        //        litCellHeader.Text = objSizeChart.objSize.SizeName;
        //    }
        //}

        //protected void rptSpecML_ItemDataBound(object sender, RepeaterItemEventArgs e)
        //{
        //    RepeaterItem item = e.Item;

        //    if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, SizeChartBO>)
        //    {
        //        List<SizeChartBO> lstSizeChart = ((IGrouping<int, SizeChartBO>)item.DataItem).ToList();

        //        MeasurementLocationBO objML = new MeasurementLocationBO();
        //        objML.ID = lstSizeChart[0].MeasurementLocation;
        //        objML.GetObject();

        //        Literal litCellHeaderKey = (Literal)item.FindControl("litCellHeaderKey");
        //        litCellHeaderKey.Text = objML.Key;

        //        Literal litCellHeaderML = (Literal)item.FindControl("litCellHeaderML");
        //        litCellHeaderML.Text = objML.Name;

        //        Repeater rptSpecSizeQty = (Repeater)item.FindControl("rptSpecSizeQty");
        //        rptSpecSizeQty.DataSource = lstSizeChart;
        //        rptSpecSizeQty.DataBind();
        //    }
        //}

        //protected void rptSpecSizeQty_ItemDataBound(object sender, RepeaterItemEventArgs e)
        //{
        //    RepeaterItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
        //    {
        //        SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

        //        Label lblCellData = (Label)item.FindControl("lblCellData");
        //        lblCellData.Text = objSizeChart.Val.ToString();
        //    }
        //}


        //protected void dgPatterns_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is PatternBO)
        //    {
        //        PatternBO objPattern = (PatternBO)item.DataItem;

        //        Label lblItemName = (Label)item.FindControl("lblItemName");
        //        lblItemName.Text = objPattern.objItem.Name;

        //        Label lblGender = (Label)item.FindControl("lblGender");
        //        lblGender.Text = objPattern.objGender.Name;

        //        Label lblIsAcitve = (Label)item.FindControl("lblIsAcitve");
        //        lblIsAcitve.Text = (objPattern.IsActive ? "Inactive" : "Active");

        //        LinkButton btnSelectPattern = (LinkButton)item.FindControl("btnSelectPattern");
        //        btnSelectPattern.Attributes.Add("qid", objPattern.ID.ToString());
        //    }
        //}

        //protected void dgPatterns_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    //this.dgPatterns.CurrentPageIndex = e.NewPageIndex;

        //    // Populate patterns datagrid
        //    this.PopulateDataGridPatterns();

        //    ViewState["PopulatePatern"] = true;
        //    ViewState["PopulateFabric"] = false;
        //}

        //protected void dgPatterns_SortCommand(object source, DataGridSortCommandEventArgs e)
        //{
        //    string sortDirection = String.Empty;
        //    if (!SortExpression.ToUpper().StartsWith(e.SortExpression) && !SortExpression.ToUpper().Trim().EndsWith("ASC"))
        //    {
        //        sortDirection = " asc";
        //    }
        //    else
        //    {
        //        sortDirection = (SortExpression.ToUpper().EndsWith("DESC")) ? " asc" : " desc";
        //    }
        //    this.SortExpression = e.SortExpression + sortDirection;

        //    // Populate patterns datagrid
        //    this.PopulateDataGridPatterns();

        //    foreach (DataGridColumn col in this.dgPatterns.Columns)
        //    {
        //        if (col.Visible && col.SortExpression == e.SortExpression)
        //        {
        //            col.HeaderStyle.CssClass = "selected " + ((sortDirection.ToUpper() != " DESC") ? "sortDown" : "sortUp");
        //        }
        //        else
        //        {
        //            col.HeaderStyle.CssClass = ((col.HeaderStyle.CssClass == "hide") ? "hide" : string.Empty);
        //        }
        //    }

        //    ViewState["PopulatePatern"] = true;
        //    ViewState["PopulateFabric"] = false;
        //}

        //protected void btnSearchPattern_Click(object sender, EventArgs e)
        //{
        //    // Populate patterns datagrid
        //    this.PopulateDataGridPatterns();

        //    ViewState["PopulatePatern"] = true;
        //    ViewState["PopulateFabric"] = false;
        //}

        //protected void btnSelectPattern_Click(object sender, EventArgs e)
        //{
        //    int qid = int.Parse(((System.Web.UI.WebControls.LinkButton)(sender)).Attributes["qid"].ToString());
        //    if (qid > 0)
        //    {
        //        _activePatternBO = null;
        //        _activePatternFabrics = null;

        //        // Set active pattern ID
        //        this.hdnPattern.Value = qid.ToString();

        //        // Populate pattern
        //        this.PopulatePattern();
        //    }

        //    ViewState["PopulatePatern"] = false;
        //    ViewState["PopulateFabric"] = false;
        //}

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
            //this.PopulateDataGridFabrics();

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
            //this.PopulateDataGridFabrics();

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
            //this.PopulateDataGridFabrics();

            ViewState["PopulatePatern"] = false;
            ViewState["PopulateFabric"] = true;
            ViewState["PopulateEmailAddress"] = false;
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
                //this.PopulatePatternFabrics();
            }

            ViewState["PopulatePatern"] = false;
            ViewState["PopulateFabric"] = false;
        }

        protected void dgSelectFabrics_PageIndexChange(object sender, DataGridPageChangedEventArgs e)
        {
            this.dgSelectedFabrics.CurrentPageIndex = e.NewPageIndex;
            this.GetPriceIndimaPriceList();
        }

        protected void dgSelectedFabrics_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PriceLevelCostViewBO)
            {
                PriceLevelCostViewBO objPriceLevelCostView = (PriceLevelCostViewBO)item.DataItem;

                //PriceBO objPriceTmp = new PriceBO();

                //if (!string.IsNullOrEmpty(this.hdnPattern.Value) && int.Parse(this.hdnPattern.Value) > 0)
                //    objPriceTmp.Pattern = int.Parse(this.hdnPattern.Value);
                //objPriceTmp.FabricCode = objFabric.ID;

                //PriceBO objPrice = (new PriceBO()).GetAllObject().SingleOrDefault(o => o.Pattern == int.Parse(this.hdnPattern.Value) && o.FabricCode == objFabric.ID);
                //PriceBO objPrice = objPriceTmp.SearchObjects().SingleOrDefault();

                CheckBox chkEnablePriceList = (CheckBox)item.FindControl("chkEnablePriceList");
                chkEnablePriceList.Checked = (bool)objPriceLevelCostView.EnableForPriceList;

                Literal litSetCost = (Literal)item.FindControl("litSetCost");
                litSetCost.Text = "Set cost for all levels";

                Literal litConvesionFactor = (Literal)item.FindControl("litConvesionFactor");
                litConvesionFactor.Text = "Convesion Factor";

                Literal lblPatternNumber = (Literal)item.FindControl("lblPatternNumber");
                lblPatternNumber.Text = objPriceLevelCostView.Number;

                Literal lblFabricCode = (Literal)item.FindControl("lblFabricCode");
                lblFabricCode.Text = objPriceLevelCostView.FabricCodeName;

                Literal lblNickName = (Literal)item.FindControl("lblNickName");
                lblNickName.Text = objPriceLevelCostView.NickName;

                HtmlGenericControl dvSetCost = (HtmlGenericControl)item.FindControl("dvSetCost");
                dvSetCost.Visible = LoggedUserRoleName == UserRole.IndimanAdministrator;  //!this.LoggedUser.IsDirectSalesPerson;

                HtmlInputText txtSetCost = (HtmlInputText)item.FindControl("txtSetCost");

                HtmlControl olPriceTable = (HtmlControl)item.FindControl("olPriceTable");
                HtmlButton btnApply = (HtmlButton)item.FindControl("btnApply");
                btnApply.Attributes.Add("table", olPriceTable.ClientID);

                LinkButton btnUpdate = (LinkButton)item.FindControl("btnUpdate");
                btnUpdate.Attributes.Add("qid", objPriceLevelCostView.FabricCode.ToString());
                btnUpdate.Attributes.Add("fname", objPriceLevelCostView.FabricCodeName.ToString());
                btnUpdate.Attributes.Add("pnumber", objPriceLevelCostView.Number.ToString());
                btnUpdate.Attributes.Add("pnickname", objPriceLevelCostView.NickName);
                btnUpdate.Attributes.Add("patid", objPriceLevelCostView.Pattern.Value.ToString());
                //btnUpdate.InnerText = (objPriceLevelCostView != null) ? "Update" : "Add";

                HyperLink btnDelete = (HyperLink)item.FindControl("btnDelete");
                btnDelete.Attributes.Add("qid", objPriceLevelCostView.FabricCode.ToString());
                btnDelete.Attributes.Add("pid", objPriceLevelCostView.Pattern.ToString());

                HyperLink linkAddEditNote = (HyperLink)item.FindControl("linkAddEditNote");
                linkAddEditNote.Attributes.Add("PriceID", objPriceLevelCostView.ID.Value.ToString());

                Literal litPriceStatus = (Literal)item.FindControl("litPriceStatus");
                litPriceStatus.Text = (objPriceLevelCostView.EnableForPriceList == true) ? "Hide from Indico" : "Show to Indico";

                LinkButton btnSubmitIndico = (LinkButton)item.FindControl("btnSubmitIndico");
                btnSubmitIndico.Attributes.Add("pid", objPriceLevelCostView.ID.ToString());
                btnSubmitIndico.Attributes.Add("enable", (objPriceLevelCostView.EnableForPriceList == true) ? "false" : "true");
                btnSubmitIndico.ToolTip = (objPriceLevelCostView.EnableForPriceList == true) ? "Hide from Indico" : "Show to Indico";

                IndimanPriceRemarksBO objIndimanPriceRemarks = new IndimanPriceRemarksBO();
                objIndimanPriceRemarks.Price = objPriceLevelCostView.ID.Value;
                List<IndimanPriceRemarksBO> lstIndimanPriceRemarks = objIndimanPriceRemarks.SearchObjects().ToList();

                TextBox txtConversionFactor = (TextBox)item.FindControl("txtConversionFactor");
                PatternBO objPattern = new PatternBO();
                objPattern.ID = objPriceLevelCostView.Pattern.Value;
                objPattern.GetObject();
                txtConversionFactor.Text = objPattern.ConvertionFactor.ToString();

                if (lstIndimanPriceRemarks.Count > 0)
                {
                    LinkButton btnViewNote = (LinkButton)item.FindControl("btnViewNote");
                    btnViewNote.Visible = true;
                    btnViewNote.Attributes.Add("pid", objPriceLevelCostView.ID.Value.ToString());
                }

                this.hdnSelectedPattern.Value = objPriceLevelCostView.Pattern.ToString();

                Repeater rptPriceLevelCost = (Repeater)item.FindControl("rptPriceLevelCost");

                //               if (objPriceLevelCostView != null) // Update
                //               {
                //                   //decimal factoryCost = objPrice.PriceLevelCostsWhereThisIsPrice.Select(o => o.FactoryCost).Aggregate((x, y) => x + y);
                //                   //isEnableIndimanCost = (factoryCost > 0);

                //
                //               }
                //               else // Add New
                //               {
                //                   litSetCost.Visible = false;
                //                   txtSetCost.Visible = false;
                //                   btnApply.Visible = false;

                //                   List<DistributorPriceMarkupBO> lstPriceMarkups = (new DistributorPriceMarkupBO()).GetAllObject().Where(o => (int)o.Distributor == int.Parse(this.ddlDistributors.SelectedValue.Trim())).ToList();
                //                   rptPriceLevelCost.DataSource = lstPriceMarkups;
                //               }
                litSetCost.Visible = isEnableIndimanCost;
                txtSetCost.Visible = isEnableIndimanCost;
                btnApply.Visible = isEnableIndimanCost;
                btnUpdate.Visible = isEnableIndimanCost;
                PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO();
                objPriceLevelCost.Price = (int)objPriceLevelCostView.ID;
                //** objPriceLevelCost.GetObject();

                List<PriceLevelCostBO> lstPriceLevelCost = objPriceLevelCost.SearchObjects().ToList();

                rptPriceLevelCost.DataSource = lstPriceLevelCost;
                rptPriceLevelCost.DataBind();

                Literal litModifiedDate = (Literal)item.FindControl("litModifiedDate");
                litModifiedDate.Text = lstPriceLevelCost[0].CreatedDate.ToString("dd MMMM yyyy");

                Literal lblStatus = (Literal)item.FindControl("lblStatus");
                lblStatus.Text = "<span class=\"badge badge-" + ((objPriceLevelCostView.EnableForPriceList ?? false) ? "completed" : "notcompleted") + "\">&nbsp;</span></br>";
                lblStatus.Visible = LoggedUserRoleName == UserRole.IndimanAdministrator;
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

                //Label lblMarkup = (Label)item.FindControl("lblMarkup");
                //lblMarkup.Text = objPriceMarkup.Markup + "%";

                //Label lblCIFCost = (Label)item.FindControl("lblCIFCost");
                //lblCIFCost.Text = "$0.0";

                //Label lblFOBCost = (Label)item.FindControl("lblFOBCost");
                //lblFOBCost.Text = "$0.0";
            }
            else if (item.ItemIndex > -1 && item.DataItem is PriceLevelCostBO)
            {
                PriceLevelCostBO objPriceLevelCost = (PriceLevelCostBO)item.DataItem;
                //DistributorPriceMarkupBO objPriceMarkup = objPriceLevelCost.objPriceLevel.DistributorPriceMarkupsWhereThisIsPriceLevel.SingleOrDefault(o => (int)o.Distributor == int.Parse(this.ddlDistributors.SelectedValue.Trim()));
                foreach (DistributorPriceMarkupBO objPriceMarkup in objPriceLevelCost.objPriceLevel.DistributorPriceMarkupsWhereThisIsPriceLevel)
                {
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
                    txtCIFPrice.Attributes.Add("plcid", objPriceLevelCost.ID.ToString());

                    Label lblFOBPrice = (Label)item.FindControl("lblFOBPrice");
                    lblFOBPrice.Text = ((objPriceLevelCost.IndimanCost != 0) ? (objPriceLevelCost.IndimanCost - objPriceLevelCost.objPrice.objPattern.ConvertionFactor).ToString("0.00") : "0.00");

                    //Label lblMarkup = (Label)item.FindControl("lblMarkup");
                    //lblMarkup.Text = objPriceMarkup.Markup.ToString() + "%";

                    //Label lblCIFCost = (Label)item.FindControl("lblCIFCost");
                    //lblCIFCost.Text = "$" + indimanCIFCost.ToString("0.00");

                    //Label lblFOBCost = (Label)item.FindControl("lblFOBCost");
                    //lblFOBCost.Text = "$" + ((indimanCIFCost == 0) ? 0 : Convert.ToDecimal(indimanCIFCost - convertion)).ToString("0.00");
                }
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            Repeater rptPriceLevelCost = (Repeater)((LinkButton)(sender)).FindControl("rptPriceLevelCost");
            int Pattern = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["patid"]);
            if (rptPriceLevelCost != null && Pattern > 0)
            {
                TextBox txtConversionFactor = (TextBox)((LinkButton)(sender)).FindControl("txtConversionFactor");
                decimal cf = Convert.ToDecimal(decimal.Parse(txtConversionFactor.Text).ToString("0.00"));
                this.ProcessForm(rptPriceLevelCost, cf, Pattern);

                this.GetPriceIndimaPriceList();
            }
            ViewState["PopulateAddEditNote"] = false;
            ViewState["PopulateViewNote"] = false;
            ViewState["PopulateEmailAddress"] = false;
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
                    //this.PopulatePatternFabrics();
                    this.GetPriceIndimaPriceList();
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
            //this.PopulatePattern();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            //this.PopulatePatternFabrics();
            ViewState["PopulateEmailAddress"] = false;

            if (!string.IsNullOrEmpty(this.txtPattern.Text) || !string.IsNullOrEmpty(this.txtPatternNickName.Text) || !string.IsNullOrEmpty(this.ddlFabricName.SelectedItem.Text))
            {
                this.GetPriceIndimaPriceList();
            }
            else
            {
                this.dvEmptyContent.Visible = true;
                this.dgSelectedFabrics.Visible = false;
                this.h2EmptyContent.InnerText = "Please enter value to search";
                this.pEmptyContent.InnerText = string.Empty;
            }

            ViewState["PopulateAddEditNote"] = false;
            ViewState["PopulateViewNote"] = false;

        }

        /* protected void btnConvertionFactor_Click(object sender, EventArgs e)
         {
             //int Pattern = int.Parse(this.hdnSelectedPattern.Value);
             List<int> lstPattern = (List<int>)Session["PatternIdList"];
             //Session["PatternIdList"] = null;
             if (lstPattern.Count > 0)
             {
                 try
                 {
                     foreach (int id in lstPattern)
                     {
                         using (TransactionScope ts = new TransactionScope())
                         {
                             PatternBO objPattern = new PatternBO(this.ObjContext);
                             objPattern.ID = id;
                             objPattern.GetObject();
                             objPattern.ConvertionFactor = decimal.Parse(txtConvertionFactor.Text);

                             ObjContext.SaveChanges();
                             ts.Complete();
                         }
                     }
                     this.GetPriceIndimaPriceList();
                 }
                 catch (Exception ex)
                 {
                     IndicoLogging.log.Error("Error occured while Add convertion factor Indiman Price", ex);

                 }
             }
             ViewState["PopulateAddEditNote"] = false;
             ViewState["PopulateViewNote"] = false;
         }*/

        //protected void btnSaveChanges_Click(object sender, EventArgs e)
        //{
        //    ViewState["PopulatePatern"] = false;
        //    ViewState["PopulateFabric"] = false;

        //    if(this.IsNotRefresh)
        //    {
        //        int queryId = int.Parse(this.hdnPattern.Value.Trim());
        //        if (Page.IsValid && queryId > 0)
        //        {
        //            try
        //            {
        //                using (TransactionScope ts = new TransactionScope())
        //                {
        //                    PatternBO objPattern = new PatternBO(this.ObjContext);
        //                    objPattern.ID = queryId;
        //                    objPattern.GetObject();

        //                    //objPattern.ConvertionFactor = decimal.Parse(this.txtConvertionFactor.Text.Trim());
        //                    //objPattern.PriceRemarks = this.txtRemarks.Text.Trim();

        //                    this.ObjContext.SaveChanges();
        //                    ts.Complete();
        //                }

        //                this.PopulateControls();
        //            }
        //            catch (Exception ex)
        //            {
        //                IndicoLogging.log.Error("AddEditIndimanPrice.aspx btnSaveChanges_Click()", ex);
        //            }

        //            Response.Redirect("/ViewPrices.aspx");
        //        }
        //       
        //    }
        //}

        protected void btnSaveNote_Click(object sender, EventArgs e)
        {
            int PriceID = int.Parse(this.hdnPriceID.Value);
            if (this.IsNotRefresh)
            {
                if (Page.IsValid)
                {
                    if (PriceID > 0)
                    {
                        try
                        {
                            using (TransactionScope ts = new TransactionScope())
                            {
                                IndimanPriceRemarksBO objIndimanPriceRemarks = new IndimanPriceRemarksBO(this.ObjContext);
                                objIndimanPriceRemarks.Price = PriceID;
                                objIndimanPriceRemarks.Remarks = txtNote.Text;
                                objIndimanPriceRemarks.Creator = this.LoggedUser.ID;
                                objIndimanPriceRemarks.CreatedDate = DateTime.Now;
                                this.ObjContext.SaveChanges();
                                ts.Complete();
                            }
                        }
                        catch (Exception ex)
                        {
                            IndicoLogging.log.Error("Error occured while saving Indiman price remarks", ex);
                        }

                    }
                }
                ViewState["PopulateAddEditNote"] = !(Page.IsValid);
                ViewState["PopulateViewNote"] = false;
                ViewState["PopulateEmailAddress"] = false;

                this.GetPriceIndimaPriceList();
            }
        }

        protected void btnViewNote_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int price = (sender != null) ? int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["pid"]) : 0;
                if (price != 0)
                {
                    IndimanPriceRemarksBO ObjIndimanPriceRemarksBO = new IndimanPriceRemarksBO();
                    ObjIndimanPriceRemarksBO.Price = price;
                    List<IndimanPriceRemarksBO> lstIndimanPriceRemarks = ObjIndimanPriceRemarksBO.SearchObjects().OrderBy(o => o.CreatedDate).ToList();

                    if (lstIndimanPriceRemarks.Count > 0)
                    {
                        this.dvNoteEmptyContent.Visible = false;
                        this.dgViewNote.DataSource = lstIndimanPriceRemarks;
                        this.dgViewNote.DataBind();
                    }
                    else
                    {
                        this.dvNoteEmptyContent.Visible = true;
                        this.dgViewNote.Visible = false;
                    }
                }
                else
                {
                    this.dvNoteEmptyContent.Visible = true;
                    this.dgViewNote.Visible = false;
                }
                ViewState["PopulateViewNote"] = true;
                ViewState["PopulateEmailAddress"] = false;

            }
        }

        protected void dgViewNote_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is IndimanPriceRemarksBO)
            {
                IndimanPriceRemarksBO objIndimanPriceRemarks = (IndimanPriceRemarksBO)item.DataItem;
                UserBO objUser = new UserBO();
                objUser.ID = objIndimanPriceRemarks.Creator;

                List<UserBO> lstUser = objUser.SearchObjects().ToList();

                Literal lblCreator = (Literal)item.FindControl("lblCreator");
                if (lstUser.Count > 0)
                {
                    lblCreator.Text = lstUser[0].FamilyName + " " + lstUser[0].GivenName;
                }
                Literal lblCreatedDate = (Literal)item.FindControl("lblCreatedDate");
                lblCreatedDate.Text = objIndimanPriceRemarks.CreatedDate.ToShortDateString();

                Literal lblRemarks = (Literal)item.FindControl("lblRemarks");
                lblRemarks.Text = objIndimanPriceRemarks.Remarks;

                HyperLink btnDelete = (HyperLink)item.FindControl("btnDelete");
                btnDelete.Attributes.Add("imrid", objIndimanPriceRemarks.ID.ToString());
            }
        }

        protected void btnDeleteIndimanPriceRemarks_Click(object sender, EventArgs e)
        {
            int id = int.Parse(this.hdnIndimanPriceRemarks.Value);
            if (this.IsNotRefresh)
            {
                if (id > 0)
                {
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            IndimanPriceRemarksBO objIndimanPriceRemarks = new IndimanPriceRemarksBO(this.ObjContext);
                            objIndimanPriceRemarks.ID = id;
                            objIndimanPriceRemarks.GetObject();

                            objIndimanPriceRemarks.Delete();

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }

                        //this.btnViewNote_Click(null, null);
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while deleting Indiman price remarks", ex);
                    }
                }
            }
            ViewState["PopulateViewNote"] = false;
            ViewState["PopulateAddEditNote"] = false;
            ViewState["PopulateEmailAddress"] = false;
            this.GetPriceIndimaPriceList();
        }

        protected void btnEmailAddresses_OnClick(object sender, EventArgs e)
        {
            ViewState["populateProgress"] = false;
            if (this.IsNotRefresh)
            {
                //populate ToList Exist Users
                int isUsed = 0;

                this.lstBoxToExistUsers.Items.Clear();
                this.lstBoxToNewUsers.Items.Clear();
                List<UserBO> lstUsers = (new UserBO()).SearchObjects().Where(o => o.Status == 1 && (o.Company == 4 || o.Company == 3)).ToList();
                List<PriceChangeEmailListBO> lstPriceChangeToEmailList = (new PriceChangeEmailListBO()).SearchObjects().Where(o => o.IsCC == false).ToList();

                if (lstPriceChangeToEmailList.Count > 0)
                {
                    foreach (UserBO userTo in lstUsers)
                    {
                        this.lstBoxToExistUsers.Items.Add(new ListItem(userTo.GivenName + " " + userTo.FamilyName + " - " + userTo.EmailAddress, userTo.ID.ToString()));
                    }


                    foreach (PriceChangeEmailListBO pcel in lstPriceChangeToEmailList)
                    {
                        this.lstBoxToNewUsers.Items.Add(new ListItem(pcel.objUser.GivenName + " " + pcel.objUser.FamilyName + " - " + pcel.objUser.EmailAddress, pcel.User.ToString()));

                        if (pcel.User != isUsed)
                        {
                            this.lstBoxToExistUsers.Items.FindByValue(pcel.User.ToString()).Selected = true;
                            this.lstBoxToExistUsers.Items.Remove(this.lstBoxToExistUsers.SelectedItem);
                            isUsed = (int)pcel.User;
                        }
                    }
                }
                else
                {
                    foreach (UserBO userTo in lstUsers)
                    {
                        this.lstBoxToExistUsers.Items.Add(new ListItem(userTo.GivenName + " " + userTo.FamilyName + " - " + userTo.EmailAddress, userTo.ID.ToString()));
                    }
                }

                // populate CC Exist Users
                isUsed = 0;
                this.lstBoxCcExistUsers.Items.Clear();
                this.lstBoxCccNewUsers.Items.Clear();
                List<PriceChangeEmailListBO> lstPriceChangeCCEmailList = (new PriceChangeEmailListBO()).SearchObjects().Where(o => o.IsCC == true).ToList();


                if (lstPriceChangeCCEmailList.Count > 0)
                {
                    foreach (UserBO userCc in lstUsers)
                    {
                        this.lstBoxCcExistUsers.Items.Add(new ListItem(userCc.GivenName + " " + userCc.FamilyName + " - " + userCc.EmailAddress, userCc.ID.ToString()));
                    }

                    foreach (PriceChangeEmailListBO pcelcc in lstPriceChangeCCEmailList)
                    {
                        this.lstBoxCccNewUsers.Items.Add(new ListItem(pcelcc.objUser.GivenName + " " + pcelcc.objUser.FamilyName + " - " + pcelcc.objUser.EmailAddress, pcelcc.User.ToString()));

                        if (pcelcc.User != isUsed)
                        {
                            this.lstBoxCcExistUsers.Items.FindByValue(pcelcc.User.ToString()).Selected = true;
                            this.lstBoxCcExistUsers.Items.Remove(this.lstBoxCcExistUsers.SelectedItem);
                            isUsed = (int)pcelcc.User;
                        }
                    }
                }
                else
                {
                    foreach (UserBO userCc in lstUsers)
                    {
                        this.lstBoxCcExistUsers.Items.Add(new ListItem(userCc.GivenName + " " + userCc.FamilyName + " - " + userCc.EmailAddress, userCc.ID.ToString()));
                    }
                }
                ViewState["PopulateEmailAddress"] = true;

            }
        }

        protected void btnSaveEmailAddresses_OnClick(object sender, EventArgs e)
        {
            //NNM 
            if (this.IsNotRefresh)
            {
                try
                {
                    if (this.hdnEmailAddressesTo.Value != string.Empty && this.hdnEmailAddressesCC.Value != string.Empty)
                    {
                        List<PriceChangeEmailListBO> lstPriceChangeEmailListTo = (new PriceChangeEmailListBO()).SearchObjects().Where(o => o.IsCC == false).ToList();

                        if (this.hdnEmailAddressesTo.Value != string.Empty)
                        {
                            using (TransactionScope ts = new TransactionScope())
                            {
                                if (lstPriceChangeEmailListTo.Count > 0)
                                {
                                    foreach (PriceChangeEmailListBO tolist in lstPriceChangeEmailListTo)
                                    {
                                        PriceChangeEmailListBO objPriceChangeEmailList = new PriceChangeEmailListBO(this.ObjContext);
                                        objPriceChangeEmailList.ID = tolist.ID;
                                        objPriceChangeEmailList.GetObject();

                                        objPriceChangeEmailList.Delete();

                                        this.ObjContext.SaveChanges();

                                    }

                                    ts.Complete();
                                }
                            }

                            using (TransactionScope ts = new TransactionScope())
                            {
                                foreach (string value in this.hdnEmailAddressesTo.Value.Split(','))
                                {
                                    if (value != string.Empty)
                                    {
                                        PriceChangeEmailListBO objPriceChangeEmailList = new PriceChangeEmailListBO(this.ObjContext);
                                        objPriceChangeEmailList.User = int.Parse(value);
                                        objPriceChangeEmailList.IsCC = false;

                                        this.ObjContext.SaveChanges();

                                    }
                                }
                                ts.Complete();
                            }
                        }

                        List<PriceChangeEmailListBO> lstPriceChangeEmailListCC = (new PriceChangeEmailListBO()).SearchObjects().Where(o => o.IsCC == true).ToList();

                        if (this.hdnEmailAddressesCC.Value != string.Empty)
                        {
                            using (TransactionScope ts = new TransactionScope())
                            {
                                if (lstPriceChangeEmailListCC.Count > 0)
                                {
                                    foreach (PriceChangeEmailListBO cclist in lstPriceChangeEmailListCC)
                                    {
                                        PriceChangeEmailListBO objPriceChangeEmailList = new PriceChangeEmailListBO(this.ObjContext);
                                        objPriceChangeEmailList.ID = cclist.ID;
                                        objPriceChangeEmailList.GetObject();

                                        objPriceChangeEmailList.Delete();

                                        this.ObjContext.SaveChanges();

                                    }
                                    ts.Complete();
                                }
                            }

                            using (TransactionScope ts = new TransactionScope())
                            {
                                foreach (string value in this.hdnEmailAddressesCC.Value.Split(','))
                                {
                                    if (value != string.Empty)
                                    {
                                        PriceChangeEmailListBO objPriceChangeEmailList = new PriceChangeEmailListBO(this.ObjContext);
                                        objPriceChangeEmailList.User = int.Parse(value);
                                        objPriceChangeEmailList.IsCC = true;

                                        this.ObjContext.SaveChanges();
                                    }
                                }
                                ts.Complete();
                            }
                        }
                    }

                }
                catch (Exception ex)
                {

                    IndicoLogging.log.Error("Error occured while saving PriceChangeEmailList", ex);
                }
            }
            ViewState["PopulateEmailAddress"] = false;
        }

        //protected void btndownloadExcel_Click(object sender, EventArgs e)
        //{
        //    if (this.IsNotRefresh)
        //    {

        //        #region PriceTerm

        //        int priceTerm = 0;
        //        string priceTermName = string.Empty;
        //        if (this.ddlPriceTerm.SelectedValue == "1")
        //        {
        //            priceTerm = 1;
        //            priceTermName = "CIF Price";
        //        }
        //        else if (this.ddlPriceTerm.SelectedValue == "1")
        //        {
        //            priceTerm = 2;
        //            priceTermName = "FOB Price";
        //        }

        //        #endregion

        //        string fileName = "Indiman_" + this.ddlExcelDistributor.SelectedItem.Text.Trim().ToUpper() + "_" + ((priceTerm == 1) ? "CIF" : "FOB") + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".xlsx";
        //        string filepath = String.Format("{0}{1}", (IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\PriceLists\"), fileName);
        //        ViewState["filePath"] = fileName;

        //        Thread oThread = new Thread(new ThreadStart(() => GenerateExcel(filepath, int.Parse(this.ddlPriceTerm.SelectedValue), this.ddlPriceTerm.SelectedItem.Text)));
        //        oThread.IsBackground = true;
        //        oThread.Start();
        //        ViewState["populateProgress"] = true;
        //        // this.GenerateExcel(filePath, int.Parse(this.ddlPriceTerm.SelectedValue), this.ddlPriceTerm.SelectedItem.Text); 
        //        ViewState["PopulateEmailAddress"] = false;
        //    }
        //    else
        //    {
        //        ViewState["populateProgress"] = false;
        //        ViewState["PopulateEmailAddress"] = false;
        //    }
        //}

        protected void btndownloadExcel_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {

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

                string fileName = "Indiman_" + this.ddlExcelDistributor.SelectedItem.Text.Trim().ToUpper() + "_" + ((priceTerm == 1) ? "CIF" : "FOB") + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".xlsx";
                string filepath = String.Format("{0}{1}", (IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\PriceLists\"), fileName);
                ViewState["filePath"] = fileName;

                //Thread oThread = new Thread(new ThreadStart(() => CreateExcel(filepath, int.Parse(this.ddlPriceTerm.SelectedValue), this.ddlPriceTerm.SelectedItem.Text)));
                //oThread.IsBackground = true;
                //oThread.Start();
                //ViewState["populateProgress"] = true;
                this.CreateExcel(filepath, int.Parse(this.ddlPriceTerm.SelectedValue), this.ddlPriceTerm.SelectedItem.Text);
                ViewState["PopulateEmailAddress"] = false;

            }
            else
            {
                ViewState["populateProgress"] = false;
                ViewState["PopulateEmailAddress"] = false;
            }
        }

        protected void btnDownload_Click(object sender, EventArgs e)
        {
            string filename = ViewState["filePath"].ToString();
            string filePath = String.Format("{0}{1}", (IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\PriceLists\"), filename);

            if (this.IsNotRefresh)
            {
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
            ViewState["PopulateEmailAddress"] = false;

        }

        protected void btnSubmitIndico_Click(object sender, EventArgs e)
        {
            int price = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["pid"]);
            bool isenable = bool.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["enable"]);

            if (price > 0)
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    PriceBO objPrice = new PriceBO(this.ObjContext);
                    objPrice.ID = price;
                    objPrice.GetObject();

                    objPrice.EnableForPriceList = isenable;

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }

            this.GetPriceIndimaPriceList();
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            //
            ViewState["PopulateEmailAddress"] = false;
            ViewState["PopulateViewNote"] = false;
            // Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;

            // Hide the certain controls and probably we need to show in the future SDS
            //this.dvHide.Visible = false;

            //Hide Distributor Dropdown
            liDistributors.Visible = false;

            // Hide dvEmptyContent 
            this.dvEmptyContent.Visible = false;

            this.btndownloadExcel.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;

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

            //Populate Fabric Name
            this.ddlFabricName.Items.Add(new ListItem("Select Fabric Name", "0"));
            List<FabricCodeBO> lstFabricCode = (from o in (new FabricCodeBO()).GetAllObject().OrderBy(o => o.Name) select o).ToList();
            foreach (FabricCodeBO fabriccode in lstFabricCode)
            {
                this.ddlFabricName.Items.Add(new ListItem(fabriccode.Code + " - " + fabriccode.Name, fabriccode.ID.ToString()));
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

            if (!string.IsNullOrEmpty(this.QueryID))
            {
                // Set active pattern ID
                this.hdnPattern.Value = this.QueryID.ToString();

                //PatternBO objPattern = new PatternBO();
                //objPattern.ID = this.QueryID;
                //objPattern.GetObject();

                //this.PopulatePatternFabrics(objPattern);
                this.txtSearchAny.Text = this.QueryID;
                this.GetPriceIndimaPriceList();

                //Populate active pattern
                //this.PopulatePattern();
                //Populate PatternDataGrid
                //this.PopulateDataGridPatterns();
            }
            else
            {
                // Populate patterns
                //this.PopulateDataGridPatterns();

                this.dgSelectedFabrics.Visible = false;
                this.dvEmptyContent.Visible = false;
            }

            // Populate fabrics
            // this.PopulateDataGridFabrics();

            // Page Refresh


            // Set default values
            ViewState["IsPageValied"] = true;
            ViewState["PopulatePatern"] = false;
            ViewState["PopulateFabric"] = false;
            ViewState["PopulateAddEditNote"] = false;
            ViewState["PopulateViewNote"] = false;
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm(Repeater dataRepeater, decimal convesionFactor, int Pattern)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    foreach (RepeaterItem item in dataRepeater.Items)
                    {
                        //HiddenField hdnCellID = (HiddenField)item.FindControl("hdnCellID");
                        TextBox txtCIFPrice = (TextBox)item.FindControl("txtCIFPrice");

                        //int priceLevel = int.Parse(txtCIFPrice.Attributes["level"].ToString().Trim());
                        int priceLevelCost = int.Parse(txtCIFPrice.Attributes["plcid"].ToString().Trim());

                        PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO(this.ObjContext);
                        if (priceLevelCost > 0)
                        {
                            objPriceLevelCost.ID = priceLevelCost;
                            objPriceLevelCost.GetObject();
                        }
                        else
                        {
                            objPriceLevelCost.Creator = this.LoggedUser.ID;
                            objPriceLevelCost.CreatedDate = DateTime.Now;
                        }
                        objPriceLevelCost.IndimanCost = Convert.ToDecimal(decimal.Parse(txtCIFPrice.Text.Trim()).ToString("0.00"));
                        objPriceLevelCost.Modifier = this.LoggedUser.ID;
                        objPriceLevelCost.ModifiedDate = DateTime.Now;
                    }

                    if (Pattern > 0)
                    {
                        PatternBO objPattern = new PatternBO(this.ObjContext);
                        objPattern.ID = Pattern;
                        objPattern.GetObject();
                        objPattern.ConvertionFactor = convesionFactor;
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
                Thread threadSendEmail = new Thread(new ThreadStart(this.SendEmail));
                threadSendEmail.Start();
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Upadte the Price Level Cost", ex);
            }
        }

        private void GetPriceIndimaPriceList()
        {
            string search = txtSearchAny.Text.Trim().ToLower();
            string patternnickname = txtPatternNickName.Text.Trim().ToLower();
            int fabric = int.Parse(this.ddlFabricName.SelectedValue);
            string number = txtPattern.Text.Trim();
            List<PriceLevelCostViewBO> lstPeiceLevelCostView = new List<PriceLevelCostViewBO>();

            bool isIndiman = LoggedUserRoleName == UserRole.IndimanAdministrator;

            if (!string.IsNullOrEmpty(txtSearchAny.Text))
            {
                string s = txtSearchAny.Text.Trim().ToLower();

                lstPeiceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o =>
                    (isIndiman || (o.EnableForPriceList ?? false)) && (o.Number.ToLower().Contains(s) || o.NickName.ToLower().Contains(s) || o.FabricCodeName.ToLower().Contains(s))).ToList();
            }
            //else if (QueryID > 0)
            //{
            //    lstPeiceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o => o.Number == QueryID.ToString()).ToList();
            //    this.txtSearchAny.Text = QueryID.ToString();
            //}
            else
            {
                if (!string.IsNullOrEmpty(number) && !string.IsNullOrEmpty(patternnickname) && fabric > 0)
                {
                    lstPeiceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o =>
                        (isIndiman || (o.EnableForPriceList ?? false)) && (o.Number.ToLower().Contains(number)
                                                                                                 && o.NickName.ToLower().Contains(patternnickname)
                                                                                                 && o.FabricCode.Value == fabric)).ToList();
                }
                else if (!string.IsNullOrEmpty(number) && !string.IsNullOrEmpty(patternnickname))
                {
                    lstPeiceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o =>
                        (isIndiman || (o.EnableForPriceList ?? false)) && (o.Number.ToLower().Contains(number) && o.NickName.ToLower().Contains(patternnickname) || o.FabricCode.Value == fabric)).ToList();
                }
                else if (!string.IsNullOrEmpty(number) && fabric > 0)
                {
                    lstPeiceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o =>
                        (isIndiman || (o.EnableForPriceList ?? false)) && (o.Number.ToLower().Contains(number) && o.FabricCode.Value == fabric)).ToList();
                }
                else if (!string.IsNullOrEmpty(patternnickname) && fabric > 0)
                {
                    lstPeiceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o =>
                        (isIndiman || (o.EnableForPriceList ?? false)) && (o.NickName.ToLower().Contains(patternnickname) && o.FabricCode.Value == fabric)).ToList();
                }
                else if (!string.IsNullOrEmpty(number))
                {
                    lstPeiceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o =>
                        (isIndiman || (o.EnableForPriceList ?? false)) && (o.Number.Trim().Contains(number) || o.FabricCode.Value == fabric)).ToList();
                }
                else if (!string.IsNullOrEmpty(patternnickname))
                {
                    lstPeiceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o =>
                        (isIndiman || (o.EnableForPriceList ?? false)) && (o.NickName.ToLower().Contains(patternnickname) || o.FabricCode.Value == fabric)).ToList();

                }
                else if (fabric > 0)
                {
                    lstPeiceLevelCostView = (new PriceLevelCostViewBO()).SearchObjects().Where(o =>
                        (isIndiman || (o.EnableForPriceList ?? false)) && (o.FabricCode.Value == fabric)).ToList();

                }
            }

            if (lstPeiceLevelCostView.Count > 0)
            {
                //Session["PatternIdList"] = lstPeiceLevelCostView.Select(o => o.Pattern.Value).ToList();
                lstPriceLevelCostView = lstPeiceLevelCostView;
                this.dgSelectedFabrics.AllowPaging = (lstPeiceLevelCostView.Count > this.dgSelectedFabrics.PageSize);
                this.dgSelectedFabrics.DataSource = lstPeiceLevelCostView;
                this.dgSelectedFabrics.DataBind();
                this.dgSelectedFabrics.Visible = (lstPeiceLevelCostView.Count > 0);
                this.dvEmptyContent.Visible = !(this.dgSelectedFabrics.Visible);

                this.dgSelectedFabrics.Columns[7].Visible = LoggedUserRoleName == UserRole.IndimanAdministrator;
            }
            else
            {
                this.dgSelectedFabrics.Visible = (lstPeiceLevelCostView.Count > 0);
                this.dvEmptyContent.Visible = !(lstPeiceLevelCostView.Count > 0);//(this.dvEmptyContent.Visible);   
                this.h2EmptyContent.InnerText = "There are no Fabrics associated with this Pattern.";
                this.pEmptyContent.InnerText = "Once Pattern is added then you will be able to add Fabrics.";
            }
        }

        private void SendEmail()
        {
            try
            {
                string pnumber = this.hdnPatternNumber.Value.Split(',')[0].ToString();
                string fName = this.hdnSelectedID.Value;
                string NickName = this.hdnPatternNumber.Value.Split(',')[1].ToString();
                string mailTo = string.Empty;
                string mailcc = string.Empty;

                List<PriceChangeEmailListBO> lstPriceChangeEmailListTo = (new PriceChangeEmailListBO()).SearchObjects().Where(o => o.IsCC == false).ToList();

                foreach (PriceChangeEmailListBO toList in lstPriceChangeEmailListTo)
                {
                    UserBO objUser = new UserBO();
                    objUser.ID = (int)toList.User;
                    objUser.GetObject();
                    mailTo += objUser.EmailAddress + ",";
                }

                List<PriceChangeEmailListBO> lstPriceChangeEmailListCC = (new PriceChangeEmailListBO()).SearchObjects().Where(o => o.IsCC == true).ToList();

                foreach (PriceChangeEmailListBO ccList in lstPriceChangeEmailListCC)
                {
                    UserBO objUser = new UserBO();
                    objUser.ID = (int)ccList.User;
                    objUser.GetObject();
                    mailcc += objUser.EmailAddress + ",";
                }

                if (pnumber != string.Empty && fName != string.Empty)
                {
                    string emailContent = "<p>Dear Administrator,<br><br>" +
                                          "Price has been added or edited on " + DateTime.Now.ToLongDateString() + " for the following Pattern: <br><br>" +
                                          "Pattern Number: " + pnumber + " <br>" +
                                          "Nick Name: " + NickName + "<br>" +
                                          "Fabric Name: " + fName + "<br><br>" +
                                          "Please click below link to review it.<br>" +
                                          "http://" + IndicoConfiguration.AppConfiguration.SiteHostAddress + "/EditIndicoPrice.aspx?pat=" + pnumber + "<br><br>" +
                                          "Regrads, <br>" +
                                          "OPS Team</p><br>";

                    /*mailcc = IndicoConfiguration.AppConfiguration.IndimanAdministratorEmail + "," + IndicoConfiguration.AppConfiguration.PriceCCMail;*/
                    if (mailcc != string.Empty)
                    {
                        IndicoEmail.SendMailFromSystem("Indico OPS", mailTo, mailcc, "Indiman price has been added or edited", emailContent, true);
                    }
                }
                this.hdnEmailAddressesTo.Value = string.Empty;
                this.hdnEmailAddressesCC.Value = string.Empty;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while send email for indiman price change", ex);
            }
        }

        //private void GenerateExcel(string filePath, int priceTerm, string priceTermName)
        //{
        //     get a write lock on scCacheKeys
        //    IndicoPage.RWLock.AcquireWriterLock(Timeout.Infinite);

        //    string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\progress_" + 1 + ".txt";
        //    if (File.Exists(textFilePath))
        //    {
        //        File.Delete(textFilePath);
        //    }

        //     Excel
        //    double xlProgress = 0;
        //    int i = 0;
        //    string creativeDesign = string.Empty;
        //    string studioDesign = string.Empty;
        //    string thirdPartyDesign = string.Empty;
        //    string position1 = string.Empty;
        //    string position2 = string.Empty;
        //    string position3 = string.Empty;
        //    string priceValidDate = string.Empty;
        //    int row = 8;

        //    DefaultValuesPriceListBO objDefaultPriceList = new DefaultValuesPriceListBO().SearchObjects().SingleOrDefault();
        //    string lines = xlProgress.ToString();           

        //    CreateExcelDocument excell_app = new CreateExcelDocument(true);

        //    #region checkDesign

        //    /* if (checkCreativeDesign.Checked)
        //     {
        //         if (!string.IsNullOrEmpty(txtCreativeDesign.Text) && this.txtCreativeDesign.Text != objDefaultPriceList.CreativeDesign.ToString())
        //         {
        //             creativeDesign = "Creative Design Set Up Fee: $" + txtCreativeDesign.Text + " + GST per Job";
        //         }
        //         else
        //         {
        //             creativeDesign = "Creative Design Set Up Fee: $" + objDefaultPriceList.CreativeDesign.ToString() + " + GST per Job";
        //         }
        //     }
        //     if (checkStudioDesign.Checked)
        //     {
        //         if (!string.IsNullOrEmpty(txtStudioDesign.Text) && this.txtStudioDesign.Text != objDefaultPriceList.StudioDesign.ToString())
        //         {
        //             studioDesign = "Studio Design Set Up Fee: $" + txtStudioDesign.Text + " + GST per Job";
        //         }
        //         else
        //         {
        //             studioDesign = "Studio Design Set Up Fee: $" + objDefaultPriceList.StudioDesign.ToString() + " + GST per Job";
        //         }
        //     }
        //     if (checkThirdPartyDesign.Checked)
        //     {
        //         if (!string.IsNullOrEmpty(txtThirdPartyDesign.Text) && this.txtThirdPartyDesign.Text != objDefaultPriceList.ThirdPartyDesign.ToString())
        //         {
        //             thirdPartyDesign = "Third Party Design Set Up Fee: $" + txtThirdPartyDesign.Text + " + GST per Job";
        //         }
        //         else
        //         {
        //             thirdPartyDesign = "Third Party Design Set Up Fee: $" + objDefaultPriceList.ThirdPartyDesign.ToString() + " + GST per Job";
        //         }
        //     }*/

        //    #endregion

        //    #region checkPsotion

        //    /* if (checkPositionOne.Checked)
        //     {
        //         if (!string.IsNullOrEmpty(txtPositionOne.Text) && this.txtPositionOne.Text != objDefaultPriceList.Position1.ToString())
        //         {
        //             position1 = "1 x Position @ $" + txtPositionOne.Text + " - eg name on left chest";
        //         }
        //         else
        //         {
        //             position1 = "1 x Position @ $" + objDefaultPriceList.Position1.ToString() + " - eg name on left chest";
        //         }
        //     }
        //     if (checkPositionTwo.Checked)
        //     {
        //         if (!string.IsNullOrEmpty(txtPositionTwo.Text) && this.txtPositionTwo.Text != objDefaultPriceList.Position2.ToString())
        //         {
        //             position2 = "2 x Positions @ $" + txtPositionTwo.Text + " - eg names on left chest and upper back";
        //         }
        //         else
        //         {
        //             position2 = "2 x Positions @ $" + objDefaultPriceList.Position2.ToString() + " - eg names on left chest and upper back";
        //         }
        //     }
        //     if (checkPositionThree.Checked)
        //     {
        //         if (!string.IsNullOrEmpty(txtPositionThree.Text) && this.txtPositionThree.Text != objDefaultPriceList.Position3.ToString())
        //         {
        //             position3 = "3 x Positions @ $" + txtPositionThree.Text + " - eg names on left chest, upper back and number on lower back";
        //         }
        //         else
        //         {
        //             position3 = "3 x Positions @ $" + objDefaultPriceList.Position3.ToString() + " - eg names on left chest, upper back and number on lower back";
        //         }
        //     }*/
        //    #endregion

        //    try
        //    {
        //        int distributor = int.Parse(this.ddlExcelDistributor.SelectedValue);

        //        String excelType = string.Empty;
        //        PriceBO objPrice = new PriceBO();

        //         first row
        //        excell_app.AddHeaderData(1, 1, "" + this.ddlExcelDistributor.SelectedItem.Text.ToUpper() + "" + " - " + priceTermName + " PRICE LIST ALL PLUS GST PLUS LOCAL FREIGHT EX-ADELAIDE", "A1", "D1", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //         Second row
        //        excell_app.AddHeaderData(2, 1, "INDICO PTY LTD", "A2", "B2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(2, 3, "Published Date: " + DateTime.Now.ToString("dd MMMM yyyy") + "", "C2", "D2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(2, 5, "" + creativeDesign + "     " + studioDesign + "     " + thirdPartyDesign + "", "E2", "F2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(2, 9, "QUANTITY", "G2", "N2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //         Third row
        //         excell_app.AddHeaderData(3, 3, priceValidDate, "C5", "D5", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "dd MMMM yyyy");
        //         Fourth row
        //        excell_app.AddHeaderData(4, 1, "Individual Names & Numbers are charged as follows:     " + position1 + "     " + position2 + "    " + position3 + " ", "A4", "F4", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(4, 9, "All re-orders under 20 units wll have the benefit of receiving the 20 unit price", "G4", "N4", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //         Column headers
        //        excell_app.AddHeaderData(6, 1, "SPORTS CATEGORY", "A6", "A6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 2, "OTHER CATEGORIES", "B6", "B6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 3, "PATTERN", "C6", "C6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 4, "ITEM SUB CATEGORY", "D6", "D6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 5, "DESCRIPTION", "E6", "E6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 6, "FABRIC", "F6", "F6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderDataWithBackgroundColor(6, 9, "'1-5", "G6", "I6", true, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(6, 12, "'6 - 9", "J6", "L6", true, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(6, 15, "'10 - 19", "M6", "O6", true, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderData(6, 18, "20 - 49", "P6", "R6", true, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 21, "50 - 99", "S6", "U6", true, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 24, "100 - 249", "V6", "X6", true, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 27, "250 - 499", "Y6", "AA6", true, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 30, "500+", "AB6", "AD6", true, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderDataWithBackgroundColor(7, 7, "Factory", "G7", "G7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(7, 8, "Indiman", "H7", "H7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(7, 9, "Indico", "I7", "I7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(7, 10, "Factory", "J7", "J7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(7, 11, "Indiman", "K7", "K7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(7, 12, "Indico", "L7", "L7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(7, 13, "Factory", "M7", "M7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(7, 14, "Indiman", "N7", "N7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(7, 15, "Indico", "O7", "O7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderData(7, 16, "Factory", "P7", "P7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 17, "Indiman", "Q7", "Q7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 18, "Indico", "R7", "R7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 19, "Factory", "S7", "S7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 20, "Indiman", "T7", "T7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 21, "Indico", "U7", "U7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 22, "Factory", "V7", "V7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 23, "Indiman", "W7", "W7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 24, "Indico", "X7", "X7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 25, "Factory", "Y7", "Y7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 26, "Indiman", "Z7", "Z7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 27, "Indico", "AA7", "AA7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 28, "Factory", "AB7", "AB7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 29, "Indiman", "AC7", "AC7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(7, 30, "Indico", "AD7", "AD7", false, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");

        //        string categoryName = string.Empty;
        //         int row = 7;

        //        List<ReturnIndimanPriceListDataViewBO> lstIndimanPriceListData = new List<ReturnIndimanPriceListDataViewBO>();
        //        lstIndimanPriceListData = PriceLevelCostBO.GeIndimanPriceListData(int.Parse(this.ddlExcelDistributor.SelectedValue));

        //        List<IGrouping<int, ReturnIndimanPriceListDataViewBO>> lstPrice = lstIndimanPriceListData.GroupBy(o => (int)o.Price).ToList();

        //         List<int> indicoPrice = new List<int>();
        //        foreach (IGrouping<int, ReturnIndimanPriceListDataViewBO> Price in lstPrice)
        //        {
        //            List<ReturnIndimanPriceListDataViewBO> lstPriceDetails = Price.ToList();

        //            if (categoryName == string.Empty || categoryName != lstPriceDetails[0].SportsCategory)
        //            {
        //                excell_app.AddData(row, 1, "", "A" + row, "A" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //                categoryName = lstPriceDetails[0].SportsCategory;

        //                row++;
        //            }

        //            excell_app.AddData(row, 1, lstPriceDetails[0].SportsCategory, "A" + row, "A" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 2, lstPriceDetails[0].OtherCategories, "B" + row, "B" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 3, "'" + lstPriceDetails[0].Number, "C" + row, "C" + row, "@", Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 4, (lstPriceDetails[0].ItemSubCategoris != null) ? lstPriceDetails[0].ItemSubCategoris.ToUpper() : string.Empty, "D" + row, "D" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 5, lstPriceDetails[0].NickName.ToUpper(), "E" + row, "E" + row, null, Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 6, lstPriceDetails[0].FabricCodenNickName.ToUpper(), "F" + row, "F" + row, null, Excel.XlHAlign.xlHAlignLeft);

        //            0
        //            excell_app.AddDataWithBackgroundColor(row, 7, Math.Round((decimal)lstPriceDetails[0].FactoryCost, 2).ToString(), "G" + row, "G" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddDataWithBackgroundColor(row, 8, Math.Round((decimal)lstPriceDetails[0].IndimanCost, 2).ToString(), "H" + row, "H" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddDataWithBackgroundColor(row, 9, (priceTerm == 1) ? Math.Round((decimal)lstPriceDetails[0].EditedCIFPrice, 2).ToString() : Math.Round((decimal)lstPriceDetails[0].EditedFOBPrice, 2).ToString(), "I" + row, "I" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            1
        //            excell_app.AddDataWithBackgroundColor(row, 10, Math.Round((decimal)lstPriceDetails[1].FactoryCost, 2).ToString(), "J" + row, "J" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddDataWithBackgroundColor(row, 11, Math.Round((decimal)lstPriceDetails[1].IndimanCost, 2).ToString(), "K" + row, "K" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddDataWithBackgroundColor(row, 12, (priceTerm == 1) ? Math.Round((decimal)lstPriceDetails[1].EditedCIFPrice, 2).ToString() : Math.Round((decimal)lstPriceDetails[1].EditedFOBPrice, 2).ToString(), "L" + row, "L" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            2
        //            excell_app.AddDataWithBackgroundColor(row, 13, Math.Round((decimal)lstPriceDetails[2].FactoryCost, 2).ToString(), "M" + row, "M" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddDataWithBackgroundColor(row, 14, Math.Round((decimal)lstPriceDetails[2].IndimanCost, 2).ToString(), "N" + row, "N" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddDataWithBackgroundColor(row, 15, (priceTerm == 1) ? Math.Round((decimal)lstPriceDetails[2].EditedCIFPrice, 2).ToString() : Math.Round((decimal)lstPriceDetails[2].EditedFOBPrice, 2).ToString(), "O" + row, "O" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            3
        //            excell_app.AddData(row, 16, Math.Round((decimal)lstPriceDetails[3].FactoryCost, 2).ToString(), "P" + row, "P" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddData(row, 17, Math.Round((decimal)lstPriceDetails[3].IndimanCost, 2).ToString(), "Q" + row, "Q" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddData(row, 18, (priceTerm == 1) ? Math.Round((decimal)lstPriceDetails[3].EditedCIFPrice, 2).ToString() : Math.Round((decimal)lstPriceDetails[3].EditedFOBPrice, 2).ToString(), "R" + row, "R" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            4
        //            excell_app.AddData(row, 19, Math.Round((decimal)lstPriceDetails[4].FactoryCost, 2).ToString(), "S" + row, "S" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddData(row, 20, Math.Round((decimal)lstPriceDetails[4].IndimanCost, 2).ToString(), "T" + row, "T" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddData(row, 21, (priceTerm == 1) ? Math.Round((decimal)lstPriceDetails[4].EditedCIFPrice, 2).ToString() : Math.Round((decimal)lstPriceDetails[4].EditedFOBPrice, 2).ToString(), "U" + row, "U" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            5
        //            excell_app.AddData(row, 22, Math.Round((decimal)lstPriceDetails[5].FactoryCost, 2).ToString(), "V" + row, "V" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddData(row, 23, Math.Round((decimal)lstPriceDetails[5].IndimanCost, 2).ToString(), "W" + row, "W" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddData(row, 24, (priceTerm == 1) ? Math.Round((decimal)lstPriceDetails[5].EditedCIFPrice, 2).ToString() : Math.Round((decimal)lstPriceDetails[5].EditedFOBPrice, 2).ToString(), "X" + row, "X" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            6
        //            excell_app.AddData(row, 25, Math.Round((decimal)lstPriceDetails[6].FactoryCost, 2).ToString(), "Y" + row, "Y" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddData(row, 26, Math.Round((decimal)lstPriceDetails[6].IndimanCost, 2).ToString(), "Z" + row, "Z" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddData(row, 27, (priceTerm == 1) ? Math.Round((decimal)lstPriceDetails[6].EditedCIFPrice, 2).ToString() : Math.Round((decimal)lstPriceDetails[6].EditedFOBPrice, 2).ToString(), "AA" + row, "AA" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            7
        //            excell_app.AddData(row, 28, Math.Round((decimal)lstPriceDetails[7].FactoryCost, 2).ToString(), "AB" + row, "AB" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddData(row, 29, Math.Round((decimal)lstPriceDetails[7].IndimanCost, 2).ToString(), "AC" + row, "AC" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            excell_app.AddData(row, 30, (priceTerm == 1) ? Math.Round((decimal)lstPriceDetails[7].EditedCIFPrice, 2).ToString() : Math.Round((decimal)lstPriceDetails[7].EditedFOBPrice, 2).ToString(), "AD" + row, "AD" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            row++;
        //            i++;

        //            xlProgress = Math.Round(((double.Parse("100") / double.Parse(lstPrice.Count.ToString())) * i), 0);

        //             Writing progress in text file.
        //            string lines = xlProgress.ToString();
        //            System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
        //            file.WriteLine(lines);
        //            file.Close();
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //         Log the error
        //        IndicoLogging.log.Error("Error occured while Generation Indiman Excel.", ex);
        //    }
        //    finally
        //    {
        //         Set AutoFilter colums
        //        excell_app.AutoFilter(row);
        //         Save & Close the Excel Document
        //        excell_app.CloseDocument(filePath);

        //         release the lock
        //        IndicoPage.RWLock.ReleaseWriterLock();
        //    }
        //}

        //private bool isFileAccess(string filePath)
        //{
        //    FileInfo file = new FileInfo(filePath);
        //    FileStream stream = null;

        //    try
        //    {
        //        stream = file.Open(FileMode.Open, FileAccess.Read, FileShare.None);
        //    }
        //    catch (IOException)
        //    {
        //        return true;
        //    }
        //    finally
        //    {
        //        if (stream != null)
        //        {
        //            stream.Close();
        //        }
        //    }
        //    return false;
        //}

        private void CreateExcel(string filePath, int priceTerm, string priceTermName)
        {
            // get a write lock on scCacheKeys
            IndicoPage.RWLock.AcquireWriterLock(Timeout.Infinite);

            double xlProgress = 0;
            int i = 0;
            string categoryName = string.Empty;
            int row = 8;
            CreateOpenXMLExcel openxml_Excel = new CreateOpenXMLExcel("Indiman Excel");

            try
            {
                string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\progress_" + 1 + ".txt";
                if (File.Exists(textFilePath))
                {
                    File.Delete(textFilePath);
                }

                #region Column Width

                openxml_Excel.ChangeColumnWidth(1, 13);//A
                openxml_Excel.ChangeColumnWidth(2, 30);//B
                openxml_Excel.ChangeColumnWidth(3, 10);//C
                openxml_Excel.ChangeColumnWidth(4, 36);//D
                openxml_Excel.ChangeColumnWidth(5, 50);//E
                openxml_Excel.ChangeColumnWidth(6, 40);//F
                openxml_Excel.ChangeColumnWidth(7, 10);//G
                openxml_Excel.ChangeColumnWidth(8, 10);//H
                openxml_Excel.ChangeColumnWidth(9, 10);//I
                openxml_Excel.ChangeColumnWidth(10, 10);//J
                openxml_Excel.ChangeColumnWidth(11, 10);//K
                openxml_Excel.ChangeColumnWidth(12, 10);//L
                openxml_Excel.ChangeColumnWidth(13, 10);//M
                openxml_Excel.ChangeColumnWidth(14, 10);//N
                openxml_Excel.ChangeColumnWidth(15, 10);//O
                openxml_Excel.ChangeColumnWidth(16, 10);//P
                openxml_Excel.ChangeColumnWidth(17, 10);//Q
                openxml_Excel.ChangeColumnWidth(18, 10);//R
                openxml_Excel.ChangeColumnWidth(19, 10);//S
                openxml_Excel.ChangeColumnWidth(20, 10);//T
                openxml_Excel.ChangeColumnWidth(21, 10);//U
                openxml_Excel.ChangeColumnWidth(22, 10);//V
                openxml_Excel.ChangeColumnWidth(23, 10);//W
                openxml_Excel.ChangeColumnWidth(24, 10);//X
                openxml_Excel.ChangeColumnWidth(25, 10);//Y
                openxml_Excel.ChangeColumnWidth(26, 10);//Z
                openxml_Excel.ChangeColumnWidth(27, 10);//AA
                openxml_Excel.ChangeColumnWidth(28, 10);//AB
                openxml_Excel.ChangeColumnWidth(29, 10);//AC
                openxml_Excel.ChangeColumnWidth(30, 10);//AD              

                #endregion

                #region Heading

                openxml_Excel.AddHeaderData("A1", this.ddlExcelDistributor.SelectedItem.Text.ToUpper() + "" + " - " + priceTermName + " PRICE LIST ALL PLUS GST PLUS LOCAL FREIGHT EX-ADELAIDE", "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "A1:D1", XLCellValues.Text);
                openxml_Excel.AddHeaderData("A2", "INDICO PTY LTD", "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "A2:B2", XLCellValues.Text);
                openxml_Excel.AddHeaderData("C2", "Published Date: " + DateTime.Now.ToString("dd MMMM yyyy"), "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "C2:D2", XLCellValues.Text);
                openxml_Excel.AddHeaderData("G2", "QUANTITY", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, "G2:N2", XLCellValues.Text);
                openxml_Excel.AddHeaderData("A4", "Individual Names & Numbers are charged as follows:", "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "A4:F4", XLCellValues.Text);
                openxml_Excel.AddHeaderData("G4", "All re-orders under 20 units will have the benefit of receiving the 20 unit price", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, "G4:N4", XLCellValues.Text);

                //Data Heading
                openxml_Excel.AddHeaderData("A6", "SPORTS CATEGORY", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("B6", "OTHER CATEGORIES", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("C6", "PATTERN", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("D6", "ITEM SUM CATEGORY", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("E6", "DESCRIPTION", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("F6", "FABRIC", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("G6", "'1 - 5", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, "G6:I6", XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("J6", "'6 - 9", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, "J6:L6", XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("M6", "'10 - 19", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, "M6:O6", XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("P6", "'20 - 49", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, "P6:R6", XLCellValues.Text);
                openxml_Excel.AddHeaderData("S6", "'50 - 99", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, "S6:U6", XLCellValues.Text);
                openxml_Excel.AddHeaderData("V6", "'100 - 249", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, "V6:X6", XLCellValues.Text);
                openxml_Excel.AddHeaderData("Y6", "'100 - 249", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, "Y6:AA6", XLCellValues.Text);
                openxml_Excel.AddHeaderData("AB6", "'500+", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, "AB6:AD6", XLCellValues.Text);

                // merge Heading              
                openxml_Excel.AddHeaderData("G7", "Factory", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("H7", "Indiman", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("I7", "Indico", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);

                openxml_Excel.AddHeaderData("J7", "Factory", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("K7", "Indiman", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("L7", "Indico", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);

                openxml_Excel.AddHeaderData("M7", "Factory", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("N7", "Indiman", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("O7", "Indico", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);

                openxml_Excel.AddHeaderData("P7", "Factory", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("Q7", "Indiman", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("R7", "Indico", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);

                openxml_Excel.AddHeaderData("S7", "Factory", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("T7", "Indiman", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("U7", "Indico", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);

                openxml_Excel.AddHeaderData("V7", "Factory", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("W7", "Indiman", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("X7", "Indico", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);

                openxml_Excel.AddHeaderData("Y7", "Factory", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("Z7", "Indiman", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("AA7", "Indico", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);

                openxml_Excel.AddHeaderData("AB7", "Factory", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("AC7", "Indiman", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("AD7", "Indico", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);


                #endregion

                #region Data

                List<ReturnIndimanPriceListDataViewBO> lstIndimanPriceListData = new List<ReturnIndimanPriceListDataViewBO>();
                lstIndimanPriceListData = PriceLevelCostBO.GeIndimanPriceListData(int.Parse(this.ddlExcelDistributor.SelectedValue));

                List<IGrouping<int, ReturnIndimanPriceListDataViewBO>> lstPrice = lstIndimanPriceListData.GroupBy(o => (int)o.Price).ToList();

                foreach (IGrouping<int, ReturnIndimanPriceListDataViewBO> Price in lstPrice)
                {
                    List<ReturnIndimanPriceListDataViewBO> lstPriceDetails = Price.ToList();

                    if (categoryName == string.Empty || categoryName != lstPriceDetails[0].SportsCategory)
                    {
                        openxml_Excel.AddCellValue("A" + row.ToString(), string.Empty, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                        categoryName = lstPriceDetails[0].SportsCategory;

                        row++;
                    }

                    openxml_Excel.AddCellValue("A" + row.ToString(), lstPriceDetails[0].SportsCategory.ToUpper(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("B" + row.ToString(), lstPriceDetails[0].OtherCategories.ToUpper(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("C" + row.ToString(), lstPriceDetails[0].Number.ToUpper(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("D" + row.ToString(), lstPriceDetails[0].ItemSubCategoris.ToUpper(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("E" + row.ToString(), lstPriceDetails[0].NickName.ToUpper(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("F" + row.ToString(), lstPriceDetails[0].FabricCodenNickName.ToUpper(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);

                    //0
                    openxml_Excel.AddCellValueNumberFormat("G" + row.ToString(), Math.Round((decimal)lstPriceDetails[0].FactoryCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);
                    openxml_Excel.AddCellValueNumberFormat("H" + row.ToString(), Math.Round((decimal)lstPriceDetails[0].IndimanCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);
                    openxml_Excel.AddCellValueNumberFormat("I" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[0].EditedCIFPrice : (decimal)lstPriceDetails[0].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);

                    //1
                    openxml_Excel.AddCellValueNumberFormat("J" + row.ToString(), Math.Round((decimal)lstPriceDetails[1].FactoryCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);
                    openxml_Excel.AddCellValueNumberFormat("K" + row.ToString(), Math.Round((decimal)lstPriceDetails[1].IndimanCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);
                    openxml_Excel.AddCellValueNumberFormat("L" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[1].EditedCIFPrice : (decimal)lstPriceDetails[1].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);

                    //2                    
                    openxml_Excel.AddCellValueNumberFormat("M" + row.ToString(), Math.Round((decimal)lstPriceDetails[2].FactoryCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);
                    openxml_Excel.AddCellValueNumberFormat("N" + row.ToString(), Math.Round((decimal)lstPriceDetails[2].IndimanCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);
                    openxml_Excel.AddCellValueNumberFormat("O" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[2].EditedCIFPrice : (decimal)lstPriceDetails[2].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);

                    //3
                    openxml_Excel.AddCellValueNumberFormat("P" + row.ToString(), Math.Round((decimal)lstPriceDetails[3].FactoryCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");
                    openxml_Excel.AddCellValueNumberFormat("Q" + row.ToString(), Math.Round((decimal)lstPriceDetails[3].IndimanCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");
                    openxml_Excel.AddCellValueNumberFormat("R" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[3].EditedCIFPrice : (decimal)lstPriceDetails[3].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    //4
                    openxml_Excel.AddCellValueNumberFormat("S" + row.ToString(), Math.Round((decimal)lstPriceDetails[4].FactoryCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");
                    openxml_Excel.AddCellValueNumberFormat("T" + row.ToString(), Math.Round((decimal)lstPriceDetails[4].IndimanCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");
                    openxml_Excel.AddCellValueNumberFormat("U" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[4].EditedCIFPrice : (decimal)lstPriceDetails[4].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    //5
                    openxml_Excel.AddCellValueNumberFormat("V" + row.ToString(), Math.Round((decimal)lstPriceDetails[5].FactoryCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");
                    openxml_Excel.AddCellValueNumberFormat("W" + row.ToString(), Math.Round((decimal)lstPriceDetails[5].IndimanCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");
                    openxml_Excel.AddCellValueNumberFormat("X" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[5].EditedCIFPrice : (decimal)lstPriceDetails[5].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    //6
                    openxml_Excel.AddCellValueNumberFormat("Y" + row.ToString(), Math.Round((decimal)lstPriceDetails[6].FactoryCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");
                    openxml_Excel.AddCellValueNumberFormat("Z" + row.ToString(), Math.Round((decimal)lstPriceDetails[6].IndimanCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");
                    openxml_Excel.AddCellValueNumberFormat("AA" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[6].EditedCIFPrice : (decimal)lstPriceDetails[6].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    //7
                    openxml_Excel.AddCellValueNumberFormat("AB" + row.ToString(), Math.Round((decimal)lstPriceDetails[7].FactoryCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");
                    openxml_Excel.AddCellValueNumberFormat("AC" + row.ToString(), Math.Round((decimal)lstPriceDetails[7].IndimanCost, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");
                    openxml_Excel.AddCellValueNumberFormat("AD" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[7].EditedCIFPrice : (decimal)lstPriceDetails[7].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    row++;
                    i++;

                    xlProgress = Math.Round(((double.Parse("100") / double.Parse(lstPrice.Count.ToString())) * i), 0);

                    // Writing progress in text file.
                    //string lines = xlProgress.ToString();
                    //System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
                    //file.WriteLine(lines);
                    //file.Close();
                }

                #endregion

            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Generation Indiman Excel.", ex);
            }
            finally
            {

                //Set Autofilter
                openxml_Excel.AutotFilter("A6:F" + row.ToString());

                //Freeze Pane
                openxml_Excel.FreezePane(6, 6);

                // Close Excel
                openxml_Excel.CloseDocument(filePath);

                // release the lock
                IndicoPage.RWLock.ReleaseWriterLock();

                this.DownloadExcel();
            }
        }

        private void DownloadExcel()
        {
            string filename = ViewState["filePath"].ToString();
            string filePath = String.Format("{0}{1}", (IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\PriceLists\"), filename);

            if (this.IsNotRefresh)
            {
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
            ViewState["PopulateEmailAddress"] = false;
        }

        [WebMethod]
        public static string Progress(string UserID)
        {
            string percentage = "0";
            string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\progress_" + 1 + ".txt";

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