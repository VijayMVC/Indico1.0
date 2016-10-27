using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;
using System.Data.SqlClient;
using System.Configuration;
using Dapper;

namespace Indico
{
    public partial class ViewClients : IndicoPage
    {
        #region Fields

        private int pageindex = 0;
        private int dgPageSize = 20;

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ClientSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "0";
                }
                return sort;
            }
            set
            {
                ViewState["ClientSortExpression"] = value;
            }
        }

        private bool OrderBy
        {
            get
            {
                return (Session["ClientsOrderBy"] != null) ? (bool)Session["ClientsOrderBy"] : false;
            }
            set
            {
                Session["ClientsOrderBy"] = value;
            }
        }

        private int pageIndex
        {
            get
            {
                if (pageindex == 0)
                {
                    pageindex = 1;
                }
                return pageindex;
            }

            set
            {
                pageindex = value;
            }
        }

        private int TotalCount
        {
            get
            {
                int totalCount = (Session["totalCount"] != null) ? int.Parse(Session["totalCount"].ToString()) : 1;
                return totalCount;
            }
            set
            {
                Session["totalCount"] = value;
            }
        }

        protected int LoadedPageNumber
        {
            get
            {
                int c = 1;
                try
                {
                    if (Session["LoadedPageNumber"] != null)
                    {
                        c = Convert.ToInt32(Session["LoadedPageNumber"]);
                    }
                }
                catch (Exception)
                {
                    Session["LoadedPageNumber"] = c;
                }
                Session["LoadedPageNumber"] = c;
                return c;

            }
            set
            {
                Session["LoadedPageNumber"] = value;
            }
        }

        protected int ClientPageCount
        {
            get
            {
                int c = 0;
                try
                {
                    if (Session["ClientPageCount"] != null)
                        c = Convert.ToInt32(Session["ClientPageCount"]);
                }
                catch (Exception)
                {
                    Session["ClientPageCount"] = c;
                }
                Session["ClientPageCount"] = c;
                return c;
            }
            set
            {
                Session["ClientPageCount"] = value;
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

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void RadGridClients_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridClients_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridClients_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if ((item.ItemIndex > -1 && item.DataItem is JobNameDetailsView))
                {
                    JobNameDetailsView objClientDetails = (JobNameDetailsView)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.NavigateUrl = "/AddEditClient.aspx?id=" + objClientDetails.ID.ToString();

                    HyperLink lnkDelete = (HyperLink)item.FindControl("lnkDelete");
                    lnkDelete.Attributes.Add("qid", objClientDetails.ID.ToString());

                    lnkDelete.Visible = !(objClientDetails.HasVisualLayouts == true);
                }
            }
        }

        protected void RadGridClients_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridClients_ItemCommand(object sender, GridCommandEventArgs e)
        {
            //if (e.CommandName == RadGrid.FilterCommandName)
            //{
            this.ReBindGrid();
            //}
        }

        protected void RadGridClients_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            {
                int client = int.Parse(hdnSelectedClientID.Value.Trim());

                if (client > 0)
                {
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            JobNameBO objJobName = new JobNameBO(this.ObjContext);
                            objJobName.ID = client;
                            objJobName.GetObject();

                            objJobName.Delete();

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }

                        this.PopulateDataGrid();
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
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
            this.litHeaderText.Text = this.ActivePage.Heading;
            ViewState["IsPageValied"] = true;
            Session["ClientPageCount"] = 0;
            Session["LoadedPageNumber"] = 1;
            Session["totalCount"] = 1;
            Session["ClientsOrderBy"] = false;
            Session["JobNameDetailsView"] = null;

            // Populate Distributors
            //this.ddlDistributor.Items.Clear();
            //this.ddlDistributor.Items.Add(new ListItem("All", "0"));
            //List<int> lstClient = (new ClientBO()).SearchObjects().Where(o => o.objDistributor.IsActive == true && o.objDistributor.IsDelete == false).OrderBy(o => o.objDistributor.Name).Select(o => (int)o.Distributor).Distinct().ToList();

            //foreach (int id in lstClient)
            //{
            //    CompanyBO objCompany = new CompanyBO();
            //    objCompany.ID = id;
            //    objCompany.GetObject();

            //    this.ddlDistributor.Items.Add(new ListItem(objCompany.Name, objCompany.ID.ToString()));

            //}
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
            string distributor = string.Empty;
            // Populate Distributors
            
            if (this.LoggedUser.IsDirectSalesPerson)
            {
                distributor = "DIS" + this.Distributor.ID.ToString();
            }
            else if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
            {
                distributor = "COD" + this.LoggedUser.ID.ToString();
            }
                        
            List<JobNameDetailsView> lstJobNameDetails = new List<JobNameDetailsView>();

            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Open();
                lstJobNameDetails = connection.Query<JobNameDetailsView>(" EXEC	[dbo].[SPC_JobNameDetails] " +
                                                                        "@P_SearchText = '" + searchText + "'," +
                                                                        "@P_Distributor = '" + distributor + "'").ToList();

                connection.Close();
            }

            if (lstJobNameDetails.Count > 0)
            {
                this.RadGridClients.AllowPaging = (lstJobNameDetails.Count > this.RadGridClients.PageSize);
                this.RadGridClients.DataSource = lstJobNameDetails;
                this.RadGridClients.DataBind();
                Session["JobNameDetailsView"] = lstJobNameDetails;
                
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
                this.btnAddClient.Visible = false;
            }


            this.RadGridClients.Visible = (lstJobNameDetails.Count > 0);
        }
        private void ReBindGrid()
        {
            if (Session["JobNameDetailsView"] != null)
            {
                RadGridClients.DataSource = (List<JobNameDetailsView>)Session["JobNameDetailsView"];
                RadGridClients.DataBind();
            }
        }

        #endregion
    }
}