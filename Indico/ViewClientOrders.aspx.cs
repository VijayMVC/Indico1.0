using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Transactions;
using System.IO;

using Indico.BusinessObjects;
using Indico.Common;



namespace Indico
{
    public partial class ViewClientOrders : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)Session["OrderSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "OrderNumber";
                }
                return sort;
            }
            set
            {
                Session["OrderSortExpression"] = value;
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

        protected override void OnPreRender(EventArgs e)
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

        protected void dgOrders_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is ClientOrderDetailsViewBO)
            {
                ClientOrderDetailsViewBO objClientOrder = (ClientOrderDetailsViewBO)item.DataItem;

                Label lblOrderDate = (Label)item.FindControl("lblOrderDate");
                lblOrderDate.Text = ((DateTime)objClientOrder.Date).ToString("dd MMM yyyy");

                Label lblDesiredDate = (Label)item.FindControl("lblDesiredDate");
                //SDU lblDesiredDate.Text = ((DateTime)objClientOrder.DesiredDeliveryDate).ToString("dd MMM yyyy");

                Label lblVlNumber = (Label)item.FindControl("lblVlNumber");
                lblVlNumber.Text = objClientOrder.NamePrefix + "" + objClientOrder.NameSuffix + " - " + objClientOrder.PatternNumber + " - " + objClientOrder.FabricNickName;

                HtmlAnchor ancVLImage = (HtmlAnchor)item.FindControl("ancVLImage");
                ancVLImage.HRef = IndicoPage.GetVLImagePath((int)objClientOrder.VisualLayoutId);
                if (File.Exists(Server.MapPath(ancVLImage.HRef)))
                {
                    ancVLImage.Attributes.Add("class", "btn-link iview preview");
                    List<float> lstVLImageDimensions = (new ImageProcess()).GetResizedImageDimension(960, 720, 420, 360);
                    if (lstVLImageDimensions.Count > 0)
                    {
                        ancVLImage.Attributes.Add("height", lstVLImageDimensions[0].ToString());
                        ancVLImage.Attributes.Add("width", lstVLImageDimensions[1].ToString());
                    }
                }
                else
                {
                    ancVLImage.Title = "Visual Layout Image Not Found";
                    ancVLImage.Attributes.Add("class", "btn-link iremove");
                }

                Label lblOrderStatus = (Label)item.FindControl("lblOrderStatus");
                lblOrderStatus.Text = objClientOrder.Status;
                //lblOrderStatus.Attributes.Add("class", objClientOrder.Status.ToLower());
                lblOrderStatus.CssClass = objClientOrder.Status.ToLower().Replace(" ", "");

                HtmlAnchor linkOrderQty = (HtmlAnchor)item.FindControl("linkOrderQty");
                linkOrderQty.Attributes.Add("qid", objClientOrder.OrderDetailId.ToString());

                HyperLink linkEditView = (HyperLink)item.FindControl("linkEditView");
                linkEditView.CssClass = "btn-link " + (((bool)objClientOrder.IsTemporary) ? "iedit" : "iview");
                linkEditView.ToolTip = (((bool)objClientOrder.IsTemporary) ? "Edit Order" : "View Order");
                linkEditView.NavigateUrl = "AddEditClientOrder.aspx?id=" + objClientOrder.OrderId.ToString();
            }
        }

        protected void dgOrders_PageIndexChanged(object sender, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dgOrders.CurrentPageIndex = e.NewPageIndex;

            this.PopulateDataGrid();
        }

        protected void dgOrders_SortCommand(object source, DataGridSortCommandEventArgs e)
        {
            ViewState["IsPopulate"] = false;
            string sortDirection = String.Empty;

            if (!SortExpression.ToUpper().StartsWith(e.SortExpression) && !SortExpression.ToUpper().Trim().EndsWith("ASC"))
                sortDirection = " asc";
            else
                sortDirection = (SortExpression.ToUpper().EndsWith("DESC")) ? " asc" : " desc";

            this.SortExpression = e.SortExpression + sortDirection;
            this.PopulateDataGrid();

            foreach (DataGridColumn col in this.dgOrders.Columns)
            {
                if (col.Visible && col.SortExpression == e.SortExpression)
                {
                    col.HeaderStyle.CssClass = "selected " + ((sortDirection.ToUpper() != " DESC") ? "sortDown" : "sortUp");
                }
                else if (!col.HeaderStyle.CssClass.Contains("hide"))
                {
                    col.HeaderStyle.CssClass = ((col.HeaderStyle.CssClass == "hide") ? "hide" : string.Empty);
                }
            }
        }

        protected void rptSizeQty_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objClientOrderQty = (OrderDetailQtyBO)item.DataItem;

                Literal litHeading = (Literal)item.FindControl("litHeading");
                litHeading.Text = objClientOrderQty.objSize.SizeName;

                Label lblQty = (Label)item.FindControl("lblQty");
                lblQty.Text = objClientOrderQty.Qty.ToString();
                lblQty.Attributes.Add("Size", objClientOrderQty.Size.ToString());
            }
        }

        protected void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            ViewState["IsPopulate"] = false;
            this.PopulateDataGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["IsPopulate"] = false;
            this.PopulateDataGrid();
        }

        //this option has been removed.
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            /*int distributorId = int.Parse(this.hdnSelectedOrderID.Value.Trim());

            if (distributorId > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        OrderBO objOrder = new OrderBO(;
                        objOrder.ID = distributorId;
                        objOrder.GetObject();

                        objOrder.Delete();
                        //this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }*/
        }

        protected void linkOrderQty_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                OrderDetailBO objClientOrderDetail = new OrderDetailBO();
                objClientOrderDetail.ID = int.Parse(((HtmlAnchor)(sender)).Attributes["qid"].ToString());
                objClientOrderDetail.GetObject();

                this.rptSizeQty.DataSource = objClientOrderDetail.OrderDetailQtysWhereThisIsOrderDetail;
                this.rptSizeQty.DataBind();

                ViewState["IsPopulate"] = true;
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
            ViewState["IsPageValied"] = true;
            ViewState["IsPopulate"] = false;

            //Populate Order statuses for sorting
            List<OrderStatusBO> lstOrderStatus = (new OrderStatusBO()).GetAllObject();
            this.ddlSortBy.Items.Add(new ListItem("All", "0"));
            foreach (OrderStatusBO orderStatus in lstOrderStatus)
            {
                this.ddlSortBy.Items.Add(new ListItem(orderStatus.Name, (orderStatus.ID).ToString()));
            }

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

            ClientOrderDetailsViewBO objClientOrders = new ClientOrderDetailsViewBO();
            objClientOrders.CompanyId = this.LoggedCompany.ID;

            List<ClientOrderDetailsViewBO> lstClientOrders = new List<ClientOrderDetailsViewBO>();

            //Sort by condition
            int sortbyStatus = int.Parse(this.ddlSortBy.SelectedItem.Value);
            if (sortbyStatus != 0)
            {
                if (sortbyStatus == 1)
                {
                    objClientOrders.IsTemporary = true;
                }
                else
                {
                    objClientOrders.IsTemporary = false;
                    objClientOrders.StatusId = sortbyStatus;
                }
            }

            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstClientOrders = (from o in objClientOrders.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                   where o.CompanyName.ToLower().Contains(searchText) ||
                                       //SDU o.OrderNumber.ToLower().Contains(searchText) ||
                                         o.ClientName.ToLower().Contains(searchText) ||
                                         o.OrderType.ToLower().Contains(searchText) ||
                                         o.NamePrefix.ToLower().Contains(searchText) ||
                                         o.NameSuffix.ToString().Contains(searchText) ||
                                         o.PatternNumber.ToLower().Contains(searchText) ||
                                         o.Fabric.ToLower().Contains(searchText) ||
                                         o.FabricNickName.ToLower().Contains(searchText)
                                   select o).ToList();
            }
            else
            {
                lstClientOrders = objClientOrders.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            }

            List<ClientOrderDetailsViewBO> lst = new List<ClientOrderDetailsViewBO>();
            foreach (ClientOrderDetailsViewBO item in lstClientOrders)
            {
                OrderBO objOrder = new OrderBO(this.ObjContext);
                objOrder.ID = (int)item.OrderId;
                objOrder.GetObject();

                UserRole modifierRole = this.GetUserRole(objOrder.objModifier.UserRolesWhereThisIsUser[0].ID);

                if ((modifierRole == UserRole.DistributorAdministrator) || (item.StatusId != 1))
                {
                    lst.Add(item);
                }
            }

            if (lst.Count > 0)
            {
                this.dgOrders.AllowPaging = (lst.Count > this.dgOrders.PageSize);
                this.dgOrders.DataSource = lst;
                this.dgOrders.DataBind();

                this.dvDataContent.Visible = true;
                this.btnAddOrder.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search") || (sortbyStatus != 0))
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty) + "Sort by " + this.ddlSortBy.SelectedItem.Text;

                this.btnAddOrder.Visible = true;
                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyContent.Visible = true;
                this.btnAddOrder.Visible = false;
            }
            this.dgOrders.Visible = (lst.Count > 0);
        }

        #endregion
    }
}