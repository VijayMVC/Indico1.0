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
    public partial class ViewFabricCodes : IndicoPage
    {
        #region Fields

        private int urlType = -1;
        //private int FabricID = 0;

        #endregion

        #region Properties

        protected int QueryType
        {
            get
            {
                if (urlType > -1)
                    return urlType;

                urlType = 1;
                if (Request.QueryString["type"] != null)
                {
                    urlType = Convert.ToInt32(Request.QueryString["type"].ToString());
                }
                return urlType;
            }
        }

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["FabricCodeSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Code";
                }
                return sort;
            }
            set
            {
                ViewState["FabricCodeSortExpression"] = value;
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

        protected void RadGridFabricCode_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridFabricCode_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridFabricCode_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridFabricCode_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is FabricCodeDetailsViewBO)
                {
                    FabricCodeDetailsViewBO objFabricCode = (FabricCodeDetailsViewBO)item.DataItem;

                    HtmlAnchor linkEdit = (HtmlAnchor)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objFabricCode.Fabric.ToString());

                    HtmlAnchor linkDelete = (HtmlAnchor)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objFabricCode.Fabric.ToString());
                    linkDelete.Visible = (objFabricCode.IsCostSheetWherethisFabricCode == true ||
                                          objFabricCode.IsPatternSupportFabricWherethisFabricCode == true ||
                                          objFabricCode.IsPriceWherethisFabricCode == true ||
                                          objFabricCode.IsQuoteWherethisFabricCode == true ||
                                          objFabricCode.IsVisualLayoutWherethisFabricCode == true) ? false : true;

                    HtmlAnchor linkBreakDown = (HtmlAnchor)item.FindControl("linkBreakDown");
                    linkBreakDown.HRef = "AddEditFabricCode.aspx?id=" + objFabricCode.Fabric; //.Add("qid", objFabricCode.Fabric.ToString());

                    linkBreakDown.Visible = !(objFabricCode.IsPure ?? false); // int.Parse(this.ddlFilterFabricType.SelectedValue) == 0;
                    linkEdit.Visible = (objFabricCode.IsPure ?? false); // int.Parse(this.ddlFilterFabricType.SelectedValue) == 1;
                }
            }
        }

        protected void RadGridFabricCode_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridFabricCode_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dgFabricCodes_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is FabricCodeBO)
        //    {
        //        FabricCodeBO objFabricCode = (FabricCodeBO)item.DataItem;

        //        Literal lblSupplier = (Literal)item.FindControl("lblSupplier");
        //        lblSupplier.Text = (objFabricCode.Supplier != null && objFabricCode.Supplier > 0) ? objFabricCode.objSupplier.Name : string.Empty;

        //        Literal lblCountry = (Literal)item.FindControl("lblCountry");
        //        lblCountry.Text = objFabricCode.objCountry.ShortName;

        //        Literal litUnit = (Literal)item.FindControl("litUnit");
        //        litUnit.Text = (objFabricCode.Unit != null && objFabricCode.Unit > 0) ? objFabricCode.objUnit.Name : string.Empty;

        //        HtmlAnchor linkEdit = (HtmlAnchor)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objFabricCode.ID.ToString());

        //        HtmlAnchor linkDelete = (HtmlAnchor)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objFabricCode.ID.ToString());
        //        linkDelete.Visible = (objFabricCode.OrderDetailsWhereThisIsFabricCode.Count == 0 &&
        //                              objFabricCode.PatternSupportFabricsWhereThisIsFabric.Count == 0 &&
        //                              objFabricCode.PricesWhereThisIsFabricCode.Count == 0 &&
        //                              objFabricCode.QuotesWhereThisIsFabric.Count == 0) ? true : false;
        //    }
        //}

        //protected void dgFabricCodes_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgFabricCodes.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dgFabricCodes_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dgFabricCodes.Columns)
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
            ResetViewStateValues();
            this.PopulateDataGrid();
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            if (this.IsNotRefresh)
            {
                int itemId = int.Parse(this.hdnSelectedFabricCodeID.Value.ToString().Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(itemId, false, true);

                    Response.Redirect("~/ViewFabricCodes.aspx?type=1");
                }

                // Popup Header Text
                this.lblPopupHeaderText.Text = ((itemId > 0) ? "Edit " : "New ") + "Fabric Code";
                ViewState["IsPageValidPure"] = (Page.IsValid);
            }
        }

        protected void btnDeleteFabricCode_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();
            int qid = int.Parse(this.hdnSelectedFabricCodeID.Value.Trim());

            this.ProcessForm(qid, true, true);

            this.PopulateDataGrid();
        }

        protected void ddlFilterFabricType_SelectedIndexChanged(object sender, EventArgs e)
        {
            urlType = int.Parse(this.ddlFilterFabricType.SelectedValue);
            ResetViewStateValues();
            this.PopulateDataGrid();
        }

        //protected void btnCombinedSave_ServerClick(object sender, EventArgs e)
        //{
        //    ResetViewStateValues();

        //    if (this.IsNotRefresh)
        //    {
        //        int itemId = int.Parse(this.hdnSelectedFabricCodeID.Value.ToString().Trim());

        //        if (!string.IsNullOrEmpty(this.txtFabricCode.Text))
        //        {
        //            List<FabricCodeBO> lstFabricCodes = (List<FabricCodeBO>)Session["ListFabricCodes"];
        //            lstFabricCodes = lstFabricCodes.Where(m => m.Code == this.txtFabricCode.Text).ToList();

        //            if (lstFabricCodes.Any())
        //            {
        //                if (itemId == 0 || !lstFabricCodes.Select(m => m.ID).Contains(itemId))
        //                {
        //                    CustomValidator cv = new CustomValidator();
        //                    cv.IsValid = false;
        //                    cv.ValidationGroup = "valCombined";
        //                    cv.ErrorMessage = "Fabric Code exists in the system.";
        //                    Page.Validators.Add(cv);
        //                }
        //            }
        //        }

        //        if (Page.IsValid)
        //        {
        //            this.ProcessForm(itemId, false, false);
        //            Response.Redirect("~/ViewFabricCodes.aspx");
        //        }

        //        this.lblPopupHeaderText.Text = ((itemId > 0) ? "Edit " : "New ") + "Fabric Code";
        //        ViewState["IsPageValidCombined"] = (Page.IsValid);
        //    }
        //}

        //protected void dgvAddEditFabrics_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;

        //    if (item.ItemIndex > -1 && item.DataItem is KeyValuePair<int, KeyValuePair<int, string>>) // KeyValuePair<Tuple<int, int>, int>)
        //    {
        //        //KeyValuePair<Tuple<int, int>, int> kv = (KeyValuePair<Tuple<int, int>, int>)item.DataItem;
        //        KeyValuePair<int, KeyValuePair<int, string>> kv = (KeyValuePair<int, KeyValuePair<int, string>>)item.DataItem;

        //        //Literal litVFID = (Literal)item.FindControl("litVFID");
        //        Literal litID = (Literal)item.FindControl("litID");
        //        Literal litFabricTypeID = (Literal)item.FindControl("litFabricTypeID");
        //        Literal litFabricType = (Literal)item.FindControl("litFabricType");
        //        Literal litCode = (Literal)item.FindControl("litCode");
        //        Literal litFabricNickName = (Literal)item.FindControl("litFabricNickName");
        //        Literal litFabricSupplier = (Literal)item.FindControl("litFabricSupplier");
        //        TextBox txtWhere = (TextBox)item.FindControl("txtWhere");

        //        litFabricTypeID.Text = kv.Key.ToString();

        //        int value = kv.Key;
        //        FabricType type = (FabricType)value;
        //        litFabricType.Text = type.ToString();

        //        //populate FabricCodeType dropdown
        //        //DropDownList ddlfabricCodeType = (DropDownList)item.FindControl("ddlfabricCodeType");
        //        //ddlfabricCodeType.Items.Add(new ListItem("Select Fabric Type", "0"));
        //        //foreach (FabricCodeTypeBO fabCodeType in (new FabricCodeTypeBO()).SearchObjects())
        //        //{
        //        //    ListItem listItemcolor = new ListItem(fabCodeType.Name, fabCodeType.ID.ToString());
        //        //    ddlfabricCodeType.Items.Add(listItemcolor);
        //        //}

        //        //if (kv.Key.Item1 > 0)
        //        //{
        //        //    VisualLayoutFabricBO objVLF = new VisualLayoutFabricBO();
        //        //    objVLF.ID = kv.Key.Item1;
        //        //    objVLF.GetObject();

        //        //    litVFID.Text = objVLF.ID.ToString();
        //        //    litID.Text = objVLF.Fabric.ToString();
        //        //    litCode.Text = objVLF.objFabric.Code;
        //        //    litFabricNickName.Text = objVLF.objFabric.NickName;
        //        //    litFabricSupplier.Text = objVLF.objFabric.objSupplier.Name;
        //        //    ddlfabricCodeType.Items.FindByValue(kv.Key.Item2.ToString()).Selected = true;
        //        //}
        //        //else
        //        //{
        //        FabricCodeBO objFC = new FabricCodeBO();
        //        objFC.ID = kv.Value.Key;
        //        objFC.GetObject();

        //        txtWhere.Text = kv.Value.Value;

        //        //litVFID.Text = "0";
        //        litID.Text = objFC.ID.ToString();
        //        litCode.Text = objFC.Code;
        //        litFabricNickName.Text = objFC.NickName;
        //        litFabricSupplier.Text = (objFC.Supplier.HasValue && objFC.Supplier.Value > 0) ? objFC.objSupplier.Name : string.Empty;
        //        //    ddlfabricCodeType.Items.FindByValue(kv.Key.Item2.ToString()).Selected = true;
        //        //}
        //    }
        //}

        //protected void dgvAddEditFabrics_ItemCommand(object source, DataGridCommandEventArgs e)
        //{
        //    ResetViewStateValues();

        //    string commandName = e.CommandName;

        //    switch (commandName)
        //    {
        //        case "Delete":
        //            Literal litID = (Literal)e.Item.FindControl("litID");
        //            int fabric = int.Parse(litID.Text.ToString());

        //            Literal litFabricTypeID = (Literal)e.Item.FindControl("litFabricTypeID");
        //            int fabricType = int.Parse(litFabricTypeID.Text);

        //            this.PopulateFabricDataGrid(fabric, fabricType, true);
        //            ViewState["IsPageValidCombined"] = false;

        //            break;
        //        default:
        //            break;
        //    }
        //}

        //protected void ddlFabricCodeType_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    ViewState["IsPageValidCombined"] = false;

        //    int type = int.Parse(((System.Web.UI.WebControls.ListControl)(sender)).SelectedValue);

        //    if (type == (int)FabricType.Lining)
        //    {
        //        PopulateFilteredFabrics(true);
        //    }
        //    else
        //    {
        //        PopulateFilteredFabrics(false);
        //    }
        //}

        //protected void ddlAddFabrics_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    ViewState["IsPageValidCombined"] = false;

        //    int fabric = int.Parse(((System.Web.UI.WebControls.ListControl)(sender)).SelectedValue);
        //    int fabricType = int.Parse(ddlFabricCodeType.SelectedValue);

        //    CustomValidator cv = null;

        //    if (ddlFabricCodeType.SelectedIndex < 1)
        //    {
        //        cv = new CustomValidator();
        //        cv.IsValid = false;
        //        cv.ValidationGroup = "valCombined";
        //        cv.ErrorMessage = "Fabric Type is required.";
        //        Page.Validators.Add(cv);
        //    }
        //    else if (fabric > 0)
        //    {
        //        List<KeyValuePair<int, KeyValuePair<int, string>>> lstFabrics = (List<KeyValuePair<int, KeyValuePair<int, string>>>)Session["CombinedFabrics"];

        //        if (fabricType == 0 && lstFabrics.Where(o => o.Key == 0).Any())
        //        {
        //            cv = new CustomValidator();
        //            cv.IsValid = false;
        //            cv.ValidationGroup = "valCombined";
        //            cv.ErrorMessage = "Main Fabric alredy exists in the list.";
        //            Page.Validators.Add(cv);
        //        }
        //        else if (lstFabrics.Where(o => o.Value.Key == fabric).Any())
        //        {
        //            cv = new CustomValidator();
        //            cv.IsValid = false;
        //            cv.ValidationGroup = "valCombined";
        //            cv.ErrorMessage = "This Fabric alredy exists in the list.";
        //            Page.Validators.Add(cv);
        //        }
        //        else
        //        {
        //            this.PopulateFabricDataGrid(fabric, fabricType);
        //        }
        //    }
        //    this.ddlAddFabrics.SelectedIndex = 0;
        //}

        //protected void linkBreakDown_Click(object sender, EventArgs e)
        //{
        //    this.ResetViewStateValues();
        //    this.dgvAddEditFabrics.DataSource = null;
        //    this.dgvAddEditFabrics.DataBind();

        //    ViewState["IsPageValidCombined"] = false;

        //    LinkButton linkBreakDown = (LinkButton)sender;
        //    this.FabricID = int.Parse(linkBreakDown.Attributes["qid"]);
        //    this.hdnSelectedFabricCodeID.Value = this.FabricID.ToString();

        //    this.PopulateFabricDataGrid(0, 0);
        //}

        //protected void btnNewCombinedFabric_Click(object sender, EventArgs e)
        //{
        //    this.ResetViewStateValues();

        //    ViewState["IsPageValidCombined"] = false;

        //    txtFabricCode.Text = string.Empty;
        //    txtCombinedName.Text = string.Empty;
        //    txtCombinedNickName.Text = string.Empty;
        //    this.FabricID = 0;
        //    this.dgvAddEditFabrics.DataSource = null;
        //    this.dgvAddEditFabrics.DataBind();

        //    this.PopulateFabricDataGrid(0, 0);
        //}

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int itemId = int.Parse(this.hdnSelectedFabricCodeID.Value.ToString().Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(itemId, "FabricCode", "Code", this.txtCode.Text);
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
            //Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;

            // Popup Header Text
            this.lblPopupHeaderText.Text = "New Fabric Code";

            // Populate Country
            this.ddlCountry.Items.Add(new ListItem("Select your country", "0"));
            foreach (CountryBO country in (new CountryBO()).GetAllObject())
            {
                this.ddlCountry.Items.Add(new ListItem(country.ShortName, country.ID.ToString()));
            }

            // Populate Currncy
            this.ddlLandedCurrency.Items.Add(new ListItem("Select your currency", "0"));
            foreach (CurrencyBO currency in (new CurrencyBO()).GetAllObject())
            {
                this.ddlLandedCurrency.Items.Add(new ListItem(currency.Name, currency.ID.ToString()));
            }

            //populate supplier
            this.ddlSupplier.Items.Clear();
            this.ddlSupplier.Items.Add(new ListItem("Select Supplier", "0"));
            List<SupplierBO> lstSupplier = (new SupplierBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (SupplierBO sup in lstSupplier)
            {
                this.ddlSupplier.Items.Add(new ListItem(sup.Name, sup.ID.ToString()));
            }

            //populate unit
            this.ddlUnit.Items.Clear();
            this.ddlUnit.Items.Add(new ListItem("Select Unit", "0"));
            List<UnitBO> lstUnit = (new UnitBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (UnitBO unit in lstUnit)
            {
                this.ddlUnit.Items.Add(new ListItem(unit.Name, unit.ID.ToString()));
            }

            //populate unit
            this.ddlFabricColor.Items.Clear();
            this.ddlFabricColor.Items.Add(new ListItem("Select Color", "0"));
            List<AccessoryColorBO> lstAccessorycolor = (new AccessoryColorBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (AccessoryColorBO unit in lstAccessorycolor)
            {
                this.ddlFabricColor.Items.Add(new ListItem(unit.Name, unit.ID.ToString()));
            }

            this.ddlFilterFabricType.Items.Clear();
            this.ddlFilterFabricType.Items.Add(new ListItem("Pure Fabrics", "1"));
            this.ddlFilterFabricType.Items.Add(new ListItem("Combined Fabrics", "0"));
            this.ddlFilterFabricType.Items.Add(new ListItem("All", "2"));

            this.ddlFilterFabricType.Items.FindByValue(this.QueryType.ToString()).Selected = true;

            //Fabric Types
            //ddlFabricCodeType.Items.Clear();
            //ddlFabricCodeType.Items.Add(new ListItem("Select a Type", "-1"));
            //int fabricCodeType = 0;
            //foreach (FabricType type in Enum.GetValues(typeof(FabricType)))
            //{
            //    ddlFabricCodeType.Items.Add(new ListItem(type.ToString(), fabricCodeType++.ToString()));
            //}

            this.ResetViewStateValues();
            this.PopulateDataGrid();
            //this.PopulateFabrics();

            // hide columns
            this.RadGridFabricCode.MasterTableView.GetColumn("SupplierID").Display = false;
            this.RadGridFabricCode.MasterTableView.GetColumn("CountryID").Display = false;
            this.RadGridFabricCode.MasterTableView.GetColumn("Material").Display = false;
            this.RadGridFabricCode.MasterTableView.GetColumn("DenierCount").Display = false;
            this.RadGridFabricCode.MasterTableView.GetColumn("Filaments").Display = false;
            this.RadGridFabricCode.MasterTableView.GetColumn("SerialOrder").Display = false;
            this.RadGridFabricCode.MasterTableView.GetColumn("LandedCurrency").Display = false;
            this.RadGridFabricCode.MasterTableView.GetColumn("UnitID").Display = false;
            this.RadGridFabricCode.MasterTableView.GetColumn("FabricColorID").Display = false;
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
            FabricCodeDetailsViewBO objFabricCode = new FabricCodeDetailsViewBO();

            if (this.QueryType == 0) // combined
            {
                objFabricCode.IsPure = false;
                objFabricCode.IsLiningFabric = false;

                btnNewPureFabric.Visible = false;
                btnNewCombinedFabric.Visible = true;

                this.RadGridFabricCode.MasterTableView.GetColumn("IsLining").Display = false;
                this.RadGridFabricCode.MasterTableView.GetColumn("Supplier").Display = false;
                this.RadGridFabricCode.MasterTableView.GetColumn("Country").Display = false;
                this.RadGridFabricCode.MasterTableView.GetColumn("GSM").Display = false;
                this.RadGridFabricCode.MasterTableView.GetColumn("FabricPrice").Display = false;
                this.RadGridFabricCode.MasterTableView.GetColumn("FabricWidth").Display = false;
                this.RadGridFabricCode.MasterTableView.GetColumn("Unit").Display = false;
            }
            else if (this.QueryType == 1) // pure
            {
                objFabricCode.IsPure = true;
                btnNewPureFabric.Visible = true;
                btnNewCombinedFabric.Visible = false;

                this.RadGridFabricCode.MasterTableView.GetColumn("IsLining").Display = true;
                this.RadGridFabricCode.MasterTableView.GetColumn("Supplier").Display = true;
                this.RadGridFabricCode.MasterTableView.GetColumn("Country").Display = true;
                this.RadGridFabricCode.MasterTableView.GetColumn("GSM").Display = true;
                this.RadGridFabricCode.MasterTableView.GetColumn("FabricPrice").Display = true;
                this.RadGridFabricCode.MasterTableView.GetColumn("FabricWidth").Display = true;
                this.RadGridFabricCode.MasterTableView.GetColumn("Unit").Display = true;
            }
            else // All
            {
                btnNewPureFabric.Visible = true;
                btnNewCombinedFabric.Visible = true;

                this.RadGridFabricCode.MasterTableView.GetColumn("IsLining").Display = true;
                this.RadGridFabricCode.MasterTableView.GetColumn("Supplier").Display = true;
                this.RadGridFabricCode.MasterTableView.GetColumn("Country").Display = true;
                this.RadGridFabricCode.MasterTableView.GetColumn("GSM").Display = true;
                this.RadGridFabricCode.MasterTableView.GetColumn("FabricPrice").Display = true;
                this.RadGridFabricCode.MasterTableView.GetColumn("FabricWidth").Display = true;
                this.RadGridFabricCode.MasterTableView.GetColumn("Unit").Display = true;
            }

            // Sort by condition
            List<FabricCodeDetailsViewBO> lstFabricCode = new List<FabricCodeDetailsViewBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstFabricCode = (from o in objFabricCode.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                 where (
                                        (o.Code.ToLower().Contains(searchText)) ||
                                         (o.Name.ToLower().Contains(searchText)) ||
                                         (o.Country.Contains(searchText)) ||
                                         (o.Supplier.ToLower().Contains(searchText)) ||
                                         (o.NickName.ToLower().Contains(searchText))
                                        )
                                 select o).ToList();
            }
            else
            {
                lstFabricCode = objFabricCode.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<FabricCodeDetailsViewBO>();
            }

            if (lstFabricCode.Count > 0)
            {
                this.RadGridFabricCode.AllowPaging = (lstFabricCode.Count > this.RadGridFabricCode.PageSize);
                this.RadGridFabricCode.DataSource = lstFabricCode;
                this.RadGridFabricCode.DataBind();
                Session["FabricCodeDetails"] = lstFabricCode;

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
            }

            this.RadGridFabricCode.Visible = (lstFabricCode.Count > 0);
        }

        private void ProcessForm(int fabricID, bool isDelete, bool isPure)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    FabricCodeBO objFabricCode = new FabricCodeBO(this.ObjContext);
                    if (fabricID > 0)
                    {
                        objFabricCode.ID = fabricID;
                        objFabricCode.GetObject();
                    }

                    if (isDelete)
                    {
                        objFabricCode.Delete();
                    }
                    else
                    {
                        //if (isPure)
                        //{
                        objFabricCode.Code = this.txtCode.Text;
                        objFabricCode.Name = this.txtName.Text;
                        objFabricCode.NickName = (!String.IsNullOrEmpty(this.txtNickName.Text)) ? this.txtNickName.Text : string.Empty;
                        objFabricCode.IsActive = (this.chbIsActive.Checked) ? true : false;
                        objFabricCode.IsLiningFabric = (this.chkIsLining.Checked) ? true : false;
                        objFabricCode.IsPure = (this.chbIsPure.Checked) ? true : false;

                        objFabricCode.Supplier = int.Parse(this.ddlSupplier.SelectedValue);
                        objFabricCode.Material = (!String.IsNullOrEmpty(this.txtMaterial.Text)) ? this.txtMaterial.Text : string.Empty;
                        objFabricCode.GSM = (!String.IsNullOrEmpty(this.txtGsm.Text)) ? this.txtGsm.Text : string.Empty;
                        objFabricCode.DenierCount = (!String.IsNullOrEmpty(this.txtDenierCount.Text)) ? this.txtDenierCount.Text : string.Empty;
                        objFabricCode.Filaments = (!String.IsNullOrEmpty(this.txtFilaments.Text)) ? this.txtFilaments.Text : string.Empty;
                        objFabricCode.SerialOrder = (!String.IsNullOrEmpty(this.txtSerialOrder.Text)) ? this.txtSerialOrder.Text : string.Empty;
                        objFabricCode.FabricPrice = (!String.IsNullOrEmpty(this.txtFabricPrice.Text)) ? decimal.Parse(this.txtFabricPrice.Text) : decimal.Parse("0.0");
                        objFabricCode.Fabricwidth = (!String.IsNullOrEmpty(this.txtFabricWidth.Text)) ? this.txtFabricWidth.Text : string.Empty;
                        objFabricCode.Unit = int.Parse(this.ddlUnit.SelectedValue);
                        objFabricCode.FabricColor = int.Parse(this.ddlFabricColor.SelectedValue);
                        objFabricCode.Country = int.Parse(this.ddlCountry.SelectedValue);

                        if (int.Parse(this.ddlLandedCurrency.SelectedValue) > 0)
                        {
                            objFabricCode.LandedCurrency = int.Parse(this.ddlLandedCurrency.SelectedValue);
                        }
                        //}
                        //else
                        //{
                        //    objFabricCode.Code = this.txtFabricCode.Text;
                        //    objFabricCode.Name = this.txtCombinedName.Text;
                        //    objFabricCode.NickName = (!String.IsNullOrEmpty(this.txtCombinedNickName.Text)) ? this.txtCombinedNickName.Text : string.Empty;
                        //    objFabricCode.IsActive = (this.chkCombinedIsActive.Checked) ? true : false;

                        //    objFabricCode.IsLiningFabric = (this.chkIsLining.Checked) ? true : false;
                        //    objFabricCode.IsPure = false;
                        //    objFabricCode.Country = 14;
                        //}

                        if (fabricID == 0)
                        {
                            objFabricCode.Add();
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Saving Fabric", ex);
            }
        }

        //private void PopulateFabricDataGrid(int fabricID, int typeID, bool isDeleted = false)
        //{
        //    List<KeyValuePair<int, KeyValuePair<int, string>>> fcIds = this.GetFilteredFabricData(fabricID, typeID, isDeleted);

        //    this.dgvAddEditFabrics.DataSource = fcIds;
        //    this.dgvAddEditFabrics.DataBind();

        //    this.dgvAddEditFabrics.Visible = (this.dgvAddEditFabrics.Items.Count > 0);
        //    this.dvEmptyFabrics.Visible = !this.dgvAddEditFabrics.Visible;

        //    PopulateFabricName();
        //}

        //private void PopulateFabricName()
        //{
        //    string mainFabName = string.Empty;
        //    string secondaryFabName = string.Empty;
        //    string liningFabName = string.Empty;

        //    foreach (DataGridItem item in this.dgvAddEditFabrics.Items)
        //    {
        //        Literal litID = (Literal)item.FindControl("litID");
        //        Literal litFabricTypeID = (Literal)item.FindControl("litFabricTypeID");

        //        FabricCodeBO objFab = new FabricCodeBO();
        //        objFab.ID = int.Parse(litID.Text);
        //        objFab.GetObject();

        //        if (int.Parse(litFabricTypeID.Text) == 0)
        //        {
        //            mainFabName = objFab.Code;
        //        }
        //        else if (objFab.IsLiningFabric)
        //        {
        //            liningFabName += objFab.Code + "+";
        //        }
        //        else
        //        {
        //            secondaryFabName += objFab.Code + "+";
        //        }
        //    }

        //    liningFabName = string.IsNullOrEmpty(liningFabName) ? "" : "+" + liningFabName.Remove(liningFabName.Length - 1, 1);
        //    secondaryFabName = string.IsNullOrEmpty(secondaryFabName) ? "" : "+" + secondaryFabName.Remove(secondaryFabName.Length - 1, 1);

        //    string selectedFabric = mainFabName + secondaryFabName + liningFabName;
        //    this.txtFabricCode.Text = selectedFabric;
        //    //this.ddlFabric.Enabled = false;

        //    List<FabricCodeBO> lstFabricCodes = (List<FabricCodeBO>)Session["ListFabricCodes"];
        //    //this.ddlFabric.ClearSelection();

        //    if (!string.IsNullOrEmpty(selectedFabric) && lstFabricCodes != null)
        //    {
        //        try
        //        {
        //            lstFabricCodes = lstFabricCodes.Where(m => m.Code == selectedFabric).ToList();

        //            if (this.FabricID == 0 && lstFabricCodes.Any())
        //            {
        //                CustomValidator cv = new CustomValidator();
        //                cv.IsValid = false;
        //                cv.ValidationGroup = "valCombined";
        //                cv.ErrorMessage = "Fabric Code exists in the system.";
        //                Page.Validators.Add(cv);
        //            }
        //        }
        //        catch (Exception ex)
        //        {
        //            //lblVLFabricErrorText.Text = "The fabric combination selected, does not exist in Indiman Price List.  Please contact Indiman administrator to include in fabric combination list.";
        //        }
        //    }
        //}

        //private List<KeyValuePair<int, KeyValuePair<int, string>>> GetFilteredFabricData(int fabricID, int typeID, bool isDeleted)
        //{
        //    List<KeyValuePair<int, KeyValuePair<int, string>>> lst = new List<KeyValuePair<int, KeyValuePair<int, string>>>();

        //    foreach (DataGridItem item in this.dgvAddEditFabrics.Items)
        //    {
        //        Literal litID = (Literal)item.FindControl("litID");
        //        Literal litFabricTypeID = (Literal)item.FindControl("litFabricTypeID");
        //        Literal litFabricType = (Literal)item.FindControl("litFabricType");
        //        TextBox txtWhere = (TextBox)item.FindControl("txtWhere");

        //        lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>(int.Parse(litFabricTypeID.Text), new KeyValuePair<int, string>(int.Parse(litID.Text), txtWhere.Text)));
        //    }

        //    if (fabricID > 0) // Add, Delete
        //    {
        //        if (isDeleted)
        //        {
        //            KeyValuePair<int, KeyValuePair<int, string>> removeFabric = lst.Where(m => m.Key == typeID && m.Value.Key == fabricID).SingleOrDefault();
        //            lst.Remove(removeFabric);
        //        }
        //        else
        //        {
        //            lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>(typeID, new KeyValuePair<int, string>(fabricID, "")));
        //        }
        //    }
        //    else // Page edit mode to load all data 
        //    {
        //        if (this.FabricID > 0)
        //        {
        //            FabricCodeBO objFabric = new FabricCodeBO();
        //            objFabric.ID = FabricID;
        //            objFabric.GetObject();

        //            this.txtCombinedName.Text = objFabric.Name;
        //            this.txtCombinedNickName.Text = objFabric.NickName;

        //            try
        //            {
        //                string[] codes = objFabric.Code.Split('+');
        //                //string[] wheres = string.IsNullOrEmpty(objVL.Where) ? new string[0] : objVL.Where.Split(',');

        //                List<KeyValuePair<int, string>> lstWheres = new List<KeyValuePair<int, string>>();

        //                //foreach (string whereText in wheres)
        //                //{
        //                //    lstWheres.Add(new KeyValuePair<int, string>(int.Parse(whereText.Split('-')[0]), whereText.Split('-')[1]));
        //                //}

        //                List<FabricCodeBO> lstFabricCodes = (List<FabricCodeBO>)Session["ListFabricCodes"];

        //                int fabricPosition = 0;

        //                foreach (string code in codes)
        //                {
        //                    FabricCodeBO objFabCode = lstFabricCodes.Where(m => m.Code == code).Single();
        //                    string whereText = lstWheres.Where(m => m.Key == objFabCode.ID).SingleOrDefault().Value;

        //                    if (++fabricPosition == 1)
        //                    {
        //                        lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>((int)FabricType.Main, new KeyValuePair<int, string>(objFabCode.ID, whereText)));
        //                    }
        //                    else if (objFabCode.IsLiningFabric)
        //                    {
        //                        lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>((int)FabricType.Lining, new KeyValuePair<int, string>(objFabCode.ID, whereText)));
        //                    }
        //                    else
        //                    {
        //                        lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>((int)FabricType.Secondary, new KeyValuePair<int, string>(objFabCode.ID, whereText)));
        //                    }
        //                }
        //            }
        //            catch (Exception ex)
        //            {

        //            }
        //        }
        //    }

        //    Session["CombinedFabrics"] = lst;
        //    return lst;
        //}

        //private void PopulateFilteredFabrics(bool isLining)
        //{
        //    FabricCodeBO objFabric = new FabricCodeBO();
        //    objFabric.IsActive = true;
        //    objFabric.IsPure = true;
        //    objFabric.IsLiningFabric = isLining;

        //    Dictionary<int, string> filteredfabrics = objFabric.SearchObjects().AsQueryable().OrderBy(o => o.Name).ToList().Select(o => new { Key = o.ID, Value = (o.Code + " - " + o.NickName) }).ToDictionary(o => o.Key, o => o.Value);
        //    Dictionary<int, string> fdicFabrics = new Dictionary<int, string>();

        //    fdicFabrics.Add(0, "Please select or type...");
        //    foreach (KeyValuePair<int, string> item in filteredfabrics)
        //    {
        //        fdicFabrics.Add(item.Key, item.Value);
        //    }

        //    this.ddlAddFabrics.DataSource = fdicFabrics;
        //    this.ddlAddFabrics.DataTextField = "Value";
        //    this.ddlAddFabrics.DataValueField = "Key";
        //    this.ddlAddFabrics.DataBind();
        //}

        //private void PopulateFabrics()
        //{
        //    FabricCodeBO objFabric = new FabricCodeBO();
        //    objFabric.IsActive = true;

        //    List<FabricCodeBO> lstFabricCodes = objFabric.SearchObjects();
        //    Session["ListFabricCodes"] = lstFabricCodes;

        //    Dictionary<int, string> fabrics = lstFabricCodes.AsQueryable().OrderBy(o => o.Name).ToList().Select(o => new { Key = o.ID, Value = (o.Code + " - " + o.NickName) }).ToDictionary(o => o.Key, o => o.Value);
        //    Dictionary<int, string> dicFabrics = new Dictionary<int, string>();

        //    dicFabrics.Add(0, "Please select or type...");
        //    foreach (KeyValuePair<int, string> item in fabrics)
        //    {
        //        dicFabrics.Add(item.Key, item.Value);
        //    }
        //}

        private void ReBindGrid()
        {
            ResetViewStateValues();

            if (Session["FabricCodeDetails"] != null)
            {
                RadGridFabricCode.DataSource = (List<FabricCodeDetailsViewBO>)Session["FabricCodeDetails"];
                RadGridFabricCode.DataBind();
            }
        }

        private void ResetViewStateValues()
        {
            ViewState["IsPageValidPure"] = true;
            ViewState["IsPageValidCombined"] = true;
            Session["CombinedFabrics"] = new List<KeyValuePair<int, KeyValuePair<int, string>>>();
        }

        #endregion
    }
}