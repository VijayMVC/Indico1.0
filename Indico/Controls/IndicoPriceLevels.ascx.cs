using Indico.BusinessObjects;
using Indico.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;

namespace Indico.Controls
{
    public partial class IndicoPriceLevels : System.Web.UI.UserControl
    {
        #region Fields

        private UserBO currentUser = null;
        private IndicoContext context = null;
        private bool displayPriceLevels = false;
        private bool displayIndimanPrice = false;
        private bool displayJKPrice = false;
        private bool displayFOBCost = false;
        private bool displayMarginRates = false;
        private bool displayFabricPrice = false;
        private bool displayCostSheet = false;
        private bool displayIndicoPricesOnly = false;
        private bool isFOB = false;
        private string modifiedText = string.Empty;

        #endregion

        #region Properties

        public UserBO LoggedUser
        {
            get
            {
                if (this.currentUser != null)
                {
                    return currentUser;
                }

                if (Session["in_uid"] != null)
                {
                    currentUser = new UserBO(this.ObjContext);
                    currentUser.ID = Convert.ToInt32(Session["in_uid"]);
                    currentUser.GetObject();
                }
                else
                {
                    currentUser = null;
                }
                return currentUser;
            }
        }

        public IndicoContext ObjContext
        {
            get
            {
                if (context == null)
                {
                    context = new IndicoContext();
                }
                return context;
            }
        }

        public bool DisplayPriceLevels
        {
            get
            {
                return displayPriceLevels;
            }
            set
            {
                displayPriceLevels = value;
            }
        }

        public bool DisplayIndimanPrice
        {
            get
            {
                return displayIndimanPrice;
            }
            set
            {
                displayIndimanPrice = value;
            }
        }

        public bool DisplayJKPrice
        {
            get
            {
                return displayJKPrice;
            }
            set
            {
                displayJKPrice = value;
            }
        }

        public bool DisplayFOBCost
        {
            get
            {
                return displayFOBCost;
            }
            set
            {
                displayFOBCost = value;
            }
        }

        public bool DisplayMarginRates
        {
            get
            {
                return displayMarginRates;
            }
            set
            {
                displayMarginRates = value;
            }
        }

        public bool DisplayFabricPrice
        {
            get
            {
                return displayFabricPrice;
            }
            set
            {
                displayFabricPrice = value;
            }
        }

        public bool DisplayCostSheet
        {
            get
            {
                return displayCostSheet;
            }
            set
            {
                displayCostSheet = value;
            }
        }

        public bool IsFOB
        {
            get
            {
                return isFOB;
            }
            set
            {
                isFOB = value;
            }
        }

        public string ModifiedText
        {
            get
            {
                return modifiedText;
            }
            set
            {
                modifiedText = value;
            }
        }

        #endregion

        #region Constructors

        #endregion

        #region Events

