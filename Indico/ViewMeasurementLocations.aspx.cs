using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;
using System.Linq.Dynamic;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class ViewMeasurementLocations : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["MeasurementLocationSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["MeasurementLocationSortExpression"] = value;
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

        protected void RadGridMeasurements_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();

            ViewState["IsPopulateModel"] = false;
        }

        protected void RadGridMeasurements_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();

            ViewState["IsPopulateModel"] = false;
        }

        protected void RadGridMeasurements_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is ItemBO)
                {
                    ItemBO objItem = (ItemBO)item.DataItem;

                    LinkButton linkEdit = (LinkButton)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objItem.ID.ToString());
                }
            }
        }

        protected void RadGridMeasurements_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();

                ViewState["IsPopulateModel"] = false;
            }
        }

        protected void RadGridMeasurements_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();

            ViewState["IsPopulateModel"] = false;
        }

        protected void RadGridMeasurements_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void linkEdit_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int ml = int.Parse(this.hdnSelectedMeasurementLocationListID.Value);

                if (ml > 0)
                {
                    List<ItemBO> lstExistingItems = (new MeasurementLocationBO()).SearchObjects().GroupBy(o => o.Item).Select(m => m.First().objItem).ToList();

                    this.ddlItem.Items.Clear();
                    this.ddlItem.Items.Add(new ListItem("Select an Item", "0"));
                    foreach (ItemBO item in lstExistingItems.OrderBy(o => o.Name))
                    {
                        this.ddlItem.Items.Add(new ListItem(item.Name, item.ID.ToString()));
                    }

                    this.ddlItem.Items.FindByValue(ml.ToString()).Selected = true;
                    this.linkAddNew.Visible = true;

                    this.PopulateML(false);
                    this.hdnIsNewML.Value = "0";
                }
            }
            else
            {
                ViewState["IsPopulateModel"] = false;
            }
        }

        //protected void dgMeasurementLocation_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is ItemBO)
        //    {
        //        ItemBO objItem = (ItemBO)item.DataItem;

        //        Literal lblItem = (Literal)item.FindControl("lblItem");
        //        lblItem.Text = objItem.Name;

        //        LinkButton linkEdit = (LinkButton)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objItem.ID.ToString());
        //    }
        //}

        //protected void dgMeasurementLocation_PageIndexChanged(object sender, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgMeasurementLocation.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dgMeasurementLocation_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dgMeasurementLocation.Columns)
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

        //protected void dgMeasurementLocation_ItemCommand(object source, DataGridCommandEventArgs e)
        //{
        //    if (e.CommandName == "Edit")
        //    {

        //    }
        //}

        protected void dgAddEditMLs_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if ((item.ItemIndex > -1 && item.DataItem is MeasurementLocationBO) && (item.ItemType == ListItemType.Item || item.ItemType == ListItemType.AlternatingItem))
            {
                MeasurementLocationBO objMeasurementLocation = (MeasurementLocationBO)item.DataItem;

                // bool canDelete = (objMeasurementLocation.SizeChartsWhereThisIsMeasurementLocation.Count == 0);

                CheckBox chkIsSend = (CheckBox)item.FindControl("chkIsSend");
                chkIsSend.Checked = (bool)objMeasurementLocation.IsSend;
                chkIsSend.Enabled = false;

                Label lblID = (Label)item.FindControl("lblID");
                lblID.Text = objMeasurementLocation.ID.ToString();

                Label lblKey = (Label)item.FindControl("lblKey");
                lblKey.Text = objMeasurementLocation.Key;

                Label lblName = (Label)item.FindControl("lblName");
                lblName.Text = objMeasurementLocation.Name;

                LinkButton linkEdit = (LinkButton)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objMeasurementLocation.ID.ToString());

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objMeasurementLocation.ID.ToString());
                //linkDelete.Visible = canDelete;
            }
            else if ((item.ItemIndex > -1 && item.DataItem is MeasurementLocationBO) && (item.ItemType == ListItemType.EditItem))
            {
                MeasurementLocationBO objMeasurementLocation = (MeasurementLocationBO)item.DataItem;

                CheckBox chkIsSend = (CheckBox)item.FindControl("chkIsSend");
                chkIsSend.Checked = objMeasurementLocation.IsSend?? false;

                Label lblID = (Label)item.FindControl("lblID");
                lblID.Text = objMeasurementLocation.ID.ToString();
                chkIsSend.Enabled = true;

                TextBox txtKey = (TextBox)item.FindControl("txtKey");
                txtKey.Text = objMeasurementLocation.Key;
                this.hdnKey.Value = txtKey.Text;

                TextBox txtName = (TextBox)item.FindControl("txtName");
                txtName.Text = objMeasurementLocation.Name;
                this.hdnName.Value = txtName.Text;

                LinkButton linkSave = (LinkButton)item.FindControl("linkSave");
                linkSave.Attributes.Add("qid", objMeasurementLocation.ID.ToString());
                linkSave.CommandName = (!string.IsNullOrEmpty(hdnName.Value) || !string.IsNullOrEmpty(this.hdnKey.Value)) ? "Update" : "Save";
            }
        }

        /*protected void dgAddEditMLs_PageIndexChanged(object sender, DataGridPageChangedEventArgs e)
        {
            this.PopulateML(false, -1, e.NewPageIndex);
        }*/

        protected void dgAddEditMLs_SortCommand(object sender, DataGridSortCommandEventArgs e)
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

            this.PopulateML(false);

            foreach (DataGridColumn col in this.dgAddEditMLs.Columns)
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

        protected void dgAddEditMLs_ItemCommand(object sender, DataGridCommandEventArgs e)
        {
            //Page.Validate();

            //if (Page.IsValid)
            //{
            switch (e.CommandName)
            {
                case "Save":
                    this.ProcessML(true);
                    this.PopulateML(false);
                    break;
                case "Update":
                    this.ProcessML(false);
                    this.PopulateML(false);
                    break;
                case "Delete":
                    break;
                case "Edit":
                    this.PopulateML(false, e.Item.ItemIndex, ((System.Web.UI.WebControls.DataGrid)(sender)).CurrentPageIndex);
                    break;
                default:
                    break;
            }
            //}
        }

        protected void btnAddMeasurementLocation_Click(object sender, EventArgs e)
        {
            // Populate popup items dropdown
            this.ddlItem.Items.Clear();
            this.ddlItem.Items.Add(new ListItem("Select an Item", "0"));

            List<int> lstExistingItems = (new MeasurementLocationBO()).SearchObjects().GroupBy(o => o.Item).Select(m => m.First().Item).ToList();
            List<int> lstNewItems = (new ItemBO()).SearchObjects().Where(o => o.Parent == 0).OrderBy(o => o.Name).Select(o => o.ID).Except(lstExistingItems).ToList();

            foreach (int item in lstNewItems)
            {
                ItemBO objItem = new ItemBO();
                objItem.ID = item;
                objItem.GetObject();

                this.ddlItem.Items.Add(new ListItem(objItem.Name, objItem.ID.ToString()));
            }

            this.dgAddEditMLs.DataSource = null;
            this.dgAddEditMLs.DataBind();

            this.hdnIsNewML.Value = "1";
            ViewState["IsPopulateModel"] = true;
        }

        protected void ddlItem_SelectedIndexChange(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (this.ddlItem.SelectedIndex > 0)
                {
                    this.PopulateML(false);
                    this.linkAddNew.Visible = true;
                }
                else
                {
                    this.linkAddNew.Visible = false;
                    this.dgAddEditMLs.DataSource = null;
                    this.dgAddEditMLs.DataBind();
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
            this.PopulateML(true);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        /*protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int queryId = int.Parse(this.hdnSelectedMeasurementLocationListID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(queryId, false);
                    Response.Redirect("/ViewMeasurementLocations.aspx");
                }

                // Popup Header Text
                this.lblPopupHeaderText.Text = ((queryId > 0) ? "Edit " : "New ") + "Measurement Location";
                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }*/

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int queryId = int.Parse(this.hdnSelectedMeasurementLocationListID.Value.Trim());
            this.DeleteML(queryId);
            this.PopulateML(false);
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading; //this.ActivePage.Heading;

            // Popup Header Text
            this.lblPopupHeaderText.Text = "New Measurement Location";

            ViewState["IsPageValied"] = true;
            ViewState["IsPopulateModel"] = false;

            // Populate popup items dropdown
            //this.ddlItem.Items.Add(new ListItem("Select an Item", "0"));
            //foreach (ItemBO item in (new ItemBO()).SearchObjects())
            //{
            //    this.ddlItem.Items.Add(new ListItem(item.Name, item.ID.ToString()));
            //}

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
            //ItemBO objItem = new ItemBO();
            MeasurementLocationBO objMeasurementLocation = new MeasurementLocationBO();
            List<ItemBO> lstItems = new List<ItemBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstItems = objMeasurementLocation.SearchObjects().AsQueryable().OrderBy(SortExpression).GroupBy(o => o.Item).Select(m => m.First().objItem).Where(o => o.Name.ToLower().Contains(searchText)).ToList();
            }
            else
            {
                lstItems = objMeasurementLocation.SearchObjects().AsQueryable().OrderBy(SortExpression).GroupBy(o => o.Item).Select(m => m.First().objItem).ToList();
            }

            if (lstItems.Count > 0)
            {
                this.RadGridMeasurements.AllowPaging = (lstItems.Count > this.RadGridMeasurements.PageSize);
                this.RadGridMeasurements.DataSource = lstItems;
                this.RadGridMeasurements.DataBind();
                Session["MeasurementDetails"] = lstItems;

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
                this.btnAddMeasurementLocation.Visible = false;
            }

            //this.lblSerchKey.Text = string.Empty;
            this.RadGridMeasurements.Visible = (lstItems.Count > 0);
        }

        private void PopulateML(bool addNewRecorde)
        {
            this.PopulateML(addNewRecorde, -1, 0);
        }

        private void PopulateML(bool addNewRecorde, int editItemIndex, int currentPageIndex)
        {
            if (this.IsNotRefresh)
            {
                this.dgAddEditMLs.CurrentPageIndex = currentPageIndex;
                this.dgAddEditMLs.EditItemIndex = editItemIndex;

                MeasurementLocationBO obj = new MeasurementLocationBO();
                obj.Item = int.Parse(this.ddlItem.SelectedValue.ToString());

                List<MeasurementLocationBO> lstEmptyList = (from o in obj.SearchObjects()
                                                            orderby o.Key
                                                            select o).ToList();

                if (addNewRecorde || lstEmptyList.Count == 0)
                {
                    MeasurementLocationBO objMeasurementLocation = new MeasurementLocationBO();
                    objMeasurementLocation.ID = 0;
                    objMeasurementLocation.Item = int.Parse(this.ddlItem.SelectedValue.ToString());
                    objMeasurementLocation.Key = string.Empty;
                    objMeasurementLocation.Name = string.Empty;

                    lstEmptyList.Insert(0, objMeasurementLocation);

                    if (dgAddEditMLs.CurrentPageIndex > Math.Floor((double)(lstEmptyList.Count / dgAddEditMLs.PageSize)))
                        dgAddEditMLs.CurrentPageIndex = Convert.ToInt32(Math.Floor((double)(lstEmptyList.Count / dgAddEditMLs.PageSize)));
                    this.dgAddEditMLs.EditItemIndex = 0;// lstEmptyList.Count - 1;
                }

                this.dgAddEditMLs.DataSource = lstEmptyList;
                //this.dgAddEditMLs.AllowPaging = (lstEmptyList.Count > dgAddEditMLs.PageSize);
                this.dgAddEditMLs.DataBind();

                ViewState["IsPopulateModel"] = true;
            }
            else
            {
                ViewState["IsPopulateModel"] = false;
            }
        }

        private void DeleteML(int queryId)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    MeasurementLocationBO objMeasurementLocation = new MeasurementLocationBO(this.ObjContext);
                    if (queryId > 0)
                    {
                        objMeasurementLocation.ID = queryId;
                        objMeasurementLocation.GetObject();


                        foreach (SizeChartBO schart in objMeasurementLocation.SizeChartsWhereThisIsMeasurementLocation)
                        {
                            SizeChartBO objSizeChart = new SizeChartBO(this.ObjContext);
                            objSizeChart.ID = schart.ID;
                            objSizeChart.GetObject();

                            objSizeChart.Delete();
                            this.ObjContext.SaveChanges();
                        }
                        objMeasurementLocation.Delete();
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while Deleting the Measurement Location", ex);
            }
        }

        private void ProcessML(bool isNewML)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    MeasurementLocationBO objML = new MeasurementLocationBO(this.ObjContext);

                    if (!isNewML)
                    {
                        objML.ID = int.Parse(this.hdnSelectedMeasurementLocationListID.Value);
                        objML.GetObject();
                    }

                    objML.IsSend = (int.Parse(this.hdnIsSend.Value.ToString()) > 0) ? true : false;
                    objML.Name = this.hdnName.Value.ToString();
                    objML.Key = this.hdnKey.Value.ToString();

                    if (isNewML)
                    {
                        int itemId = int.Parse(this.ddlItem.SelectedValue.ToString());

                        ItemBO objItem = new ItemBO(this.ObjContext);
                        objItem.ID = itemId;
                        objItem.GetObject();

                        objItem.MeasurementLocationsWhereThisIsItem.Add(objML);
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while processing Measurement Locations", ex);
            }
        }

        private void ReBindGrid()
        {
            if (Session["MeasurementDetails"] != null)
            {
                RadGridMeasurements.DataSource = (List<ItemBO>)Session["MeasurementDetails"];
                RadGridMeasurements.DataBind();
            }
        }

        #endregion
    }
}