using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading;

using Indico.BusinessObjects;
using Indico.Common;
using System.IO;
using System.Web.UI.HtmlControls;
using System.Drawing;

namespace Indico
{
    public partial class AddEditEmbroidery : IndicoPage
    {
        #region Fields

        private int urlQueryID = -1;
        private int ID = -1;
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

        protected int EmbroiderID
        {
            get
            {
                ID = 0;

                if ((ViewState["ID"] != null))
                {
                    ID = int.Parse(ViewState["ID"].ToString());
                }
                return ID;
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
                    Response.Redirect("/ViewEmbroideries.aspx");
                }
            }
        }

        protected void btnAddEmbroidery_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {

                this.ProcessForm(true);
                this.hdnEmbDetail.Value = "0";
                ViewState["isCompareImage"] = false;

                this.txtLocation.Text = string.Empty;
                this.txtHeight.Text = string.Empty;
                this.txtWidth.Text = string.Empty;
                this.txtNotes.Text = string.Empty;
            }
            this.PopulateControls();
        }

        protected void ddlDistributor_SelectedIndexChanged(object sender, EventArgs e)
        {
            int distributor = int.Parse(this.ddlDistributor.SelectedValue);
            this.PopulateCoordinator(distributor);
            ViewState["isCompareImage"] = false;
        }

        protected void dgEmbroiderDetails_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is EmbroideryDetailsBO)
            {
                EmbroideryDetailsBO objEmbroiderDetails = (EmbroideryDetailsBO)item.DataItem;

                Literal litLocation = (Literal)item.FindControl("litLocation");
                litLocation.Text = objEmbroiderDetails.Location;

                Literal litFabricType = (Literal)item.FindControl("litFabricType");
                litFabricType.Text = objEmbroiderDetails.objFabricType.Name;

                HtmlGenericControl dvFabricColor = (HtmlGenericControl)item.FindControl("dvFabricColor");
                dvFabricColor.Attributes.Add("style", (objEmbroiderDetails.FabricColor > 0) ? "background-color: " + objEmbroiderDetails.objFabricColor.ColorValue.ToString() : "background-color:#FFFFFF");

                Literal litWidth = (Literal)item.FindControl("litWidth");
                litWidth.Text = Convert.ToDecimal(objEmbroiderDetails.Width.ToString()).ToString("0.00");

                Literal litHeight = (Literal)item.FindControl("litHeight");
                litHeight.Text = Convert.ToDecimal(objEmbroiderDetails.Height.ToString()).ToString("0.00");

                Literal litStatus = (Literal)item.FindControl("litStatus");
                litStatus.Text = objEmbroiderDetails.objStatus.Name;

                Literal litNotes = (Literal)item.FindControl("litNotes");
                litNotes.Text = objEmbroiderDetails.Notes;

                HtmlAnchor ancProducedIamge = (HtmlAnchor)item.FindControl("ancProducedIamge");
                HtmlGenericControl iProimageView = (HtmlGenericControl)item.FindControl("iProimageView");

                // Procedure Image
                EmbroideryImageBO objEmbroideryImage = new EmbroideryImageBO();
                objEmbroideryImage.EmbroideryDetails = objEmbroiderDetails.ID;


                List<EmbroideryImageBO> lstProImage = objEmbroideryImage.SearchObjects().Where(o => o.IsRequested == false).ToList();


                if (lstProImage.Count > 0)
                {
                    ancProducedIamge.HRef = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmbroideryImages/" + "/" + objEmbroiderDetails.ID.ToString() + "/" + lstProImage[0].Filename + lstProImage[0].Extension;

                    if (!File.Exists(Server.MapPath(ancProducedIamge.HRef)))
                    {
                        ancProducedIamge.HRef = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    }

                    ancProducedIamge.Attributes.Add("class", "btn-link preview");
                    iProimageView.Attributes.Add("class", "icon-eye-open");
                    List<float> lstProcImageDimensions = (new ImageProcess()).GetResizedImageDimension(960, 720, 420, 360);
                    if (lstProcImageDimensions.Count > 0)
                    {
                        ancProducedIamge.Attributes.Add("height", lstProcImageDimensions[0].ToString());
                        ancProducedIamge.Attributes.Add("width", lstProcImageDimensions[1].ToString());
                    }
                }
                else
                {
                    ancProducedIamge.Title = "Produced Image Not Found";
                    iProimageView.Attributes.Add("class", "icon-eye-close");
                }

                // <! --------- / ----------------->


                // Requested Image

                HtmlAnchor ancRequestedIamge = (HtmlAnchor)item.FindControl("ancRequestedIamge");
                HtmlGenericControl iReqimageView = (HtmlGenericControl)item.FindControl("iReqimageView");

                List<EmbroideryImageBO> lstReqImage = objEmbroideryImage.SearchObjects().Where(o => o.IsRequested == true).ToList();

                if (lstReqImage.Count > 0)
                {
                    ancRequestedIamge.HRef = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmbroideryImages/" + "/" + objEmbroiderDetails.ID.ToString() + "/" + lstReqImage[0].Filename + lstReqImage[0].Extension;

                    if (!File.Exists(Server.MapPath(ancRequestedIamge.HRef)))
                    {
                        ancRequestedIamge.HRef = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    }

                    ancRequestedIamge.Attributes.Add("class", "btn-link preview");
                    iReqimageView.Attributes.Add("class", "icon-eye-open");
                    List<float> lstProcImageDimensions = (new ImageProcess()).GetResizedImageDimension(960, 720, 420, 360);
                    if (lstProcImageDimensions.Count > 0)
                    {
                        ancRequestedIamge.Attributes.Add("height", lstProcImageDimensions[0].ToString());
                        ancRequestedIamge.Attributes.Add("width", lstProcImageDimensions[1].ToString());
                    }
                }
                else
                {
                    ancRequestedIamge.Title = "Requested Image Not Found";
                    iReqimageView.Attributes.Add("class", "icon-eye-close");
                }


                // <! --------- / ----------------->

                HtmlAnchor linkCompare = (HtmlAnchor)item.FindControl("linkCompare");
                linkCompare.Attributes.Add("qid", objEmbroiderDetails.ID.ToString());

                HtmlAnchor linkEdit = (HtmlAnchor)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objEmbroiderDetails.ID.ToString());

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objEmbroiderDetails.ID.ToString());
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int id = int.Parse(this.hdnSelectedID.Value);
            string imagePath = string.Empty;

            if (id > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {

                        EmbroideryDetailsBO objEmbroiderDetails = new EmbroideryDetailsBO(this.ObjContext);
                        objEmbroiderDetails.ID = id;
                        objEmbroiderDetails.GetObject();

                        foreach (EmbroideryImageBO image in objEmbroiderDetails.EmbroideryImagesWhereThisIsEmbroideryDetails)
                        {
                            imagePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmbroideryImages/" + "/" + image.EmbroideryDetails.ToString() + "/" + image.Filename + image.Extension;

                            if (File.Exists(Server.MapPath(imagePath)))
                            {
                                File.Delete(Server.MapPath(imagePath));
                            }

                            EmbroideryImageBO objEmbroideryImage = new EmbroideryImageBO(this.ObjContext);
                            objEmbroideryImage.ID = image.ID;
                            objEmbroideryImage.GetObject();

                            objEmbroideryImage.Delete();
                        }

                        objEmbroiderDetails.Delete();

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while Deleting Embroider Detail From AddEditEmbroider.aspx Page", ex);
                }
            }

            this.PopulateControls();
        }

        protected void linkEdit_Click(object sender, EventArgs e)
        {
            int id = int.Parse(((HtmlAnchor)sender).Attributes["qid"].ToString());
            this.hdnEmbDetail.Value = id.ToString();

            this.ddlFabricColor.Items.FindByValue("0").Selected = false;
            this.ddlStatus.Items.FindByValue("0").Selected = false;
            this.ddlFabric.Items.FindByValue("0").Selected = false;

            this.btnAddEmbroidery.InnerText = "Update Embroider Detail";

            //NNM
            if (id > 0)
            {
                try
                {
                    EmbroideryDetailsBO objEmbroiderDetails = new EmbroideryDetailsBO();
                    objEmbroiderDetails.ID = id;
                    objEmbroiderDetails.GetObject();

                    this.txtLocation.Text = objEmbroiderDetails.Location;
                    this.ddlFabric.Items.FindByValue(objEmbroiderDetails.FabricType.ToString()).Selected = true;
                    this.ddlFabricColor.Items.FindByValue(objEmbroiderDetails.FabricColor.ToString()).Selected = true;
                    this.txtHeight.Text = Convert.ToDecimal(objEmbroiderDetails.Height.ToString()).ToString("0.00");
                    this.txtWidth.Text = Convert.ToDecimal(objEmbroiderDetails.Width.ToString()).ToString("0.00");
                    this.ddlStatus.Items.FindByValue(objEmbroiderDetails.Status.ToString()).Selected = true;
                    this.txtNotes.Text = objEmbroiderDetails.Notes;

                    this.PopulateEmbroideryImage(id);

                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while edit Embroider Detail From AddEditEmbroider.aspx Page", ex);
                }
            }

            ViewState["isCompareImage"] = false;

            this.collapse2.Attributes.Add("class", "accordion-body collapse in");
        }

        protected void btnDleteImage_Click(object sender, EventArgs e)
        {
            int id = int.Parse(this.hdnEmbImage.Value);
            string imagePath = string.Empty;
            int embDetailID = 0;

            if (id > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {

                        EmbroideryImageBO objEmbroideryImage = new EmbroideryImageBO(this.ObjContext);
                        objEmbroideryImage.ID = id;
                        objEmbroideryImage.GetObject();

                        embDetailID = objEmbroideryImage.EmbroideryDetails;
                        imagePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmbroideryImages/" + "/" + objEmbroideryImage.EmbroideryDetails.ToString() + "/" + objEmbroideryImage.Filename + objEmbroideryImage.Extension;

                        if (File.Exists(Server.MapPath(imagePath)))
                        {
                            File.Delete(Server.MapPath(imagePath));
                        }

                        objEmbroideryImage.Delete();

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }

                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while deleting Embroidery Image AddEditEmbroidery.aspx Page", ex);
                }
            }

            this.hdnUploadFiles.Value = string.Empty;
            this.hdnUploadFiles_1.Value = string.Empty;
            PopulateEmbroideryImage(embDetailID);
            ViewState["isCompareImage"] = false;
        }

        protected void linkCompare_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int id = int.Parse(((HtmlAnchor)sender).Attributes["qid"].ToString());
                string imagepathreq = string.Empty;
                string imageprocpath = string.Empty;
                this.dvNoEmbroideryImages.Visible = false;

                if (id > 0)
                {
                    // Requested Image
                    EmbroideryImageBO objEmbroideryImage = new EmbroideryImageBO();
                    objEmbroideryImage.EmbroideryDetails = id;


                    List<EmbroideryImageBO> lstReqImage = objEmbroideryImage.SearchObjects().Where(o => o.IsRequested == true).ToList();

                    if (lstReqImage.Count > 0)
                    {
                        imagepathreq = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmbroideryImages/" + "/" + id.ToString() + "/" + lstReqImage[0].Filename + lstReqImage[0].Extension;

                        if (!File.Exists(Server.MapPath(imagepathreq)))
                        {
                            imagepathreq = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                        }

                        System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + imagepathreq);
                        SizeF origImageSize = VLOrigImage.PhysicalDimension;
                        VLOrigImage.Dispose();

                        List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 500);


                        //lblItemName.Text = lstPatternTemplates[0].Filename;

                        this.linkDeleteRequested.Attributes.Add("qid", lstReqImage[0].ID.ToString());
                        imgRequestedImage.ImageUrl = imagepathreq;
                        imgRequestedImage.Width = int.Parse(lstImgDimensions[1].ToString());
                        imgRequestedImage.Height = int.Parse(lstImgDimensions[0].ToString());
                    }
                    else
                    {
                        imgRequestedImage.ImageUrl = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmbroideryImages/noimage-png-350px-350px.png";
                    }

                    // Procedure Image

                    List<EmbroideryImageBO> lstProImage = objEmbroideryImage.SearchObjects().Where(o => o.IsRequested == false).ToList();

                    if (lstProImage.Count > 0)
                    {
                        imageprocpath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmbroideryImages/" + "/" + id.ToString() + "/" + lstProImage[0].Filename + lstProImage[0].Extension;

                        if (!File.Exists(Server.MapPath(imageprocpath)))
                        {
                            imageprocpath = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                        }

                        System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + imageprocpath);
                        SizeF origImageSize = VLOrigImage.PhysicalDimension;
                        VLOrigImage.Dispose();

                        List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 500);


                        //lblItemName.Text = lstPatternTemplates[0].Filename;

                        this.linkDeleteProduced.Attributes.Add("qid", lstProImage[0].ID.ToString());
                        imgProducedImage.ImageUrl = imageprocpath;
                        imgProducedImage.Width = int.Parse(lstImgDimensions[1].ToString());
                        imgProducedImage.Height = int.Parse(lstImgDimensions[0].ToString());
                    }
                    else
                    {
                        imgProducedImage.ImageUrl = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    }

                    if (lstReqImage.Count == 0 && lstProImage.Count == 0)
                    {
                        this.dvNoEmbroideryImages.Visible = true;
                    }
                }
                else
                {
                    this.dvNoEmbroideryImages.Visible = true;
                }

                ViewState["isCompareImage"] = true;
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            ViewState["isPopulate"] = false;
            //Header Text
            this.litHeaderText.Text = ((this.QueryID > 0) ? "Edit " : "New ") + this.ActivePage.Heading;
            this.dvNoEmbroiderDetails.Visible = true;
            this.dgEmbroiderDetails.Visible = false;

            this.txtEmbStrikeOffDate.Text = DateTime.Now.ToString("dd MMMM yyyy");
            this.txtRequiredBy.Text = DateTime.Now.AddDays(7).ToString("dd MMMM yyyy");

            // Populate Distributor
            this.ddlDistributor.Items.Clear();
            this.ddlDistributor.Items.Add(new ListItem("Select Distributor", "0"));
            List<CompanyBO> lstDistributors = (new CompanyBO()).SearchObjects().Where(o => o.IsDistributor == true).OrderBy(o => o.Name).ToList();
            foreach (CompanyBO distributor in lstDistributors)
            {
                this.ddlDistributor.Items.Add(new ListItem(distributor.Name, distributor.ID.ToString()));
            }

            // populate Is Factory Users
            this.ddlAssigned.Items.Clear();
            this.ddlAssigned.Items.Add(new ListItem("Select Assigned", "0"));
            List<UserBO> lstFactoryUsers = (new UserBO()).GetAllObject().Where(o => o.Company == 2).OrderBy(o => o.GivenName).ToList();
            foreach (UserBO user in lstFactoryUsers)
            {
                this.ddlAssigned.Items.Add(new ListItem(user.GivenName + " " + user.FamilyName, user.ID.ToString()));
            }

            // populate Fabric Color
            this.ddlFabricColor.Items.Clear();
            this.ddlFabricColor.Items.Add(new ListItem("Select Fabric Color", "0"));
            List<AccessoryColorBO> lstColors = (new AccessoryColorBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (AccessoryColorBO color in lstColors)
            {
                this.ddlFabricColor.Items.Add(new ListItem(color.Name, color.ID.ToString()));
            }

            // populate Fabric
            this.ddlFabric.Items.Clear();
            this.ddlFabric.Items.Add(new ListItem("Select a Fabric Type", "0"));
            List<FabricTypeBO> lstFabrics = (new FabricTypeBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (FabricTypeBO fabric in lstFabrics)
            {
                this.ddlFabric.Items.Add(new ListItem(fabric.Name, fabric.ID.ToString()));
            }

            // populate Status
            this.ddlStatus.Items.Clear();
            this.ddlStatus.Items.Add(new ListItem("Select Status", "0"));
            List<EmbroideryStatusBO> lstStatus = (new EmbroideryStatusBO()).GetAllObject().OrderBy(o => o.Name).ToList();
            foreach (EmbroideryStatusBO status in lstStatus)
            {
                this.ddlStatus.Items.Add(new ListItem(status.Name, status.ID.ToString()));
            }

            this.btnAddEmbroidery.InnerText = "Add Embroider Detail";
            this.hdnUploadFiles.Value = string.Empty;
            this.hdnUploadFiles_1.Value = string.Empty;

            if (this.QueryID > 0 || this.EmbroiderID > 0)
            {
                EmbroideryBO objEmroidery = new EmbroideryBO();
                objEmroidery.ID = (this.QueryID > 0) ? this.QueryID : this.EmbroiderID;
                objEmroidery.GetObject();

                this.txtEmbStrikeOffDate.Text = objEmroidery.EmbStrikeOffDate.ToString("dd MMMM yyyy");
                this.txtJobName.Text = objEmroidery.JobName;
                this.ddlDistributor.Items.FindByValue(objEmroidery.Distributor.ToString()).Selected = true;
                this.txtClient.Text = objEmroidery.Client;
                this.txtProduct.Text = objEmroidery.Client;
                this.txtRequiredBy.Text = objEmroidery.PhotoRequiredBy.ToString("dd MMMM yyyy");
                this.ddlAssigned.Items.FindByValue(objEmroidery.Assigned.ToString()).Selected = true;

                this.PopulateCoordinator(objEmroidery.Distributor);

                List<EmbroideryDetailsBO> lstEmbroiderDetails = (new EmbroideryDetailsBO()).SearchObjects().Where(o => o.Embroidery == objEmroidery.ID).ToList();

                if (lstEmbroiderDetails.Count > 0)
                {
                    this.dgEmbroiderDetails.DataSource = lstEmbroiderDetails;
                    this.dgEmbroiderDetails.DataBind();

                    this.dgEmbroiderDetails.Visible = true;
                    this.dvNoEmbroiderDetails.Visible = false;
                }
                else
                {
                    this.dgEmbroiderDetails.Visible = false;
                    this.dvNoEmbroiderDetails.Visible = true;
                }
            }

            this.PopulateEmbroideryImage();
        }

        private void ProcessForm(bool isEmbDetails = false)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    // Save Embroider
                    #region Save Embroidery

                    EmbroideryBO objEmbroidery = new EmbroideryBO(this.ObjContext);
                    if (this.QueryID > 0 || this.EmbroiderID > 0)
                    {
                        objEmbroidery.ID = (this.QueryID > 0) ? this.QueryID : this.EmbroiderID;
                        objEmbroidery.GetObject();
                    }
                    else
                    {
                        objEmbroidery.Creator = this.LoggedUser.ID;
                        objEmbroidery.CreatedDate = DateTime.Now;
                    }

                    objEmbroidery.EmbStrikeOffDate = Convert.ToDateTime(this.txtEmbStrikeOffDate.Text);
                    objEmbroidery.JobName = this.txtJobName.Text;
                    objEmbroidery.Distributor = int.Parse(this.ddlDistributor.SelectedValue);
                    objEmbroidery.Coordinator = int.Parse(this.hdnCoordinator.Value);
                    objEmbroidery.Client = this.txtClient.Text;
                    objEmbroidery.Product = this.txtProduct.Text;
                    objEmbroidery.PhotoRequiredBy = Convert.ToDateTime(this.txtRequiredBy.Text);
                    objEmbroidery.Assigned = int.Parse(this.ddlAssigned.SelectedValue);
                    objEmbroidery.Modifier = this.LoggedUser.ID;
                    objEmbroidery.ModifiedDate = DateTime.Now;

                    this.ObjContext.SaveChanges();
                    ViewState["ID"] = objEmbroidery.ID.ToString();

                    #endregion

                    //Save Embroider Details
                    #region Save Embroidery Detail

                    if (isEmbDetails == true)
                    {
                        int EmbDetailID = int.Parse(this.hdnEmbDetail.Value);

                        EmbroideryDetailsBO objEmbroideryDetails = new EmbroideryDetailsBO(this.ObjContext);

                        if (EmbDetailID > 0)
                        {
                            objEmbroideryDetails.ID = EmbDetailID;
                            objEmbroideryDetails.GetObject();
                        }

                        objEmbroideryDetails.Location = this.txtLocation.Text;
                        objEmbroideryDetails.FabricColor = int.Parse(this.ddlFabricColor.SelectedValue);
                        objEmbroideryDetails.FabricType = int.Parse(this.ddlFabric.SelectedValue);
                        objEmbroideryDetails.Width = Convert.ToDecimal(this.txtWidth.Text);
                        objEmbroideryDetails.Height = Convert.ToDecimal(this.txtHeight.Text);
                        objEmbroideryDetails.Notes = this.txtNotes.Text;
                        objEmbroideryDetails.Embroidery = int.Parse(ViewState["ID"].ToString());
                        objEmbroideryDetails.Status = int.Parse(this.ddlStatus.SelectedValue);

                        this.ObjContext.SaveChanges();

                        ViewState["EmbroideryDetailID"] = objEmbroideryDetails.ID.ToString();
                    }

                    #endregion

                    // save Requested Images for Embroidery
                    #region Save Embroidery Requested Image

                    if (!string.IsNullOrEmpty(this.hdnUploadFiles.Value) && this.hdnUploadFiles.Value != "REMOVED")
                    {
                        foreach (string img in this.hdnUploadFiles.Value.Split('|').Select(o => o.Split(',')[0]))
                        {
                            if (!string.IsNullOrEmpty(img))
                            {
                                EmbroideryImageBO objEmbroideryImage = new EmbroideryImageBO(this.ObjContext);
                                objEmbroideryImage.Filename = Path.GetFileNameWithoutExtension(img);
                                objEmbroideryImage.Extension = Path.GetExtension(img);
                                objEmbroideryImage.Size = (int)(new FileInfo(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + img)).Length;
                                objEmbroideryImage.IsRequested = true;
                                objEmbroideryImage.EmbroideryDetails = int.Parse(ViewState["EmbroideryDetailID"].ToString());
                            }
                        }

                        this.ObjContext.SaveChanges();
                    }



                    #endregion

                    // Save Embroidery Produced Image
                    #region Save Embroidery Produced Image


                    if (!string.IsNullOrEmpty(this.hdnUploadFiles_1.Value) && this.hdnUploadFiles_1.Value != "REMOVED")
                    {
                        foreach (string img in this.hdnUploadFiles_1.Value.Split('|').Select(o => o.Split(',')[0]))
                        {
                            if (!string.IsNullOrEmpty(img))
                            {
                                EmbroideryImageBO objEmbroideryImage = new EmbroideryImageBO(this.ObjContext);
                                objEmbroideryImage.Filename = Path.GetFileNameWithoutExtension(img);
                                objEmbroideryImage.Extension = Path.GetExtension(img);
                                objEmbroideryImage.Size = (int)(new FileInfo(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\temp\\" + img)).Length;
                                objEmbroideryImage.IsRequested = false;
                                objEmbroideryImage.EmbroideryDetails = int.Parse(ViewState["EmbroideryDetailID"].ToString());
                            }
                        }

                        this.ObjContext.SaveChanges();
                    }

                    #endregion

                    ts.Complete();
                }

                #region Copy Template Images

                string sourceFileLocation = string.Empty;
                string destinationFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\EmbroideryImages\\" + ViewState["EmbroideryDetailID"].ToString();
                if (!string.IsNullOrEmpty(this.hdnUploadFiles.Value))
                {

                    // Save Embroidery Requested Image
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
                // Save Embroidery Produced Image
                if (this.hdnUploadFiles_1.Value != "0")
                {
                    foreach (string fileTemplateName in this.hdnUploadFiles_1.Value.Split('|').Select(o => o.Split(',')[0]))
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
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving  or updating Embroidery details in AddEditEbroidery.aspx", ex);
            }
        }

        private void PopulateCoordinator(int distributor)
        {
            if (distributor > 0)
            {
                CompanyBO objCompany = new CompanyBO();
                objCompany.ID = distributor;
                objCompany.GetObject();

                this.txtCoordinator.Text = objCompany.objCoordinator.GivenName + " " + objCompany.objCoordinator.FamilyName;
                this.hdnCoordinator.Value = objCompany.Coordinator.ToString();
            }
        }

        private void PopulateEmbroideryImage(int id = 0)
        {
            this.dvEmbroideryImagePreview.Visible = false;
            this.dvEmbroideryEmbProImage.Visible = false;
            this.dvEmptyContentEmbReqImage.Visible = false;
            string imagepathreq = string.Empty;
            string imageprocpath = string.Empty;
            this.dvRequestedImage.Visible = true;
            this.dvProducedImage.Visible = true;
            this.liProducedImage.Visible = true;
            this.liRequestedImage.Visible = true;

            if (id > 0)
            {
                // Requested Image
                EmbroideryImageBO objEmbroideryImage = new EmbroideryImageBO();
                objEmbroideryImage.EmbroideryDetails = id;


                List<EmbroideryImageBO> lstReqImage = objEmbroideryImage.SearchObjects().Where(o => o.IsRequested == true).ToList();

                if (lstReqImage.Count > 0)
                {
                    imagepathreq = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmbroideryImages/" + "/" + id.ToString() + "/" + lstReqImage[0].Filename + lstReqImage[0].Extension;

                    if (!File.Exists(Server.MapPath(imagepathreq)))
                    {
                        imagepathreq = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    }

                    System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + imagepathreq);
                    SizeF origImageSize = VLOrigImage.PhysicalDimension;
                    VLOrigImage.Dispose();

                    List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 300);


                    //lblItemName.Text = lstPatternTemplates[0].Filename;

                    this.linkDeleteRequested.Attributes.Add("qid", lstReqImage[0].ID.ToString());
                    imgEmbroiderRequested.ImageUrl = imagepathreq;
                    imgEmbroiderRequested.Width = int.Parse(lstImgDimensions[1].ToString());
                    imgEmbroiderRequested.Height = int.Parse(lstImgDimensions[0].ToString());
                    this.dvEmbroideryImagePreview.Visible = true;
                    this.dvRequestedImage.Visible = false;
                }
                else
                {
                    imgEmbroiderRequested.ImageUrl = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    this.dvRequestedImage.Visible = true;
                    this.liRequestedImage.Visible = false;
                }

                // Procedure Image

                List<EmbroideryImageBO> lstProImage = objEmbroideryImage.SearchObjects().Where(o => o.IsRequested == false).ToList();

                if (lstProImage.Count > 0)
                {
                    imageprocpath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmbroideryImages/" + "/" + id.ToString() + "/" + lstProImage[0].Filename + lstProImage[0].Extension;

                    if (!File.Exists(Server.MapPath(imageprocpath)))
                    {
                        imageprocpath = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    }

                    System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + imageprocpath);
                    SizeF origImageSize = VLOrigImage.PhysicalDimension;
                    VLOrigImage.Dispose();

                    List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 300);


                    //lblItemName.Text = lstPatternTemplates[0].Filename;

                    this.linkDeleteProduced.Attributes.Add("qid", lstProImage[0].ID.ToString());
                    imgEmbroideryProduced.ImageUrl = imageprocpath;
                    imgEmbroideryProduced.Width = int.Parse(lstImgDimensions[1].ToString());
                    imgEmbroideryProduced.Height = int.Parse(lstImgDimensions[0].ToString());
                    this.dvEmbroideryImagePreview.Visible = true;
                    this.dvProducedImage.Visible = false;
                }
                else
                {
                    imgEmbroideryProduced.ImageUrl = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                    this.dvProducedImage.Visible = true;
                    this.liRequestedImage.Visible = false;
                }
            }

            ViewState["isCompareImage"] = false;
        }

        #endregion
    }
}