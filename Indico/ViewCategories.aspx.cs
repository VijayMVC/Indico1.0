using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class ViewCategories : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["CategorySortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["CategorySortExpression"] = value;
            }
        }

        public bool IsNotRefresh
        {
            get
            {
                return (Session["IsPostBack"].ToString() == ViewState["IsPostBack"].ToString());
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
        protected void Page_PreRender(object sender, EventArgs e)
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

        protected void RadGridCategories_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridCategories_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridCategories_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is CategoryBO)
                {
                    CategoryBO objCategory = (CategoryBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objCategory.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objCategory.ID.ToString());
                    linkDelete.Visible = (objCategory.PatternOtherCategorysWhereThisIsCategory.Count == 0 && objCategory.PatternsWhereThisIsCoreCategory.Count == 0) ? true : false;

                }
            }
        }

        protected void RadGridCategories_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridCategories_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, EventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dgCategory_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is CategoryBO)
        //    {
        //        CategoryBO objCategory = (CategoryBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objCategory.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objCategory.ID.ToString());
        //        linkDelete.Visible = (objCategory.PatternOtherCategorysWhereThisIsCategory.Count == 0);
        //        linkDelete.Visible = (objCategory.PatternsWhereThisIsCoreCategory.Count == 0);
        //    }
        //}

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["IsPageValied"] = true;
            this.PopulateDataGrid();
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int categoryId = int.Parse(this.hdnSelectedCategoryID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(categoryId, false);

                    Response.Redirect("/ViewCategories.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int categoryId = int.Parse(this.hdnSelectedCategoryID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(categoryId, true);
                this.PopulateDataGrid();
            }
            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);
        }

        //protected void dgCategory_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgCategory.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //    ViewState["IsPageValied"] = true;
        //}

        //protected void dgCategory_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    this.PopulateDataGrid();

        //    foreach (DataGridColumn col in this.dgCategory.Columns)
        //    {
        //        if (col.Visible && col.SortExpression == e.SortExpression)
        //        {
        //            col.HeaderStyle.CssClass = "selected " + ((sortDirection.ToUpper() != " DESC") ? "sortDown" : "sortUp");
        //        }
        //        else
        //        {
        //            col.HeaderStyle.CssClass = "";
        //        }
        //    }
        //    ViewState["IsPageValied"] = true;
        //}

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int categoryId = int.Parse(this.hdnSelectedCategoryID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(categoryId, "Category", "Name", this.txtCategoryName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewCategories.aspx", ex);
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;

            lblPopupHeaderText.Text = "New Category";
            ViewState["IsPageValied"] = true;
            Session["CategoriesDetails"] = null;

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

            // Populate Category
            CategoryBO objCategory = new CategoryBO();

            List<CategoryBO> lstCategory = new List<CategoryBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstCategory = (from o in objCategory.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                               where o.Name.ToLower().Contains(searchText) ||
                               (o.Description != null ? o.Description.ToLower().Contains(searchText) : false)
                               select o).ToList();
            }
            else
            {
                lstCategory = objCategory.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            }

            if (lstCategory.Count > 0)
            {
                this.RadGridCategories.AllowPaging = (lstCategory.Count > this.RadGridCategories.PageSize);
                this.RadGridCategories.DataSource = lstCategory;
                this.RadGridCategories.DataBind();
                Session["CategoriesDetails"] = lstCategory;

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
                this.btnAddCategories.Visible = false;
            }

            this.RadGridCategories.Visible = (lstCategory.Count > 0);
        }

        private void ProcessForm(int categoryId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    CategoryBO objCategory = new CategoryBO(this.ObjContext);
                    if (categoryId > 0)
                    {
                        objCategory.ID = categoryId;
                        objCategory.GetObject();
                        objCategory.Name = this.txtCategoryName.Text;
                        objCategory.Description = this.txtDescription.Text;

                        if (isDelete)
                        {
                            objCategory.Delete();
                        }
                    }
                    else
                    {
                        objCategory.Name = this.txtCategoryName.Text;
                        objCategory.Description = this.txtDescription.Text;
                        objCategory.Add();
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                //throw ex;
            }
        }

        private void ReBindGrid()
        {
            if (Session["CategoriesDetails"] != null)
            {
                RadGridCategories.DataSource = (List<CategoryBO>)Session["CategoriesDetails"];
                RadGridCategories.DataBind();
            }
        }

        #endregion
    }
}