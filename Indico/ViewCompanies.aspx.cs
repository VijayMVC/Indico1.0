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
    public partial class ViewCompanies : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ItemsSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["ItemsSortExpression"] = value;
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

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void dataGridCompany_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is CompanyBO)
            {
                CompanyBO objCompany = (CompanyBO)item.DataItem;
                               
               //HyperLink lnkEdit = (HyperLink)item.FindControl("lnkEdit");

                HyperLink lnkDelete = (HyperLink)item.FindControl("lnkDelete");

                Label lblCompanyType = (Label)item.FindControl("lblCompanyType");

                lblCompanyType.Text = objCompany.objType.Name.ToString();

                Label lblCoordinator = (Label)item.FindControl("lblCoordinator");
                if (objCompany.Coordinator!=0)
                {
                    lblCoordinator.Text = objCompany.objCoordinator.GivenName + "" + objCompany.objCoordinator.FamilyName;
                }
                else
                {
                    lblCoordinator.Text = "No Coordinator";
                }
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            {
                int companyId = int.Parse(hdnSelectedCompanyID.Value.Trim ());

                if (companyId > 0)
                {
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            CompanyBO objCompany = new CompanyBO(this.ObjContext);
                            objCompany.ID = companyId;
                            objCompany.GetObject();

                            List<UserBO> lstUsers = objCompany.UsersWhereThisIsCompany;
                            foreach (UserBO  user in lstUsers)
                            {
                                UserBO objUser = new UserBO(this.ObjContext);
                                objUser.ID = user.ID;
                                objUser.GetObject();
                                objUser.Delete();
                            }
                            
                            List<ClientBO> lstClient = objCompany.ClientsWhereThisIsDistributor;
                            foreach (ClientBO client in lstClient )
                            {
                                ClientBO objClient = new ClientBO(this.ObjContext);
                                objClient.ID = client.ID;
                                objClient.GetAllObject();
                                objClient.Delete();
                            }


                            objCompany.Delete();

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                            this.PopulateDataGrid();
                        }
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }
        }

        protected void dataGridCompany_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dataGridCompany.CurrentPageIndex = e.NewPageIndex;

            this.PopulateDataGrid();
        }

        protected void dataGridCompany_SortCommand(object source, DataGridSortCommandEventArgs e)
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

            foreach (DataGridColumn col in this.dataGridCompany.Columns)
            {
                if (col.Visible && col.SortExpression == e.SortExpression)
                {
                    col.HeaderStyle.CssClass = "selected " + ((sortDirection.ToUpper() != " DESC") ? "sortDown" : "sortUp");
                }
                else
                {
                    col.HeaderStyle.CssClass = ((col.HeaderStyle.CssClass == "hide") ? "hide" : string.Empty);
                }
            }
        }

        protected void dataGridCompany_ItemCommand(object source, DataGridCommandEventArgs e)
        {
            switch (e.CommandName)
            {
                case "Edit":
                    {
                        Response.Redirect("/AddEditCompany.aspx?id=" + e.Item.Cells[0].Text);
                        break;
                    }
                case "Delete":
                    {
         
                        break;
                    }
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
            this.litHeaderText.Text = this.ActivePage.Heading;

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

            // Populate Company
            CompanyBO objCompany = new CompanyBO();

           
            List<CompanyBO> lstCompany = new List<CompanyBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstCompany = (from o in objCompany.SearchObjects().AsQueryable().OrderBy (SortExpression ).ToList()
                              where o.Name.ToLower().Contains(searchText)
                              select o).ToList();
            }
            else
            {
                lstCompany = objCompany.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            }

            if (lstCompany.Count > 0)
            {
                this.dataGridCompany.AllowPaging = (lstCompany.Count > this.dataGridCompany.PageSize);
                this.dataGridCompany.DataSource = lstCompany;
                this.dataGridCompany.DataBind();

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
                this.dvDataContent.Visible = false;
                this.dvEmptyContent.Visible = true;
                this.btnAddCompany.Visible = false;
            }

            //this.lblSerchKey.Text = string.Empty;
            this.dataGridCompany.Visible = (lstCompany.Count > 0);
        }

        #endregion
    }
}