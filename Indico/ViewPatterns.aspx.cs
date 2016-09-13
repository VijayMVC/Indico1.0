using Dapper;
using Indico.BusinessObjects;
using Indico.Common;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using Telerik.Web.UI;

namespace Indico
{
    public partial class ViewPatterns : IndicoPage
    {
        #region Fields

        private int dgPageSize = 20;
        private int pageindex = 0;
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

        private bool OrderBy
        {
            get
            {
                return (Session["PatternOrderBy"] != null) ? (bool)Session["PatternOrderBy"] : false;
            }
            set
            {
                Session["PatternOrderBy"] = value;
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

        protected int PatternPageCount
        {
            get
            {
                int c = 0;
                try
                {
                    if (Session["PatternCount"] != null)
                        c = Convert.ToInt32(Session["PatternCount"]);
                }
                catch (Exception)
                {
                    Session["PatternCount"] = c;
                }
                Session["PatternCount"] = c;
                return c;
            }
            set
            {
                Session["DistributorCount"] = value;
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
            ViewState["ShowPatternOtherCat"] = false;
            ViewState["ShowConfirmPatternCat"] = false;

            if (!this.IsPostBack)
            {
                PopulateControls();
            }
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPattern_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if ((item.ItemIndex > -1 && item.DataItem is PatternDetailsView))
                {
                    PatternDetailsView objPatternDetails = (PatternDetailsView)item.DataItem;

                    CheckBox chkSelect = (CheckBox)item.FindControl("chkSelect");
                    chkSelect.Attributes.Add("qid", objPatternDetails.Pattern.ToString());

                    CheckBox chkIsCoreRange = (CheckBox)item.FindControl("chkIsCoreRange");
                    chkIsCoreRange.Checked = objPatternDetails.IsCoreRange;
                    chkIsCoreRange.Attributes.Add("qid", objPatternDetails.Pattern.ToString());

                    //HtmlAnchor ancGarmentSpec = (HtmlAnchor)item.FindControl("ancGarmentSpec");
                    LinkButton ancGarmentSpec = (LinkButton)item.FindControl("ancGarmentSpec");
                    ancGarmentSpec.Attributes.Add("qid", objPatternDetails.Pattern.ToString());

                    //Displaying pattern images
                    string imagePath_1 = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    string imagePath_2 = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    string imagePath_3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    string imagePath_hero = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    int count = 0;

                    int patternID = objPatternDetails.Pattern;
                    PatternTemplateImageBO objPatternTemplateImage = new PatternTemplateImageBO();
                    objPatternTemplateImage.Pattern = patternID;

                    List<PatternTemplateImageBO> lstPatternTemplateImageNotHero = objPatternTemplateImage.SearchObjects().Where(m => m.IsHero == false).ToList();
                    count = lstPatternTemplateImageNotHero.Count;

                    foreach (PatternTemplateImageBO patImage in lstPatternTemplateImageNotHero)
                    {
                        if (patImage.ImageOrder == 1)
                        {
                            string imagePath1 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + "/" + patImage.Pattern + "/" + patImage.Filename + lstPatternTemplateImageNotHero[0].Extension;

                            if (File.Exists(Server.MapPath(imagePath1)))
                            {
                                imagePath_1 = imagePath1;
                            }

                            continue;
                        }

                        if (patImage.ImageOrder == 2)
                        {
                            string imagepPath2 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + "/" + patImage.Pattern + "/" + patImage.Filename + lstPatternTemplateImageNotHero[0].Extension;

                            if (File.Exists(Server.MapPath(imagepPath2)))
                            {
                                imagePath_2 = imagepPath2;
                            }

                            continue;
                        }

                        if (patImage.ImageOrder == 3)
                        {
                            string imagePath3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + "/" + patImage.Pattern + "/" + patImage.Filename + lstPatternTemplateImageNotHero[0].Extension;

                            if (File.Exists(Server.MapPath(imagePath3)))
                            {
                                imagePath_3 = imagePath3;
                            }

                            continue;
                        }
                    }

                    HtmlAnchor ancTemplateImage = (HtmlAnchor)item.FindControl("ancTemplateImage");
                    HtmlGenericControl iimageView = (HtmlGenericControl)item.FindControl("iimageView");

                    List<PatternTemplateImageBO> lstPatternTemplateImageHero = objPatternTemplateImage.SearchObjects().Where(m => m.IsHero == true).ToList();

                    if (lstPatternTemplateImageHero.Count > 0)
                    {
                        string imagePathHero = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + patternID.ToString() + "/" + lstPatternTemplateImageHero.First().Filename + lstPatternTemplateImageHero.First().Extension;
                        if (File.Exists(Server.MapPath(imagePathHero)))
                        {
                            imagePath_hero = imagePathHero;
                        }

                        if (File.Exists(Server.MapPath(imagePathHero)))
                        {
                            ancTemplateImage.Attributes.Add("class", "btn-link preview");
                            iimageView.Attributes.Add("class", "icon-eye-open");

                            System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(Server.MapPath(imagePathHero));
                            SizeF origImageSize = VLOrigImage.PhysicalDimension;
                            VLOrigImage.Dispose();

                            System.Drawing.Image VLImage_1 = System.Drawing.Image.FromFile(Server.MapPath(imagePath_1));
                            SizeF image_1Size = VLImage_1.PhysicalDimension;
                            VLImage_1.Dispose();

                            System.Drawing.Image VLImage_2 = System.Drawing.Image.FromFile(Server.MapPath(imagePath_2));
                            SizeF image_2Size = VLImage_2.PhysicalDimension;
                            VLImage_2.Dispose();

                            System.Drawing.Image VLImage_3 = System.Drawing.Image.FromFile(Server.MapPath(imagePath_3));
                            SizeF image_3Size = VLImage_3.PhysicalDimension;
                            VLImage_3.Dispose();

                            List<float> lstVLImageDimensions = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 380, 380);
                            List<float> lstVLImageDimensionsForPhotographyImage_1 = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(image_1Size.Width)), Convert.ToInt32(Math.Abs(image_1Size.Height)), 128, 128);
                            List<float> lstVLImageDimensionsForPhotographyImage_2 = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(image_2Size.Width)), Convert.ToInt32(Math.Abs(image_2Size.Height)), 128, 128);
                            List<float> lstVLImageDimensionsForPhotographyImage_3 = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(image_3Size.Width)), Convert.ToInt32(Math.Abs(image_3Size.Height)), 128, 128);

