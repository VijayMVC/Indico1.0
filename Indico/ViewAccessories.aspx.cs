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
    public partial class ViewAccessories : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["PatternAccessoryExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["PatternAccessoryExpression"] = value;
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
            //ViewState["IsPageValied"] = true;
        }

        protected void RadGridAccessory_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridAccessory_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridAccessory_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridAccessory_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is AccessoryDetailsViewBO)
                {
                    AccessoryDetailsViewBO objAccessory = (AccessoryDetailsViewBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objAccessory.Accessory.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objAccessory.Accessory.ToString());
                    linkDelete.Visible = (objAccessory.IsPatternAccessoryWherethisAccessory == true ||
                                          objAccessory.IsPatternSupportAccessorySubWherethisAccessory == true ||
                                          objAccessory.IsVisualLayoutAccessorySubWherethisAccessory == true) ? false : true;
                }
            }
        }

        protected void RadGridAccessory_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridAccessory_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridPatternAccessory_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is AccessoryBO)
        //    {
        //        AccessoryBO objAccessory = (AccessoryBO)item.DataItem;

        //        Literal litAccessoryCategory = (Literal)item.FindControl("litAccessoryCategory");
        //        litAccessoryCategory.Text = objAccessory.objAccessoryCategory.Name;

        //        Literal litUnit = (Literal)item.FindControl("litUnit");
        //        litUnit.Text = (objAccessory.Unit != null && objAccessory.Unit > 0) ? objAccessory.objUnit.Name : string.Empty;

        //        Literal litSupplier = (Literal)item.FindControl("litSupplier");
        //        litSupplier.Text = (objAccessory.Supplier != null && objAccessory.Supplier > 0) ? objAccessory.objSupplier.Name : string.Empty;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objAccessory.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objAccessory.ID.ToString());
        //        linkDelete.Visible = (objAccessory.PatternAccessorysWhereThisIsAccessory.Count == 0 && objAccessory.PatternSupportAccessorysWhereThisIsAccessory.Count == 0) ? true : false;
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
                int patternaccesooryid = int.Parse(this.hdnSelectedPatternAccessoryID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(patternaccesooryid, false);

                    Response.Redirect("/ViewAccessories.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int patternaccesooryid = int.Parse(this.hdnSelectedPatternAccessoryID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(patternaccesooryid, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;

        }

        //protected void dataGridPatternAccessory_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridPatternAccessory.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dataGridPatternAccessory_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dataGridPatternAccessory.Columns)
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

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int patternaccesooryid = int.Parse(this.hdnSelectedPatternAccessoryID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(patternaccesooryid, "Accessory", "Name", this.txtPatternAccessory.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewAccessories.aspx", ex);
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

            //lblPopupHeaderText.Text = "New Shipment Mode";

            Session["AccessoryDetails"] = null;
            ViewState["IsPageValied"] = true;

            this.PopulateDataGrid();

            //populate Accessory Category
            this.ddlAccessoryaCategory.Items.Clear();
            this.ddlAccessoryaCategory.Items.Add(new ListItem("Select Accesssory Category", "0"));
            List<AccessoryCategoryBO> lstAccessoryCategory = (new AccessoryCategoryBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (AccessoryCategoryBO ac in lstAccessoryCategory)
            {
                this.ddlAccessoryaCategory.Items.Add(new ListItem(ac.Name, ac.ID.ToString()));
            }

            //populate Unit
            this.ddlUnit.Items.Clear();
            this.ddlUnit.Items.Add(new ListItem("Select Unit", "0"));
            List<UnitBO> lstUnit = (new UnitBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (UnitBO unit in lstUnit)
            {
                this.ddlUnit.Items.Add(new ListItem(unit.Name, unit.ID.ToString()));
            }

            //populate Supplier
            this.ddlSupplier.Items.Clear();
            this.ddlSupplier.Items.Add(new ListItem("Select Supplier", "0"));
            List<SupplierBO> lstSupplier = (new SupplierBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (SupplierBO sup in lstSupplier)
            {
                this.ddlSupplier.Items.Add(new ListItem(sup.Name, sup.ID.ToString()));
            }

            // hide columns
            this.RadGridAccessory.MasterTableView.GetColumn("AccessoryCategoryID").Display = false;
            this.RadGridAccessory.MasterTableView.GetColumn("Cost").Display = false;
            this.RadGridAccessory.MasterTableView.GetColumn("SuppCode").Display = false;
            this.RadGridAccessory.MasterTableView.GetColumn("UnitID").Display = false;
            this.RadGridAccessory.MasterTableView.GetColumn("SupplierID").Display = false;
        }

        private void PopulateDataGrid()
        {
            {
                // Hide Controls
                this.dvEmptyContent.Visible = false;
                this.dvDataContent.Visible = false;
                this.dvNoSearchResult.Visible = false;

                // Search text
                string searchText = this.txtSearch.Text.ToLower().Trim();

                // Populate Items
                AccessoryDetailsViewBO objAccessory = new AccessoryDetailsViewBO();

                List<AccessoryDetailsViewBO> lstAccessory = new List<AccessoryDetailsViewBO>();

                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstAccessory = (from o in objAccessory.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                    where o.Name.ToLower().Contains(searchText) ||
                                          o.Code.ToLower().Contains(searchText) ||
                                          o.AccessoryCategory.ToLower().Contains(searchText) ||
                                          o.Supplier.ToLower().Contains(searchText) ||
                                          o.Unit.ToLower().Contains(searchText)
                                    select o).ToList();
                }
                else
                {
                    lstAccessory = objAccessory.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstAccessory.Count > 0)
                {
                    this.RadGridAccessory.AllowPaging = (lstAccessory.Count > this.RadGridAccessory.PageSize);
                    this.RadGridAccessory.DataSource = lstAccessory;
                    this.RadGridAccessory.DataBind();
                    Session["AccessoryDetails"] = lstAccessory;

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
                    this.btnAddPatternAccessory.Visible = false;
                }

                this.RadGridAccessory.Visible = (lstAccessory.Count > 0);
            }
        }

        private void ProcessForm(int accessory, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    AccessoryBO objAccessory = new AccessoryBO(this.ObjContext);
                    if (accessory > 0)
                    {
                        //Update Data
                        objAccessory.ID = accessory;
                        objAccessory.GetObject();
                        objAccessory.Name = this.txtPatternAccessory.Text;
                        objAccessory.Code = this.txtCode.Text;
                        objAccessory.AccessoryCategory = int.Parse(ddlAccessoryaCategory.SelectedValue.ToString());
                        objAccessory.Description = txtDescription.Text;
                        objAccessory.Cost = decimal.Parse(txtCost.Text);
                        objAccessory.SuppCode = txtSuppCode.Text;
                        objAccessory.Unit = int.Parse(this.ddlUnit.SelectedValue);
                        objAccessory.Supplier = int.Parse(this.ddlSupplier.SelectedValue);

                        if (isDelete)
                        {
                            objAccessory.Delete();
                        }
                    }
                    else
                    {
                        objAccessory.Name = this.txtPatternAccessory.Text;
                        objAccessory.Code = this.txtCode.Text;
                        objAccessory.AccessoryCategory = int.Parse(ddlAccessoryaCategory.SelectedValue.ToString());
                        objAccessory.Description = txtDescription.Text;
                        objAccessory.Cost = decimal.Parse(txtCost.Text);
                        objAccessory.SuppCode = txtSuppCode.Text;
                        objAccessory.Unit = int.Parse(this.ddlUnit.SelectedValue);
                        objAccessory.Supplier = int.Parse(this.ddlSupplier.SelectedValue);
                        objAccessory.Add();
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while adding, updating and deleting Accessory.aspx page", ex);
            }
        }

        private void ReBindGrid()
        {
            if (Session["AccessoryDetails"] != null)
            {
                RadGridAccessory.DataSource = (List<AccessoryDetailsViewBO>)Session["AccessoryDetails"];
                RadGridAccessory.DataBind();
            }
        }

        #endregion          
    }
}