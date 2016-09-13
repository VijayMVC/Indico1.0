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
    public partial class ViewGender : IndicoPage
    {

        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {


            get
            {
                string sort = (string)ViewState["GenderSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["GenderSortExpression"] = value;
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

        protected void RadGridGender_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridGender_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridGender_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is GenderBO)
                {
                    GenderBO objGender = (GenderBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objGender.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objGender.ID.ToString());
                    linkDelete.Visible = (objGender.PatternsWhereThisIsGender.Count == 0 &&
                                          objGender.HSCodesWhereThisIsGender.Count == 0);
                }
            }
        }

        protected void RadGridGender_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridGender_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridGender_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is GenderBO)
        //    {
        //        GenderBO objGender = (GenderBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objGender.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objGender.ID.ToString());
        //        linkDelete.Visible = (objGender.PatternsWhereThisIsGender.Count == 0 &&
        //                              objGender.HSCodesWhereThisIsGender.Count == 0);

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
                int genderId = int.Parse(this.hdnSelectedGenderID.Value.Trim());
                if (Page.IsValid)
                {
                    ProcessForm(genderId, false);
                    Response.Redirect("/ViewGender.aspx");
                }
                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int genderId = int.Parse(this.hdnSelectedGenderID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(genderId, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);
        }

        //protected void dataGridGender_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dataGridGender.Columns)
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

        //protected void dataGridGender_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridGender.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int genderId = int.Parse(this.hdnSelectedGenderID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(genderId, "Gender", "Name", this.txtGenderName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewGender.aspx", ex);
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

            this.lblPopupHeaderText.Text = "New Gender";

            ViewState["IsPageValied"] = true;
            Session["GenderDetails"] = null;

            this.PopulateDataGrid();
        }

        private void PopulateDataGrid()
        {
            //Hide Controls

            this.dvNoSearchResult.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvEmptyContent.Visible = false;

            string searchText = this.txtSearch.Text.ToLower().Trim();

            GenderBO objGender = new GenderBO();


            List<GenderBO> lstGender = new List<GenderBO>();

            if (searchText != string.Empty && txtSearch.Text != "search")
            {
                lstGender = (from g in objGender.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                             where g.Name.ToLower().Contains(searchText)
                             select g).ToList();
            }
            else
            {
                lstGender = objGender.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            }
            if (lstGender.Count > 0)
            {
                this.RadGridGender.AllowPaging = (lstGender.Count > this.RadGridGender.PageSize);
                this.RadGridGender.DataSource = lstGender;
                this.RadGridGender.DataBind();
                Session["GenderDetails"] = lstGender;

                this.dvDataContent.Visible = true;
            }
            else if (searchText != string.Empty && txtSearch.Text != "search")
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyContent.Visible = true;
                this.btnAddGender.Visible = false;
            }
            // this.dvDataContent.Visible = (lstGender.Count > 0);
            this.RadGridGender.Visible = (lstGender.Count > 0);
            //throw new NotImplementedException();
        }

        private void ProcessForm(int genderId, bool isDelete)
        {
            try
            {
                GenderBO objGender = new GenderBO(this.ObjContext);
                using (TransactionScope ts = new TransactionScope())
                {
                    if (genderId > 0)
                    {
                        objGender.ID = genderId;
                        objGender.GetObject();
                        objGender.Name = this.txtGenderName.Text;

                        if (isDelete)
                        {
                            objGender.Delete();
                        }

                    }
                    else
                    {
                        objGender.Name = this.txtGenderName.Text;
                        objGender.Add();
                    }
                    this.ObjContext.SaveChanges();
                    //objGender.Add();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {

            }
        }

        private void ReBindGrid()
        {
            if (Session["GenderDetails"] != null)
            {
                RadGridGender.DataSource = (List<GenderBO>)Session["GenderDetails"];
                RadGridGender.DataBind();
            }
        }

        #endregion
    }
}