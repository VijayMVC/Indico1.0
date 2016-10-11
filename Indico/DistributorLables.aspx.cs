using System;
using System.Collections.Generic;
using System.Linq;
using System.Transactions;
using System.IO;
using System.Drawing;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

using Indico.BusinessObjects;
using Indico.Common;


namespace Indico
{
    public partial class DistributorLables : IndicoPage
    {
        #region Fields

        private int rptPageSize = 10;

        #endregion

        #region Properties

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

        protected int LabelTotal
        {

            get
            {
                int c = 0;
                try
                {
                    if (Session["LabelTotal"] != null)
                    {
                        c = Convert.ToInt32(Session["LabelTotal"]);
                    }
                }
                catch (Exception)
                {
                    Session["LabelTotal"] = c;
                }
                Session["LabelTotal"] = c;
                return c;
            }
            set
            {
                Session["LabelTotal"] = value;
            }
        }

        protected int LabelPageCount
        {
            get
            {
                int c = 0;
                try
                {
                    if (Session["LabelPageCount"] != null)
                        c = Convert.ToInt32(Session["LabelPageCount"]);
                }
                catch (Exception)
                {
                    Session["LabelPageCount"] = c;
                }
                Session["LabelPageCount"] = c;
                return c;
            }
            set
            {
                Session["LabelPageCount"] = value;
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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                PopulateControls();
            }

        }

        protected override void OnPreRender(EventArgs e)
        {
            //Page Refresh
            Session["IsPostBack"] = Server.UrlEncode(Guid.NewGuid().ToString());
            ViewState["IsPostBack"] = Session["IsPostBack"];
        }

        protected void cvLabel_OnServerValidate(object sender, ServerValidateEventArgs e)
        {
            int labelID = int.Parse(hdnEditLabel.Value);

            if (labelID == 0 && (this.hdnUploadFiles.Value == "0" || string.IsNullOrEmpty(this.hdnUploadFiles.Value)))
                e.IsValid = false;
            else
                e.IsValid = true;
        }

