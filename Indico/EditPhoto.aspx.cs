using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class EditPhoto : IndicoPage
    {
        #region Fields

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

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (Page.IsValid)
                {
                    this.ProcessForm();

                    Response.Redirect("/EditPhoto.aspx");
                }

                this.dvPageValidation.Visible = !Page.IsValid;
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            // Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;

            // Populate profile picture
            this.imgProfilePicture.ImageUrl = UserBO.GetProfilePicturePath(this.LoggedUser, UserBO.ImageSize.Medium);
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm()
        {
            using (TransactionScope ts = new TransactionScope())
            {
                try
                {
                    UserBO objUser = new UserBO(this.ObjContext);
                    objUser.ID = this.LoggedUser.ID;
                    objUser.GetObject();

                    string physicalFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Users\\" + objUser.Guid;
                    if (!Directory.Exists(physicalFolderPath))
                    {
                        Directory.CreateDirectory(physicalFolderPath);
                    }

                    foreach (var path in Directory.GetFiles(physicalFolderPath))
                    {
                        File.Delete(path);
                    }

                    physicalFolderPath += "\\";

                    //Copy profile picture from temp to users and update database
                    if (!String.IsNullOrEmpty(this.hdnProfilePicture.Value))
                    {
                        try
                        {
                            string[] fileNames = (this.hdnProfilePicture.Value.Trim()).Split(',');
                            string fileReName = "user-profile-picture" + Path.GetExtension(fileNames[0]);
                            string temporyFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + /*this.LoggedUserTempLocation +*/ "\\" + Path.GetFileName(fileNames[0]);
                            ImageProcess objImageProcess = new ImageProcess();


                            string newFileName = string.Empty;

                            //32px x 32px

                            newFileName = physicalFolderPath + "user-profile-picture-32px-32px" + Path.GetExtension(fileNames[0]);
                            if (File.Exists(newFileName))
                            {
                                FileInfo oldFile = new FileInfo(newFileName);
                                oldFile.Delete();
                            }
                            objImageProcess.ResizeWebServiceImages(32, 32, temporyFolderPath, newFileName);


                            //64px x 64px

                            newFileName = physicalFolderPath + "user-profile-picture-64px-64px" + Path.GetExtension(fileNames[0]);
                            if (File.Exists(newFileName))
                            {
                                FileInfo oldFile = new FileInfo(newFileName);
                                oldFile.Delete();
                            }
                            objImageProcess.ResizeWebServiceImages(64, 64, temporyFolderPath, newFileName);


                            // 96px x 96px
                            newFileName = physicalFolderPath + "user-profile-picture-96px-96px" + Path.GetExtension(fileNames[0]);
                            if (File.Exists(newFileName))
                            {
                                FileInfo oldFile = new FileInfo(newFileName);
                                oldFile.Delete();
                            }
                            objImageProcess.ResizeWebServiceImages(96, 96, temporyFolderPath, newFileName);


                            objUser.PhotoPath = fileReName;
                        }
                        catch (Exception ex)
                        {
                            // Log the error
                            IndicoLogging.log.Error("Error occured while upload user profile picture to the data base", ex);
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
                catch (Exception ex)
                {
                    // Log the error
                    IndicoLogging.log.Error("Error occured while upload user image to the data base", ex);
                }
            }
        }

        #endregion
    }
}