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
    public partial class ViewOrderTypes : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["OrderTypesSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["OrderTypesSortExpression"] = value;
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
            ViewState["IsPageValied"] = true;
        }
        
        protected void RadGridOrderTypes_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridOrderTypes_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridOrderTypes_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is OrderTypeBO)
                {
                    OrderTypeBO objOrderType = (OrderTypeBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objOrderType.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objOrderType.ID.ToString());

                    ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                    objReturnInt = SettingsBO.ValidateField(0, "OrderDetail", "OrderType", objOrderType.ID.ToString());
                    linkDelete.Visible = objReturnInt.RetVal == 1;

                    //linkDelete.Visible = (objOrderType.OrderDetailsWhereThisIsOrderType.Count == 0) ? true : false;
                    //linkDelete.Visible = (objOrderType.ReservationsWhereThisIsOrderType.Count == 0);
                }
            }
        }

        protected void RadGridOrderTypes_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridOrderTypes_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridOrderType_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is OrderTypeBO)
        //    {
        //        OrderTypeBO objOrderType = (OrderTypeBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objOrderType.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objOrderType.ID.ToString());
        //        linkDelete.Visible = (objOrderType.OrderDetailsWhereThisIsOrderType.Count == 0);
        //        //linkDelete.Visible = (objOrderType.ReservationsWhereThisIsOrderType.Count == 0);
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
                int ordertypeId = int.Parse(this.hdnSelectedOrderTypeID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(ordertypeId, false);

                    Response.Redirect("/ViewOrderTypes.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int ordertypeId = int.Parse(this.hdnSelectedOrderTypeID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(ordertypeId, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);

        }

        //protected void dataGridOrderType_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridOrderType.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dataGridOrderType_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dataGridOrderType.Columns)
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
                int ordertypeId = int.Parse(this.hdnSelectedOrderTypeID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(ordertypeId, "OrderType", "Name", this.txtOrderTypeName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewOrderTypes.aspx", ex);
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

            lblPopupHeaderText.Text = "New Order Type";

            ViewState["IsPageValied"] = true;
            Session["OrderTypesDetails"] = null;

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
                OrderTypeBO objOrderType = new OrderTypeBO();

                // Sort by condition
                //int sortbyStatus = int.Parse(this.ddlSortBy.SelectedItem.Value);
                //if (sortbyStatus < 2)
                //{
                //    //objItem.IsActive = Convert.ToBoolean(sortbyStatus);
                //}

                List<OrderTypeBO> lstOrderType = new List<OrderTypeBO>();

                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstOrderType = (from o in objOrderType.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                    where o.Name.ToLower().Contains(searchText) || o.Description.ToLower().Contains(searchText)
                                    select o).ToList();
                }
                else
                {
                    lstOrderType = objOrderType.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstOrderType.Count > 0)
                {
                    this.RadGridOrderTypes.AllowPaging = (lstOrderType.Count > this.RadGridOrderTypes.PageSize);
                    this.RadGridOrderTypes.DataSource = lstOrderType;
                    this.RadGridOrderTypes.DataBind();
                    Session["OrderTypesDetails"] = lstOrderType;

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
                    this.btnAddOrderType.Visible = false;
                }

                this.RadGridOrderTypes.Visible = (lstOrderType.Count > 0);
            }
        }

        private void ProcessForm(int ordertypeId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    OrderTypeBO objOrderType = new OrderTypeBO(this.ObjContext);
                    if (ordertypeId > 0)
                    {
                        //Update Data
                        objOrderType.ID = ordertypeId;
                        objOrderType.GetObject();
                        objOrderType.Name = this.txtOrderTypeName.Text;
                        objOrderType.Description = this.txtDescription.Text;


                        if (isDelete)
                        {
                            objOrderType.Delete();
                        }

                    }
                    else
                    {
                        objOrderType.Name = this.txtOrderTypeName.Text;
                        objOrderType.Description = this.txtDescription.Text;
                        objOrderType.Add();
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
            if (Session["OrderTypesDetails"] != null)
            {
                RadGridOrderTypes.DataSource = (List<OrderTypeBO>)Session["OrderTypesDetails"];
                RadGridOrderTypes.DataBind();
            }
        }

        #endregion
    }
}