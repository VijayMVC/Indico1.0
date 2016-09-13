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
    public partial class ViewOrderDetailStatus : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["OrderDetailStatusSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["OrderDetailStatusSortExpression"] = value;
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
        /// 
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

        protected void RadGridOrderDetailsStatus_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridOrderDetailsStatus_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridOrderDetailsStatus_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is OrderDetailStatusBO)
                {
                    OrderDetailStatusBO objOrderDetailStatus = (OrderDetailStatusBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objOrderDetailStatus.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objOrderDetailStatus.ID.ToString());
                    linkDelete.Visible = false; //(objOrderDetailStatus.PatternsWhereThisIsAgeGroup.Count == 0);
                }
            }
        }

        protected void RadGridOrderDetailsStatus_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridOrderDetailsStatus_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridAgeGroup_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is OrderDetailStatusBO)
        //    {
        //        OrderDetailStatusBO objOrderDetailStatus = (OrderDetailStatusBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objOrderDetailStatus.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objOrderDetailStatus.ID.ToString());
        //        linkDelete.Visible = (objOrderDetailStatus.PatternsWhereThisIsAgeGroup.Count == 0);
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
                int agegroupId = int.Parse(this.hdnSelectedAgeGroupID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(agegroupId, false);

                    Response.Redirect("/ViewOrderDetailStatus.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int agegroupId = int.Parse(this.hdnSelectedAgeGroupID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(agegroupId, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);

        }

        //protected void dataGridAgeGroup_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridAgeGroup.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dataGridAgeGroup_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dataGridAgeGroup.Columns)
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
                int itemID = int.Parse(this.hdnSelectedAgeGroupID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(itemID, "OrderDetailStatus", "Name", this.txtName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewOrderDetailStatus.aspx", ex);
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
            Session["OrderDetailStatusDetails"] = null;

            this.PopulateDataGrid();

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
                OrderDetailStatusBO objOrderDetailStatus = new OrderDetailStatusBO();

                List<OrderDetailStatusBO> lstOrderDetailStatus = new List<OrderDetailStatusBO>();
                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstOrderDetailStatus = (from o in objOrderDetailStatus.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                   where o.Name.ToLower().Contains(searchText) ||
                                   (o.Description != null ? o.Description.ToLower().Contains(searchText) : false)
                                   select o).ToList();
                }
                else
                {
                    lstOrderDetailStatus = objOrderDetailStatus.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstOrderDetailStatus.Count > 0)
                {
                    this.RadGridOrderDetailsStatus.AllowPaging = (lstOrderDetailStatus.Count > this.RadGridOrderDetailsStatus.PageSize);
                    this.RadGridOrderDetailsStatus.DataSource = lstOrderDetailStatus;
                    this.RadGridOrderDetailsStatus.DataBind();
                    Session["OrderDetailStatusDetails"] = lstOrderDetailStatus;

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
                    this.btnAddAgeGroup.Visible = false;
                }

                this.RadGridOrderDetailsStatus.Visible = (lstOrderDetailStatus.Count > 0);
            }
        }

        private void ProcessForm(int itemId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    OrderDetailStatusBO objOrderDetailStatus = new OrderDetailStatusBO(this.ObjContext);
                    if (itemId > 0)
                    {
                        objOrderDetailStatus.ID = itemId;
                        objOrderDetailStatus.GetObject();
                        objOrderDetailStatus.Name = this.txtName.Text;
                        objOrderDetailStatus.Description = this.txtDescription.Text;

                        if (isDelete)
                        {
                            objOrderDetailStatus.Delete();
                        }
                    }
                    else
                    {
                        objOrderDetailStatus.Name = this.txtName.Text;
                        objOrderDetailStatus.Description = this.txtDescription.Text;
                        objOrderDetailStatus.Add();
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
            if (Session["OrderDetailStatusDetails"] != null)
            {
                RadGridOrderDetailsStatus.DataSource = (List<OrderDetailStatusBO>)Session["OrderDetailStatusDetails"];
                RadGridOrderDetailsStatus.DataBind();
            }
        }

        #endregion
    }
}