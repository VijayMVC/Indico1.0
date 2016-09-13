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
    public partial class ViewDestinationPorts : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["DestinationPortsSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["DestinationPortsSortExpression"] = value;
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

        protected void RadGridDestinationPorts_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridDestinationPorts_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridDestinationPorts_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;
                if (item.ItemIndex > -1 && item.DataItem is DestinationPortBO)
                {
                    DestinationPortBO objDestinationPort = (DestinationPortBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objDestinationPort.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objDestinationPort.ID.ToString());
                    //linkDelete.Visible = (objDestinationPort.OrdersWhereThisIsDestinationPort.Count == 0);
                    linkDelete.Visible = (objDestinationPort.DistributorClientAddresssWhereThisIsPort.Count == 0) ? true : false;
                }
            }
        }

        protected void RadGridDestinationPorts_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridDestinationPorts_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridDestinationPort_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is DestinationPortBO)
        //    {
        //        DestinationPortBO objDestinationPort = (DestinationPortBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objDestinationPort.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objDestinationPort.ID.ToString());
        //        // linkDelete.Visible = (objDestinationPort.OrdersWhereThisIsDestinationPort.Count == 0);
        //        linkDelete.Visible = (objDestinationPort.ReservationsWhereThisIsDestinationPort.Count == 0) ? true : false;
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
                int destinationportId = int.Parse(this.hdnSelectedDestinationPortID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(destinationportId, false);

                    Response.Redirect("/ViewDestinationPorts.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int destinationportId = int.Parse(this.hdnSelectedDestinationPortID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(destinationportId, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);

        }

        //protected void dataGridDestinationPort_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridDestinationPort.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dataGridDestinationPort_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dataGridDestinationPort.Columns)
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
                int destinationportId = int.Parse(this.hdnSelectedDestinationPortID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(destinationportId, "DestinationPort", "Name", this.txtDestinationPortName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewDestinationPorts.aspx", ex);
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

            lblPopupHeaderText.Text = "New Destination Port";

            ViewState["IsPageValied"] = true;
            Session["DestinationPortDetails"] = null;

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
                DestinationPortBO objDestinationPort = new DestinationPortBO();

                List<DestinationPortBO> lstDestinationPort = new List<DestinationPortBO>();

                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstDestinationPort = (from o in objDestinationPort.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                          where o.Name.ToLower().Contains(searchText) ||
                                          o.Description.ToLower().Contains(searchText)
                                          select o).ToList();
                }
                else
                {
                    lstDestinationPort = objDestinationPort.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstDestinationPort.Count > 0)
                {
                    this.RadGridDestinationPorts.AllowPaging = (lstDestinationPort.Count > this.RadGridDestinationPorts.PageSize);
                    this.RadGridDestinationPorts.DataSource = lstDestinationPort;
                    this.RadGridDestinationPorts.DataBind();
                    Session["DestinationPortDetails"] = lstDestinationPort;

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
                    this.btnAdddestinationType.Visible = false;
                }

                this.RadGridDestinationPorts.Visible = (lstDestinationPort.Count > 0);
            }
        }

        private void ProcessForm(int destinationportId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    DestinationPortBO objDestinationPort = new DestinationPortBO(this.ObjContext);
                    if (destinationportId > 0)
                    {
                        //Update Data
                        objDestinationPort.ID = destinationportId;
                        objDestinationPort.GetObject();
                        objDestinationPort.Name = this.txtDestinationPortName.Text;
                        objDestinationPort.Description = this.txtDescription.Text;


                        if (isDelete)
                        {
                            objDestinationPort.Delete();
                        }

                    }
                    else
                    {
                        objDestinationPort.Name = this.txtDestinationPortName.Text;
                        objDestinationPort.Description = this.txtDescription.Text;
                        objDestinationPort.Add();
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
            if (Session["DestinationPortDetails"] != null)
            {
                RadGridDestinationPorts.DataSource = (List<DestinationPortBO>)Session["DestinationPortDetails"];
                RadGridDestinationPorts.DataBind();
            }
        }

        #endregion
    }
}