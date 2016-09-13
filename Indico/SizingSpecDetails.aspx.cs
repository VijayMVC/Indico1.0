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

namespace Indico
{
    public partial class SizingSpecDetails : System.Web.UI.Page
    {
        #region Fields

        private string urlQueryNumber = string.Empty;

        #endregion

        #region Properties

        protected string QueryNumber
        {
            get
            {
                if (string.IsNullOrEmpty(urlQueryNumber) && (HttpContext.Current.Request.QueryString["id"] != null))
                {
                    urlQueryNumber = HttpContext.Current.Request.QueryString["id"].ToString().ToLower();
                }
                return urlQueryNumber;
            }
        }

        protected string CompressionImagePhysicalPath
        {
            get
            {
                string path = (string)Session["CompressionImagePhysicalPath"];

                return path;
            }
            set
            {
                Session["CompressionImagePhysicalPath"] = value;
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

            if (!Page.IsPostBack && !string.IsNullOrEmpty(this.QueryNumber))
            {
                this.PopulateControls();
            }
            Response.AddHeader("p3p", "CP=\"IDC DSP COR ADM DEVi TATi PSA PSD IVAi IVDi CONi HIS OUR IND CNT\"");
        }

        protected void btnStarRating_Click(object sender, EventArgs e)
        {

        }

        protected void lbDownload_Click(object sender, EventArgs e)
        {
            try
            {
                WebServicePattern objWebServicePattern = new WebServicePattern();
                PatternBO objPattern = new PatternBO();
                objPattern.Number = this.QueryNumber;
                objPattern.IsActiveWS = true;
                objPattern.IsActive = true;
                objPattern = objPattern.SearchObjects().SingleOrDefault();

                string filePath = objWebServicePattern.GeneratePDF(objPattern, false, this.hdnType.Value, this.CompressionImagePhysicalPath);
                this.DownloadPDFFile(filePath, objPattern.Number);
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while downloading pdf in Sizingspecs.aspx", ex);
            }
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            if (string.IsNullOrEmpty(this.QueryNumber))
            {
                //#if DEBUG
                //                Response.Redirect("http://www.bmizzle.com.au/sizing-specs/");
                //#else
                //                Response.Redirect("http://www.blackchrome.com.au/garment-sizing-specifications/");
                //#endif
                Response.Redirect("http://www.blackchrome.com.au/");
            }
            else
            {
                PatternBO objPattern = new PatternBO();
                objPattern.IsActiveWS = true;
                objPattern.IsActive = true;
                objPattern.Number = this.QueryNumber;
                objPattern = objPattern.SearchObjects().SingleOrDefault();

                if (objPattern != null && objPattern.Creator > 0)
                {
                    WebServicePattern obj = new WebServicePattern();

                    if ((objPattern.PatternCompressionImage ?? 0) > 0)
                    {
                        this.imgSpec.ImageUrl = PopulatePatternCompressionImage(objPattern);
                        this.imgSpec.Visible = true;
                    }
                    else
                    {
                        this.litSpecBody.Text = obj.CreateHtml(objPattern, "0", true);
                        this.litSpecBody.Visible = this.dvUnits.Visible = true;
                    }

                    //Populate Images
                    PatternTemplateImageBO objOtherImage = new PatternTemplateImageBO();
                    objOtherImage.Pattern = objPattern.ID;
                    List<PatternTemplateImageBO> lstOtherImages = objOtherImage.SearchObjects();

                    List<PatternTemplateImageBO> lstOtherImages1 = lstOtherImages.Where(o => o.ImageOrder == 1).ToList();
                    List<PatternTemplateImageBO> lstOtherImages2 = lstOtherImages.Where(o => o.ImageOrder == 2).ToList();
                    List<PatternTemplateImageBO> lstOtherImages3 = lstOtherImages.Where(o => o.ImageOrder == 3).ToList();

                    this.imgOther1.Src = this.TemplateImagePath(lstOtherImages1);
                    this.lnkImage1.Attributes.Add("data-image", "../" + this.imgOther1.Src);
                    this.lnkImage1.Attributes.Add("data-zoom-image", "../" + this.imgOther1.Src);
                    this.lnkImage1.Visible = !string.IsNullOrEmpty(this.imgOther1.Src);

                    this.imgOther2.Src = TemplateImagePath(lstOtherImages2);
                    this.lnkImage2.Attributes.Add("data-image", "../" + this.imgOther2.Src);
                    this.lnkImage2.Attributes.Add("data-zoom-image", "../" + this.imgOther2.Src);
                    this.lnkImage2.Visible = !string.IsNullOrEmpty(this.imgOther2.Src);

                    this.imgOther3.Src = TemplateImagePath(lstOtherImages3);
                    this.lnkImage3.Attributes.Add("data-image", "../" + this.imgOther3.Src);
                    this.lnkImage3.Attributes.Add("data-zoom-image", "../" + this.imgOther3.Src);
                    this.lnkImage3.Visible = !string.IsNullOrEmpty(this.imgOther3.Src);

                    //PatternTemplateImageBO objGamentSpec = new PatternTemplateImageBO();
                    //if (lstOtherImages.Where(o => o.IsHero).Any())
                    //{
                    //    objGamentSpec = lstOtherImages.Where(o => o.IsHero).Last();
                    this.imgGamentSpec.Src = TemplateImagePath(lstOtherImages.Where(o => o.IsHero).ToList(), true);
                    // }

                    this.lblNumber.InnerText = objPattern.Number;
                    this.lblRemarks.InnerText = objPattern.Remarks;
                    this.lblGender.InnerText = objPattern.objGender.Name;
                    this.lblDescription.InnerText = objPattern.Description;

                    this.imgHero.Src = (this.lnkImage3.Visible) ? this.imgOther3.Src :
                        (this.lnkImage1.Visible) ? this.imgOther1.Src : IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }
                else
                {
                    //#if DEBUG
                    //                    Response.Redirect("http://www.bmizzle.com.au/sizing-specs/");
                    //#else
                    //                    Response.Redirect("http://www.blackchrome.com.au/garment-sizing-specifications/");
                    //#endif
                    Response.Redirect("http://www.blackchrome.com.au/");
                }
            }
        }

        private string TemplateImagePath(List<PatternTemplateImageBO> lstOtherImages, bool isHero = false)
        {
            string imageFilePath = string.Empty;

            if (lstOtherImages.Any() && lstOtherImages.First().ID > 0)
            {
                PatternTemplateImageBO objPTI = isHero ? lstOtherImages.Last() : lstOtherImages.First();
                imageFilePath = File.Exists(IndicoConfiguration.AppConfiguration.PathToDataFolder + "/PatternTemplates/" + objPTI.Pattern + "/" + objPTI.Filename + objPTI.Extension) ?
                                IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + objPTI.Pattern + "/" + objPTI.Filename + objPTI.Extension :
                                string.Empty; //IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
            }
            else
            {
                imageFilePath = string.Empty; // IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
            }
            return imageFilePath.ToLower();
        }

        private void DownloadPDFFile(string filePath, string patternNumber)
        {
            FileInfo fileInfo = new FileInfo(filePath);
            string outputName = patternNumber + ".pdf";//System.Text.RegularExpressions.Regex.Replace(fileInfo.Name, @"\W+", "_");
            //outputName = System.Text.RegularExpressions.Regex.Replace(outputName, "_pdf", ".pdf");
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Content-Type", "application/pdf");
            Response.AddHeader("Content-Disposition", string.Format("attachment; filename = {0}", outputName));
            Response.AddHeader("Content-Length", (fileInfo.Length).ToString("F0"));
            Response.TransmitFile(filePath);
            Response.Flush();
            Response.Close();
            Response.BufferOutput = true;
            //Response.End();
        }

        private string PopulatePatternCompressionImage(PatternBO objPattern)
        {
            string dataFolderPath = "/" + IndicoConfiguration.AppConfiguration.DataFolderName;
            string ImagePath = dataFolderPath + "/noimage-png-350px-350px.png";

            if ((objPattern.PatternCompressionImage ?? 0) > 0)
            {
                string fileName = objPattern.objPatternCompressionImage.Filename;
                string extension = objPattern.objPatternCompressionImage.Extension;

                string physicalFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\PatternCompressionImages\\" + objPattern.ID + "\\";
                CompressionImagePhysicalPath = physicalFolderPath + fileName + extension;

                if (File.Exists(CompressionImagePhysicalPath))
                {
                    ImagePath = dataFolderPath + "/PatternCompressionImages/" + objPattern.ID + "/" + fileName + extension;
                }
            }

            return ImagePath;
        }

        #endregion
    }
}