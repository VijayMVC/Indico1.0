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
    public partial class ViewSuppliers : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["AgeGroupsSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["AgeGroupsSortExpression"] = value;
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

        protected void RadGridSuppliers_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridSuppliers_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridSuppliers_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is SupplierDetailsViewBO)
                {
                    SupplierDetailsViewBO objSupplier = (SupplierDetailsViewBO)item.DataItem;

                    Label lblCountry = (Label)item.FindControl("lblCountry");
                    lblCountry.Text = objSupplier.CountryID.ToString();

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objSupplier.Supplier.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objSupplier.Supplier.ToString());
                    linkDelete.Visible = (objSupplier.IsAccessoriesWherethisSupplier == true && objSupplier.IsFabricCodesWherethisSupplier == true) ? false : true;
                }
            }
        }

        protected void RadGridSuppliers_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridSuppliers_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dgSuppliers_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is SupplierBO)
        //    {
        //        SupplierBO objSupplier = (SupplierBO)item.DataItem;

        //        Literal litCountry = (Literal)item.FindControl("litCountry");
        //        litCountry.Text = objSupplier.objCountry.ShortName;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objSupplier.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objSupplier.ID.ToString());
        //        linkDelete.Visible = (objSupplier.AccessorysWhereThisIsSupplier.Count == 0) ? true : false;
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
                int supplierid = int.Parse(this.hdnSelectedSupplierID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(supplierid, false);

                    Response.Redirect("/ViewSuppliers.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int agegroupId = int.Parse(this.hdnSelectedSupplierID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(agegroupId, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);

        }

        //protected void dgSuppliers_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgSuppliers.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dgSuppliers_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dgSuppliers.Columns)
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
                int supplierid = int.Parse(this.hdnSelectedSupplierID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(supplierid, "Supplier", "Name", this.txtSupplierName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on AddEditClient.aspx", ex);
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

            lblPopupHeaderText.Text = "New Age Group";
            ViewState["IsPageValied"] = true;
            Session["SupplierDetails"] = null;

            this.PopulateDataGrid();

            // populate country
            this.ddlCountry.Items.Clear();
            this.ddlCountry.Items.Add(new ListItem("Select a Country", "0"));
            List<CountryBO> lstCountry = (new CountryBO()).GetAllObject().OrderBy(o => o.ShortName).ToList();
            foreach (CountryBO country in lstCountry)
            {
                this.ddlCountry.Items.Add(new ListItem(country.ShortName, country.ID.ToString()));
            }

            this.ddlCountry.Items.FindByValue("14").Selected = true;

            // hide CountryID Column
            this.RadGridSuppliers.MasterTableView.GetColumn("CountryID").Display = false;

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
                SupplierDetailsViewBO objSupplier = new SupplierDetailsViewBO();

                List<SupplierDetailsViewBO> lstSuplliers = new List<SupplierDetailsViewBO>();
                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstSuplliers = (from o in objSupplier.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                    where o.Name.ToLower().Contains(searchText) ||
                                          o.Country.ToLower().Contains(searchText)
                                    select o).ToList();
                }
                else
                {
                    lstSuplliers = objSupplier.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstSuplliers.Count > 0)
                {
                    this.RadGridSuppliers.AllowPaging = (lstSuplliers.Count > this.RadGridSuppliers.PageSize);
                    this.RadGridSuppliers.DataSource = lstSuplliers;
                    this.RadGridSuppliers.DataBind();
                    Session["SupplierDetails"] = lstSuplliers;

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
                    this.btnAddSupplier.Visible = false;
                }

                this.RadGridSuppliers.Visible = (lstSuplliers.Count > 0);
            }
        }

        private void ProcessForm(int supplierid, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    SupplierBO objSupplier = new SupplierBO(this.ObjContext);
                    if (supplierid > 0)
                    {
                        objSupplier.ID = supplierid;
                        objSupplier.GetObject();
                        objSupplier.Name = this.txtSupplierName.Text;
                        objSupplier.Country = int.Parse(this.ddlCountry.SelectedValue);
                        objSupplier.Modifier = LoggedUser.ID;
                        objSupplier.ModifiedDate = DateTime.Now;

                        if (isDelete)
                        {
                            objSupplier.Delete();
                        }
                    }
                    else
                    {
                        objSupplier.Name = this.txtSupplierName.Text;
                        objSupplier.Name = this.txtSupplierName.Text;
                        objSupplier.Country = int.Parse(this.ddlCountry.SelectedValue);
                        objSupplier.Creator = LoggedUser.ID;
                        objSupplier.CreatedDate = DateTime.Now;
                        objSupplier.Modifier = LoggedUser.ID;
                        objSupplier.ModifiedDate = DateTime.Now;
                        objSupplier.Add();
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while inserting or updating or deleting Suppliers in ViewSuppliers.aspx page", ex);
            }
        }

        private void ReBindGrid()
        {
            if (Session["SupplierDetails"] != null)
            {
                RadGridSuppliers.DataSource = (List<SupplierDetailsViewBO>)Session["SupplierDetails"];
                RadGridSuppliers.DataBind();
            }
        }

        #endregion
    }
}