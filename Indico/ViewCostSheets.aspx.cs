using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;
using Telerik.Web.UI;
using Dapper;
using Indico.BusinessObjects;
using Indico.Common;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using System.Web.UI.HtmlControls;
using System.Drawing;
using Indico.DAL;
using CostSheetDetailsView = Indico.Common.CostSheetDetailsView;
using Label = System.Web.UI.WebControls.Label;

namespace Indico
{
    public partial class ViewCostSheets : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["CostSheetSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Pattern";
                }
                return sort;
            }
            set
            {
                ViewState["CostSheetSortExpression"] = value;
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

        protected void RadGridCostSheet_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridCostSheet_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridCostSheet_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is CostSheetDetailsView)
                {
                    CostSheetDetailsView objCostSheet = (CostSheetDetailsView)item.DataItem;

                    Label lblCostSheet = (Label)item.FindControl("lblCostSheet");
                    lblCostSheet.Text = (objCostSheet.CostSheet).ToString();

                    TextBox txtQuotedCIF = (TextBox)item.FindControl("txtQuotedCIF");
                    txtQuotedCIF.Text = (objCostSheet.QuotedCIF).ToString("0.00");

                    TextBox txtFOBCost = (TextBox)item.FindControl("txtFOBCost");
                    txtFOBCost.Text = (objCostSheet.QuotedFOBCost).ToString("0.00");

                    TextBox txtExchangeRate = (TextBox)item.FindControl("txtExchangeRate");
                    txtExchangeRate.Text = (objCostSheet.ExchangeRate).ToString("0.00");

                    TextBox txtDutyRate = (TextBox)item.FindControl("txtDutyRate");
                    txtDutyRate.Text = (objCostSheet.DutyRate).ToString("0.00");

                    TextBox txtSMVRate = (TextBox)item.FindControl("txtSMVRate");
                    txtSMVRate.Text = (objCostSheet.SMVRate).ToString("0.000");

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.NavigateUrl = "/AddEditFactoryCostSheet.aspx?id=" + objCostSheet.CostSheet.ToString();

                    LinkButton btnPrintJkCostSheet = (LinkButton)item.FindControl("btnPrintJkCostSheet");
                    btnPrintJkCostSheet.Attributes.Add("id", objCostSheet.CostSheet.ToString());

                    LinkButton btnIndimanCostSheet = (LinkButton)item.FindControl("btnIndimanCostSheet");
                    btnIndimanCostSheet.Attributes.Add("id", objCostSheet.CostSheet.ToString());
                    btnIndimanCostSheet.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;

                    var linkDelete = (HyperLink)item.FindControl("linkDelete");
                    var hasProduct = ValidateField2(0, "VisualLayout", "FabricCode", objCostSheet.FabricID.ToString(), "Pattern", objCostSheet.PatternID.ToString()) < 1;
                    if (hasProduct)
                    {
                        linkDelete.Visible = false;
                    }


                    linkDelete.Attributes.Add("qid", objCostSheet.CostSheet.ToString());

                    //VisualLayoutBO objVL = new VisualLayoutBO();
                    //objVL.Pattern = objCostSheet.patt

                    HyperLink linkClone = (HyperLink)item.FindControl("linkClone");
                    linkClone.NavigateUrl = "AddEditFactoryCostSheet.aspx?cloneid=" + objCostSheet.CostSheet.ToString();

                    LinkButton btnShowToIndico = (LinkButton)item.FindControl("btnShowToIndico");
                    btnShowToIndico.Attributes.Add("id", objCostSheet.CostSheet.ToString());
                    btnShowToIndico.Text = ((bool)objCostSheet.ShowToIndico) ? "Hide from Indico" : "Show to Indico";

                    btnShowToIndico.Visible = !(this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator);

                    /*  // Column show to indico
                      Label lblShowToIndico = (Label)item.FindControl("lblShowToIndico");
                      lblShowToIndico.Attributes.Add("id", objCostSheet.CostSheet.ToString());
                      if((bool)objCostSheet.ShowToIndico)
                      {
                          lblShowToIndico.Text = "Yes";
  ;                   }
                      else if ((bool)objCostSheet.ShowToIndico == false)
                      {
                          lblShowToIndico.Text = "No";
                      } */

                    Label lblShowToIndico = (Label)item.FindControl("lblShowToIndico");
                    if ((bool)objCostSheet.ShowToIndico)
                    {
                        lblShowToIndico.Text = @"<span class='badge badge-success '\>&nbsp;</span>";

                    }
                    else if ((bool)objCostSheet.ShowToIndico == false)
                    {
                        lblShowToIndico.Text = @"<span class='badge badge-important'\>&nbsp;</span>";
                    }

                    //Displaying pattern images
                    string imagePath_1 = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    string imagePath_2 = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    string imagePath_3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    string imagePath_hero = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    int count = 0;

                    int patternID = objCostSheet.PatternID;
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

                            HtmlAnchor ancFullImage = (HtmlAnchor)item.FindControl("ancFullImage");
                            ancFullImage.HRef = imagePathHero;
                            ancFullImage.Visible = true;

                            ancTemplateImage.HRef = "#" + previewTemplate.ClientID;
                            // ancTemplateImage.Title = "Pattern Images";

                            //ancTemplateImage.Attributes.Add("target", "_blank");
                            //ancTemplateImage.Attributes.Add("onclick", "Javascript:populateDiv(this);return false;");
                            //ancTemplateImage.Attributes.Add("style", "pointer-events:none;");

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
                }
            }
        }

        protected void RadGridCostSheet_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridCostSheet_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
            else if (e.CommandName == "SaveCostSheet")
            {
                try
                {
                    Label lblCostSheet = (Label)e.Item.FindControl("lblCostSheet");
                    int costSheet = int.Parse(lblCostSheet.Text.ToString());

                    TextBox txtExchangeRate = (TextBox)e.Item.FindControl("txtExchangeRate");
                    TextBox txtFOBCost = (TextBox)e.Item.FindControl("txtFOBCost");
                    TextBox txtQuotedCIF = (TextBox)e.Item.FindControl("txtQuotedCIF");
                    TextBox txtDutyRate = (TextBox)e.Item.FindControl("txtDutyRate");
                    TextBox txtSMVRate = (TextBox)e.Item.FindControl("txtSMVRate");

                    decimal exchangeRate = !string.IsNullOrEmpty(txtExchangeRate.Text) ? Convert.ToDecimal(txtExchangeRate.Text) : 0;
                    decimal fobCost = !string.IsNullOrEmpty(txtFOBCost.Text) ? Convert.ToDecimal(txtFOBCost.Text) : 0;
                    decimal quotedCIF = !string.IsNullOrEmpty(txtQuotedCIF.Text) ? Convert.ToDecimal(txtQuotedCIF.Text) : 0;
                    decimal dutyRate = !string.IsNullOrEmpty(txtDutyRate.Text) ? Convert.ToDecimal(txtDutyRate.Text) : 0;
                    decimal smvRate = !string.IsNullOrEmpty(txtSMVRate.Text) ? Convert.ToDecimal(txtSMVRate.Text) : 0;

                    CostSheetBO objCostSheet = new CostSheetBO(this.ObjContext);
                    objCostSheet.ID = costSheet;
                    objCostSheet.GetObject();

                    if (this.LoggedUserRoleName == UserRole.IndimanAdministrator)
                    {
                        objCostSheet.IndimanModifier = this.LoggedUser.ID;
                        objCostSheet.IndimanModifiedDate = DateTime.Now;
                    }
                    else if (this.LoggedUserRoleName == UserRole.FactoryAdministrator)
                    {
                        objCostSheet.Modifier = this.LoggedUser.ID;
                        objCostSheet.ModifiedDate = DateTime.Now;
                    }

                    objCostSheet.ExchangeRate = exchangeRate;
                    objCostSheet.QuotedCIF = quotedCIF;
                    objCostSheet.QuotedFOBCost = fobCost;
                    objCostSheet.DutyRate = dutyRate;
                    objCostSheet.SMVRate = smvRate;

                    this.ObjContext.SaveChanges();

                    PopulateDataGrid();
                }
                catch (Exception ex)
                {
                    // Log the error
                    IndicoLogging.log.Error("Error occured while saving exchangeRate to the Cost Sheet from ViewCostSheets.aspx", ex);
                }
            }
        }

        protected void RadGridCostSheet_SortCommand(object sender, GridSortCommandEventArgs e)
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

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int Id = int.Parse(this.hdnSelectedID.Value.Trim());

            if (Page.IsValid)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        CostSheetBO objCostSheet = new CostSheetBO(this.ObjContext);
                        objCostSheet.ID = Id;
                        objCostSheet.GetObject();

                        // delete Pattern Support Fabric
                        //List<PatternSupportFabricBO> lstPatternSupportFabric = (new PatternSupportFabricBO()).SearchObjects().Where()
                        foreach (PatternSupportFabricBO psf in objCostSheet.PatternSupportFabricsWhereThisIsCostSheet)
                        {
                            PatternSupportFabricBO objPatternSupportFabric = new PatternSupportFabricBO(this.ObjContext);
                            objPatternSupportFabric.ID = psf.ID;
                            objPatternSupportFabric.GetObject();

                            objPatternSupportFabric.Delete();
                        }

                        // delete Pattern Support Accesories
                        foreach (PatternSupportAccessoryBO psf in objCostSheet.PatternSupportAccessorysWhereThisIsCostSheet)
                        {
                            PatternSupportAccessoryBO objPatternSupportAccesory = new PatternSupportAccessoryBO(this.ObjContext);
                            objPatternSupportAccesory.ID = psf.ID;
                            objPatternSupportAccesory.GetObject();

                            objPatternSupportAccesory.Delete();
                        }

                        //delete CostSheetRemarks

                        foreach (CostSheetRemarksBO cr in objCostSheet.CostSheetRemarkssWhereThisIsCostSheet)
                        {
                            CostSheetRemarksBO objCostSheetRemarks = new CostSheetRemarksBO(this.ObjContext);
                            objCostSheetRemarks.ID = cr.ID;
                            objCostSheetRemarks.GetObject();

                            objCostSheetRemarks.Delete();
                        }

                        // delete Indiman CostSheet Remarks
                        foreach (IndimanCostSheetRemarksBO icr in objCostSheet.IndimanCostSheetRemarkssWhereThisIsCostSheet)
                        {
                            IndimanCostSheetRemarksBO objIndimanCostSheetRemarks = new IndimanCostSheetRemarksBO(this.ObjContext);
                            objIndimanCostSheetRemarks.ID = icr.ID;
                            objIndimanCostSheetRemarks.GetObject();

                            objIndimanCostSheetRemarks.Delete();
                        }

                        // delete costsheet
                        objCostSheet.Delete();

                        this.ObjContext.SaveChanges();
                        ts.Complete();

                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occurder while deleting Cost Sheet From ViewCostSheets.aspx page", ex);
                }
                this.PopulateDataGrid();
            }
        }

        protected void btnPrintJkCostSheet_Click(object sender, EventArgs e)
        {
            int id = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["id"].ToString());

            if (id > 0)
            {
                try
                {
                    string pdfFilePath = Common.GenerateOdsPdf.GenerateJKCostSheetPDF(id);
                    this.DownloadPDFFile(pdfFilePath);
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while printing JKCostSheet from ViewCostSheet.aspx", ex);
                }
            }
        }

        protected void ddlFocCost_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void ddlIndimanCIF_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnIndimanCostSheet_Click(object sender, EventArgs e)
        {
            int id = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["id"].ToString());

            if (id > 0)
            {
                try
                {
                    string pdfFilePath = Common.GenerateOdsPdf.GenerateIndimanCostSheet(id);
                    this.DownloadPDFFile(pdfFilePath);
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while printing IndimanCostSheet from ViewCostSheet.aspx", ex);
                }
            }
        }

        protected void btnChange_ServerClick(object sender, EventArgs e)
        {

            decimal duty = (!string.IsNullOrEmpty(this.txtDutyRate.Text) && decimal.TryParse(this.txtDutyRate.Text, out duty) == true) ? decimal.Parse(this.txtDutyRate.Text) : 0;
            decimal exchange = (!string.IsNullOrEmpty(this.txtExchangeRate.Text) && decimal.TryParse(this.txtExchangeRate.Text, out exchange) == true) ? decimal.Parse(this.txtExchangeRate.Text) : 0;

            try
            {
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = CostSheetBO.UpdateDutyRateExchnageRate(duty, exchange);
                if (objReturnInt.RetVal == 0)
                {
                    IndicoLogging.log.Error("btnChange_ServerClick : Error occured while Updating the Duty Rate and Exchange Rate ViewCostSheet.aspx, SPC_UpdateDutyRateExchnageRateCostSheet");
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("btnChange_ServerClick : Error occured while Updating the Duty Rate and Exchange Rate ViewCostSheet.aspx", ex);
            }

            this.PopulateDataGrid();

            this.txtDutyRate.Text = string.Empty;
            this.txtExchangeRate.Text = string.Empty;

        }

        protected void btnBulkCostSheet_Click(object sender, EventArgs e)
        {
            try
            {
                string pdfFilePath = Common.GenerateOdsPdf.GenerateIndimanBulkCostSheet();
                this.DownloadPDFFile(pdfFilePath);
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while printing IndimanBulkCostSheet from ViewCostSheet.aspx", ex);
            }
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            try
            {
                foreach (GridDataItem dgitem in this.RadGridCostSheet.Items)
                {
                    Label lblCostSheet = (Label)dgitem.FindControl("lblCostSheet");
                    int costSheet = int.Parse(lblCostSheet.Text.ToString());

                    TextBox txtExchangeRate = (TextBox)dgitem.FindControl("txtExchangeRate");
                    TextBox txtQuotedCIF = (TextBox)dgitem.FindControl("txtQuotedCIF");
                    TextBox txtDutyRate = (TextBox)dgitem.FindControl("txtDutyRate");
                    TextBox txtSMVRate = (TextBox)dgitem.FindControl("txtSMVRate");

                    decimal exchangeRate = !string.IsNullOrEmpty(txtExchangeRate.Text) ? Convert.ToDecimal(txtExchangeRate.Text) : 0;
                    decimal quotedCIF = !string.IsNullOrEmpty(txtQuotedCIF.Text) ? Convert.ToDecimal(txtQuotedCIF.Text) : 0;
                    decimal dutyRate = !string.IsNullOrEmpty(txtDutyRate.Text) ? Convert.ToDecimal(txtDutyRate.Text) : 0;
                    decimal smvRate = !string.IsNullOrEmpty(txtSMVRate.Text) ? Convert.ToDecimal(txtSMVRate.Text) : 0;

                    CostSheetBO objCostSheet = new CostSheetBO(this.ObjContext);
                    objCostSheet.ID = costSheet;
                    objCostSheet.GetObject();

                    objCostSheet.ExchangeRate = exchangeRate;
                    objCostSheet.QuotedCIF = quotedCIF;
                    objCostSheet.DutyRate = dutyRate;
                    objCostSheet.SMVRate = smvRate;

                    this.ObjContext.SaveChanges();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while saving data to the Cost Sheet from ViewCostSheets.aspx", ex);
            }

            Response.Redirect("ViewCostSheets.aspx");
        }

        protected void btnExchangeRate_Click(object sender, EventArgs e)
        {
            try
            {
                GridHeaderItem header = (GridHeaderItem)this.RadGridCostSheet.MasterTableView.GetItems(GridItemType.Header)[0];
                TextBox txtApplyExchangeRate = (TextBox)header.FindControl("txtApplyExchangeRate");
                decimal exchangeRate = !string.IsNullOrEmpty(txtApplyExchangeRate.Text) ? Convert.ToDecimal(txtApplyExchangeRate.Text) : 0;

                foreach (GridDataItem dgitem in this.RadGridCostSheet.Items)
                {
                    Label lblCostSheet = (Label)dgitem.FindControl("lblCostSheet");
                    int costSheet = int.Parse(lblCostSheet.Text.ToString());

                    TextBox txtExchangeRate = (TextBox)dgitem.FindControl("txtExchangeRate");
                    txtExchangeRate.Text = exchangeRate.ToString();

                    CostSheetBO objCostSheet = new CostSheetBO(this.ObjContext);
                    objCostSheet.ID = costSheet;
                    objCostSheet.GetObject();

                    objCostSheet.ExchangeRate = exchangeRate;
                    this.ObjContext.SaveChanges();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while saving exchangeRate to the Cost Sheet from ViewCostSheets.aspx", ex);
            }

            Response.Redirect("ViewCostSheets.aspx");
        }

        protected void btnQuotedCIF_Click(object sender, EventArgs e)
        {
            try
            {
                GridHeaderItem header = (GridHeaderItem)this.RadGridCostSheet.MasterTableView.GetItems(GridItemType.Header)[0];
                TextBox txtApplyQuotedCIF = (TextBox)header.FindControl("txtApplyQuotedCIF");
                decimal quotedCIF = !string.IsNullOrEmpty(txtApplyQuotedCIF.Text) ? Convert.ToDecimal(txtApplyQuotedCIF.Text) : 0;

                foreach (GridDataItem dgitem in this.RadGridCostSheet.Items)
                {
                    Label lblCostSheet = (Label)dgitem.FindControl("lblCostSheet");
                    int costSheet = int.Parse(lblCostSheet.Text.ToString());

                    TextBox txtQuotedCIF = (TextBox)dgitem.FindControl("txtQuotedCIF");
                    txtQuotedCIF.Text = quotedCIF.ToString();

                    CostSheetBO objCostSheet = new CostSheetBO(this.ObjContext);
                    objCostSheet.ID = costSheet;
                    objCostSheet.GetObject();

                    objCostSheet.QuotedCIF = quotedCIF;

                    this.ObjContext.SaveChanges();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while saving quotedCIF to the Cost Sheet from ViewCostSheets.aspx", ex);
            }

            Response.Redirect("ViewCostSheets.aspx");
        }

        protected void btnDutyRate_Click(object sender, EventArgs e)
        {
            try
            {
                GridHeaderItem header = (GridHeaderItem)this.RadGridCostSheet.MasterTableView.GetItems(GridItemType.Header)[0];
                TextBox txtApplyDutyRate = (TextBox)header.FindControl("txtApplyDutyRate");
                decimal dutyRate = !string.IsNullOrEmpty(txtApplyDutyRate.Text) ? Convert.ToDecimal(txtApplyDutyRate.Text) : 0;

                foreach (GridDataItem dgitem in this.RadGridCostSheet.Items)
                {
                    Label lblCostSheet = (Label)dgitem.FindControl("lblCostSheet");
                    int costSheet = int.Parse(lblCostSheet.Text.ToString());

                    TextBox txtDutyRate = (TextBox)dgitem.FindControl("txtDutyRate");
                    txtDutyRate.Text = dutyRate.ToString();

                    CostSheetBO objCostSheet = new CostSheetBO(this.ObjContext);
                    objCostSheet.ID = costSheet;
                    objCostSheet.GetObject();

                    objCostSheet.DutyRate = dutyRate;

                    this.ObjContext.SaveChanges();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while saving dutyRate to the Cost Sheet from ViewCostSheets.aspx", ex);
            }

            Response.Redirect("ViewCostSheets.aspx");
        }

        protected void btnSMVRate_Click(object sender, EventArgs e)
        {
            try
            {
                GridHeaderItem header = (GridHeaderItem)this.RadGridCostSheet.MasterTableView.GetItems(GridItemType.Header)[0];
                TextBox txtApplySMVRate = (TextBox)header.FindControl("txtApplySMVRate");
                decimal smvRate = !string.IsNullOrEmpty(txtApplySMVRate.Text) ? Convert.ToDecimal(txtApplySMVRate.Text) : 0;

                foreach (GridDataItem dgitem in this.RadGridCostSheet.Items)
                {
                    Label lblCostSheet = (Label)dgitem.FindControl("lblCostSheet");
                    int costSheet = int.Parse(lblCostSheet.Text.ToString());

                    TextBox txtSMVRate = (TextBox)dgitem.FindControl("txtSMVRate");
                    txtSMVRate.Text = smvRate.ToString();

                    CostSheetBO objCostSheet = new CostSheetBO(this.ObjContext);
                    objCostSheet.ID = costSheet;
                    objCostSheet.GetObject();

                    objCostSheet.SMVRate = smvRate;

                    this.ObjContext.SaveChanges();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while saving smvRate to the Cost Sheet from ViewCostSheets.aspx", ex);
            }

            Response.Redirect("ViewCostSheets.aspx");
        }

        protected void btnShowToIndico_Click(object sender, EventArgs e)
        {
            int id = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["id"].ToString());

            if (id > 0)
            {
                CostSheetBO objCostSheet = new CostSheetBO(this.ObjContext);
                objCostSheet.ID = id;
                objCostSheet.GetObject();

                objCostSheet.ShowToIndico = !objCostSheet.ShowToIndico;

                this.ObjContext.SaveChanges();

                this.PopulateDataGrid();
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

            Session["CostSheetDetailsView"] = null;

            this.btnBulkCostSheet.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;

            this.PopulateDataGrid();

            this.RadGridCostSheet.MasterTableView.GetColumn("ModifiedDate").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("CalculateCM").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("HPCost").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("LabelCost").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("CM").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("JKFOBCost").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("Roundup").Display = false;
            //this.RadGridCostSheet.MasterTableView.GetColumn("DutyRate").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("SubCons").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("MarginRate").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("Duty").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("AirFregiht").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("ImpCharges").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("Landed").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("MGTOH").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("IndicoOH").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("InkCost").Display = false;
            this.RadGridCostSheet.MasterTableView.GetColumn("PaperCost").Display = false;

            if (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator)
            {
                this.RadGridCostSheet.MasterTableView.GetColumn("SubCons").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("Duty").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("AirFregiht").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("ImpCharges").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("Landed").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("MGTOH").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("IndicoOH").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("InkCost").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("PaperCost").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("ExchangeRate").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("QuotedCIF").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("QuotedMP").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("DutyRate").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("IndimanModifiedDate").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("ShowToIndico").Visible = false;
                this.RadGridCostSheet.MasterTableView.GetColumn("ModifiedDate").Display = true;
            }
        }

        private void PopulateDataGrid()
        {
            //Hide Controls

            this.dvNoSearchResult.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvEmptyContent.Visible = false;

            string searchText = this.txtSearch.Text.ToLower().Trim();

            List<CostSheetDetailsView> lstCostSheets = new List<CostSheetDetailsView>();

            //if (searchText != string.Empty && txtSearch.Text != "search")
            //{
            //    lstCostSheets = (from g in objCostSheet.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
            //                     where (g.Pattern.ToLower().Contains(searchText) ||
            //                            g.Fabric.ToLower().Contains(searchText) ||
            //                            g.Category.ToLower().Contains(searchText))
            //                     select g).ToList();
            //}
            //else
            //{
            //    lstCostSheets = objCostSheet.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
            //}

            searchText = (searchText != string.Empty && txtSearch.Text != "search") ? searchText : string.Empty;

            //lstCostSheets = CostSheetBO.GetCostSheetDetails(searchText);

            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Open();

                lstCostSheets = connection.Query<CostSheetDetailsView>(string.Format(@"EXEC [Indico].[dbo].[SPC_GetCostSheetDetails] '{0}'", searchText)).ToList();
                connection.Close();
            }

            if (int.Parse(this.ddlFocCost.SelectedValue) > 0)
            {
                lstCostSheets = lstCostSheets.Where(o => o.QuotedFOBCost == Convert.ToDecimal(this.ddlFocCost.SelectedItem.Text)).ToList();
            }

            if (int.Parse(this.ddlIndimanCIF.SelectedValue) > 0)
            {
                lstCostSheets = lstCostSheets.Where(o => o.QuotedCIF == Convert.ToDecimal(this.ddlIndimanCIF.SelectedItem.Text)).ToList();
            }

            if (lstCostSheets.Count > 0)
            {
                this.RadGridCostSheet.AllowPaging = (lstCostSheets.Count > this.RadGridCostSheet.PageSize);
                this.RadGridCostSheet.DataSource = lstCostSheets;
                this.RadGridCostSheet.DataBind();
                Session["CostSheetDetailsView"] = lstCostSheets;

                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && txtSearch.Text != "search") || (int.Parse(this.ddlFocCost.SelectedValue) > 0) || (int.Parse(this.ddlIndimanCIF.SelectedValue) > 0))
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyContent.Visible = true;

            }

            // this.dvDataContent.Visible = (lstGender.Count > 0);
            this.RadGridCostSheet.Visible = (lstCostSheets.Count > 0);
            //throw new NotImplementedException();
        }

        private void ReBindGrid()
        {
            if (Session["CostSheetDetailsView"] != null)
            {
                RadGridCostSheet.DataSource = (List<CostSheetDetailsView>)Session["CostSheetDetailsView"];
                RadGridCostSheet.DataBind();
            }
        }

        #endregion
    }
}