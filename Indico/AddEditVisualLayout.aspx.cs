using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Transactions;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using Dapper;
using Indico.BusinessObjects;
using Indico.Common;
using Image = System.Drawing.Image;

namespace Indico
{
    public partial class AddEditVisualLayout : IndicoPage
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

        //protected int DistributorID
        //{
        //    get
        //    {
        //        return urlDisributorID;
        //    }
        //}

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
                int visualLayoutID = (int)ViewState["visualLayoutID"];

                return visualLayoutID;
            }
            set
            {
                ViewState["visualLayoutID"] = value;
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

        public bool IsNotRefreshed
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

            ResetViewStateValues();

            CustomValidator cv = null;

            //if (this.checkIsCommonproduct.Checked == false)
            //{
            if (string.IsNullOrEmpty(this.txtProductNumber.Text))
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpVL";
                cv.ErrorMessage = "Product No. is required";
                Page.Validators.Add(cv);
            }

            cvProductNumber_OnServerValidate(null, null);

            if (int.Parse(this.ddlDistributor.SelectedValue) == 0)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpVL";
                cv.ErrorMessage = "Distributor is required";
                Page.Validators.Add(cv);
            }

            if (string.IsNullOrEmpty(this.ddlJobName.SelectedValue) || int.Parse(this.ddlJobName.SelectedValue) == 0)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpVL";
                cv.ErrorMessage = "JobName is required";
                Page.Validators.Add(cv);
            }

            /*if (int.Parse(this.ddlFabric.SelectedValue) == 0)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpVL";
                cv.ErrorMessage = "Fabric is required";
                Page.Validators.Add(cv);
            }*/

            if (int.Parse(this.ddlPattern.SelectedValue) == 0)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpVL";
                cv.ErrorMessage = "Pattern is required";
                Page.Validators.Add(cv);
            }
            //}

            if (int.Parse(this.ddlBySizeArtwork.SelectedValue) == 0)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpVL";
                cv.ErrorMessage = "By-Size Artwork is required";
                Page.Validators.Add(cv);
            }

            if (this.hdnUploadFiles.Value != "0") // || /*!string.IsNullOrEmpty(this.hdnPatternId.Value)*/ (int.Parse(this.ddlPattern.SelectedValue) > 0)) //New VL
            {
                int n = 0;
                foreach (string fileName in this.hdnUploadFiles.Value.Split('|').Select(o => o.Split(',')[0]))
                {
                    if (fileName != string.Empty)
                    {
                        n++;

                        string fileExtension = Path.GetExtension(fileName).ToLower();

                        if (!(fileExtension == ".jpeg" || fileExtension == ".jpg" || fileExtension == ".png"))
                        {
                            cv = new CustomValidator();
                            cv.IsValid = false;
                            cv.ValidationGroup = "valGrpVL";
                            cv.ErrorMessage = "Invalid Image file.";
                            Page.Validators.Add(cv);

                            break;
                        }
                    }
                }
            }

            if (Page.IsValid)
            {
                var visualLayout = ProcessForm();
                SaveAccessories();

                //if (this.OrderID > -1)
                //{
                //    Response.Redirect("/AddEditOrder.aspx?id=" + this.OrderID + "&vln=" + visualLayout);
                //}
                //else
                //{
                var myobService = new MyobService();
                myobService.SaveVisualLayout(visualLayoutID);
                Response.Redirect("/ViewVisualLayouts.aspx");
                //}
            }
        }

        protected void btnSearchPattern_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            if (Page.IsValid)
            {
                this.PopulatePatterns();
            }
            //else
            //{
            //    this.validationSummary.Visible = !Page.IsValid;
            //}
            //ViewState["PopulatePatern"] = true;
            this.PopulateFileUploder(this.rptUploadFile, this.hdnUploadFiles);
        }

        protected void btnClose_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect("ViewVisualLayouts.aspx");
        }

        protected void cvLabel_OnServerValidate(object sender, ServerValidateEventArgs e)
        {
            if (this.QueryID == 0)
            {
                if (this.hdnUploadFiles.Value == "0" || string.IsNullOrEmpty(this.hdnUploadFiles.Value))
                    e.IsValid = false;
                else
                    e.IsValid = true;
            }


            VisualLayoutBO objVisualLayout = new VisualLayoutBO();
            objVisualLayout.ID = this.QueryID;
            objVisualLayout.GetObject();

            if (this.QueryID > 0)
            {
                if (objVisualLayout.ImagesWhereThisIsVisualLayout.Count == 0)
                {
                    if (this.hdnUploadFiles.Value == "0" || string.IsNullOrEmpty(this.hdnUploadFiles.Value))
                        e.IsValid = false;
                    else
                        e.IsValid = true;

                }
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

                try
                {
                    Image VLOrigImage = Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + VlImgLocation);
                    SizeF origImageSize = VLOrigImage.PhysicalDimension;
                    VLOrigImage.Dispose();

                    List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 300, 300);

                    System.Web.UI.WebControls.Image imgVisualLayout = (System.Web.UI.WebControls.Image)item.FindControl("imgVisualLayout");
                    imgVisualLayout.ImageUrl = VlImgLocation;
                    imgVisualLayout.Width = int.Parse(lstImgDimensions[1].ToString());
                    imgVisualLayout.Height = int.Parse(lstImgDimensions[0].ToString());
                }
                catch (Exception ex)
                {
                    VlImgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }

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
            ddlClient.Items.Clear();
            ddlJobNameClient.Items.Clear();
            ddlJobName.Items.Clear();
            this.litClient.Text = string.Empty;
            this.litJobName.Text = string.Empty;
            this.ancEditClient.Visible = false;
            this.btnEditJobName.Visible = false;

            if (int.Parse(this.ddlDistributor.SelectedValue) == 0)
            {
                this.ddlClient.Enabled = false;
                this.lblPrimaryCoordinator.Text = "None";
                this.lblSecondaryCoordinator.Text = "None";
                this.ancNewClient.Visible = false;
            }
            else
            {
                this.ddlClient.Enabled = true;
                this.ancNewClient.Visible = true;

                CompanyBO objCompany = new CompanyBO();
                objCompany.ID = int.Parse(this.ddlDistributor.SelectedValue);
                objCompany.GetObject();

                this.ddlClient.Items.Add(new ListItem("Select Client", "0"));
                this.ddlJobNameClient.Items.Add(new ListItem("Select Client", "0"));

                List<ClientBO> lstClients = objCompany.ClientsWhereThisIsDistributor.OrderBy(o => o.Name).ToList();

                foreach (ClientBO client in lstClients)
                {
                    this.ddlClient.Items.Add(new ListItem(client.Name, client.ID.ToString()));
                    this.ddlJobNameClient.Items.Add(new ListItem(client.Name, client.ID.ToString()));
                }

                ddlClientDistributor.ClearSelection();
                ddlClientDistributor.Items.FindByValue(this.ddlDistributor.SelectedValue).Selected = true;
                //lblclient.Text = this.ddlDistributor.SelectedItem.Text;

                this.lblPrimaryCoordinator.Text = (objCompany.Coordinator != null && objCompany.Coordinator > 0) ? objCompany.objCoordinator.GivenName + " " + objCompany.objCoordinator.FamilyName : "None";
                this.lblSecondaryCoordinator.Text = (objCompany.SecondaryCoordinator != null && objCompany.SecondaryCoordinator > 0) ? objCompany.objSecondaryCoordinator.GivenName + " " + objCompany.objSecondaryCoordinator.FamilyName : "None";
            }
        }

        protected void ddlClient_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateJobNames(int.Parse(ddlClient.SelectedValue));
        }

        protected void ddlJobName_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlJobName.SelectedIndex > 0)
            {
                JobNameBO objJobName = new JobNameBO();
                objJobName.ID = int.Parse(ddlJobName.SelectedValue);
                objJobName.GetObject();

                this.litJobName.Text = objJobName.Name +
                   (string.IsNullOrEmpty(objJobName.Address) ? string.Empty : (" " + objJobName.Address)) +
                   (string.IsNullOrEmpty(objJobName.City) ? string.Empty : (" " + objJobName.City)) +
                   (string.IsNullOrEmpty(objJobName.State) ? string.Empty : (" " + objJobName.State)) +
                   (string.IsNullOrEmpty(objJobName.PostalCode) ? string.Empty : (" " + objJobName.PostalCode)) +
                   (string.IsNullOrEmpty(objJobName.Country) ? string.Empty : (" " + objJobName.Country))
                    ;
                this.btnEditJobName.Visible = true;
            }
            else
            {
                this.litJobName.Text = string.Empty;
                this.btnEditJobName.Visible = false;
            }
        }

        protected void btnDeleteVLImage_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            int imgId = int.Parse(this.hdnSelectedID.Value);
            if (imgId > 0)
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    try
                    {
                        ImageBO objImage = new ImageBO(this.ObjContext);
                        objImage.ID = imgId;
                        objImage.GetObject();

                        objImage.Delete();
                        this.ObjContext.SaveChanges();

                        string destinationFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\VisualLayout\\" + objImage.VisualLayout.ToString() + "\\" + objImage.Filename + objImage.Extension;

                        if (File.Exists(destinationFilePath))
                        {
                            File.Delete(destinationFilePath);
                        }

                        ts.Complete();
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while deleting visual layout image", ex);
                    }
                }

                this.PopulateVLImages(0);
            }

            this.hdnUploadFiles.Value = "";
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

            if (clickedPageNumber == ((VLTotal % rptPageSize == 0) ? VLTotal / rptPageSize : Math.Floor((double)(VLTotal / rptPageSize)) + 1))
                this.lbFooterNext.Visible = false;
            if (clickedPageNumber == 1)
                this.lbFooterPrevious.Visible = false;

            int startIndex = clickedPageNumber * 10 - 10;
            this.PopulateVLImages(startIndex);

            if (clickedPageNumber % 10 == 1)
                this.ProcessNumbering(clickedPageNumber, VLPageCount);
            else
            {
                if (clickedPageNumber > 10)
                {
                    if (clickedPageNumber % 10 == 0)
                        this.ProcessNumbering(clickedPageNumber - 9, VLPageCount);
                    else
                        this.ProcessNumbering(((clickedPageNumber / 10) * 10) + 1, VLPageCount);
                }
                else
                {
                    this.ProcessNumbering((clickedPageNumber / 10 == 0) ? 1 : clickedPageNumber / 10, VLPageCount);
                }
            }
        }

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
            if (item.ItemIndex > -1 && item.DataItem is VisualLayoutAccessoryBO)
            {
                VisualLayoutAccessoryBO objVisualLayoutAccessory = (VisualLayoutAccessoryBO)item.DataItem;

                Label lblAccessoryName = (Label)item.FindControl("lblAccessoryName");
                lblAccessoryName.Text = objVisualLayoutAccessory.objAccessory.Name;

                Label lblAccessoryID = (Label)item.FindControl("lblAccessoryID");
                lblAccessoryID.Text = objVisualLayoutAccessory.Accessory.ToString();
                lblAccessoryID.Attributes.Add("vlaid", objVisualLayoutAccessory.ID.ToString());

                Label lblAccessoryCategory = (Label)item.FindControl("lblAccessoryCategory");
                lblAccessoryCategory.Text = objVisualLayoutAccessory.objAccessory.objAccessoryCategory.Name;


                Label lblAccessoryCategoryID = (Label)item.FindControl("lblAccessoryCategoryID");
                lblAccessoryCategoryID.Text = objVisualLayoutAccessory.objAccessory.AccessoryCategory.ToString();

                Label lblCategoryCode = (Label)item.FindControl("lblCategoryCode");
                lblCategoryCode.Text = objVisualLayoutAccessory.objAccessory.objAccessoryCategory.Code + objVisualLayoutAccessory.objAccessory.Code;

                DropDownList ddlAccessoryColor = (DropDownList)item.FindControl("ddlAccessoryColor");
                // Populate AccessoryColor dropdown
                ddlAccessoryColor.Items.Add(new ListItem("Select a Color", "0"));
                foreach (AccessoryColorBO AccColor in (new AccessoryColorBO()).SearchObjects())
                {
                    ListItem listItemcolor = new ListItem(AccColor.Name, AccColor.ID.ToString());
                    listItemcolor.Attributes.Add("color", AccColor.ColorValue);
                    ddlAccessoryColor.Items.Add(listItemcolor);
                }
                ddlAccessoryColor.Items.FindByValue(objVisualLayoutAccessory.AccessoryColor.ToString()).Selected = true;

                HtmlGenericControl dvAccessoryColor = (HtmlGenericControl)item.FindControl("dvAccessoryColor");
                dvAccessoryColor.Attributes.Add("style", (objVisualLayoutAccessory.AccessoryColor > 0) ? "background-color: " + objVisualLayoutAccessory.objAccessoryColor.ColorValue.ToString() : "background-color:#FFFFFF");
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

        protected void txtProductNumber_TextChanged(object sender, EventArgs e)
        {
            ResetViewStateValues();
            cvProductNumber.Validate();
        }

        protected void ddlPrintType_SelectedIndexChange(object sender, EventArgs e)
        {
            if (this.rbGenerate.Checked == true)
            {
                int suffixName = 0;
                int id = int.Parse(ddlPrinterType.SelectedValue);
                PrinterTypeBO objPrintType = new PrinterTypeBO();
                objPrintType.ID = id;
                objPrintType.GetObject();

                if (objPrintType.Prefix != null)
                {
                    List<AcquiredVisulaLayoutNameBO> lstAcquiredVlName = (from o in (new AcquiredVisulaLayoutNameBO()).SearchObjects().Where(o => o.Name.Contains(Regex.Replace(objPrintType.Prefix, "[^A-Z]", string.Empty))) select o).ToList();

                    if (objPrintType.Prefix == "VL-")
                    {
                        List<LastRecordOfVisullayoutPrefixVLBO> lstLastRecordVLPrefixVL = (from o in (new LastRecordOfVisullayoutPrefixVLBO()).SearchObjects().Where(o => o.NamePrefix == objPrintType.Prefix.Split('-')[0]) select o).ToList();
                        if (lstAcquiredVlName.Count == 0)
                        {
                            if (lstLastRecordVLPrefixVL.Count == 0)
                            {
                                namePrefix = objPrintType.Prefix.Split('-')[0];
                                nameSuffix = "30000";
                                ViewState["vlName"] = namePrefix + " " + nameSuffix;
                            }
                            else
                            {
                                if (lstAcquiredVlName.Count == 0)
                                {
                                    suffixName = int.Parse(lstLastRecordVLPrefixVL[0].NameSuffix.ToString()) + 1;
                                    suffixName = (suffixName < 30000) ? 30000 : suffixName;
                                    ViewState["vlName"] = lstLastRecordVLPrefixVL[0].NamePrefix + "" + suffixName;
                                }
                                else
                                {
                                    foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
                                    {
                                        if (lstLastRecordVLPrefixVL[0].NameSuffix.Value > int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty)))
                                        {
                                            suffixName = int.Parse(lstLastRecordVLPrefixVL[0].NameSuffix.ToString()) + 1;
                                            suffixName = (suffixName < 30000) ? 30000 : suffixName;
                                            ViewState["vlName"] = lstLastRecordVLPrefixVL[0].NamePrefix + "" + suffixName;
                                        }
                                        else
                                        {
                                            if (lstAcquiredVlName[0].CreatedDate < DateTime.Now.AddHours(-24))
                                            {
                                                suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty));
                                                suffixName = (suffixName < 30000) ? 30000 : suffixName;
                                                vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;

                                                lstAcquiredVlName = lstAcquiredVlName.Where(o => o.Name.Contains(objPrintType.Prefix.Split('-')[0])).OrderBy(o => o.CreatedDate).ToList();
                                                if (lstAcquiredVlName.Count > 1)
                                                {
                                                    foreach (AcquiredVisulaLayoutNameBO vl in lstAcquiredVlName)
                                                    {
                                                        suffixName = int.Parse(Regex.Replace(vl.Name, "[^0-9]", string.Empty)) + 1;
                                                        suffixName = (suffixName < 30000) ? 30000 : suffixName;
                                                    }

                                                    vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
                                                }
                                                ViewState["vlName"] = vlName;
                                                break;
                                            }
                                            else
                                            {
                                                suffixName = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty)) + 1;
                                                suffixName = (suffixName < 30000) ? 30000 : suffixName;
                                                ViewState["vlName"] = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
                                            }
                                        }
                                    }
                                }

                            }
                        }
                        else
                        {
                            if (lstLastRecordVLPrefixVL.Count > 0)
                            {
                                suffixName = int.Parse(lstLastRecordVLPrefixVL[0].NameSuffix.ToString()) + 1;
                                suffixName = (suffixName < 30000) ? 30000 : suffixName;

                                vlName = lstLastRecordVLPrefixVL[0].NamePrefix + "" + suffixName;

                                foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
                                {
                                    if (acqvLName.CreatedDate < DateTime.Now.AddHours(-24))
                                    {
                                        if (!acqvLName.Name.Contains("-") && !acqvLName.Name.Contains(" "))
                                        {
                                            int suffix = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty));
                                            suffix = suffix + 1;
                                            suffix = (suffix < 30000) ? 30000 : suffix;
                                            suffix = (suffixName > suffix) ? suffixName : suffix;
                                            vlName = lstLastRecordVLPrefixVL[0].NamePrefix + "" + suffix;
                                        }
                                    }
                                }

                                foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
                                {
                                    int suffix = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty));

                                    if (suffix >= suffixName)
                                    {
                                        suffix = suffix + 1;
                                        suffix = (suffix < 30000) ? 30000 : suffix;
                                        vlName = lstLastRecordVLPrefixVL[0].NamePrefix + "" + suffix;
                                    }
                                }

                                ViewState["vlName"] = vlName;
                            }
                            else
                            {
                                foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
                                {
                                    if (lstAcquiredVlName[0].CreatedDate < DateTime.Now.AddHours(-24))
                                    {
                                        suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty));
                                        vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;

                                        lstAcquiredVlName = lstAcquiredVlName.Where(o => o.Name.Contains(objPrintType.Prefix.Split('-')[0])).OrderBy(o => o.CreatedDate).ToList();
                                        if (lstAcquiredVlName.Count > 1)
                                        {
                                            foreach (AcquiredVisulaLayoutNameBO vl in lstAcquiredVlName)
                                            {
                                                suffixName = int.Parse(Regex.Replace(vl.Name, "[^0-9]", string.Empty)) + 1;
                                                suffixName = (suffixName < 30000) ? 30000 : suffixName;
                                            }

                                            vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
                                        }
                                        ViewState["vlName"] = vlName;
                                        break;


                                    }
                                    else
                                    {

                                        suffixName = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty)) + 1;
                                        suffixName = (suffixName < 30000) ? 30000 : suffixName;
                                        ViewState["vlName"] = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
                                    }
                                }
                            }
                        }
                    }
                    else if (objPrintType.Prefix == "CS-")
                    {
                        List<LastRecordOfVisullayoutPrefixCSBO> lstLastRecordPrefixCS = (from o in (new LastRecordOfVisullayoutPrefixCSBO()).SearchObjects().Where(o => o.NamePrefix == objPrintType.Prefix.Split('-')[0]) select o).ToList();
                        if (lstAcquiredVlName.Count == 0)
                        {
                            if (lstLastRecordPrefixCS.Count == 0)
                            {
                                namePrefix = objPrintType.Prefix.Split('-')[0];
                                nameSuffix = "00001";
                                ViewState["vlName"] = namePrefix + "" + nameSuffix;
                            }
                            else
                            {
                                if (lstAcquiredVlName.Count == 0)
                                {
                                    suffixName = int.Parse(lstLastRecordPrefixCS[0].NameSuffix.ToString()) + 1;
                                    ViewState["vlName"] = lstLastRecordPrefixCS[0].NamePrefix + "" + suffixName;
                                }
                                else
                                {
                                    foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
                                    {
                                        if (lstLastRecordPrefixCS[0].NameSuffix.Value > int.Parse(acqvLName.Name.Split('-')[1]))
                                        {
                                            suffixName = int.Parse(lstLastRecordPrefixCS[0].NameSuffix.ToString()) + 1;
                                            ViewState["vlName"] = lstLastRecordPrefixCS[0].NamePrefix + "" + suffixName;
                                        }
                                        else
                                        {
                                            if (lstAcquiredVlName[0].CreatedDate < DateTime.Now.AddHours(-72))
                                            {
                                                suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty));
                                                vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;

                                                lstAcquiredVlName = lstAcquiredVlName.Where(o => o.Name.Contains(objPrintType.Prefix.Split('-')[0])).OrderBy(o => o.CreatedDate).ToList();
                                                if (lstAcquiredVlName.Count > 1)
                                                {
                                                    foreach (AcquiredVisulaLayoutNameBO vl in lstAcquiredVlName)
                                                    {
                                                        suffixName = int.Parse(Regex.Replace(vl.Name, "[^0-9]", string.Empty)) + 1;
                                                    }

                                                    vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
                                                }
                                                ViewState["vlName"] = vlName;
                                                break;
                                            }
                                            else
                                            {
                                                suffixName = int.Parse(acqvLName.Name.Split('-')[1].ToString()) + 1;
                                                ViewState["vlName"] = objPrintType.Prefix + "" + suffixName;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {
                            if (lstLastRecordPrefixCS.Count > 0)
                            {
                                suffixName = int.Parse(lstLastRecordPrefixCS[0].NameSuffix.ToString()) + 1;
                                vlName = lstLastRecordPrefixCS[0].NamePrefix + "" + suffixName;


                                foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
                                {
                                    if (acqvLName.CreatedDate < DateTime.Now.AddHours(-24))
                                    {
                                        if (!acqvLName.Name.Contains("-") && !acqvLName.Name.Contains(" "))
                                        {
                                            vlName = acqvLName.Name;
                                        }
                                    }
                                }

                                foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
                                {
                                    int suffix = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty));

                                    if (suffix >= suffixName)
                                    {
                                        suffix = suffix + 1;
                                        vlName = lstLastRecordPrefixCS[0].NamePrefix + "" + suffix;
                                    }
                                }

                                ViewState["vlName"] = vlName;
                            }
                            else
                            {
                                foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
                                {
                                    if (lstAcquiredVlName[0].CreatedDate < DateTime.Now.AddHours(-72))
                                    {
                                        suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty));
                                        vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;

                                        lstAcquiredVlName = lstAcquiredVlName.Where(o => o.Name.Contains(objPrintType.Prefix.Split('-')[0])).OrderBy(o => o.CreatedDate).ToList();
                                        if (lstAcquiredVlName.Count > 1)
                                        {
                                            foreach (AcquiredVisulaLayoutNameBO vl in lstAcquiredVlName)
                                            {
                                                suffixName = int.Parse(Regex.Replace(vl.Name, "[^0-9]", string.Empty)) + 1;
                                            }

                                            vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
                                        }
                                        ViewState["vlName"] = vlName;
                                        break;
                                    }
                                    else
                                    {

                                        suffixName = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty)) + 1;
                                        ViewState["vlName"] = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
                                    }
                                }
                            }
                        }
                    }

                    else if (objPrintType.Prefix == "DY-")
                    {
                        List<LastRecordOfVisullayoutPrefixDYBO> lstLastRecordVlPrefixDY = (from o in (new LastRecordOfVisullayoutPrefixDYBO()).SearchObjects().Where(o => o.NamePrefix == objPrintType.Prefix.Split('-')[0]) select o).ToList();

                        if (lstAcquiredVlName.Count == 0)
                        {
                            if (lstLastRecordVlPrefixDY.Count == 0)
                            {
                                namePrefix = objPrintType.Prefix.Split('-')[0];//(objPrintType.Prefix != null) ? objPrintType.Prefix.Split('-')[0] : string.Empty;
                                nameSuffix = "00001";
                                ViewState["vlName"] = namePrefix + " " + nameSuffix;
                            }
                            else
                            {
                                if (lstAcquiredVlName.Count == 0)
                                {
                                    suffixName = int.Parse(lstLastRecordVlPrefixDY[0].NameSuffix.ToString()) + 1;
                                    ViewState["vlName"] = lstLastRecordVlPrefixDY[0].NamePrefix + "" + suffixName;
                                }
                                else
                                {
                                    foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
                                    {
                                        if (lstLastRecordVlPrefixDY[0].NameSuffix.Value > int.Parse(acqvLName.Name.Split('-')[1]))
                                        {
                                            suffixName = int.Parse(lstLastRecordVlPrefixDY[0].NameSuffix.ToString()) + 1;
                                            ViewState["vlName"] = lstLastRecordVlPrefixDY[0].NamePrefix + "" + suffixName;
                                        }
                                        else
                                        {
                                            if (lstAcquiredVlName[0].CreatedDate < DateTime.Now.AddHours(-72))
                                            {
                                                suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty));
                                                vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;

                                                lstAcquiredVlName = lstAcquiredVlName.Where(o => o.Name.Contains(objPrintType.Prefix.Split('-')[0])).OrderBy(o => o.CreatedDate).ToList();
                                                if (lstAcquiredVlName.Count > 1)
                                                {
                                                    foreach (AcquiredVisulaLayoutNameBO vl in lstAcquiredVlName)
                                                    {
                                                        suffixName = int.Parse(Regex.Replace(vl.Name, "[^0-9]", string.Empty)) + 1;
                                                    }

                                                    vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
                                                }
                                                ViewState["vlName"] = vlName;
                                                break;
                                            }
                                            else
                                            {
                                                suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty)) + 1;
                                                ViewState["vlName"] = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {
                            if (lstLastRecordVlPrefixDY.Count > 0)
                            {
                                suffixName = int.Parse(lstLastRecordVlPrefixDY[0].NameSuffix.ToString()) + 1;
                                vlName = lstLastRecordVlPrefixDY[0].NamePrefix + "" + suffixName;

                                foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
                                {
                                    if (acqvLName.CreatedDate < DateTime.Now.AddHours(-24))
                                    {
                                        if (!acqvLName.Name.Contains("-") && !acqvLName.Name.Contains(" "))
                                        {
                                            vlName = acqvLName.Name;
                                        }
                                    }
                                }

                                foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
                                {
                                    int suffix = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty));

                                    if (suffix >= suffixName)
                                    {
                                        suffix = suffix + 1;
                                        vlName = lstLastRecordVlPrefixDY[0].NamePrefix + "" + suffix;
                                    }
                                }

                                ViewState["vlName"] = vlName;
                            }
                            else
                            {
                                foreach (AcquiredVisulaLayoutNameBO acqvLName in lstAcquiredVlName)
                                {
                                    if (lstAcquiredVlName[0].CreatedDate < DateTime.Now.AddHours(-72))
                                    {
                                        suffixName = int.Parse(Regex.Replace(lstAcquiredVlName[0].Name, "[^0-9]", string.Empty));
                                        vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;

                                        lstAcquiredVlName = lstAcquiredVlName.Where(o => o.Name.Contains(objPrintType.Prefix.Split('-')[0])).OrderBy(o => o.CreatedDate).ToList();
                                        if (lstAcquiredVlName.Count > 1)
                                        {
                                            foreach (AcquiredVisulaLayoutNameBO vl in lstAcquiredVlName)
                                            {
                                                suffixName = int.Parse(Regex.Replace(vl.Name, "[^0-9]", string.Empty)) + 1;
                                            }

                                            vlName = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
                                        }
                                        ViewState["vlName"] = vlName;
                                        break;
                                    }
                                    else
                                    {

                                        suffixName = int.Parse(Regex.Replace(acqvLName.Name, "[^0-9]", string.Empty)) + 1;
                                        ViewState["vlName"] = objPrintType.Prefix.Split('-')[0] + "" + suffixName;
                                    }
                                }
                            }
                        }
                    }
                    using (TransactionScope ts = new TransactionScope())
                    {
                        try
                        {
                            AcquiredVisulaLayoutNameBO objAcquiredVisualLayout = new AcquiredVisulaLayoutNameBO(this.ObjContext);

                            objAcquiredVisualLayout.Name = ViewState["vlName"].ToString();
                            objAcquiredVisualLayout.CreatedDate = DateTime.Now;

                            objAcquiredVisualLayout.Add();

                            ObjContext.SaveChanges();
                            ts.Complete();
                        }
                        catch (Exception)
                        {
                            throw;
                        }
                    }
                }
            }

            this.txtProductNumber.Text = (ViewState["vlName"] != null) ? ViewState["vlName"].ToString() : string.Empty;
            this.PopulateFileUploder(this.rptUploadFile, this.hdnUploadFiles);
        }

        protected void IsProduct_OnCheckChanged(object sender, EventArgs e)
        {
            ResetViewStateValues();
            this.IsGeneratedProduct();
            this.PopulateFileUploder(this.rptUploadFile, this.hdnUploadFiles);
        }

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
            ResetViewStateValues();

            if (this.IsNotRefresh)
            {
                int pattern = int.Parse(this.ddlPattern.SelectedValue);

                PatternBO objPattern = new PatternBO();
                objPattern.ID = pattern;
                objPattern.GetObject();

                //Fill the pattern popup data
                this.txtPatternNo.Text = objPattern.Number;
                this.txtItemName.Text = (objPattern.Item > 0) ? objPattern.objItem.Name : string.Empty;
                this.txtSizeSet.Text = (objPattern.SizeSet > 0) ? objPattern.objSizeSet.Name : string.Empty;
                this.txtAgeGroup.Text = (objPattern.AgeGroup != null && objPattern.AgeGroup > 0) ? objPattern.objAgeGroup.Name : string.Empty;
                this.txtPrinterType.Text = (objPattern.PrinterType > 0) ? objPattern.objPrinterType.Name : string.Empty;
                this.txtKeyword.Text = objPattern.Keywords;

                this.txtOriginalRef.Text = objPattern.OriginRef;
                this.txtSubItem.Text = (objPattern.SubItem != null && objPattern.SubItem > 0) ? objPattern.objSubItem.Name : string.Empty;
                this.txtGender.Text = (objPattern.Gender > 0) ? objPattern.objGender.Name : string.Empty;
                this.txtNickName.Text = objPattern.NickName;
                this.txtCorrPattern.Text = objPattern.CorePattern;
                this.txtConsumption.Text = objPattern.Consumption;

                ViewState["PopulatePatern"] = true;
            }
        }

        protected void linkSpecification_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            if (this.IsNotRefresh)
            {
                int pattern = int.Parse(this.ddlPattern.SelectedValue);

                PatternBO objPattern = new PatternBO();
                objPattern.ID = pattern;
                objPattern.GetObject();

                List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = (objPattern.SizeChartsWhereThisIsPattern).OrderBy(o => o.MeasurementLocation).GroupBy(o => o.MeasurementLocation).ToList();
                if (lstSizeChartGroup.Count > 0)
                {
                    this.rptSpecSizeQtyHeader.DataSource = (List<SizeChartBO>)lstSizeChartGroup[0].ToList();
                    this.rptSpecSizeQtyHeader.DataBind();

                    this.rptSpecML.DataSource = lstSizeChartGroup;
                    this.rptSpecML.DataBind();
                }
                this.linkSpecification.Visible = (lstSizeChartGroup.Count > 0);

                ViewState["PopulateFabric"] = true;
            }
        }

        protected void cvProductNumber_OnServerValidate(object sender, ServerValidateEventArgs e)
        {
            //if (this.rbCustom.Checked == true)
            //{           
            List<VisualLayoutBO> lstVisualLayout = new List<VisualLayoutBO>();

            if (!string.IsNullOrEmpty(this.txtProductNumber.Text))
            {
                //lstVisualLayout = (from o in (new VisualLayoutBO()).SearchObjects().Where(o => o.NamePrefix.Trim().ToLower() == this.txtProductNumber.Text.Trim().ToLower() &&
                //                                                                               o.ID != QueryID)
                //                   select o).ToList();

                //cvProductNumber.IsValid = !(lstVisualLayout.Count > 0);

                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(this.QueryID, "VisualLayout", "NamePrefix", this.txtProductNumber.Text);
                cvProductNumber.IsValid = objReturnInt.RetVal == 1;

                if (cvProductNumber.IsValid)
                {
                    lblCheckName.Text = "Available.";
                    lblCheckName.ForeColor = Color.Green;
                }
                else
                {
                    lblCheckName.Text = "Not available.";
                    lblCheckName.ForeColor = Color.Red;
                }
            }
            else
            {
                lblCheckName.Text = "Product Number is required.";
                lblCheckName.ForeColor = Color.Red;
            }

            //}
        }

        protected void btnSaveClient_ServerClick(object sender, EventArgs e)
        {
            ResetViewStateValues();

            //if (!IsNotRefreshed) return;
            if (Page.IsValid)
            {
                try
                {
                    int id = int.Parse(hdnClientID.Value);
                    int newClient = 0;

                    using (TransactionScope ts = new TransactionScope())
                    {
                        ClientBO objClient = new ClientBO(this.ObjContext);

                        if (id > 0)
                        {
                            objClient.ID = id;
                            objClient.GetObject();
                        }

                        objClient.Distributor = int.Parse(ddlClientDistributor.SelectedValue);
                        objClient.Name = txtNewClient.Text;

                        //objJobName.Creator = this.LoggedUser.ID;
                        //objJobName.CreatedDate = DateTime.Now;
                        //objJobName.Modifier = this.LoggedUser.ID;
                        //objJobName.ModifiedDate = DateTime.Now;

                        ObjContext.SaveChanges();
                        newClient = objClient.ID;
                        ts.Complete();
                    }

                    if (newClient > 0)
                    {
                        ddlDistributor_SelectedIndexChange(null, null);
                        ddlClient.ClearSelection();
                        ddlClient.Items.FindByValue(newClient.ToString()).Selected = true;

                        hdnEditJobNameID.Value = ddlJobName.SelectedValue;
                        ddlClient_SelectedIndexChanged(null, null);
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while Saving Client/Job Name", ex);
                }

                ViewState["PopulateClientOrJob"] = false;
            }
            else
            {
                ViewState["PopulateClientOrJob"] = true;
            }
        }

        protected void ddlPattern_OnSelectedIndexChanged(object sender, EventArgs e)
        {
            int Pattern = int.Parse(this.ddlPattern.SelectedValue);
            this.PopulateFabrics(Pattern);
            this.PopulateAccessories(Pattern);
        }

        //protected void ddlAddFabrics_SelectedIndexChange(object sender, EventArgs e)
        //{
        //    int fabric = int.Parse(((System.Web.UI.WebControls.ListControl)(sender)).SelectedValue);
        //    int fabricType = int.Parse(ddlFabricCodeType.SelectedValue);

        //    CustomValidator cv = null;

        //    if (ddlFabricCodeType.SelectedIndex < 1)
        //    {
        //        cv = new CustomValidator();
        //        cv.IsValid = false;
        //        cv.ValidationGroup = "valGrpVL";
        //        cv.ErrorMessage = "Fabric Type is required.";
        //        Page.Validators.Add(cv);
        //    }
        //    else if (fabric > 0)
        //    {
        //        List<KeyValuePair<int, KeyValuePair<int, string>>> lstFabrics = (List<KeyValuePair<int, KeyValuePair<int, string>>>)Session["VisualLayoutFabrics"];
        //        //List<KeyValuePair<Tuple<int, int>, int>> lstFabrics = (List<KeyValuePair<Tuple<int, int>, int>>)Session["VisualLayoutFabrics"];

        //        if (fabricType == 0 && lstFabrics.Where(o => o.Key == 0).Any())
        //        {
        //            cv = new CustomValidator();
        //            cv.IsValid = false;
        //            cv.ValidationGroup = "valGrpVL";
        //            cv.ErrorMessage = "Main Fabric alredy exists in the list.";
        //            Page.Validators.Add(cv);
        //        }
        //        else if (lstFabrics.Where(o => o.Value.Key == fabric).Any())
        //        {
        //            cv = new CustomValidator();
        //            cv.IsValid = false;
        //            cv.ValidationGroup = "valGrpVL";
        //            cv.ErrorMessage = "This Fabric alredy exists in the list.";
        //            Page.Validators.Add(cv);
        //        }
        //        else
        //        {
        //            this.PopulateFabricDataGrid(fabric, fabricType);
        //        }
        //    }
        //    this.ddlAddFabrics.SelectedIndex = 0;
        //    ViewState["deleteFabric"] = false;
        //}

        //protected void dgvAddEditFabrics_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;

        //    if (item.ItemIndex > -1 && item.DataItem is KeyValuePair<int, KeyValuePair<int, string>>) // KeyValuePair<Tuple<int, int>, int>)
        //    {
        //        //KeyValuePair<Tuple<int, int>, int> kv = (KeyValuePair<Tuple<int, int>, int>)item.DataItem;
        //        KeyValuePair<int, KeyValuePair<int, string>> kv = (KeyValuePair<int, KeyValuePair<int, string>>)item.DataItem;

        //        //Literal litVFID = (Literal)item.FindControl("litVFID");
        //        Literal litID = (Literal)item.FindControl("litID");
        //        Literal litFabricTypeID = (Literal)item.FindControl("litFabricTypeID");
        //        Literal litFabricType = (Literal)item.FindControl("litFabricType");
        //        Literal litCode = (Literal)item.FindControl("litCode");
        //        Literal litFabricNickName = (Literal)item.FindControl("litFabricNickName");
        //        Literal litFabricSupplier = (Literal)item.FindControl("litFabricSupplier");
        //        TextBox txtWhere = (TextBox)item.FindControl("txtWhere");

        //        litFabricTypeID.Text = kv.Key.ToString();

        //        int value = kv.Key;
        //        FabricType type = (FabricType)value;
        //        litFabricType.Text = type.ToString();

        //        //populate FabricCodeType dropdown
        //        //DropDownList ddlfabricCodeType = (DropDownList)item.FindControl("ddlfabricCodeType");
        //        //ddlfabricCodeType.Items.Add(new ListItem("Select Fabric Type", "0"));
        //        //foreach (FabricCodeTypeBO fabCodeType in (new FabricCodeTypeBO()).SearchObjects())
        //        //{
        //        //    ListItem listItemcolor = new ListItem(fabCodeType.Name, fabCodeType.ID.ToString());
        //        //    ddlfabricCodeType.Items.Add(listItemcolor);
        //        //}

        //        //if (kv.Key.Item1 > 0)
        //        //{
        //        //    VisualLayoutFabricBO objVLF = new VisualLayoutFabricBO();
        //        //    objVLF.ID = kv.Key.Item1;
        //        //    objVLF.GetObject();

        //        //    litVFID.Text = objVLF.ID.ToString();
        //        //    litID.Text = objVLF.Fabric.ToString();
        //        //    litCode.Text = objVLF.objFabric.Code;
        //        //    litFabricNickName.Text = objVLF.objFabric.NickName;
        //        //    litFabricSupplier.Text = objVLF.objFabric.objSupplier.Name;
        //        //    ddlfabricCodeType.Items.FindByValue(kv.Key.Item2.ToString()).Selected = true;
        //        //}
        //        //else
        //        //{
        //        FabricCodeBO objFC = new FabricCodeBO();
        //        objFC.ID = kv.Value.Key;
        //        objFC.GetObject();

        //        txtWhere.Text = kv.Value.Value;

        //        //litVFID.Text = "0";
        //        litID.Text = objFC.ID.ToString();
        //        litCode.Text = objFC.Code;
        //        litFabricNickName.Text = objFC.NickName;
        //        litFabricSupplier.Text = (objFC.Supplier.HasValue && objFC.Supplier.Value > 0) ? objFC.objSupplier.Name : string.Empty;
        //        //    ddlfabricCodeType.Items.FindByValue(kv.Key.Item2.ToString()).Selected = true;
        //        //}
        //    }
        //}

        //protected void dgvAddEditFabrics_onItemCommand(object sender, DataGridCommandEventArgs e)
        //{
        //    ResetViewStateValues();

        //    string commandName = e.CommandName;

        //    switch (commandName)
        //    {
        //        case "Delete":
        //            Literal litID = (Literal)e.Item.FindControl("litID");
        //            int fabric = int.Parse(litID.Text.ToString());

        //            //Literal litVFID = (Literal)e.Item.FindControl("litVFID");
        //            //int vlFabric = int.Parse(litVFID.Text);

        //            Literal litFabricTypeID = (Literal)e.Item.FindControl("litFabricTypeID");
        //            int fabricType = int.Parse(litFabricTypeID.Text);

        //            this.PopulateFabricDataGrid(fabric, fabricType, true);
        //            ViewState["deleteFabric"] = true;
        //            ViewState["deleteAccessory"] = false;

        //            break;
        //        default:
        //            break;
        //    }
        //}

        //protected void ddlFabricCodeType_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    int type = int.Parse(((System.Web.UI.WebControls.ListControl)(sender)).SelectedValue);

        //    if (type == (int)FabricType.Lining)
        //    {
        //        PopulateFilteredFabrics(true);
        //    }
        //    else
        //    {
        //        PopulateFilteredFabrics(false);
        //    }
        //}

        protected void btnCheckName_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();
            cvProductNumber_OnServerValidate(null, null);
        }

        protected void btnSaveJobName_ServerClick(object sender, EventArgs e)
        {
            ResetViewStateValues();

            //if (!IsNotRefreshed) return;
            if (Page.IsValid)
            {
                try
                {
                    int newJobName = 0;
                    using (TransactionScope ts = new TransactionScope())
                    {
                        JobNameBO objJobName = new JobNameBO(this.ObjContext);

                        int id = int.Parse(hdnEditJobNameID.Value);

                        if (id > 0)
                        {
                            objJobName.ID = id;
                            objJobName.GetObject();
                        }
                        else
                        {
                            objJobName.Creator = this.LoggedUser.ID;
                            objJobName.CreatedDate = DateTime.Now;
                        }

                        objJobName.Client = int.Parse(ddlJobNameClient.SelectedValue);
                        objJobName.Name = txtNewJobName.Text;
                        //objJobName.Address = this.txtAddress1.Text;
                        //objJobName.City = this.txtCity.Text;
                        //objJobName.State = this.txtState.Text;
                        //objJobName.PostalCode = this.txtPostalCode.Text;

                        //if (ddlCountry.SelectedIndex > 0)
                        //    objJobName.Country = this.ddlCountry.SelectedItem.Text;  //int.Parse(this.ddlCountry.SelectedValue);
                        //objJobName.Phone = this.txtPhoneNo1.Text;
                        //objJobName.Email = this.txtEmailAddress.Text;
                        objJobName.Modifier = this.LoggedUser.ID;
                        objJobName.ModifiedDate = DateTime.Now;

                        ObjContext.SaveChanges();
                        newJobName = objJobName.ID;
                        ts.Complete();
                    }

                    if (newJobName > 0)
                    {
                        ddlClient_SelectedIndexChanged(null, null);
                        ddlJobName.ClearSelection();
                        ddlJobName.Items.FindByValue(newJobName.ToString()).Selected = true;
                        ddlJobName_SelectedIndexChanged(null, null);
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while Saving Job Name", ex);
                }
            }
            else
            {
                ViewState["PopulateJobName"] = true;
            }
        }

        protected void btnEditJobName_Click(object sender, EventArgs e)
        {
            ResetViewStateValues();

            JobNameBO objJobName = new JobNameBO();
            objJobName.ID = int.Parse(ddlJobName.SelectedValue);
            objJobName.GetObject();

            this.ddlJobNameClient.Items.FindByValue(objJobName.Client.ToString()).Selected = true;
            this.txtNewJobName.Text = objJobName.Name;
            //this.txtAddress1.Text = objJobName.Address;
            //this.txtCity.Text = objJobName.City;
            //this.txtState.Text = objJobName.State;
            //this.txtPostalCode.Text = objJobName.PostalCode;

            //this.ddlCountry.ClearSelection();
            //if (!string.IsNullOrEmpty((objJobName.Country)) && this.ddlCountry.Items.FindByText(objJobName.Country) != null)
            //    this.ddlCountry.Items.FindByText(objJobName.Country).Selected = true;
            //this.txtPhoneNo1.Text = objJobName.Phone;
            //this.txtEmailAddress.Text = objJobName.Email;

            hdnEditJobNameID.Value = objJobName.ID.ToString();
            ViewState["PopulateJobName"] = true;
        }

        protected void ddlFabric_SelectedIndexChanged(object sender, EventArgs e)
        {
            lblFabricDescription.Text = string.Empty;
            int fabricID = int.Parse(ddlFabric.SelectedValue);

            PopulateFabricDescription(fabricID);
        }

        protected void cfvJobName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int itemID = int.Parse(hdnEditJobNameID.Value);
                int clientID = int.Parse(this.ddlClient.SelectedValue);

                //ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                //objReturnInt = SettingsBO.ValidateField(itemID, "JobName", "Name", this.txtNewJobName.Text);
                //args.IsValid = objReturnInt.RetVal == 1;

                args.IsValid = ValidateField2(itemID, "JobName", "Name", this.txtNewJobName.Text, "Client", clientID.ToString()) == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cfvJobName_ServerValidate on AddEditVisualLayout.aspx", ex);
            }
        }

        protected void cvTxtClientName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int itemID = int.Parse(hdnClientID.Value);
                int distributorID = int.Parse(this.ddlDistributor.SelectedValue);

                //ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                //objReturnInt = SettingsBO.ValidateField(itemID, "Client", "Name", this.txtNewClient.Text);
                //args.IsValid = objReturnInt.RetVal == 1;

                args.IsValid = ValidateField2(itemID, "Client", "Name", this.txtNewClient.Text, "Distributor", distributorID.ToString()) == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtClientName_ServerValidate on AddEditVisualLayout.aspx", ex);
            }
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            //this.cvLayoutImage.Enabled = false;
            this.litHeaderText.Text = (this.QueryID > 0) ? "Edit Product" : "New Product";
            this.dvVLImagePreview.Visible = false;
            this.dvEmptyContentVLImages.Visible = false;
            this.dvHideColums.Visible = true;
            this.lblPrimaryCoordinator.Text = "None";
            this.lblSecondaryCoordinator.Text = "None";

            Session["VisualLayoutFabrics"] = new List<KeyValuePair<int, KeyValuePair<int, string>>>();

            //ViewState["PopulatePatern"] = false;

            //populate Resolution Profile
            this.ddlResolutionProfile.Items.Clear();
            this.ddlResolutionProfile.Items.Add(new ListItem("Select Resolution Profile", "0"));
            List<ResolutionProfileBO> lstResolutionProfile = (new ResolutionProfileBO()).GetAllObject().ToList();
            foreach (ResolutionProfileBO res in lstResolutionProfile)
            {
                this.ddlResolutionProfile.Items.Add(new ListItem(res.Name, res.ID.ToString()));
            }

            //Fabric Types
            //ddlFabricCodeType.Items.Clear();
            //ddlFabricCodeType.Items.Add(new ListItem("Select a Type", "-1"));
            //int fabricCodeType = 0;
            //foreach (FabricType type in Enum.GetValues(typeof(FabricType)))
            //{
            //    ddlFabricCodeType.Items.Add(new ListItem(type.ToString(), fabricCodeType++.ToString()));
            //}

            if (this.QueryID < 1)
            {
                this.ddlResolutionProfile.Items.FindByText("CMYK HIGH RES").Selected = true;
            }

            // populate Distributor
            this.PopulateDistributors();
            this.PopulatePatterns();
            //this.PopulateFabrics();
            //this.PopulateFilteredFabrics(false);

            // Populate Pocket Type
            this.ddlPocketType.Items.Add(new ListItem("Select Pocket Type", "0"));
            List<PocketTypeBO> lstPocketType = (new PocketTypeBO()).GetAllObject();
            foreach (PocketTypeBO pt in lstPocketType)
            {
                this.ddlPocketType.Items.Add(new ListItem(pt.Name, pt.ID.ToString()));
            }

            //Populate By-Size Artwork
            this.ddlBySizeArtwork.Items.Add(new ListItem("Select By-Size Artwork", "0"));
            this.ddlBySizeArtwork.Items.Add(new ListItem("Yes", "1"));
            this.ddlBySizeArtwork.Items.Add(new ListItem("No", "2"));

            // Populate Print Typr
            this.ddlPrinterType.Items.Add(new ListItem("Select Print Type", "0"));
            List<PrinterTypeBO> lstPrintType = (new PrinterTypeBO()).GetAllObject();
            foreach (PrinterTypeBO pt in lstPrintType)
            {
                this.ddlPrinterType.Items.Add(new ListItem(pt.Name, pt.ID.ToString()));
            }

            // Populate CountryBO
            //this.ddlCountry.Items.Add(new ListItem("Select Your Country"));
            //List<CountryBO> lstCountry = (new CountryBO()).GetAllObject().AsQueryable().OrderBy("ShortName").ToList();
            //foreach (CountryBO country in lstCountry)
            //{
            //    this.ddlCountry.Items.Add(new ListItem(country.ShortName, country.ID.ToString()));
            //}
            //  this.ddlCountry.Items.FindByValue("14").Selected = true;

            if (this.QueryID > 0)
            {
                this.PopulateVLImages(0);

                VisualLayoutBO objVisualLayout = new VisualLayoutBO();
                objVisualLayout.ID = this.QueryID;
                objVisualLayout.GetObject();

                this.litHeaderText.Text += "-" + objVisualLayout.NamePrefix;

                // If editing a product then select the correct By-Size Artwork
                this.ddlBySizeArtwork.SelectedIndex = (objVisualLayout.BySizeArtWork) ? 1 : 2;

                //List<FabricCodeBO> lstFabrics = (new FabricCodeBO()).SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();

                //this.PopulateFabricDataGrid(0, 0);

                if (objVisualLayout.IsGenerated == true)
                {
                    this.rbGenerate.Checked = true;
                    this.rbCustom.Checked = false;
                }
                else
                {
                    this.rbGenerate.Checked = false;
                    this.rbCustom.Checked = true;
                }

                this.IsGeneratedProduct();

                this.txtProductNumber.Text = (objVisualLayout.NameSuffix == null || objVisualLayout.NameSuffix == 0) ? objVisualLayout.NamePrefix : objVisualLayout.NamePrefix + "" + objVisualLayout.NameSuffix.ToString();

                lblCheckName.Text = "Available.";
                lblCheckName.ForeColor = Color.Green;

                this.ddlDistributor.SelectedValue = (objVisualLayout.Client != null && objVisualLayout.Client > 0) ? objVisualLayout.objClient.objClient.objDistributor.ID.ToString() : "0";
                this.ddlDistributor_SelectedIndexChange(null, null);

                this.PopulateJobNames(objVisualLayout.objClient.Client ?? 0);

                int pocket = objVisualLayout.PocketType ?? 0;
                if (pocket > 0)
                    this.ddlPocketType.Items.FindByValue(pocket.ToString()).Selected = true;

                if (this.txtProductNumber.Text.Contains("VL"))
                {
                    this.ddlPrinterType.Items.FindByValue("1").Selected = true;
                }
                else if (this.txtProductNumber.Text.Contains("CS"))
                {
                    this.ddlPrinterType.Items.FindByValue("2").Selected = true;
                }
                else if (this.txtProductNumber.Text.Contains("DY"))
                {
                    this.ddlPrinterType.Items.FindByValue("3").Selected = true;
                }

                this.ddlResolutionProfile.Items.FindByValue((objVisualLayout.ResolutionProfile != null && objVisualLayout.ResolutionProfile > 0) ? objVisualLayout.ResolutionProfile.Value.ToString() : "0").Selected = true;

                //this.checkIsCommonproduct.Checked = (objVisualLayout.IsCommonProduct == true) ? true : false;
                //isCommonProduct
                if (objVisualLayout.IsCommonProduct == true)
                {
                    this.dvHideColums.Visible = false;
                }

                this.ddlClient.Items.FindByValue(objVisualLayout.objClient.Client.ToString()).Selected = true;
                this.litClient.Text = objVisualLayout.objClient.objClient.Name;
                this.ancEditClient.Visible = true;

                this.ddlJobName.ClearSelection();
                this.ddlJobName.Items.FindByValue(objVisualLayout.Client.ToString()).Selected = true;

                JobNameBO objJobName = objVisualLayout.objClient;

                this.litJobName.Text = objJobName.Name +
                  (string.IsNullOrEmpty(objJobName.Address) ? string.Empty : (" " + objJobName.Address)) +
                  (string.IsNullOrEmpty(objJobName.City) ? string.Empty : (" " + objJobName.City)) +
                  (string.IsNullOrEmpty(objJobName.State) ? string.Empty : (" " + objJobName.State)) +
                  (string.IsNullOrEmpty(objJobName.PostalCode) ? string.Empty : (" " + objJobName.PostalCode)) +
                  (string.IsNullOrEmpty(objJobName.Country) ? string.Empty : (" " + objJobName.Country))
                   ;
                this.btnEditJobName.Visible = true;

                this.PopulateFabrics(objVisualLayout.Pattern);

                if (this.ddlFabric.Items.FindByValue(objVisualLayout.FabricCode.ToString()) != null)
                {
                    this.ddlFabric.Items.FindByValue(objVisualLayout.FabricCode.ToString()).Selected = true;
                    PopulateFabricDescription(objVisualLayout.FabricCode ?? 0);
                }

                PatternBO objPattern = new PatternBO();
                objPattern.ID = objVisualLayout.Pattern;
                objPattern.GetObject();

                if (objPattern.IsActive)
                {
                    this.ddlPattern.Items.FindByValue(objVisualLayout.Pattern.ToString()).Selected = true;
                }
                else
                {
                    this.litPatternError.Visible = true;
                    this.litPatternError.Text = "Associated Pattern ( <strong>" + objPattern.Number + " - " + objPattern.NickName + "</strong> ) for this Product is inactive. Please activate the pattern or select diffrent pattern";
                }

                this.txtNotes.Text = objVisualLayout.Description;

                bool canEdit = false;

                try
                {
                    ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                    objReturnInt = SettingsBO.ValidateField(0, "OrderDetail", "VisualLayout", this.QueryID.ToString());
                    canEdit = objReturnInt.RetVal == 1;
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on AddEditPattern.aspx", ex);
                }

                this.ddlDistributor.Enabled = canEdit;
                this.ddlClient.Enabled = canEdit;
                this.ddlJobName.Enabled = canEdit;

                this.ddlPattern.Enabled = canEdit || this.LoggedUserRoleName == UserRole.IndimanAdministrator;
                this.ddlFabric.Enabled = canEdit || this.LoggedUserRoleName == UserRole.IndimanAdministrator;

                ancNewClient.Visible = canEdit;
                ancNewJobName.Visible = canEdit;

                //Get check box values from table with dapper

                using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
                {
                    connection.Open();

                    List<bool> lstActive = connection.Query<bool>("SELECT IsActive FROM [dbo].VisualLayout WHERE ID = " + this.QueryID.ToString()).ToList();
                    chkIsActive.Checked = lstActive.FirstOrDefault();

                    List<bool> lstEmbroidery = connection.Query<bool>("SELECT IsEmbroidery FROM [dbo].VisualLayout WHERE ID = " + this.QueryID.ToString()).ToList();
                    chkIsEmbroidery.Checked = lstEmbroidery.FirstOrDefault();

                    connection.Close();
                }

            }
            //else if (this.Distributor.ID > 0)
            //{
            //    this.ddlDistributor.SelectedValue = this.Distributor.ID.ToString();
            //    this.ddlDistributor_SelectedIndexChange(null, null);

            //    this.ddlClient.SelectedValue = this.ClientID.ToString();
            //}
            //else if (this.Distributor.ID == -1 && this.ClientID > 0)
            //{
            //    this.PopulateVisualLayout();
            //}

            if (this.QueryID == 0)
            {
                rbCustom.Checked = true;
                IsProduct_OnCheckChanged(null, null);
            }
        }

        private void PopulateVLImages(int startIndex)
        {
            this.dvVLImagePreview.Visible = false;

            VisualLayoutBO objVisualLayout = new VisualLayoutBO();
            objVisualLayout.ID = this.QueryID;
            objVisualLayout.GetObject();

            if (objVisualLayout.ImagesWhereThisIsVisualLayout.Count > 0)
            {
                this.dvVLImagePreview.Visible = true;

                #region Pagination Process

                int TotVLCount = objVisualLayout.ImagesWhereThisIsVisualLayout.Count;
                int count = 0;

                if (TotVLCount < rptPageSize)
                    count = TotVLCount;
                else
                {
                    if (startIndex == 0)
                        count = rptPageSize;
                    else
                    {
                        if ((count + rptPageSize) > TotVLCount)
                            count = rptPageSize;
                        else
                        {
                            if (startIndex + rptPageSize > TotVLCount)
                                count = TotVLCount % 10;
                            else
                                count = rptPageSize;
                        }
                    }
                }

                ViewState["VLTotal"] = TotVLCount;
                ViewState["VLPageCount"] = (TotVLCount % 10 == 0) ? (TotVLCount / 10) : (TotVLCount / 10 + 1);

                this.dvPagingFooter.Visible = (TotVLCount > rptPageSize);
                this.lbFooterPrevious.Visible = (startIndex != 0 && startIndex != 90);
                this.ProcessNumbering(1, Convert.ToInt32(ViewState["VLPageCount"]));
                //this.lblPageCountString.Text = "Showing " + (startIndex + 1).ToString() + " to " + (count + startIndex).ToString() + " of " + TotArticleCount + " Articles";

                #endregion

                this.rptVisualLayouts.DataSource = objVisualLayout.ImagesWhereThisIsVisualLayout.GetRange(startIndex, count);
                this.rptVisualLayouts.DataBind();
            }
            else
            {
                this.rptVisualLayouts.DataSource = null;
                this.rptVisualLayouts.DataBind();
                this.dvEmptyContentVLImages.Visible = true;
            }
        }

        private void PopulatePatterns()
        {
            PatternBO objPattern = new PatternBO();
            objPattern.IsActive = true;

            Dictionary<int, string> patterns = objPattern.SearchObjects().AsQueryable().OrderBy(o => o.Number).Select(o => new { Key = o.ID, Value = (o.Number + " - " + o.NickName) }).ToDictionary(o => o.Key, o => o.Value);
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

        private void PopulateFabrics(int pattern)
        {
            CostSheetBO objCS = new CostSheetBO();
            objCS.Pattern = pattern;

            List<FabricCodeBO> lstFabricCodes = objCS.SearchObjects().Select(m => m.objFabric).ToList();

            this.ddlFabric.Items.Clear();
            this.ddlFabric.Items.Add(new ListItem("Please select or type...", "0"));

            if (lstFabricCodes.Any())
            {
                foreach (FabricCodeBO objFabric in lstFabricCodes)
                {
                    this.ddlFabric.Items.Add(new ListItem(objFabric.Code + " - " + objFabric.Name, objFabric.ID.ToString()));
                }
            }
            else
            {
                this.litPatternError.Text = "The pattern selected, does not have any price lists. Please contact Indiman administrator to include price list for pattern and fabric.";
            }

            this.litPatternError.Visible = !lstFabricCodes.Any();
        }

        private void PopulateFabricDescription(int fabricID)
        {
            if (fabricID > 0)
            {
                string mainFabName = string.Empty;
                string secondaryFabName = string.Empty;
                string liningFabName = string.Empty;

                FabricCodeBO objFabric = new FabricCodeBO();
                objFabric.ID = fabricID;
                objFabric.GetObject();

                try
                {
                    string[] codes = objFabric.Code.Split('+');

                    FabricCodeBO objPureFabric = new FabricCodeBO();
                    objPureFabric.IsPure = true;

                    List<FabricCodeBO> lstFabricCodes = objPureFabric.SearchObjects();

                    int fabricPosition = 0;

                    foreach (string code in codes)
                    {
                        List<FabricCodeBO> lstCodes = lstFabricCodes.Where(m => m.Code == code).ToList();

                        if (lstCodes.Any())
                        {
                            FabricCodeBO objFabCode = lstCodes.First();

                            if (++fabricPosition == 1)
                            {
                                mainFabName = objFabCode.Name;
                            }
                            else if (objFabCode.IsLiningFabric)
                            {
                                liningFabName = liningFabName + "," + objFabCode.Name;
                            }
                            else
                            {
                                secondaryFabName = secondaryFabName + "," + objFabCode.Name;
                            }
                        }
                    }

                    lblFabricDescription.Text = string.IsNullOrEmpty(mainFabName) ? string.Empty : ("Main: " + mainFabName);
                    lblFabricDescription.Text += string.IsNullOrEmpty(secondaryFabName) ? string.Empty : (", Secondary: " + secondaryFabName.Remove(0, 1));
                    lblFabricDescription.Text += string.IsNullOrEmpty(liningFabName) ? string.Empty : (", Lining: " + liningFabName.Remove(0, 1));
                }
                catch (Exception ex)
                {

                }
            }
        }

        //private void PopulateFilteredFabrics(bool isLining)
        //{
        //    FabricCodeBO objFabric = new FabricCodeBO();
        //    objFabric.IsActive = true;
        //    objFabric.IsPure = true;
        //    objFabric.IsLiningFabric = isLining;

        //    Dictionary<int, string> filteredfabrics = objFabric.SearchObjects().AsQueryable().OrderBy(o => o.Name).ToList().Select(o => new { Key = o.ID, Value = (o.Code + " - " + o.NickName) }).ToDictionary(o => o.Key, o => o.Value);
        //    Dictionary<int, string> fdicFabrics = new Dictionary<int, string>();

        //    fdicFabrics.Add(0, "Please select or type...");
        //    foreach (KeyValuePair<int, string> item in filteredfabrics)
        //    {
        //        fdicFabrics.Add(item.Key, item.Value);
        //    }

        //    this.ddlAddFabrics.DataSource = fdicFabrics;
        //    this.ddlAddFabrics.DataTextField = "Value";
        //    this.ddlAddFabrics.DataValueField = "Key";
        //    this.ddlAddFabrics.DataBind();
        //}

        private void PopulateDistributors()
        {
            this.ddlDistributor.Items.Clear();
            this.ddlDistributor.Items.Add(new ListItem("Select Distributor", "0"));

            this.ddlClientDistributor.Items.Clear();
            this.ddlClientDistributor.Items.Add(new ListItem("Select Client", "0"));

            CompanyBO objDis = new CompanyBO();
            objDis.IsDistributor = true;
            objDis.IsActive = true;
            objDis.IsDelete = false;

            List<CompanyBO> lstComapny = objDis.SearchObjects().OrderBy(o => o.Name).ToList();
            foreach (CompanyBO company in lstComapny)
            {
                this.ddlDistributor.Items.Add(new ListItem(company.Name, company.ID.ToString()));
                this.ddlClientDistributor.Items.Add(new ListItem(company.Name, company.ID.ToString()));
            }

            ClientBO objClient = new ClientBO();

            if (LoggedUser.IsDirectSalesPerson)
            {
                objClient.Distributor = this.Distributor.ID;
            }
            else if (LoggedUserRoleName == UserRole.DistributorAdministrator || LoggedUserRoleName == UserRole.DistributorCoordinator)
            {
                objClient.Distributor = LoggedCompany.ID;
            }

            //List<ClientBO> lstClient = (from o in objClient.SearchObjects().OrderBy(m => m.Name).AsQueryable().ToList<ClientBO>()
            //                            select o).ToList();
            //foreach (ClientBO client in lstClient)
            //{
            //    this.ddlClientDistributor.Items.Add(new ListItem(client.Name, client.ID.ToString()));
            //}
        }

        private void PopulateJobNames(int client)
        {
            this.litClient.Text = string.Empty;
            this.litJobName.Text = string.Empty;
            this.btnEditJobName.Visible = false;
            this.ddlJobName.Items.Clear();
            this.ddlJobName.Items.Add(new ListItem("Select Job Name", "0"));

            this.ancNewJobName.Visible = client > 0;
            this.ddlJobNameClient.ClearSelection();
            this.ddlJobNameClient.Items.FindByValue(client.ToString()).Selected = true;

            this.ancEditClient.Visible = client > 0;

            if (client > 0)
            {
                JobNameBO objJobName = new JobNameBO();
                objJobName.Client = client;

                List<JobNameBO> lstJobNames = objJobName.SearchObjects().OrderBy(o => o.Name).ToList();

                foreach (JobNameBO jobName in lstJobNames)
                {
                    this.ddlJobName.Items.Add(new ListItem(jobName.Name, jobName.ID.ToString()));
                }

                this.litClient.Text = objJobName.objClient.Name;

                if (this.ddlJobName.SelectedValue == "0")
                {
                    if (this.QueryID > 0)
                    {
                        VisualLayoutBO objVisualLayout = new VisualLayoutBO();
                        objVisualLayout.ID = this.QueryID;
                        objVisualLayout.GetObject();

                        this.ddlJobName.ClearSelection();
                        var item = ddlJobName.Items.FindByValue(objVisualLayout.Client.ToString());
                        if (item != null)
                            item.Selected = true;
                    }
                }
            }
        }

        private int ProcessForm()
        {
            int visualLayout = 0;
            try
            {
                VisualLayoutBO objVisualLayout = new VisualLayoutBO(this.ObjContext);

                using (TransactionScope ts = new TransactionScope())
                {
                    try
                    {
                        if (this.QueryID > 0)
                        {
                            objVisualLayout.ID = this.QueryID;
                            objVisualLayout.GetObject();
                        }

                        if (this.QueryID == 0)
                        {
                            /*  #region Generate New VL Number

                              string NewVLNumber = string.Empty;

                              if ((new VisualLayoutBO()).GetAllObject().Count == 0)
                                  NewVLNumber = "VL001";
                              else
                                  NewVLNumber = "VL" + ((new VisualLayoutBO()).GetAllObject().Select(o => int.Parse(o.NamePrefix.Substring(2))).ToList().Max() + 1).ToString("000");

                              objVisualLayout.NamePrefix = NewVLNumber;

                              #endregion*/
                            List<AcquiredVisulaLayoutNameBO> lstAcquiredVlName = (from o in (new AcquiredVisulaLayoutNameBO()).SearchObjects().Where(o => o.Name == txtProductNumber.Text) select o).ToList();
                            if (lstAcquiredVlName.Count > 0)
                            {
                                objVisualLayout.CreatedDate = lstAcquiredVlName[0].CreatedDate;
                            }
                            else
                            {
                                objVisualLayout.CreatedDate = DateTime.Now;
                            }
                        }

                        List<VisualLayoutBO> lstVisualLayouts = (from o in objVisualLayout.SearchObjects().Where(o => o.NamePrefix.Trim().ToLower() == this.txtProductNumber.Text.Trim().ToLower() && QueryID > 0) select o).ToList();

                        if (lstVisualLayouts.Count > 0)
                        {
                            objVisualLayout.NamePrefix = this.txtProductNumber.Text;
                        }
                        else
                        {
                            objVisualLayout.NamePrefix = (this.rbCustom.Checked == true) ? this.txtProductNumber.Text : Regex.Replace(this.txtProductNumber.Text, "[^A-Z]", string.Empty);
                        }
                        //  objVisualLayout.Coordinator = (int.Parse(this.ddlCoordinator.SelectedValue) > 0) ? int.Parse(this.ddlCoordinator.SelectedValue) : (int?)null;

                        //if (this.ddlDistributor.Items.Count > 0)
                        //{
                        //    objVisualLayout.Distributor = (int.Parse(this.ddlDistributor.SelectedValue) > 0) ? int.Parse(this.ddlDistributor.SelectedValue) : (int?)null;
                        //}
                        //else
                        //{
                        //    objVisualLayout.Distributor = (int?)null;
                        //}

                        objVisualLayout.Client = this.ddlJobName.SelectedValue != string.Empty ? int.Parse(this.ddlJobName.SelectedValue) : (int?)null;
                        objVisualLayout.FabricCode = int.Parse(this.ddlFabric.SelectedValue);
                        objVisualLayout.Pattern = int.Parse(this.ddlPattern.SelectedValue);
                        objVisualLayout.Description = this.txtNotes.Text;
                        objVisualLayout.IsGenerated = (this.rbGenerate.Checked == true) ? true : false;
                        objVisualLayout.ResolutionProfile = int.Parse(this.ddlResolutionProfile.SelectedValue);

                        string fabricWhere = string.Empty;

                        //foreach (DataGridItem item in this.dgvAddEditFabrics.Items)
                        //{
                        //    Literal litID = (Literal)item.FindControl("litID");
                        //    TextBox txtWhere = (TextBox)item.FindControl("txtWhere");

                        //    fabricWhere += litID.Text + "-" + txtWhere.Text + ",";
                        //}

                        //objVisualLayout.Where = fabricWhere.Remove(fabricWhere.Length - 1);

                        int pocket = int.Parse(this.ddlPocketType.SelectedValue);
                        if (pocket > 0)
                            objVisualLayout.PocketType = pocket;

                        objVisualLayout.BySizeArtWork = (int.Parse(this.ddlBySizeArtwork.SelectedValue) == 1) ? true : false;

                        if (lstVisualLayouts.Count > 0)
                        {
                            objVisualLayout.NameSuffix = (int?)null;
                        }
                        else
                        {
                            objVisualLayout.NameSuffix = (this.rbCustom.Checked == true) ? (int?)null : int.Parse(Regex.Replace(this.txtProductNumber.Text, "[^0-9]", string.Empty));
                        }
                        //objVisualLayout.IsCommonProduct = (this.checkIsCommonproduct.Checked == true) ? true : false;



                        ViewState["visualLayoutNa"] = this.txtProductNumber.Text;

                        if (this.QueryID > 0)
                        {
                            foreach (RepeaterItem item in this.rptVisualLayouts.Items)
                            {
                                CheckBox chkHeroImage = (CheckBox)item.FindControl("chkHeroImage");
                                int imgId = int.Parse(chkHeroImage.Attributes["qid"].ToString());

                                ImageBO objImage = new ImageBO(this.ObjContext);
                                objImage.ID = imgId;
                                objImage.GetObject();

                                objImage.IsHero = chkHeroImage.Checked;
                                //this.ObjContext.SaveChanges();
                            }
                        }

                        #region DeleteAcquiredVisualLayoutName

                        List<AcquiredVisulaLayoutNameBO> lstAcquiredVisualLayoutName = (new AcquiredVisulaLayoutNameBO()).SearchObjects().Where(o => o.Name == this.txtProductNumber.Text).ToList();
                        if (lstAcquiredVisualLayoutName.Count > 0)
                        {
                            foreach (AcquiredVisulaLayoutNameBO vlNames in lstAcquiredVisualLayoutName)
                            {
                                AcquiredVisulaLayoutNameBO objAcquiredVisualLayoutName = new AcquiredVisulaLayoutNameBO(this.ObjContext);
                                objAcquiredVisualLayoutName.ID = vlNames.ID;
                                objAcquiredVisualLayoutName.GetObject();
                                objAcquiredVisualLayoutName.Delete();
                            }
                        }
                        #endregion

                        this.ObjContext.SaveChanges();

                        visualLayout = objVisualLayout.ID;
                        #region Save multiple fabrics


                        /*    foreach (DataGridItem item in this.dgv.Items)
                            {
                                CheckBox chkHeroImage = (CheckBox)item.FindControl("chkHeroImage");
                                int imgId = int.Parse(chkHeroImage.Attributes["qid"].ToString());

                                ImageBO objImage = new ImageBO(this.ObjContext);
                                objImage.ID = imgId;
                                objImage.GetObject();

                                objImage.IsHero = chkHeroImage.Checked;
                                //this.ObjContext.SaveChanges();
                            }
                        }*/

                        /*
                        List<KeyValuePair<Tuple<int, int>, int>> lst = new List<KeyValuePair<Tuple<int, int>, int>>();

                        foreach (DataGridItem item in this.dgvAddEditFabrics.Items)
                        {
                            Literal litID = (Literal)item.FindControl("litID");
                            Literal litVFID = (Literal)item.FindControl("litVFID");
                            DropDownList ddlfabricCodeType = (DropDownList)item.FindControl("ddlfabricCodeType");

                            lst.Add(new KeyValuePair<Tuple<int, int>, int>(new Tuple<int, int>(int.Parse(litVFID.Text), int.Parse(ddlfabricCodeType.SelectedValue.ToString())), int.Parse(litID.Text)));
                        }

                        List<int> lstExistingVLF = objVisualLayout.VisualLayoutFabricsWhereThisIsVisualLayout.Select(m => m.ID).ToList();

                        foreach (int existingID in lstExistingVLF)
                        {
                            VisualLayoutFabricBO objVisuallayoutFabric = new VisualLayoutFabricBO(this.ObjContext);
                            objVisuallayoutFabric.ID = existingID;
                            objVisuallayoutFabric.GetObject();

                            objVisuallayoutFabric.Delete();
                            this.ObjContext.SaveChanges();
                        }

                        foreach (KeyValuePair<Tuple<int, int>, int> savingFabric in lst)
                        {
                            VisualLayoutFabricBO objVisuallayoutFabric = new VisualLayoutFabricBO(this.ObjContext);
                            objVisuallayoutFabric.VisualLayout = visualLayout;
                            objVisuallayoutFabric.Fabric = savingFabric.Value;
                            objVisuallayoutFabric.FabricCodeType = savingFabric.Key.Item2;

                            this.ObjContext.SaveChanges();
                        }*/

                        #endregion

                        #region Copy VL Image


                        string sourceFileLocation = string.Empty;
                        string destinationFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\VisualLayout\\" + objVisualLayout.ID.ToString();

                        //Other VL Images
                        if (!string.IsNullOrWhiteSpace(serverImagePath.Value))
                        {
                            var filePath = HttpContext.Current.Server.MapPath(serverImagePath.Value);
                            var fileName = new FileInfo(filePath).Name;
                            if (!Directory.Exists(destinationFolderPath))
                                Directory.CreateDirectory(destinationFolderPath);
                            if (File.Exists(destinationFolderPath + "\\" + fileName))
                                File.Delete(destinationFolderPath + "\\" + fileName);
                            File.Copy(filePath, destinationFolderPath + "\\" + fileName);
                            var objImage = new ImageBO(ObjContext)
                            {
                                Filename = Path.GetFileNameWithoutExtension(filePath),
                                Extension = Path.GetExtension(filePath),
                                Size = Convert.ToInt32(new FileInfo(filePath).Length),
                                IsHero = objVisualLayout.ImagesWhereThisIsVisualLayout.Count < 1
                            };
                            foreach (var img in objVisualLayout.ImagesWhereThisIsVisualLayout)
                            {
                                img.Delete();
                            }
                            objVisualLayout.ImagesWhereThisIsVisualLayout.Add(objImage);
                            ObjContext.SaveChanges();
                        }
                        else
                        {

                            //VL Images
                            if (hdnUploadFiles.Value != "0" || (int.Parse(ddlPattern.SelectedValue) > 0))
                            {
                                var n = 0;
                                foreach (var fileName in hdnUploadFiles.Value.Split('|').Select(o => o.Split(',')[0]).Where(fileName => fileName != string.Empty))
                                {
                                    n++;
                                    var objImage = new ImageBO(ObjContext)
                                    {
                                        Filename = Path.GetFileNameWithoutExtension(fileName),
                                        Extension = Path.GetExtension(fileName),
                                        Size = (int)(new FileInfo(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + fileName)).Length
                                    };
                                    if (QueryID == 0 || objVisualLayout.ImagesWhereThisIsVisualLayout.Count == 0)
                                    {
                                        objImage.IsHero = (n == 1);
                                    }
                                    if (QueryID == 0)
                                    {
                                        objVisualLayout.ImagesWhereThisIsVisualLayout.Add(objImage);
                                    }
                                    else
                                    {
                                        objImage.VisualLayout = QueryID;
                                    }
                                }
                            }

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


                        #endregion

                        ts.Complete();
                        ts.Dispose();

                        //Update table with dapper
                        using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
                        {
                            connection.Execute("UPDATE [dbo].VisualLayout SET IsActive = " + (chkIsActive.Checked ? "1" : "0") + " where ID = " + visualLayout.ToString());
                            connection.Execute("UPDATE [dbo].VisualLayout SET IsEmbroidery = " + (chkIsEmbroidery.Checked ? "1" : "0") + " where ID = " + visualLayout.ToString());
                            connection.Close();
                        }

                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while saving vlsual layouts", ex);
                    }
                }

                ViewState["visualLayoutID"] = objVisualLayout.ID;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving Visual Layout", ex);
            }

            List<VisualLayoutBO> lstVisualLayout = new List<VisualLayoutBO>();
            if (this.rbGenerate.Checked == true)
            {
                lstVisualLayout = (from o in (new VisualLayoutBO()).SearchObjects().Where(o => o.NamePrefix == this.txtProductNumber.Text) select o).ToList();
                if (lstVisualLayout.Count == 0)
                {
                    lstVisualLayout = (from o in (new VisualLayoutBO()).SearchObjects()
                                       where o.NamePrefix == ((this.rbCustom.Checked == true) ? this.txtProductNumber.Text : Regex.Replace(this.txtProductNumber.Text, "[^A-Z]", string.Empty)) &&
                                             o.NameSuffix == int.Parse((this.rbCustom.Checked == true) ? this.txtProductNumber.Text : Regex.Replace(this.txtProductNumber.Text, "[^0-9]", string.Empty))
                                       select o).ToList();
                }
            }
            else if (this.rbCustom.Checked == true)
            {
                VisualLayoutBO vl = new VisualLayoutBO();
                vl.NamePrefix = this.txtProductNumber.Text;
                lstVisualLayout = vl.SearchObjects().ToList();
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
                            VisualLayoutAccessoryBO objVisualLayoutAccessory = new VisualLayoutAccessoryBO(this.ObjContext);
                            Label lblAccessoryID = (Label)(item.FindControl("lblAccessoryID"));
                            Label lblAccessoryCategoryID = (Label)(item.FindControl("lblAccessoryCategoryID"));
                            DropDownList ddlAccessoryColor = (DropDownList)(item.FindControl("ddlAccessoryColor"));

                            objVisualLayoutAccessory.Accessory = int.Parse(lblAccessoryID.Text);
                            objVisualLayoutAccessory.AccessoryColor = int.Parse(ddlAccessoryColor.SelectedValue);
                            objVisualLayoutAccessory.VisualLayout = visualLayoutID;
                        }
                    }
                    else if (this.QueryID > 0)
                    {
                        VisualLayoutAccessoryBO objVLA = new VisualLayoutAccessoryBO();
                        objVLA.VisualLayout = QueryID;

                        List<int> lstVisualLayoutAccessoryID = objVLA.SearchObjects().Select(m => m.ID).ToList();

                        if (lstVisualLayoutAccessoryID.Any())
                        {
                            foreach (DataGridItem item in dgPatternAccessory.Items)
                            {
                                Label lblAccessoryID = (Label)item.FindControl("lblAccessoryID");
                                int id = int.Parse(((WebControl)(lblAccessoryID)).Attributes["vlaid"].ToString());

                                if (id > 0)
                                {
                                    VisualLayoutAccessoryBO objVisualLayoutAccessory = new VisualLayoutAccessoryBO(this.ObjContext);
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
                                VisualLayoutAccessoryBO objVisualLayoutAccessory = new VisualLayoutAccessoryBO(this.ObjContext);
                                Label lblAccessoryID = (Label)(item.FindControl("lblAccessoryID"));
                                Label lblAccessoryCategoryID = (Label)(item.FindControl("lblAccessoryCategoryID"));
                                DropDownList ddlAccessoryColor = (DropDownList)(item.FindControl("ddlAccessoryColor"));

                                objVisualLayoutAccessory.Accessory = int.Parse(lblAccessoryID.Text);
                                objVisualLayoutAccessory.AccessoryColor = int.Parse(ddlAccessoryColor.SelectedValue);
                                objVisualLayoutAccessory.VisualLayout = QueryID;
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

            if (VLTotal <= 10 * rptPageSize)
            {
                this.lbFooterPreviousDots.Visible = false;
                this.lbFooterNextDots.Visible = false;
            }

            else if (VLTotal - ((loadedPageTemp) * 10 * rptPageSize) <= 10 * rptPageSize)
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

        private void PopulateVisualLayout()
        {
            PopulateOrders objPopulateVisualLayout = (PopulateOrders)Session["populateVisualLayout"];
            //this.checkIsCommonproduct.Checked = objPopulateVisualLayout.IsCommonProduct;

            if (objPopulateVisualLayout.IsCommonProduct)
            {
                this.dvHideColums.Visible = false;
            }
            else
            {
                this.dvHideColums.Visible = true;
            }


            this.txtProductNumber.Text = objPopulateVisualLayout.productNumber;
            this.rbGenerate.Checked = objPopulateVisualLayout.IsGenerate;
            this.rbCustom.Checked = objPopulateVisualLayout.IsCustom;

            if (this.rbGenerate.Checked == true)
            {
                //this.lblProductNumber.Attributes.Remove("class");
                this.liPrinterType.Visible = true;
                this.txtProductNumber.Enabled = false;

            }
            else if (this.rbCustom.Checked == true)
            {
                //this.lblProductNumber.Attributes.Add("class", "control-label required");
                this.liPrinterType.Visible = false;
                this.txtProductNumber.Enabled = true;
            }

            this.ddlDistributor.Items.FindByValue(objPopulateVisualLayout.vlDistributor.ToString()).Selected = true;
            this.ddlDistributor.Items.FindByValue("0").Selected = false;

            this.ddlDistributor_SelectedIndexChange(null, null);

            this.ddlClient.Items.FindByValue("0").Selected = false;
            this.ddlClient.SelectedValue = this.ClientID.ToString();

            this.ddlPrinterType.Items.FindByValue("0").Selected = false;
            this.ddlFabric.Items.FindByValue("0").Selected = false;
            this.ddlPattern.Items.FindByValue("0").Selected = false;

            this.ddlPrinterType.Items.FindByValue(objPopulateVisualLayout.printerType.ToString()).Selected = true;
            this.ddlFabric.Items.FindByValue(objPopulateVisualLayout.Fabric.ToString()).Selected = true;
            this.ddlPattern.Items.FindByValue(objPopulateVisualLayout.Pattern.ToString()).Selected = true;

            this.ddlPattern_OnSelectedIndexChanged(null, null);

            if (objPopulateVisualLayout.imageHiddenField.Value != string.Empty)
            {
                this.PopulateFileUploder(this.rptUploadFile, objPopulateVisualLayout.imageHiddenField);
                this.hdnUploadFiles.Value = objPopulateVisualLayout.imageHiddenField.Value;
            }

            this.txtNotes.Text = objPopulateVisualLayout.Notes;

            Session["populateVisualLayout"] = null;
        }

        private void IsGeneratedProduct()
        {
            if (this.rbGenerate.Checked == true)
            {
                //this.lblProductNumber.Attributes.Remove("class");
                this.liPrinterType.Visible = true;

                this.txtProductNumber.Enabled = false;
                this.txtProductNumber.Text = (ViewState["vlName"] != null) ? ViewState["vlName"].ToString() : string.Empty;

            }
            else if (this.rbCustom.Checked == true)
            {
                //this.lblProductNumber.Attributes.Add("class", "required");
                // this.liPrinterType.Visible = false;

                this.txtProductNumber.Enabled = true;
                this.txtProductNumber.Text = string.Empty;
            }
        }

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

        //private List<KeyValuePair<Tuple<int, int>, int>> GetFilteredFabricData(int fabricID, int vlFabricID, bool isDeleted)
        //{
        //    List<KeyValuePair<Tuple<int, int>, int>> lst = new List<KeyValuePair<Tuple<int, int>, int>>();

        //    foreach (DataGridItem item in this.dgvAddEditFabrics.Items)
        //    {
        //        Literal litID = (Literal)item.FindControl("litID");
        //        Literal litVFID = (Literal)item.FindControl("litVFID");
        //        DropDownList ddlfabricCodeType = (DropDownList)item.FindControl("ddlfabricCodeType");

        //        lst.Add(new KeyValuePair<Tuple<int, int>, int>(new Tuple<int, int>(int.Parse(litVFID.Text), int.Parse(ddlfabricCodeType.SelectedValue.ToString())), int.Parse(litID.Text)));
        //    }

        //    if (fabricID > 0) // Add, Delete
        //    {
        //        if (isDeleted)
        //        {
        //            lst.Remove(new KeyValuePair<Tuple<int, int>, int>(new Tuple<int, int>(vlFabricID, 0), fabricID));
        //        }
        //        else
        //        {
        //            lst.Add(new KeyValuePair<Tuple<int, int>, int>(new Tuple<int, int>(vlFabricID, 0), fabricID));
        //        }
        //    }
        //    else // Page edit mode to load all data 
        //    {
        //        if (this.QueryID > 0)
        //        {
        //            VisualLayoutFabricBO objVLF = new VisualLayoutFabricBO();
        //            objVLF.VisualLayout = this.QueryID;

        //            lst.AddRange(objVLF.SearchObjects().Select(m => new KeyValuePair<Tuple<int, int>, int>(new Tuple<int, int>(m.ID, m.FabricCodeType ?? 0), m.Fabric)).ToList());
        //        }
        //    }

        //    Session["VisualLayoutFabrics"] = lst;
        //    return lst;
        //}

        //private List<KeyValuePair<int, KeyValuePair<int, string>>> GetFilteredFabricData(int fabricID, int typeID, bool isDeleted)
        //{
        //    //List<KeyValuePair<Tuple<int, int>, int>> lst = new List<KeyValuePair<Tuple<int, int>, int>>();
        //    List<KeyValuePair<int, KeyValuePair<int, string>>> lst = new List<KeyValuePair<int, KeyValuePair<int, string>>>();

        //    foreach (DataGridItem item in this.dgvAddEditFabrics.Items)
        //    {
        //        Literal litID = (Literal)item.FindControl("litID");
        //        //Literal litVFID = (Literal)item.FindControl("litVFID");
        //        Literal litFabricTypeID = (Literal)item.FindControl("litFabricTypeID");
        //        Literal litFabricType = (Literal)item.FindControl("litFabricType");
        //        TextBox txtWhere = (TextBox)item.FindControl("txtWhere");

        //        //lst.Add(new KeyValuePair<Tuple<int, int>, int>(new Tuple<int, int>(int.Parse(litVFID.Text), int.Parse(ddlfabricCodeType.SelectedValue.ToString())), int.Parse(litID.Text)));
        //        lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>(int.Parse(litFabricTypeID.Text), new KeyValuePair<int, string>(int.Parse(litID.Text), txtWhere.Text)));
        //    }

        //    if (fabricID > 0) // Add, Delete
        //    {
        //        if (isDeleted)
        //        {
        //            //lst.Remove(new KeyValuePair<Tuple<int, int>, int>(new Tuple<int, int>(typeID, 0), fabricID));
        //            //lst.Remove(new KeyValuePair<int, KeyValuePair<int, string>>(typeID, fabricID));
        //            KeyValuePair<int, KeyValuePair<int, string>> removeFabric = lst.Where(m => m.Key == typeID && m.Value.Key == fabricID).SingleOrDefault();
        //            lst.Remove(removeFabric);
        //        }
        //        else
        //        {
        //            //lst.Add(new KeyValuePair<Tuple<int, int>, int>(new Tuple<int, int>(typeID, 0), fabricID));
        //            lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>(typeID, new KeyValuePair<int, string>(fabricID, "")));
        //        }
        //    }
        //    else // Page edit mode to load all data 
        //    {
        //        if (this.QueryID > 0)
        //        {
        //            VisualLayoutBO objVL = new VisualLayoutBO();
        //            objVL.ID = QueryID;
        //            objVL.GetObject();

        //            FabricCodeBO objFabric = new FabricCodeBO();
        //            objFabric.ID = objVL.FabricCode ?? 0;
        //            objFabric.GetObject();

        //            try
        //            {
        //                string[] codes = objFabric.Code.Split('+');
        //                string[] wheres = string.IsNullOrEmpty(objVL.Where) ? new string[0] : objVL.Where.Split(',');

        //                List<KeyValuePair<int, string>> lstWheres = new List<KeyValuePair<int, string>>();

        //                foreach (string whereText in wheres)
        //                {
        //                    lstWheres.Add(new KeyValuePair<int, string>(int.Parse(whereText.Split('-')[0]), whereText.Split('-')[1]));
        //                }

        //                List<FabricCodeBO> lstFabricCodes = (List<FabricCodeBO>)Session["ListFabricCodes"];

        //                int fabricPosition = 0;

        //                foreach (string code in codes)
        //                {
        //                    FabricCodeBO objFabCode = lstFabricCodes.Where(m => m.Code == code).Single();
        //                    string whereText = lstWheres.Where(m => m.Key == objFabCode.ID).SingleOrDefault().Value;

        //                    if (++fabricPosition == 1)
        //                    {
        //                        lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>((int)FabricType.Main, new KeyValuePair<int, string>(objFabCode.ID, whereText)));
        //                    }
        //                    else if (objFabCode.IsLiningFabric)
        //                    {
        //                        lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>((int)FabricType.Lining, new KeyValuePair<int, string>(objFabCode.ID, whereText)));
        //                    }
        //                    else
        //                    {
        //                        lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>((int)FabricType.Secondary, new KeyValuePair<int, string>(objFabCode.ID, whereText)));
        //                    }
        //                }
        //            }
        //            catch (Exception ex)
        //            {

        //            }

        //            //lst.AddRange(objVLF.SearchObjects().Select(m => new KeyValuePair<Tuple<int, int>, int>(new Tuple<int, int>(m.ID, m.FabricCodeType ?? 0), m.Fabric)).ToList());
        //        }
        //    }

        //    Session["VisualLayoutFabrics"] = lst;
        //    return lst;
        //}

        //private List<KeyValuePair<int, int>> GetFilteredFabricData(int fabricID, int vlFabricID, bool isDeleted)
        //{
        //    List<KeyValuePair<int, int>> lst = (List<KeyValuePair<int, int>>)Session["VisualLayoutFabrics"];
        //    lst = (lst == null) ? new List<KeyValuePair<int, int>>() : lst;

        //    if (fabricID > 0) // Add, Delete
        //    {
        //        if (isDeleted)
        //        {
        //            lst.Remove(new KeyValuePair<int, int>(vlFabricID, fabricID));
        //        }
        //        else
        //        {
        //            lst.Add(new KeyValuePair<int, int>(vlFabricID, fabricID));
        //        }
        //    }
        //    else // Page edit mode to load all data 
        //    {
        //        if (this.QueryID > 0)
        //        {
        //            VisualLayoutFabricBO objVLF = new VisualLayoutFabricBO();
        //            objVLF.VisualLayout = this.QueryID;

        //            lst.AddRange(objVLF.SearchObjects().Select(m => new KeyValuePair<int, int>(m.ID, m.Fabric)).ToList());
        //        }
        //    }

        //    Session["VisualLayoutFabrics"] = lst;
        //    return lst;
        //}

        //private void PopulateFabricDataGrid(int fabricID = 0, int vlFabricID = 0, bool isDeleted = false)
        //{
        //    List<KeyValuePair<int, FabricCodeBO>> lstFCodes = new List<KeyValuePair<int, FabricCodeBO>>();
        //    List<KeyValuePair<Tuple<int, int>, int>> fcIds = this.GetFilteredFabricData(fabricID, vlFabricID, isDeleted);

        //    this.dgvAddEditFabrics.DataSource = fcIds;
        //    this.dgvAddEditFabrics.DataBind();

        //    this.dgvAddEditFabrics.Visible = (this.dgvAddEditFabrics.Items.Count > 0);
        //    this.dvEmptyFabrics.Visible = !this.dgvAddEditFabrics.Visible;

        //}

        //private void PopulateFabricDataGrid(int fabricID, int typeID, bool isDeleted = false)
        //{
        //    //List<KeyValuePair<Tuple<int, int>, int>>  = this.GetFilteredFabricData(fabricID, typeID, isDeleted);
        //    List<KeyValuePair<int, KeyValuePair<int, string>>> fcIds = this.GetFilteredFabricData(fabricID, typeID, isDeleted);

        //    this.dgvAddEditFabrics.DataSource = fcIds;
        //    this.dgvAddEditFabrics.DataBind();

        //    this.dgvAddEditFabrics.Visible = (this.dgvAddEditFabrics.Items.Count > 0);
        //    this.dvEmptyFabrics.Visible = !this.dgvAddEditFabrics.Visible;

        //    PopulateFabricName();
        //}

        //private void PopulateFabricName()
        //{
        //    string mainFabName = string.Empty;
        //    string secondaryFabName = string.Empty;
        //    string liningFabName = string.Empty;

        //    foreach (DataGridItem item in this.dgvAddEditFabrics.Items)
        //    {
        //        Literal litID = (Literal)item.FindControl("litID");
        //        Literal litFabricTypeID = (Literal)item.FindControl("litFabricTypeID");

        //        FabricCodeBO objFab = new FabricCodeBO();
        //        objFab.ID = int.Parse(litID.Text);
        //        objFab.GetObject();

        //        if (int.Parse(litFabricTypeID.Text) == 0)
        //        {
        //            mainFabName = objFab.Code;
        //        }
        //        else if (objFab.IsLiningFabric)
        //        {
        //            liningFabName += objFab.Code + "+";
        //        }
        //        else
        //        {
        //            secondaryFabName += objFab.Code + "+";
        //        }
        //    }

        //    liningFabName = string.IsNullOrEmpty(liningFabName) ? "" : "+" + liningFabName.Remove(liningFabName.Length - 1, 1);
        //    secondaryFabName = string.IsNullOrEmpty(secondaryFabName) ? "" : "+" + secondaryFabName.Remove(secondaryFabName.Length - 1, 1);

        //    string selectedFabric = mainFabName + secondaryFabName + liningFabName;
        //    this.ddlFabric.Enabled = false;
        //    //litVLFabricName.Text = selectedFabric;

        //    List<FabricCodeBO> lstFabricCodes = (List<FabricCodeBO>)Session["ListFabricCodes"];
        //    this.ddlFabric.ClearSelection();

        //    if (!string.IsNullOrEmpty(selectedFabric) && lstFabricCodes != null)
        //    {
        //        try
        //        {
        //            FabricCodeBO objFabric = lstFabricCodes.Where(m => m.Code == selectedFabric).Single();
        //            this.ddlFabric.Items.FindByValue(objFabric.ID.ToString()).Selected = true;
        //            lblVLFabricErrorText.Text = string.Empty;
        //        }
        //        catch (Exception ex)
        //        {
        //            lblVLFabricErrorText.Text = "The fabric combination selected, does not exist in Indiman Price List.  Please contact Indiman administrator to include in fabric combination list.";
        //        }
        //    }
        //}

        private void ResetViewStateValues()
        {
            ViewState["PopulateClientOrJob"] = false;
            ViewState["PopulateJobName"] = false;
        }
        
        #endregion

        [WebMethod]
        public static string CheckImageAvailable(string vlname)
        {
            using (var service = new ImageService())
            {
                var path = service.GetVlImageFromServerIfAvailable(vlname);
                return path;
            }
        }
    }
}