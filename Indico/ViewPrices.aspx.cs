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

namespace Indico
{
    public partial class ViewPrices : IndicoPage
    {
        #region Fields
        string sportsCategory = string.Empty;
        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["PriceSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Pattern";
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

        protected void dgPrices_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, PriceBO>)
            {
                var lstPrices = ((IGrouping<int, PriceBO>)item.DataItem).ToList();
                PriceBO objPrice = lstPrices[0];
                if (sportsCategory == string.Empty || (sportsCategory != objPrice.objPattern.objCoreCategory.Name))
                {
                    Label lblSportsCategory = (Label)item.FindControl("lblSportsCategory");
                    lblSportsCategory.Text = objPrice.objPattern.objCoreCategory.Name;
                    sportsCategory = objPrice.objPattern.objCoreCategory.Name;
                }

                Label lblPatternNo = (Label)item.FindControl("lblPatternNo");
                lblPatternNo.Text = objPrice.objPattern.Number;

                Label lblOtherCategories = (Label)item.FindControl("lblOtherCategories");
                lblOtherCategories.Text = (objPrice.objPattern.PatternOtherCategorysWhereThisIsPattern.Count > 0) ? objPrice.objPattern.PatternOtherCategorysWhereThisIsPattern[0].Name : "";

                Label lblNickName = (Label)item.FindControl("lblNickName");
                lblNickName.Text = objPrice.objPattern.NickName;

                HtmlContainerControl dvFabricCodes = (HtmlContainerControl)item.FindControl("dvFabricCodes");
                for (int i = 0; i < lstPrices.Count; i++)
                {
                    if (i == 0)
                    {
                        dvFabricCodes.InnerHtml += "<Label>" + lstPrices[i].objFabricCode.Name + "</label>";
                    }
                    else
                    {
                        dvFabricCodes.InnerHtml += "<Label class=\"iseparator\">" + lstPrices[i].objFabricCode.Name + "</label>";
                    }
                }

                Label lblModifiedDate = (Label)item.FindControl("lblModifiedDate");
                lblModifiedDate.Text = objPrice.ModifiedDate.ToString("MMM dd yyyy");

                HyperLink linkEditFactoryCost = (HyperLink)item.FindControl("linkEditFactoryCost");
                linkEditFactoryCost.NavigateUrl = "/EditFactoryPrice.aspx?id=" + objPrice.Pattern.ToString();
                linkEditFactoryCost.ToolTip = "Edit Factory Cost";

                HyperLink linkEditIndimanCost = (HyperLink)item.FindControl("linkEditIndimanCost");
                linkEditIndimanCost.NavigateUrl = "/EditIndimanPrice.aspx?id=" + objPrice.Pattern.ToString();
                linkEditIndimanCost.ToolTip = "Edit Manufature Cost";

                HyperLink linkEditIndicoCost = (HyperLink)item.FindControl("linkEditIndicoCost");
                linkEditIndicoCost.NavigateUrl = "/EditIndicoPrice.aspx?pat=" + objPrice.Pattern.ToString();
                linkEditIndicoCost.ToolTip = "Edit Sales Cost";

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objPrice.Pattern.ToString());
            }
        }

        protected void dgPrices_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dgPrices.CurrentPageIndex = e.NewPageIndex;
            // Populate data grid
            this.PopulateDataGrid();
        }

        protected void dgPrices_SortCommand(object source, DataGridSortCommandEventArgs e)
        {
            string sortDirection = String.Empty;
            if (!SortExpression.ToUpper().StartsWith(e.SortExpression) && !SortExpression.ToUpper().Trim().EndsWith("DESC"))
            {
                sortDirection = " desc";
            }
            else
            {
                sortDirection = (SortExpression.ToUpper().EndsWith("DESC")) ? " asc" : " desc";
            }
            this.SortExpression = e.SortExpression + sortDirection;

            this.PopulateDataGrid();

            foreach (DataGridColumn col in this.dgPrices.Columns)
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

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int queryId = int.Parse(this.hdnSelectedID.Value.Trim());

            if (Page.IsValid)
            {
                this.ProcessForm(queryId, true);

                this.PopulateDataGrid();
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

            // Popup Filter Drop Down
            this.ddlFilterBy.Items.Add(new ListItem("Selecet Distributor", "-1"));
            List<CompanyBO> lstDistributors = (from o in (new CompanyBO()).SearchObjects()
                                               where o.IsDistributor == true
                                               select o).ToList();
            this.ddlFilterBy.Items.Add(new ListItem("Platinum", "0"));
            foreach (CompanyBO item in lstDistributors)
            {
                this.ddlFilterBy.Items.Add(new ListItem(item.Name, item.ID.ToString()));
            }

            ViewState["IsPageValied"] = true;

            this.PopulateDataGrid();
        }

        private void PopulateDataGrid()
        {
            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvEmptyContentFactory.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            // Search text
            string searchText = this.txtSearch.Text.ToLower().Trim();
            //int distributor = int.Parse(this.ddlFilterBy.SelectedValue);

            // Populate Items
            PriceBO objPrice = new PriceBO();

            List<IGrouping<int, PriceBO>> lstPrices = new List<IGrouping<int, PriceBO>>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstPrices = (from o in objPrice.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                             where o.objPattern.Number.ToLower().Contains(searchText)
                             orderby o.Pattern
                             group o by o.Pattern into g
                             select g).ToList();
            }
            else
            {
                lstPrices = (from o in objPrice.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                             orderby o.objPattern.objCoreCategory.Name
                             group o by o.Pattern into g
                             select g).ToList();
            }

            if (lstPrices.Count > 0)
            {
                this.dgPrices.AllowPaging = (lstPrices.Count > this.dgPrices.PageSize);
                this.dgPrices.DataSource = lstPrices;
                this.dgPrices.DataBind();

                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search"))
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " " : string.Empty);

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyContentFactory.Visible = (this.LoggedCompany.Type == 1);
                this.dvEmptyContent.Visible = !(this.dvEmptyContentFactory.Visible);
                this.btnAddPrice.Visible = false;
            }

            switch (this.LoggedCompanyType)
            {
                case CompanyType.Factory:
                    {
                        //this.dgPrices.Columns[7].Visible = false;
                        // this.dgPrices.Columns[8].Visible = false;
                        this.btnAddPrice.Visible = false;
                        break;
                    }
                case CompanyType.Sales:
                    {
                        this.dgPrices.Columns[6].Visible = false;
                        this.dgPrices.Columns[7].Visible = false;
                        break;
                    }
                case CompanyType.Manufacturer:
                    break;
                case CompanyType.Distributor:
                    break;
                case CompanyType.Client:
                    break;
                default:
                    break;
            }
            this.dgPrices.Visible = (lstPrices.Count > 0);
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm(int queryId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    PatternBO objPattern = new PatternBO(this.ObjContext);
                    if (queryId > 0)
                    {
                        objPattern.ID = queryId;
                        objPattern.GetObject();
                    }
                    if (isDelete)
                    {
                        List<PriceBO> lstPrces = objPattern.PricesWhereThisIsPattern;
                        foreach (PriceBO price in lstPrces)
                        {
                            PriceBO objPrice = new PriceBO(this.ObjContext);
                            objPrice.ID = price.ID;
                            objPrice.GetObject();

                            foreach (PriceLevelCostBO priceLevelCost in objPrice.PriceLevelCostsWhereThisIsPrice)
                            {
                                PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO(this.ObjContext);
                                objPriceLevelCost.ID = priceLevelCost.ID;
                                objPriceLevelCost.GetObject();

                                objPriceLevelCost.Delete();
                            }

                            objPrice.Delete();
                        }
                    }
                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                //IndicoLogging.log("Error occured while Adding the Item", ex);
            }
        }

        #endregion
    }
}