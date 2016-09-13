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
    public partial class ViewPaymentTerms : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["PaymentTermsSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["PaymentTermsSortExpression"] = value;
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

        protected void RadGridPaymentTerms_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPaymentTerms_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is PaymentMethodBO)
                {
                    PaymentMethodBO objPaymentTerm = (PaymentMethodBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objPaymentTerm.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objPaymentTerm.ID.ToString());

                    ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                    objReturnInt = SettingsBO.ValidateField(0, "Order", "PaymentMethod", objPaymentTerm.ID.ToString());
                    linkDelete.Visible = objReturnInt.RetVal == 1;

                    //linkDelete.Visible = (objPaymentTerm.OrdersWhereThisIsPaymentMethod.Count == 0) ? true : false;
                    //linkDelete.Visible = true;//PBD : TODO (objPaymentTerm.ReservationsWhereThisIsPaymentMethod.Count == 0);
                }
            }
        }

        protected void RadGridPaymentTerms_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPaymentTerms_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridPaymentTerms_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridPaymentTerm_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is PaymentMethodBO)
        //    {
        //        PaymentMethodBO objPaymentTerm = (PaymentMethodBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objPaymentTerm.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objPaymentTerm.ID.ToString());
        //        linkDelete.Visible = (objPaymentTerm.OrdersWhereThisIsPaymentMethod.Count == 0);
        //        linkDelete.Visible = true;//PBD : TODO (objPaymentTerm.ReservationsWhereThisIsPaymentMethod.Count == 0);
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
                int paymenttermId = int.Parse(this.hdnSelectedPaymentTermID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(paymenttermId, false);

                    Response.Redirect("/ViewPaymentTerms.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int paymenttermId = int.Parse(this.hdnSelectedPaymentTermID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(paymenttermId, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);

        }

        //protected void dataGridPaymentTerm_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridPaymentTerm.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dataGridPaymentTerm_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dataGridPaymentTerm.Columns)
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
                int paymenttermId = int.Parse(this.hdnSelectedPaymentTermID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(paymenttermId, "PaymentMethod", "Name", this.txtPaymentTermName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewPaymentTerms.aspx", ex);
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

            lblPopupHeaderText.Text = "New Payment Term";

            ViewState["IsPageValied"] = true;
            Session["PaymentTermsDetails"] = null;

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
                PaymentMethodBO objPaymentTerm = new PaymentMethodBO();

                List<PaymentMethodBO> lstPaymentTerm = new List<PaymentMethodBO>();

                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstPaymentTerm = (from o in objPaymentTerm.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                      where o.Name.ToLower().Contains(searchText) ||
                                      (o.Description != null && o.Description.ToLower().Contains(searchText))
                                      select o).ToList();
                }
                else
                {
                    lstPaymentTerm = objPaymentTerm.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstPaymentTerm.Count > 0)
                {
                    this.RadGridPaymentTerms.AllowPaging = (lstPaymentTerm.Count > this.RadGridPaymentTerms.PageSize);
                    this.RadGridPaymentTerms.DataSource = lstPaymentTerm;
                    this.RadGridPaymentTerms.DataBind();
                    Session["PaymentTermsDetails"] = lstPaymentTerm;

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
                    this.btnAddPaymentTerm.Visible = false;
                }

                this.RadGridPaymentTerms.Visible = (lstPaymentTerm.Count > 0);
            }
        }

        private void ProcessForm(int shipmentmodeId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    PaymentMethodBO objPaymentTerm = new PaymentMethodBO(this.ObjContext);
                    if (shipmentmodeId > 0)
                    {
                        //Update Data
                        objPaymentTerm.ID = shipmentmodeId;
                        objPaymentTerm.GetObject();
                        objPaymentTerm.Name = this.txtPaymentTermName.Text;
                        objPaymentTerm.Description = this.txtDescription.Text;


                        if (isDelete)
                        {
                            objPaymentTerm.Delete();
                        }

                    }
                    else
                    {
                        objPaymentTerm.Name = this.txtPaymentTermName.Text;
                        objPaymentTerm.Description = this.txtDescription.Text;
                        objPaymentTerm.Add();
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
            if (Session["PaymentTermsDetails"] != null)
            {
                RadGridPaymentTerms.DataSource = (List<PaymentMethodBO>)Session["PaymentTermsDetails"];
                RadGridPaymentTerms.DataBind();
            }
        }

        #endregion
    }
}