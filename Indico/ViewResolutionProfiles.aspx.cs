using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;
using System.Linq.Dynamic;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class ViewResolutionProfiles : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ResolutionProfilesSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["ResolutionProfilesSortExpression"] = value;
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

        protected void RadGridResolutionProfile_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridResolutionProfile_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridResolutionProfile_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is ResolutionProfileBO)
                {
                    ResolutionProfileBO objResolutionProfile = (ResolutionProfileBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objResolutionProfile.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objResolutionProfile.ID.ToString());

                    ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                    objReturnInt = SettingsBO.ValidateField(0, "VisualLayout", "ResolutionProfile", objResolutionProfile.ID.ToString());
                    linkDelete.Visible = objReturnInt.RetVal == 1;
                    //linkDelete.Visible = (objResolutionProfile.VisualLayoutsWhereThisIsResolutionProfile.Any()) ? false : true;
                }
            }
        }

        protected void RadGridResolutionProfile_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridResolutionProfile_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dgResolutionProfiles_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is ResolutionProfileBO)
        //    {
        //        ResolutionProfileBO objResolutionProfile = (ResolutionProfileBO)item.DataItem;

        //        Literal lblName = (Literal)item.FindControl("lblName");
        //        lblName.Text = objResolutionProfile.Name;

        //        Literal lblDescription = (Literal)item.FindControl("lblDescription");
        //        lblDescription.Text = objResolutionProfile.Description;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objResolutionProfile.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objResolutionProfile.ID.ToString());
        //        linkDelete.Visible = (objResolutionProfile.ProductsWhereThisIsResolutionProfile.Count == 0);
        //    }
        //}

        //protected void dgResolutionProfiles_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgResolutionProfiles.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dgResolutionProfiles_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dgResolutionProfiles.Columns)
        //    {
        //        if (col.Visible && col.SortExpression == e.SortExpression)
        //        {
        //            col.HeaderStyle.CssClass = "selected " + ((sortDirection.ToUpper() != " DESC") ? "sortDown" : "sortUp");
        //        }
        //        else
        //        {
        //            col.HeaderStyle.CssClass = ((col.HeaderStyle.CssClass == "hide") ? "hide" : string.Empty);
        //        }
        //    }
        //}

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int queryId = int.Parse(this.hdnSelectedResolutionProfilesID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(queryId, false);

                    Response.Redirect("/ViewResolutionProfiles.aspx");
                }

                // Popup Header Text
                this.lblPopupHeaderText.Text = ((queryId > 0) ? "Edit " : "New ") + "Resolution Profile";

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int queryId = int.Parse(this.hdnSelectedResolutionProfilesID.Value.Trim());

            this.ProcessForm(queryId, true);

            this.PopulateDataGrid();
        }

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int queryId = int.Parse(this.hdnSelectedResolutionProfilesID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(queryId, "ResolutionProfile", "Name", this.txtResolutionProfileName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewResolutionProfiles.aspx", ex);
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            // Header Text
            this.litHeaderText.Text = this.ActivePage.Heading; //this.ActivePage.Heading;

            // Popup Header Text
            this.lblPopupHeaderText.Text = "New Resolution Profile";

            Session["ResolutionProfileDetails"] = null;

            ViewState["IsPageValied"] = true;

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

            // Populate Resolution Profiles
            ResolutionProfileBO objResolutionProfile = new ResolutionProfileBO();

            List<ResolutionProfileBO> lstResolutionProfile = new List<ResolutionProfileBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstResolutionProfile = (from o in objResolutionProfile.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<ResolutionProfileBO>()
                                        where o.Name.ToLower().Contains(searchText) ||
                                        (o.Description != null && o.Description.ToLower().Contains(searchText))
                                        select o).ToList();
            }
            else
            {
                lstResolutionProfile = objResolutionProfile.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<ResolutionProfileBO>();
            }

            if (lstResolutionProfile.Count > 0)
            {
                this.RadGridResolutionProfile.AllowPaging = (lstResolutionProfile.Count > this.RadGridResolutionProfile.PageSize);
                this.RadGridResolutionProfile.DataSource = lstResolutionProfile;
                this.RadGridResolutionProfile.DataBind();
                Session["ResolutionProfileDetails"] = lstResolutionProfile;

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
                this.btnAddResolutionProfiles.Visible = false;
            }

            //this.lblSerchKey.Text = string.Empty;
            this.RadGridResolutionProfile.Visible = (lstResolutionProfile.Count > 0);
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm(int queryId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    ResolutionProfileBO objResolutionProfile = new ResolutionProfileBO(this.ObjContext);
                    if (queryId > 0)
                    {
                        objResolutionProfile.ID = queryId;
                        objResolutionProfile.GetObject();
                    }

                    if (isDelete)
                    {
                        objResolutionProfile.Delete();
                    }
                    else
                    {
                        objResolutionProfile.Name = this.txtResolutionProfileName.Text;
                        objResolutionProfile.Description = this.txtDescription.Text;


                        if (queryId == 0)
                        {
                            objResolutionProfile.Add();
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                //IndicoLogging.log("Error occured while Adding the Item", ex);
            }
        }

        private void ReBindGrid()
        {
            if (Session["ResolutionProfileDetails"] != null)
            {
                RadGridResolutionProfile.DataSource = (List<ResolutionProfileBO>)Session["ResolutionProfileDetails"];
                RadGridResolutionProfile.DataBind();
            }
        }

        #endregion
    }
}