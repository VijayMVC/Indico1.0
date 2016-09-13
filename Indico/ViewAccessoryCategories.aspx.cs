using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class ViewAccessoryCategories : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["AccessoryCategorySortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["AccessoryCategorySortExpression"] = value;
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

        protected void RadGridAccessoryCategories_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is AccessoryCategoryBO)
                {
                    AccessoryCategoryBO objAccessoryCategory = (AccessoryCategoryBO)item.DataItem;

                    HtmlAnchor linkEdit = (HtmlAnchor)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objAccessoryCategory.ID.ToString());
                    //linkEdit.Attributes.Add("aid", objPatternAccessoryCategory.Accessory.ToString());

                    HtmlAnchor linkDelete = (HtmlAnchor)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objAccessoryCategory.ID.ToString());
                    linkDelete.Visible = (objAccessoryCategory.AccessorysWhereThisIsAccessoryCategory.Count == 0) ? true : false;
                }
            }

        }

        protected void RadGridAccessoryCategories_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridAccessoryCategories_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridAccessoryCategories_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridAccessoryCategories_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dgAccessoryCategory_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is AccessoryCategoryBO)
        //    {
        //        AccessoryCategoryBO objAccessoryCategory = (AccessoryCategoryBO)item.DataItem;

        //        HtmlAnchor linkEdit = (HtmlAnchor)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objAccessoryCategory.ID.ToString());
        //        //linkEdit.Attributes.Add("aid", objPatternAccessoryCategory.Accessory.ToString());

        //        HtmlAnchor linkDelete = (HtmlAnchor)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objAccessoryCategory.ID.ToString());
        //        linkDelete.Visible = (objAccessoryCategory.AccessorysWhereThisIsAccessoryCategory.Count == 0) ? true : false;
        //    }
        //}

        //protected void dgAccessoryCategory_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgAccessoryCategory.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dgAccessoryCategory_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dgAccessoryCategory.Columns)
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
        //}

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int itemId = int.Parse(this.hdnSelectedAccessoryCategoryID.Value.ToString().Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(itemId, false);
                    Response.Redirect("/ViewAccessoryCategories.aspx");
                }

                // Popup Header Text
                this.lblPopupHeaderText.Text = ((itemId > 0) ? "Edit " : "New ") + "Accessory Category";

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnDeleteAccessoryCategory_Click(object sender, EventArgs e)
        {
            int qid = int.Parse(this.hdnSelectedAccessoryCategoryID.Value.Trim());

            this.ProcessForm(qid, true);
            this.PopulateDataGrid();
        }

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int itemId = int.Parse(this.hdnSelectedAccessoryCategoryID.Value.ToString().Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(itemId, "AccessoryCategory", "Name", this.txtName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewAccessoryCategories.aspx", ex);
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            //Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;

            // Popup Header Text
            this.lblPopupHeaderText.Text = "New Accessory Category";

            //Set validity of the control fields
            ViewState["IsPageValied"] = true;
            Session["AccessoryCategoryDetails"] = null;

            //Popultate the data grid
            this.PopulateDataGrid();

        }

        private void ProcessForm(int queryId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    AccessoryCategoryBO objPatternAccessoryCategory = new AccessoryCategoryBO(this.ObjContext);
                    if (queryId > 0)
                    {
                        objPatternAccessoryCategory.ID = queryId;
                        objPatternAccessoryCategory.GetObject();
                    }

                    if (isDelete)
                    {
                        objPatternAccessoryCategory.Delete();
                    }
                    else
                    {
                        objPatternAccessoryCategory.Name = this.txtName.Text;
                        objPatternAccessoryCategory.Code = this.txtCode.Text;

                        if (queryId == 0)
                        {
                            objPatternAccessoryCategory.Add();
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Adding or Updating or Deleting Accessory Category in ViewAccessoryCategories.aspx page", ex);
            }
        }

        private void PopulateDataGrid()
        {
            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            // Search text
            string searchText = this.txtSearch.Text.ToLower().Trim();

            // Populate Accessory Category
            AccessoryCategoryBO objAccessoryCategory = new AccessoryCategoryBO();

            // Sort by condition
            List<AccessoryCategoryBO> lstAccessoryCategory = new List<AccessoryCategoryBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstAccessoryCategory = (from o in objAccessoryCategory.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<AccessoryCategoryBO>()
                                        where o.Name.ToLower().Contains(searchText) ||
                                        o.Code.ToLower().Contains(searchText)
                                        select o).ToList();
            }
            else
            {
                lstAccessoryCategory = objAccessoryCategory.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<AccessoryCategoryBO>();
            }


            if (lstAccessoryCategory.Count > 0)
            {
                this.RadGridAccessoryCategories.AllowPaging = (lstAccessoryCategory.Count > this.RadGridAccessoryCategories.PageSize);
                this.RadGridAccessoryCategories.DataSource = lstAccessoryCategory;
                this.RadGridAccessoryCategories.DataBind();
                Session["AccessoryCategoryDetails"] = lstAccessoryCategory;

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
                this.btnNewAccessoryCategory.Visible = false;
            }

            this.RadGridAccessoryCategories.Visible = (lstAccessoryCategory.Count > 0);
        }

        private void ReBindGrid()
        {
            if (Session["AccessoryCategoryDetails"] != null)
            {
                RadGridAccessoryCategories.DataSource = (List<AccessoryCategoryBO>)Session["AccessoryCategoryDetails"];
                RadGridAccessoryCategories.DataBind();
            }
        }

        #endregion
    }
}