                            string htmlPreview = "<div id='dvPatternTemplate' class=\"ihero\"  target='_blank'>" +
                                                    "<div class=\"ihero-image\">" +
                                                        "<img src=\"" + imagePathHero + "\" alt=\"Hero Image\" height=\"" + lstVLImageDimensions[0].ToString() + "\" width=\"" + lstVLImageDimensions[1].ToString() + "\" />" +
                                                    "</div>" +
                                                    "<div class=\"ihero-details\">" +
                                                        "<img src=\"" + imagePath_1 + "\" alt=\"Thumbnail\" height=\"" + lstVLImageDimensionsForPhotographyImage_1[0].ToString() + "\" width=\"" + lstVLImageDimensionsForPhotographyImage_1[1].ToString() + "\" />" +
                                                        "<img src=\"" + imagePath_2 + "\" alt=\"Thumbnail\" height=\"" + lstVLImageDimensionsForPhotographyImage_2[0].ToString() + "\" width=\"" + lstVLImageDimensionsForPhotographyImage_2[1].ToString() + "\" />" +
                                                        "<img src=\"" + imagePath_3 + "\" alt=\"Thumbnail\" height=\"" + lstVLImageDimensionsForPhotographyImage_3[0].ToString() + "\" width=\"" + lstVLImageDimensionsForPhotographyImage_3[1].ToString() + "\" />" +
                                                    "</div>" +
                                                "</div>";

                            HtmlContainerControl previewTemplate = (HtmlContainerControl)item.FindControl("previewTemplate");
                            previewTemplate.InnerHtml = htmlPreview;

                            ancTemplateImage.HRef = "#" + previewTemplate.ClientID;
                            // ancTemplateImage.Title = "Pattern Images";

