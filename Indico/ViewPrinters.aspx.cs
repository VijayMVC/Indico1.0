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
    public partial class ViewPrinters : IndicoPage
    {

        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ViewPrintersSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["ViewPrintersSortExpression"] = value;
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

        protected void RadGridPrinters_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPrinters_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPrinters_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is PrinterBO)
                {
                    PrinterBO objPrinter = (PrinterBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objPrinter.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objPrinter.ID.ToString());
                    linkDelete.Visible = !(objPrinter.VisualLayoutsWhereThisIsPrinter.Any() || objPrinter.ProductsWhereThisIsPrinter.Any());
                }
            }
        }

        protected void RadGridPrinters_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridPrinters_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dgPrinters_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is PrinterBO)
        //    {
        //        PrinterBO objPrinter = (PrinterBO)item.DataItem;

        //        Literal lblName = (Literal)item.FindControl("lblName");
        //        lblName.Text = objPrinter.Name;

        //        Literal lblDescription = (Literal)item.FindControl("lblDescription");
        //        lblDescription.Text = objPrinter.Description;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objPrinter.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objPrinter.ID.ToString());
        //        linkDelete.Visible = (objPrinter.OrdersWhereThisIsPrinter.Count == 0 || objPrinter.ProductsWhereThisIsPrinter.Count == 0);
        //    }
        //}

        //protected void dgPrinters_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgPrinters.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dgPrinters_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dgPrinters.Columns)
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
                int queryId = int.Parse(this.hdnSelectedPrintersID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(queryId, false);

                    Response.Redirect("/ViewPrinters.aspx");
                }

                // Popup Header Text
                this.lblPopupHeaderText.Text = ((queryId > 0) ? "Edit " : "New ") + "Printer";

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int queryId = int.Parse(this.hdnSelectedPrintersID.Value.Trim());

            this.ProcessForm(queryId, true);

            this.PopulateDataGrid();
        }

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int queryId = int.Parse(this.hdnSelectedPrintersID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(queryId, "Printer", "Name", this.txtPrintersName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewPrinters.aspx", ex);
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
            this.litHeaderText.Text = this.ActivePage.Heading; //this.ActivePage.Heading;

            // Popup Header Text
            this.lblPopupHeaderText.Text = "New Printer";

            ViewState["IsPageValied"] = true;
            Session["EmbroideryStatusDetails"] = null;

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

            // Populate Resolution Profiles
            PrinterBO objPrinter = new PrinterBO();

            List<PrinterBO> lstPrinter = new List<PrinterBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstPrinter = (from o in objPrinter.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                              where o.Name.ToLower().Contains(searchText) ||
                              o.Description.ToLower().Contains(searchText)
                              select o).ToList();
            }
            else
            {
                lstPrinter = objPrinter.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<PrinterBO>();
            }

            if (lstPrinter.Count > 0)
            {
                this.RadGridPrinters.AllowPaging = (lstPrinter.Count > this.RadGridPrinters.PageSize);
                this.RadGridPrinters.DataSource = lstPrinter;
                this.RadGridPrinters.DataBind();
                Session["EmbroideryStatusDetails"] = lstPrinter;

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
                this.btnAddPrinters.Visible = false;
            }

            this.RadGridPrinters.Visible = (lstPrinter.Count > 0);
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
                    PrinterBO objPrinter = new PrinterBO(this.ObjContext);
                    if (queryId > 0)
                    {
                        objPrinter.ID = queryId;
                        objPrinter.GetObject();
                    }

                    if (isDelete)
                    {
                        objPrinter.Delete();
                    }
                    else
                    {
                        objPrinter.Name = this.txtPrintersName.Text;
                        objPrinter.Description = this.txtDescription.Text;


                        if (queryId == 0)
                        {
                            objPrinter.Add();
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                //IndicoLogging.log("Error occured while Adding the Item", ex);
            }
        }

        private void ReBindGrid()
        {
            if (Session["EmbroideryStatusDetails"] != null)
            {
                RadGridPrinters.DataSource = (List<PrinterBO>)Session["EmbroideryStatusDetails"];
                RadGridPrinters.DataBind();
            }
        }

        #endregion
    }
}