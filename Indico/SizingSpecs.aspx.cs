using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml;
using System.Xml.Linq;

using Indico.BusinessObjects;
using Indico.Common;
using System.Collections.Specialized;

namespace Indico
{
    public partial class SizingSpecs : System.Web.UI.Page
    {
        #region Fields

        private int pageindex = 0;
        private int PageSize = 16;
        private List<PatternBO> p_source;
        private List<PatternBO> pc_source;
        private string urlCategory = string.Empty;
        private string urlSearchText = string.Empty;
        private int urlMainCategory = -1;
        private string loadedMenuItem = string.Empty;

        #endregion

        #region Properties

        private string SortBy
        {
            get
            {
                return (Session["SortBy"] != null) ? Session["SortBy"].ToString() : "Number";
            }
            set
            {
                Session["SortBy"] = value;
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

        protected int PageNumber
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
                    if (Session["PageCount"] != null)
                        c = Convert.ToInt32(Session["PageCount"]);
                }
                catch (Exception)
                {
                    Session["PageCount"] = c;
                }
                Session["PageCount"] = c;
                return c;
            }
            set
            {
                Session["PageCount"] = value;
            }
        }

        private List<PatternBO> Source
        {
            get
            {
                if (p_source == null)
                {
                    if (Session["Source"] == null || Session["Source"].GetType() != typeof(List<PatternBO>))
                        return null;

                    List<PatternBO> dv = ((List<PatternBO>)Session["Source"]);

                    p_source = dv;
                }

                return p_source;
            }
            set
            {
                p_source = value;
                if (value != null)
                {
                    Session["Source"] = ((List<PatternBO>)value); ;
                }
                else
                {
                    Session["Source"] = null;
                }
            }
        }

        private List<PatternBO> PatternCategorySource
        {
            get
            {
                List<PatternBO> list;

                if (Session["PatternCategorySource"] == null || Session["PatternCategorySource"].GetType() != typeof(List<PatternBO>))
                {
                    PatternBO objPattern = new PatternBO();
                    objPattern.IsActiveWS = true;
                    list = objPattern.SearchObjects();
                    Session["PatternCategorySource"] = list;
                }
                else
                {
                    list = (List<PatternBO>)(Session["PatternCategorySource"]);
                }
                return list;
            }
        }

        private List<CategoryBO> CategorySource
        {
            get
            {
                List<CategoryBO> list;

                if (Session["CategorySource"] == null || Session["CategorySource"].GetType() != typeof(List<CategoryBO>))
                {
                    list = new CategoryBO().SearchObjects();
                    Session["CategorySource"] = list;
                }
                else
                {
                    list = (List<CategoryBO>)(Session["CategorySource"]);
                }
                return list;
            }
        }

        protected string QueryCategory
        {
            get
            {
                if (urlCategory != string.Empty)
                    return urlCategory;

                if (HttpContext.Current.Request.QueryString["cat"] != null)
                {
                    urlCategory = HttpContext.Current.Request.QueryString["cat"].ToString();
                }
                return urlCategory;
            }
        }

        protected string QuerySearchText
        {
            get
            {
                if (urlSearchText != string.Empty)
                    return urlSearchText;

                if (HttpContext.Current.Request.QueryString["search"] != null)
                {
                    urlSearchText = HttpContext.Current.Request.QueryString["search"].ToString();
                }
                return urlSearchText;
            }
        }

        protected int QueryMainCategory
        {
            get
            {
                if (urlMainCategory > -1)
                    return urlMainCategory;

                urlMainCategory = 0;
                if (Request.QueryString["maincat"] != null)
                {
                    urlMainCategory = Convert.ToInt32(Request.QueryString["maincat"].ToString());
                }
                return urlMainCategory;
            }
        }

        #endregion

        #region Events

