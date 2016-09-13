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
    public partial class ViewFabricTypes : IndicoPage
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

        protected void RadGridFabricTypes_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridFabricTypes_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridFabricTypes_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is FabricTypeBO)
                {
                    FabricTypeBO objFabricType = (FabricTypeBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objFabricType.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objFabricType.ID.ToString());
                    linkDelete.Visible = (objFabricType.EmbroideryDetailssWhereThisIsFabricType.Count == 0);
                }

            }
        }

        protected void RadGridFabricTypes_ItemCommand(object sender, GridCommandEventArgs e)
        {
            //if (e.CommandName == RadGrid.FilterCommandName)
            //{
            this.ReBindGrid();
            //}
        }

        protected void RadGridFabricTypes_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dgFabricTypes_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is FabricTypeBO)
        //    {
        //        FabricTypeBO objFabricType = (FabricTypeBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objFabricType.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objFabricType.ID.ToString());
        //        linkDelete.Visible = (objFabricType.EmbroideryDetailssWhereThisIsFabricType.Count == 0);
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

                    Response.Redirect("/ViewFabricTypes.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int ID = int.Parse(this.hdnSelectedAgeGroupID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(ID, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);

        }

        //protected void dgFabricTypes_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgFabricTypes.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dgFabricTypes_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dgFabricTypes.Columns)
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
                int typeId = int.Parse(this.hdnSelectedAgeGroupID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(typeId, "FabricType", "Name", this.txtAgeGroupName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewFabricTypes.aspx", ex);
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

            lblPopupHeaderText.Text = "New Fabric Type";
            ViewState["IsPageValied"] = true;
            Session["FabricTypeStatusDetails"] = null;

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
                FabricTypeBO objFabricTypes = new FabricTypeBO();

                List<FabricTypeBO> lstFabricTypes = new List<FabricTypeBO>();
                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstFabricTypes = (from o in objFabricTypes.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                      where o.Name.ToLower().Contains(searchText) ||
                                      (o.Description != null ? o.Description.ToLower().Contains(searchText) : false)
                                      select o).ToList();
                }
                else
                {
                    lstFabricTypes = objFabricTypes.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstFabricTypes.Count > 0)
                {
                    this.RadGridFabricTypes.AllowPaging = (lstFabricTypes.Count > this.RadGridFabricTypes.PageSize);
                    this.RadGridFabricTypes.DataSource = lstFabricTypes;
                    this.RadGridFabricTypes.DataBind();

                    Session["FabricTypeStatusDetails"] = lstFabricTypes;

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

                this.RadGridFabricTypes.Visible = (lstFabricTypes.Count > 0);
            }
        }

        private void ProcessForm(int typeId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    FabricTypeBO objFabricType = new FabricTypeBO(this.ObjContext);
                    if (typeId > 0)
                    {
                        objFabricType.ID = typeId;
                        objFabricType.GetObject();
                        objFabricType.Name = this.txtAgeGroupName.Text;
                        objFabricType.Description = this.txtDescription.Text;

                        if (isDelete)
                        {
                            objFabricType.Delete();
                        }
                    }
                    else
                    {
                        objFabricType.Name = this.txtAgeGroupName.Text;
                        objFabricType.Description = this.txtDescription.Text;
                        objFabricType.Add();
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
            if (Session["FabricTypeStatusDetails"] != null)
            {
                RadGridFabricTypes.DataSource = (List<FabricTypeBO>)Session["FabricTypeStatusDetails"];
                RadGridFabricTypes.DataBind();
            }
        }

        #endregion
    }
}