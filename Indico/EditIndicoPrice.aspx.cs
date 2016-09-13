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
using Excel = Microsoft.Office.Interop.Excel;
using System.IO;
using System.Text;
using System.Threading;
using System.Web.Services;
using System.Text.RegularExpressions;
using System.Reflection;

namespace Indico
{
    public partial class EditIndicoPrice : IndicoPage
    {
        #region Fields

        private decimal conversionFactor = 0;
        private string urlPatternID = string.Empty;
        private int urlDistributorID = 0;
        private int urlTermID = 0;
        List<int> sportCategories = null;
        public string errorMessage { get; set; }

        #endregion

        #region Properties

        protected string QueryPatternID
        {
            get
            {
                if (!string.IsNullOrEmpty(urlPatternID))
                    return urlPatternID.ToString();

                if ((urlPatternID == string.Empty) && (Request.QueryString["pat"] != null))
                {
                    urlPatternID = (Request.QueryString["pat"].ToString() != null) ? Request.QueryString["pat"].ToString() : string.Empty;
                }
                return urlPatternID;
            }
        }

        protected int QueryDistributorID
        {
            get
            {
                if (urlDistributorID > 0)
                    return urlDistributorID;

                if ((urlDistributorID == 0) && (Request.QueryString["dist"] != null))
                {
                    urlDistributorID = Convert.ToInt32(Request.QueryString["dist"].ToString());
                }
                return urlDistributorID;
            }
        }

        protected int QueryTermID
        {
            get
            {
                if (urlTermID > 0)
                    return urlTermID;

                if ((urlTermID == 0) && (Request.QueryString["term"] != null))
                {
                    urlTermID = Convert.ToInt32(Request.QueryString["term"].ToString());
                }
                return urlTermID;
            }
        }

        protected List<int> SportCategories
        {
            get
            {
                if (sportCategories != null)
                    return sportCategories;

                if ((sportCategories == null) && (Session["SportCategories"] != null))
                {
                    sportCategories = (List<int>)(Session["SportCategories"]);
                }
                return sportCategories;
            }
        }

        /*private int SelectedPattern
{
    get
    {
        if (this.selectedPattern > 0)
        {
            this.hdnSelectPattern.Value = this.selectedPattern.ToString();
            return this.selectedPattern;
        }

        if (int.Parse(this.hdnSelectPattern.Value) > 0)
        {
            this.selectedPattern = int.Parse(this.hdnSelectPattern.Value);
        }
        else if (string.IsNullOrEmpty(this.txtPattern.Text.Trim()))
        {
            this.selectedPattern = 0;
        }
        else if (!string.IsNullOrEmpty(this.txtPattern.Text.Trim()))
        {
            if (!string.IsNullOrEmpty(this.hdnSelectPattern.Value.ToString()) && int.Parse(this.hdnSelectPattern.Value) == 0)
            {
                string s = this.txtPattern.Text;
                List<PatternBO> lstPattern = (new PatternBO()).SearchObjects().Where(o => o.Number.Contains(s) || o.NickName.Contains(s)).ToList();

                if (lstPattern == null || lstPattern.Count == 0)
                {
                    this.cvPattern.IsValid = false;
                    this.cvPattern.Visible = true;
                    return -1;
                }
            }
            else
            {
                this.selectedPattern = int.Parse(this.hdnSelectPattern.Value.ToString());
            }
        }
        else
        {
            this.selectedPattern = this.QueryPatternID;
        }

        this.hdnSelectPattern.Value = this.selectedPattern.ToString();
        return selectedPattern;
    }
}*/

        /*protected PatternBO ActivePattern
        {
            get
            {
                if (_activePatternBO == null || _activePatternBO.ID == 0)
                {
                    _activePatternBO = new PatternBO(this.ObjContext);
                    _activePatternBO.ID = this.SelectedPattern;
                    _activePatternBO.GetObject();
                }
                return _activePatternBO;
            }
        }*/

        /*protected List<FabricCodeBO> FabricCodesWhereThisIsPattern
        {
            get
            {
                if (_activePatternFabrics == null || _activePatternFabrics.Count == 0)
                {
                    _activePatternFabrics = this.ActivePattern.PricesWhereThisIsPattern.OrderBy(o => o.ID).Select(o => o.objFabricCode).ToList();
                }
                return _activePatternFabrics;
            }
        }*/

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

        private bool IsFileLocked(FileInfo file)
        {
            FileStream stream = null;

            try
            {
                stream = file.Open(FileMode.Open, FileAccess.ReadWrite, FileShare.None);
            }
            catch (IOException)
            {
                //the file is unavailable because it is:
                //still being written to
                //or being processed by another thread
                //or does not exist (has already been processed)
                return true;
            }
            finally
            {
                if (stream != null)
                    stream.Close();
            }

            //file is not locked
            return false;
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

        //protected override void OnPreInit(EventArgs e)
        //{
        //    // Pop a script manager on the page if one does not yet exist.
        //    ScriptManager scriptManager = ScriptManager.GetCurrent(this);
        //    if (scriptManager == null)
        //    {
        //        scriptManager = new ScriptManager();
        //        scriptManager.ID = "myScriptManager";
        //        //this.Controls.AddAt(1, scriptManager);
        //        scriptManager.EnablePartialRendering = true;
        //        this.Controls.Add(scriptManager);
        //       /* HtmlForm form = this.Form;
        //        if (form != null)
        //        {
        //            form.Controls.AddAt(0, scriptManager);
        //        }*/
        //    }

        //    base.OnPreInit(e);
        //}

        /*protected void rptSpecSizeQtyHeader_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
            {
                SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

                Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
                litCellHeader.Text = objSizeChart.objSize.SizeName;
            }
        }*/

        /*protected void rptSpecML_ItemDataBound(object sender, RepeaterItemEventArgs e)
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
        }*/

        /*protected void rptSpecSizeQty_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
            {
                SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

                Label lblCellData = (Label)item.FindControl("lblCellData");
                lblCellData.Text = objSizeChart.Val.ToString();
            }
        }*/

        protected void cfvPriceValidDate_Validating(object sender, EventArgs e)
        {

        }

        protected void btnChangeCifFob_Click(object sender, EventArgs e)
        {
            //List<int> selectedSprotCategories = new List<int>();

            //foreach (ListItem item in this.lstOtherCategories.Items)
            //{
            //    if (item.Selected)
            //    {
            //        selectedSprotCategories.Add(int.Parse(item.Value));
            //    }
            //}

            //Session["SportCategories"] = lstOtherCategories;
            if (Session["IsRefresh"].ToString() == ViewState["IsRefresh"].ToString())
            {
                if (((System.Web.UI.WebControls.Button)(sender)).Text == "Show FOB Pricing")
                {
                    this.hdnTerm.Value = "2";
                    this.btnChangeCifFob.Text = "Show CIF Pricing";
                }
                else
                {
                    this.hdnTerm.Value = "1";
                    this.btnChangeCifFob.Text = "Show FOB Pricing";
                }

                this.PopulatePriceLevelCosts();
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            //this.ProcessForm(this.rptSportCategory);
            //ViewState["PopulatePaternSearch"] = false;          

            Repeater rptPriceLevelCost = (Repeater)((LinkButton)(sender)).FindControl("rptPriceLevelCost");
            //PRW this.ProcessPricesses(rptPriceLevelCost);
            this.ProcessAll(this.rptSportCategory);

            //this.rptSelectedFabrics.DataSource = this.FabricCodesWhereThisIsPattern;
            //this.rptSelectedFabrics.DataBind();

            ViewState["PopulatePatern"] = false;
            ViewState["PopulatePaternSearch"] = false;
            ViewState["PopulateViewNote"] = false;
            ViewState["PopulateAddEditNote"] = false;
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int fabricCode = int.Parse(this.hdnSelectedID.Value.Trim());
            if (Page.IsValid)
            {
                /*try
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

                        List<FabricCodeBO> lstFabricCodes = (List<FabricCodeBO>)(Session["SelectedFabrics" + this.LoggedUser.ID.ToString()]);
                        lstFabricCodes = (from o in lstFabricCodes
                                          where o.ID != fabricCode
                                          select o).ToList();

                        this.rptSelectedCategory.DataSource = lstFabricCodes;
                        this.rptSelectedCategory.DataBind();

                        this.rptSelectedCategory.Visible = (lstFabricCodes.Count > 0);
                        this.dvEmptyContent.Visible = !(this.rptSelectedCategory.Visible);
                        Session.Add("SelectedFabrics" + this.LoggedUser.ID.ToString(), ((lstFabricCodes.Count > 0) ? lstFabricCodes : null));
                    }
                    else
                    {
                        List<FabricCodeBO> lstFabricCodes = (List<FabricCodeBO>)(Session["SelectedFabrics" + this.LoggedUser.ID.ToString()]);
                        lstFabricCodes = (from o in lstFabricCodes
                                          where o.ID != fabricCode
                                          select o).ToList();
                        this.rptSelectedCategory.DataSource = lstFabricCodes;
                        this.rptSelectedCategory.DataBind();

                        this.rptSelectedCategory.Visible = (lstFabricCodes.Count > 0);
                        this.dvEmptyContent.Visible = !(this.rptSelectedCategory.Visible);
                        Session.Add("SelectedFabrics" + this.LoggedUser.ID.ToString(), ((lstFabricCodes.Count > 0) ? lstFabricCodes : null));
                    }
                }
                catch (Exception)
                {
                    // Log the error
                    //IndicoLogging.log("btnDelete_Click : Error occured while Adding the Item", ex);
                }*/
            }
        }

        /*protected void dgPatterns_ItemDataBound(object sender, DataGridItemEventArgs e)
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
        }*/

        /*protected void dgPatterns_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dgPatterns.CurrentPageIndex = e.NewPageIndex;

            // Populate patterns datagrid
            this.PopulateDataGridPatterns();

            ViewState["PopulatePaternSearch"] = true;
            ViewState["PopulateFabric"] = false;
        }*/

        /*protected void dgPatterns_SortCommand(object source, DataGridSortCommandEventArgs e)
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

            ViewState["PopulatePaternSearch"] = true;
            ViewState["PopulateFabric"] = false;
        }*/

        /*protected void btnSearchPattern_Click(object sender, EventArgs e)
        {
            // Populate patterns datagrid
            if (this.IsNotRefresh)
            {
                this.PopulateDataGridPatterns();
            }

            ViewState["PopulatePaternSearch"] = true;
            ViewState["PopulateFabric"] = false;
        }*/

        /*protected void btnSelectPattern_Click(object sender, EventArgs e)
        {
            int qid = int.Parse(((System.Web.UI.WebControls.LinkButton)(sender)).Attributes["qid"].ToString());
            if (qid > 0)
            {
                _activePatternBO = null;
                _activePatternFabrics = null;

                // Set active pattern ID
                this.hdnSelectPattern.Value = qid.ToString();

                // Populate pattern
                this.PopulatePattern();
            }

            ViewState["PopulatePatern"] = false;
            ViewState["PopulatePaternSearch"] = false;
            ViewState["PopulateFabric"] = false;
            ViewState["PopulateAddEditNote"] = false;
        }*/


        //protected void btnViewPattern_Click(object sender, EventArgs e)
        //{
        //    this.PopulatePattern();
        //}

        /*  protected void btnAddEditNote_Click(object sender, EventArgs e)
          {
              int price = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["PriceID"]);
              this.btnSaveNote.Attributes.Add("PriceID", price.ToString());

              if (price > 0)
              {
                  PriceBO objPrice = new PriceBO();
                  objPrice.ID = price;
                  objPrice.GetObject();

                  //this.lblNoteTitle.Text = string.IsNullOrEmpty(objPrice.Remarks) ? "Add New Note" : "Edit Note";
                  this.txtNote.Text = objPrice.Remarks;
              }

              ViewState["PopulateAddEditNote"] = true;
          }*/

        protected void btnViewNote_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int price = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["pid"]);
                PriceRemarksBO objPriceRemarks = new PriceRemarksBO();
                objPriceRemarks.Price = price;
                List<PriceRemarksBO> lstPriceRemarks = objPriceRemarks.SearchObjects().ToList();

                if (lstPriceRemarks.Count > 0)
                {
                    this.dvNoteEmptyContent.Visible = false;
                    this.dgViewNote.DataSource = lstPriceRemarks;
                    this.dgViewNote.DataBind();
                }
                else
                {
                    this.dvNoteEmptyContent.Visible = true;
                    this.dgViewNote.Visible = false;
                }
                ViewState["PopulateViewNote"] = true;
                // Session["IsRefresh"] = Server.UrlEncode(System.DateTime.Now.ToString());
            }
        }

