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
    public partial class ViewPatternAccessory : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ItemsAttributeSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "ID";
                }
                return sort;
            }
            set
            {
                ViewState["ItemsAttributeSortExpression"] = value;
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

        protected void dgPatternAccessory_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PatternAccessoryBO)
            {
                PatternAccessoryBO objPatterAccessory = (PatternAccessoryBO)item.DataItem;

                Literal lblpattern = (Literal)item.FindControl("lblpattern");
                lblpattern.Text = objPatterAccessory.objPattern.Number;

                Literal lblAccessory = (Literal)item.FindControl("lblAccessory");
                lblAccessory.Text = (objPatterAccessory.Accessory != null && objPatterAccessory.Accessory > 0) ? objPatterAccessory.objAccessory.Name : string.Empty;

                Literal lblAccessoryCategory = (Literal)item.FindControl("lblAccessoryCategory");
                lblAccessoryCategory.Text = (objPatterAccessory.Accessory != null && objPatterAccessory.Accessory > 0) ? objPatterAccessory.objAccessory.objAccessoryCategory.Name : string.Empty;

                HtmlAnchor linkEdit = (HtmlAnchor)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objPatterAccessory.ID.ToString());
                linkEdit.Attributes.Add("patid", objPatterAccessory.Pattern.ToString());
                linkEdit.Attributes.Add("catid", objPatterAccessory.objAccessory.AccessoryCategory.ToString());
                linkEdit.Attributes.Add("accid", objPatterAccessory.Accessory.ToString());

                HtmlAnchor linkDelete = (HtmlAnchor)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objPatterAccessory.ID.ToString());
            }
        }

        protected void dgPatternAccessory_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dgPatternAccessory.CurrentPageIndex = e.NewPageIndex;

            this.PopulateDataGrid();
        }

        protected void dgPatternAccessory_SortCommand(object source, DataGridSortCommandEventArgs e)
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

            foreach (DataGridColumn col in this.dgPatternAccessory.Columns)
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

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int itemId = int.Parse(this.hdnSelectedPatternAccessoryID.Value.ToString().Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(itemId, false);
                    Response.Redirect("/ViewPatternAccessory.aspx");
                }

                // Popup Header Text
                this.lblPopupHeaderText.Text = ((itemId > 0) ? "Edit " : "New ") + "Pattern Accessory";

                ViewState["IsPageValied"] = (Page.IsValid);
                //this.validationSummary.Visible = !(Page.IsValid);
            }
            else
            {
                ViewState["IsPageValied"] = false;
            }
        }

        /*protected void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }*/

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int qid = int.Parse(this.hdnSelectedPatternAccessoryID.Value.Trim());

            this.ProcessForm(qid, true);

            this.PopulateDataGrid();

        }

        protected void ddlAccessoryCategory_SelectedIndexChange(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int accessory = int.Parse(this.ddlAccessoryCategory.SelectedValue);

                this.PopulateAccessories(accessory);

                ViewState["IsPageValied"] = false;
            }
        }

        protected void linkEdit_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {

                int id = int.Parse(((System.Web.UI.HtmlControls.HtmlControl)(sender)).Attributes["qid"]);

                PatternAccessoryBO objPatterAccessory = new PatternAccessoryBO();
                objPatterAccessory.ID = id;
                objPatterAccessory.GetObject();

                // hide the errors
                this.validationSummary.Visible = false;
                this.rfvItem.Visible = false;
                this.rfvAccessory.Visible = false;
                this.rfvCategoryAccessory.Visible = false;

                this.lblPopupHeaderText.Text = "Edit Pattern Accessory";
                this.btnSaveChanges.InnerHtml = "Update";

                this.ddlPattern.SelectedValue = objPatterAccessory.Pattern.ToString();
                this.ddlAccessory.SelectedValue = objPatterAccessory.Accessory.ToString();

                this.PopulateAccessories(objPatterAccessory.objAccessory.AccessoryCategory);

                this.ddlAccessoryCategory.SelectedValue = objPatterAccessory.objAccessory.AccessoryCategory.ToString();


                ViewState["IsPageValied"] = false;
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
            this.lblPopupHeaderText.Text = "New Item Attribute";

            //Set validity of the control fields
            ViewState["IsPageValied"] = true;

            //Popultate the data grid
            this.PopulateDataGrid();

            // Populate popup Accessory dropdown
            this.ddlAccessoryCategory.Items.Add(new ListItem("Select an Accessory Category", "0"));
            foreach (AccessoryCategoryBO acc in (new AccessoryCategoryBO()).SearchObjects())
            {
                this.ddlAccessoryCategory.Items.Add(new ListItem(acc.Name, acc.ID.ToString()));
            }

            // Populate popup Pattern dropdown
            this.ddlPattern.Items.Add(new ListItem("Select an ItemAttribute", "0"));
            foreach (PatternBO parentItem in (new PatternBO()).SearchObjects())
            {
                this.ddlPattern.Items.Add(new ListItem(parentItem.Number + " - " + parentItem.NickName, parentItem.ID.ToString()));
            }

        }

        private void ProcessForm(int queryId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    PatternAccessoryBO objPatternAccessory = new PatternAccessoryBO(this.ObjContext);
                    if (queryId > 0)
                    {
                        objPatternAccessory.ID = queryId;
                        objPatternAccessory.GetObject();
                    }

                    if (isDelete)
                    {
                        objPatternAccessory.Delete();
                    }
                    else
                    {
                        objPatternAccessory.Pattern = int.Parse(this.ddlPattern.SelectedItem.Value);
                        objPatternAccessory.Accessory = int.Parse(this.ddlAccessory.SelectedItem.Value);

                        if (queryId == 0)
                        {
                            objPatternAccessory.Add();
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while adding or updating or deleting Pattern Accessory", ex);
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

            // Populate Item Attribute
            PatternAccessoryBO objPatternAccessory = new PatternAccessoryBO();

            // Sort by condition
            List<PatternAccessoryBO> lstPatternAccessory = new List<PatternAccessoryBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstPatternAccessory = (from o in objPatternAccessory.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<PatternAccessoryBO>()
                                       where (o.Accessory != null) ? o.objAccessory.Name.ToLower().Contains(searchText) : false ||
                                             (o.Pattern != null) ? o.objPattern.Number.ToLower().Contains(searchText) : false ||
                                             (o.Pattern != null) ? o.objPattern.NickName.ToLower().Contains(searchText) : false
                                       //(o.Parent != 0 && o.objParent.Name.ToLower().Contains(searchText))
                                       select o).ToList();
            }
            else
            {
                lstPatternAccessory = objPatternAccessory.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<PatternAccessoryBO>();
            }



            if (lstPatternAccessory.Count > 0)
            {
                this.dgPatternAccessory.AllowPaging = (lstPatternAccessory.Count > this.dgPatternAccessory.PageSize);
                this.dgPatternAccessory.DataSource = lstPatternAccessory;
                this.dgPatternAccessory.DataBind();

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
                this.btnPatternAccessory.Visible = false;
            }

            this.dgPatternAccessory.Visible = (lstPatternAccessory.Count > 0);
        }

        private void PopulateAccessories(int accessorycatID)
        {
            // Populate popup AccessoryCategory dropdown
            this.ddlAccessory.Items.Clear();
            this.ddlAccessory.Items.Add(new ListItem("Select an Accessory", "0"));
            foreach (AccessoryBO parentItem in (new AccessoryBO()).SearchObjects().Where(o => o.AccessoryCategory == accessorycatID))
            {
                this.ddlAccessory.Items.Add(new ListItem(parentItem.Name, parentItem.ID.ToString()));
            }
        }

        #endregion
    }
}