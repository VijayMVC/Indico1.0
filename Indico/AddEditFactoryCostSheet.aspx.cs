using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;
using System.IO;

using Indico.BusinessObjects;
using Indico.Common;
using System.Drawing;

namespace Indico
{
    public partial class AddEditFactoryCostSheet : IndicoPage
    {
        #region Fields

        private int urlQueryID = -1;
        private List<FabricDetails> _activePatternFabrics = null;
        private List<AccessoryDetails> _activeAccessories = null;
        private int urlCloneID = -1;
        private int patternid = -1;
        private int fabricid = -1;
        private int invoice = -1;
        private int exsistfabric = 0;
        private decimal totalAccCost = 0;
        private decimal totalFabCost = 0;
        public string accTotalID = string.Empty;
        public string fabTotalID = string.Empty;

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

        protected int CloneID
        {
            get
            {
                if (urlCloneID > -1)
                    return urlCloneID;

                urlCloneID = 0;
                if (Request.QueryString["cloneid"] != null)
                {
                    urlCloneID = Convert.ToInt32(Request.QueryString["cloneid"].ToString());
                }
                return urlCloneID;
            }
        }

        protected int PatternID
        {
            get
            {
                if (patternid > -1)
                    return patternid;

                patternid = 0;
                if (Request.QueryString["pat"] != null)
                {
                    patternid = Convert.ToInt32(Request.QueryString["pat"].ToString());
                }
                return patternid;
            }
        }

        protected int FabricID
        {
            get
            {
                if (fabricid > -1)
                    return fabricid;

                fabricid = 0;
                if (Request.QueryString["fab"] != null)
                {
                    fabricid = Convert.ToInt32(Request.QueryString["fab"].ToString());
                }
                return fabricid;
            }
        }

        protected int Invoice
        {
            get
            {
                if (invoice > -1)
                    return invoice;

                invoice = 0;
                if (Request.QueryString["inv"] != null)
                {
                    invoice = Convert.ToInt32(Request.QueryString["inv"].ToString());
                }
                return invoice;
            }
        }

        protected int OldFabric
        {
            get
            {
                if (exsistfabric == 0 && ViewState["ExsistsFabric"] != null)
                {
                    exsistfabric = Convert.ToInt32(ViewState["ExsistsFabric"].ToString());
                }

                return exsistfabric;
            }
            set
            {
                ViewState["ExsistsFabric"] = value;
            }
        }

        #endregion

        #region Constructors

        #endregion

        #region Event
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
            this.ValidDataGrids();

            // ddlFabric_SelectedIndexChanged(null, null);

            if (Page.IsValid)
            {
                if (this.QueryID > 0)
                {
                    // delete fabric
                    this.DeleteFabrics(this.QueryID);

                    //delete accessory
                    this.DeleteAccessories(this.QueryID);
                }
                this.ProcessForm();

                this.dgAccessories.DataSource = null;
                this.dgAccessories.DataBind();

                this.dgAddEditFabrics.DataSource = null;
                this.dgAddEditFabrics.DataBind();
                // Response.Redirect("/AddEditFactoryCostSheet.aspx");

                if ((this.PatternID > 0 && this.FabricID > 0) || this.Invoice > 0)
                {
                    Response.Redirect("/AddEditInvoice.aspx?csid=" + Session["costsheetid"].ToString());
                }
                else if (this.QueryID == 0)
                {
                    if (Session["costsheetid"] != null)
                    {
                        Response.Redirect("/AddEditFactoryCostSheet.aspx?id=" + Session["costsheetid"].ToString());
                    }
                }
                else
                {
                    this.PopulateCostSheet(false);
                }

            }
            ViewState["deleteFabric"] = false;
            ViewState["deleteAccessory"] = false;
            ViewState["ViewNote"] = false;
        }

        protected void ddlFabrics_SelectedIndexChange(object sender, EventArgs e)
        {
            int fabric = int.Parse(((System.Web.UI.WebControls.ListControl)(sender)).SelectedValue);
            CustomValidator cv = null;

            if (fabric > 0)
            {
                List<FabricDetails> lstFabrics = (List<FabricDetails>)Session["Fabrics"];
                if (lstFabrics != null)
                {
                    lstFabrics = lstFabrics.Where(o => o.ID == fabric).ToList();

                    if (lstFabrics.Count == 0)
                    {
                        this.PopulateFabricDataGrid(fabric);
                    }
                    else
                    {
                        cv = new CustomValidator();
                        cv.IsValid = false;
                        cv.ValidationGroup = "validateCostsheet";
                        cv.ErrorMessage = "Cost Sheet for this Fabric exist in the system.";
                        Page.Validators.Add(cv);
                    }
                    this.PopulateAccessoriesDataGrid();
                }

            }
            this.ddlFabrics.SelectedIndex = 0;
            ViewState["deleteFabric"] = false;
            ViewState["deleteAccessory"] = false;
        }

        protected void ddlFabric_SelectedIndexChanged(object sender, EventArgs e)
        {
            int fabric = int.Parse(this.ddlFabric.SelectedValue);
            int pattern = int.Parse(this.ddlPattern.SelectedValue);

            CustomValidator cv = null;

            if (fabric > 0)
            {
                List<FabricDetails> lstFabrics = (List<FabricDetails>)Session["Fabrics"];

                if (lstFabrics != null)
                {
                    if (pattern > 0)
                    {
                        CostSheetBO objCostSheet = new CostSheetBO();
                        objCostSheet.Pattern = int.Parse(this.ddlPattern.SelectedValue);
                        objCostSheet.Fabric = fabric;
                        List<int> lstCostSheet = objCostSheet.SearchObjects().Select(m => m.ID).ToList();

                        // Check if this pattern and fabric use in another cost sheet
                        if (lstCostSheet.Any())
                        {
                            if (this.QueryID == 0)
                            {
                                cv = new CustomValidator();
                                cv.IsValid = false;
                                cv.ValidationGroup = "validateCostsheet";
                                cv.ErrorMessage = "<p>Cost Sheet exists for this pattern and main Fabric in the System.</p>     <p><a href=\"AddEditFactoryCostSheet.aspx?id=" + lstCostSheet[0] + "\" class=\"btn\">View Cost Sheet</a><p>";
                                Page.Validators.Add(cv);
                            }
                            else if (lstCostSheet.Contains(this.QueryID))
                            {
                                this.PopulateFabricDataGrid(fabric);
                            }
                        }
                        else
                        {
                            this.PopulateFabricDataGrid(fabric);
                        }

                        //if (lstCostSheet.Count == 0)
                        //{
                        //    if (this.QueryID > 0)
                        //    {
                        //        if (lstFabrics.Count == 0)
                        //        {
                        //            this.PopulateFabricDataGrid(fabric);
                        //        }
                        //        else
                        //        {
                        //            cv = new CustomValidator();
                        //            cv.IsValid = false;
                        //            cv.ValidationGroup = "validateCostsheet";
                        //            cv.ErrorMessage = "Cost Sheet for this Fabric exist in the system.";
                        //            Page.Validators.Add(cv);
                        //        }
                        //    }
                        //    else
                        //    {
                        //        // check if this fabric already in the system
                        //        if (lstFabrics.Count == 0)
                        //        {
                        //            this.PopulateFabricDataGrid(int.Parse(this.ddlFabric.SelectedValue));
                        //        }
                        //    }
                        //}
                        //else
                        //{
                        //    cv = new CustomValidator();
                        //    cv.IsValid = false;
                        //    cv.ValidationGroup = "validateCostsheet";
                        //    cv.ErrorMessage = "<p>Cost Sheet exists for this pattern and main Fabric in the System.</p>     <p><a href=\"AddEditFactoryCostSheet.aspx?id=" + lstCostSheet[0].ID + "\" class=\"btn\">View Cost Sheet</a><p>";
                        //    Page.Validators.Add(cv);
                        //}
                    }
                    else
                    {
                        cv = new CustomValidator();
                        cv.IsValid = false;
                        cv.ValidationGroup = "validateCostsheet";
                        cv.ErrorMessage = "Select the Pattern";
                        Page.Validators.Add(cv);
                        this.ddlFabric.SelectedIndex = 0;
                    }

                    this.PopulateAccessoriesDataGrid();
                }
            }
        }

        protected void ddlPattern_SelectedIndexChange(object sender, EventArgs e)
        {
            int pattern = int.Parse(this.ddlPattern.SelectedValue);
            if (pattern > 0)
            {
                List<CostSheetBO> lstCostSheet = null;
                string Meassage = string.Empty;

                if (this.CloneID > 0 && int.Parse(this.ddlFabric.SelectedValue) > 0)
                {
                    CostSheetBO objCostSheet = new CostSheetBO();
                    objCostSheet.Pattern = pattern;
                    objCostSheet.Fabric = int.Parse(this.ddlFabric.SelectedValue);

                    lstCostSheet = objCostSheet.SearchObjects();

                    Meassage = "<p>Cost Sheet exist for this pattern and main Fabric in the System.</p>     <p><a href=\"AddEditFactoryCostSheet.aspx?id=" + lstCostSheet[0].ID + "\" class=\"btn\">View Cost Sheet</a><p>";

                    if (lstCostSheet.Count > 0)
                    {
                        CustomValidator cv = new CustomValidator();
                        cv.IsValid = false;
                        cv.ValidationGroup = "validateCostsheet";
                        cv.ErrorMessage = Meassage;
                        Page.Validators.Add(cv);
                    }
                    else
                    {
                        this.PopulatePattern(pattern);
                    }
                }
                else
                {
                    this.PopulatePattern(pattern);
                }
            }

            ViewState["deleteFabric"] = false;
            // ViewState["deleteAccessory"] = false;
        }

        protected void ddlAccessory_SelectedIndexChange(object sender, EventArgs e)
        {
            int accessory = int.Parse(this.ddlAccessory.SelectedValue);

            if (accessory > 0)
            {
                List<AccessoryDetails> lstAccessories = (List<AccessoryDetails>)Session["Accessories"];
                if (lstAccessories != null)
                {
                    lstAccessories = lstAccessories.Where(o => o.ID == accessory).ToList();

                    if (lstAccessories.Count == 0)
                    {
                        this.PopulateAccessoriesDataGrid(accessory);
                    }
                    this.PopulateFabricDataGrid();
                }
            }
            this.ddlAccessory.SelectedIndex = 0;
            ViewState["deleteFabric"] = false;
            ViewState["deleteAccessory"] = false;
        }

