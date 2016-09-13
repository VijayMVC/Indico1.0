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
//using Indico.Model;

namespace Indico
{
    public partial class ViewDistributorClients : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

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

        protected void RadGridClient_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridClient_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridClient_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is ClientBO)
                {
                    ClientBO objClient = (ClientBO)item.DataItem;

                    Literal litDistributor = (Literal)item.FindControl("litDistributor");
                    litDistributor.Text = objClient.objDistributor.Name;

                    Literal litFOCPenalty = (Literal)item.FindControl("litFOCPenalty");
                    litFOCPenalty.Text = objClient.FOCPenalty ? "Yes" : "No";

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objClient.ID.ToString());
                    linkEdit.Attributes.Add("did", objClient.Distributor.ToString());
                    linkEdit.Attributes.Add("foc", objClient.FOCPenalty ? "Yes" : "No");

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objClient.ID.ToString());
                    linkDelete.Visible = !(objClient.JobNamesWhereThisIsClient.Any());
                }
            }
        }

        protected void RadGridClient_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridClient_SortCommand(object sender, GridSortCommandEventArgs e)
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
                int clientID = int.Parse(this.hdnSelectedClientID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(clientID, false);

                    //IndicoEntities1 context = new IndicoEntities1();
                    //context.fun

                    Response.Redirect("/ViewDistributorClients.aspx");
                }

                ViewState["IsPageValid"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int clientID = int.Parse(this.hdnSelectedClientID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(clientID, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValid"] = (Page.IsValid);
            ViewState["IsPageValid"] = true;
            this.validationSummary.Visible = !(Page.IsValid);
        }

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int clientID = int.Parse(this.hdnSelectedClientID.Value.Trim());
                int disID = int.Parse(ddlDistributor.SelectedValue);

                //ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                //objReturnInt = SettingsBO.ValidateField(clientID, "Client", "Name", this.txtClientName.Text);
                //args.IsValid = objReturnInt.RetVal == 1;

                args.IsValid = IndicoPage.ValidateField2(clientID, "Client", "Name", this.txtClientName.Text, "Distributor", disID.ToString()) == 1;           
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewDistributorClients.aspx", ex);
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

            lblPopupHeaderText.Text = "New Client";
            ViewState["IsPageValid"] = true;
            Session["ClientDetails"] = null;

            ddlDistributor.Items.Clear();
            ddlDistributor.Items.Add(new ListItem("Select Distributor", "0"));
            ddlDistributor.Enabled = false;
            List<CompanyBO> lstDistributors = (new CompanyBO()).GetAllObject().Where(o => o.IsDistributor == true && o.IsActive == true && o.IsDelete == false).OrderBy(o => o.Name).ToList(); ;
            foreach (CompanyBO distributor in lstDistributors)
            {
                ddlDistributor.Items.Add(new ListItem(distributor.Name, distributor.ID.ToString()));
            }

            if (LoggedUser.IsDirectSalesPerson)
            {
                ddlDistributor.Items.FindByValue(Distributor.ID.ToString()).Selected = true;
            }
            else if (LoggedUserRoleName == UserRole.DistributorAdministrator || LoggedUserRoleName == UserRole.DistributorCoordinator)
            {
                ddlDistributor.Items.FindByValue(this.LoggedCompany.ID.ToString()).Selected = true;
            }
            else
            {
                ddlDistributor.Enabled = true;
            }

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
                ClientBO objClient = new ClientBO();

                if (LoggedUser.IsDirectSalesPerson)
                {
                    objClient.Distributor = this.Distributor.ID;
                }
                else if (LoggedUserRoleName == UserRole.DistributorAdministrator || LoggedUserRoleName == UserRole.DistributorCoordinator)
                {
                    objClient.Distributor = this.LoggedCompany.ID;
                }

                List<ClientBO> lstClients;
                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstClients = (from o in objClient.SearchObjects().ToList()
                                  where o.Name.ToLower().Contains(searchText) ||
                                  (o.Description != null ? o.Description.ToLower().Contains(searchText) : false)
                                  select o).ToList();
                }
                else
                {
                    lstClients = objClient.SearchObjects().ToList();
                }

                if (lstClients.Count > 0)
                {
                    this.RadGridClient.AllowPaging = (lstClients.Count > this.RadGridClient.PageSize);
                    this.RadGridClient.DataSource = lstClients;
                    this.RadGridClient.DataBind();
                    Session["ClientDetails"] = lstClients;

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

                this.RadGridClient.Visible = (lstClients.Count > 0);
            }
        }

        private void ProcessForm(int clientID, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    ClientBO objClient = new ClientBO(this.ObjContext);

                    if (clientID > 0)
                    {
                        objClient.ID = clientID;
                        objClient.GetObject();

                        objClient.Distributor = int.Parse(ddlDistributor.SelectedValue);
                        objClient.Name = this.txtClientName.Text;
                        objClient.Description = this.txtDescription.Text;
                        objClient.FOCPenalty = (this.chkFocPenalty.Checked) ? true : false;

                        if (isDelete)
                        {
                            objClient.Delete();
                        }
                    }
                    else
                    {
                        objClient.Distributor = int.Parse(ddlDistributor.SelectedValue);
                        objClient.Name = this.txtClientName.Text;
                        objClient.Description = this.txtDescription.Text;
                        objClient.FOCPenalty = this.chkFocPenalty.Checked;
                        objClient.Add();
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
            if (Session["ClientDetails"] != null)
            {
                RadGridClient.DataSource = (List<ClientBO>)Session["ClientDetails"];
                RadGridClient.DataBind();
            }
        }

        #endregion
    }
}