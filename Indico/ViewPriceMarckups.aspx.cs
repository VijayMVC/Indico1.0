using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class ViewPriceMarckups : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["PriceMarckupSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Distributor";
                }
                return sort;
            }
            set
            {
                ViewState["PriceMarckupSortExpression"] = value;
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

        protected void dgPriceMarckups_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, DistributorPriceMarkupBO>)
            {
                var lstPriceMarckups = ((IGrouping<int, DistributorPriceMarkupBO>)item.DataItem).ToList();
                DistributorPriceMarkupBO objPriceMarckup = lstPriceMarckups[0];

                ((System.Web.UI.WebControls.WebControl)(item)).CssClass = "irow_" + objPriceMarckup.Distributor.ToString();

                Literal litDistributor = (Literal)item.FindControl("litDistributor");
                litDistributor.Text = objPriceMarckup.Distributor.ToString();

                Literal lblDistributor = (Literal)item.FindControl("lblDistributor");
                lblDistributor.Text = ((objPriceMarckup.Distributor > 0) ? objPriceMarckup.objDistributor.Name : "PLATINUM");

                Repeater rptDistributorPriceLevels = (Repeater)item.FindControl("rptDistributorPriceLevels");
                rptDistributorPriceLevels.DataSource = lstPriceMarckups;
                rptDistributorPriceLevels.DataBind();

                HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objPriceMarckup.Distributor.ToString());
                linkEdit.Attributes.Add("isType", "distributor");

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objPriceMarckup.Distributor.ToString());
                linkDelete.Attributes.Add("isType", "distributor");
                if (lblDistributor.Text == "PLATINUM")
                {
                    linkDelete.Visible = false;
                }
            }
        }

        protected void dgPriceMarckups_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dgPriceMarckups.CurrentPageIndex = e.NewPageIndex;
            // Populate data grid
            this.PopulateDataGrid();
        }

        protected void dgPriceMarckups_SortCommand(object source, DataGridSortCommandEventArgs e)
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

            foreach (DataGridColumn col in this.dgPriceMarckups.Columns)
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

        protected void rptPriceLevels_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PriceLevelBO)
            {
                PriceLevelBO objPriceLevel = (PriceLevelBO)item.DataItem;

                Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
                litCellHeader.Text = objPriceLevel.Name + "<em>( " + objPriceLevel.Volume + " )</em>";

                TextBox txtCellData = (TextBox)item.FindControl("txtCellData");
                txtCellData.Attributes.Add("qid", objPriceLevel.ID.ToString());
                txtCellData.CssClass = "level" + objPriceLevel.ID.ToString();
            }
            else if (item.ItemIndex > -1 && item.DataItem is DistributorPriceMarkupBO)
            {
                DistributorPriceMarkupBO objPriceMarckup = (DistributorPriceMarkupBO)item.DataItem;

                Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
                litCellHeader.Text = objPriceMarckup.objPriceLevel.Name + "<em>( " + objPriceMarckup.objPriceLevel.Volume + " )</em>";

                HiddenField hdnCellID = (HiddenField)item.FindControl("hdnCellID");
                hdnCellID.Value = objPriceMarckup.ID.ToString();

                Label lblCellData = (Label)item.FindControl("lblCellData");
                lblCellData.Attributes.Add("qid", objPriceMarckup.PriceLevel.ToString());
                lblCellData.Text = objPriceMarckup.Markup.ToString();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            int distributorID = int.Parse(this.hdnSelectedID.Value.Trim());
            bool isEdit = (Boolean.Parse(this.hdndistributor.Value) == true) ? true : false;

            if (Page.IsValid)
            {
                string type = this.hdnType.Value;
                this.ProcessForm(distributorID, false, isEdit, type);

                Response.Redirect("/ViewPriceMarckups.aspx");
            }

            // Popup Header Text
            //this.lblPopupHeaderText.Text = ((queryId > 0) ? "Edit " : "New ") + "Price Marckup";

            ViewState["IsPageValied"] = (Page.IsValid);            
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                int distributorID = int.Parse(this.hdnSelectedID.Value.Trim());
                string type = this.hdnType.Value;
                this.ProcessForm(distributorID, true, true, type);

                this.PopulateControls();
            }

            ViewState["IsPageValied"] = (Page.IsValid);           
        }

        protected void btnSaveClonePriceMarkup_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();

                if (this.ddlExistDistributors.SelectedValue != null && this.ddlNewDistributors.SelectedValue != "0")
                {
                    objReturnInt = DistributorPriceMarkupBO.CloneDistributorPriceMarkup(int.Parse(this.ddlExistDistributors.SelectedValue), int.Parse(this.ddlNewDistributors.SelectedValue));

                    if (objReturnInt.RetVal == 1)
                    {
                        ViewState["ClonePriceMarkup"] = false;
                        Response.Redirect("~/ViewPriceMarckups.aspx");
                    }
                    else
                    {
                        CustomValidator customValidator = new CustomValidator();
                        customValidator.ErrorMessage = "Insertion Failed Distributor Price Markup";
                        customValidator.IsValid = false;
                        customValidator.EnableClientScript = false;

                        this.ClonevalidationSummary.Controls.Add(customValidator);
                        ViewState["ClonePriceMarkup"] = true;
                    }
                }
            }
        }

        protected void btnSaveClonePriceMarkupLabel_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();

                if (this.ddlExistDistributors.SelectedValue != null && this.txtMarkupLabel.Text != string.Empty)
                {
                    objReturnInt = PriceMarkupLabelBO.CloneLabelPriceMarkup(int.Parse(this.ddlExistDistributors.SelectedValue), this.txtMarkupLabel.Text);

                    if (objReturnInt.RetVal == 1)
                    {
                        ViewState["ClonePriceMarkup"] = false;
                        Response.Redirect("~/ViewPriceMarckups.aspx");
                    }
                    else
                    {
                        CustomValidator customValidator = new CustomValidator();
                        customValidator.ErrorMessage = "Insertion Failed Price Markup Label";
                        customValidator.IsValid = false;
                        customValidator.EnableClientScript = false;

                        this.ClonevalidationSummary.Controls.Add(customValidator);
                        ViewState["ClonePriceMarkup"] = true;
                    }
                }
            }
        }

        protected void dgLabelPriceMarckups_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, LabelPriceMarkupBO>)
            {
                var lstLabelPriceMarckups = ((IGrouping<int, LabelPriceMarkupBO>)item.DataItem).ToList();
                LabelPriceMarkupBO objLabelPriceMarckup = lstLabelPriceMarckups[0];

                ((System.Web.UI.WebControls.WebControl)(item)).CssClass = "irow_" + objLabelPriceMarckup.Label.ToString();

                Literal litLabel = (Literal)item.FindControl("litLabel");
                litLabel.Text = objLabelPriceMarckup.Label.ToString();

                Literal lblLabel = (Literal)item.FindControl("lblLabel");
                lblLabel.Text = objLabelPriceMarckup.objLabel.Name;

                Repeater rptLabelPriceLevels = (Repeater)item.FindControl("rptLabelPriceLevels");
                rptLabelPriceLevels.DataSource = lstLabelPriceMarckups;
                rptLabelPriceLevels.DataBind();

                HyperLink linkLabelEdit = (HyperLink)item.FindControl("linkLabelEdit");
                linkLabelEdit.Attributes.Add("qid", objLabelPriceMarckup.Label.ToString());
                linkLabelEdit.Attributes.Add("isType", "label");

                HyperLink linkLabelDelete = (HyperLink)item.FindControl("linkLabelDelete");
                linkLabelDelete.Attributes.Add("qid", objLabelPriceMarckup.Label.ToString());
                linkLabelDelete.Attributes.Add("isType", "label");
            }
        }

        protected void dgLabelPriceMarckups_PageIndexChanged(object sender, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dgLabelPriceMarckups.CurrentPageIndex = e.NewPageIndex;
            // Populate data grid
            this.PopulateDataGrid();
        }

        protected void dgPriceMarckupsLabel_SortCommand(object sender, DataGridSortCommandEventArgs e)
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

            foreach (DataGridColumn col in this.dgLabelPriceMarckups.Columns)
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

        protected void rptLabelPriceLevels_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PriceLevelBO)
            {
                PriceLevelBO objPriceLevel = (PriceLevelBO)item.DataItem;

                Literal litLabelCellHeader = (Literal)item.FindControl("litLabelCellHeader");
                litLabelCellHeader.Text = objPriceLevel.Name + "<em>( " + objPriceLevel.Volume + " )</em>";

                TextBox txtCellData = (TextBox)item.FindControl("txtCellData");
                txtCellData.Attributes.Add("qid", objPriceLevel.ID.ToString());
                txtCellData.CssClass = "level" + objPriceLevel.ID.ToString();
            }
            else if (item.ItemIndex > -1 && item.DataItem is LabelPriceMarkupBO)
            {
                LabelPriceMarkupBO objLabelPriceMarckup = (LabelPriceMarkupBO)item.DataItem;

                Literal litLabelCellHeader = (Literal)item.FindControl("litLabelCellHeader");
                litLabelCellHeader.Text = objLabelPriceMarckup.objPriceLevel.Name + "<em>( " + objLabelPriceMarckup.objPriceLevel.Volume + " )</em>";

                HiddenField hdnCellID = (HiddenField)item.FindControl("hdnCellID");
                hdnCellID.Value = objLabelPriceMarckup.ID.ToString();

                Label lblLabelCellData = (Label)item.FindControl("lblLabelCellData");
                lblLabelCellData.Attributes.Add("qid", objLabelPriceMarckup.PriceLevel.ToString());
                lblLabelCellData.Text = objLabelPriceMarckup.Markup.ToString();
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

            // Populate Price Levels            
            this.rptPriceLevels.DataSource = (new PriceLevelBO()).GetAllObject().ToList();
            this.rptPriceLevels.DataBind();

            ViewState["IsPageValied"] = true;

            this.PopulateDataGrid();

            // Populate distributors dropdown

            GetNonAssignedPriceMarkupDistributorsViewBO objgnapmd = new GetNonAssignedPriceMarkupDistributorsViewBO();
            List<GetNonAssignedPriceMarkupDistributorsViewBO> lstgnpmd = (from o in objgnapmd.SearchObjects() orderby o.Name select o).ToList();

            DistributorPriceMarkupExtentions.BindList(this.ddlDistributors, lstgnpmd, "ID", "Name");
            DistributorPriceMarkupExtentions.BindListClone(this.ddlNewDistributors, lstgnpmd, "ID", "Name");

            this.ddlDistributors.Items.FindByValue(lstgnpmd[1].ID.ToString()).Selected = true;

            this.ddlExistDistributors.Items.Add(new ListItem("Platinum", "0"));
            List<int> lstExistDistributor = (new DistributorPriceMarkupBO()).SearchObjects().Where(o => o.Distributor != null && o.Distributor > 0 && o.objDistributor.IsActive == true && o.objDistributor.IsDelete == false).OrderBy(o => o.objDistributor.Name).Select(o => (int)o.Distributor).Distinct().ToList();
            foreach (int distributor in lstExistDistributor)
            {
                CompanyBO objComPany = new CompanyBO();
                objComPany.ID = distributor;
                objComPany.GetObject();

                this.ddlExistDistributors.Items.Add(new ListItem(objComPany.Name, objComPany.ID.ToString()));
            }
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
            DistributorPriceMarkupBO objPriceMarckup = new DistributorPriceMarkupBO();
            LabelPriceMarkupBO objLabelPriceMarkup = new LabelPriceMarkupBO();

            List<IGrouping<int, DistributorPriceMarkupBO>> lstPriceMarckups = new List<IGrouping<int, DistributorPriceMarkupBO>>();
            List<IGrouping<int, LabelPriceMarkupBO>> lstLabelPriceMarkups = new List<IGrouping<int, LabelPriceMarkupBO>>();

            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstPriceMarckups = (from o in objPriceMarckup.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                    where o.Distributor != 0 && o.objDistributor.Name.ToLower().Contains(searchText)
                                    orderby (int)o.Distributor
                                    group o by (int)o.Distributor into g
                                    select g).ToList();

                lstLabelPriceMarkups = (from o in objLabelPriceMarkup.SearchObjects().AsQueryable().ToList()
                                        where o.Label != 0 && o.objLabel.Name.ToLower().Contains(searchText)
                                        orderby (int)o.Label
                                        group o by (int)o.Label into g
                                        select g).ToList();
            }
            else
            {
                lstPriceMarckups = (from o in objPriceMarckup.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                    orderby (int)o.Distributor
                                    group o by (int)o.Distributor into g
                                    select g).ToList();

                lstLabelPriceMarkups = (from o in objLabelPriceMarkup.SearchObjects().AsQueryable().ToList()
                                        orderby (int)o.Label
                                        group o by (int)o.Label into g
                                        select g).ToList();

            }

            if (lstPriceMarckups.Count > 0)
            {
                this.dgPriceMarckups.AllowPaging = (lstPriceMarckups.Count > this.dgPriceMarckups.PageSize);
                this.dgPriceMarckups.DataSource = lstPriceMarckups;
                this.dgPriceMarckups.DataBind();

                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search"))
            {
                this.lblSerchKey.Text = searchText;

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyDistributor.Visible = true;
            }

            if (lstLabelPriceMarkups.Count > 0)
            {
                this.dgLabelPriceMarckups.AllowPaging = (lstLabelPriceMarkups.Count > this.dgLabelPriceMarckups.PageSize);
                this.dgLabelPriceMarckups.DataSource = lstLabelPriceMarkups;
                this.dgLabelPriceMarckups.DataBind();
            }
            else if ((searchText != string.Empty && searchText != "search"))
            {
                this.lblLabelSerchKey.Text = searchText;

                this.dvDataContent.Visible = true;
                this.dvNoSearchResultLabel.Visible = true;
            }
            else
            {
                this.dvEmptyLabel.Visible = true;
            }

            if (lstPriceMarckups.Count == 0 && lstLabelPriceMarkups.Count == 0)
            {
                this.dvEmptyContent.Visible = true;
                this.btnAddPriceMarckup.Visible = false;
            }

            this.dgPriceMarckups.Visible = (lstPriceMarckups.Count > 0);
            this.dgLabelPriceMarckups.Visible = (lstLabelPriceMarkups.Count > 0);
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm(int distributorID, bool isDelete, bool isEdit, string isType)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {

                    if (isEdit)
                    {
                        //Delete Statment
                        if (isDelete)
                        {
                            ReturnIntViewBO objReturnIntView = new ReturnIntViewBO();
                            if (isType == "distributor")
                            {
                                objReturnIntView = DistributorPriceMarkupBO.DeleteDistributorPriceMarkup(distributorID);
                                if (objReturnIntView.RetVal == 0)
                                {
                                    return;
                                }
                            }

                            if (isType == "label")
                            {
                                objReturnIntView = PriceMarkupLabelBO.DeleteLabelPriceMarkup(distributorID);
                                if (objReturnIntView.RetVal == 0)
                                {
                                    return;
                                }
                            }

                        }
                        else
                        {
                            if (isType == "distributor")
                            {
                                foreach (RepeaterItem item in this.rptPriceLevels.Items)
                                {
                                    HiddenField hdnCellID = (HiddenField)item.FindControl("hdnCellID");
                                    TextBox txtCellData = (TextBox)item.FindControl("txtCellData");

                                    int markup = int.Parse(hdnCellID.Value);

                                    DistributorPriceMarkupBO objPriceMarckup = new DistributorPriceMarkupBO(this.ObjContext);
                                    if (markup > 0)
                                    {
                                        objPriceMarckup.ID = int.Parse(hdnCellID.Value.Trim());
                                        objPriceMarckup.GetObject();
                                    }

                                    if (isEdit)
                                    {
                                        objPriceMarckup.Distributor = (distributorID > 0) ? distributorID : 0;
                                    }
                                    objPriceMarckup.PriceLevel = int.Parse(txtCellData.Attributes["qid"].ToString());
                                    objPriceMarckup.Markup = Convert.ToDecimal(decimal.Parse(txtCellData.Text.Trim()).ToString("0.00"));
                                }
                            }

                            if (isType == "label")
                            {
                                foreach (RepeaterItem item in this.rptPriceLevels.Items)
                                {
                                    HiddenField hdnCellID = (HiddenField)item.FindControl("hdnCellID");
                                    TextBox txtCellData = (TextBox)item.FindControl("txtCellData");

                                    int Labelmarkup = int.Parse(hdnCellID.Value);

                                    LabelPriceMarkupBO objLabelPriceMarkup = new LabelPriceMarkupBO(this.ObjContext);

                                    if (Labelmarkup > 0)
                                    {
                                        objLabelPriceMarkup.ID = int.Parse(hdnCellID.Value.Trim());
                                        objLabelPriceMarkup.GetObject();
                                    }

                                    objLabelPriceMarkup.Label = distributorID;
                                    objLabelPriceMarkup.PriceLevel = int.Parse(txtCellData.Attributes["qid"].ToString());
                                    objLabelPriceMarkup.Markup = Convert.ToDecimal(decimal.Parse(txtCellData.Text.Trim()).ToString("0.00"));
                                }
                            }
                        }

                    }
                    else
                    {
                        foreach (RepeaterItem item in this.rptPriceLevels.Items)
                        {
                            int distributor = int.Parse(this.ddlDistributors.SelectedValue);
                            HiddenField hdnCellID = (HiddenField)item.FindControl("hdnCellID");
                            TextBox txtCellData = (TextBox)item.FindControl("txtCellData");

                            int markup = int.Parse(hdnCellID.Value);

                            DistributorPriceMarkupBO objPriceMarckup = new DistributorPriceMarkupBO(this.ObjContext);
                            if (markup > 0)
                            {
                                objPriceMarckup.ID = int.Parse(hdnCellID.Value.Trim());
                                objPriceMarckup.GetObject();
                            }

                            if (distributor > 0)
                            {
                                objPriceMarckup.Distributor = (int?)distributor;
                            }
                            objPriceMarckup.PriceLevel = int.Parse(txtCellData.Attributes["qid"].ToString());
                            objPriceMarckup.Markup = Convert.ToDecimal(decimal.Parse(txtCellData.Text.Trim()).ToString("0.00"));
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Adding, upadting and deleting the PriceMarkups", ex);
            }
        }

        #endregion
    }
}