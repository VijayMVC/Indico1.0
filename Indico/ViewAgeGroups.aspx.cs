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
    public partial class ViewAgeGroups : IndicoPage
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

        protected void RadGridAgeGroup_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridAgeGroup_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridAgeGroup_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is AgeGroupBO)
                {
                    AgeGroupBO objAgeGroup = (AgeGroupBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objAgeGroup.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objAgeGroup.ID.ToString());
                    linkDelete.Visible = (objAgeGroup.PatternsWhereThisIsAgeGroup.Count == 0);
                }
            }
        }

        protected void RadGridAgeGroup_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridAgeGroup_SortCommand(object sender, GridSortCommandEventArgs e)
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
                int agegroupId = int.Parse(this.hdnSelectedAgeGroupID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(agegroupId, false);

                    Response.Redirect("/ViewAgeGroups.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int agegroupId = int.Parse(this.hdnSelectedAgeGroupID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(agegroupId, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);

        }
        
        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int agegroupId = int.Parse(this.hdnSelectedAgeGroupID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(agegroupId, "AgeGroup", "Name", this.txtAgeGroupName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewAgeGroups.aspx", ex);
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
            Session["AgeGroupDetails"] = null;

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
                AgeGroupBO objAgeGroup = new AgeGroupBO();

                List<AgeGroupBO> lstAgeGroup = new List<AgeGroupBO>();
                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstAgeGroup = (from o in objAgeGroup.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                   where o.Name.ToLower().Contains(searchText) ||
                                   (o.Description != null ? o.Description.ToLower().Contains(searchText) : false)
                                   select o).ToList();
                }
                else
                {
                    lstAgeGroup = objAgeGroup.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstAgeGroup.Count > 0)
                {
                    this.RadGridAgeGroup.AllowPaging = (lstAgeGroup.Count > this.RadGridAgeGroup.PageSize);
                    this.RadGridAgeGroup.DataSource = lstAgeGroup;
                    this.RadGridAgeGroup.DataBind();
                    Session["AgeGroupDetails"] = lstAgeGroup;

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

                this.RadGridAgeGroup.Visible = (lstAgeGroup.Count > 0);
            }
        }

        private void ProcessForm(int agegroupId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    AgeGroupBO objAgeGroup = new AgeGroupBO(this.ObjContext);
                    if (agegroupId > 0)
                    {
                        objAgeGroup.ID = agegroupId;
                        objAgeGroup.GetObject();
                        objAgeGroup.Name = this.txtAgeGroupName.Text;
                        objAgeGroup.Description = this.txtDescription.Text;

                        if (isDelete)
                        {
                            objAgeGroup.Delete();
                        }
                    }
                    else
                    {
                        objAgeGroup.Name = this.txtAgeGroupName.Text;
                        objAgeGroup.Description = this.txtDescription.Text;
                        objAgeGroup.Add();
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
            if (Session["AgeGroupDetails"] != null)
            {
                RadGridAgeGroup.DataSource = (List<AgeGroupBO>)Session["AgeGroupDetails"];
                RadGridAgeGroup.DataBind();
            }
        }

        #endregion
    }
}