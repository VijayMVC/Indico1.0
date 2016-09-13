using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class ViewItemSubCategories : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)Session["ItemSubCategorySortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                Session["ItemSubCategorySortExpression"] = value;
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

        protected void dgItemSubCategory_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is ItemBO)
            {
                ItemBO objSubItem = (ItemBO)item.DataItem;

                Label lblItemName = (Label)item.FindControl("lblItemName");
                lblItemName.Text = objSubItem.objParent.Name;
            }
        }

        protected void dgItemSubCategory_PageIndexChanged(object sender, DataGridPageChangedEventArgs e)
        {

        }

        protected void dgItemSubCategory_SortCommand(object source, DataGridSortCommandEventArgs e)
        {

        }

        protected void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {

        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            int subCatId = int.Parse(this.hdnSelectedSubCategoryID.Value.Trim());

            if (Page.IsValid)
            {
                this.ProcessForm(subCatId);
                Response.Redirect("/ViewItemSubCategory.aspx");
            }
            else
            {
                this.lblPopupHeaderText.Text = "Edit Item Sub Category";
                this.btnSaveChanges.Text = "Save Changes";
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            this.dvPageValidation.Visible = !(Page.IsValid);
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int itemSubCatId = int.Parse(this.hdnSelectedSubCategoryID.Value.Trim());

            if (itemSubCatId > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        ItemBO objSubItem = new ItemBO(this.ObjContext);
                        objSubItem.ID = itemSubCatId;
                        objSubItem.GetObject();
                        objSubItem.Delete();

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                        this.PopulateDataGrid();
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = "Item Sub-Category"; //this.ActivePage.Heading;
            ViewState["IsPageValied"] = true;

            //Populate Items
            List<ItemBO> lstItems = (new ItemBO()).GetAllObject();
            foreach (ItemBO item in lstItems)
            {
                this.ddlItem.Items.Add(new ListItem(item.Name, item.ID.ToString()));
            }

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
            ItemBO objSubItem = new ItemBO();

            // Sort by condition
            int sortbyStatus = int.Parse(this.ddlSortBy.SelectedItem.Value);
            if (sortbyStatus < 2)
            {
                //objItem.IsActive = Convert.ToBoolean(sortbyStatus);
            }

            List<ItemBO> lstSubItems = new List<ItemBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstSubItems = (from o in objSubItem.SearchObjects().ToList()
                               where o.Name.ToLower().Contains(searchText)
                               select o).ToList();
            }
            else
            {
                lstSubItems = objSubItem.SearchObjects().ToList();
            }

            if (lstSubItems.Count > 0)
            {
                this.dgItemSubCategory.AllowPaging = (lstSubItems.Count > this.dgItemSubCategory.PageSize);
                this.dgItemSubCategory.DataSource = lstSubItems;
                this.dgItemSubCategory.DataBind();

                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search") || (sortbyStatus < 2))
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty) + "Sort by " + this.ddlSortBy.SelectedItem.Text;

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyContent.Visible = true;
            }

            this.lblSerchKey.Text = string.Empty;
            this.dgItemSubCategory.Visible = (lstSubItems.Count > 0);

        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm(int itemId)
        {

            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    ItemBO objItemSubCategoryBO = new ItemBO(this.ObjContext);

                    if (itemId > 0)
                    {
                        objItemSubCategoryBO.ID = itemId;
                        objItemSubCategoryBO.GetObject();
                    }

                    objItemSubCategoryBO.Parent = int.Parse(this.ddlItem.SelectedValue);
                    objItemSubCategoryBO.Name = this.txtName.Text;
                    objItemSubCategoryBO.Description = this.txtDescription.Text;

                    if (itemId == 0)
                        objItemSubCategoryBO.Add();

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