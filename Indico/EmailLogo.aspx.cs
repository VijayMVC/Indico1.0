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
    public partial class EmailLogo : IndicoPage
    {

        #region Fields

        private int rptPageSize = 10;

        #endregion

        #region Properties

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

        protected void cvLabel_OnServerValidate(object sender, ServerValidateEventArgs e)
        {
            if (this.hdnUploadFiles.Value == "0" || string.IsNullOrEmpty(this.hdnUploadFiles.Value))
                e.IsValid = false;
            else
                e.IsValid = true;
        }

        protected void rptEmailLogo_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is EmailLogoBO)
            {
                EmailLogoBO objEmailLogo = (EmailLogoBO)item.DataItem;
                string emailLogoLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmailLogos/" + objEmailLogo.EmailLogoPath;

                if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + emailLogoLocation))
                {
                    emailLogoLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }
                System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + emailLogoLocation);
                SizeF origImageSize = VLOrigImage.PhysicalDimension;
                VLOrigImage.Dispose();

                List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 240, 160);

                System.Web.UI.WebControls.Image imgLabel = (System.Web.UI.WebControls.Image)item.FindControl("imgEmailLogo");
                imgLabel.ImageUrl = emailLogoLocation;
                imgLabel.Width = int.Parse(lstImgDimensions[1].ToString());
                imgLabel.Height = int.Parse(lstImgDimensions[0].ToString());

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objEmailLogo.ID.ToString());

                HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objEmailLogo.ID.ToString());
            }
        }

        protected void btnAddEmailLogo_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (Page.IsValid)
                {
                    this.ProcessForm();
                    this.PopulateEmailLogo();
                }
                else
                {
                    this.PopulateFileUploder(this.rptUploadFile, this.hdnUploadFiles);
                }
                Session["isRefresh"] = Server.UrlEncode(System.DateTime.Now.ToString());
            }
            else
            {
                this.PopulateEmailLogo();
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int emailogoID = int.Parse(this.hdnSelectedId.Value);
            // int distributorId = int.Parse(this.ddlDistributor.SelectedValue);

            if (emailogoID > 0)
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    try
                    {

                        EmailLogoBO objEmailLogo = new EmailLogoBO(this.ObjContext);
                        objEmailLogo.ID = emailogoID;
                        objEmailLogo.GetObject();

                        string labelPath = objEmailLogo.EmailLogoPath;

                        objEmailLogo.Delete();

                        this.ObjContext.SaveChanges();
                        ts.Complete();

                        string fileLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\EmailLogos\\" + labelPath;

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
                    //  this.rfvLabelName.Enabled = false;
                }
            }

            this.PopulateEmailLogo();
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


            this.PopulateEmailLogo();
        }

        private void PopulateEmailLogo()
        {
            //this.hdnUploadFiles.Value = "0";

            this.rptEmailLogo.DataSource = null;
            this.rptEmailLogo.DataBind();

            this.litHeaderText.Text = this.ActivePage.Heading;

            List<EmailLogoBO> lstEmailLogo = (from o in (new EmailLogoBO()).GetAllObject() select o).ToList();
            if (lstEmailLogo.Count > 0)
            {
                this.rptEmailLogo.DataSource = lstEmailLogo;
                this.rptEmailLogo.DataBind();
            }

            this.dvEmailLogo.Visible = (lstEmailLogo.Count > 0);
            this.fieldDetails.Visible = !(lstEmailLogo.Count > 0);
            this.dvFormAction.Visible = !(lstEmailLogo.Count > 0);
            this.btnAddEmailLogo.Visible = !(lstEmailLogo.Count > 0);
            this.fieldpopulateEmailLogo.Visible = (lstEmailLogo.Count > 0);


        }

        private void ProcessForm()
        {
            string sourceFileLocation = string.Empty;
            string destinationFolderPath = string.Empty;
            string EmailLogo = this.hdnUploadFiles.Value.Split(',')[0];

            using (TransactionScope ts = new TransactionScope())
            {
                try
                {

                    EmailLogoBO objEmailLogo = new EmailLogoBO(this.ObjContext);
                    objEmailLogo.EmailLogoPath = EmailLogo;

                    destinationFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\EmailLogos\\";
                    sourceFileLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + EmailLogo;

                    #region Copy File

                    if (EmailLogo != string.Empty)
                    {
                        if (File.Exists(destinationFolderPath + "\\" + EmailLogo))
                        {
                            string tmpFileName = Path.GetFileNameWithoutExtension(EmailLogo);
                            string tmpExtension = Path.GetExtension(EmailLogo);

                            objEmailLogo.EmailLogoPath = EmailLogo;
                        }

                        if (!Directory.Exists(destinationFolderPath))
                            Directory.CreateDirectory(destinationFolderPath);
                        File.Copy(sourceFileLocation, destinationFolderPath + "\\" + EmailLogo);
                    }

                    #endregion

                    objEmailLogo.Add();

                    this.ObjContext.SaveChanges();
                    ts.Complete();

                    this.hdnUploadFiles.Value = "0";

                    this.rptUploadFile.DataSource = null;
                    this.rptUploadFile.DataBind();
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while adding Email Logos", ex);
                }
            }
        }



        #endregion
    }
}