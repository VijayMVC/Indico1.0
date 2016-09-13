using System;
using System.Collections.Generic;
using System.IO;
using System.Drawing;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

using Indico.Common;
using Indico.BusinessObjects;
using System.Text.RegularExpressions;

namespace Indico
{
    public partial class AddEditArtWork : IndicoPage
    {
        #region Fields

        private int urlQueryID = -1;
        private int urlOrderID = -1;
        private int urlDisributorID = -1;
        private int urlClientID = -1;
        private int rptPageSize = 10;
        private string sort = string.Empty;


        #endregion

        #region Properties

        protected int QueryID
        {
            get
            {
                urlQueryID = 0;

                if (Request.QueryString["id"] != null)
                    urlQueryID = Convert.ToInt32(Request.QueryString["id"].ToString());
                else if ((ViewState["VLID_" + this.LoggedUser.ID.ToString()] != null) && (urlQueryID == 0))
                    urlQueryID = int.Parse(ViewState["VLID_" + this.LoggedUser.ID.ToString()].ToString());

                if (Request.QueryString["orr"] != null)
                {
                    urlOrderID = Convert.ToInt32(Request.QueryString["orr"].ToString());
                }

                if (Request.QueryString["dir"] != null)
                {
                    urlDisributorID = Convert.ToInt32(Request.QueryString["dir"].ToString());
                }

                if (Request.QueryString["clt"] != null)
                {
                    urlClientID = Convert.ToInt32(Request.QueryString["clt"].ToString());
                }

                return urlQueryID;
            }
        }

        protected int OrderID
        {
            get
            {
                return urlOrderID;
            }
        }

        protected int DistributorID
        {
            get
            {
                return urlDisributorID;
            }
        }

        protected int ClientID
        {
            get
            {
                return urlClientID;
            }
        }

        private string SortExpression
        {
            get
            {
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "ID";
                }
                return sort;
            }
            set
            {
                sort = value;
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

        protected int VLTotal
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

        protected int VLPageCount
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

        private int AccessoryID
        {
            get
            {
                int AccessoryID = (int)ViewState["AccessoryID"];

                return AccessoryID;
            }
            set
            {
                ViewState["AccessoryID"] = value;
            }
        }

        private int visualLayoutID
        {
            get
            {
                int visualLayoutID = (int)ViewState["artWorkID"];

                return visualLayoutID;
            }
            set
            {
                ViewState["artWorkID"] = value;
            }
        }

        private string visualLayoutNa
        {
            get
            {
                string visualLayoutName = (string)ViewState["visualLayoutNa"];

                return visualLayoutName;
            }
            set
            {
                ViewState["visualLayoutNa"] = value;
            }
        }

        public string nameSuffix { get; set; }

        public string namePrefix { get; set; }

        public string vlName { get; set; }

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

            ViewState["PopulatePatern"] = false;
            ViewState["PopulateFabric"] = false;
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            //this.cvLayoutImage.Enabled = true;
            //Page.Validate();

            //ViewState["PopulatePatern"] = false;

            CustomValidator cv = null;

            //if (this.checkIsCommonproduct.Checked == false)
            //{
            if (string.IsNullOrEmpty(this.txtReferenceNumber.Text))
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpVL";
                cv.ErrorMessage = "Reference Number is required";
                Page.Validators.Add(cv);
            }

            if (int.Parse(this.ddlDistributor.SelectedValue) == 0)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpVL";
                cv.ErrorMessage = "Distributor is required";
                Page.Validators.Add(cv);
            }

