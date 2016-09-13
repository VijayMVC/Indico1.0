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
    public partial class ViewEmbroideryStatus : IndicoPage
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

        //protected void RadGridEmbroideriesStatus_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is EmbroideryStatusBO)
        //    {
        //        EmbroideryStatusBO objEmbroideryStatus = (EmbroideryStatusBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objEmbroideryStatus.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objEmbroideryStatus.ID.ToString());
        //        linkDelete.Visible = (objEmbroideryStatus.EmbroideryDetailssWhereThisIsStatus.Count > 0) ? false : true;
        //    }
        //}

        protected void RadGridEmbroideriesStatus_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridEmbroideriesStatus_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridEmbroideriesStatus_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is EmbroideryStatusBO)
                {
                    EmbroideryStatusBO objEmbroideryStatus = (EmbroideryStatusBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objEmbroideryStatus.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objEmbroideryStatus.ID.ToString());
                    linkDelete.Visible = (objEmbroideryStatus.EmbroideryDetailssWhereThisIsStatus.Count > 0) ? false : true;
                }
            }
        }

        protected void RadGridEmbroideriesStatus_ItemCommand(object sender, GridCommandEventArgs e)
        {
            //if (e.CommandName == RadGrid.FilterCommandName)
            //{
                this.ReBindGrid();
            //}
        }

        protected void RadGridEmbroideriesStatus_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
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
                int estatusId = int.Parse(this.hdnSelectedAgeGroupID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(estatusId, false);

                    Response.Redirect("/ViewEmbroideryStatus.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int estatusid = int.Parse(this.hdnSelectedAgeGroupID.Value.Trim());
            if (this.IsNotRefresh)
            {

                if (!Page.IsValid)
                {
                    this.ProcessForm(estatusid, true);

                    this.PopulateDataGrid();
                }
            }

            ViewState["IsPageValied"] = !(Page.IsValid);
        }

        //protected void RadGridEmbroideriesStatus_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.RadGridEmbroideriesStatus.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void RadGridEmbroideriesStatus_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.RadGridEmbroideriesStatus.Columns)
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
                int statusId = int.Parse(this.hdnSelectedAgeGroupID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(statusId, "EmbroideryStatus", "Name", this.txtStatusName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewEmbroideryStatus.aspx", ex);
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

            lblPopupHeaderText.Text = "New Embroidery Status";
            ViewState["IsPageValied"] = true;
            Session["EmbroideryStatusDetails"] = null;

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
                EmbroideryStatusBO objEmbroideryStatus = new EmbroideryStatusBO();

                List<EmbroideryStatusBO> lstEmbroideryStatus = new List<EmbroideryStatusBO>();
                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstEmbroideryStatus = (from o in objEmbroideryStatus.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                           where o.Name.ToLower().Contains(searchText) ||
                                           (o.Description != null ? o.Description.ToLower().Contains(searchText) : false)
                                           select o).ToList();
                }
                else
                {
                    lstEmbroideryStatus = objEmbroideryStatus.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstEmbroideryStatus.Count > 0)
                {
                    this.RadGridEmbroideriesStatus.AllowPaging = (lstEmbroideryStatus.Count > this.RadGridEmbroideriesStatus.PageSize);
                    this.RadGridEmbroideriesStatus.DataSource = lstEmbroideryStatus;
                    this.RadGridEmbroideriesStatus.DataBind();
                    Session["EmbroideryStatusDetails"] = lstEmbroideryStatus;

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

                this.RadGridEmbroideriesStatus.Visible = (lstEmbroideryStatus.Count > 0);
            }
        }

        private void ProcessForm(int estatusId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    EmbroideryStatusBO objEmbroideryStatus = new EmbroideryStatusBO(this.ObjContext);
                    if (estatusId > 0)
                    {
                        objEmbroideryStatus.ID = estatusId;
                        objEmbroideryStatus.GetObject();
                        objEmbroideryStatus.Name = this.txtStatusName.Text;
                        objEmbroideryStatus.Description = this.txtDescription.Text;

                        if (isDelete)
                        {
                            objEmbroideryStatus.Delete();
                        }
                    }
                    else
                    {
                        objEmbroideryStatus.Name = this.txtStatusName.Text;
                        objEmbroideryStatus.Description = this.txtDescription.Text;
                        objEmbroideryStatus.Add();
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error ocured while Adding or Updating or Deleting Embroidery Status From ViewEmbroidery.aspx", ex);
            }
        }

        private void ReBindGrid()
        {
            if (Session["EmbroideryStatusDetails"] != null)
            {
                RadGridEmbroideriesStatus.DataSource = (List<EmbroideryStatusBO>)Session["EmbroideryStatusDetails"];
                RadGridEmbroideriesStatus.DataBind();
            }
        }

        #endregion
    }
}