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
    public partial class ViewOrderStatus : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["OrderStatusSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["OrderStatusSortExpression"] = value;
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

        protected void RadGridOrderStatus_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridOrderStatus_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridOrderStatus_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is OrderStatusBO)
                {
                    OrderStatusBO objOrderStatus = (OrderStatusBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objOrderStatus.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objOrderStatus.ID.ToString());
                    linkDelete.Visible = false;// (objOrderStatus.PatternsWhereThisIsAgeGroup.Count == 0);
                }
            }
        }

        protected void RadGridOrderStatus_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridOrderStatus_SortCommand(object sender, GridSortCommandEventArgs e)
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
        //    if (item.ItemIndex > -1 && item.DataItem is AgeGroupBO)
        //    {
        //        AgeGroupBO objOrderStatus = (AgeGroupBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objOrderStatus.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objOrderStatus.ID.ToString());
        //        linkDelete.Visible = (objOrderStatus.PatternsWhereThisIsAgeGroup.Count == 0);
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
                int orderstatusId = int.Parse(this.hdnSelectedorderstatusId.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(orderstatusId, false);

                    Response.Redirect("/ViewOrderStatus.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int orderstatusId = int.Parse(this.hdnSelectedorderstatusId.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(orderstatusId, true);

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
                int orderstatusId = int.Parse(this.hdnSelectedorderstatusId.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(orderstatusId, "OrderStatus", "Name", this.txtName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewOrderStatus.aspx", ex);
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

            lblPopupHeaderText.Text = "New Order Status";
            ViewState["IsPageValied"] = true;
            Session["OrderStatusDetails"] = null;

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
                OrderStatusBO objOrderStatus = new OrderStatusBO();

                List<OrderStatusBO> lstOrderStatus = new List<OrderStatusBO>();
                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstOrderStatus = (from o in objOrderStatus.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                      where o.Name.ToLower().Contains(searchText) ||
                                      (o.Description != null ? o.Description.ToLower().Contains(searchText) : false)
                                      select o).ToList();
                }
                else
                {
                    lstOrderStatus = objOrderStatus.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstOrderStatus.Count > 0)
                {
                    this.RadGridOrderStatus.AllowPaging = (lstOrderStatus.Count > this.RadGridOrderStatus.PageSize);
                    this.RadGridOrderStatus.DataSource = lstOrderStatus;
                    this.RadGridOrderStatus.DataBind();
                    Session["OrderStatusDetails"] = lstOrderStatus;

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

                this.RadGridOrderStatus.Visible = (lstOrderStatus.Count > 0);
            }
        }

        private void ProcessForm(int orderstatusId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    OrderStatusBO objOrderStatus = new OrderStatusBO(this.ObjContext);

                    if (orderstatusId > 0)
                    {
                        objOrderStatus.ID = orderstatusId;
                        objOrderStatus.GetObject();
                        objOrderStatus.Name = this.txtName.Text;
                        objOrderStatus.Description = this.txtDescription.Text;
                        objOrderStatus.Sequence = int.Parse(this.txtOrder.Text);

                        if (isDelete)
                        {
                            objOrderStatus.Delete();
                        }
                    }
                    else
                    {
                        objOrderStatus.Name = this.txtName.Text;
                        objOrderStatus.Description = this.txtDescription.Text;
                        objOrderStatus.Sequence = int.Parse(this.txtOrder.Text);

                        objOrderStatus.Add();
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
            if (Session["OrderStatusDetails"] != null)
            {
                RadGridOrderStatus.DataSource = (List<OrderStatusBO>)Session["OrderStatusDetails"];
                RadGridOrderStatus.DataBind();
            }
        }

        #endregion
    }
}