        protected void dgAddEditFabrics_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is FabricDetails)
            {
                FabricDetails objItem = (FabricDetails)item.DataItem;

                Literal litCode = (Literal)item.FindControl("litCode");
                litCode.Text = objItem.Fabric;

                Literal litFabricNickName = (Literal)item.FindControl("litFabricNickName");
                litFabricNickName.Text = objItem.NickName;

                Literal litFabricSupplier = (Literal)item.FindControl("litFabricSupplier");
                litFabricSupplier.Text = objItem.Supplier;

                TextBox txtCons = (TextBox)item.FindControl("txtCons");
                txtCons.Text = objItem.Constant;

                Literal litUnit = (Literal)item.FindControl("litUnit");
                litUnit.Text = objItem.Unit;

                Label litFabricPrice = (Label)item.FindControl("litFabricPrice");
                litFabricPrice.Text = objItem.FabricPrice;
                litFabricPrice.Attributes.Add("id", objItem.ID.ToString());
                litFabricPrice.Attributes.Add("costid", objItem.CostSheet.ToString());
                litFabricPrice.Attributes.Add("pfid", objItem.patternfabric.ToString());

                Label lblfabricCost = (Label)item.FindControl("lblfabricCost");
                lblfabricCost.Text = objItem.FabricCost;

                TextBox txtFabricCost = (TextBox)item.FindControl("txtFabricCost");
                txtFabricCost.Text = objItem.FabricCost;

                totalFabCost += decimal.Parse(objItem.FabricCost);
            }

            if (e.Item.ItemType == ListItemType.Footer)
            {
                Label lblTotalFabricCost = (Label)item.FindControl("lblTotalFabricCost");
                lblTotalFabricCost.Text = totalFabCost.ToString();
                fabTotalID = lblTotalFabricCost.ClientID;
            }
        }

        protected void dgAddEditFabrics_onItemCommand(object sender, DataGridCommandEventArgs e)
        {
            string commandName = e.CommandName;

            switch (commandName)
            {
                case "Delete":
                    Label litFabricPrice = (Label)e.Item.FindControl("litFabricPrice");
                    int fabric = int.Parse(((System.Web.UI.WebControls.WebControl)(litFabricPrice)).Attributes["id"].ToString());
                    this.PopulateFabricDataGrid(fabric, true);
                    this.PopulateAccessoriesDataGrid();
                    ViewState["deleteFabric"] = true;
                    ViewState["deleteAccessory"] = false;

                    break;
                default:
                    break;
            }
        }

        protected void dgAccessories_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is AccessoryDetails)
            {
                AccessoryDetails objAccessory = (AccessoryDetails)item.DataItem;

                Literal litName = (Literal)item.FindControl("litName");
                litName.Text = objAccessory.Accesssory;

                Literal lblAccessoryDescription = (Literal)item.FindControl("lblAccessoryDescription");
                lblAccessoryDescription.Text = objAccessory.Description;

                Literal lblSupplier = (Literal)item.FindControl("lblSupplier");
                lblSupplier.Text = objAccessory.Supplier;

                Label litAccessoryPrice = (Label)item.FindControl("litAccessoryPrice");
                litAccessoryPrice.Text = objAccessory.Price;
                litAccessoryPrice.Attributes.Add("id", objAccessory.ID.ToString());
                litAccessoryPrice.Attributes.Add("costid", objAccessory.CostSheet.ToString());
                litAccessoryPrice.Attributes.Add("paid", objAccessory.patternaccessory.ToString());

                TextBox txtcons = (TextBox)item.FindControl("txtcons");
                txtcons.Text = objAccessory.Constant;

                TextBox txtAccessoryCost = (TextBox)item.FindControl("txtAccessoryCost");
                txtAccessoryCost.Text = objAccessory.Cost;

                Literal litaccessoryUnit = (Literal)item.FindControl("litaccessoryUnit");
                litaccessoryUnit.Text = objAccessory.Unit;

                Label lblaccessoryCost = (Label)item.FindControl("lblaccessoryCost");
                lblaccessoryCost.Text = objAccessory.Cost;

                totalAccCost += decimal.Parse(objAccessory.Cost);
            }

            if (e.Item.ItemType == ListItemType.Footer)
            {
                Label lblTotalAccessoryCost = (Label)item.FindControl("lblTotalAccessoryCost");
                lblTotalAccessoryCost.Text = totalAccCost.ToString();
                accTotalID = lblTotalAccessoryCost.ClientID;
            }
        }

        protected void dgAccessories_onItemCommand(object sender, DataGridCommandEventArgs e)
        {
            string commandName = e.CommandName;

            switch (commandName)
            {
                case "Delete":
                    Label litAccessoryPrice = (Label)e.Item.FindControl("litAccessoryPrice");
                    int ace = int.Parse(((System.Web.UI.WebControls.WebControl)(litAccessoryPrice)).Attributes["id"].ToString());
                    int id = int.Parse(((System.Web.UI.WebControls.WebControl)(litAccessoryPrice)).Attributes["paid"].ToString());

                    this.DeleteAccessory(id);
                    this.PopulateAccessoriesDataGrid(ace, true);
                    this.PopulateFabricDataGrid();
                    ViewState["deleteFabric"] = false;
                    ViewState["deleteAccessory"] = true;
                    break;
                default:
                    break;
            }
        }

        protected void dgViewNote_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (e.Item.ItemIndex > -1 && item.DataItem is CostSheetRemarksBO)
            {
                CostSheetRemarksBO objCostSheetRemarks = (CostSheetRemarksBO)item.DataItem;

                Literal litModifier = (Literal)item.FindControl("litModifier");
                litModifier.Text = objCostSheetRemarks.objModifier.GivenName + " " + objCostSheetRemarks.objModifier.FamilyName;

                Literal litModifiedDate = (Literal)item.FindControl("litModifiedDate");
                litModifiedDate.Text = objCostSheetRemarks.ModifiedDate.ToString("dd MMMM yyyy");

                Literal litRemarks = (Literal)item.FindControl("litRemarks");
                litRemarks.Text = objCostSheetRemarks.Remarks;

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objCostSheetRemarks.ID.ToString());
                linkDelete.Attributes.Add("type", "factory");
            }
        }

        protected void rptCostSheetImages_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is PatternTemplateImageBO)
            {
                PatternTemplateImageBO objPatternTemplate = (PatternTemplateImageBO)item.DataItem;
                string costsheetimage = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + objPatternTemplate.Pattern.ToString() + "/" + objPatternTemplate.Filename + objPatternTemplate.Extension;

                if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + costsheetimage))
                {
                    costsheetimage = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }
                System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + costsheetimage);
                SizeF origImageSize = VLOrigImage.PhysicalDimension;
                VLOrigImage.Dispose();

                List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 300);

                Label lblItemName = (Label)item.FindControl("lblItemName");
                lblItemName.Text = objPatternTemplate.Filename;

                System.Web.UI.WebControls.Image imgCostSheet = (System.Web.UI.WebControls.Image)item.FindControl("imgCostSheet");
                imgCostSheet.ImageUrl = costsheetimage;
                imgCostSheet.Width = int.Parse(lstImgDimensions[1].ToString());
                imgCostSheet.Height = int.Parse(lstImgDimensions[0].ToString());

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                //linkDelete.Attributes.Add("qid", objPatternTemplate.ID.ToString());

                HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                //linkEdit.Attributes.Add("qid", objPatternTemplate.ID.ToString());
            }
        }

        protected void btnDeleteCostSheetImage_OnClick(object sender, EventArgs e)
        {

        }

        protected void dgIndimanViewNote_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (e.Item.ItemIndex > -1 && item.DataItem is IndimanCostSheetRemarksBO)
            {
                IndimanCostSheetRemarksBO objIndimanCostSheetRemarks = (IndimanCostSheetRemarksBO)item.DataItem;

                Literal litModifier = (Literal)item.FindControl("litModifier");
                litModifier.Text = objIndimanCostSheetRemarks.objModifier.GivenName + " " + objIndimanCostSheetRemarks.objModifier.FamilyName;

                Literal litModifiedDate = (Literal)item.FindControl("litModifiedDate");
                litModifiedDate.Text = objIndimanCostSheetRemarks.ModifiedDate.ToString("dd MMMM yyyy");

                Literal litRemarks = (Literal)item.FindControl("litRemarks");
                litRemarks.Text = objIndimanCostSheetRemarks.Remarks;

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objIndimanCostSheetRemarks.ID.ToString());
                linkDelete.Attributes.Add("type", "indiman");

            }
        }

        protected void aPrintJKCostSheet_Click(object sender, EventArgs e)
        {
            try
            {
                if (this.QueryID > 0)
                {
                    string pdfFilePath = Common.GenerateOdsPdf.GenerateJKCostSheetPDF(this.QueryID);
                    this.DownloadPDFFile(pdfFilePath);
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while printing JKCostSheet", ex);
            }
        }

        protected void btnDeleteCostSheet_OnClick(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {

                int id = int.Parse(this.hdnRemarks.Value);
                string type = this.hdnRemarksType.Value;
                try
                {
                    if (id > 0 && !(string.IsNullOrEmpty(type)))
                    {
                        if (type == "indiman")
                        {
                            using (TransactionScope ts = new TransactionScope())
                            {
                                IndimanCostSheetRemarksBO objIndimanCostSheetRemarks = new IndimanCostSheetRemarksBO(this.ObjContext);
                                objIndimanCostSheetRemarks.ID = id;
                                objIndimanCostSheetRemarks.GetObject();

                                objIndimanCostSheetRemarks.Delete();

                                this.ObjContext.SaveChanges();
                                ts.Complete();
                            }
                        }
                        else
                        {
                            using (TransactionScope ts = new TransactionScope())
                            {
                                CostSheetRemarksBO objCostSheetRemarks = new CostSheetRemarksBO(this.ObjContext);
                                objCostSheetRemarks.ID = id;
                                objCostSheetRemarks.GetObject();

                                objCostSheetRemarks.Delete();

                                this.ObjContext.SaveChanges();
                                ts.Complete();
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while deleting Remarks from AddEditFactoryCostSheet.aspx page", ex);
                }
            }

            ViewState["deleteFabric"] = false;
            ViewState["deleteAccessory"] = false;

            // set to null data Grids
            this.dgAccessories.DataSource = null;
            this.dgAccessories.DataBind();

            this.dgAddEditFabrics.DataSource = null;
            this.dgAddEditFabrics.DataBind();

            this.PopulateCostSheet(false);
        }

        protected void aPrintIndimanCostSheet_Click(object sender, EventArgs e)
        {
            try
            {
                if (this.QueryID > 0)
                {
                    string pdfFilePath = Common.GenerateOdsPdf.GenerateIndimanCostSheet(this.QueryID);
                    this.DownloadPDFFile(pdfFilePath);
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while printing Indiman Cost Sheet", ex);
            }
        }

        protected void btnClone_ServerClick(object sender, EventArgs e)
        {
            if (this.QueryID > 0)
            {
                Response.Redirect("AddEditFactoryCostSheet.aspx?cloneid=" + this.QueryID.ToString());
            }
        }

        protected void btnShowHide_Click(object sender, EventArgs e)
        {
            if (this.QueryID > 0)
            {
                CostSheetBO objCostSheet = new CostSheetBO(this.ObjContext);
                objCostSheet.ID = this.QueryID;
                objCostSheet.GetObject();

                objCostSheet.ShowToIndico = !objCostSheet.ShowToIndico;

                this.ObjContext.SaveChanges();

                this.btnShowHide.Text = (objCostSheet.ShowToIndico) ? "Hide from Indico" : "Show to Indico";
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            //Header Text
            this.litHeaderText.Text = ((this.QueryID > 0) ? "Edit " : "New ") + this.ActivePage.Heading;
            this.aPrintIndimanCostSheet.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator && this.QueryID > 0) ? true : false;

            //populate pattern
            this.ddlPattern.Items.Clear();
            this.ddlPattern.Items.Add(new ListItem("Please select or type...", "0"));
            List<PatternBO> lstPatterns = (new PatternBO()).SearchObjects().Where(o => o.IsActive == true).OrderBy(o => o.Number).ToList();
            foreach (PatternBO pat in lstPatterns)
            {
                this.ddlPattern.Items.Add(new ListItem(pat.Number + " - " + pat.NickName, pat.ID.ToString()));
            }

            //populate fabrics
            this.ddlFabric.Items.Clear();
            this.ddlFabric.Items.Add(new ListItem("Please select or type...", "0"));
            List<FabricCodeBO> lstFabrics = (new FabricCodeBO()).SearchObjects().OrderBy(o => o.Code).ToList();
            foreach (FabricCodeBO fab in lstFabrics)
            {
                string price = (fab.FabricPrice != null) ? Convert.ToDecimal(fab.FabricPrice.ToString()).ToString("0.00") : "0.00";
                this.ddlFabric.Items.Add(new ListItem(fab.Code + " - " + fab.Name + " - " + " ( " + price + " )", fab.ID.ToString()));
            }

            this.ddlFabrics.Items.Clear();
            this.ddlFabrics.Items.Add(new ListItem("Please select or type...", "0"));
            List<FabricCodeBO> lstPureFabrics = (new FabricCodeBO()).SearchObjects().Where(m => m.IsPure).OrderBy(o => o.Code).ToList();
            foreach (FabricCodeBO fab in lstPureFabrics)
            {
                string price = (fab.FabricPrice != null) ? Convert.ToDecimal(fab.FabricPrice.ToString()).ToString("0.00") : "0.00";

                this.ddlFabrics.Items.Add(new ListItem(fab.Code + " - " + fab.Name + " - " + " ( " + price + " )", fab.ID.ToString()));
            }
            //populate Accessories
            this.ddlAccessory.Items.Clear();
            this.ddlAccessory.Items.Add(new ListItem("Please select or type...", "0"));
            List<AccessoryBO> lstAccessories = (new AccessoryBO()).SearchObjects().OrderBy(o => o.Name).ToList();
            foreach (AccessoryBO acc in lstAccessories)
            {
                string price = (acc.Cost != null) ? Convert.ToDecimal(acc.Cost.ToString()).ToString("0.00") : "0.00";

                this.ddlAccessory.Items.Add(new ListItem(acc.Name + " - " + " ( " + price + " )", acc.ID.ToString()));
            }
            //populate TextBox Factory
            this.txttotalFabricCost.Text = "0.00";
            this.txtAccessoriesCost.Text = "0.00";
            this.txtWastage.Text = "3.0";
            this.txtFinance.Text = "4.0";
            this.txtsmvrate.Text = "0.15";
            this.txtLabelCost.Text = "0.10";
            this.txtPacking.Text = "0.30";
            this.txtHeatPressOverhead.Text = "1.15";
            this.txtCM.Text = "0.00";

            //populate TextBox Indiman
            this.txtAirFreight.Text = "1.15";
            this.txtMgtOH.Text = "1.83";
            this.txtIndicoOH.Text = "0.56";
            this.txtMarginRate.Text = "12.5";
            this.txtImpCharges.Text = "0.35";
            this.txtFOB.Text = "0.00";
            this.txtDuty.Text = "1.2";
            this.txtInk.Text = "0.017";
            this.txtInkRate.Text = "80.00";
            this.txtInkCost.Text = (Convert.ToDecimal("0.017") * Convert.ToDecimal("80.00") * Convert.ToDecimal("1.02")).ToString("0.000");
            this.txtPaperRate.Text = "0.80";
            this.txtExchangeRate.Text = "0.70";
            this.txtPaperCost.Text = "0.00";
            this.txtCost1.Text = "0.00";
            this.txtCost2.Text = "0.00";
            this.txtCost3.Text = "0.00";
            this.txtDepar.Text = "0.20";
            this.txtDutyRate.Text = "5.0";
            this.txtCONS1.Text = "0.00";
            this.txtCONS2.Text = "0.00";
            this.txtCONS3.Text = "0.00";
            this.txtRate1.Text = "0.00";
            this.txtRate2.Text = "0.00";
            this.txtRate3.Text = "0.00";

            //populate Indiman Controls
            this.dvIndiman1.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;
            this.dvIndiman2.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;
            this.dvIndiman3.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;
            this.dvIndiman4.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;
            this.dvIndiman5.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;
            this.dvIndiman6.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;
            this.dvIndimanModifier.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;

            // btnClone Visible Hide isNew or IsClone
            this.btnClone.Visible = (this.QueryID == 0 || this.CloneID > 0 || this.Invoice > 0) ? false : true;

            //ddlShow to indico

            Session["Fabrics"] = null;
            Session["Accessories"] = null;

            this.dvShowToIndico.Visible = (this.QueryID > 0) ? false : true;
            this.btnShowHide.Visible = !this.dvShowToIndico.Visible;

            if (this.QueryID > 0)
            {
                this.PopulateCostSheet(true);
            }
            else if (this.CloneID > 0)
            {
                //this.ddlPattern.Enabled = false;
                this.PopulateCloneCostSheet();
            }
            else if (this.PatternID > 0 && this.FabricID > 0)
            {
                this.ddlPattern.Items.FindByValue(this.PatternID.ToString()).Selected = true;
                this.ddlFabric.Items.FindByValue(this.FabricID.ToString()).Selected = true;

                ViewState["MainFabric"] = this.FabricID.ToString();

                //populate fabrics
                this.PopulateFabricDataGrid();

                //populate pattern
                this.PopulatePattern(this.PatternID);

                ViewState["deleteFabric"] = true;
                ViewState["deleteAccessory"] = true;

                this.ddlPattern.Enabled = false;
                this.ddlFabric.Enabled = false;
            }
            else
            {
                //populate fabrics
                this.PopulateFabricDataGrid();

                // populate Accessories
                this.PopulateAccessoriesDataGrid();

                this.ddlShowToIndico.Items.Add(new ListItem("No"));
                this.ddlShowToIndico.Items.Add(new ListItem("Yes"));
            }
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm()
        {
            try
            {
                int costsheetid = 0;
                int oldFabric = 0;
                using (TransactionScope ts = new TransactionScope())
                {
                    CostSheetBO objCostSheet = new CostSheetBO(this.ObjContext);

                    if (this.QueryID > 0)
                    {
                        objCostSheet.ID = this.QueryID;
                        objCostSheet.GetObject();

                        oldFabric = objCostSheet.Fabric;
                    }
                    else
                    {
                        objCostSheet.Creator = this.LoggedUser.ID;
                        objCostSheet.CreatedDate = DateTime.Now;

                        objCostSheet.ShowToIndico = (ddlShowToIndico.SelectedValue == "No") ? false : true;
                    }

                    #region Create Cost Sheet

                    // Factory
                    objCostSheet.Pattern = int.Parse(this.ddlPattern.SelectedValue);
                    objCostSheet.Fabric = int.Parse(this.ddlFabric.SelectedValue);

                    this.SetCostValues(objCostSheet);

                    objCostSheet.MarginRate = Convert.ToDecimal(string.IsNullOrEmpty(this.txtMarginRate.Text) ? "0.00" : this.txtMarginRate.Text.Replace("%", ""));
                    objCostSheet.CalMGN = Convert.ToDecimal(string.IsNullOrEmpty(this.txtCalMgn.Text) ? "0.00" : this.txtCalMgn.Text);
                    objCostSheet.MP = Convert.ToDecimal(string.IsNullOrEmpty(this.txtMp.Text) ? "0.00" : this.txtMp.Text);
                    objCostSheet.QuotedCIF = Convert.ToDecimal(string.IsNullOrEmpty(this.txtQuotedCif.Text) ? "0.00" : this.txtQuotedCif.Text);
                    objCostSheet.FobFactor = Convert.ToDecimal(string.IsNullOrEmpty(this.txtFobFactor.Text) ? "0.00" : this.txtFobFactor.Text);

                    #region Change SMV

                    PatternBO objPattern = new PatternBO(this.ObjContext);
                    objPattern.ID = int.Parse(this.ddlPattern.SelectedValue);
                    objPattern.GetObject();

                    #endregion

                    objPattern.SMV = Convert.ToDecimal(string.IsNullOrEmpty(this.txtsmv.Text) ? "0.00" : this.txtsmv.Text);

                    if (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator)
                    {
                        objCostSheet.Modifier = this.LoggedUser.ID;
                        objCostSheet.ModifiedDate = DateTime.Now;
                    }
                    else if (this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator)
                    {
                        objCostSheet.IndimanModifier = this.LoggedUser.ID;
                        objCostSheet.IndimanModifiedDate = DateTime.Now;
                    }
                    this.ObjContext.SaveChanges();
                    costsheetid = objCostSheet.ID;

                    #endregion

                    #region Save Fabrics

                    foreach (DataGridItem item in dgAddEditFabrics.Items)
                    {
                        PatternSupportFabricBO objPatternSupportFabric = new PatternSupportFabricBO(this.ObjContext);

                        TextBox txtCons = (TextBox)item.FindControl("txtCons");
                        Label litFabricPrice = (Label)item.FindControl("litFabricPrice");

                        if (!string.IsNullOrEmpty(txtCons.Text))
                        {
                            objPatternSupportFabric.Fabric = int.Parse(((System.Web.UI.WebControls.WebControl)(litFabricPrice)).Attributes["id"].ToString());
                            objPatternSupportFabric.FabConstant = Convert.ToDecimal(txtCons.Text);
                            objPatternSupportFabric.CostSheet = costsheetid;

                            this.ObjContext.SaveChanges();
                        }
                        //else
                        //{
                        //    CustomValidator cv = new CustomValidator();
                        //    cv.IsValid = false;
                        //    cv.ValidationGroup = "validateCostsheet";
                        //    cv.ErrorMessage = "Fabric consumption is required";
                        //    Page.Validators.Add(cv);
                        //    return;
                        //}
                    }

                    #endregion

                    #region Save Accessories

                    foreach (DataGridItem item in dgAccessories.Items)
                    {
                        PatternSupportAccessoryBO objPatternSupportAccessory = new PatternSupportAccessoryBO(this.ObjContext);

                        Label litAccessoryPrice = (Label)item.FindControl("litAccessoryPrice");

                        TextBox txtcons = (TextBox)item.FindControl("txtcons");

                        if (!string.IsNullOrEmpty(txtcons.Text))
                        {
                            int id = int.Parse(((System.Web.UI.WebControls.WebControl)(litAccessoryPrice)).Attributes["paid"].ToString());

                            objPatternSupportAccessory.Accessory = int.Parse(((System.Web.UI.WebControls.WebControl)(litAccessoryPrice)).Attributes["id"].ToString());
                            objPatternSupportAccessory.AccConstant = Convert.ToDecimal(txtcons.Text);
                            objPatternSupportAccessory.Pattern = int.Parse(this.ddlPattern.SelectedValue);
                            objPatternSupportAccessory.CostSheet = costsheetid;

                            this.ObjContext.SaveChanges();
                        }
                        //else
                        //{
                        //    CustomValidator cv = new CustomValidator();
                        //    cv.IsValid = false;
                        //    cv.ValidationGroup = "validateCostsheet";
                        //    cv.ErrorMessage = "Accessory consumption is required";
                        //    Page.Validators.Add(cv);
                        //    return;
                        //}
                    }

                    #endregion

                    #region Save Remarks

                    if (this.LoggedUserRoleName == UserRole.FactoryAdministrator || this.LoggedUserRoleName == UserRole.FactoryCoordinator)
                    {
                        if (!string.IsNullOrEmpty(this.txtRemarks.Text))
                        {
                            CostSheetRemarksBO objCostSheetRemarks = new CostSheetRemarksBO(this.ObjContext);
                            objCostSheetRemarks.CostSheet = costsheetid;
                            objCostSheetRemarks.Remarks = this.txtRemarks.Text;
                            objCostSheetRemarks.Modifier = LoggedUser.ID;
                            objCostSheetRemarks.ModifiedDate = DateTime.Now;

                            this.ObjContext.SaveChanges();

                        }
                    }
                    else if (this.LoggedUserRoleName == UserRole.IndimanAdministrator || this.LoggedUserRoleName == UserRole.IndimanCoordinator)
                    {
                        if (!string.IsNullOrEmpty(this.txtRemarks.Text))
                        {
                            IndimanCostSheetRemarksBO objIndimanCostSheetRemarks = new IndimanCostSheetRemarksBO(this.ObjContext);
                            objIndimanCostSheetRemarks.CostSheet = costsheetid;
                            objIndimanCostSheetRemarks.Remarks = this.txtRemarks.Text;
                            objIndimanCostSheetRemarks.Modifier = LoggedUser.ID;
                            objIndimanCostSheetRemarks.ModifiedDate = DateTime.Now;

                            this.ObjContext.SaveChanges();

                        }
                    }

                    #endregion

                    #region Save Price Values

                    List<PriceBO> lstPrices = (from o in (new PriceBO()).SearchObjects()
                                               where o.Pattern == int.Parse(this.ddlPattern.SelectedValue) &&
                                                     o.FabricCode == ((OldFabric > 0) ? OldFabric : int.Parse(this.ddlFabric.SelectedValue))
                                               select o).ToList();
                    PriceBO objPrice = new PriceBO(this.ObjContext);
                    if (lstPrices.Count > 0)
                    {
                        objPrice.ID = lstPrices[0].ID;
                        objPrice.GetObject();
                    }
                    else
                    {
                        objPrice.EnableForPriceList = false;
                        objPrice.Creator = this.LoggedUser.ID;
                        objPrice.CreatedDate = Convert.ToDateTime(DateTime.Now.ToString("g"));
                    }

                    objPrice.Pattern = int.Parse(this.ddlPattern.SelectedValue);
                    objPrice.FabricCode = int.Parse(this.ddlFabric.SelectedValue);
                    objPrice.Modifier = this.LoggedUser.ID;
                    objPrice.ModifiedDate = Convert.ToDateTime(DateTime.Now.ToString("g"));

                    this.ObjContext.SaveChanges();

                    if (lstPrices.Count == 0)
                    {

                        foreach (int priceLevel in (new PriceLevelBO()).GetAllObject().Select(o => o.ID))
                        {
                            PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO(this.ObjContext);

                            decimal indimaprice = (string.IsNullOrEmpty(this.txtQuotedCif.Text)) ? Convert.ToDecimal(string.IsNullOrEmpty(this.txtCIF.Text) ? "0.00" : this.txtCIF.Text) : (this.txtQuotedCif.Text == "0.00") ? Convert.ToDecimal(string.IsNullOrEmpty(this.txtCIF.Text) ? "0.00" : this.txtCIF.Text) : Convert.ToDecimal(this.txtQuotedCif.Text);

                            objPriceLevelCost.FactoryCost = (string.IsNullOrEmpty(this.txtJKFobQuoted.Text)) ? Convert.ToDecimal(string.IsNullOrEmpty(this.txtFobCost.Text) ? "0.00" : this.txtFobCost.Text) : (this.txtJKFobQuoted.Text == "0.00") ? Convert.ToDecimal(string.IsNullOrEmpty(this.txtFobCost.Text) ? "0.00" : this.txtFobCost.Text) : Convert.ToDecimal(this.txtJKFobQuoted.Text);
                            objPriceLevelCost.IndimanCost = (indimaprice == 0) ? objPriceLevelCost.IndimanCost : indimaprice;
                            objPriceLevelCost.Creator = this.LoggedUser.ID;
                            objPriceLevelCost.CreatedDate = DateTime.Now;
                            objPriceLevelCost.Modifier = this.LoggedUser.ID;
                            objPriceLevelCost.ModifiedDate = DateTime.Now;
                            objPriceLevelCost.PriceLevel = priceLevel;
                            objPrice.PriceLevelCostsWhereThisIsPrice.Add(objPriceLevelCost);
                        }
                    }
                    else
                    {
                        List<PriceLevelCostBO> lstPriceLevelCost = (new PriceLevelCostBO()).GetAllObject().Where(o => o.Price == lstPrices[0].ID).ToList();

                        foreach (PriceLevelCostBO plc in lstPriceLevelCost)
                        {
                            PriceLevelCostBO objPriceLevelCost = new PriceLevelCostBO(this.ObjContext);
                            objPriceLevelCost.ID = plc.ID;
                            objPriceLevelCost.GetObject();

                            objPriceLevelCost.FactoryCost = (string.IsNullOrEmpty(this.txtJKFobQuoted.Text)) ? Convert.ToDecimal(string.IsNullOrEmpty(this.txtFobCost.Text) ? "0.00" : this.txtFobCost.Text) : (this.txtJKFobQuoted.Text == "0.00") ? Convert.ToDecimal(string.IsNullOrEmpty(this.txtFobCost.Text) ? "0.00" : this.txtFobCost.Text) : Convert.ToDecimal(this.txtJKFobQuoted.Text);
                            objPriceLevelCost.IndimanCost = (string.IsNullOrEmpty(this.txtQuotedCif.Text)) ? Convert.ToDecimal(string.IsNullOrEmpty(this.txtCIF.Text) ? "0.00" : this.txtCIF.Text) : (this.txtQuotedCif.Text == "0.00") ? Convert.ToDecimal(string.IsNullOrEmpty(this.txtCIF.Text) ? "0.00" : this.txtCIF.Text) : Convert.ToDecimal(this.txtQuotedCif.Text);
                            objPriceLevelCost.Modifier = this.LoggedUser.ID;
                            objPriceLevelCost.ModifiedDate = DateTime.Now;
                        }
                    }

                    #endregion

                    //Update VL fabrics
                    if (this.QueryID > 0)
                    {
                        VisualLayoutBO objVL = new VisualLayoutBO();
                        objVL.Pattern = objCostSheet.Pattern;
                        objVL.FabricCode = oldFabric;
                        List<VisualLayoutBO> lstVLs = objVL.SearchObjects();

                        foreach (int id in lstVLs.Select(m => m.ID))
                        {
                            VisualLayoutBO objVLUpdate = new VisualLayoutBO(this.ObjContext);
                            objVLUpdate.ID = id;
                            objVLUpdate.GetObject();

                            objVLUpdate.FabricCode = objCostSheet.Fabric;
                        }
                    }

                    this.ObjContext.SaveChanges();

                    Session["costsheetid"] = objCostSheet.ID;

                    ts.Complete();
                }

                #region CostSheet Images

                string sourceFileLocation = string.Empty;
                string destinationFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\CostSheet\\" + costsheetid.ToString();
                if (!string.IsNullOrEmpty(this.hdnUploadFiles.Value))
                {

                    // Save Cost Sheet Images
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

                //ViewState["urlQueryID"] = costsheetid;
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while saving data to the Cost Sheet from AddEditFactoryCostSheet.aspx", ex);
            }
        }

        private void PopulatePattern(int Pattern)
        {

            PatternBO objPattern = new PatternBO();
            objPattern.ID = Pattern;
            objPattern.GetObject();
            string TemplateImgLocation = string.Empty;

            this.txtPatternNo.Text = objPattern.Number;
            this.txtItemName.Text = objPattern.objItem.Name;
            this.txtSizeSet.Text = (objPattern.SizeSet != null && objPattern.SizeSet > 0) ? objPattern.objSizeSet.Name : string.Empty;
            this.txtAgeGroup.Text = (objPattern.AgeGroup != null && objPattern.AgeGroup > 0) ? objPattern.objAgeGroup.Name : string.Empty;
            this.txtPrinterType.Text = (objPattern.PrinterType != null && objPattern.PrinterType > 0) ? objPattern.objPrinterType.Name : string.Empty;
            this.txtSubItem.Text = (objPattern.SubItem != null && objPattern.SubItem > 0) ? objPattern.objSubItem.Name : string.Empty;
            this.txtGender.Text = (objPattern.Gender != null && objPattern.Gender > 0) ? objPattern.objGender.Name : string.Empty;
            this.txtNickName.Text = objPattern.NickName;

            this.PopulateCostSheetImages();

            this.dgAccessories.DataSource = null;
            this.dgAccessories.DataBind();

            //List<PatternSupportAccessoryBO> lstPatternSupportAccessory = (new PatternSupportAccessoryBO()).GetAllObject().Where(o => o.Pattern == objPattern.ID).ToList();

            //if (lstPatternSupportAccessory.Count > 0)
            //{
            //    foreach (PatternSupportAccessoryBO psa in lstPatternSupportAccessory)
            //    {
            //        if (this.QueryID > 0)
            //        {
            //            this.PopulateAccessoriesDataGrid(0, false, psa.ID);
            //        }
            //        else
            //        {
            //            this.PopulateAccessoriesDataGrid(0, false, psa.ID);
            //            ViewState["deleteFabric"] = false;
            //            ViewState["deleteAccessory"] = true;
            //        }

            //    }
            //}
            //else
            //{
            //    this.PopulateAccessoriesDataGrid();
            //}
        }

        private void PopulateFabricDataGrid(int id = 0, bool isDeleted = false, int costsheet = 0)
        {
            totalFabCost = 0;
            this.dgAddEditFabrics.DataSource = this.GetFabricData(id, isDeleted, costsheet);
            this.dgAddEditFabrics.DataBind();

            this.dgAddEditFabrics.Visible = (this.dgAddEditFabrics.Items.Count > 0);
            this.dvEmptyFabrics.Visible = !this.dgAddEditFabrics.Visible;

            ClientScript.RegisterStartupScript(this.GetType(), "CalFabrics", "calculateSMV();calculateFabricDataGrid();calculateAccessoryDataGrid();", true);
        }

        private void PopulateAccessoriesDataGrid(int id = 0, bool isDeleted = false, int psaid = 0)
        {
            totalAccCost = 0;
            this.dgAccessories.DataSource = this.GetAccessoryData(id, isDeleted, psaid);
            this.dgAccessories.DataBind();

            this.dgAccessories.Visible = (this.dgAccessories.Items.Count > 0);
            this.dvEmptyAccessories.Visible = !this.dgAccessories.Visible;

            ClientScript.RegisterStartupScript(this.GetType(), "CalAccessories", "calculateFabricDataGrid();calculateAccessoryDataGrid();", true);
        }

        private List<FabricDetails> GetFabricData(int id, bool isDeleted, int costsheet)
        {
            List<FabricDetails> lst = new List<FabricDetails>();

            foreach (DataGridItem item in this.dgAddEditFabrics.Items)
            {
                FabricDetails objItem = new FabricDetails();

                Literal litCode = (Literal)item.FindControl("litCode");
                Literal litFabricNickName = (Literal)item.FindControl("litFabricNickName");
                Literal litFabricSupplier = (Literal)item.FindControl("litFabricSupplier");
                TextBox txtCons = (TextBox)item.FindControl("txtCons");
                Literal litUnit = (Literal)item.FindControl("litUnit");
                Label litFabricPrice = (Label)item.FindControl("litFabricPrice");
                Label lblfabricCost = (Label)item.FindControl("lblfabricCost");
                TextBox txtFabricCost = (TextBox)item.FindControl("txtFabricCost");

                int fabric = int.Parse(((System.Web.UI.WebControls.WebControl)(litFabricPrice)).Attributes["id"].ToString());

                if (fabric != id || costsheet > 0)
                {
                    objItem.Fabric = litCode.Text.Trim();
                    objItem.NickName = litFabricNickName.Text.Trim();
                    objItem.Supplier = litFabricSupplier.Text.Trim();
                    objItem.Constant = txtCons.Text.Trim();
                    objItem.Unit = litUnit.Text.Trim();
                    objItem.FabricPrice = litFabricPrice.Text.Trim();
                    objItem.ID = fabric;
                    objItem.FabricCost = txtFabricCost.Text.Trim();
                    objItem.CostSheet = int.Parse(((System.Web.UI.WebControls.WebControl)(litFabricPrice)).Attributes["costid"].ToString());
                    objItem.patternfabric = int.Parse(((System.Web.UI.WebControls.WebControl)(litFabricPrice)).Attributes["pfid"].ToString());
                    lst.Add(objItem);
                }


            }

            if ((id > 0) && !isDeleted && (costsheet == 0))
            {
                FabricCodeBO objFabric = new FabricCodeBO();
                objFabric.ID = id;
                objFabric.GetObject();

                lst.Add(new FabricDetails()
                {
                    ID = objFabric.ID,
                    Fabric = objFabric.Code,
                    NickName = objFabric.NickName,
                    Supplier = (objFabric.Supplier != null && objFabric.Supplier > 0) ? objFabric.objSupplier.Name : string.Empty,
                    Constant = string.Empty,
                    Unit = (objFabric.Unit != null && objFabric.Unit > 0) ? objFabric.objUnit.Name : string.Empty,
                    FabricPrice = (objFabric.FabricPrice != null) ? Convert.ToDecimal(objFabric.FabricPrice.ToString()).ToString("0.00") : "0.00",
                    FabricCost = "0.00",
                    CostSheet = 0,
                    patternfabric = 0
                });
            }

            if (costsheet > 0)
            {
                PatternSupportFabricBO objPatternFabric = new PatternSupportFabricBO();
                objPatternFabric.ID = costsheet;
                objPatternFabric.GetObject();

                lst.Add(new FabricDetails()
                {
                    ID = objPatternFabric.Fabric,
                    Fabric = objPatternFabric.objFabric.Code,
                    NickName = objPatternFabric.objFabric.NickName,
                    Supplier = (objPatternFabric.objFabric.Supplier != null && objPatternFabric.objFabric.Supplier > 0) ? objPatternFabric.objFabric.objSupplier.Name : string.Empty,
                    Constant = objPatternFabric.FabConstant.ToString("0.00"),
                    Unit = (objPatternFabric.objFabric.Unit != null && objPatternFabric.objFabric.Unit > 0) ? objPatternFabric.objFabric.objUnit.Name : string.Empty,
                    FabricPrice = (objPatternFabric.objFabric.FabricPrice != null) ? Convert.ToDecimal(objPatternFabric.objFabric.FabricPrice.ToString()).ToString("0.00") : "0.00",
                    FabricCost = (objPatternFabric.FabConstant * (objPatternFabric.objFabric.FabricPrice ?? 0)).ToString("0.00"),
                    //Math.Round((objPatternFabric.FabConstant * objPatternFabric.objFabric.FabricPrice ?? 0), 2).ToString(),
                    //(Convert.ToDecimal(Convert.ToDecimal(objPatternFabric.FabConstant.ToString()) * Convert.ToDecimal((objPatternFabric.objFabric.FabricPrice != null) ? objPatternFabric.objFabric.FabricPrice.ToString() : "0.00"))).ToString("0.00"),
                    CostSheet = (this.CloneID > 0) ? 0 : objPatternFabric.CostSheet,
                    patternfabric = objPatternFabric.ID
                });
            }

            Session["Fabrics"] = lst;
            return lst;
        }

        private List<AccessoryDetails> GetAccessoryData(int id, bool isDeleted, int psaid)
        {
            List<AccessoryDetails> lst = new List<AccessoryDetails>();

            foreach (DataGridItem item in dgAccessories.Items)
            {
                AccessoryDetails objAccessory = new AccessoryDetails();

                Literal litName = (Literal)item.FindControl("litName");
                Literal lblAccessoryDescription = (Literal)item.FindControl("lblAccessoryDescription");
                Literal lblSupplier = (Literal)item.FindControl("lblSupplier");
                Label litAccessoryPrice = (Label)item.FindControl("litAccessoryPrice");
                TextBox txtcons = (TextBox)item.FindControl("txtcons");
                Literal litaccessoryUnit = (Literal)item.FindControl("litaccessoryUnit");
                Label lblaccessoryCost = (Label)item.FindControl("lblaccessoryCost");
                TextBox txtAccessoryCost = (TextBox)item.FindControl("txtAccessoryCost");

                int ace = int.Parse(((System.Web.UI.WebControls.WebControl)(litAccessoryPrice)).Attributes["id"].ToString());
                if (ace != id || psaid > 0)
                {
                    objAccessory.Accesssory = litName.Text;
                    objAccessory.Description = lblAccessoryDescription.Text;
                    objAccessory.Supplier = lblSupplier.Text;
                    objAccessory.Price = litAccessoryPrice.Text;
                    objAccessory.ID = ace;
                    objAccessory.Constant = txtcons.Text;
                    objAccessory.Unit = litaccessoryUnit.Text;
                    objAccessory.Cost = txtAccessoryCost.Text;
                    objAccessory.CostSheet = int.Parse(((System.Web.UI.WebControls.WebControl)(litAccessoryPrice)).Attributes["costid"].ToString());
                    objAccessory.patternaccessory = int.Parse(((System.Web.UI.WebControls.WebControl)(litAccessoryPrice)).Attributes["paid"].ToString());
                    lst.Add(objAccessory);
                }
            }

            if (!isDeleted && (id > 0) && (psaid == 0))
            {
                AccessoryBO objAccessory = new AccessoryBO();
                objAccessory.ID = id;
                objAccessory.GetObject();

                lst.Add(new AccessoryDetails()
                {
                    ID = objAccessory.ID,
                    Accesssory = objAccessory.Name,
                    Description = objAccessory.Description,
                    Supplier = (objAccessory.Supplier != null && objAccessory.Supplier > 0) ? objAccessory.objSupplier.Name : string.Empty,
                    Constant = string.Empty,
                    Unit = (objAccessory.Unit != null && objAccessory.Unit > 0) ? objAccessory.objUnit.Name : string.Empty,
                    Price = (objAccessory.Cost != null) ? Convert.ToDecimal(objAccessory.Cost.ToString()).ToString("0.00") : "0.00",
                    Cost = "0.00",
                    CostSheet = 0,
                    patternaccessory = 0
                });
            }

            if (psaid > 0)
            {
                PatternSupportAccessoryBO objPatternAccessory = new PatternSupportAccessoryBO();
                objPatternAccessory.ID = psaid;
                objPatternAccessory.GetObject();

                lst.Add(new AccessoryDetails()
                {
                    ID = objPatternAccessory.Accessory,
                    Accesssory = objPatternAccessory.objAccessory.Name,
                    Description = objPatternAccessory.objAccessory.Description,
                    Supplier = (objPatternAccessory.objAccessory.Supplier != null && objPatternAccessory.objAccessory.Supplier > 0) ? objPatternAccessory.objAccessory.objSupplier.Name : string.Empty,
                    Constant = objPatternAccessory.AccConstant.ToString("0.00"),
                    Unit = (objPatternAccessory.objAccessory.Unit != null && objPatternAccessory.objAccessory.Unit > 0) ? objPatternAccessory.objAccessory.objUnit.Name : string.Empty,
                    Price = (objPatternAccessory.objAccessory.Cost != null) ? Convert.ToDecimal(objPatternAccessory.objAccessory.Cost.ToString()).ToString("0.00") : "0.00",
                    Cost = (objPatternAccessory.AccConstant * (objPatternAccessory.objAccessory.Cost ?? 0)).ToString("0.00"),
                    //(objPatternAccessory.AccConstant * objPatternAccessory.objAccessory.Cost ?? 0).ToString("0.00"),// Convert.ToDecimal((objPatternAccessory.objAccessory.Cost != null) ? objPatternAccessory.objAccessory.Cost.ToString() : "0.00")).ToString("0.00"),
                    CostSheet = (this.CloneID > 0) ? 0 : objPatternAccessory.CostSheet,
                    patternaccessory = objPatternAccessory.ID
                });
            }

            Session["Accessories"] = lst;
            return lst;
        }

        private void PopulateCostSheet(bool isPopulate)
        {
            if (this.QueryID > 0)
            {
                CostSheetBO objCostSheet = new CostSheetBO();
                objCostSheet.ID = this.QueryID;
                objCostSheet.GetObject();

                //Show to indico button
                if (objCostSheet.ShowToIndico == true)
                {
                    btnShowHide.Text = "Hide to Indico";
                }

                if (objCostSheet.ShowToIndico == false)
                {
                    btnShowHide.Text = "Show to Indico";
                }

                // Factory
                this.ddlPattern.Items.FindByValue(objCostSheet.Pattern.ToString()).Selected = true;
                this.ddlFabric.Items.FindByValue(objCostSheet.Fabric.ToString()).Selected = true;

                PopulateCostValues(objCostSheet, false);

                ViewState["MainFabric"] = objCostSheet.Fabric.ToString();
                OldFabric = objCostSheet.Fabric;

                if (objCostSheet.FOBAUD.ToString() == "0.00" && isPopulate == true && this.LoggedUserRoleName == UserRole.IndicoAdministrator)
                {
                    ViewState["CalculateIndiman"] = true;
                }
                else
                {
                    ViewState["CalculateIndiman"] = false;
                }

                PatternSupportFabricBO objPatternSupportFabric = new PatternSupportFabricBO();
                objPatternSupportFabric.CostSheet = this.QueryID;

                if (objPatternSupportFabric.SearchObjects().Count > 0)
                {
                    foreach (PatternSupportFabricBO psf in objPatternSupportFabric.SearchObjects())
                    {
                        this.PopulateFabricDataGrid(0, false, psf.ID);
                    }
                }
                else
                {
                    PopulateFabricDataGrid();
                }

                // visible print jk costsheet button
                this.aPrintJKCostSheet.Visible = true;

                this.PopulatePattern(objCostSheet.Pattern);

                PatternSupportAccessoryBO objPatternSupportAccessory = new PatternSupportAccessoryBO();
                objPatternSupportAccessory.CostSheet = objCostSheet.ID;

                if (objPatternSupportAccessory.SearchObjects().Count > 0)
                {
                    foreach (PatternSupportAccessoryBO psa in objPatternSupportAccessory.SearchObjects())
                    {
                        this.PopulateAccessoriesDataGrid(0, false, psa.ID);
                    }
                }
                else
                {
                    PopulateAccessoriesDataGrid();
                }

                // populate Factory Remarks 
                List<CostSheetRemarksBO> lstCostSheetRemarks = (new CostSheetRemarksBO()).SearchObjects().Where(o => o.CostSheet == this.QueryID).ToList();

                if (lstCostSheetRemarks.Count > 0)
                {
                    dgViewNote.DataSource = lstCostSheetRemarks;
                    dgViewNote.DataBind();
                    this.dvNoFactoryRemarks.Visible = false;
                    this.dgViewNote.Visible = true;
                }
                else
                {
                    this.dgViewNote.Visible = false;
                    this.dvNoFactoryRemarks.Visible = true;
                }

                this.dvIndimanRemarks.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;

                // Populate Indiman Remarks
                List<IndimanCostSheetRemarksBO> lstIndimanCostSheetRemarks = (new IndimanCostSheetRemarksBO()).SearchObjects().Where(o => o.CostSheet == this.QueryID).ToList();
                if (lstIndimanCostSheetRemarks.Count > 0)
                {
                    this.dgIndimanViewNote.DataSource = lstIndimanCostSheetRemarks;
                    this.dgIndimanViewNote.DataBind();
                    this.dvNoIndimanRemarks.Visible = false;
                    this.dgIndimanViewNote.Visible = true;
                }
                else
                {
                    this.dgIndimanViewNote.Visible = false;
                    this.dvNoIndimanRemarks.Visible = true;
                }


                VisualLayoutBO objVL = new VisualLayoutBO();
                objVL.Pattern = objCostSheet.Pattern;
                objVL.FabricCode = objCostSheet.Fabric;
                List<VisualLayoutBO> lst = objVL.SearchObjects();

                this.ddlPattern.Enabled = (this.QueryID > 0) ? false : true;
                //  this.ddlFabric.Enabled = objVL.SearchObjects().Any() ? false : true;

                if (lst.Any())
                {
                    this.lblVLCount.Text = "This Cost Sheet has " + lst.Count + " Visual Layouts added. Changing of Fabric will update them too.";
                }

                if (!isPopulate)
                {
                    ViewState["deleteFabric"] = true;
                    ViewState["deleteAccessory"] = true;
                }
            }
        }

        private void DeleteFabrics(int costsheetid)
        {
            try
            {
                List<PatternSupportFabricBO> lstPatternSupportFabric = (new PatternSupportFabricBO()).GetAllObject().Where(o => o.CostSheet == costsheetid).ToList();

                if (lstPatternSupportFabric.Count > 0)
                {
                    using (TransactionScope ts = new TransactionScope())
                    {

                        foreach (PatternSupportFabricBO psf in lstPatternSupportFabric)
                        {
                            PatternSupportFabricBO objPatternSupportFabric = new PatternSupportFabricBO(this.ObjContext);
                            objPatternSupportFabric.ID = psf.ID;
                            objPatternSupportFabric.GetObject();

                            objPatternSupportFabric.Delete();
                        }
                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }

                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Deleting Fabric data to the Cost Sheet from AddEditFactoryCostSheet.aspx", ex);
            }

        }

        private void DeleteAccessory(int id)
        {
            try
            {
                if (id > 0)
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        PatternSupportAccessoryBO objPatternSupportAccessory = new PatternSupportAccessoryBO(this.ObjContext);
                        objPatternSupportAccessory.ID = id;
                        objPatternSupportAccessory.GetObject();

                        objPatternSupportAccessory.Delete();


                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Deleting Accessory data to the Cost Sheet from AddEditFactoryCostSheet.aspx", ex);
            }
        }

        private void DeleteAccessories(int CostSheet)
        {
            try
            {
                if (CostSheet > 0)
                {

                    List<PatternSupportAccessoryBO> lstPatternSupportaccessory = (new PatternSupportAccessoryBO()).GetAllObject().Where(o => o.CostSheet == CostSheet).ToList();

                    using (TransactionScope ts = new TransactionScope())
                    {
                        foreach (PatternSupportAccessoryBO psf in lstPatternSupportaccessory)
                        {

                            PatternSupportAccessoryBO objPatternSupportAccessory = new PatternSupportAccessoryBO(this.ObjContext);
                            objPatternSupportAccessory.ID = psf.ID;
                            objPatternSupportAccessory.GetObject();

                            objPatternSupportAccessory.Delete();

                        }

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Deleting Accessory data to the Cost Sheet from AddEditFactoryCostSheet.aspx", ex);
            }
        }

        /* private void GetData()
         {
             int fabric = int.Parse(this.ddlFabric.SelectedValue);
             int pattern = int.Parse(this.ddlPattern.SelectedValue);

             List<FabricDetails> lstFabrics = (List<FabricDetails>)Session["Fabrics"];
             lstFabrics = lstFabrics.Where(o => o.ID == fabric).ToList();

             if (fabric > 0)
             {
                 if (pattern > 0)
                 {
                     int costsheet = (new CostSheetBO()).SearchObjects().Where(o => o.Pattern == pattern && o.Fabric == fabric).Select(o => o.ID).SingleOrDefault();
                     if (costsheet > 0)
                     {
                         dgAccessories.DataSource = null;
                         dgAccessories.DataBind();

                         dgAddEditFabrics.DataSource = null;
                         dgAddEditFabrics.DataBind();

                         ViewState["urlQueryID"] = costsheet;
                         this.PopulateCostSheet(true);
                     }
                     else
                     {
                         if (lstFabrics.Count == 0)
                         {
                             this.PopulateFabricDataGrid(fabric);
                         }
                     }
                 }
                 else
                 {
                     if (lstFabrics.Count == 0)
                     {
                        
                     }
                 }
             }

             this.ddlFabrics.SelectedIndex = 0;
             ViewState["deleteFabric"] = false;
             ViewState["deleteAccessory"] = false;
         }*/

        private void ValidDataGrids()
        {
            CustomValidator cv = null;

            foreach (DataGridItem item in dgAddEditFabrics.Items)
            {
                //PatternSupportFabricBO objPatternSupportFabric = new PatternSupportFabricBO(this.ObjContext);

                TextBox txtCons = (TextBox)item.FindControl("txtCons");
                Label litFabricPrice = (Label)item.FindControl("litFabricPrice");

                if (string.IsNullOrEmpty(txtCons.Text))
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "validateCostsheet";
                    cv.ErrorMessage = "Fabric consumption is required";
                    Page.Validators.Add(cv);
                }
            }

            foreach (DataGridItem item in dgAccessories.Items)
            {
                PatternSupportAccessoryBO objPatternSupportAccessory = new PatternSupportAccessoryBO(this.ObjContext);

                Label litAccessoryPrice = (Label)item.FindControl("litAccessoryPrice");

                TextBox txtcons = (TextBox)item.FindControl("txtcons");

                if (string.IsNullOrEmpty(txtcons.Text))
                {

                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "validateCostsheet";
                    cv.ErrorMessage = "Accessory consumption is required";
                    Page.Validators.Add(cv);
                }
            }

            int fabric = int.Parse(this.ddlFabric.SelectedValue);
            if (fabric > 0)
            {
                List<FabricDetails> lstFabrics = (List<FabricDetails>)Session["Fabrics"];

                if (lstFabrics != null)
                {
                    lstFabrics = lstFabrics.Where(o => o.ID == fabric).ToList();

                    // check if pattern was selected before select the main fabic
                    if (int.Parse(this.ddlPattern.SelectedValue) > 0)
                    {
                        CostSheetBO objCostSheet = new CostSheetBO();
                        objCostSheet.Pattern = int.Parse(this.ddlPattern.SelectedValue);
                        objCostSheet.Fabric = fabric;
                        List<CostSheetBO> lstCostSheet = objCostSheet.SearchObjects();

                        // Check if this pattern and fabric use in another cost sheet
                        if (lstCostSheet.Count == 0)
                        {
                            if (lstCostSheet.Any())
                            {
                                if (this.QueryID == 0)
                                {
                                    cv = new CustomValidator();
                                    cv.IsValid = false;
                                    cv.ValidationGroup = "validateCostsheet";
                                    cv.ErrorMessage = "<p>Cost Sheet exists for this pattern and main Fabric in the System.</p>     <p><a href=\"AddEditFactoryCostSheet.aspx?id=" + lstCostSheet[0] + "\" class=\"btn\">View Cost Sheet</a><p>";
                                    Page.Validators.Add(cv);
                                }
                            }
                            else
                            {
                                //  this.PopulateFabricDataGrid(fabric);
                            }

                            //// check  if new cost sheet or edited cost sheet
                            //if (this.QueryID > 0)
                            //{
                            //    // check if this fabric already in the system
                            //    if (lstFabrics.Count == 0)
                            //    {
                            //        // change the main fabric. Exist fabric remove from the system 
                            //        //this.DeleteMainFabric();

                            //        /* if (ViewState["MainFabric"] != null && int.Parse(ViewState["MainFabric"].ToString()) > 0)
                            //         {
                            //             this.PopulateFabricDataGrid(int.Parse(ViewState["MainFabric"].ToString()), true);
                            //         }
                            //         else if (ViewState["XFabric"] != null && int.Parse(ViewState["XFabric"].ToString()) > 0)
                            //         {
                            //             this.PopulateFabricDataGrid(int.Parse(ViewState["XFabric"].ToString()), true);
                            //         }*/

                            //        //this.PopulateFabricDataGrid(fabric);
                            //        ViewState["MainFabric"] = null;
                            //    }
                            //    else
                            //    {
                            //        cv = new CustomValidator();
                            //        cv.IsValid = false;
                            //        cv.ValidationGroup = "validateCostsheet";
                            //        cv.ErrorMessage = "Cost Sheet for this Fabric exists in the system.";
                            //        Page.Validators.Add(cv);
                            //        //  this.ddlFabric.Items.FindByValue(ViewState["MainFabric"].ToString()).Selected = true;
                            //    }
                            //}
                            //else
                            //{
                            //    // check if this fabric already in the system
                            //    if (lstFabrics.Count == 0)
                            //    {
                            //        /*if (ViewState["XFabric"] != null && int.Parse(ViewState["XFabric"].ToString()) > 0)
                            //        {
                            //            this.PopulateFabricDataGrid(int.Parse(ViewState["XFabric"].ToString()), true);
                            //        }*/

                            //        //this.PopulateFabricDataGrid(int.Parse(this.ddlFabric.SelectedValue));
                            //    }
                            //}
                        }
                        else
                        {
                            bool shouldValidate = false;

                            if (this.QueryID == 0)
                            {
                                shouldValidate = true;
                            }
                            else
                            {
                                if (lstCostSheet.Select(m => m.ID).Contains(this.QueryID))
                                {
                                    shouldValidate = false;
                                }
                                else
                                {
                                    shouldValidate = true;
                                }
                            }

                            if (shouldValidate)
                            {
                                cv = new CustomValidator();
                                cv.IsValid = false;
                                cv.ValidationGroup = "validateCostsheet";
                                cv.ErrorMessage = "<p>Cost Sheet exists for this pattern and main Fabric in the System.</p>     <p><a href=\"AddEditFactoryCostSheet.aspx?id=" + lstCostSheet[0].ID + "\" class=\"btn\">View Cost Sheet</a><p>";
                                Page.Validators.Add(cv);
                            }
                        }
                    }
                    else
                    {
                        cv = new CustomValidator();
                        cv.IsValid = false;
                        cv.ValidationGroup = "validateCostsheet";
                        cv.ErrorMessage = "Select the Pattern";
                        Page.Validators.Add(cv);
                        this.ddlFabric.SelectedIndex = 0;
                    }
                }
            }
        }

        private void PopulateCostSheetImages()
        {
            PatternTemplateImageBO objPatternTemplate = new PatternTemplateImageBO();
            objPatternTemplate.Pattern = int.Parse(this.ddlPattern.SelectedValue);
            objPatternTemplate.IsHero = true;
            List<PatternTemplateImageBO> lstPatternTemplates = objPatternTemplate.SearchObjects();
            this.dvCostSheetImages.Visible = true;
            string costsheetimage = string.Empty;


            if (lstPatternTemplates.Count > 0)
            {
                costsheetimage = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + lstPatternTemplates[0].Pattern.ToString() + "/" + lstPatternTemplates[0].Filename + lstPatternTemplates[0].Extension;

                if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + costsheetimage))
                {
                    costsheetimage = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                }

                System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + costsheetimage);
                SizeF origImageSize = VLOrigImage.PhysicalDimension;
                VLOrigImage.Dispose();

                List<float> lstImgDimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 300);


                lblItemName.Text = lstPatternTemplates[0].Filename;


                imgCostSheet.ImageUrl = costsheetimage;
                imgCostSheet.Width = int.Parse(lstImgDimensions[1].ToString());
                imgCostSheet.Height = int.Parse(lstImgDimensions[0].ToString());
                this.dvCostSheetImages.Visible = true;
            }
            else
            {
                imgCostSheet.ImageUrl = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";
                lblItemName.Text = "noimage-png-350px-350px";
            }
        }

        private void DeleteMainFabric()
        {
            try
            {
                List<FabricDetails> lstFabrics = (List<FabricDetails>)Session["Fabrics"];

                if (lstFabrics != null)
                {
                    lstFabrics = lstFabrics.Where(o => o.ID == int.Parse(ViewState["MainFabric"].ToString())).ToList();

                    if (lstFabrics.Count > 0)
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {

                            foreach (FabricDetails psf in lstFabrics)
                            {
                                PatternSupportFabricBO objPatternSupportFabric = new PatternSupportFabricBO(this.ObjContext);
                                objPatternSupportFabric.ID = psf.patternfabric;
                                objPatternSupportFabric.GetObject();

                                objPatternSupportFabric.Delete();
                            }

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while deleting main fabic from PatternSupportFabricBO in AddEditFactoryCostSheet.aspx page", ex);
            }
        }

        private void PopulateCloneCostSheet()
        {
            if (this.CloneID > 0)
            {
                CostSheetBO objCostSheet = new CostSheetBO();
                objCostSheet.ID = this.CloneID;
                objCostSheet.GetObject();

                // Factory
                this.ddlPattern.Items.FindByValue(objCostSheet.Pattern.ToString()).Selected = true;

                PopulateCostValues(objCostSheet, true);

                //this.ddlFabric.Items.FindByValue(objCostSheet.Fabric.ToString()).Selected = true;
                //this.txtsmv.Text = Convert.ToDecimal((objCostSheet.objPattern.SMV != null) ? objCostSheet.objPattern.SMV.ToString() : "0.00").ToString("0.00");
                //this.txtsmvrate.Text = Convert.ToDecimal((objCostSheet.SMVRate != null) ? objCostSheet.SMVRate.ToString() : "0").ToString("0.00");
                //this.txtcalccm.Text =  Convert.ToDecimal((objCostSheet.CalculateCM != null) ? objCostSheet.CalculateCM.ToString() : "0").ToString("0.00");
                //this.txttotalFabricCost.Text = Convert.ToDecimal((objCostSheet.TotalFabricCost != null) ? objCostSheet.TotalFabricCost.ToString() : "0").ToString("0.00");
                //this.txtAccessoriesCost.Text = Convert.ToDecimal((objCostSheet.TotalAccessoriesCost != null) ? objCostSheet.TotalAccessoriesCost.ToString() : "0").ToString("0.00");
                //this.txtHeatPressOverhead.Text = Convert.ToDecimal((objCostSheet.HPCost != null) ? objCostSheet.HPCost.ToString() : "0").ToString("0.00");
                //this.txtLabelCost.Text = Convert.ToDecimal((objCostSheet.LabelCost != null) ? objCostSheet.LabelCost.ToString() : "0").ToString("0.00");
                //this.txtPacking.Text = Convert.ToDecimal((objCostSheet.Other != null) ? objCostSheet.Other.ToString() : "0").ToString("0.00");
                //this.txtWastage.Text = Convert.ToDecimal((objCostSheet.Wastage != null) ? objCostSheet.Wastage.ToString() : "0").ToString("0.00");
                //this.txtFinance.Text = Convert.ToDecimal((objCostSheet.Finance != null) ? objCostSheet.Finance.ToString() : "0").ToString("0.00");
                //this.txtCM.Text = Convert.ToDecimal((objCostSheet.CM != null) ? objCostSheet.CM.ToString() : "0").ToString("0.00");
                //this.txtFobCost.Text = Convert.ToDecimal((objCostSheet.JKFOBCost != null) ? objCostSheet.JKFOBCost.ToString() : "0").ToString("0.00");
                //this.txtJKFobQuoted.Text = Convert.ToDecimal((objCostSheet.QuotedFOBCost != null && objCostSheet.QuotedFOBCost != decimal.Parse("0")) ? objCostSheet.QuotedFOBCost.ToString() : (objCostSheet.JKFOBCost != null) ? objCostSheet.JKFOBCost.ToString() : "0").ToString("0.00");
                //this.txtRoundUp.Text = Convert.ToDecimal((objCostSheet.Roundup != null) ? objCostSheet.Roundup.ToString() : "0").ToString("0.00");
                //this.txtSubWastage.Text = Convert.ToDecimal((objCostSheet.SubWastage != null) ? objCostSheet.SubWastage.ToString() : "0").ToString("0.00");
                //this.txtSubFinance.Text = Convert.ToDecimal((objCostSheet.SubFinance != null) ? objCostSheet.SubFinance.ToString() : "0").ToString("0.00");
                //this.txtModifer.Text = (objCostSheet.Modifier != null && objCostSheet.Modifier > 0) ? objCostSheet.objModifier.GivenName + " " + objCostSheet.objModifier.FamilyName : string.Empty;
                //this.txtModifiedDate.Text = (objCostSheet.ModifiedDate != null) ? Convert.ToDateTime(objCostSheet.ModifiedDate.ToString()).ToString("dd MMMM yyyy") : string.Empty;//objCostSheet.ModifiedDate.ToString("dd MMMM yyyy");
                //this.txtIndimanModifier.Text = (objCostSheet.IndimanModifier != null && objCostSheet.IndimanModifier > 0) ? objCostSheet.objIndimanModifier.GivenName + " " + objCostSheet.objIndimanModifier.FamilyName : string.Empty;
                //this.txtIndimanModifiedDate.Text = (objCostSheet.IndimanModifiedDate != null) ? Convert.ToDateTime(objCostSheet.IndimanModifiedDate.ToString()).ToString("dd MMMM yyyy") : string.Empty;//objCostSheet.ModifiedDate.ToString("dd MMMM yyyy");
                //this.txtMarginRate.Text = (objCostSheet.MarginRate != null) ? Convert.ToDecimal(objCostSheet.MarginRate.ToString()).ToString("0.00") : "0.00";
                //this.txtSublimationConsumption.Text = (objCostSheet.SubCons != null) ? Convert.ToDecimal(objCostSheet.SubCons.ToString()).ToString("0.00") : "0.00";
                //this.txtDutyRate.Text = (objCostSheet.DutyRate != null) ? Convert.ToDecimal(objCostSheet.DutyRate.ToString()).ToString("0.00") : "0.00";
                //this.txtCF1.Text = objCostSheet.CF1;
                //this.txtCF2.Text = objCostSheet.CF2;
                //this.txtCF3.Text = objCostSheet.CF3;
                //this.txtCONS1.Text = (objCostSheet.CONS1 != null) ? Convert.ToDecimal(objCostSheet.CONS1.ToString()).ToString("0.00") : "0.00";
                //this.txtCONS2.Text = (objCostSheet.CONS2 != null) ? Convert.ToDecimal(objCostSheet.CONS2.ToString()).ToString("0.00") : "0.00";
                //this.txtCONS3.Text = (objCostSheet.CONS3 != null) ? Convert.ToDecimal(objCostSheet.CONS3.ToString()).ToString("0.00") : "0.00";
                //this.txtRate1.Text = (objCostSheet.Rate1 != null) ? Convert.ToDecimal(objCostSheet.Rate1.ToString()).ToString("0.00") : "0.00";
                //this.txtRate2.Text = (objCostSheet.Rate2 != null) ? Convert.ToDecimal(objCostSheet.Rate2.ToString()).ToString("0.00") : "0.00";
                //this.txtRate3.Text = (objCostSheet.Rate3 != null) ? Convert.ToDecimal(objCostSheet.Rate3.ToString()).ToString("0.00") : "0.00";
                //this.txtInk.Text = (objCostSheet.InkCons != null) ? Convert.ToDecimal(objCostSheet.InkCons.ToString()).ToString("0.000") : "0.000";
                //this.txtInkRate.Text = (objCostSheet.InkRate != null) ? Convert.ToDecimal(objCostSheet.InkRate.ToString()).ToString("0.00") : "0.00";
                //this.txtInkCost.Text = (objCostSheet.InkCost != null) ? Convert.ToDecimal(objCostSheet.InkCost.ToString()).ToString("0.000") : "0.000";
                //this.txtPaper.Text = (objCostSheet.PaperCons != null) ? Convert.ToDecimal(objCostSheet.PaperCons.ToString()).ToString("0.00") : "0.00";
                //this.txtPaperRate.Text = (objCostSheet.PaperRate != null) ? Convert.ToDecimal(objCostSheet.PaperRate.ToString()).ToString("0.00") : "0.00";
                //this.txtPaperCost.Text = (objCostSheet.PaperCost != null) ? Convert.ToDecimal(objCostSheet.PaperCost.ToString()).ToString("0.00") : "0.00";
                //this.txtExchangeRate.Text = (objCostSheet.ExchangeRate != null) ? Convert.ToDecimal(objCostSheet.ExchangeRate.ToString()).ToString("0.00") : "0.00";
                //this.txtFOB.Text = (objCostSheet.FOBAUD != null) ? Convert.ToDecimal(objCostSheet.FOBAUD.ToString()).ToString("0.00") : "0.00";
                //this.txtDuty.Text = (objCostSheet.Duty != null) ? Convert.ToDecimal(objCostSheet.Duty.ToString()).ToString("0.00") : "0.00";
                //this.txtCost1.Text = (objCostSheet.Cost1 != null) ? Convert.ToDecimal(objCostSheet.Cost1.ToString()).ToString("0.00") : "0.00";
                //this.txtCost2.Text = (objCostSheet.Cost2 != null) ? Convert.ToDecimal(objCostSheet.Cost2.ToString()).ToString("0.00") : "0.00";
                //this.txtCost3.Text = (objCostSheet.Cost3 != null) ? Convert.ToDecimal(objCostSheet.Cost3.ToString()).ToString("0.00") : "0.00";
                //this.txtAirFreight.Text = (objCostSheet.AirFregiht != null) ? Convert.ToDecimal(objCostSheet.AirFregiht.ToString()).ToString("0.00") : "0.00";
                //this.txtImpCharges.Text = (objCostSheet.ImpCharges != null) ? Convert.ToDecimal(objCostSheet.ImpCharges.ToString()).ToString("0.00") : "0.00";
                //this.txtMgtOH.Text = (objCostSheet.MGTOH != null) ? Convert.ToDecimal(objCostSheet.MGTOH.ToString()).ToString("0.00") : "0.00";
                //this.txtIndicoOH.Text = (objCostSheet.IndicoOH != null) ? Convert.ToDecimal(objCostSheet.IndicoOH.ToString()).ToString("0.00") : "0.00";
                //this.txtDepar.Text = (objCostSheet.Depr != null) ? Convert.ToDecimal(objCostSheet.Depr.ToString()).ToString("0.00") : "0.00";
                //this.txtLanded.Text = (objCostSheet.Landed != null) ? Convert.ToDecimal(objCostSheet.Landed.ToString()).ToString("0.00") : "0.00";
                //this.txtCIF.Text = (objCostSheet.IndimanCIF != null) ? Convert.ToDecimal(objCostSheet.IndimanCIF.ToString()).ToString("0.00") : "0.00";
                //this.txtCalMgn.Text = (objCostSheet.CalMGN != null) ? Convert.ToDecimal(objCostSheet.CalMGN.ToString()).ToString("0.00") : "0.00";
                //this.txtMp.Text = (objCostSheet.MP != null) ? Convert.ToDecimal(objCostSheet.MP.ToString()).ToString("0.00") : "0.00";
                //this.txtQuotedCif.Text = (objCostSheet.QuotedCIF != null && objCostSheet.QuotedCIF != int.Parse("0")) ? Convert.ToDecimal(objCostSheet.QuotedCIF.ToString()).ToString("0.00") : (objCostSheet.IndimanCIF != null) ? Convert.ToDecimal(objCostSheet.IndimanCIF.ToString()).ToString("0.00") : "0.00";
                //this.txtActMgn.Text = (objCostSheet.ActMgn != null) ? Convert.ToDecimal(objCostSheet.ActMgn.ToString()).ToString("0.00") : "0.00";
                //this.txtQuotedMp.Text = (objCostSheet.QuotedMP != null) ? Convert.ToDecimal(objCostSheet.QuotedMP.ToString()).ToString("0.00") : "0.00";
                //this.txtFobFactor.Text = (objCostSheet.FobFactor != null) ? Convert.ToDecimal(objCostSheet.FobFactor.ToString()).ToString("0.00") : "0.00";
                //this.txtQuotedFOB.Text = (objCostSheet.IndimanFOB != null) ? Convert.ToDecimal(objCostSheet.IndimanFOB.ToString()).ToString("0.00") : "0.00";

                ViewState["MainFabric"] = objCostSheet.Fabric.ToString();

                if (objCostSheet.FOBAUD.ToString() == "0.00" && this.LoggedUserRoleName == UserRole.IndicoAdministrator)
                {
                    ViewState["CalculateIndiman"] = true;
                }
                else
                {
                    ViewState["CalculateIndiman"] = false;
                }

                PatternSupportFabricBO objPatternSupportFabric = new PatternSupportFabricBO();
                objPatternSupportFabric.CostSheet = this.CloneID;
                List<PatternSupportFabricBO> lstPSFabrics = objPatternSupportFabric.SearchObjects().Where(m => m.objFabric.IsPure).ToList();

                if (lstPSFabrics.Any())
                {
                    foreach (PatternSupportFabricBO psf in lstPSFabrics)
                    {
                        this.PopulateFabricDataGrid(0, false, psf.ID);
                    }
                }
                else
                {
                    PopulateFabricDataGrid();
                }

                // visible print jk costsheet button
                this.aPrintJKCostSheet.Visible = true;

                this.PopulatePattern(objCostSheet.Pattern);
                PatternSupportAccessoryBO objPatternSupportAccessory = new PatternSupportAccessoryBO();
                objPatternSupportAccessory.CostSheet = this.CloneID;

                if (objPatternSupportAccessory.SearchObjects().Count > 0)
                {
                    foreach (PatternSupportAccessoryBO psa in objPatternSupportAccessory.SearchObjects())
                    {
                        this.PopulateAccessoriesDataGrid(0, false, psa.ID);
                    }
                }
                else
                {
                    PopulateAccessoriesDataGrid();
                }


                // populate Factory Remarks 

                /* List<CostSheetRemarksBO> lstCostSheetRemarks = (new CostSheetRemarksBO()).SearchObjects().Where(o => o.CostSheet == this.QueryID).ToList();

                 if (lstCostSheetRemarks.Count > 0)
                 {
                     dgViewNote.DataSource = lstCostSheetRemarks;
                     dgViewNote.DataBind();
                     this.dvNoFactoryRemarks.Visible = false;
                     this.dgViewNote.Visible = true;
                 }
                 else
                 {
                     this.dgViewNote.Visible = false;
                     this.dvNoFactoryRemarks.Visible = true;
                 }*/

                this.dvIndimanRemarks.Visible = (this.LoggedUserRoleName == UserRole.IndimanAdministrator) ? true : false;

                ////////////

                // Populate Indiman Remarks
                /*List<IndimanCostSheetRemarksBO> lstIndimanCostSheetRemarks = (new IndimanCostSheetRemarksBO()).SearchObjects().Where(o => o.CostSheet == this.QueryID).ToList();
                if (lstIndimanCostSheetRemarks.Count > 0)
                {
                    this.dgIndimanViewNote.DataSource = lstIndimanCostSheetRemarks;
                    this.dgIndimanViewNote.DataBind();
                    this.dvNoIndimanRemarks.Visible = false;
                    this.dgIndimanViewNote.Visible = true;
                }
                else
                {
                    this.dgIndimanViewNote.Visible = false;
                    this.dvNoIndimanRemarks.Visible = true;
                }*/


                //this.ddlPattern.Enabled = (this.QueryID > 0) ? false : true;
                //this.ddlFabric.Enabled = (this.QueryID > 0) ? false : true;

                ViewState["deleteFabric"] = false;
                ViewState["deleteAccessory"] = false;
            }
        }

        private void PopulateCostValues(CostSheetBO objCostSheet, bool isClone)
        {
            //decimal smv = objCostSheet.objPattern.SMV ?? 0;
            //decimal smvRate = objCostSheet.SMVRate ?? 0;
            //decimal calculatedCM = smv * smvRate;
            //decimal totalFabricCost = objCostSheet.PatternSupportFabricsWhereThisIsCostSheet.Select(m => decimal.Parse((m.FabConstant * (m.objFabric.FabricPrice ?? 0)).ToString("0.00"))).Sum(); // objCostSheet.TotalFabricCost ?? 0;
            //decimal totalAccCost = objCostSheet.PatternSupportAccessorysWhereThisIsCostSheet.Select(m => decimal.Parse((m.AccConstant * (m.objAccessory.Cost ?? 0)).ToString("0.00"))).Sum();  //objCostSheet.TotalAccessoriesCost ?? 0;
            //decimal heatpress = objCostSheet.HPCost;
            //decimal labelCost = objCostSheet.LabelCost;
            //decimal packing = objCostSheet.Other ?? 0;
            //decimal wastage = objCostSheet.Wastage;
            //decimal subWastage = (totalAccCost + heatpress + labelCost + packing) * (wastage / 100);//Convert.ToDecimal(0.03); //Convert.ToDecimal(1.03);
            //decimal finance = objCostSheet.Finance;
            //decimal subFinance = (totalFabricCost + totalAccCost + heatpress + labelCost + packing) * (finance / 100);//Convert.ToDecimal(0.04); // + subWastage
            //decimal FOBCost = calculatedCM + totalFabricCost + totalAccCost + heatpress + labelCost + packing + subWastage + subFinance;
            ////FOBCost = decimal.Truncate(FOBCost * 100) / 100;
            //decimal quotedFOB = ((objCostSheet.QuotedFOBCost ?? 0) > 0) ? (objCostSheet.QuotedFOBCost ?? 0) : FOBCost;
            //decimal roundUp = quotedFOB - FOBCost;
            //decimal dutyRate = objCostSheet.DutyRate ?? 0;

            //decimal cons1 = objCostSheet.CONS1 ?? 0;
            //decimal cons2 = objCostSheet.CONS2 ?? 0;
            //decimal cons3 = objCostSheet.CONS3 ?? 0;
            //decimal rate1 = objCostSheet.Rate1 ?? 0;
            //decimal rate2 = objCostSheet.Rate2 ?? 0;
            //decimal rate3 = objCostSheet.Rate3 ?? 0;
            //decimal cost1 = cons1 * rate1;
            //decimal cost2 = cons2 * rate2;
            //decimal cost3 = cons3 * rate3;

            //decimal exchangeRate = objCostSheet.ExchangeRate ?? 0;
            //decimal fobAUD = (exchangeRate > 0) ? quotedFOB / exchangeRate : 0;
            //decimal duty = (fobAUD * dutyRate) / 100;

            //decimal ink = objCostSheet.InkCons ?? 0;
            //decimal inkRate = objCostSheet.InkRate ?? 0;
            //decimal inkCost = ink * inkRate * Convert.ToDecimal(1.02);

            //decimal paper = (objCostSheet.SubCons ?? 0) * Convert.ToDecimal(1.1); //objCostSheet.PaperCons ?? 0;
            //decimal paperRate = objCostSheet.PaperRate ?? 0;
            //decimal paperCost = paper * paperRate * Convert.ToDecimal(1.2);

            //decimal airFreight = objCostSheet.AirFregiht ?? 0;
            //decimal impCharges = objCostSheet.ImpCharges ?? 0;
            //decimal mgtOH = objCostSheet.MGTOH ?? 0;
            //decimal indicoOH = objCostSheet.IndicoOH ?? 0;
            //decimal depr = objCostSheet.Depr ?? 0;

            //decimal marginRate = objCostSheet.MarginRate ?? 0;
            //decimal landed = fobAUD + duty + cost1 + cost2 + cost3 + inkCost + paperCost + airFreight + impCharges + mgtOH + indicoOH + depr;
            //landed = decimal.Truncate(landed * 100) / 100;
            //decimal indimanCIF = landed / ((100 - marginRate) / 100);
            //indimanCIF = decimal.Truncate(indimanCIF * 100) / 100;
            //decimal calMgn = indimanCIF - landed;
            //decimal calMp = (1 - (landed / indimanCIF)) * 100;

            //decimal quotedCIF = (objCostSheet.QuotedCIF.HasValue && (objCostSheet.QuotedCIF ?? 0) > 0) ? objCostSheet.QuotedCIF.Value
            //    : (objCostSheet.IndimanCIF.HasValue && (objCostSheet.IndimanCIF ?? 0) > 0) ? objCostSheet.IndimanCIF.Value
            //    : 0;

            //decimal actMgn = quotedCIF - landed;
            //decimal quotedMp = (quotedCIF > 0) ? (1 - (landed / quotedCIF)) * 100 : 0;

            CostSheet objCostValues = CalculateCostSheet(objCostSheet);

            this.txtsmv.Text = objCostValues.smv.ToString("0.00");
            this.txtsmvrate.Text = objCostValues.smvRate.ToString("0.000");
            this.txtcalccm.Text = objCostValues.calculatedCM.ToString("0.00");
            this.txttotalFabricCost.Text = objCostValues.totalFabricCost.ToString("0.00");
            this.txtAccessoriesCost.Text = objCostValues.totalAccCost.ToString("0.00");
            this.txtHeatPressOverhead.Text = objCostValues.heatpress.ToString("0.00");
            this.txtLabelCost.Text = objCostValues.labelCost.ToString("0.00");
            this.txtPacking.Text = objCostValues.packing.ToString("0.00");
            this.txtWastage.Text = objCostValues.wastage.ToString("0.00");
            this.txtFinance.Text = objCostValues.finance.ToString("0.00");
            this.txtCM.Text = objCostValues.calculatedCM.ToString("0.00");
            this.txtFobCost.Text = objCostValues.FOBCost.ToString("0.00");
            this.txtJKFobQuoted.Text = (isClone) ? "0.00" : objCostValues.quotedFOB.ToString("0.00");
            this.txtRoundUp.Text = objCostValues.roundUp.ToString("0.00");
            this.txtSubWastage.Text = objCostValues.subWastage.ToString("0.00");
            this.txtSubFinance.Text = objCostValues.subFinance.ToString("0.00");

            this.txtModifer.Text = (objCostSheet.Modifier != null && objCostSheet.Modifier > 0) ? objCostSheet.objModifier.GivenName + " " + objCostSheet.objModifier.FamilyName : string.Empty;
            this.txtModifiedDate.Text = (objCostSheet.ModifiedDate != null) ? Convert.ToDateTime(objCostSheet.ModifiedDate.ToString()).ToString("dd MMMM yyyy") : string.Empty;//objCostSheet.ModifiedDate.ToString("dd MMMM yyyy");
            this.txtIndimanModifier.Text = (objCostSheet.IndimanModifier != null && objCostSheet.IndimanModifier > 0) ? objCostSheet.objIndimanModifier.GivenName + " " + objCostSheet.objIndimanModifier.FamilyName : string.Empty;
            this.txtIndimanModifiedDate.Text = (objCostSheet.IndimanModifiedDate != null) ? Convert.ToDateTime(objCostSheet.IndimanModifiedDate.ToString()).ToString("dd MMMM yyyy") : string.Empty;//objCostSheet.ModifiedDate.ToString("dd MMMM yyyy");

            this.txtMarginRate.Text = objCostValues.marginRate.ToString("0.00");
            this.txtSublimationConsumption.Text = (objCostSheet.SubCons ?? 0).ToString("0.00");
            this.txtDutyRate.Text = objCostValues.dutyRate.ToString("0.00");

            this.txtCF1.Text = objCostSheet.CF1;
            this.txtCF2.Text = objCostSheet.CF2;
            this.txtCF3.Text = objCostSheet.CF3;

            this.txtCONS1.Text = objCostValues.cons1.ToString("0.00");
            this.txtCONS2.Text = objCostValues.cons2.ToString("0.00");
            this.txtCONS3.Text = objCostValues.cons3.ToString("0.00");
            this.txtRate1.Text = objCostValues.rate1.ToString("0.00");
            this.txtRate2.Text = objCostValues.rate2.ToString("0.00");
            this.txtRate3.Text = objCostValues.rate3.ToString("0.00");
            this.txtCost1.Text = objCostValues.cost1.ToString("0.00");
            this.txtCost2.Text = objCostValues.cost2.ToString("0.00");
            this.txtCost3.Text = objCostValues.cost3.ToString("0.00");

            this.txtInk.Text = objCostValues.ink.ToString("0.000");
            this.txtInkRate.Text = objCostValues.inkRate.ToString("0.00");
            this.txtInkCost.Text = objCostValues.inkCost.ToString("0.000");
            this.txtPaper.Text = objCostValues.paper.ToString("0.00");
            this.txtPaperRate.Text = objCostValues.paperRate.ToString("0.00");
            this.txtPaperCost.Text = objCostValues.paperCost.ToString("0.00");

            this.txtExchangeRate.Text = objCostValues.exchangeRate.ToString("0.00");
            this.txtFOB.Text = objCostValues.fobAUD.ToString("0.00");
            this.txtDuty.Text = objCostValues.duty.ToString("0.00");

            this.txtAirFreight.Text = objCostValues.airFreight.ToString("0.00");
            this.txtImpCharges.Text = objCostValues.impCharges.ToString("0.00");
            this.txtMgtOH.Text = objCostValues.mgtOH.ToString("0.00");
            this.txtIndicoOH.Text = objCostValues.indicoOH.ToString("0.00");
            this.txtDepar.Text = objCostValues.depr.ToString("0.00");
            this.txtLanded.Text = objCostValues.landed.ToString("0.00");

            this.txtCIF.Text = objCostValues.indimanCIF.ToString("0.00");
            this.txtCalMgn.Text = objCostValues.calMgn.ToString("0.00");
            this.txtMp.Text = objCostValues.calMp.ToString("0.00");
            this.txtQuotedCif.Text = (isClone) ? "0.00" : objCostValues.quotedCIF.ToString("0.00");
            this.txtActMgn.Text = objCostValues.actMgn.ToString("0.00");
            this.txtQuotedMp.Text = objCostValues.quotedMp.ToString("0.00");
            this.txtFobFactor.Text = (objCostSheet.FobFactor ?? 0).ToString("0.00");
            this.txtQuotedFOB.Text = (objCostValues.quotedCIF - (objCostSheet.FobFactor ?? 0)).ToString("0.00");
        }

        private CostSheetBO SetCostValues(CostSheetBO objCostSheet)
        {
            decimal smv = !string.IsNullOrEmpty(this.txtsmv.Text) ? Convert.ToDecimal(this.txtsmv.Text) : 0; // objCostSheet.objPattern.SMV ?? 0;
            decimal smvRate = !string.IsNullOrEmpty(this.txtsmvrate.Text) ? Convert.ToDecimal(this.txtsmvrate.Text) : 0; // objCostSheet.SMVRate ?? 0
            decimal calculatedCM = smv * smvRate;
            decimal totalFabricCost = !string.IsNullOrEmpty(this.txttotalFabricCost.Text) ? Convert.ToDecimal(this.txttotalFabricCost.Text) : 0; // objCostSheet.TotalFabricCost ?? 0;
            decimal totalAccCost = !string.IsNullOrEmpty(this.txtAccessoriesCost.Text) ? Convert.ToDecimal(this.txtAccessoriesCost.Text) : 0;  //objCostSheet.TotalAccessoriesCost ?? 0;
            decimal heatpress = !string.IsNullOrEmpty(this.txtHeatPressOverhead.Text) ? Convert.ToDecimal(this.txtHeatPressOverhead.Text) : 0;  //objCostSheet.HPCost;
            decimal labelCost = !string.IsNullOrEmpty(this.txtLabelCost.Text) ? Convert.ToDecimal(this.txtLabelCost.Text) : 0;  //objCostSheet.LabelCost;
            decimal packing = !string.IsNullOrEmpty(this.txtPacking.Text) ? Convert.ToDecimal(this.txtPacking.Text) : 0;  //objCostSheet.Other ?? 0;
            decimal wastage = !string.IsNullOrEmpty(this.txtWastage.Text) ? Convert.ToDecimal(this.txtWastage.Text) : 0;  //objCostSheet.Wastage;
            decimal subWastage = (totalAccCost + heatpress + labelCost + packing) * Convert.ToDecimal(0.03);
            decimal finance = !string.IsNullOrEmpty(this.txtFinance.Text) ? Convert.ToDecimal(this.txtFinance.Text) : 0;  // objCostSheet.Finance;
            decimal subFinance = (totalFabricCost + totalAccCost + heatpress + labelCost + packing) * Convert.ToDecimal(0.04);
            decimal FOBCost = calculatedCM + totalFabricCost + totalAccCost + heatpress + labelCost + packing + subWastage + subFinance;
            decimal quotedFOB = !string.IsNullOrEmpty(this.txtJKFobQuoted.Text) ? Convert.ToDecimal(this.txtJKFobQuoted.Text) : 0; // ((objCostSheet.QuotedFOBCost ?? 0) > 0) ? (objCostSheet.QuotedFOBCost ?? 0) : FOBCost;
            decimal dutyRate = !string.IsNullOrEmpty(this.txtDutyRate.Text) ? Convert.ToDecimal(this.txtDutyRate.Text) : 0; //objCostSheet.DutyRate ?? 0;

            decimal cons1 = !string.IsNullOrEmpty(this.txtCONS1.Text) ? Convert.ToDecimal(this.txtCONS1.Text) : 0; //objCostSheet.CONS1 ?? 0;
            decimal cons2 = !string.IsNullOrEmpty(this.txtCONS2.Text) ? Convert.ToDecimal(this.txtCONS2.Text) : 0; //objCostSheet.CONS2 ?? 0;
            decimal cons3 = !string.IsNullOrEmpty(this.txtCONS3.Text) ? Convert.ToDecimal(this.txtCONS3.Text) : 0; //objCostSheet.CONS3 ?? 0;
            decimal rate1 = !string.IsNullOrEmpty(this.txtRate1.Text) ? Convert.ToDecimal(this.txtRate1.Text) : 0; //objCostSheet.Rate1 ?? 0;
            decimal rate2 = !string.IsNullOrEmpty(this.txtRate2.Text) ? Convert.ToDecimal(this.txtRate2.Text) : 0; //objCostSheet.Rate2 ?? 0;
            decimal rate3 = !string.IsNullOrEmpty(this.txtRate3.Text) ? Convert.ToDecimal(this.txtRate3.Text) : 0; //objCostSheet.Rate3 ?? 0;
            decimal cost1 = !string.IsNullOrEmpty(this.txtCost1.Text) ? Convert.ToDecimal(this.txtCost1.Text) : 0; //cons1 * rate1;
            decimal cost2 = !string.IsNullOrEmpty(this.txtCost2.Text) ? Convert.ToDecimal(this.txtCost2.Text) : 0; //cons2 * rate2;
            decimal cost3 = !string.IsNullOrEmpty(this.txtCost3.Text) ? Convert.ToDecimal(this.txtCost3.Text) : 0; //cons3 * rate3;

            decimal exchangeRate = !string.IsNullOrEmpty(this.txtExchangeRate.Text) ? Convert.ToDecimal(this.txtExchangeRate.Text) : 0; // objCostSheet.ExchangeRate ?? 0;
            decimal fobAUD = (exchangeRate > 0) ? quotedFOB / exchangeRate : 0;
            decimal duty = (dutyRate > 0) ? fobAUD / dutyRate : 0;

            decimal ink = !string.IsNullOrEmpty(this.txtInk.Text) ? Convert.ToDecimal(this.txtInk.Text) : 0; // objCostSheet.InkCons ?? 0;
            decimal inkRate = !string.IsNullOrEmpty(this.txtInkRate.Text) ? Convert.ToDecimal(this.txtInkRate.Text) : 0; // objCostSheet.InkRate ?? 0;
            decimal inkCost = ink * inkRate * Convert.ToDecimal(1.02);

            decimal paper = !string.IsNullOrEmpty(this.txtPaper.Text) ? Convert.ToDecimal(this.txtPaper.Text) : 0; //objCostSheet.PaperCons ?? 0;
            decimal paperRate = !string.IsNullOrEmpty(this.txtPaperRate.Text) ? Convert.ToDecimal(this.txtPaperRate.Text) : 0; //objCostSheet.PaperRate ?? 0;
            decimal paperCost = paper * paperRate * Convert.ToDecimal(1.02);

            decimal airFreight = !string.IsNullOrEmpty(this.txtAirFreight.Text) ? Convert.ToDecimal(this.txtAirFreight.Text) : 0; //objCostSheet.AirFregiht ?? 0;
            decimal impCharges = !string.IsNullOrEmpty(this.txtImpCharges.Text) ? Convert.ToDecimal(this.txtImpCharges.Text) : 0; //objCostSheet.ImpCharges ?? 0;
            decimal mgtOH = !string.IsNullOrEmpty(this.txtMgtOH.Text) ? Convert.ToDecimal(this.txtMgtOH.Text) : 0; //objCostSheet.MGTOH ?? 0;
            decimal indicoOH = !string.IsNullOrEmpty(this.txtIndicoOH.Text) ? Convert.ToDecimal(this.txtIndicoOH.Text) : 0; //objCostSheet.IndicoOH ?? 0;
            decimal depr = !string.IsNullOrEmpty(this.txtDepar.Text) ? Convert.ToDecimal(this.txtDepar.Text) : 0; //objCostSheet.Depr ?? 0;

            decimal landed = fobAUD + duty + cost1 + cost2 + cost3 + inkCost + paperCost + airFreight + impCharges + mgtOH + indicoOH + depr;

            decimal marginRate = !string.IsNullOrEmpty(this.txtMarginRate.Text) ? Convert.ToDecimal(this.txtMarginRate.Text) : 0;
            decimal subcons = !string.IsNullOrEmpty(this.txtSublimationConsumption.Text) ? Convert.ToDecimal(this.txtSublimationConsumption.Text) : 0;
            decimal indimanCIF = (landed * (100 - marginRate)) / 100;

            objCostSheet.SMVRate = smvRate;
            // objCostSheet.TotalFabricCost = totalFabricCost;
            // objCostSheet.TotalAccessoriesCost = totalAccCost;
            objCostSheet.HPCost = heatpress;
            objCostSheet.LabelCost = labelCost;
            objCostSheet.Other = packing;
            objCostSheet.Wastage = wastage;
            objCostSheet.Finance = finance;
            objCostSheet.QuotedFOBCost = quotedFOB;
            objCostSheet.DutyRate = dutyRate;

            objCostSheet.CONS1 = cons1;
            objCostSheet.CONS2 = cons2;
            objCostSheet.CONS3 = cons3;
            objCostSheet.Rate1 = rate1;
            objCostSheet.Rate2 = rate2;
            objCostSheet.Rate3 = rate3;

            objCostSheet.ExchangeRate = exchangeRate;

            objCostSheet.InkCons = ink;
            objCostSheet.InkRate = inkRate;
            //objCostSheet.PaperCons = paper;
            objCostSheet.PaperRate = paperRate;

            objCostSheet.AirFregiht = airFreight;
            objCostSheet.ImpCharges = impCharges;
            objCostSheet.MGTOH = mgtOH;
            objCostSheet.IndicoOH = indicoOH;
            objCostSheet.Depr = depr;

            objCostSheet.MarginRate = marginRate;
            objCostSheet.SubCons = subcons;

            objCostSheet.CF1 = this.txtCF1.Text;
            objCostSheet.CF2 = this.txtCF2.Text;
            objCostSheet.CF3 = this.txtCF3.Text;

            objCostSheet.IndimanCIF = indimanCIF;
            objCostSheet.QuotedCIF = !string.IsNullOrEmpty(this.txtQuotedCif.Text) ? Convert.ToDecimal(this.txtQuotedCif.Text) : 0;
            objCostSheet.FobFactor = !string.IsNullOrEmpty(this.txtFobFactor.Text) ? Convert.ToDecimal(this.txtFobFactor.Text) : 0;
            //objCostSheet.IndimanFOB = !string.IsNullOrEmpty(this.txtQuotedFOB.Text) ? Convert.ToDecimal(this.txtQuotedFOB.Text) : 0;

            return objCostSheet;
        }

        // Not in use
        private List<FabricCodeBO> GetFabricNotInCostSheet(List<int> lst)
        {
            List<FabricCodeBO> lstPattern = new List<FabricCodeBO>();
            List<int> lstPatternNotInCostSheet = new List<int>();

            List<int> lstCostSheetFabric = (new CostSheetBO()).SearchObjects().Where(o => o.Pattern == int.Parse(this.ddlPattern.SelectedValue)).Select(o => o.Fabric).ToList();

            lstPatternNotInCostSheet = lst.Except(lstCostSheetFabric).ToList();

            if (lstPatternNotInCostSheet.Count > 0)
            {
                foreach (int patid in lstPatternNotInCostSheet)
                {
                    FabricCodeBO objFabricCode = new FabricCodeBO();
                    objFabricCode.ID = patid;
                    objFabricCode.GetObject();

                    lstPattern.Add(objFabricCode);

                }
            }

            return lstPattern.OrderBy(o => o.Code).ToList();
        }

        public CostSheet CalculateCostSheet(CostSheetBO objCostSheet)
        {
            return new CostSheet(objCostSheet);
        }

        #endregion
    }

    #region Internal Classes

    internal class FabricDetails
    {
        public int ID { get; set; }
        public string Fabric { get; set; }
        public string NickName { get; set; }
        public string Supplier { get; set; }
        public string Constant { get; set; }
        public string Unit { get; set; }
        public string FabricPrice { get; set; }
        public string FabricCost { get; set; }
        public int CostSheet { get; set; }
        public int patternfabric { get; set; }
    }

    internal class AccessoryDetails
    {
        public int ID { get; set; }
        public string Accesssory { get; set; }
        public string Description { get; set; }
        public int CostSheet { get; set; }
        public string Supplier { get; set; }
        public string Price { get; set; }
        public string Constant { get; set; }
        public string Unit { get; set; }
        public string Cost { get; set; }
        public int patternaccessory { get; set; }
    }

    public class CostSheet
    {
        public int ID { get; set; }

        public decimal smv { get; set; }
        public decimal smvRate { get; set; }
        public decimal calculatedCM { get; set; }

        public decimal totalFabricCost { get; set; }
        public decimal totalAccCost { get; set; }

        public decimal heatpress { get; set; }
        public decimal labelCost { get; set; }
        public decimal packing { get; set; }
        public decimal wastage { get; set; }
        public decimal subWastage { get; set; }
        public decimal finance { get; set; }
        public decimal subFinance { get; set; }
        public decimal FOBCost { get; set; }
        public decimal quotedFOB { get; set; }

        public decimal roundUp { get; set; }
        public decimal dutyRate { get; set; }

        public decimal cons1 { get; set; }
        public decimal cons2 { get; set; }
        public decimal cons3 { get; set; }
        public decimal rate1 { get; set; }
        public decimal rate2 { get; set; }
        public decimal rate3 { get; set; }
        public decimal cost1 { get; set; }
        public decimal cost2 { get; set; }
        public decimal cost3 { get; set; }

        public decimal exchangeRate { get; set; }
        public decimal fobAUD { get; set; }
        public decimal duty { get; set; }

        public decimal ink { get; set; }
        public decimal inkRate { get; set; }
        public decimal inkCost { get; set; }

        public decimal paper { get; set; }
        public decimal paperRate { get; set; }
        public decimal paperCost { get; set; }

        public decimal airFreight { get; set; }
        public decimal impCharges { get; set; }
        public decimal mgtOH { get; set; }
        public decimal indicoOH { get; set; }
        public decimal depr { get; set; }
        public decimal marginRate { get; set; }
        public decimal landed { get; set; }

        public decimal indimanCIF { get; set; }

        public decimal calMgn { get; set; }
        public decimal calMp { get; set; }
        public decimal quotedCIF { get; set; }

        public decimal actMgn { get; set; }
        public decimal quotedMp { get; set; }

        public CostSheet() { }

        public CostSheet(CostSheetBO objCostSheet)
        {
            this.ID = objCostSheet.ID;

            this.smv = objCostSheet.objPattern.SMV ?? 0;
            this.smvRate = objCostSheet.SMVRate ?? 0;
            this.calculatedCM = smv * smvRate;
            this.totalFabricCost = objCostSheet.PatternSupportFabricsWhereThisIsCostSheet.Select(m => decimal.Parse((m.FabConstant * (m.objFabric.FabricPrice ?? 0)).ToString("0.00"))).Sum();
            this.totalAccCost = objCostSheet.PatternSupportAccessorysWhereThisIsCostSheet.Select(m => decimal.Parse((m.AccConstant * (m.objAccessory.Cost ?? 0)).ToString("0.00"))).Sum();
            this.heatpress = objCostSheet.HPCost;
            this.labelCost = objCostSheet.LabelCost;
            this.packing = objCostSheet.Other ?? 0;
            this.wastage = objCostSheet.Wastage;
            this.subWastage = (totalAccCost + heatpress + labelCost + packing) * (wastage / 100);
            this.finance = objCostSheet.Finance;
            this.subFinance = (totalFabricCost + totalAccCost + heatpress + labelCost + packing) * (finance / 100);
            this.FOBCost = calculatedCM + totalFabricCost + totalAccCost + heatpress + labelCost + packing + subWastage + subFinance;
            this.quotedFOB = (objCostSheet.QuotedCIF.GetValueOrDefault()) - (objCostSheet.FobFactor.GetValueOrDefault());
            this.roundUp = quotedFOB - FOBCost;
            this.dutyRate = objCostSheet.DutyRate ?? 0;

            this.cons1 = objCostSheet.CONS1 ?? 0;
            this.cons2 = objCostSheet.CONS2 ?? 0;
            this.cons3 = objCostSheet.CONS3 ?? 0;
            this.rate1 = objCostSheet.Rate1 ?? 0;
            this.rate2 = objCostSheet.Rate2 ?? 0;
            this.rate3 = objCostSheet.Rate3 ?? 0;
            this.cost1 = cons1 * rate1;
            this.cost2 = cons2 * rate2;
            this.cost3 = cons3 * rate3;

            this.exchangeRate = objCostSheet.ExchangeRate ?? 0;
            this.fobAUD = (exchangeRate > 0) ? quotedFOB / exchangeRate : 0;
            this.duty = (fobAUD * dutyRate) / 100;

            this.ink = objCostSheet.InkCons ?? 0;
            this.inkRate = objCostSheet.InkRate ?? 0;
            this.inkCost = ink * inkRate * Convert.ToDecimal(1.02);

            this.paper = (objCostSheet.SubCons ?? 0) * Convert.ToDecimal(1.1);
            this.paperRate = objCostSheet.PaperRate ?? 0;
            this.paperCost = paper * paperRate * Convert.ToDecimal(1.2);

            this.airFreight = objCostSheet.AirFregiht ?? 0;
            this.impCharges = objCostSheet.ImpCharges ?? 0;
            this.mgtOH = objCostSheet.MGTOH ?? 0;
            this.indicoOH = objCostSheet.IndicoOH ?? 0;
            this.depr = objCostSheet.Depr ?? 0;

            this.marginRate = objCostSheet.MarginRate ?? 0;
            this.landed = fobAUD + duty + cost1 + cost2 + cost3 + inkCost + paperCost + airFreight + impCharges + mgtOH + indicoOH + depr;
            landed = decimal.Truncate(landed * 100) / 100;
            this.indimanCIF = landed / ((100 - marginRate) / 100);
            indimanCIF = decimal.Truncate(indimanCIF * 100) / 100;
            this.calMgn = indimanCIF - landed;
            this.calMp = (1 - (landed / indimanCIF)) * 100;

            this.quotedCIF = (objCostSheet.QuotedCIF.HasValue && (objCostSheet.QuotedCIF ?? 0) > 0) ? objCostSheet.QuotedCIF.Value
                : (objCostSheet.IndimanCIF.HasValue && (objCostSheet.IndimanCIF ?? 0) > 0) ? objCostSheet.IndimanCIF.Value
                : 0;

            this.actMgn = quotedCIF - landed;
            this.quotedMp = (quotedCIF > 0) ? (1 - (landed / quotedCIF)) * 100 : 0;
        }
    }

    #endregion
}
