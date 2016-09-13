using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class ViewSportsCategories : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["SportsCategoryExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["SportsCategoryExpression"] = value;
            }

        }

        #endregion

        #region Constructors

        #endregion

        #region Events

        protected override void OnPreRender(EventArgs e)
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

        protected void dataGridSportCategory_SortCommand(object source, DataGridSortCommandEventArgs e)
        {
            string sortDirection = String.Empty;
            if (!SortExpression.ToUpper().StartsWith(e.SortExpression) && !SortExpression.ToUpper().Trim().EndsWith("ASC"))
            {
                sortDirection = " asc";
            }
            else
            {
                sortDirection = (SortExpression.ToUpper().EndsWith("DESC")) ? " asc" : " desc";
            }
            this.SortExpression = e.SortExpression + sortDirection;

            this.PopulateDataGrid();

            foreach (DataGridColumn col in this.dataGridSportCategory.Columns)
            {
                if (col.Visible && col.SortExpression == e.SortExpression)
                {
                    col.HeaderStyle.CssClass = "selected " + ((sortDirection.ToUpper() != " DESC") ? "sortDown" : "sortUp");
                }
                else
                {
                    col.HeaderStyle.CssClass = "";
                }
            }
        }

        protected void dataGridSportCategory_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dataGridSportCategory.CurrentPageIndex = e.NewPageIndex;

            this.PopulateDataGrid();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            //ProcessForm
            int sportcategoryId = int.Parse(this.hdnSelectedSportCategoryID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(sportcategoryId, true);

                this.PopulateDataGrid();
            }
           
            //ViewState["IsPageValid"] = (Page.IsValid);
            ViewState["IsPageValid"] = true;
            this.validationSummary.Visible = !(Page.IsValid);
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int sportcategoryId = int.Parse(this.hdnSelectedSportCategoryID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(sportcategoryId, false);

                    Response.Redirect("/ViewSportsCategories.aspx");
                }

                ViewState["IsPageValid"] = (Page.IsValid);                
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["IsPageValid"] = true;
            this.PopulateDataGrid();
        }

        protected void dataGridSportCategory_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SportsCategoryBO)
            {
                SportsCategoryBO objSportsCategory = (SportsCategoryBO)item.DataItem;

                //Edit Link (add attribute)
                HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objSportsCategory.ID.ToString());

                //Delete Link (add attribute)
                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objSportsCategory.ID.ToString());
            }
        }


        #endregion 

        #region Methods

        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;
            this.lblPopupHeaderText.Text = "New Sports Categories";
            ViewState["IsPageValid"] = true;

            PopulateDataGrid();

        }

        private void PopulateDataGrid()
        {
            //Hide Details
            this.dvDataContent.Visible = false;
            this.dvEmptyContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            //Search Text
            string searchText = this.txtSearch.Text.ToLower().Trim();

            SportsCategoryBO objSportCategory = new SportsCategoryBO();

            List<SportsCategoryBO> lstSportCategory = new List<SportsCategoryBO>();

            if (txtSearch.Text != string.Empty && txtSearch.Text != "search")
            {
                lstSportCategory = (from pt in objSportCategory.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                  where pt.Name.ToLower().Contains(searchText) || 
                                  (pt.Description != null && pt.Description.ToLower().Contains(searchText))
                                  select pt).ToList();
            }
            else
            {
                lstSportCategory = objSportCategory.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            }

            if (lstSportCategory.Count > 0)
            {
                //Bind data to the Data Grid
                this.dataGridSportCategory.AllowPaging = (lstSportCategory.Count > this.dataGridSportCategory.PageSize);
                this.dataGridSportCategory.DataSource = lstSportCategory;
                this.dataGridSportCategory.DataBind();

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
               this.btnAddSportCatagories.Visible = false;
            }

            this.dataGridSportCategory.Visible = (lstSportCategory.Count > 0);
        }

        private void ProcessForm(int sportcategoryId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    SportsCategoryBO objSportCategory = new SportsCategoryBO(this.ObjContext);
                    if (sportcategoryId > 0)
                    {
                        objSportCategory.ID = sportcategoryId;
                        objSportCategory.GetObject();
                        //get data for update
                        objSportCategory.Name = this.txtSportCategoryName.Text;
                        objSportCategory.Description = this.txtDescription.Text;

                        //btn_Delete
                        if (isDelete)
                        {
                            objSportCategory.Delete();
                        }
                    }
           
                    else
                    {
                        //btn_SaveChanges
                        objSportCategory.Name = this.txtSportCategoryName.Text;
                        objSportCategory.Description = this.txtDescription.Text;
                        if (sportcategoryId == 0)
                        {
                            objSportCategory.Add();
                        }
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

        #endregion
    }
}