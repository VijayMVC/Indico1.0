using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
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
using System.IO;
using System.Drawing;
using Dapper;

namespace Indico
{
    public partial class ViewDescriptionGrid : IndicoPage
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
                string sort = (string)ViewState["PatternSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "0";
                }
                return sort;
            }
            set
            {
                ViewState["PatternSortExpression"] = value;
            }
        }

        public bool IsNotRefresh
        {
            get
            {
                return (Session["IsPostBack"].ToString() == ViewState["IsPostBack"].ToString());
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

        protected void RadGridPattern_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPattern_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPattern_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if ((item.ItemIndex > -1 && item.DataItem is ReturnPatternDetailsViewBO))
                {
                    ReturnPatternDetailsViewBO objPatternDetails = (ReturnPatternDetailsViewBO)item.DataItem;

                    TextBox txtManualDescription = (TextBox)item.FindControl("txtManualDescription");
                    txtManualDescription.Text = objPatternDetails.Remarks;

                    TextBox txtMarketingDescription = (TextBox)item.FindControl("txtMarketingDescription");
                    txtMarketingDescription.Text = objPatternDetails.MarketingDescription;

                    TextBox txNotes = (TextBox)item.FindControl("txNotes");
                    txNotes.Text = objPatternDetails.PatternNotes;

                    TextBox txtFactoryDescription = (TextBox)item.FindControl("txtFactoryDescription");
                    txtFactoryDescription.Text = objPatternDetails.FactoryDescription;

                    PatternBO objPattern = new PatternBO();
                    objPattern.ID = (int)objPatternDetails.Pattern;
                    objPattern.GetObject();

                    string status = this.PopulateGarmentSpecStatus(objPattern);

                    RadGridPattern.Columns[12].Visible = (this.LoggedUser.HaveAccessForHTTPPost != null) ? (bool)this.LoggedUser.HaveAccessForHTTPPost : false;
                    Literal lblStatus = (Literal)item.FindControl("lblStatus");
                    lblStatus.Text = "<span class=\"badge badge-" + status.ToLower().Replace(" ", string.Empty).Trim() + "\">&nbsp;</span>";

                    LinkButton lbSave = (LinkButton)item.FindControl("lbSave");
                    lbSave.Attributes.Add("pid", objPatternDetails.Pattern.ToString());

                    Literal litPost = (Literal)item.FindControl("litPost");

                    bool HaveAcccessHttpPost = (this.LoggedUser.HaveAccessForHTTPPost != null) ? (bool)this.LoggedUser.HaveAccessForHTTPPost : false;
                    if (objPatternDetails.IsActiveWS == true && HaveAcccessHttpPost)
                    {
                        litPost.Text = "Sent";
                    }
                    else
                    {
                        litPost.Text = "Not yet sent";
                    }
                }
            }
        }

        protected void RadGridPattern_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridPattern_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPattern_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void ddlWebService_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void ddlSortByActive_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void ddlSortByGarmentSpec_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void linkSortby_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["IsPageValied"] = true;
            this.PopulateDataGrid();
        }

        protected void lbSave_Click(object sender, EventArgs e)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    foreach (GridDataItem item in RadGridPattern.Items)
                    {
                        TextBox txtManualDescription = (TextBox)item.FindControl("txtManualDescription");

                        TextBox txtMarketingDescription = (TextBox)item.FindControl("txtMarketingDescription");

                        TextBox txNotes = (TextBox)item.FindControl("txNotes");

                        TextBox txtFactoryDescription = (TextBox)item.FindControl("txtFactoryDescription");

                        LinkButton lbSave = (LinkButton)item.FindControl("lbSave");

                        int id = int.Parse(((System.Web.UI.WebControls.WebControl)(lbSave)).Attributes["pid"].ToString());

                        if (id > 0)
                        {
                            PatternBO objPattern = new PatternBO(this.ObjContext);
                            objPattern.ID = id;
                            objPattern.GetObject();

                            objPattern.Remarks = txtManualDescription.Text;
                            objPattern.Description = txtMarketingDescription.Text;
                            objPattern.PatternNotes = txNotes.Text;
                            objPattern.FactoryDescription = txtFactoryDescription.Text;

                            //if (objPattern.IsActiveWS)
                            //{
                            //    this.UpdateWebService(objPattern);
                            //}   
                        }
                    }
                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }

                this.PopulateDataGrid();
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while changing the notes and descriptions in Pattern from ViewDescriptionGrid.aspx", ex);
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
            Session["PatternDetails"] = null;

            this.RadGridPattern.MasterTableView.GetColumn("OriginRef").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("PrinterType").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("SpecialAttributes").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("ConvertionFactor").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("Gender").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("Item").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("AgeGroup").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("CorePattern").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("SizeSet").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("OriginRef").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("PrinterType").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("SpecialAttributes").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("ConvertionFactor").Display = false;
            //this.RadGridPattern.MasterTableView.GetColumn("Spec").Display = false;

            this.PopulateDataGrid();

        }

        private void PopulateDataGrid()
        {
            ViewState["ShowSpec"] = false;

            // Hide Controls

            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            string garmentSpecStatus = string.Empty;
            int blackchrome = 2;
            int patternStatus = 2;
            string searchText = string.Empty;



            List<ReturnPatternDetailsViewBO> lstPatternDetailsView = new List<ReturnPatternDetailsViewBO>();
            int totalCount = 0;

            if ((this.txtSearch.Text != string.Empty) && (this.txtSearch.Text != "search"))
            {
                searchText = this.txtSearch.Text.ToLower();
            }

            // Sort by Grament Spec           
            string sortText = this.ddlSortByGarmentSpec.SelectedItem.Text;
            if (sortText != string.Empty && this.ddlSortByGarmentSpec.SelectedIndex != 0)
            {
                garmentSpecStatus = this.ddlSortByGarmentSpec.SelectedItem.Text;

            }

            // sort by active pattern and in active pattern
            if (this.ddlSortByActive.SelectedItem.Text == "Active")
            {
                patternStatus = 1;
            }
            else if (this.ddlSortByActive.SelectedItem.Text == "InActive")
            {
                patternStatus = 0;
            }

            if (this.ddlWebService.SelectedItem.Value == "1")
            {
                blackchrome = 1;
            }
            else if (this.ddlWebService.SelectedItem.Value == "2")
            {
                blackchrome = 0;
            }
            using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Open();
                lstPatternDetailsView = connection.Query<ReturnPatternDetailsViewBO>(string.Format(@"EXEC [Indico].[dbo].[SPC_ViewPatternDetails] '{0}','{1}','{2}','{3}'", searchText, blackchrome, garmentSpecStatus, patternStatus)).ToList();
                connection.Close();
            }
           // lstPatternDetailsView = PatternBO.GetPatternDetails(searchText, dgPageSize, pageIndex, int.Parse(SortExpression), false, out totalCount, blackchrome, garmentSpecStatus, patternStatus);

            if (lstPatternDetailsView.Count > 0)
            {
                this.RadGridPattern.AllowPaging = (lstPatternDetailsView.Count > this.RadGridPattern.PageSize);
                this.RadGridPattern.DataSource = lstPatternDetailsView;
                this.RadGridPattern.DataBind();
                Session["PatternDetails"] = lstPatternDetailsView;
                this.dvDataContent.Visible = (lstPatternDetailsView.Count > 0);
                this.RadGridPattern.Visible = (lstPatternDetailsView.Count > 0);


            }
            else if ((searchText != string.Empty && searchText != "search") || this.ddlSortByGarmentSpec.SelectedItem.Text != string.Empty)
            {
                this.dvDataContent.Visible = true;
                this.RadGridPattern.Visible = (lstPatternDetailsView.Count > 0);
                this.dvNoSearchResult.Visible = true;

            }
            else
            {
                this.dvDataContent.Visible = (lstPatternDetailsView.Count > 0);
                this.RadGridPattern.Visible = (lstPatternDetailsView.Count > 0);

            }
        }

        private string PopulateGarmentSpecStatus(PatternBO objPattern)
        {
            string status = string.Empty;
            bool haveValues = false;
            bool haveZeroes = false;

            // check pattern status
            if (objPattern.SizeChartsWhereThisIsPattern.Count > 0)
            {
                foreach (SizeChartBO sChartValue in objPattern.SizeChartsWhereThisIsPattern)
                {
                    if (sChartValue.Val != 0)
                    {
                        haveValues = true;
                    }
                    else
                    {
                        haveZeroes = true;
                    }
                }
            }
            if (objPattern.SizeChartsWhereThisIsPattern.Count == 0 && objPattern.objItem.MeasurementLocationsWhereThisIsItem.Count > 0 && objPattern.objSizeSet.SizesWhereThisIsSizeSet.Count > 0)
            {
                status = "Not Completed";
            }
            else if (objPattern.SizeChartsWhereThisIsPattern.Count == 0 && objPattern.objItem.MeasurementLocationsWhereThisIsItem.Count == 0)
            {
                status = "Spec Missing";
            }
            else if (objPattern.SizeChartsWhereThisIsPattern.Count == 0 && objPattern.objItem.MeasurementLocationsWhereThisIsItem.Count > 0 && objPattern.objSizeSet.SizesWhereThisIsSizeSet.Count == 0)
            {
                status = "Spec Missing";
            }
            //-----------------------------------------------------------
            if (haveValues == true && haveZeroes == true)
            {
                status = "Partialy Completed";
            }

            if (haveValues == true && haveZeroes == false)
            {
                status = "Completed";
            }

            if (haveValues == false && haveZeroes == true)
            {
                status = "Not Completed";
            }
            //-------------------------------------------------------------

            return status;
        }

        //private void UpdateWebService(PatternBO objPattern)
        //{
        //    try
        //    {
        //        WebServicePattern objWebServicePattern = new WebServicePattern();

        //        //PatternBO objPattern = new PatternBO();
        //        //objPattern.ID = id;
        //        //objPattern.GetObject();

        //        objWebServicePattern.GUID = IndicoConfiguration.AppConfiguration.HttpPostGuid;
        //        objWebServicePattern.img1 = objWebServicePattern.CreateImages(objPattern, "img1");
        //        objWebServicePattern.img2 = objWebServicePattern.CreateImages(objPattern, "img2");
        //        objWebServicePattern.img3 = objWebServicePattern.CreateImages(objPattern, "img3");
        //        objWebServicePattern.img4 = objWebServicePattern.CreateImages(objPattern, "img4");
        //        objWebServicePattern.pdf = objWebServicePattern.GeneratePDF(objPattern, true, "0");
        //        objWebServicePattern.meas_xml = objWebServicePattern.WriteGramentSpecXML(objPattern);
        //        objWebServicePattern.garment_des = (!string.IsNullOrEmpty(objPattern.Remarks)) ? objPattern.Remarks.ToString() : string.Empty;
        //        objWebServicePattern.pat_no = objPattern.Number.ToString().Trim();
        //        objWebServicePattern.s_desc = "";
        //        objWebServicePattern.l_desc = (!string.IsNullOrEmpty(objPattern.Description)) ? objPattern.Description.ToString() : string.Empty;
        //        objWebServicePattern.gen_cat = objPattern.objGender.Name;
        //        objWebServicePattern.age_group = (objPattern.AgeGroup != null && objPattern.AgeGroup > 0) ? objPattern.objAgeGroup.Name : string.Empty;
        //        objWebServicePattern.main_cat_id = objPattern.objCoreCategory.Name.Trim();
        //        objWebServicePattern.sub_cat_id = "";
        //        //objWebServicePattern.rating = "1";
        //        //objWebServicePattern.times = "1";
        //        objWebServicePattern.date_entered = DateTime.Now.ToString("yyyy-MM-dd");
        //        objWebServicePattern.Post(false);
        //    }
        //    catch (Exception ex)
        //    {
        //        IndicoLogging.log.Error("Error occured while saving IsActiveWS in ViewPattern page", ex);
        //    }
        //}

        private void ReBindGrid()
        {
            if (Session["PatternDetails"] != null)
            {
                RadGridPattern.DataSource = (List<ReturnPatternDetailsViewBO>)Session["PatternDetails"];
                RadGridPattern.DataBind();
            }
        }

        #endregion
    }
}