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
    public partial class ViewHSCode : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["HSCodeSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Code";
                }
                return sort;
            }
            set
            {
                ViewState["HSCodeSortExpression"] = value;
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

        protected void RadGridHSCode_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridHSCode_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridHSCode_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex>-1 && item.DataItem is HSCodeDetailsBO)
                {
                    HSCodeDetailsBO objHSCode = (HSCodeDetailsBO)item.DataItem;

                     HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                     linkEdit.Attributes.Add("qid", objHSCode.HSCode.ToString());

                     HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                     linkDelete.Attributes.Add("qid", objHSCode.HSCode.ToString());
                }
            }
        }

        protected void RadGridHSCode_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName )
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridHSCode_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dgHSCode_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is HSCodeBO)
        //    {
        //        HSCodeBO objHSCode = (HSCodeBO)item.DataItem;

        //        Literal litCode = (Literal)item.FindControl("litCode");
        //        litCode.Text = objHSCode.Code;

        //        Literal litItemSUbGroup = (Literal)item.FindControl("litItemSUbGroup");
        //        litItemSUbGroup.Text = objHSCode.objItemSubCategory.Name;

        //        Literal litGender = (Literal)item.FindControl("litGender");
        //        litGender.Text = objHSCode.objGender.Name;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objHSCode.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objHSCode.ID.ToString());
        //        //linkDelete.Visible = (objHSCode.PatternsWhereThisIsAgeGroup.Count == 0);
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
                int id = int.Parse(this.hdnHSCode.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(id, false);

                    Response.Redirect("/ViewHSCode.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int id = int.Parse(this.hdnHSCode.Value.Trim());

                if (!Page.IsValid)
                {
                    this.ProcessForm(id, true);

                    this.PopulateDataGrid();
                }
            }

        }

        //protected void dgHSCode_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgHSCode.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dgHSCode_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dgHSCode.Columns)
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

        protected void cvHSCode_OnServerValidate(object sender, ServerValidateEventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int subitem = int.Parse(this.ddlItemSubGroup.SelectedValue);
                int gender = int.Parse(this.ddlGender.SelectedValue);

                List<HSCodeBO> lstHsCodes = new List<HSCodeBO>();

                if ((!string.IsNullOrEmpty(this.txtCode.Text)) && (subitem > 0) && (gender > 0))
                {
                    lstHsCodes = (new HSCodeBO()).GetAllObject().Where(o =>o.ItemSubCategory == subitem && o.Gender == gender).ToList();
                }

                e.IsValid = !(lstHsCodes.Count > 0);
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

            lblPopupHeaderText.Text = "New HS Code";
            Session["HSCodeDetails"] = null;
            ViewState["IsPageValied"] = true;

            this.ddlGender.Items.Clear();
            this.ddlGender.Items.Add(new ListItem("Select a Gender", "0"));
            List<GenderBO> lstGender = (new GenderBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (GenderBO objGender in lstGender)
            {
                this.ddlGender.Items.Add(new ListItem(objGender.Name, objGender.ID.ToString()));
            }

            this.ddlItemSubGroup.Items.Clear();
            this.ddlItemSubGroup.Items.Add(new ListItem("Select an Item Sub Group", "0"));
            List<ItemBO> lstItemSubGroups = (new ItemBO()).GetAllObject().Where(o => o.Parent != null).OrderBy(o => o.Name).ToList();
            foreach (ItemBO objItem in lstItemSubGroups)
            {
                this.ddlItemSubGroup.Items.Add(new ListItem(objItem.Name, objItem.ID.ToString()));
            }

            this.PopulateDataGrid();

            // hide columns from radgrid
            this.RadGridHSCode.MasterTableView.GetColumn("ItemSubCategoryID").Display = false;
            this.RadGridHSCode.MasterTableView.GetColumn("GenderID").Display = false;

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
                HSCodeDetailsBO objHSCode = new HSCodeDetailsBO();

                List<HSCodeDetailsBO> lstHSCodes = new List<HSCodeDetailsBO>();
                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstHSCodes = (from o in objHSCode.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                  where o.Code.ToLower().Contains(searchText) ||
                                        o.Gender.ToLower().Contains(searchText) ||
                                        o.ItemSubCategory.ToLower().Contains(searchText)
                                  select o).ToList();
                }
                else
                {
                    lstHSCodes = objHSCode.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstHSCodes.Count > 0)
                {
                    this.RadGridHSCode.AllowPaging = (lstHSCodes.Count > this.RadGridHSCode.PageSize);
                    this.RadGridHSCode.DataSource = lstHSCodes;
                    this.RadGridHSCode.DataBind();
                    Session["HSCodeDetails"] = lstHSCodes;

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
                    this.btnAddHSCode.Visible = false;
                }

                this.RadGridHSCode.Visible = (lstHSCodes.Count > 0);
            }
        }

        private void ProcessForm(int hscode, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    HSCodeBO objHSCode = new HSCodeBO(this.ObjContext);
                    if (hscode > 0)
                    {
                        objHSCode.ID = hscode;
                        objHSCode.GetObject();

                    }
                    if (isDelete)
                    {
                        objHSCode.Delete();
                    }
                    else
                    {

                        objHSCode.Code = this.txtCode.Text;
                        objHSCode.Gender = int.Parse(this.ddlGender.SelectedValue);
                        objHSCode.ItemSubCategory = int.Parse(this.ddlItemSubGroup.SelectedValue);

                        if (hscode == 0)
                        {
                            objHSCode.Add();
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while adding, updating or deleting HS Code from ViewHSCode.aspx Page", ex);
            }
        }

        private void ReBindGrid()
        {
            if (Session["HSCodeDetails"] != null)
            {
                RadGridHSCode.DataSource = (List<HSCodeDetailsBO>)Session["HSCodeDetails"];
                RadGridHSCode.DataBind();
            }
        }

        #endregion

    }
}