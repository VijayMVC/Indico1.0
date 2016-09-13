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
using System.Transactions;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using Telerik.Web.UI;

namespace Indico
{
    public partial class ViewVisualLayouts : IndicoPage
    {
        #region Fields

        private readonly List<ResolutionProfileBO> rp_source = new ResolutionProfileBO().SearchObjects().ToList();
        private readonly List<PrinterBO> pr_source = new PrinterBO().SearchObjects().ToList();

        #endregion

        #region Properties

        private List<ResolutionProfileBO> ResolutionProfile_Source
        {
            get { return rp_source; }
        }

        private List<PrinterBO> Printer_Source
        {
            get { return pr_source; }
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
                if (Request.UrlReferrer != null)
                {
                    string previousPage = Request.UrlReferrer.ToString();
                    Uri uri = new Uri(previousPage);
                    string filename = System.IO.Path.GetFileName(uri.LocalPath);
                    if (filename == "AddEditArtWork.aspx")
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "Artworks",
                              "<script type=\"text/javascript\"> $(document).ready(function () { $(\".iSwitchArtwork\").click(); });</script>");
                    }
                    if (filename == "AddEditVisualLayout.aspx")
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "products",
                              "<script type=\"text/javascript\"> $(document).ready(function () { $(\".iSwitchProduct\").click(); });</script>");
                    }
                }
                PopulateControls();
            }
        }

        protected void RadGridVisualLayouts_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindProductsGrid();
        }

        protected void RadGridVisualLayouts_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindProductsGrid();
        }

        protected void RadGridVisualLayouts_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if ((item.ItemIndex > -1 && item.DataItem is VisualLayoutDetailsView))
                {
                    try
                    {
                        VisualLayoutDetailsView objVisualLayoutDetails = (VisualLayoutDetailsView)item.DataItem;

                        HtmlAnchor ancMainImage = (HtmlAnchor)item.FindControl("ancMainImage");
                        HtmlGenericControl iVlimageView = (HtmlGenericControl)item.FindControl("iVlimageView");

                        if (!string.IsNullOrEmpty(objVisualLayoutDetails.FileName + objVisualLayoutDetails.Extension))
                        {
                            ancMainImage.Title = "Visual Layout Image";
                            ancMainImage.HRef = IndicoPage.GetVLImagePath(objVisualLayoutDetails.VisualLayout, objVisualLayoutDetails.FileName, objVisualLayoutDetails.Extension);

                            ancMainImage.Attributes.Add("class", "btn-link preview");
                            iVlimageView.Attributes.Add("class", "icon-eye-open");

                            try
                            {
                                System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + ancMainImage.HRef);
                                SizeF origImageSize = VLOrigImage.PhysicalDimension;
                                VLOrigImage.Dispose();

                                List<float> lstVLImageDimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 350);

                                if (lstVLImageDimensions.Count > 0)
                                {
                                    ancMainImage.Attributes.Add("height", lstVLImageDimensions[0].ToString());
                                    ancMainImage.Attributes.Add("width", lstVLImageDimensions[1].ToString());
                                }
                            }
                            catch (Exception ex)
                            {
                                ancMainImage.Title = "Visual Layout Image Not Found";
                                iVlimageView.Attributes.Add("class", "icon-eye-close");
                            }
                        }
                        else
                        {
                            ancMainImage.Title = "Visual Layout Image Not Found";
                            iVlimageView.Attributes.Add("class", "icon-eye-close");
                        }

                        Literal lblIsGenerated = (Literal)item.FindControl("lblIsGenerated");
                        //lblIsGenerated.Text = (objVisualLayoutDetails.)

                        HyperLink lnkEdit = (HyperLink)item.FindControl("lnkEdit");
                        lnkEdit.NavigateUrl = "AddEditVisualLayout.aspx?id=" + objVisualLayoutDetails.VisualLayout.ToString();

                        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                        linkDelete.Attributes.Add("qid", objVisualLayoutDetails.VisualLayout.ToString());

                        linkDelete.Visible = objVisualLayoutDetails.CanDelete ?? false;

                        DropDownList ddlResolutionProfile = (DropDownList)item.FindControl("ddlResolutionProfile");
                        DropDownList ddlPrinter = (DropDownList)item.FindControl("ddlPrinter");

                        ddlResolutionProfile.Items.Add(new ListItem("Select Resolution Profile", "0"));
                        ddlPrinter.Items.Add(new ListItem("Select Printer", "0"));

                        ddlResolutionProfile.Attributes.Add("vlid", objVisualLayoutDetails.VisualLayout.ToString());
                        ddlPrinter.Attributes.Add("vlid", objVisualLayoutDetails.VisualLayout.ToString());

                        foreach (ResolutionProfileBO res in ResolutionProfile_Source)
                        {
                            ddlResolutionProfile.Items.Add(new ListItem(res.Name, res.ID.ToString()));
                        }

                        foreach (PrinterBO printer in Printer_Source)
                        {
                            ddlPrinter.Items.Add(new ListItem(printer.Name, printer.ID.ToString()));
                        }

                        ddlResolutionProfile.Items.FindByValue(objVisualLayoutDetails.ResolutionProfile.ToString()).Selected = true;
                        ddlPrinter.Items.FindByValue(objVisualLayoutDetails.Printer.ToString()).Selected = true;
                    }
                    catch (Exception ex)
                    {
                    }
                }
            }
        }

        protected void RadGridVisualLayouts_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindProductsGrid();
        }

        protected void RadGridVisualLayouts_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindProductsGrid();
            }
        }

        protected void RadGridVisualLayouts_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindProductsGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindProductsGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateVisualLayouts();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int vlId = int.Parse(this.hdnSelectedID.Value);
            if (vlId > 0)
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    try
                    {
                        VisualLayoutBO objVisualLayout = new VisualLayoutBO(this.ObjContext);
                        objVisualLayout.ID = vlId;
                        objVisualLayout.GetObject();

                        List<ImageBO> lstVisualLayoutImages = objVisualLayout.ImagesWhereThisIsVisualLayout;

                        foreach (ImageBO image in lstVisualLayoutImages)
                        {
                            ImageBO objImage = new ImageBO(this.ObjContext);
                            objImage.ID = image.ID;
                            objImage.GetObject();

                            objImage.Delete();
                            this.ObjContext.SaveChanges();
                        }

                        List<VisualLayoutAccessoryBO> lstVisualLayoutAccessory = objVisualLayout.VisualLayoutAccessorysWhereThisIsVisualLayout;
                        foreach (VisualLayoutAccessoryBO Accessory in lstVisualLayoutAccessory)
                        {
                            VisualLayoutAccessoryBO objVisualLayoutAccessory = new VisualLayoutAccessoryBO(this.ObjContext);
                            objVisualLayoutAccessory.ID = Accessory.ID;
                            objVisualLayoutAccessory.GetObject();

                            objVisualLayoutAccessory.Delete();
                            this.ObjContext.SaveChanges();
                        }

                        // Delete from Visual Layout Fabric table records befor deleting Visual layout
                        List<VisualLayoutFabricBO> lstVisualLayoutFabrics = objVisualLayout.VisualLayoutFabricsWhereThisIsVisualLayout;
                        foreach (VisualLayoutFabricBO fabric in lstVisualLayoutFabrics)
                        {
                            VisualLayoutFabricBO objVisualLayoutFabric = new VisualLayoutFabricBO(this.ObjContext);
                            objVisualLayoutFabric.ID = fabric.ID;
                            objVisualLayoutFabric.GetObject();

                            objVisualLayoutFabric.Delete();
                            this.ObjContext.SaveChanges();
                        }

                        objVisualLayout.Delete();
                        this.ObjContext.SaveChanges();
                        ts.Complete();

                        //Delete 
                        try
                        {
                            string folderLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\VisualLayout\\" + vlId.ToString();
                            if (Directory.Exists(folderLocation))
                                Directory.Delete(folderLocation, true);
                        }
                        catch { }
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while deleting visual layout", ex);
                    }
                }

                this.PopulateVisualLayouts();
            }
        }

        protected void ddlResolutionProfile_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                int visuallayout = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["vlid"].ToString());

                if (visuallayout > 0)
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        VisualLayoutBO objVisualLayout = new VisualLayoutBO(this.ObjContext);
                        objVisualLayout.ID = visuallayout;
                        objVisualLayout.GetObject();

                        objVisualLayout.ResolutionProfile = int.Parse(((System.Web.UI.WebControls.ListControl)(sender)).SelectedValue);

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving Resolution Profile in ViewVisualLayout.aspx page", ex);
            }

            this.PopulateVisualLayouts();
        }

        protected void ddlPrinter_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                int visuallayout = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["vlid"].ToString());

                if (visuallayout > 0)
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        VisualLayoutBO objVisualLayout = new VisualLayoutBO(this.ObjContext);
                        objVisualLayout.ID = visuallayout;
                        objVisualLayout.GetObject();

                        objVisualLayout.Printer = int.Parse(((System.Web.UI.WebControls.ListControl)(sender)).SelectedValue);

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving Printer in ViewVisualLayout.aspx page", ex);
            }

            // this.pageIndex = pageIndex;
            this.PopulateVisualLayouts();
        }


        protected void ddlSortByActive_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateVisualLayouts();
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            // Header Text
            this.litHeaderText.Text = "Products"; //this.ActivePage.Heading;
            // populate clients 
            Session["VLOrderBy"] = true;
            Session["totalCount"] = 1;
            Session["VLPageCount"] = 1;
            Session["VLLoadedPageNumber"] = 1;
            Session["pageindex"] = 1;
            Session["VisualLayoutsDetailsView"] = null;
            ViewState["IsPageValid"] = true;

            this.btnAddVL.Visible = !this.LoggedUser.IsDirectSalesPerson;
            if (this.LoggedUser.IsDirectSalesPerson)
            {
                this.RadGridVisualLayouts.MasterTableView.Columns.FindByUniqueNameSafe("ResolutionProfile").Visible = false;
                this.RadGridVisualLayouts.MasterTableView.Columns.FindByUniqueNameSafe("Printer").Visible = false;
                this.RadGridVisualLayouts.MasterTableView.Columns.FindByUniqueNameSafe("UserFunctions").Visible = false;
            }

            this.PopulateVisualLayouts();
        }

        private void PopulateVisualLayouts()
        {
            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;
            int coordinator = 0;
            int distributor = 0;
            int client = 0;
            string searchText = string.Empty;

            List<VisualLayoutDetailsView> lstVisualLayoutDetailsView = new List<VisualLayoutDetailsView>();

            if ((this.txtSearch.Text != string.Empty) && (this.txtSearch.Text != "search"))
            {
                searchText = this.txtSearch.Text.ToLower().Trim();
            }

            if (this.LoggedUser.IsDirectSalesPerson)
            {
                distributor = this.Distributor.ID;
            }
            else if (this.LoggedUserRoleName == UserRole.IndicoAdministrator || this.LoggedUserRoleName == UserRole.IndicoCoordinator)
            {
                // coordinator = this.LoggedUser.ID;
            }
            else if (this.LoggedUserRoleName == UserRole.DistributorAdministrator || this.LoggedUserRoleName == UserRole.DistributorCoordinator)
            {
                distributor = this.LoggedCompany.ID;
            }

            var visualLayoutStatus = (ddlSortByActive.SelectedItem.Text == "InActive") ? 0 : 1;

            //lstVisualLayoutDetailsView = VisualLayoutBO.GetVisualLayoutDetails(searchText, dgPageSize, pageIndex, int.Parse(SortExpression), OrderBy, out totalCount, coordinator, distributor, client, commonproduct).ToList();

            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Open();

                lstVisualLayoutDetailsView = connection.Query<VisualLayoutDetailsView>(string.Format(@"EXEC [Indico].[dbo].[SPC_ViewVisualLayoutDetails] '{0}','{1}','{2}','{3}',{4}", searchText, coordinator, distributor, client, visualLayoutStatus)).ToList();
                connection.Close();
            }

            if (lstVisualLayoutDetailsView.Count > 0)
            {
                this.RadGridVisualLayouts.AllowPaging = (lstVisualLayoutDetailsView.Count > this.RadGridVisualLayouts.PageSize);
                this.RadGridVisualLayouts.DataSource = lstVisualLayoutDetailsView;

                this.RadGridVisualLayouts.DataBind();
                Session["VisualLayoutsDetailsView"] = lstVisualLayoutDetailsView;
                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search")) // || (this.ddlDistributor.SelectedIndex != 0 || this.ddlClient.SelectedIndex != 0 || this.ddlCoordinator.SelectedIndex != 0)) //|| this.ddlCommonProduct.SelectedIndex != 0))
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyContent.Visible = true;
            }

            this.RadGridVisualLayouts.Visible = (lstVisualLayoutDetailsView.Count > 0);
        }

        private void ReBindProductsGrid()
        {
            if (Session["VisualLayoutsDetailsView"] != null)
            {
                RadGridVisualLayouts.DataSource = (List<VisualLayoutDetailsView>)Session["VisualLayoutsDetailsView"];
                RadGridVisualLayouts.DataBind();
                this.RadGridVisualLayouts.MasterTableView.Columns.FindByUniqueNameSafe("UserFunctions").Visible = !this.LoggedUser.IsDirectSalesPerson;
                ClientScript.RegisterStartupScript(this.GetType(), "products",
                    "<script type=\"text/javascript\"> $(document).ready(function () { $(\".iSwitchProduct\").click(); });</script>");
            }
        }

        #endregion

        #region inner class

        private class VisualLayoutDetailsView
        {
            public int VisualLayout { get; set; }
            public string Name { get; set; }
            public string Description { get; set; }
            public string Pattern { get; set; }
            public string Fabric { get; set; }
            public string JobName { get; set; }
            public string Client { get; set; }
            public string Distributor { get; set; }
            public string Coordinator { get; set; }
            public string NNPFilePath { get; set; }
            public DateTime? CreatedDate { get; set; }
            public bool? IsCommonProduct { get; set; }
            public int ResolutionProfile { get; set; }
            public int Printer { get; set; }
            public string SizeSet { get; set; }
            public bool? CanDelete { get; set; }
            public string FileName { get; set; }
            public string Extension { get; set; }
        }

        #endregion

    }
}