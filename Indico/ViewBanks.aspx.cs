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
    public partial class ViewBanks : IndicoPage
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

        protected void RadGridBank_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridBank_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridBank_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is BankBO)
                {
                    BankBO objBank = (BankBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objBank.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objBank.ID.ToString());
                    linkDelete.Visible = (objBank.InvoicesWhereThisIsBank.Count == 0);
                }
            }
        }

        protected void RadGridBank_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridBank_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridAgeGroup_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is BankBO)
        //    {
        //        BankBO objBank = (BankBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objBank.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objBank.ID.ToString());
        //        linkDelete.Visible = (objBank.PatternsWhereThisIsAgeGroup.Count == 0);
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
                int id = int.Parse(this.hdnSelectedBankID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(id, false);

                    Response.Redirect("/ViewBanks.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int id = int.Parse(this.hdnSelectedBankID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(id, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            ViewState["IsPageValied"] = true;
            this.validationSummary.Visible = !(Page.IsValid);

        }

        

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;

            lblPopupHeaderText.Text = "New Bank";
            ViewState["IsPageValied"] = true;
            Session["BankDetails"] = null;

            this.RadGridBank.MasterTableView.GetColumn("Number").Display = false;
            this.RadGridBank.MasterTableView.GetColumn("Address").Display = false;
            this.RadGridBank.MasterTableView.GetColumn("City").Display = false;
            this.RadGridBank.MasterTableView.GetColumn("State").Display = false;
            this.RadGridBank.MasterTableView.GetColumn("Postcode").Display = false;
            this.RadGridBank.MasterTableView.GetColumn("Country").Display = false;

            this.ddlCountry.Items.Clear();
            this.ddlCountry.Items.Add(new ListItem("Select a Country", "0"));
            List<CountryBO> lstCountry = (new CountryBO()).GetAllObject().OrderBy(o => o.ShortName).ToList();
            foreach (CountryBO country in lstCountry)
            {
                this.ddlCountry.Items.Add(new ListItem(country.ShortName, country.ID.ToString()));
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
                BankBO objBank = new BankBO();

                List<BankBO> lstBank = new List<BankBO>();
                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstBank = (from o in objBank.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                               where o.Name.ToLower().Contains(searchText) ||
                                     o.Branch.ToLower().Contains(searchText) ||
                                     o.AccountNo.ToLower().Contains(searchText) ||
                                    (o.SwiftCode != null ? o.SwiftCode.ToLower().Contains(searchText) : false)
                               select o).ToList();
                }
                else
                {
                    lstBank = objBank.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                }

                if (lstBank.Count > 0)
                {
                    this.RadGridBank.AllowPaging = (lstBank.Count > this.RadGridBank.PageSize);
                    this.RadGridBank.DataSource = lstBank;
                    this.RadGridBank.DataBind();
                    Session["BankDetails"] = lstBank;

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

                this.RadGridBank.Visible = (lstBank.Count > 0);
            }
        }

        private void ProcessForm(int id, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    BankBO objBank = new BankBO(this.ObjContext);
                    if (id > 0)
                    {
                        objBank.ID = id;
                        objBank.GetObject();

                        objBank.Name = this.txtName.Text;
                        objBank.Branch = this.txtBranch.Text;
                        objBank.Number = this.txtNumber.Text;
                        objBank.Address = this.txtAddress.Text;
                        objBank.City = this.txtCity.Text;
                        objBank.State = this.txtState.Text;
                        objBank.Postcode = this.txtPostcode.Text;
                        objBank.Country = int.Parse(this.ddlCountry.SelectedValue);
                        objBank.AccountNo = this.txtAccountNo.Text;
                        objBank.SwiftCode = this.txtSwiftCode.Text;
                        objBank.Modifier = this.LoggedUser.ID;
                        objBank.ModifiedDate = DateTime.Now;

                        if (isDelete)
                        {
                            objBank.Delete();
                        }
                    }
                    else
                    {
                        objBank.Name = this.txtName.Text;
                        objBank.Branch = this.txtBranch.Text;
                        objBank.Number = this.txtNumber.Text;
                        objBank.Address = this.txtAddress.Text;
                        objBank.City = this.txtCity.Text;
                        objBank.State = this.txtState.Text;
                        objBank.Postcode = this.txtPostcode.Text;
                        objBank.Country = int.Parse(this.ddlCountry.SelectedValue);
                        objBank.AccountNo = this.txtAccountNo.Text;
                        objBank.SwiftCode = this.txtSwiftCode.Text;
                        objBank.Creator = this.LoggedUser.ID;
                        objBank.CreatedDate = DateTime.Now;
                        objBank.Add();
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while editing, updating or insering a Bank in ViewBank.aspx page", ex);
            }
        }

        private void ReBindGrid()
        {
            if (Session["BankDetails"] != null)
            {
                RadGridBank.DataSource = (List<BankBO>)Session["BankDetails"];
                RadGridBank.DataBind();
            }
        }

        #endregion
    }
}