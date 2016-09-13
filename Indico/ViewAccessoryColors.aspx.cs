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
using System.Web.UI.HtmlControls;

namespace Indico
{
    public partial class ViewAccessoryColors : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["AcessoryColorsExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }

            set
            {
                ViewState["AcessoryColorsExpression"] = value;
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

        protected void RadGridColor_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridColor_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridColor_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is AccessoryColorBO)
                {
                    AccessoryColorBO objPatternAccessoryColor = (AccessoryColorBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objPatternAccessoryColor.ID.ToString());
                    linkEdit.Attributes.Add("colorvalue", objPatternAccessoryColor.ColorValue.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objPatternAccessoryColor.ID.ToString());
                    linkDelete.Visible = (objPatternAccessoryColor.VisualLayoutAccessorysWhereThisIsAccessoryColor.Count == 0);

                    HtmlGenericControl dvAccessoryColor = (HtmlGenericControl)item.FindControl("dvAccessoryColor");
                    dvAccessoryColor.Attributes.Add("style", "background-color: " + objPatternAccessoryColor.ColorValue.ToString());
                }
            }
        }

        protected void RadGridColor_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridColor_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridAccessoryColor_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is AccessoryColorBO)
        //    {
        //        AccessoryColorBO objPatternAccessoryColor = (AccessoryColorBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objPatternAccessoryColor.ID.ToString());
        //        linkEdit.Attributes.Add("colorvalue", objPatternAccessoryColor.ColorValue.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objPatternAccessoryColor.ID.ToString());
        //        linkDelete.Visible = (objPatternAccessoryColor.VisualLayoutAccessorysWhereThisIsAccessoryColor.Count == 0);

        //        HtmlGenericControl dvAccessoryColor = (HtmlGenericControl)item.FindControl("dvAccessoryColor");
        //        dvAccessoryColor.Attributes.Add("style", "background-color: " + objPatternAccessoryColor.ColorValue.ToString());
        //    }
        //}

        //protected void dataGridAccessoryColor_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dataGridAccessoryColor.Columns)
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

        //protected void dataGridAccessoryColor_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridAccessoryColor.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int accessorycolorsId = int.Parse(this.hdnSelectedAccessoryColorID.Value.Trim());

                if (!Page.IsValid)
                {
                    this.ProcessForm(accessorycolorsId, true);

                    this.PopulateDataGrid();
                }

                ViewState["IsPageValied"] = !(Page.IsValid);
            }
           
            // ViewState["IsPageValied"] = true;
            //this.validationSummary.Visible = !(Page.IsValid);
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            int accessorycolorsId = int.Parse(this.hdnSelectedAccessoryColorID.Value.Trim());
            if (this.IsNotRefresh)
            {
                if (Page.IsValid)
                {
                    this.ProcessForm(accessorycolorsId, false);

                    Response.Redirect("/ViewAccessoryColors.aspx");
                }

                ViewState["IsPageValied"] = (Page.IsValid);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["IsPageValied"] = true;
            this.PopulateDataGrid();
        }

        protected void cfvColorValue_Validate(object sender, ServerValidateEventArgs e)
        {
            if (!string.IsNullOrEmpty(hdnColorValue.Value.ToString()))
            {
                e.IsValid = true;
            }
            else
            {
                e.IsValid = false;
            }
        }

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int accessorycolorsId = int.Parse(this.hdnSelectedAccessoryColorID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(accessorycolorsId, "AccessoryColor", "Name", this.txtColorName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewAccessoryColors.aspx", ex);
            }
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;

            this.lblPopupHeaderText.Text = "New Size Sets";

            ViewState["IsPageValied"] = true;
            Session["AccessoryColorDetails"] = null;

            PopulateDataGrid();
        }

        private void PopulateDataGrid()
        {
            this.dvDataContent.Visible = false;
            this.dvEmptyContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            string searchText = this.txtSearch.Text.ToLower().Trim();

            AccessoryColorBO objPatternAccessoryColor = new AccessoryColorBO();
            List<AccessoryColorBO> lstPatternAccessoryColor = new List<AccessoryColorBO>();

            if (txtSearch.Text != string.Empty && txtSearch.Text != "search")
            {
                lstPatternAccessoryColor = (from ac in objPatternAccessoryColor.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                            where ac.Name.ToLower().Contains(searchText) ||
                                            ac.Code.ToLower().Contains(searchText) ||
                                            ac.ColorValue.ToLower().Contains(searchText)
                                            select ac).ToList();
            }
            else
            {
                lstPatternAccessoryColor = objPatternAccessoryColor.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            }

            if (lstPatternAccessoryColor.Count > 0)
            {
                this.RadGridColor.AllowPaging = (lstPatternAccessoryColor.Count > this.RadGridColor.PageSize);
                this.RadGridColor.DataSource = lstPatternAccessoryColor;
                this.RadGridColor.DataBind();
                Session["AccessoryColorDetails"] = lstPatternAccessoryColor;

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
                this.btnAddAccessoryColor.Visible = false;
            }

            this.RadGridColor.Visible = (lstPatternAccessoryColor.Count > 0);
        }

        private void ProcessForm(int accessorycolorsId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    AccessoryColorBO objAccessoryColor = new AccessoryColorBO(this.ObjContext);
                    if (accessorycolorsId > 0)
                    {
                        objAccessoryColor.ID = accessorycolorsId;
                        objAccessoryColor.GetObject();
                    }

                    if (isDelete)
                    {
                        objAccessoryColor.Delete();
                    }
                    else
                    {
                        objAccessoryColor.Name = this.txtColorName.Text;
                        objAccessoryColor.Code = this.txtCode.Text;
                        objAccessoryColor.ColorValue = this.hdnColorValue.Value.ToString();

                        if (accessorycolorsId == 0)
                        {
                            objAccessoryColor.Add();
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving Accessory color ViewAccessoryColor page", ex);
            }

        }

        private void ReBindGrid()
        {
            if (Session["AccessoryColorDetails"] != null)
            {
                RadGridColor.DataSource = (List<AccessoryColorBO>)Session["AccessoryColorDetails"];
                RadGridColor.DataBind();
            }
        }

        #endregion    
    }
}