        protected void btnSaveNote_Click(object sender, EventArgs e)
        {
            int price = int.Parse(this.PriceID.Value);
            if (this.IsNotRefresh)
            {
                if (Page.IsValid)
                {
                    if (price > 0)
                    {
                        try
                        {
                            using (TransactionScope ts = new TransactionScope())
                            {
                                PriceRemarksBO objPriceRemarks = new PriceRemarksBO(this.ObjContext);
                                objPriceRemarks.Price = price;
                                objPriceRemarks.Remarks = this.txtNote.Text;
                                objPriceRemarks.Creator = LoggedUser.ID;
                                objPriceRemarks.CreatedDate = DateTime.Now;
                                this.ObjContext.SaveChanges();
                                ts.Complete();
                            }
                        }
                        catch (Exception ex)
                        {
                            IndicoLogging.log.Error("Error occured while ading/updating note(btnSaveNote_Click())", ex);
                        }
                    }
                }

                ViewState["PopulateAddEditNote"] = !(Page.IsValid);
                ViewState["PopulateViewNote"] = false;
                this.PopulatePriceLevelCosts();
            }
        }

        protected void dgViewNote_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PriceRemarksBO)
            {
                PriceRemarksBO objPriceRemarks = (PriceRemarksBO)item.DataItem;
                UserBO objUser = new UserBO();
                objUser.ID = objPriceRemarks.Creator;
                List<UserBO> lstUser = objUser.SearchObjects().ToList();

                Literal lblCreator = (Literal)item.FindControl("lblCreator");
                if (lstUser.Count > 0)
                {
                    lblCreator.Text = lstUser[0].FamilyName + " " + lstUser[0].GivenName;
                }
                Literal lblCreatedDate = (Literal)item.FindControl("lblCreatedDate");
                lblCreatedDate.Text = objPriceRemarks.CreatedDate.ToShortDateString();

                Literal lblRemarks = (Literal)item.FindControl("lblRemarks");
                lblRemarks.Text = objPriceRemarks.Remarks;

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("pr", objPriceRemarks.ID.ToString());
            }
        }

        //PRW
        protected void btnSearchByCategory_Click(object sender, EventArgs e)
        {
            //test
            bool isSelected = false;
            this.hdnTerm.Value = (this.rbCifPrice.Checked == true) ? "1" : "2";
            foreach (ListItem item in this.lstOtherCategories.Items)
            {
                if (item.Selected)
                {
                    isSelected = true;
                    break;
                }
            }

            if (isSelected == true)
            {
                this.dvEmptyContent.Visible = false;
                errorMessage = string.Empty;
                this.PopulatePriceLevelCosts();
            }
            else
            {
                PriceLevelCostViewBO objPriceLevelCostView = new PriceLevelCostViewBO();
                List<int> lstCategories = new List<int>();
                if (!string.IsNullOrEmpty(this.txtSearchAny.Text))
                {
                    lstCategories = (from o in objPriceLevelCostView.SearchObjects().Where(o => o.Number.ToLower() == this.txtSearchAny.Text.ToLower())
                                     select o.CoreCategory.Value).ToList();
                    if (lstCategories.Count > 0)
                    {
                        this.hdnSelectPattern.Value = this.txtSearchAny.Text;
                    }
                }
                if (lstCategories.Count == 0 && !string.IsNullOrEmpty(this.txtSearchAny.Text))
                {
                    lstCategories = (from o in objPriceLevelCostView.SearchObjects().Where(o => o.Number.ToLower().Contains(this.txtSearchAny.Text.ToLower()) ||
                                                                                                 o.NickName.ToLower().Contains(this.txtSearchAny.Text.ToLower()) ||
                                                                                                 o.FabricCodeName.ToLower().Contains(this.txtSearchAny.Text.ToLower()))
                                     select o.CoreCategory.Value).ToList();

                }

                if (lstCategories.Count > 0)
                {
                    foreach (ListItem item in lstOtherCategories.Items)
                    {
                        if (lstCategories.Contains(int.Parse(item.Value)))
                        {
                            this.lstOtherCategories.Items.FindByValue(item.Value).Selected = true;
                        }
                    }
                    errorMessage = string.Empty;
                }
                else
                {
                    this.dvEmptyContent.Visible = true;
                    errorMessage = "No results found.";
                }
                this.PopulatePriceLevelCosts();
            }

            ViewState["PopulatePaternSearch"] = false;
            ViewState["populatePresentage"] = false;
            ViewState["PopulateViewNote"] = false;
        }

        //PRW
        protected void rptSportCategory_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PatternCoreCategoriesViewBO)
            {
                PatternCoreCategoriesViewBO objPatternCoreCategory = (PatternCoreCategoriesViewBO)item.DataItem;

                PriceLevelCostViewBO objPriceLevelCostView = new PriceLevelCostViewBO();
                objPriceLevelCostView.CoreCategory = objPatternCoreCategory.CoreCategory;

                List<PriceLevelCostViewBO> lstPriceLevelCosts = new List<PriceLevelCostViewBO>();
                if (objPatternCoreCategory.ID == null)
                {
                    lstPriceLevelCosts = this.GetFilteredPriceLevelCosts(objPriceLevelCostView.SearchObjects().ToList());
                }
                else
                {
                    CategoryBO objCategory = new CategoryBO();
                    objCategory.ID = objPatternCoreCategory.ID.Value;
                    objCategory.GetObject();

                    var tmpList = (from i in objPriceLevelCostView.SearchObjects()
                                   where i.OtherCategories != null && i.OtherCategories.Split(',').Contains(objCategory.Name)
                                   select i).ToList();

                    lstPriceLevelCosts = this.GetFilteredPriceLevelCosts(tmpList);
                }

                if (lstPriceLevelCosts.Count > 0)
                {
                    HtmlGenericControl h3SportCatogoryName = (HtmlGenericControl)item.FindControl("h3SportCatogoryName");
                    h3SportCatogoryName.InnerHtml = objPatternCoreCategory.Name;
                    h3SportCatogoryName.Visible = true;

                    DataGrid dgSelectedFabrics = (DataGrid)item.FindControl("dgSelectedFabrics");
                    dgSelectedFabrics.DataSource = lstPriceLevelCosts.OrderBy(o => Regex.IsMatch(o.Number, @"^[a-zA-Z]+$") ? o.Number : Convert.ToInt32(Regex.Replace(o.Number, "[^0-9]", string.Empty)).ToString()).ThenBy(o => o.FabricCodeName).ToList();
                    dgSelectedFabrics.DataBind();
                }
            }
        }

        //PBD
        protected void dgSelectedFabrics_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PriceLevelCostViewBO)
            {
                PriceLevelCostViewBO objPriceLevelCostView = (PriceLevelCostViewBO)item.DataItem;

                PriceBO objPrice = new PriceBO();
                objPrice.ID = objPriceLevelCostView.ID.Value;
                objPrice.GetObject();

                this.conversionFactor = objPriceLevelCostView.ConvertionFactor.Value;
                string modifiedDate = string.Empty;

                List<DistributorNullPatternPriceLevelCostViewBO> lstDistributorNullPatternPriceLevelCost = new List<DistributorNullPatternPriceLevelCostViewBO>();
                List<DistributorPatternPriceLevelCostViewBO> lstDistributorPatternPriceLevelCost = new List<DistributorPatternPriceLevelCostViewBO>();

                if (int.Parse(this.ddlDistributors.SelectedValue) == 0) // Platinum
                {
                    DistributorNullPatternPriceLevelCostViewBO objDistributorNullPatternPriceLevelCostView = new DistributorNullPatternPriceLevelCostViewBO();
                    objDistributorNullPatternPriceLevelCostView.Price = objPriceLevelCostView.ID.Value;

                    lstDistributorNullPatternPriceLevelCost = objDistributorNullPatternPriceLevelCostView.SearchObjects().ToList();
                }
                else
                {
                    DistributorPatternPriceLevelCostViewBO objDistributorPatternPriceLevelCostView = new DistributorPatternPriceLevelCostViewBO();
                    objDistributorPatternPriceLevelCostView.Price = objPriceLevelCostView.ID.Value;

                    objDistributorPatternPriceLevelCostView.Distributor = int.Parse(this.ddlDistributors.SelectedValue);
                    lstDistributorPatternPriceLevelCost = objDistributorPatternPriceLevelCostView.SearchObjects().ToList();
                }

                CheckBox checkEnablePriceList = (CheckBox)item.FindControl("checkEnablePriceList");
                checkEnablePriceList.Attributes.Add("pid", objPrice.ID.ToString());
                if (objPrice.EnableForPriceList == true)
                {
                    checkEnablePriceList.Checked = true;
                }
                else
                {
                    checkEnablePriceList.Checked = false;
                }

                Literal litOtherCategories = (Literal)item.FindControl("litOtherCategories");
                if (objPriceLevelCostView.OtherCategories != null)
                {
                    litOtherCategories.Text = objPriceLevelCostView.OtherCategories.Remove(objPriceLevelCostView.OtherCategories.LastIndexOf(','));
                }
                Literal litPatternNo = (Literal)item.FindControl("litPatternNo");
                litPatternNo.Text = objPriceLevelCostView.Number;

                Literal litItemSubCategory = (Literal)item.FindControl("litItemSubCategory");
                litItemSubCategory.Text = objPriceLevelCostView.ItemSubCategory;

                Literal litDescription = (Literal)item.FindControl("litDescription");
                litDescription.Text = objPriceLevelCostView.NickName;

                Literal litfabric = (Literal)item.FindControl("litfabric");
                litfabric.Text = objPriceLevelCostView.FabricCodeName;

                HyperLink linkAddEditNote = (HyperLink)item.FindControl("linkAddEditNote");
                linkAddEditNote.Attributes.Add("PriceID", objPriceLevelCostView.ID.Value.ToString());

                PriceRemarksBO objPriceRemarks = new PriceRemarksBO();
                objPriceRemarks.Price = objPriceLevelCostView.ID.Value;
                List<PriceRemarksBO> lstPriceRemarks = objPriceRemarks.SearchObjects().ToList();

                if (lstPriceRemarks.Count > 0)
                {
                    LinkButton btnViewNote = (LinkButton)item.FindControl("btnViewNote");
                    btnViewNote.Visible = true;
                    btnViewNote.Attributes.Add("pid", objPriceLevelCostView.ID.Value.ToString());
                }


                modifiedDate = (int.Parse(this.ddlDistributors.SelectedValue) == 0)
                                ? lstDistributorNullPatternPriceLevelCost.Max(o => (o.ModifiedDate != null) ? o.ModifiedDate : string.Empty)
                                : lstDistributorPatternPriceLevelCost.Max(o => (o.ModifiedDate != null) ? o.ModifiedDate : string.Empty);

                Literal litModifiedDate = (Literal)item.FindControl("litModifiedDate");
                if (!String.IsNullOrEmpty(modifiedDate))
                {
                    litModifiedDate.Text = modifiedDate;
                }
                else
                {
                    litModifiedDate.Visible = false;
                }

                //Literal litSetCost = (Literal)item.FindControl("litSetCost");
                //litSetCost.Text = "Set cost for all levels";

                //decimal indimanCost = objPrice.PriceLevelCostsWhereThisIsPrice.Select(o => o.IndimanCost).Aggregate((x, y) => x + y);
                //decimal indimanCost = lstPriceLevelCosts.Select(o => o.IndimanCost).Aggregate((x, y) => x + y);
                //isEnableIndicoCost = (indimanCost > 0);

                //litSetCost.Visible = isEnableIndicoCost;
                //txtSetCost.Visible = isEnableIndicoCost;
                //btnApply.Visible = isEnableIndicoCost;
                //btnUpdate.Visible = isEnableIndicoCost;

                //PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO();
                //objPriceLevelCost.Price = objPriceLevelCostView.ID.Value;
                //List<PriceLevelCostBO> lstPriceLevelCosts = objPriceLevelCost.SearchObjects().ToList();

                Repeater rptPriceLevelCost = (Repeater)item.FindControl("rptPriceLevelCost");

                if (int.Parse(this.ddlDistributors.SelectedValue) == 0)
                    rptPriceLevelCost.DataSource = lstDistributorNullPatternPriceLevelCost;
                else
                    rptPriceLevelCost.DataSource = lstDistributorPatternPriceLevelCost;

                rptPriceLevelCost.DataBind();
            }
        }

        protected void rptPriceLevelCost_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is DistributorPatternPriceLevelCostViewBO)
            {
                DistributorPatternPriceLevelCostViewBO objPriceLevelCost = (DistributorPatternPriceLevelCostViewBO)item.DataItem;

                PriceLevelBO objPriceLevel = new PriceLevelBO(this.ObjContext);
                objPriceLevel.ID = objPriceLevelCost.PriceLevel.Value;
                objPriceLevel.GetObject();

                Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
                litCellHeader.Text = objPriceLevel.Name + "<em>( " + objPriceLevel.Volume + " )</em>";

                PatternBO objPattern = new PatternBO();

                //int distributor = int.Parse(this.ddlDistributors.SelectedValue);
                //DistributorPriceMarkupBO objPriceMarkup = objPriceLevelCost.objPriceLevel.DistributorPriceMarkupsWhereThisIsPriceLevel.SingleOrDefault(o => (int)o.Distributor == distributor);                
                //DistributorPriceLevelCostBO obj = new DistributorPriceLevelCostBO();
                //obj.PriceLevelCost = objPriceLevelCost.ID;
                //List<DistributorPriceLevelCostBO> lstDistributorPriceLevelCosts = (from o in obj.SearchObjects() where o.Distributor == distributor select o).ToList();

                //decimal convertion = objPriceLevelCost.objPrice.objPattern.ConvertionFactor;
                //decimal indimanPrice = (objPriceLevelCost.IndimanCost == 0) ? 0 : Math.Round(Convert.ToDecimal(objPriceLevelCost.IndimanCost + ((objPriceLevelCost.IndimanCost / 100) * objPriceMarkup.Markup)), 2);
                decimal indicoCIFMarkup = (objPriceLevelCost.EditedCIFPrice != null) ? Math.Round(100 - ((objPriceLevelCost.IndimanCost.Value * 100) / objPriceLevelCost.EditedCIFPrice.Value), 2) : objPriceLevelCost.Markup.Value;
                decimal indicoFOBMarkup = (objPriceLevelCost.EditedFOBPrice != null) ? Math.Round(100 - (((objPriceLevelCost.IndimanCost.Value - this.conversionFactor) * 100) / objPriceLevelCost.EditedFOBPrice.Value), 2) : objPriceLevelCost.Markup.Value;

                decimal calculatedIndimanCIFPrice = (objPriceLevelCost.IndimanCost != 0) ? Decimal.Round((objPriceLevelCost.IndimanCost.Value * 100) / (100 - objPriceLevelCost.Markup.Value), 2, MidpointRounding.AwayFromZero) : 0;
                decimal calculatedIndimanFOBPrice = (objPriceLevelCost.IndimanCost != 0) ? Decimal.Round(((objPriceLevelCost.IndimanCost.Value - this.conversionFactor) * 100) / (100 - objPriceLevelCost.Markup.Value), 2, MidpointRounding.AwayFromZero) : 0;
                decimal calIndimanFOBPrice = (objPriceLevelCost.IndimanCost != 0) ? Math.Round(((objPriceLevelCost.IndimanCost.Value - this.conversionFactor)) / (1 - (indicoCIFMarkup / 100)), 2) : 0;
                //decimal indicoCIFMarkup = (objPriceLevelCost.EditedCIFPrice != null) ? Math.Round(Convert.ToDecimal(((objPriceLevelCost.EditedCIFPrice.Value - objPriceLevelCost.IndimanCost.Value) * 100) / objPriceLevelCost.IndimanCost), 2) : objPriceLevelCost.Markup.Value;
                //decimal indicoFOBMarkup = (objPriceLevelCost.EditedCIFPrice != null) ? Math.Round(Convert.ToDecimal(((objPriceLevelCost.EditedCIFPrice.Value - (objPriceLevelCost.IndimanCost.Value - this.conversionFactor)) * 100) / objPriceLevelCost.IndimanCost), 2) : objPriceLevelCost.Markup.Value;


                //**SDS decimal calculatedFOBMarkup = (objPriceLevelCost.IndimanCost != 0) ? Math.Round(100 - ((objPriceLevelCost.IndimanCost.Value * 100) / calculatedIndimanFOBPrice), 2) : 0;

                //decimal calculatedCIFMarkup = Math.Round(100 - ((objPriceLevelCost.IndimanCost.Value * 100) / calculatedIndimanCIFPrice), 2);


                //HiddenField hdnCellID = (HiddenField)item.FindControl("hdnCellID");
                //hdnCellID.Value = objPriceLevelCost.ID.Value.ToString(); //(lstDistributorPriceLevelCosts.Count == 0) ? "0" : lstDistributorPriceLevelCosts[0].ID.ToString();

                decimal indimanCIFPrice = (this.hdnTerm.Value == "1") ? calculatedIndimanCIFPrice : calculatedIndimanFOBPrice;
                decimal indicoCIFPrice = (this.hdnTerm.Value == "1")
                                         ? (objPriceLevelCost.EditedCIFPrice != null) ? objPriceLevelCost.EditedCIFPrice.Value : calculatedIndimanCIFPrice
                                         : (objPriceLevelCost.EditedFOBPrice != null && objPriceLevelCost.EditedFOBPrice.Value > 0) ? objPriceLevelCost.EditedFOBPrice.Value : calIndimanFOBPrice;


                TextBox txtEditedIndicoCIFPrice = (TextBox)item.FindControl("txtEditedIndicoCIFPrice");
                txtEditedIndicoCIFPrice.Text = indicoCIFPrice.ToString("0.00");
                txtEditedIndicoCIFPrice.CssClass = (indimanCIFPrice != indicoCIFPrice) ? "idouble idiff" : "idouble";
                txtEditedIndicoCIFPrice.Attributes.Add("levelcost", objPriceLevelCost.ID.Value.ToString());
                txtEditedIndicoCIFPrice.Attributes.Add("IndimanCost", objPriceLevelCost.IndimanCost.Value.ToString());
                txtEditedIndicoCIFPrice.Attributes.Add("cf", this.conversionFactor.ToString());
                //txtEditedIndicoCIFPrice.Attributes.Add("termCif", txtEditedIndicoCIFPrice.Text);
                //txtEditedIndicoCIFPrice.Attributes.Add("termFob", (objPriceLevelCost.EditedFOBPrice != null) ? objPriceLevelCost.EditedFOBPrice.Value.ToString("0.00") : calculatedIndimanFOBPrice.ToString("0.00"));                

                Label lblEditedIndicoCIFMarkup = (Label)item.FindControl("lblEditedIndicoCIFMarkup");
                lblEditedIndicoCIFMarkup.Text = (this.hdnTerm.Value == "1") ? indicoCIFMarkup.ToString("0.00") + "%" : (objPriceLevelCost.EditedFOBPrice != null && objPriceLevelCost.EditedFOBPrice.Value > 0) ? indicoFOBMarkup.ToString("0.00") + "%" : indicoCIFMarkup.ToString("0.00") + "%";
                //lblEditedIndicoCIFMarkup.Attributes.Add("cifMarkup", indicoCIFMarkup.ToString() + "%");
                //lblEditedIndicoCIFMarkup.Attributes.Add("fobMarkup", indicoFOBMarkup.ToString() + "%");

                Label lblCalculatedIndimanCIFPrice = (Label)item.FindControl("lblCalculatedIndimanCIFPrice");
                lblCalculatedIndimanCIFPrice.Text = "$" + indimanCIFPrice.ToString("0.00");
                //lblCalculatedIndimanCIFPrice.Attributes.Add("cifPrice", "$" + calculatedIndimanCIFPrice.ToString("0.00"));
                //lblCalculatedIndimanCIFPrice.Attributes.Add("fobPrice", "$" + calculatedIndimanFOBPrice.ToString("0.00"));

                Label lblCalculatedIndimanCIFMarkup = (Label)item.FindControl("lblCalculatedIndimanCIFMarkup");
                //** SDS lblCalculatedIndimanCIFMarkup.Text = (this.hdnTerm.Value == "1") ? objPriceLevelCost.Markup.Value.ToString() + "%" : calculatedFOBMarkup.ToString() + "%";
                lblCalculatedIndimanCIFMarkup.Text = objPriceLevelCost.Markup.Value.ToString() + "%";

                //Label lblIndicoFOBPrice = (Label)item.FindControl("lblIndicoFOBPrice");
                //lblIndicoFOBPrice.Text = indicoFOBPrice.ToString("0.00");

                //Label lblIndicoFOBMarkup = (Label)item.FindControl("lblIndicoFOBMarkup");
                //lblIndicoFOBMarkup.Text = indicoFOBMarkup.ToString() + "%";


                //Label lblIndimanFOBPrice = (Label)item.FindControl("lblIndimanFOBPrice");
                //lblIndimanFOBPrice.Text = "$" + (indicoCIFPrice - convertion).ToString("0.00");

                //Label lblIndimanFOBMarkup = (Label)item.FindControl("lblIndimanFOBMarkup");
                //lblIndimanFOBMarkup.Text = objPriceMarkup.Markup.ToString() + "%";

                PriceBO objPrice = new PriceBO();
                objPrice.ID = objPriceLevelCost.Price.Value;
                objPrice.GetObject();

                decimal conversionFactor = objPrice.objPattern.ConvertionFactor;
                string IndimanPrice = (this.hdnTerm.Value == "1") ? objPriceLevelCost.IndimanCost.Value.ToString("0.00") : (objPriceLevelCost.IndimanCost.Value - conversionFactor).ToString("0.00");

                Label lblIndimanPrice = (Label)item.FindControl("lblIndimanPrice");
                lblIndimanPrice.Text = IndimanPrice;
            }
            else if (item.ItemIndex > -1 && item.DataItem is DistributorNullPatternPriceLevelCostViewBO)
            {
                DistributorNullPatternPriceLevelCostViewBO objPriceLevelCost = (DistributorNullPatternPriceLevelCostViewBO)item.DataItem;

                PriceLevelBO objPriceLevel = new PriceLevelBO(this.ObjContext);
                objPriceLevel.ID = objPriceLevelCost.PriceLevel.Value;
                objPriceLevel.GetObject();

                Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
                litCellHeader.Text = objPriceLevel.Name + "<em>( " + objPriceLevel.Volume + " )</em>";

                //int distributor = int.Parse(this.ddlDistributors.SelectedValue);
                //DistributorPriceMarkupBO objPriceMarkup = objPriceLevelCost.objPriceLevel.DistributorPriceMarkupsWhereThisIsPriceLevel.SingleOrDefault(o => (int)o.Distributor == distributor);                
                //DistributorPriceLevelCostBO obj = new DistributorPriceLevelCostBO();
                //obj.PriceLevelCost = objPriceLevelCost.ID;
                //List<DistributorPriceLevelCostBO> lstDistributorPriceLevelCosts = (from o in obj.SearchObjects() where o.Distributor == distributor select o).ToList();

                //decimal convertion = objPriceLevelCost.objPrice.objPattern.ConvertionFactor;
                //decimal indimanPrice = (objPriceLevelCost.IndimanCost == 0) ? 0 : Math.Round(Convert.ToDecimal(objPriceLevelCost.IndimanCost + ((objPriceLevelCost.IndimanCost / 100) * objPriceMarkup.Markup)), 2);

                decimal indicoCIFMarkup = (objPriceLevelCost.EditedCIFPrice != null && objPriceLevelCost.EditedCIFPrice != 0) ? Math.Round(100 - ((objPriceLevelCost.IndimanCost.Value * 100) / objPriceLevelCost.EditedCIFPrice.Value), 2) : objPriceLevelCost.Markup.Value;
                decimal indicoFOBMarkup = (objPriceLevelCost.EditedFOBPrice != null) ? Math.Round(100 - (((objPriceLevelCost.IndimanCost.Value - this.conversionFactor) * 100) / objPriceLevelCost.EditedFOBPrice.Value), 2) : objPriceLevelCost.Markup.Value;

                decimal calculatedIndimanCIFPrice = (objPriceLevelCost.IndimanCost != 0) ? Math.Round((objPriceLevelCost.IndimanCost.Value * 100) / (100 - objPriceLevelCost.Markup.Value), 2) : 0;
                decimal calculatedIndimanFOBPrice = (objPriceLevelCost.IndimanCost != 0) ? Math.Round(((objPriceLevelCost.IndimanCost.Value - this.conversionFactor) * 100) / (100 - objPriceLevelCost.Markup.Value), 2) : 0;
                decimal calIndimanFOBPrice = (objPriceLevelCost.IndimanCost != 0) ? Math.Round(((objPriceLevelCost.IndimanCost.Value - this.conversionFactor)) / (1 - (indicoCIFMarkup / 100)), 2) : 0;

                //decimal calculatedFOBMarkup = (objPriceLevelCost.IndimanCost != 0) ? Math.Round(100 - ((objPriceLevelCost.IndimanCost.Value * 100) / calculatedIndimanFOBPrice), 2) : 0;
                //decimal calculatedCIFMarkup = Math.Round(100 - ((objPriceLevelCost.IndimanCost.Value * 100) / calculatedIndimanCIFPrice), 2);

                //HiddenField hdnCellID = (HiddenField)item.FindControl("hdnCellID");
                //hdnCellID.Value = objPriceLevelCost.ID.Value.ToString(); ;//(lstDistributorPriceLevelCosts.Count == 0) ? "0" : lstDistributorPriceLevelCosts[0].ID.ToString();

                decimal indimanCIFPrice = (this.hdnTerm.Value == "1") ? calculatedIndimanCIFPrice : calculatedIndimanFOBPrice;
                decimal indicoCIFPrice = (this.hdnTerm.Value == "1")
                                         ? (objPriceLevelCost.EditedCIFPrice != null) ? objPriceLevelCost.EditedCIFPrice.Value : calculatedIndimanCIFPrice
                                         : (objPriceLevelCost.EditedFOBPrice != null && objPriceLevelCost.EditedFOBPrice.Value > 0) ? objPriceLevelCost.EditedFOBPrice.Value : calIndimanFOBPrice;


                TextBox txtEditedIndicoCIFPrice = (TextBox)item.FindControl("txtEditedIndicoCIFPrice");
                txtEditedIndicoCIFPrice.Text = indicoCIFPrice.ToString("0.00");
                txtEditedIndicoCIFPrice.CssClass = (indimanCIFPrice != indicoCIFPrice) ? "idouble idiff" : "idouble";
                txtEditedIndicoCIFPrice.Attributes.Add("levelcost", objPriceLevelCost.ID.Value.ToString());
                txtEditedIndicoCIFPrice.Attributes.Add("IndimanCost", objPriceLevelCost.IndimanCost.Value.ToString());
                txtEditedIndicoCIFPrice.Attributes.Add("cf", this.conversionFactor.ToString());
                //txtEditedIndicoCIFPrice.Attributes.Add("termCif", txtEditedIndicoCIFPrice.Text);
                //txtEditedIndicoCIFPrice.Attributes.Add("termFob", (objPriceLevelCost.EditedFOBPrice != null) ? objPriceLevelCost.EditedFOBPrice.Value.ToString("0.00") : calculatedIndimanFOBPrice.ToString("0.00"));                

                Label lblEditedIndicoCIFMarkup = (Label)item.FindControl("lblEditedIndicoCIFMarkup");
                lblEditedIndicoCIFMarkup.Text = (this.hdnTerm.Value == "1") ? indicoCIFMarkup.ToString("0.00") + "%" : (objPriceLevelCost.EditedFOBPrice != null && objPriceLevelCost.EditedFOBPrice.Value > 0) ? indicoFOBMarkup.ToString("0.00") + "%" : indicoCIFMarkup.ToString("0.00") + "%";
                //lblEditedIndicoCIFMarkup.Attributes.Add("cifMarkup", indicoCIFMarkup.ToString() + "%");
                //lblEditedIndicoCIFMarkup.Attributes.Add("fobMarkup", indicoFOBMarkup.ToString() + "%");

                Label lblCalculatedIndimanCIFPrice = (Label)item.FindControl("lblCalculatedIndimanCIFPrice");
                lblCalculatedIndimanCIFPrice.Text = "$" + indimanCIFPrice.ToString("0.00");
                //lblCalculatedIndimanCIFPrice.Attributes.Add("cifPrice", "$" + calculatedIndimanCIFPrice.ToString("0.00"));
                //lblCalculatedIndimanCIFPrice.Attributes.Add("fobPrice", "$" + calculatedIndimanFOBPrice.ToString("0.00"));

                Label lblCalculatedIndimanCIFMarkup = (Label)item.FindControl("lblCalculatedIndimanCIFMarkup");
                lblCalculatedIndimanCIFMarkup.Text = objPriceLevelCost.Markup.Value.ToString() + "%"; //**SDS(this.hdnTerm.Value == "1") ? objPriceLevelCost.Markup.Value.ToString() + "%" : calculatedFOBMarkup.ToString() + "%";

                //Label lblIndicoFOBPrice = (Label)item.FindControl("lblIndicoFOBPrice");
                //lblIndicoFOBPrice.Text = indicoFOBPrice.ToString("0.00");

                //Label lblIndicoFOBMarkup = (Label)item.FindControl("lblIndicoFOBMarkup");
                //lblIndicoFOBMarkup.Text = indicoFOBMarkup.ToString() + "%";


                //Label lblIndimanFOBPrice = (Label)item.FindControl("lblIndimanFOBPrice");
                //lblIndimanFOBPrice.Text = "$" + (indicoCIFPrice - convertion).ToString("0.00");

                //Label lblIndimanFOBMarkup = (Label)item.FindControl("lblIndimanFOBMarkup");
                //lblIndimanFOBMarkup.Text = objPriceMarkup.Markup.ToString() + "%";

                PriceBO objPrice = new PriceBO();
                objPrice.ID = objPriceLevelCost.Price.Value;
                objPrice.GetObject();

                decimal conversionFactor = objPrice.objPattern.ConvertionFactor;
                string IndimanPrice = (this.hdnTerm.Value == "1") ? objPriceLevelCost.IndimanCost.Value.ToString("0.00") : (objPriceLevelCost.IndimanCost.Value - conversionFactor).ToString("0.00");

                Label lblIndimanPrice = (Label)item.FindControl("lblIndimanPrice");
                lblIndimanPrice.Text = IndimanPrice;
            }
        }

        protected void checkPrice_Check(object sender, EventArgs e)
        {
            if (rbCifPrice.Checked)
            {
                this.hdnTerm.Value = "1";
            }
            else if (rbFobPrice.Checked)
            {
                this.hdnTerm.Value = "2";

            }
            errorMessage = string.Empty;
            this.PopulatePriceLevelCosts();
            //this.rbFobPrice.Checked = true;
        }

        protected void btnSearchByPatternNumber_Click(object sender, EventArgs e)
        {
            bool isSelected = false;
            foreach (ListItem item in this.lstOtherCategories.Items)
            {
                if (item.Selected)
                {
                    isSelected = true;
                    break;
                }
            }

            if (isSelected == true)
            {
                this.dvEmptyContent.Visible = false;
                errorMessage = string.Empty;
                this.PopulatePriceLevelCosts();
            }
            else
            {
                PriceLevelCostViewBO objPriceLevelCostView = new PriceLevelCostViewBO();
                List<int> lstCategories = new List<int>();

                if (!string.IsNullOrEmpty(this.txtSerchPatternNumber.Text))
                {
                    lstCategories = (from o in objPriceLevelCostView.SearchObjects().Where(o => o.Number.ToLower() == this.txtSerchPatternNumber.Text.ToLower())
                                     select o.CoreCategory.Value).ToList();

                }

                if (lstCategories.Count > 0)
                {
                    foreach (ListItem item in lstOtherCategories.Items)
                    {
                        if (lstCategories.Contains(int.Parse(item.Value)))
                        {
                            this.lstOtherCategories.Items.FindByValue(item.Value).Selected = true;
                        }
                    }
                    errorMessage = string.Empty;
                }
                else
                {
                    this.dvEmptyContent.Visible = true;
                    errorMessage = "Invalid pattern number.";
                }
                this.hdnSelectPattern.Value = this.txtSerchPatternNumber.Text.ToLower();
                this.PopulatePriceLevelCosts();
            }

            ViewState["PopulatePaternSearch"] = false;
            ViewState["populatePresentage"] = false;
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            Response.Redirect("/EditIndicoPrice.aspx");
        }

        protected void btnDeleteIndicoPriceRemarks_Click(object sender, EventArgs e)
        {
            int id = int.Parse(this.hdnIndicoPriceRemarks.Value);
            if (this.IsNotRefresh)
            {
                if (id > 0)
                {
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            PriceRemarksBO objPriceRemarks = new PriceRemarksBO(this.ObjContext);
                            objPriceRemarks.ID = id;
                            objPriceRemarks.GetObject();

                            objPriceRemarks.Delete();

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }

                        this.PopulatePriceLevelCosts();
                        ViewState["PopulateViewNote"] = false;
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while deleting price remarks note(btnDeleteIndicoPriceRemarks_Click())", ex);
                    }
                }
                // Session["IsRefresh"] = Server.UrlEncode(System.DateTime.Now.ToString());
            }
        }

        protected void btnImportExcel_Click(object sender, EventArgs e)
        {
            string filePath = this.hdnUploadFiles.Value.Split(',')[0];

            if (this.IsNotRefresh)
            {
                if (!string.IsNullOrEmpty(filePath))
                {
                    string newDirectory = string.Empty;
                    FileInfo tetmlFile = null;

                    tetmlFile = new FileInfo(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + filePath);

                    while (this.IsFileLocked(tetmlFile))
                    {
                        Thread.Sleep(100);
                    }
                    if (File.Exists(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + filePath))
                    {
                        newDirectory = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\PriceLists\\Import\\" + Guid.NewGuid();

                        if (!Directory.Exists(newDirectory))
                        {
                            Directory.CreateDirectory(newDirectory);
                        }

                        string newFilePath = newDirectory + "\\" + filePath;

                        File.Copy(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + filePath, newFilePath);

                        // bool isnotExistsnewFilePath = true;

                        tetmlFile = new FileInfo(newFilePath);
                        while (this.IsFileLocked(tetmlFile))
                        {
                            Thread.Sleep(100);
                        }

                        Thread thImportExcle = new Thread(new ThreadStart(() => ReadExcelData(newFilePath, newDirectory)));
                        thImportExcle.IsBackground = true;
                        thImportExcle.Start();

                        /*while (isnotExistsnewFilePath)
                        {
                            File.Exists(newFilePath);
                            {
                                isnotExistsnewFilePath = false;

                                Thread thImportExcle = new Thread(new ThreadStart(() => ReadExcelData(newFilePath, newDirectory)));
                                thImportExcle.IsBackground = true;
                                thImportExcle.Start();

                                break;
                            }
                        }*/
                    }

                    ViewState["populateImportExcel"] = false;
                }
            }
            else
            {
                ViewState["populateImportExcel"] = false;
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
            this.dvEmptyContent.Visible = false;

            this.linkExcel.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;

            // Hide the certain controls and probably we need to show in the future SDS
            this.dvHide.Visible = false;

            //Populate Core Category & other categiries
            this.lstOtherCategories.Items.Clear();
            List<CategoryBO> lstCategories = (new CategoryBO()).GetAllObject();
            foreach (CategoryBO category in lstCategories.OrderBy(o => o.Name))
            {
                this.lstOtherCategories.Items.Add(new ListItem(category.Name, category.ID.ToString()));
            }

            // Populate Distributor
            this.ddlDistributors.Items.Add(new ListItem("PLATINUM", "0"));
            List<int> lstDistributoridsExcel = (new DistributorPriceMarkupBO()).SearchObjects().Where(o => o.Distributor != 0 && o.objDistributor.IsActive == true && o.objDistributor.IsDelete == false).Select(m => (int)m.Distributor).Distinct().ToList();
            foreach (int id in lstDistributoridsExcel)
            {
                CompanyBO objCompany = new CompanyBO();
                objCompany.ID = id;
                objCompany.GetObject();
                this.ddlDistributors.Items.Add(new ListItem(objCompany.Name, objCompany.ID.ToString()));
            }

            //Populate Fabric Name
            this.ddlFabricName.Items.Add(new ListItem("Select Fabric Name", "0"));
            List<FabricCodeBO> lstFabricCode = (new FabricCodeBO()).GetAllObject();
            foreach (FabricCodeBO fabricName in lstFabricCode.OrderBy(o => o.Name))
            {
                this.ddlFabricName.Items.Add(new ListItem(fabricName.Name, fabricName.ID.ToString()));
            }

            if (this.QueryPatternID != string.Empty)
            {
                /*this.hdnSelectPattern.Value = this.QueryPatternID.ToString();

                PatternBO objPattern = new PatternBO();
                objPattern.ID = this.QueryPatternID;
                objPattern.GetObject();

                this.txtPattern.Text = objPattern.Number.Trim() + " - " + objPattern.NickName.Trim();
                this.txtPatternNickName.Text = objPattern.NickName;
                */
                //this.PopulatePriceLevelCosts();

                this.txtSearchAny.Text = this.QueryPatternID.ToString();
                // this.PopulatePriceLevelCosts();

                this.btnSearchByCategory_Click(null, null);
            }
            // To Get Progress
            this.hdnUserID.Value = this.LoggedUser.ID.ToString();

            // Page Refresh
            Session["IsRefresh"] = Server.UrlEncode(System.DateTime.Now.ToString());

            // Set default values
            ViewState["IsPageValied"] = true;
            ViewState["PopulatePatern"] = false;
            ViewState["PopulatePaternSearch"] = false;
            ViewState["populateDownloadExcel"] = false;
            ViewState["PopulateAddEditNote"] = false;
            ViewState["populatePresentage"] = false;
            ViewState["PopulateViewNote"] = false;
        }

        /*private void PopulatePattern()
        {
            if (this.ActivePattern.ID > 0)
            {
                // Populate pattern data
                this.txtPattern.Text = this.ActivePattern.Number.Trim() + " - " + this.ActivePattern.NickName.Trim();
                this.txtPatternNickName.Text = this.ActivePattern.NickName;
                // this.txtFabricCode.Text = this.ActivePattern.PricesWhereThisIsPattern[0].objFabricCode.Name;
                //this.txtConvertionFactor.Text = this.ActivePattern.ConvertionFactor.ToString();
                //this.txtRemarks.Text = (this.ActivePattern.PriceRemarks != null) ? this.ActivePattern.PriceRemarks.ToString() : string.Empty;
                //this.linkViewPattern.Visible = true;
                //this.btnViewPattern.Visible = true;
                //this.btnViewSpecification.Visible = true;
                this.ddlDistributors.Enabled = true;

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

                //Populate Distributor Excel
                string distributor = this.ddlDistributors.SelectedValue;
                this.ddlDistributorsExcel.SelectedValue = distributor;

                ViewState["PopulateAddEditNote"] = false;
                ViewState["PopulatePatern"] = true;

                this.PopulateSpec();

                // Set active pattern core category
                //this.litCoreCatogoryName.Text = this.ActivePattern.objCoreCategory.Name;

                // Populate active pattern fabrics
                //this.PopulatePatternFabrics();
            }
        }*/

        /*private void PopulateSpec()
        {
            List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = (this.ActivePattern.SizeChartsWhereThisIsPattern).OrderBy(o => o.MeasurementLocation).GroupBy(o => o.MeasurementLocation).ToList();
            if (lstSizeChartGroup.Count > 0)
            {
                this.rptSpecSizeQtyHeader.DataSource = (List<SizeChartBO>)lstSizeChartGroup[0].ToList();
                this.rptSpecSizeQtyHeader.DataBind();

                this.rptSpecML.DataSource = lstSizeChartGroup;
                this.rptSpecML.DataBind();
            }

            this.btnViewSpecification.Visible = (lstSizeChartGroup.Count > 0);
        }*/

        private void PopulatePatternFabrics()
        {

            //this.dgSelectedFabrics.DataSource = this.FabricCodesWhereThisIsPattern;
            //this.dgSelectedFabrics.DataBind();

            //this.dgSelectedFabrics.Visible = (this.FabricCodesWhereThisIsPattern.Count > 0);
            //this.dvEmptyContent.Visible = !(this.dgSelectedFabrics.Visible);
        }

        //PRW
        private void PopulatePriceLevelCosts()
        {
            List<int> lstCategories = new List<int>();
            foreach (ListItem item in lstOtherCategories.Items)
            {
                if (item.Selected)
                {
                    lstCategories.Add(int.Parse(item.Value));
                }
            }

            PatternCoreCategoriesViewBO objPatternCoreCategories = new PatternCoreCategoriesViewBO();
            List<PatternCoreCategoriesViewBO> lstPatternCoreCategories = new List<PatternCoreCategoriesViewBO>();

            foreach (int category in lstCategories)
            {
                CategoryBO objCategory = new CategoryBO();
                objCategory.ID = category;
                objCategory.GetObject();

                PatternCoreCategoriesViewBO objPCCTmp = new PatternCoreCategoriesViewBO();
                objPCCTmp.CoreCategory = objCategory.ID;
                //objPCCTmp.ID = objCategory.ID;
                objPCCTmp.Name = objCategory.Name;

                lstPatternCoreCategories.Add(objPCCTmp);
            }

            /* SDS */
            List<PatternCoreCategoriesViewBO> lstTmp = new List<PatternCoreCategoriesViewBO>();
            lstTmp = objPatternCoreCategories.SearchObjects().Where(o => lstCategories.Contains(o.ID.Value)).ToList();

            if (lstTmp != null && lstTmp.Count > 0)
            {
                foreach (PatternCoreCategoriesViewBO item in lstTmp)
                {
                    if ((from o in lstPatternCoreCategories where o.CoreCategory == item.CoreCategory select o).Count() == 0)
                    {
                        lstPatternCoreCategories.Add(item);
                    }
                }
            }

            bool isEmpty = true;
            foreach (PatternCoreCategoriesViewBO item in lstPatternCoreCategories)
            {
                PriceLevelCostViewBO objPriceLevelCostView = new PriceLevelCostViewBO();
                objPriceLevelCostView.CoreCategory = item.CoreCategory;

                List<PriceLevelCostViewBO> lstPriceLevelCosts = this.GetFilteredPriceLevelCosts(objPriceLevelCostView.SearchObjects().ToList());
                if (lstPriceLevelCosts != null && lstPriceLevelCosts.Count > 0)
                {
                    isEmpty = false;
                    break;
                }
            }

            if (!isEmpty)
            {
                this.dvFormActions.Visible = (lstPatternCoreCategories.Count > 0);
                this.rptSportCategory.Visible = (lstPatternCoreCategories.Count > 0);
                this.dvEmptyContent.Visible = (lstPatternCoreCategories.Count == 0);

                //this.PopulateSpec();

                this.rptSportCategory.DataSource = lstPatternCoreCategories;
                this.rptSportCategory.DataBind();
            }
            else
            {
                this.rptSportCategory.DataSource = null;
                this.rptSportCategory.DataBind();

                this.dvEmptyContent.Visible = true;
                this.lblEmptyMessage.Text = (errorMessage != string.Empty) ? errorMessage : "No prices found";
                this.dvFormActions.Visible = false;
                this.rptSportCategory.Visible = false;
            }

            //if (this.SelectedPattern == 0)
            //{
            //    this.hdnConvertionFactor.Value = string.Empty;
            //    this.btnViewPattern.Visible = false;
            //    this.btnViewSpecification.Visible = false;
            //}

            this.dvSelectedCategories.Visible = true;
            ViewState["PopulatePatern"] = false;
            ViewState["PopulateAddEditNote"] = false;
        }

        private List<PriceLevelCostViewBO> GetFilteredPriceLevelCosts(List<PriceLevelCostViewBO> priceLevelCosts)
        {
            if (this.hdnSelectPattern.Value.ToString().Trim() != string.Empty && this.hdnSelectPattern.Value != "0")
            {
                //int pattern = int.Parse(this.hdnSelectPattern.Value.ToString());
                //priceLevelCosts = priceLevelCosts.Where(o => o.Pattern.Value == pattern).ToList();

                string patternNumber = this.hdnSelectPattern.Value.ToString().Trim().ToLower();
                priceLevelCosts = priceLevelCosts.Where(o => o.Number.ToLower() == patternNumber).ToList();
            }
            else
            {
                if (!string.IsNullOrEmpty(this.txtSearchAny.Text)) //Search Any
                {
                    string s = this.txtSearchAny.Text.Trim().ToLower();
                    priceLevelCosts = priceLevelCosts.Where(o => o.Number.ToLower().Contains(s) || o.NickName.ToLower().Contains(s)).ToList();
                }
                else if (!string.IsNullOrEmpty(this.txtSerchPatternNumber.Text))//Search Pattern Number
                {
                    priceLevelCosts = priceLevelCosts.Where(o => o.Number == this.txtSerchPatternNumber.Text.Trim().ToLower()).ToList();
                    if (priceLevelCosts.Count == 0)
                    {
                        // this.dvEmptyContent.Visible = true;
                        // this.lblEmptyMessage.Text = "No prices found this pattern number";
                    }
                }

                else
                {
                    string pn = (!String.IsNullOrEmpty(this.txtPattern.Text) ? this.txtPattern.Text.Trim().ToLower() : string.Empty);
                    string des = (!String.IsNullOrEmpty(this.txtPatternNickName.Text) ? this.txtPatternNickName.Text.Trim().ToLower() : string.Empty);
                    int fabric = int.Parse(this.ddlFabricName.SelectedValue);

                    if (!string.IsNullOrEmpty(pn) && !string.IsNullOrEmpty(des))
                        priceLevelCosts = priceLevelCosts.Where(o => o.Number.ToLower().Contains(pn) || o.NickName.ToLower().Contains(des) || o.FabricCode.Value == fabric).ToList();
                    else if (!string.IsNullOrEmpty(pn))
                        priceLevelCosts = priceLevelCosts.Where(o => o.Number.ToLower().Contains(pn) || o.FabricCode.Value == fabric).ToList();
                    else if (!string.IsNullOrEmpty(des))
                        priceLevelCosts = priceLevelCosts.Where(o => o.NickName.ToLower().Contains(des) || o.FabricCode.Value == fabric).ToList();
                    else
                        return priceLevelCosts;
                }
            }

            return priceLevelCosts.Where(o => o.EnableForPriceList == true).ToList();
        }

        /*private void PopulateDataGridPatterns()
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
                                     o.Number.ToLower().Contains(searchText) ||
                                     o.NickName.ToLower().Contains(searchText)
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
        }*/

        /// <summary>
        /// Process pricesses.
        /// </summary>
        private void ProcessPricesses(Repeater dataRepeater)
        {
            try
            {
                //using (TransactionScope ts = new TransactionScope())
                //{
                //foreach (RepeaterItem outerRpt in dataRepeater.Items)
                //{
                //    //Repeater rptSelectedFabrics = (Repeater)outerRpt.FindControl("rptSelectedFabrics");
                //    DataGrid dgSelectedFabrics = (DataGrid)outerRpt.FindControl("dgSelectedFabrics");
                //    if (dgSelectedFabrics != null)
                //    {
                //        foreach (DataGridItem innerRpt in dgSelectedFabrics.Items)
                //        {
                //            Repeater rptPriceLevelCost = (Repeater)innerRpt.FindControl("rptPriceLevelCost");
                //            if (rptPriceLevelCost != null)
                //            {
                foreach (RepeaterItem item in dataRepeater.Items)
                {
                    TextBox txtEditedIndicoCIFPrice = (TextBox)item.FindControl("txtEditedIndicoCIFPrice");

                    int distributor = int.Parse(this.ddlDistributors.SelectedValue);
                    int PriceTerm = int.Parse(this.hdnTerm.Value.Trim());
                    int priceLevelCost = int.Parse(txtEditedIndicoCIFPrice.Attributes["levelcost"].ToString().Trim());

                    DistributorPriceLevelCostBO objDistributorPriceLevelCost = new DistributorPriceLevelCostBO();
                    objDistributorPriceLevelCost.PriceTerm = PriceTerm;
                    objDistributorPriceLevelCost.PriceLevelCost = priceLevelCost;
                    var pricelevelCost = objDistributorPriceLevelCost.SearchObjects();

                    objDistributorPriceLevelCost = new DistributorPriceLevelCostBO(this.ObjContext);
                    if (pricelevelCost.Count > 0)
                    {
                        pricelevelCost = (from o in pricelevelCost.Where(o => o.Distributor == distributor) select o).ToList();
                        if (pricelevelCost.Count > 0)
                        {
                            int dplCostID = pricelevelCost.SingleOrDefault(o => o.Distributor == distributor).ID;

                            objDistributorPriceLevelCost.ID = dplCostID;
                            objDistributorPriceLevelCost.GetObject();

                            if (objDistributorPriceLevelCost.IndicoCost == Convert.ToDecimal(decimal.Parse(txtEditedIndicoCIFPrice.Text.Trim()).ToString("0.00")))
                            {
                                continue;
                            }
                            else
                            {
                                DistributorPriceLevelCostHistoryBO objDistributorPriceLevelCostHistory = new DistributorPriceLevelCostHistoryBO(this.ObjContext);
                                objDistributorPriceLevelCostHistory.Distributor = (objDistributorPriceLevelCost.Distributor != 0) ? objDistributorPriceLevelCost.Distributor : null;
                                objDistributorPriceLevelCostHistory.PriceTerm = objDistributorPriceLevelCost.PriceTerm;
                                objDistributorPriceLevelCostHistory.PriceLevelCost = objDistributorPriceLevelCost.PriceLevelCost;
                                objDistributorPriceLevelCostHistory.IndicoCost = objDistributorPriceLevelCost.IndicoCost;
                                objDistributorPriceLevelCostHistory.Modifier = this.LoggedUser.ID;//objDistributorPriceLevelCost.Modifier;
                                objDistributorPriceLevelCostHistory.ModifiedDate = DateTime.Now;//objDistributorPriceLevelCost.ModifiedDate;
                                objDistributorPriceLevelCostHistory.Add();
                            }
                        }
                        else
                        {
                            objDistributorPriceLevelCost.Distributor = (distributor > 0) ? (int?)distributor : null;
                            objDistributorPriceLevelCost.PriceLevelCost = priceLevelCost;
                        }
                    }
                    else
                    {
                        objDistributorPriceLevelCost.Distributor = (distributor > 0) ? (int?)distributor : null;
                        objDistributorPriceLevelCost.PriceLevelCost = priceLevelCost;
                        // objDistributorPriceLevelCost.PriceTerm = priceLevelCost;
                    }

                    objDistributorPriceLevelCost.IndicoCost = Convert.ToDecimal(decimal.Parse(txtEditedIndicoCIFPrice.Text.Trim()).ToString("0.00"));
                    objDistributorPriceLevelCost.PriceTerm = PriceTerm;
                    objDistributorPriceLevelCost.Modifier = this.LoggedUser.ID;
                    objDistributorPriceLevelCost.ModifiedDate = Convert.ToDateTime(DateTime.Now.ToString("g"));
                }
                //            }
                //        }
                //    }
                //}

                //    this.ObjContext.SaveChanges();
                //    ts.Complete();
                //}

                //  this.PopulatePriceLevelCosts();
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Adding the Item", ex);
            }
        }

        /// <summary>
        /// Process all changes at once.
        /// </summary>
        /// <param name="outerRepeater"></param>
        private void ProcessAll(Repeater outerRepeater)
        {

            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    foreach (RepeaterItem outerRpt in outerRepeater.Items)
                    {
                        DataGrid dgSelectedFabrics = (DataGrid)outerRpt.FindControl("dgSelectedFabrics");
                        if (dgSelectedFabrics != null)
                        {
                            foreach (DataGridItem innerRpt in dgSelectedFabrics.Items)
                            {
                                CheckBox checkEnablePriceList = (CheckBox)innerRpt.FindControl("checkEnablePriceList");

                                int priceid = int.Parse(((System.Web.UI.WebControls.WebControl)(checkEnablePriceList)).Attributes["pid"]);
                                PriceBO objPrice = new PriceBO(this.ObjContext);
                                objPrice.ID = priceid;
                                objPrice.GetObject();

                                if (checkEnablePriceList.Checked == true)
                                {
                                    objPrice.EnableForPriceList = true;
                                }
                                else
                                {
                                    objPrice.EnableForPriceList = false;
                                }

                                Repeater rptPriceLevelCost = (Repeater)innerRpt.FindControl("rptPriceLevelCost");
                                if (rptPriceLevelCost != null)
                                {
                                    this.ProcessPricesses(rptPriceLevelCost);
                                }
                            }
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }

                this.PopulatePriceLevelCosts();
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Adding the Item", ex);
            }
        }

        private void ReadExcelData(string filePath, string newDirectory)
        {
            CreateExcelDocument excell_app = null;
            // string newDirectory = string.Empty;

            //string path = Server.MapPath("IndicoData\\temp\\" + filePath);

            string read_text_path = newDirectory + "\\ReadExcelData" + ".txt";
            System.IO.StreamWriter read_file = null;

            try
            {
                if (File.Exists(filePath))
                {
                    /* newDirectory = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\PriceLists\\Import\\" + Guid.NewGuid();

                     if (!Directory.Exists(newDirectory))
                     {
                         Directory.CreateDirectory(newDirectory);
                     }

                     string newFilePath = newDirectory + "\\" + filePath;

                     File.Copy(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + filePath, newFilePath);

                     bool isnotExists = true;

                     while (isnotExists)
                     {
                         File.Exists(newFilePath);
                         {
                             isnotExists = false;
                         }
                     }*/

                    excell_app = new CreateExcelDocument(filePath);

                    if (excell_app != null)
                    {
                        ExcelData objExeclData = new ExcelData();

                        List<PriceData> lstPriceD = new List<PriceData>();

                        List<PriceValue> lstPriceV;

                        read_file = new System.IO.StreamWriter(read_text_path, true);
                        read_file.WriteLine("Start to read the file");
                        read_file.Close();

                        string text = excell_app.ReadCell("A1");

                        objExeclData.Distributor = text.Split('-')[0];

                        objExeclData.PaymentMethod = (text.Split('-')[1].Contains("CIF")) ? "CIF" : "FOB";

                        for (int i = 8; i < (excell_app.ReturnExcelRowCount()); i++)
                        {
                            // range = xlWorkSheet.get_Range("C" + i.ToString(), Missing.Value);

                            if (!string.IsNullOrEmpty(excell_app.ReadCell("C" + i.ToString())))
                            {
                                PriceData objPriceData = new PriceData();

                                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                                objReturnInt = PriceBO.GetPrice(excell_app.ReadCell("C" + i.ToString()), excell_app.ReadCell("F" + i.ToString()));
                                int Price = (int)objReturnInt.RetVal;

                                if (Price > 0)
                                {
                                    objPriceData.Pattern = excell_app.ReadCell("C" + i.ToString());

                                    objPriceData.Fabric = excell_app.ReadCell("F" + i.ToString());


                                    lstPriceV = new List<PriceValue>();

                                    for (int c = 71; c <= 79; c++)
                                    {
                                        PriceValue objPriceValue = new PriceValue();
                                        string strAlpha = Convert.ToChar(c).ToString();

                                        //range = excell_app.ReadCell(strAlpha + i.ToString());

                                        if (!string.IsNullOrEmpty(excell_app.ReadCell(strAlpha + "6")))
                                        {
                                            // if (Price > 0)
                                            //{

                                            objPriceValue.Level = excell_app.ReadCell(strAlpha + "6");

                                            text = excell_app.ReadCell(strAlpha + i.ToString());

                                            if (!string.IsNullOrEmpty(excell_app.ReadCell(strAlpha + i.ToString())) && excell_app.ReadCell(strAlpha + i.ToString()).Replace("$", string.Empty) != "0.00")
                                            {
                                                objPriceValue.Value = objPriceValue.Value = Convert.ToDecimal(text.Replace("$", string.Empty));
                                            }

                                            else
                                            {
                                                int PriceLevel = 0;

                                                switch (excell_app.ReadCell(strAlpha + "6"))
                                                {
                                                    case "1- 5":
                                                        PriceLevel = 1;
                                                        break;
                                                    case "6- 9":
                                                        PriceLevel = 2;
                                                        break;
                                                    case "10 - 19":
                                                        PriceLevel = 3;
                                                        break;
                                                    case "20 - 49":
                                                        PriceLevel = 4;
                                                        break;
                                                    case "50 - 99":
                                                        PriceLevel = 5;
                                                        break;
                                                    case "100 - 249":
                                                        PriceLevel = 6;
                                                        break;
                                                    case "250 - 499":
                                                        PriceLevel = 7;
                                                        break;
                                                    case "500+":
                                                        PriceLevel = 8;
                                                        break;
                                                    default:
                                                        break;
                                                }

                                                string distributor = excell_app.ReadCell("A1").Split('-')[0];

                                                CompanyBO objCompany = new CompanyBO();
                                                objCompany.Name = distributor;

                                                int Distributor = objCompany.SearchObjects().Select(o => o.ID).SingleOrDefault();

                                                /*DistributorPriceMarkupBO objDPM = new DistributorPriceMarkupBO();
                                                 objDPM.PriceLevel = PriceLevel;
                                                  objDPM.Distributor = Distributor;*/



                                                int DistributorPriceMarkup = (new DistributorPriceMarkupBO()).SearchObjects().Where(o => o.PriceLevel == PriceLevel && o.Distributor == Distributor).Select(o => o.ID).SingleOrDefault();

                                                DistributorPriceMarkupBO objDistributorPriceMarkup = new DistributorPriceMarkupBO();
                                                objDistributorPriceMarkup.ID = DistributorPriceMarkup;
                                                objDistributorPriceMarkup.GetObject();


                                                PriceLevelCostBO objPLC = new PriceLevelCostBO();
                                                objPLC.Price = Price;
                                                objPLC.PriceLevel = PriceLevel;

                                                int PriceLevelCost = objPLC.SearchObjects().Select(o => o.ID).SingleOrDefault();

                                                PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO();
                                                objPriceLevelCost.ID = PriceLevelCost;
                                                objPriceLevelCost.GetObject();

                                                decimal convertionfactor = objPriceLevelCost.objPrice.objPattern.ConvertionFactor;

                                                PriceTermBO objPriceTerm = new PriceTermBO();
                                                objPriceTerm.Name = objExeclData.PaymentMethod;

                                                int PriceTerm = objPriceTerm.SearchObjects().Select(o => o.ID).SingleOrDefault();

                                                DistributorPriceLevelCostBO objDistributorPriceLevelCost = new DistributorPriceLevelCostBO();
                                                //objDistributorPriceLevelCost.Distributor = (Distributor>0)?Distributor:(int)null;
                                                objDistributorPriceLevelCost.PriceLevelCost = PriceLevelCost;
                                                objDistributorPriceLevelCost.PriceTerm = PriceTerm;

                                                int DistributorPriceLevelCost = objDistributorPriceLevelCost.SearchObjects().Where(o => o.Distributor == Distributor).Select(o => o.ID).SingleOrDefault();

                                                if (DistributorPriceLevelCost > 0)
                                                {
                                                    DistributorPriceLevelCostBO objDPLC = new DistributorPriceLevelCostBO();
                                                    objDPLC.ID = DistributorPriceLevelCost;
                                                    objDPLC.GetObject();

                                                    objPriceValue.Value = objDPLC.IndicoCost;
                                                }
                                                else
                                                {
                                                    if (objExeclData.PaymentMethod == "CIF")
                                                    {
                                                        decimal calculatedIndimanCIFPrice = (objPriceLevelCost.IndimanCost != 0) ? Math.Round((objPriceLevelCost.IndimanCost * 100) / (100 - objDistributorPriceMarkup.Markup), 2) : 0;

                                                        objPriceValue.Value = calculatedIndimanCIFPrice;
                                                    }
                                                    else
                                                    {
                                                        decimal indicoCIFMarkup = objDistributorPriceMarkup.Markup;

                                                        decimal calIndimanFOBPrice = (objPriceLevelCost.IndimanCost != 0) ? Math.Round(((objPriceLevelCost.IndimanCost - convertionfactor)) / (1 - (indicoCIFMarkup / 100)), 2) : 0;

                                                        objPriceValue.Value = calIndimanFOBPrice;
                                                    }
                                                }

                                            }

                                            lstPriceV.Add(objPriceValue);
                                            //}
                                        }
                                    }

                                    objPriceData.lstPriceValue = lstPriceV;
                                    lstPriceD.Add(objPriceData);


                                }
                                else
                                {
                                    string textFilePath = newDirectory + "\\Not_Existed_Fabric_NickName" + ".txt";
                                    System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, true);
                                    file.WriteLine(excell_app.ReadCell("C" + i.ToString()) + " - " + excell_app.ReadCell("F" + i.ToString()));
                                    file.Close();
                                }
                            }

                        }

                        objExeclData.lstPriceData = lstPriceD;

                        read_file = new System.IO.StreamWriter(read_text_path, true);
                        read_file.WriteLine("End of the reading");
                        read_file.Close();

                        this.ProcessExcelData(objExeclData, newDirectory);
                    }
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while reding" + filePath + " form IndicoPrice Page ", ex);
            }
            finally
            {
                excell_app.CloseDocument();

                string textFilePath = newDirectory + "\\Log" + ".txt";
                System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, true);
                file.WriteLine(filePath + " File Process Successfully");
                file.Close();
            }
        }

        private void ProcessExcelData(ExcelData objExcelData, string directoryPath)
        {
            int count = 0;

            try
            {
                PriceTermBO objPriceTerm = new PriceTermBO();
                objPriceTerm.Name = objExcelData.PaymentMethod;

                int PriceTerm = objPriceTerm.SearchObjects().Select(o => o.ID).SingleOrDefault();

                CompanyBO objCompany = new CompanyBO();
                objCompany.Name = objExcelData.Distributor;

                int Distributor = objCompany.SearchObjects().Select(o => o.ID).SingleOrDefault();

                string textFilePath = directoryPath + "\\ProcessFile" + ".txt";
                System.IO.StreamWriter processfile = new System.IO.StreamWriter(textFilePath, true);
                processfile.WriteLine("Process starting");
                processfile.Close();

                foreach (PriceData pd in objExcelData.lstPriceData)
                {
                    count++;


                    /*  List<FabricCodeBO> lst = (new FabricCodeBO()).SearchObjects().Where(o => o.NickName == pd.Fabric).ToList();

                     if (lst.Count == 0)
                      {
                          string textFilePath = directoryPath + "\\Not_Existed_Fabric_NickName" + ".txt";
                          System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, true);
                          file.WriteLine(pd.Fabric + " - " + pd.Pattern);
                          file.Close();
                      }*/


                    if (count == 44)
                    {
                        string pat = pd.Pattern;
                        string fab = pd.Fabric;
                    }

                    ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                    objReturnInt = PriceBO.GetPrice(pd.Pattern, pd.Fabric);

                    int Price = (int)objReturnInt.RetVal; //objPrice.SearchObjects().Select(o => o.ID).SingleOrDefault();

                    if (Price > 0)
                    {
                        IndicoContext _context = new IndicoContext();

                        using (TransactionScope ts = new TransactionScope())
                        {
                            foreach (PriceValue pv in pd.lstPriceValue)
                            {

                                int PriceLevel = 0;

                                switch (pv.Level)
                                {
                                    case "1- 5":
                                        PriceLevel = 1;
                                        break;
                                    case "6- 9":
                                        PriceLevel = 2;
                                        break;
                                    case "10 - 19":
                                        PriceLevel = 3;
                                        break;
                                    case "20 - 49":
                                        PriceLevel = 4;
                                        break;
                                    case "50 - 99":
                                        PriceLevel = 5;
                                        break;
                                    case "100 - 249":
                                        PriceLevel = 6;
                                        break;
                                    case "250 - 499":
                                        PriceLevel = 7;
                                        break;
                                    case "500+":
                                        PriceLevel = 8;
                                        break;
                                    default:
                                        break;
                                }

                                /* PriceLevelBO objPriceLevel = new PriceLevelBO();
                                 objPriceLevel.Volume = pv.Level;

                                 int PriceLevel = (new PriceLevelBO()).SearchObjects().Where(o => o.Volume.Trim().Contains(pv.Level.Trim())).Select(o => o.ID).SingleOrDefault(); objPriceLevel.SearchObjects().Select(o => o.ID).SingleOrDefault();*/

                                PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO();
                                objPriceLevelCost.Price = Price;
                                objPriceLevelCost.PriceLevel = PriceLevel;

                                int PriceLevelCost = objPriceLevelCost.SearchObjects().Select(o => o.ID).SingleOrDefault();


                                DistributorPriceLevelCostBO objDistributorPriceLevelCost = new DistributorPriceLevelCostBO();
                                //objDistributorPriceLevelCost.Distributor = (Distributor>0)?Distributor:(int)null;
                                objDistributorPriceLevelCost.PriceLevelCost = PriceLevelCost;
                                objDistributorPriceLevelCost.PriceTerm = PriceTerm;

                                int DistributorPriceLevelCost = objDistributorPriceLevelCost.SearchObjects().Where(o => o.Distributor == Distributor).Select(o => o.ID).SingleOrDefault();

                                DistributorPriceLevelCostBO objDPLC = new DistributorPriceLevelCostBO(_context);
                                if (DistributorPriceLevelCost > 0)
                                {
                                    objDPLC.ID = DistributorPriceLevelCost;
                                    objDPLC.GetObject();

                                    DistributorPriceLevelCostHistoryBO objDistributorPriceLevelCostHistory = new DistributorPriceLevelCostHistoryBO(this.ObjContext);
                                    objDistributorPriceLevelCostHistory.Distributor = (objDPLC.Distributor != 0) ? objDPLC.Distributor : null;
                                    objDistributorPriceLevelCostHistory.PriceTerm = objDPLC.PriceTerm;
                                    objDistributorPriceLevelCostHistory.PriceLevelCost = objDPLC.PriceLevelCost;
                                    objDistributorPriceLevelCostHistory.IndicoCost = objDPLC.IndicoCost;
                                    objDistributorPriceLevelCostHistory.Modifier = this.LoggedUser.ID;
                                    objDistributorPriceLevelCostHistory.ModifiedDate = DateTime.Now;
                                    objDistributorPriceLevelCostHistory.Add();
                                }

                                objDPLC.Distributor = (Distributor > 0) ? (int?)Distributor : null;
                                objDPLC.PriceTerm = PriceTerm;
                                objDPLC.PriceLevelCost = PriceLevelCost;
                                objDPLC.IndicoCost = Convert.ToDecimal(pv.Value.ToString("0.00"));
                                objDPLC.Modifier = this.LoggedUser.ID;
                                objDPLC.ModifiedDate = DateTime.Now;
                            }

                            _context.SaveChanges();
                            ts.Complete();
                        }
                    }
                }

                processfile = new System.IO.StreamWriter(textFilePath, true);
                processfile.WriteLine("Processed");
                processfile.Close();

            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving or updating Indico Excel data to the database", ex);

                string textFilePath = directoryPath + "\\Error" + ".txt";
                System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, true);
                file.WriteLine(ex.ToString());
                file.Close();
            }
        }

        //private void ReleaseObject(object obj)
        //{
        //    try
        //    {
        //        System.Runtime.InteropServices.Marshal.ReleaseComObject(obj);
        //        obj = null;
        //    }
        //    catch (Exception)
        //    {
        //        obj = null;
        //    }
        //    finally
        //    {
        //        GC.Collect();
        //    }
        //}

        //private void KillExcel()
        //{
        //    Process[] AllProcesses = Process.GetProcessesByName("excel");

        //    // check to kill the right process
        //    foreach (Process ExcelProcess in AllProcesses)
        //    {
        //        //if (myHashtable.ContainsKey(ExcelProcess.Id) == false)
        //        ExcelProcess.Kill();
        //    }

        //    AllProcesses = null;
        //}

        #endregion

    }

    #region Internal Class

    internal class ExcelData
    {
        public string Distributor { get; set; }

        public string PaymentMethod { get; set; }

        public List<PriceData> lstPriceData { get; set; }
    }

    internal class PriceData
    {
        public string Pattern { get; set; }

        public string Fabric { get; set; }

        public List<PriceValue> lstPriceValue { get; set; }

    }

    internal class PriceValue
    {
        public string Level { get; set; }

        public decimal Value { get; set; }
    }

    #endregion
}
