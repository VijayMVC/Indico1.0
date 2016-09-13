using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class ViewPriceLevels : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["PriceLevelSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["PriceLevelSortExpression"] = value;
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

        protected void dgPriceLevels_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            //if (item.ItemIndex > -1 && item.DataItem is PriceLevelBO)
            //{
            //    PriceLevelBO objPriceLevel = (PriceLevelBO)item.DataItem;

            if (item.ItemIndex > -1 && item.DataItem is PriceLevelNewBO)
            {
                PriceLevelNewBO objPriceLevel = (PriceLevelNewBO)item.DataItem;

                HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objPriceLevel.ID.ToString());

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objPriceLevel.ID.ToString());
            }
        }

        protected void dgPriceLevels_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dgPriceLevels.CurrentPageIndex = e.NewPageIndex;
            // Populate data grid
            this.PopulateDataGrid();
        }

        protected void dgPriceLevels_SortCommand(object source, DataGridSortCommandEventArgs e)
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

            this.PopulateDataGrid();

            foreach (DataGridColumn col in this.dgPriceLevels.Columns)
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
        }

        protected void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int queryId = int.Parse(this.hdnSelectedID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(queryId, false);

                    Response.Redirect("/ViewPriceLevels.aspx");
                }

                // Popup Header Text
                this.lblPopupHeaderText.Text = ((queryId > 0) ? "Edit " : "New ") + "Price Level";

                ViewState["IsPageValid"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int queryId = int.Parse(this.hdnSelectedID.Value.Trim());

            if (this.IsNotRefresh)
            {
                this.ProcessForm(queryId, true);
                this.PopulateDataGrid();
            }
        }

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int queryId = int.Parse(this.hdnSelectedID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(queryId, "PriceLevelNew", "Name", this.txtName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewPriceLevels.aspx", ex);
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

            // Popup Header Text
            this.lblPopupHeaderText.Text = "New Price Level";

            ViewState["IsPageValid"] = true;

            this.PopulateDataGrid();

        }

        private void PopulateDataGrid()
        {
            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            // Search text
            string searchText = this.txtSearch.Text.ToLower().Trim();

            // Populate Items
            //PriceLevelBO objPriceLevel = new PriceLevelBO();
            //List<PriceLevelBO> lstPriceLevels = new List<PriceLevelBO>();

            PriceLevelNewBO objPriceLevel = new PriceLevelNewBO();
            List<PriceLevelNewBO> lstPriceLevels = new List<PriceLevelNewBO>();

            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstPriceLevels = (from o in objPriceLevel.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                  where o.Name.ToLower().Contains(searchText)
                                  select o).ToList();
            }
            else
            {
                lstPriceLevels = objPriceLevel.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            }

            if (lstPriceLevels.Count > 0)
            {
                this.dgPriceLevels.AllowPaging = (lstPriceLevels.Count > this.dgPriceLevels.PageSize);
                this.dgPriceLevels.DataSource = lstPriceLevels;
                this.dgPriceLevels.DataBind();

                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search"))
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyContent.Visible = true;
                this.btnAddPriceLevel.Visible = false;
            }

            this.dgPriceLevels.Visible = (lstPriceLevels.Count > 0);
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        /// 
        private void ProcessForm(int queryId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    PriceLevelNewBO objPriceLevel = new PriceLevelNewBO(this.ObjContext);

                    if (queryId > 0)
                    {
                        objPriceLevel.ID = queryId;
                        objPriceLevel.GetObject();
                    }

                    if (isDelete)
                    {
                        objPriceLevel.Delete();
                    }
                    else
                    {
                        objPriceLevel.Name = txtName.Text;
                        objPriceLevel.Volume = txtVolume.Text;
                        objPriceLevel.Markup = decimal.Parse(txtMarkup.Text);
                        objPriceLevel.LastModifier = this.LoggedUser.ID;
                        objPriceLevel.LastModifiedDate = DateTime.Now;
                    }

                    if (queryId == 0)
                    {
                        objPriceLevel.Add();
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Saving the PriceLevel", ex);
            }
        }

        //private void ProcessForm_Old(int queryId, bool isDelete)
        //{
        //    try
        //    {
        //        using (TransactionScope ts = new TransactionScope())
        //        {
        //            PriceLevelBO objPriceLevel = null;

        //            if (queryId == 0)
        //            {
        //                objPriceLevel = new PriceLevelBO(this.ObjContext);
        //                objPriceLevel.Name = this.txtName.Text.Trim();
        //                objPriceLevel.Volume = this.txtVolume.Text.Trim();

        //                List<int?> lstDistributors = (new DistributorPriceMarkupBO()).SearchObjects().Select(o => o.Distributor).Distinct().ToList();
        //                if (lstDistributors.Count > 0)
        //                {
        //                    // Insert new DistributorPriceMarkup
        //                    foreach (int? distributor in lstDistributors)
        //                    {
        //                        DistributorPriceMarkupBO objDistributorPriceMarkup = new DistributorPriceMarkupBO(this.ObjContext);
        //                        objDistributorPriceMarkup.Distributor = (distributor != null) ? distributor : (int?)null;
        //                        objDistributorPriceMarkup.Markup = Convert.ToDecimal("0.00");
        //                        objPriceLevel.DistributorPriceMarkupsWhereThisIsPriceLevel.Add(objDistributorPriceMarkup);
        //                    }

        //                    // Insert new record to the PriceLelelCost
        //                    List<int> lstPrice = (new PriceBO()).SearchObjects().Select(o => o.ID).ToList();
        //                    if (lstPrice.Count > 0)
        //                    {
        //                        foreach (int price in lstPrice)
        //                        {
        //                            PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO(this.ObjContext);
        //                            objPriceLevelCost.Price = price;
        //                            objPriceLevelCost.FactoryCost = Convert.ToDecimal("0.00");
        //                            objPriceLevelCost.IndimanCost = Convert.ToDecimal("0.00");
        //                            objPriceLevel.PriceLevelCostsWhereThisIsPriceLevel.Add(objPriceLevelCost);
        //                        }
        //                    }
        //                }
        //            }
        //            else
        //            {
        //                objPriceLevel = new PriceLevelBO(this.ObjContext);
        //                objPriceLevel.ID = queryId;
        //                objPriceLevel.GetObject();

        //                if (isDelete)
        //                {
        //                    List<PriceLevelCostBO> lstPriceLevelCost = objPriceLevel.PriceLevelCostsWhereThisIsPriceLevel.ToList();
        //                    if (lstPriceLevelCost.Count > 0)
        //                    {
        //                        foreach (PriceLevelCostBO obj in objPriceLevel.PriceLevelCostsWhereThisIsPriceLevel.GetRange(0, objPriceLevel.PriceLevelCostsWhereThisIsPriceLevel.Count))
        //                        {
        //                            foreach (DistributorPriceLevelCostBO dplc in obj.DistributorPriceLevelCostsWhereThisIsPriceLevelCost.GetRange(0, obj.DistributorPriceLevelCostsWhereThisIsPriceLevelCost.Count))
        //                            {
        //                                // Delete DistributorPriceLevelCost
        //                                DistributorPriceLevelCostBO objDistributorPriceLevelCost = new DistributorPriceLevelCostBO(this.ObjContext);
        //                                objDistributorPriceLevelCost.ID = dplc.ID;
        //                                objDistributorPriceLevelCost.GetObject();
        //                                objDistributorPriceLevelCost.Delete();
        //                            }

        //                            PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO(this.ObjContext);
        //                            objPriceLevelCost.ID = obj.ID;
        //                            objPriceLevelCost.GetObject();
        //                            objPriceLevelCost.Delete();
        //                        }
        //                    }

        //                    this.ObjContext.SaveChanges();

        //                    foreach (DistributorPriceMarkupBO dpm in objPriceLevel.DistributorPriceMarkupsWhereThisIsPriceLevel.GetRange(0, objPriceLevel.DistributorPriceMarkupsWhereThisIsPriceLevel.Count))
        //                    {
        //                        DistributorPriceMarkupBO objDistributorPriceMarkup = new DistributorPriceMarkupBO(this.ObjContext);
        //                        objDistributorPriceMarkup.ID = dpm.ID;
        //                        objDistributorPriceMarkup.GetObject();
        //                        objDistributorPriceMarkup.Delete();
        //                    }

        //                    // Delete PriceLevel
        //                    objPriceLevel.Delete();
        //                }
        //                else
        //                {
        //                    // Insert and Update PriceLevel
        //                    objPriceLevel.Name = this.txtName.Text.Trim();
        //                    objPriceLevel.Volume = this.txtVolume.Text.Trim();
        //                    if (queryId == 0)
        //                    {
        //                        objPriceLevel.Add();
        //                    }
        //                }
        //            }

        //            this.ObjContext.SaveChanges();
        //            ts.Complete();
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        // Log the error
        //        IndicoLogging.log.Error("Error occured while Adding and deleating the PriceLevel", ex);
        //    }
        //}

        #endregion
    }
}