        protected void Page_Load(object sender, EventArgs e)
        {
#if !(DEBUG)
            if (Request.Browser.Id.ToLower().Contains("mozilla"))
            {
                this.litPostBackScript.Text = Environment.NewLine +
                "<div class=\"aspNetHidden\"> " + Environment.NewLine +
                    "<input type=\"hidden\" name=\"__EVENTTARGET\" id=\"__EVENTTARGET\" value=\"\" />" + Environment.NewLine +
                    "<input type=\"hidden\" name=\"__EVENTARGUMENT\" id=\"__EVENTARGUMENT\" value=\"\" />" + Environment.NewLine +
                "</div> " + Environment.NewLine +
                "<script type=\"text/javascript\">" + Environment.NewLine +
                "//<![CDATA[" + Environment.NewLine +
                    "var theForm = document.forms['frmMain'];" + Environment.NewLine +
                    "if (!theForm) {" + Environment.NewLine +
                        "theForm = document.frmMain;" + Environment.NewLine +
                    "}" + Environment.NewLine +
                    "function __doPostBack(eventTarget, eventArgument) {" + Environment.NewLine +
                        "if (!theForm.onsubmit || (theForm.onsubmit() != false)) {" + Environment.NewLine +
                            "theForm.__EVENTTARGET.value = eventTarget;" + Environment.NewLine +
                            "theForm.__EVENTARGUMENT.value = eventArgument;" + Environment.NewLine +
                            "theForm.submit();" + Environment.NewLine +
                        "}" + Environment.NewLine +
                    "}" + Environment.NewLine +
                    "//]]>" + Environment.NewLine +
                "</script>";
            }
            else
            {
                this.litPostBackScript.Text = string.Empty;
            }
#endif
            if (!Page.IsPostBack)
            {
                this.PopulateControls();
            }

            Response.AddHeader("p3p", "CP=\"IDC DSP COR ADM DEVi TATi PSA PSD IVAi IVDi CONi HIS OUR IND CNT\"");
        }

        #region repeater paging

        protected void lbHeaderPrevious_Click(object sender, EventArgs e)
        {
            LinkButton lk = new LinkButton();
            lk.ID = "lbHeader" + (--this.PageNumber).ToString();
            lk.Text = (this.PageNumber).ToString();
            this.lbHeader1_Click(lk, e);
        }

        protected void lbHeaderNext_Click(object sender, EventArgs e)
        {
            LinkButton lk = new LinkButton();
            lk.ID = "lbHeader" + (++this.PageNumber).ToString();
            lk.Text = (this.PageNumber).ToString();
            this.lbHeader1_Click(lk, e);
        }

        protected void lbHeaderNextDots_Click(object sender, EventArgs e)
        {
            LinkButton lk = new LinkButton();
            //lk.ID = "lbHeader" + ((ActivitiesTotal % 10 == 0) ? (ActivitiesTotal / 10) : (ActivitiesTotal / 10) + 1).ToString();
            //lk.Text = ((ActivitiesTotal % 10 == 0) ? (ActivitiesTotal / 10) : (ActivitiesTotal / 10) + 1).ToString();

            int nextSet = (PageNumber % 10 == 0) ? (PageNumber + 1) : ((this.PageNumber / 10) * 10) + 11;
            lk.ID = "lbHeader" + nextSet.ToString();
            lk.Text = nextSet.ToString();
            this.lbHeader1_Click(lk, e);

            //((ActivitiesTotal % 10 == 0) ? (ActivitiesTotal / 10) : (ActivitiesTotal / 10) + 1)
        }

        protected void lbHeaderPreviousDots_Click(object sender, EventArgs e)
        {
            LinkButton lk = new LinkButton();
            //lk.ID = "lbHeader" + (1).ToString();
            //lk.Text = (1).ToString();
            int previousSet = (PageNumber % 10 == 0) ? (PageNumber - 19) : (((this.PageNumber / 10) * 10) - 9);
            lk.ID = "lbHeader" + previousSet.ToString();
            lk.Text = previousSet.ToString();
            this.lbHeader1_Click(lk, e);
        }

