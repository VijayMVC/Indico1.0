using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Linq.Dynamic;
using System.Transactions;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class AddEditSizes : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["SizesSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "SizeName";
                }
                return sort;
            }
            set
            {
                ViewState["SizesSortExpression"] = value;
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

        protected void dgAddEditSizes_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeBO)
            {
                SizeBO objSize = (SizeBO)item.DataItem;

                Label lblSizeSet = (Label)item.FindControl("lblSizeSet");
                lblSizeSet.Text = objSize.objSizeSet.Name;

                Label lblSizeName = (Label)item.FindControl("lblSizeName");
                lblSizeName.Text = objSize.SizeName;

                Label lblSeqNo = (Label)item.FindControl("lblSeqNo");
                lblSeqNo.Text = objSize.SeqNo.ToString();

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objSize.ID.ToString());
            }
        }

        protected void dgAddEditSizes_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dgAddEditSizes.CurrentPageIndex = e.NewPageIndex;

            this.PopulateDataGrid();
        }
        

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnAddSizes_Click(object sender, EventArgs e)
        {
            Response.Redirect("/AddEditSizes.aspx");
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            int queryId = int.Parse(this.hdnSelectedSizeID.Value.Trim());

            if (Page.IsValid)
            {
                this.ProcessForm(queryId, false);

                Response.Redirect("/ViewSizes.aspx");
            }

            ViewState["IsPageValied"] = (Page.IsValid);
            //this.validationSummary.Visible = !(Page.IsValid);
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int queryId = int.Parse(this.hdnSelectedSizeID.Value.Trim());

            this.ProcessForm(queryId, true);

            this.PopulateDataGrid();
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

            ViewState["IsPageValied"] = true;

            this.PopulateDataGrid();
        }

        private void PopulateDataGrid()
        {
            // Hide Controls
           // this.dvEmptyContent.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            // Search text
            string searchText = this.txtSearch.Text.ToLower().Trim();

            // Populate Size
            SizeBO objSize = new SizeBO();

            List<SizeBO> lstSize = new List<SizeBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstSize = (from o in objSize.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<SizeBO>()
                           where o.SizeName.ToLower().Contains(searchText) ||
                           o.SeqNo.ToString().Contains(searchText) ||
                           o.objSizeSet.Name.ToLower().Contains(searchText)
                           select o).ToList();
            }
            else
            {
                lstSize = objSize.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<SizeBO>();
            }

            if (lstSize.Count > 0)
            {
                this.dgAddEditSizes.AllowPaging = (lstSize.Count > this.dgAddEditSizes.PageSize);
                this.dgAddEditSizes.DataSource = lstSize;
                this.dgAddEditSizes.DataBind();

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
                //this.dvEmptyContent.Visible = true;
                this.btnAddSizes.Visible = false;
            }

            // this.lblSerchKey.Text = string.Empty;
            this.dgAddEditSizes.Visible = (lstSize.Count > 0);
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
                    SizeBO objSize = new SizeBO(this.ObjContext);
                    if (queryId > 0)
                    {
                        objSize.ID = queryId;
                        objSize.GetObject();
                    }

                    if (isDelete)
                    {
                        objSize.Delete();
                    }
                    else
                    {
                        objSize.SizeName = this.txtSizeName.Text;
                        objSize.SeqNo = int.Parse(this.txtSeqNo.Text);
                        objSize.SizeSet = int.Parse(this.ddlSizeSet.SelectedItem.Value);

                        if (queryId == 0)
                        {
                            objSize.Add();
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

        #endregion
    }
}