        protected void rptLabels_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is LabelBO)
            {
                LabelBO objLabel = (LabelBO)item.DataItem;
                string labelLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/Labels/" + objLabel.LabelImagePath;

                if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + labelLocation))
                {
                    labelLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }
                System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + labelLocation);
                SizeF origImageSize = VLOrigImage.PhysicalDimension;
                VLOrigImage.Dispose();

                List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 210, 160);

                Label lblItemName = (Label)item.FindControl("lblItemName");
                lblItemName.Text = objLabel.Name;

                System.Web.UI.WebControls.Image imgLabel = (System.Web.UI.WebControls.Image)item.FindControl("imgLabel");
                imgLabel.ImageUrl = labelLocation;
                imgLabel.Width = int.Parse(lstImgDimensions[1].ToString());
                imgLabel.Height = int.Parse(lstImgDimensions[0].ToString());

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objLabel.ID.ToString());
                linkDelete.Visible = objLabel.DistributorLabelsWhereThisIsLabel.Any() || objLabel.OrderDetailsWhereThisIsLabel.Any();

                LinkButton linkEdit = (LinkButton)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objLabel.ID.ToString());

                HiddenField hdnLabelID = (HiddenField)item.FindControl("hdnLabelID");
                hdnLabelID.Value = objLabel.ID.ToString();
            }
        }

        protected void chbIsSample_CheckedChanged(object sender, EventArgs e)
        {
            this.dvDistributor.Visible = !(this.chbIsSample.Checked);
            if (this.chbIsSample.Checked)
            {
                foreach (ListItem item in this.ddlDistributor.Items)
                {
                    this.ddlDistributor.Items.FindByValue(item.Value).Selected = false;
                }

                this.ddlDistributor.Items.FindByValue("0").Selected = true;
            }

            this.PopulateLabels(0);
        }

        protected void ddlDistributor_SelectedIndexChanged(object sender, EventArgs e)
        {
            ClearControls();
            this.PopulateLabels(0);
            this.PopulateFileUploder(this.rptUploadFile, this.hdnUploadFiles);
        }

        protected void btnAddLabel_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (Page.IsValid)
                {
                    //this.rfvDistributor.Enabled = true;
                    //this.rfvLabelName.Enabled = true;
                    //this.cvLabel.Enabled = true;
                    //this.rfvLabelName.Enabled = true;

                    if (this.chbIsSample.Checked)
                        this.rfvDistributor.Enabled = false;
                    else
                        this.rfvDistributor.Enabled = true;

                    //Page.Validate();
                    this.ProcessForm();
                    this.PopulateLabels(0);
                }
                else
                {
                    this.PopulateFileUploder(this.rptUploadFile, this.hdnUploadFiles);
                }
                Session["isRefresh"] = Server.UrlEncode(System.DateTime.Now.ToString());
            }
            else
            {
                this.PopulateLabels(0);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int labelId = int.Parse(this.hdnSelectedId.Value);
            int distributorId = int.Parse(this.ddlDistributor.SelectedValue);

            if (labelId > 0 && distributorId > 0)
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    try
                    {
                        CompanyBO objDistributor = new CompanyBO(this.ObjContext);
                        objDistributor.ID = distributorId;
                        objDistributor.GetObject();

                        LabelBO objLabel = new LabelBO(this.ObjContext);
                        objLabel.ID = labelId;
                        objLabel.GetObject();

                        string labelPath = objLabel.LabelImagePath;

                        objLabel.DistributorLabelsWhereThisIsLabel.Remove(objDistributor);
                        objLabel.Delete();

                        this.ObjContext.SaveChanges();
                        ts.Complete();

                        string fileLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Labels\\" + labelPath;

                        if (File.Exists(fileLocation))
                        {
                            try
                            {
                                File.Delete(fileLocation);
                            }
                            catch { }
                        }
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while deleting the label", ex);
                    }
                    this.cvLabel.Enabled = false;
                    this.rfvLabelName.Enabled = false;
                }
            }
            else if (labelId > 0)
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    try
                    {
                        LabelBO objLabel = new LabelBO(this.ObjContext);
                        objLabel.ID = labelId;
                        objLabel.GetObject();

                        string labelPath = objLabel.LabelImagePath;

                        objLabel.Delete();
                        this.ObjContext.SaveChanges();
                        ts.Complete();

                        string fileLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Labels\\" + labelPath;

                        if (File.Exists(fileLocation))
                        {
                            try
                            {
                                File.Delete(fileLocation);
                            }
                            catch { }
                        }
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while deleting the label", ex);
                    }

                    this.rfvDistributor.Enabled = false;
                    this.rfvLabelName.Enabled = false;
                    this.cvLabel.Enabled = false;
                }
            }

            this.PopulateLabels(0);
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
            rfvDistributor.Enabled = false;
            rfvLabelName.Enabled = false;
            cvLabel.Enabled = false;

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

            if (clickedPageNumber == ((LabelTotal % rptPageSize == 0) ? LabelTotal / rptPageSize : Math.Floor((double)(LabelTotal / rptPageSize)) + 1))
                this.lbFooterNext.Visible = false;
            if (clickedPageNumber == 1)
                this.lbFooterPrevious.Visible = false;

            int startIndex = clickedPageNumber * 10 - 10;
            this.PopulateLabels(startIndex);

            if (clickedPageNumber % 10 == 1)
                this.ProcessNumbering(clickedPageNumber, LabelPageCount);
            else
            {
                if (clickedPageNumber > 10)
                {
                    if (clickedPageNumber % 10 == 0)
                        this.ProcessNumbering(clickedPageNumber - 9, LabelPageCount);
                    else
                        this.ProcessNumbering(((clickedPageNumber / 10) * 10) + 1, LabelPageCount);
                }
                else
                {
                    this.ProcessNumbering((clickedPageNumber / 10 == 0) ? 1 : clickedPageNumber / 10, LabelPageCount);
                }
            }
        }

        protected void rptLabels_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                HiddenField hdnLabelID = (HiddenField)e.Item.FindControl("hdnLabelID");

                LabelBO objLabel = new LabelBO();
                objLabel.ID = int.Parse(hdnLabelID.Value);
                objLabel.GetObject();

                this.hdnEditLabel.Value = hdnLabelID.Value;
                this.txtLabelName.Text = objLabel.Name;
                this.chbIsSample.Checked = objLabel.IsSample;
                btnAddLabel.InnerText = "Update Label";

                string labelLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/Labels/" + objLabel.LabelImagePath;

                if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + labelLocation))
                {
                    labelLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }
                System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + labelLocation);
                SizeF origImageSize = VLOrigImage.PhysicalDimension;
                VLOrigImage.Dispose();

                List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 210, 160);

                //Label lblItemName = (Label)item.FindControl("lblItemName");
                //lblItemName.Text = objLabel.Name;

                //System.Web.UI.WebControls.Image imgLabel = (System.Web.UI.WebControls.Image)e.Item.FindControl("imgLabel");
                this.imgLabel.ImageUrl = labelLocation;
                this.imgLabel.Width = int.Parse(lstImgDimensions[1].ToString());
                this.imgLabel.Height = int.Parse(lstImgDimensions[0].ToString());
                this.imgLabel.Visible = true;
            }
            catch (Exception ex)
            {

            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            //Page Refresh
            Session["isRefresh"] = Server.UrlEncode(System.DateTime.Now.ToString());
            // Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;

            //Populate Distributor
            this.ddlDistributor.Items.Clear();
            this.ddlDistributor.Items.Add(new ListItem("Select Distributor", "0"));
            List<CompanyBO> lstDistributors = (new CompanyBO()).GetAllObject().Where(o => o.IsDistributor == true && o.IsDelete == false && o.IsActive == true).OrderBy(o => o.Name).ToList();
            foreach (CompanyBO company in lstDistributors)
            {
                this.ddlDistributor.Items.Add(new ListItem(company.Name, company.ID.ToString()));
            }
            this.PopulateLabels(0);
        }

        private void PopulateLabels(int startIndex)
        {
            //this.hdnUploadFiles.Value = "0";
            int selectedDistributor = int.Parse(this.ddlDistributor.SelectedValue);
            this.rptLabels.DataSource = null;
            this.rptLabels.DataBind();

            if (selectedDistributor > 0)
            {
                this.litHeaderText.Text = this.ActivePage.Heading;

                CompanyBO objDistributor = new CompanyBO();
                objDistributor.ID = selectedDistributor;
                objDistributor.GetObject();

                if (objDistributor.DistributorLabelsWhereThisIsDistributor.Count > 0)
                {
                    #region Pagination Process

                    int TotLabelCount = objDistributor.DistributorLabelsWhereThisIsDistributor.Count;
                    int count = 0;

                    if (TotLabelCount < rptPageSize)
                        count = TotLabelCount;
                    else
                    {
                        if (startIndex == 0)
                            count = rptPageSize;
                        else
                        {
                            if ((count + rptPageSize) > TotLabelCount)
                                count = rptPageSize;
                            else
                            {
                                if (startIndex + rptPageSize > TotLabelCount)
                                    count = TotLabelCount % 10;
                                else
                                    count = rptPageSize;
                            }
                        }
                    }

                    Session["LabelTotal"] = TotLabelCount;
                    Session["LabelPageCount"] = (TotLabelCount % 10 == 0) ? (TotLabelCount / 10) : (TotLabelCount / 10 + 1);

                    this.dvPagingFooter.Visible = (TotLabelCount > rptPageSize);
                    this.lbFooterPrevious.Visible = (startIndex != 0 && startIndex != 90);
                    this.ProcessNumbering(1, Convert.ToInt32(Session["LabelPageCount"]));
                    //this.lblPageCountString.Text = "Showing " + (startIndex + 1).ToString() + " to " + (count + startIndex).ToString() + " of " + TotArticleCount + " Articles";


                    #endregion

                    this.rptLabels.DataSource = objDistributor.DistributorLabelsWhereThisIsDistributor.GetRange(startIndex, count);
                    this.rptLabels.DataBind();
                }

                this.dvLabels.Visible = (objDistributor.DistributorLabelsWhereThisIsDistributor.Count > 0);
            }
            else
            {
                List<LabelBO> lstSampleLabels = (new LabelBO()).GetAllObject().Where(o => o.IsSample == true).ToList();

                #region Pagination Process

                int TotLabelCount = lstSampleLabels.Count;
                int count = 0;

                if (TotLabelCount < rptPageSize)
                    count = TotLabelCount;
                else
                {
                    if (startIndex == 0)
                        count = rptPageSize;
                    else
                    {
                        if ((count + rptPageSize) > TotLabelCount)
                            count = rptPageSize;
                        else
                        {
                            if (startIndex + rptPageSize > TotLabelCount)
                                count = TotLabelCount % 10;
                            else
                                count = rptPageSize;
                        }
                    }
                }

                Session["LabelTotal"] = TotLabelCount;
                Session["LabelPageCount"] = (TotLabelCount % 10 == 0) ? (TotLabelCount / 10) : (TotLabelCount / 10 + 1);

                this.dvPagingFooter.Visible = (TotLabelCount > rptPageSize);
                this.lbFooterPrevious.Visible = (startIndex != 0 && startIndex != 90);
                this.ProcessNumbering(1, Convert.ToInt32(Session["LabelPageCount"]));
                //this.lblPageCountString.Text = "Showing " + (startIndex + 1).ToString() + " to " + (count + startIndex).ToString() + " of " + TotArticleCount + " Articles";


                #endregion

                if (lstSampleLabels.Count > 0)
                {
                    this.litHeaderText.Text = "Samples";
                    this.rptLabels.DataSource = lstSampleLabels.GetRange(startIndex, count);
                    this.rptLabels.DataBind();
                }

                this.dvLabels.Visible = (lstSampleLabels.Count > 0);
            }
        }

        private void ProcessForm()
        {
            string sourceFileLocation = string.Empty;
            string destinationFolderPath = string.Empty;
            string LabelName = this.hdnUploadFiles.Value.Split(',')[0];
            int labelID = int.Parse(hdnEditLabel.Value);

            using (TransactionScope ts = new TransactionScope())
            {
                try
                {
                    if (this.chbIsSample.Checked) //Sample
                    {
                        LabelBO objLabel = new LabelBO(this.ObjContext);

                        if (labelID > 0)
                        {
                            objLabel.ID = labelID;
                            objLabel.GetObject();
                        }

                        objLabel.IsSample = this.chbIsSample.Checked;
                        objLabel.Name = this.txtLabelName.Text.Trim();

                        #region Copy File

                        if (LabelName != string.Empty && LabelName != "0")
                        {
                            objLabel.LabelImagePath = LabelName;
                            destinationFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Labels\\";
                            sourceFileLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + LabelName;

                            if (File.Exists(destinationFolderPath + "\\" + LabelName))
                            {
                                string tmpFileName = Path.GetFileNameWithoutExtension(LabelName);
                                string tmpExtension = Path.GetExtension(LabelName);

                                LabelName = tmpFileName + "_" + (new Random()).Next(100).ToString() + tmpExtension;
                                objLabel.LabelImagePath = LabelName;
                            }

                            if (!Directory.Exists(destinationFolderPath))
                                Directory.CreateDirectory(destinationFolderPath);
                            File.Copy(sourceFileLocation, destinationFolderPath + "\\" + LabelName);
                        }

                        #endregion

                        if (labelID == 0)
                        {
                            objLabel.Add();
                        }

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                        this.hdnUploadFiles.Value = "0";
                    }
                    else
                    {
                        int selectedDistributor = int.Parse(this.ddlDistributor.SelectedValue);

                        if (selectedDistributor > 0)
                        {
                            CompanyBO objDistributor = new CompanyBO(this.ObjContext);
                            objDistributor.ID = selectedDistributor;
                            objDistributor.GetObject();

                            LabelBO objLabel = new LabelBO(this.ObjContext);

                            if (labelID > 0)
                            {
                                objLabel.ID = labelID;
                                objLabel.GetObject();
                            }

                            objLabel.IsSample = this.chbIsSample.Checked;
                            objLabel.Name = this.txtLabelName.Text.Trim();

                            #region Copy File

                            if (LabelName != string.Empty && LabelName != "0")
                            {
                                objLabel.LabelImagePath = objDistributor.ID.ToString() + "/" + LabelName;
                                destinationFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Labels\\" + objDistributor.ID.ToString();
                                sourceFileLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + LabelName;

                                if (File.Exists(destinationFolderPath + "\\" + LabelName))
                                {
                                    string tmpFileName = Path.GetFileNameWithoutExtension(LabelName);
                                    string tmpExtension = Path.GetExtension(LabelName);

                                    LabelName = tmpFileName + "_" + (new Random()).Next(100).ToString() + tmpExtension;
                                    objLabel.LabelImagePath = objDistributor.ID.ToString() + "/" + LabelName;
                                }

                                if (!Directory.Exists(destinationFolderPath))
                                    Directory.CreateDirectory(destinationFolderPath);
                                File.Copy(sourceFileLocation, destinationFolderPath + "\\" + LabelName);
                            }

                            #endregion

                            if (labelID == 0)
                            {
                                objDistributor.DistributorLabelsWhereThisIsDistributor.Add(objLabel);
                            }

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                            this.hdnUploadFiles.Value = "0";
                        }
                    }

                    ClearControls();
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while adding labels", ex);
                }
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

            if (LabelTotal <= 10 * rptPageSize)
            {
                this.lbFooterPreviousDots.Visible = false;
                this.lbFooterNextDots.Visible = false;
            }

            else if (LabelTotal - ((loadedPageTemp) * 10 * rptPageSize) <= 10 * rptPageSize)
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

        private void ClearControls()
        {
            this.rptUploadFile.DataSource = null;
            this.rptUploadFile.DataBind();
            this.txtLabelName.Text = string.Empty;
            this.chbIsSample.Checked = false;
            btnAddLabel.InnerText = "Add Label";
            this.imgLabel.Visible = false;
            this.hdnEditLabel.Value = "0";
        }

        
    }

        #endregion
    
}