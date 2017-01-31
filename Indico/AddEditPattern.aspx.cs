using Dapper;
using Indico.BusinessObjects;
using Indico.Common;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Threading;
using System.Transactions;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Indico
{
    public partial class AddEditPattern : IndicoPage
    {
        #region Fields

        private int urlQueryID = -1;
        private bool urlEditMode = true;
        private List<PatternSupportAccessoryBO> lstPatternAccessories = null;
        private int rptPageSize = 10;
        private static string _Val;

        #endregion

        #region Properties

        protected int QueryID
        {
            get
            {
                if (urlQueryID > -1)
                    return urlQueryID;

                urlQueryID = 0;
                if (Request.QueryString["id"] != null)
                {
                    urlQueryID = Convert.ToInt32(Request.QueryString["id"].ToString());
                }
                return urlQueryID;
            }
        }

        protected bool IsEditMode
        {
            get
            {
                if (Request.QueryString["isedit"] != null)
                {
                    urlEditMode = Convert.ToBoolean(Request.QueryString["isedit"].ToString());
                }
                return urlEditMode;
            }
        }

        public List<PatternSupportAccessoryBO> PatternAccessories
        {
            get
            {
                if (Session["PatternAccessories"] != null)
                    lstPatternAccessories = (List<PatternSupportAccessoryBO>)Session["PatternAccessories"];
                else
                {
                    lstPatternAccessories = new List<PatternSupportAccessoryBO>();
                    Session["PatternAccessories"] = lstPatternAccessories;
                }

                return lstPatternAccessories;
            }
        }

        protected int LoadedPageNumber
        {
            get
            {
                int c = 1;
                try
                {
                    if (ViewState["LoadedPageNumber"] != null)
                    {
                        c = Convert.ToInt32(ViewState["LoadedPageNumber"]);
                    }
                }
                catch (Exception)
                {
                    ViewState["LoadedPageNumber"] = c;
                }
                ViewState["LoadedPageNumber"] = c;
                return c;

            }
            set
            {
                ViewState["LoadedPageNumber"] = value;
            }
        }

        protected int TemplateTotal
        {
            get
            {
                int c = 0;
                try
                {
                    if (ViewState["VLTotal"] != null)
                    {
                        c = Convert.ToInt32(ViewState["VLTotal"]);
                    }
                }
                catch (Exception)
                {
                    ViewState["VLTotal"] = c;
                }
                ViewState["VLTotal"] = c;
                return c;
            }
            set
            {
                ViewState["VLTotal"] = value;
            }
        }

        protected int TemplatePageCount
        {
            get
            {
                int c = 0;
                try
                {
                    if (ViewState["VLPageCount"] != null)
                        c = Convert.ToInt32(ViewState["VLPageCount"]);
                }
                catch (Exception)
                {
                    ViewState["VLPageCount"] = c;
                }
                ViewState["VLPageCount"] = c;
                return c;
            }
            set
            {
                ViewState["VLPageCount"] = value;
            }
        }

        public ApartmentState ApartmentState { get; set; }

        public static string Val
        {
            get { return _Val; }
            set { _Val = value; }
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

        /*protected void cvTemplateImage_OnServerValidate(object sender, ServerValidateEventArgs e)
        {
            //if (this.chkIsTemplate.Checked)
            //{
            if (this.QueryID > 0)
            {
                if (this.hdnUploadFiles.Value != "0" && !string.IsNullOrEmpty(this.hdnUploadFiles.Value))
                    e.IsValid = true;
                else
                {
                    PatternBO objPattern = new PatternBO();
                    objPattern.ID = this.QueryID;
                    objPattern.GetObject();

                    if (objPattern.PatternTemplateImagesWhereThisIsPattern.Count > 0)
                        e.IsValid = true;
                    else
                        e.IsValid = false;
                }
            }
            else
            {
                if (this.hdnUploadFiles.Value == "0" || string.IsNullOrEmpty(this.hdnUploadFiles.Value))
                    e.IsValid = false;
                else
                    e.IsValid = true;
            }
            //}
        }*/

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                this.ProcessForm();

                Response.Redirect("/ViewPatterns.aspx");
            }

            this.validationSummary.Visible = !Page.IsValid;
        }

        protected void btnClose_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect("/ViewPatterns.aspx");
        }

        protected void btnSaveNew_Click(object sender, EventArgs e)
        {
            string newType = this.hdnAddNew.Value.ToString();
            if (newType == "ItemAttribute" || newType == "ItemSubCategory")
            {
                rfvItem.Enabled = true;
            }
            else
            {
                rfvItem.Enabled = false;
            }
            if (Page.IsValid)
            {
                ItemBO objItem = new ItemBO(this.ObjContext);
                ItemAttributeBO objItemAttribute = new ItemAttributeBO(this.ObjContext);
                ItemBO objSubItem = new ItemBO(this.ObjContext);
                GenderBO objGender = new GenderBO(this.ObjContext);
                AgeGroupBO objAgeGroup = new AgeGroupBO(this.ObjContext);
                SizeSetBO objSizeSet = new SizeSetBO(this.ObjContext);
                CategoryBO objCategory = new CategoryBO(this.ObjContext);
                PrinterTypeBO objPrintType = new PrinterTypeBO(this.ObjContext);

                try
                {
                    #region Add New Item

                    using (TransactionScope ts = new TransactionScope())
                    {
                        switch (newType)
                        {
                            case "Item":
                                objItem.Name = this.txtNewName.Text;
                                objItem.Description = this.txtNewDescription.Text;
                                objItem.Add();
                                break;
                            case "ItemAttribute":
                                objItemAttribute.Item = int.Parse(this.ddlItem.SelectedValue);
                                objItemAttribute.Name = this.txtNewName.Text;
                                objItemAttribute.Description = this.txtNewDescription.Text;
                                objItemAttribute.Add();
                                break;
                            case "ItemSubCategory":
                                objSubItem.Parent = int.Parse(this.ddlItem.SelectedValue);
                                objSubItem.Name = this.txtNewName.Text;
                                objSubItem.Description = this.txtNewDescription.Text;
                                objSubItem.Add();
                                break;
                            case "Gender":
                                objGender.Name = this.txtNewName.Text;
                                objGender.Add();
                                break;
                            case "AgeGroup":
                                objAgeGroup.Name = this.txtNewName.Text;
                                objAgeGroup.Description = this.txtNewDescription.Text;
                                objAgeGroup.Add();
                                break;
                            case "SizeSet":
                                objSizeSet.Name = this.txtNewName.Text;
                                objSizeSet.Description = this.txtNewDescription.Text;
                                objSizeSet.Add();
                                break;
                            case "CoreCategory":
                                objCategory.Name = this.txtNewName.Text;
                                objCategory.Description = this.txtNewDescription.Text;
                                objCategory.Add();
                                break;
                            case "PrintType":
                                objPrintType.Name = this.txtNewName.Text;
                                //** objPrintType.Description = this.txtNewDescription.Text;
                                objPrintType.Add();
                                break;
                            default:
                                break;
                        }

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }

                    #endregion
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while saving " + newType, ex);
                }

                #region Populate New Items

                switch (newType)
                {
                    case "Item":
                        List<ItemBO> lstItems = (new ItemBO()).GetAllObject().Where(o => o.Parent == 0).ToList();
                        this.ddlItemGroup.Items.Clear();
                        this.ddlItem.Items.Clear();
                        this.ddlItemGroup.Items.Add(new ListItem("Select Item Group", "0"));
                        this.ddlItem.Items.Add(new ListItem("Select Item", "0"));
                        foreach (ItemBO item in lstItems)
                        {
                            this.ddlItemGroup.Items.Add(new ListItem(item.Name, item.ID.ToString()));
                            this.ddlItem.Items.Add(new ListItem(item.Name, item.ID.ToString()));
                        }

                        this.PopulateDropdown(this.ddlItemGroup, objItem.ID);
                        this.PopulateDropdown(this.ddlItem, objItem.ID);
                        break;
                    case "ItemAttribute":
                        if (int.Parse(this.ddlItemGroup.SelectedValue) > 0)
                        {
                            //ItemBO objItemTmp = new ItemBO();
                            //objItemTmp.ID = int.Parse(this.ddlItemGroup.SelectedValue);
                            //objItemTmp.GetObject();

                            //this.ddlItemAttribute.Items.Clear();
                            //this.ddlItemAttribute.Items.Add(new ListItem("Select Item Attribute", "0"));
                            //foreach (ItemAttributeBO item in objItemTmp.ItemAttributesWhereThisIsItem)
                            //{
                            //    this.ddlItemAttribute.Items.Add(new ListItem(item.Name, item.ID.ToString()));
                            //}

                            //if (int.Parse(this.ddlItemGroup.SelectedValue) == int.Parse(this.ddlItem.SelectedValue))
                            //    this.PopulateDropdown(this.ddlItemAttribute, objItemAttribute.ID);
                        }
                        break;
                    case "ItemSubCategory":
                        if (int.Parse(this.ddlItemGroup.SelectedValue) > 0)
                        {
                            this.ddlItemSubGroup.Items.Clear();
                            this.ddlItemSubGroup.Items.Add(new ListItem("Select Sub Item", "0"));
                            List<ItemBO> lstItemSubCat = ((new ItemBO()).GetAllObject()).Where(o => o.Parent == int.Parse(this.ddlItemGroup.SelectedValue)).ToList();
                            foreach (ItemBO item in lstItemSubCat)
                            {
                                this.ddlItemSubGroup.Items.Add(new ListItem(item.Name, item.ID.ToString()));
                            }

                            if (int.Parse(this.ddlItemGroup.SelectedValue) == int.Parse(this.ddlItem.SelectedValue))
                                this.PopulateDropdown(this.ddlItemSubGroup, objSubItem.ID);
                        }
                        break;
                    case "Gender":
                        break;
                    case "AgeGroup":
                        List<AgeGroupBO> lstAgeGroup = (new AgeGroupBO()).GetAllObject().ToList();
                        this.ddlAgeGroup.Items.Clear();
                        this.ddlAgeGroup.Items.Add(new ListItem("Select Age Group", "0"));
                        foreach (AgeGroupBO item in lstAgeGroup)
                        {
                            this.ddlAgeGroup.Items.Add(new ListItem(item.Name, item.ID.ToString()));
                        }
                        this.PopulateDropdown(this.ddlAgeGroup, objAgeGroup.ID);

                        break;
                    case "SizeSet":
                        List<SizeSetBO> lstSizeSet = (new SizeSetBO()).GetAllObject().ToList();
                        this.ddlSizeSet.Items.Clear();
                        this.ddlSizeSet.Items.Add(new ListItem("Select Size Set", "0"));
                        foreach (SizeSetBO item in lstSizeSet)
                        {
                            this.ddlSizeSet.Items.Add(new ListItem(item.Name, item.ID.ToString()));
                        }
                        this.PopulateDropdown(this.ddlSizeSet, objSizeSet.ID);
                        break;
                    case "CoreCategory":
                        List<CategoryBO> lstCoreCategory = (new CategoryBO()).GetAllObject().ToList();
                        this.ddlCoreCategory.Items.Clear();
                        this.lstOtherCategories.Items.Clear();
                        this.ddlCoreCategory.Items.Add(new ListItem("Select Core Category", "0"));
                        foreach (CategoryBO item in lstCoreCategory)
                        {
                            this.ddlCoreCategory.Items.Add(new ListItem(item.Name, item.ID.ToString()));
                            this.lstOtherCategories.Items.Add(new ListItem(item.Name, item.ID.ToString()));
                        }
                        this.PopulateDropdown(this.ddlCoreCategory, objCategory.ID);
                        break;
                    case "PrintType":
                        List<PrinterTypeBO> lstPrinters = (new PrinterTypeBO()).GetAllObject().ToList();
                        this.ddlPrintType.Items.Clear();
                        this.ddlPrintType.Items.Add(new ListItem("Select Printer Type", "0"));
                        foreach (PrinterTypeBO item in lstPrinters)
                        {
                            this.ddlPrintType.Items.Add(new ListItem(item.Name, item.ID.ToString()));
                        }
                        this.PopulateDropdown(this.ddlPrintType, objPrintType.ID);
                        break;
                    default:
                        break;
                }

                #endregion
            }
            else
            {
                ViewState["isPopulate"] = true;
            }

            //Response.Redirect("/AddEditPattern.aspx?id=" + this.QueryID);
        }

        protected void btnAddAccessory_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (Page.IsValid)
                {
                    this.ddlPatternAccessoryCategory.SelectedIndex = 0;
                    this.ddlPatternAccessory.Items.Clear();
                    this.ddlPatternAccessory.Enabled = false;
                }

                ViewState["PopulateAccessoryUI"] = (Page.IsValid);
                this.PopulateFileUploder(this.rptUploadFile, this.hdnUploadFiles);

            }

            this.collapse5.Attributes.Add("class", "accordion-body collapse in");
            //this.dvAccessoriesContent.Attributes.Add("style", "display: block;");
        }

        protected void btnAddPatternAccessory_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (Page.IsValid)
                {
                    PatternSupportAccessoryBO objPatternPatternAccessory = new PatternSupportAccessoryBO();

                    objPatternPatternAccessory.Accessory = int.Parse(this.ddlPatternAccessory.SelectedValue);
                    // objPatternPatternAccessory.AccessoryColor = int.Parse(this.ddlPatternAccessoryColor.SelectedValue);

                    int i = this.PatternAccessories.Where(o => o.Accessory == objPatternPatternAccessory.Accessory
                                                          ).Count();

                    if (i < 1)
                    {
                        this.PatternAccessories.Add(objPatternPatternAccessory);
                        Session["PatternAccessories"] = this.PatternAccessories;

                        if (this.PatternAccessories.Count > 0)
                        {
                            this.dgPatternAccessories.DataSource = this.PatternAccessories;
                            this.dgPatternAccessories.DataBind();

                            this.dvEmptyContentAccessory.Visible = false;
                            this.dvPatternAccessory.Visible = true;
                        }
                    }
                    else
                    {
                        CustomValidator cfv = new CustomValidator();
                        cfv.ErrorMessage = "This pattern accessory all ready exists";
                        cfv.IsValid = false;
                        cfv.EnableClientScript = false;
                        cfv.ValidationGroup = "ValidationAccessory";

                        this.validationSummaryAddEditAccessory.Controls.Add(cfv);
                    }
                }

                ViewState["PopulateAccessoryUI"] = !(Page.IsValid);
            }

            this.collapse5.Attributes.Add("class", "accordion-body collapse in");
        }

        //protected void btnCopytoClipboard_Click(object sender, EventArgs e)
        //{
        //    if (Page.IsValid)
        //    {
        //        System.Windows.Forms.Clipboard.SetText(txtNickName.Text);
        //    }
        //}

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            /* try
             {
                 List<PatternAccessoryBO> lst = (List<PatternAccessoryBO>)Session["PatternAccessories"];
                 foreach (DataGridItem item in dgPatternAccessories.Items)
                 {
                     lst.RemoveAt(item.ItemIndex);
                 }                

                 dgPatternAccessories.DataSource = lst;
                 dgPatternAccessories.DataBind();
                 if (lst.Count < 1)
                 {
                     dvEmptyContentAccessory.Visible = true;
                     dvPatternAccessory.Visible = false;
                 }
                 //rfvPatternNumber.ValidationGroup.
                 btnSaveChanges.CausesValidation = false;
                 btnSaveChange.CausesValidation = false;

                 //this.PopulatePatternAccessory();
             }
             catch (Exception ex)
             {

             }*/
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

                CheckBox chkIsSend = (CheckBox)item.FindControl("chkIsSend");
                chkIsSend.Checked = (bool)objML.IsSend;
                chkIsSend.Enabled = false;

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

                TextBox txtQty = (TextBox)item.FindControl("txtQty");
                txtQty.Text = Math.Round(objSizeChart.Val, 1).ToString();

                txtQty.Attributes.Add("qid", objSizeChart.ID.ToString());
                txtQty.Attributes.Add("MLID", objSizeChart.MeasurementLocation.ToString());
                txtQty.Attributes.Add("SID", objSizeChart.Size.ToString());
            }
        }

        /*     protected void rptTemplateImages_ItemDataBound(object sender, RepeaterItemEventArgs e)
             {
                 RepeaterItem item = e.Item;
                 if (item.ItemIndex > -1 && item.DataItem is PatternTemplateImageBO)
                 {
                     string TemplateImgLocation = string.Empty;
                     PatternTemplateImageBO objPatternTemplateImage = (PatternTemplateImageBO)item.DataItem;

                     if (objPatternTemplateImage != null)
                     {
                         TemplateImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + this.QueryID.ToString() + "/" + objPatternTemplateImage.Filename + objPatternTemplateImage.Extension;

                         if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + TemplateImgLocation))
                             TemplateImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                     }
                     else
                     {
                         TemplateImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                     }

                     System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + TemplateImgLocation);
                     SizeF origImageSize = VLOrigImage.PhysicalDimension;
                     VLOrigImage.Dispose();

                     List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 240, 160);

                     System.Web.UI.WebControls.Image imgTemplateImage = (System.Web.UI.WebControls.Image)item.FindControl("imgTemplateImage");
                     imgTemplateImage.ImageUrl = TemplateImgLocation;
                     imgTemplateImage.Width = int.Parse(lstImgDimensions[1].ToString());
                     imgTemplateImage.Height = int.Parse(lstImgDimensions[0].ToString());

                     HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                     linkDelete.Attributes.Add("qid", objPatternTemplateImage.ID.ToString());
                     if (objPatternTemplateImage.objPattern.Parent == 0 || objPatternTemplateImage.objPattern.Parent == null)
                         linkDelete.Visible = true;
                     else
                         linkDelete.Visible = false;
                 }
             }*/

        protected void btnDeleteTmpImg_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int id = (this.hdnSelected.Value != "0" && this.hdnSelected.Value != "undefined") ? int.Parse(this.hdnSelected.Value) : 0;

                //int.Parse(this.hdnSelected.Value);
                if (id > 0)
                {
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            PatternTemplateImageBO objPatternTemplateImage = new PatternTemplateImageBO(this.ObjContext);
                            objPatternTemplateImage.ID = id;
                            objPatternTemplateImage.GetObject();

                            if (objPatternTemplateImage.objPattern.Parent == 0 || objPatternTemplateImage.objPattern.Parent == null)
                            {
                                objPatternTemplateImage.Delete();
                            }

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }

                        //delete the Image 

                        if (this.QueryID > 0)
                        {
                            PatternTemplateImageBO objPatternTemplateImage = new PatternTemplateImageBO();
                            objPatternTemplateImage.ID = id;
                            objPatternTemplateImage.GetObject();

                            string imagePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + this.QueryID.ToString() + "/" + objPatternTemplateImage.Filename + objPatternTemplateImage.Extension;
                            File.Delete(Server.MapPath(imagePath));
                        }

                        //this.PopulatePatternTemplates(0);
                        this.PopulatePatternTemplateImages();
                        this.liDropZone.Visible = true;

                        this.collapse4.Attributes.Add("class", "accordion-body collapse in");
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while deleting PatternTemplateImage", ex);
                    }
                }
            }
        }

        protected void lbHeaderPrevious_Click(object sender, EventArgs e)
        {
            LinkButton lk = new LinkButton();
            lk.ID = "lbHeader" + (--this.LoadedPageNumber).ToString();
            lk.Text = (this.LoadedPageNumber).ToString();
            this.lbHeader1_Click(lk, e);
        }

        protected void lbHeaderNext_Click(object sender, EventArgs e)
        {
            LinkButton lk = new LinkButton();
            lk.ID = "lbHeader" + (++this.LoadedPageNumber).ToString();
            lk.Text = (this.LoadedPageNumber).ToString();
            this.lbHeader1_Click(lk, e);
        }

        protected void lbHeaderNextDots_Click(object sender, EventArgs e)
        {
            LinkButton lk = new LinkButton();
            //lk.ID = "lbHeader" + ((ActivitiesTotal % 10 == 0) ? (ActivitiesTotal / 10) : (ActivitiesTotal / 10) + 1).ToString();
            //lk.Text = ((ActivitiesTotal % 10 == 0) ? (ActivitiesTotal / 10) : (ActivitiesTotal / 10) + 1).ToString();

            int nextSet = (LoadedPageNumber % 10 == 0) ? (LoadedPageNumber + 1) : ((this.LoadedPageNumber / 10) * 10) + 11;
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
            int previousSet = (LoadedPageNumber % 10 == 0) ? (LoadedPageNumber - 19) : (((this.LoadedPageNumber / 10) * 10) - 9);
            lk.ID = "lbHeader" + previousSet.ToString();
            lk.Text = previousSet.ToString();
            this.lbHeader1_Click(lk, e);
        }

        protected void lbHeader1_Click(object sender, EventArgs e)
        {
            string clickedPageText = ((LinkButton)sender).Text;
            int clickedPageNumber = Convert.ToInt32(clickedPageText);
            ViewState["LoadedPageNumber"] = clickedPageNumber;
            int currentPage = 1;

            this.ClearCss();

            if (clickedPageNumber > 10)
                currentPage = (clickedPageNumber % 10) == 0 ? 10 : clickedPageNumber % 10;
            else
                currentPage = clickedPageNumber;

            this.HighLightPageNumber(currentPage);

            this.lbFooterNext.Visible = true;
            this.lbFooterPrevious.Visible = true;

            if (clickedPageNumber == ((TemplateTotal % rptPageSize == 0) ? TemplateTotal / rptPageSize : Math.Floor((double)(TemplateTotal / rptPageSize)) + 1))
                this.lbFooterNext.Visible = false;
            if (clickedPageNumber == 1)
                this.lbFooterPrevious.Visible = false;

            int startIndex = clickedPageNumber * 10 - 10;
            this.PopulatePatternTemplates(startIndex);

            if (clickedPageNumber % 10 == 1)
                this.ProcessNumbering(clickedPageNumber, TemplatePageCount);
            else
            {
                if (clickedPageNumber > 10)
                {
                    if (clickedPageNumber % 10 == 0)
                        this.ProcessNumbering(clickedPageNumber - 9, TemplatePageCount);
                    else
                        this.ProcessNumbering(((clickedPageNumber / 10) * 10) + 1, TemplatePageCount);
                }
                else
                {
                    this.ProcessNumbering((clickedPageNumber / 10 == 0) ? 1 : clickedPageNumber / 10, TemplatePageCount);
                }
            }
        }

        protected void ddlPatternAccessoryCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {


                int id = int.Parse(this.ddlPatternAccessoryCategory.SelectedValue);
                if (id > 0)
                {


                    //Populate Pattern Accessory Category
                    this.ddlPatternAccessory.Items.Clear();
                    this.ddlPatternAccessory.Items.Add(new ListItem("Select Accessory", "0"));
                    List<AccessoryBO> lstPatternAccessory = (new AccessoryBO()).GetAllObject().Where(o => o.AccessoryCategory == id).OrderBy(o => o.Name).ToList();
                    foreach (AccessoryBO acc in lstPatternAccessory)
                    {
                        ddlPatternAccessory.Items.Add(new ListItem(acc.Name, acc.ID.ToString()));
                    }
                    this.ddlPatternAccessory.Enabled = (lstPatternAccessory.Count > 1) ? true : false;
                }
                else
                {
                    this.ddlPatternAccessory.Items.Clear();
                }

                ViewState["PopulateAccessoryUI"] = true;
            }
            else
            {
                ViewState["PopulateAccessoryUI"] = false;
            }
        }

        protected void dgPatternAccessories_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, PatternSupportAccessoryBO>)
            {
                List<PatternSupportAccessoryBO> objPatternPatternAccessory = ((IGrouping<int, PatternSupportAccessoryBO>)item.DataItem).ToList();

                //PatternSupportAccessoryBO objPatternPatternAccessory = (PatternSupportAccessoryBO)item.DataItem;

                Label lblPatternAccessory = (Label)item.FindControl("lblPatternAccessory");
                lblPatternAccessory.Text = objPatternPatternAccessory[0].objAccessory.Name;
                lblPatternAccessory.Attributes.Add("qid", objPatternPatternAccessory[0].Accessory.ToString());

                HiddenField hdnPatternPatternAccessoryID = (HiddenField)item.FindControl("hdnPatternPatternAccessoryID");
                hdnPatternPatternAccessoryID.Value = objPatternPatternAccessory[0].ID.ToString();

                Label lblPatternAccessoryCategory = (Label)item.FindControl("lblPatternAccessoryCategory");
                lblPatternAccessoryCategory.Text = objPatternPatternAccessory[0].objAccessory.objAccessoryCategory.Name;
                lblPatternAccessoryCategory.Attributes.Add("qid", objPatternPatternAccessory[0].objAccessory.AccessoryCategory.ToString());

                //Label lblPatternAccessoryColor = (Label)item.FindControl("lblPatternAccessoryColor");
                //lblPatternAccessoryColor.Text = objPatternPatternAccessory.objPatternAccessoryColor.Name;
                //lblPatternAccessoryColor.Attributes.Add("qid", objPatternPatternAccessory.PatternAccessoryColor.ToString());

                Label lblPatternAccessoryCode = (Label)item.FindControl("lblPatternAccessoryCode");
                lblPatternAccessoryCode.Text = objPatternPatternAccessory[0].objAccessory.objAccessoryCategory.Code + objPatternPatternAccessory[0].objAccessory.Code;// +objPatternPatternAccessory.objPatternAccessoryColor.Code;

                // HtmlGenericControl dvPatternAccessoryColor = (HtmlGenericControl)item.FindControl("dvPatternAccessoryColor");
                //  dvPatternAccessoryColor.Attributes.Add("style", "background-color: " );//+ objPatternPatternAccessory.objPatternAccessoryColor.ColorValue);

                //HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                //linkEdit.Attributes.Add("qid", objPatternPatternAccessory.ID.ToString());

                LinkButton linkDelete = (LinkButton)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objPatternPatternAccessory[0].ID.ToString());
            }
        }

        protected void dgPatternAccessories_onItemCommand(object sender, DataGridCommandEventArgs e)
        {
            string commandName = e.CommandName;

            switch (commandName)
            {
                case "Delete":
                    List<PatternSupportAccessoryBO> lst = (List<PatternSupportAccessoryBO>)Session["PatternAccessories"];

                    lst.RemoveAt(e.Item.ItemIndex);

                    dgPatternAccessories.DataSource = lst;
                    dgPatternAccessories.DataBind();
                    if (lst.Count < 1)
                    {
                        dvEmptyContentAccessory.Visible = true;
                        dvPatternAccessory.Visible = false;
                    }
                    //rfvPatternNumber.ValidationGroup.
                    //btnSaveChanges.CausesValidation = false;
                    //btnSaveChange.CausesValidation = false;
                    break;
                case "Edit":

                    break;
                default:
                    break;
            }
        }

        protected void ddlItemGroup_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (QueryID > 0)
                {
                    ViewState["PopulateSizeChart"] = true;
                    this.PopulateItemGroup();
                }
                else
                {
                    this.PopulateItemGroup();
                    this.PopulateGarmentSpec();
                }
            }

            this.collapse2.Attributes.Add("class", "accordion-body collapse in");
        }

        protected void rptrItemAtrribute_OnItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is ItemAttributeBO)
            {
                ItemAttributeBO objAttribute = (ItemAttributeBO)item.DataItem;

                Literal litItemAtributeName = (Literal)item.FindControl("litItemAtributeName");
                litItemAtributeName.Text = objAttribute.Name;

                DropDownList ddlSubAttributes = (DropDownList)item.FindControl("ddlSubAttributes");

                ItemAttributeBO objSubAttribute = new ItemAttributeBO();
                objSubAttribute.Parent = objAttribute.ID;
                objSubAttribute.Item = objAttribute.Item;

                //ddlSubAttributes.Items.Add(new ListItem("Select" + " " + lblItemAtributeName.Text, "0"));
                ddlSubAttributes.Items.Add(new ListItem("Select Sub Attribute", "0"));

                foreach (ItemAttributeBO itemAttribute in objSubAttribute.SearchObjects().OrderBy(o => o.Name))
                {
                    ddlSubAttributes.Items.Add(new ListItem(itemAttribute.Name, itemAttribute.ID.ToString()));
                }
                //Edit Mode
                if (QueryID > 0)
                {
                    PatternBO objPattern = new PatternBO();
                    objPattern.ID = QueryID;
                    objPattern.GetObject();
                    List<int> lstItem = objAttribute.ItemAttributesWhereThisIsParent.OrderBy(o => o.Name).Select(m => m.ID).ToList();
                    List<PatternItemAttributeSubBO> lstPatternItemAttributeSub = (from o in new PatternItemAttributeSubBO().SearchObjects()
                                                                                  where o.Pattern == objPattern.ID &&
                                                                                  lstItem.Contains(o.ItemAttribute)
                                                                                  select o).ToList();
                    if (lstPatternItemAttributeSub.Count > 0)
                    {
                        ddlSubAttributes.Items.FindByValue(lstPatternItemAttributeSub.First().ItemAttribute.ToString()).Selected = true;
                    }
                }
            }
        }

        protected void ddlSizeSet_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (QueryID > 0)
                {
                    ViewState["PopulateSizeChart"] = true;
                }
                else
                {
                    this.PopulateGarmentSpec();
                }

                this.collapse2.Attributes.Add("class", "accordion-body collapse in");
            }

            this.txtNickName.Text = this.hdnNickName.Value;
        }

        //protected void rptTemplatePatternImages_ItemDataBound(object sender, RepeaterItemEventArgs e)
        //{
        //    RepeaterItem item = e.Item;

        //    if (item.ItemIndex > -1 && item.DataItem is PatternTemplateImageBO)
        //    {
        //        string TemplateImgLocation = string.Empty;
        //        PatternTemplateImageBO objPatternTemplateImage = (PatternTemplateImageBO)item.DataItem;

        //        if (objPatternTemplateImage != null)
        //        {
        //            TemplateImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + this.QueryID.ToString() + "/" + objPatternTemplateImage.Filename + objPatternTemplateImage.Extension;

        //            if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + TemplateImgLocation))
        //                TemplateImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
        //        }
        //        else
        //        {
        //            TemplateImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
        //        }

        //        System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + TemplateImgLocation);
        //        SizeF origImageSize = VLOrigImage.PhysicalDimension;
        //        VLOrigImage.Dispose();

        //        List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 160);

        //        System.Web.UI.WebControls.Image imgTemplateImagePattern = (System.Web.UI.WebControls.Image)item.FindControl("imgTemplateImagePattern");
        //        imgTemplateImagePattern.ImageUrl = TemplateImgLocation;
        //        imgTemplateImagePattern.Width = int.Parse(lstImgDimensions[1].ToString());
        //        imgTemplateImagePattern.Height = int.Parse(lstImgDimensions[0].ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objPatternTemplateImage.ID.ToString());
        //        if (objPatternTemplateImage.objPattern.Parent == 0 || objPatternTemplateImage.objPattern.Parent == null)
        //            linkDelete.Visible = true;
        //        else
        //            linkDelete.Visible = false;
        //    }
        //}

        protected void btnActivateWS_Click(object sender, EventArgs e)
        {
            if (QueryID > 0)
            {
                try
                {
                    PatternBO objPattern = new PatternBO(this.ObjContext);
                    objPattern.ID = QueryID;
                    objPattern.GetObject();

                    WebServicePattern objWebServicePattern = new WebServicePattern();

                    using (TransactionScope ts = new TransactionScope())
                    {
                        if (objPattern.IsActiveWS == true)
                        {
                            objPattern.IsActiveWS = false;
                            objWebServicePattern.DeletePatternNumber = objPattern.Number;
                            objWebServicePattern.GUID = IndicoConfiguration.AppConfiguration.HttpPostGuid;
                            objWebServicePattern.DeleteDirectoriesGivenPattern(objPattern);
                            objWebServicePattern.Post(true);
                        }
                        else
                        {
                            objWebServicePattern.GUID = IndicoConfiguration.AppConfiguration.HttpPostGuid;
                            objWebServicePattern.img1 = objWebServicePattern.CreateImages(objPattern, "img1");
                            objWebServicePattern.img2 = objWebServicePattern.CreateImages(objPattern, "img2");
                            objWebServicePattern.img3 = objWebServicePattern.CreateImages(objPattern, "img3");
                            objWebServicePattern.img4 = objWebServicePattern.CreateImages(objPattern, "img4");
                            objWebServicePattern.pdf = objWebServicePattern.GeneratePDF(objPattern, true, "0");
                            objWebServicePattern.meas_xml = objWebServicePattern.WriteGramentSpecXML(objPattern);
                            objWebServicePattern.garment_des = (!string.IsNullOrEmpty(objPattern.Remarks)) ? objPattern.Remarks.ToString() : string.Empty;
                            objWebServicePattern.pat_no = objPattern.Number.ToString().Trim();
                            objWebServicePattern.s_desc = "";
                            objWebServicePattern.l_desc = (!string.IsNullOrEmpty(objPattern.Description)) ? objPattern.Description.ToString() : string.Empty;
                            objWebServicePattern.gen_cat = objPattern.objGender.Name;
                            objWebServicePattern.age_group = (objPattern.AgeGroup != null && objPattern.AgeGroup > 0) ? objPattern.objAgeGroup.Name : string.Empty;
                            objWebServicePattern.main_cat_id = objPattern.objCoreCategory.Name.Trim();
                            objWebServicePattern.sub_cat_id = "";
                            //objWebServicePattern.rating = "1";
                            //objWebServicePattern.times = "1";
                            objWebServicePattern.date_entered = DateTime.Now.ToString("yyyy-MM-dd");
                            objWebServicePattern.Post(false);

                            objPattern.IsActiveWS = true;
                        }
                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                catch (Exception)
                {

                    throw;
                }


                this.PopulateControls();
            }
        }

        protected void btnDeleteSizeset_Click(object sender, EventArgs e)
        {
            if (QueryID > 0)
            {
                PatternBO objPattern = new PatternBO();
                objPattern.ID = QueryID;
                objPattern.GetObject();
                if (objPattern.SizeChartsWhereThisIsPattern.Count > 0)
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        foreach (SizeChartBO sChart in objPattern.SizeChartsWhereThisIsPattern)
                        {
                            SizeChartBO objSizeChart = new SizeChartBO(this.ObjContext);
                            objSizeChart.ID = sChart.ID;
                            objSizeChart.GetObject();

                            objSizeChart.Delete();

                            this.ObjContext.SaveChanges();
                        }
                        ts.Complete();
                    }
                }
            }
            this.PopulateGarmentSpec();
            ViewState["PopulateSizeChart"] = false;
        }

        protected void cfvPatternNumber_OnValidate(object sender, ServerValidateEventArgs e)
        {
            //List<PatternBO> lstPattern = new List<PatternBO>();
            //if (!String.IsNullOrEmpty(this.txtPatternNumber.Text))
            //{
            //    PatternBO objpat = new PatternBO();
            //    objpat.IsActive = true;

            //    lstPattern = (from o in objpat.SearchObjects().Where(o => o.Number.ToLower().Trim() == this.txtPatternNumber.Text.ToLower().Trim() &&
            //                                                                         o.ID != this.QueryID
            //                                                                        )
            //                  select o).ToList();
            //}
            //e.IsValid = !(lstPattern.Count > 0);

            try
            {
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(this.QueryID, "Pattern", "Number", this.txtPatternNumber.Text);
                e.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on AddEditPattern.aspx", ex);
            }
        }

        protected void btnDeleteGarmentMeasurement_OnClick(object sender, EventArgs e)
        {
            int tempImgID = int.Parse(this.hdnGarmentImage.Value);

            if (tempImgID > 0)
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    PatternTemplateImageBO objPatternTemplateImage = new PatternTemplateImageBO(this.ObjContext);
                    objPatternTemplateImage.ID = tempImgID;
                    objPatternTemplateImage.GetObject();

                    objPatternTemplateImage.Delete();

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }

                //delete the Image 

                if (this.QueryID > 0)
                {
                    PatternTemplateImageBO objPatternTemplateImage = new PatternTemplateImageBO();
                    objPatternTemplateImage.ID = tempImgID;
                    objPatternTemplateImage.GetObject();

                    string imagePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + this.QueryID.ToString() + "/" + objPatternTemplateImage.Filename + objPatternTemplateImage.Extension;
                    File.Delete(Server.MapPath(imagePath));
                }

            }

            PopulatePatternTemplates(0);

            this.collapse6.Attributes.Add("class", "accordion-body collapse in");
        }

        protected void dgPatternHistory_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is PatternHistoryBO)
            {
                PatternHistoryBO objPatternHistory = (PatternHistoryBO)item.DataItem;

                Literal litModifier = (Literal)item.FindControl("litModifier");
                litModifier.Text = objPatternHistory.objModifier.GivenName + " " + objPatternHistory.objModifier.FamilyName;

                Literal litModifiedDate = (Literal)item.FindControl("litModifiedDate");
                litModifiedDate.Text = objPatternHistory.ModifiedDate.ToString("HH:mm / dd MMMM yyyy");

                Literal litPattern = (Literal)item.FindControl("litPattern");
                litPattern.Text = objPatternHistory.objPattern.Number;

                Literal litMeassage = (Literal)item.FindControl("litMeassage");
                litMeassage.Text = (objPatternHistory.Meassage != null || objPatternHistory.Meassage != string.Empty) ? objPatternHistory.Meassage : string.Empty;
            }
        }

        protected void btnNo_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                Response.Redirect(Request.RawUrl);
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            this.ddlItemSubGroup.Items.Add(new ListItem("To select a sub group, first select an item group", "0"));
            //16/07/2012  this.ddlItemAttribute.Items.Add(new ListItem("To select an attribute, first select an item group", "0"));
            //16/07/2012  this.ddlItemAttribute.Enabled = (this.QueryID > 0);

            this.ddlItemSubGroup.Enabled = (this.QueryID > 0);

            ViewState["isPopulate"] = false;
            ViewState["PopulateAccessoryUI"] = false;

            this.litHeaderText.Text = this.ActivePage.Heading;
            this.btnActivateWS.Visible = false;
            this.dvEmptyContentPatternTemplates.Visible = false;
            this.dvPatternTemplates.Visible = false;
            this.fsTemplateImages.Visible = this.IsEditMode;

            this.chbIsActive.Checked = true;
            this.dvItemAttributes.Visible = false;
            //Populate Item Groups
            this.ddlItemGroup.Items.Clear();
            this.ddlItem.Items.Clear();
            this.ddlItemGroup.Items.Add(new ListItem("Select an item group", "0"));
            this.ddlItem.Items.Add(new ListItem("Select Item", "0"));
            List<ItemBO> lstItems = (new ItemBO()).GetAllObject().Where(o => o.Parent == 0).OrderBy(o => o.Name).ToList();
            foreach (ItemBO item in lstItems)
            {
                this.ddlItemGroup.Items.Add(new ListItem(item.Name, item.ID.ToString()));
                this.ddlItem.Items.Add(new ListItem(item.Name, item.ID.ToString())); //Pop up item dropdown
            }

            // Populate pattern supplier dropdownlist
            this.ddlSupplier.Items.Add(new ListItem("Select a supplier", "0"));
            List<PatternSupplierBO> lstSuppliers = (new PatternSupplierBO()).SearchObjects();
            foreach (PatternSupplierBO item in lstSuppliers)
            {
                this.ddlSupplier.Items.Add(new ListItem(item.Name, item.ID.ToString()));
            }

            // Populate Item sub attributes and select the values

            //Populate Gender
            this.ddlGender.Items.Clear();
            this.ddlGender.Items.Add(new ListItem("Select Gender", "0"));
            List<GenderBO> lstGenders = (new GenderBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (GenderBO gender in lstGenders)
            {
                this.ddlGender.Items.Add(new ListItem(gender.Name, gender.ID.ToString()));
            }

            //Polulate Age Group
            this.ddlAgeGroup.Items.Clear();
            this.ddlAgeGroup.Items.Add(new ListItem("Select Age Group", "0"));
            List<AgeGroupBO> lstAgeGroup = (new AgeGroupBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (AgeGroupBO ageGroup in lstAgeGroup)
            {
                this.ddlAgeGroup.Items.Add(new ListItem(ageGroup.Name, ageGroup.ID.ToString()));
            }

            //Populate Size Set
            this.ddlSizeSet.Items.Clear();
            this.ddlSizeSet.Items.Add(new ListItem("Select Size Set", "0"));
            List<SizeSetBO> lstSizeSet = (new SizeSetBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (SizeSetBO sizeSet in lstSizeSet)
            {
                this.ddlSizeSet.Items.Add(new ListItem(sizeSet.Name, sizeSet.ID.ToString()));
            }

            //Populate Core Category & other categiries
            this.ddlCoreCategory.Items.Clear();
            this.lstOtherCategories.Items.Clear();
            this.ddlCoreCategory.Items.Add(new ListItem("Select Core Category", "0"));
            List<CategoryBO> lstCategories = (new CategoryBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (CategoryBO category in lstCategories)
            {
                this.ddlCoreCategory.Items.Add(new ListItem(category.Name, category.ID.ToString()));
                this.lstOtherCategories.Items.Add(new ListItem(category.Name, category.ID.ToString()));
            }

            //Populate Print Type
            this.ddlPrintType.Items.Clear();
            this.ddlPrintType.Items.Add(new ListItem("Select Printer Type", "0"));
            List<PrinterTypeBO> lstPrintTypes = (new PrinterTypeBO()).GetAllObject();
            foreach (PrinterTypeBO printType in lstPrintTypes)
            {
                ddlPrintType.Items.Add(new ListItem(printType.Name, printType.ID.ToString()));
            }

            //Populate Production Line
            this.ddlProductionLine.Items.Clear();
            this.ddlProductionLine.Items.Add(new ListItem("Select Production Line", "0"));
            List<ProductionLineBO> lstProLines = (new ProductionLineBO()).GetAllObject();
            foreach (ProductionLineBO objPL in lstProLines)
            {
                ddlProductionLine.Items.Add(new ListItem(objPL.Name, objPL.ID.ToString()));
            }

            //Populate Pattern Accessory
            this.ddlPatternAccessoryCategory.Items.Clear();
            this.ddlPatternAccessoryCategory.Items.Add(new ListItem("Select Category", "0"));
            List<AccessoryCategoryBO> lstPatternAccessoryCategory = (new AccessoryCategoryBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (AccessoryCategoryBO acccat in lstPatternAccessoryCategory)
            {
                ddlPatternAccessoryCategory.Items.Add(new ListItem(acccat.Name, acccat.ID.ToString()));
            }

            // populate Units
            this.ddlUnits.Items.Clear();
            this.ddlUnits.Items.Add(new ListItem("Select an Unit", "0"));
            List<UnitBO> lstUnits = (new UnitBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (UnitBO unit in lstUnits)
            {
                this.ddlUnits.Items.Add(new ListItem(unit.Name, unit.ID.ToString()));
            }

            this.lblGarmentSpecStatus.Visible = (this.QueryID > 0) ? true : false;

            this.PopulatePatternTemplateImages();
            this.PopulatePatternCompressionImage();

            if (this.QueryID > 0)
            {
                this.ResetDropdowns();

                ViewState["PopulateNickName"] = true;

                if (this.IsEditMode)
                {
                    this.PopulatePatternTemplates(0);
                }

                PatternBO objPattern = new PatternBO();
                objPattern.ID = this.QueryID;
                objPattern.GetObject(false);

                this.litHeaderText.Text += "-" + objPattern.Number;

                this.fsTemplateImages.Visible = (objPattern.Parent == 0 || objPattern.Parent == null) ? true : false;
                //this.fsPatternTemplateImages.Visible = (objPattern.Parent == 0 || objPattern.Parent == null) ? true : false;

                this.txtPatternNumber.Enabled = ((this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.FactoryAdministrator) && (objPattern.IsActiveWS != true)) ? true : false;


                //Populate rptItemAttribute on edit mode
                List<ItemAttributeBO> lstItemAttributes = objPattern.objItem.ItemAttributesWhereThisIsItem.OrderBy(o => o.Name).Where(o => o.Parent == 0).ToList();
                if (lstItemAttributes.Count > 0)
                {
                    this.dvItemAttributes.Visible = true;
                    this.rptItemAttribute.DataSource = lstItemAttributes;
                    this.rptItemAttribute.DataBind();
                }
                else
                {
                    this.dvItemAttributes.Visible = false;
                }
                //Populate ItemSubGroup
                this.ddlItemSubGroup.Items.Clear();
                this.ddlItemSubGroup.Items.Add(new ListItem("Select Sub Item", "0"));
                List<ItemBO> lstSubItems = ((new ItemBO()).GetAllObject()).Where(o => o.Parent == objPattern.Item).OrderBy(o => o.Name).ToList();
                foreach (ItemBO subItem in lstSubItems)
                {
                    this.ddlItemSubGroup.Items.Add(new ListItem(subItem.Name, subItem.ID.ToString()));
                }

                this.chbIsActive.Checked = objPattern.IsActive;
                this.txtPatternNumber.Text = objPattern.Number;
                this.txtNickName.Text = objPattern.NickName;
                this.hdnNickName.Value = objPattern.NickName;
                this.txtDescription.Text = objPattern.Remarks;
                this.txtOriginRef.Text = objPattern.OriginRef;
                this.ddlItemGroup.Items.FindByValue(objPattern.Item.ToString()).Selected = true;
                //16/07/2012 this.ddlItemAttribute.Items.FindByValue(objPattern.ItemAttribute.ToString()).Selected = true;                
                this.ddlItemSubGroup.SelectedValue = (objPattern.SubItem != null) ? objPattern.SubItem.Value.ToString() : "0";
                this.ddlGender.Items.FindByValue(objPattern.Gender.ToString()).Selected = true;
                this.ddlAgeGroup.Items.FindByValue(objPattern.AgeGroup.ToString()).Selected = true;

                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(0, "VisualLayout", "Pattern", objPattern.ID.ToString());
                this.ddlSizeSet.Items.FindByValue(objPattern.SizeSet.ToString()).Selected = true;

                this.ddlSizeSet.Enabled = ancAddNewSizeSet.Visible = objReturnInt.RetVal == 1;
                this.ddlGender.Enabled = ancAddNewAgeGroup.Visible = objReturnInt.RetVal == 1;
                this.ddlAgeGroup.Enabled =  objReturnInt.RetVal == 1;

                this.ddlCoreCategory.Items.FindByValue(objPattern.CoreCategory.ToString()).Selected = true;
                this.ddlPrintType.Items.FindByValue(objPattern.PrinterType.ToString()).Selected = true;
                this.txtKeyWords.Text = objPattern.Keywords;
                this.txtCorrespondingPattern.Text = objPattern.CorePattern;
                this.txtFactoryDescription.Text = objPattern.FactoryDescription;
                this.txtConsumption.Text = objPattern.Consumption;
                this.txtConvertionFactor.Text = objPattern.ConvertionFactor.ToString();
                this.txtSpecialAttributes.Text = objPattern.SpecialAttributes;
                this.txtNotes.Text = objPattern.PatternNotes;
                this.ddlUnits.SelectedValue = (objPattern.Unit != null) ? objPattern.Unit.Value.ToString() : "0";
                this.txtSMV.Text = (objPattern.SMV != null) ? Convert.ToDecimal(objPattern.SMV.ToString()).ToString("0.00") : "0";
                this.chkCoreRange.Checked = objPattern.IsCoreRange;
                this.txtMarketingDescription.Text = objPattern.Description;
                this.ddlSupplier.Items.FindByValue(objPattern.PatternSupplier.ToString()).Selected = true;

                //if (objPattern.ProductionLine.HasValue && objPattern.ProductionLine ?? 0 > 0) {
                //    this.ddlPrintType.Items.FindByValue(objPattern.ProductionLine.Value.ToString()).Selected = true;
                //}

                // populate HT CODE
                if (objPattern.SubItem != null)
                {
                    HSCodeBO objHSCode = new HSCodeBO();
                    objHSCode.ItemSubCategory = objPattern.SubItem.Value;
                    objHSCode.Gender = objPattern.Gender;

                    List<HSCodeBO> lstHTCodes = objHSCode.SearchObjects();

                    if (lstHTCodes.Any())
                    {
                        this.txtHtsCode.Text = lstHTCodes[0].Code;
                    }
                }
                //this.txtHtsCode.Text = objPattern.HTSCode;
                //if (this.IsEditMode)
                //    this.chkIsTemplate.Checked = objPattern.IsTemplate;

                //populate other categories
                foreach (CategoryBO category in objPattern.PatternOtherCategorysWhereThisIsPattern)
                {
                    this.lstOtherCategories.Items.FindByValue(category.ID.ToString()).Selected = true;
                }

                //populate Pattern History
                PatternHistoryBO objPatternHistory = new PatternHistoryBO();
                objPatternHistory.Pattern = this.QueryID;
                List<PatternHistoryBO> lstPatternHistory = objPatternHistory.SearchObjects().OrderBy(o => o.ModifiedDate).ToList();

                if (lstPatternHistory.Count > 0)
                {
                    this.dgPatternHistory.Visible = true;
                    this.dgPatternHistory.DataSource = lstPatternHistory;
                    this.dgPatternHistory.DataBind();
                    this.dvNoteEmptyContentPHistory.Visible = false;
                }
                else
                {
                    this.dgPatternHistory.Visible = false;
                    this.dvNoteEmptyContentPHistory.Visible = true;
                }

                this.PopulatePatternAccessory();
                this.PopulateGarmentSpec();

                Session["PatternDetails"] = objPattern;
            }
        }

        private void ProcessForm()
        {
            try
            {
                PatternBO objPattern = new PatternBO(this.ObjContext);
                List<int> deleteItemAttributeSubs = new List<int>();

                if (this.QueryID > 0 && this.IsEditMode)
                {
                    objPattern.ID = this.QueryID;
                    objPattern.GetObject();
                }

                using (TransactionScope ts = new TransactionScope())
                {
                    #region Create Pattern

                    objPattern.IsActive = this.chbIsActive.Checked;
                    //objPattern.HTSCode = this.txtHtsCode.Text;
                    objPattern.Number = this.txtPatternNumber.Text.Trim();
                    objPattern.NickName = (!string.IsNullOrEmpty(this.hdnNickName.Value)) ? this.hdnNickName.Value.Trim() : this.txtNickName.Text.Trim(); //this.txtNickName.Text.Trim();
                    objPattern.Remarks = this.txtDescription.Text.Trim();
                    objPattern.OriginRef = this.txtOriginRef.Text.Trim();
                    objPattern.Item = int.Parse(this.ddlItemGroup.SelectedValue);

                    //**SDS objPattern.ItemAttribute = int.Parse(this.ddlItemAttribute.SelectedValue);
                    // Save Item Sub Attributes

                    List<PatternItemAttributeSubBO> lstPatternItemAttributeSub = (from o in (new PatternItemAttributeSubBO()).SearchObjects() where o.Pattern == QueryID select o).ToList();
                    List<int> currentSelected = new List<int>();
                    foreach (RepeaterItem item in this.rptItemAttribute.Items)
                    {
                        PatternItemAttributeSubBO subAttribute = new PatternItemAttributeSubBO(this.ObjContext);
                        DropDownList ddlSubAttributes = (DropDownList)item.FindControl("ddlSubAttributes");

                        if (ddlSubAttributes != null)
                        {
                            int itemAttr = int.Parse(ddlSubAttributes.SelectedValue);
                            if (itemAttr != 0)
                            {
                                currentSelected.Add(itemAttr);
                            }
                        }
                    }

                    foreach (PatternItemAttributeSubBO sub in lstPatternItemAttributeSub)
                    {
                        if (!currentSelected.Contains(sub.ItemAttribute))
                        {
                            deleteItemAttributeSubs.Add(sub.ID);
                            /*   PatternItemAttributeSubBO delete = new PatternItemAttributeSubBO(this.ObjContext);
                               delete.ID = sub.ID;
                               delete..GetObject(); */

                            //**  objPattern.PatternItemAttributeSubsWhereThisIsPattern.Remove(delete); 
                        }
                    }

                    foreach (int i in currentSelected)
                    {
                        if (!lstPatternItemAttributeSub.Exists(o => o.ItemAttribute == i))
                        {
                            PatternItemAttributeSubBO sub = new PatternItemAttributeSubBO(this.ObjContext);
                            sub.ItemAttribute = i;
                            objPattern.PatternItemAttributeSubsWhereThisIsPattern.Add(sub);
                        }
                    }

                    objPattern.SubItem = int.Parse(this.ddlItemSubGroup.SelectedValue);
                    objPattern.Gender = int.Parse(this.ddlGender.SelectedValue);
                    objPattern.AgeGroup = int.Parse(this.ddlAgeGroup.SelectedValue);
                    objPattern.SizeSet = int.Parse(this.ddlSizeSet.SelectedValue);
                    objPattern.FactoryDescription = this.txtDescription.Text.Trim();
                    objPattern.CoreCategory = int.Parse(this.ddlCoreCategory.SelectedValue);
                    objPattern.Unit = int.Parse(this.ddlUnits.SelectedValue);
                    objPattern.SMV = (!string.IsNullOrEmpty(this.txtSMV.Text)) ? Convert.ToDecimal(this.txtSMV.Text) : 0;
                    objPattern.IsCoreRange = this.chkCoreRange.Checked;
                    objPattern.Description = (!string.IsNullOrEmpty(this.txtMarketingDescription.Text)) ? this.txtMarketingDescription.Text : string.Empty;
                    objPattern.PatternSupplier = int.Parse(this.ddlSupplier.SelectedValue);

                    //Delete Pattern OtherCategories 
                    if (QueryID > 0 && objPattern.PatternOtherCategorysWhereThisIsPattern.Count > 0)
                    {
                        foreach (CategoryBO patternCategory in objPattern.PatternOtherCategorysWhereThisIsPattern.ToList())
                        {
                            CategoryBO objCat = new CategoryBO(this.ObjContext);
                            objCat.ID = patternCategory.ID;
                            objCat.GetObject();

                            objPattern.PatternOtherCategorysWhereThisIsPattern.Remove(objCat);
                        }

                    }

                    foreach (ListItem item in lstOtherCategories.Items)
                    {
                        if (item.Selected)
                        {
                            CategoryBO objCategory = new CategoryBO(this.ObjContext);
                            objCategory.ID = int.Parse(item.Value);
                            objCategory.GetObject();

                            objPattern.PatternOtherCategorysWhereThisIsPattern.Add(objCategory);
                        }
                    }

                    objPattern.PrinterType = int.Parse(this.ddlPrintType.SelectedValue);
                    objPattern.Keywords = this.txtKeyWords.Text.Trim();
                    objPattern.CorePattern = this.txtCorrespondingPattern.Text.Trim();
                    objPattern.FactoryDescription = this.txtFactoryDescription.Text.Trim();
                    objPattern.Consumption = this.txtConsumption.Text.Trim();
                    objPattern.ConvertionFactor = decimal.Parse(this.txtConvertionFactor.Text.Trim());
                    objPattern.SpecialAttributes = this.txtSpecialAttributes.Text.Trim();
                    objPattern.PatternNotes = this.txtNotes.Text.Trim();
                    if (QueryID == 0)
                    {
                        objPattern.Creator = this.LoggedUser.ID;
                        objPattern.CreatedDate = DateTime.Now;
                        objPattern.GUID = Guid.NewGuid().ToString();
                    }
                    objPattern.Modifier = this.LoggedUser.ID;
                    objPattern.ModifiedDate = DateTime.Now;

                    if (!this.IsEditMode)
                        objPattern.Parent = this.QueryID;

                    #endregion

                    #region Save Template Images

                    if (this.hdnUploadFiles.Value != "0")
                    {
                        int n = 0;
                        foreach (string fileName in this.hdnUploadFiles.Value.Split('|').Select(o => o.Split(',')[0]))
                        {
                            if (fileName != string.Empty)
                            {
                                n++;
                                PatternTemplateImageBO objPatternTemplateImage = new PatternTemplateImageBO(this.ObjContext);
                                objPatternTemplateImage.Filename = Path.GetFileNameWithoutExtension(fileName);
                                objPatternTemplateImage.Extension = Path.GetExtension(fileName);
                                objPatternTemplateImage.Size = (int)(new FileInfo(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileName)).Length;
                                objPatternTemplateImage.IsHero = true;
                                // if (this.QueryID == 0)
                                int z = objPatternTemplateImage.Pattern;

                                var patternCount = (from o in (new PatternTemplateImageBO()).SearchObjects()
                                                    where o.Pattern == objPattern.ID
                                                    select o.Pattern).ToList();
                                if (patternCount.Count == 0)
                                {
                                    objPatternTemplateImage.IsHero = (n == 1) ? true : false;
                                }
                                objPattern.PatternTemplateImagesWhereThisIsPattern.Add(objPatternTemplateImage);
                                this.ObjContext.SaveChanges();
                            }
                        }
                    }

                    // Upload Photo Image One 

                    if (this.hdnPhotoImageOne.Value != "0")
                    {

                        foreach (string fileTemplateName in this.hdnPhotoImageOne.Value.Split('|').Select(o => o.Split(',')[0]))
                        {
                            if (fileTemplateName != string.Empty)
                            {
                                PatternTemplateImageBO objPatternTemplateImage = new PatternTemplateImageBO(this.ObjContext);
                                objPatternTemplateImage.Filename = Path.GetFileNameWithoutExtension(fileTemplateName);
                                objPatternTemplateImage.Extension = Path.GetExtension(fileTemplateName);
                                objPatternTemplateImage.Size = (int)(new FileInfo(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileTemplateName)).Length;
                                objPatternTemplateImage.IsHero = false;
                                objPatternTemplateImage.ImageOrder = 1;
                                int z = objPatternTemplateImage.Pattern;

                                objPattern.PatternTemplateImagesWhereThisIsPattern.Add(objPatternTemplateImage);
                                this.ObjContext.SaveChanges();
                            }
                        }
                    }

                    // Upload Photo Image Two

                    if (this.hdnPhotoImageTwo.Value != "0")
                    {
                        foreach (string fileTemplateName in this.hdnPhotoImageTwo.Value.Split('|').Select(o => o.Split(',')[0]))
                        {
                            if (fileTemplateName != string.Empty)
                            {

                                PatternTemplateImageBO objPatternTemplateImage = new PatternTemplateImageBO(this.ObjContext);
                                objPatternTemplateImage.Filename = Path.GetFileNameWithoutExtension(fileTemplateName);
                                objPatternTemplateImage.Extension = Path.GetExtension(fileTemplateName);
                                objPatternTemplateImage.Size = (int)(new FileInfo(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileTemplateName)).Length;
                                objPatternTemplateImage.IsHero = false;
                                objPatternTemplateImage.ImageOrder = 2;
                                int z = objPatternTemplateImage.Pattern;

                                objPattern.PatternTemplateImagesWhereThisIsPattern.Add(objPatternTemplateImage);
                                this.ObjContext.SaveChanges();
                            }
                        }
                    }

                    // Upload Photo Image Three

                    if (this.hdnPhotoImageThree.Value != "0")
                    {
                        foreach (string fileTemplateName in this.hdnPhotoImageThree.Value.Split('|').Select(o => o.Split(',')[0]))
                        {
                            if (fileTemplateName != string.Empty)
                            {

                                PatternTemplateImageBO objPatternTemplateImage = new PatternTemplateImageBO(this.ObjContext);
                                objPatternTemplateImage.Filename = Path.GetFileNameWithoutExtension(fileTemplateName);
                                objPatternTemplateImage.Extension = Path.GetExtension(fileTemplateName);
                                objPatternTemplateImage.Size = (int)(new FileInfo(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileTemplateName)).Length;
                                objPatternTemplateImage.IsHero = false;
                                objPatternTemplateImage.ImageOrder = 3;
                                int z = objPatternTemplateImage.Pattern;

                                objPattern.PatternTemplateImagesWhereThisIsPattern.Add(objPatternTemplateImage);
                                this.ObjContext.SaveChanges();
                            }
                        }
                    }


                    #endregion

                    #region Save Pattern Accessories

                    //List<int> lstPatternPatternAccessoryIDs = objPattern.PatternSupportAccessorysWhereThisIsPattern.Select(o => o.ID).ToList();

                    //foreach (DataGridItem item in this.dgPatternAccessories.Items)
                    //{
                    //    HiddenField hdnPatternPatternAccessoryID = (HiddenField)item.FindControl("hdnPatternPatternAccessoryID");
                    //    int PatternPatternAccessoryID = int.Parse(hdnPatternPatternAccessoryID.Value);

                    //    if ((lstPatternPatternAccessoryIDs.Count == 0) || !(lstPatternPatternAccessoryIDs.Contains(PatternPatternAccessoryID))) //New Accessry
                    //    {
                    //        Label lblPatternAccessory = (Label)item.FindControl("lblPatternAccessory");
                    //        Label lblPatternAccessoryCategory = (Label)item.FindControl("lblPatternAccessoryCategory");
                    //        Label lblPatternAccessoryColor = (Label)item.FindControl("lblPatternAccessoryColor");

                    //        PatternSupportAccessoryBO objPatternAccessory = new PatternSupportAccessoryBO(this.ObjContext);

                    //        objPatternAccessory.Accessory = int.Parse(lblPatternAccessory.Attributes["qid"]);
                    //        // objPatternAccessory.AccessoryColor = int.Parse(lblPatternAccessoryColor.Attributes["qid"]);
                    //        objPattern.PatternSupportAccessorysWhereThisIsPattern.Add(objPatternAccessory);
                    //    }

                    //    lstPatternPatternAccessoryIDs.Remove(PatternPatternAccessoryID);
                    //}

                    //if (lstPatternPatternAccessoryIDs.Count > 0)
                    //{
                    //    foreach (int id in lstPatternPatternAccessoryIDs)
                    //    {
                    //        PatternSupportAccessoryBO objPatternPatternAccessory = new PatternSupportAccessoryBO(this.ObjContext);
                    //        objPatternPatternAccessory.ID = id;
                    //        objPatternPatternAccessory.GetObject();

                    //        objPattern.PatternSupportAccessorysWhereThisIsPattern.Remove(objPatternPatternAccessory);
                    //        objPatternPatternAccessory.Delete();
                    //    }
                    //}

                    #endregion

                    #region Save Garment Spec
                    string status = string.Empty;
                    //Delete Old Spec
                    if (this.QueryID > 0)
                    {
                        PatternBO objPatternTemp = new PatternBO();
                        objPatternTemp.ID = this.QueryID;
                        objPatternTemp.GetObject();

                        if (objPatternTemp.Item != objPattern.Item || objPatternTemp.SizeSet != objPattern.SizeSet)
                        {
                            foreach (SizeChartBO sizeChart in objPattern.SizeChartsWhereThisIsPattern)
                            {
                                SizeChartBO obj = new SizeChartBO(this.ObjContext);
                                obj.ID = sizeChart.ID;
                                obj.GetObject();

                                obj.Delete();
                                //this.ObjContext.SaveChanges();
                            }
                        }
                    }

                    bool havingZeros = false;
                    bool havingValues = false;
                    decimal count = 0;

                    //Save New Spec
                    foreach (RepeaterItem SpecMLitem in this.rptSpecML.Items)
                    {
                        Repeater rptSpecSizeQty = (Repeater)SpecMLitem.FindControl("rptSpecSizeQty");
                        foreach (RepeaterItem SpecSizeQtyitem in rptSpecSizeQty.Items)
                        {
                            TextBox txtQty = (TextBox)SpecSizeQtyitem.FindControl("txtQty");

                            int SizeChartId = int.Parse(txtQty.Attributes["qid"]);
                            int MLId = int.Parse(txtQty.Attributes["MLID"]);
                            int SizeId = int.Parse(txtQty.Attributes["SID"]);

                            SizeChartBO objSizeChart = new SizeChartBO(this.ObjContext);

                            if (SizeChartId > 0)
                            {
                                objSizeChart.ID = SizeChartId;
                                objSizeChart.GetObject();
                            }

                            objPattern.SizeChartsWhereThisIsPattern.Add(objSizeChart);
                            objSizeChart.MeasurementLocation = MLId;
                            objSizeChart.Size = SizeId;
                            objSizeChart.Val = decimal.Parse((txtQty.Text.Trim() == string.Empty) ? "0.00" : txtQty.Text.Trim());

                            count += objSizeChart.Val;

                            //------------------------------------------
                            if (objSizeChart.Val != 0)
                            {
                                havingValues = true;
                            }
                            else
                            {
                                havingZeros = true;
                            }
                            //-----------------------------------------------


                            /*if (SizeChartId == 0)
                                objSizeChart.Add();

                            this.ObjContext.SaveChanges();*/
                        }
                    }

                    //-----------------------------------------------------------
                    if (havingValues == true && havingZeros == true)
                    {
                        status = "Partialy Completed";
                    }

                    if (havingValues == true && havingZeros == false)
                    {
                        status = "Completed";
                    }

                    if (havingValues == false && havingZeros == true)
                    {
                        status = "Not Completed";
                    }
                    //-------------------------------------------------------------


                    objPattern.GarmentSpecStatus = (status != string.Empty) ? status : "Spec Missing";

                    this.ObjContext.SaveChanges();

                    //this.UpdateWebService(objPattern);
                    #endregion

                    #region Pattern Compression Image

                    if (chkDisplayCompressionImage.Checked)
                    {
                        if (!String.IsNullOrEmpty(this.hdnCompressionImage.Value))
                        {
                            try
                            {
                                if ((objPattern.PatternCompressionImage ?? 0) > 0)
                                {
                                    PatternCompressionImageBO objPCIOld = new PatternCompressionImageBO(this.ObjContext);
                                    objPCIOld.ID = objPattern.PatternCompressionImage ?? 0;
                                    objPCIOld.GetObject();
                                    objPCIOld.Delete();
                                }

                                string[] fileNames = (this.hdnCompressionImage.Value.Trim()).Split(',');
                                string fileName = Path.GetFileName(fileNames[0]);

                                PatternCompressionImageBO objPCI = new PatternCompressionImageBO(this.ObjContext);
                                objPCI.Filename = Path.GetFileName(fileNames[0]);
                                objPCI.Extension = Path.GetExtension(fileNames[0]);

                                //this.ObjContext.SaveChanges();
                                //objPattern.PatternCompressionImage = objPCI.ID;
                                objPCI.PatternsWhereThisIsPatternCompressionImage.Add(objPattern);
                            }
                            catch (Exception ex)
                            {

                            }
                        }
                    }
                    else
                    {
                        if ((objPattern.PatternCompressionImage ?? 0) > 0)
                        {
                            PatternCompressionImageBO objPCIOld = new PatternCompressionImageBO(this.ObjContext);
                            objPCIOld.ID = objPattern.PatternCompressionImage ?? 0;
                            objPCIOld.GetObject();
                            objPCIOld.Delete();
                        }
                    }

                    #endregion

                    #region Pattern History

                    PatternHistoryBO objPatternHistory = new PatternHistoryBO(this.ObjContext);
                    objPatternHistory.Modifier = LoggedUser.ID;
                    objPatternHistory.ModifiedDate = DateTime.Now;
                    objPatternHistory.Meassage = (this.QueryID == 0) ? "This Pattern had been Created " + DateTime.Now.ToString("dd MMMM yyyy") : this.GetPatternModifiedDetails();
                    objPattern.PatternHistorysWhereThisIsPattern.Add(objPatternHistory);

                    this.ObjContext.SaveChanges();

                    #endregion

                    // Delete removed sub item attributes
                    foreach (int i in deleteItemAttributeSubs)
                    {
                        PatternItemAttributeSubBO delete = new PatternItemAttributeSubBO(this.ObjContext);
                        delete.ID = i;
                        delete.GetObject();

                        delete.Delete();
                    }

                    this.ObjContext.SaveChanges();

                    ts.Complete();
                    ts.Dispose();
                    AddPatternToDevelopment(objPattern.ID);
                }

                #region Copy Template Images

                string sourceFileLocation = string.Empty;
                string destinationFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\PatternTemplates\\" + objPattern.ID.ToString();
                if (this.hdnUploadFiles.Value != "0")
                {

                    // Save Garment Specification Image
                    foreach (string fileName in this.hdnUploadFiles.Value.Split('|').Select(o => o.Split(',')[0]))
                    {
                        sourceFileLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileName;

                        if (fileName != string.Empty)
                        {
                            if (File.Exists(destinationFolderPath + "\\" + fileName))
                            {
                                File.Delete(destinationFolderPath + "\\" + fileName);
                            }
                            else
                            {
                                if (!Directory.Exists(destinationFolderPath))
                                    Directory.CreateDirectory(destinationFolderPath);
                                File.Copy(sourceFileLocation, destinationFolderPath + "\\" + fileName);
                            }
                        }
                    }
                }
                // Save Photo Image One
                if (this.hdnPhotoImageOne.Value != "0")
                {
                    foreach (string fileTemplateName in this.hdnPhotoImageOne.Value.Split('|').Select(o => o.Split(',')[0]))
                    {
                        sourceFileLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileTemplateName;

                        if (fileTemplateName != string.Empty)
                        {
                            if (File.Exists(destinationFolderPath + "\\" + fileTemplateName))
                            {
                                File.Delete(destinationFolderPath + "\\" + fileTemplateName);
                            }
                            else
                            {
                                if (!Directory.Exists(destinationFolderPath))
                                    Directory.CreateDirectory(destinationFolderPath);
                                File.Copy(sourceFileLocation, destinationFolderPath + "\\" + fileTemplateName);
                            }
                        }
                    }
                }
                // Save Photo Image Two
                if (this.hdnPhotoImageTwo.Value != "0")
                {
                    foreach (string fileTemplateName in this.hdnPhotoImageTwo.Value.Split('|').Select(o => o.Split(',')[0]))
                    {
                        sourceFileLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileTemplateName;

                        if (fileTemplateName != string.Empty)
                        {
                            if (File.Exists(destinationFolderPath + "\\" + fileTemplateName))
                            {
                                File.Delete(destinationFolderPath + "\\" + fileTemplateName);
                            }
                            else
                            {
                                if (!Directory.Exists(destinationFolderPath))
                                    Directory.CreateDirectory(destinationFolderPath);
                                File.Copy(sourceFileLocation, destinationFolderPath + "\\" + fileTemplateName);
                            }
                        }
                    }
                }

                // Save Photo Image Three 
                if (this.hdnPhotoImageThree.Value != "0")
                {
                    foreach (string fileTemplateName in this.hdnPhotoImageThree.Value.Split('|').Select(o => o.Split(',')[0]))
                    {
                        sourceFileLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileTemplateName;

                        if (fileTemplateName != string.Empty)
                        {
                            if (File.Exists(destinationFolderPath + "\\" + fileTemplateName))
                            {
                                File.Delete(destinationFolderPath + "\\" + fileTemplateName);
                            }
                            else
                            {
                                if (!Directory.Exists(destinationFolderPath))
                                    Directory.CreateDirectory(destinationFolderPath);
                                File.Copy(sourceFileLocation, destinationFolderPath + "\\" + fileTemplateName);
                            }
                        }
                    }
                }
                #endregion

                #region Copy Pattern Compression Images

                string physicalFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\PatternCompressionImages\\" + objPattern.ID;

                if (chkDisplayCompressionImage.Checked)
                {
                    if (!String.IsNullOrEmpty(this.hdnCompressionImage.Value))
                    {
                        try
                        {
                            string[] fileNames = (this.hdnCompressionImage.Value.Trim()).Split(',');
                            string fileName = Path.GetFileName(fileNames[0]);
                            string extension = Path.GetExtension(fileNames[0]);
                            string temporyFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + /*this.LoggedUserTempLocation + "\\" +*/ fileName;

                            string targetFilePath = physicalFolderPath + "\\" + fileName + extension;

                            if (Directory.Exists(physicalFolderPath))
                            {
                                DirectoryInfo di = new DirectoryInfo(physicalFolderPath);
                                di.Delete(true);
                            }

                            Directory.CreateDirectory(physicalFolderPath);

                            File.Copy(temporyFilePath, targetFilePath);

                        }
                        catch (Exception ex) { }
                    }
                }
                else
                {
                    if (Directory.Exists(physicalFolderPath))
                    {
                        DirectoryInfo di = new DirectoryInfo(physicalFolderPath);
                        di.Delete(true);
                    }
                }

                #endregion

                #region Webservice

                if (this.QueryID > 0)
                {
                    if (objPattern.IsActiveWS == true)
                    {
                        this.UpdateWebService(this.QueryID);
                    }
                }

                #endregion
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving pattern", ex);
            }
        }

        private void ResetDropdowns()
        {
            foreach (Control control in this.dvPageContent.Controls)
            {
                if (control is DropDownList)
                {
                    foreach (ListItem item in ((DropDownList)control).Items)
                    {
                        if (item.Selected)
                            ((DropDownList)control).Items.FindByValue(item.Value).Selected = false;
                    }
                }
            }
        }

        private void PopulateDropdown(DropDownList ddl, int selectedValue)
        {
            ViewState["isPopulate"] = false;
            ViewState["PopulateAccessoryUI"] = false;

            foreach (ListItem item in ddl.Items)
            {
                if (item.Selected)
                    ddl.Items.FindByValue(item.Value).Selected = false;
            }

            ddl.Items.FindByValue(selectedValue.ToString()).Selected = true;
        }

        private void PopulatePatternTemplates(int startIndex)
        {
            //this.cvTemplateImage.IsValid = true;
            this.dvEmptyContentPatternTemplates.Visible = false;
            this.dvPatternTemplates.Visible = false;
            //this.dvTemplatesPattern.Visible = false;

            if (this.QueryID > 0)
            {
                PatternBO objPattern = new PatternBO();
                objPattern.ID = this.QueryID;
                objPattern.GetObject();

                string TemplateImgLocation = "";

                if (objPattern.PatternTemplateImagesWhereThisIsPattern.Count > 0)
                {
                    PatternTemplateImageBO objPatternTemplateImage = new PatternTemplateImageBO();
                    objPatternTemplateImage.Pattern = objPattern.ID;

                    List<PatternTemplateImageBO> lstPTImages = objPatternTemplateImage.SearchObjects().Where(m => m.IsHero).ToList();

                    if (lstPTImages.Any())
                    {
                        objPatternTemplateImage = lstPTImages.Last(); // SingleOrDefault(o => o.IsHero == true);

                        //imagepath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + objPattern.ID.ToString() + "/" + objPatternTemplateImage.Filename + objPatternTemplateImage.Extension;

                        TemplateImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + this.QueryID.ToString() + "/" + objPatternTemplateImage.Filename + objPatternTemplateImage.Extension;
                        this.linkDeletePatternTemplateImage.Attributes.Add("tempImgID", objPatternTemplateImage.ID.ToString());
                        this.dvPatternTemplateUpload.Visible = false;

                        if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + TemplateImgLocation))
                        {
                            TemplateImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                            this.dvPatternTemplateUpload.Visible = false;
                            this.linkDeletePatternTemplateImage.Visible = true;
                        }
                        else
                        {
                            //TemplateImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";                            
                            this.dvPatternTemplateUpload.Visible = true;
                            this.linkDeletePatternTemplateImage.Visible = true;
                        }
                    }
                    else
                    {
                        //TemplateImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";                            
                        this.dvPatternTemplateUpload.Visible = true;
                        this.linkDeletePatternTemplateImage.Visible = false;
                    }
                    if (!string.IsNullOrWhiteSpace(TemplateImgLocation))
                        imgTemplateImage.Visible = true;
                    imgTemplateImage.ImageUrl = TemplateImgLocation;
                }
                else
                {
                    this.dvPatternTemplateUpload.Visible = true;
                }

                this.dvEmptyContentPatternTemplates.Visible = !(objPattern.PatternTemplateImagesWhereThisIsPattern.Count > 0 || QueryID > 0);
                this.dvPatternTemplates.Visible = (objPattern.PatternTemplateImagesWhereThisIsPattern.Count > 0);

            }
        }

        private void PopulatePatternAccessory()
        {
            if (this.QueryID > 0)
            {
                PatternSupportAccessoryBO objPSA = new PatternSupportAccessoryBO();
                objPSA.Pattern = this.QueryID;
                objPSA.GetObject();

                List<IGrouping<int, PatternSupportAccessoryBO>> lst = objPSA.SearchObjects().GroupBy(o => o.Accessory).ToList();

                if (lst.Any())
                {
                    Session["PatternAccessories"] = lst;
                    this.dgPatternAccessories.DataSource = lst;
                    this.dgPatternAccessories.DataBind();

                    this.dvEmptyContentAccessory.Visible = false;
                    this.dvPatternAccessory.Visible = true;
                }
            }
        }

        private void PopulateGarmentSpec()
        {
            if (this.QueryID > 0)
            {
                string status = string.Empty;
                bool haveValues = false;
                bool haveZeroes = false;

                PatternBO objPattern = new PatternBO();
                objPattern.ID = this.QueryID;
                objPattern.GetObject();

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

                // set the status and color, it is depend on the garmentSpecStatus
                if (status != string.Empty)
                {
                    this.lblGarmentSpecStatus.Text = status;
                    this.lblGarmentSpecStatus.Text = " <span class=\"label label-" + status.ToLower().Replace(" ", string.Empty).Trim() + "\"> " + status + " </span>";

                    //visible the Activate WS
                    bool HaveAcccessHttpPost = (this.LoggedUser.HaveAccessForHTTPPost != null) ? (bool)this.LoggedUser.HaveAccessForHTTPPost : false;
                    if (status == "Completed" && HaveAcccessHttpPost && objPattern.IsActive == true)
                    {
                        this.btnActivateWS.Visible = true;
                        if (objPattern.IsActiveWS == true)
                        {
                            this.btnActivateWS.InnerHtml = "Remove from Blackchrome";
                        }
                        else
                        {
                            this.btnActivateWS.InnerHtml = "Post to Blackchrome";
                        }

                    }
                }

                // NNM <!-- Add new Size Chart -->
                //SizeSetBO objSizeSet = new SizeSetBO();
                //objSizeSet.ID = int.Parse(this.ddlSizeSet.SelectedValue);
                //objSizeSet.GetObject();

                MeasurementLocationBO objMesurementLocation = new MeasurementLocationBO();
                objMesurementLocation.Item = objPattern.Item;
                List<MeasurementLocationBO> lstAllMeasurementLocation = objMesurementLocation.SearchObjects();

                SizeChartBO objExsistingSizeChart = new SizeChartBO();
                objExsistingSizeChart.Pattern = objPattern.ID;
                List<int> lstExistingSizes = objExsistingSizeChart.SearchObjects().Select(m => m.Size).Distinct().ToList();

                SizeBO objSize = new SizeBO();
                objSize.SizeSet = objPattern.SizeSet;
                objSize.IsDefault = true;
                List<int> lstAllSizes = objSize.SearchObjects().Select(m => m.ID).ToList();

                List<int> lstExceptingSizes = lstAllSizes.Except(lstExistingSizes).ToList();

                //List<int> lstscsize = (new SizeChartBO()).SearchObjects().Where(o => o.Pattern == objPattern.ID).Select(o => o.Size).Distinct().ToList();//new List<SizeChartBO>();
                //List<int> lstSize = (new SizeBO()).SearchObjects().Where(o => o.SizeSet == objPattern.SizeSet && o.IsDefault == true).Select(o => o.ID).ToList();
                //List<int> lstExceptsize = lstSize.Except(lstscsize).ToList();

                List<SizeChartBO> lstSizeCharts = new List<SizeChartBO>();
                if (lstExceptingSizes.Any())
                {
                    foreach (MeasurementLocationBO mLocation in lstAllMeasurementLocation)
                    {
                        foreach (int size in lstExceptingSizes)
                        {
                            SizeChartBO objSizeChart = new SizeChartBO();
                            objSizeChart.MeasurementLocation = mLocation.ID;
                            objSizeChart.Pattern = objPattern.ID;
                            objSizeChart.Size = size;
                            objSizeChart.Val = 0;

                            lstSizeCharts.Add(objSizeChart);
                        }
                    }
                }

                //<!--- / --->

                if (objPattern.Item == int.Parse(this.ddlItemGroup.SelectedValue) && objPattern.SizeSet == int.Parse(this.ddlSizeSet.SelectedValue))
                {
                    if (lstSizeCharts.Count > 0)
                    {
                        lstSizeCharts.AddRange(objPattern.SizeChartsWhereThisIsPattern);
                    }
                    else
                    {
                        //lstSizeCharts = objPattern.SizeChartsWhereThisIsPattern;

                        SizeChartBO objSizeChart = new SizeChartBO();
                        objSizeChart.Pattern = objPattern.ID;

                        lstSizeCharts = objSizeChart.SearchObjects(); //.Where(m => m.Val > 0).ToList();

                    }

                    //lstSizeCharts = objPattern.SizeChartsWhereThisIsPattern;
                    List<IGrouping<int, SizeChartBO>> lst = lstSizeCharts.GroupBy(o => o.MeasurementLocation).ToList();
                    List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = lstSizeCharts.OrderBy(o => o.objMeasurementLocation.Key).OrderBy(o => o.objSize.SeqNo).GroupBy(o => o.MeasurementLocation).ToList();

                    if (lstSizeChartGroup.Count > 0)
                    {
                        this.rptSpecSizeQtyHeader.DataSource = (List<SizeChartBO>)lstSizeChartGroup[0].ToList();
                        this.rptSpecSizeQtyHeader.DataBind();

                        this.rptSpecML.DataSource = lstSizeChartGroup;
                        this.rptSpecML.DataBind();

                        this.dvEmptyContentGarmentSpec.Visible = false;
                        this.dvSpecGrd.Visible = true;
                    }
                    else
                    {
                        this.GenerateNewGarmentSpec();
                    }

                    return;
                }
            }
            else
            {
                //this.dvGarmentSpecStatus.Visible = true;
            }

            this.GenerateNewGarmentSpec();
        }

        private void GenerateNewGarmentSpec()
        {
            if (int.Parse(this.ddlItemGroup.SelectedValue) > 0 && int.Parse(this.ddlSizeSet.SelectedValue) > 0)
            {
                string ErrorMsg = string.Empty;
                bool isValid = true;

                ItemBO objItem = new ItemBO();
                objItem.ID = int.Parse(this.ddlItemGroup.SelectedValue);
                objItem.GetObject();

                SizeSetBO objSizeSet = new SizeSetBO();
                objSizeSet.ID = int.Parse(this.ddlSizeSet.SelectedValue);
                objSizeSet.GetObject();

                if (objItem.MeasurementLocationsWhereThisIsItem.Count == 0)
                {
                    ErrorMsg = "Measurement Locations could not be found for the item '" + objItem.Name + "'<br />";
                    isValid = false;
                }
                if (objSizeSet.SizesWhereThisIsSizeSet.Count == 0)
                {
                    ErrorMsg += "Sizes could not be found for the size set '" + objSizeSet.Name + "'<br />";
                    isValid = false;
                }

                if (isValid)
                {
                    List<SizeChartBO> lstSizeCharts = new List<SizeChartBO>();
                    foreach (MeasurementLocationBO ml in objItem.MeasurementLocationsWhereThisIsItem)
                    {
                        foreach (SizeBO size in objSizeSet.SizesWhereThisIsSizeSet.Where(o => o.IsDefault == true))
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

                        this.dvEmptyContentGarmentSpec.Visible = false;
                        this.dvSpecGrd.Visible = true;
                    }
                    else
                    {
                        this.rptSpecML.DataSource = null;
                        this.rptSpecML.DataBind();
                        isValid = false;
                    }
                }
                else
                {
                    this.rptSpecML.DataSource = null;
                    this.rptSpecML.DataBind();

                    this.paraSpecError.InnerHtml = ErrorMsg;
                    this.dvEmptyContentGarmentSpec.Visible = true;
                    this.dvSpecGrd.Visible = false;
                }
            }
            else
            {
                this.rptSpecML.DataSource = null;
                this.rptSpecML.DataBind();

                this.dvEmptyContentGarmentSpec.Visible = true;
                this.dvSpecGrd.Visible = false;
            }
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

            int loadedPageTemp = (LoadedPageNumber % 10 == 0) ? ((LoadedPageNumber - 1) / 10) : (LoadedPageNumber / 10);

            if (TemplateTotal <= 10 * rptPageSize)
            {
                this.lbFooterPreviousDots.Visible = false;
                this.lbFooterNextDots.Visible = false;
            }

            else if (TemplateTotal - ((loadedPageTemp) * 10 * rptPageSize) <= 10 * rptPageSize)
            {
                this.lbFooterNextDots.Visible = false;
            }
            else
            {
                this.lbFooterPreviousDots.Visible = (this.lbFooter1.Text == "1") ? false : true;
            }
        }

        private void HighLightPageNumber(int clickedPageNumber)
        {
            LinkButton clickedLink = (LinkButton)this.FindControlRecursive(this, "lbFooter" + clickedPageNumber);
            clickedLink.CssClass = "paginatorLink current";
        }

        private void ClearCss()
        {
            for (int i = 1; i <= 10; i++)
            {
                LinkButton lbFooter = (LinkButton)this.FindControlRecursive(this, "lbFooter" + i.ToString());
                lbFooter.CssClass = "paginatorLink";
            }
        }

        private Control FindControlRecursive(Control root, string id)
        {
            if (root.ID == id)
            {
                return root;
            }

            foreach (Control c in root.Controls)
            {
                Control t = FindControlRecursive(c, id);
                if (t != null)
                {
                    return t;
                }
            }

            return null;
        }

        private void PopulatePatternTemplateImages()
        {
            //this.dvEmptyContentTemplatePattern.Visible = false;
            string ImagePath_1 = string.Empty;
            string ImagePath_2 = string.Empty;
            string ImagePath_3 = string.Empty;
            this.hdnPhotoImageIDOne.Value = "0";
            this.hdnPhotoImageIDTwo.Value = "0";
            this.hdnPhotoImageIDThree.Value = "0";

            this.litFileInformation.Text = string.Empty;
            this.litfileName.Text = string.Empty;
            this.litfileSize.Text = string.Empty;
            this.litfileType.Text = string.Empty;

            this.litFileInformation_2.Text = string.Empty;
            this.litfileName_2.Text = string.Empty;
            this.litfileSize_2.Text = string.Empty;
            this.litfileType_2.Text = string.Empty;

            this.litFileInformation_3.Text = string.Empty;
            this.litfileName_3.Text = string.Empty;
            this.litfileSize_3.Text = string.Empty;
            this.litfileType_3.Text = string.Empty;

            if (QueryID > 0)
            {
                PatternBO objPattern = new PatternBO();
                objPattern.ID = QueryID;
                objPattern.GetObject();

                //bool isPhotoImage_1 = false;
                //bool isPhotoImage_2 = false;
                //bool isPhotoImage_3 = false;

                // View Photography Image                
                PatternTemplateImageBO objPatternTemplateImage = new PatternTemplateImageBO();
                objPatternTemplateImage.Pattern = objPattern.ID;

                List<PatternTemplateImageBO> lstPatternTemplateImage = objPatternTemplateImage.SearchObjects().Where(o => o.IsHero == false).ToList();

                if (lstPatternTemplateImage.Count > 0)
                {
                    lstPatternTemplateImage = objPatternTemplateImage.SearchObjects().Where(o => o.ImageOrder == 1).ToList();
                    if (lstPatternTemplateImage.Any())
                    {
                        ImagePath_1 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + "/" + lstPatternTemplateImage[0].Pattern + "/" + lstPatternTemplateImage[0].Filename + lstPatternTemplateImage[0].Extension;
                        if (!File.Exists(Server.MapPath(ImagePath_1)))
                        {
                            ImagePath_1 = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                        }

                        //this.uploadPhotoImageOne.ImageUrl = ImagePath_1;
                        this.litFileInformation.Text = "<strong>File Information</strong>";
                        this.litfileName.Text = "<strong>Filename</strong> " + lstPatternTemplateImage[0].Filename.ToString() + ".jpg";
                        this.litfileSize.Text = "<strong>File Size</strong> " + Math.Round(decimal.Parse((lstPatternTemplateImage[0].Size / 1024).ToString()), 2) + " KB";
                        this.hdnPhotoImageIDOne.Value = lstPatternTemplateImage[0].ID.ToString();
                        this.litfileType.Text = "<strong>File Type</strong> image/jpeg";
                        this.dvUploader_1.Visible = false;
                        this.linkDeleteImageOne.Visible = true;
                    }
                    else
                    {
                        this.dvUploader_1.Visible = true;
                        ImagePath_1 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/One.jpg";
                    }

                    lstPatternTemplateImage = objPatternTemplateImage.SearchObjects().Where(o => o.ImageOrder == 2).ToList();
                    if (lstPatternTemplateImage.Any())
                    {
                        ImagePath_2 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + "/" + lstPatternTemplateImage[0].Pattern + "/" + lstPatternTemplateImage[0].Filename + lstPatternTemplateImage[0].Extension;

                        if (!File.Exists(Server.MapPath(ImagePath_2)))
                        {
                            ImagePath_2 = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                        }

                        //this.uploadPhotoImageTwo.ImageUrl = ImagePath_2;
                        this.litFileInformation_2.Text = "<strong>File Information<strong>";
                        this.litfileName_2.Text = "<strong>Filename</strong> " + lstPatternTemplateImage[0].Filename.ToString() + ".jpg";
                        this.litfileSize_2.Text = "<strong>File Size</strong> " + Math.Round(decimal.Parse((lstPatternTemplateImage[0].Size / 1024).ToString()), 2) + " KB";
                        this.hdnPhotoImageIDTwo.Value = lstPatternTemplateImage[0].ID.ToString();
                        this.litfileType_2.Text = "<strong>File Type</strong> image/jpeg";
                        this.dvUploader_2.Visible = false;
                        this.linkDeleteImageTwo.Visible = true;
                    }
                    else
                    {
                        this.dvUploader_2.Visible = true;
                        ImagePath_2 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/Two.jpg";
                    }

                    lstPatternTemplateImage = objPatternTemplateImage.SearchObjects().Where(o => o.ImageOrder == 3).ToList();

                    if (lstPatternTemplateImage.Any())
                    {
                        ImagePath_3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + "/" + lstPatternTemplateImage[0].Pattern + "/" + lstPatternTemplateImage[0].Filename + lstPatternTemplateImage[0].Extension;

                        if (!File.Exists(Server.MapPath(ImagePath_3)))
                        {
                            ImagePath_3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                        }

                        //this.uploadPhotoImageThree.ImageUrl = ImagePath_3;
                        this.litFileInformation_3.Text = "<strong>File Information</strong>";
                        this.litfileName_3.Text = "<strong>Filename</strong>: " + lstPatternTemplateImage[0].Filename.ToString() + ".jpg";
                        this.litfileSize_3.Text = "<strong>File Size</strong>: " + Math.Round(decimal.Parse((lstPatternTemplateImage[0].Size / 1024).ToString()), 2) + " KB";
                        this.hdnPhotoImageIDThree.Value = lstPatternTemplateImage[0].ID.ToString();
                        this.litfileType_3.Text = "<strong>File Type</strong> image/jpeg";
                        this.dvUploader_3.Visible = false;
                        this.linkDeleteImageThree.Visible = true;
                    }
                    else
                    {
                        this.dvUploader_3.Visible = true;
                        ImagePath_3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/Three.jpg";
                    }

                    /*foreach (PatternTemplateImageBO patImage in lstPatternTemplateImage)
                    {
                        if (patImage.ImageOrder == 1)
                        {
                            lstPatternTemplateImage = objPatternTemplateImage.SearchObjects().Where(o => o.ImageOrder == 1).ToList();
                            if (lstPatternTemplateImage.Count > 0)
                            {
                                ImagePath_1 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + "/" + lstPatternTemplateImage[0].Pattern + "/" + lstPatternTemplateImage[0].Filename + lstPatternTemplateImage[0].Extension;
                                if (!File.Exists(Server.MapPath(ImagePath_1)))
                                {
                                    ImagePath_1 = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";

                                }

                                //this.uploadPhotoImageOne.ImageUrl = ImagePath_1;
                                this.litFileInformation.Text = "<strong>File Information</strong>";
                                this.litfileName.Text = "<strong>Filename</strong> " + lstPatternTemplateImage[0].Filename.ToString() + ".jpg";
                                this.litfileSize.Text = "<strong>File Size</strong> " + Math.Round(decimal.Parse((lstPatternTemplateImage[0].Size / 1024).ToString()), 2) + " KB";
                                this.hdnPhotoImageIDOne.Value = lstPatternTemplateImage[0].ID.ToString();
                                this.litfileType.Text = "<strong>File Type</strong> image/jpeg";
                                this.dvUploader_1.Visible = false;
                                this.linkDeleteImageOne.Visible = true;
                            }
                            else
                            {
                                ImagePath_1 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/One.jpg";
                            }
                            ImagePath_2 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/Two.jpg";
                            ImagePath_3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/Three.jpg";
                            isPhotoImage_1 = true;
                        }
                        else if (!isPhotoImage_1)
                        {
                            ImagePath_1 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/One.jpg";
                            this.litFileInformation.Text = string.Empty;
                            this.litfileType.Text = string.Empty;
                            this.litfileName.Text = string.Empty;
                            this.litfileSize.Text = string.Empty;
                            this.hdnPhotoImageIDOne.Value = string.Empty;
                            this.dvUploader_1.Visible = true;
                            this.linkDeleteImageOne.Visible = false;
                        }

                        if (patImage.ImageOrder == 2)
                        {
                            lstPatternTemplateImage = objPatternTemplateImage.SearchObjects().Where(o => o.ImageOrder == 2).ToList();
                            if (lstPatternTemplateImage.Count > 0)
                            {
                                ImagePath_2 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + "/" + lstPatternTemplateImage[0].Pattern + "/" + lstPatternTemplateImage[0].Filename + lstPatternTemplateImage[0].Extension;

                                if (!File.Exists(Server.MapPath(ImagePath_2)))
                                {
                                    ImagePath_2 = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                                }

                                //this.uploadPhotoImageTwo.ImageUrl = ImagePath_2;
                                this.litFileInformation_2.Text = "<strong>File Information<strong>";
                                this.litfileName_2.Text = "<strong>Filename</strong> " + lstPatternTemplateImage[0].Filename.ToString() + ".jpg";
                                this.litfileSize_2.Text = "<strong>File Size</strong> " + Math.Round(decimal.Parse((lstPatternTemplateImage[0].Size / 1024).ToString()), 2) + " KB";
                                this.hdnPhotoImageIDTwo.Value = lstPatternTemplateImage[0].ID.ToString();
                                this.litfileType_2.Text = "<strong>File Type</strong> image/jpeg";
                                this.dvUploader_2.Visible = false;
                                this.linkDeleteImageTwo.Visible = true;
                            }
                            else
                            {
                                ImagePath_2 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/Two.jpg";
                            }
                            ImagePath_3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/Three.jpg";
                            isPhotoImage_2 = true;
                        }
                        else if (!isPhotoImage_2)
                        {
                            ImagePath_2 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/Two.jpg";
                            this.litFileInformation_2.Text = string.Empty;
                            this.litfileType_2.Text = string.Empty;
                            this.litfileName_2.Text = string.Empty;
                            this.litfileSize_2.Text = string.Empty;
                            this.hdnPhotoImageIDTwo.Value = string.Empty;
                            this.dvUploader_2.Visible = true;
                            this.linkDeleteImageTwo.Visible = false;
                        }

                        if (patImage.ImageOrder == 3)
                        {
                            lstPatternTemplateImage = objPatternTemplateImage.SearchObjects().Where(o => o.ImageOrder == 3).ToList();

                            if (lstPatternTemplateImage.Count > 0)
                            {
                                ImagePath_3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + "/" + lstPatternTemplateImage[0].Pattern + "/" + lstPatternTemplateImage[0].Filename + lstPatternTemplateImage[0].Extension;

                                if (!File.Exists(Server.MapPath(ImagePath_3)))
                                {
                                    ImagePath_3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                                }

                                //this.uploadPhotoImageThree.ImageUrl = ImagePath_3;
                                this.litFileInformation_3.Text = "<strong>File Information</strong>";
                                this.litfileName_3.Text = "<strong>Filename</strong>: " + lstPatternTemplateImage[0].Filename.ToString() + ".jpg";
                                this.litfileSize_3.Text = "<strong>File Size</strong>: " + Math.Round(decimal.Parse((lstPatternTemplateImage[0].Size / 1024).ToString()), 2) + " KB";
                                this.hdnPhotoImageIDThree.Value = lstPatternTemplateImage[0].ID.ToString();
                                this.litfileType_3.Text = "<strong>File Type</strong> image/jpeg";
                                this.dvUploader_3.Visible = false;
                                this.linkDeleteImageThree.Visible = true;
                            }
                            else
                            {
                                ImagePath_3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/Three.jpg";
                            }
                            isPhotoImage_3 = true;
                        }
                        else if (!isPhotoImage_3)
                        {
                            ImagePath_3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/Three.jpg";
                            this.litFileInformation_3.Text = string.Empty;
                            this.litfileType_3.Text = string.Empty;
                            this.litfileName_3.Text = string.Empty;
                            this.litfileSize_3.Text = string.Empty;
                            this.hdnPhotoImageIDThree.Value = string.Empty;
                            this.dvUploader_3.Visible = true;
                            this.linkDeleteImageThree.Visible = false;
                        }
                    }*/
                }
                else
                {
                    ImagePath_1 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/One.jpg";
                    ImagePath_2 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/Two.jpg";
                    ImagePath_3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/Three.jpg";

                    this.dvUploader_1.Visible = true;
                    this.dvUploader_2.Visible = true;
                    this.dvUploader_3.Visible = true;

                    //reset items 
                    this.litfileName.Visible = false;
                    this.litfileSize.Visible = false;
                    this.hdnPhotoImageIDOne.Value = string.Empty;
                    this.linkDeleteImageOne.Visible = false;

                    this.litfileName_2.Visible = false;
                    this.litfileSize_2.Visible = false;
                    this.hdnPhotoImageIDTwo.Value = string.Empty;
                    this.linkDeleteImageTwo.Visible = false;
                    this.litFileInformation_2.Text = string.Empty;
                    this.litfileType_2.Text = string.Empty;

                    this.litfileName_3.Visible = false;
                    this.litfileSize_3.Visible = false;
                    this.hdnPhotoImageIDThree.Value = string.Empty;
                    this.linkDeleteImageThree.Visible = false;
                    this.litFileInformation_3.Text = string.Empty;
                    this.litfileType_3.Text = string.Empty;
                }
            }
            else
            {
                ImagePath_1 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/One.jpg";
                ImagePath_2 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/Two.jpg";
                ImagePath_3 = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/Three.jpg";
            }

            System.Drawing.Image VLImage_1 = System.Drawing.Image.FromFile(Server.MapPath(ImagePath_1));
            SizeF image_1Size = VLImage_1.PhysicalDimension;
            VLImage_1.Dispose();

            System.Drawing.Image VLImage_2 = System.Drawing.Image.FromFile(Server.MapPath(ImagePath_3));
            SizeF image_2Size = VLImage_2.PhysicalDimension;
            VLImage_2.Dispose();

            System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(Server.MapPath(ImagePath_3));
            SizeF image_3Size = VLOrigImage.PhysicalDimension;
            VLOrigImage.Dispose();

            List<float> lstVLImageDimensionsForPhotographyImage_1 = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(image_1Size.Width)), Convert.ToInt32(Math.Abs(image_1Size.Height)), 250, 140);
            List<float> lstVLImageDimensionsForPhotographyImage_2 = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(image_2Size.Width)), Convert.ToInt32(Math.Abs(image_2Size.Height)), 250, 140);
            List<float> lstVLImageDimensionsForPhotographyImage_3 = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(image_3Size.Width)), Convert.ToInt32(Math.Abs(image_3Size.Height)), 250, 140);

            this.uploadPhotoImageOne.ImageUrl = ImagePath_1;
            //this.uploadPhotoImageOne.Height = int.Parse(lstVLImageDimensionsForPhotographyImage_1[0].ToString());
            //this.uploadPhotoImageOne.Width = int.Parse(lstVLImageDimensionsForPhotographyImage_1[1].ToString());

            this.uploadPhotoImageTwo.ImageUrl = ImagePath_2;
            //this.uploadPhotoImageTwo.Height = int.Parse(lstVLImageDimensionsForPhotographyImage_2[0].ToString());
            //this.uploadPhotoImageTwo.Width = int.Parse(lstVLImageDimensionsForPhotographyImage_2[1].ToString());

            this.uploadPhotoImageThree.ImageUrl = ImagePath_3;
            //this.uploadPhotoImageThree.Height = int.Parse(lstVLImageDimensionsForPhotographyImage_3[0].ToString());
            //this.uploadPhotoImageThree.Width = int.Parse(lstVLImageDimensionsForPhotographyImage_3[1].ToString());
        }

        private void PopulatePatternCompressionImage()
        {
            string dataFolderPath = "/" + IndicoConfiguration.AppConfiguration.DataFolderName;
            string ImagePath = dataFolderPath + "/noimage-png-350px-350px.png";

            if (this.QueryID > 0)
            {
                PatternBO objPattern = new PatternBO();
                objPattern.ID = this.QueryID;
                objPattern.GetObject(false);

                if ((objPattern.PatternCompressionImage ?? 0) > 0)
                {
                    this.chkDisplayCompressionImage.Checked = true;

                    string fileName = objPattern.objPatternCompressionImage.Filename;
                    string extension = objPattern.objPatternCompressionImage.Extension;

                    string physicalFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\PatternCompressionImages\\" + this.QueryID + "\\";

                    if (File.Exists(physicalFolderPath + fileName + extension))
                    {
                        ImagePath = dataFolderPath + "/PatternCompressionImages/" + this.QueryID + "/" + fileName + extension;
                    }
                }
            }

            this.imgCompression.ImageUrl = ImagePath;
        }

        private void UpdateWebService(int id)
        {
            try
            {
                PatternBO objPattern = new PatternBO(this.ObjContext);
                objPattern.ID = QueryID;
                objPattern.GetObject();

                WebServicePattern objWebServicePattern = new WebServicePattern();

                using (TransactionScope ts = new TransactionScope())
                {
                    if (this.chbIsActive.Checked == true)
                    {
                        objPattern.IsActiveWS = true;
                        //objWebServicePattern.GUID = IndicoConfiguration.AppConfiguration.HttpPostGuid;
                        //objWebServicePattern.img1 = objWebServicePattern.CreateImages(objPattern, "img1");
                        //objWebServicePattern.img2 = objWebServicePattern.CreateImages(objPattern, "img2");
                        //objWebServicePattern.img3 = objWebServicePattern.CreateImages(objPattern, "img3");
                        //objWebServicePattern.img4 = objWebServicePattern.CreateImages(objPattern, "img4");
                        //objWebServicePattern.pdf = objWebServicePattern.GeneratePDF(objPattern, true, "0");
                        //objWebServicePattern.meas_xml = objWebServicePattern.WriteGramentSpecXML(objPattern);
                        //objWebServicePattern.garment_des = this.txtDescription.Text;
                        //objWebServicePattern.pat_no = this.txtPatternNumber.Text;
                        //objWebServicePattern.s_desc = "";
                        //objWebServicePattern.l_desc = this.txtMarketingDescription.Text;
                        //objWebServicePattern.gen_cat = this.ddlGender.SelectedItem.Text;
                        //objWebServicePattern.age_group = (objPattern.AgeGroup != null && objPattern.AgeGroup > 0) ? objPattern.objAgeGroup.Name : string.Empty;
                        //objWebServicePattern.main_cat_id = this.ddlCoreCategory.SelectedItem.Text;
                        //objWebServicePattern.sub_cat_id = "";
                        ////objWebServicePattern.rating = "1";
                        ////objWebServicePattern.times = "1";
                        //objWebServicePattern.date_entered = DateTime.Now.ToString("yyyy-MM-dd");
                        //objWebServicePattern.Post(false);
                    }
                    else
                    {
                        objPattern.IsActiveWS = false;
                        //objWebServicePattern.DeletePatternNumber = objPattern.Number;
                        //objWebServicePattern.GUID = IndicoConfiguration.AppConfiguration.HttpPostGuid;
                        //objWebServicePattern.DeleteDirectoriesGivenPattern(objPattern);
                        //objWebServicePattern.Post(true);
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while sending the data from AddEditPattern.aspx page", ex);
            }
        }

        private string GetPatternModifiedDetails()
        {
            PatternBO objPattern = (PatternBO)Session["PatternDetails"];
            string meassage = string.Empty;

            if (objPattern.IsActive != this.chbIsActive.Checked)
            {
                if (this.chbIsActive.Checked == false)
                {
                    meassage = "Change Pattern Inactive" + " ,";
                }
                else
                {
                    meassage = "Change Pattern Active" + " ,";
                }
            }

            if (objPattern.Number != this.txtPatternNumber.Text)
            {
                meassage = "Pattern Number" + " ,";
            }

            if (objPattern.Remarks != this.txtDescription.Text)
            {
                meassage += "Desciption" + " ,";
            }

            if (objPattern.OriginRef != this.txtOriginRef.Text)
            {
                meassage += "OriginRef" + " ,";
            }

            if (objPattern.Consumption != this.txtConsumption.Text)
            {
                meassage += "Consumption" + " ,";
            }

            if (objPattern.CorePattern != this.txtCorrespondingPattern.Text)
            {
                meassage += "Coresponding Pattern" + " ,";
            }

            if (objPattern.Keywords != this.txtKeyWords.Text)
            {
                meassage += "Keywords" + " ,";
            }

            if (objPattern.SpecialAttributes != this.txtSpecialAttributes.Text)
            {
                meassage += "Special Attributes" + " ,";
            }

            if (objPattern.FactoryDescription != this.txtFactoryDescription.Text)
            {
                meassage += "Special Attributes" + " ,";
            }

            if (objPattern.PrinterType != int.Parse(this.ddlPrintType.SelectedValue))
            {
                meassage += "Printer Type" + " ,";
            }

            if (objPattern.PatternNotes != this.txtNotes.Text)
            {
                meassage += "Notes" + " ,";
            }

            if (objPattern.ConvertionFactor != Convert.ToDecimal(this.txtConvertionFactor.Text))
            {
                meassage += "Convertion Factor" + " ,";
            }

            if (objPattern.Item != int.Parse(this.ddlItemGroup.SelectedValue))
            {
                meassage += "Item" + " ,";
            }

            if (objPattern.SubItem != int.Parse(this.ddlItemSubGroup.SelectedValue))
            {
                meassage += "Sub Item" + " ,";
            }

            if (objPattern.Gender != int.Parse(this.ddlGender.SelectedValue))
            {
                meassage += "Gender" + " ,";
            }

            if (objPattern.AgeGroup != int.Parse(this.ddlAgeGroup.SelectedValue))
            {
                meassage += "Age Group" + " ,";
            }

            if (objPattern.SizeSet != int.Parse(this.ddlSizeSet.SelectedValue))
            {
                meassage += "Size Set" + " ,";
            }

            string nickname = (!string.IsNullOrEmpty(this.hdnNickName.Value)) ? this.hdnNickName.Value.Trim() : this.txtNickName.Text.Trim();
            if (objPattern.NickName != nickname)
            {
                meassage += "Nick Name" + " ,";
            }

            if (objPattern.CoreCategory != int.Parse(this.ddlCoreCategory.SelectedValue))
            {
                meassage += "Categories" + " ,";
            }

            if (this.hdnPhotoImageOne.Value != "0")
            {
                meassage += "Photography Image One" + " ,";
            }

            if (this.hdnPhotoImageTwo.Value != "0")
            {
                meassage += "Photography Image Two" + " ,";
            }

            if (this.hdnPhotoImageThree.Value != "0")
            {
                meassage += "Photography Image Three" + " ,";
            }

            if (this.hdnUploadFiles.Value != string.Empty)
            {
                meassage += "Garment Measurement Image" + " ,";
            }

            if (this.hdnChangeGramentSpec.Value != string.Empty)
            {
                meassage += "Grament Specification Values" + " ,";
            }

            meassage += " this values had been Changed";

            return meassage;
        }

        private void PopulateItemGroup()
        {
            int selectedItemId = int.Parse(this.ddlItemGroup.SelectedValue.ToString());

            //16/07/2012 this.ddlItemAttribute.Enabled = (selectedItemId > 0);
            this.ddlItemSubGroup.Enabled = (selectedItemId > 0);

            if (selectedItemId > 0)
            {
                ViewState["isPopulate"] = false;
                ViewState["PopulateAccessoryUI"] = false;

                ItemBO objItem = new ItemBO();
                objItem.ID = selectedItemId;
                objItem.GetObject();


                // Get the attributes based on the item selection
                List<ItemAttributeBO> lstItems = (new ItemAttributeBO()).SearchObjects().Where(o => o.Item == selectedItemId && o.Parent == 0).ToList();

                rptItemAttribute.DataSource = lstItems;
                rptItemAttribute.DataBind();

                this.dvItemAttributes.Visible = (lstItems.Count > 0);

                //Populate ItemSubGroup
                this.ddlItemSubGroup.Items.Clear();
                this.ddlItemSubGroup.Items.Add(new ListItem("Select Sub Item", "0"));
                List<ItemBO> lstSubItems = ((new ItemBO()).GetAllObject().Where(o => o.Parent == selectedItemId).ToList().OrderBy(o => o.Name)).ToList();
                foreach (ItemBO subItem in lstSubItems)
                {
                    this.ddlItemSubGroup.Items.Add(new ListItem(subItem.Name, subItem.ID.ToString()));
                }
                this.ddlItemSubGroup.Enabled = (lstSubItems.Count > 0);
                // this.PopulateGarmentSpec(); 18/09/2014 NNM
            }
            else
            {
                //16/07/2012  this.ddlItemAttribute.Items.Clear();
                this.ddlItemSubGroup.Items.Clear();
                this.ddlItemSubGroup.Items.Add(new ListItem("To select a sub group, first select an item group", "0"));
                //16/07/2012  this.ddlItemAttribute.Items.Add(new ListItem("To select an attribute, first select an item group", "0"));
            }
        }

        /// <summary>
        /// Save newly added pattern in the PatternDevelopment Table 
        /// will not added if already exists
        /// </summary>
        /// <param name="patternId">id of the new pattern</param>
        private void AddPatternToDevelopment(int patternId)
        {
            try
            {
                using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
                {
                    connection.Execute(string.Format(@"IF (SELECT TOP 1 ID FROM [dbo].[PatternDevelopment] WHERE [Pattern] = {1}) IS NULL
                                                           BEGIN
                                                               INSERT INTO [dbo].[PatternDevelopment] (Creator,Pattern) VALUES({0},{1})
                                                           END", LoggedUser.ID, patternId));
                }
            }
            catch (Exception e)
            {
                IndicoLogging.log.Error("An error occurred while saving new pattern in  PatternDevelopment table ", e);
            }
        }
        #endregion
    }
}