using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Linq.Dynamic;
using System.Transactions;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class ViewSizes : IndicoPage
    {
        #region Fields

        private List<SizeBO> lstSizes = null;

        int selectedValue = 0;


        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["SizesSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "SizeSet";
                }
                return sort;
            }
            set
            {
                ViewState["SizesSortExpression"] = value;
            }
        }

        private List<SizeBO> Sizes
        {
            get
            {
                if (Session["sizes"] != null)
                {
                    lstSizes = (List<SizeBO>)Session["sizes"];
                }
                else
                {
                    lstSizes = new List<SizeBO>();
                    Session["sizes"] = lstSizes;
                }
                return lstSizes;
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
            this.hdnIsNewSizeSet.Value = "0";

            if (!this.IsPostBack)
            {
                PopulateControls();
            }
        }

        protected void RadGridSize_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridSize_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridSize_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is SizeSetBO)
                {
                    SizeSetBO objSizeSets = (SizeSetBO)item.DataItem;

                    Literal litName = (Literal)item.FindControl("litName");
                    litName.Text = objSizeSets.Name;

                    Literal litDescription = (Literal)item.FindControl("litDescription");
                    litDescription.Text = objSizeSets.Description;

                    HiddenField hdnSizeSet = (HiddenField)item.FindControl("hdnSizeSet");
                    hdnSizeSet.Value = objSizeSets.ID.ToString();

                    LinkButton linkEdit = (LinkButton)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objSizeSets.ID.ToString());

                }
            }
        }

        protected void RadGridSize_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }

            //if (e.CommandName == "Edit")
            //{
            //    List<SizeSetBO> lstExistingItems = (new SizeBO()).SearchObjects().GroupBy(o => o.SizeSet).Select(m => m.First().objSizeSet).ToList();

            //    this.ddlSizeSet.Items.Clear();
            //    this.ddlSizeSet.Items.Add(new ListItem("Select Size Set", "0"));
            //    foreach (SizeSetBO item in lstExistingItems)
            //    {
            //        this.ddlSizeSet.Items.Add(new ListItem(item.Name, item.ID.ToString()));
            //    }

            //    HiddenField hdnSizeSet = (HiddenField)e.Item.FindControl("hdnSizeSet");
            //    string val = hdnSizeSet.Value;

            //    this.ddlSizeSet.Items.FindByValue(val).Selected = true;
            //    this.linkAddNew.Visible = true;

            //    this.PopulateSizeSet(false);
            //    this.hdnIsNewSizeSet.Value = "0";

            //    this.ReBindGrid();
            //}
        }

        protected void RadGridSize_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridSizeSets_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is SizeSetBO)
        //    {
        //        SizeSetBO objSizeSets = (SizeSetBO)item.DataItem;

        //        LinkButton linkEdit = (LinkButton)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objSizeSets.ID.ToString());
        //    }
        //}

        //protected void dataGridSizeSets_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dataGridSizeSets.Columns)
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
        //}

        //protected void dataGridSizeSets_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //     Set page index
        //    this.dataGridSizeSets.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dataGridSizeSets_ItemCommand(object sender, DataGridCommandEventArgs e)
        //{
        //    if (e.CommandName == "Edit")
        //    {
        //        List<SizeSetBO> lstExistingItems = (new SizeBO()).SearchObjects().GroupBy(o => o.SizeSet).Select(m => m.First().objSizeSet).ToList();

        //        this.ddlSizeSet.Items.Clear();
        //        this.ddlSizeSet.Items.Add(new ListItem("Select Size Set", "0"));
        //        foreach (SizeSetBO item in lstExistingItems)
        //        {
        //            this.ddlSizeSet.Items.Add(new ListItem(item.Name, item.ID.ToString()));
        //        }

        //        this.ddlSizeSet.Items.FindByValue(((System.Web.UI.WebControls.TableRow)(e.Item)).Cells[0].Text).Selected = true;
        //        this.linkAddNew.Visible = true;

        //        this.PopulateSizeSet(false);
        //        this.hdnIsNewSizeSet.Value = "0";
        //    }
        //}

        protected void dgAddEditSizes_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            //if ((item.ItemIndex > -1 && item.DataItem is SizeBO) && (item.ItemType == ListItemType.Item || item.ItemType == ListItemType.AlternatingItem))
            if (item.ItemIndex > -1 && item.DataItem is KeyValuePair<int, SizeBO>)
            {
                KeyValuePair<int, SizeBO> objSize = (KeyValuePair<int, SizeBO>)item.DataItem;
                bool canDelete = true;

                if (objSize.Key > 0)
                {
                    //bool canDelete = (objSize.OrderDetailQtysWhereThisIsSize.Count == 0 && objSize.SizeChartsWhereThisIsSize.Count == 0);
                    OrderDetailQtyBO objODQ = new OrderDetailQtyBO();
                    objODQ.Size = objSize.Key;

                    SizeChartBO objSC = new SizeChartBO();
                    objSC.Size = objSize.Key;
                    canDelete = !(objSC.SearchObjects().Any() || objODQ.SearchObjects().Any());
                }

                /*CheckBox chkIsDefault = (CheckBox)item.FindControl("chkIsDefault");
                chkIsDefault.Checked = objSize.IsDefault;
                chkIsDefault.Enabled = false;

                Literal lblID = (Literal)item.FindControl("lblID");
                lblID.Text = objSize.ID.ToString();

                Literal lblSeqNo = (Literal)item.FindControl("lblSeqNo");
                lblSeqNo.Text = objSize.SeqNo.ToString();

                Literal lblSizeName = (Literal)item.FindControl("lblSizeName");
                lblSizeName.Text = objSize.SizeName;

                LinkButton linkEdit = (LinkButton)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objSize.ID.ToString());*/

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objSize.Key.ToString());
                linkDelete.Visible = canDelete;
                /*}
                else if ((item.ItemIndex > -1 && item.DataItem is SizeBO) && (item.ItemType == ListItemType.EditItem))
                {
                    SizeBO objSize = (SizeBO)item.DataItem;*/

                CheckBox chkIsDefault = (CheckBox)item.FindControl("chkIsDefault");
                chkIsDefault.Checked = objSize.Value.IsDefault;
                chkIsDefault.Enabled = true;

                Literal lblID = (Literal)item.FindControl("lblID");
                lblID.Text = objSize.Key.ToString();

                TextBox txtSeqNo = (TextBox)item.FindControl("txtSeqNo");
                txtSeqNo.Text = objSize.Value.SeqNo.ToString();
                this.hdnSeqNo.Value = txtSeqNo.Text;

                TextBox txtSizeName = (TextBox)item.FindControl("txtSizeName");
                txtSizeName.Text = objSize.Value.SizeName;
                this.hdnSizeName.Value = txtSizeName.Text;

                //LinkButton linkSave = (LinkButton)item.FindControl("linkSave");
                //linkSave.Attributes.Add("qid", objSize.ID.ToString());
                //linkSave.CommandName = (!string.IsNullOrEmpty(hdnSizeName.Value) || (int.Parse(this.hdnSeqNo.Value) > 0)) ? "Update" : "Save";
            }
        }

        protected void dgAddEditSizes_ItemCommand(object sender, DataGridCommandEventArgs e)
        {
            //Page.Validate();

            //if (Page.IsValid)
            //{
            //switch (e.CommandName)
            //{
            //    case "Save":
            //        this.ProcessSizeSet(true);
            //        this.PopulateSizeSet(false);
            //        break;
            //    case "Update":
            //        this.ProcessSizeSet(false);
            //        this.PopulateSizeSet(false);
            //        break;
            //    case "Delete":

            //        break;
            //    case "Edit":
            //        this.PopulateSizeSet(false, e.Item.ItemIndex, ((System.Web.UI.WebControls.DataGrid)(sender)).CurrentPageIndex);
            //        break;
            //    default:
            //        break;
            //    //}
            //}
        }

        /*protected void dgAddEditSizes_PageIndexChange(object sender, DataGridPageChangedEventArgs e)
        {
            this.PopulateSizeSet(false, -1, e.NewPageIndex);
        }*/

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                this.PopulateDataGrid();
            }
            ViewState["IsPageValid"] = true;
            ViewState["IsPopulateModel"] = false;
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                //int queryId = int.Parse(this.hdnSelectedSizeID.Value.Trim());
                int queryId = 0;

                int.TryParse(this.hdnSizeSetID.Value.Trim(), out queryId);

                if (Page.IsValid)
                {
                    this.ProcessForm(queryId, false);
                    ResetPageTemporaryValues();
                }
                //Session.Remove("sizes");                
                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnAddSizes_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                this.ddlSizeSet.Items.Clear();
                this.ddlSizeSet.Items.Add(new ListItem("Select Size Set", "0"));

                List<int> lstExistingItems = (new SizeBO()).SearchObjects().GroupBy(o => o.SizeSet).Select(m => m.First().SizeSet).ToList();
                List<int> lstNewItems = (new SizeSetBO()).SearchObjects().Select(o => o.ID).Except(lstExistingItems).ToList();

                foreach (int item in lstNewItems)
                {
                    SizeSetBO objSizeSet = new SizeSetBO();
                    objSizeSet.ID = item;
                    objSizeSet.GetObject();

                    this.ddlSizeSet.Items.Add(new ListItem(objSizeSet.Name, objSizeSet.ID.ToString()));
                }

                this.dgAddEditSizes.DataSource = null;
                this.dgAddEditSizes.DataBind();

                this.hdnIsNewSizeSet.Value = "1";
                ViewState["IsPopulateModel"] = true;
            }
            else
            {
                ViewState["IsPopulateModel"] = false;
            }

        }

        protected void ddlSizeSet_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (this.ddlSizeSet.SelectedIndex > 0)
                {
                    this.PopulateSizeSet(false);
                    this.linkAddNew.Visible = true;
                }
                else
                {
                    this.linkAddNew.Visible = false;
                    this.dgAddEditSizes.DataSource = null;
                    this.dgAddEditSizes.DataBind();
                }
                ViewState["IsPopulateModel"] = true;
            }
            else
            {
                ViewState["IsPopulateModel"] = false;
            }
        }

        protected void linkAddNew_Click(object sender, EventArgs e)
        {
            this.PopulateSizeSet(true);
        }

        /*protected void ddlSizes_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }*/

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int queryId = int.Parse(this.hdnSelectedSizeID.Value.Trim());
            this.DeleteSize(queryId);
            this.PopulateSizeSet(false);
        }

        protected void linkEdit_Click(object sender, EventArgs e)
        {
            List<SizeSetBO> lstExistingItems = (new SizeSetBO()).SearchObjects();  //(new SizeBO()).SearchObjects().GroupBy(o => o.SizeSet).Select(m => m.First().objSizeSet).ToList();

            this.ddlSizeSet.Items.Clear();
            this.ddlSizeSet.Items.Add(new ListItem("Select Size Set", "0"));
            foreach (SizeSetBO item in lstExistingItems)
            {
                this.ddlSizeSet.Items.Add(new ListItem(item.Name, item.ID.ToString()));
            }

            //HiddenField hdnSizeSet = (HiddenField)e.Item.FindControl("hdnSizeSet");
            string val = this.hdnSizeSetID.Value; //hdnSizeSet.Value;

            this.ddlSizeSet.Items.FindByValue(val).Selected = true;
            this.linkAddNew.Visible = true;

            this.PopulateSizeSet(false);
            this.hdnIsNewSizeSet.Value = "0";

            //this.ReBindGrid();
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
            this.lblPopupHeaderText.Text = "New Size";

            Session["sizes"] = null;
            ViewState["IsPageValied"] = true;
            ViewState["IsPopulateModel"] = false;

            // Populate popup SizeSet dropdown
            this.ddlSizeSet.Items.Add(new ListItem("Select an SizeSet", "0"));
            //this.ddlFilterSizeSet.Items.Add(new ListItem("All", "0"));

            foreach (SizeSetBO SizeSet in (new SizeSetBO()).SearchObjects())
            {
                this.ddlSizeSet.Items.Add(new ListItem(SizeSet.Name.ToString(), SizeSet.ID.ToString()));
                //this.ddlFilterSizeSet.Items.Add(new ListItem(SizeSet.Name, SizeSet.ID.ToString()));
            }

            Session["SizeDetails"] = null;

            // populate data grid
            this.PopulateDataGrid();
        }

        private void PopulateSize(int sizeSetId)
        {
            SizeSetBO objSizeSet = new SizeSetBO();
            objSizeSet.ID = sizeSetId;
            objSizeSet.GetObject();

            foreach (SizeBO size in objSizeSet.SizesWhereThisIsSizeSet)
            {
                if (this.Sizes.Where(o => o.ID == size.ID).ToList().Count == 0)
                {
                    this.Sizes.Add(size);
                    Session["sizes"] = this.Sizes;
                }
            }

            if (this.Sizes.Count > 0)
            {
                this.dgAddEditSizes.DataSource = this.Sizes;
                dgAddEditSizes.EditItemIndex = 0;
                this.dgAddEditSizes.DataBind();
            }

            if (this.Sizes.Count == 0)
            {
                //this.dvEmptyContentAccessory.Attributes.Add("style", "display:block");
            }
            else
            {
                //this.dvEmptyContentAccessory.Attributes.Add("style", "display:none");
            }
            dvAddEditSizes.Visible = (this.Sizes.Count > 0);
        }

        private void PopulateDataGrid()
        {
            this.dvDataContent.Visible = false;
            this.dvEmptyContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            string searchText = this.txtSearch.Text.ToLower().Trim();

            SizeSetBO objSize = new SizeSetBO();
            List<SizeSetBO> lstSizeSets = new List<SizeSetBO>();

            if (txtSearch.Text != string.Empty && txtSearch.Text != "search")
            {
                lstSizeSets = objSize.SearchObjects().Where(o => o.Name.ToLower().Contains(searchText) || (o.Description != null && o.Description.ToLower().Contains(searchText))).ToList();
            }
            else
            {
                lstSizeSets = objSize.SearchObjects().ToList();
            }

            if (lstSizeSets.Count > 0)
            {
                this.RadGridSize.AllowPaging = (lstSizeSets.Count > this.RadGridSize.PageSize);
                this.RadGridSize.DataSource = lstSizeSets;
                this.RadGridSize.DataBind();
                Session["SizeDetails"] = lstSizeSets;

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
                this.btnAddSizes.Visible = false;
            }

            this.RadGridSize.Visible = (lstSizeSets.Count > 0);
        }

        //private void PopulateSizeSet(bool addNewRecord)
        //{
        //    this.PopulateSizeSet(addNewRecord, 0);
        //}

        private void PopulateSizeSet(bool addNewRecord)
        {
            if (this.IsNotRefresh)
            {
                //this.dgAddEditSizes.CurrentPageIndex = currentPageIndex;
                //this.dgAddEditSizes.EditItemIndex = editItemIndex;

                SizeBO obj = new SizeBO();
                obj.SizeSet = int.Parse(this.ddlSizeSet.SelectedValue.ToString());

                //List<SizeBO> lstEmptyList = new List<SizeBO>();
                List<KeyValuePair<int, SizeBO>> lstEmptyList = new List<KeyValuePair<int, SizeBO>>();

                //if (editItemIndex > -1)
                //{
                List<SizeBO> lstExsistingSizes = obj.SearchObjects().OrderBy(o => o.SeqNo).ToList();
                foreach (SizeBO objSize in lstExsistingSizes)
                {
                    lstEmptyList.Add(new KeyValuePair<int, SizeBO>(objSize.ID, objSize));
                }
                //}
                //else if (Session["ListSizes"] != null)
                //{
                //    lstEmptyList = (List<KeyValuePair<int, SizeBO>>)Session["ListSizes"];
                //}
                //else
                //{
                //    List<SizeBO> lstExsistingSizes = obj.SearchObjects().OrderBy(o => o.SeqNo).ToList();
                //    foreach (SizeBO objSize in lstExsistingSizes)
                //    {
                //        lstEmptyList.Add(new KeyValuePair<int, SizeBO>(objSize.ID, objSize));
                //    }
                //}

                if (addNewRecord || lstEmptyList.Count == 0)
                {
                    SizeBO objSize = new SizeBO();
                    objSize.ID = 0;
                    objSize.SizeSet = int.Parse(this.ddlSizeSet.SelectedValue.ToString());
                    objSize.SizeName = string.Empty;
                    //objSize.SeqNo = 0;

                    int nextID = 0; // (lstEmptyList.Select(m => m.Key).Min() > 0) ? 0 : (lstEmptyList.Select(m => m.Key).Min() - 1);

                    lstEmptyList.Insert(0, new KeyValuePair<int, SizeBO>(nextID, objSize));

                    if (dgAddEditSizes.CurrentPageIndex > Math.Floor((double)(lstEmptyList.Count / dgAddEditSizes.PageSize)))
                        dgAddEditSizes.CurrentPageIndex = Convert.ToInt32(Math.Floor((double)(lstEmptyList.Count / dgAddEditSizes.PageSize)));
                    this.dgAddEditSizes.EditItemIndex = 0;//lstEmptyList.Count - 1;
                }

                this.dgAddEditSizes.DataSource = lstEmptyList;
                this.dgAddEditSizes.DataBind();
                ViewState["IsPopulateModel"] = true;
                Session["ListSizes"] = lstEmptyList;
            }
            else
            {
                ViewState["IsPopulateModel"] = false;
                ViewState["IsPageValid"] = true;
            }

        }

        private void DeleteSize(int queryId)
        {
            try
            {
                if (queryId > 0)
                {
                    using (TransactionScope ts = new TransactionScope())
                    {

                        SizeBO objSize = new SizeBO(this.ObjContext);
                        objSize.ID = queryId;
                        objSize.GetObject();

                        List<int> lstSizeCharts = objSize.SizeChartsWhereThisIsSize.Select(o => o.ID).ToList();

                        foreach (int sizeChart in lstSizeCharts)
                        {
                            SizeChartBO objSizeChart = new SizeChartBO(this.ObjContext);
                            objSizeChart.ID = sizeChart;
                            objSizeChart.GetObject();

                            objSizeChart.Delete();
                        }

                        objSize.Delete();

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                else
                {
                    if (Session["ListSizes"] != null)
                    {
                        List<KeyValuePair<int, SizeBO>> lstEmptyList = (List<KeyValuePair<int, SizeBO>>)Session["ListSizes"];
                        KeyValuePair<int, SizeBO> objSize = lstEmptyList.Where(m => m.Key == queryId).FirstOrDefault();
                        lstEmptyList.Remove(objSize);

                        Session["ListSizes"] = lstEmptyList;
                    }
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Deleting the Size", ex);
            }
        }

        private void ProcessSizeSet(bool isNewSize)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    SizeBO objSize = new SizeBO(this.ObjContext);

                    if (!isNewSize)
                    {
                        objSize.ID = int.Parse(this.hdnSelectedSizeID.Value);
                        objSize.GetObject();
                    }

                    objSize.IsDefault = (int.Parse(this.hdnIsDefault.Value.ToString()) > 0) ? true : false;
                    objSize.SizeName = this.hdnSizeName.Value.ToString();
                    objSize.SeqNo = int.Parse(this.hdnSeqNo.Value.ToString());

                    if (isNewSize)
                    {
                        int itemId = int.Parse(this.ddlSizeSet.SelectedValue.ToString());

                        SizeSetBO objSizeSet = new SizeSetBO(this.ObjContext);
                        objSizeSet.ID = itemId;
                        objSizeSet.GetObject();

                        objSizeSet.SizesWhereThisIsSizeSet.Add(objSize);
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while processing Sizes", ex);
            }
        }

        private void ReBindGrid()
        {
            ResetPageTemporaryValues();

            if (Session["SizeDetails"] != null)
            {
                RadGridSize.DataSource = (List<SizeSetBO>)Session["SizeDetails"];
                RadGridSize.DataBind();
            }
            this.hdnIsNewSizeSet.Value = "0";
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
                    if (!isDelete)
                    {
                        SizeSetBO objSizeSet = new SizeSetBO(this.ObjContext);
                        if (queryId > 0)
                        {
                            objSizeSet.ID = queryId;
                            objSizeSet.GetObject();
                        }

                        List<int> lstSizeIds = objSizeSet.SizesWhereThisIsSizeSet.Select(o => o.ID).ToList();

                        this.dgAddEditSizes.AllowPaging = false;
                        foreach (DataGridItem item in this.dgAddEditSizes.Items)
                        {
                            //HiddenField hdnSizeID = (HiddenField)item.FindControl("hdnSizeID");
                            Literal lblID = (Literal)item.FindControl("lblID");
                            TextBox txtSizeName = (TextBox)item.FindControl("txtSizeName");
                            TextBox txtSeqNo = (TextBox)item.FindControl("txtSeqNo");
                            CheckBox chkIsDefault = (CheckBox)item.FindControl("chkIsDefault");
                            int sizeId = int.Parse(lblID.Text);
                            SizeBO objSize = new SizeBO(this.ObjContext);

                            if (sizeId > 0 && lstSizeIds.Contains(sizeId)) // edit
                            {
                                objSize.ID = sizeId;
                                objSize.GetObject();

                                objSize.SizeSet = int.Parse(ddlSizeSet.SelectedItem.Value);
                                objSize.IsDefault = chkIsDefault.Checked;
                                objSize.SizeName = txtSizeName.Text;
                                objSize.SeqNo = int.Parse(txtSeqNo.Text);
                            }
                            else // new
                            {
                                objSize.SizeSet = int.Parse(ddlSizeSet.SelectedItem.Value);
                                objSize.IsDefault = chkIsDefault.Checked;
                                objSize.SizeName = txtSizeName.Text;
                                objSize.SeqNo = int.Parse(txtSeqNo.Text);
                                objSizeSet.SizesWhereThisIsSizeSet.Add(objSize);
                            }

                            //if (lstSizeIds.Count == 0 || !lstSizeIds.Contains(sizeId)) //New Size
                            //{
                            //    //Label lblSizeName = (Label)item.FindControl("lblSizeName");
                            //    //Label lblSeqNo = (Label)item.FindControl("lblSeqNo");
                            //    //Label lblSizeSet = (Label)item.FindControl("lblSizeSet");

                            //    //SizeBO objSize = new SizeBO(this.ObjContext);

                            //    //objSize.SizeSet = int.Parse(ddlSizeSet.SelectedItem.Value);
                            //    //objSize.SizeName = lblSizeName.Text;
                            //    //objSize.SeqNo = int.Parse(lblSeqNo.Text);
                            //    //objSizeSet.SizesWhereThisIsSizeSet.Add(objSize);

                            //    //Label lblSizeSet = (Label)item.FindControl("lblSizeSet");


                            //}

                            //lstSizeIds.Remove(sizeId);
                        }

                        //if (lstSizeIds.Count > 0)
                        //{
                        //    foreach (int sizeId in lstSizeIds)
                        //    {
                        //        SizeBO objSize = new SizeBO(this.ObjContext);
                        //        objSize.ID = sizeId;
                        //        objSize.GetObject();

                        //        objSizeSet.SizesWhereThisIsSizeSet.Remove(objSize);
                        //        objSize.Delete();
                        //    }
                        //}

                        this.ObjContext.SaveChanges();
                    }
                    else //Delete Size
                    {
                        SizeBO objSize = new SizeBO(this.ObjContext);
                        if (queryId > 0)
                        {
                            objSize.ID = queryId;
                            objSize.GetObject();

                            objSize.Delete();
                            this.ObjContext.SaveChanges();
                        }
                    }

                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                //IndicoLogging.log("Error occured while Adding the Item", ex);
            }
        }

        private void ResetPageTemporaryValues()
        {
            ViewState["IsPopulateModel"] = false;
            Session["ListSizes"] = null;
        }

        #endregion
    }
}