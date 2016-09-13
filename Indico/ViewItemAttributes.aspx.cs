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
    public partial class ItemAttributes : IndicoPage
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
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["ItemsAttributeSortExpression"] = value;
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

        protected void RadGridItemAttribute_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();

            ViewState["IsSubAttribute"] = (!this.IsPostBack);
            ViewState["IsPageValied"] = true;
        }

        protected void RadGridItemAttribute_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();

            ViewState["IsSubAttribute"] = (!this.IsPostBack);
            ViewState["IsPageValied"] = true;
        }

        protected void RadGridItemAttribute_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is ItemAttributesDetailsViewBO)
                {
                    ItemAttributesDetailsViewBO objItemAttribute = (ItemAttributesDetailsViewBO)item.DataItem;

                    HtmlAnchor linkEdit = (HtmlAnchor)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objItemAttribute.Attribute.ToString());

                    LinkButton lbtnEditSUbAttributes = (LinkButton)item.FindControl("lbtnEditSUbAttributes");
                    lbtnEditSUbAttributes.Attributes.Add("qid", objItemAttribute.Attribute.ToString());
                    lbtnEditSUbAttributes.Attributes.Add("item", objItemAttribute.ItemID.ToString());

                    HtmlAnchor linkDelete = (HtmlAnchor)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objItemAttribute.Attribute.ToString());
                    linkDelete.Visible = (objItemAttribute.IsItemAttributesSubWherethisFabricCode == true) ? false : true;
                }
            }
        }

        protected void RadGridItemAttribute_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();

                ViewState["IsSubAttribute"] = false;
                ViewState["IsPageValied"] = true;
            }
            else
            {
                if (this.IsNotRefresh)
                {
                    ViewState["IsSubAttribute"] = (this.IsPostBack);
                    ViewState["IsPageValied"] = true;
                }
            }  
        }

        protected void RadGridItemAttribute_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
            
            ViewState["IsSubAttribute"] = (!this.IsPostBack);
            ViewState["IsPageValied"] = true;
        }

        protected void RadGridItemAttribute_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dgItemAttributes_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is ItemAttributeBO)
        //    {
        //        ItemAttributeBO objItemAttribute = (ItemAttributeBO)item.DataItem;


        //        Literal litItem = (Literal)item.FindControl("litItem");
        //        litItem.Text = objItemAttribute.objItem.Name;

        //        HtmlAnchor linkEdit = (HtmlAnchor)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objItemAttribute.ID.ToString());

        //        LinkButton lbtnEditSUbAttributes = (LinkButton)item.FindControl("lbtnEditSUbAttributes");
        //        lbtnEditSUbAttributes.Attributes.Add("qid", objItemAttribute.ID.ToString());
        //        lbtnEditSUbAttributes.Attributes.Add("item", objItemAttribute.Item.ToString());

        //        HtmlAnchor linkDelete = (HtmlAnchor)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objItemAttribute.ID.ToString());
        //        linkDelete.Visible = (objItemAttribute.PatternItemAttributeSubsWhereThisIsItemAttribute.Count > 0 ||
        //                              objItemAttribute.ItemAttributesWhereThisIsParent.Count > 0) ? false : true;
        //    }
        //}

        //protected void dataGridItemAttributes_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgItemAttributes.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();

        //    ViewState["IsPageValied"] = true;
        //    ViewState["IsSubAttribute"] = false;
        //}

        //protected void dgItemAttributes_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dgItemAttributes.Columns)
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
                int itemId = int.Parse(this.hdnSelectedAttributeID.Value.ToString().Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(true, false);
                    Response.Redirect("/ViewItemAttributes.aspx");
                }

                // Popup Header Text
                // this.lblPopupHeaderText.Text = ((itemId > 0) ? "Edit " : "New ") + "Item Attribute";

                ViewState["IsPageValied"] = (Page.IsValid);
                ViewState["IsSubAttribute"] = false;
            }
        }

        /*protected void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }*/

        protected void btnDeleteAttribute_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {

                int qid = int.Parse(this.hdnSelectedAttributeID.Value.Trim());

                this.DeleteAttribute(qid);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = true;
            ViewState["IsSubAttribute"] = false;
        }

        protected void lbtnEditSUbAttributes_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int id = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["qid"].ToString());
                int item = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["item"].ToString());

                if (id > 0 && item > 0)
                {
                    ItemAttributeBO objItemAttribute = new ItemAttributeBO();
                    objItemAttribute.ID = id;
                    objItemAttribute.GetObject();

                    this.hdnParent.Value = id.ToString();
                    this.hdnItem.Value = item.ToString();

                    this.txtParent.Text = objItemAttribute.Name;

                    this.PopulateSubAttributes(false, id, item);

                    ViewState["IsSubAttribute"] = true;
                }

            }
        }

        protected void linkAddNew_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                this.PopulateSubAttributes(true, int.Parse(this.hdnParent.Value), int.Parse(this.hdnItem.Value));
            }
            else
            {
                ViewState["IsPageValied"] = true;
                ViewState["IsSubAttribute"] = false;
            }
        }

        protected void dgAddEditSubItemAttributes_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if ((item.ItemIndex > -1 && item.DataItem is ItemAttributeBO) && (item.ItemType == ListItemType.Item || item.ItemType == ListItemType.AlternatingItem))
            {
                ItemAttributeBO objSubItemAttribute = (ItemAttributeBO)item.DataItem;

                bool canDelete = (objSubItemAttribute.PatternItemAttributeSubsWhereThisIsItemAttribute.Count == 0 ||
                                  objSubItemAttribute.ItemAttributesWhereThisIsParent.Count == 0) ? true : false;


                Literal litID = (Literal)item.FindControl("litID");
                litID.Text = objSubItemAttribute.ID.ToString();

                Literal litAttribute = (Literal)item.FindControl("litAttribute");
                litAttribute.Text = objSubItemAttribute.Name.ToString();

                Literal litDescription = (Literal)item.FindControl("litDescription");
                litDescription.Text = (!string.IsNullOrEmpty(objSubItemAttribute.Description)) ? objSubItemAttribute.Description : string.Empty;

                LinkButton linkEdit = (LinkButton)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objSubItemAttribute.ID.ToString());

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objSubItemAttribute.ID.ToString());
                linkDelete.Visible = canDelete;
            }
            else if ((item.ItemIndex > -1 && item.DataItem is ItemAttributeBO) && (item.ItemType == ListItemType.EditItem))
            {
                ItemAttributeBO objSubItemAttribute = (ItemAttributeBO)item.DataItem;

                Literal litID = (Literal)item.FindControl("litID");
                litID.Text = objSubItemAttribute.ID.ToString();

                TextBox txtAttribute = (TextBox)item.FindControl("txtAttribute");
                txtAttribute.Text = objSubItemAttribute.Name.ToString();
                this.hdnAttributeName.Value = txtAttribute.Text;

                TextBox txtDescription = (TextBox)item.FindControl("txtDescription");
                txtDescription.Text = (!string.IsNullOrEmpty(objSubItemAttribute.Description)) ? objSubItemAttribute.Description : string.Empty;
                this.hdnAttributeDescription.Value = txtDescription.Text;

                LinkButton linkSave = (LinkButton)item.FindControl("linkSave");
                linkSave.Attributes.Add("qid", objSubItemAttribute.ID.ToString());
                linkSave.CommandName = (!string.IsNullOrEmpty(this.hdnAttributeName.Value) || (!string.IsNullOrEmpty(this.hdnAttributeDescription.Value))) ? "Update" : "Save";
            }
        }

        protected void dgAddEditSubItemAttributes_ItemCommand(object sender, DataGridCommandEventArgs e)
        {
            if (this.IsNotRefresh)
            {
                switch (e.CommandName)
                {
                    case "Save":
                        this.ProcessForm(true, true);
                        this.hdnSelectedAttributeID.Value = "0";
                        this.PopulateSubAttributes(false, int.Parse(this.hdnParent.Value), int.Parse(this.hdnItem.Value));
                        break;
                    case "Edit":
                        this.PopulateSubAttributes(false, int.Parse(this.hdnParent.Value), int.Parse(this.hdnItem.Value), ((System.Web.UI.WebControls.DataGrid)(sender)).CurrentPageIndex, e.Item.ItemIndex);
                        break;
                    case "Update":
                        Literal litID = (Literal)e.Item.FindControl("litID");
                        this.hdnSelectedAttributeID.Value = litID.Text;
                        this.ProcessForm(false, true);
                        this.PopulateSubAttributes(false, int.Parse(this.hdnParent.Value), int.Parse(this.hdnItem.Value));
                        break;
                    default:
                        break;
                }
            }
            else
            {
                ViewState["IsPageValied"] = true;
                ViewState["IsSubAttribute"] = false;
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
            Session["ItemAttributeDetails"] = null;
            ViewState["IsSubAttribute"] = false;

            //Popultate the data grid
            this.PopulateDataGrid();

            // Populate popup items dropdown
            this.ddlItem.Items.Add(new ListItem("Select an Item", "0"));
            foreach (ItemBO item in (new ItemBO()).SearchObjects().Where(o => o.Parent == 0).OrderBy(o => o.Name))
            {
                this.ddlItem.Items.Add(new ListItem(item.Name, item.ID.ToString()));
            }

            // Populate popup parent attribute items dropdown
            /*this.ddlParentAttribute.Items.Add(new ListItem("Select an ItemAttribute", "0"));
            foreach (ItemAttributeBO parentItem in (new ItemAttributeBO()).SearchObjects().Where(o => o.Parent == 0).OrderBy(o => o.Name))
            {
                this.ddlParentAttribute.Items.Add(new ListItem(parentItem.Name, parentItem.ID.ToString()));
            }*/

            //hide columns
            this.RadGridItemAttribute.MasterTableView.GetColumn("Description").Display = false;
            this.RadGridItemAttribute.MasterTableView.GetColumn("ItemID").Display = false;
        }

        private void ProcessForm(bool isNew = false, bool isSub = false)
        {
            //NNM
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    ItemAttributeBO objItemAttribute = new ItemAttributeBO(this.ObjContext);

                    if ((!isNew) && (int.Parse(this.hdnSelectedAttributeID.Value) > 0))
                    {
                        objItemAttribute.ID = int.Parse(this.hdnSelectedAttributeID.Value);
                        objItemAttribute.GetObject();
                    }

                    if (isSub)
                    {
                        objItemAttribute.Parent = int.Parse(this.hdnParent.Value);
                    }


                    objItemAttribute.Name = (isSub == false) ? this.txtAttributeName.Text : this.hdnAttributeName.Value;
                    objItemAttribute.Description = (isSub == false) ? this.txtDescription.Text : this.hdnAttributeDescription.Value;
                    objItemAttribute.Item = (isSub == false) ? int.Parse(this.ddlItem.SelectedItem.Value) : int.Parse(this.hdnItem.Value);


                    if (isNew)
                    {
                        objItemAttribute.Add();
                    }


                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Adding or Updaing Attributes from ViewItemAttributes.aspx page", ex);
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
            ItemAttributesDetailsViewBO objItemAttribute = new ItemAttributesDetailsViewBO();

            // Sort by condition
            List<ItemAttributesDetailsViewBO> lstItemAttributes = new List<ItemAttributesDetailsViewBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstItemAttributes = (from o in objItemAttribute.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<ItemAttributesDetailsViewBO>()
                                     where o.Name.ToLower().Contains(searchText) ||
                                          ((o.Name.ToLower().Contains(searchText)) ||
                                            o.Item.ToLower().Contains(searchText))
                                     select o).ToList();
            }
            else
            {
                lstItemAttributes = objItemAttribute.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<ItemAttributesDetailsViewBO>();
            }

            /*int sortbyStatus = int.Parse(this.ddlSortBy.SelectedItem.Value);
            if (sortbyStatus == 1)
            {
                lstItemAttributes = (from o in lstItemAttributes
                                     where o.Parent == 0
                                     select o).ToList();
            }
            else if (sortbyStatus == 0)
            {

                lstItemAttributes = (from o in lstItemAttributes
                                     where o.Parent > 0
                                     select o).ToList();
            }*/

            if (lstItemAttributes.Count > 0)
            {
                this.RadGridItemAttribute.AllowPaging = (lstItemAttributes.Count > this.RadGridItemAttribute.PageSize);
                this.RadGridItemAttribute.DataSource = lstItemAttributes;
                this.RadGridItemAttribute.DataBind();
                Session["ItemAttributeDetails"] = lstItemAttributes;

                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search") /*|| (sortbyStatus < 2)*/)
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty) /*+ "Filter by " + this.ddlSortBy.SelectedItem.Text*/;

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyContent.Visible = true;
                this.btnNewAttribute.Visible = false;
            }

            this.RadGridItemAttribute.Visible = (lstItemAttributes.Count > 0);
        }

        private void PopulateSubAttributes(bool isNewRecord = false, int parent = 0, int item = 0, int pageIndex = 0, int editIndex = -1)
        {
            if (this.IsNotRefresh)
            {
                this.dgAddEditSubItemAttributes.CurrentPageIndex = pageIndex;
                this.dgAddEditSubItemAttributes.EditItemIndex = editIndex;


                List<ItemAttributeBO> lstSubAttributes = (new ItemAttributeBO()).SearchObjects().Where(o => o.Parent == parent && o.Item == item && o.Parent > 0).ToList();

                if (isNewRecord || lstSubAttributes.Count == 0)
                {
                    ItemAttributeBO objSub = new ItemAttributeBO();
                    objSub.Parent = parent;
                    objSub.Item = item;
                    objSub.Name = string.Empty;
                    objSub.Description = string.Empty;

                    lstSubAttributes.Insert(0, objSub);

                    if (dgAddEditSubItemAttributes.CurrentPageIndex > Math.Floor((double)(lstSubAttributes.Count / dgAddEditSubItemAttributes.PageSize)))
                    {
                        dgAddEditSubItemAttributes.CurrentPageIndex = Convert.ToInt32(Math.Floor((double)(lstSubAttributes.Count / dgAddEditSubItemAttributes.PageSize)));
                    }

                    this.dgAddEditSubItemAttributes.EditItemIndex = 0;
                }

                this.dgAddEditSubItemAttributes.DataSource = lstSubAttributes;
                this.dgAddEditSubItemAttributes.DataBind();

                ViewState["IsSubAttribute"] = true;
                ViewState["IsPageValied"] = true;
            }
        }

        private void DeleteAttribute(int id)
        {
            //NNM
            if (id > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        ItemAttributeBO objItemAttribute = new ItemAttributeBO(this.ObjContext);
                        objItemAttribute.ID = id;
                        objItemAttribute.GetObject();

                        objItemAttribute.Delete();

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while Deleting Attribute From ViewItemAttribute.aspx", ex);
                }
            }
        }

        private void ReBindGrid()
        {
            if (Session["ItemAttributeDetails"] != null)
            {
                RadGridItemAttribute.DataSource = (List<ItemAttributesDetailsViewBO>)Session["ItemAttributeDetails"];
                RadGridItemAttribute.DataBind();
            }
        }

        #endregion

    }
}