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
    public partial class ViewColorProfiles : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ColorProfilesSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["ColorProfilesSortExpression"] = value;
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

        protected void RadGridColorProfile_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridColorProfile_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridColorProfile_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is ColourProfileBO)
                {
                    ColourProfileBO objColourProfile = (ColourProfileBO)item.DataItem;

                    //Label lblName = (Label)item.FindControl("lblName");
                    //lblName.Text = objColourProfile.Name;

                    //Label lblDescription = (Label)item.FindControl("lblDescription");
                    //lblDescription.Text = objColourProfile.Description;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objColourProfile.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objColourProfile.ID.ToString());
                    linkDelete.Visible = (objColourProfile.ProductsWhereThisIsColourProfile.Count == 0);

                }
            }
        }

        protected void RadGridColorProfile_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridColorProfile_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int queryId = int.Parse(this.hdnSelectedColorProfileID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(queryId, false);

                    Response.Redirect("/ViewColorProfiles.aspx");
                }

                // Popup Header Text
                this.lblPopupHeaderText.Text = ((queryId > 0) ? "Edit " : "New ") + "Color Profile";

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int queryId = int.Parse(this.hdnSelectedColorProfileID.Value.Trim());

            this.ProcessForm(queryId, true);

            this.PopulateDataGrid();
        }
        
        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int queryId = int.Parse(this.hdnSelectedColorProfileID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(queryId, "ColourProfile", "Name", this.txtColorProfilesName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewColorProfiles.aspx", ex);
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
            this.lblPopupHeaderText.Text = "New Color Profile";

            ViewState["IsPageValied"] = true;
            Session["ColorProfileDetails"] = null;

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

            // Populate Items
            ColourProfileBO objColourProfile = new ColourProfileBO();

            List<ColourProfileBO> lstColourProfiles = new List<ColourProfileBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstColourProfiles = (from o in objColourProfile.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                     where o.Name.ToLower().Contains(searchText) ||
                                     (o.Description != null ? o.Description.ToLower().Contains(searchText) : false)
                                     select o).ToList();
            }
            else
            {
                lstColourProfiles = objColourProfile.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            }

            if (lstColourProfiles.Count > 0)
            {
                this.RadGridColorProfile.AllowPaging = (lstColourProfiles.Count > this.RadGridColorProfile.PageSize);
                this.RadGridColorProfile.DataSource = lstColourProfiles;
                this.RadGridColorProfile.DataBind();
                Session["ColorProfileDetails"] = lstColourProfiles;

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
                this.btnAddColorProfile.Visible = false;
            }

            //this.lblSerchKey.Text = string.Empty;
            this.RadGridColorProfile.Visible = (lstColourProfiles.Count > 0);
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
                    ColourProfileBO objColourProfile = new ColourProfileBO(this.ObjContext);
                    if (queryId > 0)
                    {
                        objColourProfile.ID = queryId;
                        objColourProfile.GetObject();
                    }

                    if
                        (isDelete)
                    {
                        objColourProfile.Delete();
                    }
                    else
                    {
                        objColourProfile.Name = this.txtColorProfilesName.Text;
                        objColourProfile.Description = this.txtDescription.Text;


                        if (queryId == 0)
                        {
                            objColourProfile.Add();
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
            if (Session["ColorProfileDetails"] != null)
            {
                RadGridColorProfile.DataSource = (List<ColourProfileBO>)Session["ColorProfileDetails"];
                RadGridColorProfile.DataBind();
            }
        }

        #endregion
    }
}