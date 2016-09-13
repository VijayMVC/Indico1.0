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
    public partial class ViewUnits : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["AgeGroupsSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["AgeGroupsSortExpression"] = value;
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

        protected void RadGridUnits_PageSizeChanged(object sender, Telerik.Web.UI.GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridUnits_PageIndexChanged(object sender, Telerik.Web.UI.GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridUnits_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is UnitBO)
                {
                    UnitBO ObjUnit = (UnitBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", ObjUnit.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", ObjUnit.ID.ToString());
                    linkDelete.Visible = (ObjUnit.AccessorysWhereThisIsUnit.Count == 0 &&
                                          ObjUnit.FabricCodesWhereThisIsUnit.Count == 0 &&
                                          ObjUnit.PatternsWhereThisIsUnit.Count == 0) ? true : false;
                }
            }
        }

        protected void RadGridUnits_ItemCommand(object sender, Telerik.Web.UI.GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridUnits_SortCommand(object sender, Telerik.Web.UI.GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void dgUnits_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is UnitBO)
            {
                UnitBO ObjUnit = (UnitBO)item.DataItem;

                HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", ObjUnit.ID.ToString());

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", ObjUnit.ID.ToString());
                linkDelete.Visible = (ObjUnit.AccessorysWhereThisIsUnit.Count == 0) ? true : false;
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["IsPageValied"] = true;
            this.PopulateDataGrid();
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int agegroupId = int.Parse(this.hdnSelectedUnitID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(agegroupId, false);

                    Response.Redirect("/ViewUnits.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int agegroupId = int.Parse(this.hdnSelectedUnitID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(agegroupId, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);

        }

        //protected void dgUnits_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgUnits.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dgUnits_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dgUnits.Columns)
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
                int unitId = int.Parse(this.hdnSelectedUnitID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(unitId, "Unit", "Name", this.txtUnitName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewUnits.aspx", ex);
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
            Session["UnitsStatusDetails"] = null;

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
                UnitBO objUnit = new UnitBO();

                List<UnitBO> lstUnits = new List<UnitBO>();
                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstUnits = (from o in objUnit.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                where o.Name.ToLower().Contains(searchText) ||
                                (o.Description != null) ? o.Description.ToLower().Contains(searchText) : false
                                select o).ToList();
                }
                else
                {
                    lstUnits = objUnit.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstUnits.Count > 0)
                {
                    this.RadGridUnits.AllowPaging = (lstUnits.Count > this.RadGridUnits.PageSize);
                    this.RadGridUnits.DataSource = lstUnits;
                    this.RadGridUnits.DataBind();
                    Session["UnitsStatusDetails"] = lstUnits;

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
                    this.btnAddUnit.Visible = false;
                }

                this.RadGridUnits.Visible = (lstUnits.Count > 0);
            }
        }

        private void ProcessForm(int unitId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    UnitBO ObjUnit = new UnitBO(this.ObjContext);
                    if (unitId > 0)
                    {
                        ObjUnit.ID = unitId;
                        ObjUnit.GetObject();
                        ObjUnit.Name = this.txtUnitName.Text;
                        ObjUnit.Description = this.txtDescription.Text;

                        if (isDelete)
                        {
                            ObjUnit.Delete();
                        }
                    }
                    else
                    {
                        ObjUnit.Name = this.txtUnitName.Text;
                        ObjUnit.Description = this.txtDescription.Text;
                        ObjUnit.Add();
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving or updating or deleting Units in ViewUnits.aspx page", ex);
            }
        }

        private void ReBindGrid()
        {
            if (Session["UnitsStatusDetails"] != null)
            {
                RadGridUnits.DataSource = (List<UnitBO>)Session["UnitsStatusDetails"];
                RadGridUnits.DataBind();
            }
        }

        #endregion
    }
}