        protected void RadGridCostSheets_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridCostSheets_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridCostSheets_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is DataRowView)
                {
                    DataRowView objPrice = (DataRowView)item.DataItem;

                    HyperLink hlCostSheet = (HyperLink)item.FindControl("hlCostSheet");
                    hlCostSheet.Text = objPrice["CostSheetId"].ToString();
                    hlCostSheet.NavigateUrl = "../AddEditFactoryCostSheet.aspx?id=" + objPrice["CostSheetId"].ToString();

                    Literal litFabricCost = (Literal)item.FindControl("litFabricCost");
                    litFabricCost.Text = "$" + objPrice["FabricPrice"].ToString();

                    Literal litIndimanPrice = (Literal)item.FindControl("litIndimanPrice");
                    litIndimanPrice.Text = "$" + ((this.DisplayMarginRates && !this.IsFOB) ? string.Empty : objPrice["IndimanPrice"].ToString());

                    TextBox txtIndimanPrice = (TextBox)item.FindControl("txtIndimanPrice");
                    txtIndimanPrice.Text = objPrice["IndimanPrice"].ToString();
                    txtIndimanPrice.Visible = this.DisplayMarginRates && !this.IsFOB;

                    HiddenField hdnCSID = (HiddenField)e.Item.FindControl("hdnCSID");
                    hdnCSID.Value = objPrice["CostSheetId"].ToString();

                    Literal litActMgn = (Literal)item.FindControl("litActMgn");
                    litActMgn.Text = "$" + objPrice["ActMgn"].ToString();

                    Literal litQuotedMp = (Literal)item.FindControl("litQuotedMp");
                    litQuotedMp.Text = objPrice["QuotedMp"].ToString() + "%";

                    Literal litFOBCost = (Literal)item.FindControl("litFOBCost");
                    litFOBCost.Text = "$" + objPrice["FOBCost"].ToString();

                    Literal litQuotedFOBPrice = (Literal)item.FindControl("litQuotedFOBPrice");
                    litQuotedFOBPrice.Text = "$" + objPrice["QuotedFOBPrice"].ToString();

                    DateTime dtModified = DateTime.Parse(objPrice["ModifiedDate"].ToString());

                    if (dtModified.Year != 1900)
                    {
                        Literal litModifiedDate = (Literal)item.FindControl("litModifiedDate");
                        litModifiedDate.Text = dtModified.ToShortDateString();
                    }

                    int column = 18;

                    if (DisplayPriceLevels)
                    {
                        List<PriceLevelNewBO> lstPriceLevels = new PriceLevelNewBO().SearchObjects();

                        foreach (PriceLevelNewBO objLevel in lstPriceLevels)
                        {
                            item.Cells[column].Text = objPrice[objLevel.Volume.Replace(' ', '_')].ToString();  //"$" + ((objPrice.IndimanPrice ?? 0) / Convert.ToDecimal(((100 - objLevel.Markup) / 100))).ToString("0.00");
                            item.Cells[column++].HorizontalAlign = HorizontalAlign.Right;
                        }

                        TextBox txtPrice = new TextBox();
                        txtPrice.ID = "txtPrice";
                        txtPrice.Width = Unit.Pixel(50);
                        txtPrice.CssClass = "iWhatPrice";
                        item["WhatPrice"].Controls.Add(txtPrice);

                        TextBox txtPercentage = new TextBox();
                        txtPercentage.ID = "txtPercentage";
                        txtPercentage.Width = Unit.Pixel(50);
                        txtPercentage.CssClass = "iWhatPercentage";
                        item["WhatPercentage"].Controls.Add(txtPercentage);
                    }
                }
            }
        }

        protected void RadGridCostSheets_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
            else if (e.CommandName == "Save")
            {
                try
                {
                    TextBox txtIndimanPrice = (TextBox)e.Item.FindControl("txtIndimanPrice");
                    HiddenField hdnCSID = (HiddenField)e.Item.FindControl("hdnCSID");

                    int costSheetID = int.Parse(hdnCSID.Value);

                    if (costSheetID > 0)
                    {
                        CostSheetBO objCS = new CostSheetBO(this.ObjContext);
                        objCS.ID = costSheetID;
                        objCS.GetObject();

                        objCS.QuotedCIF = Convert.ToDecimal(string.IsNullOrEmpty(txtIndimanPrice.Text) ? "0.00" : txtIndimanPrice.Text);

                        this.ObjContext.SaveChanges();

                        Page.Response.Redirect(Request.RawUrl);
                    }
                }
                catch (Exception ex)
                {
                    // Log the error
                    IndicoLogging.log.Error("Error occured while saving indiman price to the Cost Sheet from IndicoPriceLevels.ascx", ex);
                }
            }
        }

        protected void RadGridCostSheets_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridCostSheets_ItemCreated(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridHeaderItem)
            {
                if (DisplayPriceLevels)
                {
                    IndicoPage page = new IndicoPage();
                    GridHeaderItem item = (GridHeaderItem)e.Item;
                    List<PriceLevelNewBO> lstPriceLevels = new PriceLevelNewBO().SearchObjects();

                    foreach (PriceLevelNewBO objLevel in lstPriceLevels)
                    {
                        TableCell cell = (TableCell)item[objLevel.Volume.Replace(' ', '_')];

                        Label lblBR = new Label();
                        lblBR.Text = objLevel.Volume + " units</br>";
                        cell.Controls.Add(lblBR);

                        if (page.LoggedUserRoleName == IndicoPage.UserRole.IndimanAdministrator || page.LoggedUserRoleName == IndicoPage.UserRole.IndicoAdministrator)
                        {
                            Button btnApply = new Button();
                            btnApply.Text = "Apply";
                            btnApply.CssClass = "btn btn-info";
                            btnApply.ForeColor = Color.White;
                            btnApply.Click += btnApply_Click;
                            btnApply.CommandName = objLevel.ID.ToString();

                            TextBox txtPrice = new TextBox();
                            txtPrice.ID = "txtPrice" + objLevel.ID.ToString();
                            txtPrice.Text = objLevel.Markup.ToString();
                            txtPrice.Width = Unit.Pixel(50);
                            txtPrice.BorderStyle = BorderStyle.Inset;
                            txtPrice.Height = Unit.Pixel(15);
                            txtPrice.Width = Unit.Pixel(40);

                            cell.Controls.Add(txtPrice);
                            cell.Controls.Add(btnApply);
                        }
                        else
                        {
                            Label lblPercentage = new Label();
                            lblPercentage.Text = objLevel.Markup.ToString() + "%";
                            lblPercentage.Width = Unit.Pixel(50);
                            cell.Controls.Add(lblPercentage);
                        }
                    }
                }
            }
            else if (e.Item is GridDataItem)
            {
                if (this.DisplayMarginRates && !this.IsFOB)
                {
                    var item = e.Item as GridDataItem;
                    DataRowView objPrice = (DataRowView)item.DataItem;

                    Button btnSave = new Button();
                    btnSave.ID = "btnSave";
                    btnSave.Text = "Save";
                    btnSave.CssClass = "btn btn-info";
                    btnSave.ForeColor = Color.White;
                    btnSave.Width = Unit.Pixel(50);
                    btnSave.CommandName = "Save";
                    item["Save"].Controls.Add(btnSave);
                }
            }
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                PopulateControls();
            }
        }

        protected void btnApply_Click(object sender, EventArgs e)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    Button btn = (Button)(sender);
                    int level = int.Parse(btn.CommandName);

                    GridHeaderItem header = (GridHeaderItem)this.RadGridCostSheets.MasterTableView.GetItems(GridItemType.Header)[0];
                    TextBox txtPrice = (TextBox)header.FindControl("txtPrice" + level);

                    PriceLevelNewBO objLevel = new PriceLevelNewBO(this.ObjContext);
                    objLevel.ID = level;
                    objLevel.GetObject();

                    objLevel.LastModifier = this.LoggedUser.ID;
                    objLevel.LastModifiedDate = DateTime.Now;
                    objLevel.Markup = decimal.Parse(txtPrice.Text);

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }

                if (IsFOB)
                {
                    Server.Transfer("EditIndicoFOBPriceLevel.aspx");
                }
                else
                {
                    Server.Transfer("EditIndicoCIFPriceLevel.aspx");
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while saving value to PriceLevelNewBO from IndicoPriceLevels.ascx", ex);
            }
        }

        protected void btnBulkSave_Click(object sender, EventArgs e)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    foreach (GridDataItem item in RadGridCostSheets.Items)
                    {
                        TextBox txtIndimanPrice = (TextBox)item.FindControl("txtIndimanPrice");
                        HiddenField hdnCSID = (HiddenField)item.FindControl("hdnCSID");

                        int costSheetID = int.Parse(hdnCSID.Value);

                        if (costSheetID > 0)
                        {
                            CostSheetBO objCS = new CostSheetBO(this.ObjContext);
                            objCS.ID = costSheetID;
                            objCS.GetObject();

                            objCS.QuotedCIF = Convert.ToDecimal(string.IsNullOrEmpty(txtIndimanPrice.Text) ? "0.00" : txtIndimanPrice.Text);
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }

                Page.Response.Redirect(Request.RawUrl);
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while bulk saving indiman price to CostSheetBO from IndicoPriceLevels.ascx", ex);
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            btnBulkSave.Visible = !this.IsFOB && this.DisplayMarginRates;
            Session["CostSheetDetails"] = null;
            this.PopulateDataGrid();
        }

        private void PopulateDataGrid()
        {
            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            // Populate Items
            IndicoCIFPriceViewBO objPrice = new IndicoCIFPriceViewBO();            
            List<IndicoCIFPriceViewBO> lstCostSheets = objPrice.SearchObjects().OrderBy(m => m.PatternCode).ToList();

            if (IsFOB)
                lstCostSheets.ForEach(m => m.IndimanPrice = (m.IndimanPrice - m.ConversionFactor));

            DataTable dtCostSheets = ToDataTable(lstCostSheets);

            if (lstCostSheets.Count > 0)
            {
                this.RadGridCostSheets.AllowPaging = (lstCostSheets.Count > this.RadGridCostSheets.PageSize);

                if (DisplayPriceLevels)
                {
                    List<PriceLevelNewBO> lstPriceLevels = new PriceLevelNewBO().SearchObjects();

                    if (lstPriceLevels.Any())
                    {
                        ViewState["LevelCount"] = lstPriceLevels.Count;

                        foreach (PriceLevelNewBO objLevel in lstPriceLevels)
                        {
                            string colName = objLevel.Volume.Replace(' ', '_');

                            GridTemplateColumn tempColumn = new GridTemplateColumn();
                            tempColumn.AllowFiltering = true;
                            tempColumn.DataField = colName;
                            tempColumn.FilterControlWidth = Unit.Pixel(50);
                            tempColumn.UniqueName = colName;
                            //tempColumn.HeaderText = objLevel.Volume + " units";
                            RadGridCostSheets.Columns.Add(tempColumn);

                            DataColumn columnLevel = new DataColumn(colName, typeof(string));
                            columnLevel.DefaultValue = "$0.00";
                            dtCostSheets.Columns.Add(columnLevel);

                            int row = 0;
                            foreach (IndicoCIFPriceViewBO objCostSheet in lstCostSheets)
                            {
                                dtCostSheets.Rows[row++][columnLevel] = "$" + ((objCostSheet.IndimanPrice ?? 0) / Convert.ToDecimal(((100 - objLevel.Markup) / 100))).ToString("0.00");
                            }
                        }

                        GridTemplateColumn whatIfPriceColumn = new GridTemplateColumn();
                        whatIfPriceColumn.FilterControlWidth = Unit.Pixel(50);

                        whatIfPriceColumn.AllowFiltering = false;
                        whatIfPriceColumn.UniqueName = "WhatPrice";
                        RadGridCostSheets.Columns.Add(whatIfPriceColumn);
                        whatIfPriceColumn.HeaderText = "What-if Price";

                        GridTemplateColumn whatIfPercentageColumn = new GridTemplateColumn();
                        whatIfPercentageColumn.FilterControlWidth = Unit.Pixel(50);
                        whatIfPercentageColumn.AllowFiltering = false;
                        whatIfPercentageColumn.UniqueName = "WhatPercentage";
                        RadGridCostSheets.Columns.Add(whatIfPercentageColumn);
                        whatIfPercentageColumn.HeaderText = "What-if %";

                        litModified.Text = "Last Modified by " + lstPriceLevels.First().objLastModifier.GivenName + " " + lstPriceLevels.First().objLastModifier.FamilyName + " on " + lstPriceLevels.First().LastModifiedDate.ToShortDateString();
                    }
                }

                if (this.DisplayMarginRates && !this.IsFOB)
                {
                    GridTemplateColumn savePriceColumn = new GridTemplateColumn();
                    savePriceColumn.FilterControlWidth = Unit.Pixel(50);
                    savePriceColumn.AllowFiltering = false;
                    savePriceColumn.UniqueName = "Save";
                    RadGridCostSheets.Columns.Add(savePriceColumn);
                    savePriceColumn.HeaderText = string.Empty;
                }

                this.RadGridCostSheets.DataSource = dtCostSheets;
                this.RadGridCostSheets.DataBind();

                RadGridCostSheets.MasterTableView.GetColumn("LastModifier").Display = false;
                RadGridCostSheets.MasterTableView.GetColumn("ModifiedDate").Display = false;
                RadGridCostSheets.MasterTableView.GetColumn("Remarks").Display = false;

                RadGridCostSheets.MasterTableView.GetColumn("IndimanPrice").Visible = this.DisplayIndimanPrice;
                RadGridCostSheets.MasterTableView.GetColumn("QuotedFOBPrice").Visible = this.DisplayJKPrice;
                RadGridCostSheets.MasterTableView.GetColumn("FOBCost").Visible = this.DisplayFOBCost;
                RadGridCostSheets.MasterTableView.GetColumn("CostSheet").Visible = this.DisplayCostSheet;
                RadGridCostSheets.MasterTableView.GetColumn("ActMgn").Visible = this.DisplayMarginRates;
                RadGridCostSheets.MasterTableView.GetColumn("QuotedMp").Visible = this.DisplayMarginRates;
                RadGridCostSheets.MasterTableView.GetColumn("FabricPrice").Visible = this.DisplayFabricPrice;

                this.dvDataContent.Visible = true;

                Session["CostSheetDetails"] = dtCostSheets;
            }
            //else if ((searchText != string.Empty && searchText != "search"))
            //{
            //    this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

            //    this.dvDataContent.Visible = true;
            //    this.dvNoSearchResult.Visible = true;
            //}
            else
            {
                this.dvEmptyContent.Visible = true;
                //this.btnAddSetting.Visible = false;
            }

            this.RadGridCostSheets.Visible = (lstCostSheets.Count > 0);
        }

        private void ReBindGrid()
        {
            if (Session["CostSheetDetails"] != null)
            {
                RadGridCostSheets.DataSource = (DataTable)Session["CostSheetDetails"];

                RadGridCostSheets.MasterTableView.GetColumn("IndimanPrice").FilterControlWidth = Unit.Pixel(50);
                RadGridCostSheets.MasterTableView.GetColumn("QuotedFOBPrice").FilterControlWidth = Unit.Pixel(50);
                RadGridCostSheets.MasterTableView.GetColumn("FOBCost").FilterControlWidth = Unit.Pixel(50);
                RadGridCostSheets.MasterTableView.GetColumn("CostSheet").FilterControlWidth = Unit.Pixel(50);
                RadGridCostSheets.MasterTableView.GetColumn("ActMgn").FilterControlWidth = Unit.Pixel(50);
                RadGridCostSheets.MasterTableView.GetColumn("QuotedMp").FilterControlWidth = Unit.Pixel(50);
                RadGridCostSheets.MasterTableView.GetColumn("FabricPrice").FilterControlWidth = Unit.Pixel(50);

                if (this.DisplayMarginRates && !this.IsFOB)
                {
                    RadGridCostSheets.MasterTableView.GetColumn("Save").FilterControlWidth = Unit.Pixel(50);
                }

                int column = 16;

                if (DisplayPriceLevels)
                {
                    List<PriceLevelNewBO> lstPriceLevels = new PriceLevelNewBO().SearchObjects();

                    foreach (PriceLevelNewBO objLevel in lstPriceLevels)
                    {
                        RadGridCostSheets.Columns[column].FilterControlWidth = Unit.Pixel(50);
                        column++;
                    }

                    RadGridCostSheets.Columns[column].FilterControlWidth = Unit.Pixel(50);
                    RadGridCostSheets.Columns[++column].FilterControlWidth = Unit.Pixel(50);
                }

                //if (DisplayMarginRates)
                //    RadGridCostSheets.Columns[column].FilterControlWidth = Unit.Pixel(50);

                RadGridCostSheets.DataBind();
            }
        }

        public static DataTable ToDataTable<T>(List<T> items)
        {
            DataTable dataTable = new DataTable(typeof(T).Name);

            //Get all the properties
            PropertyInfo[] Props = typeof(T).GetProperties(BindingFlags.Public | BindingFlags.Instance);
            foreach (PropertyInfo prop in Props)
            {
                //Setting column names as Property names
                dataTable.Columns.Add(prop.Name);
            }
            foreach (T item in items)
            {
                var values = new object[Props.Length];
                for (int i = 0; i < Props.Length; i++)
                {
                    //inserting property values to datatable rows
                    values[i] = Props[i].GetValue(item, null);
                }
                dataTable.Rows.Add(values);
            }
            //put a breakpoint here and check datatable
            return dataTable;
        }

        #endregion
    }
}