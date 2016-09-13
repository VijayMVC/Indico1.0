using System;
using System.Collections.Generic;
using System.IO;
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
    public partial class PendingPrice : IndicoPage
    {
        #region Field

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["PendingPriceSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "NickName";
                }
                return sort;
            }
            set
            {
                ViewState["PendingPriceSortExpression"] = value;
            }
        }

        #endregion

        #region Constructors

        #endregion

        #region Event

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

        protected void dgPendingPrice_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PendingPricesViewBO)
            {
                PendingPricesViewBO objPendingPriceView = (PendingPricesViewBO)item.DataItem;

                HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                linkEdit.NavigateUrl = "AddPatternFabricPrice.aspx?id=" + objPendingPriceView.ID.ToString();

            }
        }

        protected void dgPendingPrice_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dgPendingPrice.CurrentPageIndex = e.NewPageIndex;

            this.PopulateDataGrid();
        }

        protected void dgPendingPrice_SortCommand(object source, DataGridSortCommandEventArgs e)
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

            foreach (DataGridColumn col in this.dgPendingPrice.Columns)
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

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        /* protected void btnDelete_Click(object sender, EventArgs e)
         {
             {
                 int userId = int.Parse(hdnSelectedUserID.Value.Trim());

                 if (userId > 0)
                 {

                     try
                     {
                         using (TransactionScope ts = new TransactionScope())
                         {
                             UserBO objUser = new UserBO(this.ObjContext);
                             objUser.ID = userId;
                             objUser.GetObject();
                             objUser.Status = 4; //Deleted  
                             objUser.IsDeleted = true;
                             objUser.IsActive = false;

                             this.ObjContext.SaveChanges();
                             this.PopulateDataGrid();
                             ts.Complete();
                         }
                     }
                     catch (Exception ex)
                     {
                         throw ex;
                     }

                 }
             }
         }
         */
        #endregion

        #region Methods

        private void PopulateControls()
        {
            // Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;
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
            List<PendingPricesViewBO> lstPendingPrice = new List<PendingPricesViewBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstPendingPrice = (from o in (new PendingPricesViewBO()).SearchObjects().Where(o => o.PatternNumber.ToLower().Contains(searchText) ||
                                                                             o.NickName.ToLower().Contains(searchText) ||
                                                                             o.Gender.ToLower().Contains(searchText) ||
                                                                             o.SubItemName.ToLower().Contains(searchText) ||
                                                                             o.AgeGroup.ToLower().Contains(searchText) ||
                                                                             o.CoreCategory.ToLower().Contains(searchText)).AsQueryable().OrderBy(SortExpression)
                                   select o).ToList();
            }
            else
            {
                lstPendingPrice = (from o in (new PendingPricesViewBO()).SearchObjects().AsQueryable().OrderBy(SortExpression) select o).ToList();
            }

            if (lstPendingPrice.Count > 0)
            {
                this.dgPendingPrice.AllowPaging = (lstPendingPrice.Count > this.dgPendingPrice.PageSize);
                this.dgPendingPrice.DataSource = lstPendingPrice;
                this.dgPendingPrice.DataBind();

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

            }

            this.dgPendingPrice.Visible = (lstPendingPrice.Count > 0);
        }

        #endregion
    }
}