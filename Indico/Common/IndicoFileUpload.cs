using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Drawing;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using Indico.Common;
using Indico.BusinessObjects;

public class IndicoFileUpload
{
    public string ImageUrl { get; set; }
    public string ImageUniqueName { get; set; }
    public double ImageSize { get; set; }
    public string ImageOriginalName { get; set; }
    public string ImageHeight { get; set; }
    public string ImageWidth { get; set; }

    public void PopulateUploader(Repeater rpt, string uploadedFiles)
    {
        List<IndicoFileUpload> lstFileUpload = new List<IndicoFileUpload>();
        foreach (string imageDetails in uploadedFiles.Split('|'))
        {
            if (!string.IsNullOrEmpty(imageDetails))
            {
                string uniqName = imageDetails.Split(',')[0];
                string originalName = imageDetails.Split(',')[1].Split('|')[0];
                string sourceFileLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "\\temp\\" + uniqName;
                FileInfo fileInfo = new FileInfo(System.Web.HttpContext.Current.Server.MapPath(sourceFileLocation));
                double imageSize = Math.Round(double.Parse(fileInfo.Length.ToString()) / 1024 * 1000) / 1000;

                //Resize the  Image
                System.Drawing.Image activityOrigImage = System.Drawing.Image.FromFile(System.Web.HttpContext.Current.Server.MapPath(sourceFileLocation));
                SizeF origImageSize = activityOrigImage.PhysicalDimension;
                List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimension(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 250, 140);
                string height = lstImgDimensions[0].ToString();
                string width = lstImgDimensions[1].ToString();

                //Create Object IndicoFileUpload
                IndicoFileUpload objIndicoFileUpload = new IndicoFileUpload();
                objIndicoFileUpload.ImageUrl = sourceFileLocation;
                objIndicoFileUpload.ImageUniqueName = uniqName;
                objIndicoFileUpload.ImageOriginalName = originalName;
                objIndicoFileUpload.ImageSize = imageSize;
                objIndicoFileUpload.ImageHeight = height;
                objIndicoFileUpload.ImageWidth = width;

                //Add The Items to the IndicoFileUpload List 
                lstFileUpload.Add(objIndicoFileUpload);

            }
        }
        if (lstFileUpload.Count > 0)
        {
            rpt.ItemDataBound += new RepeaterItemEventHandler(rpt_ItemDataBound);
            rpt.DataSource = lstFileUpload;
            rpt.DataBind();
        }

    }

    void rpt_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        RepeaterItem item = e.Item;
        if (item.ItemIndex > -1 && item.DataItem is IndicoFileUpload)
        {
            IndicoFileUpload objIndicoFileUpload = (IndicoFileUpload)item.DataItem;

            System.Web.UI.WebControls.Image uploadImage = (System.Web.UI.WebControls.Image)item.FindControl("uploadImage");
            uploadImage.ImageUrl = objIndicoFileUpload.ImageUrl;
            uploadImage.Attributes.Add("Width", objIndicoFileUpload.ImageWidth);
            uploadImage.Attributes.Add("Height", objIndicoFileUpload.ImageHeight);

            Literal litfileName = (Literal)item.FindControl("litfileName");
            litfileName.Text = objIndicoFileUpload.ImageOriginalName;

            Literal litfileSize = (Literal)item.FindControl("litfileSize");
            litfileSize.Text = objIndicoFileUpload.ImageSize.ToString()+"Kb";
        }
    }

}


