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
    public partial class ViewPrinterTypes : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["PrinterTypeSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }

            set
            {
                ViewState["PrinterTypeSortExpression"] = value;
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

        #region Event

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

        protected void RadGridPrinterType_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPrinterType_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPrinterType_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is PrinterTypeBO)
                {
                    PrinterTypeBO objPrinterType = (PrinterTypeBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objPrinterType.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objPrinterType.ID.ToString());
                    linkDelete.Visible = (objPrinterType.PatternsWhereThisIsPrinterType.Count == 0) ? true : false;
                }
            }
        }

        protected void RadGridPrinterType_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridPrinterType_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridPrinterType_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is PrinterTypeBO)
        //    {
        //        PrinterTypeBO objPrinterType = (PrinterTypeBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objPrinterType.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objPrinterType.ID.ToString());
        //        linkDelete.Visible = (objPrinterType.PatternsWhereThisIsPrinterType.Count == 0);
        //    }
        //}

        //protected void dataGridPrinterType_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dataGridPrinterType.Columns)
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

        //protected void dataGridPrinterType_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridPrinterType.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        protected void btnDelete_Click(object sender, EventArgs e)
        {

            int printertypeId = int.Parse(this.hdnSelectedPrinterTypeID.Value.Trim());

            if (!Page.IsValid)
            {
                //Processform
                this.ProcessForm(printertypeId, true);

                this.PopulateDataGrid();
            }
            //ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int printertypeId = int.Parse(this.hdnSelectedPrinterTypeID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(printertypeId, false);

                    Response.Redirect("/ViewPrinterTypes.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["IsPageValied"] = true;
            this.PopulateDataGrid();
        }

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int printertypeId = int.Parse(this.hdnSelectedPrinterTypeID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(printertypeId, "PrinterType", "Name", this.txtPrinterTypeName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewPrinterTypes.aspx", ex);
            }
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;
            lblPopupHeaderText.Text = "New Print Types";

            ViewState["IsPageValied"] = true;
            Session["PrinterTypeDetails"] = null;

            PopulateDataGrid();
        }

        private void PopulateDataGrid()
        {
            this.dvDataContent.Visible = false;
            this.dvEmptyContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            string searchText = this.txtSearch.Text.ToLower().Trim();

            PrinterTypeBO objPrinterType = new PrinterTypeBO();
            List<PrinterTypeBO> lstPrinterType = new List<PrinterTypeBO>();

            if (txtSearch.Text != string.Empty && txtSearch.Text != "search")
            {
                lstPrinterType = (from pt in objPrinterType.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                  where pt.Name.ToLower().Contains(searchText)/*||
                                  pt.Description.ToLower().Contains(searchText)*/
                                  select pt).ToList();
            }
            else
            {
                lstPrinterType = objPrinterType.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            }

            if (lstPrinterType.Count > 0)
            {
                this.RadGridPrinterType.AllowPaging = (lstPrinterType.Count > this.RadGridPrinterType.PageSize);
                this.RadGridPrinterType.DataSource = lstPrinterType;
                this.RadGridPrinterType.DataBind();
                Session["PrinterTypeDetails"] = lstPrinterType;

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
                this.btnAddPrinterType.Visible = false;
            }

            this.RadGridPrinterType.Visible = (lstPrinterType.Count > 0);
        }

        private void ProcessForm(int printertypeId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    PrinterTypeBO objPrinterType = new PrinterTypeBO(this.ObjContext);
                    if (printertypeId > 0)
                    {
                        objPrinterType.ID = printertypeId;
                        objPrinterType.GetObject();
                        //Update
                        objPrinterType.Name = this.txtPrinterTypeName.Text;
                        //** objPrinterType.Description = this.txtDescription.Text;

                        //btn_Delete
                        if (isDelete)
                        {
                            objPrinterType.Delete();
                        }
                    }
                    else
                    {
                        //Add New details
                        objPrinterType.Name = this.txtPrinterTypeName.Text;
                        //**objPrinterType.Description = this.txtDescription.Text;
                        objPrinterType.Add();
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                //throw ex;
            }

        }

        private void ReBindGrid()
        {
            if (Session["PrinterTypeDetails"] != null)
            {
                RadGridPrinterType.DataSource = (List<PrinterTypeBO>)Session["PrinterTypeDetails"];
                RadGridPrinterType.DataBind();
            }
        }

        #endregion
    }
}