        protected void lbHeader1_Click(object sender, EventArgs e)
        {
            //rfvDistributor.Enabled = false;
            //rfvLabelName.Enabled = false;
            //cvLabel.Enabled = false;

            string clickedPageText = ((LinkButton)sender).Text;
            int clickedPageNumber = Convert.ToInt32(clickedPageText);
            Session["LoadedPageNumber"] = clickedPageNumber;
            int currentPage = 1;

            this.ClearCss();

            if (clickedPageNumber > 10)
                currentPage = (clickedPageNumber % 10) == 0 ? 10 : clickedPageNumber % 10;
            else
                currentPage = clickedPageNumber;

            this.HighLightPageNumber(currentPage);

            this.lbFooterNext.Visible = true;
            this.lbFooterPrevious.Visible = true;

            if (clickedPageNumber == ((TotalCount % PageSize == 0) ? TotalCount / PageSize : Math.Floor((double)(TotalCount / PageSize)) + 1))
                this.lbFooterNext.Visible = false;
            if (clickedPageNumber == 1)
                this.lbFooterPrevious.Visible = false;

            //int startIndex = clickedPageNumber * 10 - 10;
            this.pageIndex = clickedPageNumber;
            this.PopulateDataGrid();

            if (clickedPageNumber % 10 == 1)
                this.ProcessNumbering(clickedPageNumber, ClientPageCount);
            else
            {
                if (clickedPageNumber > 10)
                {
                    if (clickedPageNumber % 10 == 0)
                        this.ProcessNumbering(clickedPageNumber - 9, ClientPageCount);
                    else
                        this.ProcessNumbering(((clickedPageNumber / 10) * 10) + 1, ClientPageCount);
                }
                else
                {
                    this.ProcessNumbering((clickedPageNumber / 10 == 0) ? 1 : clickedPageNumber / 10, ClientPageCount);
                }
            }
        }

        #endregion

