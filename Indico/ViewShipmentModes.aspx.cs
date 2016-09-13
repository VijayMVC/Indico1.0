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
    public partial class ViewShipmentModes : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ShipmentModesSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["ShipmentModesSortExpression"] = value;
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
            //ViewState["IsPageValied"] = true;
        }

        protected void RadGridShipmentMode_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridShipmentMode_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridShipmentMode_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is ShipmentModeBO)
                {
                    ShipmentModeBO objShipmentMode = (ShipmentModeBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objShipmentMode.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objShipmentMode.ID.ToString());
                    //linkDelete.Visible = (objShipmentMode.OrdersWhereThisIsShipmentMode.Count == 0 ||
                    //                      objShipmentMode.ReservationsWhereThisIsShipmentMode.Count == 0);

                    ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                    objReturnInt = SettingsBO.ValidateField(0, "Order", "ShipmentMode", objShipmentMode.ID.ToString());
                    linkDelete.Visible = objReturnInt.RetVal == 1;
                }
            }
        }

        protected void RadGridShipmentMode_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridShipmentMode_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridShipmentMode_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is ShipmentModeBO)
        //    {
        //        ShipmentModeBO objShipmentMode = (ShipmentModeBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objShipmentMode.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objShipmentMode.ID.ToString());
        //        // linkDelete.Visible = (objShipmentMode.OrdersWhereThisIsShipmentMode.Count == 0);
        //        linkDelete.Visible = (objShipmentMode.ReservationsWhereThisIsShipmentMode.Count == 0);
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
                int shipmentmodeId = int.Parse(this.hdnSelectedShipmentModeID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(shipmentmodeId, false);

                    Response.Redirect("/ViewShipmentModes.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int shipmentmodeId = int.Parse(this.hdnSelectedShipmentModeID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(shipmentmodeId, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);

        }

        //protected void dataGridShipmentMode_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridShipmentMode.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dataGridShipmentMode_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dataGridShipmentMode.Columns)
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
                int shipmentmodeId = int.Parse(this.hdnSelectedShipmentModeID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(shipmentmodeId, "ShipmentMode", "Name", this.txtShipmentModeName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewShipmentModes.aspx", ex);
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

            lblPopupHeaderText.Text = "New Shipment Mode";

            ViewState["IsPageValied"] = true;
            Session["ShipmentModeDetails"] = null;

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
                ShipmentModeBO objShipmentMode = new ShipmentModeBO();

                List<ShipmentModeBO> lstShipmentMode = new List<ShipmentModeBO>();

                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstShipmentMode = (from o in objShipmentMode.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                       where o.Name.ToLower().Contains(searchText) ||
                                       (o.Description != null && o.Description.ToLower().Contains(searchText))
                                       select o).ToList();
                }
                else
                {
                    lstShipmentMode = objShipmentMode.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstShipmentMode.Count > 0)
                {
                    this.RadGridShipmentMode.AllowPaging = (lstShipmentMode.Count > this.RadGridShipmentMode.PageSize);
                    this.RadGridShipmentMode.DataSource = lstShipmentMode;
                    this.RadGridShipmentMode.DataBind();
                    Session["ShipmentModeDetails"] = lstShipmentMode;

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
                    this.btnAddShipmentMode.Visible = false;
                }

                this.RadGridShipmentMode.Visible = (lstShipmentMode.Count > 0);
            }
        }

        private void ProcessForm(int shipmentmodeId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    ShipmentModeBO objShipmentMode = new ShipmentModeBO(this.ObjContext);
                    if (shipmentmodeId > 0)
                    {
                        //Update Data
                        objShipmentMode.ID = shipmentmodeId;
                        objShipmentMode.GetObject();
                        objShipmentMode.Name = this.txtShipmentModeName.Text;
                        objShipmentMode.Description = this.txtDescription.Text;


                        if (isDelete)
                        {
                            objShipmentMode.Delete();
                        }

                    }
                    else
                    {
                        objShipmentMode.Name = this.txtShipmentModeName.Text;
                        objShipmentMode.Description = this.txtDescription.Text;
                        objShipmentMode.Add();
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
            if (Session["ShipmentModeDetails"] != null)
            {
                RadGridShipmentMode.DataSource = (List<ShipmentModeBO>)Session["ShipmentModeDetails"];
                RadGridShipmentMode.DataBind();
            }
        }

        #endregion
    }
}