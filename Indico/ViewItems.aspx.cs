using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Transactions;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;
using System.IO;
using System.Drawing;

namespace Indico
{
    public partial class ViewItems : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ItemsSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["ItemsSortExpression"] = value;
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

        protected void RadGridItems_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();

            ViewState["IsPopulateSubItemModel"] = false;
            ViewState["IsPopulateItemModel"] = false;
        }

        protected void RadGridItems_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();

            ViewState["IsPopulateSubItemModel"] = false;
            ViewState["IsPopulateItemModel"] = false;
        }

        protected void RadGridItems_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is ItemBO)
                {
                    ItemBO objItem = (ItemBO)item.DataItem;

                    LinkButton linkEdit = (LinkButton)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objItem.ID.ToString());

                    LinkButton linkEditSubItem = (LinkButton)item.FindControl("linkEditSubItem");
                    linkEditSubItem.Visible = false;
                    if (objItem.Parent == 0)
                    {
                        linkEditSubItem.Attributes.Add("qid", objItem.ID.ToString());
                        linkEditSubItem.Visible = true;
                    }

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objItem.ID.ToString());

                    if (objItem.ItemAttributesWhereThisIsItem.Count > 0 || objItem.ItemsWhereThisIsParent.Count > 0 ||
                        objItem.ItemMeasurementGuideImagesWhereThisIsItem.Count > 0 || objItem.MeasurementLocationsWhereThisIsItem.Count > 0)
                    {
                        linkDelete.Visible = false;
                    }

                    HtmlAnchor ancTemplateItemImage = (HtmlAnchor)item.FindControl("ancTemplateItemImage");
                    HtmlGenericControl iitemImage = (HtmlGenericControl)item.FindControl("iitemImage");
                    Literal litType = (Literal)item.FindControl("litType");

                    if ((objItem.ItemType ?? 0) > 0)
                        litType.Text = objItem.objItemType.Name;

                    if (objItem.ItemMeasurementGuideImagesWhereThisIsItem.Count > 0)
                    {
                        ItemMeasurementGuideImageBO objItemMeasurementGuide = objItem.ItemMeasurementGuideImagesWhereThisIsItem[0];

                        ancTemplateItemImage.HRef = IndicoConfiguration.AppConfiguration.DataFolderName + "/ItemMeasurementGuideImages/" + objItem.ID.ToString() + "/" + objItemMeasurementGuide.Filename + objItemMeasurementGuide.Extension;
                        if (!File.Exists(Server.MapPath(ancTemplateItemImage.HRef)))
                        {
                            ancTemplateItemImage.HRef = IndicoConfiguration.AppConfiguration.DataFolderName + "/ItemMeasurementGuideImages/noimage-png-350px-350px.gif";
                        }
                        /* else
                         {
                             ancTemplateItemImage.Title = "Item Image Not Found";
                             iitemImage.Attributes.Add("class", "icon-eye-close");
                             ancTemplateItemImage.Attributes.Add("NoImage", "true");
                         }*/

                        ancTemplateItemImage.Attributes.Add("class", "btn-link preview");
                        iitemImage.Attributes.Add("class", "icon-eye-open");

                        List<float> lstVLImageDimensions = (new ImageProcess()).GetResizedImageDimension(885, 630, 442, 315);
                        if (lstVLImageDimensions.Count > 0)
                        {

                            ancTemplateItemImage.Attributes.Add("height", lstVLImageDimensions[0].ToString());
                            ancTemplateItemImage.Attributes.Add("width", lstVLImageDimensions[1].ToString());
                            ancTemplateItemImage.Attributes.Add("NoImage", "false");
                        }
                    }
                    else
                    {
                        ancTemplateItemImage.Title = "Item Image Not Found";
                        iitemImage.Attributes.Add("class", "icon-eye-close");
                        ancTemplateItemImage.Attributes.Add("NoImage", "true");
                    }
                }
            }
        }

        protected void RadGridItems_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();

                ViewState["IsPopulateSubItemModel"] = false;
                ViewState["IsPopulateItemModel"] = false;
            }


            /* if (e.CommandName == "Edit Sub")
             {
                 int itemId = int.Parse(((System.Web.UI.WebControls.TableRow)(e.Item)).Cells[0].Text);
                 List<ItemBO> lstExistingItems = (new ItemBO()).SearchObjects().Where(o => o.Parent == 0).ToList();

                 this.ddlParentAttribute.Items.Clear();
                 this.ddlParentAttribute.Items.Add(new ListItem("Select Item", "0"));
                 foreach (ItemBO item in lstExistingItems)
                 {
                     this.ddlParentAttribute.Items.Add(new ListItem(item.Name, item.ID.ToString()));
                 }

                 this.ddlParentAttribute.Items.FindByValue(itemId.ToString()).Selected = true;
                 this.linkAddNew.Visible = true;

                 this.PopulateSubItems(false);
                 this.hdnIsNewItem.Value = "0";
             }
             else if (e.CommandName == "Edit")
             {
                 int itemId = int.Parse(((System.Web.UI.WebControls.TableRow)(e.Item)).Cells[0].Text);
                 this.PopulateItem(itemId);
                 this.hdnIsNewItem.Value = "0";
             }*/
        }

        protected void RadGridItems_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();

            ViewState["IsPopulateSubItemModel"] = false;
            ViewState["IsPopulateItemModel"] = false;
        }

        protected void HeaderContextMenu_ItemCLick(object sender, EventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridItems_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is ItemBO)
        //    {
        //        ItemBO objItem = (ItemBO)item.DataItem;

        //        //Label lblParent = (Label)item.FindControl("lblParent");
        //        //lblParent.Text = (objItem.Parent == 0) ? string.Empty : objItem.objParent.Name;

        //        //Label lblIsSubItem = (Label)item.FindControl("lblIsSubItem");
        //        //lblIsSubItem.Text = (objItem.Parent == 0) ? "No" : "Yes";

        //        LinkButton linkEdit = (LinkButton)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objItem.ID.ToString());

        //        LinkButton linkEditSubItem = (LinkButton)item.FindControl("linkEditSubItem");
        //        linkEditSubItem.Visible = false;
        //        if (objItem.Parent == 0)
        //        {
        //            linkEditSubItem.Attributes.Add("qid", objItem.ID.ToString());
        //            linkEditSubItem.Visible = true;
        //        }


        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objItem.ID.ToString());

        //        if (objItem.ItemAttributesWhereThisIsItem.Count > 0 || objItem.ItemsWhereThisIsParent.Count > 0 ||
        //            objItem.ItemMeasurementGuideImagesWhereThisIsItem.Count > 0 || objItem.MeasurementLocationsWhereThisIsItem.Count > 0)
        //        {
        //            linkDelete.Visible = false;
        //        }

        //        HtmlAnchor ancTemplateItemImage = (HtmlAnchor)item.FindControl("ancTemplateItemImage");
        //        HtmlGenericControl iitemImage = (HtmlGenericControl)item.FindControl("iitemImage");

        //        if (objItem.ItemMeasurementGuideImagesWhereThisIsItem.Count > 0)
        //        {
        //            ItemMeasurementGuideImageBO objItemMeasurementGuide = objItem.ItemMeasurementGuideImagesWhereThisIsItem[0];

        //            ancTemplateItemImage.HRef = IndicoConfiguration.AppConfiguration.DataFolderName + "/ItemMeasurementGuideImages/" + objItem.ID.ToString() + "/" + objItemMeasurementGuide.Filename + objItemMeasurementGuide.Extension;
        //            if (File.Exists(Server.MapPath(ancTemplateItemImage.HRef)))
        //            {
        //                ancTemplateItemImage.Attributes.Add("class", "btn-link preview");
        //                iitemImage.Attributes.Add("class", "icon-eye-open");

        //                List<float> lstVLImageDimensions = (new ImageProcess()).GetResizedImageDimension(885, 630, 442, 315);
        //                if (lstVLImageDimensions.Count > 0)
        //                {

        //                    ancTemplateItemImage.Attributes.Add("height", lstVLImageDimensions[0].ToString());
        //                    ancTemplateItemImage.Attributes.Add("width", lstVLImageDimensions[1].ToString());
        //                    ancTemplateItemImage.Attributes.Add("NoImage", "false");
        //                }
        //            }
        //            else
        //            {
        //                ancTemplateItemImage.Title = "Item Image Not Found";
        //                iitemImage.Attributes.Add("class", "icon-eye-close");
        //                ancTemplateItemImage.Attributes.Add("NoImage", "true");
        //            }
        //        }
        //        else
        //        {
        //            ancTemplateItemImage.Title = "Item Image Not Found";
        //            iitemImage.Attributes.Add("class", "icon-eye-close");
        //            ancTemplateItemImage.Attributes.Add("NoImage", "true");
        //        }
        //    }
        //}

        //protected void dataGridItems_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridItems.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dataGridItems_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dataGridItems.Columns)
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

        //protected void dataGridItems_ItemCommand(object sender, DataGridCommandEventArgs e)
        //{
        //    if (e.CommandName == "Edit Sub")
        //    {
        //        int itemId = int.Parse(((System.Web.UI.WebControls.TableRow)(e.Item)).Cells[0].Text);
        //        List<ItemBO> lstExistingItems = (new ItemBO()).SearchObjects().Where(o => o.Parent == 0).ToList();

        //        this.ddlParentAttribute.Items.Clear();
        //        this.ddlParentAttribute.Items.Add(new ListItem("Select Item", "0"));
        //        foreach (ItemBO item in lstExistingItems)
        //        {
        //            this.ddlParentAttribute.Items.Add(new ListItem(item.Name, item.ID.ToString()));
        //        }

        //        this.ddlParentAttribute.Items.FindByValue(itemId.ToString()).Selected = true;
        //        this.linkAddNew.Visible = true;

        //        this.PopulateSubItems(false);
        //        this.hdnIsNewItem.Value = "0";
        //    }
        //    else if (e.CommandName == "Edit")
        //    {
        //        int itemId = int.Parse(((System.Web.UI.WebControls.TableRow)(e.Item)).Cells[0].Text);
        //        this.PopulateItem(itemId);
        //        this.hdnIsNewItem.Value = "0";
        //    }
        //}

        protected void dgAddEditSubItem_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if ((item.ItemIndex > -1 && item.DataItem is ItemBO) && (item.ItemType == ListItemType.Item || item.ItemType == ListItemType.AlternatingItem))
            {
                ItemBO objItem = (ItemBO)item.DataItem;

                bool canDelete = (objItem.ItemAttributesWhereThisIsItem.Count == 0 &&
                                  objItem.ItemMeasurementGuideImagesWhereThisIsItem.Count == 0 &&
                                  objItem.ItemsWhereThisIsParent.Count == 0 &&
                                  objItem.MeasurementLocationsWhereThisIsItem.Count == 0 &&
                                  objItem.PatternsWhereThisIsItem.Count == 0 &&
                                  objItem.PatternsWhereThisIsSubItem.Count == 0 &&
                                  objItem.HSCodesWhereThisIsItemSubCategory.Count == 0);

                Literal lblID = (Literal)item.FindControl("lblID");
                lblID.Text = objItem.ID.ToString();

                Literal lblItemName = (Literal)item.FindControl("lblItemName");
                lblItemName.Text = objItem.Name.ToString();

                Literal lblItemDescription = (Literal)item.FindControl("lblItemDescription");
                lblItemDescription.Text = objItem.Description;

                LinkButton linkEdit = (LinkButton)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objItem.ID.ToString());

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objItem.ID.ToString());
                linkDelete.Visible = canDelete;
            }
            else if ((item.ItemIndex > -1 && item.DataItem is ItemBO) && (item.ItemType == ListItemType.EditItem))
            {
                ItemBO objItem = (ItemBO)item.DataItem;

                Literal lblID = (Literal)item.FindControl("lblID");
                lblID.Text = objItem.ID.ToString();

                TextBox txtItemDescription = (TextBox)item.FindControl("txtItemDescription");
                txtItemDescription.Text = objItem.Description.ToString();
                this.hdnSubItemDescription.Value = txtItemDescription.Text;

                TextBox txtItemName = (TextBox)item.FindControl("txtItemName");
                txtItemName.Text = objItem.Name;
                this.hdnSubItemName.Value = txtItemName.Text;

                LinkButton linkSave = (LinkButton)item.FindControl("linkSave");
                linkSave.Attributes.Add("qid", objItem.ID.ToString());
                linkSave.CommandName = (!string.IsNullOrEmpty(this.hdnSubItemName.Value) || (!string.IsNullOrEmpty(this.hdnSubItemDescription.Value))) ? "Update" : "Save";
            }
        }

        protected void dgAddEditSubItem_ItemCommand(object sender, DataGridCommandEventArgs e)
        {
            //Page.Validate();

            //if (Page.IsValid)
            //{
            switch (e.CommandName)
            {
                case "Save":
                    this.ProcessItems(true, true);
                    this.PopulateSubItems(false);
                    break;
                case "Update":
                    this.ProcessItems(false, true);
                    this.PopulateSubItems(false);
                    break;
                case "Delete":
                    break;
                case "Edit":
                    this.PopulateSubItems(false, e.Item.ItemIndex, ((System.Web.UI.WebControls.DataGrid)(sender)).CurrentPageIndex);
                    break;
                default:
                    break;
                //}
            }
        }

        /*protected void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }*/

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (Page.IsValid)
                {
                    this.ProcessItems((this.hdnIsNewItem.Value == "1"), false);
                    Response.Redirect("/ViewItems.aspx");
                }
                // Popup Header Text
                //this.lblPopupHeaderText.Text = ((queryId > 0) ? "Edit " : "New ") + "Items";
                ViewState["IsPageValied"] = (Page.IsValid);
            }
            else
            {
                ViewState["IsPageValied"] = true;
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int queryId = int.Parse(this.hdnSelectedItemID.Value.Trim());
            this.DeleteItem(queryId);

            if (bool.Parse(ViewState["IsPopulateSubItemModel"].ToString()))
                this.PopulateSubItems(false);
            else
                this.PopulateDataGrid();
        }

        protected void btnDeleteItemImg_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int imageID = int.Parse(this.hdnEditMode.Value);
                // int itemID = int.Parse(this.hdnSelectedID.Value);
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        ItemMeasurementGuideImageBO objItemMeasureGuide = new ItemMeasurementGuideImageBO(this.ObjContext);
                        objItemMeasureGuide.ID = imageID;
                        objItemMeasureGuide.GetObject();
                        objItemMeasureGuide.Delete();

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                    string filePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\ItemMeasurementGuideImages\\" + ViewState["ItemID"].ToString();
                    if (Directory.Exists(filePath))
                    {
                        Directory.Delete(filePath, true);
                    }
                    this.PopulateItemImage(int.Parse(ViewState["ItemID"].ToString()));

                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while Deleting the Item Image", ex);
                }
                ViewState["IsPageValied"] = true;
            }
            else
            {
                ViewState["IsPageValied"] = true;
            }
            this.PopulateDataGrid();
        }

        protected void btnEditImage_Click(object sender, EventArgs e)
        {
            // Populate Item Image Guide             
            ViewState["ItemID"] = (int.Parse(this.hdnSelectedID.Value) != 0) ? int.Parse(this.hdnSelectedID.Value) : 0;
            this.PopulateItemImage(int.Parse(ViewState["ItemID"].ToString()));
            ViewState["IsPageValied"] = false;
        }

        protected void linkAddNew_Click(object sender, EventArgs e)
        {
            this.PopulateSubItems(true);
        }

        protected void ddlParentAttribute_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (this.ddlParentAttribute.SelectedIndex > 0)
            {
                this.PopulateSubItems(false);
                this.linkAddNew.Visible = true;
            }
            else
            {
                this.linkAddNew.Visible = false;
                this.dgAddEditSubItem.DataSource = null;
                this.dgAddEditSubItem.DataBind();
            }
        }

        protected void btnAddItem_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                this.txtItemName.Text = string.Empty;
                this.ddlItemType.SelectedIndex = -1;
                this.txtDescription.Text = string.Empty;
                this.dvItemImageGuide.Visible = false;

                this.hdnIsNewItem.Value = "1";
                ViewState["IsPopulateItemModel"] = true;
            }
            else
            {
                ViewState["IsPopulateItemModel"] = false;
            }

        }

        protected void linkEdit_Click(object sender, EventArgs e)
        {
            int itemId = int.Parse(this.hdnSelectedItemID.Value);
            if (itemId > 0)
            {
                this.PopulateItem(itemId);
                this.hdnIsNewItem.Value = "0";
            }
        }

        protected void linkEditSubItem_Click(object sender, EventArgs e)
        {
            int itemId = int.Parse(this.hdnItemSub.Value);

            if (itemId > 0)
            {

                List<ItemBO> lstExistingItems = (new ItemBO()).SearchObjects().Where(o => o.Parent == 0).ToList();

                this.ddlParentAttribute.Items.Clear();
                this.ddlParentAttribute.Items.Add(new ListItem("Select Item", "0"));
                foreach (ItemBO item in lstExistingItems)
                {
                    this.ddlParentAttribute.Items.Add(new ListItem(item.Name, item.ID.ToString()));
                }

                this.ddlParentAttribute.Items.FindByValue(itemId.ToString()).Selected = true;
                this.linkAddNew.Visible = true;

                this.PopulateSubItems(false);
                this.hdnIsNewItem.Value = "0";
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
            this.litHeaderText.Text = "Items"; //this.ActivePage.Heading;

            // Popup Header Text
            this.lblPopupSubItemHeaderText.Text = "New Items";

            ViewState["IsPageValied"] = true;
            ViewState["IsPopulateSubItemModel"] = false;
            ViewState["IsPopulateItemModel"] = false;
            Session["ItemsDetails"] = null;

            // Populate popup parent attribute items dropdown

            /*this.ddlParentAttribute.Items.Add(new ListItem("Select an Item", "0"));
            foreach (ItemBO parentItem in (new ItemBO()).SearchObjects().OrderBy(o => o.Name))
            {
                this.ddlParentAttribute.Items.Add(new ListItem(parentItem.Name, parentItem.ID.ToString()));
            }*/

            this.PopulateDataGrid();
            this.PopulateItemType();

            //hide columns
            this.RadGridItems.MasterTableView.GetColumn("ID").Display = false;
            this.RadGridItems.MasterTableView.GetColumn("Description").Display = false;
            this.RadGridItems.MasterTableView.GetColumn("Parent").Display = false;
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
            ItemBO objItem = new ItemBO();



            List<ItemBO> lstItems = new List<ItemBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstItems = (from o in objItem.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                            where o.Name.ToLower().Contains(searchText) &&
                                 (o.Parent == 0)
                            select o).ToList();
                //lstItems = objItem.SearchObjects().AsQueryable().OrderBy(SortExpression).Where(o => o.Parent == 0 && o.Name.ToLower().Contains(searchText)).ToList();
            }
            else
            {
                lstItems = objItem.SearchObjects().AsQueryable().OrderBy(SortExpression).Where(o => o.Parent == 0).ToList();
            }

            // Sort by condition
            //int sortbyStatus = int.Parse(this.ddlSortBy.SelectedItem.Value);

            //if (sortbyStatus == 1)
            //{
            //    lstItems = (from o in lstItems
            //                where o.Parent == 0
            //                select o).ToList();
            //}
            //else if (sortbyStatus == 0)
            //{

            //    lstItems = (from o in lstItems
            //                where o.Parent > 0
            //                select o).ToList();
            //}


            if (lstItems.Count > 0)
            {
                this.RadGridItems.AllowPaging = (lstItems.Count > this.RadGridItems.PageSize);
                this.RadGridItems.DataSource = lstItems;
                this.RadGridItems.DataBind();
                Session["ItemsDetails"] = lstItems;

                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search") /*|| (sortbyStatus < 2)*/)
            {
                //this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty) + "Filter by " + this.ddlSortBy.SelectedItem.Text;

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyContent.Visible = true;
                this.btnAddItem.Visible = false;

            }

            ViewState["IsPopulateSubItemModel"] = false;
            ViewState["IsPopulateItemModel"] = false;
            this.RadGridItems.Visible = (lstItems.Count > 0);
        }

        private void PopulateItemType()
        {
            this.ddlItemType.Items.Clear();
            this.ddlItemType.Items.Add(new ListItem("Select Item Type..", "0"));

            List<ItemTypeBO> lstItemTypes = new ItemTypeBO().SearchObjects();

            foreach (ItemTypeBO objType in lstItemTypes)
            {
                this.ddlItemType.Items.Add(new ListItem(objType.Name, objType.ID.ToString()));
            }
        }

        private void PopulateItemImage(int itemID)
        {
            string destinationFolderPath = string.Empty;
            if (itemID > 0)
            {
                List<ItemMeasurementGuideImageBO> lstItemMeasurementGuide = (from o in (new ItemMeasurementGuideImageBO()).SearchObjects().Where(o => o.Item == itemID) select o).ToList();
                if (lstItemMeasurementGuide.Count > 0)
                {
                    this.liitemImage.Attributes.Add("style", "display: none;");
                    this.liuploadTable.Attributes.Add("style", "display: none;");
                    this.liUploder.Attributes.Add("style", "display: none;");
                    this.dvItemImageGuide.Visible = true;
                    linkDeleteItemImage.Attributes.Add("imageID", lstItemMeasurementGuide[0].ID.ToString());
                    destinationFolderPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/ItemMeasurementGuideImages/" + itemID + "/" + lstItemMeasurementGuide[0].Filename + lstItemMeasurementGuide[0].Extension;

                    if (!File.Exists(Server.MapPath(destinationFolderPath)))
                    {
                        destinationFolderPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/ItemMeasurementGuideImages/noimage-png-350px-350px.gif";
                    }
                    System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + destinationFolderPath);
                    SizeF origImageSize = VLOrigImage.PhysicalDimension;
                    VLOrigImage.Dispose();

                    List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 250, 140);
                    imgItemImage.Width = int.Parse(lstImgDimensions[1].ToString());
                    imgItemImage.Height = int.Parse(lstImgDimensions[0].ToString());
                    this.imgItemImage.ImageUrl = destinationFolderPath;


                }
                else
                {
                    this.liitemImage.Attributes.Add("style", "display: block;");
                    this.liuploadTable.Attributes.Add("style", "display: block;");
                    this.liUploder.Attributes.Add("style", "display: block;");
                    this.dvItemImageGuide.Visible = false;
                }
            }
            else
            {
                this.dvItemImageGuide.Visible = false;
            }
        }

        private void PopulateSubItems(bool addNewRecorde)
        {
            this.PopulateSubItems(addNewRecorde, -1, 0);
        }

        private void PopulateSubItems(bool addNewRecorde, int editItemIndex, int currentPateIndex)
        {
            if (this.IsNotRefresh)
            {

                this.dgAddEditSubItem.CurrentPageIndex = currentPateIndex;
                this.dgAddEditSubItem.EditItemIndex = editItemIndex;

                ItemBO obj = new ItemBO();
                obj.Parent = int.Parse(this.ddlParentAttribute.SelectedValue.ToString());

                List<ItemBO> lstEmptyList = obj.SearchObjects().OrderBy(o => o.Name).ToList();

                if (addNewRecorde || lstEmptyList.Count == 0)
                {
                    ItemBO objItem = new ItemBO();
                    objItem.ID = 0;
                    objItem.Parent = int.Parse(this.ddlParentAttribute.SelectedValue.ToString());
                    objItem.Name = string.Empty;
                    objItem.Description = string.Empty;

                    lstEmptyList.Insert(0, objItem);

                    if (dgAddEditSubItem.CurrentPageIndex > Math.Floor((double)(lstEmptyList.Count / dgAddEditSubItem.PageSize)))
                        dgAddEditSubItem.CurrentPageIndex = Convert.ToInt32(Math.Floor((double)(lstEmptyList.Count / dgAddEditSubItem.PageSize)));
                    this.dgAddEditSubItem.EditItemIndex = 0;//lstEmptyList.Count - 1;
                }

                this.dgAddEditSubItem.DataSource = lstEmptyList;
                //this.dgAddEditSizes.AllowPaging = (lstEmptyList.Count > dgAddEditSizes.PageSize);
                this.dgAddEditSubItem.DataBind();

                ViewState["IsPopulateSubItemModel"] = true;
                ViewState["IsPopulateItemModel"] = false;
            }
            else
            {
                ViewState["IsPopulateSubItemModel"] = false;
                ViewState["IsPopulateItemModel"] = false;
            }
        }

        private void PopulateItem(int itemId)
        {
            if (this.IsNotRefresh)
            {
                ItemBO objItem = new ItemBO();
                objItem.ID = itemId;
                objItem.GetObject();

                this.txtItemName.Text = objItem.Name;
                this.ddlItemType.ClearSelection();
                this.ddlItemType.Items.FindByValue(objItem.ItemType.ToString()).Selected = true;
                this.txtDescription.Text = objItem.Description;
                this.PopulateItemImage(itemId);

                ViewState["IsPopulateSubItemModel"] = false;
                ViewState["IsPopulateItemModel"] = true;
            }
            else
            {
                ViewState["IsPopulateSubItemModel"] = false;
                ViewState["IsPopulateItemModel"] = false;
            }

        }

        /// <summary>
        /// Process the page data.
        /// </summary> 
        ///    
        /*private void ProcessForm(int queryId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    ItemBO objItem = new ItemBO(this.ObjContext);
                    if (queryId > 0)
                    {
                        objItem.ID = queryId;
                        objItem.GetObject();
                    }

                    if (isDelete)
                    {
                        objItem.Delete();
                    }
                    else
                    {
                        objItem.Name = this.txtItemName.Text;
                        objItem.Description = this.txtDescription.Text;
                        objItem.Parent = int.Parse(this.ddlParentAttribute.SelectedItem.Value);
                        if (queryId == 0)
                        {
                            objItem.Add();
                        }
                    }

                    #region ItemMeasurementGuideImages

                    if (this.hdnItemImage.Value != "0")
                    {
                        try
                        {
                            int n = 0;

                            foreach (string fileName in this.hdnItemImage.Value.Split('|').Select(o => o.Split(',')[0]))
                            {
                                if (fileName != string.Empty)
                                {
                                    n++;
                                    ItemMeasurementGuideImageBO objItemMeasurementImage = new ItemMeasurementGuideImageBO(this.ObjContext);
                                    objItemMeasurementImage.Size = (int)(new FileInfo(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileName)).Length;
                                    objItemMeasurementImage.Filename = Path.GetFileNameWithoutExtension(fileName);
                                    objItemMeasurementImage.Extension = Path.GetExtension(fileName);
                                    objItem.ItemMeasurementGuideImagesWhereThisIsItem.Add(objItemMeasurementImage);
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            IndicoLogging.log.Error("Error occured while saving ItemMeasureMentGuideImage", ex);
                        }
                    }

                    #endregion

                    this.ObjContext.SaveChanges();
                    ts.Complete();

                    #region Copy ItemMeasureMentGuideImage

                    string sourceFileLocation = string.Empty;
                    string destinationFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\ItemMeasurementGuideImages\\" + objItem.ID.ToString();

                    foreach (string fileName in this.hdnItemImage.Value.Split('|').Select(o => o.Split(',')[0]))
                    {
                        sourceFileLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileName;

                        if (fileName != string.Empty)
                        {
                            if (File.Exists(destinationFolderPath + "\\" + fileName))
                            {
                                File.Delete(destinationFolderPath + "\\" + fileName);
                            }
                            else
                            {
                                if (!Directory.Exists(destinationFolderPath))
                                    Directory.CreateDirectory(destinationFolderPath);
                                File.Copy(sourceFileLocation, destinationFolderPath + "\\" + fileName);
                            }
                        }
                    }

                    #endregion
                }
            }
            catch (Exception ex)
            {
                // Log the error
                //IndicoLogging.log("Error occured while Adding the Item", ex);
            }
        }*/

        private void ProcessItems(bool isNewItem, bool isSubItem)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    ItemBO objItem = new ItemBO(this.ObjContext);

                    if (!isNewItem)
                    {
                        objItem.ID = int.Parse(this.hdnSelectedItemID.Value);
                        objItem.GetObject();
                    }
                    if (isSubItem)
                    {
                        objItem.Parent = int.Parse(this.ddlParentAttribute.SelectedValue);
                    }
                    else
                    {
                        #region ItemMeasurementGuideImages

                        if (this.hdnItemImage.Value != "0")
                        {
                            try
                            {
                                int n = 0;

                                foreach (string fileName in this.hdnItemImage.Value.Split('|').Select(o => o.Split(',')[0]))
                                {
                                    if (fileName != string.Empty)
                                    {
                                        n++;
                                        ItemMeasurementGuideImageBO objItemMeasurementImage = new ItemMeasurementGuideImageBO(this.ObjContext);
                                        objItemMeasurementImage.Size = (int)(new FileInfo(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileName)).Length;
                                        objItemMeasurementImage.Filename = Path.GetFileNameWithoutExtension(fileName);
                                        objItemMeasurementImage.Extension = Path.GetExtension(fileName);
                                        objItem.ItemMeasurementGuideImagesWhereThisIsItem.Add(objItemMeasurementImage);
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                IndicoLogging.log.Error("Error occured while saving ItemMeasureMentGuideImage", ex);
                            }
                        }

                        #endregion
                    }

                    objItem.Name = (!isSubItem) ? this.txtItemName.Text : this.hdnSubItemName.Value.ToString();
                    objItem.ItemType = int.Parse(this.ddlItemType.SelectedValue);
                    objItem.Description = (!isSubItem) ? this.txtDescription.Text : this.hdnSubItemDescription.Value.ToString();
                    if (isNewItem)
                        objItem.Add();

                    this.ObjContext.SaveChanges();
                    ts.Complete();

                    #region Copy ItemMeasureMentGuideImage

                    if (!isSubItem)
                    {
                        string sourceFileLocation = string.Empty;
                        string destinationFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\ItemMeasurementGuideImages\\" + objItem.ID.ToString();

                        foreach (string fileName in this.hdnItemImage.Value.Split('|').Select(o => o.Split(',')[0]))
                        {
                            sourceFileLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileName;

                            if (fileName != string.Empty)
                            {
                                if (File.Exists(destinationFolderPath + "\\" + fileName))
                                {
                                    File.Delete(destinationFolderPath + "\\" + fileName);
                                }
                                else
                                {
                                    if (!Directory.Exists(destinationFolderPath))
                                        Directory.CreateDirectory(destinationFolderPath);
                                    File.Copy(sourceFileLocation, destinationFolderPath + "\\" + fileName);
                                }
                            }
                        }
                    }

                    #endregion

                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while processing Item", ex);
            }
        }

        private void DeleteItem(int item)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    ItemBO objItem = new ItemBO(this.ObjContext);
                    if (item > 0)
                    {
                        objItem.ID = item;
                        objItem.GetObject();

                        /*if (objItem.ItemAttributesWhereThisIsItem.Count > 0)
                        {
                            foreach (ItemAttributeBO itemAttr in objItem.ItemAttributesWhereThisIsItem.ToList())
                            {
                                ItemAttributeBO objItemAttribute = new ItemAttributeBO(this.ObjContext);
                                objItemAttribute.ID = itemAttr.ID;
                                objItemAttribute.GetObject();

                                objItemAttribute.Delete();
                            }
                            this.ObjContext.SaveChanges();
                        }

                        if (objItem.ItemMeasurementGuideImagesWhereThisIsItem.Count > 0)
                        {
                            foreach (ItemMeasurementGuideImageBO imgi in objItem.ItemMeasurementGuideImagesWhereThisIsItem.ToList())
                            {
                                ItemMeasurementGuideImageBO objImgi = new ItemMeasurementGuideImageBO(this.ObjContext);
                                objImgi.ID = imgi.ID;
                                objImgi.GetObject();

                                objImgi.Delete();
                            }
                            this.ObjContext.SaveChanges();
                        }*/
                        objItem.Delete();
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Deleting the Item", ex);
            }
        }

        private void ReBindGrid()
        {
            if (Session["ItemsDetails"] != null)
            {
                RadGridItems.DataSource = (List<ItemBO>)Session["ItemsDetails"];
                RadGridItems.DataBind();
            }
        }

        #endregion
    }
}