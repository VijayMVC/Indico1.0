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
    public partial class ViewProductionLines : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ProductionLinesSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["ProductionLinesSortExpression"] = value;
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

        protected void RadGridProductionLine_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridProductionLine_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridProductionLine_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is ProductionLineBO)
                {
                    ProductionLineBO objProductionLine = (ProductionLineBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objProductionLine.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objProductionLine.ID.ToString());
                }
            }
        }

        protected void RadGridProductionLine_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridProductionLine_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void dgProductionLines_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is ProductionLineBO)
            {
                ProductionLineBO objProductionLine = (ProductionLineBO)item.DataItem;

                Literal lblName = (Literal)item.FindControl("lblName");
                lblName.Text = objProductionLine.Name;

                Literal lblDescription = (Literal)item.FindControl("lblDescription");
                lblDescription.Text = objProductionLine.Description;

                HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objProductionLine.ID.ToString());

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objProductionLine.ID.ToString());
            }
        }

        //protected void dgProductionLines_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgProductionLines.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dgProductionLines_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dgProductionLines.Columns)
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
                int queryId = int.Parse(this.hdnSelectedProductionLinesID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(queryId, false);

                    Response.Redirect("/ViewProductionLines.aspx");
                }

                // Popup Header Text
                this.lblPopupHeaderText.Text = ((queryId > 0) ? "Edit " : "New ") + "Production Line";

                ViewState["IsPageValied"] = (Page.IsValid);           
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int queryId = int.Parse(this.hdnSelectedProductionLinesID.Value.Trim());

                this.ProcessForm(queryId, true);

                this.PopulateDataGrid();
        }

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int queryId = int.Parse(this.hdnSelectedProductionLinesID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(queryId, "ProductionLine", "Name", this.txtProductionLineName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewProductionLines.aspx", ex);
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
            this.lblPopupHeaderText.Text = "New Production Line";

            ViewState["IsPageValied"] = true;

            Session["ProductionLineDetails"] = null;

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

            // Populate Production Line
            ProductionLineBO objProductionLine = new ProductionLineBO();

            List<ProductionLineBO> lstProductionLine = new List<ProductionLineBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstProductionLine = (from o in objProductionLine.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<ProductionLineBO>()
                                     where o.Name.ToLower().Contains(searchText)||
                                     (o.Description!=null?o.Description.ToLower().Contains(searchText):false)
                                     select o).ToList();
            }
            else
            {
                lstProductionLine = objProductionLine.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<ProductionLineBO>();
            }

            if (lstProductionLine.Count > 0)
            {
                this.RadGridProductionLine.AllowPaging = (lstProductionLine.Count > this.RadGridProductionLine.PageSize);
                this.RadGridProductionLine.DataSource = lstProductionLine;
                this.RadGridProductionLine.DataBind();

                Session["ProductionLineDetails"] = lstProductionLine;

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
                this.btnAddProductionLines.Visible = false;
            }

            // this.lblSerchKey.Text = string.Empty;
            this.RadGridProductionLine.Visible = (lstProductionLine.Count > 0);
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
                    ProductionLineBO objProductionLine = new ProductionLineBO(this.ObjContext);
                    if (queryId > 0)
                    {
                        objProductionLine.ID = queryId;
                        objProductionLine.GetObject();
                    }

                    if (isDelete)
                    {
                        objProductionLine.Delete();
                    }
                    else
                    {
                        objProductionLine.Name = this.txtProductionLineName.Text;
                        objProductionLine.Description = this.txtDescription.Text;


                        if (queryId == 0)
                        {
                            objProductionLine.Add();
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
            if (Session["ProductionLineDetails"] != null)
            {
                RadGridProductionLine.DataSource = (List<ProductionLineBO>)Session["ProductionLineDetails"];
                RadGridProductionLine.DataBind();
            }
        }

        #endregion              
    }
}