                            ancTemplateImage.Attributes.Add("target", "_blank");
                            ancTemplateImage.Attributes.Add("onclick", "Javascript:populateDiv(this);return false;");
                            ancTemplateImage.Attributes.Add("hero", imagePathHero);
                            ancTemplateImage.Attributes.Add("nohero_1", imagePath_1);
                            ancTemplateImage.Attributes.Add("nohero_2", imagePath_2);
                            ancTemplateImage.Attributes.Add("nohero_3", imagePath_3);
                        }
                        else
                        {
                            ancTemplateImage.Title = "Pattern Images Not Found";
                            //ancTemplateImage.Attributes.Add("class", "btn-link iremove");
                            iimageView.Attributes.Add("class", "icon-eye-close");
                        }
                    }
                    else
                    {
                        ancTemplateImage.Title = "Pattern Images Not Found";
                        //ancTemplateImage.Attributes.Add("class", "btn-link iremove");
                        iimageView.Attributes.Add("class", "icon-eye-close");
                    }

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.NavigateUrl = "AddEditPattern.aspx?id=" + objPatternDetails.Pattern.ToString();

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objPatternDetails.Pattern.ToString());

                    var addEditDevelopment = (HyperLink)item.FindControl("addEditPatternDevelopmentLink");
                    if (objPatternDetails.PatternDevelopmentID != 0)
                    {
                        addEditDevelopment.CssClass = "btn-link iedit";
                        addEditDevelopment.ToolTip = "Edit Pattern Development";
                        addEditDevelopment.Controls.Clear();
                        var html = new HtmlGenericControl { InnerHtml = "<i class=\"icon-pencil\"  ></i>Edit Development" };
                        addEditDevelopment.Text = "Edit Development";
                        addEditDevelopment.Controls.Add(html);
                        addEditDevelopment.NavigateUrl = string.Format("ViewPatternDevelopment.aspx?Pattern={0}", objPatternDetails.Number);
                        var checkDevelopmentHistoryLink = (HyperLink)item.FindControl("checkDevelopmentHistoryLink");
                        checkDevelopmentHistoryLink.Visible = true;
                        checkDevelopmentHistoryLink.Attributes.Add("data-developmentID", objPatternDetails.PatternDevelopmentID.ToString());
                    }
                    else
                    {
                        addEditDevelopment.Visible = false;
                        //   addEditDevelopment.NavigateUrl = string.Format("ViewPatternDevelopment.aspx?Create=true&Pattern={0}", objPatternDetails.Number);
                    }


                    PatternBO objPattern = new PatternBO();
                    objPattern.ID = objPatternDetails.Pattern;
                    objPattern.GetObject();

                    linkDelete.Visible = objPatternDetails.CanDelete;

                    if (this.LoggedUserRoleName == UserRole.IndicoCoordinator)
                    {
                        linkDelete.Visible = false;
                    }

                    LinkButton linkaws = (LinkButton)item.FindControl("linkaws");
                    LinkButton linkdws = (LinkButton)item.FindControl("linkdws");
                    linkdws.Attributes.Add("patid", objPatternDetails.Pattern.ToString());
                    linkaws.Attributes.Add("patid", objPatternDetails.Pattern.ToString());
                    linkaws.Visible = false;
                    linkdws.Visible = false;
                    string status = this.PopulateGarmentSpecStatus(objPattern);
                    bool HaveAcccessHttpPost = (this.LoggedUser.HaveAccessForHTTPPost != null) ? (bool)this.LoggedUser.HaveAccessForHTTPPost : false;
                    LinkButton ancDownloadPDF = (LinkButton)item.FindControl("ancDownloadPDF");

                    if (status == "Completed")
                    {
                        ancDownloadPDF.Visible = true;
                        ancDownloadPDF.Attributes.Add("pid", objPatternDetails.Pattern.ToString());
                        //bool HaveAcccessHttpPost = (this.LoggedUser.HaveAccessForHTTPPost != null) ? (bool)this.LoggedUser.HaveAccessForHTTPPost : false;

                        if (objPatternDetails.IsActiveWS == true && HaveAcccessHttpPost)
                        {
                            linkaws.Visible = false;
                            linkdws.Visible = true;
                            linkdws.ToolTip = "Remove";
                        }
                        else
                        {
                            if (HaveAcccessHttpPost)
                            {
                                linkaws.Visible = true;
                                linkdws.Visible = false;
                                linkaws.ToolTip = "Send";
                            }
                        }
                    }
                    else if (objPatternDetails.GarmentSpecStatus == "Partialy Completed")
                    {
                        ancDownloadPDF.Visible = true;
                        ancDownloadPDF.Attributes.Add("pid", objPatternDetails.Pattern.ToString());

                        if (objPatternDetails.IsActiveWS == true && HaveAcccessHttpPost)
                        {
                            linkaws.Visible = false;
                            linkdws.Visible = true;
                            linkdws.ToolTip = "Remove";
                        }
                        else
                        {
                            if (HaveAcccessHttpPost)
                            {
                                linkaws.Visible = true;
                                linkdws.Visible = false;
                                linkaws.ToolTip = "Send";
                            }
                        }
                    }

                    RadGridPattern.Columns[12].Visible = (this.LoggedUser.HaveAccessForHTTPPost != null) ? (bool)this.LoggedUser.HaveAccessForHTTPPost : false;
                    Literal lblStatus = (Literal)item.FindControl("lblStatus");
                    lblStatus.Text = "<span class=\"badge badge-" + status.ToLower().Replace(" ", string.Empty).Trim() + "\">&nbsp;</span>";
                }
            }
        }

        protected void RadGridPattern_ItemCommand(object sender, GridCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPattern_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPattern_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPattern_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridPattern_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void ddlFilterBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int patternId = int.Parse(this.hdnSelectedPatternID.Value);

            if (patternId > 0)
            {
                WebServicePattern objWebServicePattern = new WebServicePattern();
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        PatternBO objPattern = new PatternBO(this.ObjContext);
                        objPattern.ID = patternId;
                        objPattern.GetObject();

                        objPattern.IsActive = false;
                        objPattern.IsActiveWS = false;
                        objWebServicePattern.DeletePatternNumber = objPattern.Number;
                        objWebServicePattern.GUID = IndicoConfiguration.AppConfiguration.HttpPostGuid;
                        objWebServicePattern.DeleteDirectoriesGivenPattern(objPattern);
                        objWebServicePattern.Post(true);

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while deleting pattern From the View Patterns Page", ex);
                }
                this.PopulateDataGrid();
            }
        }

        protected void ancGarmentSpec_click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int patternId = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["qid"]);
                this.hdnSelectedPatternID.Value = patternId.ToString();
                this.hdnPatternID.Value = patternId.ToString();

                this.ddlConvert.Items.FindByValue("1").Selected = false;
                this.ddlConvert.Items.FindByValue("0").Selected = true;

                if (patternId > 0)
                {
                    PatternBO objPattern = new PatternBO();
                    objPattern.ID = patternId;
                    objPattern.GetObject();

                    // populate pattern details garment spec
                    this.PopulatePatternGarmentSpec(objPattern.ID);

                    List<SizeChartBO> lstSizeCharts = objPattern.SizeChartsWhereThisIsPattern;
                    List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = lstSizeCharts.OrderBy(o => o.objMeasurementLocation.Key).GroupBy(o => o.MeasurementLocation).ToList();

                    if (lstSizeChartGroup.Count > 0)
                    {
                        this.rptSpecSizeQtyHeader.DataSource = (List<SizeChartBO>)lstSizeChartGroup[0].ToList();
                        this.rptSpecSizeQtyHeader.DataBind();

                        this.rptSpecML.DataSource = lstSizeChartGroup;
                        this.rptSpecML.DataBind();

                        this.dvSpecGrdEmpty.Visible = false;
                        this.dvSpecGrd.Visible = true;
                        //this.btnSaveSpecChanges.Visible = true;
                    }
                    else
                    {
                        this.GenerateNewGarmentSpec(patternId);
                    }
                    if (objPattern.PatternCompressionImage.GetValueOrDefault() > 0)
                    {
                        var img = GetPatternCompressionImagePath(objPattern.ID);
                        if (!string.IsNullOrWhiteSpace(img))
                        {
                            imgPatternCompressionImage.ImageUrl = img;
                            imgPatternCompressionImage.Visible = true;
                            garmentSpecModalTableContainer.Style.Add("display", "none");
                            divPatternTemplateImageContainer.Style.Add("display", "none");
                        }
                        else
                        {
                            garmentSpecModalTableContainer.Style.Add("display", "block");
                            divPatternTemplateImageContainer.Style.Add("display", "block");
                            imgPatternCompressionImage.Visible = false;
                        }
                    }
                    else
                    {
                        garmentSpecModalTableContainer.Style.Add("display", "block");
                        divPatternTemplateImageContainer.Style.Add("display", "block");
                        imgPatternCompressionImage.Visible = false;
                    }


                    ViewState["ShowSpec"] = true;
                }
            }
            else
            {
                ViewState["ShowSpec"] = false;
            }
        }

        protected void rptSpecSizeQtyHeader_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
            {
                SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

                Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
                litCellHeader.Text = objSizeChart.objSize.SizeName;
            }
        }

        protected void rptSpecML_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, SizeChartBO>)
            {
                List<SizeChartBO> lstSizeChart = ((IGrouping<int, SizeChartBO>)item.DataItem).ToList();

                MeasurementLocationBO objML = new MeasurementLocationBO();
                objML.ID = lstSizeChart[0].MeasurementLocation;
                objML.GetObject();

                Literal litCellHeaderKey = (Literal)item.FindControl("litCellHeaderKey");
                litCellHeaderKey.Text = objML.Key;

                Literal litCellHeaderML = (Literal)item.FindControl("litCellHeaderML");
                litCellHeaderML.Text = objML.Name;

                Repeater rptSpecSizeQty = (Repeater)item.FindControl("rptSpecSizeQty");
                rptSpecSizeQty.DataSource = lstSizeChart;
                rptSpecSizeQty.DataBind();
            }
        }

        protected void rptSpecSizeQty_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
            {
                SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

                Label lblQty = (Label)item.FindControl("lblQty");
                lblQty.Text = Math.Round(objSizeChart.Val, 1).ToString();

                lblQty.Attributes.Add("qid", objSizeChart.ID.ToString());
                lblQty.Attributes.Add("MLID", objSizeChart.MeasurementLocation.ToString());
                lblQty.Attributes.Add("SID", objSizeChart.Size.ToString());
            }
        }

        protected void ddlSortByGarmentSpec_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/ViewPatterns.aspx");
        }

        protected void ddlSortByActive_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void ddlWebService_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void linkws_OnClick(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int patternID = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["patid"]);

                if (patternID > 0)
                {
                    try
                    {
                        WebServicePattern objWebServicePattern = new WebServicePattern();

                        using (TransactionScope ts = new TransactionScope())
                        {
                            PatternBO objPattern = new PatternBO(this.ObjContext);
                            objPattern.ID = patternID;
                            objPattern.GetObject();

                            if (objPattern.IsActiveWS == true)
                            {
                                objPattern.IsActiveWS = false;
                                //objWebServicePattern.DeletePatternNumber = objPattern.Number;
                                //objWebServicePattern.GUID = IndicoConfiguration.AppConfiguration.HttpPostGuid;
                                //objWebServicePattern.DeleteDirectoriesGivenPattern(objPattern);
                                //objWebServicePattern.Post(true);
                            }
                            else if (objPattern.IsActiveWS == false)
                            {
                                objPattern.IsActiveWS = true;
                                //objWebServicePattern.GUID = IndicoConfiguration.AppConfiguration.HttpPostGuid;
                                //objWebServicePattern.img1 = objWebServicePattern.CreateImages(objPattern, "img1");
                                //objWebServicePattern.img2 = objWebServicePattern.CreateImages(objPattern, "img2");
                                //objWebServicePattern.img3 = objWebServicePattern.CreateImages(objPattern, "img3");
                                //objWebServicePattern.img4 = objWebServicePattern.CreateImages(objPattern, "img4");
                                //objWebServicePattern.pdf = objWebServicePattern.GeneratePDF(objPattern, true, "0");
                                //objWebServicePattern.meas_xml = objWebServicePattern.WriteGramentSpecXML(objPattern);
                                //objWebServicePattern.garment_des = (!string.IsNullOrEmpty(objPattern.Remarks)) ? objPattern.Remarks.ToString() : string.Empty;
                                //objWebServicePattern.pat_no = objPattern.Number.ToString().Trim();
                                //objWebServicePattern.s_desc = "";
                                //objWebServicePattern.l_desc = (!string.IsNullOrEmpty(objPattern.Description)) ? objPattern.Description.ToString() : string.Empty;
                                //objWebServicePattern.gen_cat = objPattern.objGender.Name;
                                //objWebServicePattern.age_group = (objPattern.AgeGroup != null && objPattern.AgeGroup > 0) ? objPattern.objAgeGroup.Name : string.Empty;
                                //objWebServicePattern.main_cat_id = objPattern.objCoreCategory.Name.Trim();
                                //objWebServicePattern.sub_cat_id = "";
                                ////objWebServicePattern.rating = "1";
                                ////objWebServicePattern.times = "1";
                                //objWebServicePattern.date_entered = DateTime.Now.ToString("yyyy-MM-dd");
                                //objWebServicePattern.Post(false);
                            }
                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while saving IsActiveWS in ViewPattern page", ex);
                    }

                    this.PopulateDataGrid();
                }
            }
        }

        protected void linkSortby_Click(object sender, EventArgs e)
        {
            string status = ((System.Web.UI.WebControls.WebControl)(sender)).Attributes["status"].ToString();

            if (status == "comp")
            {
                this.ddlSortByGarmentSpec.SelectedIndex = 1; // Items.FindByValue("1").Selected = true;
            }
            else if (status == "ncomp")
            {
                this.ddlSortByGarmentSpec.SelectedIndex = 2;
            }
            else if (status == "pcomp")
            {
                this.ddlSortByGarmentSpec.SelectedIndex = 3;
            }
            else
            {
                this.ddlSortByGarmentSpec.SelectedIndex = 4;
            }
            this.ddlSortByGarmentSpec_SelectedIndexChanged(null, null);
        }

        protected void ancDownloadPDF_click(object sender, EventArgs e)
        {
            int patternID = int.Parse(((WebControl)(sender)).Attributes["pid"]);
            this.DownloadPdf(patternID);
        }

        protected void btnPrintPDF_OnClick(object sender, EventArgs e)
        {
            int patternID = int.Parse(this.hdnPatternID.Value);
            this.DownloadPdf(patternID);
            ViewState["ShowSpec"] = true;
        }

        protected void btnAddPatternOtherCategories_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                List<CategoryBO> lstCategory = (new CategoryBO()).SearchObjects().OrderBy(o => o.Name).ToList();

                this.dgCategory.DataSource = lstCategory;
                this.dgCategory.DataBind();

                ViewState["ShowPatternOtherCat"] = true;
            }
            else
            {
                ViewState["ShowPatternOtherCat"] = false;
            }
        }

        protected void btnUpdatePatternOtherCategories_Click(object sender, EventArgs e)
        {
            ViewState["ShowConfirmPatternCat"] = true;
        }

        protected void btnSavePatternOtherCategories_Click(object sender, EventArgs e)
        {
            List<int> lstPatters = new List<int>();
            List<int> lstCategories = new List<int>();
            //??????
            foreach (GridDataItem item in this.RadGridPattern.Items)
            {
                CheckBox chkSelect = (CheckBox)item.FindControl("chkSelect");

                if (chkSelect.Checked)
                {
                    lstPatters.Add(int.Parse(chkSelect.Attributes["qid"].ToString()));
                }
            }

            foreach (DataGridItem item in this.dgCategory.Items)
            {
                CheckBox chkSelect = (CheckBox)item.FindControl("chkSelect");

                if (chkSelect.Checked)
                {
                    lstCategories.Add(int.Parse(chkSelect.Attributes["qid"].ToString()));
                }
            }

            using (TransactionScope ts = new TransactionScope())
            {
                try
                {
                    foreach (int pattern in lstPatters)
                    {
                        PatternBO objPattern = new PatternBO(this.ObjContext);
                        objPattern.ID = pattern;
                        objPattern.GetObject();

                        foreach (int category in lstCategories)
                        {
                            if (objPattern.PatternOtherCategorysWhereThisIsPattern.Where(o => o.ID == category).Count() == 0)
                            {
                                CategoryBO objCategory = new CategoryBO(this.ObjContext);
                                objCategory.ID = category;
                                objCategory.GetObject();

                                objPattern.PatternOtherCategorysWhereThisIsPattern.Add(objCategory);
                            }
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while updating pattern other categories", ex);
                }
            }

            this.PopulateControls();
        }

        protected void dgCategory_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is CategoryBO)
            {
                CategoryBO objCategory = (CategoryBO)item.DataItem;

                CheckBox chkSelect = (CheckBox)item.FindControl("chkSelect");
                chkSelect.Attributes.Add("qid", objCategory.ID.ToString());
            }
        }

        protected void btnSaveChanges_ServerClick(object sender, EventArgs e)
        {
            try
            {
                foreach (GridDataItem item in this.RadGridPattern.Items)
                {
                    CheckBox chkIsCoreRange = (CheckBox)item.FindControl("chkIsCoreRange");

                    PatternBO objPattern = new PatternBO(this.ObjContext);
                    objPattern.ID = int.Parse(chkIsCoreRange.Attributes["qid"].ToString());
                    objPattern.GetObject();

                    objPattern.IsCoreRange = chkIsCoreRange.Checked;
                }

                this.ObjContext.SaveChanges();
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while updating pattern other categories", ex);
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            //Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;
            ViewState["ShowSpec"] = false;
            ViewState["ShowPatternOtherCat"] = false;
            ViewState["ShowConfirmPatternCat"] = false;
            Session["PatternOrderBy"] = false;
            Session["totalCount"] = 1;
            Session["LoadedPageNumber"] = 1;
            Session["PatternCount"] = 0;
            Session["PatternDetailsView"] = null;
            // Show Add Pattern
            btnAddPattern.Visible = false;
            if (this.LoggedUserRoleName != GetUserRole(8))
            {
                btnAddPattern.Visible = true;
            }

            //this.RadGridPattern.MasterTableView.GetColumn("SizeSet").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("OriginRef").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("PrinterType").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("SpecialAttributes").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("ConvertionFactor").Display = false;
            this.RadGridPattern.MasterTableView.GetColumn("Remarks").Display = false;

            this.PopulateDataGrid();
        }

        private void PopulateDataGrid()
        {
            ViewState["ShowSpec"] = false;

            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;
            this.btnBack.Visible = false;
            string garmentSpecStatus = string.Empty;
            int blackchrome = 2;
            int patternStatus = 2;
            string searchText = string.Empty;

            List<PatternDetailsView> lstPatternDetailsView = new List<PatternDetailsView>();

            if ((this.txtSearch.Text != string.Empty) && (this.txtSearch.Text != "search"))
            {
                searchText = this.txtSearch.Text.ToLower();
            }

            // Sort by Grament Spec           
            string sortText = this.ddlSortByGarmentSpec.SelectedItem.Text;
            if (sortText != string.Empty && this.ddlSortByGarmentSpec.SelectedIndex != 0)
            {
                garmentSpecStatus = this.ddlSortByGarmentSpec.SelectedItem.Text;
                this.btnBack.Visible = true;
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

            //lstPatternDetailsView = PatternBO.GetPatternDetails(searchText, dgPageSize, pageIndex, int.Parse(SortExpression), this.OrderBy, out totalCount, blackchrome, garmentSpecStatus, patternStatus);

            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Open();
                lstPatternDetailsView = connection.Query<PatternDetailsView>(string.Format(@"EXEC [Indico].[dbo].[SPC_ViewPatternDetails] '{0}','{1}','{2}','{3}'", searchText, blackchrome, garmentSpecStatus, patternStatus)).ToList();
                connection.Close();
            }

            if (lstPatternDetailsView.Count > 0)
            {
                this.RadGridPattern.AllowPaging = (lstPatternDetailsView.Count > this.RadGridPattern.PageSize);
                this.RadGridPattern.DataSource = lstPatternDetailsView;
                this.RadGridPattern.DataBind();

                if (this.LoggedUser.IsDirectSalesPerson)
                {
                    this.RadGridPattern.MasterTableView.Columns.FindByUniqueNameSafe("chkSelect").Visible = false;
                    this.RadGridPattern.MasterTableView.Columns.FindByUniqueNameSafe("Item").Visible = false;
                    this.RadGridPattern.MasterTableView.Columns.FindByUniqueNameSafe("Keywords").Visible = false;
                    this.RadGridPattern.MasterTableView.Columns.FindByUniqueNameSafe("CorePattern").Visible = false;
                    this.RadGridPattern.MasterTableView.Columns.FindByUniqueNameSafe("CoreCategory").Visible = false;
                    this.RadGridPattern.MasterTableView.Columns.FindByUniqueNameSafe("SizeSet").Visible = false;
                    this.RadGridPattern.MasterTableView.Columns.FindByUniqueNameSafe("Post").Visible = false;
                    this.RadGridPattern.MasterTableView.Columns.FindByUniqueNameSafe("Spec").Visible = false;
                    this.RadGridPattern.MasterTableView.Columns.FindByUniqueNameSafe("UserFunctions").Visible = false;
                }

                Session["PatternDetailsView"] = lstPatternDetailsView;
                this.dvDataContent.Visible = (lstPatternDetailsView.Count > 0);
                this.RadGridPattern.Visible = (lstPatternDetailsView.Count > 0);
            }
            else if ((searchText != string.Empty && searchText != "search") || this.ddlSortByGarmentSpec.SelectedItem.Text != string.Empty)
            {
                this.dvDataContent.Visible = true;
                this.RadGridPattern.Visible = (lstPatternDetailsView.Count > 0);
                this.dvNoSearchResult.Visible = true;
                this.btnBack.Visible = true;
            }
            else
            {
                this.dvEmptyContent.Visible = (lstPatternDetailsView.Count == 0);
                this.btnAddPattern.Visible = !(lstPatternDetailsView.Count == 0);
                this.dvDataContent.Visible = (lstPatternDetailsView.Count > 0);
                this.RadGridPattern.Visible = (lstPatternDetailsView.Count > 0);
            }

            if (this.LoggedUserRoleName != GetUserRole(8))
            {
                this.btnAddPattern.Visible = (lstPatternDetailsView.Count > 0);
            }
        }

        private void ProcessGarmentSpec()
        {
            using (TransactionScope ts = new TransactionScope())
            {
                try
                {
                    foreach (RepeaterItem SpecMLitem in this.rptSpecML.Items)
                    {
                        Repeater rptSpecSizeQty = (Repeater)SpecMLitem.FindControl("rptSpecSizeQty");
                        foreach (RepeaterItem SpecSizeQtyitem in rptSpecSizeQty.Items)
                        {
                            Label lblQty = (Label)SpecSizeQtyitem.FindControl("lblQty");

                            int SizeChartId = int.Parse(lblQty.Attributes["qid"]);
                            int MLId = int.Parse(lblQty.Attributes["MLID"]);
                            int SizeId = int.Parse(lblQty.Attributes["SID"]);
                            decimal Size = decimal.Parse((lblQty.Text.Trim() == string.Empty) ? "0.00" : lblQty.Text.Trim());

                            if (int.Parse(this.ddlConvert.SelectedValue) == 1)
                                Size = Math.Round(((decimal)Size * (decimal)0.3937), 2);

                            SizeChartBO objSizeChart = new SizeChartBO(this.ObjContext);

                            if (SizeChartId > 0)
                            {
                                objSizeChart.ID = SizeChartId;
                                objSizeChart.GetObject();
                            }

                            objSizeChart.Pattern = int.Parse(this.hdnSelectedPatternID.Value);
                            objSizeChart.MeasurementLocation = MLId;
                            objSizeChart.Size = SizeId;
                            objSizeChart.Val = Size;

                            this.ObjContext.SaveChanges();
                        }
                    }

                    ts.Complete();
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while saving garment spec values", ex);
                }
            }

            ViewState["ShowSpec"] = false;
        }

        private void GenerateNewGarmentSpec(int patternId)
        {
            string ErrorMsg = string.Empty;
            bool isValid = true;

            PatternBO objPattern = new PatternBO();
            objPattern.ID = patternId;
            objPattern.GetObject();

            if (objPattern.objItem.MeasurementLocationsWhereThisIsItem.Count == 0)
            {
                ErrorMsg = "Measurement Locations could not be found for the item '" + objPattern.objItem.Name + "'<br />";
                isValid = false;
            }
            if (objPattern.objSizeSet.SizesWhereThisIsSizeSet.Count == 0)
            {
                ErrorMsg += "Sizes could not be found for the size set '" + objPattern.objSizeSet.Name + "'<br />";
                isValid = false;
            }

            if (isValid)
            {
                List<SizeChartBO> lstSizeCharts = new List<SizeChartBO>();
                foreach (MeasurementLocationBO ml in objPattern.objItem.MeasurementLocationsWhereThisIsItem)
                {
                    foreach (SizeBO size in objPattern.objSizeSet.SizesWhereThisIsSizeSet)
                    {
                        SizeChartBO objSizeChart = new SizeChartBO();
                        objSizeChart.MeasurementLocation = ml.ID;
                        objSizeChart.Size = size.ID;
                        objSizeChart.Val = 0;

                        lstSizeCharts.Add(objSizeChart);
                    }
                }

                List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = lstSizeCharts.OrderBy(o => o.objMeasurementLocation.Key).GroupBy(o => o.MeasurementLocation).ToList();

                if (lstSizeChartGroup.Count > 0)
                {
                    this.rptSpecSizeQtyHeader.DataSource = (List<SizeChartBO>)lstSizeChartGroup[0].ToList();
                    this.rptSpecSizeQtyHeader.DataBind();

                    this.rptSpecML.DataSource = lstSizeChartGroup;
                    this.rptSpecML.DataBind();

                    this.dvSpecGrdEmpty.Visible = false;
                    this.dvSpecGrd.Visible = true;
                }
                else
                {
                    isValid = false;
                }
            }
            else
            {
                this.paraSpecError.InnerHtml = ErrorMsg;
                this.dvSpecGrdEmpty.Visible = true;
                this.dvSpecGrd.Visible = false;
            }

            // this.btnSaveSpecChanges.Visible = isValid;
        }

        private void PopulatePatternGarmentSpec(int PatternID)
        {
            if (PatternID > 0)
            {
                string TemplateImgLocation = string.Empty;

                PatternBO objPattern = new PatternBO();
                objPattern.ID = PatternID;
                objPattern.GetObject();

                this.lblDescription.Text = objPattern.Number + " " + objPattern.NickName;
                this.lblDate.Text = objPattern.ModifiedDate.ToLongDateString();

                List<PatternTemplateImageBO> lstPatternTemplateImage = (from o in (new PatternTemplateImageBO()).SearchObjects().Where(o => o.Pattern == objPattern.ID &&
                                                                                                                                           o.IsHero == true)
                                                                        select o).ToList();
                if (lstPatternTemplateImage.Count > 0)
                {
                    foreach (PatternTemplateImageBO Image in lstPatternTemplateImage)
                    {
                        TemplateImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + objPattern.ID.ToString() + "/" + Image.Filename + Image.Extension;

                        if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + TemplateImgLocation))
                        {
                            TemplateImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                        }
                    }
                }
                else
                {
                    TemplateImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }

                imgPatternTemplateImage.ImageUrl = TemplateImgLocation;

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

        private void DownloadPdf(int PatternID)
        {
            string convertType = this.ddlConvert.SelectedValue;
            try
            {
                WebServicePattern objWebServicePattern = new WebServicePattern();
                PatternBO objPattern = new PatternBO();
                objPattern.ID = PatternID;
                objPattern.GetObject();

                string filePath = objWebServicePattern.GeneratePDF(objPattern, false, convertType);

                //FileInfo fileInfo = new FileInfo(filePath);
                //string outputName = System.Text.RegularExpressions.Regex.Replace(fileInfo.Name, @"\W+", "_");
                //outputName = System.Text.RegularExpressions.Regex.Replace(outputName, "_pdf", ".pdf");
                //Response.ClearContent();
                //Response.ClearHeaders();
                //Response.AddHeader("Content-Type", "application/pdf");
                //Response.AddHeader("Content-Disposition", string.Format("attachment; filename = {0}", outputName));
                //Response.AddHeader("Content-Length", (fileInfo.Length).ToString("F0"));
                //Response.TransmitFile(filePath);
                //Response.Flush();
                //Response.Close();
                //Response.BufferOutput = true;
                //// Response.End();

                this.DownloadPDFFile(filePath);

            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while downloading pdf in viewpattern", ex);
            }
        }

        private void ReBindGrid()
        {
            if (Session["PatternDetailsView"] != null)
            {
                RadGridPattern.DataSource = (List<PatternDetailsView>)Session["PatternDetailsView"];
                RadGridPattern.DataBind();
            }
        }

        #endregion

        #region inner class

        private class PatternDetailsView
        {
            public int Pattern { get; set; }
            public string Item { get; set; }
            public string SubItem { get; set; }
            public string Gender { get; set; }
            public string AgeGroup { get; set; }
            public string SizeSet { get; set; }
            public string CoreCategory { get; set; }
            public string PrinterType { get; set; }
            public string Number { get; set; }
            public string OriginRef { get; set; }
            public string NickName { get; set; }
            public string Keywords { get; set; }
            public string CorePattern { get; set; }
            public string FactoryDescription { get; set; }
            public string Consumption { get; set; }
            public decimal ConvertionFactor { get; set; }
            public string SpecialAttributes { get; set; }
            public string PatternNotes { get; set; }
            public string PriceRemarks { get; set; }
            public bool IsActive { get; set; }
            public int Creator { get; set; }
            public DateTime CreatedDate { get; set; }
            public int Modifier { get; set; }
            public DateTime ModifiedDate { get; set; }
            public string Remarks { get; set; }
            public string IsTemplate { get; set; }
            public string Parent { get; set; }
            public string GarmentSpecStatus { get; set; }
            public bool IsActiveWS { get; set; }
            public bool IsCoreRange { get; set; }
            public string HTSCode { get; set; }
            public decimal SMV { get; set; }
            public string MarketingDescription { get; set; }
            public bool CanDelete { get; set; }

            public int PatternDevelopmentID { get; set; }
        }

        #endregion

        private string GetPatternCompressionImagePath(int id)
        {
            var dataFolderPath = "/" + IndicoConfiguration.AppConfiguration.DataFolderName;
            var imagePath = "";

            if (id <= 0)
                return imagePath;
            var objPattern = new PatternBO { ID = id };
            objPattern.GetObject();

            if ((objPattern.PatternCompressionImage ?? 0) <= 0)
                return imagePath;
            var fileName = objPattern.objPatternCompressionImage.Filename;
            var extension = objPattern.objPatternCompressionImage.Extension;
            var physicalFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\PatternCompressionImages\\" + id + "\\";
            if (File.Exists(physicalFolderPath + fileName + extension))
            {
                imagePath = dataFolderPath + "/PatternCompressionImages/" + id + "/" + fileName + extension;
            }
            return imagePath;
        }

    }


}