            if (string.IsNullOrEmpty(this.ddlClient.SelectedValue) || int.Parse(this.ddlClient.SelectedValue) == 0)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpVL";
                cv.ErrorMessage = "Client is required";
                Page.Validators.Add(cv);
            }

            if (int.Parse(this.ddlFabric.SelectedValue) == 0)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpVL";
                cv.ErrorMessage = "Fabric is required";
                Page.Validators.Add(cv);
            }

            if (int.Parse(this.ddlPattern.SelectedValue) == 0)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpVL";
                cv.ErrorMessage = "Pattern is required";
                Page.Validators.Add(cv);
            }
            //}

            if (Page.IsValid)
            {
                int visualLayout = this.ProcessForm();
                this.SaveAccessories();

                //if (this.OrderID > -1)
                //{
                //    Response.Redirect("/AddArtWork.aspx?id=" + this.OrderID + "&vln=" + visualLayout);
                //}
                //else
                //{
                Response.Redirect("/ViewVisualLayouts.aspx");
                //}
            }
        }

        protected void btnSearchPattern_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                this.PopulatePatterns();
            }
            //else
            //{
            //    this.validationSummary.Visible = !Page.IsValid;
            //}
            //ViewState["PopulatePatern"] = true;
            // this.PopulateFileUploder(this.rptUploadFile, this.hdnUploadFiles);
        }

        //protected void cvLabel_OnServerValidate(object sender, ServerValidateEventArgs e)
        //{
        //    if (this.QueryID == 0)
        //    {
        //        if (this.hdnUploadFiles.Value == "0" || string.IsNullOrEmpty(this.hdnUploadFiles.Value))
        //            e.IsValid = false;
        //        else
        //            e.IsValid = true;
        //    }


        //    VisualLayoutBO objVisualLayout = new VisualLayoutBO();
        //    objVisualLayout.ID = this.QueryID;
        //    objVisualLayout.GetObject();

        //    if (this.QueryID > 0)
        //    {
        //        if (objVisualLayout.ImagesWhereThisIsVisualLayout.Count == 0)
        //        {
        //            if (this.hdnUploadFiles.Value == "0" || string.IsNullOrEmpty(this.hdnUploadFiles.Value))
        //                e.IsValid = false;
        //            else
        //                e.IsValid = true;

        //        }
        //    }
        //}

        protected void rptVisualLayouts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is ImageBO)
            {
                string VlImgLocation = string.Empty;
                ImageBO objImage = (ImageBO)item.DataItem;

                if (objImage != null)
                {
                    VlImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/VisualLayout/" + this.QueryID.ToString() + "/" + objImage.Filename + objImage.Extension;

                    if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + VlImgLocation))
                        VlImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }
                else
                {
                    VlImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }

                System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + VlImgLocation);
                SizeF origImageSize = VLOrigImage.PhysicalDimension;
                VLOrigImage.Dispose();

                List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 300, 300);

                System.Web.UI.WebControls.Image imgVisualLayout = (System.Web.UI.WebControls.Image)item.FindControl("imgVisualLayout");
                imgVisualLayout.ImageUrl = VlImgLocation;
                imgVisualLayout.Width = int.Parse(lstImgDimensions[1].ToString());
                imgVisualLayout.Height = int.Parse(lstImgDimensions[0].ToString());

                CheckBox chkHeroImage = (CheckBox)item.FindControl("chkHeroImage");
                chkHeroImage.Checked = objImage.IsHero;
                chkHeroImage.Attributes.Add("qid", objImage.ID.ToString());

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objImage.ID.ToString());
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

                Label lblCellData = (Label)item.FindControl("lblCellData");
                lblCellData.Text = objSizeChart.Val.ToString();
            }
        }

        /*protected void cvLabel_OnServerValidate(object sender, ServerValidateEventArgs e)
        {
            if (this.QueryID == 0)
            {
                if (this.hdnUploadFiles.Value == "0" || string.IsNullOrEmpty(this.hdnUploadFiles.Value))
                    e.IsValid = false;
                else
                    e.IsValid = true;
            }
        }

        protected void rptVisualLayouts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is ImageBO)
            {
                string VlImgLocation = string.Empty;
                ImageBO objImage = (ImageBO)item.DataItem;

                if (objImage != null)
                {
                    VlImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/VisualLayout/" + this.QueryID.ToString() + "/" + objImage.Filename + objImage.Extension;

                    if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + VlImgLocation))
                        VlImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }
                else
                {
                    VlImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }

                System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + VlImgLocation);
                SizeF origImageSize = VLOrigImage.PhysicalDimension;
                VLOrigImage.Dispose();

                List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 250, 140);

                System.Web.UI.WebControls.Image imgVisualLayout = (System.Web.UI.WebControls.Image)item.FindControl("imgVisualLayout");
                imgVisualLayout.ImageUrl = VlImgLocation;
                imgVisualLayout.Width = int.Parse(lstImgDimensions[1].ToString());
                imgVisualLayout.Height = int.Parse(lstImgDimensions[0].ToString());

                CheckBox chkHeroImage = (CheckBox)item.FindControl("chkHeroImage");
                chkHeroImage.Checked = objImage.IsHero;
                chkHeroImage.Attributes.Add("imgid", objImage.ID.ToString());

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("imgid", objImage.ID.ToString());
            }
        }*/

        /*  protected void ddlCoordinator_SelectedIndexChange(object sender, EventArgs e)
          {
              if (int.Parse(this.ddlCoordinator.SelectedValue) == 0)
              {
                  this.ddlDistributor.Enabled = false;
              }
              else
              {
                  this.ddlDistributor.Enabled = true;
                  UserBO objUser = new UserBO();
                  objUser.ID = int.Parse(this.ddlCoordinator.SelectedValue);
                  objUser.GetObject();

                  //Populate Distributor
                  this.ddlDistributor.Items.Clear();
                  this.ddlDistributor.Items.Add(new ListItem("Select Distributor", "0"));
                  List<CompanyBO> lstDistributors = objUser.CompanysWhereThisIsCoordinator;
                  foreach (CompanyBO company in lstDistributors)
                  {
                      this.ddlDistributor.Items.Add(new ListItem(company.Name, company.ID.ToString()));
                  }
              }

              this.PopulateFileUploder(this.rptUploadFile, this.hdnUploadFiles);
          }*/

        protected void ddlDistributor_SelectedIndexChange(object sender, EventArgs e)
        {
            if (int.Parse(this.ddlDistributor.SelectedValue) == 0)
            {
                this.ddlClient.Enabled = false;
                this.lblPrimaryCoordinator.Text = "None";
                //this.lblSecondaryCoordinator.Text = "None";
            }
            else
            {
                this.ddlClient.Enabled = true;

                CompanyBO objCompany = new CompanyBO();
                objCompany.ID = int.Parse(this.ddlDistributor.SelectedValue);
                objCompany.GetObject();

                this.ddlClient.Items.Clear();
                this.ddlClient.Items.Add(new ListItem("Select Client", "0"));
                List<ClientBO> lstClients = objCompany.ClientsWhereThisIsDistributor.OrderBy(o => o.Name).ToList();

                foreach (ClientBO client in lstClients)
                {
                    this.ddlClient.Items.Add(new ListItem(client.Name, client.ID.ToString()));
                }

                this.lbAddNewClient.Attributes.Add("style", (QueryID == 0 && this.ClientID == -1) ? "visibility: visible" : "visibility: hidden");

                this.lblPrimaryCoordinator.Text = (objCompany.Coordinator != null && objCompany.Coordinator > 0) ? objCompany.objCoordinator.GivenName + " " + objCompany.objCoordinator.FamilyName : "None";
                //this.lblSecondaryCoordinator.Text = (objCompany.SecondaryCoordinator != null && objCompany.SecondaryCoordinator > 0) ? objCompany.objSecondaryCoordinator.GivenName + " " + objCompany.objSecondaryCoordinator.FamilyName : "None";
            }
        }

        //protected void btnDeleteVLImage_Click(object sender, EventArgs e)
        //{
        //    int imgId = int.Parse(this.hdnSelectedID.Value);
        //    if (imgId > 0)
        //    {
        //        using (TransactionScope ts = new TransactionScope())
        //        {
        //            try
        //            {
        //                ImageBO objImage = new ImageBO(this.ObjContext);
        //                objImage.ID = imgId;
        //                objImage.GetObject();

        //                objImage.Delete();
        //                this.ObjContext.SaveChanges();
        //                ts.Complete();
        //            }
        //            catch (Exception ex)
        //            {
        //                IndicoLogging.log.Error("Error occured while deleting visual layout image", ex);
        //            }
        //        }

        //        this.PopulateVLImages(0);
        //    }

        //    this.hdnUploadFiles.Value = "0";
        //}

        //protected void lbHeaderPrevious_Click(object sender, EventArgs e)
        //{
        //    LinkButton lk = new LinkButton();
        //    lk.ID = "lbHeader" + (--this.LoadedPageNumber).ToString();
        //    lk.Text = (this.LoadedPageNumber).ToString();
        //    this.lbHeader1_Click(lk, e);
        //}

        //protected void lbHeaderNext_Click(object sender, EventArgs e)
        //{
        //    LinkButton lk = new LinkButton();
        //    lk.ID = "lbHeader" + (++this.LoadedPageNumber).ToString();
        //    lk.Text = (this.LoadedPageNumber).ToString();
        //    this.lbHeader1_Click(lk, e);
        //}

        //protected void lbHeaderNextDots_Click(object sender, EventArgs e)
        //{
        //    LinkButton lk = new LinkButton();
        //    //lk.ID = "lbHeader" + ((ActivitiesTotal % 10 == 0) ? (ActivitiesTotal / 10) : (ActivitiesTotal / 10) + 1).ToString();
        //    //lk.Text = ((ActivitiesTotal % 10 == 0) ? (ActivitiesTotal / 10) : (ActivitiesTotal / 10) + 1).ToString();

        //    int nextSet = (LoadedPageNumber % 10 == 0) ? (LoadedPageNumber + 1) : ((this.LoadedPageNumber / 10) * 10) + 11;
        //    lk.ID = "lbHeader" + nextSet.ToString();
        //    lk.Text = nextSet.ToString();
        //    this.lbHeader1_Click(lk, e);

        //    //((ActivitiesTotal % 10 == 0) ? (ActivitiesTotal / 10) : (ActivitiesTotal / 10) + 1)
        //}

        //protected void lbHeaderPreviousDots_Click(object sender, EventArgs e)
        //{
        //    LinkButton lk = new LinkButton();
        //    //lk.ID = "lbHeader" + (1).ToString();
        //    //lk.Text = (1).ToString();
        //    int previousSet = (LoadedPageNumber % 10 == 0) ? (LoadedPageNumber - 19) : (((this.LoadedPageNumber / 10) * 10) - 9);
        //    lk.ID = "lbHeader" + previousSet.ToString();
        //    lk.Text = previousSet.ToString();
        //    this.lbHeader1_Click(lk, e);
        //}

        //protected void lbHeader1_Click(object sender, EventArgs e)
        //{
        //    string clickedPageText = ((LinkButton)sender).Text;
        //    int clickedPageNumber = Convert.ToInt32(clickedPageText);
        //    ViewState["LoadedPageNumber"] = clickedPageNumber;
        //    int currentPage = 1;

        //    this.ClearCss();

        //    if (clickedPageNumber > 10)
        //        currentPage = (clickedPageNumber % 10) == 0 ? 10 : clickedPageNumber % 10;
        //    else
        //        currentPage = clickedPageNumber;

        //    this.HighLightPageNumber(currentPage);

        //    this.lbFooterNext.Visible = true;
        //    this.lbFooterPrevious.Visible = true;

        //    if (clickedPageNumber == ((VLTotal % rptPageSize == 0) ? VLTotal / rptPageSize : Math.Floor((double)(VLTotal / rptPageSize)) + 1))
        //        this.lbFooterNext.Visible = false;
        //    if (clickedPageNumber == 1)
        //        this.lbFooterPrevious.Visible = false;

        //    int startIndex = clickedPageNumber * 10 - 10;
        //    this.PopulateVLImages(startIndex);

        //    if (clickedPageNumber % 10 == 1)
        //        this.ProcessNumbering(clickedPageNumber, VLPageCount);
        //    else
        //    {
        //        if (clickedPageNumber > 10)
        //        {
        //            if (clickedPageNumber % 10 == 0)
        //                this.ProcessNumbering(clickedPageNumber - 9, VLPageCount);
        //            else
        //                this.ProcessNumbering(((clickedPageNumber / 10) * 10) + 1, VLPageCount);
        //        }
        //        else
        //        {
        //            this.ProcessNumbering((clickedPageNumber / 10 == 0) ? 1 : clickedPageNumber / 10, VLPageCount);
        //        }
        //    }
        //}

        protected void dgPatternAccessory_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            //if (QueryID == 0)
            //{
            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, PatternSupportAccessoryBO>)
            {
                List<PatternSupportAccessoryBO> objPatternPatternAccessory = ((IGrouping<int, PatternSupportAccessoryBO>)item.DataItem).ToList();
                PatternSupportAccessoryBO objPatternAccessory = objPatternPatternAccessory.First();

                Label lblPatternID = (Label)item.FindControl("lblPatternID");
                lblPatternID.Text = objPatternAccessory.objPattern.ID.ToString();

                Label lblAccessoryName = (Label)item.FindControl("lblAccessoryName");
                lblAccessoryName.Text = objPatternAccessory.objAccessory.Name.ToString();

                Label lblAccessoryID = (Label)item.FindControl("lblAccessoryID");
                lblAccessoryID.Text = objPatternAccessory.Accessory.ToString();

                Label lblAccessoryCategory = (Label)item.FindControl("lblAccessoryCategory");
                lblAccessoryCategory.Text = objPatternAccessory.objAccessory.objAccessoryCategory.Name.ToString();

                Label lblAccessoryCategoryID = (Label)item.FindControl("lblAccessoryCategoryID");
                lblAccessoryCategoryID.Text = objPatternAccessory.objAccessory.AccessoryCategory.ToString();

                Label lblCategoryCode = (Label)item.FindControl("lblCategoryCode");
                lblCategoryCode.Text = objPatternAccessory.objAccessory.objAccessoryCategory.Code + objPatternAccessory.objAccessory.Code.ToString();

                DropDownList ddlAccessoryColor = (DropDownList)item.FindControl("ddlAccessoryColor");
                // Populate AccessoryColor dropdown
                ddlAccessoryColor.Items.Add(new ListItem("Select a Color", "0"));
                foreach (AccessoryColorBO AccColor in (new AccessoryColorBO()).SearchObjects())
                {
                    ListItem listItemcolor = new ListItem(AccColor.Name, AccColor.ID.ToString());
                    listItemcolor.Attributes.Add("color", AccColor.ColorValue);
                    ddlAccessoryColor.Items.Add(listItemcolor);
                }

                HtmlGenericControl dvAccessoryColor = (HtmlGenericControl)item.FindControl("dvAccessoryColor");
            }

            //if (item.ItemIndex > -1 && item.DataItem is PatternSupportAccessoryBO)
            //{
            //    PatternSupportAccessoryBO objPatternAccessory = (PatternSupportAccessoryBO)item.DataItem;

            //    Label lblPatternNumber = (Label)item.FindControl("lblPatternNumber");
            //    lblPatternNumber.Text = objPatternAccessory.objPattern.Number;

            //    Label lblPatternID = (Label)item.FindControl("lblPatternID");
            //    lblPatternID.Text = objPatternAccessory.objPattern.ID.ToString();

            //    Label lblAccessoryName = (Label)item.FindControl("lblAccessoryName");
            //    lblAccessoryName.Text = objPatternAccessory.objAccessory.Name.ToString();

            //    Label lblAccessoryID = (Label)item.FindControl("lblAccessoryID");
            //    lblAccessoryID.Text = objPatternAccessory.Accessory.ToString();

            //    Label lblAccessoryCategory = (Label)item.FindControl("lblAccessoryCategory");
            //    lblAccessoryCategory.Text = objPatternAccessory.objAccessory.objAccessoryCategory.Name.ToString();

            //    Label lblAccessoryCategoryID = (Label)item.FindControl("lblAccessoryCategoryID");
            //    lblAccessoryCategoryID.Text = objPatternAccessory.objAccessory.AccessoryCategory.ToString();

            //    Label lblCategoryCode = (Label)item.FindControl("lblCategoryCode");
            //    lblCategoryCode.Text = objPatternAccessory.objAccessory.objAccessoryCategory.Code + objPatternAccessory.objAccessory.Code.ToString();

            //    DropDownList ddlAccessoryColor = (DropDownList)item.FindControl("ddlAccessoryColor");
            //    // Populate AccessoryColor dropdown
            //    ddlAccessoryColor.Items.Add(new ListItem("Select a Color", "0"));
            //    foreach (AccessoryColorBO AccColor in (new AccessoryColorBO()).SearchObjects())
            //    {
            //        ListItem listItemcolor = new ListItem(AccColor.Name, AccColor.ID.ToString());
            //        listItemcolor.Attributes.Add("color", AccColor.ColorValue);
            //        ddlAccessoryColor.Items.Add(listItemcolor);
            //    }

            //    HtmlGenericControl dvAccessoryColor = (HtmlGenericControl)item.FindControl("dvAccessoryColor");
            //    //dvAccessoryColor.Attributes.Add("style", "background-color: " + );
            //}
            //}
            //else if (QueryID > 0)
            //{
            if (item.ItemIndex > -1 && item.DataItem is ArtWorktAccessoryBO)
            {
                ArtWorktAccessoryBO objArtWorkAccessory = (ArtWorktAccessoryBO)item.DataItem;

                Label lblAccessoryName = (Label)item.FindControl("lblAccessoryName");
                lblAccessoryName.Text = objArtWorkAccessory.objAccessory.Name;

                Label lblAccessoryID = (Label)item.FindControl("lblAccessoryID");
                lblAccessoryID.Text = objArtWorkAccessory.Accessory.ToString();
                lblAccessoryID.Attributes.Add("vlaid", objArtWorkAccessory.ID.ToString());

                Label lblAccessoryCategory = (Label)item.FindControl("lblAccessoryCategory");
                lblAccessoryCategory.Text = objArtWorkAccessory.objAccessory.objAccessoryCategory.Name;


                Label lblAccessoryCategoryID = (Label)item.FindControl("lblAccessoryCategoryID");
                lblAccessoryCategoryID.Text = objArtWorkAccessory.objAccessory.AccessoryCategory.ToString();

                Label lblCategoryCode = (Label)item.FindControl("lblCategoryCode");
                lblCategoryCode.Text = objArtWorkAccessory.objAccessory.objAccessoryCategory.Code + objArtWorkAccessory.objAccessory.Code;

                DropDownList ddlAccessoryColor = (DropDownList)item.FindControl("ddlAccessoryColor");
                // Populate AccessoryColor dropdown
                ddlAccessoryColor.Items.Add(new ListItem("Select a Color", "0"));
                foreach (AccessoryColorBO AccColor in (new AccessoryColorBO()).SearchObjects())
                {
                    ListItem listItemcolor = new ListItem(AccColor.Name, AccColor.ID.ToString());
                    listItemcolor.Attributes.Add("color", AccColor.ColorValue);
                    ddlAccessoryColor.Items.Add(listItemcolor);
                }
                ddlAccessoryColor.Items.FindByValue(objArtWorkAccessory.AccessoryColor.ToString()).Selected = true;

                HtmlGenericControl dvAccessoryColor = (HtmlGenericControl)item.FindControl("dvAccessoryColor");
                dvAccessoryColor.Attributes.Add("style", (objArtWorkAccessory.AccessoryColor > 0) ? "background-color: " + objArtWorkAccessory.objAccessoryColor.ColorValue.ToString() : "background-color:#FFFFFF");
            }
            //}

            //if (QueryID > 0 && item.DataItem is VisualLayoutAccessoryBO)
            //{
            //    if (item.ItemIndex > -1 && item.DataItem is VisualLayoutAccessoryBO)
            //    {
            //        VisualLayoutAccessoryBO objVisualLayoutAccessory = (VisualLayoutAccessoryBO)item.DataItem;

            //        Label lblAccessoryName = (Label)item.FindControl("lblAccessoryName");
            //        lblAccessoryName.Text = objVisualLayoutAccessory.objAccessory.Name;

            //        Label lblAccessoryID = (Label)item.FindControl("lblAccessoryID");
            //        lblAccessoryID.Text = objVisualLayoutAccessory.Accessory.ToString();
            //        lblAccessoryID.Attributes.Add("vlaid", objVisualLayoutAccessory.ID.ToString());

            //        Label lblAccessoryCategory = (Label)item.FindControl("lblAccessoryCategory");
            //        lblAccessoryCategory.Text = objVisualLayoutAccessory.objAccessory.objAccessoryCategory.Name;


            //        Label lblAccessoryCategoryID = (Label)item.FindControl("lblAccessoryCategoryID");
            //        lblAccessoryCategoryID.Text = objVisualLayoutAccessory.objAccessory.AccessoryCategory.ToString();

            //        Label lblCategoryCode = (Label)item.FindControl("lblCategoryCode");
            //        lblCategoryCode.Text = objVisualLayoutAccessory.objAccessory.objAccessoryCategory.Code + objVisualLayoutAccessory.objAccessory.Code;

            //        DropDownList ddlAccessoryColor = (DropDownList)item.FindControl("ddlAccessoryColor");
            //        // Populate AccessoryColor dropdown
            //        ddlAccessoryColor.Items.Add(new ListItem("Select a Color", "0"));
            //        foreach (AccessoryColorBO AccColor in (new AccessoryColorBO()).SearchObjects())
            //        {
            //            ListItem listItemcolor = new ListItem(AccColor.Name, AccColor.ID.ToString());
            //            listItemcolor.Attributes.Add("color", AccColor.ColorValue);
            //            ddlAccessoryColor.Items.Add(listItemcolor);
            //        }
            //        ddlAccessoryColor.Items.FindByValue(objVisualLayoutAccessory.AccessoryColor.ToString()).Selected = true;

            //        HtmlGenericControl dvAccessoryColor = (HtmlGenericControl)item.FindControl("dvAccessoryColor");
            //        dvAccessoryColor.Attributes.Add("style", (objVisualLayoutAccessory.AccessoryColor > 0) ? "background-color: " + objVisualLayoutAccessory.objAccessoryColor.ColorValue.ToString() : "background-color:#FFFFFF");
            //    }
            //}

            //if (QueryID > 0 && item.DataItem is PatternSupportAccessoryBO)
            //{
            //    if (item.ItemIndex > -1 && item.DataItem is PatternSupportAccessoryBO)
            //    {
            //        PatternSupportAccessoryBO objPatternAccessory = (PatternSupportAccessoryBO)item.DataItem;

            //        Label lblPatternNumber = (Label)item.FindControl("lblPatternNumber");
            //        lblPatternNumber.Text = objPatternAccessory.objPattern.Number;

            //        Label lblPatternID = (Label)item.FindControl("lblPatternID");
            //        lblPatternID.Text = objPatternAccessory.objPattern.ID.ToString();

            //        Label lblAccessoryName = (Label)item.FindControl("lblAccessoryName");
            //        lblAccessoryName.Text = objPatternAccessory.objAccessory.Name.ToString();

            //        Label lblAccessoryID = (Label)item.FindControl("lblAccessoryID");
            //        lblAccessoryID.Text = objPatternAccessory.Accessory.ToString();

            //        Label lblAccessoryCategory = (Label)item.FindControl("lblAccessoryCategory");
            //        lblAccessoryCategory.Text = objPatternAccessory.objAccessory.objAccessoryCategory.Name.ToString();

            //        Label lblAccessoryCategoryID = (Label)item.FindControl("lblAccessoryCategoryID");
            //        lblAccessoryCategoryID.Text = objPatternAccessory.objAccessory.AccessoryCategory.ToString();

            //        Label lblCategoryCode = (Label)item.FindControl("lblCategoryCode");
            //        lblCategoryCode.Text = objPatternAccessory.objAccessory.objAccessoryCategory.Code + objPatternAccessory.objAccessory.Code.ToString();

            //        DropDownList ddlAccessoryColor = (DropDownList)item.FindControl("ddlAccessoryColor");
            //        // Populate AccessoryColor dropdown
            //        ddlAccessoryColor.Items.Add(new ListItem("Select a Color", "0"));
            //        foreach (AccessoryColorBO AccColor in (new AccessoryColorBO()).SearchObjects())
            //        {
            //            ListItem listItemcolor = new ListItem(AccColor.Name, AccColor.ID.ToString());
            //            listItemcolor.Attributes.Add("color", AccColor.ColorValue);
            //            ddlAccessoryColor.Items.Add(listItemcolor);
            //        }

            //        HtmlGenericControl dvAccessoryColor = (HtmlGenericControl)item.FindControl("dvAccessoryColor");
            //    }
            //}
        }

        //protected void ddlPrintType_SelectedIndexChange(object sender, EventArgs e)
        //{
        //    if (this.rbGenerate.Checked == true)
        //    {
        //        int suffixName = 0;
        //        int id = int.Parse(ddlPrinterType.SelectedValue);
        //        PrinterTypeBO objPrintType = new PrinterTypeBO();
        //        objPrintType.ID = id;
        //        objPrintType.GetObject();

        //        if (objPrintType.Prefix != null)
        //        {
        //            List<AcquiredVisulaLayoutNameBO> lstAcquiredVlName = (from o in (new AcquiredVisulaLayoutNameBO()).SearchObjects().Where(o => o.Name.Contains(Regex.Replace(objPrintType.Prefix, "[^A-Z]", string.Empty))) select o).ToList();

        //            if (objPrintType.Prefix == "VL-")
        //            {
        //                List<LastRecordOfVisullayoutPrefixVLBO> lstLastRecordVLPrefixVL = (from o in (new LastRecordOfVisullayoutPrefixVLBO()).SearchObjects().Where(o => o.NamePrefix == objPrintType.Prefix.Split('-')[0]) select o).ToList();
        //                if (lstAcquiredVlName.Count == 0)
        //                {
        //                    if (lstLastRecordVLPrefixVL.Count == 0)
        //                    {
        //                        namePrefix = objPrintType.Prefix.Split('-')[0];
        //                        nameSuffix = "30000";
        //                        ViewState["vlName"] = namePrefix + " " + nameSuffix;
        //                    }
        //                    else
        //                    {
        //                        if (lstAcquiredVlName.Count == 0)
        //                        {
        //                            suffixName = int.Parse(lstLastRecordVLPrefixVL[0].NameSuffix.ToString()) + 1;
        //                            suffixName = (suffixName < 30000) ? 30000 : suffixName;
        //                            ViewState["vlName"] = lstLastRecordVLPrefixVL[0].NamePrefix + "" + suffixName;
        //                        }
        //                        else
        //                        {
        //                            foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
        //                            {
        //                                if (lstLastRecordVLPrefixVL[0].NameSuffix.Value > int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty)))
        //                                {
        //                                    suffixName = int.Parse(lstLastRecordVLPrefixVL[0].NameSuffix.ToString()) + 1;
        //                                    suffixName = (suffixName < 30000) ? 30000 : suffixName;
        //                                    ViewState["vlName"] = lstLastRecordVLPrefixVL[0].NamePrefix + "" + suffixName;
        //                                }
        //                                else
        //                                {
        //                                    if (lstAcquiredVlName[0].CreatedDate < DateTime.Now.AddHours(-24))
        //                                    {
        //                                        suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty));
        //                                        suffixName = (suffixName < 30000) ? 30000 : suffixName;
        //                                        vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;

        //                                        lstAcquiredVlName = lstAcquiredVlName.Where(o => o.Name.Contains(objPrintType.Prefix.Split('-')[0])).OrderBy(o => o.CreatedDate).ToList();
        //                                        if (lstAcquiredVlName.Count > 1)
        //                                        {
        //                                            foreach (AcquiredVisulaLayoutNameBO vl in lstAcquiredVlName)
        //                                            {
        //                                                suffixName = int.Parse(Regex.Replace(vl.Name, "[^0-9]", string.Empty)) + 1;
        //                                                suffixName = (suffixName < 30000) ? 30000 : suffixName;
        //                                            }

        //                                            vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
        //                                        }
        //                                        ViewState["vlName"] = vlName;
        //                                        break;
        //                                    }
        //                                    else
        //                                    {
        //                                        suffixName = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty)) + 1;
        //                                        suffixName = (suffixName < 30000) ? 30000 : suffixName;
        //                                        ViewState["vlName"] = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
        //                                    }
        //                                }
        //                            }
        //                        }

        //                    }
        //                }
        //                else
        //                {
        //                    if (lstLastRecordVLPrefixVL.Count > 0)
        //                    {
        //                        suffixName = int.Parse(lstLastRecordVLPrefixVL[0].NameSuffix.ToString()) + 1;
        //                        suffixName = (suffixName < 30000) ? 30000 : suffixName;

        //                        vlName = lstLastRecordVLPrefixVL[0].NamePrefix + "" + suffixName;

        //                        foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
        //                        {
        //                            if (acqvLName.CreatedDate < DateTime.Now.AddHours(-24))
        //                            {
        //                                if (!acqvLName.Name.Contains("-") && !acqvLName.Name.Contains(" "))
        //                                {
        //                                    int suffix = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty));
        //                                    suffix = suffix + 1;
        //                                    suffix = (suffix < 30000) ? 30000 : suffix;
        //                                    suffix = (suffixName > suffix) ? suffixName : suffix;
        //                                    vlName = lstLastRecordVLPrefixVL[0].NamePrefix + "" + suffix;
        //                                }
        //                            }
        //                        }

        //                        foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
        //                        {
        //                            int suffix = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty));

        //                            if (suffix >= suffixName)
        //                            {
        //                                suffix = suffix + 1;
        //                                suffix = (suffix < 30000) ? 30000 : suffix;
        //                                vlName = lstLastRecordVLPrefixVL[0].NamePrefix + "" + suffix;
        //                            }
        //                        }

        //                        ViewState["vlName"] = vlName;
        //                    }
        //                    else
        //                    {
        //                        foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
        //                        {
        //                            if (lstAcquiredVlName[0].CreatedDate < DateTime.Now.AddHours(-24))
        //                            {
        //                                suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty));
        //                                vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;

        //                                lstAcquiredVlName = lstAcquiredVlName.Where(o => o.Name.Contains(objPrintType.Prefix.Split('-')[0])).OrderBy(o => o.CreatedDate).ToList();
        //                                if (lstAcquiredVlName.Count > 1)
        //                                {
        //                                    foreach (AcquiredVisulaLayoutNameBO vl in lstAcquiredVlName)
        //                                    {
        //                                        suffixName = int.Parse(Regex.Replace(vl.Name, "[^0-9]", string.Empty)) + 1;
        //                                        suffixName = (suffixName < 30000) ? 30000 : suffixName;
        //                                    }

        //                                    vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
        //                                }
        //                                ViewState["vlName"] = vlName;
        //                                break;


        //                            }
        //                            else
        //                            {

        //                                suffixName = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty)) + 1;
        //                                suffixName = (suffixName < 30000) ? 30000 : suffixName;
        //                                ViewState["vlName"] = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //            else if (objPrintType.Prefix == "CS-")
        //            {
        //                List<LastRecordOfVisullayoutPrefixCSBO> lstLastRecordPrefixCS = (from o in (new LastRecordOfVisullayoutPrefixCSBO()).SearchObjects().Where(o => o.NamePrefix == objPrintType.Prefix.Split('-')[0]) select o).ToList();
        //                if (lstAcquiredVlName.Count == 0)
        //                {
        //                    if (lstLastRecordPrefixCS.Count == 0)
        //                    {
        //                        namePrefix = objPrintType.Prefix.Split('-')[0];
        //                        nameSuffix = "00001";
        //                        ViewState["vlName"] = namePrefix + "" + nameSuffix;
        //                    }
        //                    else
        //                    {
        //                        if (lstAcquiredVlName.Count == 0)
        //                        {
        //                            suffixName = int.Parse(lstLastRecordPrefixCS[0].NameSuffix.ToString()) + 1;
        //                            ViewState["vlName"] = lstLastRecordPrefixCS[0].NamePrefix + "" + suffixName;
        //                        }
        //                        else
        //                        {
        //                            foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
        //                            {
        //                                if (lstLastRecordPrefixCS[0].NameSuffix.Value > int.Parse(acqvLName.Name.Split('-')[1]))
        //                                {
        //                                    suffixName = int.Parse(lstLastRecordPrefixCS[0].NameSuffix.ToString()) + 1;
        //                                    ViewState["vlName"] = lstLastRecordPrefixCS[0].NamePrefix + "" + suffixName;
        //                                }
        //                                else
        //                                {
        //                                    if (lstAcquiredVlName[0].CreatedDate < DateTime.Now.AddHours(-72))
        //                                    {
        //                                        suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty));
        //                                        vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;

        //                                        lstAcquiredVlName = lstAcquiredVlName.Where(o => o.Name.Contains(objPrintType.Prefix.Split('-')[0])).OrderBy(o => o.CreatedDate).ToList();
        //                                        if (lstAcquiredVlName.Count > 1)
        //                                        {
        //                                            foreach (AcquiredVisulaLayoutNameBO vl in lstAcquiredVlName)
        //                                            {
        //                                                suffixName = int.Parse(Regex.Replace(vl.Name, "[^0-9]", string.Empty)) + 1;
        //                                            }

        //                                            vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
        //                                        }
        //                                        ViewState["vlName"] = vlName;
        //                                        break;
        //                                    }
        //                                    else
        //                                    {
        //                                        suffixName = int.Parse(acqvLName.Name.Split('-')[1].ToString()) + 1;
        //                                        ViewState["vlName"] = objPrintType.Prefix + "" + suffixName;
        //                                    }
        //                                }
        //                            }
        //                        }
        //                    }
        //                }
        //                else
        //                {
        //                    if (lstLastRecordPrefixCS.Count > 0)
        //                    {
        //                        suffixName = int.Parse(lstLastRecordPrefixCS[0].NameSuffix.ToString()) + 1;
        //                        vlName = lstLastRecordPrefixCS[0].NamePrefix + "" + suffixName;


        //                        foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
        //                        {
        //                            if (acqvLName.CreatedDate < DateTime.Now.AddHours(-24))
        //                            {
        //                                if (!acqvLName.Name.Contains("-") && !acqvLName.Name.Contains(" "))
        //                                {
        //                                    vlName = acqvLName.Name;
        //                                }
        //                            }
        //                        }

        //                        foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
        //                        {
        //                            int suffix = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty));

        //                            if (suffix >= suffixName)
        //                            {
        //                                suffix = suffix + 1;
        //                                vlName = lstLastRecordPrefixCS[0].NamePrefix + "" + suffix;
        //                            }
        //                        }

        //                        ViewState["vlName"] = vlName;
        //                    }
        //                    else
        //                    {
        //                        foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
        //                        {
        //                            if (lstAcquiredVlName[0].CreatedDate < DateTime.Now.AddHours(-72))
        //                            {
        //                                suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty));
        //                                vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;

        //                                lstAcquiredVlName = lstAcquiredVlName.Where(o => o.Name.Contains(objPrintType.Prefix.Split('-')[0])).OrderBy(o => o.CreatedDate).ToList();
        //                                if (lstAcquiredVlName.Count > 1)
        //                                {
        //                                    foreach (AcquiredVisulaLayoutNameBO vl in lstAcquiredVlName)
        //                                    {
        //                                        suffixName = int.Parse(Regex.Replace(vl.Name, "[^0-9]", string.Empty)) + 1;
        //                                    }

        //                                    vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
        //                                }
        //                                ViewState["vlName"] = vlName;
        //                                break;
        //                            }
        //                            else
        //                            {

        //                                suffixName = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty)) + 1;
        //                                ViewState["vlName"] = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
        //                            }
        //                        }
        //                    }
        //                }
        //            }

        //            else if (objPrintType.Prefix == "DY-")
        //            {
        //                List<LastRecordOfVisullayoutPrefixDYBO> lstLastRecordVlPrefixDY = (from o in (new LastRecordOfVisullayoutPrefixDYBO()).SearchObjects().Where(o => o.NamePrefix == objPrintType.Prefix.Split('-')[0]) select o).ToList();

        //                if (lstAcquiredVlName.Count == 0)
        //                {
        //                    if (lstLastRecordVlPrefixDY.Count == 0)
        //                    {
        //                        namePrefix = objPrintType.Prefix.Split('-')[0];//(objPrintType.Prefix != null) ? objPrintType.Prefix.Split('-')[0] : string.Empty;
        //                        nameSuffix = "00001";
        //                        ViewState["vlName"] = namePrefix + " " + nameSuffix;
        //                    }
        //                    else
        //                    {
        //                        if (lstAcquiredVlName.Count == 0)
        //                        {
        //                            suffixName = int.Parse(lstLastRecordVlPrefixDY[0].NameSuffix.ToString()) + 1;
        //                            ViewState["vlName"] = lstLastRecordVlPrefixDY[0].NamePrefix + "" + suffixName;
        //                        }
        //                        else
        //                        {
        //                            foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
        //                            {
        //                                if (lstLastRecordVlPrefixDY[0].NameSuffix.Value > int.Parse(acqvLName.Name.Split('-')[1]))
        //                                {
        //                                    suffixName = int.Parse(lstLastRecordVlPrefixDY[0].NameSuffix.ToString()) + 1;
        //                                    ViewState["vlName"] = lstLastRecordVlPrefixDY[0].NamePrefix + "" + suffixName;
        //                                }
        //                                else
        //                                {
        //                                    if (lstAcquiredVlName[0].CreatedDate < DateTime.Now.AddHours(-72))
        //                                    {
        //                                        suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty));
        //                                        vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;

        //                                        lstAcquiredVlName = lstAcquiredVlName.Where(o => o.Name.Contains(objPrintType.Prefix.Split('-')[0])).OrderBy(o => o.CreatedDate).ToList();
        //                                        if (lstAcquiredVlName.Count > 1)
        //                                        {
        //                                            foreach (AcquiredVisulaLayoutNameBO vl in lstAcquiredVlName)
        //                                            {
        //                                                suffixName = int.Parse(Regex.Replace(vl.Name, "[^0-9]", string.Empty)) + 1;
        //                                            }

        //                                            vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
        //                                        }
        //                                        ViewState["vlName"] = vlName;
        //                                        break;
        //                                    }
        //                                    else
        //                                    {
        //                                        suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty)) + 1;
        //                                        ViewState["vlName"] = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
        //                                    }
        //                                }
        //                            }
        //                        }
        //                    }
        //                }
        //                else
        //                {
        //                    if (lstLastRecordVlPrefixDY.Count > 0)
        //                    {
        //                        suffixName = int.Parse(lstLastRecordVlPrefixDY[0].NameSuffix.ToString()) + 1;
        //                        vlName = lstLastRecordVlPrefixDY[0].NamePrefix + "" + suffixName;

        //                        foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
        //                        {
        //                            if (acqvLName.CreatedDate < DateTime.Now.AddHours(-24))
        //                            {
        //                                if (!acqvLName.Name.Contains("-") && !acqvLName.Name.Contains(" "))
        //                                {
        //                                    vlName = acqvLName.Name;
        //                                }
        //                            }
        //                        }

        //                        foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
        //                        {
        //                            int suffix = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty));

        //                            if (suffix >= suffixName)
        //                            {
        //                                suffix = suffix + 1;
        //                                vlName = lstLastRecordVlPrefixDY[0].NamePrefix + "" + suffix;
        //                            }
        //                        }

        //                        ViewState["vlName"] = vlName;
        //                    }
        //                    else
        //                    {
        //                        foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
        //                        {
        //                            if (lstAcquiredVlName[0].CreatedDate < DateTime.Now.AddHours(-72))
        //                            {
        //                                suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty));
        //                                vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;

        //                                lstAcquiredVlName = lstAcquiredVlName.Where(o => o.Name.Contains(objPrintType.Prefix.Split('-')[0])).OrderBy(o => o.CreatedDate).ToList();
        //                                if (lstAcquiredVlName.Count > 1)
        //                                {
        //                                    foreach (AcquiredVisulaLayoutNameBO vl in lstAcquiredVlName)
        //                                    {
        //                                        suffixName = int.Parse(Regex.Replace(vl.Name, "[^0-9]", string.Empty)) + 1;
        //                                    }

        //                                    vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
        //                                }
        //                                ViewState["vlName"] = vlName;
        //                                break;
        //                            }
        //                            else
        //                            {

        //                                suffixName = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty)) + 1;
        //                                ViewState["vlName"] = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //            using (TransactionScope ts = new TransactionScope())
        //            {
        //                try
        //                {
        //                    AcquiredVisulaLayoutNameBO objAcquiredVisualLayout = new AcquiredVisulaLayoutNameBO(this.ObjContext);

        //                    objAcquiredVisualLayout.Name = ViewState["vlName"].ToString();
        //                    objAcquiredVisualLayout.CreatedDate = DateTime.Now;

        //                    objAcquiredVisualLayout.Add();

        //                    ObjContext.SaveChanges();
        //                    ts.Complete();
        //                }
        //                catch (Exception)
        //                {
        //                    throw;
        //                }
        //            }
        //        }
        //    }

        //    this.txtProductNumber.Text = (ViewState["vlName"] != null) ? ViewState["vlName"].ToString() : string.Empty;           
        //}

        //protected void IsCommonProduct_Changed(object sender, EventArgs e)
        //{
        //    if (this.checkIsCommonproduct.Checked == true)
        //    {
        //        this.dvHideColums.Visible = false;
        //    }
        //    else
        //    {
        //        this.dvHideColums.Visible = true;
        //    }
        //}

        protected void linkViewPattern_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int pattern = int.Parse(this.ddlPattern.SelectedValue);

                PatternBO objPattern = new PatternBO();
                objPattern.ID = pattern;
                objPattern.GetObject();

                //Fill the pattern popup data
                //this.txtPatternNo.Text = objPattern.Number;
                //this.txtItemName.Text = (objPattern.Item > 0) ? objPattern.objItem.Name : string.Empty;
                //this.txtSizeSet.Text = (objPattern.SizeSet > 0) ? objPattern.objSizeSet.Name : string.Empty;
                //this.txtAgeGroup.Text = (objPattern.AgeGroup != null && objPattern.AgeGroup > 0) ? objPattern.objAgeGroup.Name : string.Empty;
                //this.txtPrinterType.Text = (objPattern.PrinterType > 0) ? objPattern.objPrinterType.Name : string.Empty;
                //this.txtKeyword.Text = objPattern.Keywords;

                //this.txtOriginalRef.Text = objPattern.OriginRef;
                //this.txtSubItem.Text = (objPattern.SubItem != null && objPattern.SubItem > 0) ? objPattern.objSubItem.Name : string.Empty;
                //this.txtGender.Text = (objPattern.Gender > 0) ? objPattern.objGender.Name : string.Empty;
                //this.txtNickName.Text = objPattern.NickName;
                //this.txtCorrPattern.Text = objPattern.CorePattern;
                //this.txtConsumption.Text = objPattern.Consumption;

                ViewState["PopulatePatern"] = true;
            }
        }

        protected void linkSpecification_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int pattern = int.Parse(this.ddlPattern.SelectedValue);

                PatternBO objPattern = new PatternBO();
                objPattern.ID = pattern;
                objPattern.GetObject();

                List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = (objPattern.SizeChartsWhereThisIsPattern).OrderBy(o => o.MeasurementLocation).GroupBy(o => o.MeasurementLocation).ToList();
                if (lstSizeChartGroup.Count > 0)
                {
                    //this.rptSpecSizeQtyHeader.DataSource = (List<SizeChartBO>)lstSizeChartGroup[0].ToList();
                    //this.rptSpecSizeQtyHeader.DataBind();

                    //this.rptSpecML.DataSource = lstSizeChartGroup;
                    //this.rptSpecML.DataBind();
                }
                this.linkSpecification.Visible = (lstSizeChartGroup.Count > 0);

                ViewState["PopulateFabric"] = true;
            }
        }

        //protected void cvProductNumber_OnServerValidate(object sender, ServerValidateEventArgs e)
        //{
        //    if (this.rbCustom.Checked == true)
        //    {
        //        List<VisualLayoutBO> lstVisualLayout = new List<VisualLayoutBO>();
        //        if (!string.IsNullOrEmpty(this.txtProductNumber.Text))
        //        {
        //            lstVisualLayout = (from o in (new VisualLayoutBO()).SearchObjects().Where(o => o.NamePrefix.Trim().ToLower() == this.txtProductNumber.Text.Trim().ToLower() &&
        //                                                                                           o.ID != QueryID)
        //                               select o).ToList();
        //        }

        //        e.IsValid = !(lstVisualLayout.Count > 0);
        //    }
        //}

        protected void ddlPattern_OnSelectedIndexChanged(object sender, EventArgs e)
        {
            int Pattern = int.Parse(this.ddlPattern.SelectedValue);
            this.PopulateAccessories(Pattern);
        }

        protected void lbAddNewClient_Click(object sender, EventArgs e)
        {
            if (int.Parse(this.ddlDistributor.SelectedValue) > 0)
            {
                #region Populate VisualLayout

                PopulateOrders objPopulateVisualLayout = new PopulateOrders();
                //objPopulateVisualLayout.IsCommonProduct = this.checkIsCommonproduct.Checked;               
                objPopulateVisualLayout.productNumber = this.txtReferenceNumber.Text;
                objPopulateVisualLayout.vlDistributor = int.Parse(this.ddlDistributor.SelectedValue);
                objPopulateVisualLayout.Fabric = int.Parse(this.ddlFabric.SelectedValue);
                objPopulateVisualLayout.Pattern = int.Parse(this.ddlPattern.SelectedValue);

                Session["populateVisualLayout"] = objPopulateVisualLayout;

                #endregion

                Response.Redirect("/AddEditClient.aspx?vl=" + this.QueryID.ToString() + "&dir=" + this.ddlDistributor.SelectedValue);
            }
            else
            {
                CustomValidator cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpVL";
                cv.ErrorMessage = "Distributor is required";
                Page.Validators.Add(cv);
            }
        }

        protected void btnCancel_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect("/ViewVisualLayouts.aspx");
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            //this.cvLayoutImage.Enabled = false;
            this.litHeaderText.Text = (this.QueryID > 0) ? "Edit Art Work" : "New Art Work";
            this.dvHideColums.Visible = true;
            this.lblPrimaryCoordinator.Text = "None";
            //this.lblSecondaryCoordinator.Text = "None";

            //ViewState["PopulatePatern"] = false;

            this.PopulatePatterns();
            this.PopulateFabrics();

            //populate Resolution Profile
            this.ddlResolutionProfile.Items.Clear();
            this.ddlResolutionProfile.Items.Add(new ListItem("Select Resolution Profile", "0"));
            List<ResolutionProfileBO> lstResolutionProfile = (new ResolutionProfileBO()).GetAllObject().ToList();
            foreach (ResolutionProfileBO res in lstResolutionProfile)
            {
                this.ddlResolutionProfile.Items.Add(new ListItem(res.Name, res.ID.ToString()));
            }

            if (this.QueryID < 1)
            {
                this.ddlResolutionProfile.Items.FindByText("CMYK HIGH RES").Selected = true;
            }

            // populate Distributor
            this.ddlDistributor.Items.Clear();
            this.ddlDistributor.Items.Add(new ListItem("Select Distributor", "0"));
            List<CompanyBO> lstComapny = (from o in (new CompanyBO()).GetAllObject().Where(o => o.IsDistributor == true && o.IsActive == true && o.IsDelete == false).OrderBy(o => o.Name) select o).ToList();
            foreach (CompanyBO company in lstComapny)
            {
                this.ddlDistributor.Items.Add(new ListItem(company.Name, company.ID.ToString()));
            }

            // Populate Pocket Type
            this.ddlPocketType.Items.Add(new ListItem("Select Pocket Type", "0"));
            List<PocketTypeBO> lstPocketType = (new PocketTypeBO()).GetAllObject();
            foreach (PocketTypeBO pt in lstPocketType)
            {
                this.ddlPocketType.Items.Add(new ListItem(pt.Name, pt.ID.ToString()));
            }

            if (this.QueryID > 0)
            {
                ArtWorkBO objArtWork = new ArtWorkBO();
                objArtWork.ID = this.QueryID;
                objArtWork.GetObject();

                List<FabricCodeBO> lstFabrics = (new FabricCodeBO()).SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();

                this.txtReferenceNumber.Text = objArtWork.ReferenceNo;
                this.ddlDistributor.SelectedValue = (objArtWork.Client != null && objArtWork.Client > 0) ? objArtWork.objClient.objClient.objDistributor.ID.ToString() : "0";
                this.ddlDistributor_SelectedIndexChange(null, null);

                int pocket = objArtWork.PocketType ?? 0;
                if (pocket > 0)
                    this.ddlPocketType.Items.FindByValue(pocket.ToString()).Selected = true;

                this.ddlResolutionProfile.Items.FindByValue((objArtWork.ResolutionProfile != null && objArtWork.ResolutionProfile > 0) ? objArtWork.ResolutionProfile.Value.ToString() : "0").Selected = true;

                //this.checkIsCommonproduct.Checked = (objVisualLayout.IsCommonProduct == true) ? true : false;

                this.ddlClient.SelectedValue = objArtWork.Client.ToString();
                this.ddlFabric.Items.FindByValue(objArtWork.FabricCode.ToString()).Selected = true;

                PatternBO objPattern = new PatternBO();
                objPattern.ID = objArtWork.Pattern;
                objPattern.GetObject();

                if (objPattern.IsActive)
                {
                    this.ddlPattern.Items.FindByValue(objArtWork.Pattern.ToString()).Selected = true;
                }
                else
                {
                    this.litPatternError.Visible = true;
                    this.litPatternError.Text = "Associated Pattern ( <strong>" + objPattern.Number + " - " + objPattern.NickName + "</strong> ) for this Product is inactive. Please activate the pattern or select diffrent pattern";
                }

                ArtWorktAccessoryBO objAWA = new ArtWorktAccessoryBO();
                objAWA.ArtWork = QueryID;
                List<ArtWorktAccessoryBO> lstArtWorkAccessories = objAWA.SearchObjects();

                if (lstArtWorkAccessories.Count > 0)
                {
                    this.dvNewDataContent.Visible = true;
                    this.dvAccessoryEmptyContent.Visible = false;
                    this.dgPatternAccessory.DataSource = lstArtWorkAccessories;
                    this.dgPatternAccessory.DataBind();
                }
                //else
                //{
                //    /*this.dvNewDataContent.Visible = true;
                //    this.dvAccessoryEmptyContent.Visible = true;
                //    this.dgPatternAccessory.Visible = false;*/
                //    this.PopulateAccessories(objArtWork.Pattern);
                //}
            }
            else if (this.DistributorID > 0)
            {
                this.ddlDistributor.SelectedValue = this.DistributorID.ToString();
                this.ddlDistributor_SelectedIndexChange(null, null);

                this.ddlClient.SelectedValue = this.ClientID.ToString();
            }
            //else if (this.DistributorID == -1 && this.ClientID > 0)
            //{
            //    this.PopulateVisualLayout();
            //}
        }

        //private void PopulateVLImages(int startIndex)
        //{
        //    this.dvVLImagePreview.Visible = false;

        //    VisualLayoutBO objVisualLayout = new VisualLayoutBO();
        //    objVisualLayout.ID = this.QueryID;
        //    objVisualLayout.GetObject();

        //    if (objVisualLayout.ImagesWhereThisIsVisualLayout.Count > 0)
        //    {
        //        this.dvVLImagePreview.Visible = true;

        //        #region Pagination Process

        //        int TotVLCount = objVisualLayout.ImagesWhereThisIsVisualLayout.Count;
        //        int count = 0;

        //        if (TotVLCount < rptPageSize)
        //            count = TotVLCount;
        //        else
        //        {
        //            if (startIndex == 0)
        //                count = rptPageSize;
        //            else
        //            {
        //                if ((count + rptPageSize) > TotVLCount)
        //                    count = rptPageSize;
        //                else
        //                {
        //                    if (startIndex + rptPageSize > TotVLCount)
        //                        count = TotVLCount % 10;
        //                    else
        //                        count = rptPageSize;
        //                }
        //            }
        //        }

        //        ViewState["VLTotal"] = TotVLCount;
        //        ViewState["VLPageCount"] = (TotVLCount % 10 == 0) ? (TotVLCount / 10) : (TotVLCount / 10 + 1);

        //        this.dvPagingFooter.Visible = (TotVLCount > rptPageSize);
        //        this.lbFooterPrevious.Visible = (startIndex != 0 && startIndex != 90);
        //        this.ProcessNumbering(1, Convert.ToInt32(ViewState["VLPageCount"]));
        //        //this.lblPageCountString.Text = "Showing " + (startIndex + 1).ToString() + " to " + (count + startIndex).ToString() + " of " + TotArticleCount + " Articles";

        //        #endregion

        //        this.rptVisualLayouts.DataSource = objVisualLayout.ImagesWhereThisIsVisualLayout.GetRange(startIndex, count);
        //        this.rptVisualLayouts.DataBind();
        //    }
        //    else
        //    {
        //        this.rptVisualLayouts.DataSource = null;
        //        this.rptVisualLayouts.DataBind();
        //        this.dvEmptyContentVLImages.Visible = true;
        //    }
        //}

        private void PopulatePatterns()
        {
            Dictionary<int, string> patterns = (new PatternBO()).SearchObjects().AsQueryable().OrderBy(o => o.Number).Where(o => o.IsActive == true).Select(o => new { Key = o.ID, Value = (o.Number + " - " + o.NickName) }).ToDictionary(o => o.Key, o => o.Value);
            Dictionary<int, string> dicPatterns = new Dictionary<int, string>();

            dicPatterns.Add(0, "Please select or type...");
            foreach (KeyValuePair<int, string> item in patterns)
            {
                dicPatterns.Add(item.Key, item.Value);
            }

            this.ddlPattern.DataSource = dicPatterns;
            this.ddlPattern.DataTextField = "Value";
            this.ddlPattern.DataValueField = "Key";
            this.ddlPattern.DataBind();
        }

        private void PopulateFabrics()
        {
            Dictionary<int, string> fabrics = (new FabricCodeBO()).SearchObjects().AsQueryable().OrderBy(o => o.Name).ToList().Select(o => new { Key = o.ID, Value = (o.Code + " - " + o.Name) }).ToDictionary(o => o.Key, o => o.Value);
            Dictionary<int, string> dicFabrics = new Dictionary<int, string>();

            dicFabrics.Add(0, "Please select or type...");
            foreach (KeyValuePair<int, string> item in fabrics)
            {
                dicFabrics.Add(item.Key, item.Value);
            }

            this.ddlFabric.DataSource = dicFabrics;
            this.ddlFabric.DataTextField = "Value";
            this.ddlFabric.DataValueField = "Key";
            this.ddlFabric.DataBind();
        }

        private int ProcessForm()
        {
            int visualLayout = 0;
            try
            {
                ArtWorkBO objArtWork = new ArtWorkBO(this.ObjContext);

                using (TransactionScope ts = new TransactionScope())
                {
                    try
                    {
                        if (this.QueryID > 0)
                        {
                            objArtWork.ID = this.QueryID;
                            objArtWork.GetObject();
                        }

                        //if (this.QueryID == 0)
                        //{
                        //    /*  #region Generate New VL Number

                        //      string NewVLNumber = string.Empty;

                        //      if ((new VisualLayoutBO()).GetAllObject().Count == 0)
                        //          NewVLNumber = "VL001";
                        //      else
                        //          NewVLNumber = "VL" + ((new VisualLayoutBO()).GetAllObject().Select(o => int.Parse(o.NamePrefix.Substring(2))).ToList().Max() + 1).ToString("000");

                        //      objVisualLayout.NamePrefix = NewVLNumber;

                        //      #endregion*/
                        //    List<AcquiredVisulaLayoutNameBO> lstAcquiredVlName = (from o in (new AcquiredVisulaLayoutNameBO()).SearchObjects().Where(o => o.Name == txtProductNumber.Text) select o).ToList();
                        //    if (lstAcquiredVlName.Count > 0)
                        //    {
                        //        objArtWork.CreatedDate = lstAcquiredVlName[0].CreatedDate;
                        //    }
                        //    else
                        //    {
                        //        objArtWork.CreatedDate = DateTime.Now;
                        //    }
                        //}

                        //List<ArtWorkBO> lstArtWorks = (from o in objArtWork.SearchObjects().Where(o => o.ReferenceNo.Trim().ToLower() == this.txtProductNumber.Text.Trim().ToLower() && QueryID > 0) select o).ToList();

                        //if (lstArtWorks.Count > 0)
                        //{
                        //    objArtWork.ReferenceNo = this.txtProductNumber.Text;
                        //}

                        //  objVisualLayout.Coordinator = (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? int.Parse(this.ddlCoordinator.SelectedValue) : (int?)null;

                        //if (this.ddlDistributor.Items.Count > 0)
                        //{
                        //    objVisualLayout.Distributor = (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? int.Parse(this.ddlDistributor.SelectedValue) : (int?)null;
                        //}
                        //else
                        //{
                        //    objVisualLayout.Distributor = (int?)null;
                        //}

                        objArtWork.ReferenceNo = this.txtReferenceNumber.Text;
                        objArtWork.Client = this.ddlClient.SelectedValue != string.Empty ? int.Parse(this.ddlClient.SelectedValue) : (int?)null;
                        objArtWork.FabricCode = int.Parse(this.ddlFabric.SelectedValue);
                        objArtWork.Pattern = int.Parse(this.ddlPattern.SelectedValue);
                        objArtWork.ResolutionProfile = int.Parse(this.ddlResolutionProfile.SelectedValue);
                        objArtWork.CreatedDate = DateTime.Now;
                        int pocket = int.Parse(this.ddlPocketType.SelectedValue);
                        if (pocket > 0)
                            objArtWork.PocketType = pocket;

                        //objVisualLayout.IsCommonProduct = (this.checkIsCommonproduct.Checked == true) ? true : false;

                        //VL Images
                        //if (this.hdnUploadFiles.Value != "0" || /*!string.IsNullOrEmpty(this.hdnPatternId.Value)*/ (int.Parse(this.ddlPattern.SelectedValue) > 0)) //New VL
                        //{
                        //    int n = 0;
                        //    foreach (string fileName in this.hdnUploadFiles.Value.Split('|').Select(o => o.Split(',')[0]))
                        //    {
                        //        if (fileName != string.Empty)
                        //        {
                        //            n++;
                        //            ImageBO objImage = new ImageBO(this.ObjContext);
                        //            objImage.Filename = Path.GetFileNameWithoutExtension(fileName);
                        //            objImage.Extension = Path.GetExtension(fileName);
                        //            objImage.Size = (int)(new FileInfo(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileName)).Length;
                        //            if (this.QueryID == 0 || objArtWork.ImagesWhereThisIsVisualLayout.Count == 0)
                        //            {
                        //                objImage.IsHero = (n == 1) ? true : false;
                        //            }
                        //            if (QueryID == 0)
                        //            {
                        //                objArtWork.ImagesWhereThisIsVisualLayout.Add(objImage);
                        //            }
                        //            else
                        //            {
                        //                objImage.VisualLayout = QueryID;
                        //            }

                        //            // objImage.Add();
                        //            //this.ObjContext.SaveChanges();
                        //        }
                        //    }
                        //}

                        ViewState["visualLayoutNa"] = this.txtReferenceNumber.Text;

                        //if (this.QueryID > 0)
                        //{
                        //    foreach (RepeaterItem item in this.rptVisualLayouts.Items)
                        //    {
                        //        CheckBox chkHeroImage = (CheckBox)item.FindControl("chkHeroImage");
                        //        int imgId = int.Parse(chkHeroImage.Attributes["qid"].ToString());

                        //        ImageBO objImage = new ImageBO(this.ObjContext);
                        //        objImage.ID = imgId;
                        //        objImage.GetObject();

                        //        objImage.IsHero = chkHeroImage.Checked;
                        //        //this.ObjContext.SaveChanges();
                        //    }
                        //}

                        this.ObjContext.SaveChanges();
                        ts.Complete();

                        visualLayout = objArtWork.ID;
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while saving Art Work", ex);
                    }
                }

                ViewState["artWorkID"] = objArtWork.ID;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving Art Work", ex);
            }

            return visualLayout;
        }

        private void SaveAccessories()
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    if (this.QueryID == 0)
                    {
                        foreach (DataGridItem item in dgPatternAccessory.Items)
                        {
                            ArtWorktAccessoryBO objVisualLayoutAccessory = new ArtWorktAccessoryBO(this.ObjContext);
                            Label lblAccessoryID = (Label)(item.FindControl("lblAccessoryID"));
                            Label lblAccessoryCategoryID = (Label)(item.FindControl("lblAccessoryCategoryID"));
                            DropDownList ddlAccessoryColor = (DropDownList)(item.FindControl("ddlAccessoryColor"));

                            objVisualLayoutAccessory.Accessory = int.Parse(lblAccessoryID.Text);
                            objVisualLayoutAccessory.AccessoryColor = int.Parse(ddlAccessoryColor.SelectedValue);
                            objVisualLayoutAccessory.ArtWork = visualLayoutID;
                        }
                    }
                    else if (this.QueryID > 0)
                    {
                        ArtWorktAccessoryBO objVLA = new ArtWorktAccessoryBO();
                        objVLA.ArtWork = QueryID;

                        List<int> lstVisualLayoutAccessoryID = objVLA.SearchObjects().Select(m => m.ID).ToList();

                        if (lstVisualLayoutAccessoryID.Any())
                        {
                            foreach (DataGridItem item in dgPatternAccessory.Items)
                            {
                                Label lblAccessoryID = (Label)item.FindControl("lblAccessoryID");
                                int id = int.Parse(((System.Web.UI.WebControls.WebControl)(lblAccessoryID)).Attributes["vlaid"].ToString());

                                if (id > 0)
                                {
                                    ArtWorktAccessoryBO objVisualLayoutAccessory = new ArtWorktAccessoryBO(this.ObjContext);
                                    objVisualLayoutAccessory.ID = id;
                                    objVisualLayoutAccessory.GetObject();

                                    DropDownList ddlAccessoryColor = (DropDownList)(item.FindControl("ddlAccessoryColor"));

                                    objVisualLayoutAccessory.AccessoryColor = int.Parse(ddlAccessoryColor.SelectedValue);
                                }
                            }
                        }
                        else
                        {
                            foreach (DataGridItem item in dgPatternAccessory.Items)
                            {
                                ArtWorktAccessoryBO objVisualLayoutAccessory = new ArtWorktAccessoryBO(this.ObjContext);
                                Label lblAccessoryID = (Label)(item.FindControl("lblAccessoryID"));
                                Label lblAccessoryCategoryID = (Label)(item.FindControl("lblAccessoryCategoryID"));
                                DropDownList ddlAccessoryColor = (DropDownList)(item.FindControl("ddlAccessoryColor"));

                                objVisualLayoutAccessory.Accessory = int.Parse(lblAccessoryID.Text);
                                objVisualLayoutAccessory.AccessoryColor = int.Parse(ddlAccessoryColor.SelectedValue);
                                objVisualLayoutAccessory.ArtWork = QueryID;
                            }
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving Visual Layout", ex);
            }
        }

        //private void ProcessNumbering(int start, int count)
        //{
        //    this.lbFooterPreviousDots.Visible = true;
        //    this.lbFooterNextDots.Visible = true;

        //    int i = start;
        //    // 1
        //    if (i <= count)
        //    {
        //        this.lbFooter1.Visible = true;
        //        this.lbFooter1.Text = (start++).ToString();
        //    }
        //    else
        //    {
        //        this.lbFooter1.Visible = false;
        //    }
        //    // 2
        //    if (++i <= count)
        //    {
        //        this.lbFooter2.Visible = true;
        //        this.lbFooter2.Text = (start++).ToString();
        //    }
        //    else
        //    {
        //        this.lbFooter2.Visible = false;
        //    }
        //    // 3
        //    if (++i <= count)
        //    {
        //        this.lbFooter3.Visible = true;
        //        this.lbFooter3.Text = (start++).ToString();
        //    }
        //    else
        //    {
        //        this.lbFooter3.Visible = false;
        //    }
        //    // 4
        //    if (++i <= count)
        //    {
        //        this.lbFooter4.Visible = true;
        //        this.lbFooter4.Text = (start++).ToString();
        //    }
        //    else
        //    {
        //        this.lbFooter4.Visible = false;
        //    }
        //    // 5
        //    if (++i <= count)
        //    {
        //        this.lbFooter5.Visible = true;
        //        this.lbFooter5.Text = (start++).ToString();
        //    }
        //    else
        //    {
        //        this.lbFooter5.Visible = false;
        //    }
        //    // 6
        //    if (++i <= count)
        //    {
        //        this.lbFooter6.Visible = true;
        //        this.lbFooter6.Text = (start++).ToString();
        //    }
        //    else
        //    {
        //        this.lbFooter6.Visible = false;
        //    }
        //    // 7
        //    if (++i <= count)
        //    {
        //        this.lbFooter7.Visible = true;
        //        this.lbFooter7.Text = (start++).ToString();
        //    }
        //    else
        //    {
        //        this.lbFooter7.Visible = false;
        //    }
        //    // 8
        //    if (++i <= count)
        //    {
        //        this.lbFooter8.Visible = true;
        //        this.lbFooter8.Text = (start++).ToString();
        //    }
        //    else
        //    {
        //        this.lbFooter8.Visible = false;
        //    }
        //    // 9
        //    if (++i <= count)
        //    {
        //        this.lbFooter9.Visible = true;
        //        this.lbFooter9.Text = (start++).ToString();
        //    }
        //    else
        //    {
        //        this.lbFooter9.Visible = false;
        //    }
        //    // 10
        //    if (++i <= count)
        //    {
        //        this.lbFooter10.Visible = true;
        //        this.lbFooter10.Text = (start++).ToString();
        //    }
        //    else
        //    {
        //        this.lbFooter10.Visible = false;
        //    }

        //    int loadedPageTemp = (LoadedPageNumber % 10 == 0) ? ((LoadedPageNumber - 1) / 10) : (LoadedPageNumber / 10);

        //    if (VLTotal <= 10 * rptPageSize)
        //    {
        //        this.lbFooterPreviousDots.Visible = false;
        //        this.lbFooterNextDots.Visible = false;
        //    }

        //    else if (VLTotal - ((loadedPageTemp) * 10 * rptPageSize) <= 10 * rptPageSize)
        //    {
        //        this.lbFooterNextDots.Visible = false;
        //    }
        //    else
        //    {
        //        this.lbFooterPreviousDots.Visible = (this.lbFooter1.Text == "1") ? false : true;
        //    }
        //}

        //private void HighLightPageNumber(int clickedPageNumber)
        //{
        //    LinkButton clickedLink = (LinkButton)this.FindControlRecursive(this, "lbFooter" + clickedPageNumber);
        //    clickedLink.CssClass = "paginatorLink current";
        //}

        //private void ClearCss()
        //{
        //    for (int i = 1; i <= 10; i++)
        //    {
        //        LinkButton lbFooter = (LinkButton)this.FindControlRecursive(this, "lbFooter" + i.ToString());
        //        lbFooter.CssClass = "paginatorLink";
        //    }
        //}

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

        //private void PopulateVisualLayout()
        //{
        //    PopulateOrders objPopulateVisualLayout = (PopulateOrders)Session["populateVisualLayout"];
        //    //this.checkIsCommonproduct.Checked = objPopulateVisualLayout.IsCommonProduct;

        //    if (objPopulateVisualLayout.IsCommonProduct)
        //    {
        //        this.dvHideColums.Visible = false;
        //    }
        //    else
        //    {
        //        this.dvHideColums.Visible = true;
        //    }

        //    this.txtProductNumber.Text = objPopulateVisualLayout.productNumber;
        //    this.rbGenerate.Checked = objPopulateVisualLayout.IsGenerate;
        //    this.rbCustom.Checked = objPopulateVisualLayout.IsCustom;

        //    if (this.rbGenerate.Checked == true)
        //    {
        //        //this.lblProductNumber.Attributes.Remove("class");
        //        this.liPrinterType.Visible = true;
        //        this.txtProductNumber.Enabled = false;

        //    }
        //    else if (this.rbCustom.Checked == true)
        //    {
        //        //this.lblProductNumber.Attributes.Add("class", "control-label required");
        //        this.liPrinterType.Visible = false;
        //        this.txtProductNumber.Enabled = true;
        //    }

        //    this.ddlDistributor.Items.FindByValue(objPopulateVisualLayout.vlDistributor.ToString()).Selected = true;
        //    this.ddlDistributor.Items.FindByValue("0").Selected = false;

        //    this.ddlDistributor_SelectedIndexChange(null, null);

        //    this.ddlClient.Items.FindByValue("0").Selected = false;
        //    this.ddlClient.SelectedValue = this.ClientID.ToString();
        //    this.ddlFabric.Items.FindByValue("0").Selected = false;
        //    this.ddlPattern.Items.FindByValue("0").Selected = false;
        //    this.ddlFabric.Items.FindByValue(objPopulateVisualLayout.Fabric.ToString()).Selected = true;
        //    this.ddlPattern.Items.FindByValue(objPopulateVisualLayout.Pattern.ToString()).Selected = true;

        //    this.ddlPattern_OnSelectedIndexChanged(null, null);

        //    Session["populateVisualLayout"] = null;
        //}

        private void PopulateAccessories(int Pattern)
        {
            this.dvNewDataContent.Visible = true;

            if (Pattern > 0)
            {
                PatternSupportAccessoryBO objPSA = new PatternSupportAccessoryBO();
                objPSA.Pattern = Pattern;
                objPSA.GetObject();

                List<IGrouping<int, PatternSupportAccessoryBO>> lstPatternAccessory = objPSA.SearchObjects().GroupBy(m => m.Accessory).ToList();

                if (lstPatternAccessory.Count > 0)
                {
                    this.dvAccessoryEmptyContent.Visible = false;
                    this.dgPatternAccessory.Visible = true;
                    this.dgPatternAccessory.DataSource = lstPatternAccessory;
                    this.dgPatternAccessory.DataBind();
                }
                else
                {
                    this.dvNewDataContent.Visible = true;
                    this.dvAccessoryEmptyContent.Visible = true;
                    this.dgPatternAccessory.Visible = false;
                }
            }
        }

        #endregion
    }
}