        protected void rptGarmentSpecs_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemType == ListItemType.Item || item.ItemType == ListItemType.AlternatingItem)
            {
                PatternBO objItem = (PatternBO)(item.DataItem);

                HtmlAnchor linkPattern = (HtmlAnchor)(item.FindControl("linkPattern"));

                //#if DEBUG
                //                linkPattern.HRef = "javascript:void(parent.window.location.href='http://www.bmizzle.com.au/sizing-spec-details/?" +
                //                                   objItem.Number.ToString() + "');";
                //#else
                //                linkPattern.HRef = "javascript:void(parent.window.location.href='http://www.blackchrome.com.au/our-products/garment-sizing-specification-details/?" +
                //                                   objItem.Number.ToString() + "');";                
                //#endif

#if DEBUG
                linkPattern.HRef = "javascript:void(window.open('http://local-indico.com/SizingSpecDetails.aspx?id=" + objItem.Number.ToString() + "','_blank'))";
#else
                linkPattern.HRef = "javascript:void(window.open('http://gw.indiman.net/SizingSpecDetails.aspx?id=" + objItem.Number.ToString() + "','_blank'))";
#endif

                string imgLocation = string.Empty;
                PatternTemplateImageBO objPatternTemplateImage = new PatternTemplateImageBO();
                objPatternTemplateImage.Pattern = objItem.ID;

                List<PatternTemplateImageBO> lstPTImages = objPatternTemplateImage.SearchObjects().Where(m => m.ImageOrder == 1).ToList();

                if (lstPTImages.Any())
                {
                    objPatternTemplateImage = lstPTImages.First();

                    if (objPatternTemplateImage != null)
                    {
                        imgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + objItem.ID.ToString() + "/" + objPatternTemplateImage.Filename + objPatternTemplateImage.Extension;
                        if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + imgLocation))
                        {
                            imgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                        }
                    }
                }
                else
                {
                    imgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }

                Image imgItem = (Image)(item.FindControl("imgItem"));
                imgItem.ImageUrl = imgLocation;

                HtmlGenericControl lblDescription = (HtmlGenericControl)(item.FindControl("lblDescription"));
                lblDescription.InnerText = objItem.Number + " - " + objItem.NickName;
                //lblDescription.InnerText = objItem.Remarks;

                HtmlGenericControl lblAgeGroupGender = (HtmlGenericControl)(item.FindControl("lblAgeGroupGender"));
                HtmlGenericControl lblSizeSet = (HtmlGenericControl)(item.FindControl("lblSizeSet"));

                string sizes = string.Empty;
                List<SizeBO> lstSizes = objItem.objSizeSet.SizesWhereThisIsSizeSet.Where(o => o.IsDefault == true).ToList();
                if (lstSizes.Any())
                {
                    sizes = (lstSizes.Count > 1) ? lstSizes.First().SizeName + " - " + lstSizes.Last().SizeName : lstSizes.First().SizeName;
                }

                lblAgeGroupGender.InnerText = objItem.objGender.Name + ((objItem.AgeGroup.HasValue && objItem.AgeGroup > 0) ? " - " + objItem.objAgeGroup.Name : "");
                lblSizeSet.InnerText = sizes;
            }
        }

        /*protected void rptGarmentSpecs_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            LinkButton lbPattern = (LinkButton)e.Item.FindControl("lbPattern");
            int id = (lbPattern.Attributes["pattern"] != null) ? int.Parse(lbPattern.Attributes["pattern"].ToString()) : 0;
            if (id > 0)
            {
                Response.Redirect("http://www.blackchrome.com.au/sizing-spec-details/?" + id.ToString());
            }
        }*/

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string searchUrl = (!string.IsNullOrEmpty(this.txtSearch.Value)) ? ("?search=" + this.txtSearch.Value) : "";
            Response.Redirect("SizingSpecs.aspx" + searchUrl);

            //this.Source = null;
            //this.PopulateDataGrid();
        }

        protected void btnSortBy_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)(sender);
            this.SortBy = btn.CommandName; //  "Number", "Newest", "Popular",  "Rating"           
            PopulateDataGrid();
        }

        protected void rptMenuItem_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemType == ListItemType.Item || item.ItemType == ListItemType.AlternatingItem)
            {
                KeyValuePair<string, string> menuItem = (KeyValuePair<string, string>)(item.DataItem);
                HyperLink ancMenu = (HyperLink)(item.FindControl("ancMenu"));
                Literal lblMenu = (Literal)(item.FindControl("lblMenu"));
                Repeater rptCategory = (Repeater)(item.FindControl("rptCategory"));

                ancMenu.Text = menuItem.Key;
                lblMenu.Text = menuItem.Value.ToUpper();
                ancMenu.NavigateUrl = "sizingspecs.aspx?cat=" + menuItem.Key;
                loadedMenuItem = menuItem.Key;
                rptCategory.DataSource = PopulateCategories(menuItem.Key);
                rptCategory.DataBind();
            }
        }

        protected void rptCategory_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemType == ListItemType.Item || item.ItemType == ListItemType.AlternatingItem)
            {
                KeyValuePair<int, string> categoryItem = (KeyValuePair<int, string>)(item.DataItem);
                HyperLink ancCategory = (HyperLink)(item.FindControl("ancCategory"));

                ancCategory.Text = categoryItem.Value;
                ancCategory.NavigateUrl = "sizingspecs.aspx?cat=" + loadedMenuItem + "&&maincat=" + categoryItem.Key;
            }
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            Session["PageCount"] = 0;
            Session["LoadedPageNumber"] = 1;
            Session["totalCount"] = 1;
            Session["OrderBy"] = false;
            Session["PatternView"] = null;
            Session["Source"] = null;

            PopulateMenuItems();
            PopulateDataGrid();
        }

        private void ProcessNumbering(int start, int count)
        {
            this.lbFooterPreviousDots.Visible = true;
            this.lbFooterNextDots.Visible = true;

            int i = start;
            // 1
            if (i <= count)
            {
                this.lbFooter1.Visible = true;
                this.lbFooter1.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter1.Visible = false;
            }
            // 2
            if (++i <= count)
            {
                this.lbFooter2.Visible = true;
                this.lbFooter2.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter2.Visible = false;
            }
            // 3
            if (++i <= count)
            {
                this.lbFooter3.Visible = true;
                this.lbFooter3.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter3.Visible = false;
            }
            // 4
            if (++i <= count)
            {
                this.lbFooter4.Visible = true;
                this.lbFooter4.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter4.Visible = false;
            }
            // 5
            if (++i <= count)
            {
                this.lbFooter5.Visible = true;
                this.lbFooter5.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter5.Visible = false;
            }
            // 6
            if (++i <= count)
            {
                this.lbFooter6.Visible = true;
                this.lbFooter6.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter6.Visible = false;
            }
            // 7
            if (++i <= count)
            {
                this.lbFooter7.Visible = true;
                this.lbFooter7.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter7.Visible = false;
            }
            // 8
            if (++i <= count)
            {
                this.lbFooter8.Visible = true;
                this.lbFooter8.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter8.Visible = false;
            }
            // 9
            if (++i <= count)
            {
                this.lbFooter9.Visible = true;
                this.lbFooter9.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter9.Visible = false;
            }
            // 10
            if (++i <= count)
            {
                this.lbFooter10.Visible = true;
                this.lbFooter10.Text = (start++).ToString();
            }
            else
            {
                this.lbFooter10.Visible = false;
            }

            int loadedPageTemp = (PageNumber % 10 == 0) ? ((PageNumber - 1) / 10) : (PageNumber / 10);

            if (TotalCount <= 10 * PageSize)
            {
                this.lbFooterPreviousDots.Visible = false;
                this.lbFooterNextDots.Visible = false;
            }

            else if (TotalCount - ((loadedPageTemp) * 10 * PageSize) <= 10 * PageSize)
            {
                this.lbFooterNextDots.Visible = false;
            }
            else
            {
                this.lbFooterPreviousDots.Visible = (this.lbFooter1.Text == "1") ? false : true;
            }

            //repeat settings for header
            lbHeaderPrevious.Visible = lbFooterPrevious.Visible;
            lbHeaderPreviousDots.Visible = lbFooterPreviousDots.Visible;
            lbHeader1.Visible = lbFooter1.Visible;
            lbHeader2.Visible = lbFooter2.Visible;
            lbHeader3.Visible = lbFooter3.Visible;
            lbHeader4.Visible = lbFooter4.Visible;
            lbHeader5.Visible = lbFooter5.Visible;
            lbHeader6.Visible = lbFooter6.Visible;
            lbHeader7.Visible = lbFooter7.Visible;
            lbHeader8.Visible = lbFooter8.Visible;
            lbHeader9.Visible = lbFooter9.Visible;
            lbHeader10.Visible = lbFooter10.Visible;
            lbHeaderNextDots.Visible = lbFooterNextDots.Visible;
            lbHeaderNext.Visible = lbFooterNext.Visible;

            lbHeader1.Text = lbFooter1.Text;
            lbHeader2.Text = lbFooter2.Text;
            lbHeader3.Text = lbFooter3.Text;
            lbHeader4.Text = lbFooter4.Text;
            lbHeader5.Text = lbFooter5.Text;
            lbHeader6.Text = lbFooter6.Text;
            lbHeader7.Text = lbFooter7.Text;
            lbHeader8.Text = lbFooter8.Text;
            lbHeader9.Text = lbFooter9.Text;
            lbHeader10.Text = lbFooter10.Text;
        }

        private void HighLightPageNumber(int clickedPageNumber)
        {
            for (int i = 1; i <= 10; i++)
            {
                LinkButton lkTop = (LinkButton)this.FindControl("lbHeader" + i.ToString());
                LinkButton lkBottom = (LinkButton)this.FindControl("lbFooter" + i.ToString());
                lkTop.CssClass = lkBottom.CssClass = string.Empty;
            }

            LinkButton lbHeader = (LinkButton)this.FindControl("lbHeader" + clickedPageNumber.ToString());
            LinkButton lbFooter = (LinkButton)this.FindControl("lbFooter" + clickedPageNumber.ToString());

            if (lbHeader != null)
                lbHeader.CssClass = "active";

            if (lbFooter != null)
                lbFooter.CssClass = "active";
        }

        private void ClearCss()
        {
            for (int i = 1; i <= 10; i++)
            {
                //LinkButton lbFooter = (LinkButton)this.FindControlRecursive(this, "lbFooter" + i.ToString());
                //lbFooter.CssClass = "paginatorLink";
            }
        }

        private void PopulateDataGrid()
        {
            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            // Search text
            this.txtSearch.Value = this.QuerySearchText;
            string searchText = this.txtSearch.Value.ToLower().Trim();

            // Populate GSpecs

            int totalCount = 0;

            List<PatternBO> lstPattern = new List<PatternBO>();
            if (Source != null)
            {
                lstPattern = Source;
            }
            else
            {
                PatternBO objPattern = new PatternBO();
                objPattern.IsActiveWS = true;
                objPattern.IsActive = true;

                if (this.QueryMainCategory > 0)
                {
                    objPattern.CoreCategory = QueryMainCategory;
                }

                switch (this.QueryCategory.ToLower())
                {
                    case "mens":
                        objPattern.Gender = 1;
                        objPattern.AgeGroup = 1;
                        lstPattern = objPattern.SearchObjects().ToList();
                        break;
                    case "ladies":
                        objPattern.Gender = 2;
                        objPattern.AgeGroup = 1;
                        lstPattern = objPattern.SearchObjects().ToList();
                        break;
                    case "unisex":
                        objPattern.Gender = 3;
                        lstPattern = objPattern.SearchObjects().ToList();
                        break;
                    case "youth":
                        objPattern.AgeGroup = 2;
                        lstPattern = objPattern.SearchObjects().ToList();
                        break;
                    case "other":
                        lstPattern = objPattern.SearchObjects().Where(m => m.Gender > 3 || m.AgeGroup > 2).ToList();
                        break;
                    default:
                        lstPattern = objPattern.SearchObjects().ToList();
                        break;
                }

                if (!string.IsNullOrEmpty(searchText))
                {
                    lstPattern = lstPattern.Where(m => (m.NickName.ToLower() + " " + m.Number.ToLower() + " " + m.objCoreCategory.Name.ToLower() + " " + (string.IsNullOrEmpty(m.Keywords) ? "" : m.Keywords.ToLower())).Contains(searchText)).ToList();
                }
                Source = lstPattern;
            }

            switch (this.SortBy)
            {
                case "Number":
                    lstPattern = lstPattern.OrderBy(m => m.Number).ToList();
                    break;
                case "Newest":
                    lstPattern = lstPattern.OrderByDescending(m => m.ModifiedDate).ToList();
                    break;
                case "CoreRange":
                    lstPattern = lstPattern.OrderByDescending(m => m.IsCoreRange).ToList();
                    break;
                //case "Popular":
                //    lstPattern = lstPattern.OrderBy(m => m.MostPopular ?? 0).ToList();
                //    break;
                //case "Rating":
                //    lstPattern = lstPattern.OrderBy(m => m.Ratings ?? 0).ToList();
                //    break;
                default:
                    lstPattern = lstPattern.OrderByDescending(m => m.IsCoreRange).ToList();
                    break;
            }

            totalCount = lstPattern.Count;
            int offSet = 0;
            if (lstPattern.Count > 0)
            {
                if (lstPattern.Count < (this.PageSize * 10))
                {
                    offSet = (this.Source.Count > this.PageSize) ? this.PageSize : this.Source.Count;
                }
                else
                {
                    offSet = ((this.Source.Count - ((this.PageNumber - 1) * this.PageSize)) > this.PageSize) ? this.PageSize : (this.Source.Count - ((this.PageNumber - 1) * this.PageSize));
                }

                int recordsLeft = totalCount - (offSet * (this.PageNumber - 1));
                int nextFetchCount = (this.PageSize > recordsLeft) ? recordsLeft : this.PageSize;

                lstPattern = lstPattern.GetRange(offSet * (this.PageNumber - 1), nextFetchCount);
                this.rptGarmentSpecs.DataSource = lstPattern;
                this.rptGarmentSpecs.DataBind();

                Session["PatternView"] = lstPattern;

                TotalCount = (totalCount == 0) ? TotalCount : totalCount;

                Session["PageCount"] = (TotalCount % PageSize == 0) ? (TotalCount / PageSize) : ((TotalCount / PageSize) + 1);

                this.dvPagingFooter.Visible = this.dvPagingHeader.Visible = (TotalCount > PageSize);
                this.lbFooterPrevious.Visible = (pageIndex != 1 && pageIndex != 90);
                this.ProcessNumbering(1, Convert.ToInt32(Session["PageCount"]));
                this.SetDisplayCount();
                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search"))
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;

                this.dvPagingFooter.Visible = this.dvPagingHeader.Visible = false;
            }
            else
            {
                this.dvEmptyContent.Visible = true;
                this.dvPagingFooter.Visible = this.dvPagingHeader.Visible = false;
            }

            this.rptGarmentSpecs.Visible = (lstPattern.Count > 0);
        }

        private void SetDisplayCount()
        {
            if (this.TotalCount > 0)
            {
                int iFrom = ((this.PageNumber - 1) * this.PageSize) + 1;
                int iTo = ((this.PageNumber - 1) * this.PageSize) + this.PageSize;

                if (iTo > this.TotalCount)
                    iTo = this.TotalCount;

                string category = string.Empty;
                string subCategory = string.Empty;
                string searchText = string.IsNullOrEmpty(this.QuerySearchText) ? "" : "'" + this.QuerySearchText + "'";

                if (!string.IsNullOrEmpty(this.QueryCategory))
                {
                    category = string.IsNullOrEmpty(this.QueryCategory) ? "" : " '" + this.QueryCategory;
                    subCategory = (QueryMainCategory > 0) ? (" - " + this.CategorySource.Where(m => m.ID == QueryMainCategory).SingleOrDefault().Name + "'") : "'";
                }
                this.litDisplayMessage.Text = "<label>Displaying " + searchText + category + subCategory + " <b>" + iFrom.ToString() + "</b> " + (((this.TotalCount - iFrom) == 0) ? (" out of") : (" to <b>" + iTo.ToString() + "</b> of ")) + " <b>" + this.TotalCount.ToString() + "</b></label>";
                this.litDisplayMessage.Visible = true;
            }
            else
            {
                this.litDisplayMessage.Visible = false;
            }
        }

        private void PopulateMenuItems()
        {
            List<KeyValuePair<string, string>> lstMenuItems = new List<KeyValuePair<string, string>>();
            lstMenuItems.Add(new KeyValuePair<string, string>("Mens", "Mens All"));
            lstMenuItems.Add(new KeyValuePair<string, string>("Ladies", "Ladies All"));
            lstMenuItems.Add(new KeyValuePair<string, string>("Unisex", "Unisex All"));
            lstMenuItems.Add(new KeyValuePair<string, string>("Youth", "Youth All"));
            lstMenuItems.Add(new KeyValuePair<string, string>("Other", "Other"));

            this.rptMenuItem.DataSource = lstMenuItems;
            this.rptMenuItem.DataBind();
        }

        private List<KeyValuePair<int, string>> PopulateCategories(string MenuItem)
        {
            List<KeyValuePair<int, string>> lstCategoryItems = new List<KeyValuePair<int, string>>();
            PatternBO objPattern = new PatternBO();
            objPattern.IsActiveWS = true;
            List<int> lstCategoryIDs = new List<int>();

            //1	MENS
            //2	LADIES
            //3	UNISEX
            //4	N/A
            //5	&nbsp;

            //1	ADULT	
            //2	YOUTH	NULL
            //3	INFANTS	NULL
            //4	N/A	NULL
            //5	FULL RANGE	NULL
            //7	BESPOKE	

            switch (MenuItem)
            {
                case "Mens":
                    lstCategoryIDs = PatternCategorySource.Where(m => m.Gender == 1 && m.AgeGroup == 1).Select(m => m.CoreCategory).Distinct().ToList();
                    break;
                case "Ladies":
                    lstCategoryIDs = PatternCategorySource.Where(m => m.Gender == 2 && m.AgeGroup == 1).Select(m => m.CoreCategory).Distinct().ToList();
                    break;
                case "Unisex":
                    lstCategoryIDs = PatternCategorySource.Where(m => m.Gender == 3).Select(m => m.CoreCategory).Distinct().ToList();
                    break;
                case "Youth":
                    lstCategoryIDs = PatternCategorySource.Where(m => m.AgeGroup == 2).Select(m => m.CoreCategory).Distinct().ToList();
                    break;
                case "Other":
                    lstCategoryIDs = PatternCategorySource.Where(m => m.Gender > 3 || m.AgeGroup > 2).Select(m => m.CoreCategory).Distinct().ToList();
                    break;
                default:
                    break;
            }

            foreach (int CatID in lstCategoryIDs)
            {
                CategoryBO objCat = this.CategorySource.Where(m => m.ID == CatID).SingleOrDefault();
                lstCategoryItems.Add(new KeyValuePair<int, string>(CatID, objCat.Name));
            }

            return lstCategoryItems.OrderBy(m => m.Value).ToList();
        }

        #endregion
    }
}