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
    public partial class ViewSizeSets : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["SizeSetSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }

            set
            {
                ViewState["SizeSetSortExpression"] = value;
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

        protected void RadGridSizeSets_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridSizeSets_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridSizeSets_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is SizeSetBO)
                {
                    SizeSetBO objSizeSets = (SizeSetBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objSizeSets.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objSizeSets.ID.ToString());
                    linkDelete.Visible = (objSizeSets.PatternsWhereThisIsSizeSet.Count == 0 && objSizeSets.SizesWhereThisIsSizeSet.Count == 0) ? true : false;
                }
            }
        }

        protected void RadGridSizeSets_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridSizeSets_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridSizeSets_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is SizeSetBO)
        //    {
        //        SizeSetBO objSizeSets = (SizeSetBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objSizeSets.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objSizeSets.ID.ToString());
        //        linkDelete.Visible = (objSizeSets.PatternsWhereThisIsSizeSet.Count == 0);

        //    }
        //}

        //protected void dataGridSizeSets_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dataGridSizeSets.Columns)
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

        //protected void dataGridSizeSets_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridSizeSets.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int sizesetsId = int.Parse(this.hdnSelectedSizeSetsID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(sizesetsId, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int sizesetsId = int.Parse(this.hdnSelectedSizeSetsID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(sizesetsId, false);

                    Response.Redirect("/ViewSizeSets.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["IsPageValied"] = true;
            this.PopulateDataGrid();
        }

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int sizesetsId = int.Parse(this.hdnSelectedSizeSetsID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(sizesetsId, "SizeSet", "Name", this.txtSizeSetName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on AddEditClient.aspx", ex);
            }
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;

            this.lblPopupHeaderText.Text = "New Size Sets";

            ViewState["IsPageValied"] = true;

            Session["SizeSetsDetails"] = null;

            // populate data grid
            PopulateDataGrid();
        }

        private void PopulateDataGrid()
        {
            this.dvDataContent.Visible = false;
            this.dvEmptyContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            string searchText = this.txtSearch.Text.ToLower().Trim();

            SizeSetBO objSizeSets = new SizeSetBO();
            List<SizeSetBO> lstSizeSets = new List<SizeSetBO>();

            if (txtSearch.Text != string.Empty && txtSearch.Text != "search")
            {
                lstSizeSets = (from ss in objSizeSets.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                               where ss.Name.ToLower().Contains(searchText) ||
                               (ss.Description != null && ss.Description.ToLower().Contains(searchText))
                               select ss).ToList();
            }
            else
            {
                lstSizeSets = objSizeSets.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            }

            if (lstSizeSets.Count > 0)
            {
                this.RadGridSizeSets.AllowPaging = (lstSizeSets.Count > this.RadGridSizeSets.PageSize);
                this.RadGridSizeSets.DataSource = lstSizeSets;
                this.RadGridSizeSets.DataBind();
                Session["SizeSetsDetails"] = lstSizeSets;

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
                this.btnAddSizeSets.Visible = false;
            }

            this.RadGridSizeSets.Visible = (lstSizeSets.Count > 0);
        }

        private void ProcessForm(int sizesetsId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    SizeSetBO objSizeSets = new SizeSetBO(this.ObjContext);
                    if (sizesetsId > 0)
                    {
                        objSizeSets.ID = sizesetsId;
                        objSizeSets.GetObject();
                        objSizeSets.Name = this.txtSizeSetName.Text;
                        objSizeSets.Description = this.txtDescription.Text;

                        if (isDelete)
                        {
                            objSizeSets.Delete();
                        }
                    }
                    else
                    {
                        objSizeSets.Name = this.txtSizeSetName.Text;
                        objSizeSets.Description = this.txtDescription.Text;
                        objSizeSets.Add();
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
            if (Session["SizeSetsDetails"] != null)
            {
                RadGridSizeSets.DataSource = (List<SizeSetBO>)Session["SizeSetsDetails"];
                RadGridSizeSets.DataBind();
            }
        }

        #endregion
    }
}