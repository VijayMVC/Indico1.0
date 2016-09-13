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
    public partial class ViewPatternSuppliers : IndicoPage
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

                if (item.ItemIndex > -1 && item.DataItem is PatternSupplierBO)
                {
                    PatternSupplierBO objSupplier = (PatternSupplierBO)item.DataItem;

                    Literal litCountry = (Literal)item.FindControl("litCountry");
                    litCountry.Text = objSupplier.objCountry.ShortName.ToString();

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objSupplier.ID.ToString());
                    linkEdit.Attributes.Add("cty", objSupplier.Country.ToString());                    

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objSupplier.ID.ToString());
                    linkDelete.Attributes.Add("cty", objSupplier.Country.ToString());     
                    linkDelete.Visible = (objSupplier.PatternsWhereThisIsPatternSupplier.Count > 0) ? false : true;
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

                    Response.Redirect("/ViewPatternSuppliers.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int supplierId = int.Parse(this.hdnSelectedSupplierID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(supplierId, true);

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

            lblPopupHeaderText.Text = "New Pattern Supplier";
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

            // hide CountryID Column
            this.RadGridSuppliers.MasterTableView.GetColumn("CountryID").Display = false;

            // Get data for the creator
            this.ddlCreator.Items.Clear();
            this.ddlCreator.Items.Add(new ListItem("Select a creator", "0"));
            List<UserBO> lstCreator = (new UserBO().GetAllObject().OrderBy(o => o.Username)).ToList();
            foreach(UserBO user in lstCreator)
            {
                this.ddlCreator.Items.Add(new ListItem(user.Username, user.ID.ToString()));
            }

            this.ddlModifier.Items.Clear();
            this.ddlModifier.Items.Add(new ListItem("Select a modifier", "0"));
            List<UserBO> lstModifier = (new UserBO().GetAllObject().OrderBy(o => o.Username)).ToList();
            foreach (UserBO user in lstModifier)
            {
                this.ddlModifier.Items.Add(new ListItem(user.Username, user.ID.ToString()));
            }

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
                PatternSupplierBO objPatternSupplier = new PatternSupplierBO();

                List<PatternSupplierBO> lstPatternSuplliers = new List<PatternSupplierBO>();
                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstPatternSuplliers = (from o in objPatternSupplier.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                    where o.Name.ToLower().Contains(searchText) // ||
                                         // o.Country.ToLower().Contains(searchText)
                                    select o).ToList();
                }
                else
                {
                    lstPatternSuplliers = objPatternSupplier.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstPatternSuplliers.Count > 0)
                {
                    this.RadGridSuppliers.AllowPaging = (lstPatternSuplliers.Count > this.RadGridSuppliers.PageSize);
                    this.RadGridSuppliers.DataSource = lstPatternSuplliers;
                    this.RadGridSuppliers.DataBind();
                    Session["PatternSupplier"] = lstPatternSuplliers;

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

                this.RadGridSuppliers.Visible = (lstPatternSuplliers.Count > 0);

            }
        }

        private void ProcessForm(int supplierid, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    PatternSupplierBO objPatternSupplier = new PatternSupplierBO(this.ObjContext);
                    if (supplierid > 0)
                    {
                        objPatternSupplier.ID = supplierid;
                        objPatternSupplier.GetObject();
                        objPatternSupplier.Name = this.txtSupplierName.Text;
                        objPatternSupplier.Country = int.Parse(this.ddlCountry.SelectedValue);
                        objPatternSupplier.Address1 = this.txtAddress1.Text;
                        objPatternSupplier.Address2 = this.txtAddress2.Text;
                        objPatternSupplier.City = this.txtCity.Text;
                        objPatternSupplier.State = this.txtState.Text;
                        objPatternSupplier.Postcode = this.txtPostcode.Text;
                        objPatternSupplier.EmailAddress = this.txtPostcode.Text;
                        objPatternSupplier.TelephoneNumber = this.txtEmailAddress.Text;
                        objPatternSupplier.Creator = LoggedUser.ID;
                        objPatternSupplier.CreatedDate = DateTime.Now;
                        objPatternSupplier.Modifier = LoggedUser.ID;
                        objPatternSupplier.ModifiedDate = DateTime.Now;
                        

                        if (isDelete)
                        {
                            objPatternSupplier.Delete();
                        }
                    }
                    else
                    {
                        objPatternSupplier.Name = this.txtSupplierName.Text;
                        objPatternSupplier.Country = int.Parse(this.ddlCountry.SelectedValue);
                        objPatternSupplier.Address1 = this.txtAddress1.Text;
                        objPatternSupplier.Address2 = this.txtAddress2.Text;
                        objPatternSupplier.City = this.txtCity.Text;
                        objPatternSupplier.State = this.txtState.Text;
                        objPatternSupplier.Postcode = this.txtPostcode.Text;
                        objPatternSupplier.EmailAddress = this.txtPostcode.Text;
                        objPatternSupplier.TelephoneNumber = this.txtEmailAddress.Text;
                        objPatternSupplier.Creator = LoggedUser.ID;
                        objPatternSupplier.CreatedDate = DateTime.Now;
                        objPatternSupplier.Modifier = LoggedUser.ID;
                        objPatternSupplier.ModifiedDate = DateTime.Now;
                        objPatternSupplier.Add();
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
            if (Session["PatternSupplier"] != null)
            {
                RadGridSuppliers.DataSource = (List<SupplierDetailsViewBO>)Session["PatternSupplier"];
                RadGridSuppliers.DataBind();
            }
        }

        